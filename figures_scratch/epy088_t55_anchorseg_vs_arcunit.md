# EPY2412A088 t55: anchor-seg (registrator) vs arc-unit (GrAMF v0.1.1)

Sources (read-only):
- anchor-seg: `/Users/simonvanstaalduine/AMOLF-SHIMIZU Dropbox/DATA/SimonDataBank/paper_plates/EPY2412A088_t55/stg_store.h5` (published /flow_measurements from the registrator)
- arc-unit: `/Users/simonvanstaalduine/AMOLF-SHIMIZU Dropbox/DATA/SimonDataBank/paper_plates/EPY2412A088_t55_arc2110/stg_store.h5` (published /flow_measurements from GrAMF, 22 Oct 15:30; roots/trail from `annotations.simonvanstaalduine.h5`)

## 1. Coverage
| | anchor-seg | arc-unit |
|---|---|---|
| runs in flow_runs | 40 | 40 |
| rows in flow_measurements | 184 | 240 |
| video edges mapped (run, undirected key) | 92 | 110 |
| STG edges per video edge, median (max) | 1 (1) | 1 (2) |

Video edges in both: 90; only anchor-seg: 2; only arc-unit: 20.
Runs only in anchor-seg: none; only in arc-unit: none.

Video edges only anchor-seg: `x_n0_57_y_n6_197/20250124_163542` (1, 2, 0), `x_n0_57_y_n6_197/20250124_163556` (1, 2, 0)

Video edges only arc-unit: `x_0_372_y_n7_016/20250124_163428` (0, 3, 0), `x_0_372_y_n7_016/20250124_163502` (0, 1, 0), `x_0_372_y_n7_016/20250124_163502` (0, 3, 0), `x_0_65_y_n7_425/20250124_163310` (3, 4, 0), `x_2_475_y_n9_381/20250124_163105` (1, 7, 0), `x_2_475_y_n9_381/20250124_163105` (2, 3, 0), `x_2_475_y_n9_381/20250124_163120` (1, 4, 0), `x_2_475_y_n9_381/20250124_163120` (1, 7, 0), `x_2_475_y_n9_381/20250124_163120` (2, 3, 0), `x_2_475_y_n9_381/20250124_163120` (3, 4, 0), `x_4_135_y_n10_398/20250124_162841` (2, 3, 0), `x_4_135_y_n10_398/20250124_162855` (2, 3, 0), `x_4_872_y_n10_777/20250124_162656` (0, 1, 0), `x_4_872_y_n10_777/20250124_162710` (0, 1, 0), `x_5_436_y_n11_045/20250124_162551` (2, 3, 0), `x_5_436_y_n11_045/20250124_162551` (4, 5, 0), `x_5_436_y_n11_045/20250124_162605` (2, 3, 0), `x_5_436_y_n11_045/20250124_162605` (4, 5, 0), `x_n0_57_y_n6_197/20250124_163542` (0, 3, 0), `x_n0_57_y_n6_197/20250124_163556` (0, 3, 0)

