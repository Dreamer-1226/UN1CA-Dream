#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
MEMORY_POLICY_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
MEMORY_POLICY_TEMP=$(mktemp -d /tmp/rezoss-memory-policy.XXXXXX)
mkdir -p "$MEMORY_POLICY_TEMP/kotlinx/coroutines"
# Compile-only fixture for the exact coroutine timeout type; never packaged.
cat > "$MEMORY_POLICY_TEMP/kotlinx/coroutines/TimeoutCancellationException.java" <<'JAVA'
package kotlinx.coroutines;
public final class TimeoutCancellationException extends java.util.concurrent.CancellationException {}
JAVA
javac --release 8 -d "$MEMORY_POLICY_TEMP/classes" \
    "$MEMORY_POLICY_ROOT/java/io/mesalabs/rezoss/memory/MemoryFailurePolicy.java" \
    "$MEMORY_POLICY_ROOT/tests/MemoryFailurePolicyTest.java" \
    "$MEMORY_POLICY_TEMP/kotlinx/coroutines/TimeoutCancellationException.java"
java -cp "$MEMORY_POLICY_TEMP/classes" io.mesalabs.rezoss.memory.MemoryFailurePolicyTest
