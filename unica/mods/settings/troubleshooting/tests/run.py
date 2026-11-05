#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the actual native worker in isolated /tmp storage; never touches a device."""
from pathlib import Path
import json,os,subprocess,tempfile,uuid,sqlite3
source=Path(__file__).resolve().parents[1]
work=Path(tempfile.mkdtemp(prefix='unica-troubleshooting-test-',dir='/tmp'))
worker=work/'worker'
subprocess.run(['g++','-std=c++17','-Wall','-Wextra','-Werror','-DTROUBLE_TEST',str(source/'native/worker.cpp'),'-ldl','-o',str(worker)],check=True)
base=work/'service';adb=work/'adb';system=work/'system'
for p in (base/'requests',base/'responses',adb/'modules',adb/'modules_update',system/'bin'):p.mkdir(parents=True)
(system/'bin/prophide.sh').write_text('test ROM marker\n')
mod=adb/'modules/overlap';mod.mkdir();(mod/'module.prop').write_text('id=overlap\nname=Overlap\nversion=1\n');(mod/'system.prop').write_text('ro.boot.flash.locked=0\n')
staged=adb/'modules_update/overlap';staged.mkdir();(staged/'module.prop').write_text('id=overlap\nname=Overlap\nversion=2\n')
def request(op='scan',stage='',name='',token='',error=False):
    identifier=str(uuid.uuid4());(base/'requests/request').write_text('\n'.join((identifier,op,stage,name,token))+'\n')
    run=subprocess.run([str(worker),str(base),str(adb),str(system)],check=False)
    result=json.loads((base/'responses/response.json').read_text());assert result['id']==identifier
    assert ('error' in result)==error,result
    assert run.returncode==(1 if error else 0),result
    return result.get('result',result)
def lookup(stage='modules'):
    return next(m for m in request()['modules'] if m['id']=='overlap' and m['stage']==stage)
m=lookup();assert 'ro.boot.flash.locked' in m['evidence']
request('disable','modules','overlap','stale-token',error=True);assert not (mod/'disable').exists()
request('disable','modules','overlap',m['token']);assert lookup()['owned'] and not (staged/'disable').exists()
request('restore','modules','overlap',m['token']);assert not (mod/'disable').exists()
(mod/'disable').write_text('user marker\n');request('disable','modules','overlap',m['token'],error=True);request('restore','modules','overlap',m['token'],error=True);assert (mod/'disable').read_text()=='user marker\n';(mod/'disable').unlink()
outside=work/'outside';outside.write_text('preserve me\n');(mod/'disable').symlink_to(outside);request('restore','modules','overlap',m['token'],error=True);assert outside.read_text()=='preserve me\n';(mod/'disable').unlink()
request('disable','modules','../outside',m['token'],error=True)
(mod/'module.prop').write_text('id=overlap\nname=Changed\nversion=3\n');request('disable','modules','overlap',m['token'],error=True)
linked=adb/'modules/linked';linked.symlink_to(mod,target_is_directory=True);result=request();assert all(m['id']!='linked' for m in result['modules']) and 'Cannot inspect linked' in result['warning']
(mod/'module.prop').unlink();(mod/'module.prop').symlink_to(outside);assert 'Cannot inspect overlap' in request()['warning'];assert outside.read_text()=='preserve me\n'
# Purpose rules require an exact ID and every corresponding installed ROM file.
import shutil
rules=system/'etc/unica/troubleshooting-root-purposes.tsv';rules.parent.mkdir(parents=True)
shutil.copyfile(source.parent/'system/etc/unica/troubleshooting-root-purposes.tsv',rules)
def add_module(name,label='Play Integrity Fix',stage='modules'):
    folder=adb/stage/name;folder.mkdir();(folder/'module.prop').write_text(f'id={name}\nname={label}\nversion=test\n');return folder
def entry(name,stage='modules'):
    return next(m for m in request()['modules'] if m['id']==name and m['stage']==stage)
