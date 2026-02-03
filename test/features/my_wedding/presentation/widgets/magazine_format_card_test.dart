/// Tests for MagazineFormatCard widget.
///
/// Tests selection state, disabled state, and UI rendering.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/magazine_format_card.dart';

void main() {
  Widget buildTestWidget({
    required MagazineFormat format,
    bool isSelected = false,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MagazineFormatCard(
          format: format,
          isSelected: isSelected,
          isEnabled: isEnabled,
          onTap: onTap,
        ),
      ),
    );
  }

  group('MagazineFormatCard', () {
    testWidgets('should display format name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.guestEdition,
      ));

      expect(find.text('GUEST EDITION'), findsOneWidget);
    });

    testWidgets('should display format details', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.guestEdition,
      ));

      expect(find.textContaining('21x30cm'), findsOneWidget);
      expect(find.textContaining('20 spreads'), findsOneWidget);
      expect(find.textContaining('Up to 20 photos'), findsOneWidget);
    });

    testWidgets('should display price', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.guestEdition,
      ));

      expect(find.text(r'$29'), findsOneWidget);
    });

    testWidgets('should show Premium badge for collector format', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.collector,
      ));

      expect(find.text('Premium'), findsOneWidget);
    });

    testWidgets('should not show Premium badge for non-collector formats',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.iconic,
      ));

      expect(find.text('Premium'), findsNothing);
    });

    testWidgets('should show checkmark when selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.iconic,
        isSelected: true,
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should not show checkmark when not selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.iconic,
        isSelected: false,
      ));

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('should call onTap when enabled and tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.iconic,
        isEnabled: true,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(MagazineFormatCard));
      expect(tapped, true);
    });

    testWidgets('should not call onTap when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.guestEdition,
        isEnabled: false,
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(MagazineFormatCard));
      expect(tapped, false);
    });

    testWidgets('should have reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.guestEdition,
        isEnabled: false,
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
    });

    testWidgets('should have full opacity when enabled', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        format: MagazineFormats.guestEdition,
        isEnabled: true,
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });
  });
}
