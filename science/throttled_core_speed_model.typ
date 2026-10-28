// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// ---------------------------------------------------------------------------

#set document(
  title: "Throttled core-return plug-speed model — how network geometry and growth become a predicted backflow speed",
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
#set ref(supplement: it => if it.func() == figure { it.supplement } else if it.func() == math.equation { "Eq." } else {
  "Section"
})
#set math.equation(numbering: "(1)")
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
#show table: it => {
  set par(justify: false)
  it
}

#let open = box(fill: rgb("#eceff0"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#4a5459"),
  weight: 600,
  "OPEN",
))

#show figure.caption: set align(left)
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt), stroke: (left: 2pt + luma(160)), text(
  11pt,
  style: "italic",
  fill: luma(60),
  body,
))

#let note(body) = block(
  fill: rgb("#f7f8f8"),
  stroke: (left: 2pt + rgb("#d9a441")),
  inset: 9pt,
  radius: 2pt,
  width: 100%,
  text(9pt, body),
)

// what a step rests on: a physical argument, or an explicit modelling choice
#let argument(body) = block(width: 100%, inset: (left: 8pt, y: 3pt), stroke: (left: 1.5pt + rgb("#9bb7a4")), text(
  9.5pt,
)[#text(weight: 600)[Argument. ]#body])
#let choice(body) = block(width: 100%, inset: (left: 8pt, y: 3pt), stroke: (left: 1.5pt + rgb("#d9a441")), text(
  9.5pt,
)[#text(weight: 600)[Modelling choice, no physical argument. ]#body])

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Throttled core-return plug-speed model]
  #v(-0.3em)
  #text(14pt, weight: 600)[How network geometry and growth become a predicted backflow speed]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    derivation and parameters · checked on 1,560 measured brightfield edges over 12 video sessions on 4 plates
  ]
]
#v(1.2em)

#outline(depth: 2, indent: 1em)

= Introduction <sec-intro>

#question[Forward flow is motor-based and backflow is pressure-based. Can a model respect that division, derive the backflow from the network's geometry and growth, and show which assumptions control its prediction?]

We image a growing colony of _Rhizophagus irregularis_ over several days and extract, for each timepoint, a network of hyphal segments that records each segment's length, width and the frame in which it appeared. Short videos at fixed positions measure the speed of material moving inside hyphae in both directions at once. The model takes one session of that network, together with the growth in the four frames after it, and returns a backflow speed on every segment.

Previous experiments provide the physical starting point: pressure-driven mass flow moves tipward in fungal hyphae @lewMassFlowPressuredriven2005 with a flat, plug-like velocity profile @abadehMassFlowVelocity2013, while cytoskeletal motors carry material through the same cytoplasm independently of that flow and can run against it @ramos-garciaCytoplasmicBulkFlow2009. Forward flow follows the motor signal, whereas backflow follows the pressure-driven component. The model therefore treats a hypha as two coupled regions: a motor-driven annulus that carries material outward and a pressure-driven core that carries the return flow, the same wall-driven-stream-and-pressure-driven-core-return geometry described for elongated cells generally @htetAnalyticalMethodsCytoplasmic2025 and, specifically, for the pollen tube's reverse fountain @heplerPollenTubeClear2015. Growth is included as a small demand that perturbs this circulation and as a possible cause of motor throttling near growing tips.

The derivation then makes this picture quantitative. Motors drive an outward stream through almost the whole cross-section, while the core returns almost all of it because growth consumes under 1 % of that flux. The pressure difference sets a pressure-driven velocity scale $v_"press"$; the corresponding core-return plug speed is $hat(v) = abs(v_"press") / 2$. A throttle measured from forward flow lowers the motor flux near growing tips and therefore lowers the return there. The model is successful if it supplies this mechanism and its sensitivities, even when a constant happens to score better as a purely predictive baseline.

This document derives the model from that physical picture. It gives the argument for each step, or marks the step as a modelling choice when the data do not derive it. Details of the network pressure calculation are included to make the dependencies explicit, not because the pressure solver itself is the scientific result. Where the derivation makes a quantitative claim, the claim is checked against the 12 sessions used for scoring, on the model run with the offset throttle of @sec-throttle and motors on zero-flux edges; the few results that come from other runs say which.

= Motivation <sec-motivation>

#link("backflow_model_accuracy.typ")[The backflow accuracy document] scores several models against measured backflow. The throttled core-return plug speed is the strongest network-derived model, although a constant can score slightly better over all edges. That comparison is not the main test here: a constant gives no mechanism and no prediction of how geometry, growth or tip distance should change the speed. The purpose of this document is to derive a model that respects the established distinction between motor-based forward flow and pressure-based backflow, while exposing the sensitivities that can be tested experimentally.

The derivation also exposes the choices that remain modelling assumptions. Several steps rest on floors, clamps and fixed numbers with no physical derivation. Listing them next to the steps they affect shows which ones can change the prediction and which cannot.

= Method <sec-method>

This part sets up the objects the derivation works on: the geometry of one hypha, the network it sits in, and the classes of parameter. The derivation itself is in @sec-results. The pressure solves are treated as standard network bookkeeping, following the Poiseuille/Kirchhoff network models used elsewhere for fungal flow @roperMycofluidicsFluidMechanics2019; the scientific question is what enters them and what the returned core flow means.

== A hypha is a tube with a motor-driven annulus around a pressure-driven core <sec-geometry>

Each network segment between two nodes is treated as a straight cylindrical tube of outer radius $b$ and length $L$. The tube is divided into two regions (@fig-cross):

