# MY WEDDING SUITE - Plan d'Implémentation V2

**Version:** 2.0  
**Date:** 2025-12-12  
**Status:** ✅ SPRINT 3.4 TERMINÉ (100%) - Guests + Map wedding UX alignée  
**Supabase Project:** `hekyovgnovhfhmkpfrna` (PROD)

---

## 📚 Documents de Référence

| Document | Chemin | Rôle |
|----------|--------|------|
| **Spec Fonctionnelle** | `docs/features/MY_WEDDING_SUITE.md` | Vision produit |
| **Plan V1 (archivé)** | `docs/archive/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V1.md` | Plan initial |
| **Ce Document** | `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md` | Plan révisé basé sur audit réel |

---

## 📊 Section 1 — État Actuel Réel

### 1.1 Vue d'Ensemble Features

| Feature | État | Description | Fichiers Clés | Preuves |
|---------|------|-------------|---------------|---------|
| **Navbar Brides** | ✅ | My Wedding en position 3 | `lib/components/nav/nav_bar_brides/nav_bar_brides_widget.dart` | `lib/components/nav/nav_bar_brides/nav_bar_brides_widget.dart:L173-L191` + `lib/features/my_wedding/presentation/pages/my_wedding_page.dart:L31-L33` |
| **Navbar Pros** | ✅ | Weddings Hub en position 3 | `lib/components/nav/nav_bar_pro/nav_bar_pro_widget.dart` | `lib/components/nav/nav_bar_pro/nav_bar_pro_widget.dart:L173-L191` + `lib/features/weddings_hub_pro/presentation/pages/weddings_hub_pro_page.dart:L20-L22` |
| **My Wedding Page** | ✅ | Page principale bride avec overview | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart:L1-479` | Chargement wedding + team |
| **Wedding Onboarding** | ✅ | 7 étapes in-page (simplifié de 9) | `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart` | `_totalSteps = 7` (`lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart:L46-L52`) |
| **Wedding Overview Card** | ✅ | Design compact horizontal | `my_wedding_page.dart` | Cover, date, countdown |
| **Wedding Team Section** | ✅ | Liste pros + actions | `my_wedding_page.dart`, `invite_pro_sheet.dart` | Invite/exclude pros |
| **Wedding Team Chat** | ✅ | Chat groupe auto-créé | Triggers DB + `chat_rooms.wedding_id` | `create_wedding_team_chat()` |
| **Weddings Hub Pro** | ✅ | Liste mariages pour pro | `lib/features/weddings_hub_pro/` | Clean Architecture |
| **Pro Leave Wedding** | ✅ | Sheet avec raison | `leave_wedding_sheet.dart` | Update `wedding_participants` |
| **Note for Pros** | ✅ | Note bride visible par pros | `note_for_pros_sheet.dart` | `weddings.note_for_pros` |
| **Cover Image Upload** | ✅ | Bucket `wedding-covers` | `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart` | Upload + public URL (`lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart:L1470-L1480`) |
| **Agenda** | ✅ | UI complète + CRUD + preview sur MyWedding | `lib/features/my_wedding/presentation/pages/agenda_page.dart`, `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart` | CRUD + toggle done/public + preview (max 5) |
| **Budget Tracker** | ✅ | UI complète + CRUD + multi-devise + preview sur MyWedding | `lib/features/my_wedding/presentation/pages/budget_page.dart`, `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart` | `currency_code` par dépense + conversion vers devise user |
| **Inspirations/Moodboard** | ✅ | Albums + uploads + save from feed + preview Bride/Pro | `lib/features/my_wedding/presentation/pages/inspirations_page.dart`, `lib/features/my_wedding/presentation/pages/album_detail_page.dart`, `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart`, `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart`, `lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart`, `public.inspiration_albums`, `public.saved_posts`, `public.album_images` | CRUD + upload `wedding-albums` + read-only pro (public albums only) |
| **Guests List** | ✅ | UI complète + CRUD + preview sur MyWedding | `lib/features/my_wedding/presentation/pages/guests_page.dart`, `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart`, `public.wedding_guests` | CRUD + long-press edit/delete + preview (max 3) dans `my_wedding_page.dart` |
| **Map - Wedding Icon (Bride)** | ✅ | Tap icône wedding: centre sur le mariage si existant, sinon ouvre l'onboarding MyWedding | `lib/features/map/presentation/pages/map_page.dart`, RPC `get_my_wedding()` | Utilise `exists` + `venueLat/venueLng` (fallback) + `Edit Wedding` ouvre `MyWeddingPage` |
| **Map - Wedding Details Sheet** | ✅ | Budget = uniquement max + guests count estimé | `lib/features/map/presentation/sheets/wedding_details_sheet.dart`, `lib/features/map/domain/entities/wedding_details.dart` | `budgetMaxOnly` + `guestCount` (parse `guestCount`/`guest_count`) |
| **Documents in Chat** | ❌ | Non implémenté | - | Pas de type `document` |
| **Cancel/Resume Wedding** | ⏳ | Colonnes OK, UI non fait | `cancelled_at` colonne | Flow UI manquant |
| **Notifications wedding_*** | ⚠️ | Triggers OK, drain KO | `supabase/functions/notifications_outbox_drain/index.ts` | Aucun `case "wedding_*"` + mapping `EVENT_TO_NOTIFICATION_TYPE` sans wedding (`supabase/functions/notifications_outbox_drain/index.ts:L151-L161` et `:L548-L563`) |

### 1.2 Architecture Flutter Réelle

```
lib/features/my_wedding/
├── domain/
│   ├── entities/
│   │   └── wedding.dart
│   └── repositories/
│       └── my_wedding_repository.dart
├── data/
│   ├── datasources/
│   │   └── supabase_my_wedding_datasource.dart (644 lignes)
│   └── repositories/
│       └── my_wedding_repository_impl.dart (234 lignes)
└── presentation/
    ├── pages/
    │   └── my_wedding_page.dart (479 lignes)
    ├── widgets/
    │   └── wedding_onboarding_widget.dart (1497 lignes)
    └── sheets/
        ├── wedding_edit_sheet.dart
        ├── note_for_pros_sheet.dart
        └── invite_pro_sheet.dart (220 lignes)

