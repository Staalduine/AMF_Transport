// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// ---------------------------------------------------------------------------

#set document(
  title: "Backflow against the growth direction — a fast subset on EPY2412A088",
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
#show table: it => { set par(justify: false); it }

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
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

#let ums = $mu upright("m") thin upright("s")^(-1)$

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Backflow against the growth direction]
  #v(-0.3em)
  #text(19pt, weight: 700)[A fast subset on EPY2412A088]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · EPY2412A088_t28, one video session, 109 edges · \@83a643a
  ]
]
#v(1.2em)

= Introduction <sec-intro>

#question[In a hypha carrying material in both directions at once, is the flow running back toward the colony's origin the same speed as the flow running outward, or is there a subset of hyphae where the two differ?]

We image a growing mycelial colony over several days, stitch the tiles into one mosaic per
timepoint, segment the hyphae, and extract a network graph from each frame. A separate set
of short high-frame-rate videos, taken at fixed stage positions during the timelapse,
measures the speed of material moving inside individual hyphae. Each position is recorded in
two imaging channels, brightfield and fluorescence, and the videos resolve the two directions of
travel separately: a hypha carries material outward and inward at the same time, the antiparallel
streams already reported on this network @oyartegalvezTravellingwaveStrategyPlant2025, and the
analysis reports a speed for each direction in each channel.

What the videos cannot say is which of those two directions points away from the colony's
origin. That is a property of the network, not of the video. Until now the answer came from
a hand-drawn trail: a curator traced a path through the network by hand, and a measurement
was called backflow when its direction opposed the trail. On this plate that route reached
16 of the trail's 281 edges, because only edges lying on the trail could be labelled at all.

This document replaces the trail with the growth chronology. Every hypha grew outward from
somewhere, and the network records when each piece appeared, so the network itself can say
which way is out. That makes all 109 measured edges usable rather than 16, and lets the
question above be asked of the whole measured set.

= Motivation <sec-motivation>

Transport models for these networks are built around a directional asymmetry. Material is
delivered outward to growing tips, and returned inward toward the colony. If the two
directions were identical in speed, the models' central quantity would not be measurable
from these videos at all, and every model comparison would reduce to a magnitude check.

The practical stake is narrower and more immediate. The backflow model produces a per-edge
predicted speed, and validating it needs measured backflow to compare against. At 16 edges
per session there is no statistical room: the earlier comparison rested on 16 edges, of
which 15 were measured twice, so a scatter that appeared to hold 33 points held 16. Whether
the model tracks the data cannot be settled at that size, and neither can the prior question
of whether the thing being predicted exists as a distinct population.

A second reason is that the directional label is currently produced by hand. A trail is
drawn by a curator, and both the coverage and the direction convention follow from where
they drew it. Deriving the direction from the growth record removes that dependency and
makes the same labelling available on any store, including the ones nobody has traced.

= Method <sec-method>

== The directed acyclic graph of growth orients every edge away from the nearest annotated root

Root nodes are the places material enters the network. On this plate they are annotated by
hand in the registrator and stored in the graph file's `/root_nodes` layer; automatic root
selection was not used, for reasons given in
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/root_node_detection.typ")[the root detection finding].

From those roots the orientation is built in one step. Geodesic distance from the nearest
root is computed for every node, measured in micrometres along hyphae rather than across the
plate, because two hyphae 50 µm apart in the image can be millimetres apart through the
network. Each edge is then directed from its lower-distance endpoint to its higher-distance
one.

This is acyclic by construction: every edge increases distance, so a cycle would require a
strictly increasing path returning to its start. Two classes of edge receive no orientation
and are dropped — those whose endpoints are exactly equidistant, and those in components
containing no root at all.

The same growth-DAG orientation is one of the network model's choices of motor direction;
#link("motor_direction_and_lipid_distribution.typ")[the motor direction document] finds it
matches the observed motors on 84.8 % of 765 identifiable edges, against 80.4 % for the
hydraulic solve's direction.

== A measurement is backflow when its own direction opposes that orientation

The flow measurements are stored keyed by an oriented pair of nodes, and both orientations
of every measured hypha are present. That is not duplication: the two entries are the two
directional components, each with its own speed. The key therefore already carries the
direction the material moved, and the only missing ingredient was a direction to compare it
against.

