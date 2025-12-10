# MY WEDDING SUITE - Plan d'Implémentation Final

**Version:** 1.0  
**Date:** 2025-12-10  
**Status:** ✅ VALIDÉ - Prêt pour Implémentation  
**Supabase Project:** `hekyovgnovhfhmkpfrna` (PROD)

---

## 📚 Documents de Référence

| Document | Chemin | Rôle |
|----------|--------|------|
| **Spec Fonctionnelle** | `docs/features/MY_WEDDING_SUITE.md` | Source de vérité pour les fonctionnalités |
| **Audit Technique** | `docs/audits/MY_WEDDING_SUITE_AUDIT.md` | État actuel du code + SQL détaillé |
| **Ce Document** | `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` | Plan d'exécution à suivre |

---

## 🎯 Résumé Exécutif

**Objectif:** Créer "My Wedding Suite" - un espace centralisé pour les brides afin d'augmenter la rétention.

**Scope:** Feature complète production-ready (pas un MVP)

**Sprints:** 8 sprints organisés par dépendances

---

## ✅ Pré-requis Validés

- [x] Spec fonctionnelle validée (`MY_WEDDING_SUITE.md`)
- [x] Audit technique complété (`MY_WEDDING_SUITE_AUDIT.md`)
- [x] Tables existantes auditées via MCP Supabase
- [x] Design System widgets existants identifiés
- [x] Navbars et pages existantes auditées
- [x] Module Map audité (wedding pin, sheets)

---

## 📋 SPRINT 1: Foundation (Backend + Core UI)

**Durée:** 3-4 jours  
**Dépendances:** Aucune  
**Priorité:** CRITIQUE - Bloque tous les autres sprints

### 1.1 Migrations Supabase - Table `weddings`

**Fichier:** Migration SQL directe sur Supabase PROD

```sql
-- 1.1.1 Ajouter colonnes à weddings
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS cover_image_url TEXT;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS note_for_pros TEXT;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS onboarding_step SMALLINT;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS guest_count INTEGER;

-- Note: wedding_name existe déjà
-- Note: status existe déjà avec enum wedding_status (planning=active, cancelled)
```

**Checklist:**
- [ ] Exécuter migration `weddings`
- [ ] Vérifier colonnes ajoutées via MCP

### 1.2 Migrations Supabase - Table `wedding_participants`

```sql
-- 1.2.1 Ajouter valeurs à l'enum existant
ALTER TYPE wedding_participant_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE wedding_participant_status ADD VALUE IF NOT EXISTS 'left';
ALTER TYPE wedding_participant_status ADD VALUE IF NOT EXISTS 'excluded';

-- 1.2.2 Ajouter colonnes
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS left_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS left_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS excluded_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS excluded_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS is_muted BOOLEAN DEFAULT false;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS joined_at TIMESTAMPTZ DEFAULT now();

-- 1.2.3 Migration des données existantes
UPDATE wedding_participants SET status = 'active' WHERE status IN ('requested', 'accepted');
UPDATE wedding_participants SET status = 'left' WHERE status = 'declined';
```

**Checklist:**
- [ ] Exécuter migration `wedding_participants`
- [ ] Vérifier migration des données existantes

### 1.3 Migrations Supabase - Tables Chat

```sql
-- 1.3.1 Modifier chat_rooms pour wedding_team
ALTER TABLE chat_rooms DROP CONSTRAINT IF EXISTS chat_rooms_type_check;
ALTER TABLE chat_rooms ADD CONSTRAINT chat_rooms_type_check 
CHECK (type = ANY (ARRAY['private'::text, 'public'::text, 'wedding_team'::text]));

ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_chat_rooms_wedding_id ON chat_rooms(wedding_id) WHERE wedding_id IS NOT NULL;

-- 1.3.2 Modifier chat_messages pour documents
ALTER TYPE "messageType" ADD VALUE IF NOT EXISTS 'document';

ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS attachment_name TEXT;
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS attachment_size INTEGER;
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS attachment_mime_type TEXT;
```

**Checklist:**
- [ ] Exécuter migration `chat_rooms`
- [ ] Exécuter migration `chat_messages`

### 1.4 Créer Nouvelles Tables

**Ordre d'exécution (respecter les FK):**

1. `wedding_guests` (FK → weddings)
2. `inspiration_albums` (FK → weddings, profiles)
3. `saved_posts` (FK → inspiration_albums, posts)
4. `album_images` (FK → inspiration_albums)
5. `wedding_events` (FK → weddings, profiles)
6. `wedding_expenses` (FK → weddings, profiles)
7. `pro_wedding_notes` (FK → profiles, weddings)

**SQL complet:** Voir `MY_WEDDING_SUITE_AUDIT.md` section 1.9

