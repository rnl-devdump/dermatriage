import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProbabilityBarWidget extends StatelessWidget {
  final String label;
  final double probability;
  final bool isTopClass;

  const ProbabilityBarWidget({
    super.key,
    required this.label,
    required this.probability,
    this.isTopClass = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (probability * 100).toStringAsFixed(1);
    final clampedProb = probability.clamp(0.0, 1.0);

    Color barColor;
    if (isTopClass) {
      if (label == 'Mpox' || label == 'Cowpox') {
        barColor = AppTheme.level1Red;
      } else if (label == 'Measles') {
        barColor = AppTheme.level2Amber;
      } else if (label == 'Healthy') {
        barColor = AppTheme.level4Green;
      } else {
        barColor = AppTheme.primaryTeal;
      }
    } else {
      barColor = const Color(0xFF94A3B8);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isTopClass ? FontWeight.w700 : FontWeight.w500,
                      color: isTopClass ? const Color(0xFF0F172A) : const Color(0xFF334155),
                    ),
                  ),
                  if (isTopClass) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: barColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRIMARY',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: barColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isTopClass ? FontWeight.w700 : FontWeight.w600,
                  color: isTopClass ? barColor : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: clampedProb,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
