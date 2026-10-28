// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// ---------------------------------------------------------------------------

#set document(
  title: "Rootward speed spread against the model's Poiseuille core",
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
#set heading(numbering: (..n) => if n.pos().len() < 4 { numbering("1.1", ..n) })
#set ref(supplement: it => if it.func() == figure { it.supplement } else { "Section" })
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
#set math.equation(numbering: "(1)")
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
  #text(19pt, weight: 700)[Rootward speed spread]
  #v(-0.3em)
  #text(19pt, weight: 700)[against the model's Poiseuille core]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · 1,367 brightfield edges over 15 sessions on 5 plates of #emph[Rhizophagus irregularis]
    · main transport model · \@6085c13 (branch analysis/plug-test)
  ]
]
#v(1.2em)

= Introduction <sec-intro>

#question[The transport model has a tipward motor stream along the wall and a pressure-driven rootward core with a parabolic speed profile, and it reads out one speed per hypha (half the parabola's peak). If the videos sample particles across that core, the rootward speeds within one hypha should spread widely (75th/25th percentile ratio 1.9 to 2.3). Is the measured spread that wide, as narrow as a plug, or in between, and what does that mean for the one-speed read-out?]

The plates are colonies of #emph[Rhizophagus irregularis] imaged over days; a session is one plate's
round of short videos between two imaging timepoints. In each video the flow pipeline draws a kymograph
along every hypha and detects streaks, the tracks of individual moving particles, each with a speed and
a direction. Orienting every network edge by the growth directed acyclic graph (DAG) says which
direction runs toward the growing tips (tipward) and which runs back toward the roots (rootward).

The transport model of the paper turns each edge into two streams. Motors carry a lipid-rich stream
tipward along the wall, and the water this displaces returns rootward through the centre of the hypha,
pushed by a pressure difference. Inside that central core the model's speed profile is a parabola, so
the particles in one hypha's return flow do not share one speed: those at the centre move fastest
and those near the core's edge barely move. The model nonetheless predicts one rootward speed per edge,
and that speed is what it is scored on. This document asks whether the spread of measured rootward
streak speeds within an edge looks like that parabola, like a plug moving at one speed, or like neither.
Throughout, the *spread* of an edge is the 75th over the 25th percentile of its speeds and its *level*
is their median; the read-out is $P slash 2$, with $P$ the peak of the parabola relative to the wall
(@sec-profile).

In short: the measured rootward spread is 1.51, between a plug (the tipward stream's 1.23) and every
way of sampling the parabola (1.78--2.32); its shape matches none of them; and the one-speed read-out
still predicts the level better than any sampled median. A plug with a spread of about 1.2 µm/s,
present within every 3 s of video, reproduces the per-edge spreads best (@sec-noisy).

= Motivation <sec-motivation>

How plug-like the return flow is decides two things. First, the read-out. The model compares one number
per edge with the median of the measured streaks, and that number is a modelling choice: the mean
speed of the pressure-driven part of the core, $|q_c| slash (pi a^2)$. If the videos sample particles
across a parabolic core, the honest prediction of the measured median is the median of the sampled
speeds, which differs from that mean. Second, the physical picture. A spread much narrower than the
parabola's means either that the videos see only part of the core, or that the core does not move as an
ideal parabola. Large particles in a narrow tube are one known cause of a blunted profile, and the
measured spread is the number to compare with that literature.

The test is independent of the model's level. Every speed is divided by its own edge's median before
comparing, so the comparison is about shape, not about whether the model predicts the right speed. The
level is checked separately (@sec-level).

= Method <sec-method>

== The model's core is a parabola that meets the motor speed at its wall <sec-profile>

The model treats an edge as a tube of radius $b$ (the hypha's lumen radius from the recalibrated network
width). An outer annulus $a < r < b$ moves tipward at the motor speed $v_m$; the core $r < a$ carries the
pressure-driven return. In the lab frame, with tipward positive,

$ u(r) = v_m - P (1 - r^2 slash a^2), quad 0 <= r <= a, $ <eq-profile>

so the core meets the annulus at speed $v_m$ at its wall and reaches $v_m - P$ at its centre. $P$ is the
peak of the pressure-driven part relative to the wall. From the model's core flux $q_c$,
$P = 2 |q_c| slash (pi a^2)$; the current read-out, $|q_c| slash (pi a^2) = P slash 2$, is the mean of
that pressure-driven part over the core's cross-section. Particles move rootward only where $u < 0$,
that is inside $r_0$ with $r_0^2 = a^2 (1 - v_m slash P)$, and the fastest rootward speed on the edge is

$ W = P - v_m. $ <eq-w>

An edge with $W <= 0$ has no rootward particles at all. The model's per-edge terms are read from
the main run's edge tables: $v_m$ is the tip-distance motor speed, typically 3.01 µm/s (median, IQR
2.84--3.08, 1,544 edges); $P$ is 6.77 µm/s (5.04--9.73); $a slash b$ is 0.93 (0.81--0.98), so the
annulus is thin; and $W$ is 4.46 µm/s (2.74--7.03) on the 1,407 edges where it is positive.

== Three guesses at which depths the videos see: whole lumen, central slice, planar profile <sec-modes>

