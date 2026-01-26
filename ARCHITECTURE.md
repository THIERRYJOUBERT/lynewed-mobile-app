# LYNEWED Architecture

**Version:** 1.2.4+70
**Last Updated:** 2026-01-26
**Architecture:** Clean Architecture + Design System

---

## Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                        LYNEWED MOBILE APP                        │
│                    Flutter 3.32.4 / Dart 3.8.1                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    PRESENTATION                          │    │
│  │     Pages • Widgets • Cubits • State • Navigation        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                      DOMAIN                              │    │
│  │         Entities • Repository Interfaces                 │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                       DATA                               │    │
│  │    Datasources • Repository Impls • Models • Mappers     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
├──────────────────────────────┼──────────────────────────────────┤
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                  SUPABASE BACKEND                        │    │
│  │   PostgreSQL + PostGIS │ Auth │ Storage │ Realtime       │    │
│  │                  16 Edge Functions                       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Structure des Dossiers

```
lib/
├── main.dart                    # Point d'entrée, initialisation
├── app_constants.dart           # Constantes globales (API keys via dotenv)
│
├── core/                        # Code partagé
│   ├── design/                  # Design System unifié
│   │   ├── design.dart          # Export principal
│   │   ├── lynewed_colors.dart
│   │   ├── lynewed_text_styles.dart
│   │   ├── lynewed_spacing.dart
│   │   ├── lynewed_borders.dart
│   │   ├── lynewed_component_styles.dart
│   │   ├── lynewed_app_theme.dart
│   │   └── widgets/             # Composants réutilisables
│   ├── services/                # Services partagés
│   └── utils/                   # Utilitaires
│
├── features/                    # 15 modules Clean Architecture
│   ├── auth/
│   ├── chat/
│   ├── content/
│   ├── dashboard/
│   ├── feed/
│   ├── home/
│   ├── map/
│   ├── my_wedding/
│   ├── notifications/
│   ├── profile/
│   ├── settings/
│   ├── support/
│   ├── video_call/
│   ├── weddings_hub_pro/
│   └── wishlist/
│
├── backend/                     # Schéma Supabase généré
│   └── supabase/database/
│
├── auth/                        # Auth helpers legacy
├── pages/                       # Pages legacy (en migration)
├── custom_code/                 # Actions et widgets custom
└── flutter_flow/                # Utilitaires FlutterFlow (legacy)
```

---

## Clean Architecture par Module

Chaque module dans `lib/features/` suit cette structure:

```
features/[module]/
├── domain/                      # Couche métier pure
│   ├── entities/                # Modèles métier immuables
│   └── repositories/            # Interfaces (contrats)
│
├── data/                        # Couche données
│   ├── datasources/             # Sources de données (Supabase)
│   ├── repositories/            # Implémentation des contrats
│   └── models/                  # DTOs, mappers DB -> Entity
│
└── presentation/                # Couche UI
    ├── pages/                   # Écrans complets
    ├── widgets/                 # Composants UI spécifiques
    ├── sheets/                  # Bottom sheets
    ├── bloc/ ou state/          # Gestion d'état (Cubit/Notifier)
    └── theme/                   # Styles spécifiques au module
```

### Exemple: Module Map

```
features/map/
├── domain/
│   ├── entities/
│   │   ├── map_marker.dart      # Marqueur sur la carte
│   │   ├── map_filter.dart      # Filtres de recherche
│   │   └── professional_alert.dart
│   └── repositories/
│       └── map_repository.dart  # Interface abstraite
│
├── data/
│   ├── datasources/
│   │   └── supabase_map_datasource.dart
│   └── repositories/
│       └── map_repository_impl.dart
│
└── presentation/
    ├── pages/
    │   └── map_page.dart
    ├── widgets/
    │   ├── map_marker_widget.dart
    │   └── filter_sheet.dart
    └── bloc/
        └── map_cubit.dart
```

---

## Modules Clean Architecture (15)

