// finding: open
#set document(
  title: "Speed profiles of growing hyphae — speed, stalling and the growth curve",
  author: "STHype pipeline investigation",
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
#set text(font: ("Helvetica", "Arial"), size: 10pt, lang: "en")
#set par(justify: true, leading: 0.62em)
#set heading(numbering: "1.")
#show heading: set block(above: 1.5em, below: 0.8em)
#show heading.where(level: 1): set text(15pt, weight: 600)
#show heading.where(level: 2): set text(12pt, weight: 600)
#show raw: set text(font: "Menlo", size: 8.5pt)
#show link: set text(fill: rgb("#8a5a10"))
#show table: it => { set par(justify: false); it }

#let holds = box(fill: rgb("#dcece3"), inset: (x: 4pt, y: 1pt), radius: 2pt,
  text(8pt, fill: rgb("#1f5a3f"), weight: 600, "HOLDS 6/6"))
#let unstable = box(fill: rgb("#f6dedb"), inset: (x: 4pt, y: 1pt), radius: 2pt,
  text(8pt, fill: rgb("#8a2f22"), weight: 600, "UNSTABLE OVER ARCS"))

#let fig(path, cap) = figure(
  image(path, width: 94%),
  caption: text(8.5pt, fill: luma(95), cap),
)
#show figure.caption: set align(left)

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt, radius: 2pt,
  width: 100%, breakable: false, text(9pt, body),
)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Speed profiles of growing hyphae]
  #v(-0.3em)
  #text(19pt, weight: 700)[speed, stalling, and the colony growth curve]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    STHype · six plates of #emph[Rhizophagus irregularis] · 40 frames each
  ]
]
#v(1.2em)

= Introduction

#question[How fast does a hypha actually grow, once the metric — paused or moving — and the measurement window — arc or growth-directed-acyclic-graph (DAG) trail — are made explicit, and what does that reveal about growth modes and the colony growth curve?]

A growing hypha does not extend at a steady rate. It advances, pauses, advances again. So
"the growth velocity" is not one quantity, and which number you get depends on two choices
that are usually left implicit:

+ Which metric? Do you average over the pauses, or measure only while the tip is moving?
+ Over what window? A rate measured over a 200 µm stub and one measured over a 4 mm run
  are not the same measurement, even with the same formula.

This document works through both. The second choice is the one the pipeline has only
recently been able to make, and it turns out to matter more than expected.

= Motivation

What the growth DAG buys. Until now the natural unit was the *maximal unbranched arc* — a stretch of hypha between
two junctions. It is a clean unit (arcs partition the network, so no length is counted
twice) but it has a hard limitation: an arc stops at the next branch point. In a densely
branching mycelium that caps the observation window at a few hundred micrometres, no
matter how far the hypha itself actually travelled.

The growth DAG removes that cap. Orienting every segment toward the neighbour it grew from
gives each segment a parent, and following those parents from a root out to a tip yields a
*trail*: a single growth lineage that runs through junctions and spans many arcs.

#table(
  columns: (auto, auto, auto, auto, auto),
  stroke: none,
  align: (left, right, right, right, right),
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*plate*], [*arc median*], [*trail median*], [*arc p90*], [*trail p90*],
  table.hline(stroke: 0.4pt),
  [EPY088#super[†]], [288], [1011], [713], [4541],
  [COL025], [390], [851], [1184], [3833],
  [COL009#super[†]], [237], [512], [695], [2028],
  [STR112], [318], [995], [1247], [7034],
  [PNF080], [265], [501], [547], [1475],
  [LPD072], [256], [724], [623], [3572],
  table.hline(stroke: 0.6pt),
)
#text(8.5pt, fill: luma(95))[
  Length grown per measured unit, µm. Trails reach 1.9–3.5× further at the median and
  2.7–6.4× at p90, on every plate.
]

That is what the DAG is for here: the difference between measuring a growth rate over a
stub and measuring it over a millimetres-long run of one advancing front. Trails do
overlap where they share a trunk, so they profile a lineage rather than partitioning
length — the right unit for "how did this front behave", not for summing total
length.

= Method

