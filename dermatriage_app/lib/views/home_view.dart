import 'package:flutter/material.dart';
import '../services/inference_service.dart';
import '../models/exanthem_info.dart';
import '../widgets/urgency_badge_widget.dart';

class HomeView extends StatefulWidget {
  final Function(int tabIndex) onNavigate;

  const HomeView({super.key, required this.onNavigate});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final InferenceService _inference = InferenceService();
  bool _checkingHealth = false;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    setState(() => _checkingHealth = true);
    await _inference.checkHealth();
    if (mounted) {
      setState(() => _checkingHealth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _inference.isPyTorchServerOnline;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner: Crisp clinical surface with zero generic AI glow
          Container(
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFF004D40),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF006A6B), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Engine Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.health_and_safety_rounded, size: 16, color: Color(0xFF26A69A)),
                        SizedBox(width: 6),
                        Text(
                          'Clinical Decision Support',
                          style: TextStyle(
                            color: Color(0xFFE0F2FE),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    // Functional Engine Status Pill
                    InkWell(
                      onTap: _checkServer,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOnline ? Icons.bolt_rounded : Icons.offline_bolt_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isOnline ? 'PyTorch Active' : 'Dart Engine',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_checkingHealth) ...[
                              const SizedBox(width: 5),
                              const SizedBox(
                                width: 9,
                                height: 9,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Dermatriage Triage Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dual-Branch CNN–Vision Transformer with Multi-Head Cross-Attention for patient-independent differentiation of Mpox, Chickenpox, Measles, Cowpox, and HFMD.',
                  style: TextStyle(
                    color: const Color(0xFFE0F2FE),
                    fontSize: isMobile ? 13 : 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => widget.onNavigate(1), // Scan tab
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF004D40),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(Icons.document_scanner_rounded, size: 18),
                      label: const Text('Start Clinical Scan'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => widget.onNavigate(2), // Exanthems Overview tab
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.3),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text('Exanthems Overview'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Key Model Metrics
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final isMedium = constraints.maxWidth >= 550;
              final colCount = isWide ? 4 : (isMedium ? 2 : 1);
              final ratio = isWide ? 2.1 : (isMedium ? 2.2 : 2.3);

              return GridView.count(
                crossAxisCount: colCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: ratio,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricCard(
                    title: '5-Fold Val Macro F1',
                    value: '86.81%',
                    subtext: '± 2.12% SD across folds',
                    icon: Icons.auto_graph_rounded,
                    accentColor: const Color(0xFF006A6B),
                  ),
                  _buildMetricCard(
                    title: 'Held-Out Test Acc',
                    value: '82.24%',
                    subtext: 'Proposed Cross-Attention',
                    icon: Icons.shield_rounded,
                    accentColor: const Color(0xFF0284C7),
                  ),
                  _buildMetricCard(
                    title: 'Patient Isolation',
                    value: 'Strict 3-Way',
                    subtext: 'Zero patient split leakage',
                    icon: Icons.lock_outline_rounded,
                    accentColor: const Color(0xFF10B981),
                  ),
                  _buildMetricCard(
                    title: 'Evaluated Classes',
                    value: '6 Classes',
                    subtext: '5 viral + healthy skin',
                    icon: Icons.category_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 26),

          // Quick Exanthem Reference Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Differential Exanthems Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Clinical hallmark profiles, transmission routes, and triage urgency',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => widget.onNavigate(2),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(isCompact ? 'View All' : 'View All Exanthems'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  LayoutBuilder(
                    builder: (context, gridConstraints) {
                      final isWide = gridConstraints.maxWidth >= 1050;
                      final isMedium = gridConstraints.maxWidth >= 650;
                      final colCount = isWide ? 3 : (isMedium ? 2 : 1);
                      final cardRatio = isWide ? 1.55 : (isMedium ? 1.45 : 1.45);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: colCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: cardRatio,
                        ),
                        itemCount: ExanthemInfo.allExanthems.length,
                        itemBuilder: (context, idx) {
                          final ex = ExanthemInfo.allExanthems[idx];
                          return Card(
                            child: InkWell(
                              onTap: () => widget.onNavigate(2),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ex.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.5,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        UrgencyBadgeWidget(urgency: ex.triagePriority),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      ex.virusFamily,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        ex.morphologySummary,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                          height: 1.35,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Test F1: ${(ex.modelF1 * 100).toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF006A6B),
                                          ),
                                        ),
                                        const Row(
                                          children: [
                                            Text(
                                              'Explore',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF0284C7),
                                              ),
                                            ),
                                            Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF0284C7)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
