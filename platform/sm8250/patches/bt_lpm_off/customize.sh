# The S20/Note20 vendor HIDL Bluetooth HAL turns on low power mode after the firmware is configured
# (BT_VND_OP_LPM_SET_MODE, BT_VND_LPM_ENABLE). The bluesleep driver then switches the HS UART clock
# off after every idle timeout, about once a second ("hsuart_power off [BT]"). On One UI 9 the
# controller's first bytes after a wake are regularly lost, H4Protocol loses the packet framing
# ("Unimplemented packet type N", "Invalid Packet Length!") and drops events and ACL data until it
# happens to resync. Ask for BT_VND_LPM_DISABLE instead, which keeps the UART awake.

# VendorInterface::OnFirmwareConfigured(): [mov w8, #0x1; str w8, [sp, #0xc]] -> [mov w8, #0x0; ...]
if [ -f "$WORK_DIR/vendor/lib64/hw/android.hardware.bluetooth@1.0-impl.so" ]; then
    HEX_PATCH "$WORK_DIR/vendor/lib64/hw/android.hardware.bluetooth@1.0-impl.so" \
        "28008052e80f00b9" "08008052e80f00b9" \
        || LOGW "lib64/hw/android.hardware.bluetooth@1.0-impl.so: LPM enable does not match, skipping"
fi

# That is not enough on its own: with LPM disabled the HAL still runs its idle watchdog, and
# VendorInterface::OnTimeout() de-asserts BT_WAKE (BT_VND_OP_LPM_WAKE_SET_STATE) 1.5 s after the
# last packet sent. Samsung's bt_upio forwards that to bluesleep, which still switches the UART
# clock off ("hsuart_power off [BT]" every few seconds) and the same desync follows, ending in an
# HCI timeout and a Bluetooth restart. Keep BT_WAKE asserted: drop the call in OnTimeout().
# Send() still asserts before every packet, which is a no-op while it stays asserted.
# OnTimeout(): [add x1, sp, #0xc; mov w0, #0x7; blr x20] -> [...; nop]
if [ -f "$WORK_DIR/vendor/lib64/hw/android.hardware.bluetooth@1.0-impl.so" ]; then
    HEX_PATCH "$WORK_DIR/vendor/lib64/hw/android.hardware.bluetooth@1.0-impl.so" \
        "e1330091e000805280023fd6" "e1330091e00080521f2003d5" \
        || LOGW "lib64/hw/android.hardware.bluetooth@1.0-impl.so: BT_WAKE de-assert does not match, skipping"
fi
