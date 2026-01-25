import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/portfolio_card.dart';

void main() {
  group('PortfolioCard', () {
    late PortfolioItem testItem;

    setUp(() {
      testItem = PortfolioItem(
        id: 'item-123',
        imageUrl: 'https://example.com/image.jpg',
        professionalId: 'pro-456',
        caption: 'Beautiful wedding setup',
        createdAt: DateTime(2025, 1, 24),
      );
    });

    testWidgets('should render image from portfolio item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should call onLongPress when long pressed', (tester) async {
      var longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(GestureDetector).first);
      await tester.pump();

      expect(longPressed, true);
    });

    testWidgets('should show save icon when onSave is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () {},
              onSave: () {},
              showSaveButton: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('should show filled save icon when saved', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () {},
              onSave: () {},
              showSaveButton: true,
              isSaved: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('should call onSave when save button tapped', (tester) async {
      var saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () {},
              onSave: () => saved = true,
              showSaveButton: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();

      expect(saved, true);
    });

    testWidgets('should have rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortfolioCard(
              item: testItem,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PortfolioCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
