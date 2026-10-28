// finding: open
#set document(
  title: "Motor direction and lipid demand distribution — the growth history against the hydraulic solve",
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
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Motor direction and lipid demand distribution]
  #v(-0.3em)
  #text(19pt, weight: 700)[the growth history against the hydraulic solve]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · 15 sessions on 5 plates · 765 edges with an identifiable motor stream, 1,567 scored edges,
    1,678 fluorescence edges · \@fb56d0b
  ]
]
#v(1.2em)

= Introduction

#question[The backflow model has to decide which way the motors run on every hypha and how the lipid that growth consumes is shared where streams meet. Do the motors follow the hydraulic solve or the way the hyphae grew, does the sharing rule matter, and can anything in the videos tell the options apart?]

We image a growing colony of _Rhizophagus irregularis_ every two hours, segment every frame into a network graph, and
date each segment by when it first appeared. Short videos record the flow inside chosen hyphae: a to-tip stream near
motor speed and a to-root stream. The backflow model takes the network and the growth of the next four frames and
predicts the to-root speed on every segment.

Three terms recur. *GIMF* is the model's first step: a hydraulic solve that sends the volume growth takes up from the
roots to the growing tips through the network, as if every hypha were a Poiseuille pipe, and so gives every segment a
flux and a direction @heatonGrowthinducedMassFlows2010. The *global model* then finds the to-root flow with a second
pressure solve over the whole
network, so a hypha can return more or less than its own to-tip stream — its loop circulation is examined in
#link("loop_circulation_global_model.typ")[the loop-circulation document]. Under *zero net flux* every segment returns
exactly its own to-tip stream, with no second solve.

Two parts of that model have no measurement behind them: the direction the motors run on each segment, and how growth's
lipid demand is divided where streams merge. This document separates the two, runs every combination on all 15 sessions
under both the global and the zero-net-flux model, and scores each against three things the videos show: the to-root
speed, the direction of the motor stream, and where lipid moves.

= Motivation

The model's motor direction and lipid routing have so far come as a pair from one hydraulic solve (GIMF, below).
Three things depend on replacing or keeping that pair:
- *the main-text model.* Its description names the motor direction and the routing, and Figures 5 and 6 are built on
  them;
