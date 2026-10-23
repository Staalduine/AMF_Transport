// finding: open
#set document(
  title: "Microtubule motors and bidirectional lipid transport — what neurons and model fungi teach, and what arbuscular mycorrhizal genomes conserve",
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

#let fig(path, cap, src: none, width: 94%) = figure(
  image(path, width: width),
  caption: text(8.5pt, fill: luma(95))[
    #cap
    #if src != none [ #text(fill: luma(140))[#raw(src)]]
  ],
)
#show figure.caption: set align(left)
#show figure: set block(breakable: true)
#show figure.where(kind: image): set figure(placement: auto)

#let question(body) = block(width: 100%, inset: (left: 10pt, y: 5pt),
  stroke: (left: 2pt + luma(160)), text(11pt, style: "italic", fill: luma(60), body))

#let note(body) = block(
  fill: rgb("#f7f8f8"), stroke: (left: 2pt + rgb("#d9a441")), inset: 9pt,
  radius: 2pt, width: 100%, text(9pt, body),
)

#align(center)[
  #set par(justify: false)
  #text(19pt, weight: 700)[Microtubule motors and bidirectional lipid transport]
  #v(-0.3em)
  #text(14pt, weight: 600)[what neurons and model fungi teach, and what arbuscular mycorrhizal genomes conserve]
  #v(0.6em)
  #text(9.5pt, fill: luma(110))[
    transport_paper · a review of 24 full texts and a database check of Glomeromycota proteomes
    (UniProtKB 2026_03), both done 2026-10-07 · \@02746b5
  ]
]
#v(1.2em)

= Introduction

#question[In arbuscular mycorrhizal fungi lipid moves towards the hyphal tips in a steady stream near 3 µm/s while material returns towards the root faster and more variably; neurons and model fungi move cargo both ways with kinesins and dynein on polarised microtubules, so which of their rules can a model of these hyphae borrow, and are the motors and their regulators conserved in the arbuscular mycorrhizal genomes?]

We image growing colonies of the arbuscular mycorrhizal fungus _Rhizophagus irregularis_ and film the cytoplasm inside
chosen hyphae. Almost every filmed hypha carries two streams at once: a to-tip stream that holds close to 3 µm/s, and a
to-root stream on the same hypha that varies from about 2 to 8 µm/s. Both are measured and owned by the transport
paper's two-stream figure; here they are only the phenomenon to be explained. The transport model reads the to-tip
stream as cargo carried by motor proteins along microtubules and the return as volume pushed back by pressure. That
reading borrows its mechanism from neurons and model fungi, where it has been measured. In arbuscular mycorrhizal fungi
(AMF) it has not.

The review follows the mechanism outwards from where it is best known: the tracks and their marks, the motors that
read them, the rule that sets direction, how fungal hyphae use the same machinery, and what is known in AMF
(@sec-results). It closes with a database investigation, not published before, of whether AMF genomes encode the motors
and their regulators; its method is given in full (@sec-method). The Discussion draws what follows for the transport
paper (@sec-discussion).

A few terms recur. A *microtubule* is a polar polymer of tubulin with a fast-growing plus end and a minus end. A
*kinesin* is a motor that walks towards plus ends; kinesin-1 and kinesin-3 are the two families that carry most cargo
in neurons. *Dynein* walks towards minus ends and needs the dynactin complex and an *activating adaptor*, a protein that
links it to a cargo, to move far. The *tubulin code* is the set of chemical modifications of tubulin, chiefly
acetylation of α-tubulin lysine 40 and the removal and re-addition of its C-terminal tyrosine, that motors can read. A
*microtubule-associated protein* (MAP) binds the lattice and can admit or block a motor. An *ortholog* is the same
gene in two species, descended from one ancestral gene.

= Motivation

Three things depend on the answer. The first is the transport model's motor term: one motor speed on every hypha,
with the direction taken from the way the hypha grew, a choice that
#link("motor_direction_and_lipid_distribution.typ")[the motor direction document] tests against the videos. It
assumes tracks of one polarity along a hypha and a motor team that runs one way on them. On mixed tracks, as in a
dendrite, motors alone move cargo both ways and the motor stream need not follow growth. The second is a sentence the
paper wants to write, that kinesin-1 and kinesin-3 are conserved between neurons and AMF; it is true of the genes and
misleading if used to import the neuronal rules (@sec-safe). The third is which experiment comes first, since AMF
cannot be transformed and no track has been mapped, no motor inhibited and no tubulin modification stained in them
(@sec-r-amf).

= Method <sec-method>

The literature was read; the database claims were searched for and scored. Both use the same evidence labels.

== Evidence is graded by how it was obtained, not by where it was printed <sec-m-evidence>

Every external statement carries one of five provenances. A paper is *read* when its main text was read in full,
*searched* when its full text was extracted and only passages matching keywords were read, and *abstract only* when only
the abstract or record was seen. A statement is *database* when it was checked in a database or with a tool on
2026-10-07, with accession, identity and E-value recorded. It is an *inference* when it follows from database results
but was not measured. Of the 24 papers whose full texts were available locally, 21 were read in full or in their
relevant sections and 3 were searched; 5 more full texts were fetched from Europe PMC and searched on the same day.
Labels are given where a paper is cited; a paper cited without one was read. A number that appears only in a figure
that could not be seen is not used.

Database claims carry a confidence. *High* means several independent lines agree: reciprocal best hits, domain
architecture and placement in a distance tree, in several genomes. *Medium* means one line, or low identity. *Low*
means the claim rests on the absence of a hit, or on annotation alone. A verdict is one of four: *supported*, *partly
supported*, *not supported*, or *not checkable* with the data this method can reach.

== The investigation tests presence, orthology and closeness to the neuronal motors <sec-m-claims>

The sixteen claims tested are the rows of @tab-claims: presence and orthology of kinesin-1, kinesin-3, the small
fungal kinesin-3, dynein, LIS1 and dynactin; closeness of the two cargo kinesins to the human neuronal ones, measured
against the model fungi; the dynein adaptors that fungi use (Hook, FTS, FHIP) and that neurons use (BicD, TRAK); the
tubulin-code enzymes, namely αTAT1 for acetylation, a tyrosination cycle in which tubulin tyrosine ligase (TTL)
re-adds the tyrosine and vasohibins and MATCAP remove it, and TTLL ligases and CCP deglutamylases for
polyglutamylation; the neuronal regulators kinesin light chain, MAP7, doublecortin and tau-family MAPs; and any
functional study of these motors in AMF.

The reference proteins were human KIF5A, KIF5B and KIF5C (kinesin-1) and KIF1A, KIF1B, KIF13A and KIF13B
(kinesin-3), and the kinesin-1 and kinesin-3 of _Aspergillus nidulans_ (KinA, UncA, UncB), _Neurospora crassa_
(kinesin heavy chain, NKIN2, Nkin3) and _Ustilago maydis_ (Kin2, Kin3). The _U. maydis_ kinesin-1 is Kin2; the protein
named Kin1 is a kinesin-7 and groups with kinesin-7 in the tree of step 6.

== How the claims were tested, in seven steps <sec-m-steps>

All searches ran on 2026-10-07 from a laptop. BLAST+, MAFFT, HMMER, IQ-TREE and Biopython were all absent from the
system paths and from the orchestrator virtual environment, so every search ran through web services and the two local
steps were done by small standard-library Python scripts written for the purpose. The scripts lived in
`/private/tmp/claude-501/motorcheck/` and were not kept (@app-repro).

