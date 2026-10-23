#import "../shared.typ": *

== Step D1 — Growth graph and demand

*Input:* the spatio-temporal graph over a time window. *Output:* a simplified graph whose tips
carry a lipid demand, derived from the hyphal volume grown between consecutive timepoints.
Everything downstream is a routing question over this graph, so an error here is not corrected
later — it is distributed.

#entry("D1", [The network handed to the model may contain abandoned tubes], open, kind: feature, tag: "d1-abandoned-tubes")

*Problem.* The model treats every edge as a conduit. But brightfield images the *wall*, not the
cytoplasm, so a septate hypha whose contents have withdrawn is still a visible tube and still an
edge — evidence that a hypha *was* there, not that anything flows through it now. Nothing in the
pipeline distinguishes a live conduit from an abandoned one, and the solver will route through
both. This is the same failure as a phantom loop, arriving through a different door: a path that
physically cannot carry flow.

It is the *cost* of a prior that is otherwise good news. Accretion holds on this data precisely
because walls outlive the cytoplasm that built them (see #link("https://github.com/Staalduine/rhizosphere/blob/main/Priors.typ")[the accretive-growth
prior]), and that same fact is what puts abandoned material in the graph.

*Intent.* Quantify the rate before deciding whether it needs handling. On a young network the
effect is negligible; the concern is a saturated plate carrying weeks of abandoned material,
which is exactly the regime the late frames sit in.

*Implementation as proposed.* The obvious route is closed: separating empty from full tubes on
*optical* grounds at the time-lapse magnification has been tried and does not work. What does
work is high magnification, where the absence of flow is plain — so septation is readable in the
flow recordings, and `registrator` already maps those recordings onto STG edges.

That makes the rate *estimable, not measurable*. Two limits on the estimate, both of which
matter for how it should be reported:

- *The hi-mag subset is not a sample.* Recordings are sited where someone judged the edge
  interesting, so the abandoned fraction among them is not the abandoned fraction of the network.
- *"No flow" is confounded with "not measurable".* An edge whose recording yields nothing and an
  edge that is genuinely dead look alike, and telling them apart is the same question the flow
  stage's coverage metric and its manual re-filtering already exist to manage.

*Evidence.* None. This is a consequence traced from a prior, not a measurement, and the first
useful number would be the abandoned fraction among edges that carry a usable recording — with
the two caveats above attached to it rather than dropped.

*Criteria.* *Yes*, worth handling, if the abandoned fraction among measurable hi-mag edges is
more than a few per cent and rises with plate age — the second half matters more than the first,
because a rate that grows with saturation is the one that invalidates late-series transport
results specifically. *No* if it is negligible, or if it proves indistinguishable from
unmeasurable edges, in which case the honest outcome is a recorded limit on what the transport
model's inputs mean rather than a fix.

#entry("D1", [Width may reach the transport model in the wrong unit], open, kind: cleanup, tag: "d1-width-unit")

*Problem.* `width` is written by amftrack in *pixels at the reference resolution*, and the
conversion to µm is a multiplication by 1.725 that the producing repo documents explicitly —
including the warning that its GeoJSON writes coordinates in µm but `width` in
reference-pixels, so one record carries two units. Three links downstream,
`transport_paper`'s `get_radius_length_um` returns `width / 2.0` and documents the result as
micrometres, with no pixel-size factor on that path; STHype's reader in between rescales
coordinates only and leaves `width` untouched. If that chain holds, every width the transport
model reads is low by 1.725.

Two observations sharpen it. The same repo computes a radius as `width * 0.5 / 2.0` elsewhere,
so no single convention is applied consistently. And a whole-network median of 5.1 read as µm
puts the typical hypha *below* the roughly 8 µm the literature reports, whereas 5.1
reference-pixels is 8.8 µm — suggestive, though not decisive on its own.

*Why this is not merely a relabelling.* Width enters Poiseuille conductance at the *fourth
power*, and the backflow core radius through $a^2 = b^2 - Q\/(theta v_0 pi)$. A uniform scale
error cancels in the *relative* flux distribution the Laplacian solve produces, but the demand
term and the pressure drop do not scale together, so the size of the backflow correction
relative to $v_0$ does not cancel. Conclusions about predicted backflow *magnitude* are
exposed; conclusions about its spatial *pattern* are much less so.

*Evidence.* None yet, and that is why this is `open` rather than `dead` or `shipped` — it is a
code-reading result, not a measurement. It was surfaced by putting two documents side by side
during the documentation migration: the producing repo states the convention, the consuming
repo assumes a different one, and neither had been read against the other.

*Discussion.* Settling it is cheap and should come before further model-versus-measurement
work: print `width` for a single edge next to that edge's length in µm and the plate's
`image_pixel_size`, and check whether the implied diameter is physical. One edge decides it.
If the unit is wrong the correction is one multiplication, but every quoted backflow magnitude
and the width caveats in
#link("https://github.com/Staalduine/rhizosphere/blob/main/findings/transport_inputs.typ")[the measurement-quality finding] need
re-reading afterwards.

This convention has already cost something once: a pipeline document stated the conversion as
`× REFERENCE_PIXEL_SIZE / image_pixel_size`, wrong by 1.725× on PRINCE, and it stood until it
was checked against the code. A unit that is correct on exactly one microscope is the kind that
survives review.

