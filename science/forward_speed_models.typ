// finding: open
// ---------------------------------------------------------------------------
// Canonical write-up preamble, inlined so this document stands alone.
// ---------------------------------------------------------------------------

#set document(
  title: "Forward speed models — what sets the speed of the tipward stream, scored on the same edges",
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

#let fig(path, cap, src: none, width: 100%) = figure(
  image(path, width: width),
  caption: text(8.5pt, fill: luma(95))[
    #cap
    #if src != none [ #text(fill: luma(140))[#raw(src)]]
  ],
)
#show figure.caption: set align(left)
#show figure: set block(breakable: false)

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

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Forward speed models]
  #v(-0.3em)
  #text(14pt, weight: 600)[What sets the speed of the tipward stream, scored on the same edges]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · every model scored on 1,503 filmed hypha segments over 15 video sessions on 5 plates, and on the 873 whose inner width was measured on video; fluorescence on 1,365 segments; one network solve per coupling ·
    master \@801bd33, lumen widths from the walls_v4 rerun of 11 Oct; measured speeds count every streak the detector calls moving, with no static cut beyond its own 0.3 µm/s
  ]
]
#v(1.2em)

#outline(depth: 2, indent: 1em)

= Introduction <sec-intro>

#question[Inside a hypha, material moves toward the growing tip at a few µm/s, carried by motors. What sets that speed on a given hypha: nothing (one speed everywhere), the distance to the nearest growing tip, the hypha's width, the growth it supplies, or a balance between the motors' force and the drag of the stream returning past them? And how many fitted numbers does each answer cost?]

We image a growing colony of _Rhizophagus irregularis_ over days, stitch and segment each timepoint into a network graph, and film short brightfield videos at fixed positions. Kymographs from those videos give, per hypha segment (an edge of the graph), the speed of the stream moving toward the tip and of the stream moving back toward the colony's origin. The transport model needs the tipward speed on every edge of the network, including the vast majority that were never filmed, so it has to predict it from what the graph knows.

This document puts every candidate rule for that speed on one footing: the same 1,503 filmed edges, the same target, each model fitted on four plates and scored on the fifth. The short answers:

- Width orders the edges and tip distance does not, except within about 1 mm of a tip, where tip distance sets the level and width does not.
- The force-balance motor model, scored on the tipward stream alone, is a two-parameter law in width. A plain power law in width scores the same.
- On the tipward stream, tip distance and width together, four fitted numbers, match the force model with no force in it, and order edges better than width alone.
- No model states the measured spread of speeds. The best cover about 0.7 of it, a constant covers 0.07.
- The rule the solver runs today saturates at 3.10 µm/s. It reaches the measured level, but its within-plate rank is 0.18–0.22, against 0.50 for width alone and 0.58 for width with tip distance.
- The lipid (fluorescence) stream slows near tips as the brightfield stream does, and tip distance ranks it better than it ranks brightfield.
- Within plates, a width term in the solver's motor speed lifts the returning stream's rank on tree edges as much as force motors do. Pooled over plates, one plate whose narrow hyphae carry the fastest returns undoes it. Force motors add beyond width on loop edges and in tracking.

= Motivation <sec-motivation>

The transport model's tipward speed is the motor speed of every edge. It sets the motor flux, and through zero net flux it sets the returning stream too (#link("lane_flux_balance.typ")[the lane flux balance document]). Since 24 Sep the solver runs one rule for it: the offset tip throttle, which depends only on the distance to the nearest growing tip and saturates at 3.10 µm/s a few millimetres back. transport_paper\#72 records the consequence: the modelled tipward speed is a narrow band, while measured tipward speeds spread from under 2 to over 3.5 µm/s, and no model of the returning stream can order edges whose motor speed is the same.

Three earlier analyses each scored part of the answer, on different edge sets, with different targets and different held-out splits. The tip-distance fits were held out by store on up to 1,547 edges. The force-balance motor model was fitted to the returning stream, held out by plate, on 874 edges. The demand-dependent throttle was held out by session on 1,116 edges. None of them scored a constant on the edges the force model used, and none of them reported how many numbers each model fits or how wide a range of speeds it can produce. transport_paper\#132 asks the tip-distance part again, per channel and held out, and adds a step.

What depends on the answer: whether the solver's motor speed should carry a width term; whether the force-balance model earns a place in the paper's Methods or stays in reserve; and whether the motor constants printed in #link("throttled_core_speed_model.typ")[the throttled core-speed document] (the old exponential fit, 2.87 µm/s and 749 µm) need replacing.

= Method <sec-method>

== Eleven models: a constant, tip-distance shapes, demand, width and a force balance <sec-models>

Every model predicts the tipward speed $v$ of an edge from what the network graph knows about it: the distance $d$ to the nearest growing tip, the edge's radius $b$, and the lipid demand $q$ the solver routes through it. Speeds are in µm/s, distances and radii in µm.

=== A constant and four tip-distance shapes test whether the stream slows toward tips

- Constant: $v = c$.
- Exponential: $v = v_0 (1 - e^(-d\/lambda))$. Forces the speed to zero at a tip. This was the solver's rule until 18 Sep.
- Offset: $v = v_infinity - (v_infinity - v_"tip") e^(-d\/lambda)$. A floor $v_"tip"$ at the tip, saturating at $v_infinity$ far from it.
- Step: $v = v_"near"$ for $d < d_0$, $v_"far"$ beyond. Asked for in transport_paper\#132 as the bluntest falloff.
- Offset as run: the offset shape with the constants the solver uses now, $v_infinity = 3.096$, $v_"tip" = 2.140$, $lambda = 1711$ µm, fitted on 25 Sep to 1,054 edges over 12 sessions. Nothing is fitted here, and those 12 sessions include these plates, so this row is the only one that is not held out.

=== Demand and width each add a second cause

- Offset + demand: the offset shape times $g_0 + (1 - g_0)(1 - e^(-q\/Q))$, a saturating factor in the demand an edge serves, with floor $g_0$. This was the solver's `--demand-throttle` until it was removed on 24 Sep.
- Width power law: $v = c b^beta$. The control for the force model below: width, with no mechanism.
- Offset × width: the offset shape times $(b\/5 "µm")^beta$, so $v_infinity$ and $v_"tip"$ keep their meaning at a 5 µm radius.

=== Force-balance motors set the speed from the drag of the returning stream

The force model (`force_motor_model.py`) treats the motors as a force, not an imposed speed. A motor lane occupying a share $phi$ of the cross-section moves as a plug at $v$ toward the tip. The rest of the cross-section carries the same volume back as Stokes flow. Per unit length, the motors' force, falling linearly with speed from an unloaded speed $v_max$, balances the viscous drag of that returning flow on the lane plus a wall friction:

$ k b^m M(phi) (1 - v\/v_max) = v [C(phi)\/(8 pi) + z] $ <eq-force>

$C(phi)$ is the lane's drag per unit viscosity and speed. It is computed once by finite differences on a unit disk (`lane_drag.py`) and has no free parameter, because Stokes flow is scale-free. $M(phi) b^m$ counts the motors. The network runs use the side-wall geometry, a lane along one wall with its motors along that wall's arc, so $m = 1$ and $M$ is the lane's share of the perimeter. The forward use fixes one lane share $phi_0$ everywhere and solves @eq-force for $v$:

