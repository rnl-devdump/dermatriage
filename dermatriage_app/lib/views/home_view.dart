import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/inference_service.dart';
import '../models/exanthem_info.dart';
import '../theme/app_theme.dart';
import '../widgets/poster.dart';

/// Overview: an exhibition poster for the tool, then the ways in.
class HomeView extends StatefulWidget {
  final Function(int tabIndex) onNavigate;
  final ValueChanged<String> onOpenExanthem;
  final InferenceService inference;

  const HomeView({super.key, required this.onNavigate, required this.onOpenExanthem, required this.inference});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: AppMotion.entrance)..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final mobile = w < 700;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PosterHero(width: w, viewportHeight: MediaQuery.of(context).size.height, mobile: mobile, intro: _intro),
            _SplitPanel(mobile: mobile, onScan: () => widget.onNavigate(1), onLibrary: () => widget.onNavigate(2)),
            _WordWall(width: w, mobile: mobile, onOpen: widget.onOpenExanthem),
            _HowItWorks(mobile: mobile),
            _ValidationBand(mobile: mobile, onOpen: () => widget.onNavigate(3)),
            _FramedFooter(mobile: mobile, inference: widget.inference, onNavigate: widget.onNavigate),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Poster hero

class _PosterHero extends StatelessWidget {
  final double width;
  final double viewportHeight;
  final bool mobile;
  final Animation<double> intro;

  const _PosterHero({required this.width, required this.viewportHeight, required this.mobile, required this.intro});

  @override
  Widget build(BuildContext context) {
    final height = mobile ? math.max(560.0, width * 1.42) : math.min(math.max(viewportHeight * 0.9, 640.0), 900.0);
    final type = (mobile ? width * 0.27 : width * 0.19).clamp(84.0, 268.0);
    final archW = (mobile ? width * 0.27 : width * 0.15).clamp(96.0, 250.0);
    final archH = archW * 1.38;
    final topPad = mobile ? 86.0 : 118.0;
    final line2Top = topPad + type * 0.84;
    final bandsH = mobile ? 92.0 : 132.0;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/brand/crumpled_teal_paper.jpg'),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          // Title: two centred lines of poster capitals
          Positioned(
            left: 0,
            right: 0,
            top: topPad,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: intro, curve: AppMotion.curve),
              child: Semantics(
                header: true,
                label: 'Dermatriage',
                child: ExcludeSemantics(
                  child: Column(
                    children: [
                      Display('DERMA', size: type, color: AppTheme.pale, height: 0.84, align: TextAlign.center),
                      Display('TRIAGE', size: type, color: AppTheme.pale, height: 0.84, align: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // The one photograph: a real MSLD v2.0 test sample in an arch,
          // breaking the second line.
          Positioned(
            // Breaks the end of the second line without erasing the word.
            left: width * (mobile ? 0.69 : 0.735),
            top: line2Top + type * (mobile ? 0.42 : 0.30),
            child: ArchImage(
              image: const AssetImage('assets/images/samples/mpox_sample_1.jpg'),
              width: archW,
              height: archH,
              outline: AppTheme.pale.withValues(alpha: 0.55),
              semanticLabel: 'Mpox test sample from the MSLD v2.0 dataset',
            ),
          ),
          // Mission line, lower left
          Positioned(
            left: mobile ? 20 : 40,
            bottom: bandsH + (mobile ? 18 : 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: mobile ? width - 40 : 360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PosterLabel('Decision support for viral rashes', color: AppTheme.pale),
                  const SizedBox(height: 4),
                  PosterLabel('ResNet-50 and ViT-B/16, joined by cross-attention',
                      color: AppTheme.pale.withValues(alpha: 0.78)),
                ],
              ),
            ),
          ),
          // Paper bands stepping up from the bottom edge, carrying tilted labels
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bandsH,
            child: _SteppedBands(mobile: mobile),
          ),
        ],
      ),
    );
  }
}

