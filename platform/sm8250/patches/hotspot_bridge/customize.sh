# shellcheck disable=SC2034
SKIPUNZIP=1

# Samsung's explicit dual-band channel lists require a bridged AP in Android 17.
# Keep one AP on SM8250 devices whose legacy Wi-Fi HAL lacks bridged AP support.
case "$TARGET_CODENAME" in
    x1q|y2q|z3q|c1q|c2q|r8q)
        if [ "$SOURCE_PLATFORM_SDK_VERSION" -ge 37 ]; then
            APPLY_PATCH "system" "system/framework/semwifi-service.jar" \
                "$MODPATH/0001-Normalize-unsupported-bridged-hotspot-configurations.patch" || return 1
        fi
        ;;
esac
