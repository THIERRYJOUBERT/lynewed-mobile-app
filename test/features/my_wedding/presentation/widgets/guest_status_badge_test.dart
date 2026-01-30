/// Tests for GuestStatusBadge widget.
///
/// Verifies correct display for each guest status.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_guest.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/guest_status_badge.dart';

void main() {
  group('GuestStatusBadge', () {
    Widget buildTestWidget(GuestStatus status) {
      return MaterialApp(
        home: Scaffold(
          body: GuestStatusBadge(status: status),
        ),
      );
    }

    group('pending status', () {
      testWidgets('should render empty for pending status', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.pending));

        // Should show nothing
        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.text('Invité'), findsNothing);
        expect(find.text('Rejoint'), findsNothing);
      });
    });

    group('invited status', () {
      testWidgets('should display "Invité" text', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.invited));

        expect(find.text('Invité'), findsOneWidget);
      });

      testWidgets('should display mail icon', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.invited));

        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      });

      testWidgets('should have amber color styling', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.invited));

        final textWidget = tester.widget<Text>(find.text('Invité'));
        expect(textWidget.style?.color, Colors.amber);
      });
    });

    group('joined status', () {
      testWidgets('should display "Rejoint" text', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.joined));

        expect(find.text('Rejoint'), findsOneWidget);
      });

      testWidgets('should display check icon', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.joined));

        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      });

      testWidgets('should have green color styling', (tester) async {
        await tester.pumpWidget(buildTestWidget(GuestStatus.joined));

        final textWidget = tester.widget<Text>(find.text('Rejoint'));
        expect(textWidget.style?.color, Colors.green);
      });
    });
  });
}
