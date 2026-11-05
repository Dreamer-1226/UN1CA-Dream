/* SPDX-License-Identifier: GPL-3.0-or-later */
package io.mesalabs.unica.troubleshooting;
import java.io.*;
public final class LogToolsTest {
    static void check(boolean ok,String why){if(!ok)throw new AssertionError(why);}
    public static void main(String[] args)throws Exception{
        String raw="11-04 12:34:56.789 1234 5678 E AndroidRuntime: FATAL EXCEPTION: main\n"
            +"Authorization: Bearer secret-bearer\napi_key=sk-secret android_id=privateid\n"
            +"person@example.com 192.168.1.2 aa:bb:cc:dd:ee:ff https://host.invalid/?token=secret\n"
            +"-----BEGIN PRIVATE KEY-----\nsecret-key\n-----END PRIVATE KEY-----\n"
            +"java.lang.IllegalStateException: HookBridge failure\n";
        String redacted=LogTools.redact(raw);
        for(String secret:new String[]{"secret-bearer","sk-secret","privateid","person@example.com","192.168.1.2","aa:bb:cc:dd:ee:ff","token=secret","secret-key"})check(!redacted.contains(secret),"Secret retained: "+secret);
        check(redacted.contains("11-04 12:34:56.789"),"Timestamp lost");check(redacted.contains("HookBridge"),"Process evidence lost");
        StringBuilder large=new StringBuilder();for(int i=0;i<1000;i++)large.append(i==500?"FATAL EXCEPTION: main":"ordinary log entry").append('\n');
        LogTools.Selection selection=LogTools.select(large.toString());check(selection.selectedLines<selection.totalLines,"Coverage overclaim");check(selection.chunks.toString().contains("L501: FATAL EXCEPTION: main"),"Failure window missing");
        StringBuilder many=new StringBuilder();for(int i=0;i<1000;i++)many.append("FATAL EXCEPTION: ").append(new String(new char[200]).replace('\0','x')).append('\n');
        selection=LogTools.select(many.toString());check(selection.chunks.size()<=8&&selection.truncated,"Excerpt budget bypass");for(String chunk:selection.chunks)check(chunk.length()<=1400,"Oversized chunk");
        check(LogTools.select("E/Service: failed retry\njava.io.IOException: temporary network failure\navc: denied\nlspd initialized\n").chunks.isEmpty(),"Routine errors selected");
        for(String failure:new String[]{"ANR in com.example","F/libc: Fatal signal 11 (SIGSEGV)","Unable to start activity ComponentInfo{com.example}","WATCHDOG KILLING SYSTEM PROCESS","Kernel panic - not syncing: Fatal exception"})check(!LogTools.select(failure).chunks.isEmpty(),"Serious failure missed: "+failure);
        check(!LogTools.select("FATAL EXCEPTION: main\njava.lang.RuntimeException: problem\n    at com.example.App.run(App.java:42)").chunks.isEmpty(),"Crash stack missing");
        LogTools.Selection reviewed=LogTools.reviewed("L501: edited evidence only",selection);check(reviewed.chunks.toString().contains("edited evidence only")&&!reviewed.chunks.toString().contains("xxxx"),"Removed preview data restored");
        try{LogTools.read(new ByteArrayInputStream(new byte[11]),10);throw new AssertionError("Import limit bypass");}catch(IOException expected){}
        System.out.println("Log tools passed: redaction, timestamp preservation, evidence windows, bounded excerpts, edited-preview isolation, import limit");
    }
}