class _SteppedBands extends StatelessWidget {
  final bool mobile;
  const _SteppedBands({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final back = isDark ? AppTheme.bandDark : AppTheme.surfaceElevatedLight;
    final front = isDark ? AppTheme.paperDark : AppTheme.band;
    final labelColor = isDark ? AppTheme.pale : AppTheme.ink;
    final labels = mobile
        ? const ['Six classes', 'Attention map']
        : const ['Six classes', 'Attention heatmap', 'Triage protocol'];
    return LayoutBuilder(builder: (context, c) {
      return Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BandsPainter(back: back, front: front))),
          for (var i = 0; i < labels.length; i++)
            Positioned(
              left: c.maxWidth * (mobile ? [0.08, 0.40][i] : [0.08, 0.38, 0.88][i]),
              bottom: c.maxHeight * (mobile ? [0.30, 0.42][i] : [0.26, 0.40, 0.30][i]),
              child: Transform.rotate(
                angle: [-0.045, -0.03, 0.035][i],
                child: PosterLabel(labels[i], color: labelColor, tracking: 0.48),
              ),
            ),
        ],
      );
    });
  }
}

class _BandsPainter extends CustomPainter {
  final Color back;
  final Color front;
  _BandsPainter({required this.back, required this.front});

  @override
  void paint(Canvas canvas, Size s) {
    final b = Path()
      ..moveTo(0, s.height * 0.36)
      ..lineTo(s.width * 0.46, s.height * 0.06)
      ..lineTo(s.width, s.height * 0.30)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    final f = Path()
      ..moveTo(0, s.height * 0.62)
      ..lineTo(s.width * 0.62, s.height * 0.40)
      ..lineTo(s.width, s.height * 0.58)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(b, Paint()..color = back);
    canvas.drawPath(f, Paint()..color = front);
  }

  @override
  bool shouldRepaint(covariant _BandsPainter old) => old.back != back || old.front != front;
}

// ---------------------------------------------------------------------------
// Split panel: the two ways in

class _SplitPanel extends StatelessWidget {
  final bool mobile;
  final VoidCallback onScan;
  final VoidCallback onLibrary;
  const _SplitPanel({required this.mobile, required this.onScan, required this.onLibrary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final left = Container(
      color: isDark ? AppTheme.fieldDark : AppTheme.primaryTeal,
      padding: EdgeInsets.all(mobile ? 24 : 48),
      constraints: BoxConstraints(minHeight: mobile ? 0 : 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PosterLabel('Scan & triage', color: AppTheme.pale, size: 14.4),
          SizedBox(height: mobile ? 20 : 48),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Text(
              'Upload a photo or pick a verified test case. Dermatriage names the most likely class, shows where the model looked, and gives the triage protocol for that class.',
              style: TextStyle(fontSize: mobile ? 17 : 20, height: 1.3, fontWeight: FontWeight.w300, color: AppTheme.pale),
            ),
          ),
          SizedBox(height: mobile ? 24 : 40),
          ElevatedButton.icon(
            onPressed: onScan,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pale, foregroundColor: AppTheme.ink),
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: const Text('Start a scan'),
          ),
        ],
      ),
    );
    final right = Material(
      color: isDark ? AppTheme.quietPanelDark : AppTheme.quietPanel,
      child: InkWell(
        onTap: onLibrary,
        child: Container(
          constraints: BoxConstraints(minHeight: mobile ? 260 : 420),
          padding: EdgeInsets.all(mobile ? 24 : 48),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Display('EXANTHEM', size: mobile ? 64 : 112, color: AppTheme.paper, height: 0.8, align: TextAlign.center),
              Display('LIBRARY', size: mobile ? 64 : 112, color: AppTheme.paper, height: 0.8, align: TextAlign.center),
              const SizedBox(height: 22),
              PosterLabel('Hallmarks, differentials, isolation  →', color: AppTheme.pale, align: TextAlign.center),
            ],
          ),
        ),
      ),
    );
    if (mobile) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, right]);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: left), Expanded(child: right)]),
    );
  }
}

// ---------------------------------------------------------------------------
// Word wall: the six classes, staggered, each opening its library entry

class _WordWall extends StatelessWidget {
  final double width;
  final bool mobile;
  final ValueChanged<String> onOpen;
  const _WordWall({required this.width, required this.mobile, required this.onOpen});

