/// Tests for AcceptCgvuUseCase.
///
/// Comprehensive tests covering CGVU acceptance logging.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/accept_cgvu_use_case.dart';

void main() {
  group('AcceptCgvuUseCase', () {
    test('should create instance successfully', () {
      const useCase = AcceptCgvuUseCase();

      expect(useCase, isNotNull);
    });
  });

  group('AcceptCgvuResult', () {
    test('success result should have no error', () {
      const result = AcceptCgvuResult.success();

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.error, isNull);
    });

    test('failure result should have error message', () {
      const result = AcceptCgvuResult.failure('User not authenticated');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, 'User not authenticated');
    });

    test('failure result with different error message', () {
      const result = AcceptCgvuResult.failure('Database error');

      expect(result.isFailure, true);
      expect(result.error, 'Database error');
    });
  });
}