+ Choose the genomes, and know their quality. Assembly statistics came from the NCBI Datasets v2 dataset report of
  each accession; proteome lists, BUSCO scores and sequences from UniProtKB release 2026_03 (released 2026-09-02)
  through its REST interface (`rest.uniprot.org`), restricted to taxonomy 214504 (Glomeromycota). At least 12 nuclear
  assemblies with protein sets are public, and UniProt lists 50 Glomeromycota proteomes. The search centred on
  _R. irregularis_ because of its chromosome-level assembly `GCA_026210795.1`
  #cite(<manleyHighlyContiguousGenome2023>) (searched): 42 contigs on 32 chromosome-scale scaffolds, scaffold N50 5.1 Mb, 30,873
  proteins, BUSCO complete 95.8 % with 3.8 % duplicated. Hits were confirmed in _R. clarus_, _Gigaspora rosea_,
  _G. margarita_, _Diversispora epigaea_, _Glomus cerebriforme_ and _Paraglomus_ species, so that a gene is a lineage
  feature and not an assembly accident. Quality varies widely, down to 173,647 contigs for one _G. margarita_ assembly
  and 18.3 % duplicated BUSCO genes for the 2014 _R. irregularis_ one (@tab-assemblies). The 33-chromosome Hi-C
  assembly of the same strain #cite(<yildirirLongReadsHiC2022>) (abstract only), `GCA_020716725.1` with 107 contigs
  and 26,634 genes in the 2023 paper's assembly table, was not among the proteomes searched.

+ Know how the gene models fail before trusting an absence. All AMF proteins here are automatic gene models in
  UniProtKB/TrEMBL; none is a reviewed Swiss-Prot entry and none has been studied experimentally. Five faults turned up
  in the genes being sought. The JGI kinesin-1 model (`U9U3B1`) carries no motor-domain annotation although its
  sequence matches the full motor; the same gene also exists as a separate 337-residue motor fragment (`A0A2P4Q352`);
  the 2014 kinesin-3 model (`A0A015JE42`) fuses a motor, an FHA domain and a protein kinase that the chromosome-level
  assembly splits into two genes (`OCT59_001126`, `OCT59_001127`); the NIBB proteome (`UP000236242`) holds 66,901
  proteins for a genome of about 26,000 to 31,000 genes; and the _R. clarus_ proteome `UP000615446` returned no
  entries from any UniProtKB search. _R. irregularis_ is coenocytic and some strains carry two nucleus types, so
  allelic copies can also appear as duplicate models.

+ Search forward from the reference proteins. Each query was run with EBI Job Dispatcher NCBI-BLAST (BLASTP 2.16.0+)
  against UniProtKB restricted to Glomeromycota (`taxids=214504`), E ≤ $10^(-3)$, 20 hits, first high-scoring pair
  per hit. The queries were the reference kinesins and the human form of every other protein named in the claims, 23
  in all (@app-repro). UniProt keyword, Pfam and PANTHER cross-reference queries over the same taxonomy collected
  further family members, and Pfam family counts by fungal lineage gave a presence pattern for the tubulin-code and MAP
  families.

+ Accept an ortholog only when the reverse search agrees. Every AMF candidate was searched back against
  UniProtKB/Swiss-Prot (E ≤ $10^(-5)$, 20 hits). A candidate was called an ortholog when its best reviewed hits were the
  family of the query that found it (a reciprocal best hit), when its domain architecture matched (UniProt PROSITE
  features PS50067 kinesin motor, PS50006 FHA, PS50003 PH, plus predicted coiled coils), when it appeared in more than
  one AMF genome, and, for the kinesins, when it fell in the right clade of the tree in step 6. Swiss-Prot holds
  curated fungal kinesin-1s but no reviewed fungal kinesin-3, so fungal orthology of the kinesin-3 rests on the tree
  and on identity to UncA, NKIN2 and Kin3.

+ Measure identity over the motor domain, where function is conserved. A kinesin tail diverges quickly, so
  whole-length identity understates kinship. Motor-domain boundaries were the UniProt "Kinesin motor" feature
  (PROSITE-ProRule for reviewed entries, PROSITE PS50067 for TrEMBL entries). Each pair of motor domains was aligned
  globally (Gotoh algorithm, BLOSUM62 matrix from the NCBI BLAST matrices directory, gap open 11, gap extend 1) by a
  standard-library script with a built-in self-check. Percent identity is identical columns over alignment columns with
  terminal gaps removed; similarity counts positive BLOSUM62 scores the same way. EBI Clustal Omega computed a
  percent-identity matrix of the same 50 motor domains as a cross-check (job
  `clustalo-R20261007-084505-0257-3647897-p1m`); the two agree within about 4 percentage points. For scale, human KIF5B
  is 41 to 43 % identical over the motor domain to human kinesins of other families (KIF1A, KIF4A, KIF11) and 86 to
  87 % to its own paralogs.

+ Place the motors in a tree, as a consistency check only. A second standard-library script built a neighbour-joining
  tree of the 50 motor domains (human, model-fungal and AMF kinesins of families 1, 2, 3, 4, 5, 6, 7, 8, 13 and 14) on
  Kimura-corrected distances $d = -ln(1 - p - 0.2 p^2)$, where $p$ is the fraction of non-identical columns. It has
  no bootstrap or other support value and no outgroup, so it is read only for clade membership; it is not a
  phylogeny (@sec-limits).

+ Read diagnostic motifs and search the literature. The kinesin-1 tail was searched for the IAK motif that folds the
  motor into its autoinhibited state, the kinesin-3 loop 12 for the lysine-rich K-loop that gives KIF1A its
  microtubule affinity, and every full-length α-tubulin for lysine 40 and its C-terminal residue. The functional
  literature was searched in Europe PMC with seven queries (@app-repro); titles and abstracts were screened.

NCBI BLAST through its URL interface and JGI MycoCosm were tried and dropped (@sec-deadends). FungiDB was reachable;
only its organism list was fetched.

== An absence in automatic gene models is weak evidence <sec-m-absence>

The searches read proteomes, not genomes. A gene that every annotation missed, split or truncated is invisible to them,
and step 2 found such faults in the very genes sought. No translated search of the genome assemblies (tblastn) was
run. So a missing hit is reported as "not found", never as "absent from the genome", and a claim resting on an absence
gets at most medium confidence. A presence call is sturdier: it needs one good model, and it was required in more than
one genome.

= Results <sec-results>

The first four sections report published measurements, from neurons to AMF; the fifth reports the database
investigation. Interpretation is left to @sec-discussion.

== Direction is set by track polarity times the active motor <sec-r-rule>

=== Tracks: uniform in axons, mixed in dendrites, and marked by acetylation and tyrosination

A kinesin moves to the plus end and dynein to the minus end of the microtubule it walks on, so the direction of a cargo
is the product of which way the track points and which motor is active (@fig-rule a). In axons nearly all
microtubules point plus-end-out @buruteCellularLogisticsUnraveling2019. In vertebrate dendrites about half point
minus-end-out, and single bundles are 2- to 4-fold enriched for one orientation. The two populations are marked
differently: the stable, acetylated microtubules are mostly minus-end-out (66 % after 4 µM nocodazole for 2.5 h
removed the dynamic ones) and the dynamic, tyrosinated ones mostly plus-end-out
@tasDifferentiationOppositelyOriented2017. MAPs add a second layer of marks: MAP7 recruits and activates kinesin-1;
tau and MAP2 inhibit kinesin-1 and kinesin-3; doublecortin inhibits kinesin-1 and permits kinesin-3; MAP9 activates
kinesin-3 and inhibits dynein @iwanskiCellularCartographyAtlas2023.

