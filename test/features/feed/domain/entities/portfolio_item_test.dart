import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';

void main() {
  group('PortfolioItem', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create PortfolioItem with required fields', () {
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final item = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          createdAt: createdAt,
        );

        expect(item.id, 'item-123');
        expect(item.imageUrl, 'https://example.com/image.jpg');
        expect(item.professionalId, 'pro-456');
        expect(item.caption, isNull);
        expect(item.createdAt, createdAt);
      });

      test('should create PortfolioItem with optional caption', () {
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final item = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          caption: 'Beautiful wedding setup',
          createdAt: createdAt,
        );

        expect(item.caption, 'Beautiful wedding setup');
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse PortfolioItem with all fields', () {
        final json = {
          'id': 'item-123',
          'image_url': 'https://example.com/image.jpg',
          'professional_id': 'pro-456',
          'caption': 'Wedding decoration',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final item = PortfolioItem.fromJson(json);

        expect(item.id, 'item-123');
        expect(item.imageUrl, 'https://example.com/image.jpg');
        expect(item.professionalId, 'pro-456');
        expect(item.caption, 'Wedding decoration');
        expect(item.createdAt.year, 2025);
        expect(item.createdAt.month, 1);
        expect(item.createdAt.day, 24);
      });

      test('should parse PortfolioItem with minimal fields', () {
        final json = {
          'id': 'item-123',
          'image_url': 'https://example.com/image.jpg',
          'professional_id': 'pro-456',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final item = PortfolioItem.fromJson(json);

        expect(item.id, 'item-123');
        expect(item.imageUrl, 'https://example.com/image.jpg');
        expect(item.professionalId, 'pro-456');
        expect(item.caption, isNull);
      });

      test('should handle null caption', () {
        final json = {
          'id': 'item-123',
          'image_url': 'https://example.com/image.jpg',
          'professional_id': 'pro-456',
          'caption': null,
          'created_at': '2025-01-24T10:00:00Z',
        };

        final item = PortfolioItem.fromJson(json);

        expect(item.caption, isNull);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final createdAt = DateTime.utc(2025, 1, 24, 10, 0, 0);
        final item = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          caption: 'Wedding photo',
          createdAt: createdAt,
        );

        final json = item.toJson();

        expect(json['id'], 'item-123');
        expect(json['image_url'], 'https://example.com/image.jpg');
        expect(json['professional_id'], 'pro-456');
        expect(json['caption'], 'Wedding photo');
        expect(json['created_at'], '2025-01-24T10:00:00.000Z');
      });

      test('should serialize null caption', () {
        final createdAt = DateTime.utc(2025, 1, 24, 10, 0, 0);
        final item = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          createdAt: createdAt,
        );

        final json = item.toJson();

        expect(json['caption'], isNull);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final createdAt = DateTime(2025, 1, 24);
        final original = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/original.jpg',
          professionalId: 'pro-456',
          caption: 'Original caption',
          createdAt: createdAt,
        );

        final copied = original.copyWith(caption: 'New caption');

        expect(copied.id, 'item-123');
        expect(copied.imageUrl, 'https://example.com/original.jpg');
        expect(copied.professionalId, 'pro-456');
        expect(copied.caption, 'New caption');
        expect(copied.createdAt, createdAt);
      });

      test('should update multiple fields at once', () {
        final original = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/original.jpg',
          professionalId: 'pro-456',
          createdAt: DateTime(2025, 1, 24),
        );

        final newDate = DateTime(2025, 2, 1);
        final copied = original.copyWith(
          imageUrl: 'https://example.com/new.jpg',
          createdAt: newDate,
        );

        expect(copied.imageUrl, 'https://example.com/new.jpg');
        expect(copied.createdAt, newDate);
      });

      test('should not modify original', () {
        final original = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/original.jpg',
          professionalId: 'pro-456',
          createdAt: DateTime(2025, 1, 24),
        );

        original.copyWith(caption: 'Modified');

        expect(original.caption, isNull);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        final createdAt = DateTime(2025, 1, 24);
        final item1 = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image1.jpg',
          professionalId: 'pro-456',
          createdAt: createdAt,
        );
        final item2 = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image2.jpg',
          professionalId: 'pro-789',
          createdAt: createdAt,
        );

        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('should not be equal when id differs', () {
        final createdAt = DateTime(2025, 1, 24);
        final item1 = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          createdAt: createdAt,
        );
        final item2 = PortfolioItem(
          id: 'item-456',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          createdAt: createdAt,
        );

        expect(item1, isNot(equals(item2)));
      });

      test('should return identical for same instance', () {
        final item = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          createdAt: DateTime(2025, 1, 24),
        );

        expect(item == item, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final item = PortfolioItem(
          id: 'item-123',
          imageUrl: 'https://example.com/image.jpg',
          professionalId: 'pro-456',
          createdAt: DateTime(2025, 1, 24),
        );

        final result = item.toString();

        expect(result, contains('item-123'));
        expect(result, contains('pro-456'));
      });
    });
  });
}
