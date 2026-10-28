// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// ---------------------------------------------------------------------------

#set document(
  title: "Flow structure across a hypha — no centred backflow core; counter-flows sit toward opposite sides",
  author: "transport_paper investigation",
)
#set page(
  paper: "a4",
  margin: (x: 2.2cm, y: 2.4cm),
  numbering: "1",
  footer: context [
    #set text(8pt, fill: luma(120))
    #h(1fr) #counter(page).display("1")
  ],
)
#set text(font: ("Helvetica Neue", "Helvetica", "Arial"), size: 10pt, lang: "en")
#set par(justify: true, leading: 0.62em)
#set math.equation(numbering: "(1)")
#set heading(numbering: (..n) => if n.pos().len() < 4 { numbering("1.1", ..n) })
#set ref(supplement: it => if it.func() == figure { it.supplement } else if it.func() == math.equation { "Equation" } else { "Section" })
#show heading.where(level: 1): it => block(above: 2.4em, below: 0.9em, width: 100%)[
  #set text(16pt, weight: 700)
  #it
  #v(-0.55em)
  #line(length: 100%, stroke: 0.6pt + luma(180))
]
#show heading.where(level: 2): set text(12pt, weight: 600)
#show heading.where(level: 2): set block(above: 1.9em, below: 0.7em)
#show heading.where(level: 3): set text(10.5pt, weight: 600, style: "italic")
#show heading.where(level: 3): set block(above: 1.5em, below: 0.55em)
#show heading.where(level: 4): it => box(text(10pt, weight: 700)[#it.body#h(0.5em)])
#show raw: set text(font: "Menlo", size: 8.5pt)
#show link: set text(fill: rgb("#8a5a10"))
#show table: it => { set par(justify: false); it }

#let dead = box(fill: rgb("#f6dedb"), inset: (x: 4pt, y: 1pt), radius: 2pt,
  text(8pt, fill: rgb("#8a2f22"), weight: 600, "DEAD"))
#let open = box(fill: rgb("#eceff0"), inset: (x: 4pt, y: 1pt), radius: 2pt,
  text(8pt, fill: rgb("#4a5459"), weight: 600, "OPEN"))

#let fig(path, cap, src: none, width: 94%) = figure(
  image(path, width: width),
  caption: text(8.5pt, fill: luma(95))[
    #cap
    #if src != none [ #text(fill: luma(140))[#raw(src)]]
  ],
)
#show figure.caption: set align(left)
#show figure.caption: set par(justify: false)
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Flow structure across a hypha]
  #v(-0.3em)
  #text(19pt, weight: 700)[no centred backflow core; counter-flows sit toward opposite sides]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · seven imaging sessions on four plates of #emph[Rhizophagus irregularis] · 189 fluorescence
    and 262 of 263 brightfield videos · \@2c2ded5
  ]
]
#v(1.2em)

= Introduction

#question[In a hypha carrying material toward the tip and back toward the colony at the same time, do the two streams sit as a central backflow core inside a tipward wall layer — the Poiseuille picture the backflow model is built on — or side by side, and can the model drop that picture?]

The plates are colonies of #emph[Rhizophagus irregularis] imaged over days; a session is one
plate's round of videos between two imaging timepoints. Each timepoint is
stitched, segmented and turned into a network graph, and the graphs over time are joined into one
spatio-temporal graph whose edges carry the time they appeared. Between timepoints, short videos
at many stage positions record the flow inside the hyphae: brightfield videos show everything
that moves, fluorescence videos show only the labelled lipids. The flow pipeline draws a
kymograph along each hypha in the video, reads the speed of moving texture in both directions,
and stores one median speed per direction per edge. Orienting every edge by the growth
directed acyclic graph (DAG) says which of the two directions runs with growth.

Those stored medians average over the whole width of the hypha. This document splits that width
into narrow strips and asks where across the hypha each direction runs, and how fast it runs
there. The answer decides whether the backflow model's picture of the cross-section, a tipward
lipid layer along the wall around a backflow core with a parabolic velocity profile, describes
the hyphae at all.

= Motivation

The backflow model of the transport_paper repository, as its overview document describes it,
places the lipid stream in an outer annulus moving tipward at a motor speed $v_0$, and returns
the displaced fluid through a central core of radius $a$ — the same core-and-return-flow geometry
as the pollen-tube reverse fountain @heplerPollenTubeClear2015 and the wall-driven-stream theory of
@htetAnalyticalMethodsCytoplasmic2025. #link("throttled_core_speed_model.typ")[The model's own
derivation] gives the core radius from demand,
$a^2 = b^2 - Q_"lipid" slash (theta v_0 pi)$ for a hypha of radius $b$, and a second hydraulic
solve through that core gives a parabolic backflow profile with a centre-line maximum.
#link("backflow_model_accuracy.typ")[Model-versus-measurement comparisons] then compare speeds
through the convention "backflow $= 2 slash 3$ of the
centre-line maximum", which reads the flow as one Poiseuille profile that crosses zero: the wall
moves tipward at $v_0$ and the opposite direction peaks at the centre.

Three things rest on that picture. The model's backflow velocity formula is a Poiseuille profile
through the core. Every model-versus-measurement comparison in the trail and width figures uses
the $2 slash 3$ factor. And the two-channel measurement of the core fraction $a slash b$ in
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[the annulus-geometry findings] reads a
speed ratio as a radius, with a profile
factor derived from a parabolic core. If the two streams do not sit as core and annulus, those
radii describe no structure in the hypha, the $2 slash 3$ factor corrects for a profile that is
not there, and the geometry terms can go.

