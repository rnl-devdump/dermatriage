import 'package:flutter/material.dart';
import '../models/exanthem_info.dart';
import '../widgets/urgency_badge_widget.dart';

class ExanthemsOverviewView extends StatefulWidget {
  final Function(String sampleAsset, String className) onSelectForScan;

  const ExanthemsOverviewView({super.key, required this.onSelectForScan});

  @override
  State<ExanthemsOverviewView> createState() => _ExanthemsOverviewViewState();
}

class _ExanthemsOverviewViewState extends State<ExanthemsOverviewView> {
  String _selectedId = 'mpox';
  String _searchQuery = '';
  bool _showComparisonMatrix = false;

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Subheader & Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search exanthem morphology, virus, or symptoms...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showComparisonMatrix = !_showComparisonMatrix;
                    });
                  },
                  icon: Icon(
                    _showComparisonMatrix ? Icons.view_agenda_rounded : Icons.table_chart_rounded,
                    size: 18,
                  ),
                  label: Text(_showComparisonMatrix ? 'Detailed Profiles' : 'Differential Matrix'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body Content
          Expanded(
            child: _showComparisonMatrix
                ? _buildComparisonMatrixView()
                : _buildMasterDetailView(filtered, selectedExanthem),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterDetailView(List<ExanthemInfo> filtered, ExanthemInfo selected) {
    return Row(
      children: [
        // Left Column: Exanthem List Selector
        Container(
          width: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, idx) {
              final ex = filtered[idx];
              final isSelected = ex.id == selected.id;
              return InkWell(
                onTap: () => setState(() => _selectedId = ex.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE6FFFA) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF006A6B) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ex.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 14,
                                color: isSelected ? const Color(0xFF006A6B) : const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          UrgencyBadgeWidget(urgency: ex.triagePriority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.pathogen,
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ex.morphologySummary,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
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

        // Right Column: Comprehensive Clinical Profile
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  selected.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                UrgencyBadgeWidget(urgency: selected.triagePriority, isLarge: true),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Etiology: ${selected.pathogen} • Family: ${selected.virusFamily}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF006A6B),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              selected.morphologySummary,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF334155),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Model Metrics Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Model Benchmark',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildStatRow('Test F1-Score', '${(selected.modelF1 * 100).toStringAsFixed(1)}%'),
                            _buildStatRow('Precision', '${(selected.modelPrecision * 100).toStringAsFixed(1)}%'),
                            _buildStatRow('Recall', '${(selected.modelRecall * 100).toStringAsFixed(1)}%'),
                            _buildStatRow('Held-out Support', '${selected.modelSupport} samples'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Clinical Case Samples Row
                if (selected.sampleAssets.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Verified MSLD v2.0 Test Split Samples',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Tap sample to load directly into Local Scan Section',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: selected.sampleAssets.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final assetPath = entry.value;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: idx == 0 ? 14 : 0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  assetPath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Test Case #${idx + 1}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Ground truth: ${selected.name}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => widget.onSelectForScan(assetPath, selected.name),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      icon: const Icon(Icons.bolt_rounded, size: 14),
                                      label: const Text('Evaluate in Scan'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Grid of detailed clinical characteristics
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildDetailCard(
                            title: 'Lesion Progression & Synchronization',
                            icon: Icons.timeline_rounded,
                            content: selected.lesionEvolution,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailCard(
                            title: 'Anatomical Predilection',
                            icon: Icons.accessibility_new_rounded,
                            content: selected.anatomicalDistribution,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailCard(
                            title: 'Lymphadenopathy Profile',
                            icon: Icons.bubble_chart_rounded,
                            content: selected.lymphadenopathyProfile,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildBulletCard(
                            title: 'Clinical Hallmark Features',
                            icon: Icons.checklist_rounded,
                            items: selected.clinicalFeatures,
                          ),
                          const SizedBox(height: 14),
                          _buildBulletCard(
                            title: 'Differential Diagnostic Checkpoints',
                            icon: Icons.compare_arrows_rounded,
                            items: selected.differentialPoints,
                          ),
                          const SizedBox(height: 14),
                          _buildRedFlagsCard(selected.redFlags),
                          const SizedBox(height: 14),
                          _buildIsolationCard(selected.isolationGuideline),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF006A6B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF334155),
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
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
                      child: Icon(Icons.circle, size: 6, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        it,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF334155),
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

  Widget _buildRedFlagsCard(List<String> redFlags) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.report_problem_rounded, size: 18, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text(
                'Clinical Red Flags & Urgent Warnings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
                      child: Icon(Icons.arrow_right_rounded, size: 16, color: Color(0xFFDC2626)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        rf,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF991B1B),
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

  Widget _buildIsolationCard(String guideline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF93C5FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Infection Control & Isolation Protocol',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            guideline,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF1E3A8A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonMatrixView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
            columnSpacing: 22,
            columns: const [
              DataColumn(label: Text('Exanthem', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Pathogen', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Lesion Morphology', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Progression', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Distribution', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Lymphadenopathy', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Triage Urgency', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Model F1', style: TextStyle(fontWeight: FontWeight.w700))),
            ],
            rows: ExanthemInfo.allExanthems.map((ex) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      ex.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF006A6B)),
                    ),
                  ),
                  DataCell(Text(ex.pathogen, style: const TextStyle(fontSize: 12))),
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
                              : (ex.id == 'measles' ? 'Cephalocaudal Wave' : 'Localized Slow')),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      ex.id == 'mpox'
                          ? 'Centrifugal (Face, Palms, Soles)'
                          : (ex.id == 'chickenpox'
                              ? 'Centripetal (Torso -> Face)'
                              : (ex.id == 'hfmd' ? 'Acral (Hands, Feet, Mouth)' : 'Focal / generalized')),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(
                    Text(
                      ex.id == 'mpox' || ex.id == 'cowpox' ? 'Prominent & Exquisite' : 'Mild / Absent',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ex.id == 'mpox' || ex.id == 'cowpox' ? const Color(0xFFDC2626) : Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(UrgencyBadgeWidget(urgency: ex.triagePriority)),
                  DataCell(
                    Text(
                      '${(ex.modelF1 * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF006A6B)),
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
