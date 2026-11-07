#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run actual NativeMapGate against small Android platform fakes and host org.json."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
json_jar = Path(os.environ['JSON_JAR']).resolve()
stubs = {
    'android/content/ContentResolver.java': 'package android.content; public class ContentResolver {}',
    'android/content/Context.java': 'package android.content; public class Context { public ContentResolver getContentResolver() { return new ContentResolver(); } }',
    'android/app/ActivityThread.java': 'package android.app; public class ActivityThread { public static boolean available=true; public static android.content.Context currentApplication() { return available ? new android.content.Context() : null; } }',
    'android/os/Looper.java': 'package android.os; public class Looper { public static boolean main=false; private static final Looper MAIN=new Looper(), WORKER=new Looper(); public static Looper myLooper() { return main?MAIN:WORKER; } public static Looper getMainLooper() { return MAIN; } }',
    'android/provider/Settings.java': 'package android.provider; public class Settings { public static class Global { public static String disabled; public static int getInt(android.content.ContentResolver resolver,String name,int fallback) { return name.equals(disabled)?0:1; } } }',
    'android/util/Log.java': 'package android.util; public class Log { public static int i(String tag,String message) { return 0; } }',
}
with tempfile.TemporaryDirectory(prefix='nudge-map-adapter-') as work:
    work = Path(work)
    sources = []
    for name, source in stubs.items():
        path = work / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source)
        sources.append(str(path))
    sources.extend(str(root / 'client-java/io/mesalabs/rezoss/ai' / name) for name in ['NativeMapGate.java','MapGateContract.java'])
    sources.append(str(root / 'validation/MapGateAdapterTest.java'))
    subprocess.run(['javac','-Xlint:all','-Werror','-cp',str(json_jar),'-d',str(work),*sources],check=True)
    subprocess.run(['java','-cp',f'{work}:{json_jar}','io.mesalabs.rezoss.ai.MapGateAdapterTest'],check=True)
