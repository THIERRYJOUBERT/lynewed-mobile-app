# Story S02: ARCHITECTURE.md

**Epic:** EPIC-04-DOCUMENTATION
**ID:** S02
**Points:** 5
**Priorite:** P1 - Critique
**Statut:** A faire

---

## Description

En tant que **developpeur ou mainteneur** du projet Lynewed,
je veux un **document ARCHITECTURE.md detaille**
afin de **comprendre la structure du projet, les patterns utilises et les decisions techniques sans avoir a lire le code**.

---

## Criteres d'Acceptance

- [ ] Vue d'ensemble de l'architecture globale avec diagramme ASCII
- [ ] Description de chaque couche Clean Architecture
- [ ] Liste des **15 modules** (`lib/features/`) avec leur role
- [ ] Documentation du Design System (`lib/core/design/`)
- [ ] Architecture backend Supabase (tables principales, RLS, **16 Edge Functions**)
- [ ] Patterns utilises (Repository, Cubit, etc.)
- [ ] **Section Gestion des Secrets** (flutter_dotenv, decision technique)
- [ ] Flux de donnees documentes
- [ ] **iOS 15.0 minimum** mentionne dans contraintes

---

## Contenu Attendu

### 1. Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                        LYNEWED APP                          │
├─────────────────────────────────────────────────────────────┤
│  PRESENTATION     │  Widgets, Pages, Cubits, State          │
├───────────────────┼─────────────────────────────────────────┤
│  DOMAIN           │  Entities, Repositories (interfaces)    │
├───────────────────┼─────────────────────────────────────────┤
│  DATA             │  Datasources, Repository Impls, Models  │
├─────────────────────────────────────────────────────────────┤
│                      SUPABASE BACKEND                       │
│  PostgreSQL + PostGIS │ Auth │ Storage │ Edge Functions     │
└─────────────────────────────────────────────────────────────┘
```

### 2. Structure des Dossiers

```
lib/
├── main.dart                 # Point d'entree
├── core/                     # Code partage (~4,500 lignes)
│   ├── design/               # Design System unifie
│   │   ├── lynewed_colors.dart
│   │   ├── lynewed_text_styles.dart
│   │   ├── lynewed_spacing.dart
│   │   └── widgets/          # Composants reutilisables
│   ├── constants/            # Constantes app
│   ├── services/             # Services partages
│   └── utils/                # Utilitaires
│
├── features/                 # Modules Clean Architecture
│   ├── map/                  # Module carte
│   │   ├── domain/           # Entities, Repository interface
│   │   ├── data/             # Datasource Supabase, Repo impl
│   │   └── presentation/     # Pages, Widgets, State
│   ├── chat/                 # Module messagerie
│   ├── notifications/        # Module notifications
│   ├── my_wedding/           # Module "Mon Mariage" (Bride)
│   └── weddings_hub_pro/     # Module mariages (Pro)
│
├── backend/                  # Schema Supabase genere
│   ├── supabase/
│   │   └── database/tables/  # Definition des tables
│   └── schema/structs/       # Structs Dart
│
├── auth/                     # Authentification
├── pages/                    # Pages legacy (migration en cours)
├── custom_code/              # Actions et widgets custom
└── flutter_flow/             # Utilitaires FlutterFlow (legacy)
```

### 3. Clean Architecture par Module

Chaque module dans `lib/features/` suit cette structure:

```
features/[module]/
├── domain/
│   ├── entities/         # Modeles metier purs
│   └── repositories/     # Interfaces (contrats)
│
├── data/
│   ├── datasources/      # Sources de donnees (Supabase)
│   ├── repositories/     # Implementation des contrats
│   └── models/           # Mappers DB -> Entity
│
└── presentation/
    ├── pages/            # Ecrans complets
    ├── widgets/          # Composants UI
    ├── sheets/           # Bottom sheets
    ├── bloc/ ou state/   # Gestion d'etat (Cubit/Notifier)
    └── theme/            # Styles specifiques au module
