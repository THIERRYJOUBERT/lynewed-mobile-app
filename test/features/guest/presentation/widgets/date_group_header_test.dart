import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/widgets/date_group_header.dart';

void main() {
  group('DateGroupHeader', () {
    Widget buildWidget({String label = 'Today', int itemCount = 5}) {
      return MaterialApp(
        home: Scaffold(
          body: DateGroupHeader(label: label, itemCount: itemCount),
        ),
      );
    }

    testWidgets('displays date label', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'Yesterday'));
      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('displays item count with plural', (tester) async {
      await tester.pumpWidget(buildWidget(itemCount: 5));
      expect(find.text('5 items'), findsOneWidget);
    });

    testWidgets('displays singular "item" for count 1', (tester) async {
      await tester.pumpWidget(buildWidget(itemCount: 1));
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('displays custom date label', (tester) async {
      await tester.pumpWidget(buildWidget(label: 'Jan 28'));
      expect(find.text('Jan 28'), findsOneWidget);
    });
  });

  group('DateGroupHeader.formatDateLabel', () {
    test('returns "Today" for today', () {
      final now = DateTime.now();
      expect(DateGroupHeader.formatDateLabel(now), 'Today');
    });

    test('returns "Yesterday" for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateGroupHeader.formatDateLabel(yesterday), 'Yesterday');
    });

    test('returns formatted date for older dates', () {
      final date = DateTime(2026, 1, 28);
      expect(DateGroupHeader.formatDateLabel(date), 'Jan 28');
    });

    test('returns correct month name for each month', () {
      expect(DateGroupHeader.formatDateLabel(DateTime(2026, 1, 1)), 'Jan 1');
      expect(DateGroupHeader.formatDateLabel(DateTime(2026, 6, 15)), 'Jun 15');
      expect(DateGroupHeader.formatDateLabel(DateTime(2026, 12, 25)), 'Dec 25');
    });
  });
}
