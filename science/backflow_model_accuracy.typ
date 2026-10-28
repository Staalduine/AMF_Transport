// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// ---------------------------------------------------------------------------

#set document(
  title: "Backflow model accuracy — where the pressure-solve model tracks measured backflow, and what a simpler model does",
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
#show raw: set text(font: "Menlo", size: 8.5pt)
#show link: set text(fill: rgb("#8a5a10"))
#show table: it => {
  set par(justify: false)
  it
}

#let dead = box(fill: rgb("#f6dedb"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#8a2f22"),
  weight: 600,
  "DEAD",
))
#let open = box(fill: rgb("#eceff0"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#4a5459"),
  weight: 600,
  "OPEN",
))

#let fig(path, cap, src: none, width: 94%) = figure(
  image(path, width: width),
  caption: text(8.5pt, fill: luma(95))[
    #cap
    #if src != none [ #text(fill: luma(140))[#raw(src)]]
  ],
)
#show figure.caption: set align(left)
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt), stroke: (left: 2pt + luma(160)), text(
  11pt,
  style: "italic",
  fill: luma(60),
  body,
))

#let note(body) = block(
  fill: rgb("#f7f8f8"),
  stroke: (left: 2pt + rgb("#d9a441")),
  inset: 9pt,
  radius: 2pt,
  width: 100%,
  text(9pt, body),
)

#let F = "figures/backflow_model_accuracy/"

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Backflow model accuracy]
  #v(-0.3em)
  #text(14pt, weight: 600)[Where the pressure-solve model tracks measured backflow, and what a simpler model does]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · 1,558 measured brightfield edges and 28 hand-drawn trails over 12 video sessions on 4 plates · \@d40df6e \
    from @sec-zero-net on: 1,567 streak-measured edges over 15 sessions on 5 plates · \@57703f7
  ]
]
#v(1.2em)

#outline(depth: 2, indent: 1em)

= Introduction <sec-intro>

#question[The transport model predicts, for every hypha in a growing colony, how fast material flows back towards the colony's origin. Measured against video on twelve sessions, does the pressure-driven flow, shaped by network geometry, remain accurate beyond the last centimetre behind a growing tip, where does each interpretation fail, can a simpler local model do as well, and does it at least get the range of backflow speeds right?]

We image a growing colony of _Rhizophagus irregularis_ over several days, stitch and segment each timepoint, and extract a network graph whose edges carry the time each piece of hypha appeared. Short videos at fixed positions measure the speed of material moving inside hyphae, in both directions at once. The model takes the network and the growth in the next few frames, routes the material that growth consumes through the network with a pressure solve, and returns a predicted backflow speed for every edge. Inside each hypha, motors carry a lipid stream outward along the wall while pressure drives a return through the core. We test two viable readings of that return: a coupled profile in which the annular and core velocities combine, and independent lanes in which backflow is the core-return flux alone.

This document scores that prediction against measured brightfield backflow on 1,558 edges over 12 sessions on 4 plates, and against the 28 trails a curator traced from a root to a tip. It asks four things, in the order a user of the model's figures would: whether the prediction holds at least 10 mm behind the tip, where and why it fails, whether a simpler model does as well with the same kind of global parameters, and whether the predicted speeds at least cover the measured range.

The short answers. Beyond 2.5 mm from the tip the shipped coupled-profile model is unbiased but no more often within a factor of 2 than a single constant speed. Within 2.5 mm it over-predicts 2.4-fold, because measured backflow drops there and the model does not. It fails where the annular and pressure-driven contributions cancel and on dead-end branches with no growth downstream. The independent-lanes core-return speed improves accuracy, while a bare pressure gradient makes it worse. A tip factor fixes the near-tip level without improving accuracy across the network. The models get the median speed right, produce a spurious slow tail in the shipped output, and do not rank sessions by their typical backflow.

The last four sections rescore the model on 15 sessions with speeds from individual kymograph streaks, and ask how much of its network-wide pressure routing the data need. Letting every hypha carry back exactly its own motor stream, zero net flux, leaves tree edges as they were (94 % within 2×) and lifts loop edges from 78 % to 93 %. The data leave room for at most a few per cent of each loop edge's motor stream as circulation routed through the network. The edges zero net flux misses by more than 2× are short-lived, tied to one recording rather than to a hypha. And the motors run the way the hyphae grew a little more often than the hydraulic solve says (84.8 % against 80.4 % of identifiable edges).

= Motivation <sec-motivation>

The model's per-edge speed is drawn onto every trail map and compared with measurement along trails. A dip or rise the model reproduces along a trail reads as mechanistic agreement. Whether it is depends on questions this document answers: a model that is right only in its median, or only where a constant would also be right, reproduces no local structure, and its agreement along one trail is coincidence.

The second stake is the model's form. It contains a Poiseuille pressure solve, an annulus of motor-driven lipid flow and a lipid speed parameter. If a local rule with one or two global numbers predicts as well, the solve is not earning its complexity, and if one part of either speed interpretation causes most of its errors, that part is what to change. Both need the failures located, not only counted.

= Method <sec-method>

The first two subsections describe the mechanism under test. The rest describe how it is tested.

== The model routes growth demand by a flow solve, then solves a pressure-driven core against a motor-driven lipid stream <sec-model>

=== The first solve routes the water growth consumes from roots to tips

The network is reduced to junction-to-junction edges, each an undirected tube with Poiseuille conductance $pi r^4 \/ 8 mu L$, radius $r$ from segmented width. Every node where growth attaches in the next 4 frames (the growth window) draws a fixed volume: the volume grown there over that window. Annotated root nodes are coupled to a near-zero reservoir pressure. Solving the network pressure-balance equations gives each edge a flux $Q$ and a pressure difference; this is the growth-induced mass flow, GIMF @heatonGrowthinducedMassFlows2010. The model has no built-in direction: it follows from where the roots and the growing nodes are, and inside a loop it can point against the order in which the hyphae grew.

=== The second solve turns lipid flux into a core backflow speed

The sign of the lipid share of $Q$ sets the motor direction on each edge, at the default lipid speed $v_0 = 3$ µm/s, with lipid fraction $theta = 0.15$. The motor-driven lipid stream occupies an annulus between inner radius $a$ and outer radius $b$; $a$ is solved from the lipid flux. A second pressure solve on core conductance $pi a^4 \/ 8 mu L$, driven by the motor source and coupled to the roots, gives the pressure difference $Delta p$ that drives the core: theory for elongated cells derives such a pressure-driven counter-flow in the core from a wall-driven stream @htetAnalyticalMethodsCytoplasmic2025, and pressure-driven mass flow is observed directly in fungal hyphae @lewMassFlowPressuredriven2005. In the coupled-profile interpretation, the centreline velocity is

$ v_"center" = v_0 - v_"press", quad v_"press" = a^2 Delta p \/ 4 mu L, $

where $v_"press"$ is the signed pressure-driven velocity scale. The shipped output is $abs(v_"center") times 2\/3$, and it can represent backflow when the pressure-driven return makes the total profile reverse. Two properties matter below. First, an edge with no growth downstream carries zero flux, so the motor source and the pressure-driven return both vanish under the shipped convention. Second, the coupled-profile output is a difference of two terms of similar size, so it can cancel towards zero when $v_"press"$ is close to $v_0$. On measured edges the annulus is nearly empty: median $a\/b$ is 0.975 (interquartile range 0.94–0.993, n 1,522). The two streams run side by side in lanes rather than as this coaxial core, as #link("radial_flow_structure.typ")[the radial flow structure document] shows directly.

=== The trail maps show two thirds of the centreline speed, and so does this document

The trail maps plot $abs(v_"center") times 2\/3$, and that quantity is what this document calls the shipped model, uncalibrated. The factor $2\/3$ is the analytical average of the positive reverse-flow part of the Poiseuille profile. The pressure-driven scale is recovered from the exported speeds as $v_"press" = 2(v_"mean" - v_"center")$, and $v_0 = 2 v_"mean" - v_"center"$, which is 3 µm/s on every edge with flux and 0 on every edge without. The later measured-forward-flow variant uses $v_0 = 2.87$ µm/s instead.

== Measured backflow is the brightfield speed against the growth direction <sec-measured>

Each measured edge carries median speeds per direction of travel and per imaging channel. The growth chronology orients each edge away from the nearest annotated root, and backflow is the component moving towards the root, as defined in #link("direction_resolved_backflow.typ")[the direction-resolved backflow document]. Brightfield backflow is the target throughout. It follows the centre of the hypha, which is what the coupled-profile centreline velocity models; fluorescence follows lipids and is used as a check, in @sec-fluorescence. On a trail, a segment's measured value is the median over the videos covering it.

The data are 12 sessions: `EPY2412A088` t28 and t55, `LPD2412A025` t25, t36 and t50, `PNF2307A072` t37 and t49, and `STR2307A112` t25, t38, t49, t60 and t73. Each plate was imaged every two hours, and each video at network time $t$ was paired with the network truncated at $t + 4$. Thus the growth window is $t$ to $t + 4$. They yield 1,558 measured brightfield edges and 28 trails with 661 measured trail segments. Sessions of one plate share hyphae, so the 12 sessions are not 12 independent samples. `LPD2412A025_t36` has no model output, because its trail component has no root, and is scored only by models that do not use the solve. θ = 0.15 on every session.

From @sec-zero-net on the data are 15 sessions: the 12 above and `PNF2307A080` t74, t81 and t91. Speeds are the median and quartiles of individual kymograph streaks faster than 1 µm/s, from videos with at least 5 streaks per direction, and the two streams of an edge are labelled by the motor-stream test of @sec-zero-net-method rather than by the growth direction alone. They give 1,567 measured brightfield edges: 220 tree edges, bridges of the network at the session, and 1,347 loop edges. The checks in @sec-fast ran on the same tables before the growth-graph fix of @sec-motor-direction, which added 4 edges (1,563 then).

== A tip is where the trail ends at the session, or a growing dead end of the network <sec-tip>

Two definitions of tip are used, and each is named wherever a distance appears.

- The trail tip: the furthest segment of a hand-drawn trail that exists at the session, not in the anchor frames 4 frames later. Distance to it is measured along the trail. This uses the annotation, which the model does not have.
- A growing apical tip: a dead end of the session network (one incident edge present at the session) that is not a root and has an edge grown onto it within the growth window. Distance to the nearest one is the shortest path through the session network. It needs no annotation. It differs from the model's growth-window nodes, which include every node where a new branch leaves an old hypha. Of the 28 trail tips, 25 are growing apical tips and all 28 are dead ends; every trail segment within 2.5 mm of its trail tip is also within 2.5 mm of an apical tip.

== Every alternative model uses one global set of parameters, fitted on the other sessions <sec-held-out>

Every model except the shipped one fits one to three numbers: a scale, an exponent, a decay length. For each session they are fitted on the other 11 sessions, which are excluded from fitting for that test session, and applied unchanged, so no session or trail informs its own prediction and no per-plate intercept exists anywhere. The fitted numbers barely move between these exclusions: the scale on the core-return plug speed spans 0.86–0.88 across the 12 sessions, the calibrated shipped scale 1.12–1.19. The models, with their fitted parameters:

