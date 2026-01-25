import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';

void main() {
  group('AppFailure', () {
    test('ServerFailure should store message and optional code', () {
      const failure = ServerFailure('Server error occurred', code: 'ERR_500');

      expect(failure.message, 'Server error occurred');
      expect(failure.code, 'ERR_500');
    });

    test('ServerFailure without code should have null code', () {
      const failure = ServerFailure('Server error');

      expect(failure.message, 'Server error');
      expect(failure.code, isNull);
    });

    test('CacheFailure should store message and optional code', () {
      const failure = CacheFailure('Cache read failed');

      expect(failure.message, 'Cache read failed');
      expect(failure.code, isNull);
    });

    test('NetworkFailure should store message and optional code', () {
      const failure = NetworkFailure('No internet connection', code: 'NO_NETWORK');

      expect(failure.message, 'No internet connection');
      expect(failure.code, 'NO_NETWORK');
    });

    test('ValidationFailure should store message and optional code', () {
      const failure = ValidationFailure('Invalid input', code: 'VALIDATION_ERROR');

      expect(failure.message, 'Invalid input');
      expect(failure.code, 'VALIDATION_ERROR');
    });

    test('AuthFailure should store message and optional code', () {
      const failure = AuthFailure('Not authenticated', code: 'AUTH_REQUIRED');

      expect(failure.message, 'Not authenticated');
      expect(failure.code, 'AUTH_REQUIRED');
    });

    test('UnknownFailure should store message and optional code', () {
      const failure = UnknownFailure('Something went wrong');

      expect(failure.message, 'Something went wrong');
      expect(failure.code, isNull);
    });

    test('all failures should be subtypes of AppFailure', () {
      const serverFailure = ServerFailure('test');
      const cacheFailure = CacheFailure('test');
      const networkFailure = NetworkFailure('test');
      const validationFailure = ValidationFailure('test');
      const authFailure = AuthFailure('test');
      const unknownFailure = UnknownFailure('test');

      expect(serverFailure, isA<AppFailure>());
      expect(cacheFailure, isA<AppFailure>());
      expect(networkFailure, isA<AppFailure>());
      expect(validationFailure, isA<AppFailure>());
      expect(authFailure, isA<AppFailure>());
      expect(unknownFailure, isA<AppFailure>());
    });

    test('failures with same values should be equal (const)', () {
      const failure1 = ServerFailure('error', code: 'ERR');
      const failure2 = ServerFailure('error', code: 'ERR');

      expect(identical(failure1, failure2), isTrue);
    });
  });
}