The picture is also testable without the model. A centred core predicts that the against-growth
direction is concentrated, and fastest, at the centre of the hypha. Side-by-side streams predict
that each direction is concentrated toward one side and moves at a speed that does not depend on
where across the hypha it is read.

= Method <sec-method>

== A centred core and side-by-side lanes predict opposite profiles across the width <sec-pictures>

The first picture is the model's. In a circular lumen of radius 1, a single Poiseuille profile
that crosses zero is
$ u(rho) = -V_"max" + (v_0 + V_"max") rho^2 $ <eq-poiseuille>
with growth-direction flow positive. The flow runs against growth inside the radius
$rho_0 = sqrt(V_"max" slash (v_0 + V_"max"))$ and with growth outside it. In the Poiseuille
reading of the two channels, $rho_0$ is the core fraction $a slash b$. The against-growth speed is
$V_"max"$ on the axis and falls to zero at $rho_0$.

The second picture has the two directions in parallel lanes: each occupies part of the lumen
toward one side, and each moves at roughly its own constant speed, a plug — the same flat,
partial plug-flow profile measured directly in Neurospora hyphae @abadehMassFlowVelocity2013.

Both are compared on strips that run along the hypha, parallel to its centreline, each at a fixed
offset across the width. A side is one side of the centreline in the image, fixed per edge by the
direction the centreline was traced; it is not tied to growth, so it is compared between pieces of
the same edge and between channels on the same centreline, never between edges.

A widefield camera does not see the cross-section. A strip at lateral offset $y$ from the centre
records every depth of the lumen along its line of sight, so a centred core is seen through the
tipward layer above and below it. To keep that from hiding a core, the Poiseuille picture is
projected before it is compared (`radial_poiseuille_projection.py`). For each $y$ the projection
takes all voxels of the chord, and reports the share of voxels moving against growth and the
median $|u|$ of each direction divided by that direction's median over the whole width. The
projection is generous to the core picture: it has no optical blur, uniform tracer density, and a
voxel median in place of a texture estimate.

#figure(kind: table, table(
  columns: 5, align: (left, right, right, right, right), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*$rho_0$*], [*against growth, centre / wall speed*], [*growth direction, centre / wall speed*],
  [*against-growth share, centre*], [*against-growth share, walls*],
  table.hline(stroke: 0.4pt),
  [0.6], [no against-growth voxels at the walls], [0.75], [0.58], [0.00],
  [0.7], [6.75], [0.96], [0.69], [0.08],
  [0.8], [4.06], [1.07], [0.79], [0.25],
  [0.9], [3.15], [1.04], [0.90], [0.52],
  [0.95], [2.90], [1.02], [0.95], [0.71],
  table.hline(stroke: 0.6pt),
), caption: text(8.5pt, fill: luma(95))[
  What a widefield strip sees of @eq-poiseuille. Centre: $|y| <= 0.3$; walls: $0.6 <= |y| <= 1$, the
  same regions used on the measured profiles in @sec-read. Speeds are medians per strip over the
  whole-width median of that direction. #text(fill: luma(140))[`radial_poiseuille_projection.py`]
]) <tab-projection>

For every $rho_0$ up to 0.95 the projected core still reads at least 2.9 times faster at the
centre than at the walls, or is absent from the walls altogether. Projection does not flatten it.

== Speeds are read in 0.69 µm strips running along the hypha at 13 offsets <sec-bands>

Every video in this document has a pixel size of 0.138 µm (50× objective, binning 2). For each
edge in a video's extraction graph, `snellius/radial_flow.py` repeats the pipeline's measurement
on two kinds of band along the edge's centreline:

- the full band, 75 px wide (10.2 µm), which is what the pipeline itself measures;
- thirteen offset bands, 5 px wide (0.69 µm), centred every 6 px (0.83 µm) from −36 to +36 px
  (±4.97 µm) across the centreline.

Each band is sampled from the video frames, normalised as the pipeline normalises a kymograph,
and passed through the pipeline's multi-orientation analysis, which keeps the three strongest
texture orientations at every kymograph pixel and filters them with the run's own thresholds.
Speed is $tan("angle") dot Delta x slash Delta t$. Positive speeds run along the centreline from
its first node to its second. Per band the script records the number of positive and negative
speed pixels ($n_+$, $n_-$), their medians, and the mean raw brightness. The band-pass centre of
a narrow band is fixed to its full band's value, because a 5 px strip carries too little texture
for the automatic estimate (@sec-deadends). The pixel counts are also stored separately for the
three thirds of the edge along its length and for the two halves of the video in time.

== A profile counts only when its whole-width speeds match the stored medians within 10 % <sec-validate>

A profile is one edge in one video. Three filters decide which profiles enter any result:

+ Validation. Both recomputed full-band medians lie within 10 % of the medians the pipeline stored
  for that edge. This holds for 510 of 580 fluorescence and 771 of 882 brightfield profiles.
+ Orientation to growth. Each stored measurement names its edge, its median and whether it runs
  along or against the growth DAG. Matching that median to the recomputed positive or negative
  median says whether positive runs with growth. Profiles whose matches all agree are kept:
  383 fluorescence and 549 brightfield.