pif=add_module('playintegrityfix');add_module('unknown_pif');add_module('zygisk_lsposed');add_module('zygisksu');add_module('mountify')
assert not entry('playintegrityfix')['duplicates']
for relative in ('lib64/libunica_pif.so','framework/framework.jar'):
    marker=system/relative;marker.parent.mkdir(parents=True,exist_ok=True);marker.write_text('fixture')
assert entry('playintegrityfix')['duplicates'][0]['feature']=='PIF'
assert not entry('playintegrityfix')['evidence'],'Purpose rule should work without overlays or properties'
for name in ('unknown_pif','zygisk_lsposed','zygisksu','mountify'):assert not entry(name)['duplicates']
add_module('playintegrityfix',stage='modules_update');assert entry('playintegrityfix','modules_update')['duplicates']
(pif/'disable').write_text('user marker');assert entry('playintegrityfix')['disabled'] and entry('playintegrityfix')['duplicates'];assert (pif/'disable').read_text()=='user marker'
marker=system/'lib64/libunica_pif.so';marker.unlink();marker.symlink_to(outside);assert not entry('playintegrityfix')['duplicates'];marker.unlink();marker.write_text('fixture')
add_module('tricky_store');add_module('unica_teesim_runtime_fix')
tee=('bin/unica-teesim-inject','framework/unica-teesim.jar','lib64/libunica_teesim.so','etc/init/unica-teesim.rc')
for relative in tee[:-1]:
    marker=system/relative;marker.parent.mkdir(parents=True,exist_ok=True);marker.write_text('fixture')
assert not entry('tricky_store')['duplicates']
marker=system/tee[-1];marker.parent.mkdir(parents=True,exist_ok=True);marker.write_text('fixture')
assert entry('tricky_store')['duplicates'][0]['feature']=='TEE Simulator'
assert entry('unica_teesim_runtime_fix')['duplicates']
with rules.open('a') as out:out.write('unknown_pif\tPIF\tInvalid path\t../outside\n')
assert not entry('unknown_pif')['duplicates']
print('Purpose rules passed: exact IDs, installed features, staged and disabled modules, infrastructure exclusions, symlink rejection')
# This schema matches the inspected device. WAL must be included; disabled state must survive.
config=adb/'lspd/config';config.mkdir(parents=True)
db=sqlite3.connect(config/'modules_config.db');db.execute('pragma journal_mode=wal');db.execute('pragma wal_autocheckpoint=0')
db.executescript('CREATE TABLE modules_state(module_pkg_name TEXT,user_id INTEGER,enabled INTEGER);CREATE TABLE scope(module_pkg_name TEXT,app_pkg_name TEXT,user_id INTEGER);')
db.execute('INSERT INTO modules_state VALUES (?,?,?)',('disabled.module',0,0));db.execute('INSERT INTO modules_state VALUES (?,?,?)',('enabled.module',0,1));db.execute('INSERT INTO scope VALUES (?,?,?)',('enabled.module','com.example',0));db.commit()
before={f.name:f.read_bytes() for f in config.iterdir() if f.name.endswith(('.db','-wal'))}
state=request()['lsposed'];assert state['available'],state
by_name={m['package']:m for m in state['modules']};assert not by_name['disabled.module']['enabled'];assert by_name['enabled.module']['enabled'] and by_name['enabled.module']['scopes']==['com.example']
assert before=={f.name:f.read_bytes() for f in config.iterdir() if f.name.endswith(('.db','-wal'))},'Live LSPosed DB/WAL changed'
assert not list(base.glob('lsposed-*')),'Private snapshots not cleaned up'
db.close()
classes=work/'classes';classes.mkdir()
subprocess.run(['javac','-d',str(classes),str(source/'java/io/mesalabs/unica/troubleshooting/LogTools.java'),str(source/'tests/LogToolsTest.java')],check=True)
subprocess.run(['java','-cp',str(classes),'io.mesalabs.unica.troubleshooting.LogToolsTest'],check=True)
print('Native worker passed: inventory, staged isolation, stale identity, reversible markers, pre-existing markers, symlink/path rejection; evidence:',work)
