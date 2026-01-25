import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_filter.dart';
import 'package:lynewed_beta/features/feed/domain/entities/feed_professional.dart';
import 'package:lynewed_beta/features/feed/domain/entities/portfolio_item.dart';
import 'package:lynewed_beta/features/feed/presentation/bloc/feed_state.dart';

void main() {
  group('FeedState', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create FeedState with default values', () {
        const state = FeedState();

        expect(state.professionals, isEmpty);
        expect(state.selectedProfessional, isNull);
        expect(state.filter.professions, isEmpty);
        expect(state.filter.sortBy, FeedSortBy.recent);
        expect(state.availableProfessions, isEmpty);
        expect(state.isLoading, false);
        expect(state.isLoadingMore, false);
        expect(state.hasMoreData, true);
        expect(state.error, isNull);
      });

      test('should create FeedState with all fields', () {
        final professionals = [
          FeedProfessional(
            profileId: 'pro-1',
            displayName: 'Jane Photography',
            profession: 'photographer',
            portfolioItems: [
              PortfolioItem(
                id: 'item-1',
                imageUrl: 'https://example.com/1.jpg',
                professionalId: 'pro-1',
                createdAt: DateTime(2025, 1, 24),
              ),
            ],
          ),
        ];
        const selectedPro = FeedProfessional(
          profileId: 'pro-1',
          displayName: 'Jane Photography',
          profession: 'photographer',
        );
        const filter = FeedFilter(
          professions: ['photographer'],
          sortBy: FeedSortBy.popular,
        );

        final state = FeedState(
          professionals: professionals,
          selectedProfessional: selectedPro,
          filter: filter,
          availableProfessions: const ['photographer', 'florist'],
          isLoading: true,
          isLoadingMore: true,
          hasMoreData: false,
          error: 'Some error',
        );

        expect(state.professionals, hasLength(1));
        expect(state.selectedProfessional, isNotNull);
        expect(state.filter.professions, ['photographer']);
        expect(state.filter.sortBy, FeedSortBy.popular);
        expect(state.availableProfessions, hasLength(2));
        expect(state.isLoading, true);
        expect(state.isLoadingMore, true);
        expect(state.hasMoreData, false);
        expect(state.error, 'Some error');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final professionals = [
          const FeedProfessional(
            profileId: 'pro-1',
            displayName: 'Jane Photography',
            profession: 'photographer',
          ),
        ];

        final original = FeedState(
          professionals: professionals,
          filter: const FeedFilter(professions: ['photographer']),
          availableProfessions: const ['photographer'],
          isLoading: true,
        );

        final copied = original.copyWith(isLoading: false);

        expect(copied.professionals, hasLength(1));
        expect(copied.filter.professions, ['photographer']);
        expect(copied.availableProfessions, ['photographer']);
        expect(copied.isLoading, false);
      });

      test('should update professionals', () {
        const original = FeedState();

        final copied = original.copyWith(
          professionals: [
            const FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
            ),
          ],
        );

        expect(copied.professionals, hasLength(1));
      });

      test('should update filter', () {
        const original = FeedState();

        final copied = original.copyWith(
          filter: const FeedFilter(
            professions: ['florist'],
            sortBy: FeedSortBy.alphabetical,
          ),
        );

        expect(copied.filter.professions, ['florist']);
        expect(copied.filter.sortBy, FeedSortBy.alphabetical);
      });

      test('should clear error with clearError flag', () {
        const original = FeedState(error: 'Some error');

        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should clear selectedProfessional with clearSelection flag', () {
        const original = FeedState(
          selectedProfessional: FeedProfessional(
            profileId: 'pro-1',
            displayName: 'Jane Photography',
            profession: 'photographer',
          ),
        );

        final copied = original.copyWith(clearSelection: true);

        expect(copied.selectedProfessional, isNull);
      });

      test('should not modify original', () {
        const original = FeedState(isLoading: true);

        original.copyWith(isLoading: false);

        expect(original.isLoading, true);
      });
    });

    // ==============================================================
    // COMPUTED PROPERTIES TESTS
    // ==============================================================

    group('computed properties', () {
      test('isEmpty should return true when no professionals', () {
        const state = FeedState(professionals: []);

        expect(state.isEmpty, true);
      });

      test('isEmpty should return false when has professionals', () {
        const state = FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
            ),
          ],
        );

        expect(state.isEmpty, false);
      });

      test('professionalsCount should return correct count', () {
        const state = FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
            ),
            FeedProfessional(
              profileId: 'pro-2',
              displayName: 'Floral Dreams',
              profession: 'florist',
            ),
          ],
        );

        expect(state.professionalsCount, 2);
      });

      test('hasSelection should return false when no selection', () {
        const state = FeedState();

        expect(state.hasSelection, false);
      });

      test('hasSelection should return true when has selection', () {
        const state = FeedState(
          selectedProfessional: FeedProfessional(
            profileId: 'pro-1',
            displayName: 'Jane Photography',
            profession: 'photographer',
          ),
        );

        expect(state.hasSelection, true);
      });

      test('hasError should return false when no error', () {
        const state = FeedState();

        expect(state.hasError, false);
      });

      test('hasError should return true when has error', () {
        const state = FeedState(error: 'Some error');

        expect(state.hasError, true);
      });

      test('hasActiveFilters should return false when default filter', () {
        const state = FeedState();

        expect(state.hasActiveFilters, false);
      });

      test('hasActiveFilters should return true when filter has professions', () {
        const state = FeedState(
          filter: FeedFilter(professions: ['photographer']),
        );

        expect(state.hasActiveFilters, true);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        const state1 = FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
            ),
          ],
          isLoading: true,
        );
        const state2 = FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
            ),
          ],
          isLoading: true,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when professionals differ', () {
        const state1 = FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-1',
              displayName: 'Jane Photography',
              profession: 'photographer',
            ),
          ],
        );
        const state2 = FeedState(
          professionals: [
            FeedProfessional(
              profileId: 'pro-2',
              displayName: 'Floral Dreams',
              profession: 'florist',
            ),
          ],
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when isLoading differs', () {
        const state1 = FeedState(isLoading: true);
        const state2 = FeedState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when error differs', () {
        const state1 = FeedState(error: 'Error 1');
        const state2 = FeedState(error: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
