#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
JSON_JAR=${1:?Usage: run_memory_contract_test.sh JSON_JAR (org.json JVM implementation)}
WORK=$(mktemp -d /tmp/memory-contract-test.XXXXXX)
javac -source 8 -target 8 -Xlint:-options -cp "$JSON_JAR" -d "$WORK" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/MemoryContract.java" "$ROOT/validation/MemoryContractTest.java"
java -cp "$WORK:$JSON_JAR" io.mesalabs.rezoss.nudge.MemoryContractTest
