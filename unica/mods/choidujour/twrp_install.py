#!/usr/bin/env python3
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
"""Let UN1CA Updates install through TWRP's OpenRecoveryScript.

Before installing, the app writes /cache/recovery/openrecoveryscript
("install <package>"), then calls RecoverySystem.installPackage(). For a package
under /data that framework call leaves recovery "--update_package=@/cache/
recovery/block.map", which only works once uncrypt has mapped the file; TWRP
then starts and installs nothing. Reboot into recovery instead and let TWRP run
the script it already got: it decrypts /data and installs the package itself.

  twrp_install.py <decoded apk dir>
"""
import pathlib
import re
import sys

CALL = re.compile(
    r'^(?P<ind>[ \t]*)invoke-static \{(?P<ctx>[vp]\d+), (?P<file>[vp]\d+)\}, '
    r'Landroid/os/RecoverySystem;->installPackage\(Landroid/content/Context;Ljava/io/File;\)V$',
    re.M)


def replacement(m):
    i, ctx, tmp = m.group('ind'), m.group('ctx'), m.group('file')
    return '\n'.join([
        f'{i}const-string {tmp}, "power"',
        f'{i}invoke-virtual {{{ctx}, {tmp}}}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;',
        f'{i}move-result-object {ctx}',
        f'{i}check-cast {ctx}, Landroid/os/PowerManager;',
        f'{i}const-string {tmp}, "recovery"',
        f'{i}invoke-virtual {{{ctx}, {tmp}}}, Landroid/os/PowerManager;->reboot(Ljava/lang/String;)V',
    ])


root = pathlib.Path(sys.argv[1])
hits = [p for p in root.glob('smali*/**/*.smali') if CALL.search(p.read_text())]
if len(hits) != 1:
    sys.exit(f'expected one RecoverySystem.installPackage call, found {len(hits)}')
path = hits[0]
text = path.read_text()
if len(CALL.findall(text)) != 1:
    sys.exit(f'{path.name}: expected one installPackage call')
path.write_text(CALL.sub(replacement, text))
print(f'{path.relative_to(root)}: installPackage -> PowerManager.reboot("recovery")')