#fig("figures/direction_rule.png", [Schematic of the direction rule. Grey lines are microtubules with their plus (+) and
minus (−) ends marked; filled circles are cargoes with the motor that carries them and its direction of travel. (a) A
uniform array, all plus ends towards the tip or the axon terminal: kinesin cargo goes out and dynein cargo comes back.
(b) A mixed array: one kinesin moves its cargo either way, depending on the track it binds. (c) The transport
model's working picture of one hypha: a motor-borne stream to the tip along tracks near the wall, and a pressure-driven
return to the root in the core. The arrangement of the tracks in (c) is the hypothesis, not a measurement.],
src: "scripts/microtubule_motors_and_lipid_transport/direction_rule_fig.py", width: 72%) <fig-rule>

=== Motors: kinesin-1 and kinesin-3 prefer different marks, and dynein needs a tyrosinated start

A rigor mutant of kinesin-1 binds the acetylated microtubules of dendrites, and a kinesin-3 rigor is enriched 1.5- to
2-fold on the tyrosinated ones, so kinesin-1 cargo is kept out of dendrites and kinesin-3 cargo is not
@tasDifferentiationOppositelyOriented2017. The preference is cellular: single kinesin-1 molecules are insensitive to
acetylation and detyrosination in vitro, while dynein–dynactin–BicD2 needs a tyrosinated tail to start a run, through
the CAP-Gly domain of dynactin p150, and keeps walking once started @jankeTubulinCodeIts2020. The motors also differ in
reach. Dimeric mammalian kinesin-3s run about 10 µm per encounter #cite(<soppinaDimerizationMammalianKinesin32014>)
(abstract only). Single _Neurospora_ kinesin-1 molecules run 1.75 µm on average (n = 182) against 0.83 µm (n = 229)
for human kinesin-1 under the same conditions #cite(<lakamperSingleFungalKinesin2003>) (abstract only). Truncated
_Drosophila_ kinesin-1 walks over extracted neuronal microtubules at 0.75 ± 0.30 µm/s (mean ± standard deviation)
@tasDifferentiationOppositelyOriented2017.

=== Teams: opposing motors on one cargo reverse often, and small polarity biases are enough

Most neuronal cargoes carry both kinds of motor. Purified neuronal vesicles carry means of 2.8 dyneins, 0.45 kinesin-1
and 1.7 kinesin-2 each, and 86 % reverse within 40 s @hendricksMotorCoordinationTugofwar2010. Removing or inhibiting
one motor often slows both directions, a "paradox of co-dependence" seen for _Drosophila_ lipid droplets and _unc-104_
mutants among others; kinesin-1 keeps walking under load, whereas kinesin-2 and kinesin-3 tend to detach
@hancockBidirectionalCargoTransport2014. On a mixed array a single motor type moves cargo both ways (@fig-rule b):
coupling an axonal cargo to dynein sends it into dendrites #cite(<kapiteinMixedMicrotubulesSteer2010>) (abstract only).
A strong bias is not needed: in the model of #cite(<tasDifferentiationOppositelyOriented2017>, form: "prose") an
outward probability of 0.55 to 0.6 per step accumulates kinesin cargo distally, and oocytes and planar-polarised
epithelia run their transport on biases of 54 to 70 % @buruteCellularLogisticsUnraveling2019. Which motors on a cargo
are active is set by its adaptor, and several adaptors exist only in neurons: kinesin light chain on kinesin-1, TRAK on
mitochondria, BicD on dynein. In _Drosophila_ embryos kinesin-1 drives lipid droplets plus-end, the single-motor stall
force in vivo is about 2.6 pN, and halving kinesin dose neither shortens runs nor slows them
@shubeitaConsequencesMotorCopy2008; segment means are 0.29 to 0.48 µm/s over 0.8 to 1.5 µm
@welteDevelopmentalRegulationVesicle1998.

== Fungal hyphae run the same machinery on short uniform arrays <sec-r-fungi>

=== Plus ends point to the tip between the tip and the first nucleus

In _A. nidulans_, 98.7 ± 0.5 % (mean ± standard error) of microtubules between the hyphal tip and the most proximal
nucleus have their plus ends towards the tip, measured with GFP-tubulin and the plus-end marker EB1, and the array
stays polarised in motor deletion strains @eganLis1InitiationFactor2012. In _U. maydis_ the uniform zone reaches about
12 µm from a tip or septum, with bipolar bundles in between @eganMicrotubulebasedTransportFilamentous2012
@bielskaHookAdapterThat2014. No fungal paper reviewed here maps polarity over millimetres.

=== Kinesin-3 and dynein carry endosomes at 1.6 to 2.7 µm/s, and other organelles hitchhike on them

Filamentous fungi typically have 10 to 12 kinesins, two or three of them transport motors of the kinesin-1 and
kinesin-3 families, and one dynein for nearly all minus-end movement @eganMicrotubulebasedTransportFilamentous2012.
Kinesin-3 carries early endosomes to the tip; kinesin-1 delivers dynein to the plus ends, where it is loaded
#cite(<lenzDyneinLoadingZone2006>) (abstract only); and the Hook adaptor, with FTS and FHIP, binds both motors
@bielskaHookAdapterThat2014 @zhangHookANovelDynein2014. In _U. maydis_ one dynein reverses an endosome carrying four
to five kinesin-3 dimers, 74 % of endosomes reverse before reaching the tip (n = 321), and dynein runs have a median
of 12.36 µm @schusterTransientBindingDynein2011. Without HookA no endosome moves in _A. nidulans_
@zhangHookANovelDynein2014.

Endosomes move at 2.62 ± 0.83 µm/s to the tip and 2.66 ± 0.77 µm/s back in _A. nidulans_ (means ± standard deviation,
n = 250) @eganLis1InitiationFactor2012, at 1.65 ± 0.40 µm/s away from the tip in another _A. nidulans_ study
(n = 16) @zhangHookANovelDynein2014, and at about 2 µm/s in _U. maydis_; a _Neurospora_ kinesin carries cargo at 2.1
to 3.8 µm/s @steinbergCellBiologyHyphal2017.

Peroxisomes, lipid droplets and the endoplasmic reticulum have no motors of their own in _U. maydis_; they hitchhike on
moving endosomes, and benomyl stops their directed runs while latrunculin does not
@guimaraesPeroxisomesLipidDroplets2015. At any moment 7.26 ± 5.55 % of lipid droplets are in a directed run, runs last
4.78 ± 3.61 µm, and 63.6 % move paired with a leading endosome @guimaraesPeroxisomesLipidDroplets2015. In a second
study 4.32 ± 4.05 % of lipid droplets are directed and about 95 % of peroxisomes and lipid droplets move diffusively,
a motion that needs ATP and moving endosomes @linActiveDiffusionMicrotubulebased2016. In _A. nidulans_ peroxisomes
also hitchhike on endosomes, through the linker PxdA #cite(<salogiannisPeroxisomesMoveHitchhiking2016>) (abstract
only), and move at 1.66 ± 0.77 µm/s (n = 50) to the tip and 1.63 ± 0.87 µm/s (n = 48) back, slower than the
endosomes that carry them @eganLis1InitiationFactor2012.

