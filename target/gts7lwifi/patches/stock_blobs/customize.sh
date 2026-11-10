LOG_STEP_IN "- Fixing Google Assistant"
DELETE_FROM_WORK_DIR "product" "priv-app/HotwordEnrollmentOKGoogleEx4HEXAGON"
DELETE_FROM_WORK_DIR "product" "priv-app/HotwordEnrollmentXGoogleEx4HEXAGON"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "priv-app/HotwordEnrollmentOKGoogleEx3HEXAGON" 0 0 755 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "priv-app/HotwordEnrollmentXGoogleEx3HEXAGON" 0 0 755 "u:object_r:system_file:s0"
LOG_STEP_OUT

LOG_STEP_IN "- Fixing brightness [Light HAL from A73XQ]"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "bin/hw/vendor.samsung.hardware.light-service"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib64/vendor.samsung.hardware.light-V1-ndk_platform.so"
LOG_STEP_OUT

DELETE_FROM_WORK_DIR "system" "system/etc/permissions/com.sec.feature.cover.flip.xml"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/com.sec.feature.pocketsensitivitymode_level1.xml"
LOG_STEP_IN "- Adding stock system features"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/com.sec.feature.pocketmode_level33.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/com.sec.feature.cover.flip.xml" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/com.sec.feature.cover.xml" 0 0 644 "u:object_r:system_file:s0"
LOG_STEP_OUT

LOG_STEP_IN "- Adding stock GameDriver"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/priv-app/GameDriver-SM8250/GameDriver-SM8250.apk" 0 0 644 "u:object_r:system_file:s0"
LOG_STEP_OUT


LOG_STEP_IN "- Wi-Fi supplicant"
ADD_TO_WORK_DIR "a52qnsxx" "vendor" "bin/hw/wpa_supplicant" 0 2000 755 "u:object_r:hal_wifi_supplicant_default_exec:s0"
LOG_STEP_OUT

LOG_STEP_IN "- Wi-Fi Display sink (Second Screen)"
# THE DONOR'S OWN 64-BIT STACK, UNTOUCHED. This block used to delete the donor's lib64 WFD/HDCP
# libraries and install a52qnsxx's 32-bit ones over them, from the first port commit onward. No
# other UN1CA device tree does that - it was our invention, and nobody tried Second Screen until
# 2026-07-30, when it turned out to fail in two different ways:
#
#   a52qnsxx (32-bit): links, negotiates, then dies as soon as audio starts -
#     F/libc: FORTIFY: pthread_mutex_lock called on a destroyed mutex
#     #04 libremotedisplay_wfd.so (DirectRenderer::AudioRenderer::play()+72)
#   T970 stock (32-bit, tried next): does not even link -
#     CANNOT LINK EXECUTABLE "/system/bin/remotedisplay": cannot locate symbol
#     "...AudioTrackC1E19audio_stream_type_t..." referenced by libremotedisplay_wfd.so
#
# The T970 build is Android 13 and A16 changed the AudioTrack constructor, which is the lesson:
# a WFD sink links against SYSTEM libraries, so the axis that has to match is the PLATFORM
# VERSION, not the SoC. The donor is the platform - its own A16 stack is the only one guaranteed
# to agree with the libaudioclient, libstagefright and libgui this ROM actually ships.
#
# It was believed unusable because libremotedisplay_wfd.so DT_NEEDs libdisplayconfig.system.qti.so
# and vendor.qti.hardware.display.config-V11-ndk.so, which are not in the donor's /system. They
# are in the donor's /system_ext (both bitnesses), which this ROM already ships and which is in
# the same linker namespace - verified present on device at /system_ext/lib64/. So the whole
# premise of the swap was wrong, and the fix is to stop doing it.
#
# HDCP is not involved either way: the sink negotiates mUsingHDCP=0. The hdcp libraries stay
# because libstagefright_hdcp.so and libhdcp2.so DT_NEED libhdcp_client_aidl.so - a missing file
# breaks the link, an absent HAL service does not.
_WFD="$WORK_DIR/system/system"
[ -f "$_WFD/bin/remotedisplay" ] || ABORT "! system/bin/remotedisplay is gone - something deleted the donor's WFD sink"
for _l in libremotedisplay_wfd.so libremotedisplayservice.so libhdcp2.so libhdcp_client_aidl.so \
          libstagefright_hdcp.so libsecuibc.so wfd_log.so; do
    [ -f "$_WFD/lib64/$_l" ] || ABORT "! system/lib64/$_l is missing - the 64-bit sink will not link"
done
unset _l
# 32-bit leftovers from the old swap would be picked over lib64 by nothing, but their presence
# means the swap came back; and bin/remotedisplay must be the donor's 64-bit one, not a 32-bit
# transplant, or it fails at exec with the AudioTrack symbol above.
head -c 5 "$_WFD/bin/remotedisplay" | grep -aq $'\x7fELF\x02' \
    || ABORT "! system/bin/remotedisplay is not a 64-bit ELF - a 32-bit WFD stack was installed again"