lib/features/weddings_hub_pro/
├── domain/
│   ├── entities/
│   │   └── wedding_client.dart
│   └── repositories/
│       └── weddings_hub_repository.dart
├── data/
│   ├── datasources/
│   │   └── supabase_weddings_hub_datasource.dart (339 lignes)
│   └── repositories/
│       └── weddings_hub_repository_impl.dart (105 lignes)
└── presentation/
    ├── pages/
    │   └── weddings_hub_pro_page.dart (105 lignes)
    └── sheets/
        ├── leave_wedding_sheet.dart
        └── wedding_actions_sheet.dart
```

### 1.3 Schéma Supabase Réel

#### Tables Principales

| Table | Colonnes Clés | RLS | Preuves |
|-------|---------------|-----|---------|
| `weddings` | `id`, `bride_id`, `event_date`, `venue_coords`, `budget_min`, `budget_max`, `guest_count`, `onboarding_step`, `note_for_pros`, `cover_image_url`, `cancelled_at`, `status` | ✅ | MCP audit |
| `wedding_participants` | `id`, `wedding_id`, `profile_id`, `status` (enum: requested/accepted/declined), `is_muted`, `left_at`, `excluded_at`, `left_reason`, `excluded_reason` | ✅ | MCP audit |
| `wedding_events` | `id`, `wedding_id`, `title`, `event_date`, `status`, `is_public` | ✅ | MCP audit |
| `wedding_expenses` | `id`, `wedding_id`, `title`, `amount`, `category`, `status` | ✅ | MCP audit |
| `wedding_guests` | `id`, `wedding_id`, `name`, `email`, `phone`, `role` | ✅ | MCP audit |
| `inspiration_albums` | `id`, `wedding_id`, `bride_profile_id`, `name`, `is_private`, `category` | ✅ | MCP audit |
| `saved_posts` | `id`, `album_id`, `image_url`, `source_profile_id`, `saved_at` | ✅ | MCP audit |
| `album_images` | `id`, `album_id`, `image_url` | ✅ | MCP audit |
| `chat_rooms` | `id`, `type` (private/public/wedding_team), `wedding_id` | ✅ | MCP audit |

#### Triggers & Functions

| Trigger | Table | Function | État |
|---------|-------|----------|------|
| `trigger_create_wedding_team_chat` | `weddings` | `create_wedding_team_chat()` | ✅ Fonctionnel |
| `trigger_manage_pro_in_wedding_team_chat` | `wedding_participants` | `manage_pro_in_wedding_team_chat()` | ✅ Fonctionnel |
| `trigger_notify_wedding_pro_added` | `wedding_participants` | `queue_wedding_notification()` | ✅ Trigger OK |
| `trigger_notify_wedding_pro_excluded` | `wedding_participants` | `queue_wedding_notification()` | ✅ Trigger OK |
| `trigger_notify_wedding_pro_left` | `wedding_participants` | `queue_wedding_notification()` | ✅ Trigger OK |
| `trigger_notify_wedding_cancelled` | `weddings` | `queue_wedding_notification()` | ✅ Trigger OK |

#### Storage Buckets

| Bucket | Public | Policies | État |
|--------|--------|----------|------|
| `wedding-covers` | ✅ | Upload auth, View public, Delete own | ⚠️ Delete policy mismatch |
| `wedding-albums` | ✅ | Upload auth, View public | ✅ OK |
| `avatars` | ✅ | Standard | ✅ OK |

---

## 📐 Section 2 — Logiques & Décisions Techniques

### 2.1 Patterns Établis

| Pattern | Implémentation | Preuve |
|---------|----------------|--------|
| **Clean Architecture** | domain/data/presentation séparés | Structure `lib/features/my_wedding/` |
| **Repository Pattern** | Interface + Impl | `my_wedding_repository.dart` + `_impl.dart` |
| **Supabase Datasource** | Classe dédiée par feature | `supabase_my_wedding_datasource.dart` |
| **Design System** | Import `/core/design/design.dart` | Tous les widgets |
| **Sheets Pattern** | Bottom sheets pour actions | `invite_pro_sheet.dart`, etc. |

### 2.2 Écarts Justifiés par Rapport au Plan V1

| Écart | Prévu V1 | Réel | Justification |
|-------|----------|------|---------------|
| **Onboarding 7 étapes** | 9 étapes | 7 étapes | Simplifié : Welcome + Features Preview fusionnés, Done intégré à Visibility |
| **Budget en devise locale** | Conversion EUR | Stockage devise sélectionnée | Plus simple, pas de taux de change |
| **search_area_coords auto** | Champ séparé | = venue_coords | Évite duplication, modifiable plus tard |
| **Onboarding in-page** | Page séparée | Widget dans MyWeddingPage | Meilleure UX, pas de navigation |

### 2.3 Problèmes Identifiés

| Problème | Gravité | Description | Preuve |
|----------|---------|-------------|--------|
| **Notifications non drainées** | 🔴 Critique | Edge function `notifications_outbox_drain` exclut les events `wedding_*` | `index.ts` - switch case incomplet |
| **Storage delete policy** | 🟡 Moyen | Potentiel mismatch: upload cover image crée un nom de fichier `${weddingId}_${timestamp}.jpg` (pas de prefix folder). La policy delete attend `auth.uid()/...`. | Policy prouvée: `pg_policies` → `Users can delete own covers` (bucket `wedding-covers`, `storage.foldername(name)[1] = auth.uid()`). Upload corrigé: `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart` (path `userId/weddingId_timestamp.jpg`). |
| **Enum status non migré** | 🟡 Moyen | Spec prévoit `active/left/excluded`, DB a `requested/accepted/declined` | Code utilise les anciens |

---

## 📋 Section 3 — Tâches Restantes

### 3.1 Corrections Critiques (Sprint 3.1)

| Tâche | Complexité | Dépendances | Description |
|-------|------------|-------------|-------------|
| ✅ **Fix notifications drain** | S | Aucune | Support complet des events `wedding_*` (in-app + push) + navigation |
| ✅ **Fix storage delete policy** | S | Aucune | Upload cover aligné sur policy delete (prefix folder `auth.uid()`) |

### 3.2 Features Placeholders → Complets (Sprint 3.2-3.4)

| Feature | Complexité | Dépendances | Tâches |
|---------|------------|-------------|--------|
| **Agenda** | M | Tables OK | UI liste, AddEventSheet, CRUD, toggle public/privé |
| **Budget Tracker** | M | Tables OK | UI liste + header totaux, AddExpenseSheet, CRUD, statuts |
| **Inspirations** | L | Tables OK | UI albums, CreateAlbumSheet, SaveToAlbumSheet, upload galerie, AlbumDetailPage |
| **Guests** | S | Tables OK | UI liste, AddGuestSheet, CRUD, rôles |

### 3.3 Features Manquantes (Sprint 3.5)

| Feature | Complexité | Dépendances | Tâches |
|---------|------------|-------------|--------|
| **Documents in Chat** | M | Chat module | Type `document` dans enum, upload PDF, display widget |
| **Cancel/Resume Wedding** | M | Colonnes OK | CancelWeddingSheet, ResumeFlow, notifications |

### 3.4 Améliorations UX (Sprint 3.6)

| Feature | Complexité | Description |
|---------|------------|-------------|
| **Mute global settings** | S | Toggle dans Settings pour muter tous les Wedding Team Chats |
| **Wedding Team Chat improvements** | S | Badge unread, avatars stack | //Déjà fait je pense, à vérifier. 

---

## 🚀 Section 4 — Plan d'Action (Sprints)

### Sprint 3.1 — Corrections Critiques (1 jour)

**Objectif:** Corriger les bugs bloquants identifiés lors de l'audit.

| # | Tâche | Fichier | Priorité |
|---|-------|---------|----------|
| 1 | ✅ Ajouter wedding_* events dans notifications drain | `supabase/functions/notifications_outbox_drain/index.ts` | 🔴 |
| 2 | ✅ Corriger storage delete policy | `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart` | 🟡 |
| 3 | ✅ Tester notifications end-to-end | Test manuel + SQL (outbox + notifications) | 🔴 |

**Critères de succès:**
- [x] Notification reçue quand pro ajouté au mariage
- [x] Notification reçue quand pro exclu
- [x] Notification reçue quand pro quitte
- [x] Bride peut supprimer sa cover image

**Preuves (Sprint 3.1):**
- **Edge Function:** `supabase/functions/notifications_outbox_drain/index.ts`
  - Ajout handlers wedding + templates I18N
  - Fix payload triggers (support `recipient_id`) + payload enrichi (`wedding_id`, `pro_profile_id`, `bride_profile_id`)
- **DB enum:** migration `add_wedding_notification_types` (ajout: `weddingProAdded`, `weddingProExcluded`, `weddingProLeft`, `weddingCancelled` dans `notificationType`)
- **RPC notifications UI:** migration `update_get_formatted_notifications_wedding_types` (titres/messages FR/EN)
- **Navigation:** `lib/custom_code/actions/handle_notification_redirection.dart`
  - Fix route names (utilise `WeddingsHubProPage.routeName` / `MyWeddingPage.routeName`)
  - `weddingProAdded` ouvre `WeddingsHubProPage` avec query param `weddingId`
  - `weddingProLeft` ouvre `ProDetailsWidget` via `pro_profile_id`
- **Auto-open détail mariage (Pro):**
  - `lib/flutter_flow/nav/nav.dart` passe `weddingId` → `WeddingsHubProPage(initialWeddingId: ...)`
  - `lib/features/weddings_hub_pro/presentation/pages/weddings_hub_pro_page.dart` auto-ouvre `_WeddingClientDetailPage`
- **Build iOS:** workflow `/build-and-run-app-simulator` OK

---

### Sprint 3.2 — Agenda & Budget (3-4 jours)

**Objectif:** Implémenter les features Agenda et Budget Tracker.

#### Agenda

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | ✅ Créer `AgendaPage` | `lib/features/my_wedding/presentation/pages/agenda_page.dart` | M |
| 2 | ✅ Créer `AddEventSheet` | `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart` | M |
| 3 | ✅ Implémenter CRUD events | `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` | S |
| 4 | ✅ Toggle public/privé par event | UI + datasource | S |
| 5 | ✅ Remplacer placeholder dans MyWeddingPage (preview max 5) | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` | S |

