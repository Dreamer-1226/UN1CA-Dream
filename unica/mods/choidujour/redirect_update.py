#!/usr/bin/env python3
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
"""Point Settings > Software update at UN1CA Updates.

Finds the stock top-level Software update preference (key containing
"software_update") in the decoded SecSettings top-level XML files and makes it
open io.mesalabs.choidujour/.activity.HomeActivity: its own fragment and
controller are dropped (they lead to and depend on the stock FOTA client), its
title, icon, layout and order are kept.
"""
import re
import sys
from pathlib import Path

INTENT = ('<intent android:targetPackage="io.mesalabs.choidujour" '
          'android:targetClass="io.mesalabs.choidujour.activity.HomeActivity">'
          '<extra android:name="from_settings" android:value="true" /></intent>')
START = re.compile(r'<(?P<tag>[\w.]+)(?P<attrs>\s[^<>]*?android:key="(?P<key>[^"]*software_update[^"]*)"[^<>]*?)\s*(?P<end>/?)>')

res = Path(sys.argv[1])
files = sorted(res.glob('xml*/sec_top_level_settings*.xml'))
done = 0
for path in files:
    text = path.read_text()
    if 'io.mesalabs.choidujour.activity.HomeActivity' in text:
        done += 1
        continue
    found = [m for m in START.finditer(text) if m.group('key') == 'top_level_software_update'] \
        or list(START.finditer(text))
    if not found:
        continue
    if len(found) > 1:
        sys.exit(f'{path.name}: several software update preferences: '
                 + ', '.join(m.group('key') for m in found))
    m = found[0]
    attrs = re.sub(r'\s(?:android:fragment|settings:controller)="[^"]*"', '', m.group('attrs'))
    tag = m.group('tag')
    if m.group('end'):
        stop = m.end()
    else:
        close = text.find(f'</{tag}>', m.end())
        if close < 0:
            sys.exit(f'{path.name}: no closing tag for {tag}')
        stop = close + len(f'</{tag}>')
    text = text[:m.start()] + f'<{tag}{attrs}>{INTENT}</{tag}>' + text[stop:]
    path.write_text(text)
    print(f'{path.relative_to(res)}: {m.group("key")} -> UN1CA Updates')
    done += 1
if not done:
    sys.exit('no Software update preference in the top-level Settings XML')
