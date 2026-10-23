// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// SKELETON: every "TO FILL" block is the contract for one test of the investigation plan.
// ---------------------------------------------------------------------------

#set document(
  title: "Flux balance at hyphal junctions — motor-driven two-way flow on tree-like network",
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
#set math.equation(numbering: "(1)")
#set heading(numbering: (..n) => if n.pos().len() < 4 { numbering("1.1", ..n) })
#set ref(supplement: it => if it.func() == figure { it.supplement } else if it.func() == math.equation { "Equation" } else { "Section" })
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

#show figure.caption: set align(left)
#show figure.caption: set par(justify: false)
#show figure: set block(breakable: true)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

// A slot the investigation fills: phase, owning agent, hypothesis, predictions per outcome, figure and table slots.
#let tofill(phase, agent, body) = block(
  fill: rgb("#fdf6e3"), stroke: (left: 2pt + rgb("#b58900")), inset: 9pt, radius: 2pt, width: 100%,
  text(9pt)[#text(weight: 700)[TO FILL — #phase, #agent.] #body],
)

// Figure placeholder until the phase delivers the panel.
#let placeholder(cap, height: 5cm) = figure(
  rect(width: 94%, height: height, fill: luma(240), stroke: 0.4pt + luma(200),
    align(center + horizon, text(9pt, fill: luma(120))[figure pending])),
  caption: text(8.5pt, fill: luma(95), cap),
)

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Flux balance at hyphal junctions]
  #v(-0.3em)
  #text(19pt, weight: 700)[motor-driven two-way flow on tree-like network]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · 309 brightfield junction videos from eight plates of #emph[Rhizophagus irregularis], rerun with
    the wall U-Net video segmenter · plan and theory, results in progress · transport_paper\@d42d483
  ]
]
#v(1.2em)

= Introduction

#question[Where a hypha branches, a motor-driven stream carries material toward the tips and a return stream carries volume back toward the root. Do these two streams add up across the branches of a junction, and if they do not, is the missing part lane geometry, a sheared return core, growth, or flow that turns round at the junction itself?]

The plates are colonies of #emph[Rhizophagus irregularis] imaged over days. Each imaging timepoint is segmented into a
network graph, and short videos at many stage positions record the flow inside the hyphae. A flow video that frames a
whole junction measures every branch leg at the same moment, so the flow on the leg growth arrived along (the stem) can be compared
directly with the flow on the tip-side legs (the children).

Most hyphae carry material both ways at once: a tipward stream at close to motor speed and a rootward return.
#link("lane_flux_balance.typ")[`science/lane_flux_balance.typ`] reads the pair as two plug lanes side by side with zero net volume flux through each
edge, and finds no test that refutes zero net flux on bridge edges. A junction adds a second conservation law: each
stream's flux must be conserved across the branches, unless material crosses between the streams at the junction.
This document sets out what that law predicts under two cross-section geometries, an annulus around a core and lanes of
arbitrary shape, and plans the tests. It starts with tree-like parts of the network, where zero net flux through each
leg is the most defensible assumption.

= Motivation

The first attempt at the junction balance weighted each leg's measured streak speed by its lumen area,
$Q = v times w^2$. That leaves about 30 % of the flux unaccounted for at 70 junctions (@sec-r-w2), in both streams, and
three explanations have already been measured and rejected (@sec-deadends). The rejected explanations share one
hidden assumption: each stream is weighted as if it filled the whole cross-section. With two streams in one lumen,
each fills only part of it, and zero net flux fixes how large that part is. So the weighting has to change before
anything else about the junction can be read.

Three things depend on the answer:

- *The model's junction rule.* The transport model conserves the return stream at junctions (Fig 4F, "backflow
  Kirchhoff"). If the measured streams do not close, either the flux weighting is wrong or the rule is.
- *The cross-section geometry.* A coaxial core and side-by-side lanes give the same balance when both streams move as
  plugs. They give different balances when the core is sheared. A junction closure test therefore discriminates
  geometries that single-edge tests cannot.
- *Local recirculation.* If flux closes only with an exchange term, junctions are places where the return stream
  turns back tipward. That is a physical claim about where motors load, and it would need to enter the model. AMF
  hyphae are coenocytic and aseptate @cargillCellularAnatomyArbuscular2025, unlike septate ascomycete hyphae, where a
  Woronin-body-plugged pore can gate a compartment off @jeddNewSelfAssembled2000 @fleissnerSoProteinInvolved2007
  @steinbergAtpPreventsWoronin2017.

= Method <sec-method>

The method has two halves. @sec-m-notation to @sec-m-growth derive the flux each leg carries and the balance a junction
must satisfy, for each geometry. @sec-m-tests turns them into numbered tests.

== Each leg carries a tipward and a rootward stream, and the junction couples them <sec-m-notation>

Take a junction $J$ with legs $i = 0, dots, k$. Leg 0 is the stem, the leg along which growth runs into the junction
in the store's growth graph (two legs where hyphae fused, 2 of the 70 junctions). The others are children. On leg $i$:

#table(
  columns: (auto, 1fr), align: (left, left), stroke: none, inset: (x: 6pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [$A_i = pi w_i^2 slash 4$], [lumen area, from the U-Net lumen width $w_i$],
  [$v_(m,i), A_(m,i)$], [speed and area of the tipward motor stream (to tip)],
  [$v_(b,i), A_(b,i)$], [speed and area of the rootward return stream (to root)],
  [$s_i$], [stationary share of the cross-section, so $A_(m,i) + A_(b,i) = (1 - s_i) A_i$],
  [$Q_(m,i) = v_(m,i) A_(m,i)$, $Q_(b,i) = v_(b,i) A_(b,i)$], [volume flux of each stream],
  [$q_i = Q_(m,i) - Q_(b,i)$], [net volume flux, tipward positive],
  [$tilde(v)_(m,i), tilde(v)_(b,i)$], [measured median streak speed of each stream],
  [$R_i = tilde(v)_(b,i) slash tilde(v)_(m,i)$], [measured speed ratio],
  table.hline(stroke: 0.6pt),
)

Volume is conserved at the junction. Let $X$ be the volume per unit time that leaves the rootward stream and joins the
tipward stream at the junction. $X > 0$ means return flow turns round and heads back toward the tips. Then each stream
obeys its own balance:
$ Q_(m,0) + X = sum_(c >= 1) Q_(m,c), quad quad sum_(c >= 1) Q_(b,c) = Q_(b,0) + X , $ <eq-streams>
and subtracting them gives total volume conservation, $q_0 = sum_c q_c$. The measured quantity is the balance ratio
of each stream,
$ B_b = Q_(b,0) / (sum_c Q_(b,c)) = 1 - X / (sum_c Q_(b,c)), quad quad
  B_m = Q_(m,0) / (sum_c Q_(m,c)) = 1 - X / (sum_c Q_(m,c)) . $ <eq-balance-ratio>

Two consequences follow before any geometry enters:

- *Total volume says nothing on a tree.* If every leg has zero net flux, $q_0 = sum_c q_c$ is $0 = 0$. Only the
  stream balances @eq-streams carry information.
- *With zero net flux on every leg, the two streams have the same balance.* $Q_(m,i) = Q_(b,i)$ gives $B_m = B_b$
  exactly. Measured $B$ below 1 then means one of two things: $X > 0$, return flow turning tipward at the junction, or a
  flux estimate that is biased between stem and children.

== Zero net flux fixes each stream's area, whatever the geometry <sec-m-general>

