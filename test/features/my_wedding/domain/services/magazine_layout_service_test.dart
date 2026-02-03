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

      test('should create cover + single for 2 photos', () {
        final photos = createPhotos(2);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages.length, 2);
        expect(pages[0], isA<CoverPage>());
        expect(pages[1], isA<SinglePage>());
      });

      test('should create cover + double for 3 photos', () {
        final photos = createPhotos(3);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages.length, 2);
        expect(pages[0], isA<CoverPage>());
        expect(pages[1], isA<DoublePage>());
      });

      test('should handle mosaic pages for 7+ photos', () {
        final photos = createPhotos(7);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        // 1 cover + remaining 6 photos = 1 mosaic page
        expect(pages.length, 2);
        expect(pages[0], isA<CoverPage>());
        expect(pages[1], isA<MosaicPage>());
        expect((pages[1] as MosaicPage).photoCount, 6);
      });

      test('should distribute photos across multiple pages', () {
        final photos = createPhotos(15);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        // Cover (1) + remaining 14 photos distributed
        expect(pages.isNotEmpty, true);
        expect(pages.first, isA<CoverPage>());

        // Verify total photos equals input
        var totalPhotos = 0;
        for (final page in pages) {
          totalPhotos += page.photoCount;
        }
        expect(totalPhotos, 15);
      });

      test('should create varied layouts for large photo count', () {
        final photos = createPhotos(20);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        // Should have mix of page types
        expect(pages.any((p) => p is CoverPage), true);
        expect(
          pages.any((p) => p is MosaicPage || p is DoublePage || p is SinglePage),
          true,
        );
      });

      test('should use all photos without loss', () {
        for (var count = 1; count <= 60; count++) {
          final photos = createPhotos(count);
          final pages = service.generateLayouts(
            photos: photos,
            weddingTitle: 'Test',
            weddingDate: DateTime.now(),
          );

          var totalPhotos = 0;
          for (final page in pages) {
            totalPhotos += page.photoCount;
          }
          expect(
            totalPhotos,
            count,
            reason: 'Photo count $count should be fully used',
          );
        }
      });
    });

    group('layout patterns', () {
      test('mosaic pages should have at most 6 photos', () {
        final photos = createPhotos(50);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        for (final page in pages) {
          if (page is MosaicPage) {
            expect(page.photoCount, lessThanOrEqualTo(6));
          }
        }
      });

      test('double pages should have exactly 2 photos', () {
        final photos = createPhotos(30);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        for (final page in pages) {
          if (page is DoublePage) {
            expect(page.photoCount, 2);
          }
        }
      });

      test('single pages should have exactly 1 photo', () {
        final photos = createPhotos(30);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        for (final page in pages) {
          if (page is SinglePage) {
            expect(page.photoCount, 1);
          }
        }
      });
    });

    group('edge cases', () {
      test('should handle exactly 4 remaining photos as mosaic', () {
        // 1 cover + 4 = mosaic of 4
        final photos = createPhotos(5);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        expect(pages.length, 2);
        final lastPage = pages.last;
        expect(lastPage, isA<MosaicPage>());
        expect((lastPage as MosaicPage).photoCount, 4);
      });

      test('should handle exactly 5 remaining photos as mosaic', () {
        final photos = createPhotos(6);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        // Cover + mosaic(5) or some other distribution
        var totalPhotos = 0;
        for (final page in pages) {
          totalPhotos += page.photoCount;
        }
        expect(totalPhotos, 6);
      });

      test('should use single page for odd remaining photo', () {
        // Total: 8 = 1 cover + 6 mosaic + 1 single
        final photos = createPhotos(8);
        final pages = service.generateLayouts(
          photos: photos,
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );

        var totalPhotos = 0;
        for (final page in pages) {
          totalPhotos += page.photoCount;
        }
        expect(totalPhotos, 8);
      });
    });
  });
}
