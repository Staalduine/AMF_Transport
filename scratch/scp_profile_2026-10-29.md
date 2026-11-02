# SCP spatial_graph runs — profile, 2026-10-29 ~11:05 CET (read-only)

Source: `ssh snelliusDev` (tshimizu). 9 Snakemake controllers (`sbatch --wrap`, staging, 1 CPU / 7 G / 3 d),
submitted 28 Oct 16:13–16:16, started 17:34–20:49 (held until their download jobs finished).
Controller logs: `/gpfs/home6/tshimizu/orchestrator/logs/SCP<nnn>_<jobid>.out`; rule logs under
`logs/cluster/rule_<rule>/<plate>_<ts>/<jobid>.log`. Rule-job ↔ rule mapping parsed from the controller logs
("submitted with SLURM jobid"); sacct read on the `.0` step for TotalCPU/MaxRSS (MaxRSS IS populated here).
Raw: `scp_sacct_raw_2026-10-29.psv` (sacct -P, all steps), `scp_sacct_2026-10-29.tsv` (one row per rule job, joined).
Script: `scp_profile.py`.

## Per plate

Job counts are SLURM rule jobs submitted so far (retries count separately). `segmented` = timepoints with a COMPLETED segment / segment jobs in the DAG.

| plate       |   controller |   COMPLETED |   FAILED |   PENDING |   RUNNING |   TIMEOUT | segmented   |
|:------------|-------------:|------------:|---------:|----------:|----------:|----------:|:------------|
| SCP2601A330 |     28666749 |         356 |        0 |        27 |        13 |         0 | 94/157      |
| SCP2601A332 |     28666774 |         364 |        0 |        29 |        11 |         0 | 98/168      |
| SCP2601A334 |     28666779 |         390 |        0 |        25 |        15 |         0 | 100/121     |
| SCP2601A335 |     28666786 |         345 |        5 |        30 |         9 |         0 | 86/129      |
| SCP2604A414 |     28666828 |         442 |        0 |        21 |        19 |         0 | 110/217     |
| SCP2604A417 |     28666844 |         332 |        0 |        26 |        14 |         0 | 89/294      |
| SCP2604A418 |     28666857 |         348 |        0 |        24 |        14 |         0 | 82/285      |
| SCP2604A420 |     28666866 |         473 |        0 |        32 |         7 |         5 | 81/81       |
| SCP2604A421 |     28666878 |         346 |        0 |        27 |        13 |         0 | 92/249      |

Snakemake progress at snapshot: 330 16 % · 332 15 % · 334 23 % · 335 19 % · 414 15 % · 417 8 % · 418 9 % · 420 42 % · 421 10 % of DAG steps.
Total segments 1701; 832 done, 95 running. Segment throughput since 00:00 ≈ 55/h ⇒ **~15–16 h more of segmentation** at the current fat_rome share, then the per-frame graph chain.

## Per step (COMPLETED jobs only)

Wait = Start − Submit. cpu_eff = TotalCPU(.0) / (elapsed × cpus). core_h = elapsed × allocated CPUs.

