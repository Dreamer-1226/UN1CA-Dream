#!/usr/bin/env bash
# shellcheck disable=SC2034
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
#
# GoRhanHee Kernel is developed by GoRhanHee (https://github.com/GoRhanHee).
# Kernel source and releases: https://github.com/GoRhanHee/android_kernel_samsung_sm8550
# This script only integrates the unmodified release binaries into the ROM build.

SKIPUNZIP=1

if [[ ! "$TARGET_CODENAME" =~ ^(dm1q|b5q)$ ]]; then
    LOG "- Skipping GoRhanHee Kernel: only enabled for dm1q and b5q"
    return 0
fi

GK_TAG="v2026.11.02"
GK_ZIP="GoRhanHee_Kernel-kalama-universal-susfs-oneui-AnyKernel3.zip"
GK_SHA256="3b06f51dbf9a638e9732929a3ea5c3ee18cde509a455c75a0029fade10c2c02f"
GK_URL="https://github.com/GoRhanHee/android_kernel_samsung_sm8550/releases/download/$GK_TAG/$GK_ZIP"
GK_DIR="$TMP_DIR/gorhanhee"

for f in boot.img vendor_boot.img; do
    [ -f "$WORK_DIR/kernel/$f" ] || ABORT "File not found: ${WORK_DIR//$SRC_DIR\//}/kernel/$f"
done

[ -d "$TMP_DIR" ] && EVAL "rm -rf \"$TMP_DIR\""
EVAL "mkdir -p \"$GK_DIR\""

LOG "- Downloading GoRhanHee Kernel ($GK_TAG)"
DOWNLOAD_FILE "$GK_URL" "$GK_DIR/ak3.zip" || exit 1
if [[ "$(sha256sum "$GK_DIR/ak3.zip" | cut -d " " -f 1)" != "$GK_SHA256" ]]; then
    ABORT "$GK_ZIP checksum mismatch ($GK_TAG)"
fi
EVAL "unzip -q -o \"$GK_DIR/ak3.zip\" Image vendor_dlkm.img system_dlkm.img \"sm8550_ramdisk/ramdisk/lib/modules/*\" -d \"$GK_DIR/ak3\"" || exit 1
EVAL "rm -f \"$GK_DIR/ak3.zip\""

# [
GK_REPACK_BOOT()
{
    local ARGS

    LOG "- Replacing kernel in boot.img"
    EVAL "mkdir -p \"$GK_DIR/boot\""
    ARGS="$(unpack_bootimg --boot_img "$WORK_DIR/kernel/boot.img" --out "$GK_DIR/boot/out" --format mkbootimg 2>&1)"
    [ -f "$GK_DIR/boot/out/kernel" ] || ABORT "Failed to unpack boot.img\n\n$ARGS"
    EVAL "cp -f \"$GK_DIR/ak3/Image\" \"$GK_DIR/boot/out/kernel\"" || exit 1
    EVAL "mkbootimg $ARGS -o \"$GK_DIR/boot/new-boot.img\"" || exit 1
    echo -n "SEANDROIDENFORCE" >> "$GK_DIR/boot/new-boot.img"
    EVAL "mv -f \"$GK_DIR/boot/new-boot.img\" \"$WORK_DIR/kernel/boot.img\"" || exit 1
}

GK_REPACK_VENDOR_BOOT()
{
    local ARGS f FORMAT REPLACED=false
    local EXTRACT="$GK_DIR/vendor_boot/ramdisk_extracted"

    LOG "- Replacing modules in vendor_boot.img"
    EVAL "mkdir -p \"$GK_DIR/vendor_boot\""
    ARGS="$(unpack_bootimg --boot_img "$WORK_DIR/kernel/vendor_boot.img" --out "$GK_DIR/vendor_boot/out" --format mkbootimg 2>&1)"

    while IFS= read -r f; do
        FORMAT=""
        [[ "$(READ_BYTES_AT "$f" "0" "2")" == "8b1f" ]] && FORMAT="gz"
        [[ "$(READ_BYTES_AT "$f" "0" "4")" == "184c2102" ]] && FORMAT="lz4"
        [ "$FORMAT" ] || ABORT "Ramdisk format not valid\n\n$(LC_ALL=C file -b "$f")"

        EVAL "rm -rf \"$EXTRACT\" && mkdir -p \"$EXTRACT\""
        if [[ "$FORMAT" == "gz" ]]; then
            EVAL "cat \"$f\" | gzip -d | cpio --quiet -i -D \"$EXTRACT\""
        else
            EVAL "cat \"$f\" | lz4 -d | cpio --quiet -i -D \"$EXTRACT\""
        fi
        [ -d "$EXTRACT/lib/modules" ] || continue

        LOG "- Replacing vendor_boot.img/$(basename "$f")/lib/modules"
        EVAL "rm -rf \"$EXTRACT/lib/modules\"" || exit 1
        EVAL "cp -a \"$GK_DIR/ak3/sm8550_ramdisk/ramdisk/lib/modules\" \"$EXTRACT/lib/modules\"" || exit 1
        EVAL "chmod 0755 \"$EXTRACT/lib/modules\" && chmod 0644 \"$EXTRACT/lib/modules/\"*" || exit 1
        if [[ "$FORMAT" == "gz" ]]; then
            EVAL "mkbootfs \"$EXTRACT\" | gzip > \"$f\"" || exit 1
        else
            EVAL "mkbootfs \"$EXTRACT\" | lz4 -l -12 --favor-decSpeed > \"$f\"" || exit 1
        fi
        REPLACED=true
    done < <(find "$GK_DIR/vendor_boot/out" -type f -name "*ramdisk*" | LC_ALL=C sort)

    $REPLACED || ABORT "No vendor_boot ramdisk contains lib/modules"
    EVAL "rm -rf \"$EXTRACT\""
    EVAL "mkbootimg $ARGS --vendor_boot \"$WORK_DIR/kernel/vendor_boot.img\"" || exit 1
}