#### Budget Tracker

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | ✅ Créer `BudgetPage` | `lib/features/my_wedding/presentation/pages/budget_page.dart` | M |
| 2 | ✅ Créer `AddExpenseSheet` | `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart` | M |
| 3 | ✅ Header avec totaux (budget vs dépenses) | `lib/features/my_wedding/presentation/pages/budget_page.dart` | S |
| 4 | ✅ Implémenter CRUD expenses | `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` | S |
| 5 | ✅ Statuts (pending/partial/paid) | UI + datasource | S |
| 6 | ✅ Remplacer placeholder dans MyWeddingPage (summary + progress) | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` | S |
| 7 | ✅ Multi-devise par dépense (`currency_code`) + conversion UI vers devise user | entity + datasource + UI | M |
| 8 | ✅ Wedding edit: budget précis + sélection devise | `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart` | S |

**Critères de succès:**
- [x] Bride peut créer/modifier/supprimer des événements
- [x] Bride peut marquer événements comme public (visible par pros)
- [x] Bride peut créer/modifier/supprimer des dépenses
- [x] Totaux budget affichés correctement
- [x] Affichage multi-devise cohérent (conversion vers devise user)
- [x] Preview Agenda/Budget visible sur MyWeddingPage (max 5 événements)

---

### Sprint 3.3 — Inspirations/Moodboard (3-4 jours)

**Objectif:** Implémenter le système d'albums d'inspiration.

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | ✅ Créer `InspirationsPage` | `lib/features/my_wedding/presentation/pages/inspirations_page.dart` | M |
| 2 | ✅ Créer `CreateAlbumSheet` | `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart` | S |
| 3 | ✅ Créer `AlbumDetailPage` | `lib/features/my_wedding/presentation/pages/album_detail_page.dart` | M |
| 4 | ✅ Créer `SaveToAlbumSheet` | `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart` | M |
| 5 | ✅ Ajouter icône signet dans FeedDetailViewer | `lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart` | S |
| 6 | ✅ Implémenter upload depuis galerie | `album_detail_page.dart` + bucket `wedding-albums` | M |
| 7 | ✅ Implémenter CRUD albums/images | `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` | S |
| 8 | ✅ Toggle privé/public album | `CreateAlbumSheet` | S |
| 9 | ✅ Remplacer placeholder dans MyWeddingPage | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` | S |

