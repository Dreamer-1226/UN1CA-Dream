# MinsOS: GsmCdmaPhone.isUiccApplicationsEnabled() reads a never-learned state (the A13 RIL answers
# SIM_ABSENT at boot and is not asked again) as disabled, so a SIM inserted after boot never gets
# mobile data. Unknown now counts as enabled; an explicit false from the RIL still disables.
SKIPUNZIP=1

DECODE_APK "system" "system/framework/telephony-common.jar" || return 1
# Dry run first: a hunk that no longer matches must not leave the smali half patched.
if LC_ALL=C patch -p1 -d "$APKTOOL_DIR/system/framework/telephony-common.jar" -N --forward -l --dry-run \
        < "$MODPATH/0001-Treat-unknown-UICC-apps-state-as-enabled.patch" > /dev/null; then
    APPLY_PATCH "system" "system/framework/telephony-common.jar" "$MODPATH/0001-Treat-unknown-UICC-apps-state-as-enabled.patch" || return 1
else
    LOGW "GsmCdmaPhone.isUiccApplicationsEnabled() does not match, skipping"
fi
