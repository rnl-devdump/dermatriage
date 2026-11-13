import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dermatriage_app/models/triage_result.dart';
import 'package:dermatriage_app/services/benchmark_service.dart';
import 'package:dermatriage_app/services/history_service.dart';
import 'package:dermatriage_app/theme/app_theme.dart';
import 'package:dermatriage_app/views/benchmarks_view.dart';
import 'package:dermatriage_app/views/triage_history_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BenchmarksView Tests', () {
    setUpAll(() async {
      await BenchmarkService().loadAssets();
    });

    testWidgets(
      'BenchmarksView loads data and renders metric cards and tables',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: BenchmarksView()),
          ),
        );

        // Settle async asset loading
        await tester.pumpAndSettle();

        expect(find.text('Research Evaluation & Benchmarks'), findsOneWidget);
        expect(find.text('5-Fold Cross-Val F1'), findsOneWidget);
        expect(find.text('Mean Held-Out Accuracy'), findsOneWidget);
        expect(
          find.text(
            'Ablation Study Visualizer (Multi-Branch vs Standalone Baselines)',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Interactive Confusion Matrix (Proposed Fold 1)'),
          findsOneWidget,
        );
        expect(
          find.text('Research Publication Visualizations'),
          findsOneWidget,
        );
      },
    );

    testWidgets('BenchmarksView renders properly in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: BenchmarksView()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Research Evaluation & Benchmarks'), findsOneWidget);
      expect(
        find.text('Fold 1 Held-Out Test Classification Report'),
        findsOneWidget,
      );
    });

    testWidgets('BenchmarksView switches ablation metric filter chips', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: BenchmarksView()),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Test Accuracy chip
      final testAccChip = find.text('Test Accuracy');
      expect(testAccChip, findsOneWidget);

      await tester.tap(testAccChip);
      await tester.pumpAndSettle();

      // Find the Test Macro F1 chip
      final testF1Chip = find.text('Test Macro F1');
      expect(testF1Chip, findsOneWidget);

      await tester.tap(testF1Chip);
      await tester.pumpAndSettle();
    });

    testWidgets('Confusion matrix cell interaction triggers inspection banner', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: BenchmarksView()),
        ),
      );

      await tester.pumpAndSettle();

      // Find a matrix cell with value '21' (Proposed Mpox true positive count)
      final cell21 = find.text('21');
      expect(cell21, findsOneWidget);

      await tester.tap(cell21);
      await tester.pumpAndSettle();

      // Inspection banner should now display True Positive details
      expect(find.text('True Positive'), findsOneWidget);
      expect(
        find.textContaining('Actual: Mpox ➔ Predicted: Mpox'),
        findsOneWidget,
      );
    });

    testWidgets(
      'BenchmarksView adapts to mobile screen size without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: BenchmarksView()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Research Evaluation & Benchmarks'), findsOneWidget);
        for (final ro in tester.allRenderObjects) {
          if (ro is RenderFlex && ro.toString().contains('OVERFLOWING')) {
            debugPrint('OVERFLOWING RENDERFLEX: ${ro.toStringDeep()}');
          }
        }
        final err = tester.takeException();
        if (err != null) {
          debugPrint('ERR TYPE: ${err.runtimeType}');
          if (err is FlutterError) {
            for (final d in err.diagnostics) {
              debugPrint('${d.name}: $d');
            }
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'BenchmarksView renders interactive Training Convergence section and fold results',
      (tester) async {
        tester.view.physicalSize = const Size(1000, 1800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: BenchmarksView()),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Training Convergence & Two-Stage Progression'),
          findsOneWidget,
        );
        expect(find.text('Stage 1: 5-Epoch Warmup (lr=1e-4)'), findsOneWidget);

        // Switch model filter chip in fold convergence
        final concatChip = find.text('CNN + ViT Concat');
        await tester.ensureVisible(concatChip);
        expect(concatChip, findsOneWidget);
        await tester.tap(concatChip);
        await tester.pumpAndSettle();

        // Open training curve lightbox
        final curveCard = find.text(
          'Two-Stage Differential Training Convergence Curves',
        );
        await tester.ensureVisible(curveCard);
        expect(curveCard, findsOneWidget);
        await tester.tap(curveCard);
        await tester.pumpAndSettle();

        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(
          find.text(
            'Pinch, scroll, or double click to zoom into resolution details',
          ),
          findsOneWidget,
        );

        // Close lightbox
        final closeBtn = find.byTooltip('Close image view');
        expect(closeBtn, findsOneWidget);
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();

        expect(find.byTooltip('Close image view'), findsNothing);
      },
    );

    testWidgets(
      'BenchmarksView adapts to narrow 320px mobile viewport without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: BenchmarksView()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Research Evaluation & Benchmarks'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('TriageHistoryView Tests', () {
    final history = HistoryService();

    setUp(() {
      history.clearHistory();
    });

    testWidgets(
      'TriageHistoryView shows clean empty state when no records exist',
      (tester) async {
        bool scanNavigated = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: TriageHistoryView(
                onNavigateToScan: () {
                  scanNavigated = true;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('No Clinical Triage Records in Session'),
          findsOneWidget,
        );
        expect(find.text('Launch Lesion Scan'), findsOneWidget);

        await tester.tap(find.text('Launch Lesion Scan'));
        await tester.pump();

        expect(scanNavigated, isTrue);
      },
    );

    testWidgets(
      'TriageHistoryView renders records list, stats strip, and urgency badges',
      (tester) async {
        final sampleRecord = TriageResult(
          condition: 'Mpox',
          confidence: 0.84,
          confidencePercent: '84.0%',
          probabilities: {
            'Mpox': 0.84,
            'Chickenpox': 0.08,
            'HFMD': 0.04,
            'Measles': 0.02,
            'Cowpox': 0.01,
            'Healthy': 0.01,
          },
          attentionMap14x14: List.filled(196, 0.5),
          urgency: 'Level 1: High Priority (Immediate Isolation Required)',
          isolationProtocol: 'Immediate Airborne & Contact Isolation',
          recommendedAction:
              'Isolate in negative pressure room and notify infection control.',
          timestamp: DateTime(2026, 11, 13, 22, 30),
          isLocalPyTorchEngine: true,
          imageBytes: Uint8List.fromList([
            0x89,
            0x50,
            0x4E,
            0x47,
            0x0D,
            0x0A,
            0x1A,
            0x0A,
            0x00,
            0x00,
            0x00,
            0x0D,
            0x49,
            0x48,
            0x44,
            0x52,
            0x00,
            0x00,
            0x00,
            0x01,
            0x00,
            0x00,
            0x00,
            0x01,
            0x08,
            0x06,
            0x00,
            0x00,
            0x00,
            0x1F,
            0x15,
            0xC4,
            0x89,
            0x00,
            0x00,
            0x00,
            0x0A,
            0x49,
            0x44,
            0x41,
            0x54,
            0x78,
            0x9C,
            0x63,
            0x00,
            0x01,
            0x00,
            0x00,
            0x05,
            0x00,
            0x01,
            0x0D,
            0x0A,
            0x2D,
            0xB4,
            0x00,
            0x00,
            0x00,
            0x00,
            0x49,
            0x45,
            0x4E,
            0x44,
            0xAE,
            0x42,
            0x60,
            0x82,
          ]),
          sampleFileName: 'test_mpox.jpg',
        );

        history.addRecord(sampleRecord);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: TriageHistoryView()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Session Triage Records'), findsOneWidget);
        expect(find.text('Total Analyzed'), findsOneWidget);
        expect(find.text('Level 1 High Priority'), findsOneWidget);
        expect(find.text('Mean Confidence'), findsOneWidget);
        expect(find.text('Mpox'), findsAtLeastNWidgets(1));
        expect(find.text('84.0%'), findsAtLeastNWidgets(1));
        expect(
          find.text('Immediate Airborne & Contact Isolation'),
          findsOneWidget,
        );
        expect(find.text('PyTorch Dual-Branch (Cross-Attn)'), findsOneWidget);
        expect(find.text('Export Audit Log'), findsOneWidget);
      },
    );

    testWidgets('TriageHistoryView toggles differential probabilities', (
      tester,
    ) async {
      final sampleRecord = TriageResult(
        condition: 'HFMD',
        confidence: 0.93,
        confidencePercent: '93.3%',
        probabilities: {'HFMD': 0.933, 'Chickenpox': 0.035, 'Healthy': 0.032},
        attentionMap14x14: List.filled(196, 0.2),
        urgency: 'Level 3: Standard Care',
        isolationProtocol: 'Contact Precautions',
        recommendedAction: 'Symptomatic pediatric care and hydration.',
        timestamp: DateTime(2026, 11, 13, 22, 45),
        isLocalPyTorchEngine: false,
      );

      history.addRecord(sampleRecord);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: TriageHistoryView()),
        ),
      );

      await tester.pumpAndSettle();

      final toggleButton = find.text('Show Probabilities');
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.text('Hide Probabilities'), findsOneWidget);
      expect(find.text('HFMD: 93.3%'), findsOneWidget);
    });

    testWidgets('TriageHistoryView clear dialog prompts and clears records', (
      tester,
    ) async {
      final sampleRecord = TriageResult(
        condition: 'Measles',
        confidence: 0.85,
        confidencePercent: '85.7%',
        probabilities: {'Measles': 0.857},
        attentionMap14x14: List.filled(196, 0.1),
        urgency: 'Level 2: Urgent Priority',
        isolationProtocol: 'Strict Airborne Precautions',
        recommendedAction: 'Isolate and check MMR vaccination history.',
        timestamp: DateTime.now(),
        isLocalPyTorchEngine: true,
      );

      history.addRecord(sampleRecord);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: TriageHistoryView()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Clear'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Session Records?'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(history.records.isEmpty, isTrue);
      expect(
        find.text('No Clinical Triage Records in Session'),
        findsOneWidget,
      );
    });

    testWidgets(
      'TriageHistoryView adapts to mobile screen size without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final sampleRecord = TriageResult(
          condition: 'Chickenpox',
          confidence: 0.72,
          confidencePercent: '72.0%',
          probabilities: {'Chickenpox': 0.72},
          attentionMap14x14: List.filled(196, 0.4),
          urgency: 'Level 2: Urgent Priority (Airborne Transmission Risk)',
          isolationProtocol: 'Airborne & Contact Isolation',
          recommendedAction: 'Prescribe acyclovir if within 24h window.',
          timestamp: DateTime.now(),
          isLocalPyTorchEngine: true,
        );
        history.addRecord(sampleRecord);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: TriageHistoryView()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Session Triage Records'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'TriageHistoryView image thumbnail opens lightbox with zoom and closes cleanly',
      (tester) async {
        final sampleRecord = TriageResult(
          condition: 'Cowpox',
          confidence: 0.82,
          confidencePercent: '82.0%',
          probabilities: {'Cowpox': 0.82},
          attentionMap14x14: List.filled(196, 0.3),
          urgency: 'Level 2: Urgent Priority',
          isolationProtocol: 'Contact Precautions',
          recommendedAction: 'Isolate lesion area and check zoonotic exposure.',
          timestamp: DateTime.now(),
          isLocalPyTorchEngine: true,
          imageBytes: Uint8List.fromList([
            0x89,
            0x50,
            0x4E,
            0x47,
            0x0D,
            0x0A,
            0x1A,
            0x0A,
            0x00,
            0x00,
            0x00,
            0x0D,
            0x49,
            0x48,
            0x44,
            0x52,
            0x00,
            0x00,
            0x00,
            0x01,
            0x00,
            0x00,
            0x00,
            0x01,
            0x08,
            0x06,
            0x00,
            0x00,
            0x00,
            0x1F,
            0x15,
            0xC4,
            0x89,
            0x00,
            0x00,
            0x00,
            0x0A,
            0x49,
            0x44,
            0x41,
            0x54,
            0x78,
            0x9C,
            0x63,
            0x00,
            0x01,
            0x00,
            0x00,
            0x05,
            0x00,
            0x01,
            0x0D,
            0x0A,
            0x2D,
            0xB4,
            0x00,
            0x00,
            0x00,
            0x00,
            0x49,
            0x45,
            0x4E,
            0x44,
            0xAE,
            0x42,
            0x60,
            0x82,
          ]),
        );
        history.addRecord(sampleRecord);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(body: TriageHistoryView()),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the thumbnail
        final thumb = find.byType(Image);
        expect(thumb, findsOneWidget);
        await tester.tap(thumb);
        await tester.pumpAndSettle();

        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(
          find.text(
            'Pinch, scroll, or double click to zoom into lesion features',
          ),
          findsOneWidget,
        );

        // Close lightbox
        final closeBtn = find.byTooltip('Close view');
        expect(closeBtn, findsOneWidget);
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();

        expect(find.byTooltip('Close view'), findsNothing);
      },
    );

    testWidgets(
      'TriageHistoryView handles extremely long filename and narrow 320px viewport without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final sampleRecord = TriageResult(
          condition: 'Chickenpox',
          confidence: 0.72,
          confidencePercent: '72.0%',
          probabilities: {'Chickenpox': 0.72},
          attentionMap14x14: List.filled(196, 0.4),
          urgency:
              'Level 1: High Priority (Immediate Airborne & Contact Isolation Required)',
          isolationProtocol:
              'Strict Airborne & Contact Isolation Protocols in Negative Pressure Suite',
          recommendedAction:
              'Immediate antiviral initiation and airborne infection control notification.',
          timestamp: DateTime.now(),
          isLocalPyTorchEngine: true,
          sampleFileName:
              'patient_sample_msld_v2_heldout_test_fold1_uncompressed_raw_telehealth_upload.png',
        );
        history.addRecord(sampleRecord);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: TriageHistoryView()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Session Triage Records'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
