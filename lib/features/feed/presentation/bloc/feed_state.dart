/// Feed State for FeedCubit.
///
/// Defines the state for managing feed professionals, filters, and selection.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/feed_filter.dart';
import '../../domain/entities/feed_professional.dart';

/// State for the feed Cubit.
///
/// Tracks the professionals list, selected professional, filters,
/// loading state, pagination, and errors.
@immutable
class FeedState {
  /// Creates a feed state.
  const FeedState({
    this.professionals = const [],
    this.selectedProfessional,
    this.filter = const FeedFilter(),
    this.availableProfessions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.error,
  });

  /// List of professionals in the feed.
  final List<FeedProfessional> professionals;

  /// Currently selected professional for detail view.
  final FeedProfessional? selectedProfessional;

  /// Current filter settings.
  final FeedFilter filter;

  /// List of available professions for filtering.
  final List<String> availableProfessions;

  /// Whether the initial load is in progress.
  final bool isLoading;

  /// Whether loading more data (pagination).
  final bool isLoadingMore;

  /// Whether there is more data to load.
  final bool hasMoreData;

  /// Error message, if any.
  final String? error;

  /// Whether the professionals list is empty.
  bool get isEmpty => professionals.isEmpty;

  /// Number of professionals in the feed.
  int get professionalsCount => professionals.length;

  /// Whether a professional is selected.
  bool get hasSelection => selectedProfessional != null;

  /// Whether there is an error.
  bool get hasError => error != null;

  /// Whether any filters are active.
  bool get hasActiveFilters => filter.hasFilters;

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  /// Use [clearSelection] to explicitly set selectedProfessional to null.
  FeedState copyWith({
    List<FeedProfessional>? professionals,
    FeedProfessional? selectedProfessional,
    FeedFilter? filter,
    List<String>? availableProfessions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreData,
    String? error,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return FeedState(
      professionals: professionals ?? this.professionals,
      selectedProfessional: clearSelection
          ? null
          : (selectedProfessional ?? this.selectedProfessional),
      filter: filter ?? this.filter,
      availableProfessions: availableProfessions ?? this.availableProfessions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedState &&
        listEquals(other.professionals, professionals) &&
        other.selectedProfessional == selectedProfessional &&
        other.filter == filter &&
        listEquals(other.availableProfessions, availableProfessions) &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.hasMoreData == hasMoreData &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(professionals),
        selectedProfessional,
        filter,
        Object.hashAll(availableProfessions),
        isLoading,
        isLoadingMore,
        hasMoreData,
        error,
      );
}
