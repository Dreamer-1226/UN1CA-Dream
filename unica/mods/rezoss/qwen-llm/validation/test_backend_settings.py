#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Test persisted routing defaults and endpoint/key safety without Android or live credentials."""
import os
from pathlib import Path
import subprocess
import tempfile
root=Path(__file__).resolve().parents[1]
sdk=Path(os.environ.get('ANDROID_HOME',str(Path.home()/'Android/Sdk')))
android=sdk/'platforms/android-37.0/android.jar'
work=Path(tempfile.mkdtemp(prefix='qwen-settings-test-',dir='/tmp'))
sources={
'android/content/Context.java': 'package android.content; public abstract class Context {public static final int MODE_PRIVATE=0;public abstract SharedPreferences getSharedPreferences(String n,int m);}',
'android/content/SharedPreferences.java': '''package android.content; public interface SharedPreferences {String getString(String k,String d);Editor edit();interface Editor {Editor putString(String k,String v);Editor remove(String k);void apply();}}''',
'io/mesalabs/rezoss/qwen/SettingsTest.java': '''package io.mesalabs.rezoss.qwen;
import android.content.*;import java.util.*;
public class SettingsTest {
 static class Prefs implements SharedPreferences,SharedPreferences.Editor {Map<String,String> values=new HashMap<>();public String getString(String k,String d){return values.getOrDefault(k,d);}public Editor edit(){return this;}public Editor putString(String k,String v){values.put(k,v);return this;}public Editor remove(String k){values.remove(k);return this;}public void apply(){}}
 static class C extends Context {Prefs prefs=new Prefs();public SharedPreferences getSharedPreferences(String n,int m){return prefs;}}
 static void check(boolean c){if(!c)throw new AssertionError();}
 interface Action{void run()throws Exception;}
 static void reject(Action a)throws Exception{try{a.run();throw new AssertionError("accepted");}catch(IllegalArgumentException expected){}}
 public static void main(String[]args)throws Exception{
  C c=new C();check("default".equals(ApiSettingsStore.backend(c,false)));check("default".equals(ApiSettingsStore.backend(c,true)));
  // Migrating PR21 API credentials must not opt the user into cloud inference.
  c.prefs.putString("endpoint","https://api.openai.com/v1/chat/completions").putString("model","saved-model").putString("api_key","").apply();
  check("default".equals(ApiSettingsStore.backend(c,false)));check(!ApiSettingsStore.configured(c));
  reject(()->ApiSettingsStore.select(c,"openai",false));
  c.prefs.putString("api_key","fake-ciphertext");
  reject(()->ApiSettingsStore.save(c,"https://generativelanguage.googleapis.com/v1beta/openai/chat/completions","model",""));
  check("https://api.openai.com/v1/chat/completions".equals(ApiSettingsStore.display(c).endpoint));
  reject(()->ApiSettingsStore.validateEndpoint("http://example.com/completions"));
  reject(()->ApiSettingsStore.validateEndpoint("https://user:secret@example.com/completions"));
  reject(()->ApiSettingsStore.validateEndpoint("https://example.com/completions?key=secret"));
  check(!ApiSettingsStore.matchesEndpoint("openai","https://example.com/v1/chat/completions"));
  check(ApiSettingsStore.matchesEndpoint("gemini","https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"));
  c.prefs.putString("backend","gemini").putString("screening_backend","custom");
  ApiSettingsStore.clearKey(c);check("default".equals(ApiSettingsStore.backend(c,false)));check("default".equals(ApiSettingsStore.backend(c,true)));check(!ApiSettingsStore.hasSavedKey(c));
  System.out.println("Settings passed: local defaults/migration, unconfigured rejection, cross-endpoint key protection, endpoint validation, key-removal reset");
 }
}'''
}
for name,content in sources.items():
 p=work/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(content)
subprocess.run(['javac','-cp',str(android),'-d',str(work),*[str(work/p) for p in sources],str(root/'app/java/io/mesalabs/rezoss/qwen/ApiSettingsStore.java')],check=True)
subprocess.run(['java','-cp',str(work)+os.pathsep+str(android),'io.mesalabs.rezoss.qwen.SettingsTest'],check=True)
