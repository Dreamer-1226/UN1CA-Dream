#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Test real LSPosed matching with isolated Android stubs. Pass an org.json JAR."""
from pathlib import Path
import json,subprocess,sys,tempfile
root=Path(__file__).resolve().parents[1];work=Path(tempfile.mkdtemp(prefix='unica-lsposed-rules-',dir='/tmp'));jar=Path(sys.argv[1]).resolve()
def write(name,text):
    p=work/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
write('android/content/Context.java','package android.content; public class Context { public android.content.pm.PackageManager getPackageManager(){return new android.content.pm.PackageManager();} public ClassLoader getClassLoader(){return getClass().getClassLoader();}}')
write('android/content/pm/ApplicationInfo.java','package android.content.pm; public class ApplicationInfo {}')
write('android/content/pm/PackageInfo.java','package android.content.pm; public class PackageInfo {public ApplicationInfo applicationInfo=new ApplicationInfo();public long getLongVersionCode(){return 1;}}')
write('android/content/pm/PackageManager.java','package android.content.pm; public class PackageManager {public static final int CERT_INPUT_SHA256=1;public static class NameNotFoundException extends Exception {} public PackageInfo getPackageInfo(String p,int f)throws NameNotFoundException{if(p.equals("missing.package"))throw new NameNotFoundException();return new PackageInfo();} public CharSequence getApplicationLabel(ApplicationInfo i){return "Test module";}public boolean hasSigningCertificate(String p,byte[] d,int t){return true;}}')
write('io/mesalabs/unica/HmaPolicy.java','package io.mesalabs.unica;public class HmaPolicy {}')
write('io/mesalabs/unica/troubleshooting/InstalledModulesTest.java',r'''
package io.mesalabs.unica.troubleshooting;
import org.json.*;import java.io.*;import android.content.Context;
public class InstalledModulesTest {
static File conflicts,purposes;static Context context=new Context();
static JSONArray scan(String pkg,boolean enabled,String scope,boolean available)throws Exception{
 JSONObject state=new JSONObject().put("available",available).put("modules",new JSONArray().put(new JSONObject().put("package",pkg).put("enabled",enabled).put("scopes",new JSONArray().put(scope))));
 return InstalledModules.scan(context,state,conflicts,purposes);
}
static void check(boolean value){if(!value)throw new AssertionError();}
public static void main(String[]args)throws Exception{
 purposes=new File(args[0]);conflicts=new File(args[1]);
 JSONArray found=scan("com.tsng.hidemyapplist",true,"android",true);
 check(found.length()==1&&found.getJSONObject(0).getBoolean("duplicate")&&!found.getJSONObject(0).getBoolean("confirmed"));
 check(found.getJSONObject(0).getString("unica_mod").equals("HMA"));
 check(scan("com.tsng.hidemyapplist",false,"android",true).length()==0);
 check(scan("com.tsng.hidemyapplist",true,"com.whatsapp",true).length()==0);
 check(scan("com.tsng.hidemyapplist.clone",true,"android",true).length()==0);
 check(scan("com.tsng.hidemyapplist",true,"android",false).length()==0);
 check(scan("com.rezoss.moseygmshook",true,"com.google.android.gms",true).length()==0);
 check(scan("app.djzrevamp.wa",true,"com.whatsapp",true).length()==0);
 String original=new String(java.nio.file.Files.readAllBytes(purposes.toPath()),"UTF-8");
 java.nio.file.Files.write(purposes.toPath(),original.replace("io.mesalabs.unica.HmaPolicy","missing.Feature").getBytes("UTF-8"));
 check(scan("com.tsng.hidemyapplist",true,"android",true).length()==0);
 java.nio.file.Files.write(purposes.toPath(),original.replace("com.tsng.hidemyapplist","missing.package").getBytes("UTF-8"));
 check(scan("missing.package",true,"android",true).length()==0);
 java.nio.file.Files.write(purposes.toPath(),original.getBytes("UTF-8"));
 JSONObject registry=new JSONObject().put("schema",1).put("rules",new JSONArray().put(new JSONObject().put("confirmed",true).put("package","com.tsng.hidemyapplist").put("version_code",1).put("signer_sha256",String.format("%064d",0)).put("scope","android").put("unica_mod","HMA").put("feature_class","io.mesalabs.unica.HmaPolicy")));
 java.nio.file.Files.write(conflicts.toPath(),registry.toString().getBytes("UTF-8"));
 found=scan("com.tsng.hidemyapplist",true,"android",true);check(found.length()==2&&found.getJSONObject(1).getBoolean("confirmed"));
 check(scan("com.tsng.hidemyapplist",false,"android",true).length()==0);
 System.out.println("LSPosed rules passed: enabled state, exact package/scope, feature gate, unavailable state, missing package, duplicate/conflict separation, excluded unrelated modules");
}}
''')
import shutil
shutil.copyfile(root.parent/'system/etc/unica/troubleshooting-lsposed-purposes.json',work/'purposes.json')
(work/'conflicts.json').write_text('{"schema":1,"rules":[]}')
classes=work/'classes';classes.mkdir()
sources=[str(p) for p in work.rglob('*.java')]+[str(root/'java/io/mesalabs/unica/troubleshooting'/name) for name in ('InstalledModules.java','LogTools.java')]
subprocess.run(['javac','-cp',str(jar),'-d',str(classes),*sources],check=True)
subprocess.run(['java','-cp',str(classes)+':'+str(jar),'io.mesalabs.unica.troubleshooting.InstalledModulesTest',str(work/'purposes.json'),str(work/'conflicts.json')],check=True)
print('Evidence:',work)
