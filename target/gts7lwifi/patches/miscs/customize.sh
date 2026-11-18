LOG_STEP_IN "- Fixing up /product/etc/build.prop"
sed -i "/# Removed by /d" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/#bluetooth./bluetooth./g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/?=/=/g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "$(sed -n "/provisioning.hostname/=" "$WORK_DIR/product/etc/build.prop" | sed "2p;d")d" "$WORK_DIR/product/etc/build.prop"
LOG_STEP_OUT

LOG_STEP_IN "- Device identity props inherited from UN1CA"
# Two props arrived verbatim from UN1CA's r9q (Galaxy S21 FE) tree in the first device-tree commit
# and shipped on every Tab S7 build since: ro.factory.model=SM-G990B and a Snapdragon 888
# ro.netflix.bsp_rev. A tester proposed deleting them to recover Widevine L1; that was chased and
# neither prop reaches the DRM stack, so this is a correctness fix and nothing more. It will not
# change playback.
#
# ro.factory.model is in NO stock firmware for any of these devices - it is UN1CA's own addition.
# SystemUI reads it, when non-empty, INSTEAD of ro.product.model when picking an edge-lighting
# corner radius. Ours is the donor's SM-X810, which matches no branch, so the override is what
# makes the lookup land. Derive it from the target's own vendor rather than writing a model per
# target: a scaffolded target that copies a hardcoded model is exactly how SM-G990B got here, and
# how the T870 once shipped the T976B's VINTF manifest.
_FM="$(GET_PROP "vendor" "ro.product.vendor.model")"
[ -n "$_FM" ] || ABORT "! vendor ro.product.vendor.model is empty - refusing to guess ro.factory.model"
case "$_FM" in
    SM-*) ;;
    *) ABORT "! vendor ro.product.vendor.model is $_FM - not a Samsung model number" ;;
esac
SET_PROP "system" "ro.factory.model" "$_FM"
[ "$(GET_PROP "system" "ro.factory.model")" = "$_FM" ] || ABORT "! ro.factory.model did not take"
LOG "- ro.factory.model: $_FM (was SM-G990B, a Galaxy S21 FE)"
unset _FM
LOG_STEP_OUT

LOG_STEP_IN "- Enabling adaptive FPS"
SET_PROP "vendor" "ro.surface_flinger.use_content_detection_for_refresh_rate" "false"
# Two props, one -e each (`a` appends in command order, measured - so idle then touch).
#
# ⚠ ro.surface_flinger.set_display_power_timer_ms is deliberately NOT set here.
# UPSTREAM DELETES IT: unica/patches/legacy/customize.sh BACKPORT_SF_PROPS() runs after us and
# drops that prop whenever TARGET_PLATFORM_SDK_VERSION < 35 (every target here is 33), because
# pre-API-35 vendor SurfaceFlinger does not take it. Measured 2026-09-10 in WSL: the sed itself
# appends all three fine in either form, so adding it back only produces a line upstream strips
# again. Do not add it back. If a target moves to an API 35+ vendor, revisit then.
# Drop any existing timer lines first. The 11-inch vendor carries its own set_idle_timer_ms=600 and
# set_touch_timer_ms=300 further down the file, and init keeps the LAST definition of a prop, so
# appending alone left the stock 600/300 in charge (found 2026-09-13 reading the shipped
# vendor/default.prop). Also makes a rerun on a reused work_dir produce one pair, not two.
sed -i \
    -e "/^ro.surface_flinger.set_idle_timer_ms=/d" \
    -e "/^ro.surface_flinger.set_touch_timer_ms=/d" \
    "$WORK_DIR/vendor/default.prop"
# 4500, not 3000 (v1.2.0). The status-bar Wi-Fi activity arrows redraw on a 3 s beat, so a 3000 ms
# timer expired just before every redraw: 60<->120 Hz 18 times a minute, each switch a DRM modeset
# (T970 1.1.3, 17 min idle: 161 up / 160 down, 150 of the ups within 150 ms of an arrow event). At
# 4500 a 3 s gap no longer drops to 60; 6 s+ gaps still do. Estimated ~55% fewer switches for
# 49% -> 42% idle time at 60 Hz. ops/V114_OPTIMIZATION_CANDIDATES.md #8.
sed -i \
    -e "/use_content_detection/a ro.surface_flinger.set_idle_timer_ms=4500" \
    -e "/use_content_detection/a ro.surface_flinger.set_touch_timer_ms=1000" \
    "$WORK_DIR/vendor/default.prop"
LOG_STEP_OUT

