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


LOG_STEP_IN "- Cellular: the platform library the Wi-Fi donor does not carry"
# MEASURED CRASH (2026-08-06, tester logcat on a real SM-T875 with a SIM in):
#
#   FATAL EXCEPTION: main   Process: com.android.phone
#   java.lang.NoClassDefFoundError: Failed resolution of:
#     Lcom/samsung/android/sec_platform_library/FactoryPhone;
#     at i.E.<init>(CscWbAmr.java:86) ... CscUpdateService.onStartCommand
#
# in a loop, which is the "Phone services keeps stopping" every cellular owner has reported.
#
# The chain, end to end:
#   - CSC.apk (com.samsung.sec.android.application.csc) runs INSIDE com.android.phone
#     (sharedUserId android.uid.phone) and declares uses-library "sec_platform_library".
#   - Samsung ships sec_platform_library.jar on CELLULAR models only: present and byte-identical
#     on SM-T875 and SM-T976B stock (10,674 B, sha256 2a0437c2...), absent from SM-T970 and
#     SM-T870 stock, and absent from the X810 Wi-Fi donor this ROM is built from.
#   - On the donor that is harmless: the crashing path sits behind CscUtil.isWifiOnly(), which
#     is true there. On a tablet with a modem it is false - the logcat line immediately before
#     the crash is literally "isWifiOnly = false" - so the path runs and the class is not there.
#
# So this is not a broken telephony stack. It is one 10 kB library, and it is restored from THIS
# device's own stock firmware, which is the same rule the rest of this file follows.
#
# Wi-Fi codenames deliberately do not get this: their stock does not have it either, and their
# isWifiOnly() is true, so adding it would be cargo cult.
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/framework/sec_platform_library.jar" 0 0 644 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/sec_platform_library.xml" 0 0 644 "u:object_r:system_file:s0"
[ -f "$WORK_DIR/system/system/framework/sec_platform_library.jar" ] \
    || ABORT "[$TARGET_CODENAME] sec_platform_library.jar did not land - com.android.phone would crash-loop with a SIM in"
[ -f "$WORK_DIR/system/system/etc/permissions/sec_platform_library.xml" ] \
    || ABORT "[$TARGET_CODENAME] sec_platform_library.xml did not land - the library would not be visible to CSC.apk"
grep -q 'name="sec_platform_library"' "$WORK_DIR/system/system/etc/permissions/sec_platform_library.xml" \
    || ABORT "[$TARGET_CODENAME] sec_platform_library.xml does not declare the library"
LOG "- sec_platform_library restored from this device's own stock (fixes the SIM crash loop)"
LOG_STEP_OUT

LOG_STEP_IN "- Cellular: restore multiclientd, the system relay between IMS and the RIL (I-43)"
# One UI 8.5's system IMS stack (libsec-ims.so, libsecril-client.so) reaches the RIL through the
# abstract sockets @Multiclient and @Multiclient2. On stock Android 13 those sockets belong to a
# SYSTEM daemon, /system/bin/multiclientd, which relays to the vendor RIL over the
# vendor.samsung.hardware.radio.bridge HAL. The X810 donor is a Wi-Fi-only tablet and has no
# multiclientd, so nothing listened on @Multiclient: CpAudioEngineClient got ECONNREFUSED and every
# VoLTE call ended after one second with "1007 Audio Create Failure". RILD's own log shows the
# missing client: "sehBridgeService[0]->mSehBridgeIndication == NULL".
#
# v1.1.2 tried to close the gap by renaming the vendor RIL's socket, @VND_Multiclient, to
# @Multiclient in libsec-ril.so. On a real T875N (XDA #527) that turned ECONNREFUSED into EACCES,
# because a system app may not connect to the vendor rild domain, and it cut off every vendor client
# that still uses @VND_Multiclient (engmode, cassd): 16,052 refused reconnects in 18 minutes where
# v1.1.1 had none, and calls still ended with 1007. That rename is gone; libsec-ril.so ships stock.
#
# Why this port needs no SELinux work: the donor's own system_ext policy already declares
# multiclientd, multiclientd_exec, the init transition and the /system/bin/multiclientd file
# context, and this device's stock vendor policy already lets system_app, radio, platform_app and
# system_server connectto it. Only the files are missing. They are Android 13 builds, identical on
# SM-T875 and SM-T976B stock; every undefined symbol in them resolves against the donor's
# system/lib64, bionic and the i18n APEX's libandroidicu (checked 2026-09-24, ops/ISSUES.md I-43).
# The service starts itself: its rc waits for ro.multisim.simslotcount and
# ril.halservice.registered.slotN, both set by this device's stock vendor (secril_config_svc, rild).
_mcd_libs="vendor.samsung.hardware.radio-V1-ndk.so vendor.samsung.hardware.radio.bridge-V1-ndk.so vendor.samsung.hardware.radio.bridge@2.0.so vendor.samsung.hardware.radio.bridge@2.1.so libhwbinder.so"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/bin/multiclientd" 0 2000 755 "u:object_r:multiclientd_exec:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/init/multiclientd.rc" 0 0 644 "u:object_r:system_file:s0"
for _l in $_mcd_libs; do
    # A later donor that already carries one of these is newer than the Android 13 copy: keep it.
    if [ -e "$WORK_DIR/system/system/lib64/$_l" ]; then
        LOG "- $_l is already in the donor system, keeping that one"
        continue
    fi
    ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/lib64/$_l" 0 0 644 "u:object_r:system_lib_file:s0"
