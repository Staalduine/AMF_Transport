#!/bin/bash
# tshimizu, staging. Copy the GPU outputs of PLATE into storage/images (only frames whose GPU dir has .segmented and
# all three output dirs), touch .segmented there (the orchestrator's segment sentinel), then drop the staged tiles.
# Needs read on /scratch-shared/svstaalduine1/seg for tshimizu.
#   sbatch -p staging -n 1 -c 4 -t 03:00:00 -J gcollect_PLATE gpu_collect_plate.sh PLATE
set -euo pipefail
P=${1:?plate}
O=/scratch-shared/svstaalduine1/seg/$P
S=/gpfs/work4/0/prjs1583/storage/images/$P
G=/scratch-shared/mycostreams_downloads/gpu_stage/frame/$P
ok=0; miss=0
while read r; do
  if [ -e $O/$r/.segmented ]; then
    for d in segmentations segmentations_width segmentations_spore; do rm -rf $S/$r/$d; cp -r $O/$r/$d $S/$r/; done
    touch $S/$r/.segmented; ok=$((ok+1)); rm -rf $G/$r
  else
    miss=$((miss+1)); echo "not segmented: $r"
  fi
done < $G/refs.txt
echo "$P: collected $ok, missing $miss"
