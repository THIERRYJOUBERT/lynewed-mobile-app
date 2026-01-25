import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_professional.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';
import 'package:lynewed_beta/features/feed/presentation/pages/feed_detail_page.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/portfolio_card.dart';
import 'package:lynewed_beta/features/feed/presentation/widgets/portfolio_grid.dart';

void main() {
  group('FeedDetailPage', () {
    late FeedProfessional testProfessional;

    setUp(() {
      testProfessional = FeedProfessional(
        profileId: 'pro-123',
        displayName: 'Jane Photography',
        avatarUrl: 'https://example.com/avatar.jpg',
        profession: 'photographer',
        portfolioItems: [
          PortfolioItem(
            id: 'item-1',
            imageUrl: 'https://example.com/1.jpg',
            professionalId: 'pro-123',
            caption: 'Wedding shot 1',
            createdAt: DateTime(2025, 1, 24),
          ),
          PortfolioItem(
            id: 'item-2',
            imageUrl: 'https://example.com/2.jpg',
            professionalId: 'pro-123',
            caption: 'Wedding shot 2',
            createdAt: DateTime(2025, 1, 24),
          ),
        ],
        isFavorited: false,
      );
    });

    testWidgets('should display professional name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );

      // Name appears in header and profile section
      expect(find.text('Jane Photography'), findsWidgets);
    });

    testWidgets('should display profession', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );

      expect(find.text('Photographer'), findsOneWidget);
    });

    testWidgets('should display portfolio grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );

      expect(find.byType(PortfolioGrid), findsOneWidget);
    });

    testWidgets('should show portfolio items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PortfolioCard), findsWidgets);
    });

    testWidgets('should show favorite button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should show filled favorite when favorited', (tester) async {
      final favoritedProfessional = testProfessional.copyWith(isFavorited: true);

      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: favoritedProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should call onFavoriteToggle when favorite button tapped',
        (tester) async {
      var toggleCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () => toggleCalled = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('should have back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
          ),
        ),
      );

      // Look for back button (could be Icons.arrow_back or from AppBar)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              (widget.icon as Icon).icon == Icons.arrow_back,
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show contact button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
            onContact: () {},
          ),
        ),
      );

      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('should call onContact when contact button tapped',
        (tester) async {
      var contactCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: FeedDetailPage(
            professional: testProfessional,
            onFavoriteToggle: () {},
            onContact: () => contactCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Contact'));
      await tester.pump();

      expect(contactCalled, true);
    });
  });
}