+ Bidirectional. The less common direction carries at least 15 % of the full-band speed pixels.
  A single-direction profile has no counter-flow to place.

The growth-direction share $s_g$ of a band is the fraction of its speed pixels moving with growth.
It counts trackable texture, not volume: a stream without texture is invisible, and a stream with
dense texture weighs more than its volume. A region enters a result only with at least 30 speed
pixels.

== Offsets are re-centred on the hypha and scaled by its half-width <sec-read>

The pipeline's centreline need not sit on the middle of the hypha, so the offsets are re-centred
before regions are defined. Fluorescence profiles are centred on the brightness centroid of the
bands, with the half-width taken as the half width at half maximum. Brightfield hyphae have dark
walls, so brightfield profiles are centred on the midpoint of the two brightness minima between
1.5 and 5.5 µm on either side, with the half-width taken as half their separation. Half-widths are
clipped to 2–6 µm, which affects 15 % of fluorescence and 6 % of brightfield profiles. The median
half-width is 2.48 µm (interquartile range, IQR, 2.07–2.90) in fluorescence and 2.90 µm (IQR 2.48–3.31) in brightfield.
The scaled offset is $r = "offset" slash "half-width"$: 0 at the centre, ±1 at the walls.

Three regions follow: left wall $r <= -0.6$, centre $|r| <= 0.3$ and right wall $r >= 0.6$, all
within $|r| <= 1.15$. The wall asymmetry of a profile is
$d = s_g("right wall") - s_g("left wall")$.

=== Six patterns of where the growth-direction share is higher: one wall, ramp, opposite wall, both walls, centre, flat

Comparing each wall's growth-direction share with the centre's, with a fixed threshold of 0.15,
gives six patterns:

#table(
  columns: 2, align: (left, left), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*pattern*], [*growth-direction share*],
  table.hline(stroke: 0.4pt),
  [both walls], [both walls exceed the centre: the annulus picture],
  [one wall], [one wall exceeds the centre, the other matches it],
  [ramp], [one wall exceeds the centre, the other falls below it],
  [opposite wall], [one wall falls below the centre, the other matches it],
  [centre], [the centre exceeds both walls],
  [flat], [both walls match the centre],
  table.hline(stroke: 0.6pt),
)

The patterns are applied to fluorescence (`radial_lanes.py`), where the growth direction is the
lipid stream: the lipid side of an edge is the side where the fluorescence growth-direction share is
higher. "Matches" means within 0.15.

=== A quadratic fit gives a left-right and a wall-centre contrast with intervals

Independently of the regions, `radial_flow_curvefit.py` fits $s_g(r) = c + a r + b r^2$ to the
bands within $|r| <= 1$, weighted by pixel count, on the pipeline's own centreline. The coefficient
$b$ is the wall-minus-centre contrast and $2a$ the right-minus-left contrast. In fluorescence the
interval comes from fitting the three along-edge thirds separately (±2 standard errors). Of the 262
brightfield videos, 215 were analysed before piece counts existed, so their interval is a bootstrap
over offsets, which is narrower than it should be because neighbouring bands share texture. With an
effect size of 0.15 a profile is wall-enriched ($b >= 0.15$, interval above 0), centre-enriched
($b <= -0.15$, interval below 0), lanes ($|2a| >= 0.15$, interval excluding 0, $|2a| > |b|$), flat
(both below 0.15) or uncertain.

== Four tests: speed across the width, a projected core, side along the edge, side across channels <sec-tests>

+ Speed across the hypha (`radial_speed_profile.py`). For each direction, the median speed of every
  band with at least 30 pixels of that direction is divided by the direction's full-band median,
  so profiles of different speeds pool. Per profile the centre / wall ratio is the median over
  $|r| <= 0.3$ over the median over $0.6 <= |r| <= 1.15$. This establishes whether either stream is
  fastest at the centre, and is tested with a Wilcoxon signed-rank test on the log ratio.
+ The projection null (@sec-pictures). A flat measured speed could be optics. Comparing the measured
  share and speed profiles with the projected Poiseuille profile says whether a core would still
  have been seen.
+ Side consistency (`radial_side_consistency.py`, fluorescence). A one-sided pattern could be a
  noise draw. Computing $d$ separately on the first and last thirds of the edge, which do not
  touch, and on the two halves of the video, asks whether the sign survives. Noise keeps it half
  the time.
+ Cross-channel agreement (`radial_cross_channel.py`). A lane seen in lipids alone could be a
  property of the dye. Each fluorescence profile is paired with the brightfield profile of the same
  edge in the video filmed closest before it at the same position, and the signs of the two wall
  asymmetries are compared. Flat fluorescence profiles are the reference for what shared optics and
  position alone produce.

= Results <sec-results>

The results run from the structure the model assumes to the structure the data show: first
whether a centred core is present at all, then where the two directions are instead, then whether
that placement is stable along the hypha and seen in both channels.

== Neither channel shows a centred backflow core, even allowing for a projected view <sec-flat>

Read across the hypha, both the share and the speed of the against-growth direction are flat
(@fig-projection). Pooled over profiles, the median against-growth share per 0.25-wide offset bin
lies between 0.42 and 0.46 in brightfield and between 0.34 and 0.41 in fluorescence, from wall to
wall. Relative speeds stay near 1 at every offset in both channels, while the projected core puts
the against-growth direction at 0.58–0.95 of the centre and 0.00–0.71 of the walls, peaking in
speed at 1.5 times the whole-width median.