**Checklist:**
- [ ] Créer `wedding_guests`
- [ ] Créer `inspiration_albums`
- [ ] Créer `saved_posts`
- [ ] Créer `album_images`
- [ ] Créer `wedding_events`
- [ ] Créer `wedding_expenses`
- [ ] Créer `pro_wedding_notes`

### 1.5 RLS Policies

**Ordre d'exécution:** Après création des tables

**SQL complet:** Voir `MY_WEDDING_SUITE_AUDIT.md` section 1.10

**Checklist:**
- [ ] Policies `wedding_guests`
- [ ] Policies `inspiration_albums`
- [ ] Policies `saved_posts`
- [ ] Policies `album_images`
- [ ] Policies `wedding_events`
- [ ] Policies `wedding_expenses`
- [ ] Policies `pro_wedding_notes`
- [ ] Modifier policies `chat_rooms` pour `wedding_team`

### 1.6 Triggers & Functions

**SQL complet:** Voir `MY_WEDDING_SUITE_AUDIT.md` section 1.11

**Checklist:**
- [ ] Function + Trigger `create_wedding_team_chat` (création auto du chat groupe)
- [ ] Function + Trigger `add_pro_to_wedding_team_chat` (ajout/retrait pro du chat)
- [ ] Function + Trigger `notify_wedding_pro_added` (notification)

### 1.7 Storage Buckets

```sql
-- Bucket pour albums d'inspiration
INSERT INTO storage.buckets (id, name, public)
VALUES ('wedding-albums', 'wedding-albums', true)
ON CONFLICT (id) DO NOTHING;

-- Bucket pour documents chat
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-documents', 'chat-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Bucket pour cover images
INSERT INTO storage.buckets (id, name, public)
VALUES ('wedding-covers', 'wedding-covers', true)
ON CONFLICT (id) DO NOTHING;
```

**Checklist:**
- [ ] Créer bucket `wedding-albums`
- [ ] Créer bucket `chat-documents`
- [ ] Créer bucket `wedding-covers`
- [ ] Configurer policies storage (voir section 1.7.1)

#### 1.7.1 Storage RLS Policies

```sql
-- Policy pour wedding-albums (public read, authenticated write)
CREATE POLICY "Authenticated users can upload to wedding-albums"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'wedding-albums');

CREATE POLICY "Anyone can view wedding-albums"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'wedding-albums');

CREATE POLICY "Users can delete own uploads in wedding-albums"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'wedding-albums' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Policy pour chat-documents (private, participants only)
CREATE POLICY "Chat participants can upload documents"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'chat-documents');

CREATE POLICY "Chat participants can view documents"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'chat-documents');

-- Policy pour wedding-covers
CREATE POLICY "Authenticated users can upload covers"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'wedding-covers');

CREATE POLICY "Anyone can view covers"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'wedding-covers');
```

### 1.8 Widgets Design System Core

**Fichiers à créer dans `lib/core/design/widgets/`:**

| Widget | Fichier | Priorité |
|--------|---------|----------|
| `LynewedCountdownCard` | `lynewed_countdown_card.dart` | Sprint 1 |
| `LynewedTeamChatItem` | `lynewed_team_chat_item.dart` | Sprint 1 |
| `LynewedProTile` | `lynewed_pro_tile.dart` | Sprint 1 |
| `LynewedSectionHeader` | `lynewed_section_header.dart` | Sprint 1 |

**Checklist:**
- [ ] Créer `LynewedCountdownCard`
- [ ] Créer `LynewedTeamChatItem`
- [ ] Créer `LynewedProTile`
- [ ] Créer `LynewedSectionHeader`
- [ ] Exporter dans `lib/core/design/widgets/widgets.dart`

### 1.9 Navbar Restructuring

**Fichiers à modifier:**

#### NavBarBrides
**Fichier:** `lib/components/nav/nav_bar_brides/nav_bar_brides_widget.dart`

**Nouvel ordre:**
| # | Label | Icon | Route |
|---|-------|------|-------|
| 1 | Home | `home_outlined` | `HomeBridesWidget` |
| 2 | Feed | `search_sharp` | `FeedBridesWidget` |
| 3 | My Wedding | `favorite_border` | `MyWeddingPage` |
| 4 | WOTW | `star_border` | `WeddingOfTheWeekWidget` |
| 5 | Replay | `mic_none` | `ContentReplayWidget` |

#### NavBarPro
**Fichier:** `lib/components/nav/nav_bar_pro/nav_bar_pro_widget.dart`

**Nouvel ordre:**
| # | Label | Icon | Route |
|---|-------|------|-------|
| 1 | Home | `home_outlined` | `DashboardProWidget` |
| 2 | Feed | `search_sharp` | `FeedBridesWidget` |
| 3 | Weddings | `favorite_border` | `WeddingsHubProPage` |
| 4 | WOTW | `star_border` | `WeddingOfTheWeekWidget` |
| 5 | Replay | `mic_none` | `ContentReplayWidget` |

