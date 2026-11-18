---
version: 1
slug: "dermatriage-app-lib-main-dart"
primary_target: "dermatriage_app/lib/main.dart"
related_targets: []
---

# Surface: Dermatriage Clinical Shell & Workspaces

<!-- impeccable:surface-brief-schema 1 -->

## Scope
Main navigation shell, clinical workspaces (Overview, Scan & Triage, Exanthem Clinical Library, Benchmarks & Empirical Validation, Session Records), and shared UI widgets.

## Visitor Mode
Operate. The Overview opens like a poster; Scan, Exanthems, Benchmarks, and Records stay task-first inside the same world.

## Constraints
- Preserve every function, data source, and state: dual-mode inference, sample library, attention heatmap with opacity and grid controls, probability breakdown, triage protocols, differential matrix, benchmarks, session records, dark mode.
- The four triage urgency colors are clinical semantics and stay exactly as they are; they are the only non-teal hues.

## Direction contract

### THESIS
A clinical tool that opens like an exhibition poster: towering condensed type, flat full-width colour fields, and one arched lesion photograph breaking the title. It refuses the category's grid of rounded white metric cards with soft shadows.

### OWN-WORLD
Toys for Joy structure in Dermatriage teal. Teal paper canvas (#EEF8F6), Slate 50 bands (#F8FAFC), Deep Teal display ink (#004D40), Primary Teal fields (#006A6B), pale Teal Container type on dark fields (#CCFBF1), a greyed-teal quiet panel, a Medical Cyan band (#0284C7), and a cool cyan wash (#E0F2FE). Italiana at 400 for every display line, line-height 0.8 to 1.0; DM Sans Light for body and uppercase labels; DM Mono for numbers. Zero radius, no shadows, 1px teal hairlines, arch masks on lesion images. One 7px-radius card only, inside the deep teal footer frame.

### STORY
A clinician lands on a poster that names the tool and shows a real lesion, sees the six classes as a staggered word wall, and goes straight to Scan. The result names the class in poster type over an urgency band, then the probabilities, the attention map, and the protocol.

### FIRST VIEWPORT
Overview: a crumpled deep-teal paper field with DERMA / TRIAGE in pale Italiana at poster scale, an arch-masked sample lesion overlapping the second line, a transparent header strip above (stacked wordmark, two-line uppercase mission, engine status, theme toggle), and slate bands stepping up from the bottom edge carrying tilted capability labels. The primary action, Start a scan, sits in the split panel directly below. Mobile keeps the poster, scaled, with a flat bottom bar.

### FORM
Toys for Joy poster storefront, translated to a clinical tool. seed: none (pinned) "use impeccable skill to redesign Dermatriage. Use the original color palette." with the Toys for Joy style reference supplied in full; palette confirmed as "Dermatriage's own teal". Signature interaction: the class word wall, where each condensed class name opens its library entry; motion is a short colour-field crossfade between workspaces and a bar sweep on results.

### FINISH
unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.
