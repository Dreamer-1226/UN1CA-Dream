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