- *where lipid goes.* Lipid bodies move along AMF hyphae in both directions @bagoTranslocationUtilizationFungal2002,
  so which way it is routed is not obvious from the biology alone; the lipid hand-over into side branches
  (transport_paper issue \#89) and the lipid test at filmed
  junctions are read against a model of which hyphae carry lipid;
- *the loop edges.* The backflow model scores tree edges the same whatever the routing, so any case for one routing
  over another has to come from loops.

= Method <sec-method>

== The model is six choices: window, motor direction, demand split, speed and core, backflow, flux to speed <sec-m-chain>

The backflow model runs the same chain on every session. Every link is a switch in `model_accuracy_throttle.py`; the
defaults reproduce the model as it was built.

#table(
  columns: (auto, 1fr, auto), align: (left, left, left), stroke: none, inset: (x: 5pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*step*], [*options*], [*default*],
  table.hline(stroke: 0.4pt),
  [1 growth window], [the growth in the next 1–4 frames (2 h each), as volume per second, times 0.256 for carbon],
    [4 frames],
  [2 motor direction], [the sign of the GIMF net flux; the growth graph; the growth graph with repair (@sec-m-routing)],
    [GIMF sign],
  [3 lipid demand distribution], [where several segments point into a node under that direction, demand divides by
    the GIMF flux, by cross-section $b^2$, or evenly], [GIMF],
  [4 motor speed and core], [the offset tip throttle (levels off near 3.1 µm/s), a constant, or the measured speed;
    the core radius set by the lipid current at $theta$ = 0.05 with the floor $a >= 0.8 b$, or a fixed $a\/b$],
    [throttle, $theta$ + floor],
  [5 backflow], [global (a second pressure solve on the core conductances), zero net flux (each segment returns its
    own motor stream), or a blend], [global],
  [6 flux to speed], [the return flux over the return-lane area, with the width exponent 0.7; the flow partition of
    transport_paper issue \#95 is a separate switch, left at its current bookkeeping here], [width exponent 0.7],
  table.hline(stroke: 0.6pt),
)

This document varies steps 2 and 3 and runs step 5 both ways. Steps 1, 4 and 6 stay at their defaults.

== One rule routes demand for every choice: it passes up the runs that point into each node <sec-m-routing>

*The GIMF solve.* Every growing node is a sink for the volume its new hyphae took up per second. Roots are pinned at
one pressure, and every segment conducts as a Poiseuille tube of its store width. The solve gives a flux on every
segment, which splits across every open path of a loop in proportion to conductance.

*The growth graph.* Every segment of the network at the session is oriented the way it grew
(`direction_resolved_flow.build_growth_dag_from_activation`): from the neighbour it grew from, by date, with ties broken
by distance along date-nondecreasing paths. Its construction and checks are in
#link("backflow_model_accuracy.typ")[the backflow accuracy document]'s section
on motor direction. The solver works on runs of segments between junctions, and each run takes the direction of the
majority of its segments.

*The routing rule* (`compute_funcs/growth_routing.route_demand`). The chosen motor direction orients every run. Each
growing node's demand passes up the runs that point into it, towards the roots. Where several runs point into one node,
the demand divides between them by the chosen split: in proportion to the GIMF flux on each, to its $b^2$, or equally.
The flux on a run is the demand of every growing node downstream of it. Nothing is solved.

Three properties follow:
- *GIMF direction with the GIMF split is the GIMF flux itself*, since that flux is conserved at every node. On
  `STR2307A112_t49` the routed flux matches it to $10^(-11)$ on the median run. The runs that differ carry fluxes of
  0.05–0.15 against a median of 3.5, in a patch where the GIMF solve itself leaks about $10^(-4)$ of its largest flux
  per junction. The model keeps its original code path for this pair.
- *On a tree whose growth runs away from the roots, every choice gives the same flux.* The choices differ only on
  loops, and where growth history and hydraulics disagree.
- *Under the growth direction, demand can end at a node that is not a root*: one where every run points away, as where
  a hypha was first segmented partway along. That demand is unsupplied. The repair sends it on to the nearest root
  along the shortest path, with the motors turned against growth there, and only there.

== Four measures: backflow speed, motor direction, where lipid moves, demand reaching a root <sec-m-tests>

+ *To-root speed.* The modelled to-root speed against the measured one on brightfield streak edges (220 tree edges and
  1,347 loop edges; a loop edge is not a bridge of the network at the session). Scored as the share within 1.5×,
  1.75× and 2× (|ln(model / measured)| below ln 1.5, ln 1.75, ln 2), Spearman $rho$ and log RMSE. Tree edges score the
  same under every routing, so only loop edges can separate them. The flux-to-speed bookkeeping is the current one
  (@sec-m-chain, step 6); a different flow partition would move every level, but not which routing ranks higher.
+ *Motor direction.* On measured edges where exactly one of the two streams is motor-like (median within ±25 % of
  3.06 µm/s and quartile spread $q_75\/q_25 <= 1.25$), that stream's direction is the observed motor direction. It is
  identifiable on 765 edges (86 tree, 679 loop, 365 on a hand-picked trail). A rule matches when it points the motors
  the same way. This measure sees only the direction, not how much lipid is carried.
+ *Where lipid moves.* The fluorescence channel shows lipid. Per fluorescence video edge, the moving signal is the
  speed-weighted signal of both directions (`lipid_bias_store.py`), divided by the median of its video so that
  videos compare. It is set against each routing's predicted lipid current on 1,678 fluorescence edges: the share
  predicted to carry none, their signal against the rest, and the within-store rank correlation. It can mislead when
  lipid moves that the model does not count, such as lipid carried back to the roots.
+ *Demand that reaches a root.* The share of the growth demand, weighted over stores, whose routed path ends at an
  annotated root. It is an internal consistency check, not a measurement.

Signs of modelled fluxes are read along each segment's lower-to-higher node id, the convention the model writes them
in since transport_paper commit 26491c7 (issue \#93).

= Results <sec-results>

== The motors run the way the hyphae grew on 84.8 % of edges, against 80.4 % for the hydraulic solve <sec-r-motors>

On the 765 edges with an identifiable motor stream, the growth graph points the motors the observed way on 84.8 %
(tree 74 %, loop 86 %), and the GIMF sign on 80.4 % (tree 74 %, loop 81 %). The model's own growth direction, on runs
between junctions, plain or repaired, gives the same (84.7 %): the majority vote over a run changes one measured edge,
and the repair turns none. Only 2.9 % of runs contain a growth turn at all.

The two rules disagree on 94 edges, and there the observed motors side with growth on 68 %. The difference sits in a
few places (@fig-where):
- *2–5 mm from the roots* the GIMF sign is wrong on 31 % of edges, the growth graph on 21 % (77 edges);
- *beyond 10 mm* on 16 % against 10 % (497 edges);
- *off the hand-picked trails* on 35 % against 28 % (400 edges); on the trails both are almost always right, 3 % and
  1 % wrong (365 edges);
- *on `PNF2307A072`* on 31 % against 19 % (212 edges). On the other four plates the two differ by at most 4 points,
  and on `EPY2412A088` the GIMF sign is the better one (4 % against 8 % wrong, 51 edges).

Both rules are wrong on 86 edges (11 %). These concentrate near the roots: within 2 mm of a root, 31 % of edges
contradict the growth graph and 27 % the GIMF sign. On the maps they sit on a few hyphae each, where the motors run
towards the root.

The mismatches cluster only weakly. Along the network, a mismatching edge's measured neighbours within 500 µm also
mismatch 0.25 of the time for the growth graph (base rate 0.15) and 0.31 for the GIMF sign (base rate 0.20). But
78–81 % of mismatches are single edges, and no run of linked mismatches is longer than four. Same-video neighbours
mismatch at 0.27 (growth) and 0.40 (GIMF), other-video neighbours at 0.35 and 0.27, on 15–95 pairs each: no
consistent recording effect. What aggregation there is follows place, near the roots.

#fig("figures/motor_disagreement_where.png", [Where the motor-direction rules contradict the observed motor stream.
Top: the share of the 765 identifiable edges each rule gets wrong, by network distance from the nearest annotated
root, on or off a hand-picked trail, and per plate (EPY088 51 edges, LPD025 72, PNF072 212, PNF080 261, STR112 169).
Bottom: the three sessions with the most identifiable edges, zoomed to the measured region (network in grey, roots at
the bottom); each edge coloured by which rule matches.], src: "routing_grid_figs.py, motor_disagreement.py") <fig-where>

