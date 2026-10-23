// finding: open
#set document(
  title: "Section cut by filming site — flow collapses at the cut and recovers only partly",
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
  #text(19pt, weight: 700)[Section cut by filming site]
  #v(-0.3em)
  #text(19pt, weight: 700)[flow collapses at the cut and recovers only partly]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · 106 brightfield flow videos at 12 filming sites, placed on the colony network by hand registration;
    cut days of four #emph[R. irregularis] plates (LPD2412A009, -025, EPY2412A084, -104), 3 pieces closed off by the cuts;
    40 min before to 5.4 h after the cut ·
    transport_paper\@4e2e8ff
  ]
]
#v(1.2em)

= Introduction
#question[When a scalpel cuts hyphae in a living colony, how much does cytoplasmic flow slow at a given filming site, and does that depend on whether the site ends up in a piece of network the cuts closed off, on its distance to the cut, on the time since the cut, and on how much hypha the closed-off piece contains?]

The plates are #emph[Rhizophagus irregularis] colonies imaged as whole-plate scans every two hours, with 10 s flow
videos at 50× taken at chosen positions. Each scan is segmented into a network graph, and the scans of one plate are
merged into one spatio-temporal graph (the STG) whose edges are the hyphae between junctions. Each video is analysed
per hypha into two opposing stream speeds. On four plates the experimenter filmed some positions, cut hyphae with a
scalpel, and filmed again; the cuts are drawn by hand as red bars on a scan of the plate from the same morning (the
annotated maps).

Fig 3C of the paper reports this experiment as one number per stage-position folder: both streams slow by about a
fifth after the cut. This document places every video on the STG by hand registration and asks the question per
filming site.

= Motivation
Neither of the two ways a video can be placed without registration finds its filming site. The pipeline's position
folders pool videos filmed millimetres apart under one name. The recorded stage positions are off by 0.4–2.3 mm on
every cut plate, found by matching video frames against each other and against the experimenter's labels on the maps:
on EPY2412A084 three recorded positions 0.4–0.7 mm apart are one field of view, and on LPD2412A009 the same
Y-junction is recorded at two positions 2.3 mm apart. A site placed by stage position can land on the wrong hypha, or
on the wrong side of a cut, and a pre-cut baseline taken from a neighbouring hypha carries that hypha's own speed.

The answer decides how Fig 3C is read. "Isolating a section slows both streams" is a claim about the closed-off piece.
If the slowing is instead concentrated at the cut, or passes within an hour, the figure measures wound response and
time, not isolation.

= Method <sec-method>
== Each video is placed on the network edges it was registered onto <sec-m-register>
The STG of each plate is built on the last scan before the cut (stores `LPD2412A025_t77`, `EPY2412A104_t82`,
`EPY2412A084_t73`, `LPD2412A009_t90`), so its edges are the network at the moment of cutting. In the registrator, each
cut-day video was placed on that STG by hand: the videos of a time group are anchored to STG nodes, and each hypha in
the video (a video edge) is pinned to the STG edge it lies on. The registrator stores, per video edge, its STG edge and
the median speed of each stream in the STG edge's frame. The registration records which STG edge a video is on, not
where along it; on a long edge that leaves the position within the edge unknown (@sec-d-within).

*Speed per video* is direction-free: per video edge the mean of the two stream medians, then a length-weighted mean
over the video's edges. Video edges shorter than 100 px (14 µm at the 0.138 µm/px of these videos) are junction stubs
and are dropped. So is *dust*: a piece of the video graph shorter than 300 px (41 µm at 0.138 µm/px) that does not
reach within 60 px of the frame edge. Dust was registered onto a hypha more than once; a 170 px fragment beside the
hypha of LPD2412A009 video 1 carried its own speed onto an STG edge.

== Cut marks are moved onto the network by aligning the map to the drawn graph <sec-m-align>
The annotated map is a downsampled scan (6.91 µm per map pixel on the LPD plates, 39.5 on the EPY plates). Its hyphae
are picked out with a 5 px white top-hat, which keeps thin dark lines and drops the scan's tile-to-tile shading, and the
experimenter's coloured marks are blanked. The STG is drawn at the map's scale, and the two images are cross-correlated
at 40 µm resolution over rotations from −45° to +45° (2.5° steps, then 0.5° around the best). The *score* is the
correlation peak over its standard deviation; an alignment is accepted above 50. Each cut mark is then carried through
the fitted rotation and shift into STG coordinates.

