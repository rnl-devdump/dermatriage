---
name: Dermatriage
description: Rash triage on a teal poster. Hairline display capitals over flat colour fields, lesion photographs in arch windows.
colors:
  paper: "#EEF8F6"
  band: "#F8FAFC"
  ink: "#004D40"
  pale: "#CCFBF1"
  primary: "#006A6B"
  quiet-panel: "#3B7473"
  cyan-band: "#0369A1"
  sky-wash: "#E0F2FE"
  teal-wash: "#D7F0EB"
  frame: "#004D40"
  ink-slate: "#2E4A47"
  hairline: "#C2D9D5"
  text-primary: "#0B3B36"
  text-secondary: "#34524E"
  paper-dark: "#061B19"
  band-dark: "#0B2724"
  field-dark: "#134E4A"
  quiet-panel-dark: "#1C3E3B"
  cyan-band-dark: "#075985"
  sky-wash-dark: "#0C2A3A"
  teal-wash-dark: "#0F3531"
  teal-accent-dark: "#2DD4BF"
  hairline-dark: "#1E4A45"
  text-primary-dark: "#E6FAF6"
  text-secondary-dark: "#A8C9C4"
  urgency-level-1: "#DC2626"
  urgency-level-2: "#B45309"
  urgency-level-3: "#2563EB"
  urgency-level-4: "#047857"
typography:
  display-poster:
    fontFamily: "Italiana, serif"
    fontSize: "192px"
    fontWeight: 400
    lineHeight: 0.8
    letterSpacing: "0em"
  display-title:
    fontFamily: "Italiana, serif"
    fontSize: "84px"
    fontWeight: 400
    lineHeight: 0.86
    letterSpacing: "0em"
  display-section:
    fontFamily: "Italiana, serif"
    fontSize: "48px"
    fontWeight: 400
    lineHeight: 1
    letterSpacing: "0em"
  body:
    fontFamily: "DM Sans, sans-serif"
    fontSize: "16px"
    fontWeight: 300
    lineHeight: 1.3
    letterSpacing: "0em"
  label:
    fontFamily: "DM Sans, sans-serif"
    fontSize: "12.8px"
    fontWeight: 300
    lineHeight: 1.1
    letterSpacing: "0.48px"
  figure:
    fontFamily: "DM Mono, monospace"
    fontSize: "40px"
    fontWeight: 400
    lineHeight: 1.2
    letterSpacing: "0em"
rounded:
  none: "0px"
  footer-card: "7px"
spacing:
  gutter-mobile: "20px"
  gutter-desktop: "40px"
  section: "160px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.none}"
    padding: "16px 22px"
  button-outline:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    rounded: "{rounded.none}"
    padding: "16px 22px"
  urgency-field:
    backgroundColor: "{colors.urgency-level-1}"
    textColor: "#FFFFFF"
    rounded: "{rounded.none}"
    padding: "28px 24px"
  stat-band:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.pale}"
    rounded: "{rounded.none}"
    padding: "32px"
  footer-card:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink}"
    rounded: "{rounded.footer-card}"
    padding: "40px"
---

# Design System: Dermatriage

## Overview

**Creative North Star: "The Clinic Poster"**

Dermatriage reads like a printed public-health poster in teal: towering hairline capitals, flat full-bleed colour fields as section breaks, and lesion photographs cut into arch windows instead of rounded cards. The structure follows the "Toys for Joy" style reference the owner supplied, with every lavender and plum role replaced by Dermatriage's own teal family. The four clinical urgency colours are product semantics and are kept exactly.

The home screen is the poster. Scan, the exanthem library, benchmarks and records are working screens in the same world: a display title over a hairline, Light body copy, square controls, and figures set in a monospace so columns of numbers line up.

**Key Characteristics:**
- Italiana display at weight 400 only, line-height 0.8 to 1.0, never bold.
- DM Sans Light 300 for body and uppercase labels; 400 only for nav and button text.
- Zero radius everywhere except the 7px footer card.
- No shadows. Depth comes from stacked colour fields, arch masks and the inset footer card.
- Urgency is a full-width colour field with white text, not a tinted badge.

## Colors

### Primary
- **Primary teal** `#006A6B`: buttons, the benchmark stat band, active nav underline.
- **Ink** `#004D40`: display type and rules on the light paper; also the footer frame.

### Secondary
- **Quiet panel** `#3B7473`: the quieter half of the home split panel.
- **Cyan band** `#0369A1`: the validation band on home (deepened from `#0284C7` so white text clears AA).

### Neutral
- **Paper** `#EEF8F6` canvas, **Band** `#F8FAFC` stepped bands and content cards, **Sky wash** `#E0F2FE` the one cool field, **Teal wash** `#D7F0EB` highlighted rows, **Hairline** `#C2D9D5` 1px dividers.
- Dark theme swaps to **Paper dark** `#061B19`, **Band dark** `#0B2724`, **Field dark** `#134E4A`, with **Teal accent** `#2DD4BF` as the primary.