GK_REPLACE_DLKM()
{
    local PARTITION="$1"
    local DEF_DIR_LABEL="$2"
    local IMG="$GK_DIR/ak3/$PARTITION.img"
    local OUT="$GK_DIR/$PARTITION"
    local FS="$WORK_DIR/configs/fs_config-$PARTITION"
    local FC="$WORK_DIR/configs/file_context-$PARTITION"
    local DIR_LABEL FILE_LABEL DIR_OWNER FILE_OWNER f ENTRY

    [ -d "$WORK_DIR/$PARTITION" ] || ABORT "Folder not found: ${WORK_DIR//$SRC_DIR\//}/$PARTITION"

    LOG "- Replacing /$PARTITION/lib/modules"
    EVAL "rm -rf \"$OUT\"" || exit 1
    EVAL "fsck.erofs --extract=\"$OUT\" \"$IMG\"" || exit 1
    [ -d "$OUT/lib/modules" ] || ABORT "lib/modules not found in $PARTITION.img"

    # Keep the stock ownership and SELinux labels of the module tree.
    DIR_LABEL="$(grep -m 1 -E "^/$PARTITION/lib/modules " "$FC" | awk '{print $2}')"
    FILE_LABEL="$(grep -m 1 -E "^/$PARTITION/lib/modules/.*\\\\\.ko " "$FC" | awk '{print $2}')"
    DIR_OWNER="$(grep -m 1 -E "^$PARTITION/lib/modules " "$FS" | awk '{print $2" "$3}')"
    FILE_OWNER="$(grep -m 1 -E "^$PARTITION/lib/modules/.*\.ko " "$FS" | awk '{print $2" "$3}')"
    [ "$FILE_LABEL" ] || FILE_LABEL="$DIR_LABEL"
    [ "$DIR_LABEL" ] || DIR_LABEL="${FILE_LABEL:-$DEF_DIR_LABEL}"
    [ "$FILE_LABEL" ] || FILE_LABEL="$DIR_LABEL"
    [ "$DIR_OWNER" ] || DIR_OWNER="0 0"
    [ "$FILE_OWNER" ] || FILE_OWNER="0 0"

    DELETE_FROM_WORK_DIR "$PARTITION" "lib/modules" || exit 1
    EVAL "cp -a \"$OUT/lib/modules\" \"$WORK_DIR/$PARTITION/lib/modules\"" || exit 1

    while IFS= read -r f; do
        ENTRY="$PARTITION/lib/${f#"$OUT/lib/"}"
        if [ -d "$f" ]; then
            echo "$ENTRY $DIR_OWNER 755 capabilities=0x0" >> "$FS"
            echo "/$(_HANDLE_SPECIAL_CHARS "$ENTRY") $DIR_LABEL" >> "$FC"
        else
            echo "$ENTRY $FILE_OWNER 644 capabilities=0x0" >> "$FS"
            echo "/$(_HANDLE_SPECIAL_CHARS "$ENTRY") $FILE_LABEL" >> "$FC"
        fi
    done < <(find "$OUT/lib/modules" | LC_ALL=C sort)

    LOG "- $(find "$WORK_DIR/$PARTITION/lib/modules" -name "*.ko" | wc -l) modules installed in /$PARTITION"
}
# ]

GK_REPACK_BOOT
GK_REPACK_VENDOR_BOOT
GK_REPLACE_DLKM "vendor_dlkm" "u:object_r:vendor_file:s0"
GK_REPLACE_DLKM "system_dlkm" "u:object_r:system_dlkm_file:s0"

EVAL "rm -rf \"$TMP_DIR\""

unset GK_TAG GK_ZIP GK_SHA256 GK_URL GK_DIR f
unset -f GK_REPACK_BOOT GK_REPACK_VENDOR_BOOT GK_REPLACE_DLKM