So the label is a comparison of two orientations, with no free parameter: a measurement
whose key runs against the directed acyclic graph (DAG) orientation is against growth, and
one that agrees is with growth.

== Speeds are per-edge medians, in µm per second, and the two channels are never pooled

Each video yields a distribution of particle speeds along one hypha; the stored `median` is
the summary used throughout, always positive, with the direction carried by the key rather
than by a sign. Where a hypha was measured more than once in the same direction and channel,
the per-edge value is the median of those measurements. Every count of $n$ in @sec-results
is a count of edges, not of measurements.

Two imaging channels are present, brightfield and fluorescence, and they are reported
separately everywhere. Pooling them is not a presentational choice but an error: they
disagree in magnitude by a factor of about 1.6 on the same hyphae, and the pooled median
sits between two populations and describes neither.

== The asymmetry is summarised as a ratio, which is silent about which hyphae are fast

The per-edge statistic is the ratio of against-growth to with-growth speed. A ratio above 1
means backflow is the faster component in that hypha. The paired Wilcoxon signed-rank test
is used for significance, since both directions are measured in the same hypha.

#note[A ratio computed over all edges is the wrong summary if the effect lives in a subset,
and on this plate it does. The overall brightfield ratio is 1.03, which reads as no effect;
the top speed quartile is 1.42. Every ratio below is therefore reported with the speed band
it applies to.]

== Clustering is tested against the measured edges, not against the network

Whether the fast hyphae sit near one another is tested by permutation. The statistic is the
mean distance from each fast edge's midpoint to its nearest other fast midpoint, in µm, and
the null redraws an equal-sized subset 5,000 times.

The null draws from the measured edges, not from the whole network. This is what makes the
test about the selection rather than about the videos: flow measurement covers about 12 % of
this network by length, so a null drawn from all edges would report the placement of the
cameras as clustering.

== A label on one 34.5 µm edge is carried along its hypha, junction to junction

The extracted network is segmented at a fixed 34.5 µm, so one anatomical hypha appears as a
chain of many edges. A chain like that is recovered by walking through nodes of degree two
and stopping at junctions or tips, which gives 1,656 hyphal segments on this plate, of median
6 edges and maximum 58.

A speed measured on one 34.5 µm piece is a property of the hypha it sits in, so it is carried
to every edge of that chain. This is a change of unit rather than an extrapolation: it does
not claim the neighbouring piece was measured, only that the measured piece and its
neighbours are the same hypha.

= Results <sec-results>

== The directed acyclic graph of growth is acyclic and its only sources are the annotated roots

Orienting all 12,946 edges away from the nearest of the 19 annotated roots yields a directed
acyclic graph of 12,578 edges. It has exactly 19 sources, and they are exactly the annotated
roots: no other node has in-degree zero, so every node traces back to a root that was placed
by hand rather than to an artefact of the orientation. 12,305 of 12,684 nodes are reachable,
97.0 %, and the remaining 379 lie in components containing no root. The graph terminates in
755 tips.

The orientation can be checked against a quantity it never used. Each node carries an
activation, the frame at which it first appeared, and growth should make that increase away
from a root. Of the edges where activation differs across the edge, 1,067 increase away from
the root and 184 decrease, so 85 % run the right way in time. The remaining 11,327 edges have
equal activation at both ends, which is expected: node activation is the minimum over
incident edges, and at 34.5 µm segmentation long stretches of one hypha share a value.

#fig(
  "figures/growth_dag.png",
  [Left: distance from the nearest annotated root, in mm along hyphae. Right: the 184 edges
   where activation decreases away from the root. Green circles are the annotated roots.
   The largest colony only.],
  src: "figs_direction_resolved_backflow.py::fig_growth_dag",
  width: 100%,
)

== Two roots produce most of the chronological contradictions

The 184 contradicting edges are not spread evenly. Roots 1758 and 1466 carry 4.5 % and 3.6 %
of their own catchments as reverse edges, against 1.9 % or below for every other root, and
seven roots produce none at all. Catchment sizes are very uneven, from 2,959 nodes down to 9.

