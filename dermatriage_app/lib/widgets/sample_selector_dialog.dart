import 'package:flutter/material.dart';
import '../models/exanthem_info.dart';

class SampleSelectorDialog extends StatelessWidget {
  final Function(String assetPath, String className) onSelectSample;

  const SampleSelectorDialog({super.key, required this.onSelectSample});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 500;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 580,
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified MSLD v2.0 Test Cases',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Select a clinical test case from the held-out evaluation split',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: ExanthemInfo.allExanthems.map((ex) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF006A6B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${ex.modelSupport} Fold-1 Test Cases',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, boxConstraints) {
                              final isNarrow = boxConstraints.maxWidth < 360;
                              final items = ex.sampleAssets.map((path) {
                                final sampleNum = path.contains('sample_1') ? 'Case 1' : 'Case 2';
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.asset(
                                            path,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 44,
                                              height: 44,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image, size: 22, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sampleNum,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Text(
                                                'Tap to evaluate',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  color: Color(0xFF0284C7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                                return isNarrow ? card : Expanded(child: card);
                              }).toList();

                              return isNarrow ? Column(children: items) : Row(children: items);
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