#table(
  columns: (auto, 1fr, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  table.header[*model*][*prediction per edge*][*fitted*],
  [shipped], [$abs(v_"center") times 2\/3$], [none],
  [shipped, calibrated], [$c abs(v_"center") times 2\/3$], [$c$],
  [core-return plug speed],
  [$c hat(v)$, $hat(v) = abs(q_c) \/ (pi a^2)$ the core's return flux over its cross-section],
  [$c$],

  [pressure gradient], [$c abs(Delta p_"GIMF") \/ L$], [$c$],
  [local plug], [$c F \/ "area"$, $F$ the window growth reachable downstream along the growth DAG, no solve], [$c$],
  [demand law], [$c F^beta$ where $F > 0$, unpredicted where $F = 0$], [$c, beta$],
  [width law], [$c w^k$], [$c, k$],
  [demand + width law], [$c F^beta w^k$, the width law where $F = 0$], [$c, beta, k$],
  [constant], [the median measured backflow of the other sessions], [$c$],
  [kinematic], [$c$ × measured forward speed on the same edge], [$c$],
  [base × tip factor], [any base × $g(d) = 1 - e^(-d\/lambda)$, $d$ a tip distance], [base, $lambda$],
)

The kinematic model uses a measurement on the edge it predicts, so it is not a prediction from the network. It is a ceiling: how well any local rule could do if it knew the forward speed. $lambda$ is chosen from a grid of 250 µm to 6 mm by the same sessions-excluded-from-fitting procedure.

== Bias, share within 2×, along-trail rank correlation and the speed distribution score a model, and each can mislead <sec-metrics>

All errors are ratios of predicted to measured speed. Before taking logs every prediction is floored at 0.1 µm/s, below the measured 5th percentile of 0.39 µm/s, because the shipped model outputs zero (below 10#super[−9] µm/s) on 105 edges and a raw log error there is infinite. The number of floored predictions is reported beside each model.

- Bias: the median of predicted / measured, as a ratio. 1 is unbiased. It says nothing about scatter.
- Within 2×: the share of edges whose ratio lies between 0.5 and 2. This is the headline accuracy. It cannot tell a model that tracks variation from a constant close to the median, which is why the constant is always reported beside it.
- Trail shape: the Spearman rank correlation of predicted with measured along one trail, taken as monotone, median over trails. Restricted to the first 10 mm behind the trail tip it is labelled "within 10 mm". Ranks see order only, so a model can score high here while its amplitude is wrong. The main comparison uses trails with at least 6 measured segments; the tip-factor comparison (@sec-tip-factor) uses at least 8, which moves the shipped model from +0.32 to +0.34.
- Distribution: percentiles of predicted and measured speed over all edges, the ratio p95/p5 as the spread, and the two-sample Kolmogorov–Smirnov distance (KS, 0 for identical distributions).

== Zero net flux gives each edge its own motor stream back; a blend and a junction measure test the rest <sec-zero-net-method>

=== The global model's return circulates on loops

The motors drive a volume flux $q_s = pi v [(1 - theta)(b^2 - a^2) + a^2]$ outward along each edge, $v$ the local motor speed. The second solve returns it: a pressure solve on the core conductances whose sources are the divergence of $q_s$ at each node. On a tree its solution is $q_s$ on every edge, whatever the conductances. On a loop it can route the return around the cycle, so an edge carries back more or less than its own motors carry out, and the difference circulates. This is the global model; the net flux of an edge is its motor stream minus its return.

=== Zero net flux returns each edge's own stream

Zero net flux sets every edge's return to its own $q_s$, with no second solve (`--zero-net-flux`), the network implementation of the two independently driven plug lanes tested directly in #link("lane_flux_balance.typ")[the lane flux balance document]. The to-root speed is the core-return plug speed of that flux, $q_s \/ pi a^2 = v [1 + (1 - theta)(b^2 \/ a^2 - 1)]$. Both models run in the paper configuration: motor speed from the fitted forward-speed profile, motors on zero-flux edges, one motor direction per hypha voted from the GIMF flux, $theta$ = 0.05, and the core-radius floor $a >= 0.8 b$. With that floor the to-root speed is at most 1.53 $v$.

=== A blend measures how much global routing the data allow

Per edge the return is $q_s + kappa (q_"global" - q_s)$: $kappa$ = 0 is zero net flux and $kappa$ = 1 the global model, with every other term from the same run. It is scored on loop edges, where the two differ, by log RMSE and median |log error| over $kappa$ from −0.5 to 1.5 in steps of 0.05; the 95 % interval of the best $kappa$ comes from resampling whole sessions, 15 clusters. A negative $kappa$ has no physical meaning and only bounds the fit from below. The slope of ln(measured / zero net) on ln(global / zero net) is the same question linearised.

=== The junction speed term compares each model's speeds across a junction

At a junction with every leg measured, each leg's two lanes are taken to carry the same volume, $Q = pi \/ 4 dot d^2 H(v_"tip", v_"root")$ with $H(x, y) = x y \/ (x + y)$ and $d$ the leg's diameter measured in the video. The speed term is the area-weighted $H$ on the legs whose motors run into the junction over that on the legs whose motors run out. Putting each model's own speeds through the same measure, with the same diameters and roles, gives what that model predicts the data would show. The measure and the junctions are those of `Notes/conveyor_junctions.typ` in transport_paper.

=== The motor-stream test labels which stream is motor-driven

A stream is motor-like when its streak median lies within 25 % of 3.06 µm/s and its quartile ratio q75/q25 is at most 1.25. Where the stream the growth graph labels to root is motor-like and the one labelled to tip is not, the labels are swapped. An edge's motor direction is identifiable when exactly one of its streams is motor-like, and the direction of that stream is the observed motor direction.

=== A spurious source is where growth appears to start away from the roots

The growth graph orients each segment from the neighbour it grew from, by activation date (`build_growth_dag_from_activation`). A non-root source is a node with no incoming segment that is not an annotated root; one farther than 2 mm along the network from every root is counted as spurious, while sources near the roots, at the bottom of the colony, are accepted. Reach is the share of network length whose growth history traces back to a root or to a source within 2 mm of one.

== The comparison runs in six steps <sec-steps>

+ Build per-edge and per-trail-segment tables with the model's terms, the tip distances, downstream demand, bridges and distance to straight axis-aligned chains that may be stitching seams. This fixes the data every later step scores.
+ Score the shipped model against distance to the trail tip. This answers whether it holds 10 mm behind the tip.
+ Split its errors by the model's own internal terms, cancellation and pressure gradient, and by network position. This locates the failure instead of counting it.
+ Score the simpler models with sessions excluded from fitting, including tip factors, and run the solver with a tip throttle. This tests whether the failure can be removed and what it costs.
+ Compare the distributions over all edges. This asks whether the model is useful in aggregate even where it is not locally.
+ On the 15-session streak data, replace the pressure-routed return with zero net flux, bound what is left for the routing with the blend and the junction measure, and check the motor directions the model is given against the observed ones. This asks whether the network routing earns its place.

= Results <sec-results>

The first two sections answer where the model is accurate along a trail, the next two where and why it fails. The rest turn from diagnosis to repair: simpler models, the measured annulus, the core-conductance exponent, tip factors, the aggregate range, and a check in fluorescence. The last four move to the 15-session streak data and ask what the network routing adds.

== On streak measurements the core-return plug speed matches the measured distribution; the throttled shipped model runs low <sec-two-models>

@fig-two-models compares the two models the derivation document describes, the throttled shipped output and the core-return plug speed, against brightfield backflow measured from individual kymograph streaks (pixel percentiles where no raw orientation data exist). Over every measured edge the plug speed reproduces the measured percentiles from the 5th to the 90th and gives 10 edges zero output; the shipped output lies below the measured distribution up to about the 90th percentile and gives 91 edges zero output. Along trails both follow the measured decline over the last 5 mm. Within 10 mm of the tip the plug speed is within 2× on 84 % of segments with bias 0.96, the shipped output on 81 % with bias 0.84. A constant, the median of the other sessions, is within 2× on 82 % of all edges and 84 % of those trail segments: on these narrower streak measurements neither model beats it on level, and what they add is the along-trail shape.

#fig(F + "fig_two_models.png", [Measured brightfield backflow against the two models: the shipped output $|v_"max"| times 2\/3$ with the motor throttle ($v_0$ = 3 µm/s, $lambda$ = 0.5 mm, orange) and the core-return plug speed $|q_c| \/ pi a^2$ ($v_0$ = 2.87 µm/s, $lambda$ = 749 µm, blue), both with the exponential throttle $g(d) = 1 - e^(-d\/lambda)$. Measured speeds are the median and quartiles of individual kymograph streaks; in the 4 sessions without raw orientation data they are filtered-pixel percentiles. (a) Distribution over every measured edge with model output (1,248 edges in 11 sessions; the backflow model gives no output on LPD2412A025_t36; grey bars: measured); speeds of 10 µm/s and above fall in the last bin. The shipped model gives 91 edges zero output, the plug speed 10. (b) Percentiles of the same distributions from the 1st to the 99th, dots at the 5th, 25th, 50th, 75th and 95th. (c) Measured against the shipped model on the 232 trail segments within 10 mm of the trail tip: within a factor of 2 on 81 %, bias (median ratio of predicted to measured) 0.84. (d) The same for the plug speed: within 2× on 84 %, bias 0.96. In both, vertical bar: 25th–75th percentile of the streak speeds of the videos covering the segment; horizontal bar: range of the prediction over the trail's segments within ±0.5 mm; grey wedge: within 2×; line: identity. (e) Backflow on trail segments against distance to the trail's tip at the session, in bins of 0–1, 1–2, 2–3, 3–5, 5–7.5, 7.5–10, 10–15 and 15–20 mm holding 4, 16, 23, 56, 63, 70, 95, 89 measured segments; line: bin median, band: 25th–75th percentile (grey for measured, tinted in each model's colour). (f) The session network of EPY2412A088_t55 with trail Main (black), its tip at the session (star) and the annotated roots (circles), in image coordinates. (g) Backflow along Main (31 measured segments, bar: 25th–75th percentile) with both predictions. The shipped model is within 2× on 97 % of segments with median |log₂ error| 0.33, the plug speed on 97 % with 0.16.], src: "transport_paper/Working_notebooks/model_accuracy_two_models.py", width: 82%) <fig-two-models>

== Beyond 2.5 mm from the trail tip the model is unbiased but no better than a constant <sec-far>

Along trails, the shipped model's bias is 0.92–1.20 in every band beyond 2.5 mm, and 66–74 % of segments are within 2× (@fig-tip, left; table below). So it is accurate at least 10 mm behind the tip in the sense of being unbiased. It is not accurate in the sense of tracking variation. A constant speed is within 2× as often between 2.5 and 10 mm (76–80 %), and only beyond 10 mm does the shipped model edge ahead (66–68 % against 61–64 %), where the constant, fitted on all edges, runs low on trails. Along a trail, the shipped model's rank correlation with measurement is +0.32 within 10 mm of the tip over 22 trails, and +0.08 beyond 10 mm over 18.

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right),
  table.header[*from trail tip (mm)*][*segments*][*shipped bias*][*shipped within 2×*][*core within 2×*][*constant within 2×*][*kinematic within 2×*],
  [0–2.5], [34], [2.40], [0.41], [0.26], [0.35], [0.62],
  [2.5–5], [84–87], [1.05], [0.67], [0.75], [0.80], [0.76],
  [5–10], [160–172], [0.99], [0.74], [0.80], [0.76], [0.87],
  [10–20], [239], [0.92], [0.66], [0.70], [0.64], [0.85],
  [> 20], [129], [1.20], [0.68], [0.72], [0.61], [0.77],
)

Segment counts differ slightly by model because an edge whose model term is undefined is not scored. Every trail is drawn in @sec-app-trails.

#fig(
  F + "fig_q1_tip_distance.png",
  [Log₂ of predicted over measured backflow on the 661 measured trail segments over 28 trails, against distance from the trail's tip at the session, for the shipped model (left) and the core-return plug speed with one held-out scale (right). Line: median in 2 mm bins; grey: interquartile range; dotted lines: a factor of 2; dashed line: 10 mm.],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
) <fig-tip>

