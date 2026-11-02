#!/bin/bash
# Local driver (runs on Simon's machine, over the two ControlMaster sockets; never logs in).
# Per plate: wait for its GPU array (svstaalduine1, job name gseg_<plate>) to leave the queue, check every staged frame
# has a GPU .segmented, copy the outputs into storage/images (tshimizu staging job gpu_collect_plate.sh), then launch
# `orchestrator run <plate> spatial_graph` with the v9 segmenter flags (segment is skipped: .segmented exists).
#   bash chain_lipids.sh PLATE...
set -uo pipefail
S=$HOME/.ssh/cm-svstaalduine1@snellius.surf.nl:22
H=svstaalduine1@snellius.surf.nl
R=/gpfs/work4/0/prjs1583/storage/reports/gpu_seg_test
MAX_CTRL=2   # our spatial_graph controllers on staging at once
# staging is 10 nodes shared with everyone: one collect at a time, at most MAX_CTRL controllers, and the per-frame
# report / spore-bridge rules (staging by default) sent to fat_rome.
busy() { ssh snelliusDev "squeue -u tshimizu -h -o %j | grep -cE '$1'"; }
alive() { ssh -O check snelliusDev 2>/dev/null || { echo "tshimizu socket gone"; exit 1; }
          ssh -S $S $H true 2>/dev/null || { echo "svstaalduine1 socket gone"; exit 1; }; }
pending=("$@")
ST=$(dirname "$0")/chain_state; mkdir -p "$ST"
while [ ${#pending[@]} -gt 0 ]; do
  alive
  next=()
  for p in "${pending[@]}"; do
    if [ ! -s "$ST/$p" ]; then
      q=$(ssh -S $S $H "squeue -u svstaalduine1 -h -n gseg_$p | wc -l")
      if [ "$q" != "0" ]; then next+=("$p"); continue; fi
      ran=$(ssh -S $S $H "sacct -X -n -S now-2days --name gseg_$p --format=JobID | wc -l")
      if [ "$ran" = "0" ]; then next+=("$p"); continue; fi   # array not submitted yet
      n=$(ssh snelliusDev "wc -l < /scratch-shared/mycostreams_downloads/gpu_stage/frame/$p/refs.txt")
      k=$(ssh snelliusDev "ls /scratch-shared/svstaalduine1/seg/$p/*/.segmented 2>/dev/null | wc -l")
      echo "$(date +%H:%M) $p: GPU done, $k of $n frames segmented"
      if [ "$k" != "$n" ]; then echo "$p: incomplete, not collected"; continue; fi
      [ "$(busy '^gcollect_')" != "0" ] && { next+=("$p"); continue; }
      c=$(ssh snelliusDev "cd $R && sbatch --parsable -p staging -n 1 -c 4 -t 03:00:00 -J gcollect_$p -o gcollect_${p}_%j.out gpu_collect_plate.sh $p 2>/dev/null"); echo "$c" > "$ST/$p"
      echo "$p: collect job $c"; next+=("$p")
    else
      c=$(cat "$ST/$p")
      st=$(ssh snelliusDev "sacct -X -j $c --format=State -n | head -1 | tr -d ' '")
      case "$st" in
        COMPLETED)
          [ -e "$ST/$p.launched" ] && continue
          [ "$(busy '^orch_(LPD2411|EPY2412)')" -ge "$MAX_CTRL" ] && { next+=("$p"); continue; }
          ssh snelliusDev "tail -1 $R/gcollect_${p}_${c}.out"
          ssh snelliusDev "cd /gpfs/home6/tshimizu/orchestrator && module load 2024 >/dev/null 2>&1; set -a; source local.env; set +a; unset VIRTUAL_ENV; source \$POETRY_ENV/bin/activate; \
            orchestrator run $p spatial_graph -C segmenter=segmenter-ts \
            -C segment_checkpoint=/gpfs/work4/0/prjs1583/models/v9_junction_s2_width_spore.ts \
            -C spore_detector=spore_map -C spore_bridge_partition=fat_rome \
            -C frame_report_partition=fat_rome -C plate_report_partition=fat_rome 2>&1 | grep -iE 'submitted|error' | tail -2"
          touch "$ST/$p.launched"; echo "$(date +%H:%M) $p: spatial_graph launched" ;;
        FAILED|CANCELLED*|TIMEOUT|OUT_OF*) echo "$p: collect $st, stopped for this plate" ;;
        *) next+=("$p") ;;
      esac
    fi
  done
  pending=("${next[@]+"${next[@]}"}")
  [ ${#pending[@]} -gt 0 ] && sleep 300
done
echo "chain done"
