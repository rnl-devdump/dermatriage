import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'poster.dart';

/// One class in the probability breakdown: name, a flat bar that sweeps in,
/// and the value in DM Mono so columns stay aligned.
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
      barColor = isDark ? AppTheme.textMutedDark : AppTheme.quietPanel;
    }

    final primaryText = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final secondaryText = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: isTopClass ? FontWeight.w400 : FontWeight.w300,
                        color: isTopClass ? primaryText : secondaryText,
                      ),
                    ),
                    if (isTopClass)
                      PosterLabel('Primary', color: isDark ? AppTheme.pale : AppTheme.ink, size: 10.4, tracking: 0.8),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$pct%',
                style: AppTheme.monoStyle(
                  isTopClass ? 15 : 14,
                  isTopClass ? primaryText : secondaryText,
                  weight: isTopClass ? FontWeight.w400 : FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: isTopClass ? 6 : 4,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: clampedProb),
                  duration: animationDuration,
                  curve: AppMotion.curve,
                  builder: (context, v, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    heightFactor: 1,
                    child: ColoredBox(color: barColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
