/// Tests for UnsharePhotosUseCase
///
/// Tests unsharing photos/videos from wedding guests.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/unshare_photos_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late UnsharePhotosUseCase useCase;
  late MockMyWeddingRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(<ShareMediaItem>[]);
  });

  setUp(() {
    mockRepository = MockMyWeddingRepository();
    useCase = UnsharePhotosUseCase(mockRepository);
  });

  group('UnsharePhotosUseCase', () {
    const testWeddingId = 'wedding-123';
    final testMediaItems = [
      const ShareMediaItem(mediaId: 'media-1', mediaType: 'album_image'),
      const ShareMediaItem(mediaId: 'media-2', mediaType: 'album_image'),
    ];

    test('should return count when unsharing succeeds', () async {
      // Arrange
      when(() => mockRepository.unsharePhotos(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer((_) async => RepositoryResult.success(2));

      // Act
      final result = await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: testMediaItems,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 2);
      verify(() => mockRepository.unsharePhotos(
            weddingId: testWeddingId,
            mediaItems: testMediaItems,
          )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.unsharePhotos(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer(
          (_) async => RepositoryResult.failure('Database error'));

      // Act
      final result = await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: testMediaItems,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Database error');
    });

    test('should handle empty media list', () async {
      // Arrange
      when(() => mockRepository.unsharePhotos(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer((_) async => RepositoryResult.success(0));

      // Act
      final result = await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: [],
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 0);
    });

    test('should handle single media item', () async {
      // Arrange
      final singleItem = [
        const ShareMediaItem(mediaId: 'single-media', mediaType: 'guest_media'),
      ];

      when(() => mockRepository.unsharePhotos(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer((_) async => RepositoryResult.success(1));

      // Act
      final result = await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: singleItem,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 1);
    });

    test('should return 0 when media items were not shared', () async {
      // Arrange
      when(() => mockRepository.unsharePhotos(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer((_) async => RepositoryResult.success(0));

      // Act
      final result = await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: testMediaItems,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 0);
    });
  });
}