Over a unit's own growth window — from its first appearance to its last extension — split
the elapsed time into hours in which it got longer and hours in which it did not:

#align(center)[#block(inset: 8pt)[```
v_effective = grown_length / total_hours     averaged over the pauses
v_active    = grown_length / active_hours    speed while actually advancing
p_active    = active_hours  / total_hours    share of the window spent advancing
```]]

These are one measurement read three ways, tied by an exact identity:

#align(center)[#text(11pt)[`v_effective = v_active × p_active`]]

written in hours, not frame counts — the cadence drifts between roughly 1.6 and 3.8
hours per frame, so a frame-counting version would break as soon as it moved. On real
plates it holds to about #raw("1e-14"), which doubles as a bookkeeping check.

Reporting the pair rather than a single number makes pausing a measured quantity
instead of an unstated averaging choice. It also explains an older in-house measurement:
that analysis discarded zero-growth intervals outright (`if np.isclose(speed, 0.0):
continue`), which is exactly `v_active` — it was measuring speed conditional on growing,
without naming it that way.

#note[
  Four of the six plates were re-measured on 2026-07-31; two were not. The diagnostic
  that produces every number here was re-projecting each segment's query point onto each
  frame and querying the next frame from there, while the pipeline queries every frame
  from the segment's original centre. Scored against an independent coverage reference,
  that chaining lands further from frame truth on 80–84 % of the segments the two
  settings date differently (`diagnostics/f27`). It is now off, matching the pipeline.

  What is re-measured, precisely: the three tables in Motivation (arc vs. trail medians) and
  under Results (the long-vs-rest split, the thick-vs-thin width split), for COL025, STR112,
  PNF080 and LPD072. Every re-measured `v_active` fell by 5–17 %.

  What is not: the rows marked #super[†] (EPY088, COL009 — no rebuilt subset exists
  here), every figure, and the numbers in the DAG-depth route, the branch-stopping
  comparison, and the colony growth curve — all under Results — which come from other
  diagnostics on the same chained path (`f11` trail slopes, `f19` branch extension, `f15`
  growth curve). Those should be read as carrying the old matcher. The direction of the
  correction is known — dates moved later, speeds fell — so they are upper bounds on
  speed, but the size of the shift on each is not established.

  A limit that travels with every number here. At a \~2 h cadence a tip moving at 240
  µm/h covers roughly twelve of our 40 µm segments between frames, and about 84 % of
  segments share their activation frame with a neighbour. Motion within a frame is
  therefore invisible: `p_active` is bounded from below (a pause shorter than one interval
  cannot be seen) and the fastest tips are blurred. Nothing below should be read as if the
  time resolution were unlimited.

  A second floor sits underneath that one, spatial rather than temporal.
  `stall_decomposition` bins each edge's length into the frame that edge is dated to, so
  an interval counts as active only if a whole unit changed date in it: at 40 µm units, an
  interval in which the tip advanced 15 µm is recorded as a #emph[stall]. This biases
  `p_active` down and `v_active` up, and unlike the cadence it is a choice — it is set by
  where the anchor is cut. Every number here carries the 40 µm version of it. See
  Still open below.
]

= Results

#fig("figures/speed_profiles_epy088.png")[
  Speed profiles, EPY088. Top left and centre: the same plate measured over arcs and
  over DAG trails. Grey fill is v_effective, the navy outline v_active. Over arcs both
  pile up below 100 µm/h; over trails the profile shifts right and broadens, with a
  substantial population approaching the reference. Top right: the same trails split by
  width — thin (amber) and thick (navy) separate cleanly, thin peaking near 75 µm/h and
  thick near 150–180. Bottom left: p_active by unit. Bottom centre: the two terms against
  each other. Bottom right: p_active by width class. Amber guides mark the two
  documented reference speeds: 240 µm/h (dashed, individual tip mean) and 280 (dotted,
  wavefront pullers).
]


== Three things hold on every plate

#holds Measuring while moving raises the estimate. v_active exceeds v_effective
everywhere, for both units. Pausing, not slow extension, is what makes a pause-blind
average look low.

#holds Measuring while moving tightens the distribution. The relative spread of
v_active is smaller than that of v_effective on all six plates and both units,
typically by a third to a half. Mixing paused and growing intervals does not merely shift
the average down — it smears the distribution out. This is why the older analysis, which
dropped zero-growth intervals, recovered a narrow band.

#holds A longer window gives a faster profile. Trail v_active exceeds arc v_active
on every plate (71–101 µm/h over arcs; 94–173 over trails). Short arcs are dominated by
stubby side branches; following growth through junctions tracks the advancing front.

== Long hyphae are faster — and, measured properly, more continuous

Splitting trails at the ninetieth percentile of length grown:

#table(
  columns: (auto, auto, auto, auto, auto),
  stroke: none,
  align: (left, right, right, right, right),
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*plate*], [*v#sub[active] long*], [*v#sub[active] rest*], [*p#sub[active] long*],
    [*p#sub[active] rest*],
  table.hline(stroke: 0.4pt),
  [EPY088#super[†]], [189], [110], [0.93], [0.75],
  [COL025], [295], [126], [1.00], [0.67],
  [COL009#super[†]], [153], [87], [0.72], [0.50],
  [STR112], [294], [131], [0.88], [0.82],
  [PNF080], [108], [82], [0.54], [0.50],
  [LPD072], [214], [88], [0.90], [0.75],
  table.hline(stroke: 0.6pt),
)

Long trails are both faster and more continuous than short ones, on all six plates. This
is a purely geometric split — no width, no tortuosity, no morphology — and it already
separates two growth behaviours.

#unstable The same comparison over arcs is not stable. Measured on arcs rather than
trails, the p_active half of that result holds on four plates and reverses on
two (COL009 0.41 vs 0.50; STR112 0.80 vs 1.00). The speed half survives either way.

The likely cause is estimator variance rather than biology. A short arc spans only two or
three intervals, so its p_active is an average over a handful of yes/no observations, and
the ranking of two noisy means is unstable. A trail spans many more intervals, so the same
quantity is estimated far better. Worth being explicit: the arc-based version of this claim
was written up first and looked falsified; lengthening the window is what settled it.

== The same split on an independent cue: width

Splitting by length and then reporting that the long ones grew further is close to
circular. Width is a genuinely independent cue — and the biologically meaningful one,
since the distinction people mean by "runner" versus "branch" is a thick transport hypha
against a thin absorptive one. It is also the best single cue we have measured for naming
a branch at a junction (69 % correct, against 47 % for angle).

Splitting trails at their median width instead:

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  stroke: none,
  align: (left, right, right, right, right, right),
  inset: (x: 5pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*plate*], [*v#sub[act] thick*], [*v#sub[act] thin*], [*ratio, ×*],
    [*p#sub[act] thick / thin*], [*width–speed corr.*],
  table.hline(stroke: 0.4pt),
  [EPY088#super[†]], [151.7], [88.3], [1.7], [0.86 / 0.66], [+0.50],
  [COL025], [*228.3*], [95.4], [2.4], [0.88 / 0.65], [+0.58],
  [COL009#super[†]], [118.4], [71.0], [1.7], [0.64 / 0.42], [+0.47],
  [STR112], [*212.0*], [96.3], [2.2], [0.87 / 0.71], [+0.65],
  [PNF080], [96.1], [78.1], [1.2], [0.50 / 0.50], [+0.17],
  [LPD072], [130.8], [73.1], [1.8], [0.83 / 0.71], [+0.50],
  table.hline(stroke: 0.6pt),
)

#holds Thick hyphae are faster than thin ones on every plate, by 1.2–2.4×, and width
and speed are positively rank-correlated on every plate (+0.17 to +0.65). Since the cue is
independent of the length cut, this is a real confirmation rather than a restatement.

Read this as a gradient, not as two classes. Later work asked directly whether hyphae
fall into two morphological populations and found they do not: over six plates, a
two-component fit to arc shape never reached the separation needed to call the split
resolvable. Thick and thin are the ends of one continuous distribution, so a width cut is
a chosen convention that happens to be informative — the speed difference above is real,
but it is the difference between the extremes of a continuum rather than between two
kinds of hypha.

Where a genuine two-population split does appear, it is not primarily on speed.
Following each branch through the growth DAG separates lineages that keep extending from
lineages that stop after a limited length — on all six plates, and against both of the
artefact controls that could have faked it. That split is developed in the next section.

The two fastest plates put the thick population near the published tip mean without
reaching it — COL025 at 228 and STR112 at 212 µm/h against 240 @oyartegalvezTravellingwaveStrategyPlant2025. Selecting runner-like
hyphae, measuring only while they move, and measuring over a long window together close
most of the gap, which none of the three choices does alone.

#note[
  This claim was stronger before the matcher was corrected, and the correction is the
  reason to state it carefully now. On the chained matcher these two plates read 241 and
  229, i.e. on the reference value, and that coincidence carried more weight in the
  argument than one plate's arithmetic should. Unchained they read 228 and 212. The
  qualitative point — that the three choices together recover most of the literature
  value — survives; "lands on it" does not.
]

The p_active half is weaker but no longer contradicted: thick trails advance a larger
share of the time on five of six plates, and on PNF080 the two classes tie at 0.50.

PNF080 previously reversed here, 0.46 against 0.50, and that reversal was the one red
cell in this table — explained away as a plate-quality effect. It was an artefact of the
chained matcher. Unchained, the anomaly disappears. PNF080 remains the weakest plate on
the other measures (smallest speed ratio at 1.2×, weakest correlation at +0.17), so the
plate-quality reading was not wrong about the plate; it was wrong about there being
something to explain.

#note[
  A units caveat. The width attribute's unit is not recorded in the file — it is
  reference pixels sitting beside micrometre coordinates, which is exactly what
  `amftrack2024#26` exists to fix. It is therefore used here only as a relative thick/thin
  split, and no absolute width is quoted anywhere in this document.
]