**Critères de succès:**
- [x] Bride peut créer albums Wedding et Privés
- [x] Bride peut sauvegarder images du feed dans albums
- [x] Bride peut uploader images depuis galerie
- [x] Pros voient uniquement albums Wedding (is_private=false)

**Preuves (Sprint 3.3):**
- **UI albums:**
  - `lib/features/my_wedding/presentation/pages/inspirations_page.dart`
  - `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart`
  - `lib/features/my_wedding/presentation/pages/album_detail_page.dart`
  - `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart`
- **Feed save toggle:** `lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart`
- **Datasource CRUD:** `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`
- **Bride preview:** `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` (preview albums)
- **Pro entry + preview:** `lib/features/weddings_hub_pro/presentation/pages/weddings_hub_pro_page.dart` (read-only + albums publics)

---

### Sprint 3.4 — Guests (2 jours)

**Objectif:** Compléter la feature Guests.

#### Guests

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | ✅ Créer `GuestsPage` | `lib/features/my_wedding/presentation/pages/guests_page.dart` | S |
| 2 | ✅ Créer `AddGuestSheet` | `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart` | S |
| 3 | ✅ Implémenter CRUD guests | `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` | S |
| 4 | ✅ Remplacer placeholder dans MyWeddingPage (preview max 3 + navigation) | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` | S |

**Critères de succès:**
- [x] Bride peut créer un invité
- [x] Bride peut modifier un invité
- [x] Bride peut supprimer un invité
- [x] Preview Guests visible sur `MyWeddingPage` (max 3)
- [x] Navigation `MyWeddingPage` → `GuestsPage`

**Preuves (Sprint 3.4):**
- **UI Guests list:** `lib/features/my_wedding/presentation/pages/guests_page.dart`
- **UI Add/Edit sheet:** `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart`
- **Datasource CRUD:** `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` (section `WEDDING GUESTS`)
- **Repository methods:**
  - `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart` (section `WEDDING GUESTS`)
  - `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart` (section `WEDDING GUESTS`)
- **Preview + navigation:** `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` (section `GUESTS`)

#### Map (Sprint 3.4) — Wedding UX Bride

**Objectif:** Aligner le comportement de l'icône wedding sur la map avec la logique produit.

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | ✅ Tap icône wedding (bride): si wedding existe → centre sur le point | `lib/features/map/presentation/pages/map_page.dart` | S |
| 2 | ✅ Tap icône wedding (bride): si pas de wedding → ouvre `MyWeddingPage` (onboarding) | `lib/features/map/presentation/pages/map_page.dart` | S |
| 3 | ✅ "Edit Wedding" depuis `WeddingDetailsSheet` → ouvre `MyWeddingPage` | `lib/features/map/presentation/pages/map_page.dart` | S |
| 4 | ✅ `WeddingDetailsSheet`: budget affiche uniquement `budgetMax` + affiche `guestCount` | `lib/features/map/presentation/sheets/wedding_details_sheet.dart` | S |

**Preuves (Map Sprint 3.4):**
- **RPC wedding coords:** `supabase/migrations/00000000000000_initial_schema.sql` → `get_my_wedding()` renvoie `exists`, `venueLat`, `venueLng`
- **Map icon behavior:** `lib/features/map/presentation/pages/map_page.dart` (méthode `_showCreateSheet`)
- **Edit wedding navigation:** `lib/features/map/presentation/pages/map_page.dart` (wiring `onEditWedding: _openMyWeddingPage`)
- **Sheet budget/guests:**
  - `lib/features/map/domain/entities/wedding_details.dart` (`guestCount`, `budgetMaxOnly`)
  - `lib/features/map/presentation/sheets/wedding_details_sheet.dart` (affichage `budgetMaxOnly` + `guests expected`)

---

### Sprint 3.5 — Documents Chat & Cancel/Resume (3 jours)

**Objectif:** Implémenter documents dans chat et flow annulation mariage.

#### Documents in Chat

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | Ajouter type `document` à enum messageType | Migration SQL | S |
| 2 | Créer bucket `chat-documents` si absent | Migration SQL | S |
| 3 | Modifier MessageComposer pour attachment | `lib/features/chat/presentation/widgets/message_composer.dart` | M |
| 4 | Créer `DocumentMessageBubble` | `lib/features/chat/presentation/widgets/` | M |
| 5 | Implémenter upload/download PDF | Storage + UI | M |

#### Cancel/Resume Wedding

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | Créer `CancelWeddingSheet` | `lib/features/my_wedding/presentation/sheets/cancel_wedding_sheet.dart` | M |
| 2 | Implémenter cancel flow | Datasource + UI | S |
| 3 | Implémenter resume flow | Datasource + UI | S |
| 4 | Afficher état "Mariage annulé" dans MyWeddingPage | `my_wedding_page.dart` | S |
| 5 | Vérifier trigger notification `wedding_cancelled` | Test | S |

**Critères de succès:**
- [ ] Utilisateurs peuvent envoyer/recevoir PDF dans Wedding Team Chat
- [ ] Bride peut annuler son mariage avec confirmation
- [ ] Pros reçoivent notification d'annulation
- [ ] Bride peut reprendre mariage annulé

---

### Sprint 3.6 — Polish & Settings (2 jours)

**Objectif:** Améliorations UX et settings.

| # | Tâche | Fichier | Complexité |
|---|-------|---------|------------|
| 1 | Mute global toggle dans Settings | Settings page | S |
| 2 | Badge unread dans Wedding Team Chat item | `my_wedding_page.dart` | S |
| 3 | Avatars stack dans chat item | Widget | S |
| 4 | Tests manuels complets Bride flow | - | M |
| 5 | Tests manuels complets Pro flow | - | M |

**Critères de succès:**
- [ ] User peut muter tous les Wedding Team Chats globalement
- [ ] UI polish conforme au Design System
- [ ] Tous les flows testés end-to-end

---

## 📊 Récapitulatif Effort

| Sprint | Durée | Priorité | Dépendances |
|--------|-------|----------|-------------|
| 3.1 Corrections Critiques | 1 jour | 🔴 Bloquant | Aucune |
| 3.2 Agenda & Budget | 3-4 jours | 🟡 Haute | Sprint 3.1 |
| 3.3 Inspirations | 3-4 jours | 🟡 Haute | Sprint 3.1 |
| 3.4 Guests & Pro Notes | 2 jours | 🟢 Moyenne | Sprint 3.1 |
| 3.5 Documents & Cancel | 3 jours | 🟢 Moyenne | Sprint 3.1 |
| 3.6 Polish | 2 jours | 🟢 Basse | Tous |

**Total estimé:** 14-16 jours de développement

---

## ⚠️ Risques & Mitigations

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Notifications non reçues | Haute | Critique | Sprint 3.1 prioritaire |
| Storage policy break | Moyenne | Moyen | Tester delete après fix |
| Complexité Moodboard | Moyenne | Moyen | Découper en sous-tâches |
| Régression chat | Basse | Haute | Tests avant/après documents |

---

## 📝 Notes de Version

### V2.0 (2025-12-12)
- Audit complet code + DB réalisé
- Écarts documentés avec preuves
- Plan révisé basé sur état réel
- Sprints 3.x définis pour compléter la feature

### V2.1 (2025-12-12)
- Sprint 3.4 complété: Guests + alignement UX Map wedding (icône + sheet)
