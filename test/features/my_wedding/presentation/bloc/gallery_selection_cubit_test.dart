/// Tests for GallerySelectionCubit and GallerySelectionState.
///
/// Comprehensive tests covering:
/// - State creation and manipulation
/// - Selection mode (enter, exit, toggle)
/// - Multi-select functionality (select, deselect, select all, deselect all)
/// - Filter functionality (all, favorites, hidden)
/// - Edge cases
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/gallery_selection_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/gallery_selection_state.dart';

void main() {
  group('GallerySelectionState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = GallerySelectionState();

        expect(state.isSelectionMode, false);
        expect(state.selectedMediaIds, isEmpty);
        expect(state.currentFilter, GalleryFilter.all);
      });

      test('should create with provided values', () {
        final state = GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1', 'media-2'},
          currentFilter: GalleryFilter.favorites,
        );

        expect(state.isSelectionMode, true);
        expect(state.selectedMediaIds, {'media-1', 'media-2'});
        expect(state.currentFilter, GalleryFilter.favorites);
      });
    });

    group('computed properties', () {
      test('selectedCount should return the number of selected items', () {
        final state = GallerySelectionState(
          selectedMediaIds: {'media-1', 'media-2', 'media-3'},
        );

        expect(state.selectedCount, 3);
      });

      test('selectedCount should return 0 when no items selected', () {
        const state = GallerySelectionState();

        expect(state.selectedCount, 0);
      });

      test('isSelected should return true for selected items', () {
        final state = GallerySelectionState(
          selectedMediaIds: {'media-1', 'media-2'},
        );

        expect(state.isSelected('media-1'), true);
        expect(state.isSelected('media-2'), true);
      });

      test('isSelected should return false for non-selected items', () {
        final state = GallerySelectionState(
          selectedMediaIds: {'media-1'},
        );

        expect(state.isSelected('media-2'), false);
        expect(state.isSelected('media-3'), false);
      });

      test('hasSelection should return true when items are selected', () {
        final state = GallerySelectionState(
          selectedMediaIds: {'media-1'},
        );

        expect(state.hasSelection, true);
      });

      test('hasSelection should return false when no items selected', () {
        const state = GallerySelectionState();

        expect(state.hasSelection, false);
      });
    });

    group('copyWith', () {
      test('should copy with new isSelectionMode', () {
        const original = GallerySelectionState();
        final copied = original.copyWith(isSelectionMode: true);

        expect(copied.isSelectionMode, true);
        expect(copied.selectedMediaIds, isEmpty);
        expect(copied.currentFilter, GalleryFilter.all);
      });

      test('should copy with new selectedMediaIds', () {
        const original = GallerySelectionState();
        final copied = original.copyWith(
          selectedMediaIds: {'media-1', 'media-2'},
        );

        expect(copied.selectedMediaIds, {'media-1', 'media-2'});
      });

      test('should copy with new currentFilter', () {
        const original = GallerySelectionState();
        final copied = original.copyWith(currentFilter: GalleryFilter.hidden);

        expect(copied.currentFilter, GalleryFilter.hidden);
      });

      test('should preserve unchanged values', () {
        final original = GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
          currentFilter: GalleryFilter.favorites,
        );
        final copied = original.copyWith(currentFilter: GalleryFilter.hidden);

        expect(copied.isSelectionMode, true);
        expect(copied.selectedMediaIds, {'media-1'});
        expect(copied.currentFilter, GalleryFilter.hidden);
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final state1 = GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
          currentFilter: GalleryFilter.favorites,
        );
        final state2 = GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
          currentFilter: GalleryFilter.favorites,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different isSelectionMode', () {
        final state1 = GallerySelectionState(isSelectionMode: true);
        const state2 = GallerySelectionState(isSelectionMode: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different selectedMediaIds', () {
        final state1 = GallerySelectionState(
          selectedMediaIds: {'media-1'},
        );
        final state2 = GallerySelectionState(
          selectedMediaIds: {'media-2'},
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different currentFilter', () {
        const state1 = GallerySelectionState(currentFilter: GalleryFilter.all);
        const state2 =
            GallerySelectionState(currentFilter: GalleryFilter.favorites);

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('GalleryFilter', () {
    test('should have all expected values', () {
      expect(GalleryFilter.values.length, 3);
      expect(GalleryFilter.values, contains(GalleryFilter.all));
      expect(GalleryFilter.values, contains(GalleryFilter.favorites));
      expect(GalleryFilter.values, contains(GalleryFilter.hidden));
    });
  });

  group('GallerySelectionCubit', () {
    late GallerySelectionCubit cubit;

    setUp(() {
      cubit = GallerySelectionCubit();
    });

    tearDown(() {
      cubit.close();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        expect(cubit.state.isSelectionMode, false);
        expect(cubit.state.selectedMediaIds, isEmpty);
        expect(cubit.state.currentFilter, GalleryFilter.all);
      });
    });

    group('enterSelectionMode', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should enter selection mode and select the initial media',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.enterSelectionMode('media-1'),
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1'},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should do nothing if already in selection mode',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
        ),
        act: (cubit) => cubit.enterSelectionMode('media-2'),
        expect: () => [],
      );
    });

    group('exitSelectionMode', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should exit selection mode and clear selection',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1', 'media-2'},
        ),
        act: (cubit) => cubit.exitSelectionMode(),
        expect: () => [
          const GallerySelectionState(
            isSelectionMode: false,
            selectedMediaIds: {},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should do nothing if not in selection mode',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.exitSelectionMode(),
        expect: () => [],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should preserve current filter when exiting selection mode',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
          currentFilter: GalleryFilter.favorites,
        ),
        act: (cubit) => cubit.exitSelectionMode(),
        expect: () => [
          const GallerySelectionState(
            isSelectionMode: false,
            selectedMediaIds: {},
            currentFilter: GalleryFilter.favorites,
          ),
        ],
      );
    });

    group('toggleSelection', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should select media if not selected',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
        ),
        act: (cubit) => cubit.toggleSelection('media-2'),
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1', 'media-2'},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should deselect media if already selected',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1', 'media-2'},
        ),
        act: (cubit) => cubit.toggleSelection('media-1'),
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-2'},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should exit selection mode when last item is deselected',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
        ),
        act: (cubit) => cubit.toggleSelection('media-1'),
        expect: () => [
          const GallerySelectionState(
            isSelectionMode: false,
            selectedMediaIds: {},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should do nothing if not in selection mode',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.toggleSelection('media-1'),
        expect: () => [],
      );
    });

    group('selectAll', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should select all provided media ids',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
        ),
        act: (cubit) =>
            cubit.selectAll(['media-1', 'media-2', 'media-3', 'media-4']),
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1', 'media-2', 'media-3', 'media-4'},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should do nothing if not in selection mode',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.selectAll(['media-1', 'media-2']),
        expect: () => [],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should handle empty list gracefully',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
        ),
        act: (cubit) => cubit.selectAll([]),
        expect: () => [
          const GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {},
          ),
        ],
      );
    });

    group('deselectAll', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should deselect all and exit selection mode',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1', 'media-2', 'media-3'},
        ),
        act: (cubit) => cubit.deselectAll(),
        expect: () => [
          const GallerySelectionState(
            isSelectionMode: false,
            selectedMediaIds: {},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should do nothing if not in selection mode',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.deselectAll(),
        expect: () => [],
      );
    });

    group('setFilter', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should change filter to favorites',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.setFilter(GalleryFilter.favorites),
        expect: () => [
          const GallerySelectionState(
            currentFilter: GalleryFilter.favorites,
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should change filter to hidden',
        build: () => GallerySelectionCubit(),
        act: (cubit) => cubit.setFilter(GalleryFilter.hidden),
        expect: () => [
          const GallerySelectionState(
            currentFilter: GalleryFilter.hidden,
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should change filter back to all',
        build: () => GallerySelectionCubit(),
        seed: () => const GallerySelectionState(
          currentFilter: GalleryFilter.favorites,
        ),
        act: (cubit) => cubit.setFilter(GalleryFilter.all),
        expect: () => [
          const GallerySelectionState(
            currentFilter: GalleryFilter.all,
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should preserve selection when changing filter',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1', 'media-2'},
        ),
        act: (cubit) => cubit.setFilter(GalleryFilter.favorites),
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1', 'media-2'},
            currentFilter: GalleryFilter.favorites,
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should do nothing if same filter is set',
        build: () => GallerySelectionCubit(),
        seed: () => const GallerySelectionState(
          currentFilter: GalleryFilter.favorites,
        ),
        act: (cubit) => cubit.setFilter(GalleryFilter.favorites),
        expect: () => [],
      );
    });

    group('edge cases', () {
      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should handle selecting same media multiple times',
        build: () => GallerySelectionCubit(),
        seed: () => GallerySelectionState(
          isSelectionMode: true,
          selectedMediaIds: {'media-1'},
        ),
        act: (cubit) {
          cubit.toggleSelection('media-1');
          cubit.toggleSelection('media-1');
        },
        expect: () => [
          // First toggle: deselect, which causes exit from selection mode
          const GallerySelectionState(
            isSelectionMode: false,
            selectedMediaIds: {},
          ),
          // Second toggle: no effect since not in selection mode
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should handle rapid enter and exit',
        build: () => GallerySelectionCubit(),
        act: (cubit) {
          cubit.enterSelectionMode('media-1');
          cubit.exitSelectionMode();
        },
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1'},
          ),
          const GallerySelectionState(
            isSelectionMode: false,
            selectedMediaIds: {},
          ),
        ],
      );

      blocTest<GallerySelectionCubit, GallerySelectionState>(
        'should handle select all then toggle individual',
        build: () => GallerySelectionCubit(),
        seed: () => const GallerySelectionState(isSelectionMode: true),
        act: (cubit) {
          cubit.selectAll(['media-1', 'media-2', 'media-3']);
          cubit.toggleSelection('media-2');
        },
        expect: () => [
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1', 'media-2', 'media-3'},
          ),
          GallerySelectionState(
            isSelectionMode: true,
            selectedMediaIds: {'media-1', 'media-3'},
          ),
        ],
      );
    });
  });
}
