#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Exercise the real API transport using a fake HTTPS connection; never accesses the network."""
import os
from pathlib import Path
import subprocess
import tempfile
root = Path(__file__).resolve().parents[1]
json_jar = os.environ['JSON_JAR']
work = Path(tempfile.mkdtemp(prefix='qwen-api-transport-', dir='/tmp'))
sources = {
'android/content/Context.java': 'package android.content; public class Context {}',
'android/os/SystemClock.java': 'package android.os; public class SystemClock { public static long elapsedRealtime(){return System.nanoTime()/1000000;} }',
'io/mesalabs/rezoss/qwen/ApiSettingsStore.java': '''package io.mesalabs.rezoss.qwen;
import android.content.Context;
final class ApiSettingsStore {
 static final class Settings {String endpoint="https://provider.invalid/v1/chat/completions",model="test-model",apiKey="test-key";boolean ready(){return true;}}
 static Settings forBackend(Context c,String backend){if(!"custom".equals(backend))throw new IllegalArgumentException("backend_changed");return new Settings();}
 static String activeBackend="custom";
 static String backend(Context c,boolean screening){return activeBackend;}
 static void validateEndpoint(String endpoint){}
}''',
'io/mesalabs/rezoss/qwen/TransportTest.java': r'''package io.mesalabs.rezoss.qwen;
import java.net.*;import java.io.*;import java.nio.charset.StandardCharsets;import android.os.SystemClock;
public class TransportTest {
 static volatile Fake last; static volatile String reason="stop"; static volatile boolean block;
 static class Fake extends HttpURLConnection {
  volatile boolean disconnected; ByteArrayOutputStream body=new ByteArrayOutputStream();
  Fake(URL u){super(u);} public void connect(){} public boolean usingProxy(){return false;}
  public void disconnect(){disconnected=true;}
  public OutputStream getOutputStream(){return body;}
  public int getResponseCode(){return 200;}
  public InputStream getInputStream() throws IOException {
   if(block){while(!disconnected){try{Thread.sleep(5);}catch(InterruptedException e){throw new IOException();}}throw new IOException();}
   return new ByteArrayInputStream(("{\"choices\":[{\"finish_reason\":\""+reason+"\",\"message\":{\"content\":\"hello\"}}]}").getBytes(StandardCharsets.UTF_8));
  }
 }
 static void check(boolean condition){if(!condition)throw new AssertionError();}
 static String call(String id,long ms,String backend)throws Exception{return ApiClient.complete(new android.content.Context(),null,"private prompt",48,SystemClock.elapsedRealtime()+ms,id,backend);}
 static void reject(String status,String id,long ms)throws Exception{try{call(id,ms,"custom");throw new AssertionError("accepted");}catch(ApiClient.ApiException e){check(status.equals(e.status));}}
 public static void main(String[]args)throws Exception{
  try{
   URL.setURLStreamHandlerFactory(protocol->new URLStreamHandler(){protected URLConnection openConnection(URL u){return last=new Fake(u);}});
   check("hello".equals(call("ok",2000,"custom")));
   org.json.JSONObject payload=new org.json.JSONObject(last.body.toString("UTF-8"));check(payload.getInt("max_tokens")==48);check(!payload.getBoolean("stream"));check(payload.getJSONArray("messages").getJSONObject(0).getString("content").equals("private prompt"));check(last.disconnected);
   Fake consentPrior=last;
   try{ApiClient.complete(new android.content.Context(),null,"private log",256,SystemClock.elapsedRealtime()+2000,"stale-consent","custom","wrong-fingerprint");throw new AssertionError("stale destination accepted");}
   catch(ApiClient.ApiException e){check("backend_changed".equals(e.status));}check(last==consentPrior);
   byte[] digest=java.security.MessageDigest.getInstance("SHA-256").digest("custom\ntest-model\nhttps://provider.invalid/v1/chat/completions".getBytes("UTF-8"));
   StringBuilder consent=new StringBuilder();for(byte b:digest)consent.append(String.format(java.util.Locale.ROOT,"%02x",b&255));
   check("hello".equals(ApiClient.complete(new android.content.Context(),null,"reviewed log",256,SystemClock.elapsedRealtime()+2000,"valid-consent","custom",consent.toString())));
   consentPrior=last;ApiSettingsStore.activeBackend="default";
   try{ApiClient.complete(new android.content.Context(),null,"private log",256,SystemClock.elapsedRealtime()+2000,"changed-route","custom",consent.toString());throw new AssertionError("changed general route accepted");}
   catch(ApiClient.ApiException e){check("backend_changed".equals(e.status));}check(last==consentPrior);ApiSettingsStore.activeBackend="custom";
   reason="length";reject("incomplete_output","truncated",2000);
   reason="content_filter";reject("incomplete_output","filtered",2000);
   reason="stop";ApiClient.cancel("cancelled");reject("cancelled","cancelled",2000);
   Fake prior=last;try{call("local",2000,"default");throw new AssertionError();}catch(IllegalArgumentException expected){}check(prior==last);
   block=true;long start=SystemClock.elapsedRealtime();reject("deadline","timeout",100);check(SystemClock.elapsedRealtime()-start<1500);check(last.disconnected);
   System.out.println("API transport passed: payload, complete/truncated/filtered output, pre-cancel, local no-network, consent fingerprint, changed general route, total deadline");System.exit(0);
  }catch(Throwable e){e.printStackTrace();System.exit(1);}
 }
}'''
}
for name, content in sources.items():
    p=work/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(content)
production=root/'app/java/io/mesalabs/rezoss/qwen/ApiClient.java'
subprocess.run(['javac','-cp',json_jar,'-d',str(work),*[str(work/p) for p in sources],str(production)],check=True)
subprocess.run(['java','-cp',str(work)+os.pathsep+json_jar,'io.mesalabs.rezoss.qwen.TransportTest'],check=True,timeout=10)