#note[
  The general lesson. Before concluding a pattern is absent, check whether the
  measurement window was long enough to see it. Here the window was set by the choice of
  unit — arcs stop at branch points — and lengthening it moved a result from "reverses on
  two of six plates" to "holds on all six".
]

== Where the two modes sit

A statistical split is only worth trusting if the objects it selects are the ones you
meant. Drawing the classification back onto the plate lets a length-based proxy be
falsified by eye.

#fig("figures/growth_modes_map_epy088.png")[
  Growth modes on the plate, EPY088. Navy: the top decile of arcs by length grown.
  Amber: the remaining measured arcs. Grey: arcs appearing in a single frame, for which no
  rate is defined. The three numbered crops are enlarged below.
]

The zoom-ins carry the argument. Navy arcs are long, smooth and unbranched — single hyphae
running a millimetre or more. Amber arcs are short, strongly curved stubs hanging off the
larger structure. That is the morphological distinction one would expect between an
exploring hypha and a branch filling in behind it, and it was never put into the
classifier: the split is on length grown alone, and the morphology emerged on its own.

What the map does not show matters too. The navy arcs are spread throughout the
colony, including well inside it — they are not confined to the advancing margin. "Long
and fast" should not be read as "at the growth front"; the cut selects a growth mode, not
a location.

