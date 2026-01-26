# MyWeddingRepository

**Location:** `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart`
**Implementation:** `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart`

---

## Description

Repository complet pour la suite mariage (Bride). Gère l'onboarding, les détails du mariage, l'équipe de pros, les albums d'inspiration, l'agenda des événements, le budget et la liste d'invités.

---

## Interface Complète

```dart
abstract class MyWeddingRepository {
  // Wedding Core
  Future<RepositoryResult<WeddingOverview?>> getMyWedding();
  Future<RepositoryResult<String>> createWedding({...});
  Future<RepositoryResult<void>> updateOnboardingData({...});
  Future<RepositoryResult<void>> completeOnboarding({...});
  Future<RepositoryResult<void>> updateWedding({...});
  Future<RepositoryResult<void>> updateWeddingStatus({...});

  // Wedding Team
  Future<RepositoryResult<List<ContactedPro>>> getContactedPros();
  Future<RepositoryResult<void>> inviteProToWedding({...});
  Future<RepositoryResult<void>> excludeProFromWedding({...});
  Future<RepositoryResult<List<WeddingTeamMember>>> getWeddingTeam({...});
  Future<RepositoryResult<List<WeddingTeamMember>>> getActiveWeddingTeam({...});
  Future<RepositoryResult<WeddingTeamChatInfo?>> getWeddingTeamChat({...});

  // Inspiration Albums
  Future<RepositoryResult<List<InspirationAlbum>>> getInspirationAlbums({...});
  Future<RepositoryResult<InspirationAlbum>> createInspirationAlbum({...});
  Future<RepositoryResult<void>> updateInspirationAlbum({...});
  Future<RepositoryResult<void>> deleteInspirationAlbum({...});

  // Album Images
  Future<RepositoryResult<List<AlbumImage>>> getAlbumImages({...});
  Future<RepositoryResult<AlbumImage>> uploadAlbumImage({...});
  Future<RepositoryResult<void>> deleteAlbumImage({...});

  // Saved Posts (from Feed)
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

---

## Méthodes Principales

### `getMyWedding()`

Récupère l'aperçu du mariage de l'utilisateur courant.

**Retour:** `Future<RepositoryResult<WeddingOverview?>>`

**Exemple:**
```dart
final result = await repository.getMyWedding();
if (result.isSuccess && result.data != null) {
  final wedding = result.data!;
  print('Mariage: ${wedding.name}');
  print('Date: ${wedding.eventDate}');
  print('Budget: ${wedding.budgetMin} - ${wedding.budgetMax}');
}
```

---

### `createWedding()`

Crée un nouveau mariage pendant l'onboarding (étape 2).

**Paramètres:**
- `eventDate` (DateTime): Date du mariage
- `lat`, `lng` (double): Coordonnées du lieu
- `venueName`, `venueAddress`, `countryCode` (String?): Détails du lieu

**Retour:** `Future<RepositoryResult<String>>` - ID du mariage créé

**Exemple:**
```dart
final result = await repository.createWedding(
  eventDate: DateTime(2025, 6, 15),
  lat: 48.8566,
  lng: 2.3522,
  venueName: 'Château de Versailles',
  venueAddress: 'Versailles, France',
  countryCode: 'FR',
);