LOG_STEP_IN "- Installing the MinsOS AIDL vibrator HAL"
# Android 16 removed the HIDL fallback from libvibratorservice (its DT_NEEDED is AIDL-only and it
# imports zero HIDL symbols), while the T970 vendor only serves HIDL
# vendor.samsung.hardware.vibrator@2.2::ISehVibrator. HIDL and AIDL are separate binder domains, so
# AServiceManager_isDeclared("android.hardware.vibrator.IVibrator/default") is false at boot,
# VibratorManagerService registers zero vibrators, and nothing can vibrate
# (dumpsys showed an empty "Vibrators:" list and "Motor type : MOTOR_NONE (0)").
#
# Transplanting a donor AIDL HAL is impossible: every candidate DT_NEEDs
# android.hardware.vibrator-V{1,2}-ndk_platform.so, which came from the VNDK APEX that Android 16
# removed and which exists in NO firmware tree we hold (T970, X810, S901E, AstroOS y2q, prebuilts).
# So the HAL is built from source instead - see target/gts7xlwifi/vibrator/ and
# minsos-backup/vibrator-hal/. Because the generated AIDL glue is linked STATICALLY, the binary
# needs only libbinder_ndk/liblog/libc++_shared, all of which the ROM already has.
#
# v40 shipped this and boot-looped: declaring ANY AIDL vibrator made system_server crash ten times
# over until Samsung's bootchecker gave up (rescueparty_by_bootchecker). Tombstone:
#
#   signal 11 (SIGSEGV), fault addr 0x0, Cause: null pointer dereference
#   #00 libvibratorservice.so android::vibrator::AidlHalWrapper::supportsHapticEngine()+64
#   #04 com.android.server.vibrator.VibratorController.<init>
#
# supportsHapticEngine() is a Samsung addition, not AOSP. It calls AidlHalWrapper::getSehHal(),
# which is ISehVibrator::fromBinder() over our binder's EXTENSION, and then does `ldr x8, [x0]` on
# the result with no null check. A plain AOSP IVibrator has no such extension, so getSehHal()
# returns null and the framework segfaults on it - 19 unchecked call sites in total.
#
# The HAL now attaches a stub binder whose class descriptor is exactly
# "vendor.samsung.hardware.vibrator.ISehVibrator" and answers STATUS_UNKNOWN_TRANSACTION to
# everything. That is enough: AIBinder_associateClass matches a REMOTE binder on the descriptor
# string alone, so fromBinder() returns a valid proxy and every Samsung-specific query answers
# "unsupported". Nothing links the system-side vendor.samsung.hardware.vibrator-V5-ndk.so, which a
# vendor process could not link anyway (not on the LLNDK allowlist).
#
# Re-enabled after measuring it on the device rather than inferring it. With the HAL running:
#   AIBinder_getExtension   -> status=0, ext non-null
#   AIBinder_associateClass -> 1
# which is exactly what getSehHal() does. The motor was driven directly too
# (motor_type COINDC, /sys/class/timed_output/vibrator/enable) and it buzzes.
#
# If this ever has to go back off: MINSOS_ENABLE_VIBRATOR_HAL=false.
MINSOS_ENABLE_VIBRATOR_HAL="${MINSOS_ENABLE_VIBRATOR_HAL:-true}"
_VIB="$SRC_DIR/target/$TARGET_CODENAME/vibrator"
if [ "$MINSOS_ENABLE_VIBRATOR_HAL" = "true" ] && [ -f "$_VIB/minsos.vibrator-service" ]; then
    # Install the binary and register its metadata by hand (there is no ADD_TO_WORK_DIR helper for a
    # file coming from the device tree rather than a donor firmware). Formats copied from the
    # existing vendor/bin/hw entries: mode "755" (not 0755) in fs_config, dots escaped in
    # file_context. hal_vibrator_default_exec already exists in the T970 vendor policy.
    install -D -m 0755 "$_VIB/minsos.vibrator-service" \
        "$WORK_DIR/vendor/bin/hw/minsos.vibrator-service"
    grep -q "^vendor/bin/hw/minsos.vibrator-service " "$WORK_DIR/configs/fs_config-vendor" || \
        echo "vendor/bin/hw/minsos.vibrator-service 0 2000 755 capabilities=0x0" \
            >> "$WORK_DIR/configs/fs_config-vendor"
    grep -q "minsos\\\\.vibrator-service" "$WORK_DIR/configs/file_context-vendor" || \
        echo "/vendor/bin/hw/minsos\\.vibrator-service u:object_r:hal_vibrator_default_exec:s0" \
            >> "$WORK_DIR/configs/file_context-vendor"
    # The .rc and vintf fragment need metadata too, or they ship unlabeled. Written out literally:
    # generating the escapes with sed emitted a doubled backslash (\\. instead of \.), so the regex
    # never matched the real filenames and both files shipped as u:object_r:unlabeled:s0.
    # servicemanager could then not read the vintf fragment, which makes the WHOLE device manifest
    # parse as NULL - not just this one entry - so every HAL lookup failed, keystore2/gatekeeper/
    # keymaster all died and init was killed. Two extra backslashes cost a boot loop (v39).
    grep -q "^vendor/etc/init/minsos.vibrator-service.rc " "$WORK_DIR/configs/fs_config-vendor" || \
        echo "vendor/etc/init/minsos.vibrator-service.rc 0 0 644 capabilities=0x0" \
            >> "$WORK_DIR/configs/fs_config-vendor"
    grep -q "^vendor/etc/vintf/manifest/minsos.vibrator.xml " "$WORK_DIR/configs/fs_config-vendor" || \
        echo "vendor/etc/vintf/manifest/minsos.vibrator.xml 0 0 644 capabilities=0x0" \
            >> "$WORK_DIR/configs/fs_config-vendor"
    grep -q "minsos\\\\.vibrator-service\\\\.rc" "$WORK_DIR/configs/file_context-vendor" || \
        echo "/vendor/etc/init/minsos\\.vibrator-service\\.rc u:object_r:vendor_configs_file:s0" \
            >> "$WORK_DIR/configs/file_context-vendor"
    grep -q "minsos\\\\.vibrator\\\\.xml" "$WORK_DIR/configs/file_context-vendor" || \
        echo "/vendor/etc/vintf/manifest/minsos\\.vibrator\\.xml u:object_r:vendor_configs_file:s0" \
            >> "$WORK_DIR/configs/file_context-vendor"

    # Never ship this unverified again - an unreadable vintf fragment is an unbootable device.
    if grep minsos "$WORK_DIR/configs/file_context-vendor" | grep -qF '\\.'; then
        ABORT "! file_context-vendor: doubled backslash in a minsos entry - would ship unlabeled"
    fi
    for _f in etc/init/minsos.vibrator-service.rc etc/vintf/manifest/minsos.vibrator.xml \
              bin/hw/minsos.vibrator-service; do
        grep -q "^vendor/$_f " "$WORK_DIR/configs/fs_config-vendor" || \
            ABORT "! fs_config-vendor: no entry for vendor/$_f"
    done
    unset _f
    install -D -m 0644 "$_VIB/minsos.vibrator-service.rc" \
        "$WORK_DIR/vendor/etc/init/minsos.vibrator-service.rc"
    install -D -m 0644 "$_VIB/minsos.vibrator.xml" \
        "$WORK_DIR/vendor/etc/vintf/manifest/minsos.vibrator.xml"

    # The T970 vendor already declares the hal_vibrator_default domain and labels
    # /sys/class/timed_output/vibrator/* as sysfs_vibrator, but ships NO rule letting the HAL domain
    # touch it (stock reached the motor through the Samsung HIDL service instead). Grant exactly that.
    cat <<'VIBCIL' >> "$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
