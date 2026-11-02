"""Ingest one LIPIDS_2024 Morrison session (raw Img + videoInfo.txt) as orchestrator video acquisitions.

usage: python ingest_session.py <raw_session_dir> <plate_id> <session_name> <storage_videos_dir> [workers]

Per video folder NNN/: writes <storage>/<plate>/<ref_id>/Img/Img_%05d.tif and a mock-morrison metadata.json
(schema 1a1, the wrapper the 2023-2025 paper plates use, exposure in µs). 1x1 frames (4096x3000) are
2x2 mean-binned to 2048x1500 so every video matches the binned Morrison videos the walls U-Net was trained on.
ref_id = uuid5(session/NNN), so a rerun lands in the same folder. The raw NNN/ is removed after a full ingest.
"""
import csv
import json
import shutil
import sys
import uuid
from concurrent.futures import ProcessPoolExecutor
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import numpy as np
import tifffile


def parse_info(path):
    kv = {}
    for line in path.read_text(encoding="utf-8-sig", errors="replace").splitlines():
        if ":" in line and not line.startswith("-"):
            k, v = line.split(":", 1)
            kv[k.strip()] = v.strip()
    return kv


def num(s):
    return float(s.split()[0])


def ingest(args):
    vdir, plate, session, out_root = args
    info = parse_info(vdir / "videoInfo.txt")
    frames = sorted((vdir / "Img").glob("Img_*.tif"))
    n_expected = int(info["Frames Recorded"].split("/")[0])
    if len(frames) < n_expected:  # "599/600" sessions still wrote 600 files
        return f"SKIP {vdir.name}: {len(frames)} frames, videoInfo says {n_expected}"
    ref_id = str(uuid.uuid5(uuid.NAMESPACE_URL, f"LIPIDS_2024/{session}/{vdir.name}"))
    out = out_root / plate / ref_id
    (out / "Img").mkdir(parents=True, exist_ok=True)
    w, h = (int(x) for x in info["FrameSize"].split()[0].split("x"))
    binning = int(info["Binning"].split("x")[0])
    for f in frames:
        dst = out / "Img" / f.name
        if binning == 1:
            a = tifffile.imread(f).astype(np.uint16)
            a = ((a[0::2, 0::2] + a[1::2, 0::2] + a[0::2, 1::2] + a[1::2, 1::2] + 2) // 4).astype(np.uint8)
            tifffile.imwrite(dst, a)
        else:
            shutil.copyfile(f, dst)
    if binning == 1:
        w, h = w // 2, h // 2
    when = datetime.strptime(info["DateTime"], "%A, %d %B %Y, %H:%M:%S").replace(tzinfo=ZoneInfo("Europe/Amsterdam"))
    mode = info["Operation"].split()[1].lower()  # brightfield | fluorescence
    meta = {
        "ref_id": ref_id,
        "experiment_id": plate,
        "timestamp": when.isoformat(),
        "type": "video",
        "system": "tsu-exp002",
        "schema_version": "1a1",
        "metadata": {
            "application": {"application": "mock-morrison", "version": "v0.1.0", "user": "lipids-2024-ingest"},
            "camera": {
                "model": info["Model"],
                "station_name": info.get("Computer", "Unknown"),
                "exposure_time": num(info["ExposureTime"]),  # µs, as mock-morrison stores it
                "frame_rate": num(info["FrameRate"]),
                "frame_size": [w, h],
                "binning": "2x2",
                "gain": num(info["Gain"]),
                "gamma": num(info["Gamma"]),
                "intensity": [0.0],
                "bits_per_pixel": 8.0,
                "pixel_size": 1.725,  # PRINCE convention; not read since pipeline-steps#49
            },
            "stitching": None,
            "video": {
                "duration": num(info["Time"]),
                "location": [num(info["X"]), num(info["Y"]), num(info["Z"])],
                "magnification": float(info["Operation"].split()[0].rstrip("x")),
                "type": mode,
                "video_nr": int(vdir.name),
            },
        },
    }
    (out / "metadata.json").write_text(json.dumps(meta, indent=4))
    shutil.rmtree(vdir)
    return [plate, session, vdir.name, ref_id, mode, meta["metadata"]["video"]["location"][0],
            meta["metadata"]["video"]["location"][1], when.isoformat(), binning]


def main():
    raw, plate, session, out_root = Path(sys.argv[1]), sys.argv[2], sys.argv[3], Path(sys.argv[4])
    workers = int(sys.argv[5]) if len(sys.argv) > 5 else 16
    vdirs = sorted(d for d in raw.iterdir() if d.is_dir() and d.name.isdigit() and (d / "videoInfo.txt").exists())
    print(f"{plate} {session}: {len(vdirs)} videos", flush=True)
    rows, bad = [], []
    with ProcessPoolExecutor(workers) as ex:
        for r in ex.map(ingest, [(d, plate, session, out_root) for d in vdirs]):
            (bad if isinstance(r, str) else rows).append(r)
            print(r if isinstance(r, str) else f"ok {r[2]} {r[4]} {r[3]}", flush=True)
    man = out_root / plate / "lipids_2024_manifest.csv"
    new = not man.exists()
    with open(man, "a", newline="") as f:  # append: a rerun only sees the videos the first pass skipped
        w = csv.writer(f)
        if new:
            w.writerow(["plate", "session", "video", "ref_id", "mode", "x_mm", "y_mm", "timestamp", "raw_binning"])
        w.writerows(rows)
    print(f"{len(rows)} ingested, {len(bad)} skipped -> {man}", flush=True)
    sys.exit(1 if not rows else 0)


if __name__ == "__main__":
    main()
