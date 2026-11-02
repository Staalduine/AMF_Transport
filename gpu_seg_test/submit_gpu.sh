#!/bin/bash
# svstaalduine1: one gpu_mig slice (cost-optimal arm of the August probe), env = ~/venvs/segmenter + missing deps.
#   bash submit_gpu.sh
set -euo pipefail
mkdir -p /scratch-shared/svstaalduine1/gpu_seg_test
sbatch --parsable -p gpu_mig --gpus=1 -t 02:00:00 -J gpuseg_test -o /scratch-shared/svstaalduine1/gpu_seg_test/gpu_%j.out \
  --wrap "module load 2025 Python/3.13.5-GCCcore-14.3.0 && source \$HOME/venvs/segmenter/bin/activate && export PYTHONPATH=/scratch-shared/svstaalduine1/gpu_seg_test/pydeps && /usr/bin/time -v python \$HOME/gpu_seg_test.py"
