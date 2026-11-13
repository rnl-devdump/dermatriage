class BenchmarkData {
  final Map<String, dynamic> classificationReport;
  final List<dynamic> fiveFoldSummary;
  final List<dynamic> foldResults;
  final List<List<int>> confusionMatrix;
  final List<String> classes;

  const BenchmarkData({
    required this.classificationReport,
    required this.fiveFoldSummary,
    required this.foldResults,
    required this.confusionMatrix,
    required this.classes,
  });

  factory BenchmarkData.fromJson(Map<String, dynamic> json) {
    final rawCm = json['confusion_matrix'] as List<dynamic>? ?? [];
    final cm = rawCm.map((row) {
      return (row as List<dynamic>).map((val) => (val as num).toInt()).toList();
    }).toList();

    return BenchmarkData(
      classificationReport:
          json['classification_report'] as Map<String, dynamic>? ?? {},
      fiveFoldSummary: json['five_fold_summary'] as List<dynamic>? ?? [],
      foldResults: json['fold_results'] as List<dynamic>? ?? [],
      confusionMatrix: cm,
      classes:
          (json['classes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
