# MinsOS: UiccProfile event 110 (EVENT_GET_PERSO_STATUS_COMPLETE) reads two bytes from the answer to
# the Korean USIM perso query with no length check, and the A13 RIL answers it with zero bytes, so
# com.android.phone crash-loops and RescueParty reboots. A short answer now takes the null-result exit.
SKIPUNZIP=1

DECODE_APK "system" "system/framework/telephony-common.jar" || return 1
# Dry run first: a hunk that no longer matches must not leave the smali half patched.
if LC_ALL=C patch -p1 -d "$APKTOOL_DIR/system/framework/telephony-common.jar" -N --forward -l --dry-run \
        < "$MODPATH/0001-Guard-short-perso-status-response.patch" > /dev/null; then
    APPLY_PATCH "system" "system/framework/telephony-common.jar" "$MODPATH/0001-Guard-short-perso-status-response.patch" || return 1
else
    LOGW "UiccProfile\$5 EVENT_GET_PERSO_STATUS_COMPLETE does not match, skipping"
fi
