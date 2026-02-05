/// Tests for MagazinePreviewCubit.
///
/// Comprehensive tests for magazine preview state management.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_format.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/magazine_page.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_preview_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_preview_state.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/magazine_selection_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

  group('MagazinePreviewCubit', () {
    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test Wedding',
          weddingDate: DateTime(2025, 6, 12),
        );

        expect(cubit.state.isLoading, true);
        expect(cubit.state.pages, isEmpty);
        expect(cubit.state.currentPageIndex, 0);
        expect(cubit.state.selectedFormat, isNull);

        cubit.close();
      });
    });

    group('initialize', () {
      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should generate layouts and select cheapest valid format',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(15),
          weddingTitle: 'Jessica & Kyle',
          weddingDate: DateTime(2025, 6, 12),
        ),
        act: (cubit) => cubit.initialize(),
        expect: () => [
          isA<MagazinePreviewState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.pages.length, 'pages.length', 1)
              .having((s) => s.pages.first, 'first page', isA<CoverPage>())
              .having((s) => s.selectedFormat, 'selectedFormat', MagazineFormats.guestEdition)
              .having((s) => s.photoCount, 'photoCount', 15)
              .having((s) => s.unassignedPhotos.length, 'unassigned', 14),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should select iconic format for 25 photos',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(25),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        act: (cubit) => cubit.initialize(),
        expect: () => [
          isA<MagazinePreviewState>()
              .having((s) => s.selectedFormat?.id, 'format', 'iconic')
              .having((s) => s.pages.length, 'pages.length', 1)
              .having((s) => s.unassignedPhotos.length, 'unassigned', 24),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should select memory format for 50 photos',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(50),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        act: (cubit) => cubit.initialize(),
        expect: () => [
          isA<MagazinePreviewState>()
              .having((s) => s.selectedFormat?.id, 'format', 'memory')
              .having((s) => s.pages.length, 'pages.length', 1)
              .having((s) => s.unassignedPhotos.length, 'unassigned', 49),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should create cover as first page',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        act: (cubit) => cubit.initialize(),
        verify: (cubit) {
          expect(cubit.state.pages.length, 1);
          expect(cubit.state.pages.first, isA<CoverPage>());
          expect(cubit.state.unassignedPhotos.length, 9);
        },
      );
    });

    group('selectFormat', () {
      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should update selected format',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(15),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: [
            CoverPage(
              photo: createPhoto(1),
              weddingTitle: 'Test',
              weddingDate: DateTime.now(),
            ),
          ],
          selectedFormat: MagazineFormats.guestEdition,
          photoCount: 15,
        ),
        act: (cubit) => cubit.selectFormat(MagazineFormats.iconic),
        expect: () => [
          isA<MagazinePreviewState>()
              .having((s) => s.selectedFormat, 'selectedFormat', MagazineFormats.iconic),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should not change if same format selected',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(15),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: [],
          selectedFormat: MagazineFormats.iconic,
          photoCount: 15,
        ),
        act: (cubit) => cubit.selectFormat(MagazineFormats.iconic),
        expect: () => [],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'should reject invalid format for photo count',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(25),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: [],
          selectedFormat: MagazineFormats.iconic,
          photoCount: 25,
        ),
        act: (cubit) => cubit.selectFormat(MagazineFormats.guestEdition),
        expect: () => [],
      );
    });

    group('navigation', () {
      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'nextPage should increment page index',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            5,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 0,
          photoCount: 10,
        ),
        act: (cubit) => cubit.nextPage(),
        expect: () => [
          isA<MagazinePreviewState>().having((s) => s.currentPageIndex, 'index', 1),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'nextPage should not exceed page count',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            3,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 2, // Last page
          photoCount: 10,
        ),
        act: (cubit) => cubit.nextPage(),
        expect: () => [],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'previousPage should decrement page index',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            5,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 2,
          photoCount: 10,
        ),
        act: (cubit) => cubit.previousPage(),
        expect: () => [
          isA<MagazinePreviewState>().having((s) => s.currentPageIndex, 'index', 1),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'previousPage should not go below 0',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            5,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 0,
          photoCount: 10,
        ),
        act: (cubit) => cubit.previousPage(),
        expect: () => [],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'goToPage should set exact page index',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            5,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 0,
          photoCount: 10,
        ),
        act: (cubit) => cubit.goToPage(3),
        expect: () => [
          isA<MagazinePreviewState>().having((s) => s.currentPageIndex, 'index', 3),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'goToPage should clamp to valid range',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            5,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 0,
          photoCount: 10,
        ),
        act: (cubit) => cubit.goToPage(10),
        expect: () => [
          isA<MagazinePreviewState>().having((s) => s.currentPageIndex, 'index', 4),
        ],
      );

      blocTest<MagazinePreviewCubit, MagazinePreviewState>(
        'goToPage should handle negative index',
        build: () => MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(10),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        ),
        seed: () => MagazinePreviewState(
          isLoading: false,
          pages: List.generate(
            5,
            (i) => SinglePage(photo: createPhoto(i)),
          ),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 3,
          photoCount: 10,
        ),
        act: (cubit) => cubit.goToPage(-5),
        expect: () => [
          isA<MagazinePreviewState>().having((s) => s.currentPageIndex, 'index', 0),
        ],
      );
    });

    group('computed properties', () {
      test('validFormats should exclude formats with insufficient capacity', () async {
        final cubit = MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(25),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );
        await cubit.initialize();

        final valid = cubit.state.validFormats;
        expect(valid.any((f) => f.id == 'guest_edition'), false);
        expect(valid.any((f) => f.id == 'iconic'), true);
        expect(valid.any((f) => f.id == 'memory'), true);
        expect(valid.any((f) => f.id == 'collector'), true);

        cubit.close();
      });

      test('isFormatValid should check format validity', () async {
        final cubit = MagazinePreviewCubit(
          weddingId: 'test-wedding-id',
          photos: createPhotos(25),
          weddingTitle: 'Test',
          weddingDate: DateTime.now(),
        );
        await cubit.initialize();

        expect(cubit.state.isFormatValid(MagazineFormats.guestEdition), false);
        expect(cubit.state.isFormatValid(MagazineFormats.iconic), true);

        cubit.close();
      });

      test('canGoNext should be true when not on last page', () {
        final state = MagazinePreviewState(
          isLoading: false,
          pages: List.generate(5, (i) => SinglePage(photo: createPhoto(i))),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 2,
          photoCount: 5,
        );

        expect(state.canGoNext, true);
      });

      test('canGoNext should be false on last page', () {
        final state = MagazinePreviewState(
          isLoading: false,
          pages: List.generate(5, (i) => SinglePage(photo: createPhoto(i))),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 4,
          photoCount: 5,
        );

        expect(state.canGoNext, false);
      });

      test('canGoPrevious should be true when not on first page', () {
        final state = MagazinePreviewState(
          isLoading: false,
          pages: List.generate(5, (i) => SinglePage(photo: createPhoto(i))),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 2,
          photoCount: 5,
        );

        expect(state.canGoPrevious, true);
      });

      test('canGoPrevious should be false on first page', () {
        final state = MagazinePreviewState(
          isLoading: false,
          pages: List.generate(5, (i) => SinglePage(photo: createPhoto(i))),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 0,
          photoCount: 5,
        );

        expect(state.canGoPrevious, false);
      });

      test('currentPage should return correct page', () {
        final pages = List.generate(5, (i) => SinglePage(photo: createPhoto(i)));
        final state = MagazinePreviewState(
          isLoading: false,
          pages: pages,
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 2,
          photoCount: 5,
        );

        expect(state.currentPage, pages[2]);
      });

      test('pageCount should return pages length', () {
        final state = MagazinePreviewState(
          isLoading: false,
          pages: List.generate(7, (i) => SinglePage(photo: createPhoto(i))),
          selectedFormat: MagazineFormats.guestEdition,
          currentPageIndex: 0,
          photoCount: 7,
        );

        expect(state.pageCount, 7);
      });
    });
  });
}
