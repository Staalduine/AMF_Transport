# Campaign: arc-unit stores (new segmenter) for the FL extension plates — plan, 19 Oct 2026

Goal: `stg_store.h5` per plate, arc-unit structure, segmenter-ts v9, anchored at the session just before the videos,
so the lipid-routes SI can be redone network-level (orientation, edge type, distance to tip, model) on these plates.

## Scope (from plate_inventory/master.tsv)
- 29 plates. Out: CHC2408A287 (no network imaging).
- Archive: 19 HSE under `raw-data/images/<plate>` (6–12 d each); EPY2412A011/017/057 and LPD2411A028/034/045/062 under
  `migration-data/images/...` (2–11 d). LPD2411A051: no archive path in the inventory (Dropbox PRINCE 133_20240911?).
- Snellius today: no graph data for any of them (only `LPD2411A061`, not in the set).
- Sources checked 19 Oct, through the renames (prefix COL→LPD; lab number + crossing date → plate ID):
  - EPY2412A011/017/057: archive `migration-data/images/611_20241021`, `617_20241022`, `657_20241208` (lab-number
    folders, 4 / 3 / 2 tars). Download with the folder name, not the plate ID.
  - LPD2411A028/034/045/062: archive `migration-data/images/<plate>` under the new ID.
  - LPD2411A051 (lab 133, crossed 20240911): not on tape under any name (no `133_20240911`, no COL2411A051).
    Dropbox `DATA/PRINCE/133_20240911`: 103 timepoints (20240911–20240920), one `Img.zip` + `param.m` each, online-only
    locally → rclone from Dropbox to Snellius (staging job).
  - HSE (19): archive `raw-data/images/<plate>` under the plate ID.
  - CHC2408A287 (lab 886, crossed 20240916; videos as `LIPIDS_2024/DATA/20240923_Plate886`): no Prince folder
    `886_2024*` (the 886 folder in PRINCE is 886_20230516 = ROT2302A116), nothing on tape. Neighbours CHC2408A286 /
    288 / 289 were imaged (885/887/888). No network images exist for it → out.

## Recipe (orchestrator; controller = Snakemake, every rule on fat_rome)
```
orchestrator download <plate> [--source migration-data]
orchestrator run <plate> spatial_graph -C segmenter=segmenter-ts \
    -C segment_checkpoint=/gpfs/work4/0/prjs1583/models/v9_junction_s2_width_spore.ts \
    -C spore_detector=spore_map -C spore_bridge_partition=fat_rome
orchestrator run <plate> temporal_graph -C tempgraph_structure=arc-unit \
    -C tempgraph_anchor=<YYYYMMDD_HHMM>.geojson -C tempgraph_mem_mb=245760 --until export_stg
```
- Neither the new segmenter nor arc-unit is the default: both flags on every call.
- `rerun-triggers: mtime`: a flag change on an existing bank re-runs nothing; use `--forcerun`.
- Earlier `_arcunit` paper stores came from `~/arcunit_builds/build_arcunit.sbatch`, not the orchestrator: check it
  still exists and which path the pilot uses.

