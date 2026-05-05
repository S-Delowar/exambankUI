"""Subject-specific addendums for HSC board exam extraction.

These addendums are injected into HSC prompts (MCQ and written) when the upload
is single-subject. They provide subject-specific guidance for:
  - Common diagram types and notation
  - Subject-specific terminology (Bangla ↔ English)
  - Formatting conventions
  - Common extraction pitfalls

Keep each addendum focused (100-200 words). Only add guidance that improves
extraction quality for that specific subject.
"""

PHYSICS_ADDENDUM = """
PHYSICS-SPECIFIC GUIDANCE:
- Circuit diagrams: Common symbols include resistor (zigzag line), capacitor (parallel lines), battery (long/short parallel lines), switch, ammeter (A in circle), voltmeter (V in circle), connecting wires. Preserve all component labels and values.
- Vector diagrams: Preserve arrow directions, magnitude labels, angle measurements. Common in dynamics, forces, projectile motion questions.
- Graphs: Velocity-time (v-t), acceleration-time (a-t), displacement-time graphs are frequent. Always identify and label axes clearly.
- Free-body diagrams: Mark all forces with arrows and labels (tension T, normal N, friction f, weight mg).
- Common Bangla terms: বল (force), ত্বরণ (acceleration), বেগ (velocity), ভর (mass), শক্তি (energy), ক্ষমতা (power), তরঙ্গ (wave), বিদ্যুৎ (electricity), চৌম্বক (magnetic).
- Units: Preserve all units exactly as printed (m/s, m/s², N, J, W, V, A, Ω, Hz, etc.).
"""

CHEMISTRY_ADDENDUM = """
CHEMISTRY-SPECIFIC GUIDANCE:
- Chemical formulas: ALWAYS use \\ce{} notation inside math mode. Examples: $\\ce{H2SO4}$, $\\ce{NaCl}$, $\\ce{CH3COOH}$, $\\ce{Ca(OH)2}$.
- Chemical equations: Use \\ce{} for the entire equation. Examples: $\\ce{2H2 + O2 -> 2H2O}$, $\\ce{NaOH + HCl -> NaCl + H2O}$.
- Ions and charges: $\\ce{SO4^{2-}}$, $\\ce{NH4^+}$, $\\ce{Fe^{3+}}$.
- Equilibrium reactions: $\\ce{N2 + 3H2 <=> 2NH3}$.
- Isotopes: $\\ce{^{14}_{6}C}$, $\\ce{^{235}_{92}U}$.
- Molecular structures: Benzene rings, structural formulas, skeletal formulas are common diagrams.
- Reaction mechanisms: Arrow-pushing diagrams showing electron movement.
- Common Bangla terms: যৌগ (compound), মৌল (element), বিক্রিয়া (reaction), আয়ন (ion), অ্যাসিড (acid), ক্ষার (base), জারণ (oxidation), বিজারণ (reduction).
- Organic chemistry: Functional groups (alcohol, aldehyde, ketone, carboxylic acid, ester, amine) appear frequently in Paper 2.
"""

MATHEMATICS_ADDENDUM = """
MATHEMATICS-SPECIFIC GUIDANCE:
- Geometric figures: Preserve all angle marks (∠ABC), parallel marks (||), perpendicular marks (⊥), congruence symbols (≅), similarity symbols (∼). Label all vertices, sides, and angles exactly as printed.
- Coordinate systems: Always label x-axis, y-axis, origin (O), and any marked points with coordinates. Preserve scale if shown.
- Function graphs: Label the function (y = f(x)), axes, intercepts, asymptotes, maxima/minima points.
- Matrices: Use proper LaTeX matrix notation: $\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}$ or $\\begin{bmatrix} ... \\end{bmatrix}$.
- Vectors: Use $\\vec{a}$ or $\\mathbf{a}$ notation. Preserve magnitude notation $|\\vec{a}|$ or $\\|\\vec{a}\\|$.
- Set notation: $\\in$, $\\notin$, $\\subset$, $\\cup$, $\\cap$, $\\emptyset$.
- Common Bangla terms: সমীকরণ (equation), অপেক্ষক (function), সমাধান (solution), অন্তরকলন (differentiation), সমাকলন (integration), ম্যাট্রিক্স (matrix), ভেক্টর (vector).
- Trigonometry: $\\sin$, $\\cos$, $\\tan$, $\\cot$, $\\sec$, $\\csc$ — always use LaTeX commands, never plain text.
"""

BIOLOGY_ADDENDUM = """
BIOLOGY-SPECIFIC GUIDANCE:
- Anatomical diagrams: Label all parts clearly. Common diagrams include heart, digestive system, respiratory system, nervous system, reproductive system, plant structures.
- Cell structures: Nucleus, mitochondria, chloroplast, ribosome, endoplasmic reticulum, Golgi apparatus, cell membrane, cell wall. Preserve all organelle labels.
- Microscope images: Cell division stages (mitosis, meiosis), tissue cross-sections, blood cells.
- Phylogenetic trees / classification diagrams: Preserve hierarchical structure and all taxonomic labels.
- Flowcharts: Metabolic pathways (photosynthesis, respiration), life cycles, food chains/webs.
- Tables: Comparison tables (plant vs animal cell, mitosis vs meiosis, DNA vs RNA) are common.
- Common Bangla terms: কোষ (cell), টিস্যু (tissue), অঙ্গ (organ), জীব (organism), প্রজাতি (species), বংশগতি (heredity), বিবর্তন (evolution), সালোকসংশ্লেষণ (photosynthesis), শ্বসন (respiration).
- Scientific names: Preserve genus/species in italics if printed, or use plain text with proper capitalization (e.g., Homo sapiens, Oryza sativa).
"""

# Dictionary mapping subject keys to their addendums
SUBJECT_ADDENDUMS = {
    "physics": PHYSICS_ADDENDUM,
    "chemistry": CHEMISTRY_ADDENDUM,
    "mathematics": MATHEMATICS_ADDENDUM,
    "biology": BIOLOGY_ADDENDUM,
}
