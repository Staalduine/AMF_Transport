#!/bin/bash
# One campaign step, run on the Snellius login node as tshimizu (cheap: file counts, squeue, at most a few sbatch).
# Decides each plate's next action from cluster state alone (no local state), so a lost driver loses nothing:
#   GPU outputs complete, not yet in storage   -> collect   (one gcollect_ at a time)
#   segmented, graphs missing, no controller   -> spatial_graph  (≤ MAX_CTRL of our orch_ controllers)
#   graphs complete, no store, no controller   -> arc-unit store at the anchor in ANCHORS
#   store exported, tiles still there          -> delete Img/ + segmentations* of frames with .graph_saved (as orchestrator cleanup_images)
# Prints one line per plate.   bash campaign_step.sh ANCHORS_CSV(plate,anchor) PLATE...
set -uo pipefail
MAX_CTRL=2
A=$1; shift
I=/gpfs/work4/0/prjs1583/storage/images
G=/gpfs/work4/0/prjs1583/storage/graphs
F=/scratch-shared/mycostreams_downloads/gpu_stage/frame
O=/scratch-shared/svstaalduine1/seg
R=/gpfs/work4/0/prjs1583/storage/reports/gpu_seg_test
Q=$(squeue -u tshimizu -h -o %j)
ctrl=$(grep -cE '^orch_(LPD2411|EPY2412|HSE25)' <<< "$Q")
LOGS=/gpfs/home6/tshimizu/orchestrator/logs
tries() { ls $LOGS/orch_$1_$2_*.out 2>/dev/null | wc -l; }   # controllers launched so far for plate, pipeline
MAX_TRIES=2   # a step that failed this often is reported, not relaunched (EPY057 was relaunched ~20 times on 21 Oct)
orch() {   # plate pipeline extra-config...
  local p=$1 pl=$2; shift 2
  ( cd /gpfs/home6/tshimizu/orchestrator && module load 2024 >/dev/null 2>&1; set -a; source local.env; set +a
    unset VIRTUAL_ENV; source "$POETRY_ENV/bin/activate"
    orchestrator run "$p" "$pl" -C plate_report_partition=fat_rome -C frame_report_partition=fat_rome "$@" 2>&1 \
      | grep -oE 'Submitted [0-9]+' | tail -1 )
}
for p in "$@"; do
  n=$(wc -l < $F/$p/refs.txt 2>/dev/null || echo 0)
  gpu=$(ls $O/$p/*/.segmented 2>/dev/null | wc -l)
  seg=$(ls $I/$p/*/.segmented 2>/dev/null | wc -l)
  gr=$(ls $I/$p/*/.graph_saved 2>/dev/null | wc -l)
  tiles=$(ls -d $I/$p/*/Img 2>/dev/null | wc -l)
  store=$([ -e $G/$p/.hyperedge_made ] && [ -s $G/$p/stg_store.h5 ] && echo 1 || echo 0)
  running=$(grep -cE "^(orch_${p}_|gcollect_$p|rmtiles_$p)" <<< "$Q")
  s="$p n=$n gpu=$gpu seg=$seg graphs=$gr store=$store tiles=$tiles"
  if [ "$running" != "0" ]; then echo "$s : running"; continue; fi
  if [ "$n" = "0" ]; then echo "$s : not staged"; continue; fi
  if [ "$seg" -lt "$n" ]; then
    if [ "$gpu" -lt "$n" ]; then echo "$s : waiting for GPU"; continue; fi
    if grep -q '^gcollect_' <<< "$Q"; then echo "$s : collect queued"; continue; fi
    j=$(cd $R && sbatch --parsable -p staging -n 1 -c 4 -t 03:00:00 -J gcollect_$p -o gcollect_${p}_%j.out gpu_collect_plate.sh $p 2>/dev/null)
    Q+=$'\n'gcollect_$p; echo "$s : collect $j"; continue
  fi
  if [ "$store" = "0" ]; then
    if [ "$ctrl" -ge "$MAX_CTRL" ]; then echo "$s : waiting for a controller slot"; continue; fi
    if [ "$gr" -lt "$n" ]; then
      [ "$(tries $p spatial_graph)" -ge "$MAX_TRIES" ] && { echo "$s : spatial_graph failed $MAX_TRIES times, needs a look"; continue; }
      j=$(orch $p spatial_graph -C segmenter=segmenter-ts \
          -C segment_checkpoint=/gpfs/work4/0/prjs1583/models/v9_junction_s2_width_spore.ts \
          -C spore_detector=spore_map -C spore_bridge_partition=fat_rome)
      ctrl=$((ctrl + 1)); echo "$s : spatial_graph $j"; continue
    fi
    [ "$(tries $p temporal_graph)" -ge "$MAX_TRIES" ] && { echo "$s : store failed $MAX_TRIES times, needs a look"; continue; }
    a=$(awk -F, -v p=$p '$1==p {print $2}' $A)
    [ -z "$a" ] && { echo "$s : no anchor"; continue; }
    j=$(orch $p temporal_graph -C tempgraph_structure=arc-unit -C tempgraph_anchor=$a.geojson \
        -C tempgraph_mem_mb=245760 --until export_stg)
    ctrl=$((ctrl + 1)); echo "$s : store $j (anchor $a)"; continue
  fi
  if [ "$tiles" -gt 0 ]; then
    j=$(cd $R && sbatch --parsable -p staging -n 1 -c 1 -t 01:00:00 -J rmtiles_$p -o rmtiles_${p}_%j.out \
        --wrap "for d in $I/$p/*/; do [ -e \$d/.graph_saved ] && rm -rf \$d/Img \$d/segmentations \$d/segmentations_width \$d/segmentations_spore && touch \$d/.cleaned; done; true" 2>/dev/null)
    echo "$s : tile cleanup $j"; continue
  fi
  echo "$s : done"
done