- the core, $0 <= r < a$, which moves only under pressure;
- the annulus, $a <= r < b$, which moves outward at the motor speed $v_0$. A fraction $theta$ of the annulus area is lipid; the remaining $1 - theta$ is the rest of the cytoplasm, carried along at the same speed.

#figure(
  box(width: 100%, height: 4.4cm)[
    #place(center + horizon, dx: -2.2cm, circle(radius: 1.9cm, fill: rgb("#e8d9b5"), stroke: 0.8pt + luma(90)))
    #place(center + horizon, dx: -2.2cm, circle(radius: 1.15cm, fill: rgb("#cfe0ea"), stroke: 0.8pt + luma(90)))
    #place(center + horizon, dx: -2.2cm, text(9pt)[core, $r < a$])
    #place(left + horizon, dx: 55%, dy: -1.0cm, text(8.5pt)[annulus, $a <= r < b$: motors, speed $v_0$])
    #place(left + horizon, dx: 55%, dy: 0cm, text(8.5pt)[core: pressure-driven return])
    #place(left + horizon, dx: 55%, dy: 1.0cm, text(8.5pt)[wall, $r = b$])
  ],
  caption: text(
    8.5pt,
    fill: luma(95),
  )[Cross-section of one hypha as the model sees it. The annulus (sand) between the core radius $a$ and the wall radius $b$ moves outward at the motor speed $v_0$, and a fraction $theta$ of its area is lipid. The core (blue) is driven only by pressure. On measured edges the median $a\/b$ is 0.973, so the annulus is thinner than drawn.],
) <fig-cross>

The two streams run side by side in lanes rather than as this coaxial core, as #link("radial_flow_structure.typ")[the radial flow structure document] shows directly.

The segmented width $w$ is converted to µm before it enters the model, and the outer radius is $b = w\/2$. Across three checked sessions, the median width was 8.0, 8.0 and 9.3 µm, respectively, consistent with the scale of the imaged hyphae.

At this stage the model only needs the kinematic distinction between the two regions: the annulus supplies an outward motor flux, while the core supplies the pressure-driven return. The core's relative flow is pressure-driven; its boundary is carried with the motor-driven annulus. We postpone the conversion from core flux to an observed speed until after the network solve. That leaves open two interpretations of the return: the speed of a plug carrying the core flux, and the speed obtained from a specified velocity profile.

#argument[Flow in a hypha a few µm wide at µm/s speeds has a Reynolds number far below 1, so the Stokes equations are linear and a moving boundary and a pressure gradient in the same tube add. Poiseuille's law is the steady solution for a pressure gradient in a circular tube.]

#choice[The annulus is represented as a plug moving at one motor-set speed, with its non-lipid material carried at the same speed as the lipid. This is motivated by the prior finding that forward flow is motor-driven; the model does not derive the annulus's radial profile or force balance.]

At a node, segments meet and volume is conserved; there is no resistance or mixing at the junction itself.

== The network supplies the flow domain; recent growth supplies the demand <sec-network>

Each plate was imaged as a growing network, with one network image every two hours. On selected days, videos were recorded manually to measure hyphal flows. For each video taken at network time $t$, the extracted network was truncated at $t + 4$. Thus the network state at $t$ is paired with the growth that occurs over the next four network frames, while no later growth enters the calculation. This produces two edge sets with different roles.

Write the session graph as $G_t = (V_t, E_t)$, where $V_t$ is the set of nodes and $E_t$ the set of segments present at time $t$. If $tau(e)$ is the frame in which segment $e$ first appears, the growth edge set is

$ E_"growth" = {e in E_(t + 4) : t < tau(e) <= t + 4} . $

The truncated network consists of the session edges $E_t$ together with $E_"growth"$. All flow is solved on $E_t$; $E_"growth"$ is never flowed through and only sets the growth demands. Let $C_"growth"$ denote a connected group of growth edges. The nodes of $E_"growth"$ that attach to the session graph form the growth-node set $V_"growth"$.

Chains of segments joined through nodes with two neighbours are merged into single edges, keeping every root and every growth node as a node. Series Poiseuille resistances add, so merging a chain of tubes changes no flow.

Three node sets carry the boundary conditions or define the tip geometry:

- Roots $V_"root"$, placed by hand where growth is known to have started, are the network's reservoirs.
- Growth nodes $V_"growth"$, the session nodes to which $E_"growth"$ attaches, carry the growth demand. They include branch points on old hyphae.
- Growing apical tips $V_"tip"$ are session nodes with degree one in $E_t$, that are not roots, and that have a segment in $E_"growth"$ attached to them. They set the throttle's distance. On the 28 hand-drawn trails, 25 trail ends are growing apical tips.

#choice[The four-frame growth window is a practical setting.]

== Every parameter is measured, assumed or fitted <sec-param-classes>

Measured parameters come from the images and videos: widths, lengths, the time between frames, and, from the forward speed profile, the motor speed far from tips $v_0$ = 3.096 µm/s, the motor speed at a growing tip $v_"tip"$ = 2.140 µm/s and the throttle length $lambda$ = 1711 µm (@sec-throttle). Assumed parameters are set once for every plate from outside knowledge or convention: the lipid fraction $theta = 0.15$, the viscosity of water, the carbon stoichiometry of new hyphae, and the Poiseuille $a^4$ weighting of the core conductance, a choice the data cannot distinguish from $a^3$ or $a^2$ (@sec-solve2). No parameter is fitted to measured backflow; a scale fitted on held-out sessions is used only as a check. The full table, with values and units, is in @sec-app-params; the numerical safeguards the solver needs are in @sec-app-safeguards.

