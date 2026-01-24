# Story S04: Documentation API (Services et Repositories)

**Epic:** EPIC-04-DOCUMENTATION
**ID:** S04
**Points:** 5
**Priorite:** P2 - Important
**Statut:** A faire
**Dependances:** S02 (ARCHITECTURE)

---

## Description

En tant que **developpeur** travaillant sur Lynewed,
je veux une **documentation des services et repositories principaux**
afin de **comprendre rapidement comment utiliser les APIs internes du projet sans lire tout le code source**.

---

## Criteres d'Acceptance

- [ ] Documentation des repositories principaux (Map, Chat, MyWedding)
- [ ] Documentation des services partages (`lib/core/services/`)
- [ ] Exemples d'utilisation pour chaque service/repository
- [ ] Documentation des Edge Functions Supabase
- [ ] Index navigable de toutes les APIs

---

## Contenu Attendu

### Structure des Fichiers a Creer

```
docs/api/
├── INDEX.md                    # Index de navigation
├── repositories/
│   ├── map-repository.md       # MapRepository
│   ├── chat-repository.md      # ChatRepository
│   └── my-wedding-repository.md # MyWeddingRepository
├── services/
│   ├── currency-service.md     # CurrencyService
│   ├── distance-service.md     # DistanceService
│   └── unread-counter-service.md # UnreadCounterService
└── edge-functions/
    └── overview.md             # Vue d'ensemble Edge Functions
```

### 1. INDEX.md

```markdown
# API Documentation

## Repositories (Domain Layer)
- [MapRepository](./repositories/map-repository.md) - Gestion des marqueurs et filtres carte
- [ChatRepository](./repositories/chat-repository.md) - Messagerie et conversations
- [MyWeddingRepository](./repositories/my-wedding-repository.md) - Suite mariage (agenda, budget, invites)

## Services (Core Layer)
- [CurrencyService](./services/currency-service.md) - Conversion devises
- [DistanceService](./services/distance-service.md) - Calcul distances
- [UnreadCounterService](./services/unread-counter-service.md) - Compteur messages non lus

## Backend (Supabase)
- [Edge Functions](./edge-functions/overview.md) - Fonctions serverless
```

### 2. Format Documentation Repository

Chaque fichier repository doit suivre ce format:

```markdown
# [Repository Name]

**Location:** `lib/features/[module]/domain/repositories/`
**Implementation:** `lib/features/[module]/data/repositories/`

## Description
[Description courte du role du repository]

## Interface

```dart
abstract class [Repository] {
  Future<List<Entity>> getAll();
  Future<Entity?> getById(String id);
  // ...
}
```

## Methodes

### `getAll()`
Recupere tous les [entities].

**Parametres:** Aucun
**Retour:** `Future<List<Entity>>`
**Erreurs:** Throws `Exception` si [condition]

**Exemple:**
```dart
final items = await repository.getAll();
```

### `getById(String id)`
[Description]

**Parametres:**
- `id` (String): Identifiant unique

**Retour:** `Future<Entity?>`

**Exemple:**
```dart
final item = await repository.getById('abc-123');
if (item != null) {
  // ...
}
```

## Utilisation avec Cubit

```dart
class MyCubit extends Cubit<MyState> {
  final MyRepository _repository;

  MyCubit(this._repository) : super(MyState.initial());

  Future<void> loadData() async {
    emit(state.copyWith(loading: true));
    try {
      final data = await _repository.getAll();
      emit(state.copyWith(data: data, loading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }
}
```

## Notes
- [Notes importantes sur l'utilisation]
```

### 3. Repositories a Documenter

#### MapRepository
- `getMarkersInBounds(bounds)` - Marqueurs dans une zone
- `getMarkerDetails(id, type)` - Details d'un marqueur
- `createWedding(data)` - Creer un mariage
- `createAlert(data)` - Creer une alerte

#### ChatRepository (existant dans le code)
- `getConversations()` - Liste des conversations
- `getMessages(roomId)` - Messages d'une room
- `sendMessage(roomId, content)` - Envoyer message
- `markAsRead(roomId)` - Marquer comme lu

#### MyWeddingRepository
- `getWeddingOverview()` - Vue d'ensemble mariage
- `getEvents()` / `createEvent()` - Agenda
- `getExpenses()` / `createExpense()` - Budget
- `getGuests()` / `createGuest()` - Invites
- `getAlbums()` / `createAlbum()` - Inspirations

### 4. Services a Documenter

#### CurrencyService (`lib/core/services/currency_service.dart`)
```dart
// Convertir un montant
final eurAmount = CurrencyService.convert(
  amount: 1000,
  from: 'USD',
  to: 'EUR',
);

// Obtenir le symbole
final symbol = CurrencyService.getSymbol('EUR'); // "€"
```

#### DistanceService (`lib/core/services/distance_service.dart`)
```dart
// Calculer distance entre deux points
final distance = DistanceService.calculate(
  from: LatLng(48.8566, 2.3522), // Paris
  to: LatLng(45.7640, 4.8357),   // Lyon
);
// Returns: 391.5 (km)
```

#### UnreadCounterService (`lib/core/services/unread_counter_service.dart`)
```dart
// Ecouter les changements
UnreadCounterService.stream.listen((count) {
  print('Unread messages: $count');
});

// Obtenir valeur actuelle
final count = UnreadCounterService.currentCount;
```

### 5. Edge Functions

#### Vue d'Ensemble
| Fonction | Description | Trigger |
|----------|-------------|---------|
| `agora_token_issue` | Genere token video Agora | HTTP POST |
| `create-or-sync-user` | Sync profil apres auth | Auth trigger |
| `delete-user` | Suppression compte + donnees | HTTP POST |
| `notifications_outbox_drain` | Envoie push FCM | Cron |
| `send-verification-email` | Email de verification | HTTP POST |

#### Appel depuis Flutter
```dart
final response = await SupaFlow.client.functions.invoke(
  'agora_token_issue',
  body: {
    'channelName': 'room-123',
    'uid': currentUser.uid,
  },
);
final token = response.data['token'];
```

---

## Notes Techniques

### Sources d'Information
- `lib/features/*/domain/repositories/` - Interfaces repositories
- `lib/features/*/data/repositories/` - Implementations
- `lib/core/services/` - Services partages
- `supabase/functions/` - Edge Functions

### Points d'Attention
- Documenter uniquement les APIs publiques (interfaces)
- Inclure exemples realistes
- Ne pas dupliquer le code - referencer les fichiers
- Mettre a jour quand l'API change

---

## Definition of Done

- [ ] INDEX.md cree avec tous les liens
- [ ] 3 repositories documentes (Map, Chat, MyWedding)
- [ ] 3 services documentes
- [ ] Edge Functions documentees (overview)
- [ ] Exemples de code fonctionnels
- [ ] Review par developpeur utilisant ces APIs

---

## Estimation

| Tache | Temps estime |
|-------|--------------|
| INDEX.md + structure | 30min |
| MapRepository | 1h |
| ChatRepository | 1h |
| MyWeddingRepository | 1h |
| Services (3) | 1h |
| Edge Functions overview | 30min |
| Review | 30min |
| **Total** | **5h30** |