Write each stream's flux as its area times its area-mean speed, and relate that mean to the measured median through a
profile factor $kappa = macron(v) slash tilde(v)$. Here $kappa = 1$ for a plug, and in general it is the ratio of mean to
median of the speeds of tracers spread evenly over the stream's area. Let $V_m = kappa_m tilde(v)_m$ and
$V_b = kappa_b tilde(v)_b$. The two areas share the moving cross-section, and the net flux is $q$:
$ A_m + A_b = (1 - s) A, quad quad V_m A_m - V_b A_b = q . $
Solving for the rootward area and flux:
$ A_b = ((1 - s) A V_m - q) / (V_m + V_b), quad quad
  Q_b = V_b A_b = (1 - s) A (V_m V_b) / (V_m + V_b) - q V_b / (V_m + V_b) . $ <eq-flux-general>
With zero net flux the flux of either stream is the moving area times half the harmonic mean of the two stream speeds:
$ Q_i = (1 - s_i) A_i H(V_(m,i), V_(b,i)), quad quad H(x, y) = (x y) / (x + y) . $ <eq-flux-zero>
Neither the number of lanes nor their shape enters. Geometry reaches the flux only through the profile factors
$kappa$, the stationary share $s$ and the net flux $q$. This is @eq-flux-zero's content beyond
#link("lane_flux_balance.typ")[`science/lane_flux_balance.typ`], whose area fraction $f = 1 slash (1 + R)$ is the special case $kappa = 1$:
$A_b slash (1 - s) A = V_m slash (V_m + V_b)$.