=== A third route to the same speed

Everything above derives speed from activation differences over a trail, so a systematic
error in the matcher would move every number together. A cheap independent check exists:
plot each root-to-leaf DAG trail as depth-first-search (DFS) depth against raw activation, and read the slope.
This uses no length measurement at all — only how many segments deep the lineage has gone
per frame — so it shares almost nothing with the velocity histogram but the dates.

The longest runner lineages, up to 306 segments, come out as near-linear monotone
staircases at roughly 11 segments per frame, which at the measured segment length is
\~220 µm/h. That lands beside the published reference speed by a route that could easily
have disagreed, and it is the strongest reason to think the residual gap discussed below is
about population and cadence rather than a scale error.

The same plot shows basal waves directly, as trails that begin at a late frame rather than
at the inoculum, and it explains a negative result from the pipeline side: the runner
lineages are already monotone, so enforcing monotonicity can only act on the short arcs
where the genuine basal-wave variation lives — which is why enforcement made dates worse.

== Branches that stop, and branches that keep going

Everything above splits hyphae by something they are — long or short, thick or thin.
The growth DAG allows a question about what a hypha does: follow every branch from the
junction it left, and ask how far that lineage ever got. A branched absorbing structure
splits off and stops after a limited length; a runner branch splits off and keeps going.

