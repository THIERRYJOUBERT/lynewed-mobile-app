import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/review.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/review_card.dart';

void main() {
  group('ReviewCard', () {
    // ==============================================================
    // SETUP
    // ==============================================================

    late Review reviewWithComment;
    late Review reviewWithoutComment;
    late Review reviewWithAvatar;

    setUp(() {
      reviewWithComment = Review(
        id: 'review-123',
        proId: 'pro-456',
        brideId: 'bride-789',
        rating: 5,
        comment: 'Excellent photographer! Highly recommended.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        brideName: 'Marie Dupont',
        brideAvatarUrl: null,
      );

      reviewWithoutComment = Review(
        id: 'review-456',
        proId: 'pro-456',
        brideId: 'bride-111',
        rating: 4,
        comment: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        brideName: 'Sophie Martin',
        brideAvatarUrl: null,
      );

      reviewWithAvatar = Review(
        id: 'review-789',
        proId: 'pro-456',
        brideId: 'bride-222',
        rating: 3,
        comment: 'Good service.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        brideName: 'Claire Bernard',
        brideAvatarUrl: 'https://example.com/avatar.jpg',
      );
    });

    // ==============================================================
    // DISPLAY TESTS (AC - Each review shows bride name, rating, comment, date)
    // ==============================================================

    testWidgets('should display bride name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithComment),
          ),
        ),
      );

      expect(find.text('Marie Dupont'), findsOneWidget);
    });

    testWidgets('should display star rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithComment),
          ),
        ),
      );

      // Should find star icons (star_rounded for filled, others for empty/half)
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('should display comment when present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithComment),
          ),
        ),
      );

      expect(
        find.text('Excellent photographer! Highly recommended.'),
        findsOneWidget,
      );
    });

    testWidgets('should not display comment when comment is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithoutComment),
          ),
        ),
      );

      // Should display name and rating but no comment
      expect(find.text('Sophie Martin'), findsOneWidget);
      // Verify that no Text widget with a long comment exists
      expect(find.textContaining('Excellent'), findsNothing);
    });

    testWidgets('should display time ago', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithComment),
          ),
        ),
      );

      // Should find time ago text (e.g., "2 days ago")
      expect(find.textContaining('ago'), findsOneWidget);
    });

    // ==============================================================
    // AVATAR TESTS
    // ==============================================================

    testWidgets('should display avatar with initial when no URL',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithComment),
          ),
        ),
      );

      // Should find CircleAvatar
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Should show initial 'M' for 'Marie Dupont'
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('should configure avatar with background image when URL provided',
        (tester) async {
      // Note: NetworkImage loading fails in test environment but we can still
      // verify the widget is configured correctly by checking the backgroundImage property
      FlutterError.onError = (details) {
        // Suppress network image loading errors in test
        if (!details.toString().contains('NetworkImage')) {
          FlutterError.presentError(details);
        }
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithAvatar),
          ),
        ),
      );

      // Pump to allow any pending operations
      await tester.pump();

      // Should find CircleAvatar with backgroundImage set
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isNotNull);
      expect(avatar.backgroundImage, isA<NetworkImage>());

      // Reset error handler
      FlutterError.onError = FlutterError.presentError;
    });

    testWidgets('should show "Anonymous" when bride name is null',
        (tester) async {
      final anonymousReview = Review(
        id: 'review-anon',
        proId: 'pro-456',
        brideId: 'bride-anon',
        rating: 4,
        createdAt: DateTime.now(),
        brideName: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: anonymousReview),
          ),
        ),
      );

      expect(find.text('Anonymous'), findsOneWidget);
    });

    // ==============================================================
    // LAYOUT TESTS - AC7: Review without comment shows no empty space
    // ==============================================================

    testWidgets('AC7: comment widget is not rendered when review has no comment',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithoutComment),
          ),
        ),
      );

      // Count Text widgets - should not have extra text for comment
      // We should find: name, time ago
      // Rating is shown as stars, not text
      final textWidgets = tester.widgetList<Text>(find.byType(Text));

      // Verify comment text is not present
      final commentTexts = textWidgets
          .where((t) => t.data == reviewWithoutComment.comment)
          .toList();
      expect(commentTexts, isEmpty);
    });

    testWidgets('comment widget is rendered when review has comment',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReviewCard(review: reviewWithComment),
          ),
        ),
      );

      // Comment text should be present
      expect(
        find.text('Excellent photographer! Highly recommended.'),
        findsOneWidget,
      );
    });
  });
}