== Within 2.5 mm of the trail tip measured backflow drops and the model does not <sec-near>

Measured backflow on trails falls from a median of 3.71–3.98 µm/s at 5–20 mm to 0.91 µm/s at 1–2.5 mm (29 segments) and 0.68 µm/s within 1 mm (5 segments). The shipped model stays at 2.26–2.58 µm/s, so within 2.5 mm (34 segments over 13 trails in 8 sessions) it over-predicts 2.4-fold and only 41 % of segments are within 2×. Every model without a tip term fails the same way, the constant included (bias 2.95). The one that does best, the kinematic model, is still biased 1.40, because forward speed also drops near the tip (median 1.81 µm/s at 1–2.5 mm) but less than backflow: backflow / forward is 0.76 there against 1.11–1.35 beyond 2.5 mm. The failure is concentrated: per trail within 10 mm, the shipped bias exceeds 1.8 on `LPD2412A025_t25` Right (2.68), `STR2307A112_t25` Left (2.00) and Right (2.42), `STR2307A112_t38` RightUp (1.86), `STR2307A112_t60` LeftHigh (1.82) and `PNF2307A072_t37` Right (1.94), and is below 0.5 on `STR2307A112_t49` LeftHalf (0.38) and `STR2307A112_t73` LeftFLat (0.47).

Width does not carry the decline. Median width on trail segments is 10.25 µm at 1–2.5 mm against 11.5–11.9 µm at 5–20 mm, 14 % narrower, while measured backflow is 4 times slower.

== The model fails where its lipid-stream speed cancels its core speed, and on dead-end branches <sec-breakdown>

Three conditions account for most of the shipped model's error over all 1,558 edges (@fig-breakdown).

=== Cancellation: where the core speed is under twice the lipid speed, the prediction collapses

Of the 1,558 edges, 105 get zero output; the remaining 1,453 have a ratio $abs(v_"center") \/ v_"press" = 1 - v_0\/v_"press"$, which is below 0.5 whenever $v_"press" < 2 v_0 = 6$ µm/s. That holds on 491 of them (34 %).

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right),
  table.header[*$abs(v_"center") \/ v_"press"$*][*edges*][*shipped / measured, median*][*shipped within 2×*][*core within 2×*],
  [0–0.25], [177], [0.15], [0.07], [0.60],
  [0.25–0.5], [314], [0.51], [0.43], [0.69],
  [0.5–0.75], [816], [1.12], [0.71], [0.71],
  [0.75–1.01], [93], [1.34], [0.29], [0.40],
  [> 1.01], [53], [1.03], [0.58], [0.21],
)

Where cancellation is strongest the shipped model reads 0.15 of measured and 7 % of edges are within 2×. The core-return plug speed alone, on the same edges, is within 2× on 60 %. Over all edges the log residual of the shipped model rises with the cancellation ratio (Spearman +0.48, n 1,453); for the core-return plug speed it barely does (+0.13). The cancellation is a property of the model, not the data: nothing measured drops where $v_"press"$ happens to approach 3 µm/s.

=== Dead ends: 106 measured edges lie on branches that grow nothing, and the model gives almost all of them zero

The window growth reachable downstream along the growth DAG, $F$, is zero on 661 of 1,558 edges, but most of those are not dead ends. Classifying each one by the session network itself: 550 lie in loops, 106 are bridges (edges whose removal disconnects the network) with no window growth on the side away from the roots, and 5 are bridges with growth beyond them.

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right),
  table.header[*edge class*][*edges*][*measured median (µm/s)*][*shipped / measured*][*shipped within 2×*][*zero output*][*core within 2×*],
  [$F > 0$], [897], [2.92], [1.02], [0.62], [1], [0.69],
  [$F = 0$, in a loop], [550], [2.34], [0.62], [0.45], [7], [0.64],
  [$F = 0$, dead-end bridge], [106], [2.00], [0.05], [0.09], [97], [0.10],
  [$F = 0$, bridge with growth beyond], [5], [2.17], [1.13], [0.75], [0], [0.75],
)

The dead-end failure is real and confined: 97 of the 105 zero outputs are on the 106 dead-end bridges, which carry no GIMF flux, and measured backflow there is 2.00 µm/s. The core-return plug speed does no better on them, because the core flux is zero too. The 550 loop edges with $F = 0$ do carry flux (median $|Q|$ 4.83 against 13.49 on edges with $F > 0$), and there the core-return plug speed is within 2× on 64 %. Their $F = 0$ is an artefact of orientation. Along the 28 trails the Growth DAG points back towards the root on 76 runs of consecutive segments, only 1 of which sits in a period when activation changes; the rest lie in periods when the timestamps do not distinguish order and the orientation falls back to hop distance from the roots. An edge upstream of a reversal reaches no growth, which is why $F$ is zero over the root end of most STR trails. What the dead ends carry does not look like a missing term tied to them. The 97 dead-end bridges whose branch could be traced lead to short branches, median 167 µm (interquartile range 34–545 µm), and carry backflow and forward flow in the same ratio as the network as a whole (median backflow / forward 0.99 against 1.07). Their backflow does not depend on how long ago the branch stopped growing, except for branches that grew within the last 4 frames: 0.92 µm/s over 16 edges, against 1.98–2.03 µm/s for older ones. The classification and these numbers are `model_accuracy_demand_audit.py`.

=== Seams and the empty annulus contribute less

The 130 edges within reach of a candidate stitching seam read 0.62 of measured against 0.85 elsewhere. The residual also correlates with $a\/b$ (Spearman −0.37 signed, n 1,522). A seam explains one feature on one trail: on `PNF2307A072_t49` Middle, removing the horizontal seam candidate from the network lowered the model's jump at 19 mm from 7.74 to 6.01 µm/s (measured 4.08), while removing the vertical one left the model's dip at 11–15 mm unchanged (0.57 to 0.61 µm/s). That dip is cancellation: $v_"press"$ is 2.2–2.8 µm/s there against $v_0 = 3$, and width does not change (12.6 µm). This ablation was a one-off on one trail and is not part of the committed scripts.

#fig(
  F + "fig_q2_breakdown.png",
  [Left: log₂ of shipped over measured backflow against $abs(v_"center") \/ v_"press"$ on the 1,453 measured edges with non-zero output; the column at 1.5 collects ratios above 1.4. Middle: the same residual for the shipped model and the calibrated core-return plug speed against log₁₀ of the GIMF pressure difference per µm. Right: log₁₀ measured and shipped backflow against the same gradient.],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
) <fig-breakdown>

== Pressure affects the error only through that cancellation; measured backflow barely rises with pressure gradient <sec-pressure>

Split into quintiles of the GIMF pressure gradient, measured backflow rises from a median of 2.25 to 3.28 µm/s, 1.5-fold. The shipped model rises from 1.39 to 3.57 µm/s, 2.6-fold, and its within-2× share from 41 % to 63 %. The core-return plug speed with one scale rises from 2.13 to 3.62 µm/s, close to measured. So the steep pressure dependence of the shipped model comes from cancellation at low gradient, where $v_"press"$ is small against $v_0$. A pressure-sign reversal next to a trail segment (7 % of segments) changes nothing: 66 % within 2× on both.

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right),
  table.header[*gradient quintile*][*edges*][*measured median (µm/s)*][*shipped median (µm/s)*][*core median (µm/s)*][*shipped within 2×*],
  [1, lowest], [286], [2.25], [1.39], [2.13], [0.41],
  [2], [285], [2.51], [1.87], [2.47], [0.49],
  [3], [285], [2.68], [2.26], [2.79], [0.59],
  [4], [285], [2.68], [2.50], [2.96], [0.61],
  [5, highest], [286], [3.28], [3.57], [3.62], [0.63],
)

== Dropping the model's lipid-stream term helps; a bare pressure gradient does worse <sec-simpler>

Held out over all edges (@fig-models), the core-return plug speed is within 2× on 63 % of edges, against 52 % for the shipped model with or without calibration. Calibration moves the shipped scale only 1.12–1.19, so its problem is shape, not level. The pressure gradient alone drops to 37 %, with a trail-shape correlation of +0.06. The local plug, downstream demand over area with no solve at all, reaches 43 % on the 886 edges with demand.

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right),
  table.header[*model, held out*][*edges scored*][*floored*][*within 2×*][*trail shape, all*][*within session*],
  [shipped], [1,522], [127], [0.52], [+0.17], [+0.28],
  [shipped, calibrated], [1,522], [126], [0.52], [+0.17], [+0.28],
  [core-return plug speed], [1,522], [108], [0.63], [+0.20], [+0.30],
  [pressure gradient], [1,532], [137], [0.37], [+0.06], [+0.20],
  [local plug, demand / area], [886], [66], [0.43], [+0.14], [+0.35],
  [demand law], [897], [0], [0.72], [+0.45], [+0.43],
  [width law], [1,546], [0], [0.71], [+0.18], [+0.33],
  [demand + width law], [1,546], [0], [0.73], [+0.26], [+0.38],
  [constant], [1,558], [0], [0.71], [–], [–],
  [kinematic], [1,558], [8], [0.80], [+0.47], [+0.57],
)

"Within session" is Spearman over all edges of one session, median over sessions. The laws with one or two global numbers tie the constant on within-2× (71–73 %). The shipped model is below the constant on 10 of 11 sessions with model output; the exception is `EPY2412A088_t55` (80 % against 72 %). Only the kinematic ceiling beats the constant (80 %).

The demand law has the best trail shape of the network-derived models (+0.45 over all of a trail, +0.67 within 10 mm), and it has it without amplitude. Its fitted exponent is 0.14–0.19 across folds, so its predictions move little: in the root-most 10 % of trail length it predicts a median 3.00 µm/s and in the tip-most 10 % 2.44, while measured is 3.02, 4.51 at 10–25 % of trail length, and 0.95 at the tip end. Downstream demand falls almost monotonically towards a trail's tip, so its ranks are the ranks of tip distance. At the root end the prediction is carried by the few segments with $F > 0$, since orientation reversals set $F$ to zero on most of them (@sec-breakdown).

#fig(
  F + "fig_q3_models.png",
  [Held-out comparison over the 1,558 measured brightfield edges in 12 sessions. Left: share of edges within a factor of 2 of measured. Right: median over trails of the Spearman correlation between prediction and measurement along the trail; the constant has none.],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
) <fig-models>

== Fixing the annulus at its measured ratio removes the cancellation but not the error <sec-annulus>

The annulus the model solves is nearly empty: median $a\/b$ is 0.975 on measured edges. #link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[The annulus geometry document] measures $a\/b$ at 0.603 from the two video channels, and the model can take that ratio as a constant instead of solving $a$ from the lipid flux. Run that way on all 12 sessions, the pressure-driven scale more than doubles (median $abs(v_"press")$ 14.93 against 6.27 µm/s), the motor speed shrinks relative to it (median $v_0\/abs(v_"press")$ 0.20 against 0.46), and cancellation nearly disappears: 91 of 1,452 edges have $abs(v_"center") \/ abs(v_"press") < 0.5$, against 491 of 1,453.

#table(
  columns: (auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right),
  table.header[*held out, all edges*][*$a\/b$ solved (median 0.975)*][*$a\/b$ = 0.603*],
  [shipped, uncalibrated: bias], [0.82], [2.71],
  [shipped, uncalibrated: within 2×], [0.52], [0.25],
  [shipped, calibrated: scale over folds], [1.12–1.19], [0.35–0.36],
  [shipped, calibrated: within 2×], [0.52], [0.57],
  [core-return plug speed: within 2×], [0.63], [0.61],
  [shipped, calibrated: trail shape], [+0.17], [+0.11],
  [core-return plug speed: bias within 2.5 mm of the trail tip], [3.25], [3.30],
  [constant: within 2×], [0.71], [0.71],
)

