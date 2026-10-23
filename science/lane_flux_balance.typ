// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// SKELETON: every "TO FILL" block is the contract for one phase of the investigation plan.
// ---------------------------------------------------------------------------

#set document(
  title: "Local lanes and zero net flux — an alternative model for measured backflow speeds",
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

#show figure.caption: set align(left)
#show figure.caption: set par(justify: false)
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

// A slot the investigation fills: phase, owning agent, hypothesis, predictions per outcome, figure and table slots.
#let tofill(phase, agent, body) = block(
  fill: rgb("#fdf6e3"), stroke: (left: 2pt + rgb("#b58900")), inset: 9pt, radius: 2pt, width: 100%,
  text(9pt)[#text(weight: 700)[TO FILL — #phase, #agent.] #body],
)

// Figure placeholder until the phase delivers the panel.
#let placeholder(cap, height: 5cm) = figure(
  rect(width: 94%, height: height, fill: luma(240), stroke: 0.4pt + luma(200),
    align(center + horizon, text(9pt, fill: luma(120))[figure pending])),
  caption: text(8.5pt, fill: luma(95), cap),
)

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Local lanes and zero net flux]
  #v(-0.3em)
  #text(19pt, weight: 700)[an alternative model for measured backflow speeds]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · brightfield and fluorescence flow videos from eight imaging sessions on four plates of
    #emph[Rhizophagus irregularis] · results in progress · \@2c2ded5
  ]
]
#v(1.2em)

= Introduction

#question[Can two locally driven plug lanes with zero net flux explain measured backflow speeds, where does zero net flux hold, and can its failure in looping networks be predicted?]

The plates are colonies of #emph[Rhizophagus irregularis] imaged over days; a session is one plate's round of
videos between two imaging timepoints. Each timepoint is segmented into a network graph, and the graphs over time
form one spatio-temporal graph whose edges carry the time they appeared. Short videos at many stage positions record
the flow inside the hyphae: brightfield shows everything that moves, fluorescence only the labelled lipids. The flow
pipeline reads the speed of moving texture along each hypha in both directions, and the growth directed acyclic graph
(DAG) says which direction runs to the tip.

Most hyphae carry material both ways at once. #link("radial_flow_structure.typ")[`science/radial_flow_structure.typ`]
showed that the two directions do not sit as a centred backflow core inside a wall layer, as the backflow model
assumes, but toward opposite sides of the hypha. This document develops the alternative that picture suggests: each
hypha's motor stream returns through its own backflow lane, so backflow is driven locally. That model rests on one
large claim, zero net volume flux through each edge. The document asks what that claim predicts for the measured
speeds, where in the network it holds, and whether its failure in looping parts of the network can be predicted
before it is measured. A second conservation law, matching flux across a junction's several branches rather than
along one edge in isolation, is tested in #link("junction_flux_balance.typ")[the junction flux balance document].

= Motivation

The backflow model routes growth demand through the network with a pressure solve, places the lipid stream in an
annulus of inner radius $a$ set by demand, returns fluid through a parabolic core, and compares its centre-line
maximum with measurements through a factor of $2 slash 3$. Its misfit has been measured twice.
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[`findings/annulus_geometry_from_two_channels.typ`] found
that substituting the measured core fraction $a slash b = 0.603$ makes the network term over-predict backflow by a
factor of 2.4, and the radial analysis found no centred core in either channel. The geometry the model is built on is
not there, and the magnitude it produced was calibrated by compensating errors.

A locally driven model needs much less. If the tipward motor stream and the return flow are two plug lanes side by side
— flat, partial plug-flow velocity profiles have already been measured in Neurospora hyphae @abadehMassFlowVelocity2013
— their speeds and areas are tied by one conservation statement, and the measured speed ratio gives the share of the
lumen the return flow occupies without any radius, profile factor or pressure solve. Everything then depends on zero net
volume flux through the edge:

- On tree-like parts of the network zero net flux is close to guaranteed: an edge with no alternative route can only
  carry the volume that growth downstream consumes, and growth is slow. It should hold best in young edges near
  growing tips.
- In loops it is not guaranteed. Motor streams act as distributed pumps, and a loop gives their return flow a second
  route, so net circulation is possible unless the pumps around the loop cancel.

Three things depend on the answer. Whether the backflow model can be rebuilt on local lanes instead of the annulus and
core. Whether the two-channel ratio of the annulus finding still means something, as an area fraction rather than a
radius. And where a later model has to add net flux from pressure balancing across loops, which is outside this
document.

= Method <sec-method>

== Two plug lanes turn the speed ratio into a lane area fraction <sec-lanes>