Which particles a brightfield video records depends on its depth of field against a lumen 7--10 µm across (IQR of $2b$),
and that depth is not measured. Three modes bracket it (@fig-schematic):

/ Whole lumen: every particle in the cross-section is seen. Radius is drawn with density $prop r$.
  The rootward speeds are then uniform on $[0, W]$, a flat-topped distribution; before any cut its
  75th/25th percentile ratio is 3.
/ Central slice: only a thin plane through the axis is seen. Radius is uniform along a diameter. The
  speeds pile up just below $W$ (density $prop 1 slash sqrt(W - w)$); the ratio is 2.14 before any cut.
/ 2D profile: the core is a planar (slab) parabola, $u(y) = v_m - P_2 (1 - y^2 slash a^2)$, with $y$
  uniform across the width, so every depth is weighted equally. A planar parabola's mean is 2/3 of its
  peak rather than 1/2, so keeping the model's mean $|q_c| slash (pi a^2)$ sets $P_2 = 3/4 P$. The shape
  is that of the central slice, but the fastest rootward speed $W_2 = 3/4 P - v_m$ is lower, and 212
  edges, against 137 for the round core, have no rootward particles.

A plug, the alternative to all three, is every particle at one speed: a spike broadened only by
measurement noise.

#fig("figures/rootward_spread_schematic_profiles.png",
  [The three sampling modes on a typical edge ($v_m = 3.0$ µm/s, $P = 7.2$ µm/s, $a = 3.8$ µm,
  $b = 4.3$ µm, the medians of the edges with $W > 0$). Left: lab-frame speed across the lumen for the
  round core (solid) and the 2D core with the same mean (dashed); grey bands are the motor annulus.
  Right: the rootward speed distribution each mode predicts after the 0.5 µm/s cut, with the current
  read-out $P slash 2$ dotted. The whole lumen gives a flat top, the central slice and the 2D profile a
  pile-up just below their fastest speed.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py schematic()") <fig-schematic>

== The measured spread is the 75th/25th ratio of an edge's pooled rootward streaks <sec-measured>

The measured speeds are every moving brightfield streak of the edge's videos in the rootward direction,
pooled over videos. The edge set and filters are those the model is scored on: the 1,544 brightfield
edges over 15 sessions on 5 plates, video directions with at least 5 moving streaks, video edges of at
least 20 µm, and the motor-orientation correction that swaps the two streams on edges whose labelled
rootward stream is the motor-like one. Streaks below 0.5 µm/s, the slowest speed simulated in the paper's synthetic
validation, are dropped here and from every draw. A typical edge has 77 rootward streaks (median, IQR
28--191) and 126 tipward ones (57--250).

Pooling videos reproduces the scored speeds: the pooled median over the scored median (the median of
per-video medians) is 1.002 (median over edges), within 10 % on 87 % of edges. Pooling adds no spread:
the median per-video ratio is 1.50 against 1.51 pooled. 1,367 edges have both rootward streaks and
$W > 0$ (1,239 with $W_2 > 0$); these are the edges every rootward comparison below uses unless said.

*Spread ratio.* The 75th over the 25th percentile of an edge's speeds. It is dimensionless and does not
depend on the edge's speed level. What makes it lie: the 0.5 µm/s cut and any under-detection of slow
streaks remove the slow tail and narrow it; with few streaks it is noisy.

*KS distance.* The two-sample Kolmogorov--Smirnov statistic between the measured speeds and 5,000
drawn speeds, both divided by their own median. It measures shape. Two samples from one law at each
edge's streak count give a median KS of 0.094, the sampling floor.

*Plug references.* Two. The synthetic kymographs of the Methods validation hold particles at one
speed per kymograph; their detected speeds (48 brightfield kymographs, exposure 0.9 of the frame period,
1--8 µm/s, 3,377 streaks) give the spread of an ideal plug after streak detection. They hold no
particle-size or depth spread, so they are a lower bound. The measured tipward stream is the second,
empirical, reference: the model moves it as a plug annulus at $v_m$.

== A noisy plug and time windows test what the spread is made of <sec-noisy-method>

*Noisy plug.* Each edge moves at one speed, its measured rootward median $m$, and every streak is
scattered around it, either relatively, $v = m e^(sigma z)$ (lognormal, $sigma$ dimensionless), or
absolutely, $v = m + sigma z$ ($sigma$ in µm/s), with $z$ standard normal. Each edge is simulated with its
own streak count and the 0.5 µm/s cut, so the finite-sample noise of a 75th/25th ratio from 28 or 191
streaks is included. One $sigma$ for all full-flow edges is fitted by minimising the KS distance between
the simulated (20 replicates per edge) and measured distributions of per-edge spread ratios; per group,
$sigma$ is fitted so the simulated median ratio equals the measured one (grid steps 0.01 and 0.05 µm/s).
The *noise share* is the variance of log spread ratio across simulated edges over that across measured
edges: the part of the edge-to-edge variation that sampling one common $sigma$ already produces. What
makes it lie: a $sigma$ fitted on the ratio alone says nothing about where the spread comes from.

*Time windows.* `plate_streaks.csv` keeps no streak times, so the detection was rerun unchanged on the
raw orientation tensors, adding each streak's mid time; the rerun reproduces every stored speed. Each
10.05 s bright-field video (20 frames per second) is split into thirds, and a video direction counts
when every third holds at least 8 streaks. The *window spread* is the median 75th/25th ratio inside a
third; the *drift* is the range of the three window medians over the video median; the *between-window
share* is the variance of the three window means of log speed over the video's variance of log speed.
The null for both is the same streaks with their times shuffled. The raw tensors of EPY2412A088 and
STR2307A112 were re-detected locally and those of LPD2412A025 and PNF2307A080 on Snellius
(`flow_analysis_comps` a0d627d); a re-detected kymograph is kept only where its speeds equal the stored
streak table's (97 % of LPD2412A025 and 100 % of PNF2307A080 kymographs). PNF2307A072 matched none of its
stored kymographs, by edge name or by trying every edge of each run, and is left out until that is
understood, so the check covers 13 of the 15 sessions.

== The comparison runs in seven steps <sec-steps>

+ Draw: per edge and mode, 5,000 rootward speeds from @eq-profile (seed 0), and the same for the
  tipward side: annulus particles at $v_m$ plus core particles with $0 < u <= v_m$, over the whole
  lumen $r < b$. This gives each edge a predicted distribution in each mode.
+ Spread: the measured spread ratio against the predicted one, per edge. This tests the width
  of the distribution, the quantity a plug and a parabola disagree on most.
+ Shape: per-edge KS and pooled distributions of median-scaled speeds (one draw per measured streak,
  so edges weigh the same in both). This tests what the spread ratio cannot: where in the distribution
  the speeds sit.
+ Level: the measured median against the drawn median and against the read-out $P slash 2$, as the
  median ratio predicted over measured and the share within 2×. This is the only step that is not
  scale-free.
+ Splits: by flow regime (full and sparse flow, from the moving-streak density classification) and
  by distance to the nearest growing tip (below 1, 1--3 and above 3 mm), because near-tip edges have
  small $W$.
+ Noisy plug: one spread for all edges, then per group (tip distance, lumen width, speed, a shear proxy,
  session), testing whether the spread is constant (@sec-noisy-method).
+ Time windows: within-window spread against between-window drift, testing whether the spread is
  slow change over the video or present at every moment.

= Results <sec-results>

The first three sections compare shapes, every speed divided by its edge's median. The crossing to
level comes in @sec-level, the only place absolute speeds are compared.

== Rootward speeds within an edge spread 1.5-fold: wider than a plug, narrower than any sampled parabola <sec-spread>

The measured rootward spread ratio is 1.51 (median, IQR 1.32--1.84, 1,367 edges over 15 sessions). The
predictions are 2.32 (2.08--2.53) for the whole lumen and 1.88 (1.76--1.97) for the central slice; the
synthetic plug gives 1.005 and the measured tipward stream 1.23 (1.16--1.45, 1,332 edges). On full flow
(1,137 edges) the measured ratio is 1.48 (1.32--1.72), below the central-slice prediction on 79 % of
edges and below the whole-lumen one on 88 % (@fig-ratio).

#fig("figures/rootward_spread_ratio_measured_vs_predicted.png",
  [Per-edge rootward spread ratio (75th/25th percentile), measured against predicted for the whole
  lumen (blue, 1,367 edges), central slice (orange, 1,367) and 2D profile (green, 1,239); dashed line
  equal. The grey line is the synthetic plug (1.005, on the axis) and the dotted line the measured
  tipward median (1.23). Bottom right: the per-edge ratios as distributions, plug clipped. Both axes
  linear, shared scale.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py", width: 80%) <fig-ratio>

=== The measured spread does not follow the predicted spread from edge to edge

Spearman's rank correlation between measured and predicted ratio, taken as monotone, is −0.11 for the
whole lumen (1,367 edges) and −0.12 for the 2D profile (1,239). The predicted ratio barely varies between
edges: within one mode the shape is fixed and only the cut moves it. So this null says little beyond
the median comparison above.

=== The spread barely changes with distance from a tip

The measured ratio is 1.62 within 1 mm of a growing tip (72 edges), 1.50 at 1--3 mm (370) and 1.50
beyond 3 mm (920); the whole-lumen prediction is 2.28, 2.28 and 2.37, the slice 1.85, 1.85 and 1.90
(@app-groups).

== Neither parabola reproduces the shape: one peak, no flat top and no pile-up <sec-shape>

Pooled over edges, the measured rootward speeds form a single peak at the median with a tail on both
sides (@fig-pooled). The whole-lumen draw is flat-topped and the slice draw piles up near its fastest
speed; the measured distribution shows neither. Pooled KS against the measured distribution is 0.08 for
the whole lumen, 0.19 for the slice and 0.42 for the synthetic plug (215,475 streaks, 1,367 edges). The
whole lumen wins on its low tail, not on its peak.

Per edge, the median KS is 0.26 (0.18--0.33) for the whole lumen and 0.27 (0.21--0.34) for the slice,
nearly three times the sampling floor of 0.094; neither mode fits a typical edge. On full flow the
whole lumen fits better than the slice on 36 % of edges.

#fig("figures/rootward_spread_pooled_scaled_distributions.png",
  [Pooled speeds, each divided by its edge's median: measured streaks (black), whole lumen (blue),
  central slice (orange), 2D profile (green, on its own 1,239 edges) and the synthetic plug (grey,
  clipped at density 4). Left rootward (215,475 streaks), right tipward (263,211 streaks). Linear axes.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py") <fig-pooled>

== A plug with an absolute spread of about 1.2 µm/s fits the per-edge spreads; a relative spread does not <sec-noisy>

The Poiseuille modes fail on shape (@sec-shape); this section asks what the spread is instead. It uses
the 1,267 full-flow edges with rootward streaks, which include the 130 with $W <= 0$ that the
Poiseuille modes skip, since a plug needs no $W$.

=== One relative spread explains a tenth of the edge-to-edge variation

A lognormal plug with $sigma = 0.32$ matches the median spread ratio (1.52 simulated, 1.48 measured) but
not its distribution: simulated ratios span 1.46--1.58 (IQR) against 1.32--1.73 measured, KS 0.24, and
sampling one common $sigma$ produces 12 % of the measured variance of log ratio (@fig-qq). The measured
ratios are skewed (skewness 3.8; 0.45 simulated). Tipward the lognormal $sigma$ is 0.16, KS 0.31, noise
share 3 %. So the long right tail of per-edge spreads is not finite-sample noise around one relative
spread.

=== One absolute spread reproduces the distribution of per-edge spreads

An additive plug with $sigma = 1.15$ µm/s matches the distribution: IQR 1.32--1.68 against 1.32--1.73, KS
0.07, noise share 44 %; the far tail (skewness 1.2 against 3.8) is still short. It implies that slow
edges spread more, as measured; Spearman's correlation of spread ratio with median speed, taken as
monotone, is −0.96 simulated against −0.46 measured, because the measured edges scatter more around that
trend (@sec-combined). Tipward the additive $sigma$ is 0.45 µm/s (KS 0.23, noise share 7 %).
The same detector on the same videos gives the tipward stream 0.45 µm/s, so most of the rootward
1.15 µm/s is not detection noise; if the two add in quadrature the rootward excess is 1.06 µm/s.

#fig("figures/rootward_spread_noisy_plug_qq.png",
  [Quantile--quantile plot of per-edge spread ratios, measured against a simulated noisy plug with one
  $sigma$ fitted by KS: lognormal (relative, purple) and additive (absolute, red), on full-flow edges.
  Left rootward (1,267 edges), right tipward (1,272). Dashed line equal; linear axes, shared scale.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py --noisy") <fig-qq>

=== The spread tracks speed, not lumen width or session

Per group, with $sigma$ fitted to the group's median spread ratio (full flow; @app-sigma):

#table(
  columns: 5, align: (left, left, right, right, right), stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*split*], [*groups*], [*edges*], [*lognormal $sigma$*], [*additive $sigma$ (µm/s)*],
  table.hline(stroke: 0.4pt),
  [rootward median speed], [slow / mid / fast (2.4 / 3.6 / 5.6 µm/s)], [341 / 440 / 486], [0.40 / 0.31 / 0.25], [1.00 / 1.10 / 1.40],
  [lumen width], [thin / mid / wide (6.7 / 8.8 / 10.9 µm)], [335 / 440 / 460], [0.36 / 0.30 / 0.28], [1.05 / 1.15 / 1.40],
  [speed over lumen radius], [low / mid / high], [376 / 399 / 460], [0.38 / 0.30 / 0.24], [1.05 / 1.20 / 1.35],
  [tip distance], [< 1 / 1--3 / > 3 mm], [64 / 346 / 857], [0.35 / 0.31 / 0.30], [0.95 / 1.05 / 1.30],
  [flow regime], [full / sparse], [1,267 / 178], [0.30 / 0.60], [1.20 / 2.40],
  [session], [14 sessions with at least 20 edges, 24--197], [], [0.26--0.48], [0.85--1.60],
  table.hline(stroke: 0.6pt),
)

Neither form is constant. The relative spread falls with speed (0.40 to 0.25) while the absolute one
rises (1.00 to 1.40 µm/s): the spread grows with speed, but less than in proportion. Width follows only
through speed: within each speed tertile the lognormal $sigma$ of thin, mid and wide lumens is 0.42, 0.39
and 0.37 (slow), 0.30, 0.30 and 0.35 (mid) and 0.27, 0.26 and 0.24 (fast), a range of at most 0.05. The
lumen widths are the video lumen measurements, available on 1,235 of the 1,267 edges. Tertiles are cut
over all edges and then restricted to full flow, so the groups are not equal in size.

=== The spread is there within every three seconds of video

On 567 full-flow rootward video directions (13 sessions on 4 plates, median 80 streaks), the spread inside
one third of the video is 1.45 against 1.48 over the whole video. The window medians differ by 13 % of the
video median, against 10 % with shuffled times, and the between-window share of log-speed variance is
3.0 % against 1.8 %; 63 % of videos exceed their shuffled null. Tipward (746 directions) the window and
video spreads are 1.19 and 1.20, the drift 6 % against 5 %. Slow change over the 10 s of a video accounts
for little of the spread; it is present at every moment, across particles or on time scales below about
3 s.

=== An absolute spread follows the speed trend; a proportional part flattens it <sec-combined>

Writing the spread as $sigma_v^2 = sigma_"abs"^2 + (c v)^2$, an absolute part plus one proportional to
speed (the form a fixed profile shape would give), and fitting both on a grid ($c$ 0--0.35, $sigma_"abs"$
0--1.6 µm/s, 3 replicates per edge; `combined_fit.csv`) splits the two targets. The distribution of
per-edge spreads is matched best by $c approx 0$, $sigma_"abs" = 1.2$ µm/s (KS 0.064), which gives Spearman
−0.90 between spread ratio and speed against the measured −0.46. The speed dependence is matched by
$c = 0.275$, $sigma_"abs" = 0.5$ µm/s (Spearman −0.455), whose per-edge spreads are too uniform (IQR
1.44--1.57, KS 0.21). Binned by edge speed (@fig-combined, right), the two fits differ: the absolute
spread follows the measured median spread ratio from slow to fast edges (1.93 to 1.25 against 1.89 to
1.23 over the speed octiles), while the proportional fit is too flat (1.61 to 1.45). The lower measured
Spearman is therefore not a weaker trend but more scatter between edges at the same speed: the measured
interquartile band is wide at every speed, and the simulated edges, which differ only in speed and
streak count, scatter less. Part of that extra scatter is the slow second population of
@sec-tail-edges. The data favour an absolute spread of about 1.2 µm/s with $c$ near zero.

#fig("figures/rootward_spread_combined_fit.png",
  [The two-part spread fit on 1,267 full-flow edges. Left: KS distance between simulated and measured
  per-edge spread ratios over the grid (grey) with contours of the simulated Spearman correlation between
  spread ratio and edge speed (orange; thick: the measured −0.46); circles mark the best fit to the
  distribution (red, $c = 0.025$, $sigma_"abs" = 1.2$ µm/s) and to the correlation (blue, $c = 0.275$,
  $sigma_"abs" = 0.5$ µm/s). Middle: quantile--quantile plot of per-edge spread ratios for the two fits,
  dashed line equal. Right: median per-edge spread ratio in octiles of edge speed, measured (black,
  interquartile range shaded) and for the two fits; 5 replicates per edge, so the legend's KS and Spearman
  values differ slightly from the 3-replicate grid. Linear axes.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py --combined-figure", width: 100%) <fig-combined>

=== The scatter shrinks with streak duration, faster tipward than rootward

If each particle diffuses along the hypha while it is tracked, a streak of duration $T$ carries a speed
error $sqrt(2D slash T)$. On full-flow edges, the robust standard deviation (1.4826 × median absolute
deviation) of streak speed minus the edge median, in eight duration bins of 0.75--3.2 s (rootward,
183,048 streaks) and 0.75--4.8 s (tipward, 217,861):

#table(
  columns: 5, align: (left, right, right, right, right), stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*stream, edges*], [*log--log slope*], [*$sigma_0$ (µm/s)*], [*$D$ (µm²/s)*], [*SD at shortest / longest $T$ (µm/s)*],
  table.hline(stroke: 0.4pt),
  [rootward, all], [−0.31], [0.76], [0.52], [1.34 / 0.85],
  [rootward, slow / mid / fast edges], [−0.38 / −0.29 / −0.20], [0.55 / 0.89 / 1.00], [0.39 / 0.64 / 0.48], [],
  [tipward, all], [−0.63], [0], [0.21], [0.71 / 0.22],
  [tipward, slow / mid / fast edges], [−0.66 / −0.67 / −0.49], [0 / 0 / 0.16], [0.30 / 0.18 / 0.13], [],
  table.hline(stroke: 0.6pt),
)

$sigma_0$ and $D$ come from fitting $sigma^2 = sigma_0^2 + 2D slash T$; edge thirds are by the edge's median
speed (`duration_scaling.csv`). Tipward scatter falls about as $T^(-1/2)$ or faster and leaves no floor;
$D approx 0.13$--$0.30$ µm²/s. Stokes--Einstein gives 1.09 and 0.55 µm²/s for 0.4 and 0.8 µm particles in
water, so these values correspond to an effective viscosity of two to eight times water's. Rootward scatter falls
more slowly ($T^(-0.2)$ to $T^(-0.4)$) and keeps a floor of 0.55--1.0 µm/s that grows with edge speed:
diffusion during the streak can account for the tipward scatter, but not for most of the rootward one.
Two caveats bound this: a straight-line fit to noisy positions also gives a speed error that shrinks with
$T$ (as $T^(-3/2)$), so the tipward slope may be part fit error; and a streak's duration is set partly by
its own speed, since a faster particle crosses the kymograph sooner, so duration bins also sort streaks
by speed within an edge.

=== The widest spreads mix a slow population near 0.5--1 µm/s with the flowing stream <sec-tail-edges>

The 25 full-flow edges with the widest rootward spread (ratio 3.0--6.4, median 4.0, against 1.48 for the
rest) were inspected one by one (@fig-tail). On 21 of them more than a fifth of the streaks run below half
the edge median, in a separate cluster at 0.5--1 µm/s, above which a flowing population sits at 2--8 µm/s.
Mixing between videos explains one edge (its video medians differ by 0.95 of the edge median); 23 of the
25 are measured in one video. They have fewer streaks (median 33 against 72, 8 with fewer than 20), are
slower (2.2 against 3.9 µm/s) and thinner (7.7 against 9.0 µm lumen), and their tipward stream is
ordinary (1.27). Cutting at 1 µm/s instead of 0.5 µm/s brings their spread to 1.78 and that of all
full-flow edges from 1.48 to 1.45. The tail is therefore a second, near-still population, slow particles
or texture drifting at the detection floor, on top of a normal flowing stream, not a broader flow.

== Seeing all depths equally (planar profile) lowers the predicted spread to 1.8, still above 1.5 <sec-2d>

The 2D profile, the depth-of-field case where every depth is weighted equally, predicts a spread ratio
of 1.78 (1.55--1.90) on its 1,239 edges, against 1.51 measured on the same edges; on full flow 1.80
against 1.48, with the measured ratio below the prediction on 70 % of 1,034 edges. Its median per-edge
KS is 0.28 (0.21--0.35). Pooled, its ratio of 1.60 comes close to the measured 1.64, but its shape still
piles up below $W_2$ and the pooled KS stays at 0.20. The planar profile therefore moves the width
toward the data without fixing the shape, and @sec-level shows it costs the level.

== The one-speed read-out, half the parabola's peak, still predicts the speed level best <sec-level>

Here absolute speeds enter. Predicted over measured rootward median (median over the 1,367 edges, the
share within 2×):

#table(
  columns: 4, align: (left, right, right, right), stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*predictor*], [*bias (median pred./meas.)*], [*within 2× (%)*], [*median fold error*],
  table.hline(stroke: 0.4pt),
  [read-out $P slash 2$], [1.09], [86], [1.37],
  [central-slice draw median], [1.04], [74], [1.50],
  [whole-lumen draw median], [0.74], [70], [1.52],
  [2D draw median (0 where $W_2 <= 0$)], [0.62], [58], [1.73],
  table.hline(stroke: 0.6pt),
)

