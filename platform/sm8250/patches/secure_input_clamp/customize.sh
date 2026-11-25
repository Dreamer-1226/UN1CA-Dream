# Protected playback corruption (MinsOS I-09): the secure OMX decoder gets the full secure
# allocation as nFilledLen and decodes the previous frame's leftovers, so Netflix reports L1
# but the picture breaks up. apply_i09_clamp.py passes the subsample sum through to
# omxBuffer.mRangeLength. It only knows the S911N donor build and refuses anything else.
SKIPUNZIP=1

_SF64="$WORK_DIR/system/system/lib64/libstagefright.so"

if [ -f "$_SF64" ]; then
    python3 "$MODPATH/apply_i09_clamp.py" "$_SF64" \
        || LOGW "lib64/libstagefright.so: unknown build, secure-input clamp skipped"
fi

unset _SF64
