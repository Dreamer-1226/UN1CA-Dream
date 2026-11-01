# SPDX-License-Identifier: GPL-3.0-or-later
# Device-local default; also accepts an exported environment override.
# Generation goes through the Rezoss AI provider (API or on-device llama.cpp),
# so the SM8250 targets (S20/S20 FE/Note20) can use it as well as SM8550.
# Set the default to false to restore the previous ROM packaging.
if [[ "$TARGET_CODENAME" =~ ^(dm1q|dm2q|dm3q|b5q|q5q|x1q|y2q|z3q|c1q|c2q|r8q)$ ]]; then
    UNICA_ENABLE_NATIVE_NOW_NUDGE="${UNICA_ENABLE_NATIVE_NOW_NUDGE:-true}"
else
    UNICA_ENABLE_NATIVE_NOW_NUDGE="${UNICA_ENABLE_NATIVE_NOW_NUDGE:-false}"
fi
