#!/bin/bash
# Local driver, second half (over the tshimizu ControlMaster socket; never logs in).
# Per plate: once its spatial_graph is complete (no controller left, every frame .graph_saved), launch the arc-unit
# store anchored at anchor_timeline.csv's frame (at most MAX_CTRL of our controllers on staging); once the store is
# exported (graphs/<plate>/.hyperedge_made), delete the plate's raw tiles (images/<plate>/*/Img).
#   bash chain_stores.sh PLATE...
set -uo pipefail
MAX_CTRL=2
ST=$(dirname "$0")/chain_state; mkdir -p "$ST"
A=$(dirname "$0")/../anchor_timeline.csv
I=/gpfs/work4/0/prjs1583/storage/images
G=/gpfs/work4/0/prjs1583/storage/graphs
R=/gpfs/work4/0/prjs1583/storage/reports/gpu_seg_test
alive() { ssh -O check snelliusDev 2>/dev/null || { echo "tshimizu socket gone"; exit 1; }; }
busy() { ssh snelliusDev "squeue -u tshimizu -h -o %j | grep -cE '$1'"; }
pending=("$@")
while [ ${#pending[@]} -gt 0 ]; do
  alive
  next=()
  for p in "${pending[@]}"; do
    if [ ! -e "$ST/$p.store" ]; then
      [ "$(busy "^orch_${p}_")" != "0" ] && { next+=("$p"); continue; }          # spatial still running
      ok=$(ssh snelliusDev "n=\$(ls -d $I/$p/*/ | wc -l); k=\$(ls $I/$p/*/.graph_saved 2>/dev/null | wc -l); [ \$n -gt 0 ] && [ \$n = \$k ] && echo yes")
      [ "$ok" != "yes" ] && { next+=("$p"); continue; }
      [ "$(busy '^orch_(LPD2411|EPY2412)')" -ge "$MAX_CTRL" ] && { next+=("$p"); continue; }
      anchor=$(awk -F, -v p="$p" 'NR==1{for(i=1;i<=NF;i++) if($i=="anchor") c=i} $1==p{print $c}' "$A")
      [ -z "$anchor" ] && { echo "$p: no anchor"; continue; }
      ssh snelliusDev "cd /gpfs/home6/tshimizu/orchestrator && module load 2024 >/dev/null 2>&1; set -a; source local.env; set +a; unset VIRTUAL_ENV; source \$POETRY_ENV/bin/activate; \
        orchestrator run $p temporal_graph -C tempgraph_structure=arc-unit -C tempgraph_anchor=$anchor.geojson \
        -C tempgraph_mem_mb=245760 -C plate_report_partition=fat_rome -C frame_report_partition=fat_rome \
        --until export_stg 2>&1 | grep -iE 'submitted|error' | tail -2"
      touch "$ST/$p.store"; echo "$(date +%H:%M) $p: store launched (anchor $anchor)"; next+=("$p")
    else
      if [ "$(busy "^orch_${p}_")" != "0" ]; then next+=("$p"); continue; fi
      done_=$(ssh snelliusDev "[ -e $G/$p/.hyperedge_made ] && [ -s $G/$p/stg_store.h5 ] && echo yes")
      if [ "$done_" != "yes" ]; then echo "$(date +%H:%M) $p: store controller ended without export, tiles kept"; continue; fi
      j=$(ssh snelliusDev "cd $R && sbatch --parsable -p staging -n 1 -c 1 -t 01:00:00 -J rmtiles_$p -o rmtiles_${p}_%j.out --wrap 'rm -rf $I/$p/*/Img; /gpfs/admin/hpc/usertools/prjspc-quota /gpfs/work4/0/prjs1583' 2>/dev/null")
      echo "$(date +%H:%M) $p: store done, tile cleanup job $j"
    fi
  done
  pending=("${next[@]+"${next[@]}"}")
  [ ${#pending[@]} -gt 0 ] && sleep 300
done
echo "stores chain done"
