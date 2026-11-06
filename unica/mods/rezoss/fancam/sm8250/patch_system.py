#!/usr/bin/env python3
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
"""Apply the SM8250 My Fan Cam byte patches to the S26U (m3qxxx) system libraries."""
import hashlib
import json
import sys

spec_path, name, path = sys.argv[1:4]
spec = json.load(open(spec_path))[name]
data = bytearray(open(path, 'rb').read())
digest = hashlib.sha256(data).hexdigest()
if digest == spec['sha256_out']:
    print(f'{name}: already patched')
    sys.exit(0)
if digest != spec['sha256_in']:
    sys.exit(f'{name}: unexpected input {digest}')
for p in spec['patches']:
    off, old, new = p['off'], bytes.fromhex(p['old']), bytes.fromhex(p['new'])
    if data[off:off + len(old)] != old:
        sys.exit(f'{name}: mismatch at {off:#x}')
    data[off:off + len(new)] = new
if hashlib.sha256(data).hexdigest() != spec['sha256_out']:
    sys.exit(f'{name}: result does not match')
open(path, 'wb').write(data)
print(f'{name}: patched {len(spec["patches"])} ranges')