$ v = v_max K b \/ (K b + v_max), quad K = k M(phi_0) \/ (C(phi_0)\/(8 pi) + z) $ <eq-forward>

The returning stream's speed is then $v phi_0 \/ (1 - phi_0)$. Three variants are scored:

- Force: @eq-forward with $k$, $v_max$, $z$ and $phi_0$ fitted jointly on both streams, the squared log error of each, as the earlier runs did.
- Force × throttle: the same, times the offset-as-run shape $|v_0|\/v_infinity$. This is the motor speed the network runs on physical inputs used (`C_f0.8m`).
- Force, to tip: @eq-forward fitted on the tipward stream alone, which leaves exactly two parameters, $v_max$ and $K$ (@sec-dof).

== Fitted counts mislead: the force model's four numbers act as two <sec-dof>

The nominal count overstates some models and understates others. @tab-dof gives, per model, what is fitted on the four training plates, what is fixed elsewhere and how, and the range each fitted number takes over the five folds.

#figure(
  table(
    columns: (auto, auto, 1fr, 1.25fr),
    align: (left, center, left, left),
    stroke: 0.4pt + luma(200),
    inset: 4pt,
    table.header([*model*], [*fitted*], [*how the numbers are obtained*], [*range over folds, lumen edges*]),
    [constant], [1], [geometric mean of the training speeds], [2.66–2.81],
    [exponential], [2], [least squares on log speed], [$v_0$ 2.68–2.84, $lambda$ 135–345 µm],
    [offset], [3], [least squares on log speed], [$v_infinity$ 2.75–2.98, $v_"tip"$ 1.99–2.09, $lambda$ 803–1,782 µm],
    [step], [3], [log-mean each side of $d_0$, $d_0$ on a grid of 95 distance quantiles], [$v_"near"$ 2.21–2.58, $v_"far"$ 2.71–2.92, $d_0$ 910–2,740 µm],
    [offset as run], [0], [3 constants fitted on 12 sessions that include these plates; not held out], [3.096, 2.140, 1,711 µm],
    [offset + demand], [5], [least squares on log speed], [$g_0$ 0.73–0.78, $Q$ 1.1–5.0, $lambda$ 770–5,180 µm],
    [width power law], [2], [least squares on log speed], [$c$ 1.22–1.32, $beta$ 0.51–0.56],
    [offset × width], [4], [least squares on log speed; reference radius 5 µm fixed], [$beta$ 0.49–0.56, $lambda$ 1,100–1,890 µm],
    [force], [4], [joint fit on both streams; geometry, $m$ and $C(phi)$ fixed beforehand], [$k$ 9.4–24.9, $v_max$ 13.8–15 (cap), $z$ 0.40–10.3, $phi_0$ 0.54–0.56],
    [force × throttle], [4 (+3)], [as force; the throttle's 3 constants fixed from offset as run], [$k$ 10.0–26.5, $v_max$ 12.1–15 (cap), $z$ 0.31–9.6],
    [force, to tip], [2], [least squares on log tipward speed], [$v_max$ 5.4–6.0, $K$ 1.22–1.33],
  ),
  caption: text(8.5pt, fill: luma(95))[Degrees of freedom per model. "Fitted" counts the numbers fitted on the training plates of each fold. Ranges are over the five held-out folds on the 873 lumen edges; the all-edges ranges are in the Appendix (@sec-app-params). Caps: $v_max$ 15 µm/s, $z$ 20. #text(fill: luma(140))[#raw("forward_speed_compare.py")]],
) <tab-dof>

Three things in the table change how the models compare.

The force model fits four numbers but the tipward speed sees two. In @eq-forward, $k$, $z$ and $phi_0$ enter only through $K$. Fitted on the tipward stream alone, @eq-force is the two-parameter saturating law "force, to tip". The joint fit pins $phi_0$ at 0.54–0.56 because the returning stream's speed is $v phi_0\/(1 - phi_0)$, so $phi_0$ is set by the ratio of the two streams, not by the tipward speed. $k$ and $z$ are not identified: over the folds $k$ ranges 2.6-fold on the lumen edges and 3.1-fold over all edges, and $z$ runs from 0.40 to 10.3 and from 0 to 8.1. Only their combination in $K$ is constrained. Before any number is fitted, the force model also spends discrete choices that the table does not count: the lane geometry (four were tried), the motor-count exponent $m$ (fixed by geometry; a sweep in `force_width_law.py` picked 0.75), and the linear force–velocity law.

Offset as run spends its three numbers elsewhere. They were fitted on 12 sessions that include the five plates scored here, so its level is fitted on the test data. Its bias of 1.00 is not comparable with the held-out models' 0.92–0.99.

The exponential's fitted $lambda$, 135–345 µm, is much shorter than the 749 µm of the earlier store-held-out fit. On these edges the fit trades the near-tip edges against the far majority and collapses toward a constant.

== How the models are tested <sec-test>

+ One edge set and one target. The edges are the brightfield streak edges of the conveyor runs on physical inputs (`model_grid/raw/C_f0.8`) with both streams measured: 1,503 edges over 15 sessions on 5 plates. The target is the edge's median measured tipward speed, counting every streak the streak detector calls moving: no static cut is applied beyond the detector's own 0.3 µm/s (the tables were rebuilt without the former 1 µm/s cut on 1 Oct). This is the force model's own edge set, which is what lets it be compared with the others at all.
+ Held out by plate. Each model is fitted on four plates and predicts the fifth, five folds. Plate is the strictest split available: sessions of one plate share a colony and an imaging setup.
+ Two width sources, because the force model needs a radius. On the 873 edges with a video lumen width, $b$ is the lumen radius. On all 1,503, $b$ is 0.82 × the radius the segmentation gives (the median ratio of lumen to segmented width, transport_paper\#73), as in the network runs. Every width-using model gets the same $b$.
+ A near-tip subset scored from the same predictions. The edges within 1 mm of a tip, 122 over 12 sessions on all 5 plates (50 with a lumen width), are scored again without refitting. Over all edges they are 8 % of the set, so an all-edge score cannot see them.
+ Two controls. Tip distance is recovered by inverting the as-run offset throttle from the tables' modelled tipward speed; against the graph's own tip distance it agrees at Spearman 0.993 with a median difference of 100 µm (1,499 of 1,503 edges matched). And the between-plate share of the variance of log speed is 4.7 % (7.3 % between sessions), so a held-out plate does not differ from the training plates by more than the scores can resolve.

== Within 2×, fold-change error, bias, rank and range each mislead differently <sec-metrics>

All scores compare a held-out prediction $hat(v)$ with the measured speed $v$ on the same edge. Predictions are floored at 0.1 µm/s before scoring, which only touches the exponential at $d = 0$.

/ Within 2×: the share of edges with $1\/2 <= hat(v)\/v <= 2$. It lies here by saturating: measured tipward speeds sit between 1.6 and 3.7 µm/s for 90 % of edges, so any prediction near 2.7 µm/s is within 2× of almost all of them.
/ Fold-change error and bias: $exp("median" |ln(hat(v)\/v)|)$ and $exp("median" ln(hat(v)\/v))$. Fold-change error 1.15 means the typical edge is off by 15 %; bias above 1 means over-prediction. A model can have low fold-change error by sitting at the median of a narrow distribution, which is why it is reported beside rank and span.
/ Within-plate rank: the Spearman correlation of $hat(v)$ with $v$ inside each plate, median over plates, taken as monotone. Pooled over plates, a held-out constant has a non-zero correlation, $-0.29$, because each plate gets a different constant. Within a plate it has none, and is left blank.
/ Span: the 5th to 95th percentile of the predictions against that of the measured speeds; the ratio of the standard deviation of $ln hat(v)$ to that of $ln v$ (span ratio, 1 for a model as spread as the data); and the share of measured speeds inside the model's own 1st to 99th percentile (coverage). Span says what a model can state, not whether it states it on the right edge; a model with random predictions of the right spread scores 1 on span ratio and 0 on rank.
/ Extremes reached: the share of the measured fastest quarter for which $hat(v) >= v\/1.25$, and of the slowest quarter for which $hat(v) <= 1.25 v$. A constant near the median reaches neither.
/ Partial rank correlation: how strongly measured speed follows one variable, lumen width or tip distance, once the other is held fixed. Speed, lumen width and tip distance are each replaced by their rank within the plate, as a fraction of that plate's edges. The rank of speed and the rank of the variable of interest are each regressed linearly on the rank of the controlled variable, and the Pearson correlation of the two residuals is taken over all plates pooled. It is computed on measured values, not on model predictions, and removes only a linear dependence between ranks, so a strongly curved relation with the controlled variable leaks through.

= Results <sec-results>

== Within 2× cannot separate the models: even a constant scores 96 % <sec-saturated>

@tab-main gives the scores on both edge sets. Every model, the constant included, is within 2× on 96–97 % of edges, and fold-change errors run 1.10–1.17. Over all edges the models differ in rank and span, not in level.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto, auto),
    align: (left, center, right, right, right, right, right, right),
    stroke: 0.4pt + luma(200),
    inset: 3.5pt,
    table.header([*model*], [*fitted*], [*within 2×*], [*fold*], [*bias*], [*rank*], [*span ratio*], [*coverage*]),
    table.cell(colspan: 8)[_873 lumen edges, lumen radius_],
    [constant], [1], [0.96], [1.17], [0.93], [–], [0.07], [0.06],
    [exponential], [2], [0.96], [1.16], [0.92], [0.20], [0.68], [0.39],
    [offset], [3], [0.96], [1.15], [0.93], [0.22], [0.19], [0.35],
    [step], [3], [0.96], [1.16], [0.93], [0.14], [0.15], [0.26],
    [offset as run], [0], [0.96], [1.10], [1.00], [0.22], [0.23], [0.45],
    [offset + demand], [5], [0.96], [1.15], [0.97], [0.36], [0.35], [0.66],
    [width power law], [2], [0.97], [1.13], [0.97], [0.50], [0.45], [0.79],
    [offset × width], [4], [0.97], [1.13], [0.97], [0.58], [0.47], [0.81],
    [force], [4], [0.97], [1.13], [0.99], [0.50], [0.70], [0.92],
    [force × throttle], [4 (+3)], [0.97], [1.14], [0.99], [0.58], [0.74], [0.92],
    [force, to tip], [2], [0.97], [1.13], [0.97], [0.50], [0.45], [0.78],
    table.cell(colspan: 8)[_1,503 edges, 0.82 × segmented radius_],
    [constant], [1], [0.97], [1.17], [0.93], [–], [0.07], [0.08],
    [offset], [3], [0.97], [1.14], [0.94], [0.18], [0.22], [0.39],
    [offset as run], [0], [0.97], [1.10], [1.00], [0.18], [0.26], [0.46],
    [offset + demand], [5], [0.97], [1.13], [0.96], [0.38], [0.33], [0.68],
    [width power law], [2], [0.97], [1.16], [0.96], [0.34], [0.32], [0.59],
    [offset × width], [4], [0.97], [1.14], [0.97], [0.35], [0.36], [0.69],
    [force × throttle], [4 (+3)], [0.97], [1.14], [0.97], [0.37], [0.50], [0.82],
  ),
  caption: text(8.5pt, fill: luma(95))[Held-out scores on the tipward stream. Rank is the within-plate Spearman correlation, median over 5 plates; span ratio and coverage as defined in @sec-metrics. Offset as run is not held out (@sec-dof). Rows omitted from the second block, and the extremes reached, are in @sec-app-tables. #text(fill: luma(140))[#raw("forward_speed_compare.py → fig_outputs/forward_speed_compare/scores.csv")]],
) <tab-main>