#fig("figures/radial_projection_vs_measured.png",
  [Against-growth share (a) and against-growth speed relative to the whole-width median (b), against
  the offset from the re-centred middle of the hypha scaled by its half-width. Blue: brightfield,
  466 bidirectional profiles; vermillion: fluorescence, 251 profiles with against-growth speed
  bands. Lines are medians over profiles of per-profile bin medians, shading the interquartile
  range. Dashed grey: the projected Poiseuille profile of @sec-pictures at $rho_0 = 0.6$, 0.8 and
  0.95, light to dark. Dotted lines mark the walls. Brightfield covers 262 of 263 videos.],
  src: "transport_paper/Working_notebooks/radial_writeup_figures.py") <fig-projection>

Per profile, the ratio of centre speed to wall speed is 1 to within 3 % in every channel and
direction (@tab-ratio).

#figure(kind: table, table(
  columns: 6, align: (left, left, right, right, right, right), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*channel*], [*direction*], [*profiles*], [*centre / wall speed, median (IQR)*], [*ratio above 1*], [*Wilcoxon p*],
  table.hline(stroke: 0.4pt),
  [brightfield], [against growth], [466], [1.01 (0.90–1.21)], [53 %], [0.057],
  [brightfield], [growth], [466], [1.02 (0.97–1.11)], [60 %], [1.9e−5],
  [fluorescence], [against growth], [210], [0.98 (0.85–1.19)], [45 %], [0.48],
  [fluorescence], [growth], [240], [0.97 (0.85–1.12)], [43 %], [0.086],
  table.hline(stroke: 0.6pt),
), caption: text(8.5pt, fill: luma(95))[
  Per-profile ratio of centre speed ($|r| <= 0.3$) to wall speed ($0.6 <= |r| <= 1.15$), each band
  speed relative to the full-band median of the same direction. Wilcoxon signed-rank test of the log
  ratio against 0. #text(fill: luma(140))[`radial_speed_profile.py`]
]) <tab-ratio>

The only ratio that differs from 1 at $p < 0.05$ is the brightfield growth direction, and it
differs by about 1 %. The core picture needs the against-growth ratio above 2.9 for every core
fraction (@tab-projection). A ratio of at least 2 occurs in 10.7 % of brightfield and 5.2 % of
fluorescence against-growth profiles, and in 7.9 % and 2.5 % of growth-direction profiles, where the
core picture predicts a ratio near 1. A tail of that size in the direction a core would not affect
means the against-growth tail is mostly the noise of the ratio; a small subset of cored hyphae
within it cannot be excluded at this resolution. Nor does the against-growth ratio exceed the growth-direction ratio within the same
profile: it does so in 46 % of 466 brightfield profiles (Wilcoxon p 0.249) and 51 % of 199
fluorescence profiles (p 0.76).

Two controls rule out the obvious ways a real peak could be flattened. A direction's speed could
be unreliable in bands where it is rare. Restricting both regions to bands where the direction
carries at least 30 % of pixels leaves the median ratios at 0.99 (358 profiles) and 1.01 (396) in
brightfield, and 1.00 (155) and 0.98 (218) in fluorescence. Speed does not follow share within a
profile either: the median per-profile Spearman correlation between a band's speed and that
direction's share is +0.13 for brightfield against growth, +0.26 for brightfield growth, +0.00 and
+0.10 in fluorescence. The brightfield against-growth share itself is no higher at the centre than
at the walls: the difference is −0.010 (IQR −0.095 to 0.069) over the 290 brightfield profiles of
@sec-cross.

The absolute speeds are unremarkable against this. In brightfield the full-band median is
2.82 µm/s with growth (IQR 2.09–3.14) and 2.92 µm/s against it (IQR 1.82–4.53), and the per-profile
ratio of against-growth to growth-direction speed is 1.22 (IQR 0.73–1.66, 466 profiles). In
fluorescence it is 0.91 (IQR 0.69–1.23, 247 profiles).

== The two directions concentrate toward opposite sides of the hypha in the image <sec-lanes>

Of 268 bidirectional oriented fluorescence profiles, 50 are one wall, 28 ramp and 58 opposite wall:
136 profiles with the growth direction concentrated toward one side or away from one side
(@fig-lanes). Flat profiles number 51. The annulus picture, both walls, accounts for 19, and centre
for 14; 48 have too few pixels in a region to classify.

#fig("figures/radial_lanes_patterns.png",
  [Growth-direction share in each band against the scaled offset from the brightness centroid, one
  line per fluorescence profile, grouped by wall pattern: (a) one wall, (b) ramp, (c) opposite
  wall, (d) both walls, (e) centre, (f) flat. One-wall and ramp profiles are mirrored so the
  high-share wall is on the right, opposite-wall profiles so the low-share wall is on the right.
  Dashed lines mark the region boundaries at $|r| = 0.3$ and $0.6$; the solid line is a share of 0.5.
  Bands with fewer than 30 speed pixels in one direction are drawn from the other direction's count.],
  src: "transport_paper/Working_notebooks/radial_writeup_figures.py") <fig-lanes>