LOG "- Wi-Fi Display sink left as the donor built it (64-bit, $(stat -c%s "$_WFD/lib64/libremotedisplay_wfd.so") bytes)"
unset _WFD
LOG_STEP_OUT

LOG_STEP_IN "- Fix face unlock"
# ADD_TO_WORK_DIR without uid/gid/mode/label defaults to 0 0 644 and NO context, and these eight
# lines were the only ones in this file that omitted them - wpa_supplicant two lines up passes
# `0 2000 755 hal_wifi_supplicant_default_exec` and works. The result on device:
#
#   -rw-r--r-- root root  u:object_r:unlabeled:s0            ...face@3.0-service      <- ours
#   -rwxr-xr-x root shell u:object_r:hal_fingerprint_default_exec:s0  ...fingerprint@3.0-service
#
# Not executable and unlabeled, so init could neither exec it nor domain-transition into it. The
# HAL therefore never started, and every biometric request queued behind it forever:
#
#   BiometricScheduler: [Added] {...FaceGenerateChallengeClient...}, new queue size: 16
#   BiometricScheduler: Cannot start next operation.
#
# which is what "face unlock cannot be turned on" looked like - fifteen operations already stacked
# up from boot before Settings was even opened.
#
# The label has to be stated here because vendor's own file_contexts only covers @2.0:
#   /(vendor|system/vendor)/bin/hw/vendor\.samsung\.hardware\.biometrics\.face@2\.0-service
#       u:object_r:hal_face_default_exec:s0
# and this patch deliberately replaces @2.0 with @3.0, which that regex does not match. The type
# itself exists - it is the one the @2.0 rule names.
DELETE_FROM_WORK_DIR "vendor" "bin/hw/vendor.samsung.hardware.biometrics.face@2.0-service"
DELETE_FROM_WORK_DIR "vendor" "etc/init/vendor.samsung.hardware.biometrics.face@2.0-service.rc"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "bin/hw/vendor.samsung.hardware.biometrics.face@3.0-service" \
    0 2000 755 "u:object_r:hal_face_default_exec:s0"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "etc/init/vendor.samsung.hardware.biometrics.face@3.0-service.rc" \
    0 0 644 "u:object_r:vendor_configs_file:s0"
for _l in lib/vendor.samsung.hardware.biometrics.face@2.0.so \
          lib/vendor.samsung.hardware.biometrics.face@3.0.so \
          lib64/vendor.samsung.hardware.biometrics.face@2.0.so \
          lib64/vendor.samsung.hardware.biometrics.face@3.0.so; do
    ADD_TO_WORK_DIR "a73xqxx" "vendor" "$_l" 0 0 644 "u:object_r:vendor_file:s0"
done
unset _l

# Assert it, because the failure mode is silent: the ROM builds, the device boots, and face unlock
# simply never turns on. Modes and contexts as they now sit in configs/, not as intended.
grep -q '^vendor/bin/hw/vendor\.samsung\.hardware\.biometrics\.face@3\.0-service 0 2000 755' \
    "$WORK_DIR/configs/fs_config-vendor" \
    || ABORT "! face HAL is not 0 2000 755 in fs_config-vendor - init cannot exec it"
grep -q 'hal_face_default_exec' "$WORK_DIR/configs/file_context-vendor" \
    || ABORT "! face HAL has no hal_face_default_exec context - it would ship unlabeled"
if grep -e 'biometrics\.face' "$WORK_DIR/configs/file_context-vendor" 2>/dev/null | grep -qF '\\.'; then
    ABORT "! file_context-vendor: doubled backslash in a face HAL entry - it would ship unlabeled"
