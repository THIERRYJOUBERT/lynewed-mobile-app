/// Tests for CheckStripeStatusUseCase.
///
/// Verifies the use case correctly checks whether a seller's Stripe
/// account is ready to receive payments.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/stripe_connect_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/check_stripe_status_use_case.dart';
import 'package:lynewed_beta/features/payments/domain/entities/stripe_account.dart';
import 'package:mocktail/mocktail.dart';

class MockStripeConnectRepository extends Mock
    implements StripeConnectRepository {}

void main() {
  group('CheckStripeStatusUseCase', () {
    late MockStripeConnectRepository mockRepository;
    late CheckStripeStatusUseCase useCase;

    setUp(() {
      mockRepository = MockStripeConnectRepository();
      useCase = CheckStripeStatusUseCase(mockRepository);
    });

    test('should return true when charges_enabled is true', () async {
      when(() => mockRepository.isSellerReady('user-123'))
          .thenAnswer((_) async => true);

      final result = await useCase('user-123');

      verify(() => mockRepository.isSellerReady('user-123')).called(1);
      expect(result, true);
    });

    test('should return false when charges_enabled is false', () async {
      when(() => mockRepository.isSellerReady('user-123'))
          .thenAnswer((_) async => false);

      final result = await useCase('user-123');

      expect(result, false);
    });

    test('should return StripeAccount when calling getAccount', () async {
      final account = StripeAccount(
        userId: 'user-123',
        stripeAccountId: 'acct_123',
        onboardingComplete: true,
        chargesEnabled: true,
        payoutsEnabled: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      when(() => mockRepository.getStripeAccount('user-123'))
          .thenAnswer((_) async => account);

      final result = await useCase.getAccount('user-123');

      verify(() => mockRepository.getStripeAccount('user-123')).called(1);
      expect(result, account);
    });

    test('should return null when no account exists', () async {
      when(() => mockRepository.getStripeAccount('user-999'))
          .thenAnswer((_) async => null);

      final result = await useCase.getAccount('user-999');

      expect(result, isNull);
    });
  });
}
