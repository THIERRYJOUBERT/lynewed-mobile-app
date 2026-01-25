import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/di/injection_container.dart';

void main() {
  group('InjectionContainer', () {
    tearDown(() async {
      // Reset the service locator after each test
      await sl.reset();
    });

    test('sl should be accessible as GetIt instance', () {
      expect(sl, isNotNull);
    });

    test('init should complete without error', () async {
      await expectLater(initDependencies(), completes);
    });

    test('should be able to register and retrieve a simple dependency', () {
      // Register a test dependency
      sl.registerSingleton<String>('test_value');

      // Retrieve it
      final value = sl<String>();

      expect(value, 'test_value');
    });

    test('should be able to register lazy singleton', () {
      var instantiated = false;

      sl.registerLazySingleton<List<int>>(() {
        instantiated = true;
        return [1, 2, 3];
      });

      // Not instantiated yet
      expect(instantiated, isFalse);

      // Access it
      final list = sl<List<int>>();

      // Now instantiated
      expect(instantiated, isTrue);
      expect(list, [1, 2, 3]);
    });

    test('should be able to register factory', () {
      var callCount = 0;

      sl.registerFactory<int>(() {
        callCount++;
        return callCount;
      });

      // Each call creates a new instance
      expect(sl<int>(), 1);
      expect(sl<int>(), 2);
      expect(sl<int>(), 3);
    });

    test('reset should clear all registrations', () async {
      sl.registerSingleton<String>('test');

      await sl.reset();

      // After reset, the dependency should not be registered
      expect(sl.isRegistered<String>(), isFalse);
    });

    test('isRegistered should return correct value', () {
      expect(sl.isRegistered<String>(), isFalse);

      sl.registerSingleton<String>('test');

      expect(sl.isRegistered<String>(), isTrue);
    });
  });
}
