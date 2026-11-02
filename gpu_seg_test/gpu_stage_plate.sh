#!/bin/bash
# tshimizu, staging. Copy every not-yet-segmented frame of PLATE (tiles + metadata) into the ACL'd stage dir (the
# default ACL set on 19 Oct makes new files readable by svstaalduine1; no new grant) and write the frame list.
#   sbatch -p staging -n 1 -c 4 -t 06:00:00 -J gstage_PLATE gpu_stage_plate.sh PLATE
set -euo pipefail
P=${1:?plate}
G=/scratch-shared/mycostreams_downloads/gpu_stage/frame/$P
S=/gpfs/work4/0/prjs1583/storage/images/$P
mkdir -p $G
: > $G/refs.txt
for d in $S/*/; do
  r=$(basename $d)
  [ -e $d/.segmented ] && continue
  mkdir -p $G/$r
  cp -r $d/Img $G/$r/
  cp $d/metadata.json $G/$r/
  [ -e $d/tile_config.json ] && cp $d/tile_config.json $G/$r/
  echo $r >> $G/refs.txt
done
echo "$P: $(wc -l < $G/refs.txt) frames staged"; du -sh $G