| Module | Description | Fonctionnalités clés |
|--------|-------------|---------------------|
| `auth/` | Authentification | Login, signup, Apple Sign-In, password reset |
| `chat/` | Messagerie temps réel | Conversations privées/publiques, modération |
| `content/` | Contenu éditorial | Wed of the week, articles inspirations |
| `dashboard/` | Dashboard utilisateur | Vue d'ensemble, statistiques, alertes |
| `feed/` | Fil d'actualité | Publications pros, inspirations Pinterest-like |
| `home/` | Page d'accueil | Navigation principale, routing |
| `map/` | Carte interactive | Marqueurs, filtres, géolocalisation PostGIS |
| `my_wedding/` | Suite mariage (Bride) | Agenda, budget, invités, albums inspiration |
| `notifications/` | Notifications | Paramètres, liste in-app, push FCM |
| `profile/` | Profil utilisateur | Édition, préférences, portfolio (pro) |
| `settings/` | Paramètres app | Configuration, compte, légal |
| `support/` | Support client | Tickets, signalements, FAQ |
| `video_call/` | Appels vidéo | Sessions Agora RTC |
| `weddings_hub_pro/` | Hub mariages (Pro) | Gestion mariages pour professionnels |
| `wishlist/` | Liste de souhaits | Favoris, prestataires sauvegardés |

---

## Design System

**Location:** `lib/core/design/`
**Import unique:** `import '/core/design/design.dart';`

### Fichiers

| Fichier | Rôle |
|---------|------|
| `lynewed_colors.dart` | Palette de couleurs |
| `lynewed_text_styles.dart` | Typographie (Haas Grot Text) |
| `lynewed_spacing.dart` | Espacements standardisés |
| `lynewed_borders.dart` | Rayons de bordure |
| `lynewed_component_styles.dart` | Styles composants |
| `lynewed_app_theme.dart` | Theme Material |
| `widgets/` | LynewedButton, LynewedSheet, etc. |

### Usage

```dart
// Couleurs
LynewedColors.primary           // #000000
LynewedColors.textPrimary       // #141414

// Typographie
LynewedTextStyles.sheetTitle    // 20px, w500
LynewedTextStyles.bodyMedium    // 14px, w400 (default)

// Espacements
LynewedSpacing.sheetHorizontalPadding  // 20px
LynewedSpacing.buttonHeight            // 48px
```

Documentation complète: [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md)

---

## Backend Supabase

### Tables Principales

| Table | Rows | Description |
|-------|------|-------------|
| `profiles` | 248 | Profils utilisateurs (bride/professional) |
| `professional_details` | 49 | Détails pros (portfolio, tarifs, localisation) |
| `weddings` | 8 | Mariages avec lieu, budget, équipe |
| `chat_rooms` | 80 | Salons de discussion |
| `chat_messages` | 199 | Messages temps réel |
| `notifications_outbox` | 245 | Queue push notifications |
| `video_sessions` | 59 | Sessions vidéo Agora |
| `connection_requests` | 4 | Demandes de contact bride/pro |
| `wishlist_items` | 6 | Favoris des brides |

### Edge Functions (16)

| Fonction | Description |
|----------|-------------|
| `account_delete` | Suppression compte RGPD |
| `agora_token_issue` | Génération tokens vidéo |
| `alerts_housekeeping` | Nettoyage alertes expirées |
| `create-or-sync-user` | Sync profil après auth |
| `delete-user` | Suppression données utilisateur |
| `notifications_outbox_drain` | Envoi push FCM (cron 30s) |
| `recent_locations_cleanup` | Nettoyage localisations |
| `send-broadcast-notification` | Notifications broadcast admin |
| `send-ticket-reply` | Réponses tickets support |
| `send-verification-email` | Emails vérification (Resend) |
| `sync-professional-profile` | Sync profils pros CRM→App |
| `sync-professional-to-app` | Sync pros vers app |
| `sync-wed-articles-to-app` | Sync articles mariage |
| `sync-wedding-article` | Sync article individuel |
| `upload-professional-images` | Upload images pros |
| `video_sessions_cleanup` | Nettoyage sessions vidéo |

### Sécurité

- **RLS (Row Level Security)** sur toutes les tables
- **Policies** par rôle (bride, professional, admin)
- **PostGIS** pour requêtes géospatiales
- **Realtime** pour chat et notifications

---

## Patterns Utilisés

