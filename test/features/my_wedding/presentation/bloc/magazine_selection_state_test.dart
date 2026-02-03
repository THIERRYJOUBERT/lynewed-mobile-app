/// Tests for MagazineSelectionState and MagazinePhoto.
///
/// Comprehensive tests covering state creation, computed properties,
/// copyWith, and equality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_selection.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';

void main() {
  group('MagazinePhoto', () {
    group('creation', () {
      test('should create with all required fields', () {
        const photo = MagazinePhoto(
          selectionId: 'sel-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        expect(photo.selectionId, 'sel-1');
        expect(photo.mediaType, 'album_image');
        expect(photo.mediaId, 'img-1');
        expect(photo.position, 1);
        expect(photo.thumbnailUrl, 'https://example.com/thumb.jpg');
      });

      test('should create from MagazineSelection', () {
        final selection = MagazineSelection(
          id: 'sel-1',
          weddingId: 'wed-1',
          userId: 'user-1',
          mediaType: 'guest_media',
          mediaId: 'media-1',
          position: 5,
          createdAt: DateTime(2026, 2, 1),
        );

        final photo = MagazinePhoto.fromSelection(
          selection,
          'https://example.com/thumb.jpg',
        );

        expect(photo.selectionId, 'sel-1');
        expect(photo.mediaType, 'guest_media');
        expect(photo.mediaId, 'media-1');
        expect(photo.position, 5);
        expect(photo.thumbnailUrl, 'https://example.com/thumb.jpg');
      });
    });

    group('copyWithPosition', () {
      test('should create copy with updated position', () {
        const original = MagazinePhoto(
          selectionId: 'sel-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        final copy = original.copyWithPosition(10);

        expect(copy.position, 10);
        expect(copy.selectionId, original.selectionId);
        expect(copy.mediaType, original.mediaType);
        expect(copy.mediaId, original.mediaId);
        expect(copy.thumbnailUrl, original.thumbnailUrl);
      });
    });

    group('equality', () {
      test('should be equal when selectionId matches', () {
        const photo1 = MagazinePhoto(
          selectionId: 'sel-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          thumbnailUrl: 'https://example.com/thumb1.jpg',
        );

        const photo2 = MagazinePhoto(
          selectionId: 'sel-1',
          mediaType: 'guest_media', // Different
          mediaId: 'media-2', // Different
          position: 5, // Different
          thumbnailUrl: 'https://example.com/thumb2.jpg', // Different
        );

        expect(photo1, equals(photo2));
        expect(photo1.hashCode, equals(photo2.hashCode));
      });

      test('should not be equal when selectionId differs', () {
        const photo1 = MagazinePhoto(
          selectionId: 'sel-1',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        const photo2 = MagazinePhoto(
          selectionId: 'sel-2',
          mediaType: 'album_image',
          mediaId: 'img-1',
          position: 1,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        expect(photo1, isNot(equals(photo2)));
      });
    });
  });

  group('MagazineSelectionState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = MagazineSelectionState();

        expect(state.photos, isEmpty);
        expect(state.isLoading, false);
        expect(state.isReordering, false);
        expect(state.errorMessage, isNull);
        expect(state.successMessage, isNull);
        expect(state.maxPhotos, MagazineSelection.maxPhotosCollector);
      });

      test('should create with provided values', () {
        const photos = [
          MagazinePhoto(
            selectionId: 'sel-1',
            mediaType: 'album_image',
            mediaId: 'img-1',
            position: 1,
            thumbnailUrl: 'https://example.com/1.jpg',
          ),
        ];

        const state = MagazineSelectionState(
          photos: photos,
          isLoading: true,
          isReordering: true,
          errorMessage: 'Test error',
          successMessage: 'Test success',
          maxPhotos: 30,
        );

        expect(state.photos.length, 1);
        expect(state.isLoading, true);
        expect(state.isReordering, true);
        expect(state.errorMessage, 'Test error');
        expect(state.successMessage, 'Test success');
        expect(state.maxPhotos, 30);
      });
    });

    group('computed properties', () {
      test('count should return number of photos', () {
        const state = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
            MagazinePhoto(
              selectionId: 'sel-2',
              mediaType: 'album_image',
              mediaId: 'img-2',
              position: 2,
              thumbnailUrl: 'https://example.com/2.jpg',
            ),
          ],
        );

        expect(state.count, 2);
      });

      test('canAddMore should return true when under limit', () {
        const state = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
          ],
          maxPhotos: 60,
        );

        expect(state.canAddMore, true);
      });

      test('canAddMore should return false when at limit', () {
        final photos = List.generate(
          60,
          (i) => MagazinePhoto(
            selectionId: 'sel-$i',
            mediaType: 'album_image',
            mediaId: 'img-$i',
            position: i + 1,
            thumbnailUrl: 'https://example.com/$i.jpg',
          ),
        );

        final state = MagazineSelectionState(
          photos: photos,
          maxPhotos: 60,
        );

        expect(state.canAddMore, false);
      });

      test('availableSlots should return remaining slots', () {
        const state = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
            MagazinePhoto(
              selectionId: 'sel-2',
              mediaType: 'album_image',
              mediaId: 'img-2',
              position: 2,
              thumbnailUrl: 'https://example.com/2.jpg',
            ),
          ],
          maxPhotos: 30,
        );

        expect(state.availableSlots, 28);
      });

      test('canPreview should return true when has photos', () {
        const state = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
          ],
        );

        expect(state.canPreview, true);
      });

      test('canPreview should return false when empty', () {
        const state = MagazineSelectionState();

        expect(state.canPreview, false);
      });

      test('isEmpty should return true when no photos', () {
        const state = MagazineSelectionState();

        expect(state.isEmpty, true);
      });

      test('isEmpty should return false when has photos', () {
        const state = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
          ],
        );

        expect(state.isEmpty, false);
      });

      test('isFull should return true when at max', () {
        final photos = List.generate(
          60,
          (i) => MagazinePhoto(
            selectionId: 'sel-$i',
            mediaType: 'album_image',
            mediaId: 'img-$i',
            position: i + 1,
            thumbnailUrl: 'https://example.com/$i.jpg',
          ),
        );

        final state = MagazineSelectionState(
          photos: photos,
          maxPhotos: 60,
        );

        expect(state.isFull, true);
      });

      test('isFull should return false when under max', () {
        const state = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
          ],
          maxPhotos: 60,
        );

        expect(state.isFull, false);
      });
    });

    group('copyWith', () {
      test('should copy with new photos', () {
        const original = MagazineSelectionState();
        const newPhotos = [
          MagazinePhoto(
            selectionId: 'sel-1',
            mediaType: 'album_image',
            mediaId: 'img-1',
            position: 1,
            thumbnailUrl: 'https://example.com/1.jpg',
          ),
        ];

        final copied = original.copyWith(photos: newPhotos);

        expect(copied.photos, newPhotos);
        expect(copied.isLoading, false);
      });

      test('should copy with new isLoading', () {
        const original = MagazineSelectionState();
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with new isReordering', () {
        const original = MagazineSelectionState();
        final copied = original.copyWith(isReordering: true);

        expect(copied.isReordering, true);
      });

      test('should copy with new errorMessage', () {
        const original = MagazineSelectionState();
        final copied = original.copyWith(errorMessage: 'New error');

        expect(copied.errorMessage, 'New error');
      });

      test('should clear error when clearError is true', () {
        const original = MagazineSelectionState(errorMessage: 'Old error');
        final copied = original.copyWith(clearError: true);

        expect(copied.errorMessage, isNull);
      });

      test('should copy with new successMessage', () {
        const original = MagazineSelectionState();
        final copied = original.copyWith(successMessage: 'Success!');

        expect(copied.successMessage, 'Success!');
      });

      test('should clear success when clearSuccess is true', () {
        const original = MagazineSelectionState(successMessage: 'Old success');
        final copied = original.copyWith(clearSuccess: true);

        expect(copied.successMessage, isNull);
      });

      test('should copy with new maxPhotos', () {
        const original = MagazineSelectionState();
        final copied = original.copyWith(maxPhotos: 30);

        expect(copied.maxPhotos, 30);
      });

      test('should preserve unchanged values', () {
        const photos = [
          MagazinePhoto(
            selectionId: 'sel-1',
            mediaType: 'album_image',
            mediaId: 'img-1',
            position: 1,
            thumbnailUrl: 'https://example.com/1.jpg',
          ),
        ];

        const original = MagazineSelectionState(
          photos: photos,
          isLoading: true,
          isReordering: true,
          errorMessage: 'Error',
          successMessage: 'Success',
          maxPhotos: 30,
        );

        final copied = original.copyWith(isLoading: false);

        expect(copied.photos, photos);
        expect(copied.isLoading, false);
        expect(copied.isReordering, true);
        expect(copied.errorMessage, 'Error');
        expect(copied.successMessage, 'Success');
        expect(copied.maxPhotos, 30);
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        const photos = [
          MagazinePhoto(
            selectionId: 'sel-1',
            mediaType: 'album_image',
            mediaId: 'img-1',
            position: 1,
            thumbnailUrl: 'https://example.com/1.jpg',
          ),
        ];

        const state1 = MagazineSelectionState(
          photos: photos,
          isLoading: true,
          errorMessage: 'Error',
        );

        const state2 = MagazineSelectionState(
          photos: photos,
          isLoading: true,
          errorMessage: 'Error',
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different photos', () {
        const state1 = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-1',
              mediaType: 'album_image',
              mediaId: 'img-1',
              position: 1,
              thumbnailUrl: 'https://example.com/1.jpg',
            ),
          ],
        );

        const state2 = MagazineSelectionState(
          photos: [
            MagazinePhoto(
              selectionId: 'sel-2',
              mediaType: 'album_image',
              mediaId: 'img-2',
              position: 2,
              thumbnailUrl: 'https://example.com/2.jpg',
            ),
          ],
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different isLoading', () {
        const state1 = MagazineSelectionState(isLoading: true);
        const state2 = MagazineSelectionState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different errorMessage', () {
        const state1 = MagazineSelectionState(errorMessage: 'Error 1');
        const state2 = MagazineSelectionState(errorMessage: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
