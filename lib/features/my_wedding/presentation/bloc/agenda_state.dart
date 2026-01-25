/// Agenda State for AgendaCubit.
///
/// Defines the state for managing wedding events/tasks in the agenda.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/wedding_event.dart';

/// State for the agenda Cubit.
///
/// Tracks the events list, loading state, and errors.
@immutable
class AgendaState {
  /// Creates an agenda state.
  const AgendaState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  /// List of all wedding events.
  final List<WeddingEvent> events;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message, if any.
  final String? error;

  /// Returns events that are in the future.
  List<WeddingEvent> get upcomingEvents =>
      events.where((e) => e.eventDate.isAfter(DateTime.now())).toList();

  /// Returns events that are in the past.
  List<WeddingEvent> get pastEvents =>
      events.where((e) => e.eventDate.isBefore(DateTime.now())).toList();

  /// Returns events with pending status.
  List<WeddingEvent> get pendingEvents =>
      events.where((e) => e.status == EventStatus.pending).toList();

  /// Returns events with done status.
  List<WeddingEvent> get completedEvents =>
      events.where((e) => e.status == EventStatus.done).toList();

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  AgendaState copyWith({
    List<WeddingEvent>? events,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AgendaState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgendaState &&
        listEquals(other.events, events) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(events),
        isLoading,
        error,
      );
}
