#!/usr/bin/env python3
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
"""Make ChoiDujour's string decoder answer the two update URLs directly.

ChoiDujour keeps its strings obfuscated and decodes them at run time through a
single static String(long) method. Prepend a check for the two keys that decode
to the update URLs, so the app reads our manifest and changelogs instead:
  0x5c18d66cd5d38297 -> <base>manifest.json
  0x5c18db24d5d38297 -> <base>           (changelog: <base><version>.txt)
"""
import re
import sys

path, method, base = sys.argv[1:4]
if not base.startswith('https://') or not base.endswith('/') or '"' in base or '\\' in base:
    sys.exit(f'invalid OTA base URL: {base}')
text = open(path).read()
head = re.compile(r'\.method public static (?:final )?' + re.escape(method) +
                  r'\(J\)Ljava/lang/String;\n\s*\.locals (\d+)\n')
match = head.search(text)
if not match:
    sys.exit(f'{method}(J) not found in {path}')
if 'unica_ota_manifest' in text:
    sys.exit(0)
if int(match.group(1)) < 2:
    sys.exit('decoder has fewer than two locals')
inject = ''
for key, label, url in (('0x5c18d66cd5d38297L', 'unica_ota_manifest', base + 'manifest.json'),
                        ('0x5c18db24d5d38297L', 'unica_ota_changelog', base)):
    inject += (f'    const-wide v0, {key}\n'
               f'    cmp-long v0, p0, v0\n'
               f'    if-nez v0, :{label}\n'
               f'    const-string v0, "{url}"\n'
               f'    return-object v0\n'
               f'    :{label}\n')
open(path, 'w').write(text[:match.end()] + inject + text[match.end():])
