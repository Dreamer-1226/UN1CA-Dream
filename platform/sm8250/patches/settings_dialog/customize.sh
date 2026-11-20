# shellcheck disable=SC2034
SKIPUNZIP=1

# The Android 17 donor optimizes these setters to return void. Platform
# patches run before UN1CA Settings is injected, so keep both signatures.
if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ]; then
    APPLY_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" \
        "$MODPATH/0001-Restore-fluent-dialog-builder-methods.patch"
fi
