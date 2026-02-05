/// Tests for MagazineOrderItem entity.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_order_item.dart';

void main() {
  group('MagazineOrderItem', () {
    final testJson = {
      'id': 'item-001',
      'order_id': 'order-123',
      'media_type': 'album_image',
      'media_id': 'media-456',
      'position': 1,
      'storage_url':
          'https://example.supabase.co/storage/v1/object/public/wedding-albums/photo.jpg',
      'caption': 'Our first dance',
    };

    group('fromJson', () {
      test('should parse all fields', () {
        final item = MagazineOrderItem.fromJson(testJson);

        expect(item.id, 'item-001');
        expect(item.orderId, 'order-123');
        expect(item.mediaType, 'album_image');
        expect(item.mediaId, 'media-456');
        expect(item.position, 1);
        expect(item.storageUrl, contains('photo.jpg'));
        expect(item.caption, 'Our first dance');
      });

      test('should handle null caption', () {
        final json = Map<String, dynamic>.from(testJson);
        json['caption'] = null;
        final item = MagazineOrderItem.fromJson(json);

        expect(item.caption, isNull);
      });
    });

    group('computed properties', () {
      test('isGuestMedia should be false for album_image', () {
        final item = MagazineOrderItem.fromJson(testJson);
        expect(item.isGuestMedia, false);
      });

      test('isGuestMedia should be true for guest_media', () {
        final json = Map<String, dynamic>.from(testJson);
        json['media_type'] = 'guest_media';
        final item = MagazineOrderItem.fromJson(json);
        expect(item.isGuestMedia, true);
      });

      test('hasFullUrl should be true for http URLs', () {
        final item = MagazineOrderItem.fromJson(testJson);
        expect(item.hasFullUrl, true);
      });

      test('hasFullUrl should be false for relative paths', () {
        final json = Map<String, dynamic>.from(testJson);
        json['storage_url'] = 'wedding-id/guests/user-id/photo.jpg';
        final item = MagazineOrderItem.fromJson(json);
        expect(item.hasFullUrl, false);
      });
    });

    group('equality', () {
      test('should be equal when id matches', () {
        final item1 = MagazineOrderItem.fromJson(testJson);
        final item2 = MagazineOrderItem.fromJson(testJson);
        expect(item1, equals(item2));
      });

      test('should not be equal when id differs', () {
        final json2 = Map<String, dynamic>.from(testJson);
        json2['id'] = 'item-999';
        final item1 = MagazineOrderItem.fromJson(testJson);
        final item2 = MagazineOrderItem.fromJson(json2);
        expect(item1, isNot(equals(item2)));
      });

      test('should have same hashCode for equal items', () {
        final item1 = MagazineOrderItem.fromJson(testJson);
        final item2 = MagazineOrderItem.fromJson(testJson);
        expect(item1.hashCode, equals(item2.hashCode));
      });
    });
  });
}