= Results <sec-results>

The first six sections follow the growth demand from the growth nodes to the throttled motor flux on each edge. The next two sections seek the pressure difference across each edge that causes the backflow, then show the two speed values that can be derived from it. The last three read what those values mean physically, why the model is a circulation, and how the prediction is set without fitting it to backflow.

== Growth consumes a known volume at each growth node, and that sets the demand <sec-demand>

For every growth component $C_"growth"$, the volume grown is summed over its segments and divided by the time between the session and the end of the window, $Delta t$ in seconds:

$ V_"growth" = 1 / (Delta t) sum_(e in C) pi (w_e / 2)^2 L_e . $ <eq-demand>

Because the growth window is short, most growth components have only one attachment point to the session network. When a component has several attachment points, its rate is shared equally among them; each share becomes a node's water demand $D_n$ in µm³/s. Its lipid demand is $D_n$ times the volume carbon ratio $kappa$ (@sec-lipid).

#argument[A segment that appeared during the window is filled with cytoplasm that had to arrive through the network, so its volume per unit time is a sink the network must supply. Splitting it equally between attachment points is the simplest allocation when the network gives no reason to prefer one.]

#choice[Equal sharing between attachment points, and a width of 7 µm for a grown segment with no measured width, are conventions.]

== The first pressure solve routes that volume from the roots through Poiseuille tubes <sec-solve1>

Each edge $(u, v)$ is assigned a Poiseuille conductance based on the wall radius:

$ g_(u v) = (pi b_(u v)^4) / (8 mu L_(u v)) . $ <eq-g-outer>

Volume conservation at every node gives a set of network pressure-balance equations for the node pressures $p$:

$ sum_(v tilde u) g_(u v) (p_u - p_v) = s_u, quad s_u = cases(-D_u & "at a growth node", 0 & "elsewhere"), $ <eq-solve1>

with every root tied towards $p = 0$ through a fixed reservoir conductance. Each edge then carries the growth-induced mass flow (GIMF) $Q_(u v) = g_(u v)(p_u - p_v)$ @heatonGrowthinducedMassFlows2010.

#argument[For incompressible, low-Reynolds flow a tube obeys $Q = g Delta p$, the hydraulic analogue of Ohm's law, and nothing accumulates at a junction, so the node balance is Kirchhoff's current law. Growth nodes are fixed sinks because growth consumes a volume set by what grew, not by the local pressure; roots are the reservoir that supplies it.]

#choice[The roots are pinned through a finite conductance, not by eliminating them exactly (@sec-app-safeguards). The flow's direction is not an input: it follows from where roots and growth nodes are, and inside a loop it can run against the order in which the hyphae grew.]

== Lipid travels with the routed water in a fixed proportion <sec-lipid>

The lipid current on an edge is the routed water flux times the volume carbon ratio:

$
  J_(u v) = kappa Q_(u v), quad kappa = (f_"dry" f_C rho_"tissue") / ("CUE" rho_"lipid") = (0.21 times 0.5 times 1.1) / (0.5 times 0.9) approx 0.256 .
$ <eq-lipid>

The numerator is the carbon a new hypha must import per unit volume: dry mass fraction 0.21, carbon fraction of dry mass 0.5 and tissue density 1.1 g/cm³, divided by a carbon-use efficiency of 0.5, giving 0.231 g of carbon per cm³ of hypha. The 0.9 in the denominator is undocumented. Its units must be g/cm³ of the transported substance, which makes it the density of triacylglycerol lipid, counted as if it were pure carbon; with the roughly 77 % carbon mass fraction of triacylglycerol, $kappa$ would be about 0.33 rather than 0.256.

#argument[If lipid is carried passively by the water flow, its current is proportional to that flow with the ratio of carbon demanded to lipid volume supplied.]

#choice[No separate lipid balance is solved; lipid is assumed to move exactly with the routed water everywhere. The four stoichiometric numbers carry no cited source.]

== Lipid volume balance fixes the core radius <sec-radius>

The lipid current must fit in the lipid part of the annulus moving at the motor speed:

$ J = theta v_0 pi (b^2 - a^2) quad arrow.double quad a^2 = b^2 - J / (theta v_0 pi) . $ <eq-radius>

We use the sign of the lipid current to assign the motor direction on each edge. An edge with no lipid current, such as a dead-end branch that grows nothing, takes the outward direction instead: along increasing network distance from the roots. Its lipid shell is empty, so its core fills the tube, $a = b$.

#argument[The volume of lipid passing a cross-section per second is the lipid area times its speed. With $J$, $theta$ and $v_0$ known, only $a$ is free.]

#argument[Motors run whether or not growth downstream consumes anything, and outward is the direction they carry material on every edge that has a flux. Without a direction an edge with no net flux would have no motors and no backflow, although measured backflow on dead-end branches is about 2 µm/s (#link("backflow_model_accuracy.typ")[the backflow accuracy document]).]

#choice[When $J$ is too large to fit, $a^2 <= 0$, the consistent answer is a closed core, $a = 0$. For now, the implementation instead sets $a = 0.75 b$ as a numerical safeguard; this convention should be revisited rather than read as a physical conclusion. Outward as distance from the roots is the simplest rule for the zero-flux direction; on the 1,560 measured edges it applies to the 106 that carry zero routed flux.]

On measured edges the median $a\/b$ is 0.973 (interquartile range 0.937–0.992, 1,548 edges), so the inferred lipid annulus is thin.

