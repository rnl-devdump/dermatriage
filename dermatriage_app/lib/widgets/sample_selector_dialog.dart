import 'package:flutter/material.dart';
import '../models/exanthem_info.dart';
import '../theme/app_theme.dart';

class SampleSelectorDialog extends StatelessWidget {
  final Function(String assetPath, String className) onSelectSample;

  const SampleSelectorDialog({super.key, required this.onSelectSample});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 500;

    return Dialog(
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? AppTheme.borderFocusedDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        width: screenWidth * 0.94,
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified MSLD v2.0 Test Cases',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Select a clinical case from the held-out validation split',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : const Color(0xFF64748B),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(
              height: 24,
              color: isDark
                  ? AppTheme.borderFocusedDark
                  : AppTheme.borderSubtleLight,
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: ExanthemInfo.allExanthems.map((ex) {
                    final urgencyColor = AppTheme.getUrgencyColor(
                      ex.triagePriority,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: urgencyColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ex.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isDark
                                          ? AppTheme.tealAccentDark
                                          : AppTheme.primaryTeal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Text(
                                '${ex.modelSupport} Cases • F1: ${(ex.modelF1 * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppTheme.textMutedDark
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, boxConstraints) {
                              final isNarrow = boxConstraints.maxWidth < 360;
                              final items = ex.sampleAssets.map((path) {
                                final sampleNum = path.contains('sample_1')
                                    ? 'Case 1'
                                    : 'Case 2';
                                final card = InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onSelectSample(path, ex.name);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: isNarrow ? 0 : 4,
                                      vertical: isNarrow ? 4 : 0,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.cardDark
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.asset(
                                            path,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: isDark
                                                      ? Colors.white10
                                                      : Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 22,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sampleNum,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? AppTheme.textPrimaryDark
                                                      : AppTheme
                                                            .textPrimaryLight,
                                                ),
                                              ),
                                              Text(
                                                'Tap to evaluate',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: isDark
                                                      ? AppTheme.tealAccentDark
                                                      : const Color(0xFF006A6B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 11,
                                          color: isDark
                                              ? AppTheme.textMutedDark
                                              : Colors.grey.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                );

                                if (isNarrow) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: card,
                                  );
                                } else {
                                  return Expanded(child: card);
                                }
                              }).toList();

                              if (isNarrow) {
                                return Column(children: items);
                              } else {
                                return Row(children: items);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
