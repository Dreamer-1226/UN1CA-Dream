# MinsOS: SecRilAdaptor::CopyDataReqData in the bundled A13 RIL reads the CID from bits 11..18 of the
# data profile ID. One UI 9 only encodes it when RILUtils.IsApAssistSupported() is true, otherwise
# data and IMS setup requests fail with "Unavailable cid(0)".
SKIPUNZIP=1

DECODE_APK "system" "system/framework/telephony-common.jar" || return 1
_SMALI="$(cd "$APKTOOL_DIR/system/framework/telephony-common.jar" && find smali* -path "*/com/android/internal/telephony/RILUtils.smali" | head -1)"
if [ "$_SMALI" ]; then
    SMALI_PATCH "system" "system/framework/telephony-common.jar" \
        "$_SMALI" "return" "IsApAssistSupported()Z" "true" || return 1
else
    LOGW "RILUtils.smali not found in telephony-common.jar, skipping"
fi
unset _SMALI
