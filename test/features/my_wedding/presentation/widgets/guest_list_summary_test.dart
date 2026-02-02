/// Tests for GuestListSummary widget.
///
/// Verifies correct display of guest status counts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_guest.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/guest_list_summary.dart';

void main() {
  group('GuestListSummary', () {
    Widget buildTestWidget(List<WeddingGuest> guests) {
      return MaterialApp(
        home: Scaffold(
          body: GuestListSummary(guests: guests),
        ),
      );
    }

    WeddingGuest createGuest({
      required String id,
      GuestStatus status = GuestStatus.pending,
    }) {
      return WeddingGuest(
        id: id,
        weddingId: 'wedding-123',
        name: 'Guest $id',
        status: status,
      );
    }

    group('Empty list', () {
      testWidgets('should display zero for all counts', (tester) async {
        await tester.pumpWidget(buildTestWidget([]));

        expect(find.text('0'), findsNWidgets(3));
      });
    });

    group('With guests', () {
      testWidgets('should display correct total count', (tester) async {
        final guests = [
          createGuest(id: '1'),
          createGuest(id: '2'),
          createGuest(id: '3'),
        ];

        await tester.pumpWidget(buildTestWidget(guests));

        expect(find.text('3'), findsOneWidget);
        expect(find.text('guests'), findsOneWidget);
      });

      testWidgets('should display correct invited count', (tester) async {
        final guests = [
          createGuest(id: '1', status: GuestStatus.pending),
          createGuest(id: '2', status: GuestStatus.invited),
          createGuest(id: '3', status: GuestStatus.invited),
        ];

        await tester.pumpWidget(buildTestWidget(guests));

        expect(find.text('3'), findsOneWidget); // total
        expect(find.text('2'), findsOneWidget); // invited
        expect(find.textContaining('invitations'), findsOneWidget);
      });

      testWidgets('should display correct joined count', (tester) async {
        final guests = [
          createGuest(id: '1', status: GuestStatus.pending),
          createGuest(id: '2', status: GuestStatus.invited),
          createGuest(id: '3', status: GuestStatus.joined),
          createGuest(id: '4', status: GuestStatus.joined),
        ];

        await tester.pumpWidget(buildTestWidget(guests));

        expect(find.text('4'), findsOneWidget); // total
        expect(find.text('1'), findsOneWidget); // invited
        expect(find.text('2'), findsOneWidget); // joined
        expect(find.textContaining('joined'), findsOneWidget);
      });

      testWidgets('should display mixed statuses correctly', (tester) async {
        final guests = [
          // 5 pending
          createGuest(id: '1', status: GuestStatus.pending),
          createGuest(id: '2', status: GuestStatus.pending),
          createGuest(id: '3', status: GuestStatus.pending),
          createGuest(id: '4', status: GuestStatus.pending),
          createGuest(id: '5', status: GuestStatus.pending),
          // 3 invited
          createGuest(id: '6', status: GuestStatus.invited),
          createGuest(id: '7', status: GuestStatus.invited),
          createGuest(id: '8', status: GuestStatus.invited),
          // 2 joined
          createGuest(id: '9', status: GuestStatus.joined),
          createGuest(id: '10', status: GuestStatus.joined),
        ];

        await tester.pumpWidget(buildTestWidget(guests));

        expect(find.text('10'), findsOneWidget); // total
        expect(find.text('3'), findsOneWidget); // invited
        expect(find.text('2'), findsOneWidget); // joined
      });
    });
  });
}