@fig-mvm shows the same thing edge by edge, and what separates the models instead. Every model's cloud lies almost entirely inside the 2× band. The models that use only tip distance collapse into a vertical band: the held-out offset predicts 2.45–2.98 µm/s (5th to 95th percentile) for edges whose measured speeds span 1.60–3.74 µm/s. The models that use width spread their predictions along the 1:1 line, with the slowest edges still predicted too fast.

#fig("figures/forward_speed_models_measured_vs_modelled.png", [Measured tipward speed against held-out modelled tipward speed, one dot per edge, on the 873 lumen edges, log–log axes, colour by plate. Each model is fitted on four plates and predicts the fifth, except offset as run, whose constants are fixed (@sec-dof). Black line: 1:1. Grey band: within 2×. In the panel names, tip distance (offset) is the offset, solver as run is offset as run, tip distance x width is offset × width and force motors x throttle is force × throttle. The 19 edges measured outside 1–6 µm/s are off the axes.], src: "forward_speed_figures.py") <fig-mvm>

== Away from tips, width ranks edges by speed and tip distance does not <sec-width>

The models split into two groups by within-plate rank (@tab-main, @fig-compare b). Those that use only tip distance (exponential, offset, step, offset as run) order the lumen edges at 0.14–0.22. Those that use width alone (width power law, force, force to tip) order them at 0.50, and the two that combine width with tip distance (offset × width, force × throttle) at 0.58. Adding demand to the offset shape gives 0.36, between the tip-distance and width groups.

@fig-pd shows where the split comes from. Binned by lumen radius (@fig-pd b), the two offset models predict the same speed in every bin while measured speed rises across the whole range, and the width models rise with it. Binned by tip distance (@fig-pd a), the width power law also rises away from tips, because on two plates the hyphae near tips are narrower, but less steeply than measured speed, so it stays above the measured speed in the bins nearest a tip. That is the near-tip over-prediction of @sec-near. The models with both terms follow measured speed on both axes.

#fig("figures/forward_speed_models_partial_dependence.png", [Bin medians of held-out predicted tipward speed for five models (coloured lines) and of measured tipward speed (black, with interquartile range), on the 873 lumen edges. Shading: the interquartile range of a model's predictions within each bin, drawn for the models that also read the variable not on that panel's axis, so their prediction varies within a bin (in a, the three models with width; in b, the two offset models and the two models with both terms). a, binned by distance to the nearest growing tip, bins widening from 250 µm near a tip to 2.5 mm far from it, edges beyond 8 mm placed at 8 mm. b, binned by video lumen radius, 0.5 µm bins. Bins with fewer than 8 edges are omitted. The constant is not drawn, and offset as run is not held out. The force × throttle line leaves the top of b in the widest bins.], src: "forward_speed_figures.py") <fig-pd>

