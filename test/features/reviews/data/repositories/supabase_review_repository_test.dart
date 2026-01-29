import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/data/repositories/supabase_review_repository.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/pro_rating.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/review.dart';
import 'package:lynewed_beta/features/reviews/domain/repositories/review_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  group('SupabaseReviewRepository', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late SupabaseReviewRepository repository;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockSupabase.auth).thenReturn(mockAuth);
      repository = SupabaseReviewRepository(mockSupabase);
    });

    test('should implement ReviewRepository', () {
      expect(repository, isA<ReviewRepository>());
    });

    group('Review entity parsing', () {
      test('should parse Review from database row with joined profile', () {
        final row = {
          'id': 'review-123',
          'pro_id': 'pro-456',
          'bride_id': 'bride-789',
          'rating': 5,
          'comment': 'Excellent service!',
          'created_at': '2024-06-15T10:30:00Z',
          'updated_at': '2024-06-20T15:45:00Z',
          'profiles': {
            'full_name': 'Marie Dupont',
            'avatar_url': 'https://example.com/avatar.jpg',
          },
        };

        final review = SupabaseReviewRepository.parseReviewFromRow(row);

        expect(review.id, 'review-123');
        expect(review.proId, 'pro-456');
        expect(review.brideId, 'bride-789');
        expect(review.rating, 5);
        expect(review.comment, 'Excellent service!');
        expect(review.brideName, 'Marie Dupont');
        expect(review.brideAvatarUrl, 'https://example.com/avatar.jpg');
        expect(review.createdAt, DateTime.utc(2024, 6, 15, 10, 30, 0));
        expect(review.updatedAt, DateTime.utc(2024, 6, 20, 15, 45, 0));
      });

      test('should handle Review without profile join', () {
        final row = {
          'id': 'review-123',
          'pro_id': 'pro-456',
          'bride_id': 'bride-789',
          'rating': 4,
          'comment': null,
          'created_at': '2024-06-15T10:30:00Z',
          'updated_at': null,
        };

        final review = SupabaseReviewRepository.parseReviewFromRow(row);

        expect(review.id, 'review-123');
        expect(review.rating, 4);
        expect(review.comment, isNull);
        expect(review.brideName, isNull);
        expect(review.brideAvatarUrl, isNull);
        expect(review.updatedAt, isNull);
      });

      test('should handle null comment in Review', () {
        final row = {
          'id': 'review-123',
          'pro_id': 'pro-456',
          'bride_id': 'bride-789',
          'rating': 3,
          'comment': null,
          'created_at': '2024-06-15T10:30:00Z',
          'updated_at': null,
        };

        final review = SupabaseReviewRepository.parseReviewFromRow(row);

        expect(review.hasComment, false);
      });

      test('should parse multiple reviews preserving order', () {
        final rows = [
          {
            'id': 'review-1',
            'pro_id': 'pro-A',
            'bride_id': 'bride-1',
            'rating': 5,
            'comment': 'Fantastic!',
            'created_at': '2024-06-15T10:30:00Z',
            'updated_at': null,
            'profiles': {
              'full_name': 'Bride One',
              'avatar_url': null,
            },
          },
          {
            'id': 'review-2',
            'pro_id': 'pro-A',
            'bride_id': 'bride-2',
            'rating': 4,
            'comment': null,
            'created_at': '2024-06-10T10:30:00Z',
            'updated_at': null,
            'profiles': {
              'full_name': 'Bride Two',
              'avatar_url': 'https://example.com/avatar.jpg',
            },
          },
        ];

        final reviews = rows
            .map((row) => SupabaseReviewRepository.parseReviewFromRow(row))
            .toList();

        expect(reviews.length, 2);
        expect(reviews[0].id, 'review-1');
        expect(reviews[0].rating, 5);
        expect(reviews[0].brideName, 'Bride One');
        expect(reviews[1].id, 'review-2');
        expect(reviews[1].rating, 4);
        expect(reviews[1].brideAvatarUrl, 'https://example.com/avatar.jpg');
      });
    });

    group('ProRating entity parsing', () {
      test('should parse ProRating from pro_ratings view row', () {
        final row = {
          'pro_id': 'pro-456',
          'average_rating': 4.5,
          'review_count': 12,
        };

        final rating = ProRating.fromJson(row);

        expect(rating.proId, 'pro-456');
        expect(rating.averageRating, 4.5);
        expect(rating.reviewCount, 12);
        expect(rating.displayRating, '4.5/5 (12 reviews)');
      });

      test('should handle singular review count display', () {
        final row = {
          'pro_id': 'pro-456',
          'average_rating': 5.0,
          'review_count': 1,
        };

        final rating = ProRating.fromJson(row);

        expect(rating.displayRating, '5.0/5 (1 review)');
      });

      test('should handle empty ProRating', () {
        final rating = ProRating.empty('pro-new');

        expect(rating.proId, 'pro-new');
        expect(rating.averageRating, 0.0);
        expect(rating.reviewCount, 0);
        expect(rating.hasReviews, false);
      });

      test('should handle null values in ProRating JSON', () {
        final row = {
          'pro_id': 'pro-456',
          'average_rating': null,
          'review_count': null,
        };

        final rating = ProRating.fromJson(row);

        expect(rating.averageRating, 0.0);
        expect(rating.reviewCount, 0);
      });

      test('should create ratings map from multiple rows', () {
        final rows = [
          {
            'pro_id': 'pro-1',
            'average_rating': 4.5,
            'review_count': 10,
          },
          {
            'pro_id': 'pro-2',
            'average_rating': 3.8,
            'review_count': 5,
          },
        ];

        final ratings = <String, ProRating>{};
        for (final row in rows) {
          final rating = ProRating.fromJson(row);
          ratings[rating.proId] = rating;
        }

        expect(ratings.length, 2);
        expect(ratings['pro-1']!.averageRating, 4.5);
        expect(ratings['pro-2']!.averageRating, 3.8);
        expect(ratings['pro-3'], isNull);
      });
    });

    group('authentication', () {
      test('should throw StateError when accessing currentUserId without auth', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        // The repository checks auth in methods that need it
        // We verify it throws by testing the expected behavior
        expect(
          () => repository.hasReviewedPro('pro-X'),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw StateError for createReview without auth', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(
          () => repository.createReview(proId: 'pro-X', rating: 5),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw StateError for getMyReviews without auth', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(
          () => repository.getMyReviews(),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw StateError for getMyReviewForPro without auth', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(
          () => repository.getMyReviewForPro('pro-X'),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Review entity methods', () {
      test('hasComment should return true for non-empty comment', () {
        final review = Review(
          id: 'review-1',
          proId: 'pro-1',
          brideId: 'bride-1',
          rating: 5,
          comment: 'Great service!',
          createdAt: DateTime.now(),
        );

        expect(review.hasComment, true);
      });

      test('hasComment should return false for null comment', () {
        final review = Review(
          id: 'review-1',
          proId: 'pro-1',
          brideId: 'bride-1',
          rating: 5,
          comment: null,
          createdAt: DateTime.now(),
        );

        expect(review.hasComment, false);
      });

      test('hasComment should return false for empty comment', () {
        final review = Review(
          id: 'review-1',
          proId: 'pro-1',
          brideId: 'bride-1',
          rating: 5,
          comment: '',
          createdAt: DateTime.now(),
        );

        expect(review.hasComment, false);
      });

      test('timeAgo should return "just now" for recent reviews', () {
        final review = Review(
          id: 'review-1',
          proId: 'pro-1',
          brideId: 'bride-1',
          rating: 5,
          createdAt: DateTime.now(),
        );

        expect(review.timeAgo, 'just now');
      });

      test('timeAgo should return days for older reviews', () {
        final review = Review(
          id: 'review-1',
          proId: 'pro-1',
          brideId: 'bride-1',
          rating: 5,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        );

        expect(review.timeAgo, '5 days ago');
      });
    });

    group('ProRating entity methods', () {
      test('shortRating should return formatted rating', () {
        final rating = ProRating(
          proId: 'pro-1',
          averageRating: 4.567,
          reviewCount: 10,
        );

        expect(rating.shortRating, '4.6');
      });

      test('hasReviews should return true when reviewCount > 0', () {
        final rating = ProRating(
          proId: 'pro-1',
          averageRating: 4.5,
          reviewCount: 1,
        );

        expect(rating.hasReviews, true);
      });

      test('hasReviews should return false when reviewCount is 0', () {
        final rating = ProRating(
          proId: 'pro-1',
          averageRating: 0.0,
          reviewCount: 0,
        );

        expect(rating.hasReviews, false);
      });
    });

    group('getRatingsForPros edge cases', () {
      test('should return empty map for empty proIds list', () async {
        final ratings = await repository.getRatingsForPros([]);
        expect(ratings, isEmpty);
      });
    });
  });
}
