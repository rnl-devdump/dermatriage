import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final color = AppTheme.getUrgencyColor(urgency);
    final bg = AppTheme.getUrgencyBg(urgency, isDark);
    final border = AppTheme.getUrgencyBorder(urgency, isDark);

    IconData icon;
    if (urgency.contains('Level 1') || urgency.contains('High')) {
      icon = Icons.warning_rounded;
    } else if (urgency.contains('Level 2') || urgency.contains('Urgent')) {
      icon = Icons.error_outline_rounded;
    } else if (urgency.contains('Level 3') || urgency.contains('Standard')) {
      icon = Icons.info_outline_rounded;
    } else {
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: isLarge ? 280 : 210),
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 8 : 4.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: border, width: 1.2),
        boxShadow: (urgency.contains('Level 1') || urgency.contains('High'))
            ? [
                BoxShadow(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLarge ? 18 : 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              urgency,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: isLarge ? 13 : 11.5,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
