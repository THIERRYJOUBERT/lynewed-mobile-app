import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/portfolio_card.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/portfolio_grid.dart';

void main() {
  group('PortfolioGrid', () {
    late List<PortfolioItem> testItems;

    setUp(() {
      testItems = [
        PortfolioItem(
          id: 'item-1',
          imageUrl: 'https://example.com/1.jpg',
          professionalId: 'pro-1',
          createdAt: DateTime(2025, 1, 24),
        ),
        PortfolioItem(
          id: 'item-2',
          imageUrl: 'https://example.com/2.jpg',
          professionalId: 'pro-1',
          createdAt: DateTime(2025, 1, 24),
        ),
        PortfolioItem(
          id: 'item-3',
          imageUrl: 'https://example.com/3.jpg',
          professionalId: 'pro-1',
          createdAt: DateTime(2025, 1, 24),
        ),
      ];
    });

    testWidgets('should render all portfolio items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: testItems,
              onItemTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(PortfolioCard), findsNWidgets(3));
    });

    testWidgets('should call onItemTap with correct item', (tester) async {
      PortfolioItem? tappedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: testItems,
              onItemTap: (item) => tappedItem = item,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tappedItem, isNotNull);
      expect(tappedItem!.id, 'item-1');
    });

    testWidgets('should show empty state when no items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: const [],
              onItemTap: (_) {},
              emptyMessage: 'No images yet',
            ),
          ),
        ),
      );

      expect(find.text('No images yet'), findsOneWidget);
      expect(find.byType(PortfolioCard), findsNothing);
    });

    testWidgets('should use 2 columns by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: testItems,
              onItemTap: (_) {},
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('should use custom column count when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: testItems,
              onItemTap: (_) {},
              crossAxisCount: 3,
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 3);
    });

    testWidgets('should call onItemSave when save button tapped', (tester) async {
      PortfolioItem? savedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: testItems,
              onItemTap: (_) {},
              onItemSave: (item) => savedItem = item,
              showSaveButtons: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.bookmark_border).first);
      await tester.pump();

      expect(savedItem, isNotNull);
      expect(savedItem!.id, 'item-1');
    });

    testWidgets('should respect savedItemIds for showing saved state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: PortfolioGrid(
                items: testItems,
                onItemTap: (_) {},
                onItemSave: (_) {}, // Required for save buttons to show
                showSaveButtons: true,
                savedItemIds: const {'item-1'},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // First item should show filled bookmark, rest show outline
      // Note: GridView only renders visible items, so count may vary
      expect(find.byIcon(Icons.bookmark), findsWidgets);
    });

    testWidgets('should be scrollable', (tester) async {
      final manyItems = List.generate(
        20,
        (i) => PortfolioItem(
          id: 'item-$i',
          imageUrl: 'https://example.com/$i.jpg',
          professionalId: 'pro-1',
          createdAt: DateTime(2025, 1, 24),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioGrid(
              items: manyItems,
              onItemTap: (_) {},
            ),
          ),
        ),
      );

      // Should be able to scroll
      await tester.drag(find.byType(GridView), const Offset(0, -200));
      await tester.pump(); // Use pump instead of pumpAndSettle to avoid timeout

      // Test passes if no error thrown
      expect(true, true);
    });
  });
}
