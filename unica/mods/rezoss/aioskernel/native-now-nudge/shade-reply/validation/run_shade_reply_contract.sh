#!/usr/bin/env bash
set -euo pipefail
validation_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
contract_dir="$(dirname -- "$validation_dir")"
classes_dir="$(mktemp -d /tmp/shade-reply-contract.XXXXXX)"
trap 'rm -r -- "$classes_dir"' EXIT
javac -Xlint:all -Werror -d "$classes_dir" \
    "$contract_dir/shared-java/io/mesalabs/rezoss/ai/ShadeReplyContract.java" \
    "$validation_dir/ShadeReplyContractTest.java"
java -cp "$classes_dir" ShadeReplyContractTest
