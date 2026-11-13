# Design System: Dermatriage Clinical Precision

<!-- impeccable:design-schema 1 -->

## Design Thesis

Dermatriage operates in the **Operate** mode. The design serves rapid, high-stakes clinical triage decisions. Every component is engineered for cognitive clarity, immediate urgency recognition, and verifiable explainability. Motion is purposeful and communicative—guiding attention, acknowledging operations, and preserving spatial continuity without frivolous delays.

## Color Strategy: Restrained Medical Clinical

### Primary Brand
- Primary Teal: `#006A6B` (Light) / `#2DD4BF` (Dark)
- Primary Teal Container: `#CCFBF1` (Light) / `#134E4A` (Dark)
- Primary Teal Dark: `#004D40`
- Medical Cyan (Accents & Highlights): `#0284C7` (Light) / `#38BDF8` (Dark)

### Neutral Surface Hierarchy
- **Light Theme**:
  - Scaffold Background: `#F8FAFC` (Slate 50)
  - Card & Container Surface: `#FFFFFF` (Pure White)
  - Secondary Panel Surface: `#F1F5F9` (Slate 100)
  - Subtle Border: `#E2E8F0` (Slate 200)
  - Text Primary: `#0F172A` (Slate 900)
  - Text Secondary: `#475569` (Slate 600)
  - Text Muted: `#94A3B8` (Slate 400)
- **Dark Theme**:
  - Scaffold Background: `#0B0F17` (Deep Obsidian Slate)
  - Card & Container Surface: `#131B2A` (Elevated Medical Navy)
  - Secondary Panel Surface: `#1E293B` (Slate 800)
  - Subtle Border: `#1E293B` / `#334155` (Slate 700)
  - Text Primary: `#F8FAFC` (Slate 50)
  - Text Secondary: `#94A3B8` (Slate 400)
  - Text Muted: `#64748B` (Slate 500)

### Triage Urgency Stratification Palette (WCAG 2.1 AA Compliant)
- **Level 1: High Priority / Emergency Isolation** (e.g. Mpox, Cowpox systemic)
  - Foreground: `#DC2626` (Red 600)
  - Light Container: `#FEF2F2` (Red 50), Border: `#FCA5A5`
  - Dark Container: `#450A0A` (Red 950), Border: `#991B1B`
- **Level 2: Urgent Priority (12–24h)** (e.g. Measles)
  - Foreground: `#D97706` (Amber 600)
  - Light Container: `#FFFBEB` (Amber 50), Border: `#FCD34D`
  - Dark Container: `#451A03` (Amber 950), Border: `#B45309`
- **Level 3: Standard Priority** (e.g. Chickenpox, HFMD)
  - Foreground: `#2563EB` (Blue 600)
  - Light Container: `#EFF6FF` (Blue 50), Border: `#93C5FD`
  - Dark Container: `#172554` (Blue 950), Border: `#1D4ED8`
- **Level 4: Routine Priority** (e.g. Healthy skin)
  - Foreground: `#059669` (Emerald 600)
  - Light Container: `#ECFDF5` (Emerald 50), Border: `#6EE7B7`
  - Dark Container: `#022C22` (Emerald 950), Border: `#047857`

## Typography

- **Scale Ratio**: Fixed 1.15 clinical ratio.
  - Display / Hero: 22–24px, Weight 800, Tracking -0.4px
  - H1 / Section Title: 18–20px, Weight 700, Tracking -0.3px
  - H2 / Card Header: 15–16px, Weight 650, Tracking -0.2px
  - Body Primary: 13.5–14px, Weight 400/500, Height 1.45
  - Body Secondary: 12–12.5px, Weight 500, Height 1.4
  - Caption / Badges / Metrics: 10–11.5px, Weight 600/700, Tracking 0.2px
- Numerical clarity: Tabular numerals for probabilities, token coordinates, and model metrics.

## Motion & Animation Grammar: Clinical Precision

1. **State & Micro-Interactions (150–200ms)**:
   - Hover cards elevate with soft shadow transition (`Curves.easeOut`).
   - Button tap press scale: subtle 0.98 spring-back.
   - Attention heatmap token hover: smooth crossfade and coordinates tooltips.
2. **Confidence & Probability Bars (350–500ms)**:
   - Animated progress bars using `Curves.easeOutCubic`.
   - Staggered bar entry on scan completion (50ms interval between classes).
3. **Screen & View Transitions (250–300ms)**:
   - Smooth crossfade slide between tabs using `AnimatedSwitcher` and `SharedAxis` pattern.
   - Differential Matrix expand/collapse using `AnimatedCrossFade` or smooth height transition.
4. **Focal Moment: Lesion Scan & Attention Synthesis**:
   - Scanning laser line sweeps across the intake preview smoothly with animated glow.
   - When inference completes, attention tokens and probability cards reveal with fluid staggered cascade.

## Elevation & Depth

- Cards: Subtle 1px border (`borderSubtle`) with soft ambient blur (`BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3))`).
- No hard 4px neobrutalist borders or glowing halos.
- Active state: crisp teal outline ring (`border: Border.all(color: primaryTeal, width: 1.5)`).

## Responsiveness & Breakpoints

- Mobile (`< 700px`): Single column layout, bottom navigation bar, compact headers, wrapped button rows to prevent any horizontal overflow.
- Tablet (`700px – 1023px`): Adaptive two-column grids, collapsible panels.
- Desktop (`>= 1024px`): Left navigation rail, side-by-side intake and triage cards, expanded differential matrix table.