  static const _words = {
    'mpox': 'MPOX',
    'chickenpox': 'CHICKENPOX',
    'measles': 'MEASLES',
    'cowpox': 'COWPOX',
    'hfmd': 'HFMD',
    'healthy': 'HEALTHY',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = (mobile ? width * 0.17 : width * 0.135).clamp(56.0, 210.0);
    final items = ExanthemInfo.allExanthems.where((e) => _words.containsKey(e.id)).toList();
    return Container(
      color: isDark ? AppTheme.paperDark : AppTheme.paper,
      padding: EdgeInsets.symmetric(vertical: mobile ? 64 : 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 40),
            child: Text(
              'Six classes the model tells apart. Open one for its hallmarks and protocol.',
              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w300,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          SizedBox(height: mobile ? 28 : 48),
          for (var i = 0; i < items.length; i++)
            _WallWord(
              word: _words[items[i].id]!,
              urgency: items[i].triagePriority,
              size: size,
              alignRight: i.isOdd,
              indent: mobile ? 20 : [40.0, 120.0, 220.0, 80.0, 300.0, 160.0][i],
              onTap: () => onOpen(items[i].id),
            ),
        ],
      ),
    );
  }
}

class _WallWord extends StatefulWidget {
  final String word;
  final String urgency;
  final double size;
  final bool alignRight;
  final double indent;
  final VoidCallback onTap;
  const _WallWord({
    required this.word,
    required this.urgency,
    required this.size,
    required this.alignRight,
    required this.indent,
    required this.onTap,
  });

  @override
  State<_WallWord> createState() => _WallWordState();
}

class _WallWordState extends State<_WallWord> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.pale : AppTheme.ink;
    final tagColor = urgencyTextColor(widget.urgency, isDark);
    final tag = PosterLabel(widget.urgency, color: tagColor, size: 11.2);
    final word = AnimatedDefaultTextStyle(
      duration: AppMotion.fast,
      style: AppTheme.displayStyle(widget.size, _hover ? (isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal) : ink,
          height: 0.78),
      child: Text(widget.word),
    );
    return Semantics(
      button: true,
      label: '${widget.word}, ${widget.urgency}. Open in the exanthem library',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: widget.onTap,
          onHover: (h) => setState(() => _hover = h),
          child: Padding(
            padding: EdgeInsets.only(
              left: widget.alignRight ? 20 : widget.indent,
              right: widget.alignRight ? widget.indent : 20,
            ),
            child: Row(
              mainAxisAlignment: widget.alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.alignRight) ...[tag, const SizedBox(width: 16)],
                Flexible(child: FittedBox(fit: BoxFit.scaleDown, alignment: widget.alignRight ? Alignment.centerRight : Alignment.centerLeft, child: word)),
                if (!widget.alignRight) ...[const SizedBox(width: 16), tag],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// How it works: three columns on the cool wash, divided by hairlines

class _HowItWorks extends StatelessWidget {
  final bool mobile;
  const _HowItWorks({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? AppTheme.pale : AppTheme.ink;
    final body = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final rule = isDark ? AppTheme.borderSubtleDark : AppTheme.ink.withValues(alpha: 0.2);
    const steps = [
      (
        Icons.add_a_photo_outlined,
        'Intake',
        'A photo is resized and normalized. The app sends it to the PyTorch server, or falls back to a simple on-device estimate when the server is out of reach.'
      ),
      (
        Icons.call_split_outlined,
        'Two branches',
        'A ResNet-50 reads the lesion\'s texture. A ViT-B/16 reads the whole image in patches. Cross-attention lets the first decide which patches matter.'
      ),
      (
        Icons.rule_outlined,
        'Triage',
        'You get the class, a probability for each class, the attention map, and the urgency level with its isolation precautions and next steps.'
      ),
    ];
    Widget col((IconData, String, String) s) => Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 0 : 32, vertical: mobile ? 22 : 0),
          child: Column(
            crossAxisAlignment: mobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(s.$1, size: 26, color: ink),
              const SizedBox(height: 18),
              Display(s.$2, size: mobile ? 40 : 48, color: ink, height: 1.0, align: mobile ? TextAlign.start : TextAlign.center),
              const SizedBox(height: 14),
              Text(s.$3,
                  textAlign: mobile ? TextAlign.start : TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.35, fontWeight: FontWeight.w300, color: body)),
            ],
          ),
        );
    return Container(
      color: isDark ? AppTheme.skyWashDark : AppTheme.skyWash,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 40, vertical: mobile ? 64 : 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Display('HOW IT WORKS', size: mobile ? 56 : 120, color: ink, height: 0.8, align: TextAlign.center),
          SizedBox(height: mobile ? 36 : 72),
          if (mobile)
            Column(children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) Divider(color: rule, height: 1),
                col(steps[i]),
              ]
            ])
          else
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) VerticalDivider(color: rule, width: 1, thickness: 1),
                  Expanded(child: col(steps[i])),
                ]
              ]),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Validation band