The experimenter's video labels are not used by the fit, so they are an independent check: a label should land near
the STG edges its own videos were registered onto. What would make the check lie is a label written beside its site
rather than on it; labels are text, a few map pixels across.

== A cut severs the edges within 50–99 µm of its mark; what it splits off is isolated <sec-m-pieces>
Each cut mark severs every STG edge passing within max(50 µm, 2.5 map pixels) of it, and at least the nearest one: 50 µm
on the LPD maps, 99 µm on the EPY maps, whose marks land 60–90 µm from the hypha after alignment. Removing the severed
edges splits the STG into parts. An *isolated piece* is a part the cuts separated from the STG component it belonged to,
other than the largest such part; its *length* is the summed length of its STG edges plus the stubs of the severed edges
on its side. A site not in an isolated piece is *connected*.

The STG has gaps where the segmentation missed a hypha, so a piece that looks closed off in the STG may still be joined
to the colony through a hypha the STG lacks. The check is the map: a piece is only as closed as the scan shows it.

== Distance runs along the network, from the cut to the nearer end of the video's edge <sec-m-distance>
The *distance to the cut* of a video is the shortest path along the STG, with the severed edges removed, from the cut
point on a severed edge to the nearer end of the video's STG edge. A video on a severed edge is put on the side of the
longer stub; its distance is then known only to be less than that stub, so it is counted as *at a cut* when the stub is
under 0.5 mm and left without a distance otherwise (11 of the 78 post-cut videos). The three *zones* are: at a cut
(distance under 0.5 mm), isolated piece, and connected.

== Post over pre on the same network edge <sec-m-ratio>
The *post/pre ratio* of a post-cut video is its speed over the median pre-cut speed on the same STG edges: per shared
edge the ratio of the two, then a length-weighted mean. Where no pre-cut video covers any of its edges, the plate's
pre-cut median is used instead, and the ratio then carries the difference between two sites' own speeds (open markers
in the figures). 53 of the 78 post-cut videos have a same-edge baseline. The ratio also lies when the pre-cut speed
itself drifts, which it does on LPD2412A009 (@sec-r-connected).

== The tests, in order <sec-m-tests>
+ *Alignment*: the correlation score, the distance from each cut mark to the edge it severs, and the label check.
  Everything after depends on the cuts landing on the right hyphae.
+ *At a cut*: the ratio of every video within 0.5 mm of a cut along the network, against time.
+ *Same-edge time courses*: the sites filmed both before and after on the same STG edge, followed through time. These
  carry no between-site difference.
+ *Distance*: the ratio against distance to the cut, all post-cut videos.
+ *Piece length*: the ratio after the first 30 min in each isolated piece, against the piece's length.

#note[Videos, not sites, are the unit of every correlation here, and videos at one site are not independent. There are
12 registered filming sites on four plates (@tab-sites). Read correlations as descriptive.]

= Results <sec-results>
== The cuts land on the network hyphae they were drawn across <sec-r-align>
All four maps align with scores of 301–515. EPY2412A104's STG sits at −21.5° to its map, and the other three within
1.5° (LPD2412A025 +1.5°, EPY2412A084 0°, LPD2412A009 +0.5°). The nine cut marks land 14–60 µm from the edge nearest to
them, and sever 3 STG edges on LPD2412A025, 5 on EPY2412A104, 3 on EPY2412A084 and 4 on LPD2412A009.

The label check passes on the LPD maps: the labels land 12, 18 and 35 µm from their videos' registered edges, and one
LPD2412A009 label (videos 60–68) 220 µm away, beside a junction. On the coarser EPY maps the one EPY2412A084 label lands
89 µm off (2.3 map pixels). On EPY2412A104 the label of video 23 agrees (81 µm) and those of 1, 22, 24 and 28 do not
(0.5–1.8 mm): videos 22 and 28 are registered on the hypha north of the upper cut, outside the piece, where the labels
put them inside it (@fig-stg). They are kept as registered.