fi
LOG_STEP_OUT
# The vendor VINTF manifest this patch installs must belong to THIS device. It is not a generic
# file: it is the target's own stock manifest with the face HAL additionally declared at @3.0, and
# it decides which HALs are allowed to register at all.
#
# WHY THIS GUARD EXISTS (2026-08-02, the first T870 boot). Scaffolding target/gts7lwifi copied
# patches/stock_blobs wholesale from the 12.4-inch tree, manifest included - so the 11-inch build
# shipped the SM-T976B's manifest. That file declares the 5G model's radio HALs and, crucially,
# does NOT declare android.hardware.gnss, which the T870's own manifest does. The consequences ran
# all the way to a bootloop and nothing in the build said a word:
#
#   hwservicemanager: Cannot find entry android.hardware.gnss@2.0::IGnss/default in either
#                     framework or device VINTF manifest.
#   HidlServiceManagement: Service ... must be in VINTF manifest in order to register/get.
#   init: Service 'sec_gnss_service' (pid 1921) exited with status 255
#   ... then, 66 seconds later, in system_server's MAIN thread:
#   Watchdog: WATCHDOG KILLING SYSTEM PROCESS: Blocked in handler on main thread (main) for 66s
#     at GnssNative.native_class_init_once(Native Method)
#     at GnssNative.initializeHal / isSupported
#     at LocationManagerService$Lifecycle.onBootPhase
#
# The block is in NATIVE code, which is why grepping the framework for ServiceManager.waitForService
# found nothing and the GNSS failures looked like noise for an afternoon.
#
# So: compare against the target's own extracted firmware. Every HAL name the stock manifest
# declares must still be declared here. Additions are fine (that is the point); losses are not.
# TARGET_FIRMWARE_PATH is NOT reliable inside a patch: deknox already has to rebuild it by hand
# for exactly this reason. Reconstruct it from TARGET_FIRMWARE, glob as a fallback, and ABORT if
# the stock manifest still cannot be found - a guard that quietly skips itself is worse than none,
# and this repository has shipped that mistake before.
_TFP="$(awk -F/ '{print $1"_"$2}' <<< "$TARGET_FIRMWARE")"
_SM="$FW_DIR/$_TFP/vendor/etc/vintf/manifest.xml"
# No glob fallback on purpose: "$FW_DIR"/*/ would happily match the DONOR firmware and compare
# this device against a Tab S9+, which is how a check starts passing for the wrong reason.
_OM="$WORK_DIR/vendor/etc/vintf/manifest.xml"
[ -f "$_SM" ] || ABORT "[$TARGET_CODENAME] cannot find this device's stock vendor manifest to check against (looked for $FW_DIR/$_TFP/...)"
[ -f "$_OM" ] || ABORT "[$TARGET_CODENAME] no vendor VINTF manifest in the work_dir"
_MISSING="$(comm -23     <(grep -oE '<name>[^<]+</name>' "$_SM" | sort -u)     <(grep -oE '<name>[^<]+</name>' "$_OM" | sort -u))"
[ -z "$_MISSING" ] || ABORT "[$TARGET_CODENAME] the shipped vendor VINTF manifest drops HALs this device's stock manifest declares - it is probably another device's file:
$_MISSING"
LOG "- vendor VINTF manifest declares every stock HAL"
unset _TFP _SM _OM _MISSING

# Color inversion (I-07): the patched composer-service is NOT shipped for this codename.
# scripts/patch_composer_service.py hardcodes T970's file size (610696), T970's byte offsets and
# T970's output MD5, so it can only ever produce the SM-T970 binary. Committed on 2026-09-05, that
# one output was copied into all four targets. Measured the same day against each device's own
# stock vendor:
#     SM-T870  610728 B   SM-T875  610720 B   SM-T970  610696 B   SM-T976B  610720 B
# The shipped blob differs from T970 stock in 18 bytes and from T870 stock in 62,018 - it is T970's
# binary, not this device's. I-07 is also described as a 12.4" AMOLED panel symptom, which the
# 11" models are not.
# To ship it here, derive the offsets from THIS device's own stock composer-service and verify the
# result on that hardware. Copying T970's output is how another device's vendor blob ships, which
# the VINTF check a few lines above exists to stop.
#
# Resolution attempt (2026-09-06) - REFUTED ON THE DEVICE, NOT SHIPPED.
# Qualcomm SDM ColorIntfSetColorTransform (0x3b2e4) multiplies the constant m[12..14] by 255.0,
# while ConvertPccCoeff (0x443a8) encodes c * 128 (7 fractional bits). So 1.0 arrives as 32640
# instead of 128. That much is read straight out of the disassembly and still stands.
#
# Patching the multiplier to 1.0 does NOT fix I-07. Measured on the owner's SM-T970 on 2026-09-06
# against the v1.1.2 build that carries the patch:
#   - the patch is genuinely on the device: /vendor/lib64/libsdm-color.so md5 7b99a17d8ae1b2a5...,
#     equal to the build tree's patched copy and different from T970 stock 0b5480098e6008d7...,
#     and the disassembly at 0x3b2e4 reads `nop; nop; fmov d1, #1.0`
#   - the eight-bar photo is IDENTICAL to the pre-patch one: all five greys black, red still red,
#     green black, blue still blue
# Same shape as the composer blob before it: it landed, and nothing changed.
#
# Why it cannot have helped, found while re-reading the same function: 0x3fc84 is not the entry to
# a non-linear path, it is `mov w0, wzr; ret` - the tail of ApplyColorTransformNoLock. So the field
# checks at 0x3fb14 are EARLY RETURNS: when the transform is anything other than a per-channel
# diagonal scale, the function returns 0 without applying. The 255.0 multiplier is never reached
# for an inversion matrix, so its value cannot matter.
#
# The patcher is kept at scripts/patch_sdm_pcc_constant.py with its measurements, but nothing
# invokes it. Do not re-add it without a device photo where the 50% grey bar stays grey.
