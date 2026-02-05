import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';

void main() {
  group('MarketplaceOffer', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create MarketplaceOffer with required fields', () {
        final now = DateTime(2026, 2, 4);
        final expiresAt = now.add(const Duration(hours: 48));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: expiresAt,
          createdAt: now,
        );

        expect(offer.id, 'offer-123');
        expect(offer.listingId, 'listing-456');
        expect(offer.buyerId, 'buyer-789');
        expect(offer.amountCents, 25000);
        expect(offer.status, 'pending');
        expect(offer.expiresAt, expiresAt);
        expect(offer.createdAt, now);
        expect(offer.message, isNull);
        expect(offer.respondedAt, isNull);
      });

      test('should create MarketplaceOffer with optional fields', () {
        final now = DateTime(2026, 2, 4);
        final expiresAt = now.add(const Duration(hours: 48));
        final respondedAt = now.add(const Duration(hours: 2));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          message: 'Interested in this dress',
          status: 'accepted',
          expiresAt: expiresAt,
          createdAt: now,
          respondedAt: respondedAt,
        );

        expect(offer.message, 'Interested in this dress');
        expect(offer.respondedAt, respondedAt);
      });

      test('should be immutable', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        // Verify fields are final (compile-time check)
        // Cannot reassign: offer.status = 'accepted'; // Would not compile
        expect(offer.status, 'pending');
      });
    });

    // ==============================================================
    // STATUS TESTS
    // ==============================================================

    group('status helpers', () {
      test('isPending should be true when status is pending', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isPending, isTrue);
      });

      test('isPending should be false when status is not pending', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'accepted',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isPending, isFalse);
      });

      test('isAccepted should be true when status is accepted', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'accepted',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isAccepted, isTrue);
      });

      test('isAccepted should be false when status is not accepted', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isAccepted, isFalse);
      });

      test('isExpired should be true when status is expired', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'expired',
          expiresAt: now.subtract(const Duration(hours: 1)),
          createdAt: now,
        );

        expect(offer.isExpired, isTrue);
      });

      test('isExpired should be true when pending and past expires_at', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.subtract(const Duration(hours: 1)),
          createdAt: now,
        );

        expect(offer.isExpired, isTrue);
      });

      test('isExpired should be false when pending and before expires_at', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.isExpired, isFalse);
      });

      test('isExpired should be false when status is withdrawn', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'withdrawn',
          expiresAt: now.subtract(const Duration(hours: 1)),
          createdAt: now,
        );

        expect(offer.isExpired, isFalse);
      });
    });

    // ==============================================================
    // AMOUNT TESTS
    // ==============================================================

    group('amountInDollars', () {
      test('should convert cents to dollars correctly', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.amountInDollars, 250.0);
      });

      test('should handle non-round amounts', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 29999,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.amountInDollars, 299.99);
      });

      test('should handle small amounts', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 1,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer.amountInDollars, 0.01);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime(2026, 2, 4);
        final offer1 = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final offer2 = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-999',
          buyerId: 'buyer-999',
          amountCents: 50000,
          status: 'accepted',
          expiresAt: now,
          createdAt: now,
        );

        expect(offer1, equals(offer2));
        expect(offer1.hashCode, equals(offer2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime(2026, 2, 4);
        final offer1 = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final offer2 = MarketplaceOffer(
          id: 'offer-999',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        expect(offer1, isNot(equals(offer2)));
        expect(offer1.hashCode, isNot(equals(offer2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated status', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final updated = offer.copyWith(status: 'accepted');

        expect(updated.status, 'accepted');
        expect(updated.id, offer.id);
        expect(updated.amountCents, offer.amountCents);
      });

      test('should create copy with updated responded_at', () {
        final now = DateTime(2026, 2, 4);
        final respondedAt = now.add(const Duration(hours: 2));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final updated = offer.copyWith(respondedAt: respondedAt);

        expect(updated.respondedAt, respondedAt);
        expect(updated.id, offer.id);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime(2026, 2, 4);
        final respondedAt = now.add(const Duration(hours: 2));
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          message: 'Test message',
          status: 'accepted',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
          respondedAt: respondedAt,
        );

        final copied = offer.copyWith();

        expect(copied.id, offer.id);
        expect(copied.listingId, offer.listingId);
        expect(copied.buyerId, offer.buyerId);
        expect(copied.amountCents, offer.amountCents);
        expect(copied.message, offer.message);
        expect(copied.status, offer.status);
        expect(copied.expiresAt, offer.expiresAt);
        expect(copied.createdAt, offer.createdAt);
        expect(copied.respondedAt, offer.respondedAt);
      });

      test('should create copy with updated amountCents', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final updated = offer.copyWith(amountCents: 30000);

        expect(updated.amountCents, 30000);
        expect(updated.id, offer.id);
        expect(updated.status, offer.status);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'buyer_id': '770e8400-e29b-41d4-a716-446655440002',
          'amount_cents': 25000,
          'message': 'Very interested in this dress',
          'status': 'pending',
          'expires_at': '2026-02-06T10:00:00.000Z',
          'created_at': '2026-02-04T10:00:00.000Z',
          'responded_at': '2026-02-04T14:00:00.000Z',
        };

        final offer = MarketplaceOffer.fromJson(json);

        expect(offer.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(offer.listingId, '660e8400-e29b-41d4-a716-446655440001');
        expect(offer.buyerId, '770e8400-e29b-41d4-a716-446655440002');
        expect(offer.amountCents, 25000);
        expect(offer.message, 'Very interested in this dress');
        expect(offer.status, 'pending');
        expect(
            offer.expiresAt, DateTime.parse('2026-02-06T10:00:00.000Z'));
        expect(
            offer.createdAt, DateTime.parse('2026-02-04T10:00:00.000Z'));
        expect(
            offer.respondedAt, DateTime.parse('2026-02-04T14:00:00.000Z'));
      });

      test('should handle null optional fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'buyer_id': '770e8400-e29b-41d4-a716-446655440002',
          'amount_cents': 10000,
          'message': null,
          'status': 'pending',
          'expires_at': '2026-02-06T10:00:00.000Z',
          'created_at': '2026-02-04T10:00:00.000Z',
          'responded_at': null,
        };

        final offer = MarketplaceOffer.fromJson(json);

        expect(offer.message, isNull);
        expect(offer.respondedAt, isNull);
      });

      test('should handle missing optional keys in JSON', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'listing_id': '660e8400-e29b-41d4-a716-446655440001',
          'buyer_id': '770e8400-e29b-41d4-a716-446655440002',
          'amount_cents': 10000,
          'status': 'pending',
          'expires_at': '2026-02-06T10:00:00.000Z',
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final offer = MarketplaceOffer.fromJson(json);

        expect(offer.message, isNull);
        expect(offer.respondedAt, isNull);
      });

      test('should parse different status values', () {
        for (final status
            in ['pending', 'accepted', 'rejected', 'expired', 'withdrawn']) {
          final json = {
            'id': '550e8400-e29b-41d4-a716-446655440000',
            'listing_id': '660e8400-e29b-41d4-a716-446655440001',
            'buyer_id': '770e8400-e29b-41d4-a716-446655440002',
            'amount_cents': 10000,
            'status': status,
            'expires_at': '2026-02-06T10:00:00.000Z',
            'created_at': '2026-02-04T10:00:00.000Z',
          };

          final offer = MarketplaceOffer.fromJson(json);

          expect(offer.status, status);
        }
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should produce correct snake_case keys', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          message: 'Interested',
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final json = offer.toJson();

        expect(json['listing_id'], 'listing-456');
        expect(json['buyer_id'], 'buyer-789');
        expect(json['amount_cents'], 25000);
        expect(json['message'], 'Interested');
        expect(json['status'], 'pending');
      });

      test('should exclude auto-generated fields', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'accepted',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
          respondedAt: now.add(const Duration(hours: 2)),
        );

        final json = offer.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('expires_at'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
        expect(json.containsKey('responded_at'), isFalse);
      });

      test('should include null message when not provided', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final json = offer.toJson();

        expect(json.containsKey('message'), isTrue);
        expect(json['message'], isNull);
      });

      test('should only contain expected keys', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          message: 'Test',
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final json = offer.toJson();
        final expectedKeys = {
          'listing_id',
          'buyer_id',
          'amount_cents',
          'message',
          'status',
        };

        expect(json.keys.toSet(), expectedKeys);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime(2026, 2, 4);
        final offer = MarketplaceOffer(
          id: 'offer-123',
          listingId: 'listing-456',
          buyerId: 'buyer-789',
          amountCents: 25000,
          status: 'pending',
          expiresAt: now.add(const Duration(hours: 48)),
          createdAt: now,
        );

        final str = offer.toString();

        expect(str, contains('offer-123'));
        expect(str, contains('listing-456'));
        expect(str, contains('25000'));
        expect(str, contains('pending'));
      });
    });
  });
}
