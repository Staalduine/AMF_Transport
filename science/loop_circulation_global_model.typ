// finding: open
#set document(
  title: "Loop circulation in the global backflow model — what the data allow",
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
#show figure.where(kind: table): set block(breakable: false)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Loop circulation in the global backflow model]
  #v(-0.3em)
  #text(19pt, weight: 700)[what the measured flows allow]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · 15 sessions on 5 plates · 548 measured trail segments, 1,567 scored edges (1,347 on loops),
    76 filmed junctions, one root cut · \@3a5f765
  ]
]
#v(1.2em)

= Introduction

#question[The paper's backflow model sends the to-root flow through the whole hyphal network with one pressure solve, so on loops a hypha can return more or less than its own to-tip stream. Where does that routing go wrong, does anything in the measured flows show the circulation it predicts, and can the solve be changed so that it matches them?]

We image a growing colony of _Rhizophagus irregularis_ every two hours, segment every frame into a network graph, and
date each segment by when it first appeared. Short videos record the flow inside chosen hyphae: a to-tip stream at
about motor speed and a to-root stream. The backflow model predicts the to-root speed on every segment of the network
from the growth of the next four frames.

The model has two ways to return the motor stream. In the *global model* (the paper's) the motors are flux sources and
the return is found by a second pressure solve over the whole network (the first, the growth-induced mass flow or GIMF
@heatonGrowthinducedMassFlows2010, routes the growth demand from the roots to the tips), on the Poiseuille conductance of each hypha's
core; the roots are pinned to a reservoir. On a tree the return on every edge is fixed by volume conservation, and the
global model returns each hypha's own motor stream. On a loop it does not have to. The difference, the *net flux*
$n = q_s - q_c$ (motor flux minus return), then runs around the loop: a *circulation*. The *conveyor* (zero net flux)
returns every edge's own motor stream, $q_c = q_s$, with no second solve.

= Motivation

The global model is the one the manuscript presents, and its second pressure solve is the part that makes it a network
model. Three things depend on whether that solve is right:
- *the main-text model.* Figures 4–6 and their captions describe network routing of the return. If the data reject the
  routing, the model the paper presents has to change or carry the rejection as a stated limitation;
- *the loop edges.* Tree edges score the same under any routing, and 86 % of the measured edges sit on loops (the
  colony adds loops as it grows @oyartegalvezTravellingwaveStrategyPlant2025), so the model's accuracy is decided there;
- *what the model can be asked next.* The spread of the measured speeds and the fastest returns are still unexplained.
  Whether they are routing effects decides where the next model term goes.

= Method <sec-method>

== The global solve returns each loop's motor flux by conductance, not hypha by hypha <sec-m-solve>

The second solve takes the motor flux $q_s$ on every edge as given (set by motor speed and the hypha's lumen) and finds
node pressures $P$ such that the return $q_c = G (P_v - P_u)$ balances the motor flux's imbalance at every node, with
the roots pinned by a reservoir conductance: the Poiseuille network picture of fungal flow
@heatonGrowthinducedMassFlows2010 @roperMycofluidicsFluidMechanics2019. $G = pi a^4 \/ (8 mu L)$ is the Poiseuille conductance of the core of
radius $a$ over the edge's length $L$.

Read as a circuit, every edge carries its own pressure demand: returning exactly its own motor stream needs a pressure
drop $q_s R$ across it, with $R = 1\/G$. Around a loop these demands generally do not add to zero, and one pressure
field cannot satisfy them all. The global solve finds the return that is a pressure gradient, which is the
least-squares projection of those demands onto a potential. Its remainder is the circulation: the net flux around the
loop, the loop's total mismatch of $q_s R$ divided by its total resistance.

All results below use the direction × split grid's GIMF-motors, GIMF-split cell under both backflow models
(`fig_outputs/model_grid/{global,zero_net}/gimf_gimf`: θ 0.05, core floor 0.8, width exponent 0.7, the offset tip
throttle), whose network dumps carry every edge's $q_s$, return, core radius and length. A standalone re-solve from
those dumps (`global_routing_errors.solve`) reproduces the paper model's return to a relative 10⁻¹⁰. Every variant
below changes only the second solve; the motor flux, core radii and motor directions stay the paper model's.

== Three amendments: a junction resistance on every leg, one only where flow changes hypha, and a membrane leak <sec-m-amend>

- *Junction resistance, every leg.* At every node of degree ≥ 3 each leg carries half of a resistance $R_j$ that only
  the net flux crosses: each edge is its demand $q_s R_e$ in series with $R_e + R_j$. A hypha's own motor stream and
  return then close within its junction-to-junction branch and only the exchange between branches meets the junction.
  $R_j$ is quoted as $L_j$, the length of a 4 µm-radius core with that resistance. $L_j = 0$ is the paper model;
  $L_j -> infinity$ the conveyor.
- *Junction resistance, switching only* (the *through-pass* version): flow that stays in one hypha through a junction
  is free, flow that changes hypha pays. Each junction's legs are paired into straight
  through-passes (directions to the point 60 µm along each leg; a pair is a pass if it turns less than 60°). Flow along
  a pass pays nothing; switching from one hypha to another crosses $R_j$. 83,386 of the 88,703 junctions have a pass.
  The solver carries this version as an option (`junction_um`, `compute_funcs/junction_coupling.py`), used in
  @sec-r-solver.
- *Osmotic leak.* Every edge exchanges water with the medium through its membrane: a conductance to a bath at the
  reference pressure, proportional to its membrane area. It is set by the length $lambda$ over which a pressure difference decays in a reference hypha,
  $lambda = sqrt(a^4 \/ (16 mu L_p b))$ for membrane permeability $L_p$ and cytoplasm viscosity $mu$.

The document also splits crossings (degree-4 nodes whose legs pair into two straight passes) and tries other
conductance laws; these are in @sec-deadends.

== Seven tests, from the model's errors to the flows the videos measure <sec-m-tests>

The measure throughout is the to-root speed: the median of the brightfield streaks per edge or per trail segment,
against the model's $|q_c| \/ (pi r^2)$ with $r$ the width-exponent return radius (the model's own bookkeeping). A
model is *within 2×* (or 1.5×) on an edge if its speed lies within that factor of the measured one. The *circulation*
of a variant is the median of $|q_s - q_c| \/ q_s$ over loop edges. The *spread* is the standard deviation of log
speed over loop edges.

+ *Locate the errors.* On the 548 measured trail segments, those where the global model is off by more than 2× while
  the conveyor is within 2× (*misrouted*), and the reverse. For each, the loop its diverted return runs around: the
  shortest path back from the segment's head to its tail along edges whose net flux points onward and carries at least
  15–50 % of the segment's own (`global_routing_errors.py`).
+ *Find what drives the circulation.* Re-solve with one factor of $q_s R$ made uniform at a time (motor speed, width,
  length, or all of them), five stores.
+ *Look for the circulation in the measured flows* (`net_flux_sign_test.py`). On the 1,479 edges with both streams
  measured, the measured net flux share $1 - v_"root" A_"root" \/ (v_"tip" A_"tip")$, with stream areas from a
  bookkeeping (the model's own; equal areas; lanes), against the model's net flux share: its sign where the model's
  circulation is at least 20 % of $q_s$ (765 loop edges), against a null that shuffles the model's shares within each
  store.
+ *Fit the circulation the data ask for* (`inverse_circulation.py`). The net flux that is conserved at every node but
  the roots and minimises the misfit to the measured returns plus $lambda$ times its dissipation (a single Laplacian
  solve per store, with the measured edges as its sources). Cross-validated in five folds held out by 2 mm spatial
  block and by junction-to-junction branch: circulation is real and coherent across hyphae if the fit from the other
  folds brings held-out loop edges closer to measured than the conveyor does.
+ *Test the amendments* on the trail segments, the per-edge tables and the fast segments (measured > 5 µm/s), with $L_j$
  chosen leaving one plate out (`global_routing_errors.py`, `global_routing_through.py`,
  `global_routing_amendments.py`); compare their circulation's direction with the fitted one
  (`junction_vs_fitted_circulation.py`).
+ *Look for the junction resistance in the anatomy* (`junction_neck_widths.py`, `junction_centre_material.py`): lumen
  width against distance from the node on the 218 legs of the 76 filmed junctions (U-Net lumen, outer halo, dark wall
  bands; the first 17 µm from the node read from the time-mean frames), and dark, static material at the node (time-mean
  brightness and motion variance), each against the same read from the leg's far end.
+ *Read the perturbations* (`root_cut_distance.py`, the salt-shock analysis of `04_fig3`): the root cut's effect per 2 mm
  stretch of trail against its distance and junction count from the cut, and the salt shock's to-root and to-tip
  response.

= Results <sec-results>

== The global model's loop errors are its own circulation, 26 % of the motor flux around 4–13 mm loops <sec-r-errors>

On the 548 trail segments the global model is within 2× on 85.0 % and within 1.5× on 65.7 %; the conveyor on 95.6 % and
75.5 %. 69 segments (13 %) are misrouted: the global model is off by more than 2× where the conveyor is within 2×. The
reverse happens on 11. The misrouted segments split evenly between too little return (35) and too much (34) and cluster
on a few trail stretches of the PNF plates: PNF072 t49 Middle (10), PNF080 t91 LeftMiddle (8), PNF072 t37 Right (8)
and Left (7).

The diverted return does not take a local shortcut (@fig-errors). Where the model removes return from a segment, the
volume runs on past it and comes back around a loop of 13.0 mm (median; IQR 10.1–26.0) through 32 junctions; where it
adds return, around a loop of 4.4 mm (2.1–9.3) through 15. None of the loops passes a root. Over all loop edges the
circulation is 26 % of the motor flux.

On the per-edge tables (1,347 loop edges, 220 tree edges) the global model is within 2× on 78.4 % of loop edges against
93.3 % for the conveyor, with a log RMSE of 0.67 against 0.36, and its spread is 0.63 against a measured 0.37. Tree
edges are identical under both, 93.6 %, as the solve requires.

#fig("figures/loop_circulation_errors.png", [Where the global model misroutes the return. *Top:* three trail stretches
with misrouted segments (open circles); every edge coloured by the global model's return against its own motor flux
(blue: less, down to none; red: more, up to 2×); black, the trail; dashed orange, the loop the diverted return of one
segment runs around. *Bottom left:* the junction resistance on every leg: trail segments within 2× and 1.5×, the
misrouted ones within 2×, and the loop circulation, against $L_j$. *Bottom right:* the loop each misrouted segment's
return runs around, where the model removes return and where it adds it.], src: "global_routing_errors.py") <fig-errors>