Two terms cancel within a junction and need not be measured. A stationary share common to all legs drops out of
@eq-balance-ratio. So does any recording effect shared by the legs, since every leg comes from the same video. That
matters: per-edge $R$ repeats poorly between videos of the same edge (#link("lane_flux_balance.typ")[`lane_flux_balance.typ`], reliability section),
and the junction design never compares across videos.

== What the width-squared balance actually measured <sec-m-w2>

The balance of @sec-r-w2 used $Q_i = tilde(v)_(b,i) A_i$ for the rootward stream. Against @eq-flux-zero:
$ B_b^(w^2) = B_b dot (chevron.l phi chevron.r_c) / phi_0, quad quad
  phi_i = (1 - s_i) kappa_(b,i) V_(m,i) / (V_(m,i) + V_(b,i)) , $ <eq-w2-bias>
where $phi_i$ is leg $i$'s rootward-stream area share times its profile factor, and $chevron.l phi chevron.r_c$ is the
children's mean weighted by $tilde(v)_(b,c) A_c$. A measured $B_b^(w^2) = 0.73$ is fully explained by geometry,
$B_b = 1$, when the stem's rootward share is 1.37 times the children's. For plug lanes,
$phi = 1 slash (1 + R)$, that means $(1 + R_c) slash (1 + R_0) approx 1.37$: the stem's return is slow relative to its
motor stream compared with the children's. That is a checkable prediction from speeds alone. The stem's return speed
is 1.14 times the children's, so the ratio closes only if the stem's motor stream is faster still.

== Geometry A: an annulus around a core <sec-m-annulus>

=== Plug annulus and plug core are the lane model

Put the tipward motor stream in an annulus $a < r < b$ and the return in the core $r < a$, both as plugs. Zero net flux
gives $a slash b = 1 slash sqrt(1 + R)$ (#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[`findings/annulus_geometry_from_two_channels.typ`]), which is
$A_b slash A = 1 slash (1 + R)$, the $kappa = 1$ case of @eq-flux-zero. For plug streams a coaxial split and side-by-side
lanes give identical junction balances. The radial profiles found no centred core (#link("radial_flow_structure.typ")[`science/radial_flow_structure.typ`])
and plug lanes in both channels (#link("lane_flux_balance.typ")[`lane_flux_balance.typ`]), so this case is the working default.

=== A sheared core changes the balance, and predicts a wide speed spread

The older backflow model returned fluid through a parabolic core. Keep the annulus as a motor-driven plug at speed $U$
tipward, and let the core carry a pressure-driven parabola that meets the annulus speed at $r = a$. With rootward
positive and centre-line speed $u_0$:
$ u(r) = u_0 - (u_0 + U) r^2 / a^2 , quad r <= a . $
The flow is rootward only inside $r_*$, where $u(r_*) = 0$: $r_*^2 = a^2 u_0 slash (u_0 + U)$. The rootward flux is
$pi r_*^2 u_0 slash 2$. Setting the net flux across the whole section to zero, with $alpha = a slash b$, gives
$ r_*^2 / a^2 = 1 - alpha^2 / 2, quad quad u_0 / U = (2 - alpha^2) / alpha^2 , $ <eq-core-geometry>
and each stream's flux in terms of the two speeds is
$ Q = A U u_0^2 / (U + u_0)^2 = A H(U, u_0) dot u_0 / (U + u_0) . $ <eq-flux-core>
This is the plug flux with $V_b = u_0$, times the factor $u_0 slash (U + u_0)$. It requires $u_0 >= U$, since
$alpha <= 1$. A leg whose return is slower at the centre than its motor stream cannot be a sheared core.
@eq-core-geometry and @eq-flux-core were checked by numerical integration at $alpha = 0.6$, 0.8 and 0.95.

What the streaks read: tracers spread evenly over the rootward region have speeds uniform on $[0, u_0]$, because
$u$ is linear in $r^2$. After the static cut $c$ (1 µm/s), the kept speeds are uniform on $[c, u_0]$, so
$ tilde(v)_b = (u_0 + c) / 2, quad quad q_75 / q_25 = (c + 3 u_0) / (3 c + u_0) . $ <eq-core-readout>
At a median of 2.5 µm/s this predicts $u_0 = 4$ µm/s and a quartile spread of 1.86. That can be checked leg by leg
against the measured spread before any junction balance is computed.

== Geometry B: lanes of arbitrary cross-section <sec-m-lanes>

For any partition of the lumen into a tipward region, a rootward region and a stationary region, @eq-flux-general holds
with $kappa$ the mean-to-median ratio of each region's speeds. The measured streak distribution samples those speeds
directly, if tracers spread evenly over each region, so the profile factor can be read from the data. Use the mean
moving-streak speed in place of the median:
$ V_(b,i) approx macron(v)_(b,i) quad "(mean of kept rootward streaks)" , $ <eq-mean-estimator>
and likewise for the tipward stream. This needs no profile shape. The plug result, centre-to-edge speed 0.99 in
brightfield and 1.07 in fluorescence (#link("lane_flux_balance.typ")[`lane_flux_balance.typ`]), predicts $kappa approx 1$ and mean close to median.
The static cut biases the mean upward on slow legs, by the same amount in stem and children when their speeds are
similar.

== Growth sets the net flux on a tree, and motors set how the tipward stream splits <sec-m-growth>

On a tree the net flux through a leg is the volume consumed by growth downstream of it, $q_i = G_i$, with $G_i$ from
the growth graph's downstream extension rate times lumen area. The median growth need is a lumen speed of about
0.18 µm/s (#link("lane_flux_balance.typ")[`lane_flux_balance.typ`]), a few percent of motor speed. Growth does not break either stream's balance: the
stem carries its children's growth need, $G_0 = sum_c G_c$, and each stream is still conserved. It biases only the
zero-net estimate @eq-flux-zero, which overstates the rootward flux by $G_i beta_i$ with
$beta_i = V_(b,i) slash (V_(m,i) + V_(b,i))$. Substituting into @eq-balance-ratio with $X = 0$, the estimated balance is
$ hat(B)_b = 1 + (sum_c G_c (beta_0 - beta_c)) / (sum_c hat(Q)_c) , $ <eq-growth-bias>
second order: growth over flux, times the difference in rootward share between stem and children. Growth cannot
produce a 30 % shortfall.

The motor stream gives one prediction that needs no stem. If motors deliver material to where it is consumed, the
children's share of tipward flux follows their share of downstream growth demand $D_c$:
$ Q_(m,c) / (sum_c Q_(m,c)) quad "against" quad D_c / (sum_c D_c) . $ <eq-split>
Because the motor speed saturates near 3 µm/s, children differ mostly in stream area. So @eq-split asks whether
the motor stream's area in each branch follows that branch's demand.

== Assumptions, each assigned a test <sec-m-assumptions>

#table(
  columns: (auto, 1fr, auto), align: (left, left, left), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*\#*], [*assumption*], [*tested in*],
  table.hline(stroke: 0.4pt),
  [1], [zero net flux through each leg of a tree-like junction (up to growth)], [J0, J4],
  [2], [steady state over the video; no exchange through the wall], [not tested],
  [3], [the stem is the leg growth arrived along], [@sec-deadends (stem check); J3 random-stem null],
  [4], [each stream is one plug per leg ($kappa = 1$)], [J1, J3 (mean estimator)],
  [5], [stationary share equal across the legs of one junction], [@sec-r-static (motion variance)],
  [6], [the U-Net lumen width is the moving cross-section's width], [J7 (outer width only)],
  [7], [streak medians are unbiased between stem and children], [J1 (counts, spreads)],
  [8], [no stream crossing at the junction ($X = 0$)], [J3, J6],
  table.hline(stroke: 0.6pt),
)

== Nine tests, cheapest first <sec-m-tests>

Every test runs on the 70 junctions of @sec-r-w2 and on their tree-like subset, reported side by side. The balance
statistic is the median of $B$ over junctions with a 95 % bootstrap interval resampled by video, and the median
$|ln B|$ against a random-stem null computed with the same flux formula. A formula *closes* the balance when the
interval of the median contains 1 and its median $|ln B|$ is below the null's 2.5th percentile.

+ *J0 — Select tree-like junctions.* This establishes the sample on which zero net flux is defensible. A junction is
  tree-like when every incident arc is a bridge of the session graph. A relaxed set admits junctions with no cycle shorter than
  3 mm through any leg, the shortest cycle being found by removing the leg and reconnecting its ends through the
  session graph. The loop-circulation prediction $hat(q)$ was the first choice for this rule, but it exists for only 8
  of the 15 stores (`loop_circulation.py`). Only 20 of 227 measured brightfield edges were bridges in the lane analysis,
  so the strict set may be small. *Continue* with the strict set if it holds at least 15 junctions with both streams on
  every leg; otherwise use the relaxed set.
+ *J1 — Per-leg readout, before any balance.* This establishes which geometry each leg admits, from its own streaks
  alone. Per leg and stream: count, median, mean, quartiles and $R$, from the rerun's streak tables. Checks: the share
  of legs with $2 tilde(v)_b - c < tilde(v)_m$, which the sheared core forbids; measured rootward $q_75 slash q_25$
  against @eq-core-readout; and mean against median for $kappa$. *Kill the sheared core* if the measured spread sits
  below the prediction on most legs, or more than a quarter of legs violate $u_0 >= U$.
+ *J2 — The width-squared bias, predicted from speeds.* This tests @eq-w2-bias before computing any new balance: is
  $(1 + R_c) slash (1 + R_0)$ near 1.37 on the junctions where $B^(w^2)$ is near 0.73, and does it track $B^(w^2)$
  across junctions? Report both.
+ *J3 — The balance under each flux formula.* This establishes which geometry closes the junctions. Compute $B_b$ with
  (a) $tilde(v) A$, the current weighting; (b) plug lanes, @eq-flux-zero with $kappa = 1$; (c) the sheared core,
  @eq-flux-core with $u_0 = 2 tilde(v)_b - c$; (d) the mean estimator, @eq-mean-estimator. Each gets a random-stem
  null. Tree-like and all junctions are shown separately. The verdict table is set out below the list.
+ *J4 — The growth correction.* On tree-like junctions this puts $q_i = G_i$ into @eq-flux-general and reports the
  shift in $B$ against @eq-growth-bias. Expected: well under the interval of $B$. A larger shift means the growth
  need per leg is larger than the 0.18 µm/s median suggests.
+ *J5 — Motor split between children.* This is the stem-free test, @eq-split: children's tipward flux share against
  their downstream-demand share, with a shuffled-demand null. It uses the formula J3 selects. A positive slope says the
  motor stream is apportioned by demand at the junction.
+ *J6 — Flow passing between the children.* This looks for $X$ directly. With the stem chosen by distance to the
  root, return flow from one child that continues into the other child is exactly $X$: to root in one child, to tip
  in the other. So the test asks whether streaks continue straight through the node on child-to-child paths, against
  child-to-stem paths as the positive control. Kymographs of every leg outward from the U-Net junction node are built
  from the raw video (`snellius/junction_transfer.py`) and joined into paths through the node. Continuity is read two
  ways: (i) the correlation between positions on the two legs at the travel time through the node, normalised by the
  same correlation within a leg; (ii) line continuity, the correlation between the two halves of a path after every
  pixel is mapped to the time its line crosses the node at speed $v$. Crossing counts do not measure flux in this
  pipeline (#link("lane_flux_balance.typ")[`lane_flux_balance.typ`], calibration), so both are presence tests. (iii) The streak detector itself:
  a path through the node runs unchanged through the production chain (volume extraction, normalisation, kymograph,
  orientation tensor, `detect_streaks` at 0.10 / 0.17, 15 frames), and a streak spans the node when it reaches 6 µm
  on both sides (`snellius/junction_path_streaks.py`).
+ *J7 — Width check.* This bounds a width bias between stem and children, independently of the U-Net. Each leg is
  measured again from the raw video, on perpendicular lines every 20 px along the edge, 120 px clear of both ends, in
  the time-mean of 150 frames: from dark wall band to dark wall band, and from bright outer halo to halo. The U-Net
  lumen run along the same lines is the like-for-like reference. Overlays on 10 random junctions check the edges by
  eye. $B$ scales as the ratio of $w^2$, so a 10 % relative width error moves it by 20 %.
+ *J8 — Speed against width across the junction.* This asks whether the stem's streams speed up to carry what its
  smaller cross-section cannot. Per junction, the log of the stem-to-children speed ratio of each stream is regressed
  on the log of the stem-to-children area ratio. Stream-by-stream conservation predicts a slope of −1. Speeds set by
  each hypha's own width predict the slope of the speed-width law instead: the transport model's return
  $prop w^(0.7)$ is a slope of +0.35 on area.
+ *J9 — Junction geometry.* This asks where the missing flux goes. Each leg's direction runs from the U-Net node to
  the point 20 µm along it. The straightest pair of legs is a through-hypha when it meets at 130° or more and is at
  least 25° straighter than the next pair; U-Net centre lines curve into the node, so a straight hypha reads 140–150°
  over a 20 µm arm. Class A: the stem continues straight into one child, and the other child branches off. Class B:
  the two children form the through-hypha, and the stem branches off. Class C: no clear through-hypha. Class D: four
  or more legs. In class A the stem is also compared with the straight-through child alone.

#table(
  columns: (1.3fr, 2fr), align: (left, left), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*J3 outcome*], [*reading*],
  table.hline(stroke: 0.4pt),
  [(b) closes], [plug lanes with zero net flux explain junctions; the shortfall was the full-section weighting],
  [(c) closes, (b) does not], [a sheared core, which contradicts the radial and lane results; reconcile before use],
  [(d) closes, (b) does not], [profile shape matters although centre-to-edge speeds look flat; revisit the plug result],
  [none closes, $B < 1$ in all], [return flow turns tipward at junctions ($X > 0$); run J6],
  [tree-like closes, all does not], [circulation through loops; the lane model's loop layer applies],
  table.hline(stroke: 0.6pt),
)

= Results <sec-results>

== Speed times width squared leaves about 30 % of the flux unaccounted for at 70 junctions <sec-r-w2>

All 309 junction videos were rerun with the wall U-Net video segmenter on Snellius (jobs 27029651 and 27033747). That
gives a lumen mask, a graph with U-Net junction nodes, and individual streaks per edge. Of 353 junctions filmed whole,
215 match onto the U-Net graph with one shared node and a separate U-Net edge per leg, 182 have streaks on every leg
and a stem, and 70 have at least five moving streaks in each stream on every leg (66 of them three-way). The 13 left
out for sharing an edge are places where one U-Net edge serves as two legs, so the U-Net graph has no node where the
store has one; 6 of them would otherwise pass the streak cut, all on PNF2307A080. The stem is the leg growth arrives
along in the store's growth graph (@sec-m-notation). Lumen widths come from twice the distance transform along each
edge (job 27034024).

#table(
  columns: (1.6fr, 1.3fr, 1fr), align: (left, center, center), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*stem / sum of children, median (IQR)*], [*U-Net lumen width*], [*STG width*],
  table.hline(stroke: 0.4pt),
  [rootward flux, $tilde(v)_b w^2$], [0.73 (0.61–0.84)], [0.63 (0.56–0.80)],
  [tipward flux, $tilde(v)_m w^2$], [0.68 (0.61–0.76)], [0.60 (0.52–0.67)],
  [$w^2$ alone], [0.67 (0.59–0.74)], [0.56 (0.52–0.65)],
  [rootward speed, stem / mean of children], [1.14 (0.99–1.27)], [—],
  table.hline(stroke: 0.6pt),
) <tab-w2>

The U-Net widths move every row 0.08–0.11 toward closure. The STG underestimates stem width relative to the
children. The remaining shortfall sits in the area term: the stem's $w^2$ is 0.67 of the children's sum, and its
rootward speed rises only 1.14-fold. `unet_junction_balance_all.py`.

The sections from @sec-r-j7 on were measured before two changes to this junction set: the stem was then the leg whose
far end is nearest a root, and the 6 shared-edge junctions were still in (73 or 76 junctions). On the 70 junctions
above, the two rules pick the same stem at 61. `transport_paper/Notes/conveyor_junctions.typ`
carries the class, speed-term and side-branch results on the growth-graph stems.

== Only 1 of 70 junctions is strictly tree-like; 23 have no loop shorter than 3 mm <sec-r-j0>

Of the 214 legs of the 70 junctions, 13 are bridges, and only 1 junction has a bridge on every leg. The strict set is
far below the 15 needed, so the tree-like set is the relaxed one. The number of junctions with no cycle shorter than
1, 2, 3 and 5 mm through any leg is 62, 33, 23 and 12. The 3 mm set, 23 junctions, is used below. The networks loop
so densely that a strictly tree-like junction filmed whole is rare.

== The streak spreads rule out a sheared core: 1.43 measured against 2.17 predicted <sec-r-j1>

On the 214 legs, the to-root streaks have a median quartile spread $q_75 slash q_25$ of 1.43. A sheared core with the
same medians predicts 2.17 (@eq-core-readout), and the measured spread is below the prediction on 88 % of legs
(@fig-j1). Measurement noise can only widen a spread, so the gap cannot be a noise effect. The to-tip spread is 1.19.
The other check is weaker: $u_0 >= U$ is violated on 5 % of legs, under the quarter set as the limit. The pre-registered
kill fires on the spread, so the sheared core is rejected, independently of the radial profiles that already argued
against it. Mean and median agree within 1 % in both streams (to root 1.001, to tip 0.994), so $kappa approx 1$ and the
mean estimator (d) is expected to match the plug formula (b).

#figure(image("figures/junction_j1_spread.svg", width: 55%),
  caption: text(8.5pt, fill: luma(95))[Per leg, measured to-root $q_75 slash q_25$ against the sheared-core prediction
  from the same leg's median (@eq-core-readout), with the 1:1 line. 214 legs of 70 junctions. Source:
  `junction_flux_tests.py`.]) <fig-j1>

== Stem and children share their lumen between the streams alike, so lane shares cannot close the gap <sec-r-j2>

Plug lanes would close the width-squared balance if the stem's to-root share $phi_0 = 1 slash (1 + R_0)$ were 1.38
times the children's weighted share (@eq-w2-bias; 1.38 is the median of $1 slash B^(w^2)$ over the 70 junctions). The
measured ratio is 0.98 (IQR 0.92–1.06). Stem and children split their lumen between the two streams in nearly the same
proportion, so the lane correction changes the balance by a few percent at most. The per-junction Spearman correlation
between the two is 0.77, but that is not support: both contain the stem's to-root speed, one in the denominator and
one through $R_0$.

== No flux formula closes the balance; all four sit near 0.7, on tree-like junctions too <sec-r-j3>

#table(
  columns: (1.5fr, 0.5fr, 1.5fr, 0.8fr, 0.9fr, 0.9fr), align: (left, center, center, center, center, center),
  stroke: none, inset: (x: 5pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*formula*], [*n*], [*median $B$ [95 % CI]*], [*median $|ln B|$*], [*random stem: median $B$*],
  [*random stem: $|ln B|$ 2.5th pct*],
  table.hline(stroke: 0.4pt),
  table.cell(colspan: 6)[_all junctions_],
  [(a) $tilde(v)_b A$], [70], [0.73 [0.66, 0.76]], [0.32], [0.51], [0.48],
  [(b) plug lanes], [70], [0.69 [0.68, 0.74]], [0.37], [0.55], [0.46],
  [(c) sheared core], [70], [0.73 [0.67, 0.75]], [0.32], [0.52], [0.46],
  [(d) mean speeds], [70], [0.69 [0.66, 0.73]], [0.37], [0.55], [0.46],
  table.cell(colspan: 6)[_tree-like, no cycle shorter than 3 mm_],
  [(a) $tilde(v)_b A$], [23], [0.73 [0.66, 0.77]], [0.32], [0.56], [0.43],
  [(b) plug lanes], [23], [0.72 [0.68, 0.77]], [0.34], [0.57], [0.41],
  [(c) sheared core], [23], [0.73 [0.69, 0.75]], [0.31], [0.55], [0.42],
  [(d) mean speeds], [23], [0.70 [0.66, 0.75]], [0.36], [0.58], [0.43],
  table.hline(stroke: 0.6pt),
) <tab-j3>

Every formula beats the random stem, by a median $|ln B|$ of 0.31–0.37 against a null whose 2.5th percentile is
0.41–0.48. None closes: every bootstrap interval ends between 0.73 and 0.77 (@fig-j3 and the table above). The four formulas
differ by at most 0.04 in median $B$, which follows from @sec-r-j2 and @sec-r-j1: stem and children have the same
speed ratio, and mean equals median, so any factor built from the two speeds cancels between stem and children. The
tree-like junctions sit at most 0.02 higher than all junctions, well within the intervals, so loop circulation does not carry
the shortfall either.

In the outcome table of @sec-m-tests this is "none closes, $B < 1$ in all". The whole shortfall sits in the lumen
areas. The stem's $w^2$ is 0.67 of the children's sum (@sec-r-w2), and no speed-based correction moves it. Two readings
remain. Return flow turns tipward at the junction, $X approx 0.27 sum_c Q_(b,c)$, which J6 looks for. Or the lumen widths are biased between stem and children, which J7 rules out (@sec-r-j7).

#figure(image("figures/junction_j3_balance.svg", width: 100%),
  caption: text(8.5pt, fill: luma(95))[To-root balance $B$ per junction under each flux formula (dots), median (black),
  95 % bootstrap interval over videos (orange), and the median under a random stem (dashed); log scale, $B = 1$
  marked. Left all 70 junctions, right the 23 with no cycle shorter than 3 mm. Source: `junction_flux_tests.py`.])
<fig-j3>

== Does growth move the balance by more than its second-order bias? <sec-r-j4>

#tofill("J4", "coordinator")[$B$ with and without $q = G$; the shift against @eq-growth-bias.]

== Does the tipward stream split between children by their growth demand? <sec-r-j5>

#tofill("J5", "coordinator")[Children's tipward-flux share against demand share; slope and shuffled null.]

== Ten-second videos cannot show flow passing through a node; J6 is inconclusive <sec-r-j6>

Neither continuity measure clears its positive control. For the correlation measure, the maximum over speeds on
records mostly 200 frames long (10 s at 20 fps) picks up noise at the slowest speeds, and every pair class reads
alike; correlated at the measured leg speeds instead, even within-leg references fall to 0.01–0.1. For line
continuity (468 ordered leg pairs), every class sits at its null, a time-reversed right half with the same
speed search:

#table(
  columns: (1.3fr, 0.5fr, 1fr, 1fr, 1fr, 1fr), align: (left, center, center, center, center, center), stroke: none,
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*pair class*], [*n*], [*continuity*], [*null*], [*excess*], [*Wilcoxon p*],
  table.hline(stroke: 0.4pt),
  [child → child], [168], [0.31], [0.32], [−0.012], [0.6],
  [child → stem], [150], [0.32], [0.34], [−0.008], [0.34],
  [stem → child], [150], [0.35], [0.34], [+0.003], [0.82],
  table.hline(stroke: 0.6pt),
)

