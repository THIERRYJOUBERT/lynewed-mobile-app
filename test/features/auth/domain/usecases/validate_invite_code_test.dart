/// Tests for ValidateInviteCode use case.
///
/// Verifies invitation code validation logic:
/// - Code format validation
/// - Repository delegation
/// - Result handling
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/invite_code_repository.dart';
import 'package:lynewed_beta/features/auth/domain/usecases/validate_invite_code.dart';
import 'package:mocktail/mocktail.dart';

class MockInviteCodeRepository extends Mock implements InviteCodeRepository {}

void main() {
  group('ValidateInviteCode', () {
    late MockInviteCodeRepository mockRepository;
    late ValidateInviteCode useCase;

    setUp(() {
      mockRepository = MockInviteCodeRepository();
      useCase = ValidateInviteCode(mockRepository);
    });

    group('Code format validation', () {
      test('should return InvalidInviteCode for empty code', () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: '');

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidInviteCode>());
        verifyNever(() => mockRepository.validateCode(any()));
      });

      test('should return InvalidInviteCode for code shorter than 8 chars',
          () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'ABC123');

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidInviteCode>());
        verifyNever(() => mockRepository.validateCode(any()));
      });

      test('should return InvalidInviteCode for code longer than 8 chars',
          () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'ABCD12345');

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidInviteCode>());
        verifyNever(() => mockRepository.validateCode(any()));
      });
    });

    group('Valid code format', () {
      test('should call repository for 8 character code', () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'ABCD1234');
        when(() => mockRepository.validateCode(any())).thenAnswer(
          (_) async => const ValidInviteCode(
            weddingId: 'wedding-123',
            brideName: 'Marie',
          ),
        );

        // Act
        await useCase(params);

        // Assert
        verify(() => mockRepository.validateCode('ABCD1234')).called(1);
      });

      test('should return ValidInviteCode when repository returns valid',
          () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'ABCD1234');
        when(() => mockRepository.validateCode(any())).thenAnswer(
          (_) async => const ValidInviteCode(
            weddingId: 'wedding-123',
            brideName: 'Marie',
            guestEmail: 'guest@example.com',
          ),
        );

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<ValidInviteCode>());
        final validResult = result as ValidInviteCode;
        expect(validResult.weddingId, 'wedding-123');
        expect(validResult.brideName, 'Marie');
        expect(validResult.guestEmail, 'guest@example.com');
      });

      test('should return InvalidInviteCode when repository returns invalid',
          () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'WXYZ5678');
        when(() => mockRepository.validateCode(any()))
            .thenAnswer((_) async => const InvalidInviteCode());

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InvalidInviteCode>());
      });

      test('should return RateLimitedInviteCode when repository returns limited',
          () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'TEST1234');
        when(() => mockRepository.validateCode(any()))
            .thenAnswer((_) async => const RateLimitedInviteCode());

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<RateLimitedInviteCode>());
      });
    });

    group('Error handling', () {
      test('should return InviteCodeError when repository throws', () async {
        // Arrange
        const params = ValidateInviteCodeParams(code: 'ABCD1234');
        when(() => mockRepository.validateCode(any()))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result, isA<InviteCodeError>());
        final errorResult = result as InviteCodeError;
        expect(errorResult.message, contains('Network error'));
      });
    });
  });

  group('ValidateInviteCodeResult', () {
    test('ValidInviteCode should contain required fields', () {
      const result = ValidInviteCode(
        weddingId: 'wedding-123',
        brideName: 'Marie',
      );

      expect(result.weddingId, 'wedding-123');
      expect(result.brideName, 'Marie');
      expect(result.guestEmail, isNull);
    });

    test('ValidInviteCode should contain optional guestEmail', () {
      const result = ValidInviteCode(
        weddingId: 'wedding-123',
        brideName: 'Marie',
        guestEmail: 'guest@example.com',
      );

      expect(result.guestEmail, 'guest@example.com');
    });

    test('InviteCodeError should contain message', () {
      const result = InviteCodeError('Something went wrong');

      expect(result.message, 'Something went wrong');
    });
  });
}