```

### 4. Modules Clean Architecture (15 modules)

> **Note**: Les statistiques exactes doivent etre generees avec `find lib/features/[module] -name "*.dart" | wc -l`

| Module | Description | Role |
|--------|-------------|------|
| `auth/` | Authentification | Login, signup, password reset |
| `chat/` | Messagerie temps reel | Conversations, messages, moderation |
| `content/` | Contenu editorial | Articles, inspirations |
| `dashboard/` | Dashboard utilisateur | Vue d'ensemble, alertes |
| `feed/` | Fil d'actualite | Publications, interactions |
| `home/` | Page d'accueil | Navigation principale |
| `map/` | Carte interactive | Marqueurs, filtres, geolocalisation |
| `my_wedding/` | Suite mariage (Bride) | Agenda, budget, invites, albums |
| `notifications/` | Notifications | Parametres, liste, push |
| `profile/` | Profil utilisateur | Edition, preferences |
| `settings/` | Parametres app | Configuration, compte |
| `support/` | Support client | Tickets, FAQ |
| `video_call/` | Appels video | Sessions Agora |
| `weddings_hub_pro/` | Hub mariages (Pro) | Gestion mariages professionnels |
| `wishlist/` | Liste de souhaits | Favoris, prestataires sauvegardes |

### 5. Design System

**Location:** `lib/core/design/`
**Import:** `import '/core/design/design.dart';`

| Fichier | Role |
|---------|------|
| `lynewed_colors.dart` | Palette de couleurs |
| `lynewed_text_styles.dart` | Typographie |
| `lynewed_spacing.dart` | Espacements |
| `lynewed_borders.dart` | Rayons de bordure |
| `lynewed_component_styles.dart` | Styles composants |
| `widgets/` | Composants reutilisables (LynewedButton, LynewedSheet, etc.) |

### 6. Backend Supabase

#### Tables Principales
| Table | Description |
|-------|-------------|
| `profiles` | Profils utilisateurs |
| `wedding_pins` | Mariages sur la carte |
| `chat_rooms` / `chat_messages` | Messagerie |
| `notifications` | Notifications in-app |
| `connection_requests` | Demandes de contact |

#### Edge Functions (16)
| Fonction | Description |
|----------|-------------|
| `account_delete` | Suppression compte complet |
| `agora_token_issue` | Generation tokens video Agora |
| `alerts_housekeeping` | Nettoyage alertes expirees |
| `create-or-sync-user` | Sync profil apres auth |
| `delete-user` | Suppression donnees utilisateur |
| `notifications_outbox_drain` | Envoi push FCM (cron) |
| `recent_locations_cleanup` | Nettoyage localisations |
| `send-broadcast-notification` | Notifications broadcast |
| `send-ticket-reply` | Reponses tickets support |
| `send-verification-email` | Emails verification |
| `sync-professional-profile` | Sync profils pros |
| `sync-professional-to-app` | Sync pros vers app |
| `sync-wed-articles-to-app` | Sync articles mariage |
| `sync-wedding-article` | Sync article individuel |
| `upload-professional-images` | Upload images pros |
| `video_sessions_cleanup` | Nettoyage sessions video |

#### Securite
- **RLS (Row Level Security)** sur toutes les tables
- **Policies** par role (bride, pro, admin)
- **Secrets** via variables d'environnement

### 7. Patterns Utilises

| Pattern | Utilisation |
|---------|-------------|
| Repository | Abstraction acces donnees |
| Cubit | State management (features/chat, map, etc.) |
| Provider | State global (FFAppState) |
| Notifier | State local (ValueNotifier) |
| Dependency Injection | Manuel via constructeurs |

### 8. Gestion des Secrets

> **Decision technique importante** (voir ADR-006 dans S05)

| Approche | Status | Raison |
|----------|--------|--------|
| `flutter_dotenv` | **ACTIF** | Compatible avec scripts build existants |
| `--dart-define-from-file` | Desactive | Necessite mise a jour CI/CD complete |

**Configuration actuelle:**
- Fichier `.env` a la racine (NON commite)
- Charge au runtime via `dotenv.load()` dans `main.dart`
- Variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_PLACES_API_KEY_*`, `AGORA_APP_ID`

**Historique:**
- EPIC-05 avait migre vers `--dart-define-from-file` (compile-time)
- Reverte car incompatible avec `scripts/build_and_run.sh`
- Stabilite production (248 users) prioritaire sur securite theorique

### 8. Flux de Donnees

```
UI (Widget)
    │
    ▼
Cubit/Notifier (State)
    │
    ▼
Repository (Interface)
    │
    ▼
Repository Impl
    │
    ▼
Datasource (Supabase Client)
    │
    ▼
Supabase Backend (PostgreSQL)
```

---

## Notes Techniques

### Sources d'Information
- `docs/PROJECT.md` - Etat actuel
- `docs/App/DESIGN_SYSTEM.md` - Design System detaille
- `lib/features/map/` - Module reference Clean Architecture
- `pubspec.yaml` - Dependances

### Fichier a Creer
- `/ARCHITECTURE.md` (racine du projet)

### Points d'Attention
- Documenter le "pourquoi" des choix, pas seulement le "quoi"
- Garder les diagrammes en ASCII pour faciliter la maintenance
- Lier vers la documentation existante plutot que dupliquer

---

## Definition of Done

- [ ] Document cree avec toutes les sections
- [ ] Diagrammes ASCII lisibles et corrects
- [ ] Tous les modules documentes
- [ ] Liens vers documentation existante fonctionnels
- [ ] Review par un developpeur senior

---

## Estimation

| Tache | Temps estime |
|-------|--------------|
| Sections 1-3 (structure) | 1h30 |
| Section 4 (modules) | 1h |
| Section 5-6 (design + backend) | 1h30 |
| Section 7-8 (patterns + flux) | 1h |
| Review et ajustements | 1h |
| **Total** | **6h** |
