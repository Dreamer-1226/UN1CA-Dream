#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Summarize the last diagnostic attempt without implying calibrated Portrait."""
import argparse
import json
from pathlib import Path


def summarize(rows):
    starts = [i for i, row in enumerate(rows) if row.get("event") == "begin"]
    if not starts:
        raise ValueError("No begin record; this is not a completed probe report")
    rows = rows[starts[-1]:]
    summaries = [row for row in rows if row.get("event") == "summary"]
    last = summaries[-1] if summaries else {}
    errors = [row for row in rows if row.get("event") in {
        "error", "device_error", "capture_failed", "configure_failed"
    }]
    streams = last.get("main_images", 0) > 0 and last.get("aux_images", 0) > 0
    return {
        "complete": bool(last),
        "requested_pair_buffers_observed": streams,
        "exact_image_timestamp_matches": last.get("exact_timestamp_matches", 0),
        "frames_with_both_physical_results": last.get("frames_with_both_physical_results", 0),
        "calibration_validated": False,
        "portrait_ready": False,
        "summary": last,
        "errors": errors,
        "calibration_inventory": [row for row in rows if row.get("event") == "calibration_blob"],
        "result_keys": [row for row in rows if row.get("event") == "result_key"],
        "next_step": (
            "Validate optical identity, pair geometry and real per-device calibration; "
            "then test still-capture streams and depth processing."
            if streams else
            "Resolve the recorded access/session/delivery failure before changing Portrait flags."
        ),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path)
    args = parser.parse_args()
    rows = [json.loads(line) for line in args.report.read_text().splitlines() if line.strip()]
    print(json.dumps(summarize(rows), indent=2))


if __name__ == "__main__":
    main()