The slice median has the smallest bias but more scatter than the read-out, because it depends on
$W = P - v_m$, a difference of two uncertain terms; the read-out depends on $P$ alone. The share
within 2× is higher than the model's headline score because the 137 edges with $W <= 0$ are not in
this set (@sec-noroot). The scatter behind the table is in @app-level.

== Tipward speeds are plug-like, but the model's own tipward profile spreads twofold <sec-tip>

The measured tipward spread ratio is 1.23 (1.16--1.45, 1,332 edges); 1.21 on full flow. The model's
tipward side predicts 1.99 (whole lumen), 2.10 (slice) and 2.15 (2D): with $a slash b = 0.93$ the
annulus is a small share of the cross-section, so most tipward particles are slow core particles with
$0 < u < v_m$. Median per-edge KS is 0.37--0.38 in both round modes. Pooled, the measured tipward
distribution is a narrow peak (ratio 1.29) where every mode gives a spike at $v_m$ on a broad low shoulder
(@fig-pooled, right). The tipward particles the videos record behave like the motor annulus alone.

== Only on sparse-flow edges does the spread match a whole-lumen parabola <sec-sparse>

On the 154 sparse-flow edges the measured rootward ratio is 2.39 (2.13--2.57), against 2.21 (2.04--2.48)
predicted for the whole lumen and 1.84 for the slice. The whole lumen has the lower KS on 86 % of them,
median 0.17 (0.14--0.22) against 0.34 (@fig-ks). Their tipward ratio is 2.31 as well: sparse flow is
broad in both directions, so its match to the whole-lumen shape need not mean a parabolic core.

