import 'dart:typed_data';

class TriageResult {
  final String condition;
  final double confidence;
  final String confidencePercent;
  final Map<String, double> probabilities;
  final List<double>
  attentionMap14x14; // 196 normalized spatial patch attention weights
  final String urgency;
  final String isolationProtocol;
  final String recommendedAction;
  final DateTime timestamp;
  final bool isLocalPyTorchEngine;
  final Uint8List? imageBytes;
  final String? sampleFileName;

  const TriageResult({
    required this.condition,
    required this.confidence,
    required this.confidencePercent,
    required this.probabilities,
    required this.attentionMap14x14,
    required this.urgency,
    required this.isolationProtocol,
    required this.recommendedAction,
    required this.timestamp,
    required this.isLocalPyTorchEngine,
    this.imageBytes,
    this.sampleFileName,
  });

  factory TriageResult.fromJson(
    Map<String, dynamic> json, {
    bool isLocalPyTorch = true,
    Uint8List? imageBytes,
    String? sampleFileName,
  }) {
    final probsRaw = json['probabilities'] as Map<String, dynamic>? ?? {};
    final probs = <String, double>{};
    probsRaw.forEach((k, v) {
      probs[k] = (v as num).toDouble();
    });

    final attnRaw = json['attention_map_14x14'] as List<dynamic>? ?? [];
    final attn = attnRaw.map((e) => (e as num).toDouble()).toList();

    final triage = json['triage'] as Map<String, dynamic>? ?? {};

    return TriageResult(
      condition: json['prediction'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      confidencePercent: json['confidence_percent'] as String? ?? '0.0%',
      probabilities: probs,
      attentionMap14x14: attn,
      urgency: triage['urgency'] as String? ?? 'Urgent Priority',
      isolationProtocol:
          triage['isolation_protocol'] as String? ?? 'Contact Precautions',
      recommendedAction:
          triage['recommended_action'] as String? ?? 'Consult physician.',
      timestamp: DateTime.now(),
      isLocalPyTorchEngine: isLocalPyTorch,
      imageBytes: imageBytes,
      sampleFileName: sampleFileName,
    );
  }

  Map<String, dynamic> toSummaryMap() {
    return {
      'condition': condition,
      'confidence': confidencePercent,
      'urgency': urgency,
      'isolationProtocol': isolationProtocol,
      'recommendedAction': recommendedAction,
      'timestamp': timestamp.toIso8601String(),
      'engine': isLocalPyTorchEngine
          ? 'Local PyTorch (Dual-Branch Cross-Attn)'
          : 'Local Standalone Dart Engine',
      'sampleFile': sampleFileName ?? 'User Upload',
      'probabilities': probabilities,
    };
  }
}
