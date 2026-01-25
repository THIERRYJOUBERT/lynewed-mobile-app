import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';

/// Tests that the barrel export correctly exposes all core functionality.
void main() {
  group('Core Barrel Export', () {
    tearDown(() async {
      await sl.reset();
    });

    group('Error classes', () {
      test('should export AppFailure and subclasses', () {
        // AppFailure
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

      test('should export AppException and subclasses', () {
        final serverException = ServerException('test');
        final cacheException = CacheException('test');
        final networkException = NetworkException('test');
        final validationException = ValidationException('test');
        final authException = AuthException('test');

        expect(serverException, isA<AppException>());
        expect(cacheException, isA<AppException>());
        expect(networkException, isA<AppException>());
        expect(validationException, isA<AppException>());
        expect(authException, isA<AppException>());
      });
    });

    group('Result pattern', () {
      test('should export Result, Success, and Failure', () {
        const Result<int> success = Success(42);
        const Result<int> failure = Failure(ServerFailure('error'));

        expect(success, isA<Success<int>>());
        expect(failure, isA<Failure<int>>());
      });
    });

    group('Typedefs', () {
      test('should export FutureResult', () async {
        FutureResult<int> futureResult = Future.value(const Success(42));
        final result = await futureResult;
        expect(result.isSuccess, isTrue);
      });

      test('should export Json and JsonList', () {
        Json json = {'key': 'value'};
        JsonList jsonList = [
          {'id': 1}
        ];

        expect(json['key'], 'value');
        expect(jsonList.length, 1);
      });
    });

    group('Dependency injection', () {
      test('should export sl and initDependencies', () async {
        await initDependencies();
        expect(sl, isNotNull);
      });
    });
  });
}