#fig("figures/rootward_spread_ks_by_regime_tipdist.png",
  [Per-edge KS of median-scaled speeds by flow regime and tip distance, whole lumen (blue), central
  slice (orange), 2D profile (green); boxes are IQR, whiskers 1.5 IQR, outliers hidden. Left rootward,
  right tipward. The sampling floor is 0.094.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py") <fig-ks>

== On 134 edges the model predicts no rootward flow, yet rootward streaks appear <sec-noroot>

On 137 edges $W <= 0$: the core's pressure-driven part never outruns the motor annulus, and the model
predicts no particle moving rootward. 134 of them have measured rootward streaks. They were left out of
every comparison above and were not examined further.

= Discussion <sec-discussion>

Within one edge, measured rootward streak speeds spread by a 75th/25th ratio of 1.51 (1.48 on full flow;
@sec-spread), between a plug (the tipward stream's 1.23) and every sampling of the model's parabolic
core: 2.32 for the whole lumen, 1.88 for a central slice and 1.78 for a planar profile that weighs all
depths equally (@sec-2d). The measured distribution has one peak and lacks both the flat top and the
pile-up the parabola predicts (@sec-shape). The tipward stream is plug-like although the model's own
tipward profile is not (@sec-tip), and only sparse flow matches a whole-lumen parabola (@sec-sparse).
The read-out $P slash 2$ remains the best level predictor (@sec-level). What fits is a plug with a
spread: an absolute spread of 1.15 µm/s reproduces the per-edge spread ratios (KS 0.07) where one
relative spread does not (KS 0.24), the spread grows with speed but not with lumen width at fixed speed,
and it is present within every third of a video (@sec-noisy). Its tipward part shrinks with streak
duration as diffusion would, at an effective viscosity of two to eight times water's; the rootward part keeps a
floor of 0.55--1.0 µm/s, and the widest rootward spreads are a slow second population at 0.5--1 µm/s
(@sec-tail-edges). All of this is 1,367 edges over 15
sessions on 5 plates, brightfield streaks only, on the model's widths.

== Streak detection narrows the measured spread by an unknown amount

Slow particles near the $r_0$ contour make short, faint streaks
that the detector misses more often than fast ones, and the 0.5 µm/s cut removes the rest. Both narrow the
measured spread relative to any drawn one, which receives only the hard cut. How much is not known: the
brightfield synthetic runs start at 1 µm/s. Part of the gap between 1.48 and the 2D profile's 1.80 may be
this, not physics.

== No choice of imaged depth reaches the measured spread

The three modes bracket it but do not measure it, and an intermediate
slab of thickness δ through the axis would give a spread between the central slice's (δ → 0) and the
whole lumen's (δ → $2b$); that slab mode was not computed. The measured 1.48 lies below all three
modes, so a depth of field alone is unlikely to reach it.

== The realistic plug floor is the tipward stream, not the synthetic plug

The synthetic plug's 1.005 has no particle-size, depth or speed spread; the tipward
1.23 is the realistic plug floor, and it assumes the annulus is a plug, which is the model's assumption,
not a measurement.

== Noisy model widths move the level, hardly the spread

$a$ and $b$ come from the recalibrated network width, so per-edge $W$ is
noisy. That noise moves the level comparison but hardly the spread ratio, which is fixed by the mode.

== The test assumes a centred core, which the radial flow document does not find

#link("radial_flow_structure.typ")[The radial flow structure
document] finds no centred backflow core in the image: the two directions concentrate toward opposite
sides of the hypha. A rootward spread narrower than any centred parabola is consistent with that, but
this test assumes the centred geometry and cannot confirm the side-by-side one.

== On full flow the return is flatter than a parabola, but the half-peak read-out still serves

On full flow the return behaves as a blunted stream: broader than a plug, narrower than a parabola
sampled any way, and best described as a plug with a spread of about 1.1 µm/s beyond the detector's
(@sec-noisy). Concentrated suspensions of non-Brownian particles give such blunted profiles in
pressure-driven flow: particles migrate toward the low-shear centre @leightonShearinducedMigrationParticles1987,
laser-Doppler measurements in a rectangular channel found a blunted velocity profile with a concentration
maximum near the centre @kohExperimentalInvestigationConcentrated1994, later measured across the gap of a
two-dimensional channel for monodisperse spheres @lyonExperimentalStudyMotion1998, and in a circular conduit
the profile flattens from bulk volume fractions of 0.20 upward @hamptonMigrationParticlesUndergoing1997. These
were read at the level of their abstracts and secondary descriptions only; the volume and pages of the
1994 paper and the specific findings of the 1998 paper were not checked against their full texts. In those
systems blunting is set by concentration and particle-to-tube size; here the spread does not depend on
lumen width at fixed speed (@sec-noisy), which a confinement-driven blunting would make it do. A
quantitative comparison needs the cytoplasm's particle volume fraction and size, which this measurement
does not give. The read-out
$P slash 2$ stays: replacing it with the median of sampled speeds makes the level worse in every mode.

= What didn't work <sec-deadends>

== #dead Per-pixel speed quartiles cannot test the shape: background pulls their 25th percentile down

The per-pixel speeds of the orientation filter avoid the streak detector's bias against slow particles,
so they were the planned second check (video directions with at least 100 pixels). Only their quartiles
are stored. Their rootward spread ratio is 3.35 against 1.51 for streaks, and tipward 2.32 against 1.23;
within 1 mm of a tip it reaches 6.5. Slow pixels from background and texture, not particles, set the
25th percentile, so the ratio measures noise and was dropped.

= Actionable Items <sec-actions>

== Compendium handoff

- Bears on the paper's Methods description of the read-out $|q_c| slash (pi a^2)$: the measured spread
  gives no reason to replace it with a sampled median (@sec-level), and the model's parabola is not what
  the videos see (@sec-spread). How the read-out is justified is an `/entry` decision.
- Consistent with #link("radial_flow_structure.typ")[the radial flow structure document] (no centred
  core) without testing its alternative.