== On loop edges growth ranks backflow best under zero net flux, GIMF under the global model <sec-r-backflow>

#table(
  columns: (1fr, auto, auto, auto, auto, auto), align: (left, center, center, center, center, center), stroke: none,
  inset: (x: 5pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*motor direction × split*], [*within 1.5×*], [*1.75×*], [*2×*], [*$rho$*], [*log RMSE*],
  table.hline(stroke: 0.4pt),
  table.cell(colspan: 6)[_zero net flux, loop edges_],
  [GIMF sign × GIMF (default)], [73.1 %], [86.3 %], [93.3 %], [0.35], [0.364],
  [GIMF sign × area], [72.5 %], [86.2 %], [93.5 %], [0.31], [0.369],
  [GIMF sign × even], [70.0 %], [84.8 %], [93.2 %], [0.26], [0.379],
  [growth × GIMF / area / even], [74.5–75.1 %], [86.7–87.0 %], [93.5–93.7 %], [0.40–0.41], [0.358–0.359],
  [growth, repaired × any split], [74.4–74.8 %], [86.7–86.9 %], [93.5–93.8 %], [0.40–0.41], [0.359],
  table.cell(colspan: 6)[_global model, loop edges_],
  [GIMF sign × GIMF (default)], [55.2 %], [68.9 %], [78.4 %], [0.32], [0.666],
  [GIMF sign × area / even], [50.4–50.6 %], [63.5–63.8 %], [73.3–73.5 %], [0.31–0.32], [0.774–0.873],
  [growth, plain or repaired, any split], [51.1–51.4 %], [64.0–65.3 %], [73.8–74.2 %], [0.12–0.13], [0.753–0.803],
  table.cell(colspan: 6)[_tree edges, every cell, both models_],
  [], [76.4–76.8 %], [89.5–90.5 %], [93.6 %], [0.45–0.47], [0.344–0.347],
  table.hline(stroke: 0.6pt),
) <tab-grid>

