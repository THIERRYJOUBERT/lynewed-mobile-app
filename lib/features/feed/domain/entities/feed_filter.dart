/// Feed Filter entity for Feed feature
///
/// Represents filter and sort options for the professional portfolio feed.
library;

import 'package:flutter/foundation.dart';

/// Sort options for the feed
enum FeedSortBy {
  recent,
  popular,
  alphabetical;

  /// Display-friendly name for the sort option
  String get displayName {
    switch (this) {
      case FeedSortBy.recent:
        return 'Most recent';
      case FeedSortBy.popular:
        return 'Most popular';
      case FeedSortBy.alphabetical:
        return 'A to Z';
    }
  }
}

/// Feed Filter entity
@immutable
class FeedFilter {
  const FeedFilter({
    this.professions = const [],
    this.locationQuery,
    this.sortBy = FeedSortBy.recent,
  });

  /// List of profession types to filter by
  final List<String> professions;

  /// Location query string for filtering
  final String? locationQuery;

  /// Sort order
  final FeedSortBy sortBy;

  /// Whether any filters are active (non-default)
  bool get hasFilters {
    return professions.isNotEmpty ||
        (locationQuery != null && locationQuery!.isNotEmpty) ||
        sortBy != FeedSortBy.recent;
  }

  /// Count of active filters
  int get activeFilterCount {
    int count = professions.length;
    if (locationQuery != null && locationQuery!.isNotEmpty) count++;
    if (sortBy != FeedSortBy.recent) count++;
    return count;
  }

  /// Create a copy with updated values
  FeedFilter copyWith({
    List<String>? professions,
    String? locationQuery,
    FeedSortBy? sortBy,
    bool clearLocation = false,
  }) {
    return FeedFilter(
      professions: professions ?? this.professions,
      locationQuery:
          clearLocation ? null : (locationQuery ?? this.locationQuery),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Add a profession to the filter
  FeedFilter addProfession(String profession) {
    if (professions.contains(profession)) return this;
    return copyWith(professions: [...professions, profession]);
  }

  /// Remove a profession from the filter
  FeedFilter removeProfession(String profession) {
    return copyWith(
      professions: professions.where((p) => p != profession).toList(),
    );
  }

  /// Toggle a profession in the filter
  FeedFilter toggleProfession(String profession) {
    if (professions.contains(profession)) {
      return removeProfession(profession);
    }
    return addProfession(profession);
  }

  /// Reset all filters to defaults
  FeedFilter reset() {
    return const FeedFilter();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedFilter &&
        listEquals(other.professions, professions) &&
        other.locationQuery == locationQuery &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(professions),
        locationQuery,
        sortBy,
      );

  @override
  String toString() =>
      'FeedFilter(professions: $professions, location: $locationQuery, sortBy: ${sortBy.name})';
}
