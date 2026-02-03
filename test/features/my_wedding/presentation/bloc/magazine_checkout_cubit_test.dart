/// Tests for MagazineCheckoutCubit.
///
/// Comprehensive tests for checkout cubit state management.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/shipping_address.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_checkout_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_checkout_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockFunctionsClient mockFunctions;
  final testFormat = MagazineFormats.iconic;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockFunctions = MockFunctionsClient();
    when(() => mockSupabase.functions).thenReturn(mockFunctions);
  });

  group('MagazineCheckoutCubit', () {
    group('initialization', () {
      test('should initialize with correct state', () {
        final cubit = MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        );

        expect(cubit.state.weddingId, 'wedding-123');
        expect(cubit.state.brideUserId, 'user-123');
        expect(cubit.state.format, testFormat);
        expect(cubit.state.photoCount, 25);
        expect(cubit.state.weddingTitle, 'Wedding');
        expect(cubit.state.step, CheckoutStep.addressEntry);
        expect(cubit.state.address, isNotNull);
        expect(cubit.state.cgvuAccepted, false);

        cubit.close();
      });

      test('should initialize with optional parameters', () {
        final weddingDate = DateTime(2024, 6, 15);
        final cubit = MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          weddingDate: weddingDate,
          coverPhotoId: 'photo-123',
          coverPhotoUrl: 'https://example.com/cover.jpg',
          supabaseClient: mockSupabase,
        );

        expect(cubit.state.weddingDate, weddingDate);
        expect(cubit.state.coverPhotoId, 'photo-123');
        expect(cubit.state.coverPhotoUrl, 'https://example.com/cover.jpg');

        cubit.close();
      });
    });

    group('updateAddress', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should update address in state',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) => cubit.updateAddress(const ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        )),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.address?.fullName, 'fullName', 'John Doe')
              .having((s) => s.address?.city, 'city', 'New York'),
        ],
      );

      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should clear error when updating address',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        seed: () => MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          errorMessage: 'Previous error',
        ),
        act: (cubit) => cubit.updateAddress(const ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          zipCode: '10001',
          country: 'US',
        )),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );
    });

    group('updateAddressField', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should update single field',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) => cubit.updateAddressField(fullName: 'Jane Doe'),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.address?.fullName, 'fullName', 'Jane Doe'),
        ],
      );

      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should update country and recalculate shipping',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) => cubit.updateAddressField(country: 'FR'),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.address?.country, 'country', 'FR')
              .having((s) => s.shippingCostCents, 'shippingCostCents', 2500),
        ],
      );
    });

    group('toggleCgvuAccepted', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should toggle CGVU from false to true',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) => cubit.toggleCgvuAccepted(),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.cgvuAccepted, 'cgvuAccepted', true),
        ],
      );

      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should toggle CGVU from true to false',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        seed: () => MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          cgvuAccepted: true,
        ),
        act: (cubit) => cubit.toggleCgvuAccepted(),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.cgvuAccepted, 'cgvuAccepted', false),
        ],
      );
    });

    group('setCgvuAccepted', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should set CGVU to specific value',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) => cubit.setCgvuAccepted(true),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.cgvuAccepted, 'cgvuAccepted', true),
        ],
      );
    });

    group('onPaymentSuccess', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should set state to success when sessionId matches',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        seed: () => MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          step: CheckoutStep.processing,
          checkoutSessionId: 'cs_test_123',
        ),
        act: (cubit) =>
            cubit.onPaymentSuccess('cs_test_123', orderId: 'order-456'),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.step, 'step', CheckoutStep.success)
              .having((s) => s.checkoutSessionId, 'sessionId', 'cs_test_123')
              .having((s) => s.orderId, 'orderId', 'order-456'),
        ],
      );

      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should succeed when no prior sessionId exists (first call)',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) =>
            cubit.onPaymentSuccess('cs_test_123', orderId: 'order-456'),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.step, 'step', CheckoutStep.success)
              .having((s) => s.checkoutSessionId, 'sessionId', 'cs_test_123')
              .having((s) => s.orderId, 'orderId', 'order-456'),
        ],
      );

      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should fail when sessionId does not match (security check)',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        seed: () => MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          step: CheckoutStep.processing,
          checkoutSessionId: 'cs_real_session_456',
        ),
        act: (cubit) =>
            cubit.onPaymentSuccess('cs_fake_tampered_123', orderId: 'order-456'),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.step, 'step', CheckoutStep.failed)
              .having((s) => s.errorMessage, 'error',
                  'Session ID mismatch - invalid callback'),
        ],
      );
    });

    group('onPaymentCancelled', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should reset to address entry step',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        seed: () => MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          step: CheckoutStep.processing,
          checkoutUrl: 'https://checkout.stripe.com/...',
          checkoutSessionId: 'cs_test_123',
        ),
        act: (cubit) => cubit.onPaymentCancelled(),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.step, 'step', CheckoutStep.addressEntry)
              .having((s) => s.checkoutUrl, 'checkoutUrl', isNull)
              .having((s) => s.checkoutSessionId, 'sessionId', isNull),
        ],
      );
    });

    group('onPaymentFailed', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should set state to failed with error',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        act: (cubit) => cubit.onPaymentFailed('Payment declined'),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.step, 'step', CheckoutStep.failed)
              .having((s) => s.errorMessage, 'error', 'Payment declined'),
        ],
      );
    });

    group('retryCheckout', () {
      blocTest<MagazineCheckoutCubit, MagazineCheckoutState>(
        'should reset from failed state',
        build: () => MagazineCheckoutCubit(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          supabaseClient: mockSupabase,
        ),
        seed: () => MagazineCheckoutState(
          weddingId: 'wedding-123',
          brideUserId: 'user-123',
          format: testFormat,
          photoCount: 25,
          weddingTitle: 'Wedding',
          address: ShippingAddress.empty(),
          step: CheckoutStep.failed,
          errorMessage: 'Payment failed',
          checkoutUrl: 'https://checkout.stripe.com/...',
        ),
        act: (cubit) => cubit.retryCheckout(),
        expect: () => [
          isA<MagazineCheckoutState>()
              .having((s) => s.step, 'step', CheckoutStep.addressEntry)
              .having((s) => s.errorMessage, 'error', isNull)
              .having((s) => s.checkoutUrl, 'url', isNull),
        ],
      );
    });
  });
}