Take one edge with a motor lane of area $A_m$ moving tipward at $v_m$ and a backflow lane of area $A_b$ moving rootward
at $v_b$, both as plugs, of any cross-sectional shape. Zero net volume flux means
$ v_m A_m = v_b A_b $ <eq-balance>
so the backflow lane's share of the moving cross-section is
$ f = A_b / (A_m + A_b) = 1 / (1 + R), quad R = v_b / v_m . $ <eq-fraction>
Shape does not enter. With a stationary share $s$ of the cross-section and a net lumen speed $u$ (positive tipward),
the general form is
$ f = (1 - s) (1 - u slash v_m) / (1 + R) . $ <eq-general>
Growth downstream of an edge needs a mean lumen speed of about 0.18 µm/s at the median, so $u slash v_m$ is a few
percent on most edges. That bound comes from growth alone; circulation around loops has none.

== Crossings would need tracer density, so net flux is read from the speed ratio <sec-crossings>

Counting particles that cross fixed positions along an edge, per unit time, gives a particle flux $J = n v A$ per
direction, with $n$ the tracer density in the lane. The to-root share of crossings is
$ S = J_b / (J_b + J_m) = (n_b v_b A_b) / (n_b v_b A_b + n_m v_m A_m) . $ <eq-crossing>
Under @eq-balance this reduces to $S = rho slash (1 + rho)$ with $rho = n_b slash n_m$. A crossing share of 0.5
therefore means equal tracer density if the flux balances, or balanced particle flux if the densities are equal. It
cannot establish both, and through the flow pipeline the crossing share does not reach even that stage: on synthetic
videos it follows the true share with a slope of 0.13 (@sec-r-calibration). Net flux is therefore read from the speed
ratio. With a net volume flux $q$ through the edge, @eq-balance becomes $v_m A_m - v_b A_b = q$ and
$ R = (A_m / A_b) (1 - q / (v_m A_m)) , $ <eq-r-flux>
so net flux shows as a departure of $R$ from the ratio of lane areas. A tipward net flux lowers $R$; when the motor lane
fills half the lumen, $q slash (v_m A_m)$ is about twice $u slash v_m$.

== Loops can carry circulation that bridges cannot <sec-loops>

Treat each edge's motor stream as a pump pointing along growth with strength $v_m A_m$, and give each edge a return
conductance proportional to its lumen area squared over its length, with one free shape factor. Solving the network's
flow balance with these sources gives a predicted net flux $hat(q)$ per edge. On a bridge $hat(q) = 0$ exactly. In a
loop $hat(q)$ is non-zero wherever the pumps around the cycle do not cancel, and it grows with the imbalance and with
the loop's conductance relative to the edge's own return lane. This is a prediction of where zero net flux fails, not a
model of backflow speed.

== Eleven assumptions, each assigned a test <sec-assumptions>

#table(
  columns: (auto, 1fr, auto), align: (left, left, left), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*\#*], [*assumption*], [*tested in*],
  table.hline(stroke: 0.4pt),
  [1], [each direction moves as one plug], [@sec-r-plug],
  [2], [only lane areas matter], [@sec-r-fraction-drivers],
  [3], [zero net volume flux through the edge], [@sec-r-zero-flux, @sec-r-loops],
  [4], [the whole cross-section moves], [@sec-r-static],
  [5], [steady state, no exchange through the wall], [@sec-r-zero-flux],
  [6], [measured medians are lane speeds], [@sec-r-calibration, @sec-r-plug],
  [7], [which speed ratio $R$ describes the lanes], [@sec-r-which-r],
  [8], [equal tracer density in both lanes], [not needed without crossings],
  [9], [how the backflow lane's area is set], [@sec-r-fraction-drivers],
  [10], [backflow is kinematic, not pressure-driven], [@sec-r-model],
  [11], [network conductance, demands and roots], [not tested here],
  table.hline(stroke: 0.6pt),
)

== Ten tests, each with a pre-registered verdict <sec-tests>

#tofill("Method", "coordinator")[Write each test as a numbered step with its lead sentence (what it establishes that
the previous step could not), the metric definition with units, the data, and the kill criterion.]

+ Cheap checks on existing outputs: a null for the pilot median match; static texture inside the stored medians;
  leverage in $R$; frame resolution per channel; growth-DAG confidence; power for the fluorescence test.
+ Synthetic ground truth through the real pipeline: particles in a cylinder, lanes at angle φ to the image plane,
  density ratio ρ, stationary share $s$, net flux $u$. Kill per estimator: slope of recovered against true below 0.5, or
  bias from ρ or $R$ above 0.05. Static cut 0.5 µm/s, at most three candidates per pixel.
+ Reliability: split-half (time halves, edge thirds) and test–retest; ceiling on any per-edge correlation. Decision:
  ceiling below 0.4 means per-edge nulls are noise-limited; ceiling at least 0.6 with observed below 0.2 is a genuine
  per-edge failure.
