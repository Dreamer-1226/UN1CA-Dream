#!/usr/bin/env bash
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Pin the firmwares a build uses to the build FUS serves right now, or to the
# build given on the command line.
#
# The OTA channel diffs every new build against the previous one, so neither the
# donor nor the target firmware may move between them: a Samsung update would
# change most of the image and the incremental package would no longer be small,
# or even apply. Bump a pin on purpose, test that build, then publish a new base.
#
# Usage: scripts/pin_firmware.sh [<name> [<PDA/CSC/CP>]]
#   no arguments : pin the donors (qssi, flip-qssi, tab-qssi) and every OTA
#                  target (dm1q, b5q, gts7lwifi, z3q, x1q, y2q, c1q, c2q)
#   <name>       : a donor config (qssi, ...), a target (z3q, ...) or a file
#   <PDA/CSC/CP> : pin to this build instead of the current one

set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
NAMES=(qssi flip-qssi tab-qssi dm1q b5q gts7lwifi z3q x1q y2q c1q c2q)

if [ "$#" -ge 1 ]; then
    NAMES=("$1")
fi
REQUESTED="${2:-}"

for n in "${NAMES[@]}"; do
    FILE="$n"
    [ -f "$FILE" ] || FILE="$SRC_DIR/unica/configs/$n.sh"
    [ -f "$FILE" ] || FILE="$SRC_DIR/target/$n/config.sh"
    if [ ! -f "$FILE" ]; then
        echo "Config not found: $n" >&2
        exit 1
    fi

    if grep -q '^SOURCE_FIRMWARE=' "$FILE"; then
        KIND="SOURCE"
    elif grep -q '^TARGET_FIRMWARE=' "$FILE"; then
        KIND="TARGET"
    else
        echo "No SOURCE_FIRMWARE or TARGET_FIRMWARE in $FILE" >&2
        exit 1
    fi

    FIRMWARE="$(sed -n "s/^${KIND}_FIRMWARE=\"\\([^\"]*\\)\"/\\1/p" "$FILE")"
    MODEL="$(cut -d "/" -f 1 <<< "$FIRMWARE")"
    CSC="$(cut -d "/" -f 2 <<< "$FIRMWARE")"
    if [ ! "$MODEL" ] || [ ! "$CSC" ]; then
        echo "Malformed ${KIND}_FIRMWARE in $FILE" >&2
        exit 1
    fi

    VERSION="$REQUESTED"
    if [ ! "$VERSION" ]; then
        # FUS answers 403 without its client's User-Agent.
        VERSION="$(curl -fsSL --retry 3 -A "Kies2.0_FUS" \
            "https://fota-cloud-dn.ospserver.net/firmware/$CSC/$MODEL/version.xml" \
            | sed -n 's|.*<latest[^>]*>\([^<]*\)</latest>.*|\1|p' | head -n 1)"
    fi
    if [[ ! "$VERSION" =~ ^[A-Z0-9]+/[A-Z0-9]*/[A-Z0-9]*$ ]]; then
        echo "Could not get a firmware version for $MODEL/$CSC (got \"$VERSION\")" >&2
        exit 1
    fi

    if grep -q "^${KIND}_FIRMWARE_VERSION=" "$FILE"; then
        sed -i "s|^${KIND}_FIRMWARE_VERSION=.*|${KIND}_FIRMWARE_VERSION=\"$VERSION\"|" "$FILE"
    else
        sed -i "/^${KIND}_FIRMWARE=/a ${KIND}_FIRMWARE_VERSION=\"$VERSION\"" "$FILE"
    fi
    echo "$n: $MODEL/$CSC -> $VERSION"
done
