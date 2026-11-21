#!/usr/bin/env python3
# Copyright (c) 2026 ssch71
# SPDX-License-Identifier: GPL-3.0-or-later
"""Catch AbstractMethodError around IProcessObserver$Stub's onProcessStarted call.

Register-agnostic: wraps whichever invoke the donor's onTransact uses and
resumes right after it, so it applies to every One UI 9 donor.
"""
import re
import sys

path = sys.argv[1]
text = open(path).read()
if ':try_start_ipo' in text:
    print('already patched')
    sys.exit(0)
call = re.compile(r'^(?P<ind>[ \t]*)(?P<inv>invoke-virtual(?:/range)? \{[^}\n]*\}, '
                  r'Landroid/app/IProcessObserver\$Stub;->onProcessStarted\(IIILjava/lang/String;Ljava/lang/String;\)V)$',
                  re.M)
found = list(call.finditer(text))
if len(found) != 1:
    sys.exit(f'expected one onProcessStarted call, found {len(found)}')
m = found[0]
end = text.find('\n.end method', m.end())
if end < 0:
    sys.exit('no end of method after the call')
ind = m.group('ind')
wrapped = (f'{ind}:try_start_ipo\n{ind}{m.group("inv")}\n{ind}:try_end_ipo\n'
           f'{ind}.catch Ljava/lang/AbstractMethodError; {{:try_start_ipo .. :try_end_ipo}} :catch_ipo\n'
           f'{ind}:resume_ipo')
handler = f'\n\n{ind}:catch_ipo\n{ind}goto :resume_ipo'
text = text[:m.start()] + wrapped + text[m.end():end] + handler + text[end:]
open(path, 'w').write(text)
print('patched')