*Tree edges score the same in every cell*, as they must. On loop edges two things hold (@fig-grid and the table
above):
- *under zero net flux the growth direction ranks the loop edges best* ($rho$ 0.40–0.41 against 0.35) and puts
  1.4–2.0 points more edges within 1.5×. Under it the split barely matters. Under the GIMF direction it does: the
  GIMF split is best and the even split worst ($rho$ 0.26);
- *under the global model the default pair is best*, and routing by growth loses most of the rank order
  ($rho$ 0.12–0.13). The global model's second solve is sourced by the routed flux, and routing by growth leaves 28 % of edges
  with no lipid current, so its sources are patchier.

Tighter measures widen the gap between the two backflow models rather than between the routings. Zero net flux beats
the global model on loop edges by 15 points within 2× (93.3 against 78.4 %), 17 within 1.75× (86.3 against 68.9 %)
and 18–20 within 1.5× (73–75 against 55 %).

#fig("figures/routing_grid_scores.png", [Loop-edge scores of every motor direction × lipid demand split, under zero net
flux (top) and the global model (bottom): the share within 1.5× and 2× of the measured to-root speed, and Spearman
$rho$; 1,347 loop edges. Axis ranges are shared between the two models.], src: "routing_grid_figs.py, routing_grid_compare.py") <fig-grid>

== Under the growth direction a third of the demand never reaches a root unless repaired <sec-r-reach>

The share of the growth demand that reaches an annotated root, weighted over the 15 sessions:
- *GIMF direction*: 97.8 %, whatever the split. The rest sits in network pieces with no root, where the GIMF solve
  finds no flux at all.
- *growth direction*: 63.0–67.1 % plain. Growing tips whose growth history traces back to a node that is not a root
  leave their demand there.
- *growth direction, repaired*: 90.6–96.1 %. On most sessions 99–100 %, but one session keeps only 29 % and another
  75 %, where pieces of network have no path to a root that the repair could use.

== Where lipid moves does not follow any routing's lipid current <sec-r-lipid>

On the 1,678 fluorescence edges, the moving fluorescence signal is the same on edges each routing gives no lipid
(7.3 % of them under the GIMF direction, 28 % under the growth direction) as on the rest: the ratio of medians is 1.00
in every cell. Its within-store rank correlation with the predicted lipid current is between −0.04 and 0.00 in every
cell. The moving lipid signal carries no trace of the growth demand's routing under any of the options.

= Discussion <sec-discussion>

The motors follow the growth history more often than the hydraulic solve: 84.8 % against 80.4 % of the 765 edges
with an identifiable motor stream (@sec-r-motors). The gap sits 2–5 mm from the roots, beyond 10 mm, off the
hand-picked trails and on one plate, and both rules fail together on 11 % of edges, near the roots, where the motors
run rootward on a few hyphae. Under zero net flux the growth direction also ranks loop-edge backflow best ($rho$ 0.41 against 0.35) whichever
split is used; under the global model the hydraulic pair stays best, because its second solve needs the GIMF sources
(@sec-r-backflow). The split rule matters only under the GIMF direction. Nothing measured discriminates between splits,
and the moving fluorescence signal follows none of the predicted lipid currents (@sec-r-lipid). These results hold on
15 sessions of 5 plates, with the flux bookkeeping of the current model.

*The observed-direction test has few edges where the rules differ.* The two rules disagree on 94 of the 765 edges; on
86 more they agree and are both wrong. PNF072 and PNF080 carry 62 % of the edges. A per-plate comparison rests on
51–261 edges.

*The identifiable edges are not a random sample.* An edge counts only if exactly one stream looks like motor transport,
which excludes edges where both streams are fast or neither is plug-like. 48 % lie on hand-picked trails, which were
chosen as simple root-to-tip routes; on them both rules are almost always right. Off the trails the two rules are wrong
on 28 % and 35 %.