The isolated pieces are 4.57 mm of hypha on EPY2412A104 (one hypha between two cuts; 4.3 mm measured by hand on the
map), 23.8 mm on LPD2412A025 and 72.6 mm on EPY2412A084. LPD2412A009's cuts split off no piece: its cut hyphae stay
joined to the rest of the network on both sides.

#fig("figures/section_cut_stg.png",
  [*The four plates on their network graphs.* 8 × 8 mm around the cuts. Grey: STG edges; red: severed edges, drawn whole;
  orange: isolated pieces; blue and purple: the STG edges of pre-cut and post-cut videos; red crosses: the cut marks.
  Most of EPY2412A104's piece is the severed edge itself, so it shows red. LPD2412A009 has no isolated piece. Bar 1 mm.],
  src: "Working_notebooks/figure3/section_cut_registered.py (plot_sites)", width: 88%) <fig-stg>

== At a cut flow falls to a median ×0.19, and is still low after 2 h <sec-r-cut>
Nine post-cut videos lie within 0.5 mm of a cut, on three plates. Their ratios are ×0.07–0.84, median ×0.19:

- *EPY2412A104*: at the lower cut, on the same edge as the pre-cut videos, ×0.10 and ×0.19 at 12–13 min; at the upper
  cut, outside the piece, ×0.07 and ×0.10 at 9 and 16 min (plate baseline). One video at 6 min, on edges 3778 and 3982
  0.28 mm from the lower cut, is at ×0.84.
- *LPD2412A009*: at the junction where two cuts meet, ×0.48 and ×0.53 at 13–15 min, and ×0.10 at 124 min (plate
  baseline).
- *LPD2412A025*: 0.37 mm from its cut, ×0.65 at 176 min (plate baseline).

The three videos filmed more than 2 h after the cut are at ×0.10 (LPD2412A009, 124 min) and ×0.65 (LPD2412A025,
176 min); none is back near its pre-cut speed.

== On the same edge, flow dips within half an hour and recovers only part of the way <sec-r-time>
Four sites were filmed on one STG edge through time (@fig-time). Three have a same-edge baseline:

- *LPD2412A025*, edge 8643, 1.4 mm from the cut, in the 23.8 mm piece. Pre 3.43–3.83 µm/s (5 videos). At 5–7 min
  ×0.39–0.55; at 10–28 min ×0.11–0.26; at 80–81 min ×0.66–0.72; at 174–175 min ×0.78–0.86; at 4.5–5.4 h ×0.55–0.79.
  The deepest point comes 10–28 min after the cut, and in 5.4 h the site never regains its pre-cut speed.
- *EPY2412A084*, edge 174, 3.0 mm from the nearest cut, in the 72.6 mm piece. Pre 4.14–4.48 µm/s (5 videos). At
  12–14 min ×0.78–0.89; at 28–30 min ×0.62–0.83; at 56–58 min ×0.82–0.89. A shallower dip, and back to about ×0.85.
- *LPD2412A009*, edge 7504, 1.9 mm from the cut, connected. Its ratios are in @sec-r-connected, because its own
  baseline moves.

The fourth site, *EPY2412A104* edge 3778 inside the 4.57 mm piece, has no pre-cut video; against the plate's pre-cut
median (4.45 µm/s, five videos on the edge at the lower cut) it runs at ×0.73–1.04 at 4–7 min, ×0.36–0.40 at 14–17 min,
×0.34 at 35 min and ×0.17–0.18 at 49–68 min. It is the only site still falling after half an hour.

#fig("figures/section_cut_timecourse.png",
  [*Post/pre speed against time after the cut, per registered filming site.* Lines join the videos of one site on one
  STG edge; LPD2412A025, EPY2412A084 and LPD2412A009 are divided by the same edge's pre-cut median, EPY2412A104
  (dashed) by the plate's. Crosses: videos within 0.5 mm of a cut along the network.],
  src: "Working_notebooks/figure3/section_cut_registered_figs.py") <fig-time>

