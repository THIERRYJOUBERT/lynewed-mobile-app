import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/review.dart';

void main() {
  group('Review', () {
    // ==============================================================
    // CREATION TESTS (AC1)
    // ==============================================================

    group('creation', () {
      test('should create Review with required fields', () {
        final now = DateTime.now();
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: now,
        );

        expect(review.id, 'review-123');
        expect(review.proId, 'pro-456');
        expect(review.brideId, 'bride-789');
        expect(review.rating, 5);
        expect(review.createdAt, now);
        expect(review.comment, isNull);
        expect(review.updatedAt, isNull);
      });

      test('should create Review with all optional fields', () {
        final now = DateTime.now();
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Great!',
          createdAt: now,
          updatedAt: now,
          brideName: 'Marie',
          brideAvatarUrl: 'https://example.com/avatar.jpg',
        );

        expect(review.comment, 'Great!');
        expect(review.updatedAt, now);
        expect(review.brideName, 'Marie');
        expect(review.brideAvatarUrl, 'https://example.com/avatar.jpg');
      });

      test('should be immutable', () {
        // Entity is marked @immutable, this test verifies final fields
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now(),
        );

        // All fields should be final (compile-time check)
        expect(review.id, isNotNull);
        expect(review.proId, isNotNull);
      });

      test('should have hasComment return true when comment exists', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Great service!',
          createdAt: DateTime.now(),
        );

        expect(review.hasComment, true);
      });

      test('should have hasComment return false when comment is null', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now(),
        );

        expect(review.hasComment, false);
      });

      test('should have hasComment return false when comment is empty', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: '',
          createdAt: DateTime.now(),
        );

        expect(review.hasComment, false);
      });
    });

    // ==============================================================
    // FROMJSON TESTS (AC2)
    // ==============================================================

    group('fromJson', () {
      test('should create Review from valid JSON', () {
        final json = {
          'id': 'test-id',
          'pro_id': 'pro-123',
          'bride_id': 'bride-456',
          'rating': 5,
          'comment': 'Excellent!',
          'created_at': '2026-01-28T10:00:00Z',
        };

        final review = Review.fromJson(json);

        expect(review.id, 'test-id');
        expect(review.proId, 'pro-123');
        expect(review.brideId, 'bride-456');
        expect(review.rating, 5);
        expect(review.comment, 'Excellent!');
        expect(review.hasComment, true);
      });

      test('should parse rating as integer between 1-5', () {
        final json = {
          'id': 'test-id',
          'pro_id': 'pro-123',
          'bride_id': 'bride-456',
          'rating': 3,
          'created_at': '2026-01-28T10:00:00Z',
        };

        final review = Review.fromJson(json);

        expect(review.rating, 3);
        expect(review.rating, greaterThanOrEqualTo(1));
        expect(review.rating, lessThanOrEqualTo(5));
      });

      test('should parse all optional fields when present', () {
        final json = {
          'id': 'test-id',
          'pro_id': 'pro-123',
          'bride_id': 'bride-456',
          'rating': 4,
          'comment': 'Very good!',
          'created_at': '2026-01-28T10:00:00Z',
          'updated_at': '2026-01-29T10:00:00Z',
          'bride_name': 'Marie',
          'bride_avatar_url': 'https://example.com/avatar.jpg',
        };

        final review = Review.fromJson(json);

        expect(review.updatedAt, isNotNull);
        expect(review.brideName, 'Marie');
        expect(review.brideAvatarUrl, 'https://example.com/avatar.jpg');
      });

      test('should handle null optional fields', () {
        final json = {
          'id': 'test-id',
          'pro_id': 'pro-123',
          'bride_id': 'bride-456',
          'rating': 5,
          'comment': null,
          'created_at': '2026-01-28T10:00:00Z',
          'updated_at': null,
          'bride_name': null,
          'bride_avatar_url': null,
        };

        final review = Review.fromJson(json);

        expect(review.comment, isNull);
        expect(review.updatedAt, isNull);
        expect(review.brideName, isNull);
        expect(review.brideAvatarUrl, isNull);
      });
    });

    // ==============================================================
    // TOJSON TESTS (AC3)
    // ==============================================================

    group('toJson', () {
      test('should produce valid JSON with all insert fields', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Excellent!',
          createdAt: DateTime.parse('2026-01-28T10:00:00Z'),
        );

        final json = review.toJson();

        expect(json['pro_id'], 'pro-456');
        expect(json['bride_id'], 'bride-789');
        expect(json['rating'], 5);
        expect(json['comment'], 'Excellent!');
      });

      test('should not include id in toJson (auto-generated by DB)', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now(),
        );

        final json = review.toJson();

        expect(json.containsKey('id'), false);
      });

      test('should not include created_at in toJson (auto-generated by DB)', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now(),
        );

        final json = review.toJson();

        expect(json.containsKey('created_at'), false);
      });

      test('should handle null comment in toJson', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 4,
          createdAt: DateTime.now(),
        );

        final json = review.toJson();

        expect(json['comment'], isNull);
      });
    });

    // ==============================================================
    // TIMEAGO TESTS (AC6)
    // ==============================================================

    group('timeAgo', () {
      test('should return human-readable time for recent review', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        final timeAgo = review.timeAgo;

        expect(timeAgo, isNotEmpty);
        // Should contain some time indication
        expect(timeAgo, isA<String>());
      });

      test('should return human-readable time for old review', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        final timeAgo = review.timeAgo;

        expect(timeAgo, isNotEmpty);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Original',
          createdAt: now,
        );

        final copied = original.copyWith(comment: 'Modified');

        expect(copied.id, 'review-123');
        expect(copied.proId, 'pro-456');
        expect(copied.brideId, 'bride-789');
        expect(copied.rating, 5);
        expect(copied.createdAt, now);
        expect(copied.comment, 'Modified');
      });

      test('should update multiple fields at once', () {
        final original = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 3,
          createdAt: DateTime.now(),
        );

        final copied = original.copyWith(
          rating: 5,
          comment: 'Updated comment',
        );

        expect(copied.rating, 5);
        expect(copied.comment, 'Updated comment');
      });

      test('should not modify original', () {
        final original = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Original',
          createdAt: DateTime.now(),
        );

        original.copyWith(comment: 'Modified');

        expect(original.comment, 'Original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        final now = DateTime(2026, 1, 28, 10, 0, 0);
        final review1 = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Great!',
          createdAt: now,
        );
        final review2 = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          comment: 'Great!',
          createdAt: now,
        );

        expect(review1, equals(review2));
        expect(review1.hashCode, equals(review2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime(2026, 1, 28, 10, 0, 0);
        final review1 = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: now,
        );
        final review2 = Review(
          id: 'review-456',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: now,
        );

        expect(review1, isNot(equals(review2)));
      });

      test('should not be equal when rating differs', () {
        final now = DateTime(2026, 1, 28, 10, 0, 0);
        final review1 = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 4,
          createdAt: now,
        );
        final review2 = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: now,
        );

        expect(review1, isNot(equals(review2)));
      });

      test('should return identical for same instance', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime.now(),
        );

        expect(review == review, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final review = Review(
          id: 'review-123',
          proId: 'pro-456',
          brideId: 'bride-789',
          rating: 5,
          createdAt: DateTime(2026, 1, 28),
        );

        final result = review.toString();

        expect(result, contains('review-123'));
        expect(result, contains('5'));
      });
    });
  });
}
