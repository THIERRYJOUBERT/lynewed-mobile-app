# Story S17: My Wedding - Domain Layer Completion

## Description

En tant que developpeur, je veux completer la couche domain du module My Wedding afin d'avoir une base solide pour toutes les fonctionnalites de gestion de mariage.

## Criteres d'Acceptance (Gherkin)

- [ ] Given le module My Wedding existant When j'analyse `lib/features/my_wedding/domain/` Then je liste les entites manquantes

- [ ] Given les entites existantes When je les verifie Then elles sont completes avec copyWith et tests

- [ ] Given `MyWeddingRepository` When je verifie l'interface Then toutes les operations sont couvertes

- [ ] Given les entities When j'ecris les tests unitaires Then 100% passent

## Fichiers Concernes

### Existants (a verifier)
- `lib/features/my_wedding/domain/entities/wedding_overview.dart`
- `lib/features/my_wedding/domain/entities/wedding_event.dart`
- `lib/features/my_wedding/domain/entities/wedding_expense.dart`
- `lib/features/my_wedding/domain/entities/wedding_guest.dart`
- `lib/features/my_wedding/domain/entities/inspiration_album.dart`
- `lib/features/my_wedding/domain/entities/album_image.dart`
- `lib/features/my_wedding/domain/entities/saved_post.dart`
- `lib/features/my_wedding/domain/entities/wedding_team_chat_info.dart`
- `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart`

### A Creer si Manquants
- `lib/features/my_wedding/my_wedding.dart` - Barrel export
- Tests pour toutes les entites

## Notes Techniques

### Audit Entities Existantes

Verifier que chaque entity a :
1. `const` constructor
2. `copyWith` method
3. `fromJson` factory (si applicable)
4. `toJson` method (si applicable)
5. `==` et `hashCode` ou utiliser `Equatable`

### Exemple Entity Complete
```dart
class WeddingOverview {
  final String id;
  final String brideProfileId;
  final String? name;
  final DateTime? eventDate;
  final String? venueLabel;
  final double? venueLat;
  final double? venueLng;
  final String? locationCountryCode;
  final int? guestCount;
  final int? budgetMin;
  final int? budgetMax;
  final String? currency;
  final String? visibility;
  final int? searchRadiusKm;
  final String? coverImageUrl;
  final String? noteForPros;
  final List<String>? professionsNeeded;
  final int? onboardingStep;
  final String status; // 'draft', 'active', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WeddingOverview({
    required this.id,
    required this.brideProfileId,
    this.name,
    this.eventDate,
    this.venueLabel,
    this.venueLat,
    this.venueLng,
    this.locationCountryCode,
    this.guestCount,
    this.budgetMin,
    this.budgetMax,
    this.currency,
    this.visibility,
    this.searchRadiusKm,
    this.coverImageUrl,
    this.noteForPros,
    this.professionsNeeded,
    this.onboardingStep,
    this.status = 'draft',
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOnboardingComplete => onboardingStep == null;
  bool get hasVenue => venueLabel != null && venueLat != null;
  bool get hasBudget => budgetMin != null || budgetMax != null;

  WeddingOverview copyWith({...});

  factory WeddingOverview.fromJson(Map<String, dynamic> json) {...}
  Map<String, dynamic> toJson() {...}
}
```

### Repository Interface Verification
Le `MyWeddingRepository` existant est deja complet. Verifier qu'il inclut :

```dart
abstract class MyWeddingRepository {
  // Core
  Future<RepositoryResult<WeddingOverview?>> getMyWedding();
  Future<RepositoryResult<String>> createWedding({...});
  Future<RepositoryResult<void>> updateWedding({...});
  Future<RepositoryResult<void>> updateWeddingStatus({...});

  // Onboarding
  Future<RepositoryResult<void>> updateOnboardingData({...});
  Future<RepositoryResult<void>> completeOnboarding({...});

  // Team
  Future<RepositoryResult<List<WeddingTeamMember>>> getWeddingTeam({...});
  Future<RepositoryResult<List<WeddingTeamMember>>> getActiveWeddingTeam({...});
  Future<RepositoryResult<void>> inviteProToWedding({...});
  Future<RepositoryResult<void>> excludeProFromWedding({...});
  Future<RepositoryResult<WeddingTeamChatInfo?>> getWeddingTeamChat({...});

  // Albums
  Future<RepositoryResult<List<InspirationAlbum>>> getInspirationAlbums({...});
  Future<RepositoryResult<InspirationAlbum>> createInspirationAlbum({...});
  Future<RepositoryResult<void>> updateInspirationAlbum({...});
  Future<RepositoryResult<void>> deleteInspirationAlbum({...});

  // Album Images
  Future<RepositoryResult<List<AlbumImage>>> getAlbumImages({...});
  Future<RepositoryResult<AlbumImage>> uploadAlbumImage({...});
  Future<RepositoryResult<void>> deleteAlbumImage({...});

  // Saved Posts
  Future<RepositoryResult<List<SavedPost>>> getSavedPosts({...});
  Future<RepositoryResult<SavedPost>> saveImageToAlbum({...});
  Future<RepositoryResult<void>> removeSavedPost({...});
  Future<RepositoryResult<bool>> isImageSavedInWedding({...});

  // Events (Agenda)
  Future<RepositoryResult<List<WeddingEvent>>> getWeddingEvents({...});
  Future<RepositoryResult<WeddingEvent>> createWeddingEvent({...});
  Future<RepositoryResult<void>> updateWeddingEvent({...});
  Future<RepositoryResult<void>> deleteWeddingEvent({...});
  Future<RepositoryResult<void>> toggleEventStatus({...});

  // Expenses (Budget)
  Future<RepositoryResult<List<WeddingExpense>>> getWeddingExpenses({...});
  Future<RepositoryResult<WeddingExpense>> createWeddingExpense({...});
  Future<RepositoryResult<void>> updateWeddingExpense({...});
  Future<RepositoryResult<void>> deleteWeddingExpense({...});

  // Guests
  Future<RepositoryResult<List<WeddingGuest>>> getWeddingGuests({...});
  Future<RepositoryResult<WeddingGuest>> createWeddingGuest({...});
  Future<RepositoryResult<void>> updateWeddingGuest({...});
  Future<RepositoryResult<void>> deleteWeddingGuest({...});
}
```

## Definition of Done

- [ ] Audit de toutes les entites existantes
- [ ] Ajout de copyWith/fromJson/toJson si manquants
- [ ] Barrel export `my_wedding.dart`
- [ ] Tests unitaires pour chaque entite
- [ ] Documentation
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Faible (completion)
**Risque** : Faible

## Dependances

- S01 : Setup infrastructure

## Stories Dependantes

- S18 : My Wedding - Data layer
- S19-S22 : Presentation stories
