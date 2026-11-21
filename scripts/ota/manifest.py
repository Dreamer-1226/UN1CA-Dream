#!/usr/bin/env python3
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
"""Maintain the UN1CA Updates (ChoiDujour) manifest on the ota branch.

  manifest.py add <manifest.json> <package.zip> <url>
  manifest.py check <manifest.json>

ChoiDujour offers an entry when device == ro.unica.device, datetime is not older
than ro.unica.timestamp, and incremental is 0 (full package) or equal to
ro.unica.timestamp (incremental built from the installed build). The values come
from the package's build_info.txt, which the UN1CA zip builders write.
"""
import hashlib
import json
import os
import sys
import zipfile

FIELDS = ('datetime', 'device', 'filename', 'id', 'patch', 'size', 'urls', 'version', 'incremental')


def load(path):
    if not os.path.exists(path):
        return {'response': []}
    with open(path) as f:
        data = json.load(f)
    if not isinstance(data.get('response'), list):
        raise SystemExit(f'{path}: no "response" list')
    return data


def save(path, data):
    data['response'].sort(key=lambda e: (e['device'], -e['datetime'], e['incremental']))
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path + '.tmp', 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    os.replace(path + '.tmp', path)


def build_info(package):
    with zipfile.ZipFile(package) as z:
        text = z.read('build_info.txt').decode()
    info = dict(line.split('=', 1) for line in text.splitlines() if '=' in line)
    for key in ('device', 'version', 'timestamp', 'security_patch_version', 'incremental'):
        if not info.get(key):
            raise SystemExit(f'{package}: build_info.txt has no {key}')
    return info


def check(data):
    seen = set()
    for i, e in enumerate(data['response']):
        missing = [k for k in FIELDS if k not in e]
        if missing:
            raise SystemExit(f'entry {i}: missing {missing}')
        if not e['urls'] or not all(u.startswith('https://') for u in e['urls']):
            raise SystemExit(f'entry {i}: bad urls')
        if e['incremental'] and e['incremental'] >= e['datetime']:
            raise SystemExit(f'entry {i}: incremental source is not older than the build')
        if e['filename'] in seen:
            raise SystemExit(f'entry {i}: duplicate filename {e["filename"]}')
        seen.add(e['filename'])


def add(path, package, url):
    info = build_info(package)
    sha = hashlib.sha256()
    with open(package, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            sha.update(chunk)
    entry = {
        'datetime': int(info['timestamp']),
        'device': info['device'],
        'filename': os.path.basename(package),
        'id': hashlib.sha256(f'{sha.hexdigest()} {info["timestamp"]}'.encode()).hexdigest(),
        'patch': info['security_patch_version'],
        'size': os.path.getsize(package),
        'urls': [url],
        'version': info['version'],
        'incremental': int(info['incremental']),
    }
    data = load(path)
    data['response'] = [e for e in data['response'] if e.get('filename') != entry['filename']]
    data['response'].append(entry)
    check(data)
    save(path, data)
    kind = 'full' if entry['incremental'] == 0 else f'incremental from {entry["incremental"]}'
    print(f'{entry["device"]} {entry["datetime"]} ({kind}): {entry["filename"]}')


if __name__ == '__main__':
    if len(sys.argv) == 5 and sys.argv[1] == 'add':
        add(*sys.argv[2:])
    elif len(sys.argv) == 3 and sys.argv[1] == 'check':
        check(load(sys.argv[2]))
        print('ok')
    else:
        raise SystemExit(__doc__)
