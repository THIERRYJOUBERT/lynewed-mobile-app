/// Tests for MagazineFormatSelector widget.
///
/// Tests format listing, selection, and validation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/magazine_format_selector.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/magazine_format_card.dart';

void main() {
  Widget buildTestWidget({
    required int photoCount,
    MagazineFormat? selectedFormat,
    ValueChanged<MagazineFormat>? onFormatSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MagazineFormatSelector(
            photoCount: photoCount,
            selectedFormat: selectedFormat,
            onFormatSelected: onFormatSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  group('MagazineFormatSelector', () {
    testWidgets('should display header with photo count', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 15));

      expect(find.text('Choose your magazine format'), findsOneWidget);
      expect(find.text('15 photos selected'), findsOneWidget);
    });

    testWidgets('should handle singular photo count', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 1));

      expect(find.text('1 photo selected'), findsOneWidget);
    });

    testWidgets('should display all 4 format cards', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));

      expect(find.byType(MagazineFormatCard), findsNWidgets(4));
    });

    testWidgets('should display all format names', (tester) async {
      await tester.pumpWidget(buildTestWidget(photoCount: 10));

      expect(find.text('GUEST EDITION'), findsOneWidget);
      expect(find.text('ICONIC'), findsOneWidget);
      expect(find.text('MEMORY'), findsOneWidget);
      expect(find.text('COLLECTOR'), findsOneWidget);
    });

    testWidgets('should call onFormatSelected when format is tapped',
        (tester) async {
      MagazineFormat? selected;
      await tester.pumpWidget(buildTestWidget(
        photoCount: 10,
        onFormatSelected: (format) => selected = format,
      ));

      // Tap the ICONIC format (second card)
      await tester.tap(find.text('ICONIC'));
      await tester.pump();

      expect(selected?.id, 'iconic');
    });

    testWidgets('should mark selected format', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        photoCount: 15,
        selectedFormat: MagazineFormats.iconic,
      ));

      // Find the check icon which appears only on selected cards
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