+ Stationary share of the section, minus an outside-hypha control. Material if interior $s > 0.2$.
+ Plug within a lane: speed against distance from the lane interface. Profile factor returns if lane-centre / lane-edge
  speed $>= 1.3$ beyond the projected plug null.
+ Which $R$: Deming slope of the chord-weighted area fraction on $1 slash (1 + R_k)$ for each ratio, on binned edges,
  since the calibration supports that fraction only in aggregate. Kill: no ratio with slope 0.7–1.3 and intercept
  within ±0.1.
+ Zero net flux where it should hold, through @eq-r-flux: the growth bound per edge; static-cut $log R$ on bridges
  against cycle edges, by age and distance to the tip; $log R$ against the net flux downstream growth requires. Kill:
  $log R$ on bridges falls with downstream growth more steeply than @eq-r-flux allows.
+ Loop failure: on cycle edges, the residual of $log R$ after the lane-area rule against $log(1 - hat(q) slash (v_m A_m))$
  from @sec-loops, with bridges as the zero control. Falsified if no relation at the measured reliability of $R$.
+ What sets the backflow lane's area: speed-based against chord-weighted fractions, demand, width, age, role.
+ Kinematic model: $v_b = v_m (1 - f) slash f$ with constant, demand-set or saturating $f$, against measured trails and
  the network model. Kill: no better than the network model or the demand fit, held out.

= Results <sec-results>

#tofill("all phases", "A0–A13")[Open with one paragraph on the order of the blocks: calibration and reliability first,
then the assumptions one by one, then zero net flux and its predicted failure, then the model. Every heading below is a
question until its phase delivers a verdict; it is then rewritten as the claim.]

== Cheap checks remove the median match and send R back for a static cut <sec-r-phase0>

Six checks on outputs that already existed (`lane_phase0.py`, `chord_weighted_test.py --null`) decide what the pilot
can still be trusted for before anything new is built.

#table(
  columns: (auto, 1fr, auto), align: (left, left, left), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*check*], [*measurement*], [*verdict*],
  table.hline(stroke: 0.4pt),
  [median match], [a constant share of 0.5 matches as closely as the data], [not evidence],
  [static texture in $R$], [6 of 24 edges move by more than 0.1 in $log R$, all toward 1], [redo $R$ with a static cut],
  [leverage in $R$], [205 brightfield and 147 fluorescence store edges with $|log R| > 0.4$], [enough, recount after the cut],
  [crossing resolution], [brightfield crossings are texture fragments and merge more in the slower lane], [biased, calibrate],
  [growth-direction errors], [orientation votes disagree on 6.6 % (brightfield) and 8.6 % (fluorescence)], [keep full agreement],
  [fluorescence power], [depends on the unknown lipid volume fraction], [undecided],
  table.hline(stroke: 0.6pt),
)

The pilot's median agreement between the width-integrated backflow share and $1 slash (1 + R)$ carries no information.
Setting every strip share to 0.5 gives a median difference of +0.032 to +0.035 and puts 39–58 % of edges within ±0.1,
as close as the measured shares (−0.042 to +0.058, 25–61 %). Every observed per-edge Spearman correlation lies inside
the 95 % band of 1000 shuffles of share profiles across edges (about ±0.41). The median of $1 slash (1 + R)$ is 0.47
because $R$ is near 1, so any share near 0.5 reproduces the match.

The stored medians include static texture. On the 24 pilot edges 17 % of kept candidates (IQR 9–22 %) move slower than
0.5 µm/s, with an arbitrary sign. Removing them leaves the median change in $log R$ at 0.027 but moves 6 edges by more than
0.1, all toward $R = 1$ (one from 3.74 to 1.07, another from 0.43 to 1.12); the interquartile range of $log R$ shrinks from
0.45 to 0.31 and the edges with $|log R| > 0.4$ fall from 11 to 6. Static texture makes most of the extreme ratios, which
are the edges that give per-edge tests their leverage, so every ratio in this document is taken with static candidates
removed.

Leverage survives that correction. Of 758 oriented radial profiles, 205 of 401 brightfield and 147 of 341 fluorescence
store edges have $|log R| > 0.4$, and 142 and 120 when both direction medians are at least 1 µm/s. PNF2307A072_t37 supplies
53 of the 58 brightfield profiles beyond that threshold in its store, so leverage is uneven across sessions.

Particle crossings are not particle counts. In brightfield, occupied runs per kymograph column last 4.1 frames against
about 7 expected for a 1 µm particle at the edge's speed, so they are fragments of texture; closing gaps of up to 2 frames
merges consecutive particles with probability 0.41–0.59, more in the slower lane, which pushes the crossing share toward
the faster lane. In fluorescence (0.5 s per frame, 20 frames) a 1 µm particle occupies less than one frame per column above
about 3 µm/s, so fluorescence needs hits along rows rather than crossings. Both biases go to the calibration
(@sec-r-calibration).