- Bears on the tipward side of the model: a plug annulus with a slow core predicts a twofold tipward
  spread the data do not show (@sec-tip).

== Open

- #open Compare the noisy-plug spread quantitatively with blunted-profile measurements in concentrated
  suspensions, which needs an estimate of the cytoplasm's particle volume fraction and size.
- #open Run the time-window check on PNF2307A072 once its re-detected streaks can be matched to the stored
  table (no kymograph matches with `flow_analysis_comps` a0d627d).
- #open Measure streak detection efficiency below 1 µm/s with the synthetic kymographs, to size how
  much of the gap to the 2D profile is detection (@sec-discussion).
- #open Repeat with lumen widths measured in the videos instead of network widths.
- #open Look at the 134 edges with rootward streaks and no predicted rootward flow (@sec-noroot).
- #open Filipe to check the profile and the read-out before anything reaches the paper.

= Appendix <sec-appendix>

== Every group, in one table <app-groups>

#table(
  columns: 8, align: (left, right, right, right, right, right, right, right), stroke: none,
  inset: (x: 4pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*group*], [*edges*], [*measured*], [*whole*], [*slice*], [*2D (edges)*], [*tipward meas.*], [*read-out bias*],
  table.hline(stroke: 0.4pt),
  [all], [1,367], [1.51], [2.32], [1.88], [1.78 (1,239)], [1.23], [1.09],
  [full flow], [1,137], [1.48], [2.35], [1.89], [1.80 (1,034)], [1.21], [1.04],
  [sparse flow], [154], [2.39], [2.21], [1.84], [1.69 (139)], [2.31], [1.52],
  [tip < 1 mm], [72], [1.62], [2.28], [1.85], [1.72 (68)], [1.41], [1.24],
  [tip 1--3 mm], [370], [1.50], [2.28], [1.85], [1.74 (338)], [1.29], [1.07],
  [tip > 3 mm], [920], [1.50], [2.37], [1.90], [1.81 (829)], [1.21], [1.08],
  table.hline(stroke: 0.6pt),
)
#text(8.5pt, fill: luma(95))[
  Median rootward spread ratio (75th/25th) measured and predicted per mode, the measured tipward ratio,
  and the read-out's level bias (median $P slash 2$ over measured median). 76 edges have no regime label
  and 5 no tip distance. `summary.csv` of `plug_test.py`.
]