The width signal is in the measurements themselves, not only in the fits. Within each plate, measured tipward speed correlates with the lumen width at Spearman 0.45–0.72 and with tip distance at 0.62 and 0.69 on two plates (EPY2412A088, LPD2412A025) but 0.15–0.18 on the other three. On those same two plates the wider hyphae are also the ones further from tips (lumen width against tip distance 0.41 and 0.54; $-0.13$ to 0.30 elsewhere), so there tip distance partly stands in for width. @fig-profile shows both relations: speed rises with tip distance only over the first 1–1.5 mm and then is flat, while it rises with lumen radius across the whole range filmed, 2.6–6.2 µm (5th to 95th percentile).

#fig("figures/forward_speed_models_profile.png", [Measured tipward speed per edge (dots) with medians and interquartile ranges in bins (black). a, against the distance to the nearest growing tip, 1,503 edges, 250 µm bins, with the exponential, offset and step fitted on all of them. b, against the video lumen radius, 873 edges, 0.25 µm bins, with the width power law and the force model's tipward form fitted on all of them.], src: "forward_speed_compare.py --plot") <fig-profile>

Holding each fixed in turn separates them (@fig-confound). On the 873 lumen edges, the partial rank correlation (@sec-metrics) of speed with lumen width at fixed tip distance is 0.51, and of speed with tip distance at fixed width 0.17. On the 50 lumen edges within 1 mm of a tip they are 0.35 and $-0.02$: width still orders the near-tip edges, and tip distance does not order them within that band. What tip distance sets there is the level (@sec-near), which a rank cannot see. The residuals show the same split. What the held-out offset leaves unexplained rises with lumen radius across the filmed range (@fig-confound b). What the held-out width power law leaves is flat in tip distance except in the bins within about 1 mm of a tip, where measured speed is below it (@fig-confound c). Neither width relation is a measurement artefact. Per-pixel speeds, a second estimator, gave the same width dependence on the lumen tables before the walls_v4 rerun (within-plate Spearman 0.52 against 0.48 for streaks on those tables), and so did fluorescence speeds from separate videos (0.45); pixel count does not track diameter (`manuscript/speed_vs_diameter.md` on transport_paper). Nor is it video quality: on the 773 lumen edges whose videos raise no flag in the wall U-Net quality check, speed follows lumen width at 0.52, as on all 873; controlling for seven segmentation-quality metrics at once leaves it at 0.53; and none of them correlates with lumen width within a plate ($|rho| <= 0.06$; `width_artefact_checks.py`).

#fig("figures/forward_speed_models_confound.png", [Lumen width and tip distance on the 873 lumen edges. a, lumen radius against distance to the nearest growing tip, one dot per edge, colour by plate, edges beyond 8 mm placed at 8 mm. b, natural log of measured over held-out offset speed, centred on each plate's median, binned by lumen radius (0.5 µm bins). c, natural log of measured over held-out width power law speed, centred on each plate's median, binned by tip distance (the bins of @fig-pd a). Points in b and c are bin medians with interquartile ranges; bins with fewer than 8 edges are omitted. Tip distance is in mm in a and in µm in c.], src: "forward_speed_figures.py") <fig-confound>

The width gain depends on measuring width well. With 0.82 × the segmented radius in place of the lumen, the width models' rank drops from 0.50–0.58 to 0.34–0.37 over all 1,503 edges. The segmented width tracks the lumen width at only 0.40–0.72 within a plate, so most of the information is lost in that substitution.

== Within 1 mm of a tip, only tip distance sets the level <sec-near>

On the 122 edges within 1 mm of a tip the order reverses (@tab-near). Measured speed there is lower, median 2.23 µm/s (interquartile range 2.00–2.62) against 2.95 µm/s over all edges. Models without tip distance over-predict it: the constant by 1.25×, the width power law and the force model fitted on both streams by 1.22–1.23×. Every model that uses tip distance is within 10 % on bias. The exponential gets the level right but sends some edges toward zero, and is within 2× on only 92 % of them.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, right, right, right),
    stroke: 0.4pt + luma(200),
    inset: 3.5pt,
    table.header([*model*], [*within 2×*], [*fold*], [*bias*]),
    [constant], [0.98], [1.26], [1.25],
    [exponential], [0.92], [1.22], [1.04],
    [offset], [0.99], [1.14], [1.03],
    [step], [0.98], [1.18], [1.09],
    [offset as run], [0.99], [1.15], [1.04],
    [offset + demand], [0.98], [1.15], [1.06],
    [width power law], [0.98], [1.26], [1.23],
    [offset × width], [0.99], [1.13], [1.06],
    [force], [0.98], [1.26], [1.22],
    [force × throttle], [0.99], [1.12], [0.99],
    [force, to tip], [0.98], [1.26], [1.23],
  ),
  caption: text(8.5pt, fill: luma(95))[Held-out scores on the 122 edges within 1 mm of a tip (12 sessions, 5 plates), 0.82 × segmented radius, from the same predictions as @tab-main. Within-plate rank is omitted: 12–55 edges per plate. The lumen subset (50 edges) is in @sec-app-tables. #text(fill: luma(140))[#raw("forward_speed_compare.py")]],
) <tab-near>

The earlier store-held-out comparison on 1,547 brightfield edges (`FORWARD_MODEL_offset.md`), which includes edges without a measured returning stream, gives the same order within 1 mm of a tip: offset 71 % within 2×, constant 64 %, exponential 60 % (125 edges). It also gives the same order in fluorescence (97 %, 90 % and 74 % over 98 edges).

== The force balance reduces to a two-parameter width law for the tipward stream <sec-force>

Fitted on the tipward stream alone, the force model ("force, to tip") and the plain width power law score identically: rank 0.50 and 0.50, fold-change error 1.13 and 1.13, near-tip bias 1.23 and 1.23 (@tab-main, @tab-near). In @fig-profile b their curves overlap over the filmed range. On this stream the force balance contributes the saturating shape of @eq-forward, which the data cannot tell apart from $b^0.53$.

The full force model, fitted on both streams, keeps that rank and widens the span: 1.9–3.8 µm/s against 2.1–3.3 µm/s for the tipward-only fit. The extra spread comes from the returning stream. The joint fit makes the tipward speed depend on width more steeply because the returning stream's width dependence demands it (measured log-log slopes on the lumen width: 0.32 for the tipward stream, 0.90 for the returning one, from the width-law sweep of the force model on the lumen tables before the walls_v4 rerun). That spread is real coverage, 0.92 against 0.78, but it buys no rank.

== No model reproduces the measured range of speeds; the force models come closest <sec-span>

Measured tipward speeds on the lumen edges span 1.6–3.7 µm/s (5th to 95th percentile). @fig-compare a sets each model's held-out range against it. The constant covers 2.66–2.81, a span ratio of 0.07. Tip-distance models reach 0.15–0.23. The exponential's 0.68 is an artefact: its range is 2.68–2.84 except for the few edges at a tip, which the log standard deviation weights heavily. Width models reach 0.45–0.47, and the force models 0.70–0.74. Only the force models cover more than 90 % of the measured speeds within their own 1st to 99th percentile.

The extremes separate the models in the same order (@sec-app-tables). Of the fastest and slowest quarters of lumen edges, the constant reaches 41 % and 21 %, the held-out tip-distance models 45–53 % and 26–28 %, the width models 67–68 % and 48–52 %, and the force models 68–70 % and 63–65 %. Offset as run reaches 76 % of the fastest quarter, because its saturation speed of 3.10 µm/s sits above the median and its level was fitted on these plates, but only 21 % of the slowest.

