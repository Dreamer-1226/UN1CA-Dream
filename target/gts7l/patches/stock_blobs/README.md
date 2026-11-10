# Provenance: filled 2026-08-05 from SM-T875's own firmware

Every file here was generated from the `SM-T875_INU` (T875XXS8DXH2) extraction, never copied from
another target, and each generated XML was verified by diffing it against T875's own stock copy:

- `vendor/etc/vintf/manifest.xml`: T875 stock + the same two-line face@3.0 declaration the
  hardware-verified gts7lwifi tree carries (`<version>3.0</version>` +
  `<fqname>@3.0::ISehBiometricsFace/default</fqname>`). Verified: pure additions, nothing lost.
  T875's radio HALs (ISehRadio/Bridge/Channel, IRadioConfig, IOffload*) and its gnss *fragment*
  declaration survive untouched because the base file is its own.
- `system/etc/vintf/compatibility_matrix.device.xml`: T875 stock (which already lists its LTE
  radio HALs; that is the delta an LTE framework matrix has over the Wi-Fi one) + the three
  additions the gts7lwifi file carries (input-list comment line, face `3.0`, the
  `vendor.samsung.hardware.bluetooth.a2dp` block). Verified: pure additions.
- `vendor/etc/vintf/compatibility_matrix.device.xml`: byte-copy of the gts7lwifi file, which is
  legitimate only because T875's and T870's stock vendor matrices are **byte-identical** (checked
  2026-08-05); the single change vs stock is `<system-sdk>` 29→30 for the A16 donor.
- `system/etc/sysconfig/minsos-gpu-preload.xml` and `system/etc/init/minsos-radio-defnet.rc` are
  written for MinsOS, not taken from any firmware. Each says why in its own header comment.
- `fs_config-*` / `file_context-*`: the vendor sidecars are byte-copies of gts7lwifi's. The system
  sidecars are gts7lwifi's plus the four cellular paths gts7lwifi does not ship (`OpenImsDm`, its
  APK, its privapp permission file, `minsos-radio-defnet.rc`).
- `customize.sh`: gts7lwifi's file, followed by four cellular steps (`sec_platform_library`,
  `multiclientd` and its libraries, the `com.ims.dm` checks, and the OMAPI UICC feature file). Every
  `$TARGET_FIRMWARE` path it pulls (HotwordEnrollment*Ex3, pocketmode/cover permissions,
  GameDriver-SM8250, and the cellular files) is present in the T875 extraction. Its VINTF guard,
  which ends the part shared with gts7lwifi, compares the shipped manifest against
  `$FW_DIR/SM-T875_INU/...` at build time, so the bootloop class this directory once caused cannot
  ship silently.

History, kept because it is the reason this directory is built this way: the first T870 build
bootlooped every unit off a manifest copied from the 12.4-inch 5G tree (no `android.hardware.gnss`
declared → LocationManagerService blocked system_server → watchdog at 66 s, nothing in the build
log). `tools/verify_vintf.sh` and the guard inside `customize.sh` both exist because of it.

One exception to the INU rule (LG U+ VoLTE): `com.ims.dm` exists only in Korean stock, so
`system/priv-app/OpenImsDm/OpenImsDm.apk` comes from SM-S918N KOO S918NKSS8FZI1 (3.3.05,
2,947,397 B, sha256 `600f3976…66ea`, platform-signed). The SM-T875N KOO T875NKOS8HXH1 build
(2.9.04, Android 13) it replaced on 2026-10-04 crashed at boot on Android 16
(`MissingForegroundServiceTypeException`, XDA #612). It is not committed; `tools/fetch_openimsdm.sh`
places it and `customize.sh` aborts without it.
`system/etc/permissions/privapp-permissions-com.ims.dm.xml` is the T875N grant list plus
`SCHEDULE_EXACT_ALARM` (S918N's own file has the same three entries), which became
signature|privileged after Android 13.