=== Fast cytoplasmic flow in fungi is not motor-driven

_Neurospora_ cytoplasm flows at about 5 µm/s on average and up to 60 µm/s; nuclei keep moving outward in motor
mutants and under cytoskeletal drugs @steinbergCellBiologyHyphal2017 @ramos-garciaCytoplasmicBulkFlow2009. In
_A. niger_, nocodazole and cytochalasin together slowed streaming by about 25 % @steinbergCellBiologyHyphal2017.

== In arbuscular mycorrhizal fungi lipid moves both ways, and no motor has been tested <sec-r-amf>

=== Microtubules have been seen only in fixed hyphae

In germ tubes of _Funneliformis mosseae_ (then _Glomus mosseae_), fixed by quick-freezing, microtubules lie in the
cortical and central cytoplasm, reach the extreme tip and continue into branches, with nuclei along them; actin was
labelled only in hyphae elicited by a host root @astromCytoskeletalComponentsArbuscular1994. In _Glomus
intraradices_ inside tomato roots, microtubules form longitudinal bundles in extraradical and intercellular hyphae and
arbuscule trunks, thinner filaments in fine branches, and none in nucleus-filled vesicles
@timonenMicrotubulesMycorrhizalFungus2001; "orientation" there means alignment with the hypha, not polarity. Neither
study measured polarity, used a drug or imaged live cells. AMF α- and β-tubulins group at the base of the fungi and
resemble those of chytrids #cite(<corradiArbuscularMycorrhizalFungi2004>) (abstract only), and one of two β-tubulin
genes is down-regulated in symbiotic extraradical hyphae relative to germinating spores of two _Glomus_ species but not
of _Gi. rosea_ #cite(<rhodyDifferentialRNAAccumulation2003>) (abstract only). No expression study of an AMF motor gene
was found.

=== Lipid bodies move with the stream at up to 4 µm/s, and some move against it

#cite(<bagoTranslocationUtilizationFungal2002>, form: "prose") imaged Nile-Red-stained lipid bodies by two-photon
microscopy, with frames 1 s long every 1 to 5 s. In runner hyphae the fastest lipid movement was 4 µm/s in
_G. intraradices_ (now _R. irregularis_) and 8 to 11 µm/s in _Gigaspora margarita_. Most lipid bodies moved with the
cytoplasmic stream, some were anchored and some moved against it; it is in germ tubes, not in runner hyphae, that
movement often did not follow the streaming. In _G. intraradices_ lipid filled about 24 % of hyphal volume near the
root, falling to 0.5 % at the colony front. The authors suggest that movement independent of the stream may run on
microtubules and did not test it. In _Gi. margarita_ small particles, lipid bodies of 0.6 to 1.0 µm and nuclei move
independently at up to about 5 µm/s, in both directions, along unlabelled thread-like tracks
@uetakeExtensiveTubularVacuole2002.

=== No genetic, drug or live-imaging study of AMF motors exists

Efforts to visualise the AMF cytoskeleton "have been nearly absent"; organelles are reported at 2 to 11 µm/s and flow
above 50 µm/s @cargillCellularAnatomyArbuscular2025. Motors and pressure "have been rarely examined" in AMF
@kokkorisMycelialDynamicsArbuscular2026; that review's 20 µm/s average particle speed with bursts to 120 µm/s carries no
citation and is not used here. The 2013 and 2014 genome papers do not mention motors
@tisserantGenomeArbuscularMycorrhizal2013 @linSingleNucleusGenome2014, and the 2019 comparison lists kinesins only
among protein families whose abundance differs between species @morinComparativeGenomicsRhizophagus2019. Europe PMC
holds no genetic, silencing, drug or live-imaging study of an AMF motor or of microtubule-based transport in AMF.
Host- and virus-induced silencing works in _R. irregularis_ and has targeted the HOG1 MAP-kinase cascade
#cite(<wangHostVirusinducedGene2023>) (abstract only). The benzimidazole albendazole, a β-tubulin polymerisation
inhibitor in animals, reduced root colonisation and symbiotic function of _R. irregularis_; the study scored
colonisation in ink-stained roots and did not image the cytoskeleton #cite(<gkimprixiVeterinaryDrugAlbendazole2023>)
(searched).

== The genomes encode kinesin-1, kinesin-3 and dynein, but not the neuronal regulators <sec-r-check>

From here every statement is a database result of @sec-method unless marked otherwise. The verdicts are in
@tab-claims; the subsections give the evidence for each block of rows.