#table(
  columns: (auto, auto, auto, auto),
  align: (left, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
  inset: (x: 7pt, y: 3.5pt),
  [root], [catchment, nodes], [reverse edges], [share, %],
  [1758], [916], [41], [4.5],
  [1466], [662], [24], [3.6],
  [1578], [2850], [53], [1.9],
  [844], [1615], [24], [1.5],
  [853], [2959], [16], [0.5],
)

A root placed slightly downstream of where growth actually began produces exactly this
signature, so the reverse-edge share is usable as an annotation-quality score. On this plate
it points at two roots out of nineteen.

== The direction label reaches 109 edges, where the trail reached 16

Every mapped hypha carries both orientations: 218 stored keys over 109 undirected edges, 444
measurements, split exactly evenly between the two channels at 222 each. All 218 keys
resolve under the DAG orientation, with none dropped for equidistance or for lying in an
unrooted component.

The trail route reached 16 edges of the trail's 281, and 15 of those 16 were measured twice,
once per channel. The gain is therefore not only in count but in independence: the earlier
33-point comparison was 16 edges with their duplicates.

== Pooled across all speeds the two directions are indistinguishable

Taken over all 109 edges, backflow and forward flow are the same to within a few percent,
and which one is faster is close to a coin toss.

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, right, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
  inset: (x: 7pt, y: 3.5pt),
  [channel], [with growth], [against growth], [ratio], [Wilcoxon $p$],
  [brightfield], [1.959], [1.894], [1.03], [0.024],
  [fluorescence], [1.872], [1.701], [0.97], [0.057],
)

Backflow is faster on 60 of 109 brightfield edges and 47 of 109 fluorescence edges. Read
alone, this says the growth direction does not separate the two components.

== Splitting by speed separates them, in the fastest quarter and in brightfield only

Splitting by how fast the hypha is at all changes the picture. The brightfield asymmetry is
absent in the lower three quartiles and large in the top one.

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  align: (left, right, right, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
  inset: (x: 7pt, y: 3.5pt),
  [speed band, #ums], [$n$], [with], [against], [ratio], [against faster],
  [0.35--1.59], [28], [0.98], [1.05], [0.99], [14/28],
  [1.59--2.18], [28], [1.84], [1.57], [0.91], [9/28],
  [2.18--3.16], [28], [2.46], [2.47], [1.00], [14/28],
  [3.16--5.22], [28], [2.87], [3.89], [1.42], [25/28],
)

Sweeping a threshold rather than binning shows the effect strengthening monotonically as the
slow edges are excluded, which is what a real subset looks like: at 2.0 #ums the
ratio is 1.29 on 60 edges, at 2.5 it is 1.34 on 45, at 3.0 it is 1.41 on 29 with 26 of them
faster in backflow, and at 3.5 it is 1.44 on 22. The corresponding $p$ values fall from
$2 times 10^(-4)$ to $5 times 10^(-6)$ between 2.0 and 3.0.

Fluorescence does the opposite. Its ratio stays at or below 1 in every band, and the
significance disappears as the threshold rises: $p$ = 0.216 above 2.0 #ums and
0.396 above 2.5. It is a symmetric population at all speeds.

#fig(
  "figures/direction_threshold.png",
  [Against-growth versus with-growth speed per edge, brightfield (left, blue) and
   fluorescence (centre, orange); coloured points are at or above 3 #ums, grey
   below. Right: the ratio against edge speed, rolling median over 21 edges, with the
   3 #ums mark dotted.],
  src: "figs_direction_resolved_backflow.py::fig_threshold",
  width: 100%,
)

== The fast edges cluster spatially, and the transport model rates them higher independently

The 29 fast brightfield edges sit closer together than chance. Mean nearest-neighbour
distance among them is 185 µm against a null mean of 345 µm, with a 5th percentile of 247 µm,
giving $p$ = 0.0036 over 5,000 permutations. Because the null redraws from the measured
edges, this is not the footprint of the cameras.

Two independent facts support the subset being structural rather than a measurement artefact.
The backflow model, which knows nothing of the directional split, assigns those same 29 edges
a higher predicted speed than the other 80, median 2.99 against 2.07 #ums. And
propagating membership onto whole hyphae, 23 of the 87 measured hyphal segments carry a fast
edge — 26 %, against 27 % at the edge level. Those two shares agreeing says fast edges arrive
roughly one per hypha, so the clustering is between neighbouring hyphae rather than along
single ones.

#fig(
  "figures/fast_hyphae_map.png",
  [Hyphae carrying a fast backflow edge (orange, 23 segments, 10.9 mm) against hyphae measured
   but not fast (blue, 64 segments). Black dots are the 29 measured fast edges, green circles
   the annotated roots, grey the rest of the colony.],
  src: "figs_direction_resolved_backflow.py::fig_fast_map",
  width: 100%,
)

