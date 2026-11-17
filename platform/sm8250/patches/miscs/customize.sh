echo "Fix up /product/etc/build.prop"
sed -i "/# Removed by /d" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/#bluetooth./bluetooth./g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/?=/=/g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "$(sed -n "/provisioning.hostname/=" "$WORK_DIR/product/etc/build.prop" | sed "2p;d")d" "$WORK_DIR/product/etc/build.prop"

# Only sources with SUPPORT_VIRTUAL_VIBRATION_SOUND compiled in (the S23 qssi)
# show this toggle; the Tab S9+ source has neither the feature nor this method shape.
if $SOURCE_AUDIO_SUPPORT_VIRTUAL_VIBRATION_SOUND; then
    # "Play vibration sound on incoming calls" (virtual vibration sound) does not
    # work on SM8250. The source SecSettings has SUPPORT_VIRTUAL_VIBRATION_SOUND
    # compiled in, so mark the toggle unsupported and keep its caption hidden.
    LOG_STEP_IN "- Hiding the incoming call vibration sound toggle"
    DECODE_APK "system" "system/priv-app/SecSettings/SecSettings.apk" || return 1
    VVS_SMALI="$(cd "$APKTOOL_DIR/system/priv-app/SecSettings/SecSettings.apk" && \
        find smali* -path "*/com/samsung/android/settings/asbase/vibration/VirtualVibrationSoundPreferenceController.smali" | head -n 1)"
    if [ "$VVS_SMALI" ]; then
        # 3 = BasePreferenceController.UNSUPPORTED_ON_DEVICE
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" "$VVS_SMALI" "return" \
            "getAvailabilityStatus()I" "3" || return 1
        SMALI_PATCH "system" "system/priv-app/SecSettings/SecSettings.apk" "$VVS_SMALI" "replace" \
            "displayPreference(Landroidx/preference/PreferenceScreen;)V" "const/4 p1, 0x1" "const/4 p1, 0x0" || return 1
    else
        LOGW "VirtualVibrationSoundPreferenceController not found, skipping"
    fi
    unset VVS_SMALI
    LOG_STEP_OUT
fi

# LockSettingsService lives in a different smali_classesN on every source's
# services.jar (smali_classes2 on the S23 qssi, not on the Tab S9+), so find it
# and point the patch at that dex. Only the qssi source is required to match.
LOG_STEP_IN "- Disabling screen lock backup support"
DECODE_APK "system" "system/framework/services.jar" || return 1
LSS_SMALI="$(cd "$APKTOOL_DIR/system/framework/services.jar" && \
    find smali* -path "*/com/android/server/locksettings/LockSettingsService.smali" | head -n 1)"
if [ "$LSS_SMALI" ]; then
    LSS_PATCH="$(mktemp)"
    sed "s#smali_classes2/com/android/server/locksettings/#${LSS_SMALI%%/*}/com/android/server/locksettings/#g" \
        "$MODPATH/services-patches/0001-Disable-screen-lock-backup-support.patch" > "$LSS_PATCH"
    if ! APPLY_PATCH "system" "system/framework/services.jar" "$LSS_PATCH"; then
        rm -f "$LSS_PATCH"
        [[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]] && return 1
        LOGW "Screen lock backup patch does not match this source, skipping"
    fi
    rm -f "$LSS_PATCH"
else
    LOGW "LockSettingsService.smali not found, skipping"
fi
unset LSS_SMALI LSS_PATCH
LOG_STEP_OUT