This is measurable even though the previous section's cuts were not resolvable, because
it needs only the branch event and the subsequent extension — not the dense branched
morphology, which the segmenter currently traces as a few short stubs. Lineages are
grouped by timing alone: did this one stop extending within the first half of its own
observation window. Both quantities below are held out of that grouping.

#fig("figures/bas_velocity_crossplate.png")[
  Stopping vs continuing branch lineages, six plates, 40 frames each. Left: speed while
  actually advancing. Middle: total length the lineage ever reached, log scale. Right:
  the ratio between the groups for each quantity, per plate — the two dots per row are
  the same comparison asked of speed and of reach.
]

#holds Continuing lineages are faster, and reach very much further — but not equally
so. v_active differs by 1.21–1.88×, while terminal extension differs by 6.3–12.5×. Both
are real; the second is roughly six times the larger effect, so *duration is what mainly
separates these populations and speed is a secondary difference.* The stopping class is
69–80 % of branches on every plate.

That the split is genuine rather than fitted rests on two controls, each of which makes it
stronger rather than weaker. Extension is quantised by the 40 µm segmentation, so
lineages that never grew past their first segment pile up at the floor and could fake a
low mode; removing them raises the separation from 2.29–3.03 to 2.85–3.12. And a lineage
born late has had no time to extend, which is ordinary right-censoring; restricting to the
longest-observed quarter raises it again, to 2.76–3.31. A censoring artefact would have
moved the other way.

#note[
  A correction, and the reason it is worth recording. This comparison was first made
  with extension divided by the hours from a lineage's birth to its last growth — a span
  that includes the stalled intervals. That is a v_effective, not a v_active, and it
  reported the two groups as equally fast, which supported a cleaner but wrong story:
  duration separates them and speed does not. The same conflation this document exists to
  warn about was made in measuring it. Recomputed as v_active, continuing lineages are
  faster on all six plates.

  One caveat survives the fix: v_active needs at least two activation frames, so
  lineages appearing entirely within one frame have none, and those are
  disproportionately the abrupt stopped ones. The speed comparison is therefore made among
  the most measurable stopped lineages — conservative for the ratio quoted, but it means
  the stopped median is not a complete population estimate.
]

What this does not establish is that the short-extension class is a branched absorbing structure (BAS). Bounded
extension after branching is a BAS's kinematic signature, but it is equally what an
aborted or damaged branch looks like. Separating those needs the branched morphology the
segmentation currently loses, so the biological label remains open even though the
measurement is now solid.

== The colony curve, and how it connects

The same measurements answer a colony-scale question: how was the network laid down over
time? Cumulative length is expected to compound early (every tip can branch) and then
slow into front-like expansion. Fitting that shape has one trap — a flexible two-regime
model will beat rigid ones whether or not the mechanism is real — so seven models are
compared on the Akaike information criterion (AIC), which charges per parameter, and the fit is constrained by physics:
cumulative length cannot jump.

#fig("figures/growth_curve_epy088_100f.png")[
  EPY088 over 100 frames (\~200 h). Top: cumulative length on linear and log axes, with
  the fitted two-regime curve and the transition marked in both coordinates — time, and
  the cumulative length reached there. Bottom: the mechanism. Growth rate (left) and the
  number of tip-bearing arcs advancing (right). Reading the law off the top row alone is
  ambiguous; the bottom row is what discriminates.
]

=== Constraining the join fixed a real instability

Fitting the two halves independently leaves a step at the join — impossible, since
cumulative length is continuous — and it flattered the fit: root-mean-square error (RMSE) 8.1 mm against 16.0 for
the constrained version. That apparent advantage was bought entirely with the illegal
jump. Imposing continuity of value and slope removes it and costs two parameters (7 to
5), and the pay-off is stability:

