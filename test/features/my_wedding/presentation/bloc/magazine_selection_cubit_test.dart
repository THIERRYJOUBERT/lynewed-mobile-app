/// Tests for MagazineSelectionCubit.
///
/// Comprehensive tests covering loading, adding, removing, reordering,
/// and clearing magazine selections.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_selection.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  late MockMyWeddingRepository mockRepository;

  const testWeddingId = 'test-wedding-id';
  const testUserId = 'test-user-id';

  setUp(() {
    mockRepository = MockMyWeddingRepository();
  });

  setUpAll(() {
    registerFallbackValue(const MagazineMediaItem(
      mediaType: 'album_image',
      mediaId: 'fallback-id',
    ));
  });

  MagazineSelectionCubit createCubit() {
    return MagazineSelectionCubit(
      weddingId: testWeddingId,
      userId: testUserId,
      repository: mockRepository,
      getThumbnailUrl: (mediaType, mediaId) async => 'https://thumb.com/$mediaId',
    );
  }

  group('MagazineSelectionCubit', () {
    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = createCubit();

        expect(cubit.state.photos, isEmpty);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.isReordering, false);
        expect(cubit.state.errorMessage, isNull);
        expect(cubit.state.successMessage, isNull);

        cubit.close();
      });
    });

    group('loadSelections', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should emit loading then success with photos',
        build: () {
          when(() => mockRepository.getMagazineSelections(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success([
                    MagazineSelection(
                      id: 'sel-1',
                      weddingId: testWeddingId,
                      userId: testUserId,
                      mediaType: 'album_image',
                      mediaId: 'img-1',
                      position: 1,
                      createdAt: DateTime(2026, 2, 1),
                    ),
                  ]));
          return createCubit();
        },
        act: (cubit) => cubit.loadSelections(),
        expect: () => [
          // Loading state
          isA<MagazineSelectionState>().having((s) => s.isLoading, 'isLoading', true),
          // Loaded state
          isA<MagazineSelectionState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.photos.length, 'photos.length', 1)
              .having((s) => s.photos.first.selectionId, 'first.selectionId', 'sel-1'),
        ],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should emit error state when repository fails',
        build: () {
          when(() => mockRepository.getMagazineSelections(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.failure('Load failed'));
          return createCubit();
        },
        act: (cubit) => cubit.loadSelections(),
        expect: () => [
          isA<MagazineSelectionState>().having((s) => s.isLoading, 'isLoading', true),
          isA<MagazineSelectionState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.errorMessage, 'errorMessage', 'Load failed'),
        ],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should handle empty selection list',
        build: () {
          when(() => mockRepository.getMagazineSelections(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return createCubit();
        },
        act: (cubit) => cubit.loadSelections(),
        expect: () => [
          isA<MagazineSelectionState>().having((s) => s.isLoading, 'isLoading', true),
          isA<MagazineSelectionState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.photos, 'photos', isEmpty),
        ],
      );
    });

    group('addPhotos', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should add photos and show success message',
        build: () {
          when(() => mockRepository.addToMagazine(
                weddingId: testWeddingId,
                userId: testUserId,
                mediaItems: any(named: 'mediaItems'),
                maxPhotos: 60,
              )).thenAnswer((_) async => const RepositoryResult.success(2));

          when(() => mockRepository.getMagazineSelections(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success([
                    MagazineSelection(
                      id: 'sel-1',
                      weddingId: testWeddingId,
                      userId: testUserId,
                      mediaType: 'album_image',
                      mediaId: 'img-1',
                      position: 1,
                      createdAt: DateTime(2026, 2, 1),
                    ),
                    MagazineSelection(
                      id: 'sel-2',
                      weddingId: testWeddingId,
                      userId: testUserId,
                      mediaType: 'album_image',
                      mediaId: 'img-2',
                      position: 2,
                      createdAt: DateTime(2026, 2, 1),
                    ),
                  ]));

          return createCubit();
        },
        act: (cubit) => cubit.addPhotos([
          const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-1'),
          const MagazineMediaItem(mediaType: 'album_image', mediaId: 'img-2'),
        ]),
        verify: (_) {
          verify(() => mockRepository.addToMagazine(
                weddingId: testWeddingId,
                userId: testUserId,
                mediaItems: any(named: 'mediaItems'),
                maxPhotos: 60,
              )).called(1);
        },
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should emit error when exceeding max photos',
        build: () => createCubit(),
        seed: () => MagazineSelectionState(
          photos: List.generate(
            60,
            (i) => MagazinePhoto(
              selectionId: 'sel-$i',
              mediaType: 'album_image',
              mediaId: 'img-$i',
              position: i + 1,
              thumbnailUrl: 'https://thumb.com/$i',
            ),
          ),
        ),
        act: (cubit) => cubit.addPhotos([
          const MagazineMediaItem(mediaType: 'album_image', mediaId: 'new-img'),
        ]),
        expect: () => [
          isA<MagazineSelectionState>()
              .having((s) => s.errorMessage, 'errorMessage', 'Maximum 60 photos per magazine'),
        ],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should return true when adding empty list',
        build: () => createCubit(),
        act: (cubit) async {
          final result = await cubit.addPhotos([]);
          expect(result, true);
        },
        expect: () => [],
      );
    });

    group('removePhoto', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should remove photo optimistically and show success',
        build: () {
          when(() => mockRepository.removeFromMagazine(
                selectionId: 'sel-1',
                weddingId: testWeddingId,
              )).thenAnswer((_) async => const RepositoryResult.success(null));

          return createCubit();
        },
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
            MagazinePhoto(
              selectionId: 'sel-2',
              mediaType: 'album_image',
              mediaId: 'img-2',
              position: 2,
              thumbnailUrl: 'https://thumb.com/2',
            ),
          ],
        ),
        act: (cubit) => cubit.removePhoto('sel-1'),
        expect: () => [
          // Optimistic removal
          isA<MagazineSelectionState>()
              .having((s) => s.photos.length, 'photos.length', 1)
              .having((s) => s.photos.first.selectionId, 'remaining.selectionId', 'sel-2')
              .having((s) => s.photos.first.position, 'remaining.position', 1),
          // Success message
          isA<MagazineSelectionState>()
              .having((s) => s.successMessage, 'successMessage', 'Photo removed from magazine'),
        ],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should revert removal on repository failure',
        build: () {
          when(() => mockRepository.removeFromMagazine(
                selectionId: 'sel-1',
                weddingId: testWeddingId,
              )).thenAnswer((_) async => const RepositoryResult.failure('Delete failed'));

          return createCubit();
        },
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
          ],
        ),
        act: (cubit) => cubit.removePhoto('sel-1'),
        expect: () => [
          // Optimistic removal
          isA<MagazineSelectionState>().having((s) => s.photos, 'photos', isEmpty),
          // Revert with error
          isA<MagazineSelectionState>()
              .having((s) => s.photos.length, 'photos.length', 1)
              .having((s) => s.errorMessage, 'errorMessage', 'Delete failed'),
        ],
      );
    });

    group('reorderPhoto', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should reorder photos optimistically',
        build: () {
          when(() => mockRepository.reorderMagazine(
                weddingId: testWeddingId,
                oldIndex: 0,
                newIndex: 2,
              )).thenAnswer((_) async => const RepositoryResult.success(null));

          return createCubit();
        },
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
            MagazinePhoto(
              selectionId: 'sel-2',
              mediaType: 'album_image',
              mediaId: 'img-2',
              position: 2,
              thumbnailUrl: 'https://thumb.com/2',
            ),
            MagazinePhoto(
              selectionId: 'sel-3',
              mediaType: 'album_image',
              mediaId: 'img-3',
              position: 3,
              thumbnailUrl: 'https://thumb.com/3',
            ),
          ],
        ),
        act: (cubit) => cubit.reorderPhoto(0, 2),
        expect: () => [
          // Optimistic reorder + isReordering
          isA<MagazineSelectionState>()
              .having((s) => s.isReordering, 'isReordering', true)
              .having((s) => s.photos[0].selectionId, 'first', 'sel-2')
              .having((s) => s.photos[1].selectionId, 'second', 'sel-3')
              .having((s) => s.photos[2].selectionId, 'third', 'sel-1'),
          // Reordering complete
          isA<MagazineSelectionState>().having((s) => s.isReordering, 'isReordering', false),
        ],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should do nothing when indices are equal',
        build: () => createCubit(),
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
          ],
        ),
        act: (cubit) => cubit.reorderPhoto(0, 0),
        expect: () => [],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should do nothing when index is negative',
        build: () => createCubit(),
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
          ],
        ),
        act: (cubit) => cubit.reorderPhoto(-1, 0),
        expect: () => [],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should do nothing when index exceeds photos length',
        build: () => createCubit(),
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
          ],
        ),
        act: (cubit) => cubit.reorderPhoto(0, 5),
        expect: () => [],
      );
    });

    group('clearAll', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should clear all photos and show success',
        build: () {
          when(() => mockRepository.clearMagazineSelections(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));

          return createCubit();
        },
        seed: () => const MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://thumb.com/1',
            ),
          ],
        ),
        act: (cubit) => cubit.clearAll(),
        expect: () => [
          // Loading
          isA<MagazineSelectionState>().having((s) => s.isLoading, 'isLoading', true),
          // Cleared
          isA<MagazineSelectionState>()
              .having((s) => s.photos, 'photos', isEmpty)
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.successMessage, 'successMessage', 'All photos removed from magazine'),
        ],
      );

      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should do nothing when already empty',
        build: () => createCubit(),
        act: (cubit) => cubit.clearAll(),
        expect: () => [],
      );
    });

    group('clearError', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should clear error message',
        build: () => createCubit(),
        seed: () => const MagazineSelectionState(errorMessage: 'Test error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          isA<MagazineSelectionState>().having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );
    });

    group('clearSuccess', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should clear success message',
        build: () => createCubit(),
        seed: () => const MagazineSelectionState(successMessage: 'Test success'),
        act: (cubit) => cubit.clearSuccess(),
        expect: () => [
          isA<MagazineSelectionState>().having((s) => s.successMessage, 'successMessage', isNull),
        ],
      );
    });

    group('setMaxPhotos', () {
      blocTest<MagazineSelectionCubit, MagazineSelectionState>(
        'should update maxPhotos',
        build: () => createCubit(),
        act: (cubit) => cubit.setMaxPhotos(30),
        expect: () => [
          isA<MagazineSelectionState>().having((s) => s.maxPhotos, 'maxPhotos', 30),
        ],
      );
    });
  });
}
