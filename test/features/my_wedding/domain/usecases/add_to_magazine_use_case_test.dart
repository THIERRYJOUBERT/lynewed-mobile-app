/// Tests for AddToMagazineUseCase.
///
/// Comprehensive tests covering validation, limit checks, and repository calls.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/add_to_magazine_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late AddToMagazineUseCase useCase;
  late MockMyWeddingRepository mockRepository;

  setUp(() {
    mockRepository = MockMyWeddingRepository();
    useCase = AddToMagazineUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const MagazineMediaItem(
      mediaType: 'album_image',
      mediaId: 'fallback-id',
    ));
  });

  group('AddToMagazineUseCase', () {
    const weddingId = 'test-wedding-id';
    const userId = 'test-user-id';

    group('validation', () {
      test('should return failure when media items list is empty', () async {
        final result = await useCase(
          weddingId: weddingId,
          userId: userId,
          mediaItems: [],
          currentCount: 0,
        );

        expect(result.isFailure, true);
        expect(result.error, 'No photos selected');
        verifyNever(() => mockRepository.addToMagazine(
              weddingId: any(named: 'weddingId'),
              userId: any(named: 'userId'),
              mediaItems: any(named: 'mediaItems'),
              maxPhotos: any(named: 'maxPhotos'),
            ));
      });

      test('should return failure when already at max photos', () async {
        final result = await useCase(
          weddingId: weddingId,
          userId: userId,
          mediaItems: [
            const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-1'),
          ],
          currentCount: 60, // Already at max
          maxPhotos: 60,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Maximum 60 photos per magazine');
        verifyNever(() => mockRepository.addToMagazine(
              weddingId: any(named: 'weddingId'),
              userId: any(named: 'userId'),
              mediaItems: any(named: 'mediaItems'),
              maxPhotos: any(named: 'maxPhotos'),
            ));
      });

      test('should return failure when adding would exceed max photos',
          () async {
        final result = await useCase(
          weddingId: weddingId,
          userId: userId,
          mediaItems: [
            const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-1'),
            const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-2'),
            const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-3'),
          ],
          currentCount: 58, // 58 + 3 = 61 > 60
          maxPhotos: 60,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Can only add 2 more photos (limit: 60)');
      });
    });

    group('successful addition', () {
      test('should call repository and return success with added count',
          () async {
        final mediaItems = [
          const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-1'),
          const MagazineMediaItem(mediaType: 'guest_media', mediaId: 'media-2'),
        ];

        when(() => mockRepository.addToMagazine(
              weddingId: weddingId,
              userId: userId,
              mediaItems: mediaItems,
              maxPhotos: 60,
            )).thenAnswer((_) async => const RepositoryResult.success(2));

        final result = await useCase(
          weddingId: weddingId,
          userId: userId,
          mediaItems: mediaItems,
          currentCount: 5,
        );

        expect(result.isSuccess, true);
        expect(result.addedCount, 2);

        verify(() => mockRepository.addToMagazine(
              weddingId: weddingId,
              userId: userId,
              mediaItems: mediaItems,
              maxPhotos: 60,
            )).called(1);
      });

      test('should use custom maxPhotos when provided', () async {
        const customMax = 30;
        final mediaItems = [
          const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-1'),
        ];

        when(() => mockRepository.addToMagazine(
              weddingId: weddingId,
              userId: userId,
              mediaItems: mediaItems,
              maxPhotos: customMax,
            )).thenAnswer((_) async => const RepositoryResult.success(1));

        final result = await useCase(
          weddingId: weddingId,
          userId: userId,
          mediaItems: mediaItems,
          currentCount: 0,
          maxPhotos: customMax,
        );

        expect(result.isSuccess, true);
        verify(() => mockRepository.addToMagazine(
              weddingId: weddingId,
              userId: userId,
              mediaItems: mediaItems,
              maxPhotos: customMax,
            )).called(1);
      });
    });

    group('repository failure', () {
      test('should return failure when repository fails', () async {
        final mediaItems = [
          const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-1'),
        ];

        when(() => mockRepository.addToMagazine(
              weddingId: weddingId,
              userId: userId,
              mediaItems: mediaItems,
              maxPhotos: 60,
            )).thenAnswer(
            (_) async => const RepositoryResult.failure('Database error'));

        final result = await useCase(
          weddingId: weddingId,
          userId: userId,
          mediaItems: mediaItems,
          currentCount: 0,
        );

        expect(result.isFailure, true);
        expect(result.error, 'Database error');
        expect(result.addedCount, 0);
      });
    });
  });

  group('AddToMagazineResult', () {
    test('success result should have addedCount and no error', () {
      const result = AddToMagazineResult.success(5);

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.addedCount, 5);
      expect(result.error, isNull);
    });

    test('failure result should have error and zero addedCount', () {
      const result = AddToMagazineResult.failure('Test error');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.addedCount, 0);
      expect(result.error, 'Test error');
    });
  });
}
