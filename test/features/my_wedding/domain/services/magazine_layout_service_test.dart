/// Tests for MagazineLayoutService.
///
/// Comprehensive tests for magazine layout generation algorithm.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_page.dart';
import 'package:lynewed_beta/features/my_wedding/domain/services/magazine_layout_service.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';

void main() {
  late MagazineLayoutService service;

  setUp(() {
    service = MagazineLayoutService();
  });

  // Test helper to create MagazinePhoto
  MagazinePhoto createPhoto(int index) {
    return MagazinePhoto(
      selectionId: 'sel-$index',
      mediaType: 'album_image',
      mediaId: 'img-$index',
      position: index,
      thumbnailUrl: 'https://example.com/$index.jpg',
    );
  }

  List<MagazinePhoto> createPhotos(int count) {
    return List.generate(count, (i) => createPhoto(i + 1));
  }

  group('MagazineLayoutService', () {
    group('generateLayouts', () {
      test('should return empty list for empty photos', () {
        final pages = service.generateLayouts(
          photos: [],
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages, isEmpty);
      });

      test('should create cover page with first photo', () {
        final photos = createPhotos(5);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Jessica & Kyle',
          weddingDate: DateTime(2025, 6, 12),
        );

        expect(pages.first, isA<CoverPage>());
        final cover = pages.first as CoverPage;
        expect(cover.photo, photos.first);
        expect(cover.weddingTitle, 'Jessica & Kyle');
        expect(cover.weddingDate, DateTime(2025, 6, 12));
      });

      test('should create single page for 1 photo', () {
        final photos = createPhotos(1);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        // Only cover page with the single photo
        expect(pages.length, 1);
        expect(pages.first, isA<CoverPage>());
      });

      test('should return only cover for 2 photos', () {
        final photos = createPhotos(2);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages.length, 1);
        expect(pages[0], isA<CoverPage>());
      });

      test('should return only cover for 3 photos', () {
        final photos = createPhotos(3);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages.length, 1);
        expect(pages[0], isA<CoverPage>());
      });

      test('should return only cover for 7+ photos', () {
        final photos = createPhotos(7);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages.length, 1);
        expect(pages[0], isA<CoverPage>());
      });

      test('should return only cover regardless of photo count', () {
        for (var count = 1; count <= 60; count++) {
          final photos = createPhotos(count);
          final pages = service.generateLayouts(
            photos: photos,
            weddingTitle: 'Test',
            weddingDate: DateTime.now(),
          );

          expect(
            pages.length,
            1,
            reason: 'Photo count $count should produce only cover page',
          );
          expect(pages.first, isA<CoverPage>());
          expect(
            (pages.first as CoverPage).photo,
            photos.first,
            reason: 'Cover should use first photo for count $count',
          );
        }
      });
    });
  });
}
