import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/triage_result.dart';
import '../services/history_service.dart';
import '../widgets/urgency_badge_widget.dart';
import '../theme/app_theme.dart';
import '../widgets/poster.dart';

class TriageHistoryView extends StatefulWidget {
  final VoidCallback? onNavigateToScan;

  const TriageHistoryView({super.key, this.onNavigateToScan});

  @override
  State<TriageHistoryView> createState() => _TriageHistoryViewState();
}

class _TriageHistoryViewState extends State<TriageHistoryView>
    with SingleTickerProviderStateMixin {
  final HistoryService _history = HistoryService();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _exportSessionLog() async {
    final records = _history.records;
    if (records.isEmpty) return;

    final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final buffer = StringBuffer();

    buffer.writeln('=' * 64);
    buffer.writeln('DERMATRIAGE CLINICAL TRIAGE SESSION AUDIT LOG');
    buffer.writeln('Export Generated: $nowStr');
    buffer.writeln('Total Clinical Evaluations: ${records.length}');
    buffer.writeln('=' * 64);
    buffer.writeln();

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(r.timestamp);
      buffer.writeln('--- [EVALUATION RECORD #${i + 1}] ---');
      buffer.writeln('Timestamp: $dateStr');
      buffer.writeln('Identified Condition: ${r.condition}');
      buffer.writeln(
        'Model Confidence: ${r.confidencePercent} (${(r.confidence * 100).toStringAsFixed(2)}%)',
      );
      buffer.writeln('Triage Stratification: ${r.urgency}');
      buffer.writeln('Isolation Protocol: ${r.isolationProtocol}');
      buffer.writeln('Clinical Recommendation: ${r.recommendedAction}');
      buffer.writeln(
        'Engine: ${r.isLocalPyTorchEngine ? "Local PyTorch (Dual-Branch Cross-Attention)" : "Standalone Dart Inference Engine"}',
      );
      buffer.writeln(
        'Sample Source: ${r.sampleFileName ?? "Direct User Image Input"}',
      );

      if (r.probabilities.isNotEmpty) {
        buffer.writeln('Differential Diagnoses:');
        final sortedProbs = r.probabilities.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (final p in sortedProbs) {
          buffer.writeln(
            '  * ${p.key}: ${(p.value * 100).toStringAsFixed(1)}%',
          );
        }
      }
      buffer.writeln();
    }

    buffer.writeln('=' * 64);
    buffer.writeln('END OF CLINICAL AUDIT EXPORT');

    try {
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
    } catch (_) {
      // In sandbox/headless environments, clipboard copy may not be supported
    }

    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.band,
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Clinical session audit log (${records.length} records) copied to clipboard.',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
            width: 1.2,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  void _showClearHistoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.band,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2))
                        .withValues(alpha: 0.8),
                borderRadius: BorderRadius.zero,
              ),
              child: Icon(
                Icons.delete_sweep_rounded,
                color: isDark
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Clear Session Records?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all ${_history.records.length} triage records and attention maps recorded in this session. This action cannot be undone.',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            height: 1.4,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark
                    ? AppTheme.borderFocusedDark
                    : AppTheme.borderSubtleLight,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _history.clearHistory();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: isDark ? AppTheme.cardDark : AppTheme.band,
                  content: Text(
                    'Session triage records cleared.',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(
                      color: isDark
                          ? AppTheme.borderFocusedDark
                          : AppTheme.borderSubtleLight,
                    ),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showImageLightbox(Uint8List imageBytes, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.band,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textMutedLight,
                    tooltip: 'Close view',
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
                        ? AppTheme.paperDark
                        : AppTheme.surfaceElevatedLight,
                    borderRadius: BorderRadius.zero,
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
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            size: 48,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textSecondaryLight,
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
                      'Pinch, scroll, or double click to zoom into lesion features',
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
    final records = _history.records;
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 40,
              vertical: isMobile ? 24 : 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(records, isDark, isMobile),
                const SizedBox(height: 16),
                if (records.isNotEmpty) ...[
                  _buildStatsStrip(records, isDark, screenWidth),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: records.isEmpty
                      ? _buildEmptyState(isDark, isMobile)
                      : _buildRecordsList(records, isDark, isMobile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<TriageResult> records, bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Display title carries the header; no icon tile.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Display(
                    'Records',
                    size: isMobile ? 52 : 84,
                    height: 0.86,
                    color: isDark ? AppTheme.pale : AppTheme.ink,
                  ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppTheme.tealAccentDark
                                      : AppTheme.primaryTeal)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          '${records.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppTheme.tealAccentDark
                                : AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Every scan from this session, with its result and urgency.',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12.5,
                      color: isDark
                          ? AppTheme.textMutedDark
                          : AppTheme.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (records.isNotEmpty && !isMobile) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _exportSessionLog,
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Export Audit Log'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppTheme.tealAccentDark
                      : AppTheme.primaryTeal,
                  side: BorderSide(
                    color: isDark
                        ? AppTheme.tealAccentDark
                        : AppTheme.primaryTeal,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _showClearHistoryDialog,
                icon: const Icon(Icons.delete_outline_rounded, size: 15),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626), width: 1.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (records.isNotEmpty && isMobile) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: _exportSessionLog,
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Export Audit Log'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppTheme.tealAccentDark
                      : AppTheme.primaryTeal,
                  side: BorderSide(
                    color: isDark
                        ? AppTheme.tealAccentDark
                        : AppTheme.primaryTeal,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showClearHistoryDialog,
                icon: const Icon(Icons.delete_outline_rounded, size: 15),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626), width: 1.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatsStrip(
    List<TriageResult> records,
    bool isDark,
    double screenWidth,
  ) {
    final highUrgencyCount = records
        .where(
          (r) => r.urgency.contains('Level 1') || r.urgency.contains('High'),
        )
        .length;

    final urgentCount = records
        .where(
          (r) => r.urgency.contains('Level 2') || r.urgency.contains('Urgent'),
        )
        .length;

    final avgConf = records.isNotEmpty
        ? (records.map((r) => r.confidence).reduce((a, b) => a + b) /
                  records.length *
                  100)
              .toStringAsFixed(1)
        : '0.0';

    final pytorchEngineCount = records
        .where((r) => r.isLocalPyTorchEngine)
        .length;

    final items = [
      _buildStatItem(
        label: 'Total Analyzed',
        value: '${records.length}',
        icon: Icons.checklist_rounded,
        color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
        isDark: isDark,
      ),
      _buildStatItem(
        label: 'Level 1 High Priority',
        value: '$highUrgencyCount',
        icon: Icons.warning_rounded,
        color: AppTheme.level1Red,
        isDark: isDark,
      ),
      _buildStatItem(
        label: 'Level 2 Urgent',
        value: '$urgentCount',
        icon: Icons.priority_high_rounded,
        color: AppTheme.level2Amber,
        isDark: isDark,
      ),
      _buildStatItem(
        label: 'Mean Confidence',
        value: '$avgConf%',
        icon: Icons.percent_rounded,
        color: const Color(0xFF0284C7),
        isDark: isDark,
      ),
      _buildStatItem(
        label: 'PyTorch Engine',
        value: '$pytorchEngineCount / ${records.length}',
        icon: Icons.memory_rounded,
        color: AppTheme.medicalCyan,
        isDark: isDark,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark
              ? AppTheme.borderSubtleDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((w) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: w,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.zero,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark
                    ? AppTheme.textMutedDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: isDark
                  ? AppTheme.borderSubtleDark
                  : AppTheme.borderSubtleLight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ArchIcon(
                icon: Icons.assignment_late_outlined,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
              const SizedBox(height: 18),
              Text(
                'No records yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Each scan you run in this session is listed here with its result, urgency, and attention map.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onNavigateToScan?.call();
                },
                icon: const Icon(Icons.document_scanner_rounded, size: 16),
                label: const Text('Start a scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppTheme.tealAccentDark
                      : AppTheme.primaryTeal,
                  foregroundColor: isDark
                      ? AppTheme.textPrimaryLight
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(
    List<TriageResult> records,
    bool isDark,
    bool isMobile,
  ) {
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = records[idx];
        final startInterval = (idx * 0.08).clamp(0.0, 0.6);
        final endInterval = (startInterval + 0.4).clamp(0.0, 1.0);
        final cardAnimation = CurvedAnimation(
          parent: _animController,
          curve: Interval(startInterval, endInterval, curve: AppMotion.curve),
        );

        return FadeTransition(
          opacity: cardAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(cardAnimation),
            child: _TriageHistoryCard(
              key: ValueKey(
                'triage_record_${item.timestamp.millisecondsSinceEpoch}_$idx',
              ),
              item: item,
              isDark: isDark,
              isMobile: isMobile,
              onTapThumbnail: item.imageBytes != null
                  ? () => _showImageLightbox(
                      item.imageBytes!,
                      '${item.condition} Lesion Evaluation (${item.confidencePercent})',
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _TriageHistoryCard extends StatefulWidget {
  final TriageResult item;
  final bool isDark;
  final bool isMobile;
  final VoidCallback? onTapThumbnail;

  const _TriageHistoryCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.isMobile,
    this.onTapThumbnail,
  });

  @override
  State<_TriageHistoryCard> createState() => _TriageHistoryCardState();
}

class _TriageHistoryCardState extends State<_TriageHistoryCard> {
  bool _isHovered = false;
  bool _showProbabilities = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;
    final isMobile = widget.isMobile;

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(item.timestamp);
    final urgencyColor = AppTheme.getUrgencyColor(item.urgency);
    final urgencyBg = AppTheme.getUrgencyBg(item.urgency, isDark);
    final urgencyBorder = AppTheme.getUrgencyBorder(item.urgency, isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: _isHovered
                ? urgencyColor.withValues(alpha: 0.7)
                : (isDark
                      ? AppTheme.borderSubtleDark
                      : AppTheme.borderSubtleLight),
            width: _isHovered ? 1.4 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Urgency colored vertical indicator
              Container(width: 5, color: urgencyColor),

              // Main Card Body
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Condition, Confidence, Urgency Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lesion Thumbnail
                          if (item.imageBytes != null)
                            GestureDetector(
                              onTap: widget.onTapThumbnail,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: Image.memory(
                                      item.imageBytes!,
                                      width: isMobile ? 64 : 76,
                                      height: isMobile ? 64 : 76,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Container(
                                            width: isMobile ? 64 : 76,
                                            height: isMobile ? 64 : 76,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppTheme.surfaceElevatedDark
                                                  : AppTheme.borderSubtleLight,
                                              borderRadius:
                                                  BorderRadius.zero,
                                            ),
                                            child: Icon(
                                              Icons.broken_image_rounded,
                                              color: isDark
                                                  ? AppTheme.textMutedDark
                                                  : AppTheme.textMutedLight,
                                            ),
                                          ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      child: const Icon(
                                        Icons.fullscreen_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: isMobile ? 64 : 76,
                              height: isMobile ? 64 : 76,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.surfaceElevatedDark
                                    : AppTheme.borderSubtleLight,
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Icon(
                                Icons.image_rounded,
                                color: isDark
                                    ? AppTheme.textMutedDark
                                    : AppTheme.textMutedLight,
                              ),
                            ),
                          const SizedBox(width: 14),

                          // Condition info and Urgency badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          item.condition,
                                          style: TextStyle(
                                            fontSize: isMobile ? 16 : 18,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? AppTheme.textPrimaryDark
                                                : AppTheme.textPrimaryLight,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (isDark
                                                        ? AppTheme
                                                              .tealAccentDark
                                                        : AppTheme.primaryTeal)
                                                    .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          child: Text(
                                            item.confidencePercent,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                              color: isDark
                                                  ? AppTheme.tealAccentDark
                                                  : AppTheme.primaryTeal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    UrgencyBadgeWidget(
                                      urgency: item.urgency,
                                      isLarge: false,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Disposition / Isolation Protocol Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: urgencyBg,
                                    borderRadius: BorderRadius.zero,
                                    border: Border.all(
                                      color: urgencyBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shield_rounded,
                                        size: 14,
                                        color: urgencyColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item.isolationProtocol,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: urgencyColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Recommended Action
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 14,
                            color: isDark
                                ? AppTheme.textMutedDark
                                : AppTheme.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.recommendedAction,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Differential Probabilities (toggleable or top 3)
                      if (item.probabilities.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showProbabilities = !_showProbabilities;
                            });
                          },
                          borderRadius: BorderRadius.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  _showProbabilities
                                      ? 'Hide Probabilities'
                                      : 'Show Probabilities',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppTheme.tealAccentDark
                                        : AppTheme.primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showProbabilities
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 15,
                                  color: isDark
                                      ? AppTheme.tealAccentDark
                                      : AppTheme.primaryTeal,
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: AppMotion.medium,
                          curve: AppMotion.curve,
                          child: _showProbabilities
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: item.probabilities.entries.map((
                                      entry,
                                    ) {
                                      final isTop = entry.key == item.condition;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isTop
                                              ? (isDark
                                                    ? AppTheme.primaryTealDark
                                                          .withValues(
                                                            alpha: 0.4,
                                                          )
                                                    : AppTheme.tealWash)
                                              : (isDark
                                                    ? AppTheme
                                                          .surfaceElevatedDark
                                                    : AppTheme.surfaceElevatedLight),
                                          borderRadius: BorderRadius.zero,
                                          border: Border.all(
                                            color: isTop
                                                ? (isDark
                                                      ? AppTheme.tealAccentDark
                                                      : AppTheme.primaryTeal)
                                                : (isDark
                                                      ? AppTheme
                                                            .borderSubtleDark
                                                      : AppTheme
                                                            .borderSubtleLight),
                                          ),
                                        ),
                                        child: Text(
                                          '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isTop
                                                ? FontWeight.w500
                                                : FontWeight.w500,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                            color: isTop
                                                ? (isDark
                                                      ? AppTheme.tealAccentDark
                                                      : const Color(0xFF065F46))
                                                : (isDark
                                                      ? AppTheme
                                                            .textSecondaryDark
                                                      : AppTheme
                                                            .textSecondaryLight),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],

                      const SizedBox(height: 10),
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: isDark
                            ? AppTheme.borderSubtleDark
                            : AppTheme.borderSubtleLight,
                      ),
                      const SizedBox(height: 8),

                      // Footer: Timestamp, Engine, Source
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: isDark
                                        ? AppTheme.textMutedDark
                                        : AppTheme.textMutedLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppTheme.textMutedDark
                                          : AppTheme.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.sampleFileName != null)
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isMobile ? 130 : 200,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.attachment_rounded,
                                        size: 12,
                                        color: isDark
                                            ? AppTheme.textMutedDark
                                            : AppTheme.textMutedLight,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          item.sampleFileName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppTheme.textMutedDark
                                                : AppTheme.textMutedLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (item.isLocalPyTorchEngine
                                          ? const Color(0xFF0284C7)
                                          : AppTheme.medicalCyan)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Text(
                              item.isLocalPyTorchEngine
                                  ? 'PyTorch Dual-Branch (Cross-Attn)'
                                  : 'Standalone Dart Engine',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: item.isLocalPyTorchEngine
                                    ? (isDark
                                          ? AppTheme.medicalCyanLight
                                          : const Color(0xFF0284C7))
                                    : (isDark
                                          ? AppTheme.medicalCyanLight
                                          : AppTheme.medicalCyan),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