**Checklist:**
- [ ] Modifier `NavBarBridesWidget`
- [ ] Modifier `NavBarProWidget`
- [ ] Créer placeholder `MyWeddingPage` (route)
- [ ] Créer placeholder `WeddingsHubProPage` (route)
- [ ] Tester navigation

### 1.10 Settings Icon in Headers

**Fichiers à modifier:**

#### HomeBridesWidget
**Fichier:** `lib/pages/bride/home_brides/home_brides_widget.dart`
**Lignes:** ~159-189 (header icons)

**Modification:**
```dart
// Ajouter après Messages icon (ligne ~188)
const SizedBox(width: 14.0),
// Settings
_buildHeaderIcon(
  icon: Icons.settings_outlined,
  onTap: () => context.pushNamed(ProfileBridesAndProWidget.routeName),
),
```

#### DashboardProWidget
**Fichier:** `lib/pages/pro/dashboard_pro/dashboard_pro_widget.dart`

**Modification:** Même pattern que HomeBridesWidget

**Checklist:**
- [ ] Ajouter settings icon dans `HomeBridesWidget`
- [ ] Ajouter settings icon dans `DashboardProWidget`
- [ ] Tester navigation vers Settings

---

## 📋 SPRINT 2: Onboarding

**Durée:** 2-3 jours  
**Dépendances:** Sprint 1.1-1.6 (migrations)  
**Priorité:** HAUTE

### 2.1 Structure Module

**Créer structure Clean Architecture:**
```
lib/features/my_wedding/
├── domain/
│   ├── entities/
│   │   └── wedding_onboarding.dart
│   └── repositories/
│       └── my_wedding_repository.dart
├── data/
│   ├── datasources/
│   │   └── supabase_my_wedding_datasource.dart
│   └── repositories/
│       └── my_wedding_repository_impl.dart
└── presentation/
    └── pages/
        └── wedding_onboarding_page.dart
```

**Checklist:**
- [ ] Créer structure dossiers
- [ ] Créer `wedding_onboarding.dart` entity
- [ ] Créer `my_wedding_repository.dart` interface
- [ ] Créer `supabase_my_wedding_datasource.dart`
- [ ] Créer `my_wedding_repository_impl.dart`

### 2.2 Onboarding Pages (9 écrans)

**Fichier:** `lib/features/my_wedding/presentation/pages/wedding_onboarding_page.dart`

| Étape | Contenu | Obligatoire | Skip |
|-------|---------|-------------|------|
| 1 | Welcome | - | - |
| 2 | Date | ✅ Oui | Non |
| 3 | Location | ✅ Oui | Non |
| 4 | Professionals | ❌ Non | Oui |
| 5 | Guest Count | ❌ Non | Oui |
| 6 | Budget | ❌ Non | Oui |
| 7 | Visibility | ❌ Non | Oui |
| 8 | Features Preview | - | - |
| 9 | Done | - | - |

**Logique de persistence:**
```dart
// À chaque étape, sauvegarder dans weddings
// onboarding_step = numéro de l'étape en cours
// onboarding_step = null → onboarding terminé
```

**Checklist:**
- [ ] Écran 1: Welcome
- [ ] Écran 2: Date (DatePicker, obligatoire)
- [ ] Écran 3: Location (AddressSearch, obligatoire)
- [ ] Écran 4: Professionals (Chips multi-select, skip)
- [ ] Écran 5: Guest Count (Input numérique, skip)
- [ ] Écran 6: Budget (RangeSlider, skip)
- [ ] Écran 7: Visibility (Toggle, skip)
- [ ] Écran 8: Features Preview (Marketing, lecture seule)
- [ ] Écran 9: Done (Récap + CTA)

### 2.3 Persistence Logic

**Datasource methods:**
```dart
// supabase_my_wedding_datasource.dart
Future<void> createWedding(WeddingOnboarding data);
Future<void> updateOnboardingStep(String weddingId, int step);
Future<void> completeOnboarding(String weddingId);
Future<Map<String, dynamic>?> getMyWedding();
```

**Checklist:**
- [ ] Implémenter `createWedding`
- [ ] Implémenter `updateOnboardingStep`
- [ ] Implémenter `completeOnboarding`
- [ ] Implémenter `getMyWedding`
- [ ] Tester persistence

### 2.4 Chat Wedding Team Auto-Creation

**Vérifier trigger Supabase:**
- Quand `onboarding_step` passe de non-null à null → Créer chat room `wedding_team`

**Checklist:**
- [ ] Vérifier trigger `create_wedding_team_chat`
- [ ] Tester création automatique du chat
- [ ] Vérifier ajout bride comme participant

---

## 📋 SPRINT 3: My Wedding Page (Bride)

**Durée:** 3-4 jours  
**Dépendances:** Sprint 2  
**Priorité:** HAUTE

### 3.1 Page Skeleton + Routing

**Fichier:** `lib/features/my_wedding/presentation/pages/my_wedding_page.dart`

