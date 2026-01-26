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

- [ ] Documentation des **11 repositories** existants (voir liste complete ci-dessous)
- [ ] Documentation des **5 services** partages (`lib/core/services/`)
- [ ] Exemples d'utilisation pour chaque service/repository
- [ ] Documentation des **16 Edge Functions** Supabase
- [ ] Index navigable de toutes les APIs

> **Note**: Le scope a ete elargi apres audit du codebase reel.

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

### 3. Repositories a Documenter (11 repositories)

> **Localisation**: `lib/features/[module]/domain/repositories/` (interface)
> **Implementation**: `lib/features/[module]/data/repositories/` (impl)

#### Repositories Priorite 1 (Core Business)

| Repository | Module | Description |
|------------|--------|-------------|
| `MapRepository` | map/ | Marqueurs, filtres, geolocalisation |
| `ChatRepository` | chat/ | Conversations, messages, moderation |
| `MyWeddingRepository` | my_wedding/ | Agenda, budget, invites, albums |

#### Repositories Priorite 2 (Features)

| Repository | Module | Description |
|------------|--------|-------------|
| `AuthRepository` | auth/ | Login, signup, password reset |
| `NotificationRepository` | notifications/ | Push, in-app notifications |
| `VideoCallRepository` | video_call/ | Sessions Agora, tokens |
| `WeddingsHubRepository` | weddings_hub_pro/ | Hub mariages (Pro) |
| `DashboardRepository` | dashboard/ | Alertes, overview |

#### Repositories Priorite 3 (Support)

| Repository | Module | Description |
|------------|--------|-------------|
| `ContactRepository` | - | Gestion contacts |
| `ContentRepository` | content/ | Articles, inspirations |
| `FeedRepository` | feed/ | Fil d'actualite |

#### Exemple MapRepository
```dart
abstract class MapRepository {
  Future<List<MapMarker>> getMarkersInBounds(LatLngBounds bounds);
  Future<MarkerDetails?> getMarkerDetails(String id, MarkerType type);
  Future<void> createWedding(WeddingData data);
  Future<void> createAlert(AlertData data);
}
```

### 4. Services a Documenter (5 services)

> **Localisation**: `lib/core/services/`

| Service | Fichier | Description |
|---------|---------|-------------|
| `CurrencyService` | currency_service.dart | Conversion devises, symboles |
| `DistanceService` | distance_service.dart | Calcul distances geographiques |
| `UnreadCounterService` | unread_counter_service.dart | Compteur messages non lus |
| `AppBadgeService` | app_badge_service.dart | Badge icone app (notifications) |
| `IncomingCallService` | incoming_call_service.dart | Gestion appels entrants Agora |

#### CurrencyService
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

#### DistanceService
```dart
// Calculer distance entre deux points
final distance = DistanceService.calculate(
  from: LatLng(48.8566, 2.3522), // Paris
  to: LatLng(45.7640, 4.8357),   // Lyon
);
// Returns: 391.5 (km)
```

#### UnreadCounterService
```dart
// Ecouter les changements
UnreadCounterService.stream.listen((count) {
  print('Unread messages: $count');
});

// Obtenir valeur actuelle
final count = UnreadCounterService.currentCount;
```

#### AppBadgeService
```dart
// Mettre a jour le badge de l'app
await AppBadgeService.updateBadge(count: 5);
await AppBadgeService.clearBadge();
```

#### IncomingCallService
```dart
// Gerer un appel entrant
IncomingCallService.onIncomingCall.listen((call) {
  // Afficher UI d'appel entrant
});
```

### 5. Edge Functions (16 fonctions)

> **Localisation**: `supabase/functions/`

#### Vue d'Ensemble Complete
| Fonction | Description | Trigger |
|----------|-------------|---------|
| `account_delete` | Suppression compte complet | HTTP POST |
| `agora_token_issue` | Genere token video Agora | HTTP POST |
| `alerts_housekeeping` | Nettoyage alertes expirees | Cron |
| `create-or-sync-user` | Sync profil apres auth | Auth trigger |
| `delete-user` | Suppression donnees utilisateur | HTTP POST |
| `notifications_outbox_drain` | Envoie push FCM | Cron |
| `recent_locations_cleanup` | Nettoyage localisations | Cron |
| `send-broadcast-notification` | Notifications broadcast | HTTP POST |
| `send-ticket-reply` | Reponses tickets support | HTTP POST |
| `send-verification-email` | Email de verification | HTTP POST |
| `sync-professional-profile` | Sync profils pros | HTTP POST |
| `sync-professional-to-app` | Sync pros vers app | Webhook |
| `sync-wed-articles-to-app` | Sync articles mariage | Webhook |
| `sync-wedding-article` | Sync article individuel | HTTP POST |
| `upload-professional-images` | Upload images pros | HTTP POST |
| `video_sessions_cleanup` | Nettoyage sessions video | Cron |

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
- [ ] **11 repositories** documentes (priorite 1-3)
- [ ] **5 services** documentes
- [ ] **16 Edge Functions** documentees (overview + details)
- [ ] Exemples de code fonctionnels
- [ ] Review par developpeur utilisant ces APIs

> **Note**: Scope elargi suite a audit codebase. Prioriser P1 si temps limite.

---

## Estimation

| Tache | Effort |
|-------|--------|
| INDEX.md + structure | Faible |
| Repositories P1 (3) | Moyen |
| Repositories P2 (5) | Moyen |
| Repositories P3 (3) | Faible |
| Services (5) | Moyen |
| Edge Functions (16) | Moyen |
| Review | Faible |

> **Recommandation**: Implementer en 2 phases si necessaire (P1 d'abord, puis P2-P3)