== Propagating onto whole hyphae multiplies labelled length elevenfold, to 11 mm of 416 mm

Carrying the 29 measured fast edges onto their hyphae takes 0.95 mm of labelled hypha to
10.88 mm, a factor of 11.4. All 109 measured edges propagate to 48.4 mm, so flow measurement
covers about 12 % of the network's 416 mm by length even after propagation.

= Discussion <sec-discussion>

On this plate and this video session, backflow and forward flow are the same speed in most
hyphae and differ sharply in a minority. The brightfield ratio is 1.03 pooled over 109 edges
and 1.42 in the top speed quartile, with 25 of 28 of those edges faster against the growth
direction (@sec-results). Those fast hyphae are spatially clustered at 185 µm against a
345 µm null, $p$ = 0.0036, and the transport model independently assigns them a higher
predicted speed, 2.99 against 2.07 #ums. Fluorescence shows none of this at any
speed. All of it rests on one activation window of one plate, with a width input that does
not vary in time, so what follows bounds how far any of it travels.

The threshold is read, not fitted. The value near 3 #ums comes from where the
quartile table changes, not from a model or a change-point fit. The effect strengthens
smoothly as the threshold rises, which is consistent with a genuine subset but equally
consistent with a continuous relationship between speed and asymmetry. Nothing here
distinguishes those two, and a second annotated store is the cheapest way to try.

Width is a repeated time-average, and the model comparison is the part that suffers. No
store in this campaign carries per-timestep width, so each edge's width is one value repeated
across every frame. The direction comparison itself never touches model width and is
unaffected. Every number that involves a model prediction is affected, including the 2.99
against 2.07 separation above, and the backflow family is specifically the width-sensitive
one. Treat those as provisional until the width campaign lands.

One session, and it is a small one. The 109 edges come from a single activation, number 24
of 28, with 444 measurements. There is no second window in this store to check consistency
against, so nothing here separates a property of this colony at this moment from a property
of the organism.

