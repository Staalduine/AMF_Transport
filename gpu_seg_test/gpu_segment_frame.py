"""svstaalduine1, GPU: segment one staged frame with segmenter-ts v9 (the pipeline's amftrack copy in the stage dir).
Writes segmentations, segmentations_width, segmentations_spore under OUT/<plate>/<ref>/ and a .segmented marker.
    python gpu_segment_frame.py PLATE REF
"""
import os
import shutil
import sys
import time
from pathlib import Path
from types import SimpleNamespace

G = Path("/scratch-shared/mycostreams_downloads/gpu_stage")
OUT = Path("/scratch-shared/svstaalduine1/seg")
sys.path.insert(0, str(G / "code"))
os.environ["AMF_SEGMENTER"] = "segmenter-ts"
os.environ["AMF_SEGMENT_CHECKPOINT"] = str(G / "models/v9_junction_s2_width_spore.ts")

import torch  # noqa: E402
from pipeline_steps.target import Target  # noqa: E402

from amftrack.scripts.image_processing.segment_tiles import process  # noqa: E402

plate, ref = sys.argv[1:3]
if not torch.cuda.is_available():
    sys.exit("FATAL: no cuda")
src, out = G / "frame" / plate / ref, OUT / plate / ref
if out.exists():
    shutil.rmtree(out)
out.mkdir(parents=True)
(out / "Img").symlink_to(src / "Img")
for n in ("metadata.json", "tile_config.json"):
    if (src / n).exists():
        shutil.copy2(src / n, out / n)
t0 = time.time()
process(Target(out, plate, ref), SimpleNamespace())
n = len(list((src / "Img").glob("*.tif")))
for d in ("segmentations", "segmentations_width", "segmentations_spore"):
    k = len(list((out / d).glob("*.tif")))
    if k != n:
        sys.exit(f"FATAL: {d} has {k} of {n} tiles")
(out / ".segmented").touch()
print(f"[DONE] {plate} {ref} {n} tiles {time.time() - t0:.0f} s on {torch.cuda.get_device_name(0)}", flush=True)