Within a single leg, across a point halfway along it, continuity is 0.40–0.49 against the same null of 0.34. The
kymographs themselves show straight streaks running through the node on some paths (`transfer/*kymo.npz`), so the
signal exists, but ten seconds of video is too short for either measure to separate it from noise. Child-to-child passage is therefore neither shown nor excluded.

The streak detector on path kymographs through each node (job 27045373, 56 371 streaks) does little better. On a
synthetic Y junction it catches about one in ten crossings, because the 75 px sampling lines overlap the other legs
within a few µm of the node. On the real junctions only about 0.1 % of moving streaks span a node:

#table(
  columns: (1.6fr, 1.2fr, 0.6fr, 0.8fr, 0.9fr), align: (left, left, center, center, center), stroke: none,
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*junction class (@sec-r-j9)*], [*path*], [*paths*], [*spanning*], [*moving*],
  table.hline(stroke: 0.4pt),
  [A: stem on the through-hypha], [straight stem–through], [38], [5], [7 122],
  [], [turning child–child], [38], [1], [7 194],
  [], [turning stem–side], [38], [1], [6 432],
  [C: no through-hypha], [turning stem–child], [50], [10], [7 575],
  [], [turning child–child], [25], [2], [4 132],
  table.hline(stroke: 0.6pt),
)