Growth-direction errors are small once orientation votes must agree: 6.6 % of brightfield and 8.6 % of fluorescence
profiles disagree, a shrinkage of pooled shares by a factor 0.83–0.87 if they were kept. The existing disagreement flag
marks plateaus of a different growth graph and flags 44 % of the 785 store edges; it is not used. The fluorescence test's
expected lipid deficit scales with the unknown lipid volume fraction: 0.0046 of the crossing share if the lumen were all
lipid (about 2400 edges to detect), 0.023 at 0.2 (96 edges), 0.092 at 0.05 (6 edges).

== The pipeline recovers the speed ratio but cannot count crossings <sec-r-calibration>

Synthetic hyphae with two plug lanes of known speed, area, tracer density, stationary share and net flux were rendered
as brightfield and fluorescence videos and passed through the unmodified candidate extraction (`synthetic_lanes.py`,
`synthetic_grid.py`): 18 conditions, each varying one axis from a symmetric base, in both channels with two random
seeds, for the full band and seven offset strips.

#figure(kind: table, table(
  columns: (1.3fr, 1.4fr, auto, 1fr), align: (left, left, left, left), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*estimator*], [*slope, recovered on true*], [*$r^2$*], [*verdict*],
  table.hline(stroke: 0.4pt),
  [speed ratio $R$, all or static-cut], [0.97], [0.84], [recovers],
  [chord-weighted area fraction], [0.66], [0.16], [aggregate use only],
  [crossing share], [0.13 pooled; 0.35 brightfield; −0.08 fluorescence], [0.04–0.16], [fails],
  [row-hit share, fluorescence], [−0.19 to +0.03], [0.00–0.08], [fails],
  table.hline(stroke: 0.6pt),
), caption: [Estimators on synthetic videos with known truth; best parameter setting per estimator.]) <tab-calibration>

The speed ratio recovers the truth with an intercept of 0.02 and a median absolute error of 0.045 (@fig-calibration,
right). The crossing share does not (@fig-calibration, left). Across every gap-closing and column-spacing setting its
slope stays below 0.5, 0.17 for the best single setting; a density ratio of 2 reads 0.24 low; and a population moving
only one way reads 8–13 % of its crossings in the wrong direction when defocused, 3.5 % for a single sharp particle,
from a secondary response of the orientation filter at the opposite sign. Detection recovers 25–44 % of the true
crossings. Hits along rows, meant to replace crossings in 20-frame fluorescence videos, stay between 0.42 and 0.61 while
the true share spans 0.34–0.71.

The chord-weighted area fraction has slope 0.66 but explains 16 % of the variance, so a single edge's value is not
usable. Lane angles other than 0 and 90° were not combined with fractions other than 0.5, so the angle at which the
fraction stops being readable is open. Two limits of the synthetic videos bound all of these numbers: stationary
particles barely register as candidates (0.5–1 % at a true stationary share of 0.2, against 17 % static candidates in
real videos), so the static cut's benefit rests on @sec-r-phase0 alone; and fluorescence noise has no real reference.

#figure(grid(columns: (1fr, 1.9fr), gutter: 8pt, align: bottom,
  image("figures/lane_crossing_calibration.png", width: 100%),
  image("figures/lane_r_calibration.png", width: 100%)),
  caption: text(8.5pt)[Synthetic calibration through the real pipeline. Left: recovered against true to-root
  crossing share, coloured by motor speed. Right: recovered against true speed ratio, from all candidates and after the
  0.5 µm/s static cut. Dashed lines are identity. Source: `synthetic_grid.py --analyze`.]) <fig-calibration>

== Per-edge estimates repeat within a video but not between videos of the same edge <sec-r-reliability>

The full lane flux run (all 263 brightfield and 189 fluorescence videos, `snellius/lane_flux.py`) gives static-cut
estimates on 518 oriented brightfield edges from 246 videos and 356 fluorescence edges from 173 videos, seven sessions
each (`lane_reliability_full.py`). Within one video they are reliable. Across time halves the two area fractions reach
Spearman–Brown 0.98–0.99 in both channels and $log R$ 0.95 (brightfield) and 0.90 (fluorescence); across edge thirds the
fractions reach 0.85–0.89, and $log R$ 0.86 in brightfield but only 0.49 in fluorescence.

#table(
  columns: (1.3fr, auto, auto, auto, auto), align: (left, center, center, center, center), stroke: none,
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*area fraction against $1 slash (1 + R)$*], [*ceiling, brightfield*], [*observed*], [*ceiling, fluorescence*], [*observed*],
  table.hline(stroke: 0.4pt),
  [width-integrated to-root share], [0.92], [+0.08], [0.80], [+0.05],
  [chord-weighted fraction], [0.92], [+0.08], [0.80], [+0.04],
  table.hline(stroke: 0.6pt),
) <tab-reliability>

