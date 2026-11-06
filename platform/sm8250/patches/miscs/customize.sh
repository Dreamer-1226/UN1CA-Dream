echo "Fix up /product/etc/build.prop"
sed -i "/# Removed by /d" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/#bluetooth./bluetooth./g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/?=/=/g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "$(sed -n "/provisioning.hostname/=" "$WORK_DIR/product/etc/build.prop" | sed "2p;d")d" "$WORK_DIR/product/etc/build.prop"

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
