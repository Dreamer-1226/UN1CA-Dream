#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Exercise the real ROM metadata helpers in an isolated copy of relevant inputs.
set -eo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
ROOT=$(cd "$HERE/../../.." && pwd)
INPUT=${1:?Usage: packaging.sh /path/to/work_dir}
TEST_ROOT=$(mktemp -d /tmp/unica-viper-packaging.XXXXXX)
python3 - "$INPUT" "$TEST_ROOT" <<'PY'
from pathlib import Path
import shutil
import sys
source, dest = map(Path, sys.argv[1:])
files = [source / 'system/system/etc/sysconfig/allowed-system-preload-apps.xml']
files += list((source / 'vendor/etc/vintf').rglob('*.xml'))
for prefix in ('vendor/etc', 'system/system/etc', 'odm/etc'):
    files += list((source / prefix).rglob('audio_effects*.xml'))
for file in files:
    if file.is_symlink():
        continue
    target = dest / file.relative_to(source)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(file, target)
(dest / 'configs').mkdir()
for partition in ('system', 'vendor', 'odm'):
    for kind in ('fs_config', 'file_context'):
        shutil.copy2(source / 'configs' / f'{kind}-{partition}', dest / 'configs' / f'{kind}-{partition}')
for directory in ('vendor/lib/soundfx', 'vendor/lib64/soundfx', 'system/system/priv-app',
                  'system/system/etc/permissions', 'system/system/etc/default-permissions'):
    if (source / directory).is_dir():
        (dest / directory).mkdir(parents=True, exist_ok=True)
PY
export SRC_DIR="$ROOT" WORK_DIR="$TEST_ROOT"
export TARGET_CODENAME=dm3q TARGET_PLATFORM_SDK_VERSION=37
export TARGET_OS_BUILD_SYSTEM_EXT_PARTITION=true
source "$ROOT/scripts/utils/common_utils.sh"
MODPATH="$HERE"
source "$HERE/customize.sh"
python3 - "$TEST_ROOT" <<'PY'
from pathlib import Path
import re
import sys
root = Path(sys.argv[1])
for partition in ('system', 'vendor'):
    config = (root / f'configs/fs_config-{partition}').read_text().splitlines()
    metadata = {line.split()[0]: line.split()[1:4] for line in config}
    for file in (root / partition).rglob('*'):
        if file.is_file() and (file.name == 'ViPER4Android.apk' or file.name == 'libv4a_re.so'):
            relative = file.relative_to(root).as_posix().replace('system/system/', 'system/')
            assert metadata[relative] == ['0', '0', '644'], relative
            for parent in file.parents:
                if parent == root / partition:
                    break
                key = parent.relative_to(root).as_posix().replace('system/system/', 'system/')
                # Existing source directories have metadata from the full ROM build;
                # newly created app/soundfx directories must be registered here.
                if parent.name == 'ViPER4Android':
                    assert metadata[key] == ['0', '0', '755'], key
            assert sum(line.startswith(relative + ' ') for line in config) == 1, relative
            contexts = [line.split() for line in (root / f'configs/file_context-{partition}').read_text().splitlines()]
            expected = 'system_file' if partition == 'system' else 'vendor_file'
            assert any(len(line) == 2 and re.fullmatch(line[0], '/' + relative)
                       and line[1] == f'u:object_r:{expected}:s0' for line in contexts), relative
print('PASS: real ADD_TO_WORK_DIR / SET_METADATA packaging, new app and driver directory modes')
PY
echo "Packaging test retained at $TEST_ROOT"
