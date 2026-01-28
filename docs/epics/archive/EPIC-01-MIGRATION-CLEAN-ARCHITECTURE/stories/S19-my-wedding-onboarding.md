# Story S19: My Wedding - Onboarding Flow

## Description

En tant que developpeur, je veux migrer le flow d'onboarding mariage vers Clean Architecture afin d'avoir un parcours utilisateur fluide et testable.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `WeddingOnboardingPage` existante When je l'analyse Then je comprends les etapes

- [ ] Given le state management When je cree un Cubit Then l'onboarding est gere de maniere reactive

- [ ] Given chaque etape When je la complete Then les donnees sont sauvegardees progressivement

- [ ] Given l'onboarding complete When l'utilisateur termine Then la wedding team chat est creee

- [ ] Given une erreur When elle se produit Then l'utilisateur peut reprendre ou corriger

## Fichiers Concernes

### Existants (a verifier/migrer)
- `lib/features/my_wedding/presentation/pages/wedding_onboarding_page.dart`
- `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart`

### A Creer
- `lib/features/my_wedding/presentation/bloc/wedding_onboarding_cubit.dart`
- `lib/features/my_wedding/presentation/bloc/wedding_onboarding_state.dart`
- `lib/features/my_wedding/presentation/pages/onboarding/` - Pages par etape

### Pages Legacy Reference
- `lib/pages/onboarding/onboarding_brides_wizard/`

## Notes Techniques

### Etapes Onboarding
D'apres le repository, l'onboarding semble avoir ces etapes :
1. **Date & Location** - Event date, venue
2. **Professions** - Professions needed
3. **Guest count** - Number of guests
4. **Budget** - Budget range
5. **Visibility** - Public/private
6. **Search radius** - Geographical preference
7. **Cover image** - Wedding cover
8. **Invite pros** - Invite contacted pros
9. **Complete** - Finalize

### Onboarding State
```dart
class WeddingOnboardingState {
  final int currentStep;
  final int totalSteps;
  final String? weddingId;
  final OnboardingData data;
  final bool isLoading;
  final String? error;
  final List<ContactedPro> contactedPros;
  final List<String> selectedProIds;

  const WeddingOnboardingState({
    this.currentStep = 1,
    this.totalSteps = 9,
    this.weddingId,
    this.data = const OnboardingData(),
    this.isLoading = false,
    this.error,
    this.contactedPros = const [],
    this.selectedProIds = const [],
  });

  bool get isFirstStep => currentStep == 1;
  bool get isLastStep => currentStep == totalSteps;
  double get progress => currentStep / totalSteps;

  WeddingOnboardingState copyWith({...});
}

class OnboardingData {
  final DateTime? eventDate;
  final String? venueName;
  final String? venueAddress;
  final double? lat;
  final double? lng;
  final String? countryCode;
  final List<String> professionsNeeded;
  final int? guestCount;
  final double? budgetMin;
  final double? budgetMax;
  final String visibility;
  final int searchRadius;
  final String? coverImageUrl;

  const OnboardingData({
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
    this.visibility = 'visible',
    this.searchRadius = 50,
    this.coverImageUrl,
  });

  OnboardingData copyWith({...});
}
```

### Onboarding Cubit
```dart
class WeddingOnboardingCubit extends Cubit<WeddingOnboardingState> {
  final MyWeddingRepository _repository;

  WeddingOnboardingCubit({required MyWeddingRepository repository})
      : _repository = repository,
        super(const WeddingOnboardingState());

  Future<void> initialize() async {
    // Check if wedding already exists (resume onboarding)
    final result = await _repository.getMyWedding();
    result.when(
      success: (wedding) {
        if (wedding != null && wedding.onboardingStep != null) {
          emit(state.copyWith(
            weddingId: wedding.id,
            currentStep: wedding.onboardingStep!,
            data: OnboardingData(
              eventDate: wedding.eventDate,
              venueAddress: wedding.venueLabel,
              lat: wedding.venueLat,
              lng: wedding.venueLng,
              professionsNeeded: wedding.professionsNeeded ?? [],
              guestCount: wedding.guestCount,
              budgetMin: wedding.budgetMin?.toDouble(),
              budgetMax: wedding.budgetMax?.toDouble(),
              visibility: wedding.visibility ?? 'visible',
              searchRadius: wedding.searchRadiusKm ?? 50,
              coverImageUrl: wedding.coverImageUrl,
            ),
          ));
        }
      },
      failure: (_) {},
    );
  }

  Future<void> nextStep() async {
    if (state.isLastStep) {
      await _completeOnboarding();
      return;
    }

    // Save current step data
    await _saveStepData();

    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void previousStep() {
    if (!state.isFirstStep) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _saveStepData() async {
    emit(state.copyWith(isLoading: true));

    if (state.weddingId == null) {
      // Create wedding on first save
      final result = await _repository.createWedding(
        eventDate: state.data.eventDate!,
        lat: state.data.lat!,
        lng: state.data.lng!,
        venueName: state.data.venueName,
        venueAddress: state.data.venueAddress,
        countryCode: state.data.countryCode,
      );

      result.when(
        success: (weddingId) {
          emit(state.copyWith(
            weddingId: weddingId,
            isLoading: false,
          ));
        },
        failure: (error) {
          emit(state.copyWith(isLoading: false, error: error));
        },
      );
    } else {
      // Update existing wedding
      await _repository.updateOnboardingData(
        weddingId: state.weddingId!,
        data: state.data,
      );
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _completeOnboarding() async {
    emit(state.copyWith(isLoading: true));

    // Invite selected pros
    for (final proId in state.selectedProIds) {
      await _repository.inviteProToWedding(
        weddingId: state.weddingId!,
        proProfileId: proId,
      );
    }

    // Complete onboarding
    final result = await _repository.completeOnboarding(
      weddingId: state.weddingId!,
    );

    result.when(
      success: (_) {
        emit(state.copyWith(isLoading: false));
        // Navigate to home handled by listener
      },
      failure: (error) {
        emit(state.copyWith(isLoading: false, error: error));
      },
    );
  }

  // Update methods for each step
  void updateEventDate(DateTime date) {
    emit(state.copyWith(data: state.data.copyWith(eventDate: date)));
  }

  void updateVenue({required String address, required double lat, required double lng}) {
    emit(state.copyWith(data: state.data.copyWith(
      venueAddress: address,
      lat: lat,
      lng: lng,
    )));
  }

  void updateProfessions(List<String> professions) {
    emit(state.copyWith(data: state.data.copyWith(professionsNeeded: professions)));
  }

  // ... autres methodes update
}
```

### Step Widget Example
```dart
class OnboardingDateStep extends StatelessWidget {
  const OnboardingDateStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeddingOnboardingCubit, WeddingOnboardingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHEN IS YOUR WEDDING?',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Date picker
            CalendarDatePicker(
              initialDate: state.data.eventDate ?? DateTime.now().add(const Duration(days: 180)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
              onDateChanged: (date) {
                context.read<WeddingOnboardingCubit>().updateEventDate(date);
              },
            ),
          ],
        );
      },
    );
  }
}
```

## Definition of Done

- [ ] Onboarding Cubit implemente
- [ ] Toutes les etapes migrees
- [ ] Sauvegarde progressive
- [ ] Reprise d'onboarding interrompu
- [ ] Integration place search (Google Places)
- [ ] Tests bloc
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Moyen (UX critique)

## Dependances

- S03 : Design system
- S04 : Navigation
- S17 : My Wedding - Domain
- S18 : My Wedding - Data

## Stories Dependantes

- S16 : Startup gate (redirection)
