#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
WORK=$(mktemp -d /tmp/map-gate-contract.XXXXXX)
trap 'rm -rf "$WORK"' EXIT
javac -Xlint:all -Werror -d "$WORK" "$ROOT/client-java/io/mesalabs/rezoss/ai/MapGateContract.java" "$ROOT/validation/MapGateContractTest.java"
java -cp "$WORK" MapGateContractTest