### State Management

| Pattern | Usage | Exemple |
|---------|-------|---------|
| **Provider** | State global | `FFAppState` (legacy) |
| **Cubit** | State features | `MapCubit`, `ChatCubit` |
| **ValueNotifier** | State local | Widgets simples |

### Architecture

| Pattern | Usage |
|---------|-------|
| **Repository** | Abstraction accès données |
| **Dependency Injection** | Manuel via constructeurs |
| **Factory** | Création entities depuis JSON |

### Exemple Repository Pattern

```dart
// Domain: Interface
abstract class MapRepository {
  Future<MapSearchResult> searchMarkers({
    required LatLngBounds bounds,
    required MapFilter filter,
  });
}

// Data: Implémentation
class MapRepositoryImpl implements MapRepository {
  final SupabaseMapDatasource _datasource;

  @override
  Future<MapSearchResult> searchMarkers({...}) {
    return _datasource.fetchMarkers(bounds, filter);
  }
}

// Presentation: Usage
class MapCubit extends Cubit<MapState> {
  final MapRepository _repository;

  Future<void> loadMarkers() async {
    final result = await _repository.searchMarkers(...);
    emit(state.copyWith(markers: result.allMarkers));
  }
}
```

---

## Gestion des Secrets

> **Décision technique importante** - Voir [ADR-006](docs/decisions/ADR-006-flutter-dotenv.md)

### Configuration actuelle

| Aspect | Détail |
|--------|--------|
| **Méthode** | `flutter_dotenv` (runtime) |
| **Fichier** | `.env` à la racine (non commité) |
| **Chargement** | `await dotenv.load()` dans `main.dart` |

### Variables requises

```bash
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
GOOGLE_PLACES_API_KEY_IOS=AIza...
GOOGLE_PLACES_API_KEY_ANDROID=AIza...
AGORA_APP_ID=xxx
```

### Historique

- EPIC-05 avait migré vers `--dart-define-from-file` (compile-time)
- Reverté car incompatible avec scripts build existants
- Stabilité production (248 users) prioritaire

---

## Flux de Données

```
┌─────────────────────────────────────────────────────────────┐
│                         UI (Widget)                          │
│                    Affiche les données                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ User action
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Cubit / Notifier                          │
│              Gère l'état, appelle repository                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Method call
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Repository (Interface)                     │
│                   Contrat abstrait                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Delegation
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                Repository Implementation                     │
│              Coordonne datasources, mapping                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Data fetch
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Datasource (Supabase)                       │
│            Requêtes SQL, Realtime subscriptions              │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Network
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Backend                          │
│            PostgreSQL + PostGIS + Edge Functions             │
└─────────────────────────────────────────────────────────────┘
```

---

## Contraintes Techniques

| Contrainte | Valeur | Raison |
|------------|--------|--------|
| **iOS Minimum** | 15.0 | Firebase 12.x requirement |
| **Dart SDK** | >=3.0.0 <4.0.0 | Flutter 3.32.4 |
| **Null Safety** | Activé | Migration complète |
| **Analyse stricte** | 0 warnings | `flutter analyze --fatal-infos` |

---

## Intégrations Externes

| Service | Usage | SDK/Package |
|---------|-------|-------------|
| **Supabase** | Backend complet | `supabase_flutter` |
| **Google Maps** | Carte interactive | `google_maps_flutter` |
| **Google Places** | Recherche lieux | `flutter_google_places_sdk` |
| **Agora** | Appels vidéo | `agora_rtc_engine` |
| **Firebase** | Push notifications | `firebase_messaging` |

---

## Navigation

**Package:** GoRouter 12.1.3

```dart
// Configuration dans lib/pages/routes.dart
GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    GoRoute(path: '/map', builder: (_, __) => MapPage()),
    GoRoute(path: '/chat/:roomId', builder: (_, state) => ChatPage(...)),
    // ...
  ],
)
```

---

## Références

- [README.md](README.md) - Installation et commandes
- [CONTRIBUTING.md](CONTRIBUTING.md) - Guide de contribution
- [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md) - Design System complet
- [docs/PROJECT.md](docs/PROJECT.md) - État du projet
