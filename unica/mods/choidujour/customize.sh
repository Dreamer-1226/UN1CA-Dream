# shellcheck disable=SC2034
SKIPUNZIP=1

# UN1CA Updates (ChoiDujour) installs OTA packages it finds in a manifest, and
# verifies them against /system/etc/security/otacerts.zip first. Ship it only
# when this build can sign packages with a key the app will trust:
# - the official UN1CA key (upstream manifest), or
# - our own OTA key, security/ssch71_ota.pk8 (from the OTA_KEY_PK8 secret),
#   with the app pointed at the manifest on our "ota" branch.
if $ROM_IS_OFFICIAL; then
    _OTA_KEY="unica_ota"
elif [ -f "$SRC_DIR/security/ssch71_ota.pk8" ] && [ -f "$SRC_DIR/security/ssch71_ota.x509.pem" ]; then
    _OTA_KEY="ssch71_ota"
else
    LOG "\033[0;33m! No OTA signing key. Skipping\033[0m"
    return 0
fi

ADD_TO_WORK_DIR "$MODPATH" "system" "." 0 0 755 "u:object_r:system_file:s0"

LOG "- Patching /system/system/etc/security/otacerts.zip"
EVAL "rm -f \"$WORK_DIR/system/system/etc/security/otacerts.zip\""
EVAL "cd \"$SRC_DIR\"; zip -q \"$WORK_DIR/system/system/etc/security/otacerts.zip\" \"./security/$_OTA_KEY.x509.pem\""

if [[ "$_OTA_KEY" == "ssch71_ota" ]]; then
    # The app keeps its URLs as obfuscated strings, decoded at run time by one
    # static String(long) method. Answer the two update URLs before decoding:
    #   0x5c18d66cd5d38297 -> updates manifest (manifest.json)
    #   0x5c18db24d5d38297 -> changelog base ("<base><version>.txt")
    # Both constants belong to the ChoiDujour.apk in this module; a new APK must
    # be checked again, so a missing constant aborts the build.
    _OTA_URL="${UNICA_OTA_URL:-https://raw.githubusercontent.com/ssch71/UN1CA/ota/updates/}"
    _APK="system/priv-app/ChoiDujour/ChoiDujour.apk"
    DECODE_APK "system" "$_APK"
    _DIR="$APKTOOL_DIR/system/${_APK//system\//}"

    _CALL="$(grep -rh -A8 "const-wide [vp][0-9]*, 0x5c18d66cd5d38297L" "$_DIR"/smali* 2> /dev/null \
        | grep -oE "invoke-static \{[^}]*\}, L[^;]+;->[A-Za-z0-9_\$]+\(J\)Ljava/lang/String;" | head -n 1)"
    _CLASS="$(sed -E 's/.*, L([^;]+);->.*/\1/' <<< "$_CALL")"
    _METHOD="$(sed -E 's/.*;->([A-Za-z0-9_$]+)\(J\).*/\1/' <<< "$_CALL")"
    _SMALI=""
    for d in "$_DIR"/smali*; do
        [ -f "$d/$_CLASS.smali" ] && _SMALI="$d/$_CLASS.smali" && break
    done
    if [ ! "$_CALL" ] || [ ! "$_SMALI" ] || \
            ! grep -rq "const-wide [vp][0-9]*, 0x5c18db24d5d38297L" "$_DIR"/smali*; then
        ABORT "ChoiDujour: update URL constants not found, the APK changed"
    fi

    LOG "- Pointing UN1CA Updates at $_OTA_URL"
    python3 "$MODPATH/point_manifest.py" "$_SMALI" "$_METHOD" "$_OTA_URL" \
        || ABORT "ChoiDujour: could not patch the update URLs"

    unset _OTA_URL _APK _DIR _CALL _CLASS _METHOD _SMALI
fi

DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk"
_SETTINGS="$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk"

# Settings > Software update and the FOTA suggestion open UN1CA Updates. The
# Settings side of this was written for older donors, so each step only runs
# where it still fits; the app itself checks for updates on its own either way.
if LC_ALL=C patch -p1 -d "$_SETTINGS" -N --forward -l --dry-run \
        < "$MODPATH/suggestions/SecSettings.apk/0001-Launch-UN1CA-Updates-from-suggestions.patch" &> /dev/null; then
    APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "$MODPATH/suggestions/SecSettings.apk/0001-Launch-UN1CA-Updates-from-suggestions.patch"
else
    LOGW "FOTA suggestion patch does not apply to this SecSettings, skipping it"
fi

# Disable stock OTA references
_SUU="$(RESOLVE_SMALI "system" "priv-app/SecSettings/SecSettings.apk" "smali_classes3/com/samsung/android/settings/softwareupdate/SoftwareUpdateUtils.smali")"
if [ -f "$_SUU" ] && grep -q "isOTAUpgradeAllowed(Landroid/content/Context;)Z" "$_SUU"; then
    SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "${_SUU#"$_SETTINGS/"}" "return" \
        "isOTAUpgradeAllowed(Landroid/content/Context;)Z" "false"
else
    LOGW "SoftwareUpdateUtils.isOTAUpgradeAllowed not found, skipping it"
fi
unset _SUU

# Dynamically patch SecSettings
# - Add missing/non-xml files in place
# - Patch existing files
#   - Use the first line of the file to tell sed how to apply the rest of the content
#   - Exception made for files under *res/values* where the "resources" tag gets nuked
while IFS= read -r f; do
    f="${f//$MODPATH\/SecSettings.apk\//}"

    if [ ! -f "$_SETTINGS/$f" ] || \
            [[ "$f" != *".xml" ]]; then
        LOG "- Adding \"$f\" to /system/system/priv-app/SecSettings.apk"
        EVAL "mkdir -p \"$(dirname "$_SETTINGS/$f")\""
        EVAL "cp -a \"$MODPATH/SecSettings.apk/${f//\$/\\$}\" \"$_SETTINGS/${f//\$/\\$}\""
    else
        LOG "- Patching \"$f\" in /system/system/priv-app/SecSettings.apk"
        if [[ "$f" == *"res/values"* ]]; then
            PATCH_INST="/<\/resources>/i"
            CONTENT="$(sed -e "/?xml/d" -e "/resources>/d" "$MODPATH/SecSettings.apk/$f")"
        else
            PATCH_INST="$(head -n 1 "$MODPATH/SecSettings.apk/$f")"
            CONTENT="$(tail -n +2 "$MODPATH/SecSettings.apk/$f")"
        fi
        CONTENT="$(sed -e "s/\"/\\\\\"/g" -e "s/\\$/\\\\$/g" -e "s/ /\\\ /g" -e "s/\\\\n/\\\\\\\\\n/g" <<< "$CONTENT")"
        CONTENT="$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' <<< "$CONTENT")"
        EVAL "sed -i \"$PATCH_INST $CONTENT\" \"$_SETTINGS/$f\""
    fi
done < <(find "$MODPATH/SecSettings.apk" -type f)

unset PATCH_INST CONTENT _SETTINGS _OTA_KEY
