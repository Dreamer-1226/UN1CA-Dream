#!/usr/bin/env bash
# Copyright (c) 2026

# The phones (x1q/y2q/z3q) swap the donor's 64-bit WFD sink for a patched 32-bit one.
# gts7lwifi keeps the donor's own 64-bit stack (asserted in its stock_blobs patch), and the
# 32-bit bin/remotedisplay in system/ would overwrite it, so unzip only for the phones.
# shellcheck disable=SC2034 # read by APPLY_MODULE
SKIPUNZIP=1
if [[ "$TARGET_CODENAME" == "gts7lwifi" ]]; then
    LOG "- Skipping the 32-bit WFD swap on $TARGET_CODENAME"
else
    ADD_TO_WORK_DIR "$MODPATH" "system" "." 0 0 755 "u:object_r:system_file:s0"

    DELETE_FROM_WORK_DIR "system" "system/lib64/libhdcp_client_aidl.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libhdcp2.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libremotedisplay_wfd.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libremotedisplayservice.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libsecuibc.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/libstagefright_hdcp.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/vendor.samsung.hardware.security.hdcp.wifidisplay-V2-ndk.so"
    DELETE_FROM_WORK_DIR "system" "system/lib64/wfd_log.so"


    # Hex patch libremotedisplay_wfd.so to bypass unsupported WFD R2 parameters
    if [ -f "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" ]; then
        if xxd -p -c 0 "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" | grep -q "94f80d0318b994f8141301290ed1"; then
            # r9qxxx (Snapdragon S23 / S21 FE) WFD R2 bypass
            HEX_PATCH "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" \
                "94f80d0318b994f8141301290ed1" \
                "00f00fb818b994f8141301290ed1"
        elif xxd -p -c 0 "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" | grep -q "94f81d0318b994f8241301290ed1"; then
            # r9sxxx (Exynos S23 / S22) WFD R2 bypass
            HEX_PATCH "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" \
                "94f81d0318b994f8241301290ed1" \
                "00f00fb818b994f8241301290ed1"
        fi
    fi

    # One UI 9 changed the AudioTrack constructor, so libremotedisplay_wfd.so
    # fails to link and remotedisplay never starts (system_server then dies in
    # WifiDisplayController). Swap its ubsan NEEDED entry for a shim that forwards
    # the old constructor; the shim pulls the ubsan runtime in itself.
    if [ -f "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" ] && \
            [ -f "$WORK_DIR/system/system/lib/libwfd_audiotrack_shim.so" ]; then
        HEX_PATCH "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" \
            "006c6962636c616e675f72742e756273616e5f7374616e64616c6f6e652d61726d2d616e64726f69642e736f00" \
            "006c69627766645f617564696f747261636b5f7368696d2e736f00000000000000000000000000000000000000"
    fi

    # One UI 9 libgui added IGraphicBufferProducer methods, so the old vtable
    # slot (0x7c) in PlaybackSession::addConsumerUsageBits() now hits
    # getFrameTimestamps() instead of getConsumerUsage() (0x84), and the encoder
    # surface ends up with garbage usage bits (black screen on the sink).
    # Drop the CFI check in front of the call and use its slot to move the
    # vtable pointer forward by 8, so [r4, #0x7c] lands on getConsumerUsage().
    if [ -f "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" ]; then
        HEX_PATCH "$WORK_DIR/system/system/lib/libremotedisplay_wfd.so" \
            "224643f0c2e8e26f" \
            "2246083400bfe26f"
    fi

    # Hex patch libstagefright.so to fix ACodec getProcessNameByPid buffer overflow
    if [ -f "$WORK_DIR/system/system/lib/libstagefright.so" ]; then
        if xxd -p -c 0 "$WORK_DIR/system/system/lib/libstagefright.so" | grep -q "204601214ff400722b46"; then
            # r11qxxx / Android 16 ARM32 ACodec getProcessNameByPid buffer overflow fix (512 -> 254 bytes)
            HEX_PATCH "$WORK_DIR/system/system/lib/libstagefright.so" \
                "204601214ff400722b46" \
                "204601214ff0fe022b46"
        elif xxd -p -c 0 "$WORK_DIR/system/system/lib/libstagefright.so" | grep -q "01214ff4007230462b460097"; then
            # Legacy ACodec getProcessNameByPid buffer overflow fix
            HEX_PATCH "$WORK_DIR/system/system/lib/libstagefright.so" \
                "01214ff4007230462b460097" \
                "01214ff0fe0230462b460097"
        fi
    fi
fi