The curve fit, which uses no regions and no re-centring, agrees. Of 225 bidirectional fluorescence
profiles fitted with intervals from the three edge thirds, 56 are lanes, 39 centre-enriched,
25 flat, 20 wall-enriched and 85 uncertain. The wall-minus-centre contrast $b$ has a median of
−0.03 and its interval lies above zero for 12 % of profiles, below zero for 19 %. The
right-minus-left contrast $|2a|$ has a median of 0.30 and its interval excludes zero for 39 %. In
brightfield, 466 profiles give 168 lanes, 95 flat, 94 uncertain, 55 centre-enriched and
54 wall-enriched, with $b$ at a median of +0.01 and $|2a|$ at 0.24, excluding zero for 53 %. The
brightfield intervals are bootstraps over offsets and too narrow (@sec-read), so its lanes count is
an upper bound.

A single video shows the same thing as the pooled profiles: the share of each direction changes
across the hypha while its speed stays level (@fig-examples).

#fig("figures/radial_speed_examples.png",
  [Single profiles, one per class, chosen as the profile with the most speed pixels in bands carrying
  both directions, from a different session where possible. Lines: band median speed in µm/s, blue
  with growth, vermillion against growth (left axis). Grey bars: against-growth share of the band
  (right axis). Brightfield classes are curve-fit classes: (a) lanes, PNF2307A072\_t37
  `x_n3_969_y_n7_18/20230810_140653` edge `2_3_0`; (b) centre-enriched, EPY2412A088\_t28
  `x_n1_676_y_n2_716/20250122_114220` edge `5_2_0`; (c) flat, EPY2412A088\_t55
  `x_n0_57_y_n6_197/20250124_163542` edge `2_1_0`. Fluorescence classes are wall patterns: (d) one wall,
  LPD2412A025\_t50 `x_8_582_y_n15_449/20250112_183224` edge `0_1_0`; (e) ramp, LPD2412A025\_t25
  `x_25_442_y_n3_774/20250110_162741` edge `0_1_0`; (f) both walls, EPY2412A088\_t55
  `x_n1_839_y_n4_055/20250124_163934` edge `2_3_0`. The growth-direction point at the left wall in (a)
  rests on a band where that direction is rare.],
  src: "transport_paper/Working_notebooks/radial_writeup_figures.py") <fig-examples>

Two mechanisms could manufacture one-sided patterns without a lane, and neither does. A centreline
off the middle of the hypha would tilt every profile. After re-centring, 32 of 46 one-wall and
33 of 51 opposite-wall profiles keep their pattern. The brightness centroid sits a median 0.37 µm
off the pipeline's centreline in one-wall and ramp profiles and 0.44 µm in the rest (Mann–Whitney
p 0.696). Faster flow on the outside of a bend would put the growth direction on one side of curved
edges. Among edges that turn by at least 0.3 rad, the high-share wall of one-wall profiles is on
the inside of the bend in 8 of 20 (binomial p 0.503), of ramps in 9 of 15 (p 0.607) and the
low-share wall of opposite-wall profiles in 10 of 24 (p 0.541).

== One-wall and ramp profiles keep their side from one end of the edge to the other <sec-side>

The sign of the wall asymmetry $d$, computed independently on the first and last thirds of the
edge, agrees in 81 % of one-wall profiles (30 of 37, binomial p < 0.001, Spearman correlation of
$d$ between the thirds +0.58) and 93 % of ramps (14 of 15, +0.75), against 55 % of flat profiles
(17 of 31, p 0.36, +0.07) (@fig-side, panel a). All three thirds agree for 83 % of 29 one-wall
profiles and 93 % of 14 ramps, against 38 % of 32 flat profiles, where noise gives 25 %.

#fig("figures/radial_side_and_cross_channel.png",
  [(a) Share of fluorescence profiles whose wall asymmetry keeps its sign between independent
  pieces, per wall pattern: light bars, first and second half of the video; dark bars, first and
  last third of the edge. (b) Share of fluorescence–brightfield pairs of the same edge in which the
  brightfield wall asymmetry has the sign of the fluorescence one, per fluorescence wall pattern.
  The dashed line is 0.5, the agreement of unrelated signs. Profile and pair counts per bar are in
  the text.],
  src: "transport_paper/Working_notebooks/radial_writeup_figures.py") <fig-side>

Opposite-wall profiles share it only weakly. Their thirds agree in 65 % (26 of 40, p 0.040, +0.27),
and all three thirds in 50 % of 38 — above chance, but far below the one-wall and ramp shares. The two halves of a video are a weaker test than the thirds
of an edge: they agree for 96 % of one-wall profiles (47 of 49) and 100 % of ramps (27 of 27), but
also for 73 % of flat profiles (36 of 49) and 93 % of opposite-wall profiles (53 of 57), so a
fixed per-position asymmetry already survives between halves.

== Brightfield growth-direction flow is on the lipid side in 85–88 % of one-sided pairs, 59 % of flat ones <sec-cross>

The 290 fluorescence profiles paired with a brightfield profile of the same edge span all seven
sessions; 250 pairs have a wall asymmetry in both channels. Brightfield carries the growth
direction toward the same wall in 87 % of pairs where fluorescence is one wall (39 of 45), 88 % of
ramps (22 of 25) and 85 % of opposite-wall pairs (44 of 52), each binomial p < 0.001, with
Spearman correlations of $d$ between the channels of +0.62, +0.76 and +0.77 (@fig-side, panel b).
Where fluorescence is both walls, centre or flat, agreement is 50 % (8 of 16), 55 % (6 of 11) and
59 % (55 of 93, p 0.048). Over the 176 pairs bidirectional in both channels, the Spearman
correlation of $d$ is +0.65.