With the measured annulus the shipped model over-predicts 2.7-fold and needs a scale of about 0.35. Once scaled it becomes almost the core-return plug speed, and scores like it (57 % against 61 %), still below the constant, with the same near-tip failure and a weaker trail shape. Its 5th–95th percentile spread is 0.10–5.80 µm/s with 7 % of predictions below 0.1 µm/s, the dead-end edges of @sec-breakdown, which no annulus geometry changes. Across sessions the calibrated core-return plug speed's median correlates −0.36 with measured. So the cancellation is a property of the solved geometry, and removing it recovers the core-return plug speed, not a better model.

== A decay factor in tip distance fixes the near-tip level without annotation, but not the trail shape <sec-tip-factor>

Multiplying a base model by $g(d) = 1 - e^(-d\/lambda)$, with $lambda$ fitted held out, gives the following on trail segments (bands by trail-tip distance; trail shape within 10 mm, trails with at least 8 segments). All models here are fitted on trail segments, not on all edges, so the constant is 3.46 µm/s rather than the all-edge median of 2.56 µm/s behind the tables of @sec-far and @sec-near, and its near-tip bias is 4.05 rather than 2.95.

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right),
  table.header[*model on 661 trail segments*][*λ (mm)*][*bias, 0–2.5 mm*][*within 2×, 0–2.5 mm*][*within 2×, all*][*trail shape*],
  [shipped], [–], [2.40], [0.41], [0.67], [+0.34],
  [constant], [–], [4.05], [0.18], [0.76], [–],
  [constant × g(trail tip)], [2], [1.70], [0.50], [0.82], [+0.61],
  [constant × g(growing apical tip)], [1], [1.78], [0.53], [0.80], [+0.33],
  [constant × g(any dead end)], [0.25], [3.77], [0.18], [0.73], [+0.07],
  [core-return plug speed], [–], [3.05], [0.35], [0.73], [+0.34],
  [core × g(trail tip)], [1.5], [1.48], [0.56], [0.74], [+0.46],
  [core × g(growing apical tip)], [0.5], [2.16], [0.50], [0.74], [+0.40],
)

Distance to the trail tip is an upper bound, because it uses the hand-drawn trail. Measured to growing apical tips, which the network alone provides, the factor keeps nearly all of the near-tip correction (bias 1.78 against 1.70) and loses the trail shape (+0.33 against +0.61): along a trail, distance to the nearest apical tip also drops wherever a side branch grows nearby, so it does not fall steadily towards the trail's end. Measured to any dead end, stalled ones included, it does nothing, and the fit pushes $lambda$ to the grid's minimum. The decline belongs to growing tips.

Over all edges the decline is real but shallower (@fig-decline, right): measured backflow is 1.35 µm/s within 1 mm of a growing apical tip (125 edges) and 2.29 µm/s at 1–2.5 mm (319), against 2.83–2.89 µm/s at 2.5–10 mm; forward speed falls with it (1.66 µm/s within 1 mm), and $abs(v_"press")$ does not (6.18 µm/s within 1 mm, 6.07–6.52 µm/s beyond). The constant with the apical-tip factor removes most of the near-tip bias (1.29 to 1.08 within 2.5 mm) and does not change accuracy: 72 % within 2× against 71 %.

The decline is deeper on trails because trails follow the fastest-growing tips and run along the tip's own hypha, while most edges near a growing tip are neither. Of 2,557 growing apical tips over the 12 sessions, the 25 that end a trail extended by a median 3,966 µm over the growth window against 280 µm for all tips, the 93rd percentile within their session (lowest: 43rd). Measured edges on a tip's own unbranched hypha, from the tip back to the first junction, carry a median 1.01 µm/s within 1 mm (15 edges) and 0.99 µm/s at 1–2.5 mm (4 edges), against 1.35 and 2.29 µm/s on the other edges at the same distance (110 and 315). Growth speed of the nearest tip on its own tells little: over the 444 edges within 2.5 mm its Spearman correlation with backflow is −0.17, against +0.37 for distance, and only 11 of those edges have a top-decile tip as their nearest. The own-hypha comparison rests on 19 edges. The classification is `model_accuracy_tip_growth.py`.

#fig(
  F + "fig_tip_decline.png",
  [Median speed per distance band. Left: the 661 measured trail segments over 28 trails, by distance to the trail's tip at the session. Right: the 1,558 measured brightfield edges over 12 sessions, by distance through the network to the nearest growing apical tip; no measured edge lies beyond 20 mm. Series: measured backflow, the shipped model, and the shipped model with the lipid speed throttled inside the solver (@sec-throttle) at $lambda$ = 1 mm and 0.5 mm.],
  src: "transport_paper/Working_notebooks/model_accuracy_tip.py",
) <fig-decline>

== Slowing the model's motors within 0.5 mm of growing tips fixes near-tip trails but barely changes the network <sec-throttle>

The model scales $v_0$ on each edge by a factor in [0, 1] of the distance to the nearest tip, before the second solve. Here it is driven by $g(d)$ with $d$ the network distance to the nearest growing apical tip, no dependence on demand, and $lambda$ run at 0.25, 0.5, 0.75, 1 and 1.5 mm. Each session excluded from fitting takes the $lambda$, or no throttle, with the lowest median log error over the other 11 sessions. The annulus radius $a$ is still solved at the unscaled $v_0$. Scaling $v_0$ scales the motor flux that drives the second solve, so $v_"press"$ falls with it: within 1 mm of an apical tip, median $abs(v_"press")$ drops from 6.18 to 1.82 µm/s at $lambda$ = 1 mm.

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right),
  table.header[*shipped model*][*trail, bias*][*trail, within 2×*][*trail 2.5–5 mm, within 2×*][*edges, bias*][*edges, within 2×*][*all edges, within 2×*],
  [no throttle], [2.40], [0.41], [0.67], [1.00], [0.46], [0.52],
  [$lambda$ = 0.25 mm], [1.80], [0.59], [0.73], [0.83], [0.48], [0.52],
  [$lambda$ = 0.5 mm, chosen held out], [1.16], [0.68], [0.69], [0.73], [0.48], [0.53],
  [$lambda$ = 0.75 mm], [0.90], [0.65], [0.65], [0.63], [0.46], [0.52],
  [$lambda$ = 1 mm], [0.75], [0.71], [0.61], [0.56], [0.43], [0.51],
  [$lambda$ = 1.5 mm], [0.56], [0.50], [0.51], [0.46], [0.36], [0.49],
)

"Trail" columns are the 34 segments within 2.5 mm of the trail tip unless marked; "edges" columns are the 433 scored edges within 2.5 mm of a growing apical tip. Held-out selection picks 0.5 mm in all 12 folds and never picks no throttle. At that value, on the 34 near-tip trail segments, bias falls from 2.40 to 1.16 and within 2× rises from 41 % to 68 %, without loss at 2.5–5 mm (69 % against 67 %). Across the network the gain is marginal: the 433 edges within 2.5 mm of an apical tip are unbiased without the throttle (1.00) and are pushed low with it (0.73) at the same accuracy (48 % against 46 %), and all edges move from 52 % to 53 % within 2×, median log error 0.65 against 0.66. Longer $lambda$ over-suppresses: at 1.5 mm near-tip trail accuracy falls to 50 % and the network to 49 %.

The same throttled runs give the core-return plug speed at every $lambda$, scored with one scale per held-out session fitted on the other sessions' edges, like the unthrottled one beside it.

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right),
  table.header[*core-return plug speed*][*trail, bias*][*trail, within 2×*][*trail 2.5–5 mm, within 2×*][*edges, bias*][*edges, within 2×*][*all edges, within 2×*],
  [no throttle], [3.25], [0.26], [0.75], [1.21], [0.57], [0.63],
  [$lambda$ = 0.25 mm], [2.10], [0.44], [0.77], [1.04], [0.57], [0.64],
  [$lambda$ = 0.5 mm], [1.52], [0.56], [0.76], [0.94], [0.57], [0.64],
  [$lambda$ = 1 mm], [1.03], [0.56], [0.75], [0.78], [0.57], [0.64],
  [$lambda$ = 1.5 mm], [0.82], [0.71], [0.70], [0.66], [0.54], [0.63],
  [$lambda$ chosen held out], [2.10], [0.47], [0.76], [0.98], [0.57], [0.64],
)

Throttled, the core-return plug speed is the most accurate network model over all edges (64 % within 2×, against 53 % for the throttled shipped model), and it is still below the constant (71 %). The throttle adds one point to it. Near trail tips it helps less than it helps the shipped model: held-out selection picks 0.25 mm in 6 folds and 0.5 mm in 6, because a longer $lambda$ lowers the return near tips and the refitted scale raises it everywhere else (bias beyond 5 mm from the trail tip 1.02 at 0.25 mm, 1.12 at 1.5 mm). The shipped model has no free scale, so its throttle cannot be undone that way.

== Within 10 mm of the trail tip the throttled models match a constant on level and follow the trail's shape <sec-near-scatter>

The first question of this document, whether the model holds 10 mm behind the tip, is answered here for the throttled models, on the 278 measured trail segments within 10 mm of their trail's tip at the session, over 26 trails in 11 sessions. None of these segments has a zero model output. The core-return plug speed's scale and the affine link are fitted on the other sessions.

#table(
  columns: (auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right),
  table.header[*model, trail segments within 10 mm of the tip*][*within 2×*][*bias*][*trail shape*],
  [shipped output, $v_0$ throttle $lambda$ = 0.5 mm, no fitted scale], [0.73], [0.98], [+0.38],
  [core-return plug speed $c hat(v)$, same throttle], [0.77], [1.03], [+0.38],
  [affine in throttled $abs(v_"press")$], [0.77], [0.99], [+0.38],
  [constant], [0.74], [0.99], [–],
)

Trail shape is the median Spearman correlation along a trail, over the 22 trails with at least 6 of these segments. Near the tip the throttle removes the shipped model's over-prediction and the cancellation is rare, so the shipped output is as accurate as the fitted models, within 4 points of each other and of the constant. What separates the models from the constant is the ordering along a trail, which the constant does not have.

The measurement itself is broad. Each video reports a distribution of speeds along its hypha, and the spread between the 25th and 75th percentile has a median ratio of 3.7 across these segments; on 47 % of them it is wider than 4×, the full span of the 2× band (from half to twice the measurement) the accuracy is scored on. The model is much steadier: over ±0.5 mm along the trail its prediction varies by a median factor of 1.38. So a prediction outside the 2× band can still sit inside the segment's own measured spread, and where the model's local range is wide, as at a few junctions on `LPD2412A025_t25`, `LPD2412A025_t50` and `STR2307A112_t49`, it reacts to local structure such as width that the measured speed does not follow. The misses that remain outside their own bars are the slow segments, below about 1 µm/s, on `STR2307A112_t25`, `STR2307A112_t49` and `LPD2412A025_t25`.

#fig(
  F + "fig_trail_scatter_core.png",
  [Measured brightfield backflow against the throttled core-return plug speed $c hat(v)$ ($lambda$ = 0.5 mm, scale fitted on the other sessions) on trail segments within 10 mm of the trail's tip at the session, one panel per session. Vertical bar: from the lowest 25th to the highest 75th percentile of the speed distributions of the videos covering the segment. Horizontal bar: the range of the prediction over the trail's segments within ±0.5 mm along the trail. Grey band: within a factor of 2; line: identity. Panel titles give the segment and trail count, the share within 2× and the median Spearman correlation along a trail (trails with at least 6 segments; – where none has). The shipped output is in @sec-app-scatter.],
  src: "transport_paper/Working_notebooks/model_accuracy_trail_scatter.py",
) <fig-near-scatter>

