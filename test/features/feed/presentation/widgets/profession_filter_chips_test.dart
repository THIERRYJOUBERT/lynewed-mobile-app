import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/profession_filter_chips.dart';

void main() {
  group('ProfessionFilterChips', () {
    final testProfessions = ['photographer', 'florist', 'videographer'];

    testWidgets('should render all professions as chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: testProfessions,
              selectedProfessions: const [],
              onProfessionToggled: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Photographer'), findsOneWidget);
      expect(find.text('Florist'), findsOneWidget);
      expect(find.text('Videographer'), findsOneWidget);
    });

    testWidgets('should highlight selected professions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: testProfessions,
              selectedProfessions: const ['photographer'],
              onProfessionToggled: (_) {},
            ),
          ),
        ),
      );

      // Find the Photographer chip and verify it's selected
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      final photographerChip = chips.firstWhere(
        (chip) => (chip.label as Text).data == 'Photographer',
      );

      expect(photographerChip.selected, true);
    });

    testWidgets('should call onProfessionToggled when chip tapped', (tester) async {
      String? toggledProfession;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: testProfessions,
              selectedProfessions: const [],
              onProfessionToggled: (p) => toggledProfession = p,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Florist'));
      await tester.pumpAndSettle();

      expect(toggledProfession, 'florist');
    });

    testWidgets('should handle empty professions list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: const [],
              selectedProfessions: const [],
              onProfessionToggled: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('should be scrollable horizontally', (tester) async {
      final manyProfessions = List.generate(
        10,
        (i) => 'profession_$i',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: manyProfessions,
              selectedProfessions: const [],
              onProfessionToggled: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should show "All" chip when showAllChip is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: testProfessions,
              selectedProfessions: const [],
              onProfessionToggled: (_) {},
              showAllChip: true,
              onAllSelected: () {},
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('should call onAllSelected when All chip tapped', (tester) async {
      var allSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfessionFilterChips(
              professions: testProfessions,
              selectedProfessions: const ['photographer'],
              onProfessionToggled: (_) {},
              showAllChip: true,
              onAllSelected: () => allSelected = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(allSelected, true);
    });
  });
}
