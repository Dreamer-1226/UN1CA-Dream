SKIPUNZIP=1

LOG_STEP_IN "- Invalidating PackageManager's parse cache when the ROM version changes"
# WHY (measured on a real T970, 2026-08-23, and fixed live before this was written):
#
#   PackageManager caches the parsed manifest of every APK under /data/system/package_cache and
#   throws that cache away only when the build fingerprint changes. This ROM keeps the donor's
#   fingerprint (X810XXS6EZF1) across every MinsOS release, so from PM's side an update never
#   happens and the cache survives it. Every system APK whose contents changed between releases
#   then keeps being read from an entry parsed by an older build.
#
#   What that looked like: SamsungSmartSuggestions on disk was versionCode 723100000 (7.2.31.0)
#   while PM reported 711100100 (7.1.05.0), out of a cache entry dated 2026-08-09. PM kept
#   registering a provider that only exists in the older APK; the new one has no such class, so
#   the app crash-looped on ClassNotFoundException, and its labels resolved through the old
#   resource ids - the app showed as "Bottom sheet" and its widget carried an unrelated string.
#   `rm -rf /data/system/package_cache` fixed both at once, with nothing else changed. 804 entries
#   were stale. Only people who UPDATE hit this; a clean flash writes the cache from what it ships.
#
# WHAT THIS IS NOT: it is not a fix for one app. Any APK this ROM changes between releases is
# exposed, and nothing in the build can see it, because the staleness lives in /data.
ADD_TO_WORK_DIR "$MODPATH/files" "system" "bin/minsos_pkgcache" 0 0 755 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$MODPATH/files" "system" "etc/init/minsos_pkgcache.rc" 0 0 644 "u:object_r:system_file:s0"
EVAL "chmod 755 \"$WORK_DIR/system/system/bin/minsos_pkgcache\""
# Registered file by file, and through ADD_TO_WORK_DIR rather than a plain copy. Both rules are
# paid for: a plain `cat >` puts the file there but registers it nowhere, and the image build then
# dies with "failed to find ... in canned fs_config" after the whole patch phase has succeeded.
for _F in system/bin/minsos_pkgcache system/etc/init/minsos_pkgcache.rc; do
    [ -f "$WORK_DIR/system/$_F" ] \
        || ABORT "[$TARGET_CODENAME] $_F did not land in the work dir"
    grep -q "^system/${_F#system/} " "$WORK_DIR/configs/fs_config-system" 2>/dev/null \
        || ABORT "[$TARGET_CODENAME] $_F has no fs_config entry - the image build would refuse it"
done
unset _F
# I-40: the key must include the build's own timestamp. Keyed on the version string alone, a
# rebuild under the same version never clears the cache again - v1.1.2 went through four such
# builds and the owner's tablet kept the 09-05 parse cache through every one of them.
grep -q 'ro.unica.timestamp' "$WORK_DIR/system/system/bin/minsos_pkgcache" \
    || ABORT "[$TARGET_CODENAME] minsos_pkgcache does not key on ro.unica.timestamp - same-version rebuilds would keep a stale parse cache (I-40)"
grep -qE '^system/bin/minsos_pkgcache 0 0 0?755 ' "$WORK_DIR/configs/fs_config-system" \
    || ABORT "[$TARGET_CODENAME] minsos_pkgcache is not 0755 in fs_config - init could not exec it ($(grep '^system/bin/minsos_pkgcache ' "$WORK_DIR/configs/fs_config-system" 2>/dev/null))"

# ---- the domain init needs to start it -----------------------------------------------------------
# Same shape as patches/battery_info, and for the same reason: the script is labelled plain
# system_file, init cannot derive a domain from that, and without a seclabel plus a matching
# entrypoint rule the service dies before fork with status 127 - which reads exactly like a clean
# exit. battery_info shipped dead that way through every release up to v1.1.0 before anyone noticed.
_PLAT_CIL="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
[ -f "$_PLAT_CIL" ] || ABORT "[$TARGET_CODENAME] plat_sepolicy.cil is not in the work dir"
if grep -q "(type minsos_pkgcache)" "$_PLAT_CIL"; then
    ABORT "[$TARGET_CODENAME] plat_sepolicy.cil already declares minsos_pkgcache - the work dir was not rebuilt from the donor"
