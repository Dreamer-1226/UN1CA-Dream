#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Standalone diagnostic build; not part of ROM packaging and never installs an APK.
set -euo pipefail

probe_source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
probe_repo_dir="$(git -C "$probe_source_dir" rev-parse --show-toplevel)"
probe_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"
probe_tools="$probe_sdk/build-tools/37.0.0"
probe_android_jar="$probe_sdk/platforms/android-37.0/android.jar"
if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [new-output-directory]" >&2
    exit 2
fi
for probe_tool in javac keytool python3; do command -v "$probe_tool" >/dev/null; done
for probe_tool in aapt2 d8 zipalign apksigner; do [[ -x "$probe_tools/$probe_tool" ]]; done
[[ -f "$probe_android_jar" ]]
if [[ $# == 1 ]]; then
    probe_output="$(realpath -m -- "$1")"
    if [[ -e "$probe_output" ]]; then
        echo "Refusing to replace an existing output directory: $probe_output" >&2
        exit 1
    fi
    mkdir -p -- "$probe_output"
else
    mkdir -p "$probe_repo_dir/out/archived"
    probe_output="$(mktemp -d "$probe_repo_dir/out/archived/portrait-pair-probe.XXXXXX")"
fi
mkdir "$probe_output/classes" "$probe_output/dex"
javac -source 8 -target 8 -bootclasspath "$probe_android_jar:$probe_tools/core-lambda-stubs.jar" \
    -d "$probe_output/classes" "$probe_source_dir/ProbeActivity.java"
mapfile -d '' probe_classes < <(find "$probe_output/classes" -name '*.class' -print0)
"$probe_tools/d8" --lib "$probe_android_jar" --min-api 30 \
    --output "$probe_output/dex" "${probe_classes[@]}"
"$probe_tools/aapt2" link --manifest "$probe_source_dir/AndroidManifest.xml" \
    -I "$probe_android_jar" -o "$probe_output/unsigned.apk"
python3 - "$probe_output" <<'PY'
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import sys
root = Path(sys.argv[1])
with ZipFile(root / 'unsigned.apk', 'a', ZIP_DEFLATED) as archive:
    for dex in sorted((root / 'dex').glob('*.dex')):
        archive.write(dex, dex.name)
PY
"$probe_tools/zipalign" -p 4 "$probe_output/unsigned.apk" "$probe_output/aligned.apk"
keytool -genkeypair -keystore "$probe_output/debug.keystore" -storepass android \
    -keypass android -alias androiddebugkey -dname 'CN=Portrait Pair Diagnostic' \
    -keyalg RSA -keysize 2048 -validity 3650 >/dev/null 2>&1
"$probe_tools/apksigner" sign --ks "$probe_output/debug.keystore" --ks-pass pass:android \
    --key-pass pass:android --out "$probe_output/PortraitPairProbe.apk" "$probe_output/aligned.apk"
"$probe_tools/apksigner" verify "$probe_output/PortraitPairProbe.apk"
python3 - "$probe_output/PortraitPairProbe.apk" <<'PY'
from zipfile import ZipFile
import sys
with ZipFile(sys.argv[1]) as archive:
    assert archive.testzip() is None
    assert {'AndroidManifest.xml', 'classes.dex'} <= set(archive.namelist())
print(sys.argv[1])
PY