; Added by target/gts7xlwifi/patches/miscs - MinsOS AIDL vibrator HAL
(allow hal_vibrator_default sysfs_vibrator (file (read write open getattr)))
(allow hal_vibrator_default sysfs_vibrator (dir (read search open getattr)))
VIBCIL
    LOG "- MinsOS vibrator HAL installed (binary + rc + vintf fragment + sepolicy)"
elif [ "$MINSOS_ENABLE_VIBRATOR_HAL" != "true" ]; then
    LOG "- MinsOS vibrator HAL disabled (needs an ISehVibrator extension; see comment above)"
else
    LOG "! MinsOS vibrator HAL binary missing - skipped"
fi
unset _VIB
LOG_STEP_OUT
LOG_STEP_IN "- Correcting audio volume curves for quad speakers"
if [ -f "$SRC_DIR/unica/shared/volume_tables/patch_volume_tables.py" ]; then
    python3 "$SRC_DIR/unica/shared/volume_tables/patch_volume_tables.py" "$WORK_DIR/vendor/etc"
    grep -q "^vendor/etc/situation_audio_policy_volumes_sec.xml " "$WORK_DIR/configs/fs_config-vendor" || \
        echo "vendor/etc/situation_audio_policy_volumes_sec.xml 0 0 644 capabilities=0x0" \
            >> "$WORK_DIR/configs/fs_config-vendor"
    grep -q "situation_audio_policy_volumes_sec\\\\.xml" "$WORK_DIR/configs/file_context-vendor" || \
        echo "/vendor/etc/situation_audio_policy_volumes_sec\\.xml u:object_r:vendor_configs_file:s0" \
            >> "$WORK_DIR/configs/file_context-vendor"
    LOG "- Audio volume curves patched for quad speakers (including situation volume table)"
else
    LOGE "unica/shared/volume_tables/patch_volume_tables.py missing - is unica-mods synced?"
    exit 1
fi
LOG_STEP_OUT

