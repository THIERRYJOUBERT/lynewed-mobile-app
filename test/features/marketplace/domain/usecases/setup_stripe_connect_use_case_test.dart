/// Tests for SetupStripeConnectUseCase.
///
/// Verifies the use case delegates to the repository and returns
/// the onboarding URL for Stripe Connect setup.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/stripe_connect_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/usecases/setup_stripe_connect_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockStripeConnectRepository extends Mock
    implements StripeConnectRepository {}

void main() {
  group('SetupStripeConnectUseCase', () {
    late MockStripeConnectRepository mockRepository;
    late SetupStripeConnectUseCase useCase;

    setUp(() {
      mockRepository = MockStripeConnectRepository();
      useCase = SetupStripeConnectUseCase(mockRepository);
    });

    const userId = 'user-123';
    const email = 'seller@test.com';
    const returnUrl = 'lynewed://stripe-connect-return?success=true';
    const refreshUrl = 'lynewed://stripe-connect-return?error=refresh_required';

    test('should call repository with correct parameters', () async {
      when(
        () => mockRepository.createConnectAccount(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          returnUrl: any(named: 'returnUrl'),
          refreshUrl: any(named: 'refreshUrl'),
        ),
      ).thenAnswer(
        (_) async => {
          'url': 'https://connect.stripe.com/test',
          'stripe_account_id': 'acct_test123',
        },
      );

      final result = await useCase(
        userId: userId,
        email: email,
        returnUrl: returnUrl,
        refreshUrl: refreshUrl,
      );

      verify(
        () => mockRepository.createConnectAccount(
          userId: userId,
          email: email,
          returnUrl: returnUrl,
          refreshUrl: refreshUrl,
        ),
      ).called(1);

      expect(result['url'], 'https://connect.stripe.com/test');
      expect(result['stripe_account_id'], 'acct_test123');
    });

    test('should propagate repository exceptions', () async {
      when(
        () => mockRepository.createConnectAccount(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          returnUrl: any(named: 'returnUrl'),
          refreshUrl: any(named: 'refreshUrl'),
        ),
      ).thenThrow(Exception('Stripe API error'));

      expect(
        () => useCase(
          userId: userId,
          email: email,
          returnUrl: returnUrl,
          refreshUrl: refreshUrl,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