= Discussion <sec-discussion>

Neither channel carries a centred backflow core. Across the hypha, the median centre / wall speed
ratio is 0.97–1.01 for both directions in both channels, and the brightfield against-growth share
is no higher at the centre than at the walls (@sec-flat). A Poiseuille profile crossing zero, seen
through a widefield camera with no blur at all, would read at least 2.9 times faster at the centre
for every core fraction up to 0.95, and would leave the walls without backflow at the 0.6 the
two-channel speed ratio implies (@tab-projection). Instead the two directions occupy different
sides: 136 of 268 fluorescence profiles concentrate the lipid stream toward or away from one wall,
20 look like an annulus (@sec-lanes). For one-wall and ramp profiles the side holds from one end of
the edge to the other in 82–93 % of cases (@sec-side), and brightfield leans to the same wall in
85–88 % of pairs (@sec-cross). The evidence is bounded by a widefield view, texture rather than
particle speeds, fixed class thresholds, and a brightfield set that is 262 of 263 videos.

== The model can drop its Poiseuille cross-section and keep its network <sec-simplify>

What the data remove is the model's picture of one cross-section: the lipid annulus of inner radius
$a$ set by demand, the parabolic backflow through that core with its centre-line maximum, and
everything that converts between a centre-line value and a measured median. That is the inner
radius $a$ and its demand relation, the maximum and average backflow speeds computed from the core,
the $2 slash 3$ comparator, the profile factor $k$ of the two-channel geometry, and the reading of
$a slash b$ as a core radius with a shell thickness around it. Each of these parameterises a
velocity profile that is centre-peaked, and across 466 brightfield and 210 fluorescence
against-growth profiles the centre is no faster than the walls (@tab-ratio).

Side-by-side plug streams need less. If the tipward stream moves at $v_"motor"$ through a fraction
$1 - f$ of the lumen and the return flow at $v_"back"$ through the fraction $f$, zero net flux gives
$ f = 1 / (1 + R), quad R = v_"back" / v_"motor" $ <eq-fraction>
which is the same algebra as $(a slash b)^2$ in
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[the annulus-geometry findings].
The two-channel speed ratio therefore survives unchanged, reinterpreted as the share of the lumen
carrying backflow, with no radius, no profile factor and no $2 slash 3$. The measured medians are
compared with the model directly. A plug in each lane is what the flat speeds in @fig-projection
show within this document's resolution. This two-lane picture is what
#link("lane_flux_balance.typ")[the lane flux-balance document] builds a local backflow model on,
and what #link("junction_flux_balance.typ")[the junction flux-balance document] tests where lanes
meet at a branch.

What this document does not test is equally specific. The network solve (the hydraulic conductance
per edge, the tip demands and root supply, and the split of demand at junctions) uses no
cross-section beyond the hypha's radius, and nothing here measures pressure or conductance.
Whether the return fraction $f$ is set by demand, as the core radius was, or is near constant, is
not measured here either; a simplified model has to choose, and that choice needs its own test
against the stored speeds. The zero-net-flux assumption in @eq-fraction is carried over from the
annulus derivation, not tested.

== The side is lateral in the image, not a position in the lumen <sec-projection-limits>

A widefield strip integrates over depth, so "side" means a side in the image plane. A lane running
along the upper or lower surface of the hypha projects onto the centre and reads as centre or flat.
Some of the 13 centre and 51 flat fluorescence profiles may be lanes seen from above. The lane
reading therefore rests on the laterally resolved profiles, and the core rejection rests on the
projection, which does account for depth. Neither test distinguishes a lane on the upper surface
from a mixed stream.

== Share counts texture, and speed is texture speed <sec-texture-limits>

The share is a fraction of pixels carrying a trackable orientation, not of volume or of material.
In brightfield the texture is mostly organelles and vesicles; in fluorescence, labelled lipid
droplets. A stream without texture is invisible to both, and dense texture overweights a stream.
The speeds are medians of kymograph texture orientations, which average whatever moves in the
strip's line of sight. Neither limit favours lanes over a core, since @sec-pictures shows a core
changes both share and speed, and flatness in both is what was measured.

== Filming the same spot explains some agreement, but not why one-sided patterns agree more <sec-shared-limits>

A fluorescence video and the brightfield video before it share the stage position, the focus and
the edge's centreline, and the two halves of one video share everything. Both agree more than
chance even where there is no pattern: flat pairs agree across channels 59 % of the time (p 0.048)
and flat profiles keep their side between video halves 73 % of the time. The evidence for lanes is
therefore the excess over those references, 85–88 % against 59 % across channels, and the edge
thirds, which do not share a stretch of hypha. Opposite-wall profiles pass the cross-channel test
but fail the thirds (63 %), which fits a feature fixed at one position along the edge rather than
a stream along the whole hypha; what that feature is, is not established.

== Classes use fixed thresholds, and brightfield is incomplete <sec-class-limits>

The six wall patterns and five curve-fit classes use an effect size of 0.15 that was set, not
fitted, and 85 of 225 fluorescence profiles fall in the uncertain class. The claims above do not
rest on one class count: the pooled share and speed profiles, the curve-fit coefficients and the
side and cross-channel tests use the continuous asymmetry $d$ and contrast $b$. The brightfield
analysis covers 262 of 263 videos. The one missing video is from PNF2307A072\_t37, which has 83 of
its 84 brightfield videos in this document (the 84th failed to load its frames); the other six
sessions are complete. The brightfield
curve-fit intervals are bootstraps over neighbouring bands and too narrow, and brightfield has no
side-consistency test because those videos were analysed without piece counts. The sessions come
from four plates and two strains (STR2307A112 is strain A5, the others C2), and per-session class
shares are in @app-stores.

