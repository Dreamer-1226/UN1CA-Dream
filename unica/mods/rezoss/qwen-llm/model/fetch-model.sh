#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
DEST="${1:?Usage: fetch-model.sh OUTPUT_DIRECTORY}"
# Qwen3-0.6B (Apache-2.0) quantized to Q4_0, which llama.cpp repacks at load
# time for the dotprod (SM8250) and i8mm (SM8550) CPU kernels.
REPO=bartowski/Qwen_Qwen3-0.6B-GGUF
REV=60b85c0e3d8fe0f6474f406922a26d12aca4550d
FILE=Qwen_Qwen3-0.6B-Q4_0.gguf
NAME=qwen3-0.6b-q4_0.gguf
SHA=4b78d8e3c61976cebb78ef5affe19d0eca75b1b47ec66f613a5a3245484758d5
mkdir -p "$DEST"
if [[ ! -f "$DEST/$NAME" ]]; then
    curl --fail --location --retry 3 --continue-at - \
        "https://huggingface.co/$REPO/resolve/$REV/$FILE" \
        -o "$DEST/$NAME.part"
    printf '%s  %s\n' "$SHA" "$DEST/$NAME.part" | sha256sum -c -
    mv "$DEST/$NAME.part" "$DEST/$NAME"
fi
printf '%s  %s\n' "$SHA" "$DEST/$NAME" | sha256sum -c -
[[ $(stat -c %s "$DEST/$NAME") -le 3000000000 ]]
curl --fail --location --retry 3 \
    "https://huggingface.co/Qwen/Qwen3-0.6B/resolve/main/LICENSE" \
    -o "$DEST/QWEN-LICENSE"
