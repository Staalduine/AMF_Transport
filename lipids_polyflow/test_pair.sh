#!/bin/bash
# One BF/FL pair of LPD2411A034 (videos 001, 002) through transfer + ingest into a throwaway videos root, then
# read it back the way the pipeline does (flow_analysis_comps metadata reader + orchestrator video index).
set -euo pipefail
D=/gpfs/work4/0/prjs1583/storage/reports/lipids_polyflow; T=/scratch-shared/tshimizu/lipids_test
PY=/home/tshimizu/.cache/pypoetry/virtualenvs/orchestrator-reBytX-n-py3.11/bin/python
rm -rf $T; mkdir -p $T/raw $T/videos
rclone copy dropbox:/DATA/LIPIDS_2024/DATA/20240912_Plate116/RAW_DATA $T/raw --include '/00[12]/**' --transfers 16
$PY $D/ingest_session.py $T/raw LPD2411A034 20240912_Plate116 $T/videos 2
cd /gpfs/home6/tshimizu/orchestrator
PYTHONPATH=/gpfs/home6/tshimizu/orchestrator $PY - <<PY
from pathlib import Path
from flow_analysis_comps.io import find_video_metadata
from orchestrator.util.video_index import build_video_position_index, compute_borrower_map
root = Path("$T/videos/LPD2411A034")
for d in sorted(p for p in root.iterdir() if p.is_dir()):
    m = find_video_metadata(d)
    print(d.name, m.mode, m.position, m.camera.binning, m.camera.frame_size, m.camera.exposure_us, m.frame_nr, m.date_time)
idx = build_video_position_index(root)
print("borrowers:", compute_borrower_map(idx))
import tifffile; a = tifffile.imread(next((root / sorted(p.name for p in root.iterdir() if p.is_dir())[0] / "Img").glob("*.tif")))
print("frame", a.shape, a.dtype, a.min(), a.max(), a.mean())
PY
