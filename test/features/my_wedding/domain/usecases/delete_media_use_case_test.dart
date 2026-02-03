/// Tests for DeleteMediaUseCase
///
/// Tests soft-deleting single and multiple media items.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/delete_media_use_case.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/toggle_favorite_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMediaActionsDataSource extends Mock
    implements MediaActionsDataSource {}

void main() {
  late DeleteMediaUseCase useCase;
  late MockMediaActionsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMediaActionsDataSource();
    useCase = DeleteMediaUseCase(mockDataSource);
  });

  group('DeleteMediaUseCase', () {
    group('deleteSingle', () {
      const testMediaId = 'media-123';

      test('should soft delete media', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.deleteSingle(mediaId: testMediaId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: testMediaId,
              status: 'deleted_by_bride',
            )).called(1);
      });

      test('should return Failure when delete fails', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async =>
            Failure(const ServerFailure('Failed to delete media')));

        // Act
        final result = await useCase.deleteSingle(mediaId: testMediaId);

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Failed to delete media');
      });
    });

    group('deleteMultiple', () {
      final testMediaIds = ['media-1', 'media-2', 'media-3'];

      test('should soft delete all media', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.deleteMultiple(mediaIds: testMediaIds);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 3);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: 'deleted_by_bride',
            )).called(3);
      });

      test('should return count of successfully deleted media', () async {
        // Arrange - second call fails
        var callCount = 0;
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 2) {
            return Failure(const ServerFailure('Failed'));
          }
          return const Success(null);
        });

        // Act
        final result = await useCase.deleteMultiple(mediaIds: testMediaIds);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 2); // 2 succeeded, 1 failed
      });

      test('should handle empty list', () async {
        // Act
        final result = await useCase.deleteMultiple(mediaIds: []);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 0);
        verifyNever(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            ));
      });
    });

    group('restoreSingle', () {
      const testMediaId = 'media-123';

      test('should restore deleted media', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.restoreSingle(mediaId: testMediaId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: testMediaId,
              status: 'active',
            )).called(1);
      });
    });
  });
}
