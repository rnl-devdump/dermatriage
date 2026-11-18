import 'package:flutter/material.dart';
import '../models/exanthem_info.dart';
import '../widgets/urgency_badge_widget.dart';
import '../theme/app_theme.dart';
import '../widgets/poster.dart';

class ExanthemsOverviewView extends StatefulWidget {
  final Function(String sampleAsset, String className) onSelectForScan;
  /// Class to open first, e.g. from the word wall on the overview.
  final String? initialId;

  const ExanthemsOverviewView({super.key, required this.onSelectForScan, this.initialId});

  @override
  State<ExanthemsOverviewView> createState() => _ExanthemsOverviewViewState();
}

class _ExanthemsOverviewViewState extends State<ExanthemsOverviewView> {
  late String _selectedId = widget.initialId ?? 'mpox';
  String _searchQuery = '';
  bool _showComparisonMatrix = false;

  void _showImageLightbox(String assetPath, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.zero,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = ExanthemInfo.allExanthems.where((ex) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return ex.name.toLowerCase().contains(q) ||
          ex.pathogen.toLowerCase().contains(q) ||
          ex.morphologySummary.toLowerCase().contains(q);
    }).toList();

    final selectedExanthem = ExanthemInfo.allExanthems.firstWhere(
      (e) => e.id == _selectedId,
      orElse: () => ExanthemInfo.allExanthems.first,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          const WorkspaceHeader(
            title: 'Exanthem Library',
            lead: 'Hallmarks, differentials, and isolation guidance for the six classes, with verified test cases you can send straight to a scan.',
          ),
          // Search and matrix toggle
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 40,
              vertical: 14,
            ),
            color: isDark ? AppTheme.paperDark : AppTheme.paper,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: isCompact
                          ? 'Search exanthems...'
                          : 'Search morphology, pathogen, symptoms...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark
                            ? AppTheme.tealAccentDark
                            : AppTheme.primaryTeal,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppTheme.surfaceElevatedDark
                          : AppTheme.surfaceElevatedLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showComparisonMatrix = !_showComparisonMatrix;
                    });
                  },
                  icon: Icon(
                    _showComparisonMatrix
                        ? Icons.view_agenda_rounded
                        : Icons.table_chart_rounded,
                    size: 18,
                  ),
                  label: Text(
                    _showComparisonMatrix
                        ? (isCompact ? 'Profiles' : 'Detailed Profiles')
                        : (isCompact ? 'Matrix' : 'Differential Matrix'),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),

          // Body Content with Animated Transition
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              switchInCurve: AppMotion.curve,
              switchOutCurve: Curves.easeIn,
              child: _showComparisonMatrix
                  ? _buildComparisonMatrixView(isDark)
                  : _buildResponsiveMasterDetail(
                      filtered,
                      selectedExanthem,
                      isDark,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveMasterDetail(
    List<ExanthemInfo> filtered,
    ExanthemInfo selected,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return Row(
            children: [
              // Left Column: Exanthem List Selector
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : AppTheme.band,
                  border: Border(
                    right: BorderSide(
                      color: isDark
                          ? AppTheme.borderFocusedDark
                          : AppTheme.borderSubtleLight,
                    ),
                  ),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, idx) {
                    final ex = filtered[idx];
                    final isSelected = ex.id == selected.id;
                    return InkWell(
                      onTap: () => setState(() => _selectedId = ex.id),
                      borderRadius: BorderRadius.zero,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                    ? AppTheme.primaryTeal.withValues(
                                        alpha: 0.25,
                                      )
                                    : AppTheme.tealWash)
                              : Colors.transparent,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                      ? AppTheme.tealAccentDark
                                      : AppTheme.primaryTeal)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    ex.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      fontSize: 14,
                                      color: isSelected
                                          ? (isDark
                                                ? AppTheme.tealAccentDark
                                                : AppTheme.primaryTeal)
                                          : (isDark
                                                ? AppTheme.textPrimaryDark
                                                : AppTheme.textPrimaryLight),
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                UrgencyBadgeWidget(urgency: ex.triagePriority),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ex.pathogen,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppTheme.textMutedDark
                                    : AppTheme.textMutedLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ex.morphologySummary,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Right Column: Comprehensive Clinical Profile with Animated Switcher
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedSwitcher(
                    duration: AppMotion.medium,
                    switchInCurve: AppMotion.curve,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.015, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(selected.id),
                      child: _buildDetailContent(
                        selected,
                        constraints.maxWidth - 320,
                        isDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile/Tablet reflow: Horizontal Exanthem Selector + Full-width Detail Content
          return Column(
            children: [
              // Top Horizontal Scrollable Exanthem Selector
              Container(
                height: 54,
                color: isDark ? AppTheme.cardDark : AppTheme.band,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final ex = filtered[idx];
                    final isSelected = ex.id == selected.id;
                    return ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: isDark
                          ? AppTheme.primaryTeal
                          : const Color(0xFF006A6B),
                      backgroundColor: isDark
                          ? AppTheme.surfaceElevatedDark
                          : AppTheme.surfaceElevatedLight,
                      side: BorderSide(
                        color: isSelected
                            ? (isDark
                                  ? AppTheme.tealAccentDark
                                  : const Color(0xFF006A6B))
                            : (isDark
                                  ? AppTheme.inkSlate
                                  : AppTheme.borderSubtleLight),
                      ),
                      label: Text(
                        ex.name,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.inkSlate),
                        ),
                      ),
                      onSelected: (_) => setState(() => _selectedId = ex.id),
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                color: isDark
                    ? AppTheme.borderFocusedDark
                    : AppTheme.borderSubtleLight,
              ),

              // Full-width Detail Content with Animated Transition
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: AppMotion.medium,
                    switchInCurve: AppMotion.curve,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey(selected.id),
                      child: _buildDetailContent(
                        selected,
                        constraints.maxWidth,
                        isDark,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDetailContent(
    ExanthemInfo selected,
    double availableWidth,
    bool isDark,
  ) {
    final isCompact = availableWidth < 720;

    final headerCard = Container(
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.band,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark
              ? AppTheme.borderFocusedDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Display(
                  selected.name,
                  size: 44,
                  height: 0.95,
                  color: isDark ? AppTheme.pale : AppTheme.ink,
                ),
                const SizedBox(height: 12),
                UrgencyBadgeWidget(urgency: selected.triagePriority),
                const SizedBox(height: 6),
                Text(
                  'Etiology: ${selected.pathogen} • Family: ${selected.virusFamily}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppTheme.tealAccentDark
                        : AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selected.morphologySummary,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.inkSlate,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                // Model Metrics Box on Mobile
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Held-out test split',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textMutedLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          _buildStatRow(
                            'Test F1',
                            '${(selected.modelF1 * 100).toStringAsFixed(1)}%',
                            isDark,
                          ),
                          _buildStatRow(
                            'Precision',
                            '${(selected.modelPrecision * 100).toStringAsFixed(1)}%',
                            isDark,
                          ),
                          _buildStatRow(
                            'Recall',
                            '${(selected.modelRecall * 100).toStringAsFixed(1)}%',
                            isDark,
                          ),
                          _buildStatRow(
                            'Support',
                            '${selected.modelSupport} samples',
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Display(
                        selected.name,
                        size: 72,
                        height: 0.9,
                        color: isDark ? AppTheme.pale : AppTheme.ink,
                      ),
                      const SizedBox(height: 14),
                      UrgencyBadgeWidget(
                        urgency: selected.triagePriority,
                        isLarge: true,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Etiology: ${selected.pathogen} • Family: ${selected.virusFamily}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppTheme.tealAccentDark
                              : AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selected.morphologySummary,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.inkSlate,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Held-out metrics: a ruled column beside the profile, not a box in a box
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterLabel(
                        'Held-out test split',
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        size: 11.2,
                        tracking: 0.5,
                      ),
                      const SizedBox(height: 6),
                      _buildStatRow(
                        'Test F1-Score',
                        '${(selected.modelF1 * 100).toStringAsFixed(1)}%',
                        isDark,
                      ),
                      _buildStatRow(
                        'Precision',
                        '${(selected.modelPrecision * 100).toStringAsFixed(1)}%',
                        isDark,
                      ),
                      _buildStatRow(
                        'Recall',
                        '${(selected.modelRecall * 100).toStringAsFixed(1)}%',
                        isDark,
                      ),
                      _buildStatRow(
                        'Support',
                        '${selected.modelSupport} samples',
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );

    // Samples row or column
    Widget buildSamplesSection() {
      if (selected.sampleAssets.isEmpty) return const SizedBox.shrink();

      final isSampleCompact = availableWidth < 550;

      final sampleCards = selected.sampleAssets.asMap().entries.map((entry) {
        final idx = entry.key;
        final assetPath = entry.value;
        final cardWidget = Container(
          margin: EdgeInsets.only(
            right: !isSampleCompact && idx == 0 ? 12 : 0,
            bottom: isSampleCompact ? 10 : 0,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.band,
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: isDark
                  ? AppTheme.borderFocusedDark
                  : AppTheme.borderSubtleLight,
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => _showImageLightbox(
                  assetPath,
                  '${selected.name} - Test Case #${idx + 1}',
                ),
                borderRadius: BorderRadius.zero,
                child: ClipPath(
                  clipper: const ArchClipper(),
                  child: Image.asset(
                    assetPath,
                    width: isSampleCompact ? 68 : 80,
                    height: isSampleCompact ? 88 : 104,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: isDark ? Colors.white10 : AppTheme.textMutedLight,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Case #${idx + 1}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ground truth: ${selected.name}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppTheme.textMutedDark
                            : AppTheme.textMutedLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      onPressed: () =>
                          widget.onSelectForScan(assetPath, selected.name),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 14),
                      label: const Text('Evaluate in Scan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return isSampleCompact ? cardWidget : Expanded(child: cardWidget);
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Verified test cases',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                  letterSpacing: -0.2,
                ),
              ),
              if (!isSampleCompact)
                Text(
                  'Send a case straight to Scan',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textMutedDark
                        : AppTheme.textMutedLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isSampleCompact)
            Column(children: sampleCards)
          else
            Row(children: sampleCards),
          const SizedBox(height: 20),
        ],
      );
    }

    final leftDetailCards = Column(
      children: [
        _buildDetailCard(
          title: 'Lesion Progression & Synchronization',
          icon: Icons.timeline_rounded,
          content: selected.lesionEvolution,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildDetailCard(
          title: 'Anatomical Predilection',
          icon: Icons.accessibility_new_rounded,
          content: selected.anatomicalDistribution,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildDetailCard(
          title: 'Lymphadenopathy Profile',
          icon: Icons.bubble_chart_rounded,
          content: selected.lymphadenopathyProfile,
          isDark: isDark,
        ),
      ],
    );

    final rightDetailCards = Column(
      children: [
        _buildBulletCard(
          title: 'Clinical Hallmark Features',
          icon: Icons.checklist_rounded,
          items: selected.clinicalFeatures,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildBulletCard(
          title: 'Differential Diagnostic Checkpoints',
          icon: Icons.compare_arrows_rounded,
          items: selected.differentialPoints,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildRedFlagsCard(selected.redFlags, isDark),
        const SizedBox(height: 14),
        _buildIsolationCard(selected.isolationGuideline, isDark),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerCard,
        const SizedBox(height: 18),
        buildSamplesSection(),
        if (isCompact)
          Column(
            children: [
              leftDetailCards,
              const SizedBox(height: 14),
              rightDetailCards,
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftDetailCards),
              const SizedBox(width: 14),
              Expanded(child: rightDetailCards),
            ],
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textMutedDark
                    : AppTheme.textMutedLight,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.mono,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required String content,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.band,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark
              ? AppTheme.borderFocusedDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark
                    ? AppTheme.tealAccentDark
                    : const Color(0xFF006A6B),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.inkSlate,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.band,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark
              ? AppTheme.borderFocusedDark
              : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: items.map((it) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        it,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.inkSlate,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRedFlagsCard(List<String> redFlags, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.report_problem_rounded,
                size: 18,
                color: Color(0xFFDC2626),
              ),
              SizedBox(width: 8),
              Text(
                'Clinical Red Flags & Urgent Warnings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: redFlags.map((rf) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.arrow_right_rounded,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rf,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFFFECACA)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIsolationCard(String guideline, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.tealWashDark : AppTheme.tealWash,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDark ? AppTheme.borderFocusedDark : AppTheme.borderSubtleLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                size: 18,
                color: isDark ? AppTheme.tealAccentDark : AppTheme.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(
                'Infection control and isolation',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.pale : AppTheme.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            guideline,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMatrixView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.band,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isDark
                ? AppTheme.borderFocusedDark
                : AppTheme.borderSubtleLight,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark ? AppTheme.surfaceElevatedDark : AppTheme.surfaceElevatedLight,
            ),
            columnSpacing: 22,
            columns: const [
              DataColumn(
                label: Text(
                  'Exanthem',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Pathogen',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Lesion Morphology',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Progression',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Distribution',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Lymphadenopathy',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Triage Urgency',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataColumn(
                label: Text(
                  'Model F1',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
            rows: ExanthemInfo.allExanthems.map((ex) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      ex.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.tealAccentDark
                            : const Color(0xFF006A6B),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(ex.pathogen, style: const TextStyle(fontSize: 12)),
                  ),
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(
                        ex.morphologySummary,
                        style: const TextStyle(fontSize: 11.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      ex.id == 'mpox'
                          ? 'Synchronous'
                          : (ex.id == 'chickenpox'
                                ? 'Pleomorphic Crops'
                                : (ex.id == 'measles'
                                      ? 'Cephalocaudal Wave'
                                      : 'Localized Slow')),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      ex.id == 'mpox'
                          ? 'Centrifugal (Face, Palms, Soles)'
                          : (ex.id == 'chickenpox'
                                ? 'Centripetal (Torso -> Face)'
                                : (ex.id == 'hfmd'
                                      ? 'Acral (Hands, Feet, Mouth)'
                                      : 'Focal / generalized')),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(
                    Text(
                      ex.id == 'mpox' || ex.id == 'cowpox'
                          ? 'Prominent & Exquisite'
                          : 'Mild / Absent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ex.id == 'mpox' || ex.id == 'cowpox'
                            ? const Color(0xFFDC2626)
                            : (isDark
                                  ? AppTheme.textPrimaryDark
                                  : Colors.black87),
                      ),
                    ),
                  ),
                  DataCell(UrgencyBadgeWidget(urgency: ex.triagePriority)),
                  DataCell(
                    Text(
                      '${(ex.modelF1 * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.tealAccentDark
                            : const Color(0xFF006A6B),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