The direction is the one the loop model predicts: streaks carry on along the through-hypha and rarely turn into a
side branch or between children. But five against one is not a test, and a straight-line detector finds straight
paths easier. `junction_model_checks.py`, section 4.

== Widths measured from the raw frames show no stem/children bias, and the balance stays near 0.65 <sec-r-j7>

The raw-frame widths cover 229 of the 232 legs (73 junctions; Snellius job 27044083). Against the U-Net lumen width
used in the balance, the U-Net run along the measurement lines is 1.03 times as wide, halo-to-halo 1.12 (IQR
1.05–1.21) and dark-band-to-dark-band 0.66 (0.60–0.71). Each measure differs from the U-Net by a factor that is the
same on stem and children:

#table(
  columns: (1.6fr, 1fr, 1fr, 1fr), align: (left, center, center, center), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*median [95 % CI], 73 junctions*], [*U-Net run*], [*halo to halo*], [*dark band to dark band*],
  table.hline(stroke: 0.4pt),
  [width bias, stem ratio / children's ratio], [0.99 [0.99, 1.00]], [0.98 [0.96, 1.00]], [1.02 [0.98, 1.06]],
  [$w^2$, stem / sum of children], [0.65 [0.60, 0.67]], [0.61 [0.57, 0.64]], [0.64 [0.53, 0.72]],
  [$B$ (a), $tilde(v)_b w^2$], [0.69 [0.64, 0.73]], [0.65 [0.61, 0.70]], [0.64 [0.56, 0.77]],
  [$B$ (b), plug lanes], [0.68 [0.63, 0.70]], [0.63 [0.58, 0.68]], [0.64 [0.56, 0.74]],
  table.hline(stroke: 0.6pt),
)

The stem is no wider, relative to its U-Net width, than the children are. With either independent width the balance
drops slightly rather than rising, so a width bias is ruled out as the source of the shortfall. The overlays
(`junction_width_overlays.png`) show halo points on the hypha's outer edges and dark-band points inside the walls at
all 10 junctions. They also show why the stem's $w^2$ is small: in at least 3 of the 10, the stem is the narrower leg,
a thin branch meeting a wide hypha that runs straight through the junction. `junction_width_check.py`.

The dark bands mark the walls, so dark-band-to-dark-band is closer to the inner lumen than the U-Net. It still does
not bring the balance nearer 1: on the same 73 junctions, the median $|ln B|$ is 0.45 against 0.35 with the U-Net,
and it is closer to 1 at only 44 % of junctions. Subtracting a wall thickness from every width shrinks narrow
children more than a wide stem, but even 4 µm off a median of 6.5 µm raises $B$ only to 0.67 (a) or 0.77 (b).

== Only part of the lumen moves, and the same part in stem and children <sec-r-static>

What static share would close the balance? With the stem fully mobile, the children would need a static share of
$1 - B$: a median of 0.30 (IQR 0.20–0.48). If the stem is 10, 20 or 30 % static, the children need 37, 44 or 51 %. So
the question is whether children are more restricted than their stem.

Static streaks are the obvious proxy and point the right way. Children have more of them than the stem (7 % against
0.5 % below 0.3 µm/s; 10.5 % against 1.9 % below 1 µm/s), but correcting by that moves $B$ only from 0.705 to 0.74.
A count of static streaks cannot measure area, though. Static particles barely register in this pipeline: a true
static share of 0.2 was read as 0.5–1 % on synthetic videos (#link("lane_flux_balance.typ")[`lane_flux_balance.typ`], calibration).

The mobile area is measured directly from the raw video, on the same lines across each leg as the widths
(@sec-r-j7), with a motion variance per pixel,
$ V = "var"_t (I) - "var"_t (I(t + 1) - I(t)) slash 2 . $
Over frames spread through the video, the first term is noise plus the fluctuation of passing particles.
Consecutive frames share particle positions but not their noise, so the second term removes the noise. $V$ is about
zero outside the hypha and on static material, and high where particles move; on a synthetic check it reads −0.4 on
a static stripe and 415 in a moving band. The mobile width is the contiguous extent around the centre where $V$
exceeds a fraction of its peak. Widefield projection makes $V$ fall towards the walls even for uniform motion, since
the line of sight through the tube shortens, so the absolute value depends on that fraction; the comparison between
stem and children does not:

#table(
  columns: (1fr, 1fr, 1fr, 1.2fr, 1fr), align: (left, center, center, center, center), stroke: none,
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*threshold, fraction of peak $V$*], [*mobile width / lumen*], [*mobile area fraction*],
  [*stem / children (1.43 needed)*], [*corrected $B$*],
  table.hline(stroke: 0.4pt),
  [5 %], [0.81], [0.66], [1.11], [0.69],
  [10 %], [0.68], [0.47], [1.02], [0.67],
  [25 %], [0.44], [0.20], [1.00], [0.69],
  table.hline(stroke: 0.6pt),
)

