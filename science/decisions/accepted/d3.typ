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
its inputs. And its free parameter, the lipid fraction $theta$, was the only knob on it shown
to change a score until September, when how far each hypha's return travels (the entries on the
local return below) turned out to matter more than $theta$ ever did.

#entry("D3", [The $a > b$ data-quality gate], shipped, kind: cleanup, tag: "d3-dataquality-gate")

*Problem.* The backflow model represents a hypha as a lipid annulus of outer radius $b$ around
a core of inner radius $a$, so $a < b$ holds by construction. On *18.5 %* of edges it did not:
the inner radius came out *larger* than the outer, which is physically impossible and
invalidates every occupancy ratio $b^2\/a^2$ the model computes.

*Intent.* Treat it as a gate rather than a curiosity — nothing downstream is interpretable
while a fifth of the edges are geometrically impossible, so the analysis stops until the rate
is zero.

*Change.* Two provenance bugs in the pipeline, neither of them physical, both patched and the
pipeline re-run.

*Evidence.* Afterwards $a > b$ occurs on *0.00 %* of edges, and the occupancy ratio bottoms out
at exactly $1.0$ — the value it must take when the annulus vanishes. That the floor lands on
the theoretical bound rather than near it is the check worth having: it is a criterion the fix
cannot satisfy by accident, whereas "the rate went down" would have been satisfied by any
clamp.

*Discussion.* The durable consequence is a convention: every ratio-based result now uses the
model's *own outer radius*, never half the measured width. Those are different quantities that
happen to be close, and mixing them is how the impossible values arose in the first place.

Worth reading beside `D1` *Width may reach the transport model in the wrong unit*, which is
still open — a systematic scale error on width would be invisible to this gate, because $a$
and $b$ would scale together and their ordering would be preserved.


#entry("D3", [The prediction is the core-return plug speed], shipped, kind: cleanup, tag: "d3-plug-speed")

*Problem.* The model's reported speed was $|v_"max"| dot 2\/3$ of a Poiseuille core running back
against the motor speed, $u(r) = v_0 - P (1 - r^2\/a^2)$, justified by an assumed averaging factor
of the velocimetry. Where $P approx v_0$ the two terms cancel and the prediction collapses towards
zero (91 zero outputs over 1,248 measured edges). Measure it as the share of measured edges within a
factor of 2, and the number of zero outputs.

*Intent.* Report the quantity the second solve actually determines: the core's return flux over the
core's cross-section.

*Change* (17 Sep). The prediction is $|q_c| \/ pi a^2$. For a Poiseuille core this equals $|P| \/ 2$
exactly, so the ½ is not an averaging choice and the ⅔ alternative has no basis.

*Implementation.* `transport_paper` model tables (`model_accuracy_table.py`, `bflow_flux` over
$pi a^2$); `P` survives only as an intermediate.

*Evidence.* Within 2× on 72 % of 1,248 measured edges (bias 0.97, 10 zero outputs), against 55 %
(bias 0.72, 91 zeros) for the shipped throttled output and 82 % for a held-out constant. The
identity $|P|\/2 = |q_c|\/pi a^2$ is checked to a ratio of 1.000 on every edge, which the scoring
does not touch. Details in
#link("../../backflow_model_accuracy.typ")[the backflow accuracy document],
`sec-measured-model`.

*Discussion.* A constant still beats it on level; what the model adds is shape along trails. How the
velocimetry samples the radial profile is not settled by the within-video speed spread, so the
measured-to-centreline ratio remains an assumption the prediction rests on.

#entry("D3", [Forward speed from an offset profile, not a zero at the tip], shipped, kind: feature, tag: "d3-offset-forward")

*Problem.* The motor speed the model runs on was throttled as $v_0 (1 - e^(-d \/ lambda))$ in distance
$d$ to the nearest growing tip ($v_0 = 2.87$ µm/s, $lambda = 749$ µm), which forces the speed to zero at
a tip. Tip positions are uncertain at network scale, and measured forward flow does not stop there.
Measure it against brightfield forward streak speeds, which the backflow score never sees.

*Intent.* Fit the forward profile with a floor: $v(d) = v_infinity - (v_infinity - v_"tip") e^(-d \/
lambda)$.

*Change* (18 Sep, transport_paper `b6f335e`). The offset form #strike[with $v_infinity = 3.09$ µm/s,
$v_"tip" = 1.85$ µm/s, $lambda = 1.6$ mm, fitted on 1,116 brightfield streak edges over 12 sessions
(fold ranges 3.04–3.11, 1.76–1.88, 1.4–1.8 mm). Selected by `--offset-throttle` in the model-table
scripts; the old form stays the default.] *Superseded 2026-10-07:* it is now the only throttle, with the constants in the amendment below.