#figure(
  text(8.5pt, table(
    columns: (2.5fr, 1.05fr, 0.75fr, 3.2fr),
    align: (left, left, left, left),
    stroke: 0.4pt + luma(190),
    inset: 4pt,
    table.header[*claim*][*verdict*][*confidence*][*evidence*],
    [A kinesin-1 ortholog is encoded in each AMF genome checked], [supported], [high],
      [one full-length heavy chain of 888 to 953 residues in 6 species of 4 genera; reciprocal best hits are kinesin heavy chains; IAK tail motif; kinesin-1 clade],
    [Its motor domain is as close to human KIF5 as the model fungi's are], [supported], [high],
      [52 to 57 % identity to KIF5A/B/C, against 53 to 57 % for _N. crassa_, _A. nidulans_ and _U. maydis_],
    [Kinesin-1 is regulated as in neurons, with a light chain], [not supported], [low],
      [no kinesin light chain found; KLC1 hits only repeat fragments],
    [A kinesin-3 ortholog of the UNC-104/KIF1 type is encoded], [supported], [high],
      [motor, FHA and PH domains in KIF1A order in 5 species of 3 genera; groups with UncA, NKIN2 and Kin3],
    [Its motor domain is as close to KIF1A as the model fungi's are], [supported], [high],
      [66 to 67 % to KIF1A/1B, against 60 to 63 % for UncA, Kin3 and NKIN2],
    [The small fungal kinesin-3 (Nkin3/UncB) is encoded], [not supported], [low],
      [no AMF motor groups with UncB/Nkin3; absence in gene models only],
    [Dynein heavy chain, LIS1 and dynactin are encoded], [supported], [high],
      [heavy chain 56 to 57 % to DYNC1H1 over about 4,700 residues; LIS1 58 to 60 %; p150 best hit _N. crassa_ Ro-3],
    [The fungal dynein adaptor Hook–FTS–FHIP is encoded], [supported], [medium],
      [all three present, at 20 to 31 % identity to the human proteins],
    [The neuronal adaptors BicD and TRAK are encoded], [not supported], [low],
      [only partial coiled-coil hits; no Milton/TRAK Pfam domain],
    [Tubulin can be acetylated], [supported], [high (genes), medium (function)],
      [lysine 40 in a human-identical context; an αTAT1 ortholog, 40 to 49 % to animal ATAT1],
    [A tyrosination–detyrosination cycle exists], [not supported], [medium],
      [α-tubulin ends in tyrosine, but no TTL ortholog, no vasohibin, no MATCAP found],
    [Tubulin is polyglutamylated], [not supported], [low],
      [no TTLL glutamylase or CCP deglutamylase found],
    [The neuronal MAP code (MAP7, doublecortin, tau) is present], [partly supported], [medium],
      [MAP7 and doublecortin not found; one tau/MAP2/MAP4-repeat protein, 31 % to human tau, function unknown],
    [The kinesin assignments hold in a supported phylogeny], [not checkable], [—],
      [only a distance tree without support values or outgroup was built],
    [The AMF kinesin-3 is superprocessive like KIF1A], [not checkable], [—],
      [its K-loop is shorter and interrupted, as in UncA and NKIN2; motility never measured],
    [Any of these motors has been tested functionally in AMF], [not supported], [high],
      [no genetic, silencing, drug or live-imaging study found; absence of literature cannot be proven],
  )),
  caption: text(8.5pt, fill: luma(95))[Claims about motor conservation in AMF, with the verdict and confidence defined in
  @sec-m-evidence. Identities are over the motor domain unless a length is given. "Found" and "not found" refer to
  UniProtKB gene models, not to genome sequences (@sec-m-absence).],
  kind: table,
) <tab-claims>

=== Kinesin-1: one ortholog per genome, its motor domain 52 to 57 % identical to KIF5

Each AMF genome checked has one full-length kinesin-1 heavy chain: 906 residues on chromosome 13 of _R. irregularis_,
and 953, 925, 888, 947 and 907 residues in _R. clarus_, _G. rosea_, _G. margarita_, _D. epigaea_ and _Paraglomus
occultum_. All 20 of its best Swiss-Prot hits are kinesin heavy chains: first that of the mucoromycete
_Syncephalastrum racemosum_ (68 % over 904 residues), then four ascomycete heavy chains (58 to 59 %), then the animal
KIF5s (34 to 35 %, E ≈ $10^(-165)$); human KIF5B finds exactly these proteins first (35 to 36 %, E ≈ $10^(-167)$). The
motor domain spans residues 8 to 331, coiled coils follow, and the tail carries the autoinhibitory IAK motif in the
fungal context R-IAK-PLRGG (residue 892 in _R. irregularis_), against the SAQ-IAK-P context of human KIF5A, KIF5B and
KIF5C. In the tree the smallest clade containing all 11 kinesin-1s (3 human, 3 model-fungal, 5 AMF) contains nothing
else, and the AMF proteins sit in the fungal branch.

Over the motor domain the AMF kinesin-1s are 52 to 57 % identical to KIF5A, KIF5B and KIF5C, the model fungi 53 to 57
% (@tab-identity), and the AMF motors 66 to 78 % to the fungal kinesin-1s; Clustal Omega gives 54.5 to 56.9 % for the
AMF–KIF5 pairs. Over the whole protein identity to the KIF5s falls to 34 to 36 %.

#figure(
  text(8.5pt, table(
    columns: (2.4fr, 0.6fr, 0.6fr, 0.6fr, 0.8fr, 0.8fr, 0.8fr),
    align: (left, right, right, right, right, right, right),
    stroke: 0.4pt + luma(190),
    inset: 4pt,
    table.header[*kinesin-1 motor domain, identity (%)*][*KIF5A*][*KIF5B*][*KIF5C*][*_N. crassa_ heavy chain*][*_A. nidulans_ KinA*][*_U. maydis_ Kin2*],
    [_R. irregularis_], [55], [56], [57], [76], [77], [70],
    [_D. epigaea_], [56], [56], [57], [76], [78], [69],
    [_G. margarita_], [52], [52], [52], [70], [72], [66],
    [_P. occultum_], [54], [54], [55], [75], [77], [69],
    [_N. crassa_ heavy chain], [57], [57], [57], [—], [87], [70],
    [_A. nidulans_ KinA], [55], [56], [56], [87], [—], [71],
    [_U. maydis_ Kin2], [54], [53], [54], [70], [71], [—],
  )),
  caption: text(8.5pt, fill: luma(95))[Motor-domain identity of kinesin-1, by global alignment (BLOSUM62, gap open 11,
  extend 1; @sec-m-steps step 5). The first four rows are AMF, the last three model-fungal references; _G. rosea_ and
  _R. clarus_ score 56 % to KIF5B. Human kinesins of different families are 41 to 43 % identical.],
  kind: table,
) <tab-identity>

=== Kinesin-3: an UNC-104-type ortholog, 66 to 67 % identical to KIF1A over the motor

Each AMF genome checked has a kinesin-3 of about 1,600 residues (1,601 on chromosome 11 of _R. irregularis_) with a
motor domain (residues 5 to 359), an FHA domain (509 to 560) and a C-terminal PH domain (1,487 to 1,585), the layout
of KIF1A. Its best Swiss-Prot hits are UNC-104/KIF1A of insects and nematodes, then human KIF1A (44 % over 1,025
residues), and human KIF1A finds it first (44 to 45 %, E-value 0). In the tree the eight AMF kinesin-3s form one
clade with _A. nidulans_ UncA, _N. crassa_ NKIN2 and _U. maydis_ Kin3, inside a kinesin-3 clade that also holds human
KIF1A, KIF1B, KIF1C, KIF13A, KIF13B and KIF16B and the small fungal UncB and Nkin3. Over the motor domain the AMF
kinesin-3s are 66 to 67 % identical to KIF1A and KIF1B and 56 to 61 % to KIF13A and KIF13B; the model-fungal ones
score 60 to 63 % to KIF1A, and the AMF motors are 70 to 73 % identical to UncA and NKIN2. Clustal Omega gives 69.6 to
70.8 % for AMF against KIF1A.

A second, AMF-specific kinesin-3 of about 750 residues, with motor and FHA but no PH domain, occurs in both
Glomeraceae and Gigasporaceae and on a different chromosome from the first, so it is not an assembly duplicate
(inference); its motor is 78 to 88 % identical to the UNC-104-type motor and 62 % to KIF1A. No ortholog of the small
fungal kinesin-3 (Nkin3, UncB) was found: both queries find the KIF1-type proteins first (46 to 53 %), and no AMF motor
groups with them. The K-loop that makes KIF1A bind microtubules tightly is present in a shorter, interrupted form, as
in UncA and NKIN2.

=== Dynein, LIS1 and dynactin are clear; the fungal endosome adaptor is present at low identity

The _R. irregularis_ cytoplasmic dynein heavy chain (4,674 residues) is 56 to 57 % identical to human and mouse
DYNC1H1 over about 4,720 residues (E-value 0), and equally close to _A. nidulans_ NudA and _N. crassa_ Ro-1. LIS1 (420
residues) is 58 to 60 % identical to the _U. maydis_ and vertebrate proteins. Dynactin p150 (1,334 residues, with a
CAP-Gly domain) has _N. crassa_ Ro-3 as best hit (31 %, E ≈ $10^(-168)$) and human DCTN1 next (29 to 30 %); dynactin
subunits 4, 5 and 6 are annotated by name only. The Hook protein (733 residues) is 25 to 26 % identical to human HOOK3
and HOOK1 (E ≈ $10^(-63)$), and human HOOK3 finds Hook-domain proteins in four AMF genera (26 to 27 %). FTS was found in
_G. cerebriforme_ (28 to 31 % to AKTIP, E ≈ $10^(-18)$) and two FHIP paralogs carry the FHIP domain (20 to 25 %).
Swiss-Prot holds no fungal Hook, so these comparisons are with human proteins only. Human BICD2 and TRAK1 hit only
coiled-coil stretches or fragments (20 to 25 %, partial), and no Glomeromycota protein carries the Milton/TRAK Pfam
domain. Miro, the mitochondrial anchor of TRAK in neurons, is present (634 residues, 51 to 60 % to fungal Gem1).

