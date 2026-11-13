import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/benchmark_data.dart';

class BenchmarkService {
  static final BenchmarkService _instance = BenchmarkService._internal();
  factory BenchmarkService() => _instance;
  BenchmarkService._internal();

  BenchmarkData? _benchmarkData;
  List<Map<String, dynamic>> _samples = [];

  BenchmarkData? get benchmarkData => _benchmarkData;
  List<Map<String, dynamic>> get samples => _samples;

  Future<void> loadAssets() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/benchmarks.json',
      );
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _benchmarkData = BenchmarkData.fromJson(data);
    } catch (e) {
      // Fallback
    }

    try {
      final samplesString = await rootBundle.loadString(
        'assets/data/samples.json',
      );
      final List<dynamic> list = jsonDecode(samplesString);
      _samples = list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {}
  }
}
