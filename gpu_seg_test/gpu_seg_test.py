"""svstaalduine1, GPU: re-segment the staged FLW003 frame with segmenter-ts v9 and compare with the CPU outputs.

Checks: device must be cuda (abort otherwise); per tile the mask must match the CPU mask (pixel disagreement share);
width and spore maps compared too; wall time per frame.
    python gpu_seg_test.py
"""
import os
import shutil
import sys
import time
from pathlib import Path
from types import SimpleNamespace

G = Path("/scratch-shared/mycostreams_downloads/gpu_stage")
REF = "20260609_113215_fmn"
OUT = Path("/scratch-shared/svstaalduine1/gpu_seg_test") / REF
sys.path.insert(0, str(G / "code"))
os.environ["AMF_SEGMENTER"] = "segmenter-ts"
os.environ["AMF_SEGMENT_CHECKPOINT"] = str(G / "models/v9_junction_s2_width_spore.ts")

import imageio.v3 as iio  # noqa: E402
import numpy as np  # noqa: E402
import torch  # noqa: E402
from pipeline_steps.target import Target  # noqa: E402

from amftrack.scripts.image_processing.segment_tiles import process  # noqa: E402

print("torch", torch.__version__, "cuda", torch.cuda.is_available(), flush=True)
if not torch.cuda.is_available():
    sys.exit("FATAL: no cuda, a CPU number would be meaningless")
print("gpu", torch.cuda.get_device_name(0), flush=True)
src = G / "frame/FLW2605A003" / REF
if OUT.exists():
    shutil.rmtree(OUT)
OUT.mkdir(parents=True)
(OUT / "Img").symlink_to(src / "Img")
for n in ("metadata.json", "tile_config.json"):
    shutil.copy2(src / n, OUT / n)
t0 = time.time()
process(Target(OUT, "FLW2605A003", REF), SimpleNamespace())
wall = time.time() - t0
print(f"[RESULT] wall_s {wall:.1f}, peak gpu {torch.cuda.max_memory_allocated() / 2**30:.2f} GiB", flush=True)
ref = G / "cpu_ref" / REF
for d in sorted(p.name for p in ref.iterdir()):
    a_files = sorted((ref / d).glob("*.tif"))
    diffs, missing = [], 0
    for f in a_files:
        g = OUT / d / f.name
        if not g.exists():
            missing += 1
            continue
        a, b = iio.imread(f), iio.imread(g)
        if a.shape != b.shape:
            diffs.append(1.0)
            continue
        diffs.append(float(np.mean((a > 0) != (b > 0))) if d == "segmentations" else float(np.mean(np.abs(a.astype(int) - b.astype(int)) > 1)))
    d_ = np.array(diffs) if diffs else np.array([np.nan])
    print(f"[COMPARE] {d}: {len(a_files)} CPU tiles, missing on GPU {missing}, pixel disagreement median "
          f"{np.median(d_):.2e}, max {np.max(d_):.2e}", flush=True)