== The circulation comes from the loops and the motor directions, not from widths, speeds or lengths <sec-r-drivers>

With the motor speed, the width, or the length made uniform across the network, the circulation on five stores moves
from 16–34 % of the motor flux (paper) to 15–34 %, 13–28 % and 17–34 %. With every edge given the same motor flux and
the same conductance it is still 19–34 %. The circulation is set by the network's loops and the pattern of motor
directions around them: two legs of unequal length between the same pair of junctions, both with motors running from
one to the other, cannot have the same pressure drop and each return its own stream. No local property of the hyphae
removes that, and no change of conductance law does (@sec-deadends).

The model does send more return along wider hyphae, the capacity effect a pressure solve is meant to have: its added
return correlates with width (ρ 0.29 on loop edges). The measured excess over the conveyor does not (ρ −0.07), and it
does not grow with the model's added return (regression slope 0.00 against the model's 1).

== The measured flows carry none of the model's circulation <sec-r-sign>

In the model's own bookkeeping the measured net flux has the sign of the model's circulation on 48 % of the 765
strongly circulating loop edges, against 51 % when the model's shares are shuffled (97.5 % of the null below 54 %). Its
correlation with the model's net flux is ρ −0.08, its slope −0.08 against 1. The measured net flux share is flat across
the model's circulation classes (medians −0.13 to −0.05). With equal stream areas (speeds only) agreement rises to 57.5 %
against 52.5 %, but that is width: the model's circulation follows the geometry (ρ −0.46 with the conveyor's area
ratio), and so do measured speed ratios (ρ −0.21). With the geometry removed the correlation is ρ +0.10 by ranks and
−0.08 in the exact bookkeeping. The lanes bookkeeping with the model's core radius puts 70–95 % of the section in the
return lane and fixes the sign by geometry alone; it is not informative.