The channels disagree and it is not understood. Brightfield reads 1.61 times faster than
fluorescence on the same 16 hyphae while correlating with it at 0.74, so they rank hyphae
alike and scale them differently. Since the asymmetry appears in one channel and not the
other, whatever causes that disagreement is a candidate cause of the asymmetry itself, and
until it is understood the fast subset cannot be attributed to transport with confidence.
The two streams run in lanes side by side across the hypha
(#link("radial_flow_structure.typ")[the radial flow structure document]), which bears on what each
channel records; it has not been tested against this disagreement.

The orientation depends on annotation that two roots do less well. Roots 1758 and 1466
carry three to nine times the reverse-edge rate of the others, meaning the DAG orientation
in their catchments is less reliable than elsewhere. 15 of the 109 measured edges lie in
those two catchments. Re-annotating them and repeating the split would test whether the fast
subset survives.

= What didn't work <sec-deadends>

== Pooling the two imaging channels — it hides a factor of 1.6 and describes neither

The first comparison pooled brightfield and fluorescence and reported a single ratio. On the
16 hyphae measured both ways, brightfield reads 1.61 times faster, ranging 0.42 to 2.59 per
hypha, while the two channels correlate at 0.74. The pooled figure is an average over two
populations at different scales. Against brightfield alone the model overpredicts by 19 %;
pooled, the same comparison reads 65 %. The channels are kept apart everywhere in this
document for that reason.

== Pooling all speeds — it reports 1.03 for an effect that is 1.42 where it exists

The overall brightfield ratio is 1.03, $p$ = 0.024, which reads as a negligible effect that
happens to reach significance on 109 edges. Splitting by speed shows 1.42 in the top quartile
against 0.99, 0.91 and 1.00 in the others. A median over the whole set was averaging a 40 %
effect on a quarter of the edges against symmetric traffic in the rest.

== Using measurements rather than edges as the unit — it triples the apparent sample

The trail-based comparison reported 33 backflow measurements. Those were 16 edges, 15 of them
measured twice, once in each channel. Since the model prediction is per-edge, every duplicate
plotted at the same height, and the correlation was computed over rows rather than over
independent hyphae. Every $n$ in this document is a count of edges.

= Actionable Items <sec-actions>

== Compendium handoff

This document supports no pipeline-step entry directly; it is a biological result resting on
steps documented elsewhere. It bears on two reference sections:

- #link("https://github.com/Staalduine/rhizosphere/blob/main/Priors.typ")[`Priors.typ`] — the prior that transport is directionally asymmetric.
  This is the first measurement on this project that separates the two directions without a
  hand-drawn trail, and it finds asymmetry confined to a fast minority rather than present
  throughout.
- #link("https://github.com/Staalduine/rhizosphere/blob/main/Methods.md")[`Methods.md`] — the section describing how backflow is identified. It
  currently describes the trail-based convention, which reached 16 of 281 trail edges here; the
  growth-DAG route reaches all 109 measured edges and needs no trail.

== Open

#open Confirm or kill the threshold on a second store. The 3 #ums boundary rests
on one plate's quartiles. Four more anchored stores are built and unannotated; annotating one
and repeating @sec-results is a day's work and settles whether the subset is real.

#open Explain the channel disagreement. Brightfield reads 1.61 times fluorescence on the
same hyphae. Until that is understood, an effect that appears in one channel and not the
other cannot be attributed to transport.

#open Re-annotate roots 1758 and 1466. Their catchments carry three to nine times the
reverse-edge rate of the rest, and 15 measured edges sit inside them.

#open Repeat once per-timestep width exists. The width campaign is planned; every
model-involving number here should be recomputed against real time-varying width rather than
a repeated average.

= Appendix <sec-appendix>

== Reproducing this <app-repro>

The store is `EPY2412A088_t28`, anchor `20250122_2023.geojson`, 29 timepoints, 12,684 nodes
and 12,946 edges, backbone fingerprint `fe943184…`, carrying 19 hand-annotated roots and 444
flow measurements. Both scripts are in `transport_paper/Working_notebooks/`.

```
python Working_notebooks/figs_direction_resolved_backflow.py \
    --store <store>/stg_store.h5 --out docs/science/figures
```

`direction_resolved_flow.py` holds the reusable half: `build_growth_dag`,
`directional_table`, `hyphal_segments`, `propagate_along_segments` and
`clustering_permutation_test`. The model is run at activation 24 with a growth window of 4
frames, which is what an anchored store needs — its anchor sits 4 frames past the video
session, and the default of 5 runs past the end of the series and silently produces nothing.

== Model against measurement, for reference

The model comparison is not this document's subject and is bounded by the width caveat in
@sec-discussion, but it is what the direction labels were built for;
#link("backflow_model_accuracy.typ")[the backflow accuracy document] presents the model
comparison in full, on the larger measured set the direction labels here made possible.

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, left, right, right, right),
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
  inset: (x: 7pt, y: 3.5pt),
  [channel], [comparator], [$n$ edges], [model/measured], [Spearman $rho$],
  [brightfield], [|max| × 2/3], [16], [1.19], [+0.54],
  [brightfield], [model mean], [16], [0.52], [+0.66],
  [fluorescence], [|max| × 2/3], [16], [1.99], [+0.23],
  [fluorescence], [model mean], [16], [0.92], [+0.26],
)

The shipped comparator is the model's maximum velocity times a fixed 2/3. The model reports
its own mean-to-maximum ratio and it is neither 2/3 nor constant: median 0.287 for the
brightfield-matched edges, ranging 0.108 to 0.887. The fixed factor is therefore roughly
twice what the model itself says the mean should be, which accounts for most of the
overprediction in the first row.

#fig(
  "figures/model_by_mode.png",
  [Left and centre: model against measurement, one point per edge, using the shipped
   comparator and the model's own mean. Right: the two channels against each other on the
   16 hyphae measured both ways. Blue brightfield, orange fluorescence.],
  src: "figs_direction_resolved_backflow.py::fig_by_mode",
  width: 100%,
)

== References

#bibliography("references.bib", title: none, style: "apa")
