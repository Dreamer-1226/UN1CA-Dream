# shellcheck disable=SC2034
SKIPUNZIP=1

APPLY_PATCH "system" "system/framework/services.jar" "$MODPATH/9010-Skip-dropbox-before-it-is-published-oneui9.patch"