done
# Read back what landed rather than trusting the calls above.
[ -f "$WORK_DIR/system/system/bin/multiclientd" ] \
    || ABORT "[$TARGET_CODENAME] multiclientd did not land in system/bin"
grep -q "service multiclient-daemon /system/bin/multiclientd" "$WORK_DIR/system/system/etc/init/multiclientd.rc" \
    || ABORT "[$TARGET_CODENAME] multiclientd.rc did not land or does not start /system/bin/multiclientd"
for _l in $_mcd_libs; do
    [ -f "$WORK_DIR/system/system/lib64/$_l" ] || ABORT "[$TARGET_CODENAME] $_l missing - multiclientd would not link"
done
grep -q "^/system/bin/multiclientd .*u:object_r:multiclientd_exec:s0" "$WORK_DIR/configs/file_context-system" \
    || ABORT "[$TARGET_CODENAME] no multiclientd_exec label for /system/bin/multiclientd - init would not transition"
# The label only means something if the policy that ships still declares the type.
_mcd_cil=$(find "$WORK_DIR/system_ext" "$WORK_DIR/system/system/system_ext" -name system_ext_sepolicy.cil 2>/dev/null | head -1)
grep -q "(type multiclientd_exec)" "$_mcd_cil" 2>/dev/null \
    || ABORT "[$TARGET_CODENAME] the shipped system_ext policy no longer declares multiclientd_exec (${_mcd_cil:-not found})"
# A reused work_dir from a v1.1.2 build would still carry the renamed socket. Catch it here.
if strings -a "$WORK_DIR/vendor/lib64/libsec-ril.so" | grep -qx "Multiclient"; then
    ABORT "[$TARGET_CODENAME] vendor libsec-ril.so still carries the v1.1.2 socket rename - rebuild from a clean work_dir"
fi
strings -a "$WORK_DIR/vendor/lib64/libsec-ril.so" | grep -qx "VND_Multiclient" \
    || ABORT "[$TARGET_CODENAME] vendor libsec-ril.so lost its stock @VND_Multiclient socket name"
LOG "- multiclientd and ${_mcd_libs// /, } restored from this device's stock system"
unset _l _mcd_libs _mcd_cil
LOG_STEP_OUT


LOG_STEP_IN "- Cellular: the Korean IMS DM client LG U+ VoLTE provisions through (I-43)"
# MEASURED (2026-09-26, SM-T875N, LG U+ SIM): VoLTE never registers, KT on the same build does.
#   isOmadmConfigAvailable : DM Package not found
#   regi failed due to empty p-cscf
# The "LGU VoLTE" profile has pcscf_pref=5. For a non-emergency Korean profile the donor imsservice
# then uses only the P-CSCF list the DM client provisioned (RegistrationUtils.retrievePcscfViaOmadm),
# never PCO. RegistrationGovernorKor.isOmadmConfigAvailable() returns false unless
# getPackageInfo("com.ims.dm") succeeds; when it does, NetworkEventController starts the client with
#   update content://com.ims.dm.ContentProvider/imsDmStart {dm_state=10, sim_slot_id}
# and the client answers through ImsManager.startDmConfig / updateConfigValues / finishDmConfig.
# KT's profile takes P-CSCF from PCO, which is why KT never needed any of this.
#
# WHICH BUILD (10-04, XDA #612, SM-T875N on LG U+ with the 1.2.0 test build): the Android 13 client
# (2.9.04, T875NKOS8HXH1, targetSdk 33) died 0.3 s after boot, three times, before it provisioned:
#   MissingForegroundServiceTypeException: Starting FGS without a type ... targetSDK=33
#     at RealNotificationTypeManagerService.notify -> Service.startForeground(int, Notification)
# then the "keeps stopping" dialog, RegiMgr "tryRegister: pcscf is null", and calls end with 2005.
# The Android 16 client from Korean S23 Ultra stock (SM-S918N KOO S918NKSS8FZI1, 3.3.05, targetSdk
# 36) is Samsung's own fix: the same service declares foregroundServiceType="location|systemExempted"
# and calls startForeground(id, n, 0x408). Same platform certificate, sharedUserId and uses-library;
# the only new permissions are the two normal FOREGROUND_SERVICE_* ones, S918N's grant list is the
# same three entries as ours, and S918N's imsservice is the donor's own build (6.0.260907.0).
#
# com.ims.dm (/system/priv-app/OpenImsDm) is on Korean stock only: present in SM-T875N KOO and
# SM-S918N KOO, absent from the SM-T875 INU firmware this target builds from and from the X810
# donor. The donor still carries the rest of stock's wiring for it (allowed-system-preload,
# safe-mode allow list, assign-uid-for-data-usage 2907), so the APK and its grant list are all
# that is missing. It declares sharedUserId android.uid.system and is signed with the donor's own
# platform certificate (v2 cert sha256 34df0e7a...), so only this exact build is acceptable.
# Not committed (.gitignore *.apk): tools/fetch_openimsdm.sh puts it in system/priv-app/OpenImsDm/
# of this patch, and the directory copy above brings it in with the sidecar fs_config lines.
#
# Nothing to gate by region: imsservice only calls it for a Korean MNO on a Korean OMC
# (OmcCode.isKOROmcCode), and it has no boot receiver, so on a non-Korean unit it never starts.
_DM="$WORK_DIR/system/system/priv-app/OpenImsDm/OpenImsDm.apk"
_DMX="$WORK_DIR/system/system/etc/permissions/privapp-permissions-com.ims.dm.xml"
[ -f "$_DM" ] \
    || ABORT "[$TARGET_CODENAME] no OpenImsDm.apk - run tools/fetch_openimsdm.sh (it is not committed); without it LG U+ VoLTE never registers"
