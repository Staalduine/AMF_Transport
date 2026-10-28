#import "../shared.typ": *

== Step D3 — Backflow model

#entry("D3", [Motors away from the roots on every edge], dead, kind: feature, tag: "d3-outward-motors")

*Problem.* Motor direction from the sign of a near-zero net flux flips along single hyphae
(#link(<d3-hypha-motors>)[the per-hypha entry]), which distorts the global return.

*Intent.* Replace the sign with geometry: every edge's motors run towards increasing network distance
from the roots, the rule the model already used on zero-flux edges (`motors_on_zero_flux`).

*Implementation.* `motor_direction_outward` in `backflow_model.add_backflow_model_to_stg`
(transport_paper `1b808fc`, kept as a diagnostic): the direction is the sign of the root-distance
difference across each simplified edge, from a multi-source Dijkstra on length; an edge whose net flux
points the other way has its lipid demand carried outward with the motors, since the solver refuses
lipids flowing against them.

*Evidence.* It scores better — the global return goes from 0.591 to 0.514 log RMSE and 81 % to 87 %
within 2× on 1,189 edges — but it is rejected on what it does to the network, not on the score: a
root-distance direction leaves many edges with no growing tip downstream, so the lipid supply the
hydraulic solve routes through loops to the tips is cut off. The same rule by shortest distance was
tried earlier and rejected for isolating much of the network. The score gain also comes with the
global return losing its shape along trails (median rank correlation 0.34 → 0.15).

*Discussion.* A variant that avoids the stranding keeps the solve's routing and only removes the sign
noise, which is what the per-hypha direction does.

#entry("D3", [Motor stream scaled by net-flux strength on loop edges], dead, kind: feature, tag: "d3-flux-scaled-motors")

*Problem.* The same sign noise as above: loop edges with near-zero net flux run the full motor stream
in an arbitrary direction.

*Intent.* Let the motor stream fade where the solve barely orients an edge, as if motors ran both
ways: $q_s dot tanh(|Q_"net"| \/ Q_0)$ on loop edges (edges that lie on a cycle of the network), full
motors on tree edges, whose direction is never ambiguous.

*Implementation.* `motor_flux_scale` ($Q_0$) in `add_backflow_model_to_stg` (transport_paper
`1c49842`), applied through the existing per-edge `velocity_scale`, after the core radius is solved
at the base speed. Tried at $Q_0$ = 1, 3 and 10 in units of the raw GIMF flux.

*Evidence.* Worse at every $Q_0$, and worse as it grows: global-return log RMSE 0.702, 0.846 and 1.234
against 0.591 unscaled; the local return goes from 0.422 to 0.770 at $Q_0 = 3$. The failure was
predicted before the run: measured brightfield backflow on flipped edges is 2.86 µm/s against 3.09 on
the rest, so these edges carry nearly normal return, and fading their motors drives the prediction
towards zero where about 3 µm/s is measured.

*Discussion.* A variant that dodges this must keep the return's size on low-flux edges and fix only
its direction.

#entry("D3", [Routing the return on $a^3$ or $a^2$ instead of Poiseuille's $a^4$], dead, kind: feature, tag: "d3-core-conductance-exponent")

*Problem.* The core return is routed on Poiseuille conductances $G prop a^4 \/ L$, a physical
assumption the data had never been asked to confirm.

*Intent.* Let the data choose the exponent $n$ in $G = pi a^n A_"ref"^(4-n) \/ (8 mu L)$, held equal to
Poiseuille at $a = A_"ref" = 4$ µm so only the weighting by width moves.

*Implementation.* `core_conductance_exponent` in `run_backflow_model`, tried at $n$ = 4, 3 and 2.

*Evidence.* A typical edge moves by 5 % and 10 %, and no aggregate changes: within 2× 0.68, 0.69 and
0.69 on all edges. With $a\/b approx 0.975$ nearly everywhere the exponent only reweights edges by
width. Poiseuille stays as the physically motivated default, declared as a choice the data cannot
distinguish rather than a result;
#link("../../backflow_model_accuracy.typ")[the backflow accuracy document],
`sec-measured-model`.
