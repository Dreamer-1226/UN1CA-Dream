#!/usr/bin/env python3
# Copyright (c) 2026 Rezoss
# SPDX-License-Identifier: GPL-3.0-or-later
"""Resolve known AOD obfuscation drift and preflight the ordered patch stack."""
import argparse
import difflib
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path


def unique(values, description):
    if len(values) != 1:
        raise ValueError(f'{description}: expected one match, found {len(values)}')
    return values[0]


PROVIDER_GLOB = 'smali*/com/samsung/android/app/aodservice/provider/AODContentProvider.smali'
SYNC_CALL = 'Lio/mesalabs/unica/aod/ClockFontSettingsSync;->syncAodLockClockStyle(Landroid/content/Context;)V'


def provider_hook_diff(decoded):
    """Rebuild the AODContentProvider startup hook against the decoded APK.

    Galaxy Store AOD builds move the DBAdapter field and the provider's
    register layout, so the fixed-line hunk in 0003 stops applying. Hook
    onCreate() right before its final "return true", after the DBAdapter is
    set up, and fetch the Context with getContext() into v0. v0 is free there
    because only the constant return follows.
    """
    path = unique(list(decoded.glob(PROVIDER_GLOB)), 'AODContentProvider')
    rel = path.relative_to(decoded).as_posix()
    lines = path.read_text().splitlines(keepends=True)
    start = unique([i for i, line in enumerate(lines) if re.fullmatch(r'\.method public (final )?onCreate\(\)Z\n', line)],
                   'AODContentProvider.onCreate')
    end = next(i for i in range(start, len(lines)) if lines[i] == '.end method\n')
    found = re.match(r'^    \.locals (\d+)\n$', lines[start + 1])
    if not found or int(found.group(1)) < 1:
        raise ValueError('AODContentProvider.onCreate has no free local register')
    body = [i for i in range(start + 2, end) if lines[i].strip()]
    ret, const = body[-1], body[-2]
    reg = re.fullmatch(r'const/4 ([vp]\d+), 0x1', lines[const].strip())
    if not reg or lines[ret].strip() != 'return ' + reg.group(1):
        raise ValueError('AODContentProvider.onCreate does not end with "return true"')
    if not any('/DBAdapter;' in lines[i] for i in range(start, const)):
        raise ValueError('AODContentProvider.onCreate no longer sets up DBAdapter')
    hook = ['    invoke-virtual {p0}, Landroid/content/ContentProvider;->getContext()Landroid/content/Context;\n',
            '\n',
            '    move-result-object v0\n',
            '\n',
            '    invoke-static {v0}, ' + SYNC_CALL + '\n',
            '\n']
    patched = lines[:const] + hook + lines[const:]
    diff = difflib.unified_diff(lines, patched, 'a/' + rel, 'b/' + rel, n=3)
    return f'diff --git a/{rel} b/{rel}\n' + ''.join(diff)


def replace_provider_section(content, section):
    parts = re.split(r'(?m)^(?=diff --git )', content)
    hits = [i for i, part in enumerate(parts) if part.startswith('diff --git ') and 'AODContentProvider.smali' in part.splitlines()[0]]
    unique(hits, '0003 AODContentProvider section')
    parts[hits[0]] = section if section.endswith('\n') else section + '\n'
    return ''.join(parts)


def prepare(decoded, templates, output, native_full=False):
    owners = []
    for path in decoded.glob('smali*/**/*.smali'):
        if path.parent.name != 'aod':
            continue
        text = path.read_text()
        if all(re.search(r'^\.field .*\b' + name + ':' + kind + r'$', text, re.M)
               for name, kind in [('sSystemFontMap', 'Ljava/util/HashMap;'),
                                  ('sIsSystemFontMapInitialized', 'Z'),
                                  ('sIsSystemFontListInitialized', 'Z')]):
            owners.append((path, text))
    owner, text = unique(owners, 'system font-map owner')
    descriptor = unique(re.findall(r'^\.class .* (L[^;]+;)$', text, re.M), 'font owner descriptor')
    # The hook uses v0/v1 and p0/p1; reject changed parameter/register layouts.
    unique(re.findall(r'\.method public static h\(Landroid/content/Context;Ljava/lang/String;\)Landroid/graphics/Typeface;\n    \.locals 6\n\n    sget-object v0, '
                      + re.escape(descriptor) + r'->sSystemFontMap:Ljava/util/HashMap;', text),
           'font lookup method entry')
    font_path = owner.relative_to(decoded).as_posix()
    provider = unique(list(decoded.glob('smali*/com/samsung/android/app/facewidget/utils/KeyguardClockProvider.smali')),
                      'KeyguardClockProvider')
    provider_text = provider.read_text()
    method = unique(re.findall(r'^\.method public final getAODClockType\(\)I\n(.*?)^\.end method',
                              provider_text, re.M | re.S), 'getAODClockType method')
    if not method.startswith('    .locals 4\n\n'):
        raise ValueError('getAODClockType register layout changed')
    unique(re.findall(r'^\.method public getLockClockType\(\)I$', provider_text, re.M),
           'lockscreen clock type getter')
    controller_type = unique(re.findall(
        r'invoke-virtual \{v0\}, Lcom/samsung/android/app/facewidget/FaceWidgetController;->b\(\)(Laod/[^;]+;)',
        method), 'AOD controller return type')
    patches = sorted(templates.glob('*.patch'))
    if len(patches) != 9:
        raise ValueError(f'Expected nine AOD patches, found {len(patches)}')
    if native_full:
        patches = [p for p in patches if p.name[:4] in ("0001", "0002", "0003", "0007")]
    generated = []
    for patch in patches:
        content = patch.read_text()
        if patch.name.startswith('0003-'):
            content = replace_provider_section(content, provider_hook_diff(decoded))
        content = content.replace('smali_classes3/aod/rl2.smali', font_path)
        content = content.replace('Laod/rl2;', descriptor)
        if patch.name.startswith('0007-'):
            content = content.replace('Laod/x89;', controller_type)
            content = content.replace('smali/com/samsung/android/app/facewidget/utils/KeyguardClockProvider.smali',
                                      provider.relative_to(decoded).as_posix())
        generated.append((patch.name, content))
    # Never touch the build decode until every patch has passed in order.
    with tempfile.TemporaryDirectory(prefix='unica-aod-preflight-') as scratch:
        trial = Path(scratch) / 'decoded'
        shutil.copytree(decoded, trial)
        for name, content in generated:
            command = ['patch', '--batch', '--fuzz=0', '-p1', '-N', '--forward', '-l', '-d', str(trial)]
            for extra in (['--dry-run'], []):
                result = subprocess.run(command + extra, input=content, text=True,
                                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                        env={**os.environ, 'LC_ALL': 'C'})
                if result.returncode:
                    raise ValueError(f'{name} preflight failed:\n{result.stdout}')
            print(f'AOD preflight passed: {name}', flush=True)
    output.mkdir(parents=True, exist_ok=True)
    for name, content in generated:
        destination = output / name
        with destination.open('x') as handle:
            handle.write(content)
    print(f'AOD dynamic font owner: {descriptor} ({font_path})', flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('decoded', type=Path)
    parser.add_argument('templates', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--native-full', action='store_true', help='Keep font-bank, identity synchronization and lockscreen style; native port owns normalization/widgets')
    args = parser.parse_args()
    try:
        prepare(args.decoded, args.templates, args.output, args.native_full)
    except (ValueError, OSError) as error:
        parser.exit(1, f'AOD adaptation stopped safely: {error}\n')


if __name__ == '__main__':
    main()