| rule                             |   n | partition   |   cpus |   req_GB |   limit_min |   med_elapsed_min |   max_elapsed_min |   med_wait_min |   cpu_eff |   maxrss_med_GB |   maxrss_max_GB |   core_h |
|:---------------------------------|----:|:------------|-------:|---------:|------------:|------------------:|------------------:|---------------:|----------:|----------------:|----------------:|---------:|
| segment                          | 832 | fat_rome    |     32 |       16 |         360 |             77.05 |            185.72 |         104.63 |      0.95 |            3.83 |            4.16 | 35689.3  |
| stitch                           | 888 | fat_rome    |     32 |       64 |          60 |              1.83 |              5.3  |          96.95 |      0.48 |            6.94 |           14.09 |   876.33 |
| make_graph                       |  55 | fat_rome    |     16 |       64 |         720 |             12.37 |             33.17 |          46.8  |      0.06 |           11.37 |           24.31 |   189.54 |
| correct_tile_layout_from_content | 405 | fat_rome    |     16 |       64 |          60 |              1.58 |              2.57 |          44.2  |      0.08 |            0.48 |            0.58 |   168.39 |
| skeletonize_segmentations        | 279 | fat_rome    |     16 |       64 |          60 |              1.55 |              2.45 |          44.88 |      0.13 |            9.01 |           13.81 |   114.09 |
| bridge_graph_on_evidence         |  23 | fat_rome    |     16 |       64 |          60 |              5.6  |             45.23 |          42.83 |      0.06 |            2    |            6.62 |    79.97 |
| detect_spores                    | 171 | fat_rome    |     16 |       64 |          60 |              1.33 |              1.87 |          44.8  |      0.16 |            0.43 |            0.57 |    60.87 |
| mask                             |  86 | fat_rome    |     16 |       64 |          60 |              1.58 |              1.83 |          42.72 |      0.05 |            4.22 |            4.29 |    36.23 |
| focus_gate                       | 641 | staging     |      1 |        4 |          10 |              0.42 |              5.3  |           0.95 |      0.24 |            0    |            0    |     7.1  |
| extract_edge_widths              |   2 | fat_rome    |     16 |       64 |         360 |              6.74 |             10.83 |          42.6  |      0.48 |            8.56 |           10.88 |     3.6  |
| save_graph                       |   1 | fat_rome    |     16 |       64 |          60 |              4.72 |              4.72 |          35.33 |      0.06 |            5.97 |            5.97 |     1.26 |
| bridge_graph_on_spores           |  11 | staging     |      1 |       64 |          10 |              0.42 |              0.7  |           0.7  |      0.22 |            0    |            0    |     0.08 |
| frame_report                     |   1 | staging     |      1 |        8 |          30 |              2.25 |              2.25 |           0.25 |      0.79 |            1.73 |            1.73 |     0.04 |
| upload_graph                     |   1 | staging     |      1 |        4 |         360 |              0.75 |              0.75 |           0.6  |      0.16 |            0    |            0    |     0.01 |

Currently RUNNING: 115 jobs = 3392 cores on fat_rome (95 segment × 32). fat_rome overall: 9072/9216 cores allocated, 0 idle nodes — tshimizu holds 37 % of the partition. All PENDING rule jobs say `Resources`.

## Versions — verdict: no mixing, nothing new reached these runs

