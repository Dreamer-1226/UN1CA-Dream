#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
INDEX_SOURCE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
INDEX_ANDROID_JAR="${ANDROID_JAR:-${ANDROID_HOME:-$HOME/Android/Sdk}/platforms/android-37.0/android.jar}"
INDEX_TEST_BUILD=$(mktemp -d /tmp/rezoss-memory-index-tests.XXXXXX)
javac --release 8 -Xlint:-options -encoding UTF-8 -cp "$INDEX_ANDROID_JAR" -d "$INDEX_TEST_BUILD" \
    "$INDEX_SOURCE/java/io/mesalabs/rezoss/memory/MemoryIndexAdapter.java" \
    "$INDEX_SOURCE/java/io/mesalabs/rezoss/memory/IndexTextQuery.java" \
    "$INDEX_SOURCE/tests/IndexContractTest.java"
java -cp "$INDEX_TEST_BUILD:$INDEX_ANDROID_JAR" io.mesalabs.rezoss.memory.IndexContractTest "$INDEX_TEST_BUILD/sql.tsv"
python3 "$INDEX_SOURCE/tests/test_sql.py" "$INDEX_TEST_BUILD/sql.tsv"