== The data allow a small circulation of their own, 2–8 % of the motor flux and arranged differently <sec-r-fit>

The fitted circulation predicts held-out loop edges better than chance, but only slightly (@tab-fit). From other 2 mm
blocks it moves 731 held-out loop edges closer to measured and 566 further (p = 5 × 10⁻⁶); from other branches, 756 and
556 (p = 4 × 10⁻⁸). The best-predicting circulation is 3.5 % (blocks) to 8.5 % (branches) of the motor flux. Letting it
grow makes held-out predictions worse. At the measured edges the full fit is 3–21 % of the motor flux per store, larger
on the PNF plates; away from measured edges it falls to 0–3 %. Its pattern is unrelated to the global model's
(ρ −0.17 to +0.17 per store).

#figure(
  table(columns: 5, align: (left, right, right, right, right), stroke: 0.4pt, inset: 4pt,
    [held-out loop edges (1,347)], [median \|log error\|], [within 1.5×], [within 2×], [circulation / $q_s$],
    [conveyor], [0.243], [73.1 %], [93.3 %], [0],
    [fit from other 2 mm blocks, $lambda$ 0.01], [0.239], [74.5 %], [93.9 %], [3.5 %],
    [fit from other branches, $lambda$ 0.01], [0.226], [74.2 %], [93.5 %], [8.5 %],
    [fit, $lambda$ 0.001 (overfits)], [0.245–0.251], [71–72 %], [90–92 %], [8–16 %],
    [global model], [0.350], [–], [78.4 %], [26 %],
  ),
  caption: text(8.5pt, fill: luma(95))[The circulation fitted to the measured returns, cross-validated.
    #text(fill: luma(140))[`inverse_circulation.py`]],
) <tab-fit>