== The level scatter <app-level>

#fig("figures/rootward_spread_level_check.png",
  [Predicted against measured rootward median per edge: read-out $P slash 2$ (black) and the drawn medians
  for the whole lumen (blue), slice (orange) and 2D profile (green); dashed line equal. Linear axes, clipped
  at 10 µm/s.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py", width: 60%) <fig-level>

== Spread per group <app-sigma>

`noisy_plug_groups.csv` holds every group of the table in @sec-noisy, including the nine speed-by-lumen
cells and the fourteen sessions with at least 20 full-flow edges, with the measured median spread ratio, median speed and lumen width of
each; `noisy_plug_fit.csv` holds the one-$sigma$ fits; `time_windows.csv` one row per video direction.

== The widest-spread edges <app-tail>

#fig("figures/rootward_spread_tail_edges.png",
  [Rootward streak speeds on the 25 full-flow edges with the widest spread, stacked by video (colours,
  where an edge has more than one), with session, edge and spread ratio above each panel. Linear axes, scaled
  per panel.],
  src: "transport_paper/Working_notebooks/plug_test/plug_test.py --tail") <fig-tail>

== Reproducing this <app-repro>

`transport_paper`, branch `analysis/plug-test`, with the repository's `.venv`; inputs are read from the
main checkout's `fig_outputs/`.

