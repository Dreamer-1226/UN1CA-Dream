# MinsOS/GoRhanHee: the SM8250 OMX decoders cannot run with a detached output Surface, but One UI 9
# advertises "detached-surface" for them and Media3 then takes a path that fails. Do not advertise it.
# The patch names smali_classes3; the class may sit in another dex here, so point it at the real one.
SKIPUNZIP=1

DECODE_APK "system" "system/framework/framework.jar" || return 1
_SMALI="$(cd "$APKTOOL_DIR/system/framework/framework.jar" && find smali* -path '*/android/media/MediaCodecInfo$CodecCapabilities.smali' | head -1)"
if [ "$_SMALI" ]; then
    _PATCH="$(mktemp)"
    sed "s#smali_classes3/android/media/MediaCodecInfo\$CodecCapabilities.smali#$_SMALI#" \
        "$MODPATH/0001-Do-not-advertise-detached-Surface-support.patch" > "$_PATCH"
    if LC_ALL=C patch -p1 -d "$APKTOOL_DIR/system/framework/framework.jar" -N --forward -l --dry-run \
            < "$_PATCH" > /dev/null; then
        APPLY_PATCH "system" "system/framework/framework.jar" "$_PATCH" || return 1
    else
        LOGW "MediaCodecInfo\$CodecCapabilities.isFeatureSupported() does not match, skipping"
    fi
    rm -f "$_PATCH"
else
    LOGW "MediaCodecInfo\$CodecCapabilities.smali not found in framework.jar, skipping"
fi
unset _SMALI _PATCH
