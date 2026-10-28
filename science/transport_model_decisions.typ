#set document(
  title: "Transport model decisions — what we decided, its status, and the evidence",
  author: "AMF_Transport",
)
#set page(
  paper: "a4",
  // asymmetric: the wide right margin holds the tracker cards (see `#track`)
  margin: (left: 2.0cm, right: 5.2cm, y: 2.4cm),
  numbering: "1",
  footer: context [
    #set text(8pt, fill: luma(120))
    #h(1fr) #counter(page).display("1")
  ],
)
// Helvetica Neue first: macOS Helvetica draws U+00B5 (µ) as an OBLIQUE glyph, so every
// "µm" in the document came out italic against upright text. Neue draws it upright.
#set text(font: ("Helvetica Neue", "Helvetica", "Arial"), size: 10pt, lang: "en")
#set par(justify: true, leading: 0.62em)
#set heading(numbering: none)
#show heading: set block(above: 1.5em, below: 0.8em)
#show heading.where(level: 1): set text(15pt, weight: 600)
#show heading.where(level: 2): set text(12pt, weight: 600)
#show heading.where(level: 3): set text(11pt, weight: 600)
#show heading.where(level: 4): set text(9.5pt, weight: 600, fill: luma(70))
#show heading.where(level: 4): set block(above: 1.1em, below: 0.45em)
#show raw: set text(font: "Menlo", size: 8.5pt)
#show link: set text(fill: rgb("#8a5a10"))
#show table: it => {
  set par(justify: false)
  it
}


#import "decisions/shared.typ": *

#show figure.caption: set align(left)

// Entries are numbered within their step, so the count restarts at every section and every
// step heading — "entry 2 of step A5" rather than "the eleventh entry in the document".
#show heading.where(level: 1): it => {
  entry-no.update(0)
  it
}
#show heading.where(level: 2): it => {
  entry-no.update(0)
  it
}

#align(center)[
  #text(19pt, weight: 700)[Transport model decisions]
  #v(-0.4em)
  #text(13pt, weight: 600, fill: luma(75))[what we decided, its status, and the evidence]
  #v(0.6em)
  #context {
    let es = query(<entry-meta>).map(m => m.value)
    let n(b) = es.filter(e => e.badge == b).len()
    text(9.5pt, fill: luma(95))[#es.len() entries · #n(shipped) shipped, #n(gated) gated, #n(open) open, #n(dead) dead]
  }
]

#note[
  *Moved here from the rhizosphere pipeline compendium on 2026-10-23.* The compendium now covers
  the instrument only (steps A to C: imaging, the spatio-temporal graph and flow analysis). The
  decisions about the transport model, steps D1 to D3, belong with the paper that argues them, as
  do the science documents beside this file that hold their evidence. Entries keep their step
  numbers and tags, so older references still resolve by name. Links to pipeline findings, priors
  and the log point back to
  #link("https://github.com/Staalduine/rhizosphere")[rhizosphere]. Each entry follows the
  compendium's format: Problem, Decision, Evidence, and Criteria for open and gated entries (see
  #link("https://github.com/Staalduine/rhizosphere/blob/main/conventions.md")[conventions.md]).
]

#table(
  columns: (auto, 1fr),
  inset: 5pt,
  stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { (bottom: 0.2pt + luma(220)) },
  [*\#*], [*Step*],
  [D1], [Growth graph \& demand],
  [D2], [GIMF circuit model (forward flow)],
  [D3], [Backflow model],
)

= Decision register <register>

Every entry, in step order, with its status. The title links to the entry.

#context {
  let es = query(<entry-meta>).map(m => m.value)
  let order = ("shipped", "gated", "open", "dead")
  let name(b) = if b == shipped { "shipped" } else if b == gated { "gated" } else if b == open { "open" } else { "dead" }
  let sorted = es.sorted(key: e => e.step + str(order.position(x => x == name(e.badge))))
  set text(9pt)
  table(
    columns: (auto, 1fr, auto),
    inset: (x: 4pt, y: 3pt),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { (bottom: 0.2pt + luma(225)) },
    table.header([*Step*], [*Entry*], [*Status*]),
    ..sorted.map(e => (e.step, link(label(e.tag), e.title), e.badge)).flatten(),
  )
}

= Outstanding decisions <decisions>

The gated entries: built, measured, and off by default in the library, though the paper's current
model runs two of them. Each needs a call rather than more work.

/ #link(<d3-local-return>)[`D3` The return stays in the hypha that drove it].: The repair it was
  gated on, transport_paper\#70, closed 2026-09-23, so what remains is its own test: stay ahead on
  held-out sessions of a plate outside the fitted ones, and lose to a repaired global return
  matching it on all edges. Neither has been scored on the tables rebuilt since. The paper's
  current model runs the global return ($kappa = 0$).
/ #link(<d3-core-floor>)[`D3` A floor on the core radius].: A patch on the demand-derived
  geometry, waiting on the annulus inconsistency it does not resolve: the two-channel measurement
  gives $a\/b = 0.603$, the lipid balance 0.975. Its *No* is a measured geometry replacing the
  derived one.
/ #link(<d3-width-return>)[`D3` The return area narrows with hypha width].: $beta = 0.70$ was
  fitted on the same 1,178 edges it was scored on. The criterion is $beta$ refitted held out by
  plate, as the forward-speed fit was on 2026-10-07, staying near 0.7 with the gain intact. This
  and the floor above both run in the paper's current model while the library default stays off.

#pagebreak()

= Accepted <accepted>

#include "decisions/accepted/d1.typ"

#include "decisions/accepted/d3.typ"

#pagebreak()

= Open <open>

#include "decisions/open/d1.typ"

#include "decisions/open/d3.typ"

#pagebreak()

= Rejected <rejected>

#include "decisions/rejected/d2.typ"

#include "decisions/rejected/d3.typ"
