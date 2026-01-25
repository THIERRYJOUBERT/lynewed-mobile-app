/// Tests for InspirationsCubit and InspirationsState.
///
/// Comprehensive tests covering:
/// - State creation and manipulation
/// - All cubit methods (loadAlbums, createAlbum, selectAlbum, etc.)
/// - Error handling
/// - Edge cases
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/album_image.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/inspiration_album.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/saved_post.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/inspirations_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/inspirations_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  group('InspirationsState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = InspirationsState();

        expect(state.albums, isEmpty);
        expect(state.selectedAlbum, isNull);
        expect(state.albumImages, isEmpty);
        expect(state.savedPosts, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should create with provided values', () {
        final album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Dress Ideas',
          category: AlbumCategory.dress,
        );
        final image = AlbumImage(
          id: 'img-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/image.jpg',
        );
        final savedPost = SavedPost(
          id: 'post-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/feed-image.jpg',
          sourceProfileId: 'pro-1',
        );

        final state = InspirationsState(
          albums: [album],
          selectedAlbum: album,
          albumImages: [image],
          savedPosts: [savedPost],
          isLoading: true,
          error: 'Some error',
        );

        expect(state.albums, [album]);
        expect(state.selectedAlbum, album);
        expect(state.albumImages, [image]);
        expect(state.savedPosts, [savedPost]);
        expect(state.isLoading, true);
        expect(state.error, 'Some error');
      });
    });

    group('computed properties', () {
      test('allItems should return combined list of albumImages and savedPosts', () {
        final image1 = AlbumImage(
          id: 'img-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/image1.jpg',
        );
        final image2 = AlbumImage(
          id: 'img-2',
          albumId: 'album-1',
          imageUrl: 'https://example.com/image2.jpg',
        );
        final savedPost = SavedPost(
          id: 'post-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/feed-image.jpg',
        );

        final state = InspirationsState(
          albumImages: [image1, image2],
          savedPosts: [savedPost],
        );

        expect(state.allItems.length, 3);
        expect(state.allItems, containsAll([image1, image2, savedPost]));
      });

      test('allItems should return empty list when no items', () {
        const state = InspirationsState();

        expect(state.allItems, isEmpty);
      });

      test('allItems should return only albumImages when no savedPosts', () {
        final image = AlbumImage(
          id: 'img-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/image.jpg',
        );

        final state = InspirationsState(albumImages: [image]);

        expect(state.allItems.length, 1);
        expect(state.allItems.first, image);
      });

      test('allItems should return only savedPosts when no albumImages', () {
        final savedPost = SavedPost(
          id: 'post-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/feed-image.jpg',
        );

        final state = InspirationsState(savedPosts: [savedPost]);

        expect(state.allItems.length, 1);
        expect(state.allItems.first, savedPost);
      });
    });

    group('copyWith', () {
      test('should copy with new albums', () {
        const original = InspirationsState();
        final album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'New Album',
        );
        final copied = original.copyWith(albums: [album]);

        expect(copied.albums, [album]);
        expect(copied.selectedAlbum, isNull);
        expect(copied.isLoading, false);
      });

      test('should copy with new selectedAlbum', () {
        const original = InspirationsState();
        final album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Selected Album',
        );
        final copied = original.copyWith(selectedAlbum: album);

        expect(copied.selectedAlbum, album);
      });

      test('should copy with new albumImages', () {
        const original = InspirationsState();
        final image = AlbumImage(
          id: 'img-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/image.jpg',
        );
        final copied = original.copyWith(albumImages: [image]);

        expect(copied.albumImages, [image]);
      });

      test('should copy with new savedPosts', () {
        const original = InspirationsState();
        final savedPost = SavedPost(
          id: 'post-1',
          albumId: 'album-1',
          imageUrl: 'https://example.com/feed-image.jpg',
        );
        final copied = original.copyWith(savedPosts: [savedPost]);

        expect(copied.savedPosts, [savedPost]);
      });

      test('should copy with new isLoading', () {
        const original = InspirationsState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with new error', () {
        const original = InspirationsState();
        final copied = original.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should clear error with clearError flag', () {
        const original = InspirationsState(error: 'Previous error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should clear selectedAlbum with clearSelectedAlbum flag', () {
        final album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album',
        );
        final original = InspirationsState(selectedAlbum: album);
        final copied = original.copyWith(clearSelectedAlbum: true);

        expect(copied.selectedAlbum, isNull);
      });

      test('should preserve unchanged values', () {
        final album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album',
        );
        final state = InspirationsState(
          albums: [album],
          isLoading: true,
        );
        final copied = state.copyWith(error: 'New error');

        expect(copied.albums, [album]);
        expect(copied.isLoading, true);
        expect(copied.error, 'New error');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final album = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album',
        );
        final state1 = InspirationsState(albums: [album]);
        final state2 = InspirationsState(albums: [album]);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different albums', () {
        final album1 = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album 1',
        );
        final album2 = InspirationAlbum(
          id: 'album-2',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album 2',
        );
        final state1 = InspirationsState(albums: [album1]);
        final state2 = InspirationsState(albums: [album2]);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different selectedAlbum', () {
        final album1 = InspirationAlbum(
          id: 'album-1',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album 1',
        );
        final album2 = InspirationAlbum(
          id: 'album-2',
          weddingId: 'wedding-1',
          brideProfileId: 'bride-1',
          name: 'Album 2',
        );
        final state1 = InspirationsState(selectedAlbum: album1);
        final state2 = InspirationsState(selectedAlbum: album2);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different isLoading', () {
        const state1 = InspirationsState(isLoading: true);
        const state2 = InspirationsState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different error', () {
        const state1 = InspirationsState(error: 'Error 1');
        const state2 = InspirationsState(error: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('InspirationsCubit', () {
    late MockMyWeddingRepository mockRepository;
    const testWeddingId = 'wedding-123';

    final testAlbums = [
      InspirationAlbum(
        id: 'album-1',
        weddingId: testWeddingId,
        brideProfileId: 'bride-1',
        name: 'Dress Ideas',
        category: AlbumCategory.dress,
      ),
      InspirationAlbum(
        id: 'album-2',
        weddingId: testWeddingId,
        brideProfileId: 'bride-1',
        name: 'Decor',
        category: AlbumCategory.decor,
      ),
    ];

    final testImages = [
      AlbumImage(
        id: 'img-1',
        albumId: 'album-1',
        imageUrl: 'https://example.com/image1.jpg',
      ),
      AlbumImage(
        id: 'img-2',
        albumId: 'album-1',
        imageUrl: 'https://example.com/image2.jpg',
      ),
    ];

    final testSavedPosts = [
      SavedPost(
        id: 'post-1',
        albumId: 'album-1',
        imageUrl: 'https://example.com/feed1.jpg',
        sourceProfileId: 'pro-1',
      ),
    ];

    setUp(() {
      mockRepository = MockMyWeddingRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = InspirationsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        );

        expect(cubit.state.albums, isEmpty);
        expect(cubit.state.selectedAlbum, isNull);
        expect(cubit.state.isLoading, false);
        expect(cubit.weddingId, testWeddingId);

        cubit.close();
      });
    });

    group('loadAlbums', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should emit loading state then loaded state on success',
        build: () {
          when(() => mockRepository.getInspirationAlbums(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testAlbums));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadAlbums(),
        expect: () => [
          const InspirationsState(isLoading: true),
          InspirationsState(
            isLoading: false,
            albums: testAlbums,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getInspirationAlbums(weddingId: testWeddingId))
              .called(1);
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should emit error state on failure',
        build: () {
          when(() => mockRepository.getInspirationAlbums(weddingId: testWeddingId))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Network error'));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadAlbums(),
        expect: () => [
          const InspirationsState(isLoading: true),
          const InspirationsState(isLoading: false, error: 'Network error'),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should handle empty albums list',
        build: () {
          when(() => mockRepository.getInspirationAlbums(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadAlbums(),
        expect: () => [
          const InspirationsState(isLoading: true),
          const InspirationsState(isLoading: false, albums: []),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should clear error when reloading albums',
        build: () {
          when(() => mockRepository.getInspirationAlbums(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testAlbums));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => const InspirationsState(error: 'Previous error'),
        act: (cubit) => cubit.loadAlbums(),
        expect: () => [
          const InspirationsState(isLoading: true),
          InspirationsState(isLoading: false, albums: testAlbums),
        ],
      );
    });

    group('createAlbum', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should create album and add it to the list',
        build: () {
          final newAlbum = InspirationAlbum(
            id: 'album-3',
            weddingId: testWeddingId,
            brideProfileId: 'bride-1',
            name: 'New Album',
            category: AlbumCategory.general,
          );
          when(() => mockRepository.createInspirationAlbum(
                weddingId: testWeddingId,
                name: 'New Album',
                category: null,
                isPrivate: false,
              )).thenAnswer((_) async => RepositoryResult.success(newAlbum));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.createAlbum(name: 'New Album'),
        expect: () => [
          const InspirationsState(isLoading: true),
          isA<InspirationsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.albums.length, 'albums.length', 1)
              .having((s) => s.albums.first.name, 'albums.first.name', 'New Album'),
        ],
        verify: (_) {
          verify(() => mockRepository.createInspirationAlbum(
                weddingId: testWeddingId,
                name: 'New Album',
                category: null,
                isPrivate: false,
              )).called(1);
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should create album with category and isPrivate',
        build: () {
          final newAlbum = InspirationAlbum(
            id: 'album-3',
            weddingId: testWeddingId,
            brideProfileId: 'bride-1',
            name: 'Private Dress Album',
            category: AlbumCategory.dress,
            isPrivate: true,
          );
          when(() => mockRepository.createInspirationAlbum(
                weddingId: testWeddingId,
                name: 'Private Dress Album',
                category: 'dress',
                isPrivate: true,
              )).thenAnswer((_) async => RepositoryResult.success(newAlbum));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.createAlbum(
          name: 'Private Dress Album',
          category: 'dress',
          isPrivate: true,
        ),
        expect: () => [
          const InspirationsState(isLoading: true),
          isA<InspirationsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.albums.first.isPrivate, 'isPrivate', true)
              .having((s) => s.albums.first.category, 'category', AlbumCategory.dress),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should emit error state on creation failure',
        build: () {
          when(() => mockRepository.createInspirationAlbum(
                weddingId: testWeddingId,
                name: 'New Album',
                category: null,
                isPrivate: false,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Creation failed'));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.createAlbum(name: 'New Album'),
        expect: () => [
          const InspirationsState(isLoading: true),
          const InspirationsState(isLoading: false, error: 'Creation failed'),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should add album to existing list',
        build: () {
          final newAlbum = InspirationAlbum(
            id: 'album-3',
            weddingId: testWeddingId,
            brideProfileId: 'bride-1',
            name: 'Third Album',
          );
          when(() => mockRepository.createInspirationAlbum(
                weddingId: testWeddingId,
                name: 'Third Album',
                category: null,
                isPrivate: false,
              )).thenAnswer((_) async => RepositoryResult.success(newAlbum));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.createAlbum(name: 'Third Album'),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          isA<InspirationsState>()
              .having((s) => s.albums.length, 'albums.length', 3)
              .having((s) => s.albums.last.name, 'albums.last.name', 'Third Album'),
        ],
      );
    });

    group('selectAlbum', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should load album images and saved posts on selection',
        build: () {
          when(() => mockRepository.getAlbumImages(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testImages));
          when(() => mockRepository.getSavedPosts(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testSavedPosts));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.selectAlbum(testAlbums.first),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: testSavedPosts,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getAlbumImages(albumId: 'album-1')).called(1);
          verify(() => mockRepository.getSavedPosts(albumId: 'album-1')).called(1);
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should handle images fetch failure gracefully',
        build: () {
          when(() => mockRepository.getAlbumImages(albumId: 'album-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Images error'));
          when(() => mockRepository.getSavedPosts(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testSavedPosts));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.selectAlbum(testAlbums.first),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: const [],
            savedPosts: testSavedPosts,
            isLoading: false,
          ),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should handle saved posts fetch failure gracefully',
        build: () {
          when(() => mockRepository.getAlbumImages(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testImages));
          when(() => mockRepository.getSavedPosts(albumId: 'album-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Posts error'));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.selectAlbum(testAlbums.first),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: const [],
            isLoading: false,
          ),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should clear previous selection data when selecting new album',
        build: () {
          when(() => mockRepository.getAlbumImages(albumId: 'album-2'))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          when(() => mockRepository.getSavedPosts(albumId: 'album-2'))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.selectAlbum(testAlbums[1]),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums[1],
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums[1],
            albumImages: const [],
            savedPosts: const [],
            isLoading: false,
          ),
        ],
      );
    });

    group('deleteAlbum', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should delete album and remove it from list',
        build: () {
          when(() => mockRepository.deleteInspirationAlbum(albumId: 'album-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.deleteAlbum('album-1'),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          InspirationsState(
            albums: [testAlbums[1]],
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteInspirationAlbum(albumId: 'album-1'))
              .called(1);
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should clear selection if deleted album was selected',
        build: () {
          when(() => mockRepository.deleteInspirationAlbum(albumId: 'album-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.deleteAlbum('album-1'),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: testSavedPosts,
            isLoading: true,
          ),
          InspirationsState(
            albums: [testAlbums[1]],
            selectedAlbum: null,
            albumImages: const [],
            savedPosts: const [],
            isLoading: false,
          ),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should emit error state on deletion failure',
        build: () {
          when(() => mockRepository.deleteInspirationAlbum(albumId: 'album-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Deletion failed'));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.deleteAlbum('album-1'),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          InspirationsState(
            albums: testAlbums,
            isLoading: false,
            error: 'Deletion failed',
          ),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should preserve selection if different album was deleted',
        build: () {
          when(() => mockRepository.deleteInspirationAlbum(albumId: 'album-2'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
        ),
        act: (cubit) => cubit.deleteAlbum('album-2'),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            isLoading: true,
          ),
          InspirationsState(
            albums: [testAlbums.first],
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            isLoading: false,
          ),
        ],
      );
    });

    group('saveImageToAlbum', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should save image and refresh album content when album is selected',
        build: () {
          final newSavedPost = SavedPost(
            id: 'post-new',
            albumId: 'album-1',
            imageUrl: 'https://example.com/new-image.jpg',
            sourceProfileId: 'pro-1',
          );
          when(() => mockRepository.saveImageToAlbum(
                albumId: 'album-1',
                imageUrl: 'https://example.com/new-image.jpg',
                sourceProfileId: 'pro-1',
              )).thenAnswer((_) async => RepositoryResult.success(newSavedPost));
          when(() => mockRepository.getAlbumImages(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testImages));
          when(() => mockRepository.getSavedPosts(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success([...testSavedPosts, newSavedPost]));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.saveImageToAlbum(
          albumId: 'album-1',
          imageUrl: 'https://example.com/new-image.jpg',
          sourceProfileId: 'pro-1',
        ),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: testSavedPosts,
            isLoading: true,
          ),
          isA<InspirationsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.savedPosts.length, 'savedPosts.length', 2),
        ],
        verify: (_) {
          verify(() => mockRepository.saveImageToAlbum(
                albumId: 'album-1',
                imageUrl: 'https://example.com/new-image.jpg',
                sourceProfileId: 'pro-1',
              )).called(1);
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should save image without refreshing when album is not selected',
        build: () {
          final newSavedPost = SavedPost(
            id: 'post-new',
            albumId: 'album-1',
            imageUrl: 'https://example.com/new-image.jpg',
          );
          when(() => mockRepository.saveImageToAlbum(
                albumId: 'album-1',
                imageUrl: 'https://example.com/new-image.jpg',
                sourceProfileId: null,
              )).thenAnswer((_) async => RepositoryResult.success(newSavedPost));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.saveImageToAlbum(
          albumId: 'album-1',
          imageUrl: 'https://example.com/new-image.jpg',
        ),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          InspirationsState(albums: testAlbums, isLoading: false),
        ],
        verify: (_) {
          verifyNever(() => mockRepository.getAlbumImages(albumId: any(named: 'albumId')));
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should emit error state on save failure',
        build: () {
          when(() => mockRepository.saveImageToAlbum(
                albumId: 'album-1',
                imageUrl: 'https://example.com/new-image.jpg',
                sourceProfileId: null,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Save failed'));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.saveImageToAlbum(
          albumId: 'album-1',
          imageUrl: 'https://example.com/new-image.jpg',
        ),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          InspirationsState(
            albums: testAlbums,
            isLoading: false,
            error: 'Save failed',
          ),
        ],
      );
    });

    group('removeSavedPost', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should remove saved post and refresh album content',
        build: () {
          when(() => mockRepository.removeSavedPost(savedPostId: 'post-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          when(() => mockRepository.getAlbumImages(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testImages));
          when(() => mockRepository.getSavedPosts(albumId: 'album-1'))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.removeSavedPost('post-1'),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: testSavedPosts,
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: const [],
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.removeSavedPost(savedPostId: 'post-1'))
              .called(1);
        },
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should emit error state on removal failure',
        build: () {
          when(() => mockRepository.removeSavedPost(savedPostId: 'post-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Removal failed'));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.removeSavedPost('post-1'),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            savedPosts: testSavedPosts,
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            savedPosts: testSavedPosts,
            isLoading: false,
            error: 'Removal failed',
          ),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should not refresh if no album is selected',
        build: () {
          when(() => mockRepository.removeSavedPost(savedPostId: 'post-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.removeSavedPost('post-1'),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          InspirationsState(albums: testAlbums, isLoading: false),
        ],
        verify: (_) {
          verify(() => mockRepository.removeSavedPost(savedPostId: 'post-1'))
              .called(1);
          verifyNever(() => mockRepository.getAlbumImages(albumId: any(named: 'albumId')));
          verifyNever(() => mockRepository.getSavedPosts(albumId: any(named: 'albumId')));
        },
      );
    });

    group('clearError', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should clear error state',
        build: () => InspirationsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => const InspirationsState(error: 'Some error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const InspirationsState(error: null),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should preserve other state when clearing error',
        build: () => InspirationsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          error: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            error: null,
          ),
        ],
      );
    });

    group('clearSelection', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should clear selected album and its content',
        build: () => InspirationsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.clearSelection(),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: null,
            albumImages: const [],
            savedPosts: const [],
          ),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should preserve albums when clearing selection',
        build: () => InspirationsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
        ),
        act: (cubit) => cubit.clearSelection(),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
          ),
        ],
      );
    });

    group('edge cases', () {
      blocTest<InspirationsCubit, InspirationsState>(
        'should handle deleting non-existent album gracefully',
        build: () {
          when(() => mockRepository.deleteInspirationAlbum(albumId: 'non-existent'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(albums: testAlbums),
        act: (cubit) => cubit.deleteAlbum('non-existent'),
        expect: () => [
          InspirationsState(albums: testAlbums, isLoading: true),
          InspirationsState(albums: testAlbums, isLoading: false),
        ],
      );

      blocTest<InspirationsCubit, InspirationsState>(
        'should reload content when selecting same album',
        build: () {
          when(() => mockRepository.getAlbumImages(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testImages));
          when(() => mockRepository.getSavedPosts(albumId: 'album-1'))
              .thenAnswer((_) async => RepositoryResult.success(testSavedPosts));
          return InspirationsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => InspirationsState(
          albums: testAlbums,
          selectedAlbum: testAlbums.first,
          albumImages: testImages,
          savedPosts: testSavedPosts,
        ),
        act: (cubit) => cubit.selectAlbum(testAlbums.first),
        expect: () => [
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            isLoading: true,
          ),
          InspirationsState(
            albums: testAlbums,
            selectedAlbum: testAlbums.first,
            albumImages: testImages,
            savedPosts: testSavedPosts,
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getAlbumImages(albumId: 'album-1')).called(1);
          verify(() => mockRepository.getSavedPosts(albumId: 'album-1')).called(1);
        },
      );

    });
  });
}
