/// Agenda Cubit for managing wedding events state.
///
/// Handles loading events, creating events, toggling event status,
/// and deleting events.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wedding_event.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import 'agenda_state.dart';

/// Cubit for managing wedding events/agenda state.
///
/// Provides methods for loading events, creating/deleting events,
/// and toggling event status.
class AgendaCubit extends Cubit<AgendaState> {
  /// Creates an AgendaCubit with the given repository and wedding ID.
  AgendaCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  })  : _repository = repository,
        super(const AgendaState());

  /// The repository for wedding operations.
  final MyWeddingRepository _repository;

  /// The wedding ID for this cubit instance.
  final String weddingId;

  /// Loads all events for this wedding.
  ///
  /// Emits loading state first, then the loaded events or error.
  Future<void> loadEvents() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getWeddingEvents(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        events: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to load events',
      ));
    }
  }

  /// Creates a new wedding event.
  ///
  /// On success, adds the new event to the list.
  /// On failure, emits an error state.
  Future<void> createEvent({
    required String title,
    required DateTime eventDate,
    String? description,
    DateTime? eventEndDate,
    String? location,
    String? linkedProId,
    bool isPublic = false,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.createWeddingEvent(
      weddingId: weddingId,
      title: title,
      eventDate: eventDate,
      description: description,
      eventEndDate: eventEndDate,
      location: location,
      linkedProId: linkedProId,
      isPublic: isPublic,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        isLoading: false,
        events: [...state.events, result.data!],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to create event',
      ));
    }
  }

  /// Toggles an event's status between pending and done.
  ///
  /// On success, updates the event in the list locally.
  /// On failure, emits an error state.
  Future<void> toggleEventStatus(String eventId, String currentStatus) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.toggleEventStatus(
      eventId: eventId,
      currentStatus: currentStatus,
    );

    if (result.isSuccess) {
      // Update the event locally
      final newStatus =
          currentStatus == 'pending' ? EventStatus.done : EventStatus.pending;
      final updatedEvents = state.events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(status: newStatus);
        }
        return e;
      }).toList();

      emit(state.copyWith(
        isLoading: false,
        events: updatedEvents,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to toggle event status',
      ));
    }
  }

  /// Deletes an event.
  ///
  /// On success, removes the event from the list.
  /// On failure, emits an error state.
  Future<void> deleteEvent(String eventId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.deleteWeddingEvent(eventId: eventId);

    if (result.isSuccess) {
      final updatedEvents = state.events.where((e) => e.id != eventId).toList();

      emit(state.copyWith(
        isLoading: false,
        events: updatedEvents,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to delete event',
      ));
    }
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
