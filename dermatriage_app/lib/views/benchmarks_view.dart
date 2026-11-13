import 'package:flutter/material.dart';
import '../models/benchmark_data.dart';
import '../services/benchmark_service.dart';
import '../theme/app_theme.dart';

class BenchmarksView extends StatefulWidget {
  const BenchmarksView({super.key});

  @override
  State<BenchmarksView> createState() => _BenchmarksViewState();
}

class _BenchmarksViewState extends State<BenchmarksView>
    with SingleTickerProviderStateMixin {
  final BenchmarkService _service = BenchmarkService();
  late bool _isLoading;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countAnimation;

  // Confusion matrix hover/tap inspection state
  int? _hoveredRow;
  int? _hoveredCol;

  // Ablation visualizer selected metric
  String _selectedAblationMetric = 'val_macro_f1';

  // Training convergence selected model for fold details
  String _selectedConvergenceModel = 'Proposed (CNN-ViT Cross-Attention)';

  final Map<String, String> _ablationMetricLabels = {
    'val_macro_f1': 'Val Macro F1',
    'test_acc': 'Test Accuracy',
    'test_f1': 'Test Macro F1',
    'test_precision': 'Test Precision',
    'test_recall': 'Test Recall',
  };

  @override
  void initState() {
    super.initState();
    _isLoading = _service.benchmarkData == null;
    _animController = AnimationController(
      vsync: this,
      duration: AppMotion.entrance,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: AppMotion.curve,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: AppMotion.curve));
    _countAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );

    if (_isLoading) {
      _loadData();
    } else {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _service.loadAssets();
    if (mounted) {
      setState(() => _isLoading = false);
      _animController.forward();
    }
  }

  void _showImageLightbox(String assetPath, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 920, maxHeight: 820),
          padding: const EdgeInsets.all(20),
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
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textSecondaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : const Color(0xFF64748B),
                    tooltip: 'Close image view',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF090D14)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.borderSubtleDark
                          : AppTheme.borderSubtleLight,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: isDark
                                    ? AppTheme.textMutedDark
                                    : AppTheme.textSecondaryLight,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Visualization figure could not be loaded',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.textSecondaryLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.zoom_in_rounded,
                    size: 15,
                    color: isDark
                        ? AppTheme.tealAccentDark
                        : AppTheme.primaryTeal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pinch, scroll, or double click to zoom into resolution details',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppTheme.textMutedDark
                            : AppTheme.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Research Benchmark Logs...',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    final data = _service.benchmarkData;
    if (data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: isDark ? AppTheme.level2Amber : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              'Benchmark data not available.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 680;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 24,
              vertical: isMobile ? 14 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark, isMobile),
                const SizedBox(height: 20),
                _buildMetricCardsGrid(data, isDark, isMobile),
                const SizedBox(height: 24),
                _buildAblationVisualizer(data, isDark, isMobile),
                const SizedBox(height: 24),
                _buildSummaryTableCard(data, isDark, isMobile),
                const SizedBox(height: 24),
                _buildReportAndMatrixSection(data, isDark, screenWidth),
                const SizedBox(height: 28),
                _buildTrainingConvergenceSection(data, isDark, screenWidth),
                const SizedBox(height: 28),
                _buildResearchVisualizationsSection(isDark, screenWidth),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 22,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Research Evaluation & Benchmarks',
                    style: TextStyle(
                      fontSize: isMobile ? 19 : 22,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Empirical 5-fold cross-validation & held-out patient-isolated test evaluations',
                    style: TextStyle(
                      fontSize: isMobile ? 11.5 : 12.5,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCardsGrid(BenchmarkData data, bool isDark, bool isMobile) {
    final proposed = data.fiveFoldSummary.firstWhere(
      (m) => m['model'].toString().contains('Proposed'),
      orElse: () =>
          data.fiveFoldSummary.isNotEmpty ? data.fiveFoldSummary.first : {},
    );
    final cnn = data.fiveFoldSummary.firstWhere(
      (m) => m['model'].toString().contains('Standalone CNN'),
      orElse: () => {},
    );

    final cvF1Mean =
        (proposed['val_macro_f1_mean'] as num?)?.toDouble() ?? 86.81;
    final cvF1Std = (proposed['val_macro_f1_std'] as num?)?.toDouble() ?? 2.12;

    final testAccMean =
        (proposed['test_acc_mean'] as num?)?.toDouble() ?? 82.24;
    final testAccStd = (proposed['test_acc_std'] as num?)?.toDouble() ?? 4.26;

    final testF1Mean = (proposed['test_f1_mean'] as num?)?.toDouble() ?? 81.28;
    final testF1Std = (proposed['test_f1_std'] as num?)?.toDouble() ?? 5.02;

    final cnnValF1 = (cnn['val_macro_f1_mean'] as num?)?.toDouble() ?? 77.29;
    final diffF1 = cvF1Mean - cnnValF1;

    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, _) {
        final progress = _countAnimation.value;
        final cvF1Val = (cvF1Mean * progress).toStringAsFixed(2);
        final testAccVal = (testAccMean * progress).toStringAsFixed(2);
        final testF1Val = (testF1Mean * progress).toStringAsFixed(2);

        final cards = [
          _buildMetricCard(
            title: '5-Fold Cross-Val F1',
            value: '$cvF1Val%',
            subtext: '± ${cvF1Std.toStringAsFixed(2)}% Std Dev',
            badge:
                '${diffF1 >= 0 ? '+' : ''}${diffF1.toStringAsFixed(2)}% vs CNN',
            badgePositive: diffF1 >= 0,
            icon: Icons.auto_graph_rounded,
            accentColor: isDark
                ? AppTheme.tealAccentDark
                : AppTheme.primaryTeal,
            isDark: isDark,
          ),
          _buildMetricCard(
            title: 'Mean Held-Out Accuracy',
            value: '$testAccVal%',
            subtext: '± ${testAccStd.toStringAsFixed(2)}% (Held-Out Test)',
            badge: 'Patient-Isolated',
            badgePositive: true,
            icon: Icons.check_circle_outline_rounded,
            accentColor: const Color(0xFF0284C7),
            isDark: isDark,
          ),
          _buildMetricCard(
            title: 'Test Macro F1-Score',
            value: '$testF1Val%',
            subtext: '± ${testF1Std.toStringAsFixed(2)}% (6 Exanthem Classes)',
            badge: 'Balanced Score',
            badgePositive: true,
            icon: Icons.leaderboard_rounded,
            accentColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
          _buildMetricCard(
            title: 'Fusion Paradigm',
            value: 'Dual-Branch',
            subtext: 'ViT-B/16 Global × ResNet-50 Local',
            badge: 'Cross-Attention',
            badgePositive: true,
            icon: Icons.hub_rounded,
            accentColor: const Color(0xFF8B5CF6),
            isDark: isDark,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 950) {
              return Row(
                children: cards
                    .map(
                      (c) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: c,
                        ),
                      ),
                    )
                    .toList(),
              );
            } else if (constraints.maxWidth >= 540) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                children: cards
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: c,
                      ),
                    )
                    .toList(),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required String badge,
    required bool badgePositive,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (badgePositive
                              ? (isDark
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFECFDF5))
                              : (isDark
                                    ? const Color(0xFF451A03)
                                    : const Color(0xFFFFFBEB)))
                          .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgePositive
                        ? (isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669))
                        : (isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? AppTheme.textMutedDark
                        : AppTheme.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAblationVisualizer(
    BenchmarkData data,
    bool isDark,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.compare_arrows_rounded,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ablation Study Visualizer (Multi-Branch vs Standalone Baselines)',
                      style: TextStyle(
                        fontSize: isMobile ? 14.5 : 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Direct architectural performance impact of Cross-Attention vs Concatenation vs Standalone ViT vs Standalone CNN',
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
            ],
          ),
          const SizedBox(height: 14),

          // Metric Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ablationMetricLabels.entries.map((entry) {
                final isSelected = _selectedAblationMetric == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedAblationMetric = entry.key);
                      }
                    },
                    selectedColor:
                        (isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal)
                            .withValues(alpha: 0.2),
                    checkmarkColor: isDark
                        ? AppTheme.tealAccentDark
                        : AppTheme.primaryTeal,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal)
                          : (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight),
                    ),
                    backgroundColor: isDark
                        ? AppTheme.surfaceElevatedDark
                        : AppTheme.surfaceElevatedLight,
                    side: BorderSide(
                      color: isSelected
                          ? (isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal)
                          : (isDark
                                ? AppTheme.borderFocusedDark
                                : AppTheme.borderSubtleLight),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // Horizontal Bars with smooth metric transition animation
          TweenAnimationBuilder<double>(
            key: ValueKey('ablation_metric_$_selectedAblationMetric'),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: AppMotion.medium,
            curve: AppMotion.curve,
            builder: (context, metricAnim, _) {
              return Column(
                children: data.fiveFoldSummary.map((item) {
                  return _buildAblationBarItem(
                    item,
                    isDark,
                    isMobile,
                    metricAnim,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAblationBarItem(
    dynamic item,
    bool isDark,
    bool isMobile,
    double metricAnim,
  ) {
    final modelName = item['model'].toString();
    final isProposed = modelName.contains('Proposed');
    final description = item['description']?.toString() ?? '';

    double meanVal = 0.0;
    double stdVal = 0.0;

    switch (_selectedAblationMetric) {
      case 'val_macro_f1':
        meanVal = (item['val_macro_f1_mean'] as num?)?.toDouble() ?? 0.0;
        stdVal = (item['val_macro_f1_std'] as num?)?.toDouble() ?? 0.0;
        break;
      case 'test_acc':
        meanVal = (item['test_acc_mean'] as num?)?.toDouble() ?? 0.0;
        stdVal = (item['test_acc_std'] as num?)?.toDouble() ?? 0.0;
        break;
      case 'test_f1':
        meanVal = (item['test_f1_mean'] as num?)?.toDouble() ?? 0.0;
        stdVal = (item['test_f1_std'] as num?)?.toDouble() ?? 0.0;
        break;
      case 'test_precision':
        meanVal = (item['test_precision_mean'] as num?)?.toDouble() ?? 0.0;
        stdVal = (item['test_precision_std'] as num?)?.toDouble() ?? 0.0;
        break;
      case 'test_recall':
        meanVal = (item['test_recall_mean'] as num?)?.toDouble() ?? 0.0;
        stdVal = (item['test_recall_std'] as num?)?.toDouble() ?? 0.0;
        break;
    }

    // Baseline Standalone CNN comparison delta
    const cnnBaseValF1 = 77.29;
    final deltaOverCnn = meanVal - cnnBaseValF1;
    final progress = _countAnimation.value * metricAnim;
    final animatedFraction = (meanVal / 100.0 * progress).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isProposed
            ? (isDark
                  ? AppTheme.primaryTealDark.withValues(alpha: 0.25)
                  : const Color(0xFFF0FDF4))
            : (isDark
                  ? AppTheme.surfaceElevatedDark.withValues(alpha: 0.5)
                  : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isProposed
              ? (isDark ? AppTheme.tealAccentDark : const Color(0xFF10B981))
              : (isDark
                    ? AppTheme.borderSubtleDark
                    : AppTheme.borderSubtleLight),
          width: isProposed ? 1.4 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isProposed) ...[
                    Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: isDark
                          ? AppTheme.tealAccentDark
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 5),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? 180 : 340),
                    child: Text(
                      modelName,
                      style: TextStyle(
                        fontSize: isMobile ? 12.5 : 13.5,
                        fontWeight: isProposed
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isProposed
                            ? (isDark
                                  ? AppTheme.tealAccentDark
                                  : AppTheme.primaryTeal)
                            : (isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    '${(meanVal * progress).toStringAsFixed(2)}% ± ${stdVal.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: isMobile ? 10.5 : 13,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: isProposed
                          ? (isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal)
                          : (isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight),
                    ),
                  ),
                  if (!modelName.contains('Standalone CNN') &&
                      _selectedAblationMetric == 'val_macro_f1') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: deltaOverCnn >= 0
                            ? (isDark
                                  ? const Color(0xFF064E3B)
                                  : const Color(0xFFDCFCE7))
                            : (isDark
                                  ? const Color(0xFF450A0A)
                                  : const Color(0xFFFEE2E2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${deltaOverCnn >= 0 ? '+' : ''}${deltaOverCnn.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: deltaOverCnn >= 0
                              ? (isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF16A34A))
                              : (isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFDC2626)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Animated Bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: animatedFraction,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isProposed
                          ? (isDark
                                ? [
                                    AppTheme.primaryTeal,
                                    AppTheme.tealAccentDark,
                                  ]
                                : [
                                    const Color(0xFF006A6B),
                                    const Color(0xFF10B981),
                                  ])
                          : (isDark
                                ? [
                                    const Color(0xFF334155),
                                    const Color(0xFF64748B),
                                  ]
                                : [
                                    const Color(0xFF94A3B8),
                                    const Color(0xFF64748B),
                                  ]),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty && !isMobile) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark
                    ? AppTheme.textMutedDark
                    : AppTheme.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryTableCard(
    BenchmarkData data,
    bool isDark,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart_rounded,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '5-Fold Cross-Validation Summary (Mean ± SD)',
                  style: TextStyle(
                    fontSize: isMobile ? 14.5 : 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aggregated metrics across 5 patient-stratified folds on MSLD v2.0 benchmark set',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark
                  ? AppTheme.textMutedDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? AppTheme.surfaceElevatedDark
                    : AppTheme.surfaceElevatedLight,
              ),
              columnSpacing: isMobile ? 16 : 24,
              horizontalMargin: 12,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 52,
              columns: [
                DataColumn(
                  label: Text(
                    'Evaluated Model',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Val Macro F1 (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Test Acc (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Test Precision (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Test Recall (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Test Macro F1 (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ],
              rows: data.fiveFoldSummary.map((item) {
                final isProposed = item['model'].toString().contains(
                  'Proposed',
                );
                return DataRow(
                  color: isProposed
                      ? WidgetStateProperty.all(
                          isDark
                              ? AppTheme.primaryTealDark.withValues(alpha: 0.25)
                              : const Color(0xFFF0FDF4),
                        )
                      : null,
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isProposed) ...[
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: isDark
                                  ? AppTheme.tealAccentDark
                                  : const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            item['model'].toString(),
                            style: TextStyle(
                              fontWeight: isProposed
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isProposed
                                  ? (isDark
                                        ? AppTheme.tealAccentDark
                                        : AppTheme.primaryTeal)
                                  : (isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.textPrimaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['val_macro_f1_mean']} ± ${item['val_macro_f1_std']}',
                        style: TextStyle(
                          fontWeight: isProposed
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['test_acc_mean']} ± ${item['test_acc_std']}',
                        style: TextStyle(
                          fontWeight: isProposed
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['test_precision_mean']} ± ${item['test_precision_std']}',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['test_recall_mean']} ± ${item['test_recall_std']}',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${item['test_f1_mean']} ± ${item['test_f1_std']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isProposed
                              ? (isDark
                                    ? AppTheme.tealAccentDark
                                    : AppTheme.primaryTeal)
                              : (isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight),
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
    );
  }

  Widget _buildReportAndMatrixSection(
    BenchmarkData data,
    bool isDark,
    double screenWidth,
  ) {
    final isWide = screenWidth >= 1000;

    final reportCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment_rounded,
                color: isDark
                    ? AppTheme.medicalCyanLight
                    : const Color(0xFF0284C7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fold 1 Held-Out Test Classification Report',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final acc =
                  ((data.classificationReport['accuracy'] as num?)
                          ?.toDouble() ??
                      0.8243) *
                  100;
              final macroAvg =
                  data.classificationReport['macro_avg']
                      as Map<String, dynamic>? ??
                  {};
              final macroF1 =
                  ((macroAvg['f1'] as num?)?.toDouble() ?? 0.8238) * 100;
              final totalSupport = (macroAvg['support'] as num?)?.toInt() ?? 74;
              return Text(
                'Overall Accuracy: ${acc.toStringAsFixed(2)}% | Macro F1: ${macroF1.toStringAsFixed(2)}% on $totalSupport Patient-Isolated Samples',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.textMutedDark
                      : AppTheme.textSecondaryLight,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              horizontalMargin: 8,
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? AppTheme.surfaceElevatedDark
                    : AppTheme.surfaceElevatedLight,
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Class',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Precision',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Recall',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'F1-Score',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Support',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ],
              rows: data.classes.map((cls) {
                final rep =
                    data.classificationReport[cls] as Map<String, dynamic>? ??
                    {};
                final p = (rep['precision'] as num?)?.toDouble() ?? 0.0;
                final r = (rep['recall'] as num?)?.toDouble() ?? 0.0;
                final f1 = (rep['f1'] as num?)?.toDouble() ?? 0.0;
                final sup = (rep['support'] as num?)?.toInt() ?? 0;
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        cls,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${(p * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${(r * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${(f1 * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.tealAccentDark
                              : AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '$sup',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textSecondaryLight,
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
    );

    final matrixCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_4x4_rounded,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Interactive Confusion Matrix (Proposed Fold 1)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Rows: Actual Ground Truth • Columns: Model Prediction (Tap or hover cell)',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppTheme.textMutedDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),

          // The Interactive Matrix Widget
          _buildInteractiveConfusionMatrix(
            data.confusionMatrix,
            data.classes,
            isDark,
          ),

          const SizedBox(height: 12),

          // Inspection Readout Banner
          _buildConfusionInspectorBanner(
            data.confusionMatrix,
            data.classes,
            isDark,
          ),
        ],
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: reportCard),
          const SizedBox(width: 20),
          Expanded(flex: 7, child: matrixCard),
        ],
      );
    } else {
      return Column(
        children: [reportCard, const SizedBox(height: 20), matrixCard],
      );
    }
  }

  Widget _buildInteractiveConfusionMatrix(
    List<List<int>> cm,
    List<String> classes,
    bool isDark,
  ) {
    const double rowHeaderWidth = 86.0;
    const double cellWidth = 58.0;

    final maxVal = cm
        .expand((r) => r)
        .fold<int>(0, (max, v) => v > max ? v : max);
    final maxCellVal = maxVal > 0 ? maxVal.toDouble() : 1.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 440),
        child: Column(
          children: [
            // Column Header
            Row(
              children: [
                const SizedBox(width: rowHeaderWidth),
                ...classes.asMap().entries.map((entry) {
                  final colIdx = entry.key;
                  final c = entry.value;
                  final isHighlightedCol = _hoveredCol == colIdx;

                  return SizedBox(
                    width: cellWidth,
                    child: Tooltip(
                      message: c,
                      child: AnimatedDefaultTextStyle(
                        duration: AppMotion.fast,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isHighlightedCol
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isHighlightedCol
                              ? (isDark
                                    ? AppTheme.tealAccentDark
                                    : AppTheme.primaryTeal)
                              : (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight),
                        ),
                        child: Text(
                          c,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 6),

            // Rows
            ...cm.asMap().entries.map((rowEntry) {
              final rIdx = rowEntry.key;
              final row = rowEntry.value;
              final rowName = classes[rIdx];
              final isHighlightedRow = _hoveredRow == rIdx;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: [
                    SizedBox(
                      width: rowHeaderWidth,
                      child: Tooltip(
                        message: rowName,
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.fast,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isHighlightedRow
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isHighlightedRow
                                ? (isDark
                                      ? AppTheme.tealAccentDark
                                      : AppTheme.primaryTeal)
                                : (isDark
                                      ? AppTheme.textPrimaryDark
                                      : AppTheme.textPrimaryLight),
                          ),
                          child: Text(rowName, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                    ...row.asMap().entries.map((cellEntry) {
                      final cIdx = cellEntry.key;
                      final val = cellEntry.value;
                      final isDiag = rIdx == cIdx;
                      final isHovered =
                          _hoveredRow == rIdx && _hoveredCol == cIdx;
                      final intensity = (val / maxCellVal).clamp(0.0, 1.0);

                      Color cellBg;
                      Color textCol;

                      if (isDiag) {
                        if (isDark) {
                          cellBg = Color.lerp(
                            const Color(0xFF0F2E3A),
                            const Color(0xFF0D9488),
                            intensity,
                          )!;
                          textCol = intensity > 0.4
                              ? Colors.white
                              : AppTheme.tealAccentDark;
                        } else {
                          cellBg = Color.lerp(
                            const Color(0xFFE0F2FE),
                            const Color(0xFF0284C7),
                            intensity,
                          )!;
                          textCol = intensity > 0.4
                              ? Colors.white
                              : const Color(0xFF0F172A);
                        }
                      } else {
                        if (val > 0) {
                          cellBg = isDark
                              ? const Color(0xFF450A0A).withValues(alpha: 0.6)
                              : const Color(0xFFFEE2E2);
                          textCol = isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFB91C1C);
                        } else {
                          cellBg = isDark
                              ? AppTheme.surfaceElevatedDark
                              : const Color(0xFFF8FAFC);
                          textCol = isDark
                              ? AppTheme.textMutedDark
                              : const Color(0xFF94A3B8);
                        }
                      }

                      return SizedBox(
                        width: cellWidth,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) {
                            setState(() {
                              _hoveredRow = rIdx;
                              _hoveredCol = cIdx;
                            });
                          },
                          onExit: (_) {
                            // Keep state on mobile or leave null on exit
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_hoveredRow == rIdx &&
                                    _hoveredCol == cIdx) {
                                  _hoveredRow = null;
                                  _hoveredCol = null;
                                } else {
                                  _hoveredRow = rIdx;
                                  _hoveredCol = cIdx;
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: AppMotion.fast,
                              height: 34,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: cellBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isHovered
                                      ? (isDark
                                            ? AppTheme.tealAccentDark
                                            : AppTheme.primaryTeal)
                                      : (isDiag
                                            ? (isDark
                                                  ? AppTheme.tealAccentDark
                                                        .withValues(alpha: 0.3)
                                                  : const Color(
                                                      0xFF0284C7,
                                                    ).withValues(alpha: 0.3))
                                            : (isDark
                                                  ? AppTheme.borderFocusedDark
                                                  : const Color(0xFFE2E8F0))),
                                  width: isHovered ? 2.0 : 0.8,
                                ),
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color:
                                              (isDark
                                                      ? AppTheme.tealAccentDark
                                                      : AppTheme.primaryTeal)
                                                  .withValues(alpha: 0.3),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$val',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isDiag || isHovered
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: textCol,
                                ),
                              ),
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

  Widget _buildConfusionInspectorBanner(
    List<List<int>> cm,
    List<String> classes,
    bool isDark,
  ) {
    int totalSamples = 0;
    int correctSamples = 0;
    for (int r = 0; r < cm.length; r++) {
      for (int c = 0; c < cm[r].length; c++) {
        totalSamples += cm[r][c];
        if (r == c) correctSamples += cm[r][c];
      }
    }
    final overallAccuracy = totalSamples > 0
        ? (correctSamples / totalSamples * 100).toStringAsFixed(1)
        : '0.0';

    if (_hoveredRow == null || _hoveredCol == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.surfaceElevatedDark
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: isDark
                      ? AppTheme.tealAccentDark
                      : AppTheme.primaryTeal,
                ),
                Text(
                  'Tap or hover cell to inspect details',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
            Text(
              '$correctSamples/$totalSamples Correct ($overallAccuracy%)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
            ),
          ],
        ),
      );
    }

    final rIdx = _hoveredRow!;
    final cIdx = _hoveredCol!;
    final actual = classes[rIdx];
    final predicted = classes[cIdx];
    final count = cm[rIdx][cIdx];
    final isCorrect = rIdx == cIdx;

    final rowTotal = cm[rIdx].reduce((a, b) => a + b);
    final rowPct = rowTotal > 0
        ? (count / rowTotal * 100).toStringAsFixed(1)
        : '0.0';

    return AnimatedContainer(
      duration: AppMotion.fast,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? (isDark ? const Color(0xFF042F2E) : const Color(0xFFECFDF5))
            : (isDark
                  ? const Color(0xFF450A0A).withValues(alpha: 0.8)
                  : const Color(0xFFFEF2F2)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect
              ? (isDark ? const Color(0xFF0D9488) : const Color(0xFF6EE7B7))
              : (isDark ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5)),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            size: 20,
            color: isCorrect
                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF059669))
                : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      isCorrect ? 'True Positive' : 'Misclassification Pair',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isCorrect
                            ? (isDark
                                  ? const Color(0xFF2DD4BF)
                                  : const Color(0xFF059669))
                            : (isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626)),
                      ),
                    ),
                    Text(
                      'Actual: $actual ➔ Predicted: $predicted',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isCorrect
                      ? '$count of $rowTotal ground-truth $actual cases correctly identified ($rowPct% recall).'
                      : '$count actual $actual patient sample(s) were predicted as $predicted ($rowPct% of $actual test set).',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            color: isDark ? AppTheme.textSecondaryDark : Colors.grey,
            tooltip: 'Clear inspection',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () {
              setState(() {
                _hoveredRow = null;
                _hoveredCol = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingConvergenceSection(
    BenchmarkData data,
    bool isDark,
    double screenWidth,
  ) {
    final isMobile = screenWidth < 680;

    // Filter fold results for the selected model
    final filteredFolds = data.foldResults
        .where(
          (f) =>
              f['Model']?.toString().toLowerCase() ==
              _selectedConvergenceModel.toLowerCase(),
        )
        .toList();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Training Convergence & Two-Stage Progression',
                  style: TextStyle(
                    fontSize: isMobile ? 14.5 : 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Loss minimization curves and empirical epoch convergence across 5 patient-isolated folds',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark
                  ? AppTheme.textMutedDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),

          // Training Hyperparameters Summary Strip
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildHyperparamTag(
                isMobile
                    ? 'Stage 1: 5-Ep Warmup'
                    : 'Stage 1: 5-Epoch Warmup (lr=1e-4)',
                isDark,
                icon: Icons.speed_rounded,
                isMobile: isMobile,
              ),
              _buildHyperparamTag(
                isMobile
                    ? 'Stage 2: 25-Ep Fine-Tuning'
                    : 'Stage 2: 25-Epoch Fine-Tuning (lr=2e-5)',
                isDark,
                icon: Icons.tune_rounded,
                isMobile: isMobile,
              ),
              _buildHyperparamTag(
                isMobile
                    ? 'AdamW (wd=0.01)'
                    : 'Optimizer: AdamW (wd=0.01, CosineAnnealing)',
                isDark,
                icon: Icons.auto_fix_high_rounded,
                isMobile: isMobile,
              ),
              _buildHyperparamTag(
                isMobile
                    ? 'Batch 16 • Isolated Folds'
                    : 'Batch Size: 16 • Isolated Folds',
                isDark,
                icon: Icons.layers_rounded,
                isMobile: isMobile,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Figure Card with Interactive Lightbox Zoom
          _buildTrainingCurveFigureCard(isDark, isMobile),

          const SizedBox(height: 18),

          // Model Selector Chips for Fold Progression
          Text(
            'Select Model Architecture to Inspect Fold Convergence:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'Proposed (CNN-ViT Cross-Attention)',
                    'CNN + ViT (Simple Concatenation)',
                    'Standalone ViT (Global-Only)',
                    'Standalone CNN (ResNet-50)',
                  ].map((modelName) {
                    final isSelected = _selectedConvergenceModel == modelName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          modelName.contains('Proposed')
                              ? 'Proposed Cross-Attention'
                              : modelName.contains('Concatenation')
                              ? 'CNN + ViT Concat'
                              : modelName.contains('Standalone ViT')
                              ? 'Standalone ViT'
                              : 'Standalone CNN',
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(
                              () => _selectedConvergenceModel = modelName,
                            );
                          }
                        },
                        selectedColor:
                            (isDark
                                    ? AppTheme.tealAccentDark
                                    : AppTheme.primaryTeal)
                                .withValues(alpha: 0.2),
                        checkmarkColor: isDark
                            ? AppTheme.tealAccentDark
                            : AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? (isDark
                                    ? AppTheme.tealAccentDark
                                    : AppTheme.primaryTeal)
                              : (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight),
                        ),
                        backgroundColor: isDark
                            ? AppTheme.surfaceElevatedDark
                            : AppTheme.surfaceElevatedLight,
                        side: BorderSide(
                          color: isSelected
                              ? (isDark
                                    ? AppTheme.tealAccentDark
                                    : AppTheme.primaryTeal)
                              : (isDark
                                    ? AppTheme.borderFocusedDark
                                    : AppTheme.borderSubtleLight),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Fold Convergence Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: isMobile ? 16 : 22,
              horizontalMargin: 8,
              headingRowColor: WidgetStateProperty.all(
                isDark
                    ? AppTheme.surfaceElevatedDark
                    : AppTheme.surfaceElevatedLight,
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'Fold',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Best Val Epoch',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Val Macro F1 (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Test Acc (%)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Test Loss',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),
              ],
              rows: filteredFolds.map((fold) {
                final foldNum = fold['Fold']?.toString() ?? '-';
                final epoch = fold['Best_Val_Epoch']?.toString() ?? '-';
                final valF1 =
                    double.tryParse(fold['Val_Macro_F1']?.toString() ?? '') ??
                    0.0;
                final testAcc =
                    double.tryParse(fold['Test_Accuracy']?.toString() ?? '') ??
                    0.0;
                final testLoss =
                    double.tryParse(fold['Test_Loss']?.toString() ?? '') ?? 0.0;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'Fold $foldNum',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.tealAccentDark
                              : AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Epoch $epoch',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        '${valF1.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${testAcc.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        testLoss.toStringAsFixed(4),
                        style: TextStyle(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textSecondaryLight,
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
    );
  }

  Widget _buildHyperparamTag(
    String text,
    bool isDark, {
    required IconData icon,
    bool isMobile = false,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 220 : 380),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceElevatedDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? AppTheme.borderFocusedDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCurveFigureCard(bool isDark, bool isMobile) {
    const assetPath = 'assets/images/research/two_stage_training_curves.png';
    const title = 'Two-Stage Differential Training Convergence Curves';
    const subtitle =
        'Stage 1 Warmup (Head-Only) -> Stage 2 Joint Cross-Attention Fine-Tuning';

    return InkWell(
      onTap: () => _showImageLightbox(assetPath, title, subtitle),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.surfaceElevatedDark.withValues(alpha: 0.5)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark
                              ? AppTheme.surfaceElevatedDark
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.fullscreen_rounded,
                        size: 14,
                        color: isDark
                            ? AppTheme.tealAccentDark
                            : AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Tap to inspect plot in lightbox zoom',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 120,
                      height: 75,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark
                              ? AppTheme.surfaceElevatedDark
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.fullscreen_rounded,
                              size: 14,
                              color: isDark
                                  ? AppTheme.tealAccentDark
                                  : AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Tap to inspect high-resolution plot in zoom lightbox',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.tealAccentDark
                                      : AppTheme.primaryTeal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResearchVisualizationsSection(bool isDark, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.image_search_rounded,
              color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Research Publication Visualizations',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select any high-resolution figure to zoom and inspect cross-attention token maps and loss convergence',
          style: TextStyle(
            fontSize: 12.5,
            color: isDark
                ? AppTheme.textMutedDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final card1 = _buildImageCard(
              'assets/images/research/cnn_vit_cross_attention_heatmaps.png',
              'Local-to-Global Cross-Attention Heatmaps',
              'Spatial token activation & counterfactual null-query shift',
              isDark,
            );
            final card2 = _buildImageCard(
              'assets/images/research/test_confusion_matrices_comparison.png',
              '4-Model Confusion Matrices Comparison',
              'Held-out test split across all evaluated architectures',
              isDark,
            );
            final card3 = _buildImageCard(
              'assets/images/research/two_stage_training_curves.png',
              'Differential Two-Stage Training Curves',
              'Stage 1 Warmup -> Stage 2 Fine-Tuning convergence',
              isDark,
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
    );
  }

  Widget _buildImageCard(
    String assetPath,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _showImageLightbox(assetPath, title, subtitle),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppTheme.borderSubtleDark
                : AppTheme.borderSubtleLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark
                            ? AppTheme.surfaceElevatedDark
                            : Colors.grey.shade100,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: isDark ? AppTheme.textMutedDark : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textMutedDark
                    : AppTheme.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
