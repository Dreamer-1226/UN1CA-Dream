# The S23 faceswapOptical/faceswapFusion SNAP models are weight-stripped HTP caches
# that the V66 DSP cannot load. Point the ArcSoft Best Face engine at libsnap_bfsw,
# which emulates both models on the CPU (optical flow warp + Poisson blend) and
# forwards every other model to libsnap_aidl unchanged.
BESTFACE_LIB="$WORK_DIR/system/system/lib64/libgallery_pic_best.arcsoft.so"
BESTFACE_PUBLIC_LIBS="$WORK_DIR/system/system/etc/public.libraries-snap.samsung.txt"
if [ -f "$BESTFACE_LIB" ]; then
    HEX_PATCH "$BESTFACE_LIB" \
        "006c6962736e61705f6169646c2e736e61702e73616d73756e672e736f00" \
        "006c6962736e61705f626673772e736e61702e73616d73756e672e736f00" || return 1
    if ! grep -qx "libsnap_bfsw.snap.samsung.so" "$BESTFACE_PUBLIC_LIBS" 2> /dev/null; then
        EVAL "echo \"libsnap_bfsw.snap.samsung.so\" >> \"$BESTFACE_PUBLIC_LIBS\"" || return 1
    fi
else
    LOG "- libgallery_pic_best.arcsoft.so not found, skipping"
fi
unset BESTFACE_LIB BESTFACE_PUBLIC_LIBS
