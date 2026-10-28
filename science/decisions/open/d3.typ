#import "../shared.typ": *

== Step D3 — Backflow model

*Input:* each edge's outer radius and length, and the lipid current the circuit model pulls
through it. *Output:* a predicted rootward velocity per edge. The physical picture is a lipid
annulus travelling tipward at the motor speed $v_0$, and a non-lipid core carrying the return
flow; the core radius follows from conservation, so more lipid demand means a thinner core.
This is the step the whole of Part D exists to produce, and the one every measurement is
compared against.

Two things about it shape the entries below. Its prediction is a *magnitude* as well as a
pattern, which makes it unusually falsifiable — and unusually exposed to any scale error in
its inputs. And its free parameter, the lipid fraction $theta$, is the only knob on it that
has ever been shown to change a score.

#entry("D3", [$theta = 0.2$ against the published $theta = 0.05$], open, kind: cleanup, tag: "d3-theta-value")

*Problem.* The lipid fraction $theta$ is a free parameter. The paper reports $0.05$; the code
defaults to $0.2$; most of the analysis was computed at $0.05$. Those cannot all be right, and
until now nothing scored them against each other at the edge level.

*Evidence.* Every model variant that exists in the current output format, scored on the same
903 backward-brightfield edges with a seeded bootstrap interval:

#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  inset: 5pt,
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { (bottom: 0.2pt + luma(220)) },
  [*variant*], [*Spearman*], [*RMSE (µm/s)*], [*bias*],
  [baseline, $theta = 0.05$], [+0.028 \ [−0.04, +0.09]], [3.66], [+0.31],
  [*$theta = 0.2$*], [*+0.105* \ [+0.04, +0.17]], [*2.56*], [−0.45],
  [tip throttle], [−0.012], [3.70], [−0.82],
  [weak pressure pin], [+0.018], [3.77], [+0.37],
  [annulus floor 0], [−0.086], [4.09], [−2.12],
  [annulus floor 0.9], [+0.015], [3.60], [+0.07],
)

$theta = 0.2$ is *the only knob that does anything*: RMSE falls 3.66 → 2.56 and rank skill
rises +0.028 → +0.105, both with non-overlapping intervals, and only the $0.2$ interval
excludes zero. Every other variant sits inside the baseline's own confidence band, which is to
say *not distinguishable from changing nothing*.

*Discussion.* The sharpest reading is not that $0.2$ is good but that *$0.05$ is not
distinguishable from having no edge-level skill at all* — its interval is [−0.04, +0.09],
straddling zero. Most of the transport analysis is computed at that value, so its edge-level
claims should be read as untested rather than as weak.

This is `open` rather than shipped because choosing $theta$ is a claim about lipid physiology,
not a fit: $0.2$ scoring better on this data does not by itself establish that a fifth of the
tube is lipid. What the measurement does establish is that the *current* published value is
the worse of the two on every criterion tried, which is a reason to justify it explicitly or
change it, not to leave it unstated.

One caution before acting: the annulus-floor sweep produced an apparent RMSE improvement that
*evaporated once the intervals were drawn*. Any future variant should be judged against the
baseline's own band, not against its point estimate.

#entry("D3", [The per-edge activity factor the model cannot see], open, kind: feature, tag: "d3-activity-factor")

*Problem.* After the loop hypothesis died and every boundary-condition variant measured as
indistinguishable from nothing, the question became why *no* amount of tuning produces
edge-level skill.

*Evidence.* Roughly half the edge-level variance in the measured flows is a *single latent
per-edge factor* that loads on all four flow channels at once — water and lipid, forward and
backward. It is only weakly explained by geometry or by position, it is not development, and
it is not measurement noise. It is also *invisible to the model*, correlating with it at about
$rho = 0.07$.

*Discussion.* This reframes every negative result above. The model has no variable for the
thing that varies most between edges, so boundary conditions, partition models and throttles
are all adjustments to a description that is missing its dominant term — which is exactly what
"indistinguishable from changing nothing" looks like from the inside. *Further tuning of the
existing model is not worth doing until this is identified*, and that is the useful content of
this entry: it closes a direction rather than opening one.

The candidate worth testing is something about local wall or membrane state that gates all
transport on an edge at once, which would explain the loading across all four channels
simultaneously. Whatever it is, it has to be per-edge, shared across directions and species,
and largely independent of the geometry the model already knows.

