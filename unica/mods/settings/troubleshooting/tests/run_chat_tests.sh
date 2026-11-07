#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$HERE/../../../../.." && pwd)
JSON_JAR=${1:?Usage: run_chat_tests.sh HOST_ORG_JSON_JAR}
WORK=$(mktemp -d /tmp/unica-chat-tests.XXXXXX)
AI="$ROOT/unica/mods/rezoss/aioskernel/native-now-nudge"
javac -cp "$JSON_JAR" -d "$WORK" \
    "$HERE/../java/io/mesalabs/unica/troubleshooting/ChatHistory.java" "$HERE/ChatHistoryTest.java" \
    "$AI/backend/java/io/mesalabs/rezoss/nudge/DiagnosticPrompt.java" \
    "$AI/gemma/java/io/mesalabs/rezoss/nudge/GemmaPrompts.java" "$HERE/DiagnosticChatTest.java"
java -cp "$WORK:$JSON_JAR" io.mesalabs.unica.troubleshooting.ChatHistoryTest
java -cp "$WORK:$JSON_JAR" io.mesalabs.rezoss.nudge.DiagnosticChatTest