#fig("figures/forward_speed_models_compare.png", [a, 5th to 95th percentile of each model's held-out predictions on the 873 lumen edges (blue), against the measured 5th to 95th percentile (grey band). b, within-plate Spearman correlation with measured speed, median over 5 plates, on the lumen edges (filled) and on all 1,503 edges with 0.82 × segmented radius (open). The constant has no within-plate rank.], src: "forward_speed_compare.py --plot") <fig-compare>

== Tip distance and width together match the force model with no force in it <sec-combined>

Two models get both the rank of @sec-width and the near-tip level of @sec-near: offset × width (4 fitted) and force × throttle (4 fitted, plus the throttle's 3). On the lumen edges they rank at 0.58 and 0.58 with fold-change error 1.13 and 1.14, above the 0.50 of width alone, so tip distance adds order as well as level; within 1 mm of a tip their bias is 1.06 and 0.99. Offset × width does this with a width exponent of 0.49–0.56 and the offset's own constants, $v_"tip"$ 2.38–2.60 and $v_infinity$ 3.00–3.15 µm/s at a 5 µm radius. On the tipward stream the force model's extra span (@sec-span) is the only thing it adds, and that comes from being fitted to the returning stream; on the returning stream itself it adds more (@sec-solver).

== The lipid stream slows near tips as the brightfield stream does <sec-fl>

This section is on the lumen tables and width ratio (0.89) from before the walls_v4 rerun; it has not been rerun on the current lumen widths (@sec-actions). The same comparison on the fluorescence (Nile Red) channel uses the 5-frame fluorescence streaks: 1,365 edges with a tipward speed over 15 sessions on 5 plates, 873 of them with a returning speed too, 668 with a lumen width, 150 within 1 mm of a tip. Speeds are the median over videos of each video's streak median. Tip distance, radius and demand come from the same network tables as for brightfield.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, right, right, right),
    stroke: 0.4pt + luma(200),
    inset: 3.5pt,
    table.header([*model*], [*all edges: fold / bias / rank*], [*lumen edges: fold / bias / rank*], [*within 1 mm: bias*]),
    [constant], [1.26 / 0.93 / –], [1.24 / 0.93 / –], [1.21],
    [offset], [1.22 / 0.93 / 0.42], [1.21 / 0.93 / 0.30], [0.92],
    [offset + demand], [1.18 / 0.94 / 0.53], [1.18 / 0.95 / 0.48], [0.91],
    [width power law], [1.26 / 0.93 / 0.27], [1.23 / 0.93 / 0.52], [1.24],
    [offset × width], [1.22 / 0.93 / 0.41], [1.22 / 0.92 / 0.42], [0.92],
    [force × throttle], [1.27 / 0.85 / 0.42], [1.26 / 0.85 / 0.41], [0.93],
  ),
  caption: text(8.5pt, fill: luma(95))[Held-out scores on the fluorescence tipward stream, 1,365 edges (0.89 × segmented radius) and 668 lumen edges (lumen radius); the near-tip column is the 150 edges within 1 mm of a tip on all edges. Rank is the within-plate Spearman correlation. Every model and score is in `fluorescence_scores.csv`. #text(fill: luma(140))[#raw("forward_speed_compare_fl.py")]],
) <tab-fl>

The near-tip slowdown is there in fluorescence at the same strength. Median fluorescence tipward speed is 1.89 µm/s within 1 mm of a tip against 2.47 µm/s overall, a ratio of 0.77, against 0.76 in brightfield. On the 908 edges measured in both channels (89 within 1 mm) the ratios are 0.73 in fluorescence and 0.76 in brightfield. Fitted held out over all edges, the offset shape has a real length scale in fluorescence, $lambda$ 1.5–3.3 mm with $v_"tip"$ 1.3–1.7 µm/s. As in brightfield, width alone over-predicts the near-tip edges (bias 1.24) and the tip-distance models get their level (0.91–0.93).

Two rankings differ from brightfield (@tab-fl). Tip distance ranks fluorescence edges at 0.42 over all edges, against 0.18 in brightfield, and adding demand lifts it to 0.53. Width ranks the lumen edges at 0.52, as in brightfield on the same tables (0.54), but only 0.27 with the segmented width (brightfield 0.34). The force model fitted on fluorescence settles at an unloaded speed of 2.5–3.1 µm/s over all edges and predicts tipward speeds 15 % low.

Fluorescence speeds read lower than brightfield on the same edges, median ratio 0.88, and that level is only partly instrumental. With 10–20 frames per video against 200, the fluorescence streak detector loses streaks faster than about 5 µm/s, which sets its ceiling (`manuscript/synthetic_streak_ceiling.md` and `bf_subsampled_fl_efficiency.md` on transport_paper `feat/fluorescence-detection-limit`). Speeds read from orientation-filter pixels, which do not share that ceiling at 2 frames per second, recover only part of the gap. On 532 edges filmed in both modes, the returning stream runs more than 1.3× faster than the tipward one on 39 % of edges in brightfield pixels and on 21 % in fluorescence pixels (`manuscript/pixel_tip_root_density.md`). So the lower fluorescence level is partly the detector and partly unexplained, and it is not compared with brightfield here. Only 0.1 % of per-edge fluorescence medians lie above 5 µm/s, and the near-tip ratio is a ratio of medians, so the rankings and that ratio are less affected than the distributions. Weighting each streak by the inverse of the detector's efficiency at its speed (measured by subsampling brightfield videos to the fluorescence frame rate) moves the near-tip ratio from 0.76 to 0.72, and to 0.70 on the 908 paired edges; adding undetected streaks above the fastest bin moves it by at most 0.015 more (`forward_speed_followups.py --fl-ceiling`). The ceiling compresses the ratio slightly toward 1, so the lipid stream slows near tips at least as much as the brightfield stream.

== A width term in the motor speed helps within plates, not pooled <sec-solver>

The test that matters for the transport model is whether the tipward gain of @sec-width carries into the returning stream when the width term drives the network solve. The held-out offset × width speed (0.89 × segmented radius, tip distance from the as-run throttle) was written for every network edge and passed to the solver as its motor speed, for the global (G), junction (J) and conveyor (C) couplings at core floor 0.8, with every other setting as in the force-motor runs (`offset_width_motor.py --tag=m`, runs `{G,J,C}_f0.8wm`). A run table carries the measured speeds of the streak tables it was built from, and the as-run and force runs were built from different versions of those tables, whose measured returning speeds agree on 41 % of edges. So the as-run model was rerun on the same tables as the force and width runs (`{G,J,C}_f0.8am`), and all three are scored on the same 1,566 measured edges, 220 of them on trees and 1,346 in loops. Every run completed all 15 sessions. These runs and the scores in @tab-solver are on the measurement tables with the 1 µm/s static cut, built on 8 Oct from transport_paper 393515c; the rest of this document is on the tables without that cut. They also predate the walls_v4 lumen rerun and use 0.89 × the segmented radius, and have not been rerun (@sec-actions).