- Controllers parsed the Snakefile at 17:34–20:49 on 28 Oct, with orchestrator at **558bb2d** (reflog: HEAD 558bb2d from 20 Oct 09:34 until the pull to **c03c927** = #239 merge at 29 Oct 11:02:44).
- `git diff 558bb2d c03c927` = README, poetry.lock (sthype only), and comment-only edits in `rules/flows.smk`, `rules/restitch.smk`. No behavioural change in any rule or script that spatial_graph runs.
- Venv (`~/.cache/pypoetry/virtualenvs/orchestrator-reBytX-n-py3.11`, orchestrator itself via `.pth` → repo): only **sthype** changed (a0c5e5e → 4907a36, installed 29 Oct 11:02:55). amftrack d2ae13a (20 Oct), pipeline_steps 0180b7a (13 Oct), amf_temporal_registration c02b129 (13 Oct), segmenter 49a145b, flow_analysis_comps 3753395 — all unchanged for the whole run.
- spatial_graph rules call only `amftrack.scripts.image_processing.*` / `quality_report.*` + `orchestrator.transfer` (processes_config.py:87–142). sthype is used only by the temporal_graph steps (processes_config.py:147–180), and neither amftrack nor pipeline_steps imports sthype. So rule jobs started before and after 11:02 ran identical step code.
- "Improved steps" relevant to these runs (amftrack #268 thinning/width speed-ups, #264, pipeline-steps #56 Sobel default) were already installed on 20/13 Oct — **all 9 plates run them end to end**. The #239 sthype improvements (rotation-swept registration, misregistered-frame gating) are NOT exercised here; they apply when temporal_graph runs on these plates later.
- No in-job `sthype.__file__`/version print exists in the rule logs; the verdict rests on reflog + dist-info mtimes + the import graph.

## Failures

| plate | rule | n | cause |
|---|---|---|---|
| SCP2601A335 | stitch (4 attempts: 20260326_190554_tax ×3, 20260330_140552_duu ×1) | 4 FAILED | `zlib.error: Error -3 … incorrect data check` reading raw tiles — **corrupt raw TIFF** |
| SCP2601A335 | segment 20260326_190554_tax | 1 FAILED | `ZIPDecode: Decoding error … Img_r03_c11.tif` → `OSError: decoder error -2` — same corrupt tile, after 10 min of work |
| SCP2604A420 | bridge_graph_on_evidence (20260530_012243_vdh, 20260531_032244_imx ×2, 20260601_092244_ivf ×2) | 5 TIMEOUT | 60-min `runtime` limit. Elapsed climbs with timepoint (336 s → 725 → 1796 → 2509 → >3600 s; MaxRSS 2 → 7.7 GB) as the network grows. Deterministic, so the 3 Snakemake retries just burn another hour each; later frames will all hit it. |

Corrupt-tile timepoints will fail all 4 attempts and leave their downstream unbuilt (keep-going is on, so the rest of the plate continues).

## Staging jobs that are not transfers
- `focus_gate` — 641 jobs, 1 CPU, median 25 s, but p90 queue wait 58 min (staging = 10 nodes, shared with the 9 controllers).
- `bridge_graph_on_spores` — 11 no-op jobs (`_BRIDGE_SPORES` off), the known `"staging" if not _BRIDGE_SPORES` default.
- `frame_report` (1). Controllers themselves on staging are fine (single long-lived job each).

## Bottlenecks / recommendations
1. **Segmentation is the run.** 96 % of core-hours (35.7k of 37.2k), 77 min/timepoint at 32 cores, 95 % CPU-efficient — genuinely compute-bound and well sized (3.8 GB used of 16 GB). Queue wait median 105 min because fat_rome is full. Only real lever: GPU segmentation (tshimizu has no GPU budget; would need svstaalduine1 / EINF-18127) or the coming new segmentation model. Nothing to tune in the request itself.
2. **bridge_graph_on_evidence runtime=60 is too short for late frames** (SCP420 now; the other plates will hit it when they reach late timepoints). Raise `--config bridge_runtime=` (e.g. 240) on the next submit; it's single-threaded (6 % of 16 cores) so `bridge_cpus` could drop, but memory 64 G is a fair margin over 8 GB.
3. **SCP2601A335 has corrupt raw tiles** in 20260326_190554_tax (Img_r03_c11.tif) and 20260330_140552_duu — re-download those two timepoints from the archive (or exclude them); retries cannot fix it.
4. **Light steps over-request and wait ~45 min each in the queue for 1–2 min of work.** correct_tile_layout / detect_spores / mask / skeletonize / bridge: 16 CPUs × 64 GB, CPU eff 5–16 %, MaxRSS ≤ 14 GB. Cost is not the issue, but on a full partition each frame pays ~45 min queue per step × ~7 serial steps ≈ 5 h of pure waiting per frame. Not fixable by shrinking (fat_rome floor is 16 cores / 120 GB anyway); fixable by fusing the cheap per-frame chain into one job (group/`localrule`-style) — worth an orchestrator issue. stitch at 32 CPUs (48 % eff, 2 min) also queues 97 min.
5. **Move `focus_gate` and `bridge_graph_on_spores` off staging** (`--config spore_bridge_partition=fat_rome`; `focus_gate` in rules/restitch.smk:75 declares no resources, so it inherits the profile default `slurm_partition: staging`). Today the impact is small (p90 58 min wait), but it scales with fan-out.