#table(
  columns: (auto, auto, auto),
  stroke: none, align: (left, right, right), inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*EPY088, transition*], [*from 40 frames*], [*from 100 frames*],
  table.hline(stroke: 0.4pt),
  [halves fitted independently], [47 h], [82 h],
  [continuity of value + slope], [*25 h, 105 mm*], [*26 h, 98 mm*],
  table.hline(stroke: 0.6pt),
)

The unconstrained estimate nearly doubled when the window lengthened; the constrained one
gives the same answer from both. A third variant — value continuous but slope free, which
would represent an abrupt burst of tip recruitment — reproduces the smooth fit exactly,
so the data does not want a slope break either.

Reporting the transition in cumulative length as well as time matters because time is
measured from an arbitrary origin: imaging starts on an already-growing colony, and `L(0)`
ranges from 14 mm (COL025) to 277 mm (PNF080) across these plates. Length is intrinsic.

=== The late law is not universal — it tracks tip recruitment

#table(
  columns: (auto, auto, auto, auto, auto),
  stroke: none, align: (left, left, right, right, left), inset: (x: 5pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*run*], [*best model*], [*margin*], [*tip trend, %/h*], [*late law*],
  table.hline(stroke: 0.4pt),
  [EPY088 100f], [exp → linear], [2.0], [+0.6], [linear],
  [EPY088 40f], [exp → quadratic], [1.5], [+3.5], [indistinct],
  [COL025 40f], [exp → quad (C⁰)], [*7.2*], [+7.9], [quadratic],
  [COL009 40f], [quadratic], [0.3], [+2.0], [indistinct],
  [STR112 40f], [exp → quad (C⁰)], [*11.3*], [+3.2], [quadratic],
  [PNF080 40f], [quadratic], [0.6], [+3.9], [indistinct],
  [LPD072 40f], [exp → linear], [2.0], [+3.6], [linear],
  table.hline(stroke: 0.6pt),
)

Five of seven margins are under 2 AIC, so on the length curve alone the models are not
distinguishable, and quoting "the growth law" from one plate would over-read the data.
What does discriminate is the tip count, and it connects the two halves of this document:

#align(center)[#text(11pt)[`dL/dt  ≈  (number of advancing tips) × v_active`]]

A fixed set of tips, each moving at the characteristic v_active measured earlier,
gives length growing linearly. For length to grow as t#super[2] the number of tips must
grow with the expanding perimeter. These are not rival laws but the two ends of one
mechanism, and the tip panel says which end a plate is at: EPY088 over the long window has
an essentially flat tip count (+0.6 %/h) and a late phase that is linear with the
quadratic term pinned at zero — consistent with a network carried by a few long runners.
COL025, recruiting tips fastest (+7.9 %/h), takes the quadratic end decisively.

#note[
  What would settle it. The tip count is measured on tip-bearing arcs with the first
  frame excluded (everything already present is dated there, and would otherwise register
  as a burst of growth). It is still a proxy: an arc gaining length is not quite the same
  as a tip advancing. A cleaner test would count advancing DAG trails and weight them by
  whether they are runner- or BAS-like, which the width split already makes possible.
]

= Discussion

Established. A single growth velocity is ambiguous in two independent ways — which
metric, and over what window — and both matter at the factor-of-two scale. Reporting
v_active, p_active and v_effective together removes the first ambiguity, and the
identity means nothing is lost by doing so. The growth DAG removes the second by making
trails available as a unit: 1.9–3.5× longer windows, and a measurably different answer.
Long hyphae grow faster and more continuously than short ones, on every plate.

The speed difference between the two growth modes is real and survives a change of
classifier: it appears whether the split is made on length grown or on width, which
are independent cues, on all six plates.

Not established. That these are exactly the classes the literature means by "runner"
and "branch". Width is the right kind of cue and the best single one we have (69 % correct
at naming a branch, against 47 % for angle), but a proper classifier would combine width
with tortuosity and be validated against labelled examples. What can be said is narrower
and still useful: thicker hyphae grow faster, and by a factor between 1.2 and 2.4.

