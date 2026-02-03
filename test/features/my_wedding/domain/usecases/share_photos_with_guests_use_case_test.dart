/// Tests for SharePhotosWithGuestsUseCase
///
/// Tests sharing photos/videos with wedding guests.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/share_photos_with_guests_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late SharePhotosWithGuestsUseCase useCase;
  late MockMyWeddingRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(<ShareMediaItem>[]);
  });

  setUp(() {
    mockRepository = MockMyWeddingRepository();
    useCase = SharePhotosWithGuestsUseCase(mockRepository);
  });

  group('SharePhotosWithGuestsUseCase', () {
    const testWeddingId = 'wedding-123';
    final testMediaItems = [
      const ShareMediaItem(mediaId: 'media-1', mediaType: 'album_image'),
      const ShareMediaItem(mediaId: 'media-2', mediaType: 'album_image'),
      const ShareMediaItem(mediaId: 'media-3', mediaType: 'guest_media'),
    ];

    test('should return count when sharing succeeds', () async {
      // Arrange
      when(() => mockRepository.sharePhotosWithGuests(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer((_) async => RepositoryResult.success(3));

      // Act
      final result = await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: testMediaItems,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, 3);
      verify(() => mockRepository.sharePhotosWithGuests(
            weddingId: testWeddingId,
            mediaItems: testMediaItems,
          )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      when(() => mockRepository.sharePhotosWithGuests(
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
      when(() => mockRepository.sharePhotosWithGuests(
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
        const ShareMediaItem(mediaId: 'single-media', mediaType: 'album_image'),
      ];

      when(() => mockRepository.sharePhotosWithGuests(
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

    test('should pass correct media types to repository', () async {
      // Arrange
      final mixedItems = [
        const ShareMediaItem(mediaId: 'm1', mediaType: 'album_image'),
        const ShareMediaItem(mediaId: 'm2', mediaType: 'guest_media'),
      ];

      when(() => mockRepository.sharePhotosWithGuests(
            weddingId: any(named: 'weddingId'),
            mediaItems: any(named: 'mediaItems'),
          )).thenAnswer((_) async => RepositoryResult.success(2));

      // Act
      await useCase.execute(
        weddingId: testWeddingId,
        mediaItems: mixedItems,
      );

      // Assert
      final captured = verify(() => mockRepository.sharePhotosWithGuests(
            weddingId: any(named: 'weddingId'),
            mediaItems: captureAny(named: 'mediaItems'),
          )).captured.single as List<ShareMediaItem>;

      expect(captured.length, 2);
      expect(captured[0].mediaType, 'album_image');
      expect(captured[1].mediaType, 'guest_media');
    });
  });
}