By the pre-registered rule (ceiling at least 0.6, observed below 0.2) the per-edge null is a genuine failure in both
channels, and more decisively than in the 24-edge pilot, whose ceiling was 0.78–0.83. The calibration still limits what
the failure means: the chord-weighted fraction carries 16 % of the true variance on single synthetic edges
(@tab-calibration), so it may belong to the fraction rather than to @eq-fraction.

The same edge filmed in two videos of one session does not repeat. On the 77 brightfield edges seen in at least two
videos (422 videos), the test–retest intraclass correlation is +0.03 for $log R$, −0.07 for the to-root share and
−0.02 for the chord-weighted fraction; on 53 fluorescence edges (276 videos) it is +0.00, +0.02 and +0.04. Split-half
reliability measures only whether one video agrees with itself. Which video was filmed accounts for as much of the spread
in $log R$ as which edge, so per-edge $R$ is a property of the recording more than of the edge. This bounds every per-edge
test below (@sec-r-zero-flux, @sec-r-loops); aggregate tests over many edges are not affected.

#placeholder([Reliability: split-half scatter per estimator; correlation ceiling against observed correlation; test–retest
across videos of the same edge.]) <fig-reliability>

== In fluorescence none of the cross-section stands still; brightfield cannot measure it <sec-r-static>

The stationary share is the chord-weighted share of static candidates inside the hypha minus the rate outside it, in
±48 px control bands (`lane_static_plug.py`). In fluorescence it is −0.005 (95 % cluster bootstrap by video
[−0.006, −0.003]; 290 edges, 157 videos) against an outside rate of 0.007, stable across time halves (Spearman 0.81).
The $(1 - s)$ term of @eq-general is therefore a minor correction, well inside the pre-registered 0.2.

Brightfield gives −0.135 [−0.154, −0.117] (506 edges, 244 videos), a negative share that cannot be physical. Its outside
rate is 0.213: the brightfield candidate filter reads ordinary background texture outside the hypha as static material,
which the lipid-only fluorescence filter does not, and the subtraction overshoots. The brightfield estimate is a property
of the filter, not of the hypha, so the conclusion rests on fluorescence. The calibration adds a second limit in both
channels: static particles rendered at a true share of 0.2 were read at 0.5–1 % (@sec-r-calibration), so a small
immobile share would be missed.

== Each lane moves as a plug in both channels <sec-r-plug>

Speed within a lane was compared between its centre (at least 2.48 µm from the lane interface) and its edge (within
0.83 µm), relative to the full-band median of that direction, against a null that shuffles the interface position. The
ratio is 0.99 in brightfield (null 95th percentile 1.01; 394 edges that resolve an interface) and 1.07 in fluorescence
(null 1.05; 56 one-sided profiles). Fluorescence sits just above its null (one-sided p = 0.011) but far below the 1.3 at
which a profile factor would return, and brightfield does not depart from it at all. The measured medians can be read as
lane speeds. A shear layer thinner than one band, 0.69 µm, would appear only as a step at the interface and is not
excluded. In brightfield no lane-pattern classification exists, so every oriented edge enters and profiles without a
single interface drop out when they never cross half.

#placeholder([Left: stationary share across the width with the outside-hypha control. Right: per-direction speed against
distance from the lane interface, with projected plug and shear predictions.]) <fig-static>

== Which speed ratio describes the lanes? <sec-r-which-r>

#tofill("P8", "A8")[Hypothesis: one speed ratio gives $f = 1 slash (1 + R)$ with slope near 1 against an area fraction
measured without speeds. Candidates: same-video brightfield (with and without static texture), store brightfield, store
brightfield-over-fluorescence, fluorescence, and a median-free particle ratio. Predictions: one ratio fits (it is the
lane speed pair); none fits (@eq-fraction is unsupported). @fig-which-r.]

#placeholder([Speed-free area fraction against $1 slash (1 + R)$ for each ratio, binned, with errors-in-variables fits.]) <fig-which-r>

== Zero net flux survives every test that could refute it, on a few bridge edges <sec-r-zero-flux>

Static-cut $R$ was joined to the session networks and tested through @eq-r-flux (`lane_zero_flux.py`): 227 brightfield
edges (20 bridges, 207 cycle edges) and 321 fluorescence edges (65 bridges, 256 cycle edges).

#table(
  columns: (1.6fr, 1fr, 1fr), align: (left, center, center), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*test*], [*brightfield*], [*fluorescence*],
  table.hline(stroke: 0.4pt),
  [edges where growth alone needs more flux than the motor lane carries], [0 of 227], [0 of 321],
  [$log R$ against downstream growth after age (prediction negative)], [+0.05 (p 0.51, n 165)], [−0.01 (p 0.86, n 216)],
  [bridges: slope of $log R$ on the @eq-r-flux prediction (kill if CI lower bound > 1)], [−0.21 [−2.29, +0.30]], [+0.03 [−1.13, +1.54]],
  [bridges against cycle edges, age-residual $log R$ medians], [−0.00 vs +0.08 (p 0.16)], [−0.02 vs +0.04 (p 0.42)],
  table.hline(stroke: 0.6pt),
) <tab-zero-flux>

