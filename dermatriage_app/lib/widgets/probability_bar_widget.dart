import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProbabilityBarWidget extends StatelessWidget {
  final String label;
  final double probability;
  final bool isTopClass;
  final Duration animationDuration;

  const ProbabilityBarWidget({
    super.key,
    required this.label,
    required this.probability,
    this.isTopClass = false,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (probability * 100).toStringAsFixed(1);
    final clampedProb = probability.clamp(0.0, 1.0);

    Color barColor;
    if (isTopClass) {
      if (label.contains('Mpox') || label.contains('Cowpox')) {
        barColor = AppTheme.level1Red;
      } else if (label.contains('Measles')) {
        barColor = AppTheme.level2Amber;
      } else if (label.contains('Healthy')) {
        barColor = AppTheme.level4Green;
      } else {
        barColor = isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal;
      }
    } else {
      barColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isTopClass
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isTopClass
                              ? (isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight)
                              : (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isTopClass) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: barColor.withValues(
                            alpha: isDark ? 0.25 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: barColor.withValues(
                              alpha: isDark ? 0.5 : 0.3,
                            ),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'PRIMARY',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: barColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isTopClass ? FontWeight.w700 : FontWeight.w600,
                  color: isTopClass
                      ? barColor
                      : (isDark
                            ? AppTheme.textSecondaryDark
                            : const Color(0xFF64748B)),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Animated Bar Track & Indicator
          Container(
            height: isTopClass ? 10 : 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(5),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedProb),
              duration: animationDuration,
              curve: AppMotion.curve,
              builder: (context, animatedValue, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: isTopClass
                          ? [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
