/// Tests for ToggleFavoriteUseCase
///
/// Tests toggling favorite status for single and multiple media items.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/toggle_favorite_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMediaActionsDataSource extends Mock
    implements MediaActionsDataSource {}

void main() {
  late ToggleFavoriteUseCase useCase;
  late MockMediaActionsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMediaActionsDataSource();
    useCase = ToggleFavoriteUseCase(mockDataSource);
  });

  group('ToggleFavoriteUseCase', () {
    group('toggleSingle', () {
      const testMediaId = 'media-123';
      const testMediaType = 'photo';

      test('should add to favorites when not favorited', () async {
        // Arrange
        when(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.toggleSingle(
          mediaId: testMediaId,
          mediaType: testMediaType,
          currentlyFavorited: false,
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.addToFavorites(
              mediaId: testMediaId,
              mediaType: testMediaType,
            )).called(1);
        verifyNever(() => mockDataSource.removeFromFavorites(
              mediaId: any(named: 'mediaId'),
            ));
      });

      test('should remove from favorites when already favorited', () async {
        // Arrange
        when(() => mockDataSource.removeFromFavorites(
              mediaId: any(named: 'mediaId'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.toggleSingle(
          mediaId: testMediaId,
          mediaType: testMediaType,
          currentlyFavorited: true,
        );

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.removeFromFavorites(
              mediaId: testMediaId,
            )).called(1);
        verifyNever(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            ));
      });

      test('should return Failure when add to favorites fails', () async {
        // Arrange
        when(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            )).thenAnswer(
            (_) async => Failure(const ServerFailure('Failed to add favorite')));

        // Act
        final result = await useCase.toggleSingle(
          mediaId: testMediaId,
          mediaType: testMediaType,
          currentlyFavorited: false,
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Failed to add favorite');
      });

      test('should return Failure when remove from favorites fails', () async {
        // Arrange
        when(() => mockDataSource.removeFromFavorites(
              mediaId: any(named: 'mediaId'),
            )).thenAnswer((_) async =>
            Failure(const ServerFailure('Failed to remove favorite')));

        // Act
        final result = await useCase.toggleSingle(
          mediaId: testMediaId,
          mediaType: testMediaType,
          currentlyFavorited: true,
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Failed to remove favorite');
      });
    });

    group('addMultiple', () {
      final testMediaIds = ['media-1', 'media-2', 'media-3'];
      const testMediaType = 'photo';

      test('should add all media to favorites', () async {
        // Arrange
        when(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.addMultiple(
          mediaIds: testMediaIds,
          mediaType: testMediaType,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 3);
        verify(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: testMediaType,
            )).called(3);
      });

      test('should return count of successfully added favorites', () async {
        // Arrange - second call fails
        var callCount = 0;
        when(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 2) {
            return Failure(const ServerFailure('Failed'));
          }
          return const Success(null);
        });

        // Act
        final result = await useCase.addMultiple(
          mediaIds: testMediaIds,
          mediaType: testMediaType,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 2); // 2 succeeded, 1 failed
      });

      test('should return 0 when all fail', () async {
        // Arrange
        when(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            )).thenAnswer(
            (_) async => Failure(const ServerFailure('Failed')));

        // Act
        final result = await useCase.addMultiple(
          mediaIds: testMediaIds,
          mediaType: testMediaType,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 0);
      });

      test('should handle empty list', () async {
        // Act
        final result = await useCase.addMultiple(
          mediaIds: [],
          mediaType: testMediaType,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 0);
        verifyNever(() => mockDataSource.addToFavorites(
              mediaId: any(named: 'mediaId'),
              mediaType: any(named: 'mediaType'),
            ));
      });
    });

    group('removeMultiple', () {
      final testMediaIds = ['media-1', 'media-2'];

      test('should remove all media from favorites', () async {
        // Arrange
        when(() => mockDataSource.removeFromFavorites(
              mediaId: any(named: 'mediaId'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.removeMultiple(mediaIds: testMediaIds);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 2);
      });
    });
  });
}
