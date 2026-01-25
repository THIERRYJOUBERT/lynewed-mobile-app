/// Guests Cubit for managing wedding guests state.
///
/// Handles loading guests, adding guests, and deleting guests.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/my_wedding_repository.dart';
import 'guests_state.dart';

/// Cubit for managing wedding guests state.
///
/// Provides methods for loading guests, adding/deleting guests.
class GuestsCubit extends Cubit<GuestsState> {
  /// Creates a GuestsCubit with the given repository and wedding ID.
  GuestsCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  })  : _repository = repository,
        super(const GuestsState());

  /// The repository for wedding operations.
  final MyWeddingRepository _repository;

  /// The wedding ID for this cubit instance.
  final String weddingId;

  /// Loads all guests for this wedding.
  ///
  /// Emits loading state first, then the loaded guests or error.
  Future<void> loadGuests() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getWeddingGuests(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        guests: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to load guests',
      ));
    }
  }

  /// Adds a new guest.
  ///
  /// On success, adds the new guest to the list.
  /// On failure, emits an error state.
  Future<void> addGuest({
    required String name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.createWeddingGuest(
      weddingId: weddingId,
      name: name,
      email: email,
      phone: phone,
      role: role,
      notes: notes,
    );

    if (result.isSuccess && result.data != null) {
      emit(state.copyWith(
        isLoading: false,
        guests: [...state.guests, result.data!],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to add guest',
      ));
    }
  }

  /// Deletes a guest.
  ///
  /// On success, removes the guest from the list.
  /// On failure, emits an error state.
  Future<void> deleteGuest(String guestId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.deleteWeddingGuest(guestId: guestId);

    if (result.isSuccess) {
      final updatedGuests =
          state.guests.where((g) => g.id != guestId).toList();

      emit(state.copyWith(
        isLoading: false,
        guests: updatedGuests,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to delete guest',
      ));
    }
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
