#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise ROM staging against real input, preservation and rejection paths."""
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile

here = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('viper_prepare', here / 'prepare.py')
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)
work = Path(sys.argv[1]).resolve()
ns = prepare.NS

# Inspect the shipped APK, not only source: systemExempted caused an observed
# service-start crash even with its permission granted on the dm3q device.
sdk = Path(os.environ.get('ANDROID_HOME', Path.home() / 'Android/Sdk'))
manifest = subprocess.check_output([
    str(sdk / 'build-tools/37.0.0/aapt2'), 'dump', 'xmltree',
    str(here / 'ViPER4Android.apk'), '--file', 'AndroidManifest.xml',
], text=True)
service = manifest.split('="com.llsl.viper4android.service.ViperService"', 1)[1].split('E: service', 1)[0]
assert 'foregroundServiceType' in service and '=0x40000000' in service, 'ViPER must use specialUse FGS'
assert 'android.permission.FOREGROUND_SERVICE_SPECIAL_USE' in manifest
assert 'android.permission.FOREGROUND_SERVICE_SYSTEM_EXEMPTED' not in manifest
print('PASS: compiled APK retains specialUse FGS and omits systemExempted permission')

def original_effects(data):
    root = ET.fromstring(data)
    for parent in root.iter():
        for child in list(parent):
            if child.get('name') in ('v4a_re', 'v4a_standard_re'):
                parent.remove(child)
    for element in root.iter():
        element.text = (element.text or '').strip() or None
        element.tail = (element.tail or '').strip() or None
    return ET.tostring(root)

with tempfile.TemporaryDirectory(prefix='unica-viper-test.') as directory:
    stage = Path(directory) / 'stage'
    stage.mkdir()
    candidates = [p for prefix in ('vendor/etc', 'system/system/etc', 'odm/etc')
                  for p in (work / prefix).rglob('audio_effects*.xml') if not p.is_symlink()]
    original_hashes = {p: prepare.sha(p) for p in candidates}
    prepare.main(work, stage)
    rows = [line.split('\t') for line in (stage / 'install.tsv').read_text().splitlines()]
    assert len(rows) == len({path for path, _ in rows})
    for path, _ in rows:
        output = stage / path
        if output.suffix == '.xml':
            ET.parse(output)
        if 'audio_effects' in output.name:
            before = (work / path).read_bytes()
            after = output.read_bytes()
            assert original_effects(before) == original_effects(after), path
            assert prepare.patch_effects(after) == after, 'Registration not idempotent'
    assert all(prepare.sha(p) == checksum for p, checksum in original_hashes.items()), 'Input tree modified'
    samsung = ET.parse(stage / 'vendor/etc/audio_effects_sec.xml').getroot()
    assert any(e.get('name') == 'dap_proxy' for e in samsung.iter())
    assert any(e.get('name') == 'soundalive' for e in samsung.iter())
    with zipfile.ZipFile(here / 'ViPER4Android-RE-v2.1.1.zip') as archive:
        for arch, abi in (('lib', 'armeabi-v7a'), ('lib64', 'arm64-v8a')):
            driver = stage / f'vendor/{arch}/soundfx/libv4a_re.so'
            assert driver.read_bytes() == archive.read(f'common/files/libv4a_re_{abi}.so')
            subprocess.run(['readelf', '-d', str(driver)], check=True, stdout=subprocess.PIPE)
    # Refuse an incompatible pre-existing effect instead of silently replacing it.
    conflict = (stage / 'vendor/etc/audio_effects_sec.xml').read_bytes().replace(b'path="libv4a_re.so"', b'path="other.so"')
    try:
        prepare.patch_effects(conflict)
        raise AssertionError('Conflicting driver accepted')
    except ValueError:
        pass
    wrong = Path(directory) / 'aidl/vendor/etc/vintf'
    wrong.mkdir(parents=True)
    (wrong / 'manifest.xml').write_text('<manifest><hal format="aidl"><name>android.hardware.audio.effect</name><version>3</version></hal></manifest>')
    try:
        prepare.main(wrong.parents[2], Path(directory) / 'rejected')
        raise AssertionError('AIDL vendor accepted')
    except ValueError as failure:
        assert 'HIDL' in str(failure)
    print(f'PASS: {len(rows)} staged files, original Samsung effects preserved, idempotence, conflict/HAL rejection, driver integrity')
