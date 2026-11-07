#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Validate catalog compilation and exclusion behavior without touching ROM/device state."""
from pathlib import Path
import copy,importlib.util,json,tempfile
base=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('catalog',base/'compile-catalog.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
data=json.loads((base/'compatibility-catalog.json').read_text());repo=base.parents[3]
outputs=module.compile_catalog(data,repo)
assert all((base.parent/'system/etc/unica'/name).read_text()==value for name,value in outputs.items())
purposes=json.loads(outputs['troubleshooting-lsposed-purposes.json'])['rules']
assert any(r['package']=='io.github.soclear.oneuix' and r['scope']=='system' for r in purposes)
assert any(r['package']=='org.lsposed.corepatch' for r in purposes)
assert not json.loads(outputs['troubleshooting-lsposed-conflicts.json'])['rules']
assert all('*' not in r['scope'] for r in purposes)
assert 'teesim\t' in outputs['troubleshooting-root-purposes.tsv']
assert 'PixelifyPhotos\t' in outputs['troubleshooting-root-purposes.tsv']
assert 'fontrevival\t' not in outputs['troubleshooting-root-purposes.tsv']
assert all(i['kind']!='app' for e in data['entries'] if e['rules'] for i in e['identities'])
assert all(not e['rules'] for e in data['entries'] if e['verification'] in ('pending','unverified'))
# Shared IDs across forks collapse to one rule per feature.
assert sum(line.startswith('playintegrityfix\t') for line in outputs['troubleshooting-root-purposes.tsv'].splitlines())==1
work=Path(tempfile.mkdtemp(prefix='unica-catalog-test-',dir='/tmp'))
fixture={'schema':1,'updated':'2026-11-07','features':{'test':{'name':'Test','sources':['unica/mods/test/feature.patch'],'feature_class':'TestFeature','required_files':['framework/framework.jar']}},'entries':[{'key':'test','verification':'verified','identities':[{'kind':'lsposed','value':'com.example.test','verified_on':'2026-11-07','sources':['https://example.org/source']}],'rules':[{'classification':'duplicate','feature':'test','scopes':['android']}]}]}
source=work/'unica/mods/test/feature.patch';source.parent.mkdir(parents=True);source.write_text('fixture')
assert len(json.loads(module.compile_catalog(fixture,work)['troubleshooting-lsposed-purposes.json'])['rules'])==1
(source.parent/'disable').touch();assert not json.loads(module.compile_catalog(fixture,work)['troubleshooting-lsposed-purposes.json'])['rules'];(source.parent/'disable').unlink()
(work/'unica/mods/disable').touch();assert not json.loads(module.compile_catalog(fixture,work)['troubleshooting-lsposed-purposes.json'])['rules'];(work/'unica/mods/disable').unlink()
def rejected(value):
 try:module.compile_catalog(value,work)
 except (ValueError,KeyError):return
 raise AssertionError('Invalid rule accepted')
for change in ('pending','unverified','not_applicable','wildcard','confirmed','app','path','policy'):
 bad=copy.deepcopy(fixture);entry=bad['entries'][0]
 if change in ('pending','unverified','not_applicable'):entry['verification']=change
 if change=='policy':entry['policy_conflict']={'group':'missing','authority':'user','status':'classified'}
 if change=='wildcard':entry['rules'][0]['scopes']=['*']
 if change=='confirmed':entry['rules'][0]['classification']='confirmed_conflict'
 if change=='app':entry['identities'][0]['kind']='app'
 if change=='path':bad['features']['test']['sources']=['../outside']
 rejected(bad)
print('Catalog passed: generated tables current, exact IDs/scopes, fork deduplication, pending/app exclusion, disabled feature gates, malformed/unsupported conflict rejection; evidence:',work)

assert sum(bool(e.get('policy_conflict')) for e in data['entries'])==28
assert not any(e['verification']=='pending' for e in data['entries'])
print('Maintainer classifications passed: all 28 retained entries assigned, no pending classifications, unverified identities remain excluded')

info=json.loads(outputs['troubleshooting-registry-info.json'])
assert info['verified_entries']>=60
assert not any(e['name']=='KeyboxHub' for e in data['entries'])
assert next(e for e in data['entries'] if e['name']=='ForgeStore')['policy_conflict']['group']=='tee'
assert info['root_rules']<=128
hma=[r for r in purposes if r['package']=='org.frknkrc44.hma_oss']
assert sorted(r['scope'] for r in hma)==['android','system']
assert any(r['package']=='com.google.android.hmal' and r['scope']=='android' for r in purposes)
assert any(r['package']=='com.coderstory.toolkit' for r in purposes)
roots=outputs['troubleshooting-root-purposes.tsv']
for identity in ('playcurlNEXT','specter','Yurikey','oh_my_keymint','TA_utl','kp_enhancer','MFGA','Pixelify','Fontchanger','fs_enhancer_extreme'):
 assert any(line.startswith(identity+'\t') for line in roots.splitlines()),identity
assert not any(line.startswith('ForgeStore\t') for line in roots.splitlines())
print('Upstream identity regression checks passed: shared IDs, HMA scope deduplication, exact case and no invented ForgeStore ID')
