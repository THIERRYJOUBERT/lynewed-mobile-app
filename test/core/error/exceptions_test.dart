import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/exceptions.dart';

void main() {
  group('AppException', () {
    test('ServerException should store message and optional statusCode', () {
      final exception = ServerException('Internal server error', statusCode: 500);

      expect(exception.message, 'Internal server error');
      expect(exception.statusCode, 500);
    });

    test('ServerException without statusCode should have null statusCode', () {
      final exception = ServerException('Server error');

      expect(exception.message, 'Server error');
      expect(exception.statusCode, isNull);
    });

    test('CacheException should store message', () {
      final exception = CacheException('Cache read failed');

      expect(exception.message, 'Cache read failed');
    });

    test('NetworkException should store message', () {
      final exception = NetworkException('No internet connection');

      expect(exception.message, 'No internet connection');
    });

    test('ValidationException should store message and optional field', () {
      final exception = ValidationException('Invalid email', field: 'email');

      expect(exception.message, 'Invalid email');
      expect(exception.field, 'email');
    });

    test('ValidationException without field should have null field', () {
      final exception = ValidationException('Invalid input');

      expect(exception.message, 'Invalid input');
      expect(exception.field, isNull);
    });

    test('AuthException should store message', () {
      final exception = AuthException('Session expired');

      expect(exception.message, 'Session expired');
    });

    test('all exceptions should implement Exception', () {
      final serverException = ServerException('test');
      final cacheException = CacheException('test');
      final networkException = NetworkException('test');
      final validationException = ValidationException('test');
      final authException = AuthException('test');

      expect(serverException, isA<Exception>());
      expect(cacheException, isA<Exception>());
      expect(networkException, isA<Exception>());
      expect(validationException, isA<Exception>());
      expect(authException, isA<Exception>());
    });

    test('toString should include class name and message', () {
      final exception = ServerException('Test error', statusCode: 404);

      expect(exception.toString(), contains('ServerException'));
      expect(exception.toString(), contains('Test error'));
    });
  });
}
