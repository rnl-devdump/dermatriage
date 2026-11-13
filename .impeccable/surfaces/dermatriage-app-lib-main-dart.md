# Surface: Dermatriage Clinical Shell & Workspaces

<!-- impeccable:surface-brief-schema 1 -->

## Scope
Main navigation shell, clinical workspaces (Overview, Scan & Triage, Exanthem Clinical Library, Benchmarks & Empirical Validation, Session Records), and shared UI widgets.

## Visitor Mode
Operate

## Direction contract

### THESIS
The interface is a high-speed, calm clinical workstation for viral exanthem decision support. It rejects generic AI chatbot wrappers, ungrounded glowing neon cards, and clunky static layouts in favor of an ergonomic, responsive clinical console where model confidence, urgency stratification, and explainable attention maps are immediately actionable.

### OWN-WORLD
Restrained medical teal (`#006A6B` / `#2DD4BF`), clean slate surfaces, crisp 1px borders, semantic 4-level triage urgency badges (Level 1 Crimson to Level 4 Emerald), and a fluid dark mode toggle. Tabular numbers for clinical metrics and 14x14 attention grids.

### STORY
A clinician assesses an undifferentiated rash, either uploading an image or selecting a verified clinical case. The system instantaneously computes predictions via local PyTorch or embedded Dart engine, gracefully reveals the triage priority, renders an interactive 14x14 cross-attention heatmap overlay with opacity control, and provides immediate CDC/WHO infection control and referral guidance.

### FIRST VIEWPORT
On desktop, clean top navigation bar with engine status pill and dark/light toggle; left navigation rail with 5 core workspaces; center dual-pane with image intake & verified cases on the left and staggered triage disposition card on the right. On mobile, fluid single-column layout with smooth bottom navigation and zero overflow.

### FORM
Clinical Triage Console, position 1. seed: none (pinned) "(Recommended) Clinical Frontline & Triage: Fast triage decisions, clear urgency hierarchy, rapid image intake, and immediate CDC/WHO isolation guidance with interactive attention verification; Clinical Precision Motion: 250–350ms smooth ease-out curves, spring-animated confidence bars, fluid tab cross-fades, and staggered reveal for triage cards; Modern Clinical Teal & Slate with Dark Theme toggle"

### FINISH
unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.
