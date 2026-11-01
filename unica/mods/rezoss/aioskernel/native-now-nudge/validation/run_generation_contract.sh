#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
: "${JSON_JAR:?Set JSON_JAR to host org.json runtime}"
WORK=$(mktemp -d /tmp/nudge-generation-contract.XXXXXX)
javac -source 8 -target 8 -Xlint:-options -cp "$JSON_JAR" -d "$WORK" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/LocalFormat.java" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/ReplyText.java" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/PromptAdapter.java" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/ModelOutput.java" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/ActionContract.java" \
    "$ROOT/backend/java/io/mesalabs/rezoss/nudge/ContextReplyContract.java" \
    "$ROOT/ssco-java/io/mesalabs/rezoss/ai/RecallPrediction.java" \
    "$ROOT/validation/GenerationContractTest.java"
java -cp "$WORK:$JSON_JAR" io.mesalabs.rezoss.nudge.GenerationContractTest