#figure(
  text(8.5pt, table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left, right, right, right, right, right),
    stroke: 0.4pt + luma(200),
    inset: 3.5pt,
    table.header([*coupling*], [*within-plate rank, tree*], [*within-plate rank, loop*], [*pooled rank, tree*], [*within 2×, loop*], [*tracking slope*]),
    [global (G)], [0.39 / 0.52 / 0.50], [0.39 / 0.40 / 0.39], [0.41 / 0.34 / 0.23], [0.79 / 0.79 / 0.78], [0.34 / 0.38 / 0.33],
    [junction (J)], [0.39 / 0.51 / 0.51], [0.29 / 0.37 / 0.32], [0.39 / 0.34 / 0.22], [0.92 / 0.92 / 0.89], [0.15 / 0.22 / 0.14],
    [conveyor (C)], [0.39 / 0.50 / 0.51], [0.33 / 0.42 / 0.38], [0.40 / 0.34 / 0.21], [0.92 / 0.93 / 0.91], [0.18 / 0.26 / 0.18],
  )),
  caption: text(8.5pt, fill: luma(95))[Returning-stream scores for the three motor rules, each cell as run / force motors / offset × width, on the same 1,566 measured edges. Within-plate rank is the median over 5 plates of the Spearman correlation of modelled with measured returning speed inside a plate; pooled rank is the same correlation over all plates at once. Tracking slope is the slope of log modelled on log measured speed (1 follows the data, 0 ignores it). #text(fill: luma(140))[#raw("offset_width_motor.py --score --tag=m --asrun=am → model_grid/offset_width_compare_m_am.csv")]],
) <tab-solver>

On tree edges the solver returns each edge's own motor stream: modelled returning speed over motor speed has a median of 1.00, and the change in one tracks the change in the other at a correlation of 0.997–0.999 (`forward_speed_followups.py --backflow-rank`, on the earlier tables). So a tree edge's returning rank is its motor speed's rank. Within each plate, the width term lifts that rank from 0.39 to 0.50–0.51, as much as force motors do (0.50–0.52). Pooled over plates it falls to 0.21–0.23, and one plate does that. The 49 tree edges of PNF2307A080 carry the highest measured returns (median 4.13 µm/s, against 2.66–3.10 on the other plates) and are the narrowest, so the width fit made on the other four plates gives them the lowest motor speed (median 2.29 µm/s). Without that plate, the pooled tree rank is 0.47–0.49 with the width term against 0.42–0.46 as run. Force motors lose the same way with it (0.34) and gain without it (0.52–0.53).

On loop edges and in tracking, the width term does little. Its within-plate loop rank is 0.32–0.39 against 0.29–0.39 as run, its tracking slope is unchanged, and its loop accuracy is 0.01–0.03 lower. Force motors add beyond width there: within-plate loop rank 0.37–0.42 and tracking slope 0.22–0.38. So width accounts for the force motors' gain on tree edges within plates, and not for their gain on loop edges or in tracking.

Pooled over plates, the return-lane width exponent earns at most 0.006 in fold-change error with either motor rule: its best value is 0 for force motors on every coupling, and 0–0.3 for the width term (`width_exponent_force.py --offset-width`, master tables).

= Discussion <sec-discussion>

Scored on the tipward stream, held out by plate, on the same 1,503 edges over 15 sessions on 5 plates, every model is within 2× of 96–97 % of edges, so level alone does not choose between them (@sec-saturated). They are separated by rank and by where they fail. Width sets the order away from tips: within-plate rank 0.50 for width alone and 0.58 for width with tip distance on the 873 lumen edges, against 0.14–0.22 for tip distance alone (@sec-width). Within 1 mm of a tip, tip distance sets the level: models without it over-predict by 1.22–1.25× on 122 edges, models with it are within 10 % (@sec-near). The force-balance motor model adds nothing on this stream that a two-parameter width power law does not (@sec-force), and tip distance times width, four fitted numbers, matches it and ranks above width alone (@sec-combined). No model states the measured span; the force models come closest, through their fit to the returning stream (@sec-span). The lipid stream in fluorescence slows near tips by the same ratio, 0.77 against 0.76, and tip distance ranks it better than it ranks brightfield (@sec-fl). Driving the network solve, the width term lifts the returning stream's within-plate rank on tree edges from 0.39 to 0.50–0.51, as much as force motors do, but one plate's level undoes it pooled over plates, and force motors add beyond width on loop edges and in tracking (@sec-solver). These claims are bounded by five plates and one way of measuring width on the unfilmed edges.

The comparison is held out by plate, but there are five plates. A fold's training set is four of them, so a parameter can only be as stable as five folds show, and @tab-dof shows the force model's $k$ and $z$ are not: they vary 2.6- to 3.1-fold over the folds and $z$ over more than an order of magnitude, as expected of a pair that enters the tipward speed only through $K$. The between-plate share of the variance of log speed is small, 4.7 %, which is why held-out and pooled scores differ little here. It also means a sixth plate with a different imaging setup could move the level more than these scores suggest.

Offset as run looks best on fold-change error and bias (1.10–1.11, bias 1.00) because its constants were fitted on 12 sessions that include these plates. On rank and span, which its fit did not target, it is no better than the held-out offset. Its level should not be read as an advantage of the shape.

Width and tip distance are not independent on two of the five plates. On EPY2412A088 and LPD2412A025 the wider hyphae are further from tips, so part of what the tip-distance models capture there is width. The near-tip result does not rest on those two plates: the near-tip edges are spread over all five (12–55 each), and width alone over-predicts them on four, by 1.12–1.28×. On the fifth, PNF2307A080 (12 edges), every model under-predicts, the offset included (bias 0.75).

