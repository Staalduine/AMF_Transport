#import "../shared.typ": *

== Step D1 — Growth graph and demand

*Input:* the spatio-temporal graph over a time window. *Output:* a simplified graph whose tips
carry a lipid demand and whose *root nodes* are the pressure boundary every tip draws through.
Root placement is the half of this step that has no correction downstream: the solve pins
pressure at the roots, so a wrong root set moves every flux, and a component with no root has
no solution at all.

#entry("D1", [Root nodes are selected by activation band, not by position], shipped, kind: cleanup, tag: "d1-root-activation-band")

*Problem.* Root selection gated candidates on an absolute `position.x` threshold, then binned
them along one axis and kept a single extreme node per bin. Growth on every paper plate runs
along *`y`*, and the plates are 1.76–2.41 : 1 wider than tall, so the gate was applied across
the plate rather than along it. The producing repo had documented the intended meaning
correctly the whole time — `bottom_coord` is described as the *y*-coordinate of the bottom of
the network — so code and documentation had disagreed since both were written.

The measurable form: roots and tips should sit at opposite ends of whatever quantity selects
them. Under the position gate on EPY2412A088 they were *6 percentiles* apart, and the gate
admitted 54 % of all nodes.

*Intent.* Select roots by the quantity that actually defines them. Inoculated material is by
definition the oldest material present, so a root is a degree-1 node whose activation falls in
the oldest band of the network — no axis, no direction, no rotation handling, and no per-plate
constant. The prior it encodes is the physical one: resources enter where the fungus was
introduced.

*Change.* `find_root_nodes` in `sthype/utils/growth.py` now takes candidates at or below an
activation percentile of the full graph (default 8), then declusters them on a *2-D* spatial
grid keeping the oldest per cell. The grid is 2-D deliberately: binning along any single axis
would reintroduce the rotation assumption being removed. `bottom_coord` survives in the
signature as dead and warns when passed; `root_edge = (growth_deg, keep_frac)` is an opt-in
manual override for arbitrary angles — a growth direction in degrees CCW from $+x$, and the
fraction of the projected span, measured from the low end, that counts as root edge. Shipped in STHype\#208.

*Implementation.* `sthype/utils/growth.py` — `derive_root_activation_threshold` (the
percentile), `find_root_nodes` (the rule), `subsample_root_candidates` (the declustering).
The one constant a reader would otherwise hunt for is `root_activation_percentile = 8.0`. Note
that `to_growth_graph` derives the threshold from the *whole* spatio-temporal graph and passes
it in, rather than letting the rule compute it on the $t_0$ subgraph: that subgraph fragments
into dozens of components — 37 on EPY088 at $t_0$=24 — and a per-subgraph percentile would
track the fragmentation instead of the plate.

*Evidence.* The activation-percentile separation the rule was designed around (roots at 2.5–3.7,
tips at 95.5–96.2, so 92–93 percentiles apart against the old gate's 6) is a criterion the
change optimises *by construction*, and is not evidence for it. Two criteria that it does not:

- *Spatial agreement with an external fact.* Clustering the oldest band on EPY2412A088 recovers
  *three inoculum clusters*, matching the three distinct inocula stated from the bench. The
  count holds at $t_0$ = 18, 24 and 30, and is stable for DBSCAN `eps` from 3600 to 9000 µm —
  four clusters below that plateau, two above. Nothing in the selection rule optimises a spatial
  cluster count.
- *Recovery of known seeds.* On a synthetic plate grown from 1, 3 or 5 known inoculation points,
  the rule returns $hat(k)$ = 1.33 / 3.33 / 4.33 (mean over 3 seeds, tolerance 500 µm), recovering
  $k$ exactly in 33–67 % of runs and moving by at most one root under date noise.

Both are derived in
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/root_node_detection.typ")[`root_node_detection.typ`], which is also where
the comparison against the growth DAG lives. The decision itself was taken in STHype\#208 and
had no ledger entry; what this entry adds beyond recording it is the external validation, which
did not exist when the change was made.

*Discussion.* *The change fixed the axis and did not fix groundedness.* Counting components
that fail to reach the plate bottom, at $t_0$=24: EPY088 9/37, LPD022 6/51, LPD025 111/140,
PNF080 79/124, STR112 0/57. Counting components the rule returns no root for — the solver-side
quantity, a singular Laplacian block — gives 26/37, 8/51, 126/140, 83/124, 3/57. These are
different quantities, and nested rather than correlated: bottom-connection asks only whether the
component contains oldest-band material, while the solver-side count additionally requires that
material to sit at a degree-1 node and to survive declustering. That is where the factor of
three on EPY088 comes from — the ledger should not carry
either as "the" ungrounded rate. Neither is automatically a defect, since separate components
on these plates have been measured as genuinely distinct mycelial networks and may be joined
only off-canvas, but the solver still needs a boundary in every block it is handed.

*The growth DAG grounds every component and is not a drop-in replacement.* It returns a root in
every component on every plate and timepoint measured, but roughly 80 % of those roots sit at
*interior* nodes — origins of growth that emerges behind the advancing front rather than at a
tip — which the activation band cannot represent by
construction. The two answer different questions, and the open proposal is to compose them:
DAG roots filtered by bottom-connection, which would keep the DAG's per-component coverage and
the band's spatial precision. It is not built, and it should be scored on the synthetic venue
against known seeds before any real-plate claim.

Two smaller items. Only EPY088 has an inoculum count from the bench; the other four plates'
counts (LPD022 9, LPD025 1, PNF080 2, STR112 1) are measurements of oldest-band geometry, not
confirmed inocula, and LPD025 is the case that most needs a ground truth. And every number here
is at $t_0$=24 on a fragmenting subgraph, so a component ungrounded at 24 may be continuous with
an inoculum by 30.