= What didn't work <sec-deadends>

== A single-orientation structure tensor reads one direction everywhere #dead

The first version measured one dominant texture orientation per kymograph pixel. On the first test
edge, a brightfield edge of LPD2412A025\_t50 whose stored medians were 7.58 µm/s along the
centreline and 3.86 µm/s against it, it returned only against-centreline speeds at every inner
offset: an against-centreline share of 1.00 from −2.5 to +5.0 µm, at −4.4 to −4.1 µm/s. The pipeline's multi-orientation
analysis on the same edge reproduces both stored medians (7.52 and 3.85 µm/s) and puts 54–98 % of
pixels in the against-centreline direction depending on the offset. Overlapping counter-flows need more than
one orientation per pixel. The two runs sampled the edge over slightly different path lengths,
269 and 349 px.

== The kymograph filter's automatic frequency estimate finds no texture in a 5 px strip #dead

Estimating the spatial-frequency centre on each narrow band found no feature above the noise floor
and fell back to a default of 0.225 cycles per pixel, 12 times in a two-video test. The fix is to
reuse the full band's estimate. On the one fluorescence edge checked, where the narrow-band
estimate did not fall back (0.227–0.238 against 0.242), shares moved by at most 0.03.

== A symmetry test cannot find a core, because shuffled profiles look symmetric too #dead

The first classifier called a profile coaxial when its share profile was more symmetric than
shuffled offsets and the centre differed from the flanks by at least 0.4. It found 1 coaxial
profile in 234 bidirectional fluorescence profiles, and 4 with the threshold at 0.25. The test
could not have found more: the 5–95 % range of the shuffled null ran from about 0.1 to 0.85 for
almost every profile. The curve fit and wall patterns of @sec-read replace it.

== Band brightness does not say which wall carries the lipid stream #dead

In one-wall fluorescence profiles, the wall with the higher lipid share was the brighter wall in
only 6 of 23 profiles with a brightness contrast (binomial p 0.035). Fluorescence shows only
lipids, static and moving, and band brightness also depends on depth and dye load, so it does not
locate the moving stream; a dimmer lipid-stream wall is not a contradiction.

== Video halves share the stage position, so even flat profiles keep their side #dead

Comparing the first and second half of a video keeps the sign of the wall asymmetry for 73 % of
flat profiles (36 of 49), so a fixed asymmetry at the stage position passes it. The edge-thirds
comparison of @sec-side replaces it.

= Actionable Items <sec-actions>

== Compendium handoff

- Contradicts #link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[the annulus-geometry
  findings]: its sections "The profile factor is
  1, because the pipeline reports a median" (a parabolic backflow core) and "The annulus geometry is
  not" (the ratio read as a core radius), and the annulus premise of its derivation. Its measured
  ratio $R$ is unaffected and survives as the lumen fraction of @eq-fraction. Per the tier's rule
  this needs an issue, not an edit to either document.
- Makes stale, in transport_paper: sections 3 ("Lipid occupancy → inner radius") and 4
  ("Pressure-driven backflow") of `backflow_model_overview.md`
  (`Working_notebooks/backflow_exploration/`), and the $2 slash 3$ comparator in
  `direction_resolved_flow.py`, `figs_trail_map.py`, `figs_width_dependence.py` and
  `annulus_ratio_current.py` (`Working_notebooks/`).
- Does not affect #link("direction_resolved_backflow.typ")[the direction-resolved backflow
  document], which compares full-band medians.
- The decision to remove the Poiseuille cross-section from the backflow model is an `/entry`.

== Open

- #open Rerun the 215 brightfield videos analysed before piece counts existed, to give them
  along-edge intervals and a side-consistency test; three shards on the `fat_rome` partition of 8–24 h.
- #open Choose how the simplified model sets the return fraction $f$: from demand, or constant.
  Compare both against the stored per-edge speeds.
- #open Compare $f = 1 slash (1 + R)$ per edge with the measured brightfield against-growth pixel
  share, as a consistency check of @eq-fraction.
- #open Place each stream in depth with the 3D confocal data, which exist: a lane on the upper or lower
  surface, a centred stream and a mixed one all project onto the centre of a widefield strip, and only
  axial resolution separates them. Through-focus optosplit captures would place the lipid stream and the
  brightfield to-root stream of the same hypha in three dimensions.
- #open Compute the profile-class split that a motor lane along the wall predicts when its angle round
  the hypha differs between hyphae: side-on it reads as one wall or a ramp, from above or below as flat
  or centre, wrapped round as both walls. Use the projection model of @sec-projection-limits and
  `radial_poiseuille_projection.py`, and compare with the fluorescence classes (one wall or ramp 136,
  flat or centre 64, both walls 20 of 268). A match would make this lane, a coaxial arrangement seen at
  different angles, the one reading for all the classes.
- #open Identify what makes opposite-wall profiles consistent across channels but not along the edge.

= Appendix <sec-appendix>

== Class shares per session <app-stores>

