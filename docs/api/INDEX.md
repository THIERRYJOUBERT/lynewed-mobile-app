# API Documentation

Documentation des services et repositories internes du projet Lynewed.

---

## Repositories (Domain Layer)

Les repositories définissent les contrats d'accès aux données. Chaque module Clean Architecture possède son repository.

### Core Business (Priorité 1)

| Repository | Module | Description |
|------------|--------|-------------|
| [MapRepository](./repositories/map-repository.md) | `features/map/` | Marqueurs, filtres, géolocalisation PostGIS |
| [ChatRepository](./repositories/chat-repository.md) | `features/chat/` | Conversations, messages, realtime |
| [MyWeddingRepository](./repositories/my-wedding-repository.md) | `features/my_wedding/` | Suite mariage: agenda, budget, invités, albums |

### Features (Priorité 2)

| Repository | Module | Description |
|------------|--------|-------------|
| [AuthRepository](./repositories/auth-repository.md) | `features/auth/` | Login, signup, password reset |
| [NotificationRepository](./repositories/notification-repository.md) | `features/notifications/` | Push et in-app notifications |
| [VideoCallRepository](./repositories/video-call-repository.md) | `features/video_call/` | Sessions Agora, tokens vidéo |
| [WeddingsHubRepository](./repositories/weddings-hub-repository.md) | `features/weddings_hub_pro/` | Hub mariages (Pro) |
| [DashboardRepository](./repositories/dashboard-repository.md) | `features/dashboard/` | Overview, statistiques |

### Support (Priorité 3)

| Repository | Module | Description |
|------------|--------|-------------|
| [ContactRepository](./repositories/contact-repository.md) | `features/chat/` | Gestion contacts |
| [ContentRepository](./repositories/content-repository.md) | `features/content/` | Articles, inspirations |
| [FeedRepository](./repositories/feed-repository.md) | `features/feed/` | Fil d'actualité |

---

## Services (Core Layer)

Services partagés dans `lib/core/services/`.

| Service | Description |
|---------|-------------|
| [CurrencyService](./services/currency-service.md) | Conversion devises, formatage budget |
| [DistanceService](./services/distance-service.md) | Calcul distances géographiques |
| [UnreadCounterService](./services/unread-counter-service.md) | Compteur messages non lus |
| [AppBadgeService](./services/app-badge-service.md) | Badge icône app (notifications) |
| [IncomingCallService](./services/incoming-call-service.md) | Gestion appels entrants Agora |

---

## Backend (Supabase)

### Edge Functions

16 fonctions serverless déployées sur Supabase.

| Fonction | Trigger | Description |
|----------|---------|-------------|
| [Edge Functions Overview](./edge-functions/overview.md) | - | Vue d'ensemble complète |

#### Par Catégorie

**Authentification & Utilisateurs**
- `create-or-sync-user` - Sync profil après auth
- `delete-user` - Suppression données utilisateur
- `account_delete` - Suppression compte complet RGPD

**Notifications**
- `notifications_outbox_drain` - Envoi push FCM (cron 30s)
- `send-broadcast-notification` - Notifications broadcast admin

**Vidéo**
- `agora_token_issue` - Génération tokens Agora
- `video_sessions_cleanup` - Nettoyage sessions vidéo

**Synchronisation CRM**
- `sync-professional-profile` - Sync profils pros
- `sync-professional-to-app` - Sync pros vers app
- `sync-wed-articles-to-app` - Sync articles mariage
- `sync-wedding-article` - Sync article individuel
- `upload-professional-images` - Upload images pros

**Maintenance**
- `alerts_housekeeping` - Nettoyage alertes expirées
- `recent_locations_cleanup` - Nettoyage localisations

**Support**
- `send-ticket-reply` - Réponses tickets support
- `send-verification-email` - Emails vérification

---

## Utilisation Générale

### Pattern Repository

```dart
// 1. Injection via constructeur
class MyCubit extends Cubit<MyState> {
  final MyRepository _repository;

  MyCubit(this._repository) : super(MyState.initial());

  Future<void> loadData() async {
    emit(state.copyWith(loading: true));
    try {
      final result = await _repository.getData();
      if (result.isSuccess) {
        emit(state.copyWith(data: result.data, loading: false));
      } else {
        emit(state.copyWith(error: result.error, loading: false));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }
}
```

### Result Wrapper

La plupart des repositories utilisent un Result wrapper:

```dart
class RepositoryResult<T> {
  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}
```

### Appel Edge Function

```dart
final response = await SupaFlow.client.functions.invoke(
  'function-name',
  body: {'param': 'value'},
);

if (response.status == 200) {
  final data = response.data;
}
```

---

## Conventions

- **Interfaces**: `lib/features/[module]/domain/repositories/`
- **Implémentations**: `lib/features/[module]/data/repositories/`
- **Services partagés**: `lib/core/services/`
- **Edge Functions**: `supabase/functions/`