**Logique:**
```dart
// Si pas de mariage → Afficher onboarding
// Si mariage en cours d'onboarding → Reprendre onboarding
// Si mariage complété → Afficher My Wedding Page
```

**Checklist:**
- [ ] Créer `MyWeddingPage`
- [ ] Ajouter route dans `index.dart`
- [ ] Implémenter logique conditionnelle
- [ ] Tester navigation depuis navbar

### 3.2 Wedding Countdown Card

**Widget:** `LynewedCountdownCard` (créé Sprint 1.8)

**Props:**
- `coverImageUrl` (nullable)
- `weddingName`
- `eventDate`
- `venueLabel`
- `participantsCount`
- `onEdit` callback

**Checklist:**
- [ ] Intégrer `LynewedCountdownCard` dans page
- [ ] Implémenter upload cover image
- [ ] Implémenter calcul countdown J-XX
- [ ] Implémenter `onEdit` → `WeddingEditSheet`
- [ ] Créer `WeddingEditSheet` (lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart)

### 3.3 Wedding Team Chat Item

**Widget:** `LynewedTeamChatItem` (créé Sprint 1.8)

**Props:**
- `avatarUrls` (List<String>, max 4)
- `unreadCount`
- `participantsCount`
- `onTap` callback

**Checklist:**
- [ ] Intégrer `LynewedTeamChatItem` dans page
- [ ] Charger avatars des participants
- [ ] Charger unread count
- [ ] Implémenter `onTap` → `ChatDetailsPage`

### 3.4 Wedding Team Section

**Widget:** Liste de `LynewedProTile`

**Actions:**
- Tap → `ProDetailsPage`
- Long press → Modal (exclure, report)
- Tap icône chat → Chat 1-1

**Checklist:**
- [ ] Créer section Wedding Team
- [ ] Charger liste des pros actifs
- [ ] Implémenter tap → ProDetailsPage
- [ ] Implémenter long press → Modal
- [ ] Implémenter tap chat → Chat 1-1

### 3.5 Header avec Icônes

**Icônes:**
- Chat → `MessagesPage` filtré par pros du mariage
- Settings → Menu mariage (edit, cancel)

**Checklist:**
- [ ] Ajouter header avec icônes
- [ ] Implémenter filtre MessagesPage
- [ ] Créer menu settings mariage

### 3.6 Sections Overview (Preview)

**Sections à afficher (preview seulement):**
- Agenda (prochains events)
- Budget (résumé)
- Inspirations (grille albums)
- Guests (count)
- Note for Pros

**Checklist:**
- [ ] Section Agenda preview
- [ ] Section Budget preview
- [ ] Section Inspirations preview
- [ ] Section Guests preview
- [ ] Section Note for Pros

---

## 📋 SPRINT 4: Wedding Team Features

**Durée:** 2-3 jours  
**Dépendances:** Sprint 3  
**Priorité:** HAUTE

### 4.1 Invite Pro Flow

**Sheet:** `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart`

**Logique:**
1. Recherche par nom OU liste pros déjà contactés
2. Sélection → Ajout automatique (pas de validation)
3. Trigger notification au pro

**Checklist:**
- [ ] Créer `InviteProSheet`
- [ ] Implémenter recherche pros
- [ ] Implémenter liste pros contactés
- [ ] Implémenter ajout automatique
- [ ] Vérifier trigger notification

### 4.2 Exclude Pro Flow

**Sheet:** `lib/features/my_wedding/presentation/sheets/exclude_pro_sheet.dart`

**Logique:**
1. Confirmation avec raison
2. Update status → `excluded`
3. Retrait du chat wedding_team
4. Notification au pro

**Checklist:**
- [ ] Créer `ExcludeProSheet`
- [ ] Implémenter confirmation
- [ ] Implémenter update status
- [ ] Vérifier retrait du chat (trigger)
- [ ] Vérifier notification

### 4.3 Pro Quit Flow (côté Pro)

**Sheet:** `lib/features/weddings_hub_pro/presentation/sheets/leave_wedding_sheet.dart`

**Logique:**
1. Raison obligatoire
2. Update status → `left`
3. Retrait du chat wedding_team
4. Notification à la bride

**Checklist:**
- [ ] Créer `LeaveWeddingSheet`
- [ ] Implémenter raison obligatoire
- [ ] Implémenter update status
- [ ] Vérifier retrait du chat (trigger)
- [ ] Vérifier notification

### 4.4 Notifications

**Types à implémenter (6 au total selon spec):**
| Type | Destinataire | Trigger |
|------|--------------|---------|
| `wedding_pro_added` | Pro | INSERT wedding_participants (status=active) |
| `wedding_pro_excluded` | Pro | UPDATE wedding_participants (status=excluded) |
| `wedding_pro_left` | Bride | UPDATE wedding_participants (status=left) |
| `wedding_team_message` | Tous sauf sender | INSERT chat_messages (room type=wedding_team) |
| `wedding_event_reminder` | Bride | CRON job basé sur reminder_minutes |
| `wedding_cancelled` | Tous les pros | UPDATE weddings (status=cancelled) |