No edge needs more net flux for growth than its motor lane carries, and the kill criterion does not fire in either
channel: zero net flux on tree-like network is not refuted. It is also not shown. Twenty brightfield bridges leave the
slope interval wide, $log R$ does not follow downstream growth in either direction, and per-edge $R$ repeats poorly
between videos (@sec-r-reliability), which weakens any per-edge slope. The earlier test on store medians that still
contained static texture (163 bridges, 622 cycle edges; p = 0.45) reaches the same verdict.

#placeholder([Static-cut $log R$ on bridges and cycle edges by age and distance to the tip; against the net flux required
by downstream growth, with the slope @eq-r-flux predicts.]) <fig-zero-flux>

== The loop-circulation model predicts net flux that the measured ratios do not show <sec-r-loops>

On the eight session networks
(`loop_circulation.py`) the solved net flux is zero on every bridge to floating-point precision. On the 621 measured
cycle edges the predicted net lumen speed $|hat(q)| slash A$ has a median of 0.23 µm/s (IQR 0.10–0.44), about 10 % of
the edge's forward flux, and exceeds the 0.18 µm/s that growth requires on 60 % of them (@fig-loops): loops are predicted
to carry more net flux than growth does. Shorter cycles carry more (Spearman −0.24 against shortest cycle length,
n = 485), while the pump imbalance around the cycle predicts little (−0.08, p = 0.06).

A shape factor applied to every edge cancels exactly: scaling all conductances by one factor changes every node potential
and no branch flux, so the prediction depends only on relative conductances and on the pumps. It does depend on the
pumps imputed for unmeasured edges; imputing them or setting them to zero gives predictions that barely share a ranking
(Spearman +0.10). Eleven cycle edges sit on a cycle shorter than 0.2 mm and 62 touch a four-way junction; these may be
hyphae crossing without fusing.

The measured test does not find it. On cycle edges the static-cut $log R$ against the predicted
$log(1 - hat(q) slash (v_m A_m))$, after age, gives a partial Spearman of +0.12 (p 0.14, n 162) in brightfield and +0.06
(p 0.33, n 237) in fluorescence with imputed pumps; with pumps from measured edges only, −0.18 (p 0.02, n 162) and −0.02
(p 0.77, n 240). The one nominally significant value has the wrong sign, is not reproduced by the other imputation, and
lies below the smallest correlation the test could detect, 0.22 at 80 % power. The circulation model gets no support in
either channel, and the brightfield result changes sign with the pump imputation. That power figure rests on split-half
reliability; the between-video repeatability of $R$ (@sec-r-reliability) is far lower, so a real relation smaller than
the recording-to-recording scatter would also be missed.

#link("loop_circulation_global_model.typ")[The loop circulation document] tests the transport model's own loop
circulation directly against video and reaches the same absence: the model's loop-edge errors are its own
circulation, carried by none of the measured flows, and the data allow at most a few percent against the model's
26 % of the motor flux.

#figure(image("figures/lane_loop_prediction.png", width: 100%),
  caption: text(8.5pt)[Net flux predicted by the loop-circulation model. Left: predicted net lumen speed $|hat(q)| slash A$
  on measured cycle edges per session; whiskers span the range; dashed line at the 0.18 µm/s growth requires at the
  median edge. Right: the same against the length of the shortest cycle through the edge. Bridges are exactly zero and
  not shown. Source: `loop_circulation.py`.]) <fig-loops>

== What sets the backflow lane's area? <sec-r-fraction-drivers>

#tofill("P12", "A12")[Hypothesis: the lane fraction measured without speeds follows demand, width or role, and the
speed-based fraction agrees. Predictions: both follow the same drivers (areas are what varies); only the speed-based one
does (speeds, not areas, vary; assumption 2 fails). Held-out trail error for constant, demand-set, age-set and saturating
fractions. @fig-drivers.]

#placeholder([Partial correlations of speed-based and speed-free lane fractions with demand, width, age, tip distance and
network role.]) <fig-drivers>

== Along trails, backflow is best predicted by the forward speed measured beside it <sec-r-model>

Every model was scored held out on one common set of segments, 193 segments on 13 trails in five sessions, with the
lane fraction fitted on each session's other trails from static-cut $R$ and measured speeds from individual streaks
(`lane_model_trails.py --fair`). The lane models compute $v_b = v_m (1 - f) slash f$, so they need a forward speed $v_m$;
the network model needs a motor speed. To separate the model from its input, each family was run once with the forward
speed the network model assumes, $v_0 g(d)$ with $g(d) = 1 - e^(-d slash lambda)$ on the distance to the nearest growing
apical tip ($v_0 = 2.87$ µm/s, $lambda = 749$ µm), and once with the forward speed measured on the segment. For the network
model with measured input the core-return solve was re-run with the measured speed on every measured edge (23–196 edges
per session) and $v_0 g(d)$ on the rest; the solve is not linear in the motor speed, so it was not rescaled.