*Implementation.* `lane_model_trails.offset_forward_speed` (constants `V_INF_OFFSET`, `V_TIP_OFFSET`,
`LAM_OFFSET`), passed to `add_backflow_model_to_stg(tip_throttle=...)` by
`model_accuracy_throttle.py`.

*Evidence.* Median |log error| on forward speed 0.11, against 0.13 for both the old form and a
constant (pooled, not held out by session). On backflow — the criterion the fit never sees — the
global return goes from 75.6 % to 77.4 % within 2× and the local return keeps its 86–87 %, over 1,178
edges (`transport_paper/fig_outputs/model_accuracy_local/RESULTS_local.md`).

*Discussion.* #strike[Not written up in a science document yet; the fit's provenance is
`fig_outputs/model_accuracy_measured_bf_streaks/analysis/FORWARD_MODEL_offset.md`.] *Superseded
2026-10-07:* written up in #link("../../forward_speed_models.typ")[the forward speed models
document]. #strike[The fluorescence
forward profile has a slow component one exponential cannot follow.] *Superseded 2026-10-07:* on the
5-frame fluorescence streaks the offset form fits with a length scale of 1.5–3.3 mm, and the lipid
stream slows near tips as the brightfield one does.

*Criteria.* *Yes* when a held-out-by-session forward fit keeps the offset form ahead of the old one
and of a constant. *No* if it does not, since the backflow gain alone is within noise.

