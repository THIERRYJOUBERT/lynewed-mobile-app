/// Feed Cubit for managing feed state.
///
/// Handles loading feed professionals, filtering, pagination,
/// favorites, and selection.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/feed_filter.dart';
import '../../domain/entities/feed_professional.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../data/repositories/feed_repository_impl.dart';
import 'feed_state.dart';

/// Default page size for pagination.
const int _defaultPageSize = 20;

/// Cubit for managing feed state.
///
/// Provides methods for loading feed, filtering, pagination,
/// toggling favorites, and managing selection.
class FeedCubit extends Cubit<FeedState> {
  /// Creates a FeedCubit with the given repository.
  FeedCubit({
    FeedRepository? repository,
  })  : _repository = repository ?? FeedRepositoryImpl(),
        super(const FeedState());

  /// The repository for feed operations.
  final FeedRepository _repository;

  /// Current page size for pagination.
  int _pageSize = _defaultPageSize;

  /// Loads the feed with optional limit.
  ///
  /// Emits loading state first, then the loaded professionals or error.
  /// Also loads available professions for filtering.
  Future<void> loadFeed({int? limit}) async {
    _pageSize = limit ?? _defaultPageSize;
    emit(state.copyWith(isLoading: true, clearError: true));

    // Load professionals and professions in parallel
    final feedFuture = _repository.getFeedProfessionals(
      filter: state.filter,
      limit: _pageSize,
      offset: 0,
    );
    final professionsFuture = _repository.getAvailableProfessions();

    final feedResult = await feedFuture;
    final professionsResult = await professionsFuture;

    if (feedResult.isSuccess) {
      final professionals = feedResult.data ?? [];
      emit(state.copyWith(
        isLoading: false,
        professionals: professionals,
        hasMoreData: professionals.length >= _pageSize,
        availableProfessions:
            professionsResult.isSuccess ? professionsResult.data ?? [] : [],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: feedResult.error ?? 'Failed to load feed',
      ));
    }
  }

  /// Applies a new filter and reloads the feed.
  ///
  /// Replaces the current filter with [newFilter] and fetches matching
  /// professionals.
  Future<void> applyFilter(FeedFilter newFilter) async {
    emit(state.copyWith(filter: newFilter, isLoading: true, clearError: true));

    final result = await _repository.getFeedProfessionals(
      filter: newFilter,
      limit: _pageSize,
      offset: 0,
    );

    if (result.isSuccess) {
      final professionals = result.data ?? [];
      emit(state.copyWith(
        isLoading: false,
        professionals: professionals,
        hasMoreData: professionals.length >= _pageSize,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to apply filter',
      ));
    }
  }

  /// Toggles a profession in the filter.
  ///
  /// Adds the profession if not present, removes if present,
  /// then reloads the feed.
  Future<void> toggleProfessionFilter(String profession) async {
    final newFilter = state.filter.toggleProfession(profession);
    await applyFilter(newFilter);
  }

  /// Toggles favorite status for a professional.
  ///
  /// Updates the professional's favorite status locally and on the server.
  Future<void> toggleFavorite(String profileId) async {
    final result = await _repository.toggleFavorite(profileId);

    if (result.isSuccess) {
      final isFavorited = result.data ?? false;
      final updatedProfessionals = state.professionals.map((p) {
        if (p.profileId == profileId) {
          return p.copyWith(isFavorited: isFavorited);
        }
        return p;
      }).toList();

      emit(state.copyWith(professionals: updatedProfessionals));
    } else {
      emit(state.copyWith(
        error: result.error ?? 'Failed to toggle favorite',
      ));
    }
  }

  /// Loads more professionals (pagination).
  ///
  /// Appends new professionals to the existing list.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    final result = await _repository.getFeedProfessionals(
      filter: state.filter,
      limit: _pageSize,
      offset: state.professionals.length,
    );

    if (result.isSuccess) {
      final newProfessionals = result.data ?? [];
      emit(state.copyWith(
        isLoadingMore: false,
        professionals: [...state.professionals, ...newProfessionals],
        hasMoreData: newProfessionals.length >= _pageSize,
      ));
    } else {
      emit(state.copyWith(
        isLoadingMore: false,
        error: result.error ?? 'Failed to load more',
      ));
    }
  }

  /// Selects a professional for detail view.
  void selectProfessional(FeedProfessional professional) {
    emit(state.copyWith(selectedProfessional: professional));
  }

  /// Clears the current professional selection.
  void clearSelection() {
    emit(state.copyWith(clearSelection: true));
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Refreshes the feed from the beginning.
  ///
  /// Reloads all data with current filter settings.
  Future<void> refresh() async {
    await loadFeed(limit: _pageSize);
  }
}