The rank gain needs the video lumen width. With the segmented width the width models fall to 0.34–0.37 over all edges, and the network runs have only the segmented width on the edges that were never filmed. Until lumen widths exist across the network (transport_paper\#73), the network-wide gain from a width term is the smaller one.

The width term in the network solve was measured with the segmented width on every edge, where the tipward rank gain is the smaller one (0.35 against 0.58 with the lumen), and its pooled result rests on one plate's level (@sec-solver), so a sixth plate could move it either way.

Three scope limits hold for every number here. The brightfield comparison uses only edges with both streams measured, which drops filmed edges where the returning stream had too few streaks. Fluorescence streak speeds are censored above about 5 µm/s by the detector, and its lower level is only partly explained by that, so it is not compared with brightfield (@sec-fl). Each edge contributes its median speed, so within-edge spread is invisible. And the force model's discrete choices (geometry, motor-count exponent, linear force–velocity law) were made on this data before the comparison, so its four fitted numbers understate what it was tuned on.

= What didn't work <sec-dead>

Exponential falloff to zero at the tip. Held out by plate, its fitted length scale is 138–359 µm, so it is a constant everywhere except at the last few hundred micrometres. There it sends predictions toward zero and drops to 92 % within 2× on the 122 near-tip edges, the only model below 98 %. Measured tipward speed does not stop at a tip (median 2.23 µm/s within 1 mm). The offset shape replaced it in the solver on 18 Sep for this reason; this comparison confirms it held out by plate.

A step at a fixed distance. It reaches the near-tip level (bias 1.09) but has the lowest rank of any model with a free parameter, 0.16 on the lumen edges and 0.15 over all edges, and the narrowest span after the constant. The measured rise near tips is gradual over about 1–1.5 mm (@fig-profile a), not a step.

The force model fitted inversely, taking each edge's measured tipward speed and solving @eq-force for its lane share. Only the side-wall geometry's drag-limited branch reaches 99.7 % of the measured speeds. The other geometries reach 60–98 %, and the side-wall and side-area force-limited branches reach under 1 %. Even where it reaches them, it scores the returning stream no better than the conveyor run with the measured tipward speed as its motor speed (fold-change error 1.34 against 1.27, `force_motor/inverse.csv`). Scored on the returning stream through the whole network solve, force motors give 78 % within 2× against 80 % for the best global solve, 83 % against 88 % on tree edges (log, 1 Oct).

= Actionable Items <sec-actions>

Each item says what it needs and roughly how long it takes on the local machine. Durations are estimates from the runtimes in this analysis: the comparison itself runs in about 8 s, and a full solver pass over the 15 sessions took about 6 min per coupling in the force-motor runs (`model_grid/raw_force.log`).

== Can run now on existing tables

+ #open Rerun the fluorescence comparison (@sec-fl) on the walls_v4 lumen widths and the 0.82 width ratio: `forward_speed_compare_fl.py`, with the fluorescence position caches rebuilt from transport_paper `feat/fluorescence-detection-limit`. Its lumen-edge column changes with the lumen table.
+ #open Rerun the network-solve comparison (@sec-solver) on the current tables: `offset_width_motor.py --tag=m` and the six solver passes, about 1 h locally.
+ #open Score the all-edges set with the final transport model's network width, the legacy Keras width × 0.75 with 0.83 × segmented as fallback. It tracks the video lumen better than the segmented width (within-plate $rho$ 0.61 against 0.48; log 2026-10-15) and could recover part of the rank lost in @sec-width.

+ #open Whether the returning-speed level of PNF2307A080 is a property of that plate's imaging or registration, or of its hyphae. Its narrow tree hyphae carry the fastest returns of any plate, and that one plate decides the pooled result of a width term in the motor speed (@sec-solver). Its videos, registration flags and streak gate are on disk; a per-plate check of the measurement chain is a local, minutes-long script.
+ #open The measured-edge checks in #link("throttled_core_speed_model.typ")[the throttled core-speed document] (lipid share, $a\/b$, return over motor speed, the near-tip slowdown argument) come from a run with the old exponential throttle. One solver pass with the offset throttle (about 10 min) and the same summary scripts would bring them onto the model as it runs.
+ #open That document's section on the throttle says the core radius is solved at the unthrottled motor speed; the solver may size it at the throttled speed instead. Reading the solver's annulus sizing settles which, then the derivation's flux equation and section heading follow.
+ #open #link("backflow_model_accuracy.typ")[The backflow accuracy document] still presents the exponential fit (2.87 µm/s, 749 µm) as the measured configuration. A text edit like the one made to the throttled core-speed document: current constants where it says what the model is, results from exponential-throttle runs labelled as such.
+ #open Post the brightfield and fluorescence near-tip result on transport_paper\#132 and the solver result on transport_paper\#72.

== Needs new data or compute

+ #open Lumen widths on every edge (transport_paper\#73, \#116). The width gain shrinks from 0.50–0.58 to 0.34–0.37 with the segmented width; the Keras width above is the local alternative. The U-Net lumen segmentation on every frame, then re-registration of the paper videos, is a Snellius job and a re-registration, not a local rerun.
+ #open More plates. Five folds bound how stable any parameter can be shown to be, and the near-tip lumen subset is 50 edges, 2 of them on one plate. Every additional session that has videos and a network adds a fold.
+ #open Per-streak speeds against tip distance and width (transport_paper\#132). Per-edge medians hide whether near-tip edges carry slower streaks or a mix of fast and stalled ones. The streak tables exist for both channels.

== Compendium handoff

- D3, "Forward speed from an offset profile, not a zero at the tip" (`decisions/accepted/d3.typ`). Its criterion asks for a held-out forward fit that keeps the offset form ahead of the old exponential and of a constant. Held out by plate here, it is: fold-change error 1.14 against 1.16 and 1.17 over all edges, and 1.14 against 1.22 and 1.26 within 1 mm of a tip (@tab-main, @tab-near). The entry is stale in two places: its constants are the 18 Sep fit (3.09, 1.85, 1.6 mm), not the 25 Sep ones the solver uses (3.096, 2.140, 1,711 µm), and it says the old form stays the default, which it has not been since 24 Sep.
- A width term in the motor speed has no entry. Within plates it lifts the tree-edge returning rank as much as force motors, but pooled over plates one plate undoes it (@sec-solver); an entry waits on the PNF2307A080 question above.
- Stale reference: #link("backflow_model_accuracy.typ")[the backflow accuracy document], its description of the measured throttle, as in the backflow-document item above.

#pagebreak(weak: true)
= Appendix <sec-appendix>

== Every score, both edge sets and the near-tip subsets <sec-app-tables>

All numbers are from `fig_outputs/forward_speed_compare/scores.csv`. Columns: fitted parameters, n, within 2×, fold-change error, bias, within-plate rank, prediction p5–p95 (µm/s), span ratio, coverage, fastest quarter reached, slowest quarter reached. Measured p5–p95: 1.60–3.74 (lumen), 1.66–3.67 (all), 1.64–3.42 (lumen, within 1 mm), 1.65–3.39 (all, within 1 mm).

#[
#show figure: set block(breakable: true)
#figure(
  text(8.5pt, table(
    columns: 11,
    align: (left,) + (right,) * 10,
    stroke: 0.3pt + luma(210),
    inset: 2.6pt,
    table.header([*model*], [*fit*], [*n*], [*w2*], [*fold*], [*bias*], [*rank*], [*p5–p95*], [*span*], [*cov*], [*fast / slow*]),
    table.cell(colspan: 11)[_lumen edges, lumen radius_],
    [constant], [1], [873], [0.963], [1.168], [0.926], [–], [2.66–2.81], [0.07], [0.06], [0.41 / 0.21],
    [exponential], [2], [873], [0.959], [1.163], [0.922], [0.20], [2.68–2.84], [0.68], [0.39], [0.45 / 0.26],
    [offset], [3], [873], [0.964], [1.151], [0.928], [0.22], [2.45–2.98], [0.19], [0.35], [0.53 / 0.28],
    [step], [3], [873], [0.964], [1.158], [0.926], [0.14], [2.56–2.92], [0.15], [0.26], [0.48 / 0.26],
    [offset as run], [0], [873], [0.960], [1.105], [1.000], [0.22], [2.53–3.10], [0.23], [0.45], [0.76 / 0.21],
    [offset + demand], [5], [873], [0.962], [1.149], [0.966], [0.36], [2.33–3.26], [0.35], [0.66], [0.52 / 0.37],
    [force], [4], [873], [0.974], [1.133], [0.994], [0.50], [1.85–3.75], [0.70], [0.92], [0.68 / 0.63],
    [force × throttle], [4], [873], [0.971], [1.142], [0.995], [0.58], [1.78–3.89], [0.74], [0.92], [0.70 / 0.65],
    [force, to tip], [2], [873], [0.975], [1.128], [0.973], [0.50], [2.10–3.33], [0.45], [0.78], [0.68 / 0.52],
    [width power law], [2], [873], [0.973], [1.130], [0.971], [0.50], [2.14–3.39], [0.45], [0.79], [0.68 / 0.51],
    [offset × width], [4], [873], [0.974], [1.129], [0.971], [0.58], [2.11–3.46], [0.47], [0.81], [0.67 / 0.48],
    table.cell(colspan: 11)[_all edges, 0.82 × segmented radius_],
    [constant], [1], [1503], [0.970], [1.167], [0.927], [–], [2.67–2.82], [0.07], [0.08], [0.44 / 0.26],
    [exponential], [2], [1503], [0.965], [1.156], [0.927], [0.17], [2.69–2.84], [0.89], [0.33], [0.49 / 0.31],
    [offset], [3], [1503], [0.969], [1.140], [0.937], [0.18], [2.35–3.00], [0.22], [0.39], [0.60 / 0.34],
    [step], [3], [1503], [0.970], [1.146], [0.939], [0.15], [2.63–2.97], [0.19], [0.33], [0.56 / 0.32],
    [offset as run], [0], [1503], [0.967], [1.098], [0.998], [0.18], [2.42–3.10], [0.26], [0.46], [0.78 / 0.28],
    [offset + demand], [5], [1503], [0.971], [1.133], [0.963], [0.38], [2.37–3.21], [0.33], [0.68], [0.54 / 0.40],
    [force], [4], [1503], [0.971], [1.161], [0.973], [0.34], [2.03–3.18], [0.46], [0.71], [0.43 / 0.35],
    [force × throttle], [4], [1503], [0.971], [1.139], [0.974], [0.37], [2.08–3.32], [0.50], [0.82], [0.49 / 0.43],
    [force, to tip], [2], [1503], [0.973], [1.157], [0.960], [0.34], [2.22–3.04], [0.32], [0.53], [0.41 / 0.31],
    [width power law], [2], [1503], [0.973], [1.160], [0.961], [0.34], [2.24–3.07], [0.32], [0.59], [0.41 / 0.32],
    [offset × width], [4], [1503], [0.973], [1.136], [0.967], [0.35], [2.27–3.17], [0.36], [0.69], [0.45 / 0.40],
    table.cell(colspan: 11)[_lumen edges within 1 mm of a tip_],
    [constant], [1], [50], [1.000], [1.284], [1.253], [–], [2.66–2.81], [0.09], [0.06], [0.69 / 0.00],
    [exponential], [2], [50], [0.920], [1.295], [0.931], [–], [0.54–2.75], [3.60], [0.80], [0.54 / 0.23],
    [offset], [3], [50], [1.000], [1.168], [1.007], [–], [2.10–2.54], [0.28], [0.36], [0.38 / 0.31],
    [step], [3], [50], [1.000], [1.190], [1.126], [–], [2.21–2.57], [0.30], [0.22], [0.54 / 0.08],
    [offset as run], [0], [50], [1.000], [1.156], [1.041], [–], [2.18–2.54], [0.24], [0.28], [0.62 / 0.23],
    [offset + demand], [5], [50], [1.000], [1.166], [1.049], [–], [2.05–2.75], [0.47], [0.58], [0.38 / 0.46],
    [force], [4], [50], [1.000], [1.126], [1.056], [–], [1.92–3.40], [0.82], [0.86], [0.85 / 0.31],
    [force × throttle], [4], [50], [1.000], [1.211], [0.853], [–], [1.50–2.81], [0.88], [0.86], [0.62 / 0.85],
    [force, to tip], [2], [50], [1.000], [1.149], [1.127], [–], [2.18–3.11], [0.52], [0.66], [0.92 / 0.15],
    [width power law], [2], [50], [1.000], [1.147], [1.126], [–], [2.20–3.12], [0.50], [0.60], [0.92 / 0.15],
    [offset × width], [4], [50], [1.000], [1.170], [0.966], [–], [1.92–2.85], [0.56], [0.72], [0.77 / 0.54],
  )),
  caption: text(8.5pt, fill: luma(95))[Every score. Within-plate rank is left blank on the near-tip subset (2–23 edges per plate). The all-edge near-tip subset is @tab-near. #text(fill: luma(140))[#raw("forward_speed_compare.py")]],
) <tab-app-all>
]

