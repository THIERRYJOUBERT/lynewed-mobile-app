import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import 'package:lynewed_beta/core/utils/typedefs.dart';

void main() {
  group('Typedefs', () {
    test('FutureResult should be a Future of Result', () async {
      FutureResult<int> futureResult = Future.value(const Success(42));

      final result = await futureResult;

      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isTrue);
    });

    test('FutureResult with failure', () async {
      FutureResult<int> futureResult =
          Future.value(const Failure(ServerFailure('Error')));

      final result = await futureResult;

      expect(result, isA<Result<int>>());
      expect(result.isFailure, isTrue);
    });

    test('FutureVoid should be a Future of void', () async {
      FutureVoid futureVoid = Future.value();

      // Should complete without error
      await expectLater(futureVoid, completes);
    });

    test('FutureBool should be a Future of bool', () async {
      FutureBool futureBool = Future.value(true);

      final result = await futureBool;

      expect(result, isTrue);
    });

    test('Json should be a Map<String, dynamic>', () {
      Json json = {'key': 'value', 'number': 42};

      expect(json['key'], 'value');
      expect(json['number'], 42);
    });

    test('JsonList should be a List<Map<String, dynamic>>', () {
      JsonList jsonList = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
      ];

      expect(jsonList.length, 2);
      expect(jsonList[0]['name'], 'Item 1');
    });
  });
}