== The motor flux of an edge is the whole tube moving at the motor speed, minus the lipid current <sec-motor-flux>

The volume flux the motors drive along an edge counts the non-lipid part of the annulus and the core fluid at the annulus edge, both moving at $v_0$:

$ q_s = pi v_0 [(1 - theta)(b^2 - a^2) + a^2] . $ <eq-qs>

Substituting @eq-radius for $a^2$:

$ q_s = pi v_0 b^2 - theta pi v_0 (b^2 - a^2) = pi b^2 v_0 - J . $ <eq-qs-closed>

#argument[@eq-qs-closed is algebra on the lipid balance. It says the motor-driven flux is the flux of the whole tube moving rigidly at $v_0$, less the lipid current that is accounted for separately.]

On measured edges the lipid current is small against this flux: $J \/ pi b^2 v$, with $v$ the motor speed the edge runs at, has a median of 0.79 % and a 95th percentile of 4 %. Growth consumption is a small perturbation of the motor flux.

== The throttle slows each edge's motors, and the annulus is sized at the slowed speed <sec-throttle>

Near growing apical tips the motor speed is lowered edge by edge:

$ v_0 arrow.r g(d) v_0, quad g(d) = 1 - (1 - v_"tip" \/ v_0) e^(-d \/ lambda), $ <eq-throttle>

where $d$ is the network distance, along segment lengths, from the nearer end of the edge to the nearest growing apical tip. The throttled speed $g(d) v_0$ replaces $v_0$ everywhere on the edge, the lipid balance included: the core radius is solved from @eq-radius at the throttled speed, $a^2 = b^2 - J \/ (theta g(d) v_0 pi)$. Substituting that $a^2$ into @eq-qs at the same speed, as in @eq-qs-closed, the throttled motor flux is exactly

$ q_s^"thr" = pi b^2 g(d) v_0 - J . $ <eq-qs-thr>

#argument[The lipid current $J$ is set by the first solve and does not depend on the throttle, so a slower annulus must be thicker to carry it: the throttle narrows the core as well as slowing the pumps. Sized at the unthrottled speed instead, the annulus would carry $1 \/ g(d)$ times the lipid routed through it. Because $J$ is under 1 % of the motor flux, the core barely moves: the median $a\/b$ is 0.974 on measured edges within 1 mm of a growing apical tip, no lower than the 0.970 beyond 2.5 mm, so the core conductance in @sec-solve2 is nearly the unthrottled one. Measured backflow and measured forward speed both fall within about 1 mm of a growing tip while the unthrottled model does not (#link("backflow_model_accuracy.typ")[the backflow accuracy document]), and a slower motor stream is the simplest cause that moves both; how much of that fall the throttle reproduces is in @sec-circulation.]

$v_0$, $v_"tip"$ and $lambda$ are measured by fitting the same form to the forward speed, which is independent of backflow: $v_"fwd" = v_0 - (v_0 - v_"tip") e^(-d \/ lambda)$, on 1,054 brightfield edges over 12 sessions. Held out by session, this fit predicts forward speed with a median absolute log error of 0.092; on all 15 sessions, with no 1 µm/s cut on streak speed, it still predicts held-out sessions better than a refit on those data, 0.093 against 0.096. Brightfield forward speeds are used, as the more reliable measurement; the channel comparison below was made with the exponential form $v_"fwd" = v_0 (1 - e^(-d \/ lambda))$, which is the offset form with $v_"tip"$ = 0:

#table(
  columns: (auto, auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right, right),
  table.header[*forward speed, channel and form*][*edges*][*$v_0$ (µm/s), range over held-out folds*][*$v_"tip"$ (µm/s), range over held-out folds*][*$lambda$ (µm), range over held-out folds*],
  [brightfield, offset, used], [1,054], [3.096 (3.08–3.14)], [2.140 (2.08–2.16)], [1711 (1442–1922)],
  [brightfield, exponential], [1,547], [2.87 (2.82–2.91)], [0], [749 (589–939)],
  [fluorescence, exponential], [1,175], [2.69 (2.64–2.80)], [0], [323 (213–809)],
)