[ "$(sha256sum "$_DM" | cut -d' ' -f1)" = "600f3976ccb394f3948da9400af640ba0db3bcb4db929b5a435cb2abf70766ea" ] \
    || ABORT "[$TARGET_CODENAME] OpenImsDm.apk is not the pinned S918NKSS8FZI1 build (3.3.05; the Android 13 2.9.04 crashes on A16, XDA #612)"
# Under ro.control_privapp_permissions=enforce an unlisted signature|privileged request stops the
# boot. SCHEDULE_EXACT_ALARM is one on the A16 donor (it was only "appop" on Android 13, which is
# why the stock file does not list it).
for _p in READ_PRIVILEGED_PHONE_STATE SCHEDULE_EXACT_ALARM; do
    grep -q "android.permission.$_p\"" "$_DMX" 2>/dev/null \
        || ABORT "[$TARGET_CODENAME] privapp-permissions-com.ims.dm.xml does not grant $_p - an enforce build would not boot"
done
grep -q "^system/priv-app/OpenImsDm 0 0 755 " "$WORK_DIR/configs/fs_config-system" \
    || ABORT "[$TARGET_CODENAME] no fs_config entry for /system/priv-app/OpenImsDm - the image build dies on an unlisted path"
grep -q "^system/priv-app/OpenImsDm/OpenImsDm.apk 0 0 644 " "$WORK_DIR/configs/fs_config-system" \
    || ABORT "[$TARGET_CODENAME] no fs_config entry for OpenImsDm.apk - the image build dies on an unlisted path"
grep -q -F '/system/priv-app/OpenImsDm/OpenImsDm\.apk u:object_r:system_file:s0' "$WORK_DIR/configs/file_context-system" \
    || ABORT "[$TARGET_CODENAME] OpenImsDm.apk would ship unlabeled"
# Samsung's PackageManager skips a preload the allow list does not name (the SM8250 GPU packages,
# v1.2.0). The donor names com.ims.dm today; a later donor that drops it should fail here.
grep -q 'allowed-system-preload package="com.ims.dm"' "$WORK_DIR/system/system/etc/sysconfig/allowed-system-preload-apps.xml" \
    || ABORT "[$TARGET_CODENAME] the donor's allowed-system-preload-apps.xml no longer names com.ims.dm - PackageManager would skip it"
LOG "- com.ims.dm (OpenImsDm 3.3.05) added from SM-S918N KOO stock"
unset _DM _DMX _p
LOG_STEP_OUT

LOG_STEP_IN "- Cellular: declare the SIM's secure element to apps (OMAPI UICC)"
# Stock T875/T976B declare android.hardware.se.omapi.uicc; the Wi-Fi donor and Wi-Fi Tab S7 do not.
# SecureElementService already opens logical channels on the SIM through Samsung's UiccTerminal1
# (T875N log, XDA #560: "Completed Opening Secure Element", SW 9000), so only the declaration is
# missing, and apps that check hasSystemFeature (carrier and USIM-based sign-in) skip the SIM.
# ops/proposals/cellular_stock_parity_20260930.md 5.2
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "system" "system/etc/permissions/android.hardware.se.omapi.uicc.xml" 0 0 644 "u:object_r:system_file:s0"
grep -q 'feature name="android.hardware.se.omapi.uicc"' "$WORK_DIR/system/system/etc/permissions/android.hardware.se.omapi.uicc.xml" 2>/dev/null \
    || ABORT "[$TARGET_CODENAME] the OMAPI UICC feature file did not land"
LOG_STEP_OUT
