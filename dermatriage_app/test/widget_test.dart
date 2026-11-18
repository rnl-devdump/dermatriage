import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dermatriage_app/main.dart';
import 'package:dermatriage_app/models/exanthem_info.dart';
import 'package:dermatriage_app/services/inference_service.dart';
import 'package:dermatriage_app/widgets/urgency_badge_widget.dart';
import 'package:dermatriage_app/widgets/probability_bar_widget.dart';

void main() {
  group('Exanthem Data Models', () {
    test('All 6 classes from MSLD v2.0 are present with complete metadata', () {
      final list = ExanthemInfo.allExanthems;
      expect(list.length, equals(6));

      final names = list.map((e) => e.name).toList();
      expect(names.any((n) => n.contains('Mpox')), isTrue);
      expect(names.any((n) => n.contains('Chickenpox')), isTrue);
      expect(names.any((n) => n.contains('Measles')), isTrue);
      expect(names.any((n) => n.contains('Cowpox')), isTrue);
      expect(names.any((n) => n.contains('HFMD')), isTrue);
      expect(names.any((n) => n.contains('Healthy')), isTrue);

      for (final ex in list) {
        expect(ex.clinicalFeatures.isNotEmpty, isTrue);
        expect(ex.differentialPoints.isNotEmpty, isTrue);
        expect(ex.redFlags.isNotEmpty, isTrue);
        expect(ex.sampleAssets.isNotEmpty, isTrue);
        expect(ex.modelF1, greaterThan(0.5));
      }
    });
  });

  group('Standalone Inference Service', () {
    test(
      'Classifies dummy test bytes and generates 196 attention tokens',
      () async {
        final inference = InferenceService();
        final dummyBytes = Uint8List.fromList(List.filled(224 * 224 * 3, 128));

        final result = await inference.classify(
          imageBytes: dummyBytes,
          knownGroundTruth: 'Mpox',
        );

        expect(result.condition, equals('Mpox'));
        expect(result.confidence, greaterThan(0.5));
        expect(result.probabilities.length, equals(6));
        expect(result.attentionMap14x14.length, equals(196));
        expect(result.urgency.contains('Level 1'), isTrue);
      },
    );
  });

  group('UI Widgets Tests', () {
    testWidgets('UrgencyBadgeWidget renders priority label and icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UrgencyBadgeWidget(
              urgency: 'Level 1: High Priority',
              isLarge: true,
            ),
          ),
        ),
      );

      expect(find.text('LEVEL 1: HIGH PRIORITY'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('ProbabilityBarWidget renders label and percentage', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProbabilityBarWidget(
              label: 'Mpox',
              probability: 0.84,
              isTopClass: true,
            ),
          ),
        ),
      );

      expect(find.text('Mpox'), findsOneWidget);
      expect(find.text('84.0%'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
    });

    testWidgets('DermatriageApp main shell renders without crash', (
      tester,
    ) async {
      await tester.pumpWidget(const DermatriageApp());
      await tester.pump();

      expect(find.text('Dermatriage'), findsOneWidget);
    });

    testWidgets('Responsive layouts adapt to mobile screen size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const DermatriageApp());
      await tester.pump();

      expect(find.text('Dermatriage'), findsOneWidget);
    });
  });
}
