/// Tests for StripeConnectDatasource.
///
/// Verifies Edge Function invocation for Stripe Connect account creation.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/data/datasources/stripe_connect_datasource.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  group('SupabaseStripeConnectDatasource', () {
    late MockSupabaseClient mockSupabase;
    late MockFunctionsClient mockFunctions;
    late SupabaseStripeConnectDatasource datasource;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockFunctions = MockFunctionsClient();
      when(() => mockSupabase.functions).thenReturn(mockFunctions);
      datasource = SupabaseStripeConnectDatasource(mockSupabase);
    });

    test('should implement StripeConnectDatasource', () {
      expect(datasource, isA<StripeConnectDatasource>());
    });

    group('createStripeConnectAccount', () {
      const userId = 'user-123';
      const email = 'seller@test.com';
      const returnUrl = 'lynewed://stripe-connect-return?success=true';
      const refreshUrl =
          'lynewed://stripe-connect-return?error=refresh_required';

      test('should call Edge Function with correct parameters', () async {
        when(
          () => mockFunctions.invoke(
            'create-stripe-connect-account',
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            status: 200,
            data: jsonEncode({
              'url': 'https://connect.stripe.com/test',
              'stripe_account_id': 'acct_test123',
            }),
          ),
        );

        final result = await datasource.createStripeConnectAccount(
          userId: userId,
          email: email,
          returnUrl: returnUrl,
          refreshUrl: refreshUrl,
        );

        verify(
          () => mockFunctions.invoke(
            'create-stripe-connect-account',
            body: {
              'user_id': userId,
              'email': email,
              'return_url': returnUrl,
              'refresh_url': refreshUrl,
              'tos_accepted': false,
            },
          ),
        ).called(1);

        expect(result['url'], 'https://connect.stripe.com/test');
        expect(result['stripe_account_id'], 'acct_test123');
      });

      test('should throw exception when Edge Function returns error',
          () async {
        when(
          () => mockFunctions.invoke(
            'create-stripe-connect-account',
            body: any(named: 'body'),
          ),
        ).thenThrow(
          FunctionException(
            status: 500,
            details: null,
            reasonPhrase: 'Internal Server Error',
          ),
        );

        expect(
          () => datasource.createStripeConnectAccount(
            userId: userId,
            email: email,
            returnUrl: returnUrl,
            refreshUrl: refreshUrl,
          ),
          throwsA(isA<FunctionException>()),
        );
      });

      test('should throw exception when response has no url', () async {
        when(
          () => mockFunctions.invoke(
            'create-stripe-connect-account',
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            status: 200,
            data: jsonEncode({'error': 'something went wrong'}),
          ),
        );

        expect(
          () => datasource.createStripeConnectAccount(
            userId: userId,
            email: email,
            returnUrl: returnUrl,
            refreshUrl: refreshUrl,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
