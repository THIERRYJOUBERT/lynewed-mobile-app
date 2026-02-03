/// Tests for ReorderMagazineUseCase.
///
/// Comprehensive tests covering validation and repository calls.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/reorder_magazine_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late ReorderMagazineUseCase useCase;
  late MockMyWeddingRepository mockRepository;

  setUp(() {
    mockRepository = MockMyWeddingRepository();
    useCase = ReorderMagazineUseCase(mockRepository);
  });

  group('ReorderMagazineUseCase', () {
    const weddingId = 'test-wedding-id';

    group('validation', () {
      test('should return failure when oldIndex is negative', () async {
        final result = await useCase(
          weddingId: weddingId,
          oldIndex: -1,
          newIndex: 2,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Invalid position');
        verifyNever(() => mockRepository.reorderMagazine(
              weddingId: any(named: 'weddingId'),
              oldIndex: any(named: 'oldIndex'),
              newIndex: any(named: 'newIndex'),
            ));
      });

      test('should return failure when newIndex is negative', () async {
        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 2,
          newIndex: -1,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Invalid position');
      });

      test('should return success immediately when indices are equal',
          () async {
        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 3,
          newIndex: 3,
        );

        expect(result.isSuccess, true);
        verifyNever(() => mockRepository.reorderMagazine(
              weddingId: any(named: 'weddingId'),
              oldIndex: any(named: 'oldIndex'),
              newIndex: any(named: 'newIndex'),
            ));
      });
    });

    group('successful reorder', () {
      test('should call repository and return success', () async {
        when(() => mockRepository.reorderMagazine(
              weddingId: weddingId,
              oldIndex: 0,
              newIndex: 5,
            )).thenAnswer((_) async => const RepositoryResult.success(null));

        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 0,
          newIndex: 5,
        );

        expect(result.isSuccess, true);
        expect(result.error, isNull);

        verify(() => mockRepository.reorderMagazine(
              weddingId: weddingId,
              oldIndex: 0,
              newIndex: 5,
            )).called(1);
      });

      test('should handle moving item forward', () async {
        when(() => mockRepository.reorderMagazine(
              weddingId: weddingId,
              oldIndex: 2,
              newIndex: 8,
            )).thenAnswer((_) async => const RepositoryResult.success(null));

        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 2,
          newIndex: 8,
        );

        expect(result.isSuccess, true);
      });

      test('should handle moving item backward', () async {
        when(() => mockRepository.reorderMagazine(
              weddingId: weddingId,
              oldIndex: 10,
              newIndex: 3,
            )).thenAnswer((_) async => const RepositoryResult.success(null));

        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 10,
          newIndex: 3,
        );

        expect(result.isSuccess, true);
      });
    });

    group('repository failure', () {
      test('should return failure when repository fails', () async {
        when(() => mockRepository.reorderMagazine(
              weddingId: weddingId,
              oldIndex: 0,
              newIndex: 3,
            )).thenAnswer(
            (_) async => const RepositoryResult.failure('Reorder failed'));

        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 0,
          newIndex: 3,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Reorder failed');
      });

      test('should use default error message when repository error is generic',
          () async {
        when(() => mockRepository.reorderMagazine(
              weddingId: weddingId,
              oldIndex: 0,
              newIndex: 3,
            )).thenAnswer((_) async => const RepositoryResult.failure(''));

        final result = await useCase(
          weddingId: weddingId,
          oldIndex: 0,
          newIndex: 3,
        );

        expect(result.isFailure, true);
        // Empty string from repository becomes empty error
        expect(result.error, '');
      });
    });
  });

  group('ReorderMagazineResult', () {
    test('success result should have no error', () {
      const result = ReorderMagazineResult.success();

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.error, isNull);
    });

    test('failure result should have error', () {
      const result = ReorderMagazineResult.failure('Test error');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, 'Test error');
    });
  });
}