+ `python Working_notebooks/plug_test/plug_test.py --selfcheck` checks the draws against their closed forms.
+ `python Working_notebooks/plug_test/plug_test.py --noisy` (about 3 min) fits the noisy plug; `--combined`,
  `--duration` and `--tail` run the two-part spread fit, the duration scaling and the widest-spread edges.
+ `streak_times.py` in the `flow_analysis_comps` venv re-detects the streaks with times, then `plug_test.py --windows` runs the time-window check.
+ `python Working_notebooks/plug_test/plug_test.py` writes `per_edge.csv`, `summary.csv`, `pooled.csv`, the
  Poiseuille-mode figures and prints the tables (`run.log`); about 30 s on a laptop.

#block(breakable: false, table(
  columns: (1.4fr, 2.4fr, 0.9fr, 0.9fr), align: left, stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*campaign*], [*input*], [*ran*], [*input survives*],
  table.hline(stroke: 0.4pt),
  [model terms], [`fig_outputs/model_grid/junction/global_gimf_gimf_minedge20_keras_ratio_fb/edges_*.csv`], [2026-10-15], [yes, local, not in git],
  [streaks], [`fig_outputs/streaks/<store>/plate_streaks.csv`; edge-to-video map `fig_outputs/pixel_tip_root/pixel_entries.csv`], [before 2026-10-14], [yes, local],
  [regime, tip distance], [`fig_outputs/flow_regime/edges.csv`, `fig_outputs/model_accuracy/features_edges.csv`], [2026-10-14], [yes, local],
  [synthetic plug], [`fig_outputs/synthetic_streak_ceiling/results_BF.csv`], [before 2026-10-10], [yes, local],
  [streak times], [raw orientation tensors in `paper_plates/<store>/polyflow_data/` (7 sessions) and on Snellius `prjs1583/storage/videos/` (6 sessions)], [2026-10-22 / 2026-10-23], [yes; output in git],
  [this comparison], [the above], [2026-10-22], [outputs in git],
  table.hline(stroke: 0.6pt),
))

== References

#bibliography("references.bib", title: none, style: "apa")
