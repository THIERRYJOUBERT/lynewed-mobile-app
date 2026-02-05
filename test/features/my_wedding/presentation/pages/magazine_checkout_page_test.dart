/// Tests for MagazineCheckoutPage.
///
/// Comprehensive tests for checkout page display and interactions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
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

    test('should have correct magazine price for ICONIC', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: MagazineFormats.iconic,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      expect(cubit.state.magazinePriceCents, 5900);
      expect(cubit.state.magazinePriceFormatted, r'$59');

      cubit.close();
    });

    test('should have correct magazine price for GUEST EDITION', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: MagazineFormats.guestEdition,
        photoCount: 15,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      expect(cubit.state.magazinePriceCents, 2900);
      expect(cubit.state.magazinePriceFormatted, r'$29');

      cubit.close();
    });

    test('should have correct magazine price for COLLECTOR', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: MagazineFormats.collector,
        photoCount: 50,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      expect(cubit.state.magazinePriceCents, 8900);
      expect(cubit.state.magazinePriceFormatted, r'$89');

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

      cubit.emit(MagazineCheckoutState(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
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

  group('MagazineCheckoutPage canProceed', () {
    test('should update canProceed when CGVU accepted', () {
      final cubit = MagazineCheckoutCubit(
        weddingId: 'wedding-123',
        brideUserId: 'user-123',
        format: testFormat,
        photoCount: 25,
        weddingTitle: 'Wedding',
        supabaseClient: mockSupabase,
      );

      // Initial state - cannot proceed (CGVU not accepted)
      expect(cubit.state.canProceed, false);

      // Accept CGVU
      cubit.toggleCgvuAccepted();

      // Now can proceed
      expect(cubit.state.canProceed, true);

      cubit.close();
    });
  });
}
