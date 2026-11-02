#!/bin/bash
# svstaalduine1: one gpu_mig array task per staged frame (at most 8 at once).
#   bash gpu_segment_plate.sh PLATE
set -euo pipefail
P=${1:?plate}
L=/scratch-shared/mycostreams_downloads/gpu_stage/frame/$P/refs.txt
N=$(wc -l < $L)
mkdir -p /scratch-shared/svstaalduine1/seg/logs
sbatch --parsable -p gpu_mig --gpus=1 -t 00:30:00 --array=1-$N%8 -J gseg_$P \
  -o /scratch-shared/svstaalduine1/seg/logs/${P}_%A_%a.out \
  --wrap "module load 2025 Python/3.13.5-GCCcore-14.3.0 && source \$HOME/venvs/segmenter/bin/activate && \
export PYTHONPATH=\$HOME/venvs/segmenter_pydeps && R=\$(sed -n \${SLURM_ARRAY_TASK_ID}p $L) && \
python \$HOME/gpu_segment_frame.py $P \$R"