== With motor speed and throttle length measured from forward flow, the core-return plug speed needs no fit to backflow <sec-measured-model>

Every model above that beats the shipped output fits at least one number to measured backflow. This section removes that fit. Three changes make it possible, each taken from something other than backflow.

=== The forward speed profile fixes the motor speed and the throttle length

Measured forward speed falls towards growing tips as backflow does, so the throttle is fitted to forward speed alone, with $d$ the network distance to the nearest growing apical tip. The solver runs the offset form $v(d) = v_infinity - (v_infinity - v_"tip") e^(-d \/ lambda)$, fitted on 1,054 brightfield edges over 12 sessions: $v_infinity$ = 3.096 µm/s far from tips, $v_"tip"$ = 2.140 µm/s at a growing tip, $lambda$ = 1711 µm, with a held-out median absolute log error of 0.092. The scores in this section come from the earlier exponential form, $v_"fwd" = v_0 (1 - e^(-d \/ lambda))$, which is the offset form with $v_"tip"$ = 0, fitted on every measured edge:

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right),
  table.header[*forward speed, channel and form*][*edges*][*$v_0$ or $v_infinity$ (µm/s), range over held-out folds*][*$v_"tip"$ (µm/s), range over held-out folds*][*$lambda$ (µm), range over held-out folds*],
  [brightfield, offset, the solver's default], [1,054], [3.096 (3.08–3.14)], [2.140 (2.08–2.16)], [1711 (1442–1922)],
  [brightfield, exponential, scored below], [1,547], [2.87 (2.82–2.91)], [0], [749 (589–939)],
  [fluorescence, exponential], [1,175], [2.69 (2.64–2.80)], [0], [323 (213–809)],
)

The brightfield profile is used: brightfield forward speeds are the more reliable measurement, and in the exponential form they cover more edges and both parameters vary less between held-out folds. Both brightfield decay lengths, 749 and 1711 µm, are longer than the 0.25–0.5 mm range held-out selection picked when the throttle was fitted to backflow (@sec-throttle); the fluorescence profile in the exponential form, which follows lipids, gives 323 µm, inside that range. Neither route has seen backflow.

=== An empirical living-edge extension runs motors on zero-flux edges

The model takes motor direction from the sign of the routed growth flux, which leaves edges with zero flux without motors and gives them zero backflow (@sec-breakdown). As an empirical living-edge extension, those edges instead take the outward direction, along increasing network distance from the roots. In the run with the exponential throttle, measured edges with zero core flux fall from 123 to 18, and on the 106 dead-end bridges the prediction goes from zero to a median 2.87 µm/s, against 2.00 µm/s measured, and 71 % are within 2×, against 9 % for the shipped output.

=== The prediction is the core-return plug speed

The core-return plug speed $hat(v) = abs(q_c) \/ (pi a^2)$ is the core's return flux divided by its own cross-section, the speed a plug would need to carry that flux; with a Poiseuille core it equals $abs(v_"press") \/ 2$, half the pressure-driven centreline contribution, on every edge. The prediction is $hat(v)$, from the model run with the measured forward speed profile and motors on zero-flux edges. Nothing in it is fitted to backflow. The scores below are from the run with the exponential throttle, $v_0$ = 2.87 µm/s and $lambda$ = 749 µm.

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right),
  table.header[*prediction*][*within 2×*][*bias*][*inside measured 25th–75th percentile*][*trail shape*],
  table.cell(colspan: 5)[_all 1,522 measured edges with model output_],
  [$hat(v)$, nothing fitted to backflow], [0.68], [1.03], [–], [–],
  [$hat(v)$ with one scale fitted on the other sessions], [0.69], [0.99], [–], [–],
  [shipped output $abs(v_"center") times 2\/3$, same run], [0.56], [0.76], [–], [–],
  [constant], [0.72], [0.99], [–], [–],
  table.cell(colspan: 5)[_278 trail segments within 10 mm of the trail tip_],
  [$hat(v)$, nothing fitted to backflow], [0.76], [1.07], [0.72], [+0.38],
  [$hat(v)$ with one scale fitted on the other sessions], [0.77], [0.99], [0.70], [+0.38],
  [shipped output, same run], [0.70], [0.86], [0.64], [+0.38],
  [constant], [0.74], [0.99], [0.69], [–],
)

"Inside measured 25th–75th percentile" is the share of predictions falling within the segment's own measured spread (@sec-near-scatter), a score that does not penalise a model for the measurement's width. The core-return plug speed matches the model with a fitted scale to within one point on every score, so the fitted scale was carrying nothing a measurement could not supply. The median brightfield forward speed over the assumed 3 µm/s, $2.73 \/ 3 = 0.91$, lies between the scales fitted to backflow on held-out sessions, 0.87 without the throttle and 0.92 with the exponential throttle at 0.5 mm (#link("throttled_core_speed_model.typ")[the throttled core speed model document], the section on the prediction). Near the trail tip the parameter-free prediction places 72 % of segments inside their measured spread, against 69 % for a constant, and orders them along the trail, which a constant cannot. Over all edges a constant is still within 2× more often, 72 % against 68 %. The same run with the fluorescence profile scores within 1 point on each of these.

There is no averaging factor to choose here: $hat(v)$ is the return flux divided by the core's cross-section, so it is that flux's area-mean speed by construction, whatever the video actually reports. Whether the measured speed equals that area-mean, rather than some other average, is the empirical question the table above answers: the held-out scale, 0.87–0.92, sits close to the ratio of measured to assumed motor speed, 0.91, and closer to it than to the 2/3 or 2-fold departures a diameter mean or a centreline mean would imply. The velocimetry averages the video across a fixed band about 75 pixels wide around each hypha, wider than the hypha, before estimating speed from the slope of streaks in the resulting kymograph, and reports percentiles over positions along the hypha and over time; that speed is a streak-weighted mean over a band that includes background, not obviously the plug's cross-sectional mean, so the agreement could still be partly coincidence.

=== Routing the return on $a^3$ or $a^2$ instead of Poiseuille's $a^4$ moves a typical edge by 5–10 % and no aggregate

The core conductance the second solve uses, $G prop a^4$, is Poiseuille's, but the network only constrains how the return is shared between edges, not this exponent. Replacing it with $G = pi a^n a_"ref"^(4 - n) \/ (8 mu L)$, $a_"ref"$ = 4 µm so that $G$ still matches Poiseuille at $a$ = 4 µm, and re-running $n$ = 4, 3 and 2 with everything else unchanged (the exponential throttle at $v_0$ = 2.87 µm/s and $lambda$ = 749 µm, motors on zero-flux edges, prediction $abs(q_c) \/ (pi a^2)$):

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right),
  table.header[*$n$*][*all measured edges within 2×*][*bias*][*trail segs ≤ 10 mm within 2×*][*bias*][*inside IQR*][*trail $rho$*],
  [4], [0.68], [1.03], [0.76], [1.07], [0.72], [0.38],
  [3], [0.69], [1.00], [0.76], [1.01], [0.72], [0.36],
  [2], [0.69], [0.98], [0.77], [0.99], [0.70], [0.36],
)

Edge by edge against $n$ = 4 on 1,591 edges, $n$ = 3 has a median $|$log ratio$|$ of 0.047 (90th percentile 0.170) and a correlation of logs of 0.981; $n$ = 2 has 0.097 (90th percentile 0.354) and 0.963, with a median ratio of 1.000 for both. The return on a given edge is set mostly by that edge's own pump balancing its own core, so how the network shares the return between edges moves individual edges by 5–10 % and leaves every aggregate unchanged; with $a\/b approx 0.975$ on almost every edge, the exponent's main effect is to reweight by width. Poiseuille's $a^4$ is kept as the physically motivated default, not because the data select it over $a^3$ or $a^2$.

== The model gets the median speed right, spreads too low, and does not rank sessions <sec-aggregate>

Over all 1,558 edges, measured brightfield backflow has a median of 2.56 µm/s (interquartile range 1.59–3.75) and a 5th–95th percentile spread of 0.39–6.08 µm/s, a ratio of 15.6 (@fig-aggregate).

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right, right, right),
  table.header[*series (µm/s)*][*p5*][*p25*][*p50*][*p75*][*p95*][*p75/p25*][*below 0.1*][*KS*],
  [measured], [0.39], [1.59], [2.56], [3.75], [6.08], [2.35], [0 %], [–],
  [shipped], [0.10], [0.94], [2.23], [3.51], [5.67], [3.75], [8 %], [0.13],
  [core-return plug speed], [0.10], [1.77], [2.74], [3.58], [4.93], [2.02], [7 %], [0.08],
  [demand + width law], [1.43], [1.83], [2.28], [2.79], [3.65], [1.53], [0 %], [0.25],
  [kinematic], [0.51], [2.06], [2.90], [3.32], [4.90], [1.61], [1 %], [0.15],
)

The shipped model's median is 13 % low and its upper tail is right; its lower tail is spurious. 8 % of its predictions fall below 0.1 µm/s, where fewer than 1 in 20 measurements lie below 0.39, and these are the cancellation and dead-end edges of @sec-breakdown. The core-return plug speed matches the middle of the distribution best (interquartile ratio 2.02 against 2.35, KS 0.08) and keeps the low tail. The fitted laws are too narrow: they reproduce the median and none of the range. In fluorescence the picture is the same, with measured p5–p95 of 1.09–5.82 µm/s and the core-return plug speed again closest (KS 0.09).

Between sessions the model carries no information. Over the 11 sessions with model output, the Spearman correlation of session median measured backflow with session median shipped prediction is −0.01, and with the calibrated core-return plug speed −0.16. Session medians of measured backflow range from 1.54 µm/s (`LPD2412A025_t25`) to 3.28 µm/s (`EPY2412A088_t55`); the shipped model's range from 1.90 to 2.70 µm/s.

#fig(
  F + "fig_q4_aggregate_brightfield.png",
  [Distributions over the 1,558 measured brightfield edges in 12 sessions. Left: histogram of measured backflow and of three models; predictions below 0.1 µm/s are outside the axis. Right: quantile–quantile plot of four models against measured, predictions floored at 0.1 µm/s; dashed: identity.],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
) <fig-aggregate>

== In fluorescence the models rank the same, and backflow also drops near tips <sec-fluorescence>

Fluorescence backflow follows lipids rather than the hypha's centre, so it is a check on whether the brightfield conclusions depend on the channel. Held out over 1,275 measured fluorescence edges in 12 sessions, the ordering is the brightfield one: shipped model 57 % within 2×, core-return plug speed 69 %, pressure gradient 40 %, the width, demand and demand + width laws 83–85 %, kinematic 91 %. Fluorescence backflow is narrower in range (@sec-aggregate), so the constant reaches 84 %, and the shipped model is below it on 10 of 11 sessions, the exception being `LPD2412A025_t25` (60 % against 53 %). Along trails the shipped model's rank correlation is +0.05 over 24 trails, the core-return plug speed's +0.06; the demand law's is +0.30 and the kinematic model's +0.54.

Near the tip the decline is present and shallower. On 28 trail segments over 11 trails within 2.5 mm of the trail tip, measured fluorescence backflow is 1.27 µm/s against 2.81–3.05 µm/s beyond 5 mm, and the shipped model over-predicts 1.80-fold with 61 % of segments within 2×.

== Each hypha carrying back its own motor stream scores loops at 93 %, the global routing at 78 % <sec-zero-net>

