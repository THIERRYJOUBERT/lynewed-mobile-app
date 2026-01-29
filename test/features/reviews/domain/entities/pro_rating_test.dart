import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/domain/entities/pro_rating.dart';

void main() {
  group('ProRating', () {
    // ==============================================================
    // CREATION TESTS (AC4)
    // ==============================================================

    group('creation', () {
      test('should create ProRating with required fields', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating.proId, 'pro-123');
        expect(proRating.averageRating, 4.5);
        expect(proRating.reviewCount, 12);
      });

      test('should be immutable', () {
        // Entity is marked @immutable, this test verifies final fields
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating.proId, isNotNull);
        expect(proRating.averageRating, isNotNull);
        expect(proRating.reviewCount, isNotNull);
      });
    });

    // ==============================================================
    // DISPLAYRATING TESTS (AC4)
    // ==============================================================

    group('displayRating', () {
      test('should return formatted rating "4.5/5 (12 reviews)"', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating.displayRating, '4.5/5 (12 reviews)');
      });

      test('should return singular "review" for 1 review', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 5.0,
          reviewCount: 1,
        );

        expect(proRating.displayRating, '5.0/5 (1 review)');
      });

      test('should format integer rating correctly', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.0,
          reviewCount: 5,
        );

        expect(proRating.displayRating, '4.0/5 (5 reviews)');
      });

      test('should handle 0 reviews', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 0.0,
          reviewCount: 0,
        );

        expect(proRating.displayRating, '0.0/5 (0 reviews)');
      });
    });

    // ==============================================================
    // SHORTRATING TESTS
    // ==============================================================

    group('shortRating', () {
      test('should return just the rating number', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating.shortRating, '4.5');
      });

      test('should format integer rating with decimal', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 5.0,
          reviewCount: 10,
        );

        expect(proRating.shortRating, '5.0');
      });
    });

    // ==============================================================
    // HASREVIEWS TESTS (AC7)
    // ==============================================================

    group('hasReviews', () {
      test('should return true when reviewCount > 0', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating.hasReviews, true);
      });

      test('should return false when reviewCount is 0', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 0.0,
          reviewCount: 0,
        );

        expect(proRating.hasReviews, false);
      });
    });

    // ==============================================================
    // FROMJSON TESTS (AC5)
    // ==============================================================

    group('fromJson', () {
      test('should create ProRating from valid JSON', () {
        final json = {
          'pro_id': 'pro-123',
          'average_rating': 4.5,
          'review_count': 12,
        };

        final proRating = ProRating.fromJson(json);

        expect(proRating.proId, 'pro-123');
        expect(proRating.averageRating, 4.5);
        expect(proRating.reviewCount, 12);
      });

      test('should parse averageRating as double', () {
        final json = {
          'pro_id': 'pro-123',
          'average_rating': 4.0,
          'review_count': 10,
        };

        final proRating = ProRating.fromJson(json);

        expect(proRating.averageRating, isA<double>());
        expect(proRating.averageRating, 4.0);
      });

      test('should handle integer average_rating from JSON', () {
        final json = {
          'pro_id': 'pro-123',
          'average_rating': 4,
          'review_count': 10,
        };

        final proRating = ProRating.fromJson(json);

        expect(proRating.averageRating, 4.0);
        expect(proRating.averageRating, isA<double>());
      });

      test('should handle null average_rating', () {
        final json = {
          'pro_id': 'pro-123',
          'average_rating': null,
          'review_count': 0,
        };

        final proRating = ProRating.fromJson(json);

        expect(proRating.averageRating, 0.0);
      });

      test('should handle null review_count', () {
        final json = {
          'pro_id': 'pro-123',
          'average_rating': 0.0,
          'review_count': null,
        };

        final proRating = ProRating.fromJson(json);

        expect(proRating.reviewCount, 0);
      });
    });

    // ==============================================================
    // EMPTY FACTORY TESTS (AC7)
    // ==============================================================

    group('empty', () {
      test('should create empty ProRating with given proId', () {
        final proRating = ProRating.empty('pro-123');

        expect(proRating.proId, 'pro-123');
        expect(proRating.averageRating, 0.0);
        expect(proRating.reviewCount, 0);
      });

      test('should have hasReviews return false for empty', () {
        final proRating = ProRating.empty('pro-123');

        expect(proRating.hasReviews, false);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        const proRating1 = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );
        const proRating2 = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating1, equals(proRating2));
        expect(proRating1.hashCode, equals(proRating2.hashCode));
      });

      test('should not be equal when proId differs', () {
        const proRating1 = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );
        const proRating2 = ProRating(
          proId: 'pro-456',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating1, isNot(equals(proRating2)));
      });

      test('should not be equal when averageRating differs', () {
        const proRating1 = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );
        const proRating2 = ProRating(
          proId: 'pro-123',
          averageRating: 4.0,
          reviewCount: 12,
        );

        expect(proRating1, isNot(equals(proRating2)));
      });

      test('should return identical for same instance', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        expect(proRating == proRating, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const proRating = ProRating(
          proId: 'pro-123',
          averageRating: 4.5,
          reviewCount: 12,
        );

        final result = proRating.toString();

        expect(result, contains('pro-123'));
        expect(result, contains('4.5'));
        expect(result, contains('12'));
      });
    });
  });
}
