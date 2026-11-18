import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared pieces of the poster world: arch masks, labels, colour fields.

/// A rectangle whose top edge is a full semicircle: the arch window used for
/// every lesion photograph instead of rounded corners.
class ArchClipper extends CustomClipper<Path> {
  const ArchClipper();

  @override
  Path getClip(Size size) {
    final r = size.width / 2;
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, r)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Arch-masked image with an optional 1px outline that follows the arch.
class ArchImage extends StatelessWidget {
  final ImageProvider image;
  final double width;
  final double height;
  final Color? outline;
  final String? semanticLabel;

  const ArchImage({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    this.outline,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        foregroundPainter: outline == null ? null : _ArchOutlinePainter(outline!),
        child: ClipPath(
          clipper: const ArchClipper(),
          child: Image(
            image: image,
            width: width,
            height: height,
            fit: BoxFit.cover,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }
}

class _ArchOutlinePainter extends CustomPainter {
  final Color color;
  _ArchOutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(const ArchClipper().getClip(size), p);
  }

  @override
  bool shouldRepaint(covariant _ArchOutlinePainter old) => old.color != color;
}

/// Small uppercase DM Sans Light label.
class PosterLabel extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double tracking;
  final TextAlign? align;

  const PosterLabel(
    this.text, {
    super.key,
    required this.color,
    this.size = 12.8,
    this.tracking = 0.48,
    this.align,
  });

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        textAlign: align,
        style: AppTheme.labelStyle(color, size: size, tracking: tracking),
      );
}

/// Condensed display line in Italiana.
class Display extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final double height;
  final TextAlign? align;
  final int? maxLines;
  final bool upper;

  const Display(
    this.text, {
    super.key,
    required this.size,
    required this.color,
    this.height = 0.9,
    this.align,
    this.maxLines,
    this.upper = false,
  });

  @override
  Widget build(BuildContext context) => Text(
        upper ? text.toUpperCase() : text,
        textAlign: align,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: AppTheme.displayStyle(size, color, height: height),
      );
}

/// Screen header used by every workspace: a display title on a flat field,
/// a light lead line under it, and a 1px rule closing the field.
class WorkspaceHeader extends StatelessWidget {
  final String title;
  final String lead;
  final Widget? trailing;

  const WorkspaceHeader({super.key, required this.title, required this.lead, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;
    final ink = isDark ? AppTheme.pale : AppTheme.ink;
    final lead2 = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Display(title, size: mobile ? 52 : 84, color: ink, height: 0.86),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(lead, style: TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w300, color: lead2)),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(mobile ? 20 : 40, mobile ? 28 : 44, mobile ? 20 : 40, mobile ? 22 : 30),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight)),
      ),
      child: trailing == null || mobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              titleBlock,
              if (trailing != null) ...[const SizedBox(height: 18), trailing!],
            ])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Expanded(child: titleBlock), const SizedBox(width: 24), trailing!],
            ),
    );
  }
}

/// Text colour for urgency labels that clears AA on the urgency tint.
Color urgencyTextColor(String urgency, bool isDark) {
  if (urgency.contains('Level 1') || urgency.contains('High')) {
    return isDark ? AppTheme.level1RedBorder : const Color(0xFFB91C1C);
  } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
    return isDark ? AppTheme.level2AmberBorder : AppTheme.level2AmberBorderDark;
  } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
    return isDark ? AppTheme.level3BlueBorder : AppTheme.level3BlueBorderDark;
  }
  return isDark ? AppTheme.level4GreenBorder : AppTheme.level4GreenBorderDark;
}

/// Full-width urgency field colour; white text clears AA on every level.
Color urgencyFieldColor(String urgency) {
  if (urgency.contains('Level 1') || urgency.contains('High')) return AppTheme.level1Red;
  if (urgency.contains('Level 2') || urgency.contains('Urgent')) return AppTheme.level2AmberBorderDark;
  if (urgency.contains('Level 3') || urgency.contains('Standard')) return AppTheme.level3Blue;
  return AppTheme.level4GreenBorderDark;
}

/// A line icon standing in a small arch: the world's stand-in for icon badges.
class ArchIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double width;

  const ArchIcon({super.key, required this.icon, required this.color, this.width = 64});

  @override
  Widget build(BuildContext context) {
    final h = width * 1.3;
    return SizedBox(
      width: width,
      height: h,
      child: CustomPaint(
        painter: _ArchOutlinePainter(color.withValues(alpha: 0.7)),
        child: Padding(
          padding: EdgeInsets.only(top: width * 0.42),
          child: Center(child: Icon(icon, size: width * 0.44, color: color)),
        ),
      ),
    );
  }
}