== LPD2412A009's connected site slows, but its baseline had already halved <sec-r-connected>
On edge 7504 the five pre-cut videos at −39 to −34 min run at 3.28–3.54 µm/s, and the five at −17 to −15 min at
1.49–2.02 µm/s: the site slowed by about half before anything was cut. Against the median of all ten (2.65 µm/s), the
post-cut videos run at ×0.72–0.89 at 10–18 min, ×0.64–0.96 at 93–110 min, and ×0.54, ×0.39 and ×0.25 at 112, 114 and
119 min. Against the last five pre-cut videos alone, the first post-cut videos (1.90–2.36 µm/s) are not slower at all.
The late decline to ×0.25 is real on this edge, but whether the cut caused it cannot be told from a baseline that moves
by half in 20 min. A fourth LPD2412A009 site, 13 mm from the cuts and filmed only after them, runs at ×1.24–1.47 of the
plate's pre-cut median; it is a fast site, not a speed-up.

== Speed rises with network distance, but distance here is mostly the plate <sec-r-distance>
Across the 67 post-cut videos with a distance, the ratio rises with distance to the cut (Spearman ρ = 0.68; 0.55 over
the 53 with a same-edge baseline):

#figure(
  table(columns: 4, align: (left, right, right, left), stroke: none, inset: (x: 8pt, y: 3pt),
    table.hline(stroke: 0.6pt),
    [distance along the network], [videos], [median post/pre], [plates],
    table.hline(stroke: 0.4pt),
    [< 0.5 mm], [9], [0.19], [EPY104, LPD009, LPD025],
    [0.5–1 mm], [2], [0.37], [EPY104],
    [1–2 mm], [37], [0.66], [LPD009, LPD025],
    [2–4 mm], [15], [0.83], [EPY084],
    [> 4 mm], [4], [1.39], [LPD009 (plate baseline)],
    table.hline(stroke: 0.6pt)),
  caption: text(8.5pt, fill: luma(95))[Post/pre ratio by distance to the nearest cut along the network, post-cut
  videos with a distance (67 of 78). #text(fill: luma(140))[`section_cut_registered.py → videos.csv`]],
) <tab-distance>

Beyond 0.5 mm each bin is essentially one or two plates, and the plates were filmed over different times (@fig-dist a).
The rise from 1–2 mm to 2–4 mm is LPD2412A009 and LPD2412A025 against EPY2412A084, and the last bin is one site with no
same-edge baseline. Only the drop below 0.5 mm (@sec-r-cut) is seen within plates.

#fig("figures/section_cut_distance.png",
  [*(a)* Post/pre speed against distance to the cut along the network; colour = zone, marker = plate (circle
  EPY2412A084, square EPY2412A104, diamond LPD2412A009, triangle LPD2412A025); open = plate baseline. *(b)* Post/pre
  after the first 30 min in each isolated piece against the piece's hypha length; median, bars span the videos; open =
  plate baseline.],
  src: "Working_notebooks/figure3/section_cut_registered_figs.py") <fig-dist>

== The smallest isolated piece slows most, but three pieces cannot test length <sec-r-length>
After the first 30 min, the 4.57 mm piece runs at ×0.18 (3 videos, ×0.17–0.34, plate baseline), the 23.8 mm piece at
×0.66 (13 videos, ×0.55–0.86) and the 72.6 mm piece at ×0.84 (6 videos, ×0.82–0.89) (@fig-dist b). The order is the
one expected if a piece's own growing tips keep drawing flow and more hypha means more of them. It is not evidence for
it. The pieces differ in more than length: the smallest has no same-edge baseline; the late windows are 35–68, 79–326
and 30–58 min; the two large pieces are filmed 1.4 and 3.0 mm from their cuts, the smallest along its whole length. And the two
large pieces are closed only in the STG (@sec-m-pieces): if a hypha the segmentation missed joins either to the colony,
it is a cut hypha rather than an isolated piece.