*Amended 2026-10-07 — shipped, and its criterion is met held out by plate.* The offset form has been
the solver's only tip throttle since 24 Sep (transport_paper `d51c3a7`: the exponential and demand
throttles were removed), with constants refitted on 25 Sep to $v_infinity = 3.096$ µm/s, $v_"tip" =
2.140$ µm/s, $lambda = 1711$ µm on 1,054 brightfield edges over 12 sessions
(`lane_model_trails.py`, `V_INF_OFFSET` and its neighbours). Fitted on four plates and scored on the
fifth, over 1,503 brightfield edges on 5 plates (the edges with both streams measured, 15 sessions),
it is ahead of the old form and of a constant on forward speed: median fold-change error, the
exponential of the median |log error|, 1.14 against 1.16 and 1.17, and the gap widens within 1 mm of
a tip (#link("../../forward_speed_models.typ")[the forward speed models document]). That
criterion is the fit's own target, scored out of sample, so the backflow gain above stays the
independent one. Re-scored on 8 Oct with the shipped constants against the old form, run the
same way (global return, 1,187 brightfield edges over 12 sessions), it holds: within 2× 77.8 % against
74.9 %, bias 0.96 against 0.85, and no zero outputs at tips against 10 (transport_paper
`forward_speed_followups.py --d3`). The local-return comparison has not been re-scored. What it does not settle: tip distance alone orders edges by forward speed poorly,
and a hypha's width orders them better, but a width term in the motor speed lowered backflow rank in
the network solve, so width has no entry here.

#entry("D3", [The return stays in the hypha that drove it (local return, $kappa$)], gated, kind: feature, tag: "d3-local-return")

*Problem.* The second solve routes the whole network's core return by one pressure solve, so a hypha's
return can leave through any loop. On a tree that is identical to returning it locally; on loops it
lets the solve push return flux over millimetres of other hyphae. Whether real returns travel that far
is the question. Measure it on measured backflow per edge (within 2×, log RMSE) and within trails
(rank correlation).

*Intent.* A knob $kappa in [0, 1]$ that mixes the global solve with a per-edge local return,
$q_c = kappa (q_s - Q_"net") + (1 - kappa) q_c^"global"$: at $kappa = 1$ the return is the motor flux
minus what the growth routing says continues past the edge, with no solve at all.

*Change* (18 Sep, transport_paper `da9f397`). `return_locality` on `run_backflow_model` and
`add_backflow_model_to_stg`; default `None`, bit-identical to the global solve.

*Implementation.* `transport_paper/compute_funcs/circuits/testing_new_model.py` (`return_locality`,
`net_flux`); `--return-locality` in `model_accuracy_throttle.py`. At $kappa = 1$ the second solve is
skipped.

*Evidence.* Over 1,178 brightfield edges with the
#link(<d3-offset-forward>)[offset forward speed], within 2× rises from 77.4 % ($kappa = 0$) to
86.6 % ($kappa = 1$), held out by session; with the floor and width entries below, rebuilt on a later
table of 1,189 edges, the local return reaches 92 % against 81 % for the global one. Within trails it keeps a
median rank correlation of 0.37 against the global return's 0.30–0.34 — the shape criterion that a
level fit does not optimise.

*Discussion.* The local return is accurate largely because it is nearly constant: its predictions sit
in 2–5 µm/s against a measured 0.3–8. The global return is expressive but misplaces edges; on single
trails (EPY2412A088 t55, LPD2412A025 t50) it follows the fall of backflow along a trunk that the local
return cannot produce. Its worst misses trace to motor-direction flips on near-zero net-flux edges
(transport_paper\#70). Not yet written up; results in `transport_paper/fig_outputs/
model_accuracy_local/RESULTS_local.md` and the `09*` figures of the September transport talk.

*Criteria.* *Yes* for $kappa = 1$ as the default when it stays ahead on held-out sessions of a plate outside the fitted ones. *Gated* while the global return is still being repaired
(transport_paper\#70). *No* if a repaired global return matches it on all edges, since the global
solve is the one with a physical routing. *Amended 2026-10-08:* transport_paper\#70 closed on 23 Sep,
its loop error traced to the global return's circulation around cycles rather than to direction
flips, so the *Gated* clause no longer holds anything back; the status now waits on the *Yes* and
*No* tests themselves, neither scored on the tables rebuilt since.

#entry("D3", [A floor on the core radius, $a >= 0.8 b$], gated, kind: cleanup, tag: "d3-core-floor")

*Problem.* The core radius follows from the lipid demand, $a^2 = b^2 - J \/ (theta v pi)$. On
high-demand edges it collapses, and the plug speed $|q_c| \/ pi a^2$ explodes: 29 of 1,199 measured
edges have $a\/b < 0.5$, predicted 3.9× their measured speed at the median and up to 599 µm/s.

*Intent.* Cap how far demand can thin the core.

*Change* (19 Sep, transport_paper `c931278`). `a_min_frac` on `calc_inner_radius`: $a >= f b$ on every
edge; default `None`, bit-identical.

*Implementation.* `testing_new_model.calc_inner_radius(a_min_frac=...)`; `--a-min-frac` in the model
scripts, run at 0.8. Four alternatives were scored the same way: a constant $a\/b$, returning through
the whole tube, a free exponent on $b\/a$, and the exponent with a floor.

*Evidence.* For the local return, held out by session, log RMSE falls from 0.584 to 0.449 and within 2×
rises from 86.6 % to 89.5 % (1,199 edges); on the $a\/b < 0.5$ edges within 2× goes from 10 % to 76 %.
The floor chosen per held-out fold was 0.8 or 0.85. Results in
`transport_paper/fig_outputs/model_accuracy_local/CORE_RADIUS.md`.

*Discussion.* The floor is a patch on the demand-derived geometry, not a physical constraint; a
measured annulus ratio from the two video channels (0.603,
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[the two-channel annulus finding]) disagrees with the 0.975 the lipid balance implies, and neither
the floor nor the constant-ratio variant resolves which is right.

*Criteria.* *Yes* once the $a\/b$ inconsistency is resolved and a floor is still needed. *No* if a
measured geometry replaces the demand-derived one.

#entry("D3", [The return area narrows with hypha width], gated, kind: feature, tag: "d3-width-return")

*Problem.* The local return's residual rises with the hypha's own width (rank correlation 0.30 with
log measured over modelled), so wide trunks run faster than the model says.

*Intent.* Scale the return area with width: $r^2 = a^2 (w_"ref" \/ w)^beta$, capped at $b$, so speed
grows as $w^beta$.

*Change* (19 Sep, transport_paper `21f949a`). `return_width_exponent` (and
`return_width_ref_um = 11.64`) on the backflow model; default `None`, bit-identical. Run at
$beta = 0.70$.

*Implementation.* `backflow_model._return_radius`; `--return-width-exponent` in
`model_accuracy_throttle.py` and `lane_model_trails.py`. The local width range and nearby maximum
width were tested as alternatives and add little.

*Evidence.* On the local return with the floor, held out by session, log RMSE falls from 0.443 to
0.417 and within 2× rises from 90.7 % to 91.9 % over 1,178 edges, against a held-out constant's 0.469
and 89.6 %. $beta = 0.70$ itself was then fitted on those same edges, so the shipped run's numbers
are slightly in-sample. Results in `transport_paper/fig_outputs/model_accuracy_width/WIDTH.md`.

*Criteria.* *Yes* if $beta$ fitted held out by plate stays near 0.7 and keeps the gain. *No* if the
gain disappears once $beta$ is out of sample.

#entry("D3", [One motor direction per hypha], dead, kind: cleanup, tag: "d3-hypha-motors")

#track("transport_paper#70")[]

*Problem.* Each edge's motor direction is the sign of its net growth flux, which on loop edges is
\~0 (on PNF2307A072 t49 a median of 0.12 against a motor stream of \~134), so the direction flips from edge to edge
along one hypha: 15 % of measured brightfield edges, all on loops. The global return then drives full
motor flux in whichever direction the noise picks — and cancels to zero where it cannot follow, such
as the 16.2–16.5 mm stretch of PNF2307A072 t49/Middle. Measured fluorescence does not reverse on
flipped edges (tipward/rootward speed 1.02 against 1.10, no drop below 1), so most flips are
artefacts.

*Intent.* Keep the hydraulic solve's routing but give each hypha one direction: chain edges into
hyphae by continuing straight through junctions, and orient every edge of a hypha by the sign of its
length-weighted net flux.

*Change* (20 Sep, transport_paper `1c49842`). `motor_direction_per_hypha` on the backflow model;
default `False`. *Superseded 2026-10-08:* removed on 24 Sep (transport_paper `a51c6af`), see the
amendment below.

*Implementation.* #strike[`transport_paper/compute_funcs/hypha_direction.py`] *Superseded 2026-10-08:*
`hypha_direction.hypha_motor_direction`, deleted in `a51c6af`; read it at `a51c6af^`. The chaining
it voted over (`hyphae`, `_chain`, `leg_direction`) survives in `hypha_direction.py` for the
growth routing. The decision points, for anyone reviving it:
- *Chaining.* At each junction the legs are paired straightest first, each leg's direction taken
  60 µm along it, and a pair continues one hypha if it bends less than 30°; a degree-2 node always
  continues. So every edge belongs to exactly one hypha, and a hypha may close on itself around a
  loop.
- *The vote.* Per hypha, the sign of the length-weighted sum of the GIMF net growth flux on its
  edges, each signed along the hypha's own orientation; every edge then takes that sign. A hypha
  whose sum is exactly zero keeps the per-edge default. Magnitudes stay per edge; only directions
  are overwritten.
- *What rides with it.* The imposed direction also carries the edge's lipid demand, since lipids
  ride the motors.
- *What it was compared against.* The raw per-edge GIMF sign (the default) and, later, the growth
  graph's direction — the way each hypha grew, from the dated network.

*Evidence.* For the global return, trail segments improve (log RMSE 0.585 → 0.551) and the example
trail PNF2307A072 t49/Middle loses its zero (0.84 → 0.55), but all measured edges get slightly worse
(0.591 → 0.615): of the 581 edges whose prediction moves by more than 5 %, 300 improve and 281 worsen.
The local return is unaffected, since it uses the size of the return, not its direction.

*Criteria.* *Yes* if a stricter continuation rule (15°) or a vote over sub-hyphae removes the
all-edge loss. *No* if no variant improves all edges, since the trail gain alone is two example trails.

*Amended 2026-10-08 — dead: removed as a model option, no better than the per-edge sign it was
meant to correct.* The vote was removed on 24 Sep (transport_paper `a51c6af`) so that the model's
motor direction comes from one of two sources only: the GIMF net-flux sign or the growth graph. The
measurement behind that is a different criterion from the backflow score above, and one the vote
does not optimise: agreement with the *observed* motor direction. On 419 edges with an identifiable
motor stream the observed direction matched the growth graph on 89 %, the raw GIMF sign on 78 % and
the per-hypha vote on 77 %; on the hand-picked trails, GIMF 85 % and the vote 84 %
(#link("https://github.com/Staalduine/rhizosphere/blob/main/log/2026-09-23-the-data-leave-no-room-for-global-pressure-routing-and-the-motors-follow-the-fixed-growth-graph.md")[the 23 Sep log entry],
`motor_direction_compare.py`). Those numbers were read from model outputs written before the sign
fix of transport_paper\#93, and the comparison was not repeated after it
(#link("../../motor_direction_and_lipid_distribution.typ")[the motor direction document]).
Neither variant in the *Criteria* was tried. The issue it answered, transport_paper\#70, closed on
23 Sep for a different reason: the global return's loop error was traced to circulation around
cycles, not to direction flips, and under a zero-net-flux return the motor direction leaves the
to-root speed unchanged (median ratio 1.000).
A variant worth predicting before building: a vote that smooths the *growth-graph* direction rather
than the GIMF sign starts from the source that already matches the motors best, so it would have to
beat 89 %, not 78 %.