#table(
  columns: 7, align: (left, right, right, right, right, right, right), stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*fluorescence wall pattern*], [*both walls*], [*centre*], [*flat*], [*one wall*], [*opposite wall*], [*ramp*],
  table.hline(stroke: 0.4pt),
  [EPY2412A088\_t28 (79)], [0.08], [0.08], [0.14], [0.14], [0.22], [0.10],
  [EPY2412A088\_t55 (26)], [0.08], [0.00], [0.27], [0.19], [0.12], [0.12],
  [LPD2412A025\_t25 (43)], [0.16], [0.02], [0.19], [0.23], [0.19], [0.12],
  [LPD2412A025\_t36 (9)], [0.00], [0.11], [0.11], [0.11], [0.22], [0.00],
  [LPD2412A025\_t50 (75)], [0.03], [0.05], [0.17], [0.20], [0.28], [0.16],
  [PNF2307A072\_t37 (6)], [0.00], [0.00], [0.33], [0.33], [0.00], [0.00],
  [STR2307A112\_t25 (30)], [0.07], [0.07], [0.30], [0.20], [0.23], [0.00],
  table.hline(stroke: 0.6pt),
)
#text(8.5pt, fill: luma(95))[
  Share of bidirectional oriented fluorescence profiles per session (count in brackets); the
  remainder of each row has too few pixels to classify. `radial_lanes.py`.
]

#table(
  columns: 6, align: (left, right, right, right, right, right), stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*brightfield curve fit*], [*centre-enriched*], [*flat*], [*lanes*], [*uncertain*], [*wall-enriched*],
  table.hline(stroke: 0.4pt),
  [EPY2412A088\_t28], [0.05], [0.29], [0.38], [0.22], [0.05],
  [EPY2412A088\_t55], [0.07], [0.20], [0.32], [0.25], [0.16],
  [LPD2412A025\_t25], [0.07], [0.18], [0.43], [0.27], [0.05],
  [LPD2412A025\_t36], [0.19], [0.25], [0.38], [0.12], [0.06],
  [LPD2412A025\_t50], [0.20], [0.22], [0.36], [0.15], [0.07],
  [PNF2307A072\_t37], [0.11], [0.11], [0.36], [0.20], [0.22],
  [STR2307A112\_t25], [0.11], [0.38], [0.27], [0.22], [0.03],
  table.hline(stroke: 0.6pt),
)
#text(8.5pt, fill: luma(95))[
  Share of bidirectional brightfield profiles per session, bootstrap intervals. PNF2307A072\_t37 has
  83 of its 84 brightfield videos; the 84th failed to load. `radial_flow_curvefit.py`.
]

== The wall asymmetry of every pair <app-scatter>

#fig("figures/radial_cross_channel_scatter.png",
  [Brightfield against fluorescence wall asymmetry $d$ for the 250 edge pairs with both, coloured by
  fluorescence wall pattern with the colours of @fig-side; light grey marks profiles with too few
  pixels to classify.],
  src: "transport_paper/Working_notebooks/radial_writeup_figures.py", width: 70%) <fig-scatter>

The scatter behind @sec-cross: one-wall, ramp and opposite-wall pairs fall in the two quadrants
where the signs agree, flat pairs spread across all four.

== Reproducing this <app-repro>

All scripts are in `transport_paper/Working_notebooks/`; the band analysis runs on Snellius under
the `flow_analysis_comps` environment, the rest locally with `transport_paper/.venv`.

+ Band analysis: `snellius/radial_flow.py radial_runs.json OUT.csv N_WORKERS`, submitted with
  `snellius/radial_flow.sbatch` (fluorescence) and `snellius/radial_flow_bf.sbatch` with
  `SHARD=i/3` (brightfield). Workers set `SLURM_CPUS_PER_TASK=1` so the pipeline's inner pools do
  not multiply, and a rerun resumes from the existing CSV.
+ Curve fit and classes: `radial_flow_curvefit.py --radial CSV --out OUT_DIR`, once per channel.
+ Wall patterns: `radial_lanes.py --radial radial_flow_fluo_seg.csv --out OUT_DIR`.
+ Side consistency: `radial_side_consistency.py --radial radial_flow_fluo_seg.csv --out OUT_DIR`.
+ Cross-channel: `radial_cross_channel.py --radial FLUO_CSV --radial BF_CSV --out OUT_DIR`.
+ Speed across the hypha: `radial_speed_profile.py` with the same two inputs.
+ Projection: `radial_poiseuille_projection.py`.
+ Figures: `radial_writeup_figures.py --out OUT_DIR`, from the outputs of steps 2–6.

One row per measurement campaign, with where its input lives today:

#block(breakable: false, table(
  columns: (1.2fr, 1.2fr, 1.9fr, 1fr, 0.9fr), align: left, stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*campaign*], [*script*], [*input*], [*ran*], [*input survives*],
  table.hline(stroke: 0.4pt),
  [fluorescence bands, 189 videos], [step 1], [videos on Snellius project space `prjs1583`; polyflow outputs in `paper_plates/`], [2026-09-14], [yes],
  [brightfield bands, 262 videos], [step 1, three shards of 8 h; 263 attempted, one failed to load], [same], [2026-09-14 to 2026-09-15], [yes],
  [curve fit, patterns, side, cross-channel, speed, figures], [steps 2–8], [band CSVs in `fig_outputs/radial_flow/`], [2026-09-15], [yes, local, not in git],
  table.hline(stroke: 0.6pt),
))

== References

#bibliography("references.bib", title: none, style: "apa")
