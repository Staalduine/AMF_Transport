// Shared badges, tracker-card and entry() helpers for the compendium ledgers
// (Accepted/Open/Rejected) and their per-step files.
//
// #import-ed here, never #include-d: only the bindings are needed by the ledger
// files, not rendered content. A module's #show/#set rules only take effect where
// the module is #include-d, not where it's #import-ed -- so the entry-no reset
// rules and the figure-caption rule stay in Pipeline_compendium.typ itself, next
// to the rest of the document-wide #show rules, even though entry-no is defined here.

// ---- status badges -----------------------------------------------------------
#let dead = box(fill: rgb("#f6dedb"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#8a2f22"),
  weight: 600,
  "DEAD",
))
#let shipped = box(fill: rgb("#dcece3"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#1f5a3f"),
  weight: 600,
  "SHIPPED",
))
#let gated = box(fill: rgb("#fdf1d8"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#8a5a10"),
  weight: 600,
  "DEFAULT-OFF",
))
#let open = box(fill: rgb("#eceff0"), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  8pt,
  fill: rgb("#4a5459"),
  weight: 600,
  "OPEN",
))

// ---- kind: is this extra rigour on existing behaviour, or new capability? ----------
#let cleanup = box(stroke: 0.5pt + luma(175), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  7.5pt,
  fill: luma(95),
  weight: 600,
  "CLEANUP",
))
#let feature = box(stroke: 0.5pt + luma(175), inset: (x: 4pt, y: 1pt), radius: 2pt, text(
  7.5pt,
  fill: luma(95),
  weight: 600,
  "FEATURE",
))

// ---- tracker cards, in the margin ---------------------------------------------------
// Issue numbers are deliberately kept OUT of the prose — an entry should read as an argument,
// not as a ticket. They live here instead: what the tracker is being asked for, in the margin,
// where it can be ignored while reading and found when acting.
#let track(refs, body) = place(
  right,
  dx: 3.55cm,
  box(
    width: 3.3cm,
    inset: (x: 5pt, y: 5pt),
    fill: rgb("#faf9f6"),
    stroke: (left: 1.5pt + rgb("#c08a2e")),
    radius: 1pt,
    {
      set par(justify: false, leading: 0.5em)
      set align(left)
      let list = if type(refs) == str { (refs,) } else { refs }
      text(7.3pt, fill: luma(85))[
        #list.map(r => text(weight: 700, fill: rgb("#8a5a10"))[#r]).join(text(fill: luma(160))[ · ])
        #v(-0.45em)
        #body
      ]
    },
  ),
)

// Takes an already-built image (not a path): image()'s own path argument has to be
// resolved at the call site, in the step file that names it, not here -- Typst
// resolves a relative path against the file where the call is lexically written, and
// this function is imported into every step file from a different directory.
#let fig(img, cap) = figure(img, caption: text(8.5pt, fill: luma(95), cap))

#let note(body) = block(
  fill: rgb("#f7f8f8"),
  stroke: (left: 2pt + rgb("#d9a441")),
  inset: 9pt,
  radius: 2pt,
  width: 100%,
  text(9pt, body),
)

// A counter rather than heading numbering, so the section headings stay clean while
// entries carry a number that restarts per step. Its reset show rules live in
// Pipeline_compendium.typ, not here -- see the comment there for why.
#let entry-no = counter("entry")

// `tag` names are `<step>-<keyword>-<keyword>` (lowercase, from the title's content
// words, not its prose) — stable across a title rewrite, unlike a heading number that
// resets per step. Required, no default: an entry with no tag cannot be referenced, which
// is the bug this scheme exists to close. `label()` rather than the parameter name `label`
// to avoid shadowing the builtin. See ./check_labels.sh for the uniqueness check.
//
// The label sits outside the heading's own brackets: `[=== #title #label(tag)]` puts it
// INSIDE the heading body, where it labels the title text rather than the heading, and
// Typst stays silent about it right up until something tries to `link()`/`ref()` the tag
// and gets "cannot reference text". `heading(..)` as a function call, with the label
// concatenated immediately after in the same content block, attaches it to the heading
// element instead — link(label(tag))[..] resolves; @tag does not, since these headings
// carry no numbering.
#let entry(step, title, badge, kind: none, tag: none) = {
  entry-no.step()
  // Read back by the decision register and the title block's counts, so neither is
  // maintained by hand.
  [#metadata((step: step, title: title, badge: badge, tag: tag))<entry-meta>]
  [#heading(level: 3, title)#label(tag)]
  block(above: 0.35em, below: 0.9em)[
    #text(9pt, fill: luma(110))[
      #context entry-no.display("entry 1") · step #step
    ] #h(6pt) #kind #badge
  ]
}
