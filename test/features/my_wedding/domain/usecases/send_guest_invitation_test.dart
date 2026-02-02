/// Tests for SendGuestInvitation use case.
///
/// Verifies invitation sending logic and error handling.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/send_guest_invitation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  group('SendGuestInvitation', () {
    late MockSupabaseClient mockSupabase;
    late MockFunctionsClient mockFunctions;
    late SendGuestInvitation useCase;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockFunctions = MockFunctionsClient();
      when(() => mockSupabase.functions).thenReturn(mockFunctions);
      useCase = SendGuestInvitation(supabase: mockSupabase);
    });

    group('Success cases', () {
      test('should return Success when invitation sent successfully', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              status: 200,
              data: {'success': true, 'email_id': 'email-123'},
            ));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Success>());
        verify(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: {
                'guest_id': 'guest-123',
                'wedding_id': 'wedding-456',
              },
            )).called(1);
      });
    });

    group('Error handling', () {
      test('should return Failure with invalid_email message', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              status: 400,
              data: {'error': 'invalid_email'},
            ));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Failure>());
        final failure = (result as Failure).failure as InvitationFailure;
        expect(failure.message, 'Invalid email address');
        expect(failure.code, 'invalid_email');
      });

      test('should return Failure with guest_not_found message', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              status: 404,
              data: {'error': 'guest_not_found'},
            ));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Failure>());
        final failure = (result as Failure).failure as InvitationFailure;
        expect(failure.message, 'Guest not found');
      });

      test('should return Failure with rate_limited message', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              status: 429,
              data: {'error': 'rate_limited'},
            ));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Failure>());
        final failure = (result as Failure).failure as InvitationFailure;
        expect(failure.message, 'Too many requests, please try again later');
      });

      test('should return generic error for unknown errors', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              status: 500,
              data: {'error': 'unknown_error'},
            ));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Failure>());
        final failure = (result as Failure).failure as InvitationFailure;
        expect(failure.message, 'Failed to send invitation');
      });

      test('should handle FunctionException', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenThrow(FunctionException(
          status: 500,
          details: null,
          reasonPhrase: 'Internal Server Error',
        ));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Failure>());
      });

      test('should handle unexpected exceptions', () async {
        when(() => mockFunctions.invoke(
              'send-wedding-invitation',
              body: any(named: 'body'),
            )).thenThrow(Exception('Network error'));

        final result = await useCase(const SendInvitationParams(
          guestId: 'guest-123',
          weddingId: 'wedding-456',
        ));

        expect(result, isA<Failure>());
        final failure = (result as Failure).failure as InvitationFailure;
        expect(failure.message, 'Failed to send invitation');
      });
    });
  });

  group('SendInvitationParams', () {
    test('should store guestId and weddingId', () {
      const params = SendInvitationParams(
        guestId: 'guest-123',
        weddingId: 'wedding-456',
      );

      expect(params.guestId, 'guest-123');
      expect(params.weddingId, 'wedding-456');
    });
  });

  group('InvitationFailure', () {
    test('should store message and code', () {
      const failure = InvitationFailure(
        message: 'Error message',
        code: 'error_code',
      );

      expect(failure.message, 'Error message');
      expect(failure.code, 'error_code');
    });

    test('should allow null code', () {
      const failure = InvitationFailure(message: 'Error message');

      expect(failure.message, 'Error message');
      expect(failure.code, isNull);
    });
  });
}