== A junction resistance matches the conveyor's accuracy; the data only bound it and the anatomy shows none <sec-r-junction>

A resistance that only the net flux crosses at junctions shrinks the circulation without touching tree edges
(@tab-junction). On every leg, $L_j$ = 1–3 mm brings the circulation to 2–5 %, the trail segments to 94.9–96.4 % within
2× and 77.7–78.1 % within 1.5×, all 69 misrouted segments within 2× at 3 mm, and the loop edges to 92.7–93.4 % within 2×
with ρ 0.37 (conveyor 0.35). Chosen leaving each plate out, $L_j$ comes out 0.3–3 mm and the held-out accuracy equals the
conveyor's: 75.4 % within 1.5× against 75.5 %, 94.9 % within 2× against 95.6 %. The accuracy is flat above about 1 mm, so
the data set a lower bound on the resistance, not a value: exchange between branches at least 5–18× harder than flow
along one (the resistance of a 1 mm, 4 µm-radius core against a junction-to-junction branch, median 83–173 µm per store), circulation at most a few
percent.

In the through-pass version the same circulation needs about three times the resistance: 3 mm gives 5.5 %, 10 mm 2.2 %,
so switching hyphae must be 15–185× harder than flowing along a branch. Matched on circulation, it keeps more of the
fastest returns (segments measured above 5 µm/s within 1.5×: 72 % against 64 % at about 5 %; 66 % against 61 % at about
2 %) and is slightly less accurate overall (92.0 % against 94.9 %; 95.3 % against 96.4 % within 2×). Neither version
dominates.

The junction model's small circulation points the way the fitted one does only weakly. At $L_j$ = 3 mm it has the sign
of the circulation fitted from other blocks on 57.5 % of 421 loop edges, against 51.1 % shuffled (p = 0.004), and of the
measured shortfall on 54.6 % against 51.4 % (p = 0.015), with ρ 0.05. At $L_j$ = 0, the paper model, it is at chance.

#figure(
  table(columns: 7, align: (left, right, right, right, right, right, right), stroke: 0.4pt, inset: 4pt,
    [], [circulation], [trail 2×], [trail 1.5×], [misrouted 2×], [fast 1.5×], [loop edges 2×],
    [global (paper)], [26 %], [85.0 %], [65.7 %], [0 %], [76 %], [78.4 %],
    [every leg, 0.3 mm], [11.4 %], [93.1 %], [76.5 %], [65 %], [71 %], [90.3 %],
    [every leg, 1 mm], [5.2 %], [94.9 %], [77.7 %], [83 %], [64 %], [92.7 %],
    [every leg, 3 mm], [2.1 %], [96.4 %], [78.1 %], [100 %], [61 %], [93.4 %],
    [through-pass, 1 mm], [9.9 %], [90.1 %], [73.7 %], [45 %], [77 %], [88.0 %],
    [through-pass, 3 mm], [5.5 %], [92.0 %], [75.4 %], [61 %], [72 %], [90.5 %],
    [through-pass, 10 mm], [2.2 %], [95.3 %], [77.2 %], [84 %], [66 %], [92.9 %],
    [conveyor], [0], [95.6 %], [75.5 %], [–], [54 %], [93.3 %],
  ),
  caption: text(8.5pt, fill: luma(95))[Junction resistance: circulation (median over loop edges), trail segments within
    2× and 1.5× (548), the 69 misrouted segments within 2×, segments measured above 5 µm/s within 1.5×, and the per-edge
    loop edges within 2× (1,347). Tree edges are 93.6 % within 2× in every row.
    #text(fill: luma(140))[`global_routing_errors.py`, `global_routing_through.py`]],
) <tab-junction>