Medians over 218 legs and 73 junctions. A substantial part of the lumen does not move, which matters for absolute
flux in the model. But stem and children are restricted alike, 1.00–1.11 against the 1.43 the balance needs, so a
static share does not close it. `raw_leg_widths.py` (job 27045273) and `junction_width_check.py`, which writes `leg_motion_extent.csv`.

== The stem's streams do not speed up to make up for its smaller area <sec-r-j8>

If flux were conserved stream by stream, the stem's streams would run 1.54 times as fast as the children's, the
inverse of its area ratio of 0.65. They run 1.06 times as fast (to root) and 1.02 times (to tip), on 70 junctions
with the shared-edge junctions removed. Across junctions the log-log slope of speed ratio on area ratio is +0.27
(95 % bootstrap interval +0.12 to +0.42) for the to-root stream and +0.24 (+0.03 to +0.39) for the to-tip stream,
against −1 for conservation. The stem is faster when it is relatively wide, not when it is relatively narrow: speed
follows each hypha's own width, as $w^(0.5)$ here and $w^(0.7)$ in the transport model's fit.

With speed set by width alone and nothing conserved, the widths predict the balance: $B = w_0^(2+k) slash sum_c
w_c^(2+k)$ gives a median of 0.69 at $k = 0.54$ and 0.71 at $k = 0.7$, against 0.71 measured (per-junction Spearman
0.72). This match shares the $w^2$ term with the measured balance, so it is a consequence of the slope above, not
independent support. `junction_model_checks.py`.

== Along a hypha that runs straight through, flux is continuous; a side branch's flux never reaches the stem <sec-r-j9>

#table(
  columns: (2fr, 0.5fr, 1.2fr, 0.8fr, 0.9fr, 0.9fr), align: (left, center, center, center, center, center),
  stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*junction geometry*], [*n*], [*$B$ median (IQR)*], [*$w^2$ ratio*], [*speed ratio*], [*straightest pair*],
  table.hline(stroke: 0.4pt),
  [A: stem continues into one child], [38], [0.72 (0.64–0.80)], [0.65], [1.12], [152°],
  [B: stem branches off a through-hypha], [3], [0.12 (0.10–0.13)], [0.22], [0.63], [148°],
  [C: no clear through-hypha], [25], [0.73 (0.51–0.85)], [0.67], [1.07], [145°],
  [D: four or more legs], [4], [0.36 (0.33–0.37)], [0.49], [0.72], [172°],
  table.hline(stroke: 0.6pt),
)

Class A is the common geometry: a side branch leaving a hypha that continues. There the stem balances the
straight-through child alone. Stem over through-child is 1.07 (IQR 0.90–1.20) for the to-root flux and 1.06
(1.00–1.15) for the to-tip flux, with the same width (1.03) and the same speed (1.00). The side branch carries 31 %
(0.22–0.38) of the children's to-root flux, which is the whole shortfall. None of it reaches the stem: carrying it
down the stem would need the stem's streams 1.45 times as fast, and they run 1.00 times as fast, in the same lane
shares (@sec-r-j2) and the same mobile area (@sec-r-static).

The other classes fit the same picture. In class B a thin stem meets a hypha that runs through, and $B$ is 0.12:
the branch's flux against both halves of the through-hypha. At four-way junctions (class D, mostly two hyphae
crossing) the stem's continuation is one child, and the crossing hypha's two halves count as children as well.
Class C, with no clear through-hypha, sits with class A at 0.73. `junction_model_checks.py`, `junction_class_a.csv`.

== Growth consumes volume beyond the main hypha, not beyond the side branch <sec-r-growth>

One reading of class A is that the through-hypha carries zero net flux while the side branch draws a net flux that
growth at its ends consumes. Growth demand per leg tests it. Over the 8 h after the flow session (4 imaging
sessions), the growth graph gives, for everything downstream of each leg, the volume of hypha that appears (tip
growth) and the change in volume of the hypha already there (diameter expansion, from the store's widths at both
ends of the window). Each is divided by the window and compared with the leg's stream flux,
$Q = phi dot pi slash 4 dot w^2 H(v_"tip", v_"root")$, with $phi = 1$ (the full lumen) or the leg's own mobile area
fraction (@sec-r-static):

#table(
  columns: (1fr, 1.1fr, 1.3fr, 1.3fr, 1.2fr), align: (left, center, center, center, center), stroke: none,
  inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*leg (38 class A junctions)*], [*any tip growth downstream*], [*tip growth / $Q$, full lumen (IQR)*],
  [*tip growth / $Q$, mobile area*], [*expansion / $Q$, full lumen*],
  table.hline(stroke: 0.4pt),
  [stem], [74 %], [0.10 (0.00–0.21)], [0.17], [0.003],
  [through-child], [71 %], [0.09 (0.00–0.18)], [0.16], [−0.001],
  [side branch], [21 %], [0.00 (0.00–0.00)], [0.00], [0.001],
  table.hline(stroke: 0.6pt),
)

Tip growth is the whole demand: diameter expansion stays within a few tenths of a percent of the stream flux either
way, inside the noise of widths measured at two timepoints. Together they are 0.09 of the through-child's stream flux
(0.15 on its mobile area), about 2.8 tips' worth of growth at 240 µm/h, and 0.001 of the side branch's. Side
branches are mostly not growing: 79 % have no new hypha downstream in the 8 h. So growth cannot account for the side
branch's missing flux, 0.31 of the children's return, and the side-branch-consumption reading fails. Growth predicts
the reverse: a net tipward flux of about a tenth of the stream flux along the main hypha, which the stem-to-through
ratios (1.06 and 1.07, IQR about ±0.15) cannot resolve. `junction_growth_demand.py`.

== Lipid hand-over into a side branch is small against the lipid it circulates <sec-r-lipid>

The loop model concerns volume. If motors handed lipid cargo over at the branch point while the volume loops locally,
lipid flux would be conserved where volume flux is not. The fluorescence videos test it. 92 store junctions have one
fluorescence video with a to-tip lipid stream (at least 5 moving streaks) on every leg, classified by geometry from
the store's own node positions. Per leg, the lipid line density $lambda$ is the background-subtracted fluorescence
integrated across the hypha in the time-mean frame, 12–40 µm from the node (`snellius/lipid_leg_intensity.py`; a
synthetic check recovers amplitude × width within 3 %). The lipid to-tip flux is
$J = lambda dot f_"tip" dot v_"tip"$, with $f_"tip"$ the to-tip share of the leg's moving fluorescence streaks and
$v_"tip"$ their median speed. 66 of the 92 fluorescence videos were restored from the archive for this
(`snellius/fluo_restore.py`, job 27047381; each matched to its flow run by its own metadata timestamp).

