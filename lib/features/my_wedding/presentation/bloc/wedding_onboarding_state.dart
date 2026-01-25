/// Wedding Onboarding State for WeddingOnboardingCubit.
///
/// Defines the state and data classes for the wedding onboarding flow.
library;

import 'package:flutter/foundation.dart';

/// Onboarding data for the Cubit state.
///
/// Holds all the data collected during the wedding onboarding process.
/// Separate from the repository's OnboardingData to maintain clean separation.
@immutable
class CubitOnboardingData {
  /// Creates onboarding data with optional values.
  const CubitOnboardingData({
    this.eventDate,
    this.venueName,
    this.venueAddress,
    this.lat,
    this.lng,
    this.countryCode,
    this.professionsNeeded = const [],
    this.guestCount,
    this.budgetMin,
    this.budgetMax,
    this.visibility = 'private',
    this.searchRadius = 50,
    this.coverImageUrl,
  });

  /// The wedding date.
  final DateTime? eventDate;

  /// The venue name (optional).
  final String? venueName;

  /// The venue address.
  final String? venueAddress;

  /// The venue latitude.
  final double? lat;

  /// The venue longitude.
  final double? lng;

  /// The country code (ISO 3166-1 alpha-2).
  final String? countryCode;

  /// List of profession types needed for the wedding.
  final List<String> professionsNeeded;

  /// Estimated guest count.
  final int? guestCount;

  /// Minimum budget.
  final int? budgetMin;

  /// Maximum budget.
  final int? budgetMax;

  /// Visibility setting: 'private' or 'visible_to_pros'.
  final String visibility;

  /// Search radius in kilometers for finding professionals.
  final int searchRadius;

  /// URL of the wedding cover image.
  final String? coverImageUrl;

  /// Creates a copy with updated values.
  ///
  /// Use [setEventDateNull] to explicitly set eventDate to null.
  CubitOnboardingData copyWith({
    DateTime? eventDate,
    bool setEventDateNull = false,
    String? venueName,
    String? venueAddress,
    double? lat,
    double? lng,
    String? countryCode,
    List<String>? professionsNeeded,
    int? guestCount,
    int? budgetMin,
    int? budgetMax,
    String? visibility,
    int? searchRadius,
    String? coverImageUrl,
  }) {
    return CubitOnboardingData(
      eventDate: setEventDateNull ? null : (eventDate ?? this.eventDate),
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      countryCode: countryCode ?? this.countryCode,
      professionsNeeded: professionsNeeded ?? this.professionsNeeded,
      guestCount: guestCount ?? this.guestCount,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      visibility: visibility ?? this.visibility,
      searchRadius: searchRadius ?? this.searchRadius,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CubitOnboardingData &&
        other.eventDate == eventDate &&
        other.venueName == venueName &&
        other.venueAddress == venueAddress &&
        other.lat == lat &&
        other.lng == lng &&
        other.countryCode == countryCode &&
        listEquals(other.professionsNeeded, professionsNeeded) &&
        other.guestCount == guestCount &&
        other.budgetMin == budgetMin &&
        other.budgetMax == budgetMax &&
        other.visibility == visibility &&
        other.searchRadius == searchRadius &&
        other.coverImageUrl == coverImageUrl;
  }

  @override
  int get hashCode => Object.hash(
        eventDate,
        venueName,
        venueAddress,
        lat,
        lng,
        countryCode,
        Object.hashAll(professionsNeeded),
        guestCount,
        budgetMin,
        budgetMax,
        visibility,
        searchRadius,
        coverImageUrl,
      );
}

/// State for the wedding onboarding Cubit.
///
/// Tracks the current step, data, loading state, and errors.
@immutable
class WeddingOnboardingState {
  /// Creates an onboarding state.
  const WeddingOnboardingState({
    this.currentStep = 1,
    this.totalSteps = 7,
    this.weddingId,
    this.data = const CubitOnboardingData(),
    this.isLoading = false,
    this.error,
  });

  /// The current step (1-indexed).
  final int currentStep;

  /// The total number of steps.
  final int totalSteps;

  /// The wedding ID (set after creation in step 2).
  final String? weddingId;

  /// The onboarding data collected so far.
  final CubitOnboardingData data;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message, if any.
  final String? error;

  /// Returns true if on the first step.
  bool get isFirstStep => currentStep == 1;

  /// Returns true if on the last step.
  bool get isLastStep => currentStep == totalSteps;

  /// Returns the progress as a fraction (0.0 to 1.0).
  double get progress => currentStep / totalSteps;

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  WeddingOnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    String? weddingId,
    CubitOnboardingData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WeddingOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      weddingId: weddingId ?? this.weddingId,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingOnboardingState &&
        other.currentStep == currentStep &&
        other.totalSteps == totalSteps &&
        other.weddingId == weddingId &&
        other.data == data &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        currentStep,
        totalSteps,
        weddingId,
        data,
        isLoading,
        error,
      );
}