From here on the data are the 15-session streak set (@sec-measured) and the model is that of @sec-zero-net-method; nothing above is rescored. In the global model the return circulates on loops: on the 719,016 loop edges of the 15 sessions the net flux is a median 29 % of the motor stream, 74 % at the 90th percentile, and tree edges carry none (@fig-net-flux). That circulation, and how little of it the measured flows carry, is examined directly in #link("loop_circulation_global_model.typ")[the loop circulation document]. Returning each edge's own stream instead leaves tree edges where they were and lifts the loop edges:

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right, right, right),
  table.header[*model*][*tree, within 2×*][*tree $rho$*][*tree log RMSE*][*loop, within 2×*][*loop $rho$*][*loop log RMSE*],
  [global (pressure-routed return)], [0.936], [0.46], [0.345], [0.784], [0.29], [0.682],
  [zero net flux], [0.936], [0.46], [0.347], [0.933], [0.35], [0.364],
)

The 220 tree edges and 1,347 loop edges are the brightfield streak edges of @sec-measured, with the motor-stream test applied; $rho$ is Spearman over all edges of the class. The global model's modelled spread on loops is too wide (SD of log speed 0.63), zero net flux's is too narrow (0.20), and the measured one lies between them (0.37). Scores are from `dag_rebuild_compare.py` on the rebuilt tables.

#fig(F + "fig_net_flux.png", [Net volume flux through each edge in the global model. (A) Net lumen speed (net flux over the lumen area) on PNF2307A072 t37; tree edges (grey) carry none. (B) Net flux as a share of the motor stream, on cycle edges and on bridges between two roots, 15 stores. (C) Measured loop edges in eight bins of the signed net share (positive: the net runs with the motors, so the return is smaller than the motor stream): median log error of the model's backflow (blue) and of a zero-net-flux backflow (grey). Band: within 2×.], src: "transport_paper/Working_notebooks/model_net_flux.py", width: 88%) <fig-net-flux>

== The data allow at most a few per cent of the motor stream as routed circulation <sec-global-room>

On the loop edges the global model's return differs from each edge's own motor stream by a median 1.28×. Blending the two:

#table(
  columns: (auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right),
  table.header[*share of global routing, $kappa$*][*loop log RMSE*][*change against zero net flux*][*loop, within 2×*],
  [0 (zero net flux)], [0.364], [–], [0.933],
  [0.1], [0.368], [+1.0 %], [0.927],
  [0.3], [0.390], [+7.1 %], [0.914],
  [0.5], [0.435], [+19.4 %], [0.882],
  [1 (global)], [0.682], [+87 %], [0.784],
)

The best share by log RMSE is −0.05 (95 % interval over sessions −0.05 to +0.05), by median |log error| +0.15 (0 to +0.30). The share within 2× peaks below zero (−0.15), a threshold effect of edges near the 2× line. Linearised, ln(measured / zero net) follows ln(global / zero net) with slope −0.03 (−0.06 to +0.01). At most 0.3 of the routing, on edges where it moves the return by 1.28×, is a circulation of about 7 % of an edge's motor stream, and the best estimate is none (`global_room.py`).

The junctions give the same answer from a different direction. On the 177 splits and mergers whose legs all carry a measurement and a video diameter, the global model moves a median 1.33× each leg's own motor stream. It predicts a spread of the speed term between junctions of 0.31 (SD of log), against 0.16 measured and 0.05 for zero net flux; where it departs from zero net flux, the measured speed term does not follow (slope +0.02, 95 % interval −0.06 to +0.10; splits −0.01, mergers +0.05). Only the average step agrees: the global model's medians, 1.10 at splits and 0.92 at mergers, lie nearer the measured 1.08 and 0.95 than zero net flux's 1.04 and 1.00. A small uniform build-up of backflow towards the root at every junction fits the data; the global model's junction-by-junction routing does not (`network_junctions.py --boot --model`).

== The edges zero net flux misses by more than 2× are short-lived <sec-fast>

Zero net flux cannot make the fastest to-root speeds: with the core floor its return is at most 1.53 times the motor speed, and 23 % of edges run to the root faster than 1.53 times their to-tip stream. Lowering the floor frees the speed on the wrong hyphae. From a floor of 0.8 to 0.5 the fast edges stay 79–81 % within 2× while the rest fall from 98 % to 92 %. At 0.5, 331 edges go over the old cap, and only 40 % of them are measured fast (27 % of all edges are), with the model overshooting them by a median 1.43×. The lipid demand decides which hyphae speed up, and the fast ones are not the high-demand ones (`zero_net_floor.py`).

The 85 edges on which zero net flux is more than 2× too slow, 61 of them on `PNF2307A080`, are not a property of their hyphae (`fast_runs_check.py`, transport_paper issue 72):
- They are mostly isolated: 66 of 74 groups, linked within 100 µm, are single edges.
- They cluster by recording. A measured neighbour within 150 µm is also too slow at 24 % when filmed in the same video, against a base rate of 5 % (odds ratio 6.2), and at 20 % against 10 % when filmed only in other videos (odds ratio 2.3, 30 pairs). A third of the model's error variance (37 %) is shared within a video, yet 55 % of the edges in the affected videos fit.
- They do not recur. None is too slow again where the same hypha was filmed in the next session: 0 of 11 pairs with one too slow, matching within 15, 30 and 50 µm. The broader level does carry over (model error $rho$ about 0.5, measured to-root / to-tip $rho$ about 0.4 across sessions).

Frames align to about 6 µm between sessions on `EPY2412A088` and `PNF2307A080`, and to about 20 µm on `LPD2412A025` and `STR2307A112`. What these edges record is a transient state or a measurement effect tied to one recording, not a fixed trait such as width or lane geometry, so a static per-hypha term cannot capture them.

== The motors run the way the hyphae grew; the growth graph needed its spurious sources removed <sec-motor-direction>

The model takes its motor direction from the GIMF solve, the sign of its net flux. The growth graph gives another, the direction each hypha grew. Over the 759,511 edges at the session the two disagree on 30.6 % (tree 2.2 %, loop 33.6 %; 16.8 % of the lipid current). On the 765 measured edges with an identifiable motor stream the observed motor direction matches the growth graph on 84.8 % and the GIMF sign on 80.4 %; where the two disagree (94 edges) 68 % side with growth. The motors run against growth on 96 of 720 edges with a GIMF direction (13 %); GIMF points that way on 31 % of them but also reverses 10 % of the edges whose motors run with growth (`motor_direction_compare.py`, `motor_disagreement.py`). Where the two rules disagree, and how the lipid routing combines with each, is #link("motor_direction_and_lipid_distribution.typ")[the motor direction and lipid distribution document].

The trails were chosen by hand as simple root-to-tip routes, so their own direction is a reference (@fig-motor-trails). On the part kept after the root trim the observed motors run to the tip on all 372 identifiable edges; the 20 edges whose motors run towards the root all lie on the trimmed stretches, the mirror arm, or on the dropped `STR2307A112_t73` LeftMiddle trail. The growth graph, with the fix below, points to the tip on 98 % of the kept trail length and matches the observed motors on 99 % of those edges; the GIMF sign points to the tip on 97 % and matches on 97 %. The one clear miss is a whole trail: GIMF points to the root on 63 % of `PNF2307A072_t37` Left, whose motors all run to the tip.

#fig(F + "fig_motor_direction_trails.png", [Motor direction along the annotated trails, before the root trim, from each trail's root end. Per trail, three bars, top to bottom: the growth graph (with the fix below), the GIMF solve and the model's motors (the GIMF sign with the zero-flux fill-in). Pale: towards the trail's tip end; vermilion: towards its root end; blank: no direction. Triangles: the observed motor direction where the motor stream is identifiable (green: to the tip; vermilion: to the root). Grey background: removed by the root trim; `STR2307A112_t73` LeftMiddle was dropped whole. Trails with at least 3 identifiable edges.], src: "transport_paper/Working_notebooks/growth_gimf_trails.py", width: 70%) <fig-motor-trails>

=== The growth graph as built started growth all over the colony, and four changes remove it

As built, the growth graph had 10,963 non-root sources against 248 annotated roots, 10,409 of them spurious, and only 47 % of the network reached a root or a source near one. Most were stretches whose recorded date is older than everything around them, islands whose connection to the root side appears later, and same-date regions oriented by hop count. Four changes, now the default of `build_growth_dag_from_activation`, remove them:
- Date smoothing: a root-free same-date stretch older than all its neighbours takes its oldest neighbour's date.
- A connector pass: where the best-dated path from a root into an island crosses a later-dated segment, that connector is backdated to the island's date, as a segmentation gap would require.
- A growth-consistent tie-break: inside a same-date region, ties are broken by network distance along paths whose dates never decrease.
- Root edges are oriented away from the root.

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right),
  table.header[*growth graph*][*spurious sources*][*reach*][*trail length to the tip*][*matches observed motors*],
  [as built], [10,409], [0.47], [0.953], [0.811],
  [date smoothing alone], [3,701], [0.66], [0.969], [0.822],
  [all four (default)], [534], [0.976], [0.978], [0.846],
  [distance from the roots only, dates ignored], [846], [0.96], [0.959], [0.804],
)

"Matches observed motors" counts an edge the growth graph leaves without a direction as a miss, so it reads lower than the 89 % above. The 534 sources left all lie in network pieces with no path to any root, and 98 % of the network length lies in pieces that hold one, so reach is at its ceiling. The distance-only rule is the geodesic orientation this project abandoned; it removes fewer sources and matches the motors worst. The tie-break or the connector pass alone change almost nothing (10,341 and 3,585 sources), because a same-date region stays oriented from its nearest point, which runs through a later-dated connector (`growth_dag_variants.py`, `growth_dag_remaining_sources.py`).

Rebuilding the tables on the new default changes the measured labels, not the backflow scores. The motor-stream test now flips 117 streams instead of 144, and 3 trail segments instead of 15; loop edges with no downstream demand fall from 660 to 444 of 1,357; and every score of @sec-zero-net moves by at most 0.001, because the solver does not use the growth graph (`dag_rebuild_compare.py`).

=== Routing the lipid along the growth graph leaves the backflow unchanged and the lipid's destination open

Under zero net flux the motor direction changes no to-root speed: the solver keeps each edge's lipid load from GIMF and only turns which way it rides. The alternative that matters routes the lipid itself along the growth graph (`--growth-routing`): each growing tip's demand passes back up its growth ancestors, split at fusions by cross-section. On the rebuilt growth graph pure growth routing brings 63 % of the demand to an annotated root and most of the rest to sources near the roots; on the graph as built it brought 12 %. A repair sends demand stranded at a non-root source to the nearest root along the shortest path, against growth there, and brings 91 %, turning 133 of the solver's junction-to-junction edges.

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right),
  table.header[*zero net flux, lipid routed by*][*loop, within 2×*][*loop $rho$*][*loop log RMSE*][*measured edges with no lipid*],
  [GIMF (the model)], [0.933], [0.35], [0.364], [0.07],
  [growth graph, pure], [0.937], [0.40], [0.359], [0.32],
  [growth graph, repaired], [0.938], [0.40], [0.359], [0.32],
)

Tree edges are unchanged (0.936 within 2×). The to-root speeds barely move, a median ratio to the GIMF-routed run of 1.000 (interquartile range 1.000–1.006), yet growth routing ranks the loop edges a little better. What moves is which edges carry lipid. The repaired routing's motor directions match the observed ones on 87 % of 720 identifiable edges, as the growth graph does, against the GIMF sign's 82 %; the repair turns 1.9 % of the edges and almost none that are measured, so it catches 1 % of the edges whose motors run against growth (`growth_routing_compare.py`).

= Discussion <sec-discussion>