=== The tubulin code: acetylation can be written, tyrosination cannot be cycled by any enzyme found

All 22 full-length α-tubulins found, over 15 Glomeromycota species, carry lysine 40 in the human-identical context
QMPSDK and end in a tyrosine. The _R. irregularis_ α-tubulin is 94.5 % identical to human TUBA1A over its whole length,
against 79 % for _A. nidulans_ TubA, 72 to 74 % for _Saccharomyces cerevisiae_ Tub1 and 81 to 88 % for Mucoromycota
α-tubulins. The family occurs in about 15 independent assemblies, single-nucleus genomes included.

An αTAT1 ortholog of 312 residues is 40 to 49 % identical to animal and _Tetrahymena_ ATAT1 (E ≈ $10^(-45)$), and the
αTAT1 Pfam family has 13 entries in Glomeromycota, 13 in Chytridiomycota, 3 in Mucoromycota and none in Ascomycota or
Basidiomycota. αTAT1 was described as conserved exclusively in ciliated organisms
#cite(<shidaMajorAlphatubulinK402010>) (abstract only); AMF have no flagellated stage. A class IIb histone
deacetylase and a SIRT2-type sirtuin are present, neither a tubulin deacetylase by sequence.

The only TTL-family gene in _R. irregularis_ is a yeast PBY1-type protein: its best hits are _S. pombe_ C12B10.04 and
_S. cerevisiae_ PBY1 (35 to 42 %), and human TTL scores 28 % over 266 residues (E ≈ $10^(-18)$). Human VASH1 and
MATCAP1 give no hit at E < $10^(-3)$, and the vasohibin Pfam family has no Glomeromycota entry. Human TTLL1, TTLL4 and
TTLL6 hit only the same PBY1-type protein, and the deglutamylase AGBL5 gives no hit. _A. nidulans_ has a detyrosinated
microtubule subset that its kinesin-3 prefers, with no enzyme identified #cite(<zekertAspergillusNidulansKinesin32009>)
(abstract only).

=== Neuronal regulators are not found, except one tau-family protein

Human KLC1 hits only short tetratricopeptide-repeat fragments (25 to 33 %, partial). MAP7 and doublecortin give no hit
and no Glomeromycota entry in their Pfam families. One protein of 690 residues carries the tau/MAP2/MAP4 repeat and is
31 % identical to human tau over 383 residues (E ≈ $10^(-34)$); a _Paraglomus_ homolog scores 37 %. The repeat family
has 22 Glomeromycota, 29 Mucoromycota and 14 Chytridiomycota entries and none in Ascomycota or Basidiomycota.

= Discussion <sec-discussion>

AMF genomes encode one clear kinesin-1 and one clear UNC-104/KIF1-type kinesin-3, with motor domains 52 to 57 % and 66
to 67 % identical to human KIF5 and KIF1A, as close as the model fungi are, and dynein, LIS1, dynactin and, at 20 to
31 % identity, the fungal Hook–FTS–FHIP adaptor (@sec-r-check). The neuronal regulators were not found: kinesin light
chain, TRAK, BicD, MAP7, doublecortin, a tyrosination cycle; acetylation can be written and one tau-family protein
exists. Fungal arrays are uniform only to about 12 µm or the first nucleus behind a tip, endosomes run at 1.6 to
2.7 µm/s and lipid droplets hitchhike in runs of about 5 µm (@sec-r-fungi); in AMF lipid moves both ways at up to 4
µm/s in _R. irregularis_ and 8 to 11 µm/s in _Gi. margarita_, and no motor has been tested (@sec-r-amf). Every AMF
sequence result rests on automatic annotation of proteomes, one database release and a tree
without support values (@sec-limits).

== Speed makes the to-tip stream motor-compatible; its length is what no fungus has shown <sec-d-streams>

The to-tip stream at 3 µm/s lies at the top of the fungal motor range, 1.6 to 3.8 µm/s for endosomes and kinesin
cargo, and well above animal kinesin-1 on extracted microtubules (0.75 µm/s) and _Drosophila_ lipid droplets (0.29 to
0.48 µm/s). Fungal kinesin-1 is also the more processive (1.75 against 0.83 µm per run), so a fast, fungal-type motor
is plausible on speed alone. The to-root stream on the same hypha, reaching 8 µm/s, and lipid in _Gi. margarita_ at 8
to 11 µm/s are beyond any motor run and fit carriage by flow, which is how the fungal field already reads fast
streaming (@sec-r-fungi). So the transport model's split, motor-borne to the tip and pressure-driven back, is the one
the literature supports by speed (inference).

Length is the gap. Single motors run micrometres (kinesin-3 about 10 µm), dynein-driven endosomes a median of 12 µm,
hitchhiked lipid droplets about 5 µm, and only a small fraction of droplets is in a run at any moment. The AMF stream
holds for millimetres in hyphae with nuclei all along, far beyond any uniform fungal array mapped. It needs either
uniform tracks over a length no fungus has shown, or a regulated relay on a mixed array, as _U. maydis_ endosomes run
up to 90 µm by handing over between kinesin-3 and dynein #cite(<schusterKinesin3DyneinCooperate2011>) (searched; run
lengths in its figures not verified). AMF lipid bodies are 0.6 to 6 µm, against about 0.3 µm droplets in _U. maydis_,
so hitchhiking on endosomes is a weak default for them, to be tested rather than assumed (inference).

== Three neuronal rules carry over to these hyphae, and four do not <sec-borrow>

Three rules carry over, because they rest on the core machinery that is present. Direction is track polarity times
active motor, so a tipward stream needs plus-end-tipward tracks under it, and a mixed array would let one motor type
move cargo both ways (@fig-rule). A small polarity bias suffices to accumulate cargo, so tracks need not be perfectly
uniform for a net tipward stream. And opposing motors on one cargo are co-dependent, so inhibiting one motor will
rarely slow only one direction @hancockBidirectionalCargoTransport2014.

Four do not. Kinesin-1 cannot be assumed to be steered by a light chain or by MAP7, neither of which was found; fungal
kinesin-1 works without a light chain. Tyrosination cannot be assumed to gate where dynein starts: with no cycle found,
every microtubule may carry the tyrosine, and a mark everywhere tells no tracks apart. Mitochondria cannot be assumed
to move by TRAK. And the dendritic split, kinesin-1 on acetylated and kinesin-3 on tyrosinated microtubules
@tasDifferentiationOppositelyOriented2017, has only its acetylation mark available in AMF, so a division of labour by
track cannot be presumed.

== The motors may be called conserved, the neuronal rules may not <sec-safe>

#block(breakable: false)[The sentence the evidence supports is this:

#note[The genomes of arbuscular mycorrhizal fungi (_Rhizophagus irregularis_ and other Glomeromycota) encode orthologs of
the two main neuronal cargo kinesins: a conventional kinesin-1 and an UNC-104/KIF1-type kinesin-3. Their motor domains
are about 55 % (kinesin-1) and 67 % (kinesin-3) identical to human KIF5 and KIF1A, as conserved as in model filamentous
fungi. The genomes also encode cytoplasmic dynein with dynactin, LIS1 and a Hook adaptor. These assignments rest on
genome annotation and sequence similarity; none of these motors has been studied functionally in AMF.]]