#table(
  columns: (2fr, 1.3fr), align: (left, center), stroke: none, inset: (x: 6pt, y: 3.5pt),
  table.hline(stroke: 0.6pt),
  [*class A, 67 junctions on five plates*], [*median [95 % CI] or (IQR)*],
  table.hline(stroke: 0.4pt),
  [lipid density, stem / through-child], [1.05 (0.87–1.25)],
  [lipid density, side branch / through-child], [0.57 (0.37–0.79)],
  [lipid to-tip flux, stem / through-child], [1.02 [0.92, 1.23]],
  [side branch's share of the children's lipid flux], [0.33 [0.31, 0.36]],
  [lipid balance, stem / sum of children], [0.70 [0.64, 0.78]],
  [the same with area $w^2$ in place of $lambda$], [0.59 (0.53–0.67)],
  [random stem], [0.53],
  table.hline(stroke: 0.6pt),
)

The stem carries as much lipid as the through-child, and the lipid balance, 0.70, equals the volume balance
(@sec-r-w2). A hand-over must exist: side branches grow from lipid delivered through the main hypha. What the data
bound is its size. The side branch carries 0.33 of the children's lipid flux, 0.49 times the through-child's, so if a
fraction $h$ of it comes through the stem, stem over through-child is $1 + 0.49 h$. The measured 1.02 gives
$h approx 0.04$; the upper end of its interval, 1.23, allows $h$ up to 0.47. Most of a side branch's to-tip lipid is
therefore its own return turned round, and the hand-over is a minority of it, small at the median and at most about
half. The lipid signal is dim, 20 frames of weak fluorescence, and clipping background-subtracted profiles at zero
inflates the dimmest legs, the side branches; both widen the bound rather than move the median, since stem and
through-child are alike in width and brightness.

The plates differ. On STR2307A112 (31 junctions) and LPD2412A025 (11) the stem carries 1.20 and 1.33 times the
through-child's lipid flux and the balance is 0.78 and 0.76, so part of the side branch's lipid may come through the
stem there. On EPY2412A088 (18) and PNF2307A072 (6) the stem carries 0.92 and 0.81 times as much and the balance is
0.57 and 0.48. STR2307A112 is the one plate of strain A5. `junction_lipid_test.py`.

If lipid were handed over only where a side branch needs it, the stem's excess over the through-child would follow
the side branch's growth demand (@sec-r-growth, computed for each lipid junction's side leg). It does not measurably:
Spearman +0.13 (p 0.29, 67 junctions). Where the side branch grows (29) the stem carries 1.14 times the
through-child's lipid flux (IQR 0.78–1.55), where it does not (38) 0.99 (0.82–1.40), Mann–Whitney p 0.57. The test
is weak by construction: a growing side branch needs a median 9.3 µm³/s against about 129 µm³/s in the through-hypha,
so supply matched to growth would raise the ratio by about 7 % against a spread of ±30 %. By plate the link holds
only half: LPD2412A025 has the most growing side branches (73 %) and the largest excess (1.33), STR2307A112 a similar
excess (1.20) with few growing side branches (35 %) and little demand. So a full hand-over is excluded, and a hand-over sized to growth is below what these videos resolve. Requiring moving lipid on every leg also selects active side
branches: 43 % of them grow here, against 21 % in the brightfield set. `junction_lipid_test.py --demand-test`.

= Discussion <sec-discussion>

At 70 junctions filmed whole, the to-root flux leaving through the stem is about 0.73 of what the children bring in,
and the to-tip stream is short by the same factor (@sec-r-w2). No flux formula, width measure, static cut, stem choice
or static share closes it (@sec-r-j3, @sec-r-j7, @sec-r-static, @sec-deadends). The stem's streams run at the speed
its own width sets and do not speed up for the flux they would have to carry (@sec-r-j8). Where a hypha runs straight
through the junction, flux along it is continuous, and the side branch's flux is the whole shortfall (@sec-r-j9). Side branches barely grow, so growth cannot take
that flux (@sec-r-growth). Lipid balances like the volume (0.70 on five plates), which bounds the lipid handed into side
branches to a minority of what they circulate (@sec-r-lipid).
Whether flow passes between legs at the node could not be shown with ten-second videos (@sec-r-j6). Only 1 junction
is strictly tree-like, so every result rests on junctions with loops of 3 mm or more.

== A model: every branch is its own conveyor loop

The results fit one picture. Each hypha carries two plug lanes, tipward and rootward, with zero net volume flux
(@sec-m-general). Their speeds are set by the hypha itself, rising with its width, and not by the junctions it meets.
Leg $i$ then carries a stream flux
$ Q_i approx phi A_i H(v_(m,i), v_(b,i)) prop w_i^(2 + k), quad k approx 0.5 "–" 0.7 , $
with the same mobile fraction $phi$ in every leg. Along an unbranched hypha nothing changes, so the belt is
continuous, as it is through class A junctions. A side branch cannot put its flux into the parent: the parent's speed
does not rise and its area is fixed. So the branch's return turns back into a tipward stream at the branch point, and
the branch runs as a closed loop of its own. Total volume still balances at the node, because every leg is net zero.
The exchange is $X = sum_c Q_(b,c) - Q_(b,0)$, about 30 % of the children's return, and in class A it equals the
side branch's own flux.

What the model does not say is where the side branch's return turns. It may turn within the branch, lane to lane,
or join the through-hypha's tipward stream while an equal part of the through-hypha's return enters the branch.
Class A's to-tip ratio of 1.06 leaves room for either. Material being rerouted at a branch point independently of
bulk flow direction has a precedent: nuclei are actively redirected at the branch points of an oomycete
@evangelistiHydrodynamicShapeChanges2019. Growth does not decide it: side branches are mostly not
growing, so their loop consumes nothing, and the demand sits on the main hypha at about a tenth of its stream flux
(@sec-r-growth). Two predictions separate the model from stream conservation:

- *Streaks at the node.* The straight stem-to-through path carries continuous streaks; a turning path into a side
  branch carries few (J6, streak version).
- *Lipids.* The model concerns volume. Lipid has to reach a side branch through the main hypha, so a hand-over at
  the branch point exists; the question is its size. Over five plates the lipid balance is 0.70, the same as the
  volume's, which puts the hand-over at about 4 % of the side branch's circulating lipid flux at the median and
  below about half at the upper bound (@sec-r-lipid). That is a much weaker claim than the one for water: it rests on
  one dim fluorescence measurement, where the water recirculation rests on speeds, widths, mobile area and growth.

For the transport model this replaces "return flux adds up towards the root at junctions" (Fig 4F) with "each branch
circulates its own volume, and water recirculates at junctions; lipid enters a side branch as a minority of what it
circulates, and net delivery follows growth along the main hypha". It also puts the backflow on a leg down to that leg's
width and motor speed, not to the demand downstream of it. That agrees with
#link("lane_flux_balance.typ")[the lane study], where backflow follows the forward speed measured beside it.
#link("loop_circulation_global_model.typ")[The loop circulation document] finds the same picture on
loops: the measured steady-state flows carry none of the global model's loop circulation, so loops exchange little;
the junction balance alone cannot separate global from local routing.

== Two strictly tree-like junctions leave the tree-like verdict resting on a proxy

Two strictly tree-like junctions cannot carry a verdict, so the tree-like results rest on a geometric proxy: no loop
shorter than 3 mm through any leg. A long loop can still carry circulation, and the proxy ignores how the motor
streams around it balance. The shortfall does not change between the proxy set and all junctions (@sec-r-j3), which
argues against circulation, but it does not replace a strict tree-like test.

