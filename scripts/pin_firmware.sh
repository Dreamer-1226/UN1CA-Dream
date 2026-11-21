#!/usr/bin/env bash
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Pin the donor firmwares that still receive Samsung updates to the build FUS
# serves right now, or to the build given on the command line.
#
# The OTA channel diffs every new build against the previous one, so the donor
# must not move between them: a Samsung update would change most of /system and
# the incremental package would no longer be small, or even apply. Bump the pin
# on purpose, test that build, then publish it as a new full base.
#
# Usage: scripts/pin_firmware.sh [<config> [<PDA/CSC/CP>]]
#   no arguments : pin qssi, flip-qssi and tab-qssi to the current FUS build
#   <config>     : one of the above (or a path to a config file)
#   <PDA/CSC/CP> : pin to this build instead of the current one

set -euo pipefail

SRC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGS=(qssi flip-qssi tab-qssi)

if [ "$#" -ge 1 ]; then
    CONFIGS=("$1")
fi
REQUESTED="${2:-}"

for c in "${CONFIGS[@]}"; do
    FILE="$c"
    [ -f "$FILE" ] || FILE="$SRC_DIR/unica/configs/$c.sh"
    if [ ! -f "$FILE" ]; then
        echo "Config not found: $c" >&2
        exit 1
    fi

    FIRMWARE="$(sed -n 's/^SOURCE_FIRMWARE="\([^"]*\)"/\1/p' "$FILE")"
    MODEL="$(cut -d "/" -f 1 <<< "$FIRMWARE")"
    CSC="$(cut -d "/" -f 2 <<< "$FIRMWARE")"
    if [ ! "$MODEL" ] || [ ! "$CSC" ]; then
        echo "No SOURCE_FIRMWARE in $FILE" >&2
        exit 1
    fi

    VERSION="$REQUESTED"
    if [ ! "$VERSION" ]; then
        VERSION="$(curl -fsSL --retry 3 \
            "https://fota-cloud-dn.ospserver.net/firmware/$CSC/$MODEL/version.xml" \
            | sed -n 's|.*<latest[^>]*>\([^<]*\)</latest>.*|\1|p' | head -n 1)"
    fi
    if [[ ! "$VERSION" =~ ^[A-Z0-9]+/[A-Z0-9]*/[A-Z0-9]*$ ]]; then
        echo "Could not get a firmware version for $MODEL/$CSC (got \"$VERSION\")" >&2
        exit 1
    fi

    if grep -q '^SOURCE_FIRMWARE_VERSION=' "$FILE"; then
        sed -i "s|^SOURCE_FIRMWARE_VERSION=.*|SOURCE_FIRMWARE_VERSION=\"$VERSION\"|" "$FILE"
    else
        sed -i "/^SOURCE_FIRMWARE=/a SOURCE_FIRMWARE_VERSION=\"$VERSION\"" "$FILE"
    fi
    echo "$(basename "$FILE" .sh): $MODEL/$CSC -> $VERSION"
done
