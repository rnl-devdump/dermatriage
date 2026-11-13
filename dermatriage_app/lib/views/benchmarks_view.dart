import 'package:flutter/material.dart';
import '../services/benchmark_service.dart';

class BenchmarksView extends StatefulWidget {
  const BenchmarksView({super.key});

  @override
  State<BenchmarksView> createState() => _BenchmarksViewState();
}

class _BenchmarksViewState extends State<BenchmarksView> {
  final BenchmarkService _service = BenchmarkService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.loadAssets();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showImageDialog(String assetPath, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          width: MediaQuery.of(context).size.width * 0.95,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _service.benchmarkData;
    if (data == null) {
      return const Center(child: Text('Benchmark data not available.'));
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Research Evaluation & Benchmarks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Empirical 5-fold cross-validation results from MSLDv2_CNN_ViT_CrossAttention_Outputs',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            // Model Architecture Comparison Table (Mean ± SD)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.leaderboard_rounded, color: Color(0xFF006A6B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        '5-Fold Cross-Validation Summary (Mean ± SD)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Comparison of Proposed Dual-Branch Cross-Attention vs 3 Matched Ablation Baselines across all 5 folds',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Evaluated Model', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Val Macro F1 (%)', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Test Acc (%)', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Test Precision (%)', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Test Recall (%)', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Test Macro F1 (%)', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: data.fiveFoldSummary.map((item) {
                        final isProposed = item['model'].toString().contains('Proposed');
                        return DataRow(
                          color: isProposed
                              ? WidgetStateProperty.all(const Color(0xFFF0FDF4))
                              : null,
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  if (isProposed) ...[
                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFF10B981)),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    item['model'].toString(),
                                    style: TextStyle(
                                      fontWeight: isProposed ? FontWeight.w800 : FontWeight.w600,
                                      color: isProposed ? const Color(0xFF006A6B) : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text('${item['val_macro_f1_mean']} ± ${item['val_macro_f1_std']}', style: TextStyle(fontWeight: isProposed ? FontWeight.w700 : FontWeight.w500))),
                            DataCell(Text('${item['test_acc_mean']} ± ${item['test_acc_std']}', style: TextStyle(fontWeight: isProposed ? FontWeight.w700 : FontWeight.w500))),
                            DataCell(Text('${item['test_precision_mean']} ± ${item['test_precision_std']}')),
                            DataCell(Text('${item['test_recall_mean']} ± ${item['test_recall_std']}')),
                            DataCell(
                              Text(
                                '${item['test_f1_mean']} ± ${item['test_f1_std']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isProposed ? const Color(0xFF006A6B) : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fold 1 Test Classification Report & Confusion Matrix
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final reportCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assessment_rounded, color: Color(0xFF0284C7), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Fold 1 Held-Out Test Classification Report',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Overall Accuracy: 82.43% | Macro F1: 82.38% on 74 Patient-Isolated Samples',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 18,
                          columns: const [
                            DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Precision', style: TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Recall', style: TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('F1-Score', style: TextStyle(fontWeight: FontWeight.w700))),
                            DataColumn(label: Text('Support', style: TextStyle(fontWeight: FontWeight.w700))),
                          ],
                          rows: data.classes.map((cls) {
                            final rep = data.classificationReport[cls] as Map<String, dynamic>? ?? {};
                            final p = (rep['precision'] as num?)?.toDouble() ?? 0.0;
                            final r = (rep['recall'] as num?)?.toDouble() ?? 0.0;
                            final f1 = (rep['f1'] as num?)?.toDouble() ?? 0.0;
                            final sup = (rep['support'] as num?)?.toInt() ?? 0;
                            return DataRow(
                              cells: [
                                DataCell(Text(cls, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text('${(p * 100).toStringAsFixed(1)}%')),
                                DataCell(Text('${(r * 100).toStringAsFixed(1)}%')),
                                DataCell(Text('${(f1 * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF006A6B)))),
                                DataCell(Text('$sup')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );

                final matrixCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.grid_4x4_rounded, color: Color(0xFF006A6B), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Test Confusion Matrix (Proposed Fold 1)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Rows: Ground Truth Class • Columns: Model Predicted Class',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      _buildConfusionMatrixWidget(data.confusionMatrix, data.classes),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: reportCard),
                      const SizedBox(width: 20),
                      Expanded(flex: 6, child: matrixCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      reportCard,
                      const SizedBox(height: 20),
                      matrixCard,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Embedded Research Plots Section
            const Text(
              'Research Publication Visualizations',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click any figure to inspect high-resolution heatmaps and convergence curves',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final card1 = _buildImageCard(
                  'assets/images/research/cnn_vit_cross_attention_heatmaps.png',
                  'Local-to-Global Cross-Attention Heatmaps',
                  'Spatial token activation & counterfactual null-query shift',
                );
                final card2 = _buildImageCard(
                  'assets/images/research/test_confusion_matrices_comparison.png',
                  '4-Model Confusion Matrices Comparison',
                  'Held-out test split across all evaluated architectures',
                );
                final card3 = _buildImageCard(
                  'assets/images/research/two_stage_training_curves.png',
                  'Differential Two-Stage Training Curves',
                  'Stage 1 Warmup -> Stage 2 Fine-Tuning convergence',
                );

                if (constraints.maxWidth >= 900) {
                  return Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 16),
                      Expanded(child: card2),
                      const SizedBox(width: 16),
                      Expanded(child: card3),
                    ],
                  );
                } else if (constraints.maxWidth >= 550) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 16),
                          Expanded(child: card2),
                        ],
                      ),
                      const SizedBox(height: 16),
                      card3,
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      card1,
                      const SizedBox(height: 12),
                      card2,
                      const SizedBox(height: 12),
                      card3,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfusionMatrixWidget(List<List<int>> cm, List<String> classes) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 440),
        child: Column(
          children: [
            // Column Header
            Row(
              children: [
                const SizedBox(width: 85),
                ...classes.map((c) => Expanded(
                      child: Text(
                        c,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 6),
            ...cm.asMap().entries.map((rowEntry) {
              final rIdx = rowEntry.key;
              final row = rowEntry.value;
              final rowName = classes[rIdx];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 85,
                      child: Text(
                        rowName,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...row.asMap().entries.map((cellEntry) {
                      final cIdx = cellEntry.key;
                      final val = cellEntry.value;
                      final isDiag = rIdx == cIdx;
                      final intensity = (val / 27.0).clamp(0.0, 1.0);
                      final bgColor = isDiag
                          ? Color.lerp(const Color(0xFFE0F2FE), const Color(0xFF0284C7), intensity)!
                          : (val > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC));

                      return Expanded(
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDiag ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$val',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isDiag ? FontWeight.w800 : FontWeight.w500,
                              color: isDiag && intensity > 0.4 ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String assetPath, String title, String subtitle) {
    return InkWell(
      onTap: () => _showImageDialog(assetPath, title),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
