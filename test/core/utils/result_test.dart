import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should store data', () {
        const result = Success<int>(42);

        expect(result.data, 42);
      });

      test('should be a Result type', () {
        const result = Success<String>('hello');

        expect(result, isA<Result<String>>());
      });

      test('isSuccess should return true', () {
        const result = Success<int>(42);

        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('getOrNull should return data', () {
        const result = Success<int>(42);

        expect(result.getOrNull(), 42);
      });

      test('getOrElse should return data, not default', () {
        const result = Success<int>(42);

        expect(result.getOrElse(0), 42);
      });

      test('failureOrNull should return null', () {
        const result = Success<int>(42);

        expect(result.failureOrNull(), isNull);
      });

      test('fold should call onSuccess', () {
        const result = Success<int>(42);

        final folded = result.fold(
          onSuccess: (data) => 'success: $data',
          onFailure: (failure) => 'failure: ${failure.message}',
        );

        expect(folded, 'success: 42');
      });

      test('map should transform data', () {
        const result = Success<int>(42);

        final mapped = result.map((data) => data.toString());

        expect(mapped, isA<Success<String>>());
        expect((mapped as Success<String>).data, '42');
      });
    });

    group('Failure', () {
      test('should store AppFailure', () {
        const failure = ServerFailure('Server error');
        const result = Failure<int>(failure);

        expect(result.failure, failure);
        expect(result.failure.message, 'Server error');
      });

      test('should be a Result type', () {
        const failure = CacheFailure('Cache miss');
        const result = Failure<String>(failure);

        expect(result, isA<Result<String>>());
      });

      test('isFailure should return true', () {
        const failure = NetworkFailure('No connection');
        const result = Failure<int>(failure);

        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('getOrNull should return null', () {
        const failure = ServerFailure('Error');
        const result = Failure<int>(failure);

        expect(result.getOrNull(), isNull);
      });

      test('getOrElse should return default value', () {
        const failure = ServerFailure('Error');
        const result = Failure<int>(failure);

        expect(result.getOrElse(0), 0);
      });

      test('failureOrNull should return the failure', () {
        const failure = ServerFailure('Error');
        const result = Failure<int>(failure);

        expect(result.failureOrNull(), failure);
      });

      test('fold should call onFailure', () {
        const failure = ValidationFailure('Invalid input');
        const result = Failure<int>(failure);

        final folded = result.fold(
          onSuccess: (data) => 'success: $data',
          onFailure: (f) => 'failure: ${f.message}',
        );

        expect(folded, 'failure: Invalid input');
      });

      test('map should not transform and keep failure', () {
        const failure = ServerFailure('Error');
        const result = Failure<int>(failure);

        final mapped = result.map((data) => data.toString());

        expect(mapped, isA<Failure<String>>());
        expect((mapped as Failure<String>).failure, failure);
      });
    });

    group('Pattern matching', () {
      test('switch expression should work with sealed class', () {
        Result<int> result = const Success(42);

        final message = switch (result) {
          Success<int>(:final data) => 'Got $data',
          Failure<int>(:final failure) => 'Error: ${failure.message}',
        };

        expect(message, 'Got 42');
      });

      test('switch expression with failure', () {
        Result<int> result = const Failure(ServerFailure('Oops'));

        final message = switch (result) {
          Success<int>(:final data) => 'Got $data',
          Failure<int>(:final failure) => 'Error: ${failure.message}',
        };

        expect(message, 'Error: Oops');
      });
    });
  });
}
