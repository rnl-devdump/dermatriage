import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'poster.dart';

/// Flat, square urgency tag: the urgency tint, a 1px urgency rule, and an
/// uppercase label in a shade that clears contrast on that tint.
class UrgencyBadgeWidget extends StatelessWidget {
  final String urgency;
  final bool isLarge;

  const UrgencyBadgeWidget({
    super.key,
    required this.urgency,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppTheme.getUrgencyBg(urgency, isDark);
    final border = AppTheme.getUrgencyBorder(urgency, isDark);
    final text = urgencyTextColor(urgency, isDark);

    IconData icon;
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      icon = Icons.warning_amber_rounded;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      icon = Icons.error_outline_rounded;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      icon = Icons.info_outline_rounded;
    } else {
      icon = Icons.check_circle_outline_rounded;
    }

    return Semantics(
      label: 'Triage urgency: $urgency',
      child: Container(
        constraints: BoxConstraints(maxWidth: isLarge ? 300 : 220),
        padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 8, vertical: isLarge ? 8 : 5),
        decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 1)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isLarge ? 16 : 13, color: text),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                urgency.toUpperCase(),
                style: AppTheme.labelStyle(text, size: isLarge ? 12.8 : 11.2, tracking: 0.4)
                    .copyWith(fontWeight: FontWeight.w400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
