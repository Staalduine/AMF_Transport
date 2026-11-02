#!/bin/bash
# LIPIDS_2024 sessions -> orchestrator polyflow (walls_v4 U-Net), per plate:
#   xfer (staging, rclone from Dropbox) -> ingest (fat_rome, bin + metadata.json) -> orchestrator polyflow controller.
# Two staging lanes, so at most 2 transfer jobs exist at once.
# usage (Snellius, tshimizu): bash launch.sh [PLATE ...]   (default: all 8, in the order below)
set -euo pipefail
D=/gpfs/work4/0/prjs1583/storage/reports/lipids_polyflow
RAW=/scratch-shared/tshimizu/lipids_raw
VIDEOS=/gpfs/work4/0/prjs1583/storage/videos
CKPT=/gpfs/work4/0/prjs1583/models/walls_v4/best.pt
PY=/home/tshimizu/.cache/pypoetry/virtualenvs/orchestrator-reBytX-n-py3.11/bin/python
mkdir -p $D/logs $RAW
declare -A SRC=(
  [LPD2411A034]=20240912_Plate116/RAW_DATA [LPD2411A028]=20240902_Plate110/RAW_DATA
  [LPD2411A045]=20240909_Plate127/RAW_DATA [LPD2411A051]=20240920_Plate133/RAW_DATA
  [LPD2411A062]=20241008_Plate144/RAW_DATA [EPY2412A011]=20241025_Plate611
  [EPY2412A017]=20241025_Plate617 [EPY2412A057]=20241210_Plate657
)
PLATES=${*:-LPD2411A034 EPY2412A011 LPD2411A028 EPY2412A017 LPD2411A045 EPY2412A057 LPD2411A051 LPD2411A062}
i=0; declare -a last
for p in $PLATES; do
  src=${SRC[$p]}; s=${src%%/*}; lane=$((i % 2))
  dep=${last[$lane]:+--dependency=afterany:${last[$lane]}}
  x=$(sbatch --parsable $dep -p staging -c 8 --mem=16G -t 24:00:00 -J lpf_xfer_$p -o $D/logs/xfer_${p}_%j.out \
      --wrap "rclone copy 'dropbox:/DATA/LIPIDS_2024/DATA/$src' '$RAW/$s' --include '/[0-9]*/**' --transfers 16 --checkers 16 --stats 10m --stats-one-line")
  g=$(sbatch --parsable --dependency=afterok:$x -p fat_rome -c 16 --mem=100G -t 12:00:00 -J lpf_ingest_$p -o $D/logs/ingest_${p}_%j.out \
      --wrap "module load 2024; export OMP_NUM_THREADS=1; $PY $D/ingest_session.py $RAW/$s $p $s $VIDEOS 16 || exit 1; rmdir $RAW/$s 2>/dev/null || true")
  o=$(cd /gpfs/home6/tshimizu/orchestrator && module load 2024 >/dev/null 2>&1 && set -a && source local.env && set +a && unset VIRTUAL_ENV \
      && source $POETRY_ENV/bin/activate && orchestrator run $p polyflow --dependency=afterok:$g \
         -C flow_segmenter=unet -C flow_segment_checkpoint=$CKPT 2>&1 | grep -oE '[0-9]{6,}' | tail -1)
  last[$lane]=$x; i=$((i+1))
  echo "$p ($s) lane $lane xfer $x ingest $g polyflow $o" | tee -a $D/jobs.txt
done
