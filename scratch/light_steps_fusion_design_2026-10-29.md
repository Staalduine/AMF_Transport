# Fusing the light per-frame spatial_graph steps into one SLURM job (design, 2026-10-29)

Status: design only. Nothing has been implemented, pushed or changed on Snellius.
Code basis: local `~/Software_projects/orchestrator` fast-forwarded to `c03c927` (#239). This is the same commit snelliusDev is on.
Snakemake internals were read from the orchestrator venv: snakemake 9.27.0, snakemake-executor-plugin-slurm 2.6.1, slurm-jobstep 0.6.1. These are the versions the cluster runs.
Measured numbers come from `scp_profile_2026-10-29.md` (3396 completed rule jobs, 9 SCP plates).

## 1. The per-frame spatial_graph DAG

Every rule below is keyed `{plate_id}/{ref_id}`. **None of them needs a neighbouring frame.** The cross-frame windows (gate_frame_components window 6, persistence keep_k, match_frames) all belong to `temporal_graph` (`rules/tempgraph.smk`). They are not part of spatial_graph, so nothing breaks up the per-frame chain.

The only fan-ins are plate-level, and they come after the chain: `plate_report` (`rules/report.smk:78`) and the optional tile-register/volume targets (`Snakefile:226-238`).

Columns: Δ wait is the median queue wait (Start − Submit). Run is median / max elapsed. RSS is median / max. Eff is CPU efficiency.

| # | rule (file:line) | input → output sentinel | partition / cpus / mem / runtime | Δ wait | run | RSS | eff |
|---|---|---|---|---|---|---|---|
| A | stitch (`stitch.smk:57`) | frame dir → `tile_config.json`, `StitchedImage.tif` | fat_rome / 32 / 64 G / 60 | 97 min | 1.8 / 5.3 min | 6.9 / 14.1 G | 48 % |
| B | segment (`segment.smk:44`) | `metadata.json` → `.segmented` | fat_rome / 32 / 16 G / 360 | 105 min | 77 / 186 min | 3.8 / 4.2 G | 95 % |
| 1 | focus_gate (`restitch.smk:74`) | `.segmented` → `.focus_gated` | **staging** / 1 / 4 G / 10 (flag off; partition at `restitch.smk:60-64`) | 1 min | 0.4 min | – | – |
| 2 | correct_tile_layout_from_content (`restitch.smk:132`) | `.focus_gated` + `tile_config.json` → `.restitched` | fat_rome / 16 / 64 G / 60 | 44 min | 1.6 / 2.6 min | 0.5 / 0.6 G | 8 % |
| 3a | skeletonize_segmentations (`graph.smk:210`) | `.restitched` → `.skeletonized_seg` | fat_rome / 16 / 64 G / 60 | 45 min | 1.6 / 2.5 min | 9.0 / 13.8 G | 13 % |
| 3b | detect_spores (`graph.smk:245`) | `.restitched` → `.spores_detected` | fat_rome / 16 / 64 G / 60 | 45 min | 1.3 / 1.9 min | 0.4 / 0.6 G | 16 % |
| 4 | mask (`graph.smk:289`) | 3a + 3b + `.restitched` → `.masked` | fat_rome / 16 / 64 G / 60 | 43 min | 1.6 / 1.8 min | 4.2 / 4.3 G | 5 % |
| 5 | make_graph (`graph.smk:315`) | `.masked` → `.graph_made` | fat_rome / 16 / 64 G / **720** | 47 min | 12.4 / 33 min | 11.4 / 24.3 G | 6 % |
| 6 | bridge_graph_on_evidence (`graph.smk:374`) | `.graph_made` (+ `.restitched`) → `.bridged` | fat_rome / 16 / 64 G / **60** | 43 min | 5.6 / 45 min, **5 TIMEOUT** on SCP420 late frames | 2.0 / 7.7 G | 6 % |
| 7 | bridge_graph_on_spores (`graph.smk:405`) | `.bridged` + `.spores_detected` → `.spore_bridged` | **staging** / 1 / 64 G / 10 (no-op, flag off) | 1 min | 0.4 min | – | – |
| 8 | extract_edge_widths (`graph.smk:448`) | `.masked` + `.spore_bridged` → `.width_extracted` | fat_rome / 16 / 64 G / 360 | 43 min | 6.7 / 10.8 min (only n=2 so far) | 8.6 / 10.9 G | 48 % |
| 9 | save_graph (`graph.smk:472`) | `.width_extracted` + `.spores_detected` → `.graph_saved` | fat_rome / 16 / 64 G / 60 | 35 min | 4.7 min (n=1) | 6.0 G | 6 % |
| C | upload_graph (`upload.smk:38`) | `.graph_saved` → `.graph_uploaded` (the terminal, `Snakefile:212`) | staging / 1 / 4 G / 360, **a real transfer** | 1 min | 0.8 min | – | – |
| D | frame_report (`report.smk:54`) | `.graph_saved` → `.frame_reported` | staging / 1 / 8 G / 30 | 0.3 min | 2.3 min | 1.7 G | 79 % |

Notes on the table:
- stitch (A) and segment (B) run in parallel; neither depends on the other. The chain starts when both `.segmented` and `tile_config.json` exist, and in practice stitch has always finished first.
- After segment there are **eight serial fat_rome queue hops** per frame: rows 2, 3, 4, 5, 6, 8, 9, with 3a and 3b counted once because they run in parallel. Their median waits sum to **~300 min, about 5 h of queueing**. The medians of the actual work in rows 1–9 sum to **~35 min**.

Fusable block: **rows 1–9**, focus_gate through save_graph. It is one connected, purely within-frame subgraph with a single external entry (`.segmented` + `tile_config.json`) and one exit (`.graph_saved`).
- frame_report (D) can join the group as well (see §3).
- upload_graph (C) stays on its own on staging, because it is a transfer.
- stitch and segment stay separate. Segment is 96 % of the core-hours, runs at 95 % efficiency, and has its own GPU path. If stitch joined the group it would be pushed to after segment.

## 2. Options

### (a) Snakemake job groups, with a `group:` directive on rows 1–9 — **recommended**

How it behaves, checked in the installed code:
- **One SLURM job per frame.** Each frame's group is its own connected component, and `group-components` defaults to 1, so frames are never merged. Group jobs are never sent as arrays (`snakemake_executor_plugin_slurm/__init__.py:660-670`). Logs go to `logs/cluster/group_<name>/<wildcards>/%j.log` (`:1045-1050`).
- **Inside the allocation**, the jobstep plugin runs a nested snakemake under one `srun -n1` (`snakemake_executor_plugin_slurm_jobstep/__init__.py:108` says per-level srun is still a TODO; the srun call is at `:183`). The rules run locally in DAG order, so 3a and 3b run concurrently.
- **Every sentinel stays as it is.** `--until <rule>`, `--forcerun <rule>`, hand-deleting a sentinel, and `rerun-triggers: mtime` all keep working. The group postprocess touches outputs level by level with a 0.1 s gap so mtimes stay ordered (`snakemake/jobs.py:1665-1685`).
- **No changes in amftrack, and no new driver code.** Each rule keeps its own shell, environment exports and conditional inputs.

The constraints that shape the implementation:
1. **String resources must be identical across the group, or the controller raises a WorkflowError** (`snakemake/resources.py:275-291`). Today focus_gate and bridge_graph_on_spores use `staging` and `slurm_extra=""`, while everything else uses `fat_rome` and `--ntasks-per-core=1`. When grouped, all members must take `slurm_partition` and `slurm_extra` from one shared constant. That also fixes the staging mis-routing of both no-ops (profile recommendation 5).
2. **The group's resources are worked out by DAG level** (`resources.py:67-273`, called at `jobs.py:1556`):
   - runtime is summed across levels;
   - cpus and mem take the maximum across levels, but are summed within a level.

   Today's values would give runtime 10+60+60+60+720+60+10+360+60 = **1400 min (23 h)**, **32 cpus** and **128 GB**, because 3a and 3b share a level and each asks for 16 cpus and 64 GB. A 23-hour wall limit hurts backfill on a full partition. The grouped rules therefore need their own runtimes and sizes; see the sizing below.
3. **Per-rule runtime is not enforced inside a group.** Only the group's wall limit applies. That actually helps the bridge timeouts: a slow bridge can use slack left over from the fast steps. It also means a hung step can use up the whole budget.
4. **When any member fails, the whole group fails, and Snakemake deletes the sentinels of every member, including the ones that succeeded.** GroupJob.postprocess calls each job's postprocess with error=True, which calls `Job.cleanup` (`jobs.py:1637-1685`, `jobs.py:955-978`, `:1322`). A retry then runs the whole chain again: about 35 min typical, 1.5–2 h worst case. Only the touch() sentinels are removed. The real data files are not declared outputs, so they stay on disk for debugging. `--keep-incomplete` would avoid the rerun, but it applies to every rule, including stitch's real outputs, so I don't recommend it.
5. **sacct will show one record per group**, so per-step timing has to come from somewhere else. Add a `benchmark:` directive to each grouped rule (`benchmarks/<rule>/<plate>_<ref>.tsv`). Snakemake then records wall time, max RSS and CPU time per step for free. That restores the per-step profile, and it also works around the empty-MaxRSS problem on shared nodes.

### (b) One fused rule that calls a Python driver in-process — rejected

- It would have to re-implement nine shells' worth of environment exports (`_GRAPH_FLAG_EXPORTS`, the spore-detector and segmenter `if [ -n ]` exports with their documented `set -e` traps), conditional inputs, and per-rule `--arg-override`s.
- It would lose the per-step sentinels, and with them `--until`, `--forcerun <rule>` and mtime reruns. The alternative is to declare all nine as outputs of one rule, which turns every rerun into all-or-nothing anyway.
- Its one advantage is that it saves eight Python start-ups and imports per frame, a few seconds each. That isn't worth the code, and it duplicates logic that (a) gets for free.

### (c) `localrules`, running the steps on the controller — rejected

- The controllers are 1-CPU / 7 GB jobs on staging, and nine of them share that 10-node partition.
- make_graph needs up to 24 GB and 12–33 min, and skeletonize up to 14 GB.
- This would move the compute onto staging, which is exactly what the profile flagged.

## 3. Recommended change, concretely

New config keys (`workflow_config/defaults.yaml` plus a block at the top of `rules/graph.smk`):

```python
# rules/graph.smk, next to _LIGHT_CPUS (graph.smk:136)
_FRAME_GROUP = config.get("frame_group", True)   # off -> today's per-rule jobs, byte-identical DAG
_GROUP = "frame_graph" if _FRAME_GROUP else None  # verify `group: None` is accepted; else use the profile's `groups:` key
_GROUP_PARTITION = config.get("frame_group_partition", "fat_rome")
_GROUP_EXTRA = "--ntasks-per-core=1"
```

Changes to rows 1–9 (and optionally D):
- Add `group: _GROUP` and `benchmark: STORAGE + "/benchmarks/{rule}/{plate_id}_{ref_id}.tsv"`. A benchmarks tree under the plate directory is an alternative location.
- When `_FRAME_GROUP` is on, set `slurm_partition=_GROUP_PARTITION` and `slurm_extra=_GROUP_EXTRA`. This touches focus_gate (`restitch.smk:60-64, 102-113`), correct_tile_layout (`restitch.smk:141-148`), bridge_graph_on_spores (`graph.smk:433-438`) and frame_report (`report.smk:63`).
- Runtimes when grouped. The sum is what SLURM sees:

| rule | grouped runtime (min) | why |
|---|---|---|
| focus_gate, spore_bridge (flags off) | 5 each | measured 0.4 min |
| correct_tile_layout, skeletonize, detect_spores, mask, save_graph | 15 each | measured max 1.8–4.7 min |
| make_graph | 120 | measured max 33 min; the 6 h TIMEOUTs on SCP2506A083 (July) were before the amftrack speed-ups |
| bridge_graph_on_evidence | 180 | SCP420 late frames are past 60 min and still rising; see open question 2 |
| extract_edge_widths | 60 | measured max 11 min, n=2 |

  Total: **~450 min (7.5 h)**. That is less than a third of the 1400 min an untuned group would ask for, and it leaves 3–4× headroom over the measured worst chain (~1.6 h). Each value stays overridable through the existing `*_runtime` config keys.
- Sizing: set detect_spores to `cpus_per_task=4, mem_mb=8192` when grouped (measured 0.6 GB and ~2.6 cores used). That makes the 3a ∥ 3b level 20 cpus / 72 GB, so the **whole group is 20 cpus / 72 GB**, still within one 1/8-node memory slice. Everything else keeps `_LIGHT_CPUS`=16 and `_LIGHT_MEM_MB`=64 G: make_graph's 24 GB peak needs the headroom, and per the snellius skill cost is not the constraint. The alternative is to leave 32 cpus / 128 GB; that works, but each group then holds two slices.
- frame_report (D): add it to the group. That moves it off staging and removes one more job per frame. It is optional: its wait is 0.3 min today, so this is about routing rather than speed.
- Leave upload_graph, stitch and segment alone.

The profile `jobs: 40` (`profiles/snellius/config.yaml`) can stay. Every SCP controller is currently pinned at exactly 40 running + pending jobs, and roughly 27 of those are pending light jobs. With grouping, each frame holds at most one light slot, so the controllers can keep more segment jobs queued.

## 4. Expected saving

Per frame, the critical path after segment:
- **Today:** ~300 min of queue waits plus ~35 min of work ≈ **5.6 h**.
- **Grouped:** one wait plus ~35 min of work. The wait is probably closer to stitch's 97 min than to the light steps' 45 min, because the group is a bigger ask (20 cpu, 7.5 h limit). That gives **~1.3–2.2 h**.
- **Saving ≈ 3.5–4.5 h of latency per frame.**

Per plate:
- Wall-clock is mostly set by segmentation throughput on a full fat_rome. The saving shows up as (i) a shorter tail, ~4 h off the last frames before plate_report and upload can finish, and (ii) intermediate graphs becoming available ~4 h sooner for every frame.
- SLURM job count drops from ~14 per frame to ~5 (stitch, segment, group, upload, plus retries). For SCP2604A417 that is ~4100 → ~1500 jobs.
- Core-hours barely change, because the light steps are 2 % of the total.

For the current 9-plate campaign: once segmentation finishes (~15 h from the snapshot), today's chain would leave a ~5–6 h tail per plate. The grouped chain would leave ~1.5–2 h.

## 5. Validation before switching production

1. `snakemake -n` on one plate, with grouping on and off. Check that the DAG has the same rules and outputs, and that the group-job resources print as 20 cpu / 72 GB / ~450 min with partition fat_rome. Do this on snelliusDev after the running SCP controllers have finished, or from a worktree so the live runs aren't touched.
2. Pilot on one finished frame of an existing plate with `--forcerun focus_gate`. Compare graph.geojson against the ungrouped run; it should be identical, since the same commands run in the same order. Check that the per-rule benchmark TSVs appear.
3. Failure drill: inject a failure in mask on that pilot frame. Confirm that all group sentinels are cleaned up and that the retry runs the chain once from the start.
4. Run one full plate, then compare its sacct profile and benchmarks with today's numbers.

## 6. Open questions for Sajitha

1. **Should bridge_graph_on_evidence go into the group?** On SCP420 its runtime grows with the timepoint (336 s → over 3600 s by ~frame 60). On the ~290-frame plates (SCP417/418) late frames could take several hours, and a group failure re-runs the whole chain.
   - Inside the group (recommended for now): it gets a 180-min budget plus slack.
   - Alternative: keep it as its own job with a long runtime, which splits the group into two (rows 1–5 and rows 7–9 + D).
   - Either way, why it scales with network size deserves its own issue.
2. **Is the ~7.5 h group limit acceptable?** The other option is to keep make_graph's 720 min as a safety margin, giving ~17 h, which is worse for backfill.
3. **Should frame_report be in the group, or stay on staging?**
4. **Default on or off?** I suggest `frame_group: true` by default once the pilot passes, keeping `false` as the escape hatch.
5. **Timing:** land this after the 9 SCP runs finish. Snakemake parses the Snakefile when a controller starts, so the running controllers would not pick it up anyway, and a mid-campaign change only mixes behaviours across resubmits.