#table(
  columns: (1.5fr, 1fr, 1fr), align: (left, center, center), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*held-out log RMSE (along-trail Spearman)*], [*modelled forward $v_0 g(d)$*], [*measured forward*],
  table.hline(stroke: 0.4pt),
  [lane, constant fraction], [0.47 (+0.20)], [0.54 (+0.53)],
  [lane, fraction saturating with distance from the tip], [0.52 (+0.21)], [0.42 (+0.53)],
  [network, core-return plug speed $|q_c| slash pi a^2$], [0.63 (+0.20)], [0.57 (+0.29)],
  [backflow = forward speed ($R = 1$)], [0.57 (+0.20)], [*0.44 (+0.53)*],
  table.hline(stroke: 0.6pt),
) <tab-model>

Setting backflow equal to the forward speed measured on the same segment scores 0.44, within 0.02 of the best lane model;
the saturating lane fraction adds almost nothing to the measured input, and holding its fit out by session instead of by
trail leaves it at 0.42. With modelled input no model follows the trail shape (Spearman +0.20 to +0.21); the constant lane
fraction scores best there (0.47) because its fitted fraction sets the level, not because it tracks the trail. Feeding the
network model measured forward speeds improves it from 0.63 to 0.57, still worse than using the forward speed directly: the
network solve dilutes the measured signal rather than adding to it. The pre-registered kill, lane model no better than both
the network model and the demand fit (0.50), does not fire, but the lead belongs to the measured input.

For continuity: the network model at a flat, unthrottled $v_0 = 3$ µm/s scores 0.64, and the earlier centre-line reading
$|v_max| times 2 slash 3$ scores 0.71 flat and 0.74 with its own throttle ($v_0 = 3$ µm/s, $lambda = 500$ µm), so the throttle
helps one reading and hurts the other. Requiring every model on every segment removed three of the seventeen trails.

The measured-forward result has one confound this design cannot remove: backflow and forward speed are read from the same
video, and per-edge ratios repeat poorly between videos (@sec-r-reliability), so a recording-level effect that moves both
speeds together would inflate the $R = 1$ score. Taking the forward speed from a different video of the same edge would
separate the two. A systematic accuracy comparison of the network model against video, across tree and loop edges and
fast edges, is in #link("backflow_model_accuracy.typ")[the backflow accuracy document].

#placeholder([Along-trail backflow: measured against the kinematic lane models, the network model and the demand fit;
held-out error per trail.], height: 6cm) <fig-model>

= Discussion <sec-discussion>

#tofill("P14", "A14")[Open with one paragraph carrying the findings and their numbers, with section references, closing on
the limits. Then one subsection per caveat below, each rewritten as a claim.]

== Can a widefield projection separate lateral lanes from lanes above and below? <sec-d-projection>
#tofill("P14", "A14")[From the calibration's lane-angle sweep.]

== Does any tracer move passively with the fluid? <sec-d-tracers>
#tofill("P14", "A14")[Motor-bound vesicles report motor speed; lipid droplets ride both lanes.]

== Does R near 1 leave enough leverage? <sec-d-leverage>
#tofill("P14", "A14")[From the leverage check and the which-R test.]

== How much do growth-direction errors shrink the effects? <sec-d-dag>
#tofill("P14", "A14")[DAG-confident subset against all edges.]

== Are edges from one video independent samples? <sec-d-pseudoreplication>
#tofill("P14", "A14")[Cluster bootstrap by video.]

== Which estimators were frozen before the data? <sec-d-frozen>
#tofill("P14", "A14")[Primary set from the estimator freeze; everything else secondary.]

== Does filming the two channels minutes apart matter? <sec-d-channels>
#tofill("P14", "A14")[Paired videos are not simultaneous.]

== When does pressure balancing have to enter the model? <sec-d-pressure>
#tofill("P14", "A14")[From the size of the predicted and measured loop flux.]

= What didn't work <sec-deadends>

These come from the six-video pilot (24 edges) that motivated the investigation.

== A median match with 1/(1+R) is near-automatic when R is close to 1 #dead

The width-integrated backflow share matched $1 slash (1 + R)$ in the median, within −0.04 to +0.06 across three share
measures and three speed ratios. A share of exactly 0.5 in every strip gives +0.032 to +0.035, as
close as the data, and every per-edge correlation lies inside a shuffle null (@sec-r-phase0). The match shows no
inconsistency but is not evidence for @eq-fraction.

