#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Build only: never pushes files or opens a device camera.
set -euo pipefail
probe_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
probe_repo="$(git -C "$probe_source" rev-parse --show-toplevel)"
probe_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"
probe_tools="$probe_sdk/build-tools/37.0.0"
probe_jar="$probe_sdk/platforms/android-37.0/android.jar"
probe_output="$(mktemp -d "$probe_repo/out/archived/portrait-pair-root.XXXXXX")"
mkdir "$probe_output/classes" "$probe_output/dex"
javac -source 8 -target 8 -bootclasspath "$probe_jar:$probe_tools/core-lambda-stubs.jar" \
    -d "$probe_output/classes" "$probe_source/PrivilegedProbe.java"
mapfile -d '' probe_classes < <(find "$probe_output/classes" -name '*.class' -print0)
"$probe_tools/d8" --lib "$probe_jar" --min-api 30 --output "$probe_output/dex" "${probe_classes[@]}"
python3 - "$probe_output" <<'PY'
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import sys
p=Path(sys.argv[1])
with ZipFile(p/'probe.jar','x',ZIP_DEFLATED) as z:
    for f in sorted((p/'dex').glob('*.dex')): z.write(f,f.name)
print(p/'probe.jar')
PY
