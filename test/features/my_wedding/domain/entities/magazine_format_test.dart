/// Tests for MagazineFormat entity.
///
/// Comprehensive tests for magazine format validation and properties.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';

void main() {
  group('MagazineFormat', () {
    group('constructor', () {
      test('should create format with all properties', () {
        const format = MagazineFormat(
          id: 'guest_edition',
          name: 'GUEST EDITION',
          size: '21x30cm',
          spreads: 20,
          maxPhotos: 20,
          priceCents: 2900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.id, 'guest_edition');
        expect(format.name, 'GUEST EDITION');
        expect(format.size, '21x30cm');
        expect(format.spreads, 20);
        expect(format.maxPhotos, 20);
        expect(format.priceCents, 2900);
      });
    });

    group('isValidForPhotoCount', () {
      test('should return true when photo count equals max', () {
        const format = MagazineFormat(
          id: 'guest_edition',
          name: 'GUEST EDITION',
          size: '21x30cm',
          spreads: 20,
          maxPhotos: 20,
          priceCents: 2900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.isValidForPhotoCount(20), true);
      });

      test('should return true when photo count is less than max', () {
        const format = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.isValidForPhotoCount(15), true);
      });

      test('should return false when photo count exceeds max', () {
        const format = MagazineFormat(
          id: 'guest_edition',
          name: 'GUEST EDITION',
          size: '21x30cm',
          spreads: 20,
          maxPhotos: 20,
          priceCents: 2900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.isValidForPhotoCount(25), false);
      });

      test('should return true for zero photos', () {
        const format = MagazineFormat(
          id: 'memory',
          name: 'MEMORY',
          size: '21x30cm',
          spreads: 60,
          maxPhotos: 60,
          priceCents: 6900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.isValidForPhotoCount(0), true);
      });
    });

    group('priceFormatted', () {
      test('should format whole dollar amounts correctly', () {
        const format = MagazineFormat(
          id: 'guest_edition',
          name: 'GUEST EDITION',
          size: '21x30cm',
          spreads: 20,
          maxPhotos: 20,
          priceCents: 2900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.priceFormatted, r'$29');
      });

      test('should format prices with cents correctly', () {
        const format = MagazineFormat(
          id: 'test',
          name: 'TEST',
          size: '21x30cm',
          spreads: 20,
          maxPhotos: 20,
          priceCents: 2950,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.priceFormatted, r'$29.50');
      });

      test('should format zero price correctly', () {
        const format = MagazineFormat(
          id: 'free',
          name: 'FREE',
          size: '21x30cm',
          spreads: 10,
          maxPhotos: 10,
          priceCents: 0,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.priceFormatted, r'$0');
      });
    });

    group('isPremium', () {
      test('should return true for collector format', () {
        const format = MagazineFormat(
          id: 'collector',
          name: 'COLLECTOR',
          size: '25x32cm',
          spreads: 60,
          maxPhotos: 60,
          priceCents: 8900,
          widthCm: 25,
          heightCm: 32,
        );

        expect(format.isPremium, true);
      });

      test('should return false for non-collector formats', () {
        const format = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format.isPremium, false);
      });
    });

    group('equality', () {
      test('should be equal when ids match', () {
        const format1 = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        const format2 = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format1, equals(format2));
      });

      test('should not be equal when ids differ', () {
        const format1 = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        const format2 = MagazineFormat(
          id: 'memory',
          name: 'MEMORY',
          size: '21x30cm',
          spreads: 60,
          maxPhotos: 60,
          priceCents: 6900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format1, isNot(equals(format2)));
      });
    });

    group('hashCode', () {
      test('should be same for equal formats', () {
        const format1 = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        const format2 = MagazineFormat(
          id: 'iconic',
          name: 'ICONIC',
          size: '21x30cm',
          spreads: 40,
          maxPhotos: 40,
          priceCents: 5900,
          widthCm: 21,
          heightCm: 30,
        );

        expect(format1.hashCode, equals(format2.hashCode));
      });
    });

    group('toString', () {
      test('should include id and name', () {
        const format = MagazineFormat(
          id: 'collector',
          name: 'COLLECTOR',
          size: '25x32cm',
          spreads: 60,
          maxPhotos: 60,
          priceCents: 8900,
          widthCm: 25,
          heightCm: 32,
        );

        expect(format.toString(), contains('collector'));
        expect(format.toString(), contains('COLLECTOR'));
      });
    });
  });

  group('MagazineFormats', () {
    test('should have exactly 4 formats', () {
      expect(MagazineFormats.all.length, 4);
    });

    test('should contain guest edition format', () {
      expect(MagazineFormats.guestEdition.id, 'guest_edition');
      expect(MagazineFormats.guestEdition.maxPhotos, 20);
      expect(MagazineFormats.guestEdition.priceCents, 2900);
    });

    test('should contain iconic format', () {
      expect(MagazineFormats.iconic.id, 'iconic');
      expect(MagazineFormats.iconic.maxPhotos, 40);
      expect(MagazineFormats.iconic.priceCents, 5900);
    });

    test('should contain memory format', () {
      expect(MagazineFormats.memory.id, 'memory');
      expect(MagazineFormats.memory.maxPhotos, 60);
      expect(MagazineFormats.memory.priceCents, 6900);
    });

    test('should contain collector format', () {
      expect(MagazineFormats.collector.id, 'collector');
      expect(MagazineFormats.collector.maxPhotos, 60);
      expect(MagazineFormats.collector.priceCents, 8900);
      expect(MagazineFormats.collector.size, '25x32cm');
    });

    test('all formats should be ordered by price ascending', () {
      final prices = MagazineFormats.all.map((f) => f.priceCents).toList();
      for (var i = 0; i < prices.length - 1; i++) {
        expect(prices[i], lessThanOrEqualTo(prices[i + 1]));
      }
    });

    group('getValidFormats', () {
      test('should return all formats for 0 photos', () {
        final valid = MagazineFormats.getValidFormats(0);
        expect(valid.length, 4);
      });

      test('should return all formats for 20 photos', () {
        final valid = MagazineFormats.getValidFormats(20);
        expect(valid.length, 4);
      });

      test('should exclude guest edition for 25 photos', () {
        final valid = MagazineFormats.getValidFormats(25);
        expect(valid.length, 3);
        expect(valid.any((f) => f.id == 'guest_edition'), false);
      });

      test('should exclude guest edition and iconic for 45 photos', () {
        final valid = MagazineFormats.getValidFormats(45);
        expect(valid.length, 2);
        expect(valid.any((f) => f.id == 'guest_edition'), false);
        expect(valid.any((f) => f.id == 'iconic'), false);
      });

      test('should return memory and collector for 60 photos', () {
        final valid = MagazineFormats.getValidFormats(60);
        expect(valid.length, 2);
        expect(valid.any((f) => f.id == 'memory'), true);
        expect(valid.any((f) => f.id == 'collector'), true);
      });

      test('should return empty list for photos exceeding all formats', () {
        final valid = MagazineFormats.getValidFormats(100);
        expect(valid, isEmpty);
      });
    });

    group('getCheapestValidFormat', () {
      test('should return guest edition for 15 photos', () {
        final cheapest = MagazineFormats.getCheapestValidFormat(15);
        expect(cheapest?.id, 'guest_edition');
      });

      test('should return iconic for 25 photos', () {
        final cheapest = MagazineFormats.getCheapestValidFormat(25);
        expect(cheapest?.id, 'iconic');
      });

      test('should return memory for 50 photos', () {
        final cheapest = MagazineFormats.getCheapestValidFormat(50);
        expect(cheapest?.id, 'memory');
      });

      test('should return null for photos exceeding all formats', () {
        final cheapest = MagazineFormats.getCheapestValidFormat(100);
        expect(cheapest, isNull);
      });
    });

    group('getFormatById', () {
      test('should find format by id', () {
        final format = MagazineFormats.getFormatById('iconic');
        expect(format?.name, 'ICONIC');
      });

      test('should return null for unknown id', () {
        final format = MagazineFormats.getFormatById('unknown');
        expect(format, isNull);
      });
    });
  });
}