Still open. The residual gap to the published \~240 µm/h — though it is now much
smaller than it looked. Restricting to thick trails brings COL025 to 241 and STR112 to 229
µm/h, i.e. onto the published value; the remaining plates sit lower. What is left is
partly population (we measure every tip-bearing unit, whereas a tip-tracking study follows
tips that are visibly moving) and partly resolution: at this cadence a fast tip's advance
can fall inside a single frame. Whether the slower plates are biologically slower or
simply harder to track is not something this analysis can separate. This is the hypha's
own extension speed, not the motor-driven flow speed inside it — the latter's slowdown
near a growing tip is modelled separately as a throttle in
#link("throttled_core_speed_model.typ")[the throttled core-speed model].

That resolution limit has since split in two, and both halves are still binding. The
cadence bound stands. The 40 µm bound also stands, and it is worse than it looks: the
segment ruler aliases about a quarter of velocity samples onto a single value, 19.0 µm/h on
every plate, an excess of 16.7–33× over the local histogram baseline. So the resolution
caveat above is not a hedge — it is a measured, plate-invariant artefact in the estimator
these profiles are built on.

Cutting at run boundaries was tried as a candidate finer ruler, but it does not fix the
aliasing. Run units measure 89–129 µm at the median against segments' 38.5–39.4 µm, so they
are coarser rather than finer — the 16 µm figure is the floor of the run-length
distribution, not its scale — and the apparent improvement it seemed to offer (an aliased
spike falling from around a fifth of samples to a few percent, with the length-weighted p90
moving under 5 %) came from a dispersal metric that thresholded the two arms at different
physical lengths. Re-measuring these profiles on that ruler would make them worse while
appearing to sharpen them. Derivation in #link("https://github.com/Staalduine/rhizosphere/blob/main/findings/transport_inputs.typ")[the
transport-inputs findings]; decision in #link("https://github.com/Staalduine/rhizosphere/blob/main/Pipeline_compendium.typ")[the pipeline
compendium], entry B6 #emph[The velocity quantum is the unit, not the cadence] (dead).

What the next step is instead. The aliasing is real and unfixed, so any re-measurement has
to come from a ruler that has been shown to be finer — not merely different. Until one
exists, v_active on these profiles carries a known quantisation at 19.0 µm/h and should be
read as bounded below rather than estimated.

= Actionable Items

Open — validate the runner/branch split against a real classifier. Width is the best single
cue measured so far (69 % correct at naming a branch, against 47 % for angle), but on its own it
is a chosen convention, not a validated label (Discussion, Not established). A proper
classifier would combine width with tortuosity and be checked against labelled examples.

Open — recover branched morphology in the segmenter output. The stopping/continuing split
(Results, Branches that stop, and branches that keep going) is solid on timing alone, but
whether the stopping class is a BAS rather than an aborted or damaged branch needs the
branched morphology the segmenter currently traces as a few short stubs.

Open — weight the tip-recruitment proxy by growth mode. The colony-curve fit (Results, The
colony curve, and how it connects) proxies tip count by tip-bearing arcs; a cleaner
discriminant between the linear and quadratic late-growth laws would count advancing DAG
trails weighted runner-/BAS-like, which the width split already makes possible.

Open — find a ruler finer than the 40 µm segment before re-measuring anything. The known
19.0 µm/h quantisation (Discussion) is unfixed, and the one candidate tried, cutting at run
boundaries, turned out coarser rather than finer (Discussion, What the next step is instead; see
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/transport_inputs.typ")[`findings/transport_inputs.typ`] and
#link("https://github.com/Staalduine/rhizosphere/blob/main/Pipeline_compendium.typ")[`Pipeline_compendium.typ`] entry `B6`).

= Appendix

== Reproducing this

#note[
  `sthype.temporal.growth_dag.stall_decomposition` computes the metrics
  for `unit="arc"` or `unit="trail"`; `diagnostics/f13_speed_profiles.py` produces the
  tables and the six-panel figure, `diagnostics/f14_runner_bas_map.py` the classified
  plate. Both run per plate via `STHYPE_PLATE_DIR`. The identity is asserted in the unit
  tests, including at a deliberately non-uniform cadence.
]

== References

#bibliography("references.bib", title: none, style: "apa")