== Crossings divided by speed reproduce 1/(1+R) by construction #dead

Tracer amount estimated as crossings over each direction's speed gives an area fraction, but when crossings balance it
equals $v_m slash (v_m + v_b)$ identically. Its agreement with $1 slash (1 + R)$ is circular.

== Twenty-four edges cannot show a per-edge relation #dead

Per edge the width-integrated share did not follow $1 slash (1 + R)$ (Spearman −0.38 to +0.28). Most edges had $R$ near 1
(IQR 0.89–1.40), so $1 slash (1 + R)$ spanned only 0.42–0.53, and the reliability of either quantity was not measured.

== Dividing orientation value by moving contrast removes flow signal #dead

Value density follows the temporal contrast of the raw strip (median Spearman +0.48), but moving particles produce that
contrast; the fitted exponent had a median of 2.3. Static contrast, the visibility measure, is unrelated to value
(median −0.02).

== Particle crossings cannot measure net flux through this pipeline #dead

On synthetic videos with known lanes the to-root crossing share follows the true share with slope 0.13 (0.35 in
brightfield, none in fluorescence) at every gap-closing and spacing setting, misses a twofold density difference by
0.24, and reads 8–13 % reversed crossings in a one-way flow (@sec-r-calibration). The same videos rule out hits along
rows as the fluorescence substitute. With crossings went the direct test of zero net flux, the tracer density
measurement it needed, and the test for net lipid delivery in fluorescence; net flux is read from $R$ instead
(@eq-r-flux).

#tofill("P0–P13", "coordinator")[Add every estimator or test the investigation rejects, with the measurement that
rejected it.]

= Actionable Items <sec-actions>

== Compendium handoff

- Contradicts #link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[`findings/annulus_geometry_from_two_channels.typ`] on its profile-factor, core-geometry and in-model
  sections; needs an issue, not an edit.
- `/entry` topics: backflow read as local lanes with zero net flux; lane fraction constant or demand-set.
- Makes stale, in transport_paper: sections 3 and 4 of `backflow_model_overview.md`, and the $2 slash 3$ comparator
  in `direction_resolved_flow.py`, `figs_trail_map.py`, `figs_width_dependence.py` and `annulus_ratio_current.py`.

== Open

- #open P13 cross-video: the forward speed from a different video of the same edge, to separate a shared recording
  effect from a real forward–backward coupling (@sec-r-model).
- #open Why per-edge $R$ does not repeat between videos of the same edge (@sec-r-reliability): the recording, the edge's
  state at the time, or the estimator. Every per-edge test inherits the answer.
- #open P3 radial document counts from the complete brightfield set, and its stale lane-pattern figures.
- #open P8 which $R$; the channels already differ at the median (brightfield 1.22, fluorescence 0.98).
- #open A stationary-share estimate for brightfield whose outside-hypha control does not dominate (@sec-r-static).
- #open P12 lane-area drivers; P14 write-up and cold read; the figures still marked pending.

= Appendix <sec-appendix>

== Reproducing this <app-repro>

#tofill("P14", "A14")[Scripts in run order with their inputs: `lane_phase0.py`, `synthetic_lanes.py`, `lane_metrics.py`,
`snellius/lane_flux.py`, `lane_reliability.py`, `net_flux_tests.py`, `loop_circulation.py`,
`lane_fraction_drivers.py`, `figs_trail_map.py --lane-model`, `lane_writeup_figures.py`.]

== Provenance <app-provenance>

#table(
  columns: (1.1fr, 1.7fr, 1.5fr, 0.9fr, 0.9fr), align: left, stroke: none, inset: (x: 5pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [*campaign*], [*script*], [*input*], [*ran*], [*input survives*],
  table.hline(stroke: 0.4pt),
  [six-video value pilot], [`value_pilot.py` \ `chord_weighted_test.py`], [local copies of 6 brightfield videos], [2026-09-15], [no (scratch)],
  [synthetic calibration], [`synthetic_lanes.py` \ `synthetic_grid.py`], [rendered videos, two real run configs], [2026-09-15], [yes (local npz, 820 MB)],
  [loop prediction], [`loop_circulation.py`], [eight session stores], [2026-09-15], [yes],
  [trail model check], [`lane_model_trails.py`], [stores, annotated trails], [2026-09-15], [yes],
  [lane flux run, all videos], [`snellius/lane_flux.py`], [263 brightfield, 189 fluorescence videos], [2026-09-16/17], [yes (local CSV, `fig_outputs/lane_flux/phase2/`)],
  [reliability, static, plug, zero flux, loops, trails], [`lane_reliability_full.py` \ `lane_static_plug.py` \ `lane_zero_flux.py` \ `lane_model_trails.py`], [lane flux run], [2026-09-18], [yes],
  table.hline(stroke: 0.6pt),
)

== References

#bibliography("references.bib", title: none, style: "apa")
