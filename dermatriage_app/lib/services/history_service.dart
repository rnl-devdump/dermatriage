import '../models/triage_result.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<TriageResult> _records = [];

  List<TriageResult> get records => List.unmodifiable(_records);

  void addRecord(TriageResult result) {
    _records.insert(0, result);
  }

  void clearHistory() {
    _records.clear();
  }
}