Beyond 2.5 mm from a trail's tip the shipped backflow model is unbiased (0.92–1.20) and within a factor of 2 on 66–74 % of segments, which is what a single constant speed achieves (@sec-far). Within 2.5 mm it over-predicts 2.4-fold, because measured backflow drops there and nothing in the model makes it (@sec-near). Over all edges it is within 2× on 52 %, below a constant's 71 %, and its failures are located: the lipid speed cancelling a core speed under 6 µm/s, zero output on dead-end branches, and a weaker seam effect (@sec-breakdown). Pressure enters the error only through that cancellation (@sec-pressure). Dropping the lipid speed raises accuracy to 63 %, and fixing the annulus at its measured ratio removes the cancellation but only brings the model to the core-return plug speed's accuracy (@sec-annulus); a bare pressure gradient lowers it to 37 % (@sec-simpler), and measured backflow barely depends on routed flux at all (@sec-circulation). A tip factor measured to growing apical tips fixes the near-tip level without the annotation, and the same factor inside the solver fixes near-tip trail segments without improving the network (@sec-tip-factor, @sec-throttle). In aggregate the model gets the median right, produces an 8 % tail of near-zero predictions, and does not rank sessions (@sec-aggregate). Fluorescence ranks the models the same way (@sec-fluorescence). Within 10 mm of the trail tip the throttled models are within 2× on 73–77 % of 278 segments, level with a constant (74 %), and follow the order of segments along a trail (median Spearman +0.38), which a constant cannot; the measured speed spread on a segment is itself a median 3.7-fold (@sec-near-scatter). With motor speed and throttle length taken from the forward speed profile in the exponential form and motors running on zero-flux edges, the core-return plug speed matches those scores with nothing fitted to backflow, and places 72 % of near-tip segments inside their own measured spread against a constant's 69 % (@sec-measured-model); routing that return on $a^3$ or $a^2$ instead of Poiseuille's $a^4$ changes it by under 10 % (@sec-measured-model). These results are held out across sessions of only 4 plates and rest on 34 segments for the claims about the last 2.5 mm.

On 15 sessions with streak speeds, returning each edge's own motor stream, zero net flux, scores loop edges within 2× on 93 % against 78 % for the global pressure routing, and tree edges alike at 94 % (@sec-zero-net). The best share of the global routing is about zero on loop edges, at most 0.3, and at the junctions the measured speed term does not follow the global prediction (slope +0.02, at most +0.10): at most a few per cent of an edge's motor stream is routed around loops (@sec-global-room). The edges zero net flux misses by more than 2× are single, tied to one recording and not repeated on the same hypha in the next session (@sec-fast). The motors follow the growth graph (84.8 % of 765 identifiable edges, 99 % on the kept trails) a little better than the GIMF solve (80.4 %, 97 %), once four changes remove the growth graph's spurious sources (10,409 to 534); routing the lipid along the fixed growth graph scores loop edges as well as the GIMF routing (93.8 % against 93.3 % within 2×), so the backflow does not decide between them (@sec-motor-direction). These results cover 5 plates, and the bound on global routing is a bound on the global model's own routing pattern.

== The near-tip failure rests on 34 segments of 13 trails, and is half as deep on all edges near growing tips

The near-tip failure on trails rests on 34 segments over 13 trails in 8 sessions. The same decline appears across the network, on 444 measured edges within 2.5 mm of a growing apical tip, but at half the depth (1.35 against about 2.9 µm/s, not 0.68–0.91 against about 3.8). Part of the difference is where trails run: along the leading hypha of fast-growing tips, where the 19 measured edges show the deeper decline too (@sec-tip-factor). The small n on both sides leaves how much of the rest is chance open. The throttle's $lambda$ of 0.5 mm is chosen held out, and the same value wins every fold.

== Sessions of one plate share hyphae, so held-out scores overstate accuracy on a new plate

Sessions of one plate share most of their network and several of their videos: `STR2307A112` contributes 5 of 12 sessions and 732 of 1,558 edges. Leaving one session out keeps the other sessions of the same plate in the training set, so the held-out scores are optimistic for a new plate. The fitted parameters barely move between folds (@sec-held-out), which limits how much this can matter for one- and two-parameter models.

== The model's inputs other than the annulus are untested

Every model here inherits θ = 0.15, the manual roots, the growth window of 4 frames and segmented width. The annulus geometry is the one input varied, and fixing it at its measured ratio removes the cancellation without improving accuracy (@sec-annulus). None of θ, the window length or the root set was varied, and each changes the flux the core carries.

== The throttled core-return plug speed reads as motor-driven circulation that slows behind growing tips <sec-circulation>

The throttled core-return plug speed is the best network model here, and it has a physical reading that the shipped model's output does not. Each part of the reading rests on a measurement that could have come out otherwise.

=== The core-return plug speed is the return leg of a circulation, not a pressure response to growth

By construction, the core flux of a Poiseuille core is $pi a^4 Delta p \/ 8 mu L$, so $v_"press" = a^2 Delta p \/ 4 mu L$ is exactly twice its area-mean speed; the exported tables confirm the identity to three decimals on 1,417 edges. That core flux is what returns the motor-driven outward stream: median $abs(v_"press") \/ (2 v_0)$ is 1.08 (interquartile range 0.77–1.40), so on a typical edge the core carries back about what the motors carry out at 3 µm/s, and geometry and the growth consumed downstream shift it by tens of per cent. The prediction is therefore a plug-equivalent speed of the circulating flux, not of the routed growth flux. That distinction is what the data select: measured backflow barely rises with routed flux, a tenfold flux giving only 1.4- to 1.5-fold faster backflow (within-session, on log scales, flux exponent 0.14–0.18). A circulation whose size is set by motor speed, with growth as a small perturbation, predicts exactly that weak dependence.

=== The one fitted scale is the ratio of measured to assumed motor speed

The held-out scale on the core-return plug speed is 0.86–0.88 across folds. It puts the model's typical return speed, $0.86 times 1.08 v_0$, at 2.8 µm/s, against a measured median forward speed of 2.72 µm/s and backflow of 2.56 µm/s on the same edges. So the scale reads as the ratio of the measured outward speed to the assumed motor speed of 3 µm/s, and with the motor speed measured from forward flow it is not needed (@sec-measured-model). The circulation reading also says forward and backward speeds should match, and they do: backflow / forward is 1.07 at the median over all edges, and 0.99 on dead-end bridges.

=== Subtracting the lipid speed double-counts the motor stream

The shipped output $v_"center" = v_0 - v_"press"$ treats the core's edge as dragged outward at $v_0$ by the lipid annulus. With the annulus the model solves (median $a\/b$ 0.975, a sheath under 3 % of the radius) that drag cancels the return leg against the stream that drives it, producing the near-zero predictions of @sec-breakdown. When the annulus is set to its measured ratio, the model shrinks $v_0$ relative to $v_"press"$ on its own (median $v_0\/abs(v_"press")$ 0.20) and converges on the core-return plug speed (@sec-annulus). Dropping $v_0$ reaches the same place without the geometry that causes the cancellation.

=== The throttle encodes an apical zone where the circulation slows, not a geometric end effect

