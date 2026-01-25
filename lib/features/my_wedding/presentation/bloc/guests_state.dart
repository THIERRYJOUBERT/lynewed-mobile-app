/// Guests State for GuestsCubit.
///
/// Defines the state for managing wedding guests.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/wedding_guest.dart';

/// State for the guests Cubit.
///
/// Tracks the guests list, loading state, and errors.
@immutable
class GuestsState {
  /// Creates a guests state.
  const GuestsState({
    this.guests = const [],
    this.isLoading = false,
    this.error,
  });

  /// List of all wedding guests.
  final List<WeddingGuest> guests;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message, if any.
  final String? error;

  /// Returns the total number of guests.
  int get totalGuests => guests.length;

  /// Returns guests grouped by role.
  Map<GuestRole, List<WeddingGuest>> get guestsByRole {
    final result = <GuestRole, List<WeddingGuest>>{};
    for (final guest in guests) {
      result.putIfAbsent(guest.role, () => []).add(guest);
    }
    return result;
  }

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  GuestsState copyWith({
    List<WeddingGuest>? guests,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GuestsState(
      guests: guests ?? this.guests,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuestsState &&
        listEquals(other.guests, guests) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(guests),
        isLoading,
        error,
      );
}
