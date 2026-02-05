/// Tests for StripeConnectRepositoryImpl.
///
/// Verifies repository delegates to datasource and existing StripeRepository.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/datasources/stripe_connect_datasource.dart';
import 'package:lynewed_beta/features/marketplace/data/repositories/stripe_connect_repository_impl.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/stripe_connect_repository.dart';
import 'package:lynewed_beta/features/payments/domain/entities/stripe_account.dart';
import 'package:lynewed_beta/features/payments/domain/repositories/stripe_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStripeConnectDatasource extends Mock
    implements StripeConnectDatasource {}

class MockStripeRepository extends Mock implements StripeRepository {}

void main() {
  group('StripeConnectRepositoryImpl', () {
    late MockStripeConnectDatasource mockDatasource;
    late MockStripeRepository mockStripeRepository;
    late StripeConnectRepositoryImpl repository;

    setUp(() {
      mockDatasource = MockStripeConnectDatasource();
      mockStripeRepository = MockStripeRepository();
      repository = StripeConnectRepositoryImpl(
        datasource: mockDatasource,
        stripeRepository: mockStripeRepository,
      );
    });

    test('should implement StripeConnectRepository', () {
      expect(repository, isA<StripeConnectRepository>());
    });

    group('createConnectAccount', () {
      const userId = 'user-123';
      const email = 'seller@test.com';
      const returnUrl = 'lynewed://stripe-connect-return?success=true';
      const refreshUrl =
          'lynewed://stripe-connect-return?error=refresh_required';

      test('should delegate to datasource', () async {
        when(
          () => mockDatasource.createStripeConnectAccount(
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

        final result = await repository.createConnectAccount(
          userId: userId,
          email: email,
          returnUrl: returnUrl,
          refreshUrl: refreshUrl,
        );

        verify(
          () => mockDatasource.createStripeConnectAccount(
            userId: userId,
            email: email,
            returnUrl: returnUrl,
            refreshUrl: refreshUrl,
          ),
        ).called(1);

        expect(result['url'], 'https://connect.stripe.com/test');
        expect(result['stripe_account_id'], 'acct_test123');
      });

      test('should propagate datasource exceptions', () async {
        when(
          () => mockDatasource.createStripeConnectAccount(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            returnUrl: any(named: 'returnUrl'),
            refreshUrl: any(named: 'refreshUrl'),
          ),
        ).thenThrow(Exception('Edge Function failed'));

        expect(
          () => repository.createConnectAccount(
            userId: userId,
            email: email,
            returnUrl: returnUrl,
            refreshUrl: refreshUrl,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getStripeAccount', () {
      test('should delegate to existing StripeRepository', () async {
        final account = StripeAccount(
          userId: 'user-123',
          stripeAccountId: 'acct_123',
          onboardingComplete: true,
          chargesEnabled: true,
          payoutsEnabled: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockStripeRepository.getStripeAccount('user-123'))
            .thenAnswer((_) async => account);

        final result = await repository.getStripeAccount('user-123');

        verify(() => mockStripeRepository.getStripeAccount('user-123'))
            .called(1);
        expect(result, account);
      });

      test('should return null when no account exists', () async {
        when(() => mockStripeRepository.getStripeAccount('user-999'))
            .thenAnswer((_) async => null);

        final result = await repository.getStripeAccount('user-999');

        expect(result, isNull);
      });
    });

    group('isSellerReady', () {
      test('should return true when charges_enabled is true', () async {
        final account = StripeAccount(
          userId: 'user-123',
          stripeAccountId: 'acct_123',
          chargesEnabled: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockStripeRepository.getStripeAccount('user-123'))
            .thenAnswer((_) async => account);

        final result = await repository.isSellerReady('user-123');

        expect(result, true);
      });

      test('should return false when charges_enabled is false', () async {
        final account = StripeAccount(
          userId: 'user-123',
          stripeAccountId: 'acct_123',
          chargesEnabled: false,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(() => mockStripeRepository.getStripeAccount('user-123'))
            .thenAnswer((_) async => account);

        final result = await repository.isSellerReady('user-123');

        expect(result, false);
      });

      test('should return false when no account exists', () async {
        when(() => mockStripeRepository.getStripeAccount('user-999'))
            .thenAnswer((_) async => null);

        final result = await repository.isSellerReady('user-999');

        expect(result, false);
      });
    });
  });
}
