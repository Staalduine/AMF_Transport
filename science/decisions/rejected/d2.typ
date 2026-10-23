#import "../shared.typ": *

== Step D2 — GIMF circuit model

*Input:* the growth graph with its tip demands and root nodes. *Output:* nodal pressures and a
forward flux per edge, obtained by mapping the network to a resistive circuit and solving
Kirchhoff's laws. The entries here are mostly *rejected variants*, which is worth stating
plainly: the circuit model reproduces the population physics and the spatial profile, and the
attempts below to give it edge-level skill by adjusting its boundary conditions all failed.

#entry("D2", [Throttles, weakened pins, and annulus-activation floors], dead, kind: feature, tag: "d2-throttles-pins")

*Problem.* The backflow model reproduces the population physics but has no edge-level rank
skill. Four knobs were tried against that: the lipid fraction $theta$, a tip-distance and
demand *throttle* on the motor stream, a *weakened pressure pin* at the roots, and an
annulus-activation term swept over its floor.

*Evidence.* Every one had previously been judged by eye on a point estimate. Scored with
bootstrap intervals on the same 903 edges, all of them except $theta$ sit *inside the
baseline's own confidence band* — which is to say they are not distinguishable from changing
nothing. The floor sweep is the instructive one: a floor of $0.7$ appeared to improve RMSE from
$0.73$ to $0.51$, and that improvement *evaporated once the intervals were drawn*.

*Discussion.* The reason to keep this as an entry rather than delete it is that the variants
are not obviously bad ideas, and someone will propose them again. Each changes the profile's
*shape* visibly, which is exactly why eyeballing them was persuasive and why point estimates
were not enough.

One of the four is not dead, and the distinction is the useful part. The *all-roots pressure
pin* is the right boundary condition and is kept — but *the evidence for it is not RMSE*, on
which the weak pin is indistinguishable from it. It is the *root-end value*: the weak pin
pushes the profile to $-4.01$ against a measured $-3.71$, where the all-roots pin gives
$-3.69$. A summary statistic averaged over a profile can be blind to a discrepancy that is
localised at one end of it, so the criterion has to be chosen to match where the variants
actually differ.

See `D3` *$theta = 0.2$ against the published $theta = 0.05$* for the one knob that does
something, and `D3` *The per-edge activity factor* for why the rest cannot.

#entry("D2", [The loop hypothesis], dead, kind: feature, tag: "d2-loop-hypothesis")

*Problem.* The backflow model has edge-level rank skill on *exactly one* plate out of five.
That skill is real on its own terms — it survives controlling for tip distance, is stable
across a wide range of $theta$, and is not a measurement-quality artefact, since that plate has
the *worst* per-video signal-to-noise of the set. So the question was not "is the model
broken" but "what is different about that plate".

*Intent.* An answer presented itself, and it was structural rather than fitted. GIMF and
equipartition are *provably identical on a tree*, and on a tree the model collapses to an exact
local closed form. Their disagreement is therefore a *loop indicator* that costs nothing to
compute. If loops were what defeats the model, the most tree-like plate should be the most
predictable — and across five plates it was, at $rho = -0.70$ between loopiness and skill.

*Evidence.* The hypothesis makes a sharp prediction — tree-like edges should show skill, loop
edges none — and it was tested on the edges rather than on the plate means:

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, right, right, left),
  inset: 5pt,
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { (bottom: 0.2pt + luma(220)) },
  [*edge class*], [*n*], [*Spearman*], [*95 % CI*],
  [tree-like], [120], [*−0.016*], [[−0.20, +0.16]],
  [weak loop], [129], [+0.036], [[−0.14, +0.22]],
  [loop], [383], [+0.065], [[−0.04, +0.16]],
  [strong loop], [271], [−0.070], [[−0.18, +0.05]],
)

Tree-like edges give *flatly zero*, with no trend across the classes. And computed *within*
each plate the effect has no consistent sign — it is positive on some plates, negative on
others, and the two largest within-plate effects point in opposite directions.

*Discussion.* The five-plate correlation was a *plate-level confound*: with five points it
cannot separate loopiness from any other property that varies between plates, and the same
correlation computed across the thirty individual trails is only $+0.21$ at $p = 0.27$. The
seductive table was the entire evidential basis, and it dissolved the moment the analysis moved
to the unit the claim was actually about.

Worth stating what did *not* die with it. The GIMF–equipartition gap is a *valid* loop
indicator — that part is provable, not fitted, and it remains a cheap way to ask how tree-like
a region is. What died is the claim that loopiness explains model skill.

The generalisable lesson is the one this document keeps paying for in different currencies:
*an aggregate correlation over five units is a hypothesis, never a result*, and the check is
to recompute it at the level the mechanism operates on. Here the mechanism is per-edge, so the
per-edge test was always the deciding one — and it was cheap. It is also worth noticing that
the plate carrying the original skill rests on a single timepoint and twenty-two edges, which
is enough to justify a test and nowhere near enough to believe a conclusion.