### Named Rules
**The Urgency Rule.** Red, amber, blue and green appear only for triage urgency: L1 `#DC2626`, L2 `#B45309`, L3 `#2563EB`, L4 `#047857`, each carrying white text. No other surface may use them.

**The One Cool Field Rule.** Sky wash and cyan are the only cool colours, used once each on the home poster.

## Typography

**Display Font:** Italiana (OFL), weight 400.
**Body Font:** DM Sans (OFL), instanced at 300, 400 and 500.
**Figure Font:** DM Mono (OFL), for confidences, metrics and percentages (DM Sans has no tabular figures).

### Hierarchy
- **Poster** (Italiana 192px desktop, scales down on mobile, line-height 0.8): DERMA / TRIAGE on the hero only.
- **Title** (Italiana 84px desktop / 52px mobile, 0.86): one per workspace screen.
- **Section** (Italiana 48px, 1.0): feature trio titles, word wall, result class name (84/56px).
- **Body** (DM Sans 300, 16px, 1.3): paragraphs, capped near 620px measure.
- **Label** (DM Sans 300, 12.8px uppercase, +0.48px tracking): eyebrows, stat captions, engine status.
- **Figure** (DM Mono 400): every number the model or the benchmarks produce.

### Named Rules
**The Light Body Rule.** Body copy never goes heavier than 300; weight is not how this world shows emphasis. Size and the display face are.

## Layout

Gutters are 20px on mobile and 40px on desktop; the mobile breakpoint is 700px for headers and 768px for the shell. Major home sections are separated by full-bleed colour fields rather than whitespace alone. The header strip sits transparent over the poster hero and gains the paper colour once the page scrolls past 24px. Desktop navigation is a row of uppercase links with an underline on the active one; mobile uses a bottom navigation bar.

Benchmark figures sit in ruled columns (1px left rules on desktop, top rules on mobile) inside a single teal band.

## Elevation & Depth

None. Every Material elevation and shadow is set to zero. A surface steps forward by changing colour field, by being cut into an arch, or by sitting inset in the framed footer card.

### Named Rules
**The Flat Field Rule.** If a surface needs to stand out, give it a different field colour or a 1px hairline, never a shadow.

## Shapes

Square corners on buttons, chips, inputs, cards, dialogs and bars. Lesion photographs and thumbnails use the arch mask: a rectangle whose top edge is a full semicircle, optionally outlined at 1px. Icons that would sit in a badge stand inside a small outlined arch instead. The single rounded shape is the footer card at 7px, inset 16px inside the dark frame field.

## Components

### Buttons
- **Primary:** filled primary teal (teal accent in dark), white text (dark ink in dark), square, 16px vertical padding, DM Sans 500.
- **Outline:** 1px ink border on transparent, same metrics. Used for secondary actions such as Test Samples.

### Chips
Square, 1px hairline, DM Sans Light label; the selected chip takes the primary border and a check mark.

### Cards / Containers
Band-coloured blocks with a 1px hairline, no radius, no shadow. Highlighted rows (the proposed model in the benchmark list) take teal wash and a 1.4px primary border.

### Navigation
Stacked DERMA / TRIAGE wordmark at the left, uppercase links centred, engine status and theme toggle at the right. Engine status is a filled dot when the PyTorch server is serving trained weights, and a hollow ring with "Server has no weights" or "Offline estimate" otherwise.

### Urgency Result Field (signature)
The scan result opens with a full-width field in the urgency colour: uppercase priority label, the class name in Italiana, and the confidence in DM Mono. Underneath, on the band, a line states which engine produced the result, then the protocol box and the probability bars.

### Stepped Bands (signature)
On the home hero, band-coloured strips step up from the bottom edge carrying tilted uppercase labels, over a procedurally crumpled deep-teal paper texture (`tools/brand/make_paper.py`).

### Word Wall (signature)
The six classes set as single Italiana words with alternating indents, each opening its entry in the exanthem library.

## Do's and Don'ts

### Do:
- **Do** set headlines only in Italiana at 400 and body in DM Sans Light 300.
- **Do** use full-bleed colour fields as section breaks.
- **Do** cut photographs into arch windows.
- **Do** set every model output and metric in DM Mono, read from the data, never typed in.
- **Do** say which engine produced a result: the trained PyTorch model or the offline Dart estimate.

### Don't:
- **Don't** use bold display type or display line-height of 1.2 or more.
- **Don't** add drop shadows anywhere.
- **Don't** round photographs or cards (the 7px footer card is the only exception).
- **Don't** use the urgency reds, ambers, blues or greens for decoration.
- **Don't** centre every line of the word wall.
- **Don't** present the offline estimate as the trained model's output.
