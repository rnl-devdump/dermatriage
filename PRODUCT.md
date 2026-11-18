# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Primary users are clinical triage officers, emergency physicians, dermatologists, and frontline healthcare workers who encounter undifferentiated acute viral exanthems (such as suspected Mpox, Chickenpox, Cowpox, Measles, or HFMD) and need fast, high-confidence decision support to triage urgency, initiate infection control, and verify model rationale before referral.

## Product Purpose

Dermatriage provides rapid, privacy-preserving, dual-engine clinical decision support for acute viral exanthems and skin lesion triage. It reduces diagnostic delay in outbreak scenarios, differentiates morphologically similar poxviruses and viral rashes, flags emergency isolation protocols, and provides interpretable cross-attention spatial heatmaps that clinicians can inspect directly at the point of care.

## Positioning

Unlike generic black-box dermatology AI classifiers that offer only top-1 labels, Dermatriage combines a dual-branch Convolutional Neural Network (CNN for localized edge and lesion texture) with a Vision Transformer (ViT-B/16 for global contextual token attention) fused via cross-attention. The trained model runs in a PyTorch FastAPI service (local or on a cloud GPU). When that service is unreachable, the app falls back to a client-side Dart estimate based on simple colour features; it is labelled as an estimate and is not the trained model.

## Operating Context

- Fast-paced clinical triage desks, emergency consultation rooms, and mobile clinic field tablets.
- Both desktop widescreen workstations (>= 1024px) and tablet/mobile triage handhelds (< 768px).
- Low-latency scanning workflow: drag-and-drop or single-tap image intake, verified test sample library, instantaneous multi-class probability breakdown, animated cross-attention token overlay, and immediate CDC/WHO triage disposition protocols.

## Capabilities and Constraints

- **6 Target Exanthem Classes**: Monkeypox (Mpox), Chickenpox (Varicella), Cowpox, Hand-Foot-and-Mouth Disease (HFMD), Measles, and Healthy skin controls.
- **Triage Urgency Stratification**: Level 1 High Priority (Emergency/Immediate Isolation), Level 2 Urgent (12-24h Clinical Review), Level 3 Standard (Non-urgent Pediatric/General), Level 4 Routine (Observation/Healthy).
- **Dual-Mode Inference**: PyTorch FastAPI service (local `127.0.0.1:8000` or the cloud deployment) with auto-fallback to the offline Dart estimate, which the result screen labels as not the trained model.
- **Explainability**: 14x14 Vision Transformer cross-attention map (196 spatial tokens) with interactive opacity slider, grid overlay toggle, and token inspectability.
- **Differential Matrix**: Comprehensive comparison across pathogen, incubation, transmission, prodrome, lesion evolution, lymphadenopathy, and isolation guidelines.
- **Validation Metrics**: Patient-independent 5-fold cross-validation on MSLD v2.0, read at runtime from `assets/data/benchmarks.json` (proposed model: validation macro F1 86.81 ± 2.12, held-out accuracy 82.24 ± 4.26, held-out macro F1 81.28 ± 5.02). The app never shows a hard-coded fallback as a measured figure.
- **Session Records**: Audit trail of analyzed cases with timestamps, probability distributions, urgency ratings, and exportable triage summaries.

## Brand Commitments

- **Tone**: Medical authority, calm precision, non-alarmist clarity, rapid scannability.
- **Palette**: Deep Clinical Teal (`#006A6B`, `#004D40`), Medical Cyan (`#0284C7`), Crisp Slate (`#0F172A`, `#334155`), with standardized medical triage urgency colors (Level 1 Crimson `#DC2626`, Level 2 Amber `#D97706`, Level 3 Blue `#2563EB`, Level 4 Emerald `#059669`).
- **Theme**: Modern Clinical Light with smooth Dark Mode toggle support for low-light clinical environments.
- **Motion**: Clinical Precision Motion — 250–350ms smooth cubic-bezier transitions, spring-damped confidence bars, fluid page/tab cross-fades, and staggered reveal for triage diagnostic cards. No gratuitous delays or disorienting spins.

## Evidence on Hand

- Validated MSLD v2.0 benchmark dataset and 5-fold cross-validation output logs.
- Automated test suites in `dermatriage_app/test/widget_test.dart`.
- Clinical lesion test samples located in `dermatriage_app/assets/samples/`.
- Confusion matrices and loss/accuracy curves in `dermatriage_app/assets/research/`.

## Product Principles

1. **Immediate Clinical Actionability**: The triage urgency tag, primary differential, and required isolation protocol must be instantly visible without scrolling or hunting.
2. **Explainability Over Authority**: Clinicians must be able to visually audit what visual tokens the model attended to (14x14 attention heatmap) rather than being forced to trust a raw score.
3. **Graceful Resilience, Honestly Labelled**: The app keeps working without the model server, but says plainly when a result is the offline estimate rather than the trained model.
4. **Fluid Ergonomics**: Every state change (image load, inference calculation, tab change, differential matrix expansion) animates smoothly with zero layout jank or jarring pop-ins.
5. **Universal Viewport Harmony**: Unbroken responsiveness across 320px mobile screens, tablets, and wide multi-column clinical monitors.

## Accessibility & Inclusion

- WCAG 2.1 AA compliant color contrast ratios across all triage urgency badges, text labels, and probability bars.
- Clear semantic labels, tooltips, and screen-reader accessible iconography.
- Reduced motion consideration: all animations respect smooth standard duration without excessive disorienting parallax.
