/// Tests for CreateGuestAccount use case.
///
/// Verifies guest account creation including:
/// - Successful account creation
/// - Email validation
/// - Password validation
/// - Invite code validation
/// - Error handling
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/guest_repository.dart';
import 'package:lynewed_beta/features/auth/domain/usecases/create_guest_account.dart';
import 'package:mocktail/mocktail.dart';

class MockGuestRepository extends Mock implements GuestRepository {}

void main() {
  group('CreateGuestAccount', () {
    late MockGuestRepository mockRepository;
    late CreateGuestAccount useCase;

    setUp(() {
      mockRepository = MockGuestRepository();
      useCase = CreateGuestAccount(mockRepository);
    });

    group('Input validation', () {
      test('should return InvalidEmailFormat for invalid email', () async {
        // Arrange
        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'invalid-email',
          password: 'SecurePass123!',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidEmailFormat>());
        verifyNever(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            ));
      });

      test('should return WeakPassword for password less than 6 chars',
          () async {
        // Arrange
        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre@example.com',
          password: '12345',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<WeakPassword>());
        verifyNever(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            ));
      });

      test('should return InvalidInviteCodeError for code not 8 chars',
          () async {
        // Arrange
        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre@example.com',
          password: 'SecurePass123!',
          inviteCode: 'ABC123', // Only 6 chars
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidInviteCodeError>());
        verifyNever(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            ));
      });

      test('should accept valid email formats', () async {
        // Arrange
        when(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            )).thenAnswer((_) async => Success(AuthUser(
              id: 'user-123',
              email: 'pierre@example.com',
              createdAt: DateTime(2026, 1, 30),
            )));

        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre.dupont@example.co.uk',
          password: 'SecurePass123!',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<GuestAccountCreated>());
      });
    });

    group('Successful account creation', () {
      test('should return GuestAccountCreated when repository succeeds',
          () async {
        // Arrange
        final testUser = AuthUser(
          id: 'user-123',
          email: 'pierre@example.com',
          createdAt: DateTime(2026, 1, 30),
        );

        when(() => mockRepository.signUpGuest(
              email: 'pierre@example.com',
              password: 'SecurePass123!',
              firstName: 'Pierre',
              inviteCode: 'ABCD1234',
            )).thenAnswer((_) async => Success(testUser));

        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre@example.com',
          password: 'SecurePass123!',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<GuestAccountCreated>());
        expect((result as GuestAccountCreated).user.id, 'user-123');
        verify(() => mockRepository.signUpGuest(
              email: 'pierre@example.com',
              password: 'SecurePass123!',
              firstName: 'Pierre',
              inviteCode: 'ABCD1234',
            )).called(1);
      });
    });

    group('Error handling', () {
      test('should return EmailAlreadyExists for duplicate email', () async {
        // Arrange
        when(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            )).thenAnswer(
            (_) async => const Failure(AuthFailure('Cet email est déjà utilisé')));

        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre@example.com',
          password: 'SecurePass123!',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<EmailAlreadyExists>());
      });

      test('should return InvalidInviteCodeError for invalid code from server',
          () async {
        // Arrange
        when(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            )).thenAnswer(
            (_) async => const Failure(AuthFailure('invalid_code')));

        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre@example.com',
          password: 'SecurePass123!',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidInviteCodeError>());
      });

      test('should return CreateGuestAccountError for unknown errors',
          () async {
        // Arrange
        when(() => mockRepository.signUpGuest(
              email: any(named: 'email'),
              password: any(named: 'password'),
              firstName: any(named: 'firstName'),
              inviteCode: any(named: 'inviteCode'),
            )).thenAnswer(
            (_) async => const Failure(UnknownFailure('Network error')));

        const params = CreateGuestAccountParams(
          firstName: 'Pierre',
          email: 'pierre@example.com',
          password: 'SecurePass123!',
          inviteCode: 'ABCD1234',
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<CreateGuestAccountError>());
        expect((result as CreateGuestAccountError).message, 'Network error');
      });
    });
  });
}