Nothing in the anatomy marks a junction as resistant (@fig-neck). The lumen does not narrow towards the node: beyond
17 µm the widths stay within ±2–4 % of the leg's own, from 3 to 15 µm they are 2–5 % wider, and in the first 3 µm 13–14 %
wider, where the junction flares. Legs narrowing by more than 10 % are no more common within 15 µm of the node (9–19 % of legs) than
within 15 µm of the far end (16–37 %). A 1 µm-long neck with the resistance of 1–3 mm of core would be a pore about
1.1–1.4 µm across and would be plain in these frames. The node region is 9 % darker than the leg (time-mean brightness 0.91 of the leg's), but its
motion is 0.95 of the leg's: the material there moves. Only 1 of 76 junctions is both dark and static, against 8 of 76
far ends. Nor is a gate expected: AMF hyphae are aseptate @cargillCellularAnatomyArbuscular2025, so they lack the septal
pores that regulate flow between compartments in ascomycetes, where Woronin bodies plug the pore under active control
@jeddNewSelfAssembled2000 @steinbergAtpPreventsWoronin2017.

#fig("figures/loop_circulation_neck_widths.png", [Lumen width along each filmed junction leg (218 legs, 76 junctions),
over the leg's own width beyond 40 µm, from the junction node (orange) and from the leg's far end (grey, control), in
the time-mean frame: between the dark wall bands (left) and the outer halos (right). Median and IQR over legs.],
src: "junction_neck_widths.py", width: 88%) <fig-neck>

== In the full solver with growth motors, every score rises all the way to the conveyor <sec-r-solver>

The re-solves above keep the paper model's GIMF motors. Run in the solver itself (`junction_um`), with the motors running
the way the hyphae grew and the demand split by area, the junction resistance moves every score in one direction
(@tab-solver; forward speed refit to 3.10 / 2.14 µm/s and 1.7 mm, and growth directions of equal-date stretches taken
from the measured motor stream). The global solve does worse with growth motors than with GIMF motors (loop edges ρ
0.09 against 0.30),
plausibly because the growth directions around a loop need not follow a pressure field (not tested here). From the global solve through 3 and 10 mm to
the conveyor, the loop circulation falls and every score rises. Leaving each plate out, the best of the four settings on
the other plates is the conveyor for all five plates. With growth motors, the data drive the junction resistance to the
conveyor.

#figure(
  table(columns: 7, align: (left, right, right, right, right, right, right), stroke: 0.4pt, inset: 4pt,
    [growth motors, area split], [circulation], [trail 2×], [trail 1.5×], [fast 1.5×], [loop edges 2×], [loop ρ],
    [global (no resistance)], [24 %], [78.3 %], [56.8 %], [31 %], [72.4 %], [0.09],
    [junction 3 mm], [5.2 %], [91.2 %], [73.0 %], [45 %], [90.2 %], [0.27],
    [junction 10 mm], [2.0 %], [94.2 %], [75.5 %], [51 %], [92.9 %], [0.34],
    [conveyor (infinite)], [0], [96.4 %], [78.5 %], [60 %], [93.5 %], [0.41],
    [paper model (GIMF motors, global)], [26 %], [84.9 %], [64.8 %], [76 %], [78.0 %], [0.30],
  ),
  caption: text(8.5pt, fill: luma(95))[The through-pass junction resistance in the full solver, 15 sessions: loop
    circulation, trail segments within 2× and 1.5× (548), segments measured above 5 µm/s within 1.5×, and the per-edge
    loop edges within 2× (1,346) with their Spearman ρ. Tree edges are 93.2–93.6 % within 2× in every row.
    #text(fill: luma(140))[`junction_grid_compare.py`]],
) <tab-solver>

== Pressure drives the return when perturbed, but the steady state needs no network-wide solve <sec-r-pressure>