The sentence to avoid is "kinesin-1 and kinesin-3 are genetically conserved between neurons and mycorrhizal fungi, so
AMF transport follows the neuronal rules". The regulatory layer that makes neuronal transport rule-based is largely
missing from fungi and was not found in AMF (@sec-borrow), and no AMF motor has been tested. "Mycorrhizal fungi" is
also wider than the evidence: it includes ectomycorrhizal basidiomycetes and ascomycetes, while the check covered
Glomeromycota only, so "arbuscular mycorrhizal fungi (Glomeromycota)" is the accurate phrase. "Identical" and "the same
motors" are wrong too: over the whole protein the AMF kinesin-1 is about 34 % identical to KIF5B.

== The check rests on automatic gene models, one release and an unsupported tree <sec-limits>

- Gene models. No AMF protein here is reviewed, and the models were shown to be fragmented, fused and duplicated
  (@sec-m-steps step 2). Presence needed a full-length model in several genomes; absence rests on proteomes alone.
- Genome sequences were not searched. Without tblastn a gene missed by every annotation cannot be excluded, which
  weakens every "not found" in @tab-claims: kinesin light chain, Nkin3/UncB, BicD, TRAK, TTL, vasohibin, MATCAP,
  TTLL, CCP, MAP7 and doublecortin.
- The tree has no support. A neighbour-joining tree without bootstrap or outgroup shows a clade consistent with an
  assignment, not supported by it. The kinesin-3 call leans on it more, because Swiss-Prot has no reviewed fungal
  kinesin-3.
- No expression evidence for the motor or αTAT1 gene models; the only AMF expression data found concern β-tubulin.
- One release, one day. UniProtKB 2026_03, searched 2026-10-07; NCBI non-redundant and JGI MycoCosm could not be
  searched (@sec-deadends), and the 33-chromosome assembly was not among the proteomes. A cross-fungal reconstruction of
  transport gene families that includes _R. irregularis_ reports kinesin and dynein contractions and dynactin losses
  in yeast lineages #cite(<kissComparativeGenomicsReveals2019>) (searched); its per-species counts, in supplementary
  data, were not inspected.
- No function. Conservation of a motor domain says nothing about speed, processivity, cargo or regulation in AMF.

= What didn't work <sec-deadends>

== Remote searches of the non-redundant protein database never finished #dead

Thirty NCBI BLAST jobs against the non-redundant database, restricted to Glomeromycota, were accepted by the URL
interface and stayed waiting for about 75 minutes without one finishing. They were abandoned; no NCBI BLAST number
appears here, and the EBI service, searching UniProtKB, did the searches instead (@app-repro).

== The MycoCosm genome portal refuses scripted access #dead

The JGI MycoCosm portals for _R. irregularis_ (Rhiir2_1) and _G. rosea_ (Gigro1) answer a scripted request with HTTP 403
and a bot-protection page, so their gene models are checked only where UniProtKB holds them as JGI entries.

== PANTHER subfamily membership does not identify kinesin-1 #dead

The PANTHER subfamily holding the fungal kinesin-1s also holds AMF proteins of about 700 residues that are 34 to 40 %
identical to KIF5, have kinesin-7 best Swiss-Prot hits and group with _A. nidulans_ KipA, _U. maydis_ Kin1 and human
CENP-E; and the full-length kinesin-1s of _G. rosea_ and _R. clarus_ carry no PANTHER call. Family calls were used only
to collect candidates, never to assign them.

= Actionable Items <sec-actions>

== Compendium handoff

None: this document concerns the organism, not the pipeline. Outside this repository, the transport paper's
discussion still describes the Bago lipid bodies as "often not with the cytoplasmic streaming", which holds for germ
tubes only (@sec-r-amf), and a manuscript sentence on conservation should use the wording of @sec-safe.

== Re-reading the videos comes first; motor painting decides the tracks <sec-experiments>

+ Re-read the existing videos for motor signatures (no new data): run length, pauses, reversals, and speed against
  hypha width and lateral position. Short runs with pauses point to motor cargo, continuous movement over tens of µm
  at fixed speed to a stream (benchmarks in @sec-r-fungi).
+ Motor or microtubule inhibition with lipid-stream tracking: benomyl or carbendazim, which work in _U. maydis_, and
  nocodazole, with latrunculin A as the actin control. The prediction is loss of the to-tip stream and persistence of
  the return; since opposing motors are co-dependent, a slowing of both is no refutation. Wall uptake and doses are
  unknown, and depolymerisation must be confirmed by staining.
+ Acetylated and tyrosinated tubulin staining on fixed hyphae, with antibodies also against detyrosinated and
  polyglutamylated tubulin, after the published fixations with mild wall digestion. The database result predicts
  acetylated and tyrosinated signal only; a detyrosinated signal would imply an unknown enzyme.
+ Motor-PAINT polarity maps: purified kinesin walked over the extracted cytoskeleton maps which way every microtubule
  points, without transforming the fungus @tasDifferentiationOppositelyOriented2017. Its total internal reflection
  imaging sees only microtubules near the coverslip @iwanskiCellularCartographyAtlas2023, so thick hyphae need the
  lattice light-sheet version #cite(<iwanskiLatticeLightsheetMotorPAINT2024>) (record only). It decides between
  uniform tracks over millimetres and a regulated relay on a mixed array (@sec-d-streams).
+ Energy depletion (CCCP) and a hitchhiking test (lipid co-imaged with endosomes), both informative only beside the
  experiments above: flow also depends on metabolism, and hitchhiking has a low prior (@sec-d-streams).

== Six gaps keep the conservation check at the level of annotation <sec-gaps>

+ A supported phylogeny with outgroups: all kinesin motor domains of _R. irregularis_, _G. rosea_, the model fungi,
  _S. cerevisiae_, a chytrid, _Rhizopus_, human, _Dictyostelium_ and _Arabidopsis_, aligned, with a maximum-likelihood
  tree and bootstrap support; the same for the TTL family, αTAT1 and the tau-repeat proteins.
+ Translated searches of the genome sequences, starting with the chromosome-level _R. irregularis_ assemblies, for
  every "not found" in @tab-claims.
+ RNA-seq support for the kinesin-1, both kinesin-3 and the αTAT1 gene models in extraradical hyphae.
+ Single-molecule assays of the recombinant AMF kinesin-1 and kinesin-3 motor domains: speed, run length, and whether
  the kinesin-3 is superprocessive like KIF1A.
+ Silencing of kinesin-1, the UNC-104-type kinesin-3 or the dynein heavy chain by the host- or virus-induced route
  already used in _R. irregularis_, or drug experiments at defined doses, with live tracking of both streams.
+ A desk check that the AMF Hook carries the stretch matching Hook3 residues 293 to 345, the part that rescues the
  _U. maydis_ mutant @bielskaHookAdapterThat2014.

= Appendix <sec-appendix>

== Reproducing the database check <app-repro>

The scripts are gone (they lived in `/private/tmp/claude-501/motorcheck/`), so reproduction means re-running the
searches. The raw hit lines, the Newick string of the tree, the motif tables, the 50 EBI job identifiers (all
2026-10-07, form `ncbiblast-R20261007-…`) and the 30 abandoned NCBI request identifiers are in the appendix of
`transport_paper/manuscript/motor_conservation_check.md`, whose Methods this document follows.