## Deploy before the pilot (Simon, 19 Oct: after the other session's run finishes)
- Snellius runs orchestrator a3e3b2d (#232) with amftrack 7d25358 (installed 13 Oct). Upstream: orchestrator master
  558bb2d (#236) relocks amftrack to d2ae13a: Zhang-Suen LUT thinning (#266), width profiles on processes (~5×,
  identical, #267), stitch prior default calibrated (#265).
- When no orch_* controller and no UUID rule jobs remain: `git pull` the cluster checkout, `poetry install` into
  $POETRY_ENV, check direct_url.json commit = d2ae13a, print amftrack.__file__ in the first pilot job.

## Phases
0. **Preflight (one staging job, no compute)**: list the archive tars per plate (frame counts → cost), find LPD051's
   images, `myquota` on /projects (FLW003 alone held 25 GB of frame graphs), confirm `build_arcunit.sbatch`.
1. **Pilot, 2 plates**: HSE2510A276 (10 d) and LPD2411A034 (106 timepoints, the largest). Full chain to
   `export_stg`; record wall-clock and peak memory per rule (`/usr/bin/time -v` or `--exclusive`; MaxRSS is empty on
   shared nodes). Go/no-go on the arc-unit match_frames time (7–8× anchor-seg on the dev bank).
2. **Download waves**: ≤ 4 staging jobs at once (staging = 10 nodes, shared with the running SCP transfers).
3. **spatial_graph waves of ~6 plates**: ~7 h per plate on CPU, 85 % of it segmentation. Run controllers as small
   fat_rome jobs, not staging, so 6 controllers don't take 6 of the 10 staging nodes.
4. **Manual (Simon)**: per plate the anchor session (proposal: last network frame before the first video — I list
   candidates per plate), roots in the registrator, video registration sessions (`~/cutplates/build_reg_sessions.py`).
5. **temporal_graph, arc-unit**: per plate in parallel on fat_rome; match_frames limit 2880 min; gate at 942080 MB for
   large banks (FLW003 OOM'd twice at 480 GB). Chain with `--dependency=afterok`, no ssh polling.
6. **Downstream**: copy to /projects + Dropbox `paper_plates/<plate>_tNN_arcunit`; main model
   (`global_gimf_gimf_minedge20_keras_ratio_fb`) per store; mode_to_model + lipid_direction_oriented + oriented_mixture
   + orientation_flag on all plates; refresh the SI figures.

## Decisions (Simon, 19 Oct)
1. Arc-unit straight away. 2. GPU segmentation if possible. 3. Anchor = last network frame before the filming
session; check the video timeline for plates needing several stores. 4. LIPIDS_2024 plates first. 5. Wait for the
other session's orchestrator run before submitting.

## Anchors (anchor_timeline.py → anchor_timeline.csv)
- One filming session per plate (videos within 2 h of each other; spans 1.4–5.6 h): one store each, 29 stores.
- Gap from anchor to filming: LIPIDS LPD 2.4–5.3 h, EPY057 2.6 h; EPY011 / 017 21–22 h; all 19 HSE 19–32 h (imaging
  stops the day before filming; HSE025 has an imaging hole on 18 Mar). Growth in that day is missing from the store.

## Decisions asked earlier
1. Arc-unit for all, or anchor-seg first (faster, ~22 h temporal on STR112) and arc-unit after?
2. Segmentation on GPU (gpu_a100 via svstaalduine1, ~4 min/frame against ~1 h; needs your socket) or CPU only?
3. Anchor policy: approve per plate from my candidate list, or the rule "last frame before the video session"?
4. Order: LIPIDS_2024 (direct Nile Red set, 7 plates) first, then HSE?
5. Share the queue with the other session's orchestrator (LPD2412A017 running; fair-share is low)?

## Risks
Snakemake idle deadlock (cancel + resubmit), NODE_FAIL "None assigned" (orchestrator #154), OOM in a
multiprocessing.Pool (hangs, check sacct for OUT_OF_MEMORY), the hand-repaired venv, scratch retention (write to
/projects), 5 failed logins = 24 h ban (socket check before every ssh).

## Rough timeline
Preflight ½ day · pilot 2–3 days · 29 plates 1–2 weeks wall-clock, set by the arc-unit match_frames and the manual
anchor/root step.

## GPU segmentation (checked 19 Oct, svstaalduine1 socket up)
- svstaalduine1 (EINF-18127, gpu_a100 / gpu_h100 / gpu_mig) cannot read /projects/prjs1583, so segmentation cannot be
  a rule in tshimizu's Snakemake DAG (docs/log/2026-08-15-gpu-segment-cost-probe.md). Route used by that probe:
  stage into an ACL'd dir under /scratch-shared/mycostreams_downloads (u:svstaalduine1:rx, traverse already granted),
  outputs to /scratch-shared/svstaalduine1 (ACL u:tshimizu:rx). Never ACL the production tree.
- segment = per raw tile (amftrack segment_tiles): mask + width + spore maps beside Img/; sentinel `.segmented`.
- Flow per plate: tshimizu downloads frames into the stage dir → svstaalduine1 GPU array (one frame per task,
  gpu_mig first) with segmenter-ts v9 (copy the .ts into the stage dir) → tshimizu copies outputs into
  storage/images/<plate>/<ref>/, touches `.segmented`, runs spatial_graph (segment skipped).
- Env: ~/venvs/segmenter (torch 2.13 + segmenter) on svstaalduine1; amftrack/pipeline-steps from a fresh code copy in
  the stage dir (the probe's copy is fae5223, before segmenter-ts).
- Gate before use: one frame already segmented on CPU with v9 (FLW003) re-segmented on GPU; masks must match
  (count + pixel diff), device must log cuda, time per frame recorded.
- **Gate passed (19 Oct, job 28280265, gpu_mig, A100 MIG 3g.20gb, torch 2.13.0+cu130, cuda True):** FLW003 frame
  20260609_113215_fmn, 129 tiles, segmenter-ts v9 from amftrack 7d25358 (the pipeline's installed copy). Segmentation
  134 s per frame (job 3.5 min incl. model load), peak GPU 2.0 GiB. Against the CPU v9 outputs of 12 Oct: all 129
  tiles; mask pixel disagreement median 1.5e-7, max 2.3e-6 (≈ 1 pixel per tile at most); width maps same; spore maps
  median 0, max 5.7e-5. CPU reference ~1 h per frame → ~25× faster; ~2.4 SBU per frame at 64 SBU/GPU-h.
- Env: ~/venvs/segmenter + `/scratch-shared/svstaalduine1/gpu_seg_test/pydeps` (pip --target --no-deps: torchvision
  0.28, pandas 3.0.6, tqdm, opencv-python-headless, geojson, h5py, matplotlib + deps). Move it to /home before the
  campaign: scratch purges after 14 days. Stage dir ACL (approved by Simon 19 Oct):
  /scratch-shared/mycostreams_downloads/gpu_stage, u:svstaalduine1:rX.
- Per-plate GPU scripts (gpu_seg_test/): `gpu_stage_plate.sh` (tshimizu, staging: copy unsegmented frames into the
  stage dir) → `gpu_segment_plate.sh` (svstaalduine1: gpu_mig array, ≤ 8 at once, `gpu_segment_frame.py`, checks all
  three output dirs are complete) → `gpu_collect_plate.sh` (tshimizu, staging: copy outputs into storage/images,
  touch `.segmented`, drop staged tiles) → `orchestrator run <plate> spatial_graph` skips segment.
  ACL svstaalduine1 → tshimizu (approved 19 Oct): u:tshimizu:rX on /scratch-shared/svstaalduine1/seg (+ default),
  traverse only (--x) on /scratch-shared/svstaalduine1; verified from tshimizu.
  After the deploy, refresh gpu_stage/code to the deployed amftrack (d2ae13a) so both sides run one version.
  Cross-account: no --dependency between the accounts; the svstaalduine1 socket must stay up during the campaign.

## Matching radius vs production registration residual (19 Oct, job 28285939, reg_residual/)
Nearest distance from points every 20 µm on frame t's hyphae to frame t+k's network, production
`graph_data_registered` (STHype graph registration), medians over frame pairs:

| plate | lag | p50 | p90 | p95 | p99 | > 25 µm | > 50 µm |
|---|---|---|---|---|---|---|---|
| PNF2307A080 | 1 | 4.5 | 17 | 28 | 81 | 6 % | 2.3 % |
| STR2307A112 | 1 | 9.2 | 32 | 46 | 95 | 14 % | 4.2 % |
| LPD2412A025 (registered 10 Sep) | 1 | 12.3 | 44 | 61 | 105 | 26 % | 7.6 % |
| EPY2412A088 (`.ph` files excluded) | 20 | 3.8 | 16 | 33 | 105 | 7 % | 3.3 % |

- Frame-wide shift left after registration: median 0.4–1.9 µm. The rigid global fit is fine; what is left is local
  (stitching inside a frame, centreline wobble, segmentation changes) and grows with lag.
- A 50 µm radius would lose the match on 2–8 % of hypha length per frame step; ~100 µm on ~1 %. The 172.5 µm
  radius sits near p99.9. Not shrunk for this campaign (Simon, 19 Oct: global/tile registration is a later issue).
- EPY2412A088/graph_data_registered has 107 `*.ph.geojson` beside the frames (none in graph_data): unexplained.

## Project-space files and per-plate cleanup (19 Oct)
- prjs1583: 50 TiB (32 % used) but inodes 91 % (~330 k left; `prjspc-quota /gpfs/work4/0/prjs1583`). A frame is
  ~520 files (129 tiles + 3 × 129 seg outputs + graph files). Simon: no quota request; go plate by plate.
- Rule: after a plate's spatial graphs are built (`.graph_collected` on every frame), delete its `Img/` tiles (on tape)
  before the next plate's download; check inodes before each download wave.
- Downloads 19 Oct ~20:50 (staging, `download_archive`, orchestrator's `_run_archive_download` with the >100-jobs
  queue wait skipped, the other session keeps the queue above it): LPD028 28314636, LPD034 28314638 + 28314640,
  LPD045 28314642, LPD062 28314643, EPY011 28314645 (611_20241021), EPY017 28314648 (617_20241022),
  EPY057 28314651 (657_20241208). LPD051: Dropbox PRINCE/133_20240911 (Img.zip per frame), not yet.

## Deploy done (20 Oct ~09:45, Simon: cancel + relaunch the other session's controllers)
- Three SCP controllers were idle/stuck (SCP252 since 19 Oct 10:04, SCP251 since 23:17, SCP328 since 02:45; SCP252/251
  frame_report OOM at 8 GB per the stitching session). Cancelled all four + SCP278's 6 rule jobs.
- ~/orchestrator a3e3b2d → 558bb2d (ff; local .gitignore / user_GUI.ipynb kept); poetry install: amftrack 7d25358 →
  d2ae13a (#266 thinning, #267 widths, both identical output), flow-analysis-comps wheel → locked 3753395 (same commit).
- Relaunched (staging, 3 d): SCP252 28357683 / SCP251 28357684 (+ frame_report_mem_mb=49152), SCP328 28357685,
  SCP278 28357686. SCP2512A250 (same OOM, FAILED 18 Oct) left to Simon / the stitching session.
- The GPU stage dir code is still amftrack 7d25358: segmentation unchanged by #266/#267, refresh before the HSE plates.

## Anchor rule changed (Simon, 20 Oct): latest network frame up to the end of filming
Changes only LPD2411A028 (20240902_1004 → 20240902_1241, t34) and EPY2412A057 (20241210_0654 → 20241210_1044, t9);
elsewhere imaging ends before filming. anchor_timeline.csv updated (anchor_before kept).

## Progress 20 Oct
- LPD2411A028: spatial_graph (orch 28361878) 458/458 steps in ~50 min, segment skipped (GPU masks used).
  temporal_graph arc-unit (orch 28365990): `-C tempgraph_structure=arc-unit -C tempgraph_anchor=20240902_1241.geojson
  -C tempgraph_mem_mb=245760 -C plate_report_partition=fat_rome -C frame_report_partition=fat_rome --until export_stg`
  (dry-run: 35 collect_graph + register, gate, 8 store steps; no stitch/segment).
- After a plate's store exists: delete images/<plate>/*/Img (tiles on tape / Dropbox), keep the rest.
- Hyperedges: orchestrator default `continuity=none` (off since 14 Aug) → every edge in one hyperedge, empty
  hypergraph.json. The September paper arc stores used `continuity=placegraph`. Simon (20 Oct): no hyperedges for now.
- LPD2411A028 store done 12:12 (36 min): 33 timepoints, 4,495 arc edges, 3,375 nodes, 137 spores; tiles removed
  (28374213). LPD2411A034 store launched (orch 28374491, anchor 20240912_0614).
- gpu_seg_test/chain_stores.sh: spatial complete → store (≤ 2 of our controllers) → tile cleanup after export.

## Project-space cleanup (20 Oct, Simon)
- Sander's DAO2607S109 removed (sander_raw, sander_meta, storage/images + videos; originals on Dropbox
  DATA_VU/DATA_Sander): 6,188 files, 39 GB.
- Tars: 3 wall_labels/v2/archive_probe tars + registrator_bundle_EPY2412A088.tar.gz removed (2.3 GB); kept the legacy
  U-Net checkpoint myr-bg-strict-6-plates-att-2.pth.tar and cut_annotations/*.tgz.
- Tier 1 (job 28380902, 5 min, xargs -P 32 on fat_rome): 44 finished plates (storage/reports/tier1_plates.txt),
  3,722 frames with .graph_saved: Img/ + segmentations{,_width,_spore} removed, .cleaned touched (orchestrator
  cleanup_images policy). Inodes 94.9 % → 61.2 %, capacity 33.3 % → 25.7 %.
- Not touched: 18 DAS plates (~495 k files, tiles only; Simon: leave for now), SCP278/328 + LPD2412A017 (other
  session), LPD2411A061 (status unclear), our LIPIDS plates (campaign_step now cleans Img + segmentations after store).
