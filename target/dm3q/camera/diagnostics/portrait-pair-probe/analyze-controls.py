#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Analyze controlled capture evidence. Requires numpy and OpenCV in a host venv."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import struct
import cv2
import numpy as np


def stats(values):
    a = np.asarray(values, dtype=float)
    return {"count": len(a), "min": float(a.min()), "median": float(np.median(a)),
            "max": float(a.max())} if len(a) else {"count": 0}


def floats(text):
    return [float(x) for x in re.findall(r"[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", text)]


def analyze(folder, calibration):
    rows = [json.loads(line) for line in (folder / "report.jsonl").read_text().splitlines()]
    begin = next(r for r in reversed(rows) if r["event"] == "begin")
    rows = [r for r in rows if r.get("run_id") == begin["run_id"]]
    logical = {int(r["timestamp_ns"]): r for r in rows if r["event"] == "result"}
    physical = {(r["id"], r["frame"]): r for r in rows if r["event"] == "physical_result"}
    result = {"run_id": begin["run_id"], "version": begin["version"],
              "complete": any(r["event"] == "summary" for r in rows), "focus": {}, "association": {},
              "depth_validated": False, "geometry_validated": False}
    for phase in ("auto", "manual", "pulse"):
        result["focus"][phase] = {}
        for id in ("54", "52"):
            samples = [r for (i, _), r in physical.items() if i == id and r["phase"] == phase]
            result["focus"][phase][id] = {"af_states": dict(Counter(r["af_state"] for r in samples)),
                "af_modes": dict(Counter(r["af_mode"] for r in samples)),
                "focus_diopters": stats([float(r["focus_diopters"]) for r in samples if r["focus_diopters"] != "null"]),
                "actual_iso": dict(Counter(r["iso"] for r in samples)),
                "requested_iso": dict(Counter(r["requested_iso"] for r in samples))}
    for id in ("54", "52"):
        images = [(logical[int(r["timestamp_ns"])]["frame"], r["luma"]["mean"])
                  for r in rows if r["event"] == "image" and r["physical_output"] == id
                  and int(r["timestamp_ns"]) in logical
                  and logical[int(r["timestamp_ns"])]["phase"] == "pulse"]
        fits = []
        for shift in range(-6, 7):
            pairs = [(mean, float(physical[id, frame + shift]["iso"])) for frame, mean in images
                     if (id, frame + shift) in physical and physical[id, frame + shift]["phase"] == "pulse"
                     and physical[id, frame + shift]["iso"] != "null"]
            a = np.asarray(pairs)
            corr = float(np.corrcoef(a[:, 0], a[:, 1])[0, 1]) if len(a) >= 20 and np.std(a[:, 0]) > 1e-6 and np.std(a[:, 1]) > 1e-6 else None
            fits.append({"metadata_frame_minus_image_frame": shift, "count": len(pairs), "brightness_iso_correlation": corr})
        ranked = sorted([r for r in fits if r["brightness_iso_correlation"] is not None], key=lambda r: -r["brightness_iso_correlation"])
        result["association"][id] = {"candidates": fits, "best_candidate": ranked[0] if ranked else None,
            "validated": False, "limitation": "Correlation is scene-dependent evidence, not external exposure timing; competing offsets must be inspected."}

    blob = calibration.read_bytes()
    if len(blob) != 760:
        raise ValueError("Expected real 760-byte calibration; no fallback or header rewrite")
    f = lambda offset, n: np.asarray(struct.unpack_from("<" + "f" * n, blob, offset), dtype=float)
    native = {"54": f(0x4c, 12), "52": f(0x7c, 12)}
    result["calibration"] = {"sha256": hashlib.sha256(blob).hexdigest(), "bytes": len(blob),
        "header_version_float": float(f(8, 1)[0]),
        "main_intrinsics_offset": "0x4c", "aux_intrinsics_offset": "0x7c",
        "native_decoder": "libmulticam_optical_zoom_control.so FUN_00117da4 copies +0x4c block and converts +0x124 angles from degrees to radians",
        "intrinsic_blocks": {id: a.tolist() for id, a in native.items()},
        "transform_direction_and_convention_confirmed": False}
    saved = {}
    for r in rows:
        if r["event"] == "saved_luma" and int(r["timestamp_ns"]) in logical:
            saved.setdefault(int(r["timestamp_ns"]), {})[r["id"]] = r
    result["image_pairs"] = []
    detector = cv2.SIFT_create(nfeatures=3000, contrastThreshold=0.015)
    for timestamp, pair in saved.items():
        if not all(id in pair for id in ("54", "52")):
            continue
        item = {"timestamp_ns": timestamp, "frame": logical[timestamp]["frame"], "phase": logical[timestamp]["phase"]}
        images = [cv2.imread(str(folder / pair[id]["file"]), cv2.IMREAD_GRAYSCALE) for id in ("54", "52")]
        item["sharpness_laplacian_variance"] = {id: float(cv2.Laplacian(im, cv2.CV_64F).var()) for id, im in zip(("54", "52"), images)}
        features = [detector.detectAndCompute(im, None) for im in images]
        item["sift_features"] = [len(kp) for kp, _ in features]
        matches = []
        if all(d is not None and len(d) >= 2 for _, d in features):
            matches = [a for a, b in cv2.BFMatcher().knnMatch(features[0][1], features[1][1], k=2) if a.distance < 0.7 * b.distance]
        item["ratio_matches"] = len(matches)
        if len(matches) >= 12:
            a, b = [np.float64([features[i][0][m.queryIdx if i == 0 else m.trainIdx].pt for m in matches]) for i in (0, 1)]
            F, mask = cv2.findFundamentalMat(a, b, cv2.FM_RANSAC, 1.5, 0.999)
            item["empirical_fundamental_inliers"] = int(mask.sum()) if mask is not None else 0
            if F is not None and F.shape == (3, 3) and mask is not None and mask.sum() >= 12:
                keep = mask.ravel() != 0
                points = [x[keep] for x in (a, b)]
                ah, bh = [np.c_[x, np.ones(len(x))] for x in points]
                line = (F @ ah.T).T
                item["empirical_epipolar_error_px"] = stats(abs(np.sum(bh * line, axis=1)) / np.linalg.norm(line[:, :2], axis=1))
                # Audit crop transforms against actual per-frame metadata. No distortion
                # transform is silently applied to potentially corrected YUV buffers.
                item["calibrated_pixel_mappings"] = {}
                for id, im in zip(("54", "52"), images):
                    crop = floats(physical[id, item["frame"]]["crop"])
                    x, y, right, bottom = crop
                    fx, fy, cx, cy = native[id][:4]
                    sx, sy = im.shape[1] / (right-x), im.shape[0] / (bottom-y)
                    item["calibrated_pixel_mappings"][id] = {"K_scaled_from_real_blob": [[fx*sx, 0, (cx-x)*sx], [0, fy*sy, (cy-y)*sy], [0, 0, 1]], "crop": crop}
                # These are explicit hypotheses, not recovered transform conventions.
                # Keep every candidate and residual; never relabel the best fit as native truth.
                def K(id):
                    return np.asarray(item["calibrated_pixel_mappings"][id]["K_scaled_from_real_blob"])
                item["factory_pose_hypotheses"] = []
                for label, vector, translation in (
                    ("primary_vector_as_rodrigues_radians", f(0xac, 3), f(0xc4, 3)),
                    ("primary_angles_as_rodrigues_degrees", np.deg2rad(f(0xb8, 3)), f(0xc4, 3)),
                    ("supplemental_angles_as_rodrigues_degrees", np.deg2rad(f(0x124, 3)), f(0x130, 3))):
                    rotation = cv2.Rodrigues(vector)[0]
                    for inverse in (False, True):
                        R, t = (rotation.T, -rotation.T @ translation) if inverse else (rotation, translation)
                        tx, ty, tz = t
                        cross = np.asarray([[0, -tz, ty], [tz, 0, -tx], [-ty, tx, 0]])
                        factory = np.linalg.inv(K("52")).T @ cross @ R @ np.linalg.inv(K("54"))
                        lines = (factory @ ah.T).T
                        error = abs(np.sum(bh * lines, axis=1)) / np.linalg.norm(lines[:, :2], axis=1)
                        item["factory_pose_hypotheses"].append({"assumption": label, "inverse": inverse,
                            "point_to_epipolar_line_error_px": stats(error),
                            "distortion_assumption": "YUV already corrected; unverified", "validated": False})
                preview = cv2.drawMatches(images[0], features[0][0], images[1], features[1][0], [m for m, k in zip(matches, keep) if k][:60], None, flags=2)
                filename = "correspondences-" + str(timestamp) + ".png"
                cv2.imwrite(str(folder / filename), preview)
                item["correspondence_preview"] = filename
        result["image_pairs"].append(item)
    result["limitations"] = ["A robust empirical fundamental matrix is not a validation of factory extrinsics.",
        "Distortion correction state and native transform direction/convention must be established before factory epipolar rectification.",
        "AF metadata alone does not prove optical sharpness. No disparity was generated."]
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--calibration", required=True, type=Path)
    args = parser.parse_args()
    result = analyze(args.folder, args.calibration)
    output = args.folder / "controls-analysis.json"
    output.write_text(json.dumps(result, indent=2) + "\n")
    print(output)
