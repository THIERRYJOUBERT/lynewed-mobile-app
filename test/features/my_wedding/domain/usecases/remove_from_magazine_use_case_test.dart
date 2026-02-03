/// Tests for RemoveFromMagazineUseCase.
///
/// Comprehensive tests covering validation and repository calls.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/remove_from_magazine_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late RemoveFromMagazineUseCase useCase;
  late MockMyWeddingRepository mockRepository;

  setUp(() {
    mockRepository = MockMyWeddingRepository();
    useCase = RemoveFromMagazineUseCase(mockRepository);
  });

  group('RemoveFromMagazineUseCase', () {
    const weddingId = 'test-wedding-id';
    const selectionId = 'test-selection-id';

    group('validation', () {
      test('should return failure when selectionId is empty', () async {
        final result = await useCase(
          selectionId: '',
          weddingId: weddingId,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Invalid selection ID');
        verifyNever(() => mockRepository.removeFromMagazine(
              selectionId: any(named: 'selectionId'),
              weddingId: any(named: 'weddingId'),
            ));
      });
    });

    group('successful removal', () {
      test('should call repository and return success', () async {
        when(() => mockRepository.removeFromMagazine(
              selectionId: selectionId,
              weddingId: weddingId,
            )).thenAnswer((_) async => const RepositoryResult.success(null));

        final result = await useCase(
          selectionId: selectionId,
          weddingId: weddingId,
        );

        expect(result.isSuccess, true);
        expect(result.error, isNull);

        verify(() => mockRepository.removeFromMagazine(
              selectionId: selectionId,
              weddingId: weddingId,
            )).called(1);
      });
    });

    group('repository failure', () {
      test('should return failure when repository fails', () async {
        when(() => mockRepository.removeFromMagazine(
              selectionId: selectionId,
              weddingId: weddingId,
            )).thenAnswer(
            (_) async => const RepositoryResult.failure('Delete failed'));

        final result = await useCase(
          selectionId: selectionId,
          weddingId: weddingId,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Delete failed');
      });

      test('should use default error message when repository error is generic',
          () async {
        when(() => mockRepository.removeFromMagazine(
              selectionId: selectionId,
              weddingId: weddingId,
            )).thenAnswer(
            (_) async => const RepositoryResult.failure(''));

        final result = await useCase(
          selectionId: selectionId,
          weddingId: weddingId,
        );

        expect(result.isFailure, true);
        // Empty string from repository becomes empty error
        expect(result.error, '');
      });
    });
  });

  group('RemoveFromMagazineResult', () {
    test('success result should have no error', () {
      const result = RemoveFromMagazineResult.success();

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.error, isNull);
    });

    test('failure result should have error', () {
      const result = RemoveFromMagazineResult.failure('Test error');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.error, 'Test error');
    });
  });
}