+ Fetch the proteome list for taxonomy 214504 (UniProt `proteomes/search`) and the assembly reports (NCBI Datasets
  v2, `genome/accession/<GCA>/dataset_report`).
+ Run each forward query on EBI Job Dispatcher `ncbiblast` (program `blastp`, database `uniprotkb`,
  `taxids=214504`, `exp=1e-3`, 20 alignments), and each AMF candidate against `uniprotkb_swissprot` (`exp=1e-5`).
  Forward queries: KIF5B `P33176`, KIF1A `Q12756`, _N. crassa_ Nkin3 `Q1K7Y5`, _A. nidulans_ UncB `Q5AXW7`, and human
  DYNC1H1, PAFAH1B1 (LIS1), DCTN1, HOOK3, AKTIP (FTS), FHIP1B, BICD2, TRAK1, KLC1, MAP7, MAPT (tau), DCX
  (doublecortin), ATAT1, TTL, VASH1, MATCAP1, TTLL1, TTLL4, TTLL6, AGBL5, HDAC6, SIRT2 and RHOT1 (Miro).
+ Cut motor domains at the UniProt "Kinesin motor" feature; align each pair globally with BLOSUM62, gap open 11,
  extend 1; count identity over columns with terminal gaps removed. EMBOSS `needle` with `-gapopen 11 -gapextend 1` is
  the nearest standard tool, but its identity denominator includes terminal gaps.
+ Build a neighbour-joining tree on $d = -ln(1 - p - 0.2 p^2)$.
+ Europe PMC queries, each combined with the AMF names (Glomeromycota, Rhizophagus, Gigaspora, "Glomus intraradices",
  "arbuscular mycorrhizal"): `kinesin OR dynein OR "motor protein"`; `tubulin OR microtubule*`;
  `nocodazole OR oryzalin OR colchicine OR benomyl OR carbendazim OR latrunculin OR cytochalasin`;
  `"host-induced gene silencing" OR HIGS OR RNAi` with motor and cytoskeleton terms;
  `cytoskeleton OR actin OR microtubule` with live-imaging terms; `"lipid droplet*" OR "lipid bodies"` with movement
  terms; `kinesin AND "Rhizophagus irregularis"` with genome terms.

The _A. nidulans_ kinesin-1 entry `Q5B287` (`ANIA_05343`) carries no gene name in UniProt and PANTHER places it outside
kinesin-1; it is KinA, locus AN5343 #cite(<penalvaTransportFungalRAB112017>) (searched), and it matches by 87 % motor
identity to the _N. crassa_ heavy chain, its IAK tail and its clade.

== Assemblies and accessions <app-tables>

#figure(
  text(7.5pt, table(
    columns: (1.7fr, 1.6fr, 0.9fr, 1fr, 1fr, 1fr),
    align: (left, left, right, right, right, right),
    stroke: 0.4pt + luma(190),
    inset: 3pt,
    table.header[*assembly*][*species, source*][*contigs*][*contig N50 (kb)*][*proteins*][*BUSCO complete / duplicated (%)*],
    [`GCA_026210795.1`], [_R. irregularis_, Kew, chromosome level], [42], [3,901], [30,873], [95.8 / 3.8],
    [`GCA_000439145.3`], [_R. irregularis_, JGI], [5,983], [50], [25,981], [96.4 / 0.5],
    [`GCA_002897155.2`], [_R. irregularis_, NIBB], [210], [2,308], [66,901], [91.1 / 6.1],
    [`GCA_000597685.1`], [_R. irregularis_, 2014 single nucleus], [31,047], [16], [28,669], [85.3 / 18.3],
    [`GCA_001593145.1`], [_R. irregularis_ A4, Ottawa], [24,252], [15], [25,735], [96.3 / 0.7],
    [`GCA_003203555.1`], [_R. clarus_ HR1], [8,053], [27], [27,461], [94.6 / 0.7],
    [`GCA_003550325.1`], [_G. rosea_], [29,502], [37], [31,020], [90.3 / 1.7],
    [`GCA_003550305.1`], [_G. cerebriforme_], [14,741], [18], [20,972], [96.4 / 1.6],
    [`GCA_003547095.1`], [_D. epigaea_], [8,629], [42], [28,108], [89.8 / 0.9],
    [`GCA_009809945.1`], [_G. margarita_ BEG34], [47,617], [29], [29,434], [92.5 / 14.9],
    [`GCA_910592245.1`], [_G. margarita_, Uppsala], [173,647], [5.9], [46,482], [82.0 / 1.4],
  )),
  caption: text(8.5pt, fill: luma(95))[Assemblies used, from the NCBI Datasets v2 report (contigs, contig N50) and the
  matching UniProt proteome (proteins, BUSCO against 1,614 fungal genes), both fetched 2026-10-07. Contig N50 is
  rounded to the kilobase except below 10 kb.],
  kind: table,
) <tab-assemblies>

UniProtKB accessions of the _R. irregularis_ chromosome-level models behind @tab-claims, all TrEMBL: kinesin-1
`A0ACH0GIH0` (`OCT59_005362`; also `A0A015II29`, `U9U3B1`; in _R. clarus_ `A0A2Z6QKK3`, _G. rosea_ `A0A397UJA4`,
_G. margarita_ `A0ABN7UPC7`, _D. epigaea_ `A0A397INX1`, _P. occultum_ `A0A9N9F3U9`); UNC-104-type kinesin-3
`A0ACH0GBT8` (`OCT59_003129`; also `A0A2P4Q4S1`; in _R. clarus_ `A0A2Z6SJH9`, _G. rosea_ `A0A397VSD8`, _D. epigaea_
`A0A397HEG4`, _G. margarita_ `A0A8H3WXQ6`); second kinesin-3 `OCT59_001126` (`U9SMM2`); dynein heavy chain
`A0ACH0G8B2`; LIS1 `A0ACH0GVZ4`; dynactin p150 `A0ACH0HDQ7`; Hook `A0ACH0G6M6`; FTS (_G. cerebriforme_)
`A0A397TXP6`; FHIP `A0ACH0GLD3`, `A0ACH0HR76`; Miro `A0ACH0GUL0`; α-tubulin `A0ACH0HRL5`; αTAT1 `A0ACH0FVY2`;
PBY1-type TTL-family protein `A0ACH0HSS1`; tau/MAP-repeat protein `A0ACH0H0R8`.

== Provenance

#text(8.5pt, table(
  columns: (1.4fr, 2fr, 1.6fr, 0.9fr, 1fr),
  align: (left, left, left, left, left),
  stroke: 0.4pt + luma(190),
  inset: 4pt,
  table.header[*campaign*][*inputs*][*script or service*][*date*][*input survives*],
  [literature review], [24 full texts in `references_local/`; 5 full texts and further records from Europe PMC], [read or searched by hand; PyMuPDF extraction, macOS Vision OCR for the 1994 scan], [2026-10-07], [yes],
  [database check], [UniProtKB 2026_03, NCBI Datasets v2], [EBI NCBI-BLAST, EBI Clustal Omega, two stdlib Python scripts], [2026-10-07], [databases yes; scripts no],
  [schematic], [none], [`direction_rule_fig.py`], [2026-10-07], [yes],
))

== References

#show bibliography: set text(8pt)
#show bibliography: it => columns(2, gutter: 14pt, it)
#bibliography("references.bib", title: none, style: "chicago-author-date")