if (result.isSuccess) {
  print('Mariage créé: ${result.data}');
}
```

---

### `updateOnboardingData()`

Met à jour les données pendant l'onboarding (étapes 3-8).

**Exemple:**
```dart
await repository.updateOnboardingData(
  weddingId: 'wedding-123',
  data: OnboardingData(
    professionsNeeded: ['PHOTOGRAPHER', 'FILMMAKER', 'PLANNER'],
    guestCount: 150,
    budgetMin: 15000,
    budgetMax: 30000,
    visibility: 'visible_to_pros',
    onboardingStep: 5,
  ),
);
```

---

### `getWeddingTeam()`

Récupère les membres de l'équipe du mariage.

**Exemple:**
```dart
final result = await repository.getWeddingTeam(weddingId: 'wedding-123');
if (result.isSuccess) {
  for (final member in result.data!) {
    print('${member.displayName} - ${member.profession}');
    print('Status: ${member.status}'); // active, left, excluded
  }
}
```

---

### `inviteProToWedding()`

Invite un professionnel à rejoindre l'équipe.

**Exemple:**
```dart
await repository.inviteProToWedding(
  weddingId: 'wedding-123',
  proProfileId: 'pro-456',
);
```

---

### `createInspirationAlbum()`

Crée un album d'inspiration.

**Exemple:**
```dart
final result = await repository.createInspirationAlbum(
  weddingId: 'wedding-123',
  name: 'Décoration',
  category: 'decor',
  isPrivate: false, // visible par l'équipe
);
```

---

### `saveImageToAlbum()`

Sauvegarde une image du feed dans un album.

**Exemple:**
```dart
await repository.saveImageToAlbum(
  albumId: 'album-123',
  imageUrl: 'https://storage.../image.jpg',
  sourceProfileId: 'pro-456', // Pro d'origine
);
```

---

### `createWeddingEvent()`

Crée un événement dans l'agenda.

**Exemple:**
```dart
final result = await repository.createWeddingEvent(
  weddingId: 'wedding-123',
  title: 'Essayage robe',
  eventDate: DateTime(2025, 3, 15, 14, 0),
  description: 'RDV chez la couturière',
  linkedProId: 'pro-designer-123',
  isPublic: true, // visible par l'équipe
);
```

---

### `createWeddingExpense()`

Crée une dépense dans le budget.

**Exemple:**
```dart
final result = await repository.createWeddingExpense(
  weddingId: 'wedding-123',
  category: 'photographer',
  amount: 3500,
  currencyCode: 'EUR',
  description: 'Forfait photo complet',
  status: 'partial', // pending, partial, paid
  paidAmount: 1000, // acompte
  linkedProId: 'pro-photo-123',
);
```

---

### `createWeddingGuest()`

Ajoute un invité.

**Exemple:**
```dart
await repository.createWeddingGuest(
  weddingId: 'wedding-123',
  name: 'Marie Dupont',
  email: 'marie@example.com',
  role: 'bridesmaid',
  notes: 'Témoin côté mariée',
);
```

---

## Classes de Support

### WeddingTeamMember

```dart
class WeddingTeamMember {
  final String profileId;
  final String displayName;
  final String? avatarUrl;
  final String? profession;
  final String status; // 'active', 'left', 'excluded'
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final String? leftReason;

  bool get isActive => status == 'active';
}
```

### OnboardingData

```dart
class OnboardingData {
  final DateTime? eventDate;
  final String? venueName;
  final double? lat;
  final double? lng;
  final List<String>? professionsNeeded;
  final int? guestCount;
  final double? budgetMin;
  final double? budgetMax;
  final String? visibility;
  final int? onboardingStep;
}
```

---

## Utilisation avec Cubit

```dart
class MyWeddingCubit extends Cubit<MyWeddingState> {
  final MyWeddingRepository _repository;

  MyWeddingCubit(this._repository) : super(MyWeddingState.initial());

  Future<void> loadWedding() async {
    emit(state.copyWith(loading: true));

    final result = await _repository.getMyWedding();
    if (result.isSuccess) {
      emit(state.copyWith(wedding: result.data, loading: false));
    } else {
      emit(state.copyWith(error: result.error, loading: false));
    }
  }

  Future<void> loadAlbums() async {
    final result = await _repository.getInspirationAlbums(
      weddingId: state.wedding!.id,
    );
    if (result.isSuccess) {
      emit(state.copyWith(albums: result.data));
    }
  }

  Future<void> addExpense(String category, double amount) async {
    await _repository.createWeddingExpense(
      weddingId: state.wedding!.id,
      category: category,
      amount: amount,
      currencyCode: state.wedding!.currency ?? 'EUR',
    );
    // Recharger les dépenses
    await loadExpenses();
  }
}
```

---

## Notes

- Un seul mariage actif par bride
- L'onboarding comporte 9 étapes (`onboarding_step: 1-9`)
- `completeOnboarding()` crée automatiquement le chat Wedding Team
- Les albums peuvent être privés (bride only) ou partagés (équipe)
- Les événements publics sont visibles par les pros de l'équipe