== Fitted parameters over the five folds, all edges <sec-app-params>

Ranges over the five held-out folds on the 1,503 edges with 0.82 × segmented radius: constant 2.67–2.82; exponential $v_0$ 2.69–2.84, $lambda$ 129–187 µm; offset $v_infinity$ 2.79–3.04, $v_"tip"$ 1.91–2.20, $lambda$ 754–2,520 µm; step $v_"near"$ 2.20–2.63, $v_"far"$ 2.73–2.97, $d_0$ 906–3,490 µm; offset + demand $g_0$ 0.81–0.84, $Q$ 1.6–4.0; width power law $c$ 1.25–1.88, $beta$ 0.29–0.52; offset × width $beta$ 0.27–0.48; force $k$ 12–38, $v_max$ 4.9–13.3, $z$ 0–8.1, $phi_0$ 0.54–0.56; force, to tip $v_max$ 3.9–5.6, $K$ 1.2–2.4. Per-fold values are in the `params` column of `scores.csv`.

== Reproducing this <sec-app-repro>

In a transport_paper checkout of master (801bd33), with `fig_outputs/` holding the conveyor tables (`model_grid/raw/C_f0.8`), the lane drag table (`model_grid/raw/force_motor/lane_drag.csv`), the video lumen widths (`model_choices/unet_lumen_edges.csv` as committed, the walls_v4 rerun of 11 Oct, 98b364b) and, for the tip-distance control, `model_accuracy/features_edges.csv`:

```
python Working_notebooks/forward_speed_compare.py --selfcheck
python Working_notebooks/forward_speed_compare.py           # scores.csv, about 8 s
python Working_notebooks/forward_speed_compare.py --plot    # both figures
python Working_notebooks/forward_speed_doc_numbers.py       # every other number cited
python Working_notebooks/forward_speed_figures.py           # figures, partial correlations
python Working_notebooks/width_artefact_checks.py           # width vs video quality (about 8 min)
```

`forward_speed_figures.py` (@fig-mvm, @fig-pd, @fig-confound and the partial rank correlations in @sec-width) and `width_artefact_checks.py` (the video-quality check in @sec-width) are on master since PR \#138 (9 Oct).

Fluorescence (@sec-fl) needs the 5-frame fluorescence position caches, rebuilt by the scripts on transport_paper `feat/fluorescence-detection-limit` (fe036ae). The network solve (@sec-solver) uses the flags of the force branch of `run_grid_raw.sh`, once with the width motor speed (suffix `wm`) and once with no motor override (suffix `am`), one coupling at a time, about 8–10 min each:

```
python Working_notebooks/forward_speed_compare_fl.py          # fluorescence_scores.csv
python Working_notebooks/offset_width_motor.py --tag=m        # motor speed per edge
#   run_grid_raw.sh force flags: --motor-speed-dir .../raw/offset_widthm -> <c>_f0.8wm
#   the same flags without --motor-speed-dir                  -> <c>_f0.8am
python Working_notebooks/offset_width_motor.py --score --tag=m --asrun=am
```

Two scripts are on `feat/forward-speed-compare` only, not in PR \#133: `width_exponent_force.py --offset-width` (the return-lane exponent in @sec-solver) and `forward_speed_followups.py` (the tree-edge identity in @sec-solver, `--backflow-rank`, and the detector-ceiling correction in @sec-fl, `--fl-ceiling`).

The earlier store-held-out comparison cited in @sec-near is `model_accuracy_forward.py --offset`; the inverse force fit in @sec-dead is `force_motor_model.py`.