In the exponential form, brightfield covers more edges and its parameters vary less between sessions excluded from fitting. Both brightfield decay lengths are longer than the 0.25–0.5 mm range selected when $lambda$ is fitted to backflow instead (@sec-fit); the fluorescence decay length, 323 µm, lies inside that range. The prediction changes little between the brightfield-derived and fluorescence-derived parameters: a longer throttle lowers $v_"press"$ over a wider zone and a faster motor raises it everywhere, and the two runs, scored with the exponential throttle, are within 1 point of each other (#link("backflow_model_accuracy.typ")[the backflow accuracy document]).

#choice[The exponential form of $g$ is an empirical description, not a claim about the underlying cause, and its offset $v_"tip"$ keeps the motor speed above zero at a tip because tip positions are uncertain at the network scale. The decay could reflect blockages, accumulated noise, or several biological effects acting together. For now it is retained because it describes the measured forward-flow profile well; its causal interpretation remains open.]

== The second pressure solve finds the pressure difference across each edge <sec-solve2>

We wish to find the pressure difference across each edge that causes the pressure-driven backflow. We model transport through the core with a Poiseuille conductance based on its radius,

$ G_(u v) = (pi a_(u v)^4) / (8 mu L_(u v)), $ <eq-g-core>

and each edge's motor flux acts as an imposed source of flow. We now want the pressure difference across each edge, because that difference drives the pressure-based return. Volume conservation at every node, with the motor sources and the roots coupled to a reservoir pressure, gives a second set of network pressure-balance equations

$ sum_(v tilde u) G_(u v) (p'_u - p'_v) = sum_(v tilde u) plus.minus q_(s, u v), $ <eq-solve2>

where each term on the right carries the sign of the motor direction relative to the node. The solution gives the pressure difference $Delta p'_(u v) = p'_u - p'_v$ across each edge and therefore its pressure-driven core flux $q_c = G Delta p'$.

#argument[The node pressures distribute the return flow so that volume is conserved at every junction. Only the core takes part in the pressure-driven flow, because the annulus's material is already counted in the motor source.]

On a loop, this network-wide routing of the return can send more or less than an edge's own motor flux around it, producing a circulation; #link("loop_circulation_global_model.typ")[the loop circulation document] traces exactly this circulation as the source of the global model's loop-edge errors, and finds none of it in the measured flows.

The $a^4$ weighting in @eq-g-core is Poiseuille's, but the network only constrains how the return is shared between edges, not this exponent. Replacing it with $G = pi a^n a_"ref"^(4 - n) \/ (8 mu L)$, $a_"ref"$ = 4 µm so that $G$ still matches Poiseuille at $a$ = 4 µm, and re-running $n$ = 4, 3 and 2 with everything else unchanged, on the model run with the exponential throttle ($v_0$ = 2.87 µm/s, $lambda$ = 749 µm), moves the prediction on a typical edge by under 10 %; scored against measured backflow the three exponents are indistinguishable (#link("backflow_model_accuracy.typ")[the backflow accuracy document], the section on the core-conductance exponent). Because $a\/b approx 0.97$ on almost every edge, changing the exponent mainly changes the relative weighting of wider and narrower edges; it has little effect on each edge's local balance between its motor source and core conductance, which is what @eq-local shows sets $hat(v)$.

#argument[A tube obeys Poiseuille's law for a Newtonian fluid at low Reynolds number, so $a^4$ is the physically motivated weighting for the core conductance. It is kept as the default for that reason, not because the data select it over $a^3$ or $a^2$: the return on a given edge is set mostly by that edge's own pump against its own core, so how the network shares the return between edges barely reaches the prediction.]

== The pressure difference supports two interpretations of backflow <sec-p>

The solved pressure difference can be converted into two model speed proxies, depending on how the annulus and core are interpreted. The first keeps them in one coupled velocity profile. The second treats them as independent lanes and reports the return carried by the core alone.

=== Coupled profile: use the reverse-flow part of the total velocity

Under the coupled-profile interpretation, define the signed pressure-driven centreline contribution

$ v_"press" = (a^2 Delta p') / (4 mu L) . $ <eq-p>

With the core edge moving at the annulus speed, the full core profile is

$ u(r) = v_0 - v_"press" (1 - r^2 / a^2), quad 0 <= r <= a . $

Its centreline and area-mean velocities are therefore

$ v_"center" = v_0 - v_"press", quad v_"mean" = v_0 - v_"press" / 2 . $

If the profile crosses zero, only its reverse-flow part is identified as backflow. The shipped implementation summarizes that interpretation as $abs(v_"center") times 2\/3$; the factor is part of the shipped measurement mapping, not a result derived by the independent-lanes calculation. This interpretation can therefore cancel towards zero when the outward annular contribution nearly balances the pressure-driven return.

=== Independent lanes: use the core return flux

Under the independent-lanes interpretation, the pressure-driven part of the core flux is the integral of the pressure correction,

$
  q_c = integral_0^a v_"press" (1 - r^2 / a^2) 2 pi r dif r = (pi a^2 v_"press") / 2 = (pi a^4 Delta p') / (8 mu L), quad "so" quad hat(v) = abs(q_c) / (pi a^2) = abs(v_"press") / 2 .
$ <eq-p-flux>

Thus the independent-lanes interpretation gives $hat(v)$, the unsigned plug-equivalent return speed: the speed a plug would need to carry the pressure-driven flux through the core area. For a Poiseuille profile, $hat(v)$ is exactly half of $abs(v_"press")$. The model's outputs satisfy @eq-p-flux to three decimals on 1,548 measured edges. $v_"press"$ has the same sign as the motor speed on 1,540 of them (99.5 %), so on almost every edge the pressure-driven core flow returns against the motor stream. Unlike the coupled-profile speed, $hat(v)$ does not subtract the annular motor speed and therefore does not cancel when the two lanes carry opposing flows.

#argument[@eq-p-flux is exact by construction: dividing a flux by its cross-section gives the mean speed of a plug carrying it, and $q_c$ is the flux Poiseuille's law gives the core. There is no averaging factor to choose here. Whether the measured speed equals that mean, rather than some other average the velocimetry happens to report, is a separate, empirical question, checked against a held-out scale in @sec-fit.]

== Locally, the core-return plug speed is about the motor speed, set by the ratio of tube to core area <sec-local>

If an edge's own core conductance balances its own pump, $Delta p' approx q_s \/ G$, then from @eq-p, @eq-p-flux, @eq-g-core and @eq-qs

$ hat(v) approx q_s / (pi a^2) = v_0 (b / a)^2 [1 - theta (1 - (a / b)^2)], $ <eq-local>

dropping the lipid current, which is under 1 % of $q_s$. This is a heuristic for a typical edge; each individual edge is set by the whole network's solve. With the solved shell, it predicts a return speed close to the motor speed:

#table(
  columns: (auto, auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right, right),
  table.header[*core radius*][*median $a\/b$*][*$hat(v) \/ v_0$ from @eq-local*][*measured median $hat(v) \/ v_0$*],
  [solved from the lipid balance], [0.973], [1.05], [1.06 (IQR 0.82–1.35)],
)

The medians are over the same 1,548 edges, with $v_0$ in the ratio taken as the motor speed each edge runs at. This agreement is a model check, not a fit: the shell comes from the lipid balance and the speed ratio follows from the resulting geometry.

#argument[The motor flux is spread over nearly the whole tube, $pi b^2$, while the return runs through the core alone, $pi a^2$. The narrower the core, the faster the return has to run to carry the same flux, which is the $(b\/a)^2$ factor.]

== The model is a near-balanced circulation, which is why its output can drop the motor speed <sec-circulation>

=== The core returns what the motors push out

At steady state a hypha cannot deliver $pi b^2 v_0$ of material outward indefinitely when growth consumes under 1 % of it; the rest has to come back through the same tube. The second solve is what makes that return consistent across the network, and @eq-local shows its size: a core return flux close to the motor flux, perturbed by the small growth consumption.

If this circulation picture is correct, backflow should be comparable to forward flow and should vary less with routed growth demand than the routed flux itself. Both patterns are present in the measurements: the median backflow and forward speeds are 2.56 and 2.72 µm/s, respectively, their median ratio is 1.07, and their natural-log spreads are 0.83 and 1.46 for backflow and routed flux, respectively.

=== Subtracting the motor speed cancels the return against its own driver

The full centreline output $v_"center" = v_0 - v_"press"$ treats the edge of the core as dragged outward at $v_0$. With the median $v_"press" approx 2.1 v_0$ it becomes $v_"center" approx -1.1 v_0$: a small residual left after the return leg has been cancelled against the stream that drives it. Wherever $v_"press"$ is closer to $v_0$ that residual collapses towards zero, although nothing measured does. The pressure-driven term already contains the motor speed through $q_s$, so subtracting $v_0$ again counts it twice. The cancellation therefore makes the full velocity a fragile residual of two terms that are each set by the circulation, rather than a direct measure of the return flow.

#argument[Dropping $v_0$ from the output keeps it where it belongs, as the driver of the circulation inside the solve, and removes it where it double-counts. The case grows stronger the narrower the core is relative to the tube.]

=== Tip-distance throttling slows the circulation near growing tips, by less than half the measured fall

By @eq-qs-thr the throttle scales the motor source, and by @eq-local $v_"press"$ scales with that source at nearly fixed geometry, so near a growing tip the predicted return slows by about $g(d)$. In this model, tip-distance-dependent throttling is the only growth-related mechanism that directly changes the circulation strength along an existing edge.

It reproduces only part of the measured near-tip decline. The offset throttle can slow the return by at most $1 - v_"tip" \/ v_0$ = 31 %, at the tip itself. On measured edges within 1 mm of a growing apical tip the median motor speed in the model is 2.36 µm/s and the median $hat(v)$ 2.49 µm/s, against 3.05 and 3.24 µm/s beyond 2.5 mm, a fall of 23 %; measured backflow falls from 2.83 to 1.34 µm/s, 53 %, and measured forward speed from 2.84 to 1.66 µm/s, 42 % (121 and 998 edges with node ids matching the measurement tables). The throttle fitted to forward speed therefore accounts for less than half of the near-tip fall in backflow, and less than half of the fall in forward speed it was fitted to, because the fit minimises error over the whole profile and 998 of these 1,418 edges lie beyond 2.5 mm. What lowers backflow the rest of the way near tips is not in the model.

== The prediction is the core-return plug speed, and a scale fitted to backflow lands on the same number <sec-fit>

The predicted backflow on an edge is $hat(v)$, the core-return plug speed of @eq-p-flux:

$ hat(v) = abs(q_c) / (pi a^2) = abs(v_"press") / 2, $ <eq-prediction>

computed with the measured $v_0$, $v_"tip"$ and $lambda$ of @sec-throttle and motors oriented outward on zero-flux edges (@sec-radius). There is no averaging factor to choose: $hat(v)$ is exactly the area-mean speed of the core's return flux, by construction of @eq-p-flux. Nothing in @eq-prediction is fitted to backflow.

#argument[$hat(v)$ is the return flux divided by the core's cross-section, so it is that flux's area-mean speed by construction, whatever the true profile inside the core. No assumption about how the velocimetry averages over the tube enters @eq-prediction.]

Whether the measured speed equals that area-mean, rather than some other average the velocimetry happens to report, is a separate, empirical question. A scale fitted to backflow checks it. For each session, $c$ in $c hat(v)$ is fitted on the other 11 as the median log ratio of measured backflow to $hat(v)$, on the model run with the assumed $v_0$ = 3 µm/s and the exponential throttle:

#table(
  columns: (auto, auto, auto),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  align: (left, right, right),
  table.header[*variant*][*$c$, median over the 12 folds*][*range*],
  [no throttle], [0.87], [0.85–0.89],
  [$lambda$ = 0.25 mm], [0.90], [–],
  [$lambda$ = 0.5 mm], [0.92], [–],
)

Because $hat(v)$ scales with the motor speed (@eq-local), $c$ should equal the ratio of the true motor speed to the assumed 3 µm/s. With the median measured forward speed in brightfield, 2.73 µm/s, that ratio is 0.91, between the fitted 0.87 without the throttle and 0.92 with it at 0.5 mm; with the fluorescence median, 2.63 µm/s, it is 0.88. Scored against backflow in the run with the exponential throttle, @eq-prediction matches the fitted-scale model on all edges and within 10 mm of the trail tip, and places more near-tip segments inside their own measured spread than a constant does (#link("backflow_model_accuracy.typ")[the backflow accuracy document], the section on the parameter-free prediction). When $lambda$ is fitted to backflow on held-out sessions instead of measured, selection picks 0.25 mm in 6 folds and 0.5 mm in the other 6, shorter than the 749 µm the same exponential form gives on brightfield forward speed.

= Discussion <sec-discussion>

The throttled core-return plug-speed model follows growth demand from the growth nodes (@sec-demand) through a Poiseuille network (@sec-solve1) to a lipid current that fixes a thin lipid shell, median $a\/b$ 0.973 (@sec-radius). The motors then drive the whole tube's flux less that lipid current (@sec-motor-flux). A second solve finds the pressure difference across each edge and the resulting pressure-driven velocity scale $v_"press"$ (@sec-solve2). Its core-flux interpretation gives the return speed $hat(v)$, which is half of $abs(v_"press")$ and locally is about the motor speed times the tube-to-core area ratio, reproducing the measured median ratio 1.06 (@sec-p, @sec-local). Read that way, the model is a near-balanced circulation in which growth consumes under 1 % of the motor flux, backflow matches forward speed, and the full centreline output's subtraction of $v_0$ double-counts the driver (@sec-circulation). The throttle scales the pumps near growing tips over a length measured from brightfield forward flow, 1711 µm, from 2.140 µm/s at a growing tip to 3.096 µm/s far from it, which reproduces less than half of the measured near-tip fall in backflow (@sec-circulation), and the prediction is the core-return plug speed $hat(v)$; the scales fitted to backflow on held-out sessions with the exponential throttle, 0.87–0.92, bracket the 0.91 implied by the median brightfield forward speed (@sec-throttle, @sec-fit). The model's value is not that it beats every aggregate baseline: a constant can score slightly better over all edges. Its value is that it supplies a mechanism, and therefore sensitivities to geometry, growth and tip distance, that a constant cannot. How well those sensitivities predict individual edges is the subject of #link("backflow_model_accuracy.typ")[the backflow accuracy document].

== The held-out scale matches the ratio of measured to assumed motor speed

Two routes give the same number: the ratio of the measured to the assumed motor speed, 2.73 / 3 = 0.91, and the scales fitted to backflow, 0.87–0.92 (@sec-fit). So the core-return plug speed already sits at the level the data select; the agreement could still be partly coincidence between the velocimetry's averaging and the true motor speed, since the velocimetry's band-averaged, streak-slope speed has no exact relation to a plug moving through the core's cross-section. Running a synthetic Poiseuille flow of known centreline speed through the same pipeline would settle it.

== An empirical living-edge extension gives zero-flux branches a motor direction

The network solve cannot infer a motor direction on an edge with zero routed growth flux. If such an edge is still alive, however, the motor-based forward-flow result suggests that it can continue to carry an outward motor stream even when no net growth demand is downstream. We therefore add an empirical extension: zero-flux edges are oriented outward, along increasing network distance from the roots (@sec-radius). This gives them a full-tube motor flux, $q_s = pi b^2 v_0$, and lets the core return it.

This is an assumption about the state of those edges, not a consequence of the growth solve. It is supported by the observed backflow on dead-end branches, about 2 µm/s, and improves their predictions from zero to a median 3.05 µm/s, against 1.99 µm/s measured, with 69 % within 2× of measurement (104 dead-end bridges with node ids matching the measurement tables). The extension is retained because it encodes the hypothesis that these branches remain physiologically active; it should be tested independently rather than folded into the derivation as if it were forced by conservation.

== Pressures in the solves are relative, so their unit does not reach the prediction

The viscosity is water's, $10^(-3)$ Pa·s, written in µm-based units, which makes the solves' pressure unit $10^6$ Pa. No pressure is ever compared with a physical value; pressures only enter through conductance times pressure difference within one solve, and through $v_"press"$, which is a velocity scale. A real pressure comparison, with turgor for instance, would need the unit made explicit. A cytoplasm more viscous than water would not change $v_"press"$ either: both solves are driven by fixed fluxes, so pressure differences scale with $mu$ and cancel in @eq-p, apart from the fixed root reservoir conductance, whose size relative to the network would shift.

== The weakest assumptions sit upstream of the circulation, and most do not move the prediction

The stoichiometry behind $kappa$, including the undocumented 0.9, sets the lipid current, which is under 1 % of the motor flux on a typical edge; a 1.3-fold change moves $v_"press"$ by well under 1 % on a typical edge. The passive-lipid assumption and the equal sharing of growth demand shape the routed flux, which the circulation barely depends on. The core-conductance exponent, Poiseuille's $a^4$ against $a^3$ or $a^2$, moves the prediction on a typical edge by under 10 % (@sec-solve2). The assumptions that do reach the prediction are the plug-flow annulus at the motor speed, the solved shell thickness, which @eq-local shows sets $hat(v)$ through $(b\/a)^2$, the outward motor direction on zero-flux edges, and the throttle's exponential shape.

= Actionable Items <sec-actions>

#open Run a synthetic Poiseuille flow of known centreline speed through the kymograph and streak-slope pipeline, and read off the fraction of the centreline speed it reports. That checks directly whether the velocimetry measures the core's area-mean speed, which the prediction assumes but a Poiseuille profile alone does not derive from the instrument.

#open Replace the $a = 0.75 b$ clamp for over-full edges with a closed core, $a = 0$, and check how many edges change.

#open Find the source of the lipid stoichiometry, in particular the 0.9, and decide whether the carbon fraction of lipid belongs in $kappa$. Low priority: it moves the prediction by under 1 %.

#open Test the passive-lipid assumption against fluorescence, which follows lipids: lipid speed should track the routed water flux if it holds.

= Appendix <sec-appendix>

== Parameters <sec-app-params>

#set text(8.5pt)
#table(
  columns: (auto, 1fr, auto, auto, auto),
  inset: 3.5pt,
  stroke: 0.4pt + luma(200),
  table.header[*symbol*][*meaning*][*value*][*unit*][*class*],
  [$v_0$],
  [motor speed of the annulus, from the brightfield forward speed far from tips],
  [3.096 (3.08–3.14 over folds)],
  [µm/s],
  [measured],

  [$v_"tip"$],
  [motor speed at a growing apical tip, @eq-throttle, from the brightfield forward speed profile],
  [2.140 (2.08–2.16 over folds)],
  [µm/s],
  [measured],

  [$theta$], [lipid fraction of the annulus area], [0.15], [–], [assumed],
  [$mu$], [viscosity (water)], [$10^(-3)$], [Pa·s], [assumed],
  [$f_"dry"$], [dry mass fraction of new hypha], [0.21], [–], [assumed],
  [$f_C$], [carbon fraction of dry mass], [0.5], [–], [assumed],
  [$rho_"tissue"$], [tissue density], [1.1], [g/cm³], [assumed],
  [CUE], [carbon-use efficiency], [0.5], [–], [assumed],
  [$rho_"lipid"$], [lipid density, undocumented, inferred from units], [0.9], [g/cm³], [assumed],
  [$kappa$], [volume carbon ratio, @eq-lipid], [0.256], [–], [derived from the above],
  [$b$], [outer radius, half the segmented width], [per edge; median width 8–9 µm], [µm], [measured],
  [$L$], [segment length], [per edge], [µm], [measured],
  [$Delta t$], [time from session to end of growth window], [per session], [s], [measured],
  [$t$],
  [network frame at which the video was recorded; the network is truncated at $t + 4$],
  [per session],
  [frame],
  [fixed by construction],

  [window], [growth window after the session], [4], [frames], [assumed],
  [$D_n$], [water demand of a growth node, @eq-demand], [per node], [µm³/s], [derived from measured growth],
  [$Q$], [routed growth flux, @eq-solve1], [per edge], [µm³/s], [solved],
  [$J$], [lipid current, @eq-lipid], [per edge], [µm³/s], [solved],
  [$a$], [core radius, @eq-radius], [per edge; median $a\/b$ 0.973], [µm], [solved],
  [$n$], [exponent weighting the core conductance, @sec-solve2], [4], [–], [assumed; data cannot distinguish 3 or 2],
  [$q_s$], [motor flux, @eq-qs-closed], [per edge], [µm³/s], [solved],
  [$d$], [network distance to nearest growing apical tip], [per edge], [µm], [measured],
  [$lambda$],
  [throttle decay length, @eq-throttle, from the brightfield forward speed profile],
  [1711 (1442–1922 over folds)],
  [µm],
  [measured],

  [$v_"press"$], [pressure-driven velocity scale, @eq-p], [per edge; median about $2.1 v_0$], [µm/s], [solved],
  [$hat(v)$],
  [core-return plug speed, @eq-p-flux; the prediction],
  [per edge; median about $1.1 v_0$],
  [µm/s],
  [derived from $v_"press"$],

  [motor direction],
  [sign of the routed flux; outward from the roots where the flux is zero],
  [per edge],
  [–],
  [assumed rule],

  [roots], [reservoir nodes, placed by hand], [per session], [–], [measured (annotation)],
)
#set text(10pt)

== Numerical safeguards <sec-app-safeguards>

The solver needs a handful of settings that no physical argument fixes. None of them is fitted, and the list states whether each can reach the prediction.

#table(
  columns: (26%, 22%, 52%),
  inset: 4pt,
  stroke: 0.4pt + luma(200),
  table.header[*safeguard*][*value*][*what it does, and whether it matters*],
  [root reservoir conductance],
  [$10^7$ in solver units],
  [Ties each root towards zero pressure in both solves. It is smaller than a typical edge conductance ($10^8$–$10^9$), so roots are not held exactly at zero, and with several roots its size shapes how the returning flow is shared between them. Set by hand, identical in both solves, never varied.],

  [minimum component size], [100 nodes], [Pieces smaller than this are not solved and get no prediction.],
  [core clamp],
  [$a = 0.75 b$ when $a^2 <= 0$],
  [Keeps an over-full edge open instead of closing it. Affects only edges whose lipid current exceeds what the annulus can carry.],

  [minimum core conductance],
  [100 in solver units],
  [Replaces a zero core conductance. Unreachable while the core clamp is in place.],

  [zero-flux threshold],
  [$10^(-12)$],
  [Sets a lipid current below it, and in the first solve a pressure difference below it, to exactly zero, which gives the edge the outward motor direction (@sec-radius). 106 of 1,560 measured edges carry zero routed flux.],

  [radius floor], [radius below 0.01 µm set to 2.5 µm], [Guards against missing widths.],
  [length floor],
  [length below 1 µm, or missing, set to 33 µm],
  [Guards against degenerate segments, in the solves and in the throttle distance.],

  [missing grown width], [7 µm], [Width assumed for a grown segment with no measured width when computing its volume.],
)

== References

#bibliography("references.bib", title: none, style: "apa")
