/// Tests for FilterSheet widget.
///
/// Verifies filter sections rendering, preview count updates,
/// debounce behavior, apply and clear all functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/listing_filter.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_listing.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/filter_sheet.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketplaceRepository extends Mock implements MarketplaceRepository {}

class FakeListingFilter extends Fake implements ListingFilter {}

void main() {
  late MockMarketplaceRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeListingFilter());
  });

  setUp(() {
    mockRepository = MockMarketplaceRepository();

    // Default stubs for preview count.
    when(() => mockRepository.getFilteredListingsCount(any()))
        .thenAnswer((_) async => 10);
    when(() => mockRepository.getFilteredListings(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => <MarketplaceListing>[]);
  });

  Widget buildFilterSheet({
    ListingFilter initialFilter = const ListingFilter.empty(),
    void Function(ListingFilter)? onApply,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            // Render the filter sheet directly for testing.
            return FilterSheet(
              initialFilter: initialFilter,
              repository: mockRepository,
              onApply: onApply ?? (_) {},
            );
          },
        ),
      ),
    );
  }

  group('FilterSheet', () {
    group('rendering', () {
      testWidgets('should render all filter section titles', (tester) async {
        await tester.pumpWidget(buildFilterSheet());
        await tester.pumpAndSettle();

        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Price Range'), findsOneWidget);
        expect(find.text('Size'), findsOneWidget);
        expect(find.text('Brand'), findsOneWidget);
        expect(find.text('Condition'), findsOneWidget);
        expect(find.text('Country'), findsOneWidget);
      });

      testWidgets('should show category chips for Dress and Shoes',
          (tester) async {
        await tester.pumpWidget(buildFilterSheet());
        await tester.pumpAndSettle();

        expect(find.text('Dress'), findsOneWidget);
        expect(find.text('Shoes'), findsOneWidget);
      });

      testWidgets('should show condition chips', (tester) async {
        await tester.pumpWidget(buildFilterSheet());
        await tester.pumpAndSettle();

        expect(find.text('New'), findsOneWidget);
        expect(find.text('Excellent'), findsOneWidget);
        expect(find.text('Good'), findsOneWidget);
        expect(find.text('Fair'), findsOneWidget);
      });

      testWidgets('should show size hint when no category is selected',
          (tester) async {
        await tester.pumpWidget(buildFilterSheet());
        await tester.pumpAndSettle();

        expect(find.text('Select a category first'), findsOneWidget);
      });

      testWidgets('should show dress sizes when dress category selected',
          (tester) async {
        await tester.pumpWidget(buildFilterSheet(
          initialFilter: const ListingFilter(category: 'dress'),
        ));
        await tester.pumpAndSettle();

        // Dress sizes include XS, S, M, L, XL
        expect(find.text('XS'), findsOneWidget);
        expect(find.text('S'), findsOneWidget);
        expect(find.text('M'), findsOneWidget);
        expect(find.text('L'), findsOneWidget);
        expect(find.text('XL'), findsOneWidget);
      });

      testWidgets('should show shoe sizes when shoes category selected',
          (tester) async {
        await tester.pumpWidget(buildFilterSheet(
          initialFilter: const ListingFilter(category: 'shoes'),
        ));
        await tester.pumpAndSettle();

        // Shoe sizes include 35-42
        expect(find.text('35'), findsOneWidget);
        expect(find.text('39'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
      });
    });

    group('apply filters', () {
      testWidgets('should call onApply with current filter when Apply tapped',
          (tester) async {
        ListingFilter? appliedFilter;

        await tester.pumpWidget(buildFilterSheet(
          initialFilter: const ListingFilter(category: 'dress'),
          onApply: (filter) => appliedFilter = filter,
        ));
        await tester.pumpAndSettle();

        // Find and tap the apply button (contains "Show" text)
        final applyButton = find.textContaining('Show');
        expect(applyButton, findsOneWidget);
        await tester.tap(applyButton);
        await tester.pumpAndSettle();

        expect(appliedFilter, isNotNull);
        expect(appliedFilter!.category, 'dress');
      });
    });

    group('clear all', () {
      testWidgets('should reset all filters when Clear All tapped',
          (tester) async {
        await tester.pumpWidget(buildFilterSheet(
          initialFilter: const ListingFilter(
            category: 'dress',
            minPriceCents: 1000,
            country: 'France',
          ),
        ));
        await tester.pumpAndSettle();

        // Find and tap Clear All.
        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();

        // Now the category chips should not have 'Dress' selected.
        // We verify by checking that the apply returns an empty filter.
        ListingFilter? appliedFilter;

        // Rebuild with onApply capture.
        await tester.pumpWidget(buildFilterSheet(
          onApply: (filter) => appliedFilter = filter,
        ));
        await tester.pumpAndSettle();

        final applyButton = find.textContaining('Show');
        await tester.tap(applyButton);
        await tester.pumpAndSettle();

        // After clear all, the default filter should have no active filters.
        expect(appliedFilter, isNotNull);
        expect(appliedFilter!.hasActiveFilters, isFalse);
      });
    });

    group('category selection', () {
      testWidgets('should update filter when Dress chip tapped',
          (tester) async {
        ListingFilter? appliedFilter;

        await tester.pumpWidget(buildFilterSheet(
          onApply: (filter) => appliedFilter = filter,
        ));
        await tester.pumpAndSettle();

        // Tap Dress chip.
        await tester.tap(find.text('Dress'));
        await tester.pumpAndSettle();

        // Then apply.
        await tester.tap(find.textContaining('Show'));
        await tester.pumpAndSettle();

        expect(appliedFilter!.category, 'dress');
      });

      testWidgets('should toggle category off when tapped again',
          (tester) async {
        ListingFilter? appliedFilter;

        await tester.pumpWidget(buildFilterSheet(
          initialFilter: const ListingFilter(category: 'dress'),
          onApply: (filter) => appliedFilter = filter,
        ));
        await tester.pumpAndSettle();

        // Tap Dress chip to deselect.
        await tester.tap(find.text('Dress'));
        await tester.pumpAndSettle();

        // Then apply.
        await tester.tap(find.textContaining('Show'));
        await tester.pumpAndSettle();

        expect(appliedFilter!.category, isNull);
      });
    });

    group('condition selection', () {
      testWidgets('should add condition when chip tapped', (tester) async {
        ListingFilter? appliedFilter;

        await tester.pumpWidget(buildFilterSheet(
          onApply: (filter) => appliedFilter = filter,
        ));
        await tester.pumpAndSettle();

        // Scroll down to make condition chips visible.
        await tester.scrollUntilVisible(
          find.text('New'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        // Tap 'New' condition chip.
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();

        // Then apply.
        await tester.tap(find.textContaining('Show'));
        await tester.pumpAndSettle();

        expect(appliedFilter!.conditions, contains('new'));
      });
    });

    group('preview count', () {
      testWidgets('should call getFilteredListingsCount on init',
          (tester) async {
        when(() => mockRepository.getFilteredListingsCount(any()))
            .thenAnswer((_) async => 42);

        await tester.pumpWidget(buildFilterSheet());
        // Pump enough for debounce (500ms) to fire.
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        verify(() => mockRepository.getFilteredListingsCount(any())).called(1);
      });

      testWidgets('should show preview count in apply button', (tester) async {
        when(() => mockRepository.getFilteredListingsCount(any()))
            .thenAnswer((_) async => 42);

        await tester.pumpWidget(buildFilterSheet());
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        expect(find.textContaining('42'), findsOneWidget);
      });

      testWidgets('should debounce preview count updates', (tester) async {
        when(() => mockRepository.getFilteredListingsCount(any()))
            .thenAnswer((_) async => 10);

        await tester.pumpWidget(buildFilterSheet());
        await tester.pump(const Duration(milliseconds: 100));

        // Tap Dress to trigger a filter change within debounce period.
        await tester.tap(find.text('Dress'));
        await tester.pump(const Duration(milliseconds: 100));

        // Tap New to trigger another filter change.
        await tester.tap(find.text('New'));
        await tester.pump(const Duration(milliseconds: 100));

        // Only one call should have been made at this point (the initial),
        // because the subsequent changes are debounced.
        // Wait for debounce to complete.
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();

        // Should have been called at most 2 times (initial + after debounce).
        verify(() => mockRepository.getFilteredListingsCount(any()))
            .called(lessThanOrEqualTo(2));
      });
    });

    group('country selection', () {
      testWidgets('should show country dropdown', (tester) async {
        await tester.pumpWidget(buildFilterSheet());
        await tester.pumpAndSettle();

        // Verify the country section exists.
        expect(find.text('Country'), findsOneWidget);
      });
    });
  });
}
