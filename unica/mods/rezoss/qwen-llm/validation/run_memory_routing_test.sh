#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
SDK=${ANDROID_HOME:-$HOME/Android/Sdk}
WORK=$(mktemp -d /tmp/memory-routing-test.XXXXXX)
mkdir -p "$WORK/stubs/android/content" "$WORK/classes"
# Only Context's preference entry point is substituted. Production settings and
# SharedPreferences interfaces are compiled unchanged; Keystore is never invoked.
cat > "$WORK/stubs/android/content/Context.java" <<'JAVA'
package android.content;
public abstract class Context {
    public static final int MODE_PRIVATE=0;
    public abstract SharedPreferences getSharedPreferences(String name,int mode);
}
JAVA
javac -source 8 -target 8 -Xlint:-options -cp "$SDK/platforms/android-37.0/android.jar" -d "$WORK/classes" \
    "$WORK/stubs/android/content/Context.java" "$ROOT/app/java/io/mesalabs/rezoss/qwen/ApiSettingsStore.java" "$ROOT/validation/MemoryRoutingTest.java"
java -cp "$WORK/classes:$SDK/platforms/android-37.0/android.jar" io.mesalabs.rezoss.qwen.MemoryRoutingTest