## 2. Location agreement (same run + video edge)
Distance between placements (µm), n=90: median 75.8, p90 130.9, max 291.3.
> 50 µm apart: 71
- `x_5_825_y_n11_27/20250124_162512` video edge (0, 1, 0): 291 µm (anchor-seg segs [22332]..., arc-unit edges [3105, 3106])
- `x_5_825_y_n11_27/20250124_162454` video edge (0, 1, 0): 291 µm (anchor-seg segs [22332]..., arc-unit edges [3105, 3106])
- `x_n2_545_y_n2_076/20250124_164144` video edge (0, 1, 0): 197 µm (anchor-seg segs [16585]..., arc-unit edges [2209])
- `x_n2_545_y_n2_076/20250124_164159` video edge (0, 1, 0): 197 µm (anchor-seg segs [16585]..., arc-unit edges [2209])
- `x_4_135_y_n10_398/20250124_162855` video edge (0, 1, 0): 191 µm (anchor-seg segs [21997]..., arc-unit edges [2948])
- `x_0_372_y_n7_016/20250124_163428` video edge (0, 1, 0): 189 µm (anchor-seg segs [19372]..., arc-unit edges [2610])
- `x_4_135_y_n10_398/20250124_162841` video edge (0, 1, 0): 188 µm (anchor-seg segs [21997]..., arc-unit edges [2948])
- `x_0_65_y_n7_425/20250124_163256` video edge (4, 5, 0): 188 µm (anchor-seg segs [19738]..., arc-unit edges [2608])
- `x_0_65_y_n7_425/20250124_163310` video edge (4, 5, 0): 188 µm (anchor-seg segs [19738]..., arc-unit edges [2608])
- `x_n1_521_y_n4_64/20250124_163747` video edge (1, 3, 0): 125 µm (anchor-seg segs [17288]..., arc-unit edges [2360])
- `x_n1_521_y_n4_64/20250124_163727` video edge (1, 3, 0): 125 µm (anchor-seg segs [17288]..., arc-unit edges [2360])
- `x_4_872_y_n10_777/20250124_162710` video edge (2, 3, 0): 124 µm (anchor-seg segs [22267]..., arc-unit edges [2976])
- `x_0_372_y_n7_016/20250124_163502` video edge (0, 2, 0): 123 µm (anchor-seg segs [19372]..., arc-unit edges [2610])
- `x_n2_462_y_n2_732/20250124_164116` video edge (1, 3, 0): 114 µm (anchor-seg segs [15756]..., arc-unit edges [2254])
- `x_n2_462_y_n2_732/20250124_164058` video edge (1, 3, 0): 114 µm (anchor-seg segs [15756]..., arc-unit edges [2254])
- `x_4_872_y_n10_777/20250124_162656` video edge (2, 3, 0): 112 µm (anchor-seg segs [22267]..., arc-unit edges [2976])
- `x_5_436_y_n11_045/20250124_162551` video edge (0, 2, 0): 101 µm (anchor-seg segs [22319]..., arc-unit edges [3036])
- `x_5_436_y_n11_045/20250124_162605` video edge (0, 2, 0): 101 µm (anchor-seg segs [22319]..., arc-unit edges [3036])
- `x_7_424_y_n12_306/20250124_162135` video edge (0, 1, 0): 100 µm (anchor-seg segs [23817]..., arc-unit edges [3211])
- `x_7_424_y_n12_306/20250124_162228` video edge (0, 1, 0): 100 µm (anchor-seg segs [23817]..., arc-unit edges [3211])
- `x_n2_361_y_n3_245/20250124_164032` video edge (1, 3, 0): 98 µm (anchor-seg segs [15745]..., arc-unit edges [2253])
- `x_n2_361_y_n3_245/20250124_164017` video edge (1, 3, 0): 96 µm (anchor-seg segs [15745]..., arc-unit edges [2253])
- `x_n0_805_y_n5_86/20250124_163626` video edge (1, 3, 0): 93 µm (anchor-seg segs [18307]..., arc-unit edges [2424])
- `x_n0_805_y_n5_86/20250124_163641` video edge (1, 3, 0): 93 µm (anchor-seg segs [18307]..., arc-unit edges [2424])
- `x_n2_361_y_n3_245/20250124_164017` video edge (0, 1, 0): 92 µm (anchor-seg segs [16835]..., arc-unit edges [2259])
- `x_n2_361_y_n3_245/20250124_164032` video edge (0, 1, 0): 92 µm (anchor-seg segs [16835]..., arc-unit edges [2259])
- `x_3_039_y_n9_844/20250124_162934` video edge (1, 3, 0): 89 µm (anchor-seg segs [21516]..., arc-unit edges [2886, 2903])
- `x_3_039_y_n9_844/20250124_162948` video edge (1, 3, 0): 89 µm (anchor-seg segs [21516]..., arc-unit edges [2886, 2903])
- `x_1_143_y_n8_019/20250124_163210` video edge (0, 1, 0): 87 µm (anchor-seg segs [19937]..., arc-unit edges [2704])
- `x_1_143_y_n8_019/20250124_163225` video edge (0, 1, 0): 87 µm (anchor-seg segs [19937]..., arc-unit edges [2704])
- `x_2_475_y_n9_381/20250124_163120` video edge (0, 1, 0): 86 µm (anchor-seg segs [21497]..., arc-unit edges [2882])
- `x_2_475_y_n9_381/20250124_163105` video edge (0, 1, 0): 85 µm (anchor-seg segs [21497]..., arc-unit edges [2882])
- `x_3_039_y_n9_844/20250124_162934` video edge (0, 1, 0): 85 µm (anchor-seg segs [21668]..., arc-unit edges [2907])
- `x_3_039_y_n9_844/20250124_162948` video edge (0, 1, 0): 85 µm (anchor-seg segs [21668]..., arc-unit edges [2907])
- `x_n1_234_y_n5_192/20250124_163828` video edge (0, 2, 0): 83 µm (anchor-seg segs [18314]..., arc-unit edges [2425])
- `x_n1_234_y_n5_192/20250124_163842` video edge (0, 2, 0): 83 µm (anchor-seg segs [18314]..., arc-unit edges [2425])
- `x_n1_839_y_n4_055/20250124_163920` video edge (4, 5, 0): 83 µm (anchor-seg segs [16887]..., arc-unit edges [2310])
- `x_n1_839_y_n4_055/20250124_163934` video edge (4, 5, 0): 83 µm (anchor-seg segs [16887]..., arc-unit edges [2310])
- `x_3_776_y_n10_162/20250124_162757` video edge (0, 3, 0): 81 µm (anchor-seg segs [21931]..., arc-unit edges [2945])
- `x_3_776_y_n10_162/20250124_162812` video edge (0, 3, 0): 80 µm (anchor-seg segs [21931]..., arc-unit edges [2945])
- `x_5_436_y_n11_045/20250124_162605` video edge (3, 4, 0): 79 µm (anchor-seg segs [22294]..., arc-unit edges [2976])
- `x_7_424_y_n12_306/20250124_162228` video edge (1, 3, 0): 78 µm (anchor-seg segs [23783]..., arc-unit edges [3203])
- `x_7_424_y_n12_306/20250124_162135` video edge (1, 3, 0): 77 µm (anchor-seg segs [23783]..., arc-unit edges [3203])
- `x_6_327_y_n11_546/20250124_162402` video edge (0, 1, 0): 77 µm (anchor-seg segs [23035]..., arc-unit edges [3106, 3152])
- `x_5_436_y_n11_045/20250124_162551` video edge (1, 2, 0): 76 µm (anchor-seg segs [22296]..., arc-unit edges [3038])
- `x_5_436_y_n11_045/20250124_162605` video edge (1, 2, 0): 76 µm (anchor-seg segs [22296]..., arc-unit edges [3038])
- `x_n0_805_y_n5_86/20250124_163626` video edge (0, 1, 0): 75 µm (anchor-seg segs [18275]..., arc-unit edges [2434])
- `x_n0_805_y_n5_86/20250124_163641` video edge (0, 1, 0): 75 µm (anchor-seg segs [18275]..., arc-unit edges [2434])
- `x_6_327_y_n11_546/20250124_162418` video edge (0, 1, 0): 73 µm (anchor-seg segs [23035]..., arc-unit edges [3106, 3152])
- `x_3_776_y_n10_162/20250124_162757` video edge (0, 1, 0): 70 µm (anchor-seg segs [21936]..., arc-unit edges [2948])
- `x_3_776_y_n10_162/20250124_162812` video edge (0, 1, 0): 70 µm (anchor-seg segs [21936]..., arc-unit edges [2948])
- `x_6_327_y_n11_546/20250124_162402` video edge (2, 3, 0): 70 µm (anchor-seg segs [23030]..., arc-unit edges [3106])
- `x_6_327_y_n11_546/20250124_162418` video edge (2, 3, 0): 66 µm (anchor-seg segs [23030]..., arc-unit edges [3106])
- `x_3_039_y_n9_844/20250124_162934` video edge (1, 2, 0): 65 µm (anchor-seg segs [21614]..., arc-unit edges [2908])
- `x_3_039_y_n9_844/20250124_162948` video edge (1, 2, 0): 65 µm (anchor-seg segs [21614]..., arc-unit edges [2908])
- `x_0_65_y_n7_425/20250124_163256` video edge (1, 3, 0): 64 µm (anchor-seg segs [18784]..., arc-unit edges [2620])
- `x_0_65_y_n7_425/20250124_163310` video edge (1, 3, 0): 64 µm (anchor-seg segs [18784]..., arc-unit edges [2620])
- `x_3_776_y_n10_162/20250124_162757` video edge (0, 2, 0): 64 µm (anchor-seg segs [21937]..., arc-unit edges [2949])
- `x_n1_839_y_n4_055/20250124_163934` video edge (2, 3, 0): 64 µm (anchor-seg segs [16892]..., arc-unit edges [2359])
- `x_n1_839_y_n4_055/20250124_163920` video edge (2, 3, 0): 64 µm (anchor-seg segs [16892]..., arc-unit edges [2359])
- `x_3_776_y_n10_162/20250124_162812` video edge (0, 2, 0): 63 µm (anchor-seg segs [21937]..., arc-unit edges [2949])
- `x_7_424_y_n12_306/20250124_162228` video edge (1, 2, 0): 62 µm (anchor-seg segs [23789]..., arc-unit edges [3212])
- `x_7_424_y_n12_306/20250124_162135` video edge (1, 2, 0): 62 µm (anchor-seg segs [23789]..., arc-unit edges [3212])
- `x_5_436_y_n11_045/20250124_162551` video edge (3, 4, 0): 59 µm (anchor-seg segs [22290]..., arc-unit edges [2976])
- `x_n0_805_y_n5_86/20250124_163626` video edge (1, 2, 0): 56 µm (anchor-seg segs [18281]..., arc-unit edges [2448])
- `x_n0_805_y_n5_86/20250124_163641` video edge (1, 2, 0): 56 µm (anchor-seg segs [18281]..., arc-unit edges [2448])
- `x_n2_361_y_n3_245/20250124_164032` video edge (1, 2, 0): 55 µm (anchor-seg segs [15751]..., arc-unit edges [2269])
- `x_2_475_y_n9_381/20250124_163120` video edge (3, 5, 0): 55 µm (anchor-seg segs [21428]..., arc-unit edges [2886])
- `x_n2_361_y_n3_245/20250124_164017` video edge (1, 2, 0): 55 µm (anchor-seg segs [15751]..., arc-unit edges [2253, 2269])
- `x_n2_462_y_n2_732/20250124_164058` video edge (0, 1, 0): 53 µm (anchor-seg segs [15117]..., arc-unit edges [2086])
- `x_n2_462_y_n2_732/20250124_164116` video edge (0, 1, 0): 53 µm (anchor-seg segs [15117]..., arc-unit edges [2086])

