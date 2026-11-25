# I-172 (YouTube protected 1080p falls back to 480p with OEMCryptoResult 13 / ERROR_DRM_CANNOT_HANDLE) -
# HIDL <=1.3 fallback in system/lib64/libmediadrm.so DrmHalHidl::requiresSecureDecoder.
#
# WHAT BREAKS. All SM8250 targets (Tab S7 family + S20 family) ship Android 11/13 vendor Widevine on
# android.hardware.drm@1.3::IDrmFactory (Widevine CDM 16.0.0), so DrmHalHidl::mPluginV1_4 is always
# NULL. Upstream AOSP DrmHalHidl::requiresSecureDecoder() returns DrmStatus(OK) without touching
# *required when mPluginV1_4 == NULL, causing MediaDrm.requiresSecureDecoder("video/...") to return
# false (libmedia_jni initializes required=false). Apps that rely on MediaDrm.requiresSecureDecoder()
# (e.g. YouTube) then allocate the non-secure OMX.qcom.video.decoder.vp9 instead of .vp9.secure;
# 480p SD keys permit clear output, but 1080p HD keys are rejected by Widevine TA
# validate_key_usage/validate_key_control_for_decrypt (TA Result 20, OEMCryptoResult 13, WVCdm 178,
# ERROR_DRM_CANNOT_HANDLE), forcing L3 / 480p fallback after 3 retries.
#
# FIX. When mPluginV1_4 == NULL in both DrmHalHidl::requiresSecureDecoder overloads, run a fallback
# matching donor AIDL Widevine (libwvaidl.so WVDrmPlugin::requiresSecureDecoder): for video/* MIME
# types at kSecurityLevelMax(1), kSecurityLevelHwSecureDecode(5), or kSecurityLevelHwSecureAll(6),
# query this->getPropertyStringInternal("securityLevel") (gLock already held) and set *required=true
# iff the property equals "L1". Audio, ClearKey, L3, SW_SECURE_*, and HW_SECURE_CRYPTO return false;
# HAL >=1.4 and AIDL paths are untouched.
SKIPUNZIP=1

_DRM64="$WORK_DIR/system/system/lib64/libmediadrm.so"

if [ ! -f "$_DRM64" ]; then
    LOG "\033[0;33m! Nothing to do (no lib64/libmediadrm.so)\033[0m"
    unset _DRM64
    return 0
fi

LOG_STEP_IN "- Patching lib64/libmediadrm.so (I-172: HIDL 1.3 requiresSecureDecoder fallback)"
python3 "$MODPATH/apply_drm_secure_decoder.py" "$_DRM64" \
    || LOGW "lib64/libmediadrm.so: unknown build, I-172 fallback skipped"
LOG_STEP_OUT

unset _DRM64
