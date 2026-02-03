/// Tests for MagazineCheckoutState.
///
/// Comprehensive tests for checkout state management.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_checkout_state.dart';

void main() {
  group('MagazineCheckoutState', () {
    final testFormat = MagazineFormats.iconic;
    const testAddress = ShippingAddress(
      fullName: 'John Doe',
      addressLine1: '123 Main St',
      city: 'New York',
      zipCode: '10001',
      country: 'US',
    );

    group('constructor', () {
      test('should create state with required fields', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'John & Jane Wedding',
        );

        expect(state.weddingId, 'wedding-123');
        expect(state.brideUserId, 'user-123');
        expect(state.format, testFormat);
        expect(state.photoCount, 25);
        expect(state.weddingTitle, 'John & Jane Wedding');
        expect(state.cgvuAccepted, false);
        expect(state.step, CheckoutStep.addressEntry);
      });

      test('should create state with optional fields', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'John & Jane Wedding',
          weddingDate: DateTime(2024, 6, 15),
          coverPhotoId: 'photo-123',
          coverPhotoUrl: 'https://example.com/cover.jpg',
        );

        expect(state.weddingDate, DateTime(2024, 6, 15));
        expect(state.coverPhotoId, 'photo-123');
        expect(state.coverPhotoUrl, 'https://example.com/cover.jpg');
      });
    });

    group('magazinePriceCents', () {
      test('should return format price', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: MagazineFormats.iconic,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        expect(state.magazinePriceCents, 5900);
      });
    });

    group('shippingCostCents', () {
      test('should return US shipping for US address', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress,
        );

        expect(state.shippingCostCents, 1500);
      });

      test('should return EU shipping for FR address', () {
        const frAddress = ShippingAddress(
          fullName: 'Jean Dupont',
          addressLine1: '15 Rue de Paris',
          city: 'Paris',
          zipCode: '75001',
          country: 'FR',
        );

        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: frAddress,
        );

        expect(state.shippingCostCents, 2500);
      });

      test('should return US shipping when no address', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        expect(state.shippingCostCents, 1500);
      });
    });

    group('totalCents', () {
      test('should return sum of magazine and shipping', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: MagazineFormats.iconic, // 5900
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress, // US - 1500
        );

        expect(state.totalCents, 7400);
      });
    });

    group('formatted prices', () {
      test('should format magazine price', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: MagazineFormats.iconic,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        expect(state.magazinePriceFormatted, r'$59');
      });

      test('should format shipping cost', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress,
        );

        expect(state.shippingCostFormatted, r'$15');
      });

      test('should format total with cents', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: MagazineFormats.iconic,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress,
        );

        expect(state.totalFormatted, r'$74.00');
      });
    });

    group('canProceed', () {
      test('should return false when address is null', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          cgvuAccepted: true,
        );

        expect(state.canProceed, false);
      });

      test('should return false when address is invalid', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          cgvuAccepted: true,
        );

        expect(state.canProceed, false);
      });

      test('should return false when CGVU not accepted', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress,
          cgvuAccepted: false,
        );

        expect(state.canProceed, false);
      });

      test('should return false when processing', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress,
          cgvuAccepted: true,
          step: CheckoutStep.processing,
        );

        expect(state.canProceed, false);
      });

      test('should return true when all conditions met', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: testAddress,
          cgvuAccepted: true,
          step: CheckoutStep.addressEntry,
        );

        expect(state.canProceed, true);
      });
    });

    group('status flags', () {
      test('isProcessing should be true for processing step', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          step: CheckoutStep.processing,
        );

        expect(state.isProcessing, true);
        expect(state.isSuccess, false);
        expect(state.isFailed, false);
      });

      test('isSuccess should be true for success step', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          step: CheckoutStep.success,
        );

        expect(state.isProcessing, false);
        expect(state.isSuccess, true);
        expect(state.isFailed, false);
      });

      test('isFailed should be true for failed step', () {
        final state = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          step: CheckoutStep.failed,
        );

        expect(state.isProcessing, false);
        expect(state.isSuccess, false);
        expect(state.isFailed, true);
      });
    });

    group('copyWith', () {
      test('should copy with updated address', () {
        final original = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final updated = original.copyWith(address: testAddress);

        expect(updated.address, testAddress);
        expect(updated.weddingId, 'wedding-123');
      });

      test('should copy with updated cgvuAccepted', () {
        final original = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final updated = original.copyWith(cgvuAccepted: true);

        expect(updated.cgvuAccepted, true);
      });

      test('should copy with updated step', () {
        final original = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final updated = original.copyWith(step: CheckoutStep.processing);

        expect(updated.step, CheckoutStep.processing);
      });

      test('should clear error message', () {
        final original = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          errorMessage: 'Something went wrong',
        );

        final updated = original.copyWith(clearError: true);

        expect(updated.errorMessage, isNull);
      });

      test('should copy with checkout url and session', () {
        final original = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final updated = original.copyWith(
          checkoutUrl: 'https://checkout.stripe.com/...',
          checkoutSessionId: 'cs_test_123',
        );

        expect(updated.checkoutUrl, 'https://checkout.stripe.com/...');
        expect(updated.checkoutSessionId, 'cs_test_123');
      });

      test('should clear checkout url when flag set', () {
        final original = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          checkoutUrl: 'https://checkout.stripe.com/...',
        );

        final updated = original.copyWith(clearCheckoutUrl: true);

        expect(updated.checkoutUrl, isNull);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final state1 = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final state2 = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        expect(state1, equals(state2));
      });

      test('should not be equal when fields differ', () {
        final state1 = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final state2 = MagazineCheckoutState(
          weddingId: 'wedding-456',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('hashCode', () {
      test('should be same for equal states', () {
        final state1 = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        final state2 = MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
        );

        expect(state1.hashCode, equals(state2.hashCode));
      });
    });
  });

  group('CheckoutStep', () {
    test('should have all expected values', () {
      expect(CheckoutStep.values.length, 4);
      expect(CheckoutStep.values, contains(CheckoutStep.addressEntry));
      expect(CheckoutStep.values, contains(CheckoutStep.processing));
      expect(CheckoutStep.values, contains(CheckoutStep.success));
      expect(CheckoutStep.values, contains(CheckoutStep.failed));
    });
  });
}
