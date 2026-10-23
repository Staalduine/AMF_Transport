# Science — the transport paper's evidence

One document per biological result behind the transport paper: what the fungus does, measured
with the AMF pipeline. These moved here from
[rhizosphere](https://github.com/Staalduine/rhizosphere) on 2026-10-23, so that the science
lives with the paper that argues it. How the pipeline itself was validated stays in rhizosphere's
[`findings/`](https://github.com/Staalduine/rhizosphere/tree/main/findings).

[`transport_model_decisions.typ`](transport_model_decisions.typ) is the decision record for the
transport model (steps D1 to D3): what was tried, its status, and the evidence, one entry per
decision. Its entries live in [`decisions/`](decisions/) and cite the documents below.

## Building

Each document compiles on its own from this folder: `typst compile <name>.typ`. They share
[`references.bib`](references.bib), a copy of rhizosphere's bibliography, and
[`figures/`](figures/). Figure scripts are under [`scripts/`](scripts/).

## The status line

Every document carries one line in its first five, `// finding: open`, `closed YYYY-MM-DD` or
`superseded-by <relative path>`. `closed` means the document lists no live next steps, a fact
about the document rather than a verdict on the biology. Rhizosphere's `check_links.sh` enforced
this; nothing here checks it yet, so keep the status column below in step by hand.

## The documents

| document | the question it answers | status |
|---|---|---|
| [hyphal_speed_profiles.typ](hyphal_speed_profiles.typ) | How fast does a hypha actually grow, once the metric — paused or moving — and the measurement window — arc or growth-directed-acyclic-graph (DAG) trail — are made explicit, and what does that reveal about growth modes and the colony growth curve? | open |
| [direction_resolved_backflow.typ](direction_resolved_backflow.typ) | In a hypha carrying material in both directions at once, is the flow running back toward the colony's origin the same speed as the flow running outward, or is there a subset of hyphae where the two differ? | open |
| [backflow_model_accuracy.typ](backflow_model_accuracy.typ) | The transport model predicts, for every hypha in a growing colony, how fast material flows back towards the colony's origin. Measured against video on twelve sessions, does the pressure-driven flow, shaped by network geometry, remain accurate beyond the last centimetre behind a growing tip, where does each interpretation fail, can a simpler local model do as well, and does it at least get the range of backflow speeds right? | open |
| [throttled_core_speed_model.typ](throttled_core_speed_model.typ) | Forward flow is motor-based and backflow is pressure-based. Can a model respect that division, derive the backflow from the network's geometry and growth, and show which assumptions control its prediction? | open |
| [forward_speed_models.typ](forward_speed_models.typ) | Inside a hypha, material moves toward the growing tip at a few µm/s, carried by motors. What sets that speed on a given hypha: nothing (one speed everywhere), the distance to the nearest growing tip, the hypha's width, the growth it supplies, or a balance between the motors' force and the drag of the stream returning past them? And how many fitted numbers does each answer cost? | open |
| [radial_flow_structure.typ](radial_flow_structure.typ) | In a hypha carrying material toward the tip and back toward the colony at the same time, do the two streams sit as a central backflow core inside a tipward wall layer — the Poiseuille picture the backflow model is built on — or side by side, and can the model drop that picture? | open |
| [lane_flux_balance.typ](lane_flux_balance.typ) | Can two locally driven plug lanes with zero net flux explain measured backflow speeds, where does zero net flux hold, and can its failure in looping networks be predicted? | open |
| [junction_flux_balance.typ](junction_flux_balance.typ) | Where a hypha branches, a motor-driven stream carries material toward the tips and a return stream carries volume back toward the root. Do these two streams add up across the branches of a junction, and if they do not, is the missing part lane geometry, a sheared return core, growth, or flow that turns round at the junction itself? | open |
| [section_cut_sites.typ](section_cut_sites.typ) | When a scalpel cuts hyphae in a living colony, how much does cytoplasmic flow slow at a given filming site, and does that depend on whether the site ends up in a piece of network the cuts closed off, on its distance to the cut, on the time since the cut, and on how much hypha the closed-off piece contains? | open |
| [loop_circulation_global_model.typ](loop_circulation_global_model.typ) | The paper's backflow model sends the to-root flow through the whole hyphal network with one pressure solve, so on loops a hypha can return more or less than its own to-tip stream. Where does that routing go wrong, does anything in the measured flows show the circulation it predicts, and can the solve be changed so that it matches them? | open |
| [motor_direction_and_lipid_distribution.typ](motor_direction_and_lipid_distribution.typ) | The backflow model has to decide which way the motors run on every hypha and how the lipid that growth consumes is shared where streams meet. Do the motors follow the hydraulic solve or the way the hyphae grew, does the sharing rule matter, and can anything in the videos tell the options apart? | open |
| [microtubule_motors_and_lipid_transport.typ](microtubule_motors_and_lipid_transport.typ) | In arbuscular mycorrhizal fungi lipid moves towards the hyphal tips in a steady stream near 3 µm/s while material returns towards the root faster and more variably; neurons and model fungi move cargo both ways with kinesins and dynein on polarised microtubules, so which of their rules can a model of these hyphae borrow, and are the motors and their regulators conserved in the arbuscular mycorrhizal genomes? | open |

