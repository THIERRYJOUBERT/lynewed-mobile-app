/// Tests for UpgradeToBride use case.
///
/// Verifies result types and failure handling.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/usecases/upgrade_to_bride.dart';

void main() {
  group('UpgradeToBride', () {
    group('Result types', () {
      test('UpgradeSuccessful should be a valid result', () {
        const result = UpgradeSuccessful();
        expect(result, isA<UpgradeToBrideResult>());
      });

      test('NotAGuest should be a valid result', () {
        const result = NotAGuest();
        expect(result, isA<UpgradeToBrideResult>());
      });

      test('UpgradeError should store message', () {
        const result = UpgradeError('Error message');
        expect(result, isA<UpgradeToBrideResult>());
        expect(result.message, 'Error message');
      });
    });
  });

  group('UpgradeFailure', () {
    test('should store message', () {
      const failure = UpgradeFailure(message: 'Test error');
      expect(failure.message, 'Test error');
    });
  });
}
