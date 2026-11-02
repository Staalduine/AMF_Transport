#!/bin/bash
# tshimizu, staging partition. Stage one FLW003 frame (tiles + CPU v9 outputs), the pipeline's amftrack /
# pipeline_steps (the installed 7d25358) and the v9 checkpoint into ONE dir, and give svstaalduine1 read on that dir
# only (the August probe's rule: never ACL the production tree).
#   sbatch -p staging -n 1 -c 1 -t 01:00:00 -J gpu_stage -o stage_%j.out stage.sh
set -euo pipefail
G=/scratch-shared/mycostreams_downloads/gpu_stage
REF=20260609_113215_fmn
SRC=/gpfs/work4/0/prjs1583/storage/images/FLW2605A003/$REF
SP=/home/tshimizu/.cache/pypoetry/virtualenvs/orchestrator-reBytX-n-py3.11/lib/python3.11/site-packages
mkdir -p $G/code $G/models $G/frame/FLW2605A003/$REF $G/cpu_ref/$REF
cp -r $SP/amftrack $SP/pipeline_steps $G/code/
cp $SP/amftrack-0.1.0.dist-info/direct_url.json $G/code/AMFTRACK_COMMIT.json
cp /gpfs/work4/0/prjs1583/models/v9_junction_s2_width_spore.ts $G/models/
cp -r $SRC/Img $G/frame/FLW2605A003/$REF/
cp $SRC/metadata.json $SRC/tile_config.json $G/frame/FLW2605A003/$REF/
for d in $SRC/segmentations*; do cp -r $d $G/cpu_ref/$REF/; done
ls $G/cpu_ref/$REF
setfacl -R -m u:svstaalduine1:rX $G
setfacl -R -d -m u:svstaalduine1:rX $G
getfacl -p $G | head -8
du -sh $G
