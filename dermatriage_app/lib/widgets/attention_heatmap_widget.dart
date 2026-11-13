import 'dart:typed_data';
import 'package:flutter/material.dart';

class AttentionHeatmapWidget extends StatefulWidget {
  final List<double> attentionTokens; // 196 tokens
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
  double _overlayOpacity = 0.55;
  bool _showGridLines = true;
  int? _hoveredIndex;

  Color _getHeatmapColor(double val) {
    // Jet/Turbo-like colormap: Blue -> Cyan -> Green -> Yellow -> Red
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

  @override
  Widget build(BuildContext context) {
    final tokens = widget.attentionTokens;
    final hasTokens = tokens.length == 196;

    if (!hasTokens) {
      return const Center(
        child: Text('Attention map tokens not available (expected 196 for 14x14 grid).'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vision Transformer Cross-Attention Map (14×14 Patches)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Local ResNet-50 query attending to 196 ViT-B/16 spatial patch tokens',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: _showGridLines ? 'Hide Grid' : 'Show Grid',
                  icon: Icon(
                    _showGridLines ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _showGridLines = !_showGridLines;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Underlying lesion image
                Positioned.fill(
                  child: widget.imageBytes != null
                      ? Image.memory(
                          widget.imageBytes!,
                          fit: BoxFit.cover,
                        )
                      : (widget.sampleAssetPath != null
                          ? Image.asset(
                              widget.sampleAssetPath!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.black12)),
                ),
                // Heatmap Overlay Grid
                Positioned.fill(
                  child: Opacity(
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
                          onExit: (_) => setState(() => _hoveredIndex = null),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              border: _showGridLines
                                  ? Border.all(
                                      color: isHovered ? Colors.white : Colors.black.withValues(alpha: 0.08),
                                      width: isHovered ? 1.5 : 0.4,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_hoveredIndex != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Patch #$_hoveredIndex: ${(tokens[_hoveredIndex!] * 100).toStringAsFixed(1)}% Weight',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Heatmap Opacity:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Slider(
                value: _overlayOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: const Color(0xFF006A6B),
                label: '${(_overlayOpacity * 100).round()}%',
                onChanged: (v) {
                  setState(() {
                    _overlayOpacity = v;
                  });
                },
              ),
            ),
            Text(
              '${(_overlayOpacity * 100).round()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        // Colorbar legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Low Focus', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
            const SizedBox(width: 8),
            Container(
              width: 140,
              height: 10,
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
            const Text('High Focus', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