Near growing tips both legs of the circulation slow together: within 1 mm of a growing apical tip measured forward speed is 1.66 µm/s and backflow 1.35 µm/s, against 2.8–2.9 µm/s for both beyond 2.5 mm, while the unthrottled pressure-driven scale $abs(v_"press")$ stays flat (6.18 against 6.43–6.52 µm/s). A slower motor stream is the simplest cause that moves both legs, and lowering $v_0$ in the solver is that cause, but in the offset form the solver runs it covers under half of the fall: on the offset-throttle run the modelled return within 1 mm of a tip is 23 % below its value beyond 2.5 mm (121 and 998 edges), against 53 % for measured backflow, because the throttle can lower the motor speed by at most $1 - v_"tip" \/ v_infinity$ = 31 % (#link("throttled_core_speed_model.typ")[the throttled core-speed document]). What lowers backflow the rest of the way is not in the model. Three observations rule out the alternative that any closed end forces the flow down: a decay measured to stalled dead ends removes nothing (@sec-tip-factor); on dead-end bridges backflow does not depend on how long ago growth stopped, except on branches that grew within the last 4 frames (@sec-breakdown); and the decline is deepest on the leading hypha of the fastest-growing tips (@sec-tip-factor). The held-out decay lengths, 0.25–0.5 mm, give the size of that zone, and the forward speed gives, independently of backflow, 749 µm in brightfield and 323 µm in fluorescence in the exponential form, and 1711 µm in brightfield in the offset form the solver runs (@sec-measured-model). What sets it biologically, cytoskeletal organisation or vesicle traffic near the apex, is not measured here and is a hypothesis.

=== What the circulation reading does not explain

The reading made one testable prediction, and it held: a circulation should run in a dead-end branch whatever its net flux, and with motors oriented outward on zero-flux edges, in the run with the exponential throttle, the 106 dead-end bridges go from zero to a predicted 2.87 µm/s against 2.00 µm/s measured (@sec-measured-model). Two limits remain. If backflow is mostly motor speed, most variation between edges is variation in motor speed, which nothing in the network predicts; that is why a constant is within 2× on 72 % of edges and the parameter-free core-return plug speed on 68 %, and why no model ranks sessions. And whether the video's reported speed equals the core's area-mean, rather than some other average, rests on the held-out scale, not on a derivation from the velocimetry (@sec-measured-model).

== The bound on global routing tests the global model's pattern, not every pressure term <sec-global-bound>

The blend and the junction slope ask whether the data follow the routing the global solve produces from its conductances; #link("loop_circulation_global_model.typ")[the loop circulation document] traces that routing's error to the model's own circulation. They do not, and a pressure term routed differently is not excluded by either. It is only capped in size: at the junctions zero net flux leaves a spread of about 15 % in the speed term beyond measurement noise, and that spread does not follow the global pattern. The average step at junctions, faster on the root side of a split and slower on the root side of a merger, is the one feature the global model gets and zero net flux does not; a uniform build-up of backflow towards the root would produce it without network routing. The fast edges of @sec-fast are not a pressure term either: they do not recur on the same hypha.

== Where the lipid goes is not settled by the backflow <sec-lipid-direction>

Under zero net flux the backflow scores are the same whichever direction the motors are given (@sec-motor-direction). What the direction decides is which edges carry lipid to which tips, and there neither choice matches the data: supplying every growing tip needs reversals of the motor direction that the observed motors do not make, and neither the GIMF solve nor a shortest-path repair of the growth routing puts them where the motors are seen running against growth. The lipid test at filmed junctions (#link("junction_flux_balance.typ")[the junction flux balance document]) is the measurement that bears on it.

== Within-2× accuracy and along-trail rank correlation both overstate a model with no local structure

Within 2× treats a constant close to the median as accurate, so every accuracy number here is read beside the constant's. Trail-shape correlations see order only: the demand law's +0.67 within 10 mm is the ranking of tip distance at almost no amplitude (@sec-simpler). The kinematic model's 80 % uses the measured forward speed on the same edge. It shows how much of backflow a local speed rule can carry, not what the network predicts. Brightfield backflow follows the hypha's centre; fluorescence, which follows lipids, ranks the models the same way and shows the same near-tip decline at a shallower depth (@sec-fluorescence).

= What didn't work <sec-dead>

#dead The pressure gradient alone. Within 2× on 37 %, trail shape +0.06: the worst network-derived model (@sec-simpler).

#dead Local plug from downstream demand, with no solve. Within 2× on 43 % of the 886 edges with demand.

#dead A width-based tip decline. Trail segments at 1–2.5 mm from the tip are 14 % narrower than at 5–20 mm while backflow is 4 times slower (@sec-near). A width law alone is biased 2.83 within 2.5 mm of the trail tip; with a tip factor it improves only as far as the factor takes it (1.34 with the trail tip, 2.05 with growing apical tips).

#dead A tip factor measured to any dead end. Stalled dead ends included, the fit shrinks $lambda$ to 250 µm and removes nothing: near-tip bias 3.77 against 4.05, trail shape +0.07 (@sec-tip-factor).

#dead The model's existing tip throttle, measured to the growth-window nodes and gated by demand. It is either aggressive everywhere or has no effect. Two measurements explain both. Its tip set contains every node where growth attaches, including branch points on old hyphae: on `EPY2412A088_t28` 87 % of measured edges lie within its 3 mm ramp of such a node, on `STR2307A112_t49` and `PNF2307A072_t49` 28 % and 26 %. And its demand gate fully protects edges carrying lipid current above 1, which includes 85 % of trail segments within 2.5 mm of the trail tip, because the leading hypha feeds its own growth. These coverage numbers come from a one-off check on 4 sessions, with the growth-window nodes approximated from the growth record, and are not in the committed scripts.

#dead A stitching seam as the cause of the model's dip on `PNF2307A072_t49` Middle. Removing the vertical seam candidate left the dip unchanged; the dip is cancellation (@sec-breakdown).

#dead Routing the return around loops by a network pressure solve. Loop edges within 2× on 78 % against 93 % for zero net flux; the best blend share is about zero (@sec-global-room).

#dead A lower core-radius floor to reach the fast to-root edges. Floors 0.7 to 0.5 keep the fast edges at 79–81 % within 2× and drop the rest from 98 % to 92 % (@sec-fast).

#dead A static per-hypha term for the edges zero net flux misses. They do not recur on the same hypha in the next session, 0 of 11 pairs (@sec-fast).

#dead The growth graph's distance tie-break, or its connector pass, on their own. Spurious sources 10,409 to 10,341, and to 3,585 with date smoothing; only the growth-consistent tie-break together with the connector pass removes them (@sec-motor-direction).

#dead The shortest-path repair of growth routing as a model of where the motors reverse. Its turned edges catch 1 % of the edges whose motors run against growth, against the GIMF sign's 31 % (@sec-motor-direction).

= Actionable Items <sec-actions>

#open Check a sample of dead-end branches against the images. A quarter of the 106 are single stubs of 34 µm or less, which may be segmentation fragments of longer hyphae rather than real dead ends; the motors-on-zero-flux option treats both the same.

#open Rebuild the demand figures (`figs_demand_model.py`, the demand law here) on the fixed growth graph. The orientation in plateaus, which set reachable demand to zero on loop edges only because it reversed (@sec-breakdown), is fixed (@sec-motor-direction), but a third of the loop edges, 444 of 1,357, still reach no growth.

#open Decide between the global model and zero net flux for the manuscript's main text, with the supervisor. @sec-zero-net and @sec-global-room are the case for zero net flux.

#open The paper table rebuilt on today's code scores tree edges at 91.8 % within 2× against 93.5 % as it was built. The drop comes from solver changes since, not from the growth graph: the old growth graph on today's code scores 91.7 %. The manuscript's figures move when regenerated from it; the table as built is kept as `model_accuracy_local_offset_k0.0_floor0.8_w0.7_hypha_valid_olddag`.

#open Model the to-tip side per hypha (transport_paper issue 72): every model's motor speed is the tip throttle's narrow 2–3 µm/s band.

#open Refresh `Notes/conveyor_junctions.typ` section 8 and its Fig 6 on the rebuilt tables; the junction roles moved with the growth graph (152 splits and 25 mergers with video diameters, against 141 and 34).

#open Decide whether motors oriented outward on zero-flux edges and the core-return plug speed as the prediction become the model's defaults (@sec-measured-model); both are options that leave the current default unchanged. The motor speed already is measured: the solver's default is the offset throttle fitted to brightfield forward speed, 3.096 µm/s far from tips, 2.140 µm/s at a growing tip and $lambda$ = 1711 µm.

#open Run a synthetic Poiseuille flow of known centreline speed through the same kymograph and streak-slope pipeline, and read off which fraction of the centreline speed it reports. That checks directly whether the velocimetry measures the core's area-mean speed, the one part of the prediction not itself measured.

Handoff: the trail maps should present the model as a level reference, not a local prediction, and local agreement along a single trail, including the dip on `PNF2307A072_t49` Middle, is not evidence for the model. Temporal change in measured backflow across sessions is tracked separately in transport_paper issue 69. Zero net flux (@sec-zero-net) supports the circulation reading of @sec-circulation: the return is the other leg of each hypha's own motor stream, not flux the network routes between hyphae.

= Appendix <sec-appendix>

== Reproducing this <sec-repro>

From `transport_paper` at `d40df6e`, with the paper-plate stores in the Dropbox `paper_plates` folder:

```
W=Working_notebooks; T=fig_outputs/model_accuracy
.venv/bin/python $W/model_accuracy_table.py --out $T --workers 4
.venv/bin/python $W/model_accuracy_throttle.py ${T}_throttle_l1000 1000
.venv/bin/python $W/model_accuracy_throttle.py ${T}_throttle_l500 500
for l in 250 750 1500; do .venv/bin/python $W/model_accuracy_throttle.py ${T}_throttle_l$l $l; done
.venv/bin/python $W/model_accuracy_analysis.py --tables $T --out $T/analysis \
    --throttled ${T}_throttle_l500
.venv/bin/python $W/model_accuracy_tip.py --tables $T --distances
.venv/bin/python $W/model_accuracy_tip.py --tables $T \
    --throttled 250=${T}_throttle_l250 500=${T}_throttle_l500 750=${T}_throttle_l750 \
    1000=${T}_throttle_l1000 1500=${T}_throttle_l1500
.venv/bin/python $W/model_accuracy_demand_audit.py --tables $T
.venv/bin/python $W/model_accuracy_tip_growth.py --tables $T
.venv/bin/python $W/model_accuracy_trail_scatter.py --tables $T --iqr
.venv/bin/python $W/model_accuracy_trail_scatter.py --tables $T --throttled ${T}_throttle_l500
.venv/bin/python $W/model_accuracy_measured.py --tables $T --fit-forward
.venv/bin/python $W/model_accuracy_throttle.py ${T}_measured_bf 749 --motor-speed 2.87 --motors-on-zero-flux
.venv/bin/python $W/model_accuracy_measured.py --tables $T --model ${T}_measured_bf
.venv/bin/python $W/model_accuracy_throttle.py ${T}_measured_bf_g2 749 --motor-speed 2.87 --motors-on-zero-flux --core-conductance-exponent 2
.venv/bin/python $W/model_accuracy_measured.py --tables $T --model ${T}_measured_bf_g2
.venv/bin/python $W/model_accuracy_table.py --out ${T}_ab603 --workers 4 --a-over-b 0.603
.venv/bin/python $W/model_accuracy_analysis.py --tables ${T}_ab603 --out ${T}_ab603/analysis
```

Each table build runs the model on all 12 sessions, about 10 minutes on 4 workers. The analysis writes `REPORT.md`, the tip script `TIP_REPORT.md`, and the demand audit prints the edge-class table into `DEMAND_AUDIT.txt` when redirected there, all in `fig_outputs/model_accuracy/analysis/`; the tables in Results come from those three, and numbers from one-off checks say so where they appear. Each script has a `--selfcheck`.

From @sec-zero-net on, from `transport_paper` at `57703f7` (with `P` the paper configuration: `--streaks --offset-throttle --a-min-frac 0.8 --return-width-exponent 0.7 --motor-direction-per-hypha --motors-on-zero-flux --lipid-fraction 0.05 --dump-network`):

```
W=Working_notebooks; O=fig_outputs
.venv/bin/python $W/motor_orientation.py
.venv/bin/python $W/model_accuracy_throttle.py $O/model_net_flux 0 $P --return-locality 0.0
.venv/bin/python $W/model_accuracy_throttle.py $O/model_zero_net/floor0.8 0 $P --zero-net-flux
.venv/bin/python $W/dag_rebuild_compare.py --label new
.venv/bin/python $W/global_room.py
.venv/bin/python $W/network_junctions.py --boot --model
.venv/bin/python $W/zero_net_floor.py
.venv/bin/python $W/fast_runs_check.py
.venv/bin/python $W/motor_direction_compare.py
.venv/bin/python $W/growth_gimf_trails.py
.venv/bin/python $W/growth_dag_variants.py
for m in pure repair; do
  .venv/bin/python $W/model_accuracy_throttle.py $O/model_growth_routing/zero_net_$m 0 $P --zero-net-flux --growth-routing $m
done
.venv/bin/python $W/growth_routing_compare.py
```

`zero_net_floor.py` needs the floor runs listed in its docstring; `dag_rebuild_compare.py` holds the full rebuild recipe, and `TRANSPORT_GROWTH_DAG=legacy` gives the growth graph as it was built.


== Measured against predicted backflow, per session <sec-app-scatter>

#fig(
  F + "scatter_N0.png",
  [Measured brightfield backflow against the shipped model on every measured edge, one panel per session with model output (11). Predictions below 0.1 µm/s are drawn at 0.1. Grey band: within a factor of 2; line: identity. Panel titles give n, the share within 2× and the Spearman correlation.],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
)

#fig(
  F + "scatter_N1.png",
  [As above, for the pressure-driven scale $abs(v_"press")$ with one held-out scale.],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
)

#fig(
  F + "scatter_T.png",
  [As above, for the shipped model with the lipid speed throttled inside the solver at $lambda$ = 0.5 mm (@sec-throttle).],
  src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
)

#fig(
  F + "fig_trail_scatter_production.png",
  [As @fig-near-scatter, for the shipped output $abs(v_"center") times 2\/3$ with the $v_0$ throttle at $lambda$ = 0.5 mm and no fitted scale: trail segments within 10 mm of the trail tip, measured 25th–75th percentile bars, and the prediction's range within ±0.5 mm along the trail.],
  src: "transport_paper/Working_notebooks/model_accuracy_trail_scatter.py",
)

== Every trail: speeds, pressure gradient and width <sec-app-trails>

One figure per session. For each trail, three rows share a horizontal axis: distance from the trail's tip at the session in mm, root on the left, tip at 0, dashed line at 10 mm. Top: measured brightfield backflow per segment (points), the shipped model, the core-return plug speed with one held-out scale, and the shipped model with the $lambda$ = 0.5 mm throttle, on a linear axis that reaches every measurement and each model's 95th percentile along the trail, so a model's rarest peaks may be clipped. Middle: the second solve's pressure difference per µm, $abs(Delta p) \/ L$, in Pa/µm, the term that sets the pressure-driven velocity scale. Bottom: segmented width at the session in µm. `LPD2412A025_t36` has no model output and shows measurement and width only.

#let trails = (
  ("EPY2412A088_t28", 94%),
  ("EPY2412A088_t55", 94%),
  ("LPD2412A025_t25", 94%),
  ("LPD2412A025_t36", 94%),
  ("LPD2412A025_t50", 94%),
  ("PNF2307A072_t37", 94%),
  ("PNF2307A072_t49", 94%),
  ("STR2307A112_t25", 94%),
  ("STR2307A112_t38", 78%),
  ("STR2307A112_t49", 94%),
  ("STR2307A112_t60", 94%),
  ("STR2307A112_t73", 94%),
)
#for (s, w) in trails [
  #fig(
    F + "trails_" + s + ".png",
    [Trails of #raw(s): speeds, $abs(Delta p) \/ L$ and width against distance from the trail's tip at the session.],
    src: "transport_paper/Working_notebooks/model_accuracy_analysis.py",
    width: w,
  )
]

== References

#bibliography("references.bib", title: none, style: "apa")