= Discussion <sec-discussion>
Placed on the network by registration, the cut-day videos give three results. Right at a cut (within 0.5 mm along the
network), flow runs at a median ×0.19 of its pre-cut speed (9 videos on three plates, ×0.07–0.84) and is still at
×0.10–0.65 after 2 h (@sec-r-cut).
Further away, on the same STG edge, flow dips within half an hour, deepest at ×0.11–0.26 on LPD2412A025 1.4 mm from its
cut, and recovers only partly: ×0.78–0.86 at 3 h and ×0.55–0.79 at 5 h there, ×0.82–0.89 at 1 h on EPY2412A084
(@sec-r-time). The one small isolated piece keeps slowing, to ×0.18 after an hour, where the two large pieces hold at
×0.66 and ×0.84 (@sec-r-length). All of this rests on four plates, 12 filming sites and three isolated pieces, two of
them closed only in the STG, and on at most five pre-cut videos per site.

== A same-edge baseline removes site differences but not drift <sec-d-baseline>
Speeds differ between neighbouring hyphae by up to 1.7× on one plate: LPD2412A025's pre-cut videos run at 3.4–3.8 µm/s
on edge 8643 and at 2.1 µm/s on edge 9054, 0.65 mm closer to the cut. A ratio over another site's baseline carries that
difference. On a same-edge baseline it does not, but it still carries drift in time: LPD2412A009's edge 7504 slowed by
half in the 20 min before its cut (@sec-r-connected), and a single pre-cut edge can vary 2× between videos minutes apart
(LPD2412A025 edge 9054, 4.5 and 2.1 µm/s at −15 and −11 min). Same-edge ratios are the best available, not exact.

== Within an edge the position of a video is unknown <sec-d-within>
The registrations say which STG edge a video is on, so a distance measured to the nearer end of the edge (@sec-m-distance)
can be short by up to that edge's length. The 24 edges the videos sit on are 45–890 µm long (median 384 µm); on the
three same-edge sites of @sec-r-time they are 362, 471 and 761 µm, less than the 1.4–3.0 mm distances they carry. The
exception is EPY2412A104, where the cut severs a 3.6 mm edge (3778) 0.17 mm from one end, and most post-cut videos are on it; they are put inside the piece because the longer stub is there, but their
distance to the cut is not known. Registering the video's position along the edge, as the registrator's anchors already
do for one point per video, would give it.

== EPY2412A104's videos 22 and 28 are registered outside the piece, against their labels <sec-d-epy104>
The experimenter's labels put videos 22 and 28 inside EPY2412A104's piece, 0.3–0.9 mm south of the upper cut; they are
registered north of it (@sec-r-align). Either way they are within 0.2 mm of a cut and in the "at a cut" zone; what
changes is whether their ×0.07 and ×0.10 belong to the piece.

= What didn't work
== Placing videos at their recorded stage positions shows recoveries the same edge does not #dead
Placing each video at its recorded stage position on the map and classing it by eye gives two conclusions that do not
survive registration, because the stage positions are off by 0.4–2.3 mm on every cut plate (Motivation). LPD2412A025 "recovers fully, ×1.4 at 174 min": its baseline was the 2.1 µm/s edge 9054, and on the same
edge (8643) the 174 min videos are at ×0.78–0.86. LPD2412A009's site "does not dip, ×1.13": it is on the cut main hypha,
1.9 mm along the network from the cut, and dips to ×0.72–0.89 against its own edge.

== Severing only the nearest edge left EPY2412A104's piece connected #dead
With one edge cut per mark, EPY2412A104's lower mark, which lands 60 µm beside the hypha on a 39.5 µm/px map, severed a
side branch and left the stretch between the cuts joined to the network: no isolated piece at all. Severing every edge
within max(50 µm, 2.5 map pixels) gives the 4.57 mm piece, against 4.3 mm by hand.

== A ±3° map rotation search missed EPY2412A104's −21.5° without an error #dead
Scans and STGs were expected to be near-aligned. EPY2412A104's STG sits at −21.5° to its map; within ±3° the best
correlation score was 12 against 300–515 on the other plates, and its cut marks landed 10 mm from any edge. The search
is now ±45° and the run stops below a score of 50.

== Calling every video piece that misses the frame edge dust dropped real hyphae #dead
Treating every video-graph piece that does not reach the frame edge as dust dropped EPY2412A104's hyphae, whose
extracted edges end up to 330 px short of the frame edge: four of its five pre-cut videos lost all their edges. The
length condition (under 300 px) keeps them.