Two perturbations show the to-root flow responding to pressure while the motor stream holds. After a solute droplet
the to-root speed rises by a median ×2.9 over 4–15 s (15 movies) while the to-tip stream stays at ×0.81–1.20. After the
root compartment is cut, the return on the trail drops by about 30 % within minutes at every 2 mm stretch from 2.6 to
25.6 mm from the cut (×0.62–0.81, 5 to 43 junctions away) while the motor stream stays at ×0.92–1.03; 30 minutes on the
far stretches have recovered and the two nearest the cut have not (×0.54–0.55). Pressure-driven mass flow responds to
osmotic perturbation in other fungi too: in _Neurospora_ it stops or reverses under an external osmotic gradient
@lewMassFlowPressuredriven2005 @abadehMassFlowVelocity2013, and in _Serpula_ cords an osmotic change at the food source
stops translocation along the cord @brownleeLongDistanceTranslocation1982.

Nothing in the steady state asks for a network-wide solve. The circulation such a solve produces is absent
(@sec-r-sign), and the circulation that is present is small and differently arranged (@sec-r-fit). The motor direction
does not argue for it either: the motors follow the way the hyphae grew on 84.8 % of 765 identifiable edges, against
80.4 % for the hydraulic solve's direction
(#link("motor_direction_and_lipid_distribution.typ")[the motor direction document]).

= Discussion <sec-discussion>

The global model's loop errors are its own circulation: it sends 26 % of the motor flux around loops of 4–13 mm, and
69 of 548 trail segments come out more than 2× wrong where the conveyor is right (@sec-r-errors). The circulation is set
by the loops and the motor directions, not by any local property (@sec-r-drivers), and the measured flows carry none of
it: the sign of the measured net flux is at chance against it (@sec-r-sign). The data do hold a small circulation of
their own, 2–8 % of the motor flux, coherent across hyphae but arranged differently and worth only a marginal gain in
accuracy (@sec-r-fit). A resistance at junctions that only the net flux crosses brings the global solve to the
conveyor's accuracy at a circulation the data allow; the data bound it from below, the anatomy shows no structure for
it, and its circulation matches the fitted one's direction only weakly (@sec-r-junction). Pressure drives the to-root
flow when the network is perturbed, but the steady state needs no network-wide solve (@sec-r-pressure). With the motors
running the way the hyphae grew, the full solver's scores rise all the way to the conveyor (@sec-r-solver). These results
rest on 15 sessions of 5 plates, one root cut, and the model's current flux bookkeeping.

*The main text uses a finite resistance, by choice.* The transport manuscript takes the through-pass junction
resistance at 10 mm with growth motors and an area split (Simon, 25 Sep 2026): a circulation of 2 %, inside the 2–8 %
the fitted circulation allows (@sec-r-fit), so that the return remains one network solve. The data alone would take the
conveyor limit (@sec-r-solver); 10 mm costs 2.2 points on the trail segments and 0.6 on the loop edges within 2×.

*The accuracy numbers are the conveyor's.* At the junction resistances that fit, the model is 95–98 % conveyor. Its
spread on loop edges is 0.22–0.25 against a measured 0.37, nearly as flat as the conveyor's 0.20. The junction
resistance answers whether loops exchange flow (little), not what sets the spread of the returns. The tree-edge
residual points to a per-hypha activity term (the share of static particles, ρ −0.73 with the to-root speed) as what the
model lacks.

*The fast returns are not a routing effect.* The global model gets more segments measured above 5 µm/s within 1.5×
(76 % against 54 % for the conveyor) because its added return lands on wide hyphae, but the measured excess does not
follow the added return. Fast returns sit on tree edges as well (per-edge, measured over conveyor 1.83 on the 35 fast
tree edges, 1.66 on the 321 fast loop edges) and concentrate on PNF080 (42 % of its edges against 10–22 % elsewhere).
They need more to-root flux or a narrower return lane on those edges, which is the flow-partition question
(transport_paper issue \#95), not a routing one.

*The sign test depends on a bookkeeping.* Stream areas are not measured. In the model's own bookkeeping, which is what
the model predicts against, the circulation is absent; with speeds only, a width effect appears that the conveyor already
carries. The lanes bookkeeping cannot be used with the model's core radius.

*The fitted circulation is pinned only near measured hyphae.* Away from them the fit goes to zero by construction, so
where the return goes is answerable around the trails, not across the colony.

*The re-solves change only the second solve.* The motor flux, core radii and GIMF motor directions come from the unsplit
growth solve. The crossing split in particular should, in full, also change the first solve.

*Network-scale coordination of flow is known elsewhere, but it is active or slow.* _Physarum_ organises flow across the
whole network by peristaltic contraction @alimRandomNetworkPeristalsis2013, and cord-forming fungi show colony-wide
oscillating translocation domains @tlalkaEmergenceSelfOrganised2007; neither is a passive circulation around loops. The
argument that an incompressible cytoplasm makes the network respond globally and fast @frickerMyceliumNetwork2017 is
about how quickly pressure changes travel, which the perturbations here also show, not about how much flux circulates
in steady state. Each hypha returning its own motor stream is the network counterpart of the counter-flow a wall-driven
stream forces in a single elongated cell @htetAnalyticalMethodsCytoplasmic2025, as in the reverse fountain of pollen
tubes @heplerPollenTubeClear2015. No measurement of flow switching between hyphae at a junction, in AMF or elsewhere,
was found in the literature.

*The perturbations are transients.* Neither steady-state model describes cutting the roots or a droplet. A junction
resistance changes pressures and how fast a disturbance spreads, not where the net flux goes when the only reservoir is
removed; with any plausible wall compliance the spread over 26 mm takes seconds to a minute, inside the 5-minute window.
The root cut therefore cannot test the junction resistance, and the salt shock, filmed close to its droplets, cannot
either without the droplet distances.

= What didn't work <sec-deadends>

== A different conductance law does not remove the circulation #dead

Routing the return on $a^2\/L$, $1\/L$ or the whole lumen's $b^4\/L$ instead of the core's $a^4\/L$ leaves the trail
segments at 82.3 %, 75.4 % and 78.8 % within 2× (paper 85.0 %). The circulation is set by the loops and motor directions
(@sec-r-drivers); a conductance law only reweights it.

== A constriction at junctions that all flow crosses makes it worse #dead

With $R_j$ in series on every leg for the whole flow, the conveyor itself needs a pressure jump $q_s R_j$ at every
junction, which adds to each loop's mismatch. Trail segments fall to 74.6–83.2 % within 2× over $L_j$ 0.1–3 mm. Only a
resistance the net flux alone crosses works (@sec-r-junction), and that is not what a narrowing does.

== A membrane leak kills the tree returns before it reaches the loops #dead

In the model the return is born at the tips and travels back; a leak makes it fade with distance from the tips. At
$lambda$ = 10 mm the tree edges fall from 93.6 % to 85.0 % within 2× and the trail segments to 53.5 %; at 30 mm, 88.6 % and
76.3 %; by 100 mm the leak changes nothing (circulation 25 %). The tips and the measured edges are separated by the same
distances as the loops, so no $lambda$ picks out the loops. Read the other way, the tree returns need hydraulic isolation
from the medium over well beyond 30 mm, which bounds the product of cytoplasm viscosity and membrane water
permeability: $mu L_p$ below about 4 × 10⁻¹⁵ m. A membrane whose water permeability is set by its lipid bilayer
(osmotic permeability 2–10 µm/s, $L_p$ about 1.5–7 × 10⁻¹⁴ m s⁻¹ Pa⁻¹) meets that for an effective viscosity below
0.06–0.3 Pa·s, well above the 2.5 mPa·s microviscosity of fungal cytoplasm @dijksterhuisHighViscosityAnisotropy2007.
Only an aquaporin-rich membrane together with bulk-cytoplasm viscosity would bring $lambda$ below the loops. The yeast
value of @demaranonDeterminationCellsWater1997 ($L_p$ above 6 × 10⁻¹¹, an osmotic permeability near 8,000 µm/s, about
40 times a red blood cell's) is an outlier of its method, not a membrane value. All of this is an inference within a
linear model, not a measurement.

== Reading crossings as unfused removes only a quarter to a third of the circulation #dead

17,723 degree-4 nodes; 7,636 pair into two passes within 30° of straight, 10,644 within 45°. Splitting them brings the
circulation from 26 % to 18–20 % (16 % splitting every degree-4 node) and the loop edges from 78.4 % to 81–83 % within 2×,
keeps the fastest returns, and fixes 9–28 % of the misrouted segments. Most of the misrouting runs through loops that are
not crossings. The split is worth keeping as graph clean-up.

== Segmentation artefacts that come and go do not carry the circulation #dead

A fused link is permanent; a segmentation artefact (hyphae merged where they run close, a bridged gap) tends to come
and go between frames. Per edge, the share of well-registered frames since it first appeared in which the store still
matches it (`loop_link_persistence.py`): the edges on the loops the misrouted return runs around are, if anything, more
persistent than loop edges in general (0.1 % below 0.5, against 0.6 %; tree edges 2.1 %). 6 of the 50 loops (12 %)
contain an edge below 0.5. Removing every edge below 0.5 moves the circulation from 26 % to 24 % and the trail segments
from 85.0 % to 82.5 % within 2×. This rules out flickering artefacts, not stable ones: two hyphae merged in every frame,
or a crossing read as a fusion in every frame, persist like a real link. The crossings are the part tested above.

== The junction balance (stem return over the branches') cannot tell global from local #dead

The model's return on the incoming motor leg over the sum on the outgoing legs is 0.54 at tree junctions for every
$L_j$ and moves from 0.45 to 0.51 at loop junctions; at the filmed junctions 0.61 to 0.59. It is set by the motor
streams' geometry, since every leg's return balances its own motor stream and Kirchhoff addition applies only to the
net flux. The measured balance, 0.72 (IQR 0.58–0.82), sits above every variant.

== How far the root cut's effect reaches cannot test the junction resistance #dead

The return dropped by the same amount 5 and 43 junctions from the cut. That reads at first as net flux travelling
freely through junctions, but with the roots as the only reservoir a resistance changes pressures and timing, not the
net flux (@sec-discussion). Near the root the growth graph's stream labels are reversed; there the stream nearer 3.0 µm/s
is taken as the motor stream.

= Actionable Items <sec-actions>

== Compendium handoff

- #link("backflow_model_accuracy.typ")[The backflow accuracy document] presents the global model's loop score as a model property. This document places the
  loop errors in its circulation and bounds the circulation the data allow at a few percent; its loop section should
  cite that.
- #link("junction_flux_balance.typ")[The junction flux balance document]'s reading that each branch runs its own conveyor
  loop is supported: the steady-state flows show
  loops exchanging little. Its junction balance cannot separate global from local routing (@sec-deadends).

== Open

- #open *Switching against passing through.* The two junction-resistance versions fit equally; flow measured crossing
  from a hypha into a side branch or fusion, against flow passing along the main hypha, would separate them. The J6
  transfer test was inconclusive on 10 s videos, and no such measurement was found in the literature.
- #open *The spread and the fast returns.* A per-hypha activity term for the spread; the flow partition and the return
  lane on the fast edges (transport_paper issue \#95).
- #open *The salt shock against droplet distance.* The droplet distances are not in the salt-shock index; with them the
  response could be read against distance.
- #open *The crossing split in the model graph,* with GIMF re-run on it.

= Appendix <sec-appendix>

== Reproducing this <app-repro>

From `transport_paper` at `bc4c73c`, with the grid dumps of `fig_outputs/model_grid/run_grid.sh` and
`run_grid_global.sh` (GIMF motors, GIMF split):

```
python Working_notebooks/global_routing_errors.py       # cases, loops, drivers, every leg
python Working_notebooks/global_routing_amendments.py   # crossing split, leak
python Working_notebooks/global_routing_through.py      # through-pass
python Working_notebooks/net_flux_sign_test.py
python Working_notebooks/inverse_circulation.py
python Working_notebooks/junction_vs_fitted_circulation.py
python Working_notebooks/junction_neck_widths.py
python Working_notebooks/junction_centre_material.py
python Working_notebooks/root_cut_distance.py
python Working_notebooks/loop_link_persistence.py
fig_outputs/model_grid/run_grid_junction.sh              # the solver runs of @sec-r-solver
python Working_notebooks/junction_grid_compare.py
```

Tables land in `fig_outputs/model_grid/global_routing/` (`amendments.csv`, `through_pass.csv`, `net_flux_sign_test.csv`,
`inverse_circulation_{cv,full}.csv`, `junction_vs_fitted.csv`, `junction_balance_model.csv`), `fig_outputs/video_junctions/`
(neck widths, centre material) and `fig_outputs/perturbations/root_cut_distance.csv`. The roots per store are cached in
`fig_outputs/model_grid/global_routing/roots.json`.

== References
#bibliography("references.bib", title: none, style: "apa")
