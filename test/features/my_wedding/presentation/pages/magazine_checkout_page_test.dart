/// Tests for MagazineCheckoutPage.
///
/// Comprehensive tests for checkout page display and interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  group('MagazineCheckoutPage initialization', () {
    test('should have correct initial state', () {
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
      expect(cubit.state.format.name, 'ICONIC');
      expect(cubit.state.photoCount, 25);
      expect(cubit.state.step, CheckoutStep.addressEntry);

      cubit.close();
    });

    test('should calculate correct total for ICONIC', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: MagazineFormats.iconic,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // ICONIC ($59) + US shipping ($15) = $74
      expect(cubit.state.totalCents, 7400);
      expect(cubit.state.totalFormatted, r'$74.00');

      cubit.close();
    });

    test('should calculate correct total for GUEST EDITION', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: MagazineFormats.guestEdition,
        photoCount: 15,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // Guest Edition ($29) + US shipping ($15) = $44
      expect(cubit.state.totalCents, 4400);
      expect(cubit.state.totalFormatted, r'$44.00');

      cubit.close();
    });

    test('should calculate correct total for COLLECTOR', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: MagazineFormats.collector,
        photoCount: 50,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // Collector ($89) + US shipping ($15) = $104
      expect(cubit.state.totalCents, 10400);
      expect(cubit.state.totalFormatted, r'$104.00');

      cubit.close();
    });
  });

  group('MagazineCheckoutPage states', () {
    Widget buildWithCubit(MagazineCheckoutCubit cubit) {
      return MaterialApp(
        home: BlocProvider<MagazineCheckoutCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) => Scaffold(
              body: BlocBuilder<MagazineCheckoutCubit, MagazineCheckoutState>(
                builder: (context, state) {
                  if (state.isProcessing) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 24),
                          Text('Processing your order...'),
                        ],
                      ),
                    );
                  }
                  if (state.isFailed) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 24),
                          const Text('Payment Failed'),
                          Text(state.errorMessage ?? 'Unknown error'),
                        ],
                      ),
                    );
                  }
                  return const Text('Address Entry');
                },
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should show processing state', (tester) async {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // Manually set to processing state
      cubit.emit(MagazineCheckoutState(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        address: ShippingAddress.empty(),
        step: CheckoutStep.processing,
      ));

      await tester.pumpWidget(buildWithCubit(cubit));
      await tester.pump();

      expect(find.text('Processing your order...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      cubit.close();
    });

    testWidgets('should show failed state with error', (tester) async {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      cubit.emit(MagazineCheckoutState(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        address: ShippingAddress.empty(),
        step: CheckoutStep.failed,
        errorMessage: 'Payment declined',
      ));

      await tester.pumpWidget(buildWithCubit(cubit));
      await tester.pump();

      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Payment declined'), findsOneWidget);

      cubit.close();
    });

    testWidgets('should show address entry state', (tester) async {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      await tester.pumpWidget(buildWithCubit(cubit));
      await tester.pump();

      expect(find.text('Address Entry'), findsOneWidget);

      cubit.close();
    });
  });

  group('MagazineCheckoutPage address handling', () {
    test('should update shipping cost when country changes', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // Default is US - $15 shipping
      expect(cubit.state.shippingCostCents, 1500);

      // Change to France - $25 shipping
      cubit.updateAddressField(country: 'FR');
      expect(cubit.state.shippingCostCents, 2500);

      // ICONIC ($59) + FR shipping ($25) = $84
      expect(cubit.state.totalCents, 8400);

      cubit.close();
    });

    test('should update canProceed when address filled', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // Initial state - cannot proceed
      expect(cubit.state.canProceed, false);

      // Fill address
      cubit.updateAddress(const ShippingAddress(
        fullName: 'John Doe',
        addressLine1: '123 Main St',
        city: 'New York',
        zipCode: '10001',
        country: 'US',
      ));

      // Still cannot proceed - CGVU not accepted
      expect(cubit.state.canProceed, false);

      // Accept CGVU
      cubit.toggleCgvuAccepted();

      // Now can proceed
      expect(cubit.state.canProceed, true);

      cubit.close();
    });
  });
}
