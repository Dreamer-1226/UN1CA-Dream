#!/usr/bin/env python3
"""Compile the production keyboard adapter against minimal deterministic Android fakes."""
from pathlib import Path
import subprocess
import tempfile

base = Path(__file__).resolve().parent
# Resolve by source tree structure, independently of the current working directory.
keyboard = base.parent / 'keyboard-java/io/mesalabs/rezoss/ai/ShadeReplyKeyboard.java'
contract = base.parent / 'shared-java/io/mesalabs/rezoss/ai/ShadeReplyContract.java'
stubs = {
'android/os/Bundle.java': '''package android.os; import java.util.*; public class Bundle {
private final Map<String,Object> values=new HashMap<>();
public void putString(String k,String v){values.put(k,v);} public String getString(String k){return (String)values.get(k);}
public void putBoolean(String k,boolean v){values.put(k,v);} public boolean getBoolean(String k){return Boolean.TRUE.equals(values.get(k));}
}''',
'android/os/SystemClock.java': '''package android.os; public class SystemClock { public static long clock=100; public static long elapsedRealtimeNanos(){return clock++;} }''',
'android/os/Process.java': '''package android.os; public class Process { public static int myUid(){return 200;} }''',
'android/os/Looper.java': '''package android.os; public class Looper {public static Looper getMainLooper(){return new Looper();}}''',
'android/os/Handler.java': '''package android.os; public class Handler {private static final java.util.List<Runnable> pending=new java.util.ArrayList<>(); public Handler(Looper l){} public void removeCallbacks(Runnable r){pending.removeIf(item -> item==r);} public boolean post(Runnable r){r.run();return true;} public boolean postDelayed(Runnable r,long t){pending.add(r);return true;} public static void runDelayed(){java.util.List<Runnable> work=new java.util.ArrayList<>(pending);pending.clear();for(Runnable r:work)r.run();}}''',
'android/content/Intent.java': '''package android.content; import java.util.*; public class Intent {
private String action; private final Map<String,Object> values=new HashMap<>(); public Intent(){} public Intent(String a){action=a;} public String getAction(){return action;}
public Intent putExtra(String k,String v){values.put(k,v);return this;} public Intent putExtra(String k,boolean v){values.put(k,v);return this;} public Intent putExtra(String k,long v){values.put(k,v);return this;}
public String getStringExtra(String k){return (String)values.get(k);} public boolean getBooleanExtra(String k,boolean d){Object v=values.get(k);return v==null?d:(Boolean)v;} public long getLongExtra(String k,long d){Object v=values.get(k);return v==null?d:(Long)v;}
public Intent putStringArrayListExtra(String k,ArrayList<String> v){values.put(k,v);return this;}
@SuppressWarnings("unchecked") public ArrayList<String> getStringArrayListExtra(String k){return (ArrayList<String>)values.get(k);}
}''',
'android/content/Context.java': '''package android.content; public class Context {public android.content.pm.PackageManager getPackageManager(){return new android.content.pm.PackageManager();}}''',
'android/content/BroadcastReceiver.java': '''package android.content; public abstract class BroadcastReceiver {public int sender=123; public int getSentFromUid(){return sender;}}''',
'android/content/pm/PackageManager.java': '''package android.content.pm; public class PackageManager {public static final int SIGNATURE_MATCH=0; public static int signature=0; public static class ApplicationInfo {public int uid=123;} public ApplicationInfo getApplicationInfo(String name,int flags){return new ApplicationInfo();} public int checkSignatures(int a,int b){return signature;}}''',
'android/view/inputmethod/EditorInfo.java': '''package android.view.inputmethod; public class EditorInfo {public String packageName;public android.os.Bundle extras;}''',
'android/view/inputmethod/InputConnection.java': '''package android.view.inputmethod; public interface InputConnection {CharSequence getTextBeforeCursor(int n,int flags);CharSequence getTextAfterCursor(int n,int flags);CharSequence getSelectedText(int flags);}''',
'android/inputmethodservice/InputMethodService.java': '''package android.inputmethodservice; import android.view.inputmethod.*; public class InputMethodService extends android.content.Context {public EditorInfo info;public String text=""; public boolean visible=true; public EditorInfo getCurrentInputEditorInfo(){return info;} public boolean isInputViewShown(){return visible;} public InputConnection getCurrentInputConnection(){return new InputConnection(){public CharSequence getTextBeforeCursor(int n,int f){return text.isEmpty()?"":text.substring(0,1);}public CharSequence getTextAfterCursor(int n,int f){return "";}public CharSequence getSelectedText(int f){return "";}};}}''',
'android/util/Log.java': '''package android.util; public class Log {public static int i(String a,String b){return 0;} public static int w(String a,String b){return 0;}}''',
}
with tempfile.TemporaryDirectory(prefix='shade-keyboard-') as work:
    temp = Path(work)
    for relative, source in stubs.items():
        target = temp / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(source)
    sources = list(temp.rglob('*.java')) + [keyboard, contract, base / 'ShadeReplyKeyboardTest.java']
    subprocess.run(['javac', '-Xlint:all', '-Werror', '-d', str(temp / 'classes')] + [str(p) for p in sources], check=True)
    subprocess.run(['java', '-cp', str(temp / 'classes'), 'ShadeReplyKeyboardTest'], check=True)
