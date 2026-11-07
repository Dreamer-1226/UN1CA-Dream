#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run actual read-only setup checks and existing validators with isolated Android stubs."""
from pathlib import Path
import subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1];work=Path(tempfile.mkdtemp(prefix='unica-setup-test-',dir='/tmp'));jar=Path(sys.argv[1]).resolve()
def write(name,text):
 p=work/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
write('android/content/Context.java','package android.content;public class Context {public ClassLoader getClassLoader(){return getClass().getClassLoader();}public Object getContentResolver(){return null;}public java.io.File getCacheDir(){return new java.io.File(System.getProperty("java.io.tmpdir"));}}')
write('android/os/SystemClock.java','package android.os;public class SystemClock {public static long elapsedRealtime(){return 100000;}}')
write('android/os/SemSystemProperties.java','package android.os;public class SemSystemProperties {public static final java.util.Map<String,String> values=new java.util.HashMap<>();public static String get(String k,String d){return values.getOrDefault(k,d);}}')
write('android/provider/Settings.java','package android.provider;public class Settings {public static class Secure {public static final java.util.Map<String,String> values=new java.util.HashMap<>();public static String getString(Object r,String k){return values.get(k);}}}')
write('io/mesalabs/unica/PlayIntegrityHooks.java','package io.mesalabs.unica;public class PlayIntegrityHooks {}')
write('io/mesalabs/unica/troubleshooting/SetupChecksTest.java',r'''
package io.mesalabs.unica.troubleshooting;
import java.util.*;import android.provider.Settings;import android.os.SemSystemProperties;
public class SetupChecksTest {
static void check(boolean b){if(!b)throw new AssertionError();}
public static void main(String[]args)throws Exception{
 Map<String,String> p=new HashMap<>();check(SetupChecks.pifErrors(p).isEmpty());
 p.put("pif.fingerprint","google/bluejay/bluejay:12/ID/123:user/release-keys");check(SetupChecks.pifErrors(p).isEmpty());
 p.put("pif.fingerprint","secret-malformed-fingerprint");check(!SetupChecks.pifErrors(p).isEmpty());check(!SetupChecks.pifErrors(p).contains("secret-malformed"));p.clear();
 p.put("pif.security_patch","2026-02-30");check(!SetupChecks.pifErrors(p).isEmpty());p.clear();p.put("pif.first_api_level","0");check(!SetupChecks.pifErrors(p).isEmpty());p.clear();p.put("unica.pif","garbage");check(!SetupChecks.pifErrors(p).isEmpty());
 check(SetupChecks.fresh("99999",100000));check(!SetupChecks.fresh("88000",100000));check(!SetupChecks.fresh("100001",100000));check(!SetupChecks.fresh("0",100000));
 check(SetupChecks.runtime(true,true,true,true,true,true).startsWith("Runtime verified"));
 check(SetupChecks.runtime(true,false,true,true,true,true).startsWith("Not verified"));
 check(SetupChecks.runtime(true,true,true,true,false,true).startsWith("Problem found"));
 check(SetupChecks.runtime(false,true,true,true,true,true).startsWith("Not verified"));
 String success="11-05 12:00:00.000 100 100 I UnicaPIF: Initialized com.google.android.gms.unstable: Build=1 nativeProps=1";
 check(SetupChecks.pifEvidence(success).contains("historical evidence"));
 check(!SetupChecks.pifEvidence(success.replace("UnicaPIF:","OtherTag:")).contains("historical evidence"));
 check(!SetupChecks.pifEvidence(success.replace("gms.unstable","gms")).contains("historical evidence"));
 check(SetupChecks.pifEvidence(success+"\n11-05 12:01:00.000 100 100 E UnicaPIF: Startup error: SECRET").startsWith("Problem found"));
 check(!SetupChecks.pifEvidence("11-05 E UnicaPIF: Startup error: SECRET").contains("SECRET"));
 Settings.Secure.values.put("unica_keybox_data","PRIVATE-KEY-SENTINEL");
 String report=SetupChecks.collect(new android.content.Context());check(report.contains("validation failed"));check(!report.contains("PRIVATE-KEY-SENTINEL"));
 Settings.Secure.values.clear();report=SetupChecks.collect(new android.content.Context());check(report.contains("no selected keybox"));
 SemSystemProperties.values.put("persist.sys.unica.pif","false");report=SetupChecks.collect(new android.content.Context());check(report.contains("PIF is switched off"));
 check(Settings.Secure.values.isEmpty());check(SemSystemProperties.values.size()==1);
 System.out.println("Setup checks passed: property formats, heartbeat freshness, readiness, target-specific logs, historical evidence, real profile/keybox validation, secret exclusion and no settings writes");
}}
''')
classes=work/'classes';classes.mkdir()
sources=list(work.rglob('*.java'))+[root/'java/io/mesalabs/unica/troubleshooting'/f for f in ('SetupChecks.java','LogTools.java')]+[root.parent/'keybox/java/io/mesalabs/unica/keybox'/f for f in ('Profiles.java','Keybox.java','Roots.java')]
subprocess.run(['javac','-cp',str(jar),'-d',str(classes),*[str(p) for p in sources]],check=True)
subprocess.run(['java','-Djava.io.tmpdir='+str(work),'-cp',str(classes)+':'+str(jar),'io.mesalabs.unica.troubleshooting.SetupChecksTest'],check=True)
print('Evidence:',work)
