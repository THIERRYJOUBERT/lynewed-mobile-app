/// Tests for HideMediaUseCase
///
/// Tests hiding/unhiding single and multiple media items.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/hide_media_use_case.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/toggle_favorite_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMediaActionsDataSource extends Mock
    implements MediaActionsDataSource {}

void main() {
  late HideMediaUseCase useCase;
  late MockMediaActionsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMediaActionsDataSource();
    useCase = HideMediaUseCase(mockDataSource);
  });

  group('HideMediaUseCase', () {
    group('hideSingle', () {
      const testMediaId = 'media-123';

      test('should hide media when not hidden', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.hideSingle(mediaId: testMediaId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: testMediaId,
              status: 'hidden_by_bride',
            )).called(1);
      });

      test('should return Failure when hide fails', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer(
            (_) async => Failure(const ServerFailure('Failed to hide media')));

        // Act
        final result = await useCase.hideSingle(mediaId: testMediaId);

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Failed to hide media');
      });
    });

    group('unhideSingle', () {
      const testMediaId = 'media-123';

      test('should unhide media when hidden', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.unhideSingle(mediaId: testMediaId);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: testMediaId,
              status: 'active',
            )).called(1);
      });
    });

    group('hideMultiple', () {
      final testMediaIds = ['media-1', 'media-2', 'media-3'];

      test('should hide all media', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.hideMultiple(mediaIds: testMediaIds);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 3);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: 'hidden_by_bride',
            )).called(3);
      });

      test('should return count of successfully hidden media', () async {
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
        final result = await useCase.hideMultiple(mediaIds: testMediaIds);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 2); // 2 succeeded, 1 failed
      });

      test('should handle empty list', () async {
        // Act
        final result = await useCase.hideMultiple(mediaIds: []);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 0);
        verifyNever(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            ));
      });
    });

    group('unhideMultiple', () {
      final testMediaIds = ['media-1', 'media-2'];

      test('should unhide all media', () async {
        // Arrange
        when(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => const Success(null));

        // Act
        final result = await useCase.unhideMultiple(mediaIds: testMediaIds);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), 2);
        verify(() => mockDataSource.updateMediaStatus(
              mediaId: any(named: 'mediaId'),
              status: 'active',
            )).called(2);
      });
    });
  });
}
