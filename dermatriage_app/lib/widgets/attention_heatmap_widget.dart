import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AttentionHeatmapWidget extends StatefulWidget {
  final List<double> attentionTokens; // 196 tokens (14x14)
  final Uint8List? imageBytes;
  final String? sampleAssetPath;

  const AttentionHeatmapWidget({
    super.key,
    required this.attentionTokens,
    this.imageBytes,
    this.sampleAssetPath,
  });

  @override
  State<AttentionHeatmapWidget> createState() => _AttentionHeatmapWidgetState();
}

class _AttentionHeatmapWidgetState extends State<AttentionHeatmapWidget> {
  double _overlayOpacity = 0.58;
  bool _showGridLines = true;
  int? _hoveredIndex;
  bool _sideBySideMode = false;

  Color _getHeatmapColor(double val) {
    // Turbo/Medical Colormap: Deep Navy -> Cyan -> Emerald -> Amber -> Crimson
    final clamped = val.clamp(0.0, 1.0);
    if (clamped < 0.25) {
      final t = clamped / 0.25;
      return Color.lerp(const Color(0xFF1E3A8A), const Color(0xFF0284C7), t)!;
    } else if (clamped < 0.5) {
      final t = (clamped - 0.25) / 0.25;
      return Color.lerp(const Color(0xFF0284C7), const Color(0xFF10B981), t)!;
    } else if (clamped < 0.75) {
      final t = (clamped - 0.5) / 0.25;
      return Color.lerp(const Color(0xFF10B981), const Color(0xFFF59E0B), t)!;
    } else {
      final t = (clamped - 0.75) / 0.25;
      return Color.lerp(const Color(0xFFF59E0B), const Color(0xFFEF4444), t)!;
    }
  }

  Widget _buildRawImage() {
    if (widget.imageBytes != null) {
      return Image.memory(widget.imageBytes!, fit: BoxFit.cover);
    } else if (widget.sampleAssetPath != null) {
      return Image.asset(widget.sampleAssetPath!, fit: BoxFit.cover);
    }
    return Container(color: Colors.black12);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = widget.attentionTokens;
    final hasTokens = tokens.length == 196;

    if (!hasTokens) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Attention map tokens not available (expected 196 for 14x14 grid).',
            style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontSize: 12.5,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vision Transformer Cross-Attention Map (14×14 Patches)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ResNet-50 query attending to 196 spatial ViT-B/16 tokens',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _sideBySideMode
                  ? 'Switch to Overlay Mode'
                  : 'Switch to Side-by-Side Mode',
              icon: Icon(
                _sideBySideMode
                    ? Icons.layers_rounded
                    : Icons.splitscreen_rounded,
                size: 19,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
              onPressed: () {
                setState(() => _sideBySideMode = !_sideBySideMode);
              },
            ),
            IconButton(
              tooltip: _showGridLines ? 'Hide Token Grid' : 'Show Token Grid',
              icon: Icon(
                _showGridLines ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                size: 19,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : const Color(0xFF64748B),
              ),
              onPressed: () {
                setState(() => _showGridLines = !_showGridLines);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Display Viewport (Overlay or Side-by-Side)
        AnimatedSwitcher(
          duration: AppMotion.medium,
          switchInCurve: AppMotion.curve,
          switchOutCurve: Curves.easeIn,
          child: _sideBySideMode
              ? Row(
                  key: const ValueKey('side_by_side'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            'Lesion Source',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.borderFocusedDark
                                    : AppTheme.borderSubtleLight,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildRawImage(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            'ViT Attention Grid',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildHeatmapContainer(130, 130, isDark, tokens),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  key: const ValueKey('overlay_view'),
                  child: _buildHeatmapContainer(256, 256, isDark, tokens),
                ),
        ),

        const SizedBox(height: 14),

        // Token Inspector readout
        AnimatedContainer(
          duration: AppMotion.fast,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hoveredIndex != null
                  ? (isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal)
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
              width: _hoveredIndex != null ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lens_blur_rounded,
                    size: 16,
                    color: _hoveredIndex != null
                        ? _getHeatmapColor(tokens[_hoveredIndex!])
                        : (isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textSecondaryLight),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _hoveredIndex != null
                        ? 'Token #${_hoveredIndex! + 1} (Row ${(_hoveredIndex! ~/ 14) + 1}, Col ${(_hoveredIndex! % 14) + 1})'
                        : 'Hover or tap patches to inspect spatial ViT tokens',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: _hoveredIndex != null
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              if (_hoveredIndex != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getHeatmapColor(
                      tokens[_hoveredIndex!],
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getHeatmapColor(tokens[_hoveredIndex!]),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${(tokens[_hoveredIndex!] * 100).toStringAsFixed(1)}% Attn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _getHeatmapColor(tokens[_hoveredIndex!]),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Opacity Slider
        Row(
          children: [
            Text(
              'Heatmap Opacity:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: isDark
                      ? AppTheme.tealAccentDark
                      : AppTheme.primaryTeal,
                  thumbColor: isDark
                      ? AppTheme.tealAccentDark
                      : AppTheme.primaryTeal,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: _overlayOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  label: '${(_overlayOpacity * 100).round()}%',
                  onChanged: (v) => setState(() => _overlayOpacity = v),
                ),
              ),
            ),
            Text(
              '${(_overlayOpacity * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),

        // Colormap Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Low Attn (0.0)',
              style: TextStyle(
                fontSize: 10.5,
                color: isDark
                    ? AppTheme.textMutedDark
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 150,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF0284C7),
                    Color(0xFF10B981),
                    Color(0xFFF59E0B),
                    Color(0xFFEF4444),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'High Attn (1.0)',
              style: TextStyle(
                fontSize: 10.5,
                color: isDark
                    ? AppTheme.textMutedDark
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatmapContainer(
    double width,
    double height,
    bool isDark,
    List<double> tokens,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderFocusedDark : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _buildRawImage()),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: _overlayOpacity,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 14,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemCount: 196,
                itemBuilder: (context, idx) {
                  final val = tokens[idx];
                  final color = _getHeatmapColor(val);
                  final isHovered = _hoveredIndex == idx;
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = idx),
                    onExit: (_) {
                      if (_hoveredIndex == idx) {
                        setState(() => _hoveredIndex = null);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: _showGridLines
                            ? Border.all(
                                color: isHovered
                                    ? Colors.white
                                    : Colors.black.withValues(alpha: 0.1),
                                width: isHovered ? 1.5 : 0.35,
                              )
                            : (isHovered
                                  ? Border.all(color: Colors.white, width: 1.5)
                                  : null),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