**Checklist:**
- [ ] Trigger `wedding_pro_added`
- [ ] Trigger `wedding_pro_excluded`
- [ ] Trigger `wedding_pro_left`
- [ ] Trigger `wedding_team_message`
- [ ] Trigger `wedding_cancelled`
- [ ] Edge Function pour `wedding_event_reminder` (CRON)
- [ ] Tester toutes les notifications

### 4.5 Chat 1-1 Access Filtré

**Modification:** `MessagesPage` avec paramètre optionnel `weddingId`

**Logique:**
- Si `weddingId` fourni → Filtrer conversations par pros du mariage

**Checklist:**
- [ ] Ajouter paramètre `weddingId` à MessagesPage
- [ ] Implémenter filtre
- [ ] Tester depuis My Wedding Page

---

## 📋 SPRINT 5: Weddings Hub Pro

**Durée:** 2-3 jours  
**Dépendances:** Sprint 1, Sprint 4.3 (LeaveWeddingSheet)  
**Priorité:** HAUTE  
**Note:** Peut être développé en parallèle de Sprint 3-4 (côté Pro indépendant)

### 5.1 Structure Module

**Créer structure Clean Architecture:**
```
lib/features/weddings_hub_pro/
├── domain/
│   ├── entities/
│   │   └── wedding_client.dart
│   └── repositories/
│       └── weddings_hub_repository.dart
├── data/
│   ├── datasources/
│   │   └── supabase_weddings_hub_datasource.dart
│   └── repositories/
│       └── weddings_hub_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── weddings_hub_page.dart
    │   └── wedding_client_detail_page.dart
    └── sheets/
        ├── leave_wedding_sheet.dart
        └── pro_notes_sheet.dart
```

**Checklist:**
- [ ] Créer structure dossiers
- [ ] Créer entities
- [ ] Créer repositories
- [ ] Créer datasources

### 5.2 Weddings Hub Page

**Fichier:** `lib/features/weddings_hub_pro/presentation/pages/weddings_hub_page.dart`

**Widget:** Liste de `LynewedWeddingClientCard`

**Checklist:**
- [ ] Créer `LynewedWeddingClientCard` (Design System)
- [ ] Créer `WeddingsHubPage`
- [ ] Charger liste mariages (participant actif)
- [ ] Implémenter tap → `WeddingClientDetailPage`
- [ ] Implémenter long press → Modal (mute, quitter)

### 5.3 Wedding Client Detail Page

**Fichier:** `lib/features/weddings_hub_pro/presentation/pages/wedding_client_detail_page.dart`

**Sections:**
| # | Section | Actions |
|---|---------|---------|
| 1 | Header (cover, nom, date, countdown) | - |
| 2 | Bride Info | Tap → Profil bride |
| 3 | Wedding Team Chat | Tap → ChatDetailsPage |
| 4 | Chat with Bride | Tap → Chat 1-1 |
| 5 | Shared Albums | Lecture seule |
| 6 | Shared Events | Lecture seule |
| 7 | Bride's Note | Lecture seule |
| 8 | My Notes | Tap → Éditer |

**Checklist:**
- [ ] Créer `WeddingClientDetailPage`
- [ ] Section Header
- [ ] Section Bride Info
- [ ] Section Wedding Team Chat
- [ ] Section Chat with Bride
- [ ] Section Shared Albums
- [ ] Section Shared Events
- [ ] Section Bride's Note
- [ ] Section My Notes

### 5.4 Mute Workflow

**Logique:**
- Long press sur item mariage → Modal mute
- Toggle `is_muted` dans `wedding_participants`

**Checklist:**
- [ ] Implémenter modal mute
- [ ] Implémenter toggle `is_muted`
- [ ] Tester mute/unmute

### 5.5 Pro Notes

**Sheet:** `lib/features/weddings_hub_pro/presentation/sheets/pro_notes_sheet.dart`

**Checklist:**
- [ ] Créer `ProNotesSheet`
- [ ] Implémenter CRUD notes privées
- [ ] Tester sauvegarde

### 5.6 Mute Global Settings (Optionnel Sprint 5)

**Spec référence:** Lignes 484-486 de `MY_WEDDING_SUITE.md`

**Fichier à modifier:** `lib/pages/shared/profile_brides_and_pro/` (Settings page)