fi
cat <<'EOF' >> "$_PLAT_CIL"
; Added by unica/patches/pkgcache_invalidate/customize.sh - domain for the minsos_pkgcache boot
; service. It runs at post-fs-data as root, reads one property, and removes
; /data/system/package_cache (system_data_file) when the ROM version changed.
(type minsos_pkgcache)
(roletype r minsos_pkgcache)
; The trailing space before )) below is deliberate. Do not remove it.
; unica/mods/prophide rewrites every line starting with (typeattributeset domain
; using  s/))/prophide ))/  . Without the space its name is glued onto ours, the policy
; then references an undeclared type, secilc fails, and init reboots in a loop three
; seconds into boot. That shipped once, on 2026-08-17.
(typeattributeset domain (minsos_pkgcache ))
(typeattributeset coredomain (minsos_pkgcache ))
(allow init minsos_pkgcache (process (transition)))
; entrypoint has to be on system_file, not only on shell_exec: what init execs is the script
; itself, /system/bin/minsos_pkgcache, and that file is labelled system_file. The interpreter is
; never the entrypoint for the domain transition.
(allow minsos_pkgcache shell_exec (file (entrypoint read open execute map getattr)))
(allow minsos_pkgcache system_file (file (entrypoint execute execute_no_trans read open map getattr)))
; getprop, cat, printf, log, ls, wc and rm in /system/bin are symlinks to toybox, whose own label
; is toolbox_exec, so the exec check lands there rather than on system_file.
(allow minsos_pkgcache toolbox_exec (file (read open execute execute_no_trans getattr map)))
(allow minsos_pkgcache self (capability (dac_override dac_read_search fowner)))
; The cache itself. Removing a tree needs the directory perms as well as unlink on the files, and
; the marker file needs create/write. /data/system and everything under it is system_data_file.
(allow minsos_pkgcache system_data_file (dir (search read open write getattr add_name remove_name rmdir)))
(allow minsos_pkgcache system_data_file (file (read open write create unlink getattr setattr)))
; Reading ro.build.display.id.
(allow minsos_pkgcache default_prop (file (read open getattr map)))
(allow minsos_pkgcache build_prop (file (read open getattr map)))
; log -t, so the run leaves a trace. Without these the script works and says nothing, which is how
; a service that never ran gets mistaken for one that had nothing to do.
(allow minsos_pkgcache socket_device (dir (search)))
(allow minsos_pkgcache logdw_socket (sock_file (write)))
(allow minsos_pkgcache logd (unix_dgram_socket (sendto)))
(allow minsos_pkgcache null_device (chr_file (read write open getattr)))
EOF
grep -q "(type minsos_pkgcache)" "$_PLAT_CIL" \
    || ABORT "[$TARGET_CODENAME] the minsos_pkgcache CIL block did not land in plat_sepolicy.cil"
grep -q "seclabel u:r:minsos_pkgcache:s0" "$WORK_DIR/system/system/etc/init/minsos_pkgcache.rc" \
    || ABORT "[$TARGET_CODENAME] the .rc that landed has no seclabel - stale files/ copy?"
grep -q "^on post-fs-data" "$WORK_DIR/system/system/etc/init/minsos_pkgcache.rc" \
    || ABORT "[$TARGET_CODENAME] the .rc lost its post-fs-data trigger - it would only help the boot after next"
unset _PLAT_CIL

# ---- I-75: make the first boot of a new build an update boot ------------------------------------
# PackageManager calls a boot an update when the digest of ro.<p>.build.fingerprint over its partition
# list (system vendor odm oem product system_ext prism carrier - PackagePartitions.smali) plus
# ro.build.fingerprint changes. Every one of those is the donor's or the stock vendor's and survives
# a MinsOS update, so the update boot never happened: no boot-after-ota dexopt (verify), apps kept
# vdex/odex that no longer match. No oem partition exists here, so ro.oem.build.fingerprint is free:
# Build.getFingerprintedPartitions() leaves oem out, the OTA scripts key on ro.system.build.fingerprint,
# nothing in this repo or UN1CA reads it. Measured on the owner's T970 (10-18, through a test module):
# "Upgrading from ...", "Destroying unknown cache", boot-after-ota dexopt of 478 packages, no errors.
# Keyed on version AND build timestamp, like the service above (I-40). ro.unica.timestamp is set here
# when empty, as target/y2q build_stamp does: on the tablets only minsos_ota sets it, and only with
# MINSOS_OTA=1; it keeps a value that is already there, so every setter agrees.
[ -n "${ROM_BUILD_TIMESTAMP:-}" ] || ABORT "[$TARGET_CODENAME] ROM_BUILD_TIMESTAMP is empty (I-75)"
[ -n "$(GET_PROP "system" "ro.unica.timestamp")" ] || SET_PROP "system" "ro.unica.timestamp" "$ROM_BUILD_TIMESTAMP"
_VER="$(GET_PROP "system" "ro.unica.version")"
_TS="$(GET_PROP "system" "ro.unica.timestamp")"
{ [ -n "$_VER" ] && [ -n "$_TS" ]; } \
    || ABORT "[$TARGET_CODENAME] ro.unica.version or ro.unica.timestamp is empty - ro.oem.build.fingerprint would not change per build (I-75)"
SET_PROP "system" "ro.oem.build.fingerprint" "minsos/$_VER/$_TS"
[ "$(GET_PROP "system" "ro.oem.build.fingerprint")" = "minsos/$_VER/$_TS" ] \
    || ABORT "[$TARGET_CODENAME] ro.oem.build.fingerprint did not stick in system/build.prop"
LOG "- ro.oem.build.fingerprint=minsos/$_VER/$_TS (first boot of this build is an update boot)"
unset _VER _TS

LOG "- minsos_pkgcache: post-fs-data oneshot + sepolicy domain (PM re-parses after an update)"
LOG_STEP_OUT
