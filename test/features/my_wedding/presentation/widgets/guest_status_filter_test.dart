/// Tests for GuestStatusFilter widgets and utilities.
///
/// Verifies filter button, chip, and filtering logic.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_guest.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/guest_status_filter.dart';

void main() {
  group('GuestStatusFilterButton', () {
    Widget buildTestWidget({
      GuestStatusFilter currentFilter = GuestStatusFilter.all,
      ValueChanged<GuestStatusFilter>? onFilterChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GuestStatusFilterButton(
            currentFilter: currentFilter,
            onFilterChanged: onFilterChanged ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('should display filter icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should not show badge when filter is all', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentFilter: GuestStatusFilter.all,
      ));

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('should show badge when filter is not all', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentFilter: GuestStatusFilter.pending,
      ));

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('should show popup menu with all options on tap',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('En attente'), findsOneWidget);
      expect(find.text('Invités'), findsOneWidget);
      expect(find.text('Ont rejoint'), findsOneWidget);
    });

    testWidgets('should call onFilterChanged when option selected',
        (tester) async {
      GuestStatusFilter? selectedFilter;
      await tester.pumpWidget(buildTestWidget(
        onFilterChanged: (filter) => selectedFilter = filter,
      ));

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invités'));
      await tester.pumpAndSettle();

      expect(selectedFilter, GuestStatusFilter.invited);
    });

    testWidgets('should show checkmark for selected filter', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        currentFilter: GuestStatusFilter.joined,
      ));

      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Check icon should appear next to "Ont rejoint"
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('GuestStatusFilterChip', () {
    Widget buildTestWidget({
      GuestStatusFilter filter = GuestStatusFilter.pending,
      VoidCallback? onClear,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GuestStatusFilterChip(
            filter: filter,
            onClear: onClear ?? () {},
          ),
        ),
      );
    }

    testWidgets('should not display for "all" filter', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        filter: GuestStatusFilter.all,
      ));

      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should display chip for non-all filter', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        filter: GuestStatusFilter.pending,
      ));

      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('En attente'), findsOneWidget);
    });

    testWidgets('should call onClear when delete icon tapped', (tester) async {
      var clearCalled = false;
      await tester.pumpWidget(buildTestWidget(
        filter: GuestStatusFilter.invited,
        onClear: () => clearCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(clearCalled, isTrue);
    });
  });

  group('filterGuests', () {
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

    test('should return all guests for "all" filter', () {
      final guests = [
        createGuest(id: '1', status: GuestStatus.pending),
        createGuest(id: '2', status: GuestStatus.invited),
        createGuest(id: '3', status: GuestStatus.joined),
      ];

      final result = filterGuests(guests, GuestStatusFilter.all);

      expect(result.length, 3);
    });

    test('should filter only pending guests', () {
      final guests = [
        createGuest(id: '1', status: GuestStatus.pending),
        createGuest(id: '2', status: GuestStatus.invited),
        createGuest(id: '3', status: GuestStatus.pending),
      ];

      final result = filterGuests(guests, GuestStatusFilter.pending);

      expect(result.length, 2);
      expect(result.every((g) => g.status == GuestStatus.pending), isTrue);
    });

    test('should filter only invited guests', () {
      final guests = [
        createGuest(id: '1', status: GuestStatus.pending),
        createGuest(id: '2', status: GuestStatus.invited),
        createGuest(id: '3', status: GuestStatus.invited),
      ];

      final result = filterGuests(guests, GuestStatusFilter.invited);

      expect(result.length, 2);
      expect(result.every((g) => g.status == GuestStatus.invited), isTrue);
    });

    test('should filter only joined guests', () {
      final guests = [
        createGuest(id: '1', status: GuestStatus.joined),
        createGuest(id: '2', status: GuestStatus.invited),
        createGuest(id: '3', status: GuestStatus.joined),
      ];

      final result = filterGuests(guests, GuestStatusFilter.joined);

      expect(result.length, 2);
      expect(result.every((g) => g.status == GuestStatus.joined), isTrue);
    });

    test('should return empty list when no guests match filter', () {
      final guests = [
        createGuest(id: '1', status: GuestStatus.pending),
        createGuest(id: '2', status: GuestStatus.pending),
      ];

      final result = filterGuests(guests, GuestStatusFilter.joined);

      expect(result, isEmpty);
    });
  });

  group('GuestStatusFilterExtension', () {
    test('all filter should have "Tous" label', () {
      expect(GuestStatusFilter.all.label, 'Tous');
    });

    test('pending filter should have "En attente" label', () {
      expect(GuestStatusFilter.pending.label, 'En attente');
    });

    test('invited filter should have "Invités" label', () {
      expect(GuestStatusFilter.invited.label, 'Invités');
    });

    test('joined filter should have "Ont rejoint" label', () {
      expect(GuestStatusFilter.joined.label, 'Ont rejoint');
    });
  });
}