*The GIMF solve uses store widths.* Its conductances come from widths that read about 11 % wide and are only loosely
related to the video lumen widths (transport_paper issue \#73). The growth direction does not use widths at all.

*The fluorescence test measures a signal, not a flux.* The moving signal is speed-weighted fluorescence, normalised per
video. It counts lipid moving in both directions. If most lipid circulates rather than being consumed, as the model's
demand-to-flux ratio suggests (growth consumes under 1 % of the motor flux), the consumed part is too small to show,
whatever routing is right. A null here does not favour any routing.

*The backflow scores use the current flux bookkeeping* (transport_paper issue \#95): the whole lumen at motor speed as
the to-tip stream. The ranking of routings is the question here, and every cell uses the same bookkeeping, but the
levels will move when a flow partition is chosen.

= What didn't work <sec-deadends>

== Distance from the roots is not a motor direction #dead

Motors running away from the nearest root by network distance is the simplest reading of root-to-tip transport. As
the direction everywhere it treats each hypha as a single-lane supply chain. Almost every edge sits on a loop, and
around each loop the distance from the roots rises from both sides to a peak inside it. There the motors on both sides
point at each other, and lipid routed around the loop is carried against its route. The growth graph oriented by
distance alone matches the observed motors worst of the orientations tried
(#link("backflow_model_accuracy.typ")[the backflow accuracy document], section on
motor direction). The model keeps the rule only as a fill-in on edges with no net flux, such as dead-end branches,
where it coincides with growth.

== One motor direction per hypha, voted from the GIMF flux, is not carried forward #dead

Voting one direction per hypha from the length-weighted GIMF net flux along it was meant to remove sign flips on
near-zero-flux loop edges (transport_paper issue \#70). It is removed as an option so that the comparison is between the
two sources of a direction, the hydraulic solve and the growth history. Its only comparison against the observed motors
(77 % against 78 % for the raw GIMF sign) was read from model outputs whose signs were unreliable (transport_paper
issue \#93) and has not been repeated.

== The fluorescence signal as a readout of the lipid current #dead

See @sec-r-lipid: the moving lipid signal is uncorrelated with the predicted lipid current under every routing, and
equal on edges predicted to carry none.

= Actionable Items <sec-actions>

== Compendium handoff

- #link("backflow_model_accuracy.typ")[The backflow accuracy document]'s section on motor direction is brought to
  these figures: growth and GIMF disagree
  on 30.6 % of the network's edges (loop 33.6 %, tree 2.2 %), and on the observed motors growth leads 84.8 % to 80.4 %.

== Open

- #open The main-text model: keep GIMF × GIMF under the global model, or move to zero net flux with the growth
  direction, which ranks loops best (@sec-r-backflow). Simon's decision, together with the flow partition
  (transport_paper issue \#95).
- #open A test that could decide the split: the split acts only where streams merge (fusions under growth, loop merges
  under GIMF). Lipid measured on every leg of filmed fusions would decide it; the fluorescence moving signal cannot.
- #open The edges where both rules fail sit near the roots, on a few hyphae. Whether these are the mirror arms, and
  what sets their direction, is not tested here.
- #open The junction lipid split at filmed side branches (stem against through-hypha against side branch) is a
  separate result, taken up in #link("junction_flux_balance.typ")[the junction flux-balance document].
- #open transport_paper issue \#34 (growth routing): close as answered, or re-scope to the fusion test above.

= Appendix <sec-appendix>

== Reproducing this <app-repro>

From `transport_paper` at `fb56d0b`, with the paper-plate stores:

```
fig_outputs/model_grid/run_grid.sh          # zero net flux: 3 directions x 3 splits, 15 stores
fig_outputs/model_grid/run_grid_global.sh   # the same under the global model
python Working_notebooks/routing_grid_compare.py
python Working_notebooks/motor_disagreement.py
python Working_notebooks/routing_grid_figs.py
```

Each cell runs `model_accuracy_throttle.py OUT --streaks {--zero-net-flux | --return-locality 0.0} --a-min-frac 0.8
--return-width-exponent 0.7 --motors-on-zero-flux --lipid-fraction 0.05 --dump-network --motor-direction D
--demand-split S`. The grid table is `fig_outputs/model_grid/routing_grid_compare.csv`; the identifiable edges with
every rule's direction are `fig_outputs/model_grid/motor_disagreement/identifiable_edges.csv`.

== References

#bibliography("references.bib", title: none, style: "apa")