== Is five streaks per stream enough for a per-leg speed ratio?

@eq-flux-zero uses both streams' speeds on every leg, so its noise is larger than the width-squared balance's. The
comparison between formulas is within junctions and shares that noise, but the random-stem null has to be computed
for each formula separately.

== Growth-graph stem errors move the median balance by only 0.02

The stem is the leg growth arrives along in the store's growth graph. Growth-direction errors swap stem and child.
The stem check (@sec-deadends) puts their effect at 0.02 on the median. The 20 junctions with a narrower stem
are where such errors would sit, but part of that subset is geometry, not error: in classes B and D a low balance is
what the loop model predicts (@sec-r-j9).

= What didn't work <sec-deadends>

== No power of the width closes the balance #dead

With $Q = tilde(v) w^n$ the rootward balance is 0.58 at $n = 0$, 0.65 at 1, 0.73 at 2, 0.81 at 3 and 0.87 at 4. It
reaches 1 only at $n approx 8$ (7.5 for the tipward stream). A stream area that scales as any plausible power of the
hypha's width cannot explain the shortfall. At $n = 0$ the ratio is the stem's speed over the sum of two children's,
1.14 over 2.

== Slow streaks do not carry the missing flux #dead

Lowering the static cut from 1 µm/s to 0.5 and 0.3 µm/s leaves the rootward balance at 0.73, 0.72 and 0.76 (70, 72 and 74
junctions); the width-squared term stays at 0.66–0.67. Streaks between 0.3 and 1 µm/s are too few to move the leg
medians, and they are no more common on the children than on the stem. Flow below 0.3 µm/s is flagged static by the
detector and remains untested. A separate threshold sweep on 38 kymographs (`streak_stability.py`) found that lowering
the brightfield detection threshold mostly adds texture noise, so the detector is not the missing flux either.

== The stem is not the wrong leg #dead

A random stem gives a rootward balance of 0.51 (95 % of 2000 draws 0.42–0.61) against 0.73 for the growth-graph stem,
and the other legs as stem give 0.38. At the 68 junctions with a single stem, the chosen stem is the leg closest to
balance at 68 %, against 33 % by chance. Restricted to the 48 junctions where the stem is also the widest leg, the
balance is 0.75 (IQR 0.66–0.91) with $w^2$ at 0.69. The 20 junctions with a narrower stem sit at 0.55 and lower the
overall median only from 0.75 to 0.73 (`unet_junction_balance_all.py`, `unet_junction_stem_check.csv`).
The stem choice is informative and not the source of the shortfall.

== Frame differences do not show where particles move #dead

The J7 job also measured a moving-band width: the full width at half maximum of the mean absolute difference between
consecutive frames across the hypha. The difference is lower inside the hypha than outside, not higher: it is
dominated by shot noise, which scales with brightness, and the hypha is darker than the background. Particle motion
between consecutive frames is too small to stand out, so the median band came out at about 1.3 µm on hyphae 8–10 µm
wide. The measure was dropped. The moving cross-section is measured instead with a noise-corrected motion variance (@sec-r-static).

== Correlation through the node, at the best or the measured speed #dead

J6's first measure correlated positions on two legs at the travel time through the node. Taking the maximum over a
speed grid, every pair class, within-leg references included, peaked at the same slowest speed with $T approx 1$:
noise at the longest lags, which leave about 60 overlapping frames in a 200-frame video. Its circular-shift null
needs a 20 s shift and existed for only 36 of 480 pairs. At the measured leg speeds the correlation falls to 0.01–0.1,
because streaks 1–2 µm wide decorrelate over 10 µm when speeds spread by a factor of 1.4. Any variant that correlates
fixed positions needs longer records.

= Actionable Items <sec-actions>

== Compendium handoff

- The model's junction rule (Fig 4F, backflow Kirchhoff) is contradicted for volume: the to-root stream closes to
  about 0.7 (@sec-r-j3), and in class A junctions the side branch's flux never reaches the stem (@sec-r-j9). Fig 4F should show each branch circulating its own volume, or be dropped; the lipid hand-over is bounded, not
  measured.
- Only about half the lumen moves (@sec-r-static). Absolute stream fluxes computed from the full cross-section are
  about twice too large; this bears on the "under 1 % of motor flux consumed at the tip" statement (issue \#80).
- The sheared-core rejection (@sec-r-j1) is a second, independent argument against the core geometry in
  #link("https://github.com/Staalduine/rhizosphere/blob/main/findings/annulus_geometry_from_two_channels.typ")[`findings/annulus_geometry_from_two_channels.typ`], beside the radial profiles.

== Open
- #open Plate differences in the lipid test: STR2307A112 and LPD2412A025 show a stem carrying more lipid than the
  through-child (1.20, 1.33), EPY2412A088 and PNF2307A072 do not. Strain, age or session?
- #open J4 needs downstream growth per leg from the growth graph; J5 reuses it. Both are now secondary: @eq-growth-bias
  and @sec-r-j2 bound their effect well below the shortfall.
- #open J6 needs longer records: the correlation and streak versions both run out of signal in ten seconds. Only
  7 of the 72 videos are 600 frames long.
- #open Rerun @sec-r-j7 to @sec-r-lipid on the growth-graph stems and the 70 junctions, or point each to its
  counterpart in `transport_paper/Notes/conveyor_junctions.typ`.

= Appendix <sec-appendix>

== Reproducing this <app-repro>

`transport_paper/Working_notebooks/unet_junction_balance_all.py` builds the leg and balance tables from the U-Net
rerun (graphs, streak tables and `lumen_widths.csv` under `fig_outputs/unet_videos/`), and prints the width-power
sweep and the stem check. `UNET_MIN_SPEED` sets the static cut. Outputs go to `fig_outputs/video_junctions/`: `unet_junction_legs_all*.csv`, `unet_junction_balance_all*.csv`,
`unet_junction_stem_check.csv`. `junction_flux_tests.py` runs J0–J3 from those tables and the streak tables and writes
`junction_flux_legs.csv` and `junction_flux_j3.csv`; its figures go to `Notes/figures/junction_flux/`.
`junction_width_check.py` runs J7 from the raw-frame widths in `fig_outputs/unet_videos/raw_widths/` and writes
`junction_width_check.csv` and `junction_width_overlays.png`.

== Provenance <app-provenance>

#table(
  columns: (auto, 1fr), align: (left, left), stroke: none, inset: (x: 6pt, y: 3pt),
  table.hline(stroke: 0.6pt),
  [Snellius 27029651], [wall U-Net over 309 junction videos (24-task array, fat_rome); 307 succeeded],
  [Snellius 27033747], [the two STR2307A112 failures, rerun with flow_analysis_comps master (short-edge fix, PR \#55)],
  [Snellius 27034024], [lumen widths; its plate/uuid columns are shifted by one, joined on plate + run instead],
  [Snellius 27044083], [raw-frame leg widths (`snellius/raw_leg_widths.py`), 72 videos, 221 distinct legs],
    [Snellius 27047381, 27055694], [66 fluorescence videos restored from migration-data (`snellius/fluo_restore.py`)
  to `scratch_unet_junctions/fluo_restore/`, outside the production tree; their lipid densities],
  [Snellius 27044590, 27044698], [J6 leg kymographs from each junction node (`snellius/junction_transfer.py`); the
  second saves the kymographs],
  [transport_paper\@d42d483], [every script named in this document, on branch `feat/model-net-flux`],
  table.hline(stroke: 0.6pt),
)

== References

#bibliography("references.bib", title: none, style: "apa")