## 3. Localisation precision (length the measurement is assigned to, µm)
| | median | p90 |
|---|---|---|
| anchor-seg: total length of mapped segments | 34 | 34 |
| arc-unit: span (s_end − s_start) | 109 | 168 |
| arc-unit: full length of the edge(s) carrying it | 613 | 1138 |

## 4. Flow values (same polyflow input)
Directed video flows in both: 180 (anchor-seg 184, arc-unit 220).
- median speed: max |Δ| = 0.00e+00 µm/s; flux: max |Δ| = 0.00e+00. Values are copied verbatim from polyflow in both.
- spatial flow direction (cos between the two placements' flow vectors): agree (cos>0.5) 180, opposite (cos<-0.5) 0, ambiguous 0.
- perc_25/perc_75 swapped in the anchor-seg store relative to GrAMF in 89 rows (registrator writes them in the video's own order; GrAMF sorts them). flux_ratio is NaN in anchor-seg, filled in arc-unit.

## 5. Width at the measurement (edge_width_segments, µm)
n=90: Pearson r = 0.99, median |Δ| = 0.02, median (arc-unit − anchor-seg) = +0.00.
Median width: anchor-seg 10.25, arc-unit 10.25. Arc-unit width rows: 5552 for 5553 arcs (one pooled value per arc), so its width is the whole-arc mean, not local.

## 6. Timing: t_first (timepoint index; 56 timepoints)
Exact agreement 68% (median over mapped segments) / 68% (earliest mapped segment); median |Δ| 0, max |Δ| 2 timepoints; arc-unit earlier in 29, later in 0.
(Timepoints span 111 h; median spacing 2.0 h.)

## 7. Roots and trail
- roots: anchor-seg 16, arc-unit 20; shared node ids 6.
- trail: anchor-seg `Main` 636 nodes; arc-unit `trail 1` 53 nodes (5 waypoints). Starts: 2533 (root: True) vs 2533 (root: True); ends 3949 vs 3880.
- trail length: anchor-seg 21362 µm, arc-unit 20215 µm.
- measurements within 25 µm of both trails: 62; Δ(distance from trail start) anchor-seg − arc-unit: median +192 µm, median |Δ| 192, max |Δ| 459 µm.

## 8. Graph totals
| | anchor-seg | arc-unit |
|---|---|---|
| edges | 37656 | 5553 |
| nodes | 36765 | 4616 |
| total length (mm) | 1203.6 | 1204.1 |
| median edge length (µm) | 33 | 152 |
| timepoints | 56 | 56 |
| file size (MB) | 65.7 | 18.5 (+ 69 kB annotations) |