class _ValidationBand extends StatelessWidget {
  final bool mobile;
  final VoidCallback onOpen;
  const _ValidationBand({required this.mobile, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const text = Color(0xFFE0F2FE);
    return Container(
      color: isDark ? AppTheme.cyanBandDark : AppTheme.cyanBand,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 40, vertical: mobile ? 64 : 112),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Display('Checked against\nthe baselines', size: mobile ? 52 : 116, color: text, height: 0.78),
            const SizedBox(height: 28),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: const Text(
                'Trained on MSLD v2.0 with patient-independent cross-validation, and compared with ResNet-50 alone, the ViT alone, and a plain concatenation of both.',
                style: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w300, color: text),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onOpen,
              style: OutlinedButton.styleFrom(foregroundColor: text, side: const BorderSide(color: text)),
              icon: const Icon(Icons.bar_chart_outlined, size: 18),
              label: const Text('Open benchmarks'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Framed footer card

class _FramedFooter extends StatelessWidget {
  final bool mobile;
  final InferenceService inference;
  final Function(int) onNavigate;
  const _FramedFooter({required this.mobile, required this.inference, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppTheme.bandDark : AppTheme.paper;
    final ink = isDark ? AppTheme.pale : AppTheme.ink;
    final soft = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final rule = isDark ? AppTheme.borderSubtleDark : AppTheme.ink.withValues(alpha: 0.2);
    final online = inference.isPyTorchServerOnline;

    Widget heading(String t) => PosterLabel(t, color: soft, size: 11.2, tracking: 0.6);
    Widget link(String t, int i) => InkWell(
          onTap: () => onNavigate(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(t.toUpperCase(), style: AppTheme.labelStyle(ink).copyWith(fontWeight: FontWeight.w400)),
          ),
        );
    final cols = <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Display('Dermatriage', size: 48, color: ink, height: 1.0),
        const SizedBox(height: 12),
        Text(
          'Decision support for clinicians assessing viral rashes. It suggests; it does not diagnose.',
          style: TextStyle(fontSize: 14.4, height: 1.3, fontWeight: FontWeight.w300, color: soft),
        ),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        heading('Workspaces'),
        const SizedBox(height: 10),
        link('Scan & triage', 1),
        link('Exanthem library', 2),
        link('Benchmarks', 3),
        link('Records', 4),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        heading('Engine'),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? ink : null,
              border: online ? null : Border.all(color: ink, width: 1.2),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(online ? 'PyTorch server connected' : 'Offline Dart estimate',
                style: TextStyle(fontSize: 14.4, fontWeight: FontWeight.w300, color: ink)),
          ),
        ]),
        const SizedBox(height: 22),
        heading('Dataset'),
        const SizedBox(height: 12),
        Text('MSLD v2.0, six classes', style: TextStyle(fontSize: 14.4, fontWeight: FontWeight.w300, color: ink)),
      ]),
    ];

    return Container(
      color: isDark ? const Color(0xFF04211E) : AppTheme.frame,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(7)),
        padding: EdgeInsets.fromLTRB(mobile ? 20 : 24, mobile ? 24 : 32, mobile ? 20 : 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mobile)
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < cols.length; i++) ...[
                  if (i > 0) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: rule, height: 1)),
                  cols[i],
                ]
              ])
            else
              IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < cols.length; i++) ...[
                    if (i > 0) VerticalDivider(color: rule, width: 48, thickness: 1),
                    Expanded(flex: i == 0 ? 3 : 2, child: cols[i]),
                  ]
                ]),
              ),
            const SizedBox(height: 32),
            Divider(color: rule, height: 1),
            const SizedBox(height: 14),
            Text('A side project by Raven Neil Ocampo', style: AppTheme.labelStyle(soft, size: 9.6, tracking: 0.2)),
          ],
        ),
      ),
    );
  }
}
