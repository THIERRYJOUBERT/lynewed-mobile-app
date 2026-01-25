/// Wedding Onboarding Cubit for managing onboarding state.
///
/// Handles the wedding onboarding flow with step navigation and data updates.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/my_wedding_repository.dart';
import 'wedding_onboarding_state.dart';

/// Cubit for managing wedding onboarding state.
///
/// Provides methods for navigation, data updates, and state management
/// during the wedding creation onboarding flow.
class WeddingOnboardingCubit extends Cubit<WeddingOnboardingState> {
  /// Creates a WeddingOnboardingCubit with the given repository.
  WeddingOnboardingCubit({required MyWeddingRepository repository})
      : _repository = repository,
        super(const WeddingOnboardingState());

  /// The repository for wedding operations.
  ///
  /// Will be used in future for save operations.
  // ignore: unused_field
  final MyWeddingRepository _repository;

  // ============================================================
  // NAVIGATION
  // ============================================================

  /// Moves to the next step if not at the last step.
  ///
  /// Clears any existing error.
  void nextStep() {
    if (state.isLastStep) return;
    emit(state.copyWith(
      currentStep: state.currentStep + 1,
      clearError: true,
    ));
  }

  /// Moves to the previous step if not at the first step.
  ///
  /// Clears any existing error.
  void previousStep() {
    if (state.isFirstStep) return;
    emit(state.copyWith(
      currentStep: state.currentStep - 1,
      clearError: true,
    ));
  }

  /// Navigates to a specific step.
  ///
  /// Does nothing if [step] is out of valid range (1 to totalSteps).
  void goToStep(int step) {
    if (step < 1 || step > state.totalSteps) return;
    emit(state.copyWith(currentStep: step, clearError: true));
  }

  // ============================================================
  // DATA UPDATES
  // ============================================================

  /// Updates the event date.
  void updateEventDate(DateTime date) {
    emit(state.copyWith(
      data: state.data.copyWith(eventDate: date),
    ));
  }

  /// Updates the venue information.
  void updateVenue({
    required String address,
    double? lat,
    double? lng,
    String? countryCode,
  }) {
    emit(state.copyWith(
      data: state.data.copyWith(
        venueAddress: address,
        lat: lat,
        lng: lng,
        countryCode: countryCode,
      ),
    ));
  }

  /// Updates the list of needed professions.
  void updateProfessions(List<String> professions) {
    emit(state.copyWith(
      data: state.data.copyWith(professionsNeeded: professions),
    ));
  }

  /// Updates the guest count.
  void updateGuestCount(int? count) {
    emit(state.copyWith(
      data: state.data.copyWith(guestCount: count),
    ));
  }

  /// Updates the budget range.
  void updateBudget({int? min, int? max}) {
    emit(state.copyWith(
      data: state.data.copyWith(budgetMin: min, budgetMax: max),
    ));
  }

  /// Updates the visibility setting.
  void updateVisibility(String visibility) {
    emit(state.copyWith(
      data: state.data.copyWith(visibility: visibility),
    ));
  }

  /// Updates the search radius.
  void updateSearchRadius(int radius) {
    emit(state.copyWith(
      data: state.data.copyWith(searchRadius: radius),
    ));
  }

  /// Updates the cover image URL.
  void updateCoverImage(String? url) {
    emit(state.copyWith(
      data: state.data.copyWith(coverImageUrl: url),
    ));
  }

  // ============================================================
  // STATE MANAGEMENT
  // ============================================================

  /// Sets the wedding ID.
  ///
  /// Called after the wedding is created in step 2.
  void setWeddingId(String id) {
    emit(state.copyWith(weddingId: id));
  }

  /// Sets the loading state.
  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }

  /// Sets an error message, or clears it if null.
  void setError(String? message) {
    if (message == null) {
      emit(state.copyWith(clearError: true));
    } else {
      emit(state.copyWith(error: message));
    }
  }

  /// Resets the state to initial values.
  void reset() {
    emit(const WeddingOnboardingState());
  }
}
