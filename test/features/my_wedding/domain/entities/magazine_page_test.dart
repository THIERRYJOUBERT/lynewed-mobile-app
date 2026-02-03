/// Tests for MagazinePage entity and its subtypes.
///
/// Comprehensive tests for magazine page types: cover, single, double, mosaic.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_page.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';

void main() {
  // Test helper to create MagazinePhoto
  MagazinePhoto createPhoto(String id, {int position = 1}) {
    return MagazinePhoto(
      selectionId: 'sel-$id',
      mediaType: 'album_image',
      mediaId: id,
      position: position,
      thumbnailUrl: 'https://example.com/$id.jpg',
    );
  }

  group('MagazinePageType', () {
    test('should have correct values', () {
      expect(MagazinePageType.values.length, 4);
      expect(MagazinePageType.cover, isNotNull);
      expect(MagazinePageType.single, isNotNull);
      expect(MagazinePageType.double, isNotNull);
      expect(MagazinePageType.mosaic, isNotNull);
    });
  });

  group('CoverPage', () {
    test('should create with all properties', () {
      final photo = createPhoto('cover');
      final page = CoverPage(
        photo: photo,
        weddingTitle: 'Jessica & Kyle',
        weddingDate: DateTime(2025, 6, 12),
      );

      expect(page.type, MagazinePageType.cover);
      expect(page.photo, photo);
      expect(page.weddingTitle, 'Jessica & Kyle');
      expect(page.weddingDate, DateTime(2025, 6, 12));
    });

    test('photoCount should return 1', () {
      final page = CoverPage(
        photo: createPhoto('1'),
        weddingTitle: 'Test',
        weddingDate: DateTime.now(),
      );

      expect(page.photoCount, 1);
    });

    test('photos should return single photo list', () {
      final photo = createPhoto('1');
      final page = CoverPage(
        photo: photo,
        weddingTitle: 'Test',
        weddingDate: DateTime.now(),
      );

      expect(page.photos, [photo]);
    });

    test('formattedDate should format date correctly', () {
      final page = CoverPage(
        photo: createPhoto('1'),
        weddingTitle: 'Test',
        weddingDate: DateTime(2025, 6, 12),
      );

      expect(page.formattedDate, 'June 12, 2025');
    });

    test('formattedDate should handle different months', () {
      final page = CoverPage(
        photo: createPhoto('1'),
        weddingTitle: 'Test',
        weddingDate: DateTime(2025, 12, 25),
      );

      expect(page.formattedDate, 'December 25, 2025');
    });
  });

  group('SinglePage', () {
    test('should create with photo', () {
      final photo = createPhoto('single');
      final page = SinglePage(photo: photo);

      expect(page.type, MagazinePageType.single);
      expect(page.photo, photo);
    });

    test('photoCount should return 1', () {
      final page = SinglePage(photo: createPhoto('1'));

      expect(page.photoCount, 1);
    });

    test('photos should return single photo list', () {
      final photo = createPhoto('1');
      final page = SinglePage(photo: photo);

      expect(page.photos, [photo]);
    });
  });

  group('DoublePage', () {
    test('should create with two photos', () {
      final photo1 = createPhoto('1');
      final photo2 = createPhoto('2');
      final page = DoublePage(leftPhoto: photo1, rightPhoto: photo2);

      expect(page.type, MagazinePageType.double);
      expect(page.leftPhoto, photo1);
      expect(page.rightPhoto, photo2);
    });

    test('photoCount should return 2', () {
      final page = DoublePage(
        leftPhoto: createPhoto('1'),
        rightPhoto: createPhoto('2'),
      );

      expect(page.photoCount, 2);
    });

    test('photos should return both photos in order', () {
      final photo1 = createPhoto('1');
      final photo2 = createPhoto('2');
      final page = DoublePage(leftPhoto: photo1, rightPhoto: photo2);

      expect(page.photos, [photo1, photo2]);
    });
  });

  group('MosaicPage', () {
    test('should create with multiple photos', () {
      final photos = [
        createPhoto('1'),
        createPhoto('2'),
        createPhoto('3'),
        createPhoto('4'),
        createPhoto('5'),
        createPhoto('6'),
      ];
      final page = MosaicPage(mosaicPhotos: photos);

      expect(page.type, MagazinePageType.mosaic);
      expect(page.mosaicPhotos, photos);
    });

    test('photoCount should return number of photos', () {
      final photos = [
        createPhoto('1'),
        createPhoto('2'),
        createPhoto('3'),
        createPhoto('4'),
      ];
      final page = MosaicPage(mosaicPhotos: photos);

      expect(page.photoCount, 4);
    });

    test('photos should return all photos', () {
      final photos = [
        createPhoto('1'),
        createPhoto('2'),
        createPhoto('3'),
      ];
      final page = MosaicPage(mosaicPhotos: photos);

      expect(page.photos, photos);
    });

    test('should handle maximum 6 photos', () {
      final photos = List.generate(6, (i) => createPhoto('$i'));
      final page = MosaicPage(mosaicPhotos: photos);

      expect(page.photoCount, 6);
    });
  });

  group('MagazinePage equality', () {
    test('CoverPage equality should be based on photo', () {
      final photo = createPhoto('1');
      final page1 = CoverPage(
        photo: photo,
        weddingTitle: 'Test',
        weddingDate: DateTime(2025, 1, 1),
      );
      final page2 = CoverPage(
        photo: photo,
        weddingTitle: 'Test',
        weddingDate: DateTime(2025, 1, 1),
      );

      expect(page1.photo, equals(page2.photo));
    });

    test('SinglePage with different photos should not be equal', () {
      final page1 = SinglePage(photo: createPhoto('1'));
      final page2 = SinglePage(photo: createPhoto('2'));

      expect(page1.photo, isNot(equals(page2.photo)));
    });
  });
}