**Logique:**
- Ajouter toggle "Notifications groupes mariage" dans Settings → Notifications
- Si OFF → Aucun push pour les Wedding Team Chats (mais visible dans l'app)
- Stockage: `profiles.notification_settings` (JSONB) ou nouvelle colonne

**Checklist:**
- [ ] Ajouter toggle dans Settings/Notifications
- [ ] Implémenter logique côté Edge Function notifications
- [ ] Tester mute global

---

## 📋 SPRINT 6: Moodboard / Inspirations

**Durée:** 3-4 jours  
**Dépendances:** Sprint 3  
**Priorité:** MOYENNE

### 6.1 Widgets Design System

**Créer dans `lib/core/design/widgets/`:**
- `LynewedAlbumGrid`
- `LynewedAlbumCard`

**Checklist:**
- [ ] Créer `LynewedAlbumGrid`
- [ ] Créer `LynewedAlbumCard`
- [ ] Exporter dans widgets.dart

### 6.2 Albums CRUD

**Sheet:** `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart`

**Champs:**
- Nom (libre)
- Catégorie (prédéfinie ou custom)
- Privacy (Wedding/Private)

**Checklist:**
- [ ] Créer `CreateAlbumSheet`
- [ ] Implémenter création album
- [ ] Implémenter liste albums dans My Wedding
- [ ] Implémenter suppression album

### 6.3 Save from Feed Flow

**Fichier à modifier:** `lib/pages/shared/feed_detail_viewer/feed_detail_viewer_widget.dart`

> Note: Vérifier le path exact dans le projet (peut être `lib/pages/bride/` ou `lib/pages/shared/`)

**Modification:**
- Ajouter icône signet (bookmark)
- Tap → `SaveToAlbumSheet`

**Sheet:** `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart`

**Checklist:**
- [ ] Ajouter icône signet dans FeedDetailViewer
- [ ] Créer `SaveToAlbumSheet`
- [ ] Implémenter sauvegarde dans `saved_posts`
- [ ] Tester flow complet

### 6.4 Upload from Gallery

**Logique:**
1. Ouvrir album
2. Tap "Add photos"
3. Picker galerie (multi-select)
4. Upload vers Storage `wedding-albums`
5. Sauvegarder dans `album_images`

**Checklist:**
- [ ] Implémenter picker galerie
- [ ] Implémenter upload Storage
- [ ] Implémenter sauvegarde `album_images`
- [ ] Tester upload

### 6.5 Inspirations Page

**Fichier:** `lib/features/my_wedding/presentation/pages/inspirations_page.dart`

**Checklist:**
- [ ] Créer `InspirationsPage` (liste tous les albums)
- [ ] Navigation depuis My Wedding Page
- [ ] Bouton "Create Album"

### 6.6 Album Detail Page

**Fichier:** `lib/features/my_wedding/presentation/pages/album_detail_page.dart`

**Checklist:**
- [ ] Créer `AlbumDetailPage`
- [ ] Afficher grille images (saved_posts + album_images)
- [ ] Implémenter suppression image
- [ ] Implémenter toggle privacy

---

## 📋 SPRINT 7: Planning Features

**Durée:** 3-4 jours  
**Dépendances:** Sprint 3  
**Priorité:** MOYENNE

### 7.1 Widget Design System

**Créer dans `lib/core/design/widgets/`:**
- `LynewedTodoItem` (états: pending, done, cancelled)
- `LynewedGuestTile`
- `LynewedNoteCard`

**Checklist:**
- [ ] Créer `LynewedTodoItem`
- [ ] Créer `LynewedGuestTile`
- [ ] Créer `LynewedNoteCard`

### 7.2 Agenda

**Page:** `lib/features/my_wedding/presentation/pages/agenda_page.dart`
**Sheet:** `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart`

**Checklist:**
- [ ] Créer `AgendaPage`
- [ ] Créer `AddEventSheet`
- [ ] Implémenter CRUD events
- [ ] Implémenter toggle public/privé
- [ ] Implémenter changement status (pending/done/cancelled)

### 7.3 Budget Tracker

**Page:** `lib/features/my_wedding/presentation/pages/budget_page.dart`
**Sheet:** `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart`

**Checklist:**
- [ ] Créer `BudgetPage`
- [ ] Créer `AddExpenseSheet`
- [ ] Implémenter header avec totaux
- [ ] Implémenter CRUD expenses
- [ ] Implémenter changement status (pending/partial/paid)

### 7.4 Note for Pros

**Sheet:** `lib/features/my_wedding/presentation/sheets/edit_note_sheet.dart`

**Contraintes:**
- Max 1000 caractères
- Une seule note par mariage

**Checklist:**
- [ ] Créer `EditNoteSheet`
- [ ] Implémenter validation 1000 chars
- [ ] Implémenter sauvegarde dans `weddings.note_for_pros`

### 7.5 Guests List

**Page:** `lib/features/my_wedding/presentation/pages/guests_page.dart`
**Sheet:** `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart`

**Checklist:**
- [ ] Créer `GuestsPage`
- [ ] Créer `AddGuestSheet`
- [ ] Implémenter CRUD guests
- [ ] Implémenter rôles (guest, bridesmaid, etc.)

---

## 📋 SPRINT 8: Map Integration & Documents

**Durée:** 2-3 jours  
**Dépendances:** Sprint 3, 4, 5  
**Priorité:** MOYENNE

### 8.1 Map FAB Wedding - Nouveau Comportement

**Fichier:** `lib/features/map/presentation/pages/map_page.dart`
**Lignes:** ~733-801 (`_showCreateSheet`)

**Nouveau comportement (Bride):**
```dart
if (existingWedding == null) {
  // Pas de mariage → Naviguer vers MyWeddingPage (onboarding)
  context.pushNamed(MyWeddingPage.routeName);
} else {
  // Mariage existe → Centrer la map sur le point
  _mapController.animateCamera(...);
}
```

**Checklist:**
- [ ] Modifier `_showCreateSheet` pour bride
- [ ] Tester nouveau comportement

### 8.2 WeddingDetailsSheet - Modifications

**Fichier:** `lib/features/map/presentation/sheets/wedding_details_sheet.dart`

**Modifications:**
- **Bride:** Ajouter bouton "Go to My Wedding"
- **Pro participant:** Ajouter bouton "View Wedding" + "Chat"
- **Pro non-participant:** Garder bouton "Contact"

**Checklist:**
- [ ] Ajouter bouton "Go to My Wedding" (bride)
- [ ] Ajouter bouton "View Wedding" (pro participant)
- [ ] Ajouter bouton "Chat" (pro participant)
- [ ] Tester tous les cas

### 8.3 WeddingCreateSheet - Décision

**Décision:** Garder pour édition rapide depuis la map

**Modifications:**
- Retirer la création (passe par onboarding)
- Simplifier les champs
- Optionnel: Renommer en `WeddingQuickEditSheet`

**Checklist:**
- [ ] Retirer logique de création
- [ ] Simplifier champs
- [ ] Tester édition rapide

### 8.4 Document Upload in Chat

**Fichier:** `lib/features/chat/presentation/widgets/message_composer.dart`

**Modifications:**
- Ajouter icône attachment
- Tap → Modal choix média/document

**Widget:** `LynewedAttachmentModal`

**Checklist:**
- [ ] Créer `LynewedAttachmentModal`
- [ ] Modifier `MessageComposer`
- [ ] Implémenter file picker (PDF)
- [ ] Implémenter upload vers Storage `chat-documents`

### 8.5 Document Message Display

**Fichier:** `lib/features/chat/presentation/widgets/message_bubble.dart`

**Widget:** `LynewedDocumentMessage`

**Checklist:**
- [ ] Créer `LynewedDocumentMessage`
- [ ] Intégrer dans `MessageBubble`
- [ ] Implémenter download/open

### 8.6 Cancel/Resume Wedding

**Sheet:** `lib/features/my_wedding/presentation/sheets/cancel_wedding_sheet.dart`

**Cancel Flow:**
1. Confirmation avec warning
2. Raison optionnelle
3. Status → `cancelled` (utiliser enum existant)
4. Set `cancelled_at` = now()
5. Notification aux pros (trigger `wedding_cancelled`)

**Resume Flow:**
1. Afficher écran "Mariage annulé"
2. Bouton "Reprendre"
3. Status → `planning` (réutiliser enum existant)
4. Set `cancelled_at` = null

**Checklist:**
- [ ] Créer `CancelWeddingSheet`
- [ ] Implémenter cancel flow
- [ ] Implémenter resume flow
- [ ] Implémenter notifications

### 8.7 Final Polish & Testing

**Checklist:**
- [ ] Tests unitaires usecases
- [ ] Tests d'intégration flows critiques
- [ ] Test manuel complet (Bride)
- [ ] Test manuel complet (Pro)
- [ ] Test notifications

---

## 📊 Récapitulatif des Fichiers

### Fichiers à CRÉER

| Sprint | Fichier | Type |
|--------|---------|------|
| 1 | `lib/core/design/widgets/lynewed_countdown_card.dart` | Widget |
| 1 | `lib/core/design/widgets/lynewed_team_chat_item.dart` | Widget |
| 1 | `lib/core/design/widgets/lynewed_pro_tile.dart` | Widget |
| 1 | `lib/core/design/widgets/lynewed_section_header.dart` | Widget |
| 2 | `lib/features/my_wedding/` (structure complète) | Module |
| 3 | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` | Page |
| 3 | `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart` | Sheet |
| 4 | `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart` | Sheet |
| 4 | `lib/features/my_wedding/presentation/sheets/exclude_pro_sheet.dart` | Sheet |
| 5 | `lib/features/weddings_hub_pro/` (structure complète) | Module |
| 5 | `lib/core/design/widgets/lynewed_wedding_client_card.dart` | Widget |
| 6 | `lib/core/design/widgets/lynewed_album_grid.dart` | Widget |
| 6 | `lib/core/design/widgets/lynewed_album_card.dart` | Widget |
| 6 | `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart` | Sheet |
| 6 | `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart` | Sheet |
| 6 | `lib/features/my_wedding/presentation/pages/inspirations_page.dart` | Page |
| 6 | `lib/features/my_wedding/presentation/pages/album_detail_page.dart` | Page |
| 7 | `lib/core/design/widgets/lynewed_todo_item.dart` | Widget |
| 7 | `lib/core/design/widgets/lynewed_guest_tile.dart` | Widget |
| 7 | `lib/core/design/widgets/lynewed_note_card.dart` | Widget |
| 7 | `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart` | Sheet |
| 7 | `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart` | Sheet |
| 7 | `lib/features/my_wedding/presentation/sheets/edit_note_sheet.dart` | Sheet |
| 7 | `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart` | Sheet |
| 7 | `lib/features/my_wedding/presentation/pages/agenda_page.dart` | Page |
| 7 | `lib/features/my_wedding/presentation/pages/budget_page.dart` | Page |
| 7 | `lib/features/my_wedding/presentation/pages/guests_page.dart` | Page |
| 8 | `lib/core/design/widgets/lynewed_attachment_modal.dart` | Widget |
| 8 | `lib/core/design/widgets/lynewed_document_message.dart` | Widget |
| 8 | `lib/features/my_wedding/presentation/sheets/cancel_wedding_sheet.dart` | Sheet |

### Fichiers à MODIFIER

| Sprint | Fichier | Modification |
|--------|---------|--------------|
| 1 | `lib/components/nav/nav_bar_brides/nav_bar_brides_widget.dart` | Nouvel ordre tabs |
| 1 | `lib/components/nav/nav_bar_pro/nav_bar_pro_widget.dart` | Nouvel ordre tabs |
| 1 | `lib/pages/bride/home_brides/home_brides_widget.dart` | Ajouter settings icon |
| 1 | `lib/pages/pro/dashboard_pro/dashboard_pro_widget.dart` | Ajouter settings icon |
| 6 | `lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart` | Ajouter icône signet |
| 8 | `lib/features/map/presentation/pages/map_page.dart` | Nouveau comportement FAB |
| 8 | `lib/features/map/presentation/sheets/wedding_details_sheet.dart` | Nouveaux boutons |
| 8 | `lib/features/chat/presentation/widgets/message_composer.dart` | Ajouter attachment |
| 8 | `lib/features/chat/presentation/widgets/message_bubble.dart` | Support document |

---

## ✅ Checklist Finale

### Backend
- [ ] Toutes les migrations exécutées
- [ ] Tous les enums mis à jour
- [ ] RLS policies en place et testées
- [ ] Triggers fonctionnels
- [ ] Storage buckets configurés

### Frontend
- [ ] Navbars modifiées (Brides + Pro)
- [ ] Settings icon dans headers
- [ ] Tous les widgets Design System créés
- [ ] Toutes les pages créées
- [ ] Tous les sheets créés
- [ ] Module Chat étendu (documents)

### Tests
- [ ] Tests unitaires pour usecases
- [ ] Tests d'intégration pour flows critiques
- [ ] Test manuel complet (Bride + Pro)
- [ ] Test notifications

### Documentation
- [ ] Mise à jour `docs/PROJECT.md`
- [ ] Mise à jour `docs/App/DESIGN_SYSTEM.md` si nouveaux patterns
- [ ] Archiver `docs/audits/MY_WEDDING_SUITE_AUDIT.md` après implémentation

---

## 📝 Notes de Suivi

### Progression

| Sprint | Status | Date Début | Date Fin | Notes |
|--------|--------|------------|----------|-------|
| Sprint 1 | ⏳ Pending | - | - | - |
| Sprint 2 | ⏳ Pending | - | - | - |
| Sprint 3 | ⏳ Pending | - | - | - |
| Sprint 4 | ⏳ Pending | - | - | - |
| Sprint 5 | ⏳ Pending | - | - | - |
| Sprint 6 | ⏳ Pending | - | - | - |
| Sprint 7 | ⏳ Pending | - | - | - |
| Sprint 8 | ⏳ Pending | - | - | - |

### Blockers

| Date | Blocker | Resolution |
|------|---------|------------|
| - | - | - |

### Décisions Prises

| Date | Décision | Contexte |
|------|----------|----------|
| 2025-12-10 | Utiliser enum `wedding_status` existant | `planning` = `active` |
| 2025-12-10 | Garder `WeddingCreateSheet` pour édition rapide | Simplifier mais ne pas supprimer |
| 2025-12-10 | Sprint 5 parallélisable | Peut être fait en même temps que Sprint 3-4 |
| 2025-12-10 | 6 types de notifications | Selon spec lignes 560-566 |

---

**Document créé:** 2025-12-10  
**Auteur:** Cascade AI  
**Prochaine action:** Démarrer Sprint 1 - Migrations Supabase