= Actionable Items
== Compendium and paper
- *Fig 3C text (transport_paper `manuscript/04_fig3_perturbations.typ`)*: "Isolating a section of network slows both
  streams" should be scoped. Flow collapses at the cut, dips and only partly recovers 1.4–3 mm away on the same hypha,
  and keeps falling in the one small isolated piece; the pooled ×0.8 is a mixture of these.
- No compendium entry is affected; this is a biological result.

== Open
- #open *More isolated pieces* of different sizes, filmed inside and away from the cuts for at least 90 min, with
  pre-cut videos on the same edges. Three pieces cannot test length.
- #open *Check the two large pieces on the scans*: are LPD2412A025's 23.8 mm and EPY2412A084's 72.6 mm pieces closed, or
  joined to the colony by a hypha the STG lacks?
- #open *LPD2412A023* has a Y-shaped piece bounded by four cuts, but its STG misses the long hyphae around the cut site in
  every scan, so its videos cannot be registered. It needs re-segmentation.
- #open *Position within an edge* (@sec-d-within): store each video's anchored position, so distance is known on long
  edges.
- #open *To-tip and to-root separately*: the registered speeds are in the STG edge's frame, so each stream can now be
  oriented by the growth direction instead of the direction-free mean.

= Appendix
== Filming sites <tab-sites-sec>
#figure({
  set text(9pt)
  table(columns: 6, align: (left, left, left, left, right, left), stroke: none, inset: (x: 4pt, y: 2pt),
    table.hline(stroke: 0.6pt),
    [plate], [STG edges], [pre-cut videos], [post-cut videos], [to cut (mm)], [zone],
    table.hline(stroke: 0.4pt),
    [EPY2412A084], [174 (451)], [1, 3, 5, 7, 9], [11–39], [2.99], [piece 72.6 mm],
    [EPY2412A104], [3994], [1, 2, 3, 5, 7], [23, 24], [0.28], [at a cut, in piece],
    [EPY2412A104], [3778 (3981, 3982, 3803)], [], [9–20, 26, 30–36], [—], [piece 4.57 mm],
    [EPY2412A104], [3703, 3746], [], [22, 28], [0.17], [at a cut, outside],
    [LPD2412A009], [7504], [1–19], [21–29, 35–56], [1.87], [connected],
    [LPD2412A009], [7972, 7982, 7983, 8029], [], [31, 33, 58], [0.11], [at a cut],
    [LPD2412A009], [12253], [], [60–67], [12.95], [connected],
    [LPD2412A025], [8643 (8778, 8569)], [1–9], [17–27, 33, 37–47, 50–60], [1.43], [piece 23.8 mm],
    [LPD2412A025], [9054], [11, 13, 15], [], [0.78], [piece 23.8 mm],
    [LPD2412A025], [9162], [], [29, 31], [—], [piece, severed edge],
    [LPD2412A025], [8569], [], [35], [1.90], [piece 23.8 mm],
    [LPD2412A025], [9162, 9313, 9314], [], [49], [0.37], [at a cut],
    table.hline(stroke: 0.6pt))},
  caption: text(8.5pt, fill: luma(95))[Registered brightfield videos by the STG edges they were registered onto (edges in
  brackets carry only some of the videos). "—": on a severed edge with the longer stub over 0.5 mm, distance unknown.
  106 videos at 12 sites.],
) <tab-sites>

== Reproduction
#block[#set par(justify: false)
The registrations are the `/flow_measurements` of each session's `stg_store.h5` in `SimonDataBank/paper_plates/<store>/`,
next to its cut-day polyflow runs. The annotated maps are in `fig_outputs/perturbations/cut_annotations/maps/`, the video
inventory with cut times in `fig_outputs/perturbations/cut_video_maps/cut_video_positions.csv`. Then, in transport_paper,
`python Working_notebooks/figure3/section_cut_registered.py` writes `videos.csv`, `cuts.csv`, `alignment.csv` and the
network figure to `fig_outputs/perturbations/section_cut_registered/`, and `section_cut_registered_figs.py` the time
course and distance figures.]
