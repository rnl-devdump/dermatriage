import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../widgets/urgency_badge_widget.dart';

class TriageHistoryView extends StatefulWidget {
  const TriageHistoryView({super.key});

  @override
  State<TriageHistoryView> createState() => _TriageHistoryViewState();
}

class _TriageHistoryViewState extends State<TriageHistoryView> {
  final HistoryService _history = HistoryService();

  @override
  Widget build(BuildContext context) {
    final records = _history.records;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Triage Records',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Log of clinical evaluations and isolation referrals performed in this session (${records.length} total)',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                if (records.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _history.clearHistory();
                      });
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Clear Records'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (records.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 54, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No Triage Records Yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'When you classify skin lesions in the Scan section, records are automatically preserved here.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final item = records[idx];
                    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(item.timestamp);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.imageBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                item.imageBytes!,
                                width: isMobile ? 60 : 72,
                                height: isMobile ? 60 : 72,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: isMobile ? 60 : 72,
                              height: isMobile ? 60 : 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          const SizedBox(width: 14),
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
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          item.condition,
                                          style: TextStyle(
                                            fontSize: isMobile ? 15 : 17,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          item.confidencePercent,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF006A6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    UrgencyBadgeWidget(urgency: item.urgency),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Protocol: ${item.isolationProtocol}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.recommendedAction,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      'Recorded: $dateStr',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                    Text(
                                      item.isLocalPyTorchEngine ? 'Engine: PyTorch Local' : 'Engine: Standalone Dart',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
