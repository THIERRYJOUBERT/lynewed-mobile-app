# MY WEDDING SUITE - Plan d'Implémentation Final V2

**Version:** 2.4  
**Date:** 2025-12-11  
**Status:** 🚧 EN COURS - Sprint 1 ✅ | Sprint 2 ✅ | Sprint 3 ⏳ | Sprint 4 ⏳  
**Supabase Project:** `hekyovgnovhfhmkpfrna` (PROD)  
**Audit Validation:** Corrections issues de l'analyse critique intégrées

---

## 📚 Documents de Référence

| Document | Chemin | Rôle |
|----------|--------|------|
| **Spec Fonctionnelle** | `docs/features/MY_WEDDING_SUITE.md` | Source de vérité fonctionnalités |
| **Audit Technique** | `docs/audits/MY_WEDDING_SUITE_AUDIT.md` | État actuel code + SQL |
| **Ce Document** | `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` | Plan d'exécution |

---

## 🎯 Résumé Exécutif

**Objectif:** Créer "My Wedding Suite" - espace centralisé pour les brides (rétention)

**Scope:** Feature complète production-ready (pas MVP)

**Sprints:** 8 sprints | **Durée totale:** 20-28 jours

---

## 🗺️ ROUTING - Routes à Créer

| Route Name | Path | Page | Params |
|------------|------|------|--------|
| `myWedding` | `/myWedding` | `MyWeddingPage` | - |
| `weddingOnboarding` | `/weddingOnboarding` | `WeddingOnboardingPage` | `step?` |
| `weddingsHubPro` | `/weddingsHubPro` | `WeddingsHubProPage` | - |
| `weddingClientDetail` | `/weddingClientDetail` | `WeddingClientDetailPage` | `weddingId` |
| `inspirations` | `/inspirations` | `InspirationsPage` | `weddingId` |
| `albumDetail` | `/albumDetail` | `AlbumDetailPage` | `albumId` |
| `agenda` | `/agenda` | `AgendaPage` | `weddingId` |
| `budget` | `/budget` | `BudgetPage` | `weddingId` |
| `guests` | `/guests` | `GuestsPage` | `weddingId` |

---

## 📋 SPRINT 1: Foundation (Backend + Core UI)

**Durée:** 3-4 jours | **Dépendances:** Aucune | **Priorité:** 🔴 CRITIQUE

### 1.1 Migration Table `weddings`

```sql
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS cover_image_url TEXT;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS note_for_pros TEXT;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS onboarding_step SMALLINT;
ALTER TABLE weddings ADD COLUMN IF NOT EXISTS guest_count INTEGER;
```

**Checklist:** `[x]` Exécuter | `[x]` Vérifier via MCP

### 1.2 Migration Table `wedding_participants`

**⚠️ ORDRE CRITIQUE:** ADD VALUE avant UPDATE

```sql
-- ÉTAPE 1: Ajouter valeurs enum
ALTER TYPE wedding_participant_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE wedding_participant_status ADD VALUE IF NOT EXISTS 'left';
ALTER TYPE wedding_participant_status ADD VALUE IF NOT EXISTS 'excluded';

-- ÉTAPE 2: Colonnes
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS left_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS left_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS excluded_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS excluded_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS is_muted BOOLEAN DEFAULT false;
ALTER TABLE wedding_participants ADD COLUMN IF NOT EXISTS joined_at TIMESTAMPTZ DEFAULT now();

-- ÉTAPE 3: Contrainte unique
ALTER TABLE wedding_participants ADD CONSTRAINT wedding_participants_unique_active 
UNIQUE (wedding_id, professional_profile_id);

-- ÉTAPE 4: Migration données
UPDATE wedding_participants SET status = 'active', joined_at = COALESCE(accepted_at, requested_at, now())
WHERE status IN ('requested', 'accepted');
UPDATE wedding_participants SET status = 'left', left_at = now() WHERE status = 'declined';
```

**Checklist:** `[x]` ÉTAPE 1 | `[x]` ÉTAPE 2 | `[x]` ÉTAPE 3 | `[x]` ÉTAPE 4 (N/A - 0 rows) | `[x]` Vérifier

### 1.3 Migration Tables Chat

```sql
-- chat_rooms
ALTER TABLE chat_rooms DROP CONSTRAINT IF EXISTS chat_rooms_type_check;
ALTER TABLE chat_rooms ADD CONSTRAINT chat_rooms_type_check 
CHECK (type = ANY (ARRAY['private'::text, 'public'::text, 'wedding_team'::text]));
ALTER TABLE chat_rooms ADD COLUMN IF NOT EXISTS wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_chat_rooms_wedding_id ON chat_rooms(wedding_id) WHERE wedding_id IS NOT NULL;

-- chat_messages
ALTER TYPE "messageType" ADD VALUE IF NOT EXISTS 'document';
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS attachment_name TEXT;
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS attachment_size INTEGER;
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS attachment_mime_type TEXT;
```

**Checklist:** `[x]` chat_rooms | `[x]` chat_messages

### 1.4 Créer Nouvelles Tables

**Ordre FK:** 1→6 (6 tables)

```sql
-- 1. wedding_guests
CREATE TABLE IF NOT EXISTS wedding_guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  name TEXT NOT NULL, email TEXT, phone TEXT,
  role TEXT DEFAULT 'guest', notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_wedding_guests_wedding_id ON wedding_guests(wedding_id);
ALTER TABLE wedding_guests ENABLE ROW LEVEL SECURITY;

-- 2. inspiration_albums
CREATE TABLE IF NOT EXISTS inspiration_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  bride_profile_id UUID NOT NULL REFERENCES profiles(id),
  name TEXT NOT NULL, cover_image_url TEXT, category TEXT,
  is_private BOOLEAN DEFAULT false, sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_inspiration_albums_wedding_id ON inspiration_albums(wedding_id);
ALTER TABLE inspiration_albums ENABLE ROW LEVEL SECURITY;

-- 3. saved_posts
CREATE TABLE IF NOT EXISTS saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID NOT NULL REFERENCES inspiration_albums(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT now(), UNIQUE(album_id, post_id)
);
ALTER TABLE saved_posts ENABLE ROW LEVEL SECURITY;

-- 4. album_images
CREATE TABLE IF NOT EXISTS album_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID NOT NULL REFERENCES inspiration_albums(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL, thumbnail_url TEXT, uploaded_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE album_images ENABLE ROW LEVEL SECURITY;

-- 5. wedding_events
CREATE TABLE IF NOT EXISTS wedding_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  title TEXT NOT NULL, description TEXT,
  event_date TIMESTAMPTZ NOT NULL, event_end_date TIMESTAMPTZ, location TEXT,
  linked_pro_id UUID REFERENCES profiles(id),
  is_public BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'cancelled')),
  reminder_sent BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE wedding_events ENABLE ROW LEVEL SECURITY;

-- 6. wedding_expenses
CREATE TABLE IF NOT EXISTS wedding_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  category TEXT NOT NULL, description TEXT, amount NUMERIC NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'partial', 'paid')),
  paid_amount NUMERIC DEFAULT 0, due_date DATE,
  linked_pro_id UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE wedding_expenses ENABLE ROW LEVEL SECURITY;

```

**Checklist:** `[x]` wedding_guests | `[x]` inspiration_albums | `[x]` saved_posts (adapté: image_url au lieu de post_id FK) | `[x]` album_images | `[x]` wedding_events | `[x]` wedding_expenses

### 1.5 RLS Policies

**Voir fichier séparé:** `docs/sql/MY_WEDDING_SUITE_RLS.sql`

**Checklist:**
- `[x]` Policies wedding_guests
- `[x]` Policies inspiration_albums  
- `[x]` Policies saved_posts
- `[x]` Policies album_images
- `[x]` Policies wedding_events
- `[x]` Policies wedding_expenses
- `[x]` **Policies chat_rooms pour wedding_team** (NOUVEAU)
- `[x]` **Policies chat_messages pour wedding_team** (NOUVEAU)

### 1.6 Triggers & Functions (7 au total)

**Voir fichier séparé:** `docs/sql/MY_WEDDING_SUITE_TRIGGERS.sql`

| # | Function | Trigger | Description |
|---|----------|---------|-------------|
| 1 | `create_wedding_team_chat()` | `trigger_create_wedding_team_chat` | Crée chat quand onboarding terminé |
| 2 | `manage_pro_in_wedding_team_chat()` | `trigger_manage_pro_in_wedding_team_chat` | Ajoute/retire pro du chat |
| 3 | `queue_wedding_notification()` | - | Helper pour notifications |
| 4 | `notify_wedding_pro_added()` | `trigger_notify_wedding_pro_added` | Notif: pro ajouté |
| 5 | `notify_wedding_pro_excluded()` | `trigger_notify_wedding_pro_excluded` | Notif: pro exclu |
| 6 | `notify_wedding_pro_left()` | `trigger_notify_wedding_pro_left` | Notif: pro parti |
| 7 | `notify_wedding_cancelled()` | `trigger_notify_wedding_cancelled` | Notif: mariage annulé |

**Note:** `wedding_team_message` utilise le système de notifications chat existant.

**Checklist:** `[x]` 1 | `[x]` 2 | `[x]` 3 | `[x]` 4 | `[x]` 5 | `[x]` 6 | `[x]` 7

### 1.7 Storage Buckets

| Bucket | Public | Max Size | MIME Types |
|--------|--------|----------|------------|
| `wedding-albums` | ✅ | 10MB | image/jpeg, image/png, image/webp |
| `chat-documents` | ❌ | 10MB | application/pdf |
| `wedding-covers` | ✅ | 10MB | image/jpeg, image/png, image/webp |

**Checklist:** `[x]` Créer buckets (10MB limit) | `[x]` Policies storage

### 1.8 Widgets Design System Core

| Widget | Fichier | Description |
|--------|---------|-------------|
| `LynewedCountdownCard` | `lynewed_countdown_card.dart` | Cover, nom, date, countdown J-XX |
| `LynewedTeamChatItem` | `lynewed_team_chat_item.dart` | Avatars, badge unread |
| `LynewedProTile` | `lynewed_pro_tile.dart` | Photo, nom, profession, chat icon |
| `LynewedSectionHeader` | `lynewed_section_header.dart` | Titre + action |

**Checklist:** `[x]` CountdownCard | `[x]` TeamChatItem | `[x]` ProTile | `[x]` SectionHeader | `[x]` Export widgets.dart + design.dart

### 1.9 Navbar Restructuring

**NavBarBrides:** Home | Feed | **My Wedding** | WOTW | Replay
**NavBarPro:** Home | Feed | **Weddings** | WOTW | Replay

**Checklist:** `[x]` NavBarBridesWidget | `[x]` NavBarProWidget | `[x]` Placeholder MyWeddingPage | `[x]` Placeholder WeddingsHubProPage | `[x]` Routes nav.dart + index.dart

### 1.10 Settings Icon in Headers

**Fichiers:** `home_brides_widget.dart` + `dashboard_pro_widget.dart`

**Checklist:** `[ ]` HomeBridesWidget | `[ ]` DashboardProWidget (reporté Sprint 2 - Settings déjà accessible via Profile)

### 1.11 Migration One-Time Mariages Existants

Script pour créer chat wedding_team pour mariages existants sans chat.

**Checklist:** `[x]` Exécuter script (3 mariages migrés) | `[x]` Vérifier

---

## 📋 SPRINT 2: Onboarding ✅ TERMINÉ

**Durée:** 2-3 jours | **Dépendances:** Sprint 1.1-1.6 | **Priorité:** 🔴 HAUTE
**Status:** ✅ TERMINÉ (2025-12-11)

### 2.1 Structure Module + Entities ✅

```
lib/features/my_wedding/
├── domain/
│   ├── entities/wedding_overview.dart
│   └── repositories/my_wedding_repository.dart (+ OnboardingData class)
├── data/
│   ├── datasources/supabase_my_wedding_datasource.dart
│   └── repositories/my_wedding_repository_impl.dart
└── presentation/
    ├── pages/my_wedding_page.dart
    └── widgets/wedding_onboarding_widget.dart
```

**Note:** Structure simplifiée vs plan initial. Entities et usecases supplémentaires seront ajoutés au Sprint 3+.

**Checklist:** `[x]` Structure | `[x]` WeddingOverview entity | `[x]` Repository interface | `[x]` Datasource | `[x]` Repository impl

### 2.2 Onboarding Widget (7 étapes - simplifié) ✅

| Step | Contenu | Obligatoire | Skip | Status |
|------|---------|-------------|------|--------|
| 1 | Date | ✅ | Non | ✅ |
| 2 | Location (Google Places) | ✅ | Non | ✅ |
| 3 | Professionals | ❌ | Oui | ✅ |
| 4 | Guest Count (default 100) | ❌ | Oui | ✅ |
| 5 | Budget Range (min/max) | ❌ | Oui | ✅ |
| 6 | Visibility + Search Radius | ❌ | Oui | ✅ |
| 7 | Done + Cover Image | - | - | ✅ |

**Changements vs spec:**
- ❌ Welcome screen retiré (démarre directement sur Date)
- ❌ Features Preview retiré (simplification)
- ✅ Search radius optionnel avec checkbox + slider (10-500km)
- ✅ Cover image picker au step Done
- ✅ Budget stocké en devise sélectionnée (pas USD)

**Persistence:** Step 1 = créer wedding | Steps 2-6 = update | Step 7 = set onboarding_step=null

**Checklist:** `[x]` 7 étapes | `[x]` Progress indicator | `[x]` Back button | `[x]` Skip buttons | `[x]` Icons (Material)

### 2.3 Persistence Logic ✅

**Datasource methods implémentés:**
- `[x]` `createWedding()` - Appelé step 1 (avec search_area_coords)
- `[x]` `updateOnboardingData()` - Steps 2-6 (via OnboardingData.toJson())
- `[x]` `completeOnboarding()` - Step 7 (set null + upload cover)
- `[x]` `getMyWedding()` - Récupérer état (WeddingOverview entity)

**Checklist:** `[x]` 4 methods | `[x]` Test persistence | `[x]` Test reprise

### 2.4 Chat Wedding Team Auto-Creation ✅

**Checklist:** `[x]` Trigger fonctionne | `[x]` Room créée | `[x]` Bride participant

### 2.5 Wedding Overview Card (anticipé du Sprint 3) ✅

**Design compact horizontal:**
- `[x]` Full-width (edge-to-edge, pas de marges)
- `[x]` Countdown badge 64x64px
- `[x]` Titre 16px, textes secondaires 13px
- `[x]` Espacement 4px entre lignes
- `[x]` Icône edit à droite

### 2.6 DB Cleanup (décisions techniques) ✅

- `[x]` Colonnes `budget_min_eur` et `budget_max_eur` supprimées
- `[x]` Budget stocké en devise sélectionnée (`budget_min`, `budget_max` int4)
- `[x]` `search_area_coords` maintenant populé automatiquement (= venue_coords)

---

## 📋 SPRINT 3: My Wedding Page (Bride)

**Durée:** 3-4 jours | **Dépendances:** Sprint 2 | **Priorité:** 🔴 HAUTE
**Status:** ⏳ EN COURS (80% fait - Wedding Team fonctionnel, sections placeholders)

### 3.1 Page Skeleton + Routing ✅

**Logique:** Pas de mariage → Onboarding | Onboarding en cours → Reprendre | Complété → My Wedding Page

**Checklist:** `[x]` MyWeddingPage | `[x]` Route index.dart | `[x]` Logique conditionnelle

### 3.2 Wedding Countdown Card ✅

**Props:** coverImageUrl, weddingName, eventDate, venueLabel, participantsCount, onEdit

**Checklist:** `[x]` Widget intégré (inline) | `[x]` Calcul countdown | `[x]` WeddingEditSheet

### 3.2.1 WeddingEditSheet ✅ (2025-12-11)

**Fichier:** `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart`

**Features:**
- `[x]` Date picker natif avec thème Lynewed
- `[x]` Google Places address search avec autocomplétion
- `[x]` Affichage adresse actuelle avec bouton suppression
- `[x]` Champs éditables: nom, date, adresse, guests, budget min/max
- `[x]` Utilise `LynewedSheet` (Design System)
- `[x]` Sauvegarde coordonnées GPS et country_code

### 3.3 Wedding Team Chat Item ✅

**Props:** avatarUrls, unreadCount, participantsCount, onTap

**Checklist:** `[x]` Widget intégré (`_buildWeddingTeamChatItem`) | `[x]` Charger avatars (via `_teamChatInfo`) | `[x]` Charger unread | `[x]` Navigation ChatDetailsPage

### 3.4 Wedding Team Section ✅ (2025-12-11)

Liste de `_buildProTile` avec actions: Tap → ProDetails | Long press → Modal | Chat icon → Chat 1-1

**Fichiers modifiés:**
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart`
- `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`

**Checklist:** 
- `[x]` Section avec liste pros (`_buildTeamMembersList`)
- `[x]` Charger pros actifs (`getActiveWeddingTeam`)
- `[x]` Tap → ProDetails (fetch Supabase + navigation `ProDetailsWidget`)
- `[x]` Long press → Modal options (View Profile, Send Message, Remove)
- `[x]` Chat icon → Chat 1-1 (`action_blocks.contactChatRoom`)
- `[x]` Empty state avec bouton "Invite Professionals"
- `[x]` Bouton "+ Add" dans header section

### 3.5 Header avec Icônes ⏳

Chat → MessagesPage filtré | Settings → Menu mariage

**Status actuel:** Header avec titre "WEDDING" + icône settings (navigation vers settings existant)

**Checklist:** `[x]` Header basique | `[ ]` Filtre MessagesPage | `[ ]` Menu settings mariage

### 3.6 Sections Overview ✅ (2025-12-11)

Agenda | Budget | Inspirations | Guests | Note for Pros

**Toutes les 5 sections implémentées avec:**
- `[x]` Agenda section (placeholder "Add Event")
- `[x]` Budget section (affiche budget si défini, sinon "Set Budget")
- `[x]` Inspirations section (placeholder "Create Album")
- `[x]` Guests section (affiche count si défini, "Manage Guests")
- `[x]` Note for Pros section (affiche note si définie, sinon "Add Note")
- `[x]` **Boutons style primaire (fond noir)** - tous les boutons de sections

### 3.6.1 NoteForProsSheet ✅ (2025-12-11)

**Fichier:** `lib/features/my_wedding/presentation/sheets/note_for_pros_sheet.dart`

**Features:**
- `[x]` Sous-titre déplacé sous le header (comme `invite_pro_sheet`)
- `[x]` TextField multi-lignes avec maxLength 1000
- `[x]` Tips pour une bonne note
- `[x]` Sauvegarde via `updateWedding`

### 3.7 Cancelled Wedding View

Si status=cancelled: afficher écran "Mariage annulé" + bouton "Reprendre"

**Checklist:** `[ ]` CancelledWeddingView widget | `[ ]` Logique détection | `[ ]` Bouton reprendre

---

## 📋 SPRINT 4: Wedding Team Features

**Durée:** 2-3 jours | **Dépendances:** Sprint 3 | **Priorité:** 🔴 HAUTE
**Status:** ⏳ EN COURS (InviteProSheet fait, triggers corrigés)

### 4.1 Invite Pro Flow ✅ (2025-12-11)

**Fichier:** `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart`

**Logique implémentée:**
1. Liste des pros contactés (via `get_contacted_pros_for_bride` RPC)
2. Recherche/filtre par nom ou profession
3. Bouton "Add" → `inviteProToWedding` (upsert avec profession)
4. Bouton "Remove" → `excludeProFromWedding`
5. Tap sur pro → Navigation vers `ProDetailsWidget`
6. État persistant (affiche "Remove" pour pros déjà invités)

**Checklist:** 
- `[x]` InviteProSheet avec `LynewedSheet`
- `[x]` Recherche/filtre
- `[x]` Liste pros contactés (RPC `get_contacted_pros_for_bride`)
- `[x]` Ajout pro (`inviteProToWedding` avec profession)
- `[x]` Retrait pro (`excludeProFromWedding`)
- `[x]` Navigation vers ProDetails
- `[x]` État Add/Remove persistant

**Fixes appliqués (2025-12-11):**
- `[x]` RPC `get_contacted_pros_for_bride` créée (remplace query complexe)
- `[x]` `getActiveWeddingTeam` corrigé (profession depuis `wedding_participants`)
- `[x]` `inviteProToWedding` inclut maintenant la profession
- `[x]` RLS policy "Bride can update wedding participants" ajoutée

### 4.2 Exclude Pro Flow ✅ (partiel)

**Logique:** Via long press modal dans Wedding Team Section → "Remove from Team"

**Checklist:** 
- `[x]` Modal avec option "Remove from Team"
- `[x]` Confirmation dialog
- `[x]` Update status via `excludeProFromWedding`
- `[ ]` ExcludeProSheet dédié (optionnel - modal suffit)
- `[x]` Test trigger chat (trigger `manage_pro_in_wedding_team_chat`)

### 4.3 Pro Quit Flow (côté Pro)

**Sheet:** `leave_wedding_sheet.dart`
**Logique:** Raison obligatoire → status=left → Retrait chat → Notification bride

**Checklist:** `[ ]` LeaveWeddingSheet | `[ ]` Raison obligatoire | `[ ]` Update status | `[ ]` Test trigger | `[ ]` Test notif

### 4.4 Notifications - Triggers SQL ✅ (corrigés 2025-12-11)

| Type | Destinataire | Trigger | Status |
|------|--------------|--------|--------|
| `wedding_pro_added` | Pro | INSERT participants (active) | ✅ Corrigé (`full_name`) |
| `wedding_pro_excluded` | Pro | UPDATE participants (excluded) | ✅ Corrigé (`full_name`) |
| `wedding_pro_left` | Bride | UPDATE participants (left) | ✅ Corrigé (`full_name`) |
| `wedding_event_reminder` | Bride | **Edge Function CRON** (24h avant) | ⏳ À faire |
| `wedding_cancelled` | Tous pros | UPDATE weddings (cancelled) | ✅ Existant |

**Fixes appliqués (2025-12-11):**
- `[x]` `notify_pro_added_to_wedding` → `p.full_name` (était `p.display_name`)
- `[x]` `notify_pro_excluded_from_wedding` → `p.full_name`
- `[x]` `notify_wedding_pro_added` → `p.full_name`
- `[x]` `notify_wedding_pro_excluded` → `p.full_name`
- `[x]` `notify_wedding_pro_left` → `full_name`

**Checklist:** `[x]` 5 triggers SQL corrigés | `[ ]` Edge Function reminder | `[ ]` Toggle Settings

### 4.5 Edge Function `wedding_event_reminder`

**Fichier:** `supabase/functions/wedding_event_reminder/index.ts`

```typescript
// CRON: toutes les heures (0 * * * *)
// 1. SELECT events WHERE event_date BETWEEN NOW() + 23h AND NOW() + 25h AND NOT reminder_sent
// 2. Pour chaque event:
//    - Vérifier que la bride a activé les rappels (profiles.notification_settings)
//    - INSERT notifications_outbox type='wedding_event_reminder'
// 3. UPDATE reminder_sent = true
```

**Checklist:** `[ ]` Créer Edge Function | `[ ]` Config CRON horaire | `[ ]` Test

### 4.6 Settings - Toggle Rappels Événements

**Modification:** Ajouter dans Settings → Notifications un toggle "Rappels événements mariage (24h avant)"

**Stockage:** `profiles.notification_settings` (JSONB) - clé `wedding_event_reminder: boolean`

**Checklist:** `[ ]` Ajouter toggle UI | `[ ]` Sauvegarder préférence | `[ ]` Vérifier dans Edge Function

### 4.7 Chat 1-1 Access Filtré

**Modification:** MessagesPage avec param optionnel `weddingId` → Filtre par pros du mariage

**Checklist:** `[ ]` Param weddingId | `[ ]` Filtre | `[ ]` Test depuis My Wedding

---

## 📋 SPRINT 5: Weddings Hub Pro

**Durée:** 2-3 jours | **Dépendances:** Sprint 1, 4.3 | **Priorité:** 🔴 HAUTE
**Note:** Parallélisable avec Sprint 3-4

### 5.1 Structure Module

```
lib/features/weddings_hub_pro/
├── domain/entities/wedding_client.dart
├── domain/repositories/weddings_hub_repository.dart
├── data/datasources/supabase_weddings_hub_datasource.dart
├── data/repositories/weddings_hub_repository_impl.dart
└── presentation/
    ├── pages/weddings_hub_page.dart
    ├── pages/wedding_client_detail_page.dart
    └── sheets/leave_wedding_sheet.dart
```

**Checklist:** `[ ]` Structure | `[ ]` Entity | `[ ]` Repository | `[ ]` Datasource

### 5.2 Weddings Hub Page

Liste `LynewedWeddingClientCard` | Tap → Detail | Long press → Modal (mute, quitter)

**Checklist:** `[ ]` LynewedWeddingClientCard (Design System) | `[ ]` WeddingsHubPage | `[ ]` Charger mariages | `[ ]` Tap | `[ ]` Long press

### 5.3 Wedding Client Detail Page

**Sections:** Header | Bride Info | Wedding Team Chat | Chat with Bride | Shared Albums | Shared Events | Bride's Note

**Checklist:** `[ ]` Page | `[ ]` 7 sections | `[ ]` Actions menu

### 5.4 Mute Workflow

Long press → Modal → Toggle `is_muted`

**Checklist:** `[ ]` Modal | `[ ]` Toggle | `[ ]` Test

### 5.5 Mute Global Settings (Optionnel)

Toggle "Notifications groupes mariage" dans Settings → Notifications

**Checklist:** `[ ]` Toggle Settings | `[ ]` Logique Edge Function | `[ ]` Test

---

## 📋 SPRINT 6: Moodboard / Inspirations

**Durée:** 3-4 jours | **Dépendances:** Sprint 3 | **Priorité:** 🟡 MOYENNE

### 6.1 Widgets Design System

`LynewedAlbumGrid` + `LynewedAlbumCard`

**Checklist:** `[ ]` AlbumGrid | `[ ]` AlbumCard | `[ ]` Export

### 6.2 Albums CRUD

**Sheet:** `create_album_sheet.dart` - Nom + catégorie + privacy

**Checklist:** `[ ]` CreateAlbumSheet | `[ ]` Création | `[ ]` Liste albums | `[ ]` Suppression

### 6.3 Save from Feed Flow

**Modifier:** `feed_detail_viewer_widget.dart` - Ajouter icône signet → `SaveToAlbumSheet`

**Checklist:** `[ ]` Vérifier path exact | `[ ]` Icône signet | `[ ]` SaveToAlbumSheet | `[ ]` Sauvegarde saved_posts

### 6.4 Upload from Gallery

Ouvrir album → "Add photos" → Picker → Upload Storage → Sauvegarde album_images

**Checklist:** `[ ]` Picker | `[ ]` Upload | `[ ]` Sauvegarde | `[ ]` Test

### 6.5 Inspirations Page

Liste tous les albums + bouton "Create Album"

**Checklist:** `[ ]` InspirationsPage | `[ ]` Navigation | `[ ]` Create button

### 6.6 Album Detail Page

Grille images (saved_posts + album_images) + suppression + toggle privacy

**Checklist:** `[ ]` AlbumDetailPage | `[ ]` Grille | `[ ]` Suppression | `[ ]` Toggle privacy

---

## 📋 SPRINT 7: Planning Features

**Durée:** 3-4 jours | **Dépendances:** Sprint 3 | **Priorité:** 🟡 MOYENNE

### 7.1 Widgets Design System

`LynewedTodoItem` + `LynewedGuestTile` + `LynewedNoteCard`

**Checklist:** `[ ]` TodoItem | `[ ]` GuestTile | `[ ]` NoteCard

### 7.2 Agenda

**Page:** `agenda_page.dart` | **Sheet:** `add_event_sheet.dart`

**Checklist:** `[ ]` AgendaPage | `[ ]` AddEventSheet | `[ ]` CRUD | `[ ]` Toggle public/privé | `[ ]` Status change

### 7.3 Budget Tracker

**Page:** `budget_page.dart` | **Sheet:** `add_expense_sheet.dart`

**Checklist:** `[ ]` BudgetPage | `[ ]` Header totaux | `[ ]` AddExpenseSheet | `[ ]` CRUD | `[ ]` Status change

### 7.4 Note for Pros

**Sheet:** `edit_note_sheet.dart` - Max 1000 chars, une seule note

**Checklist:** `[ ]` EditNoteSheet | `[ ]` Validation 1000 chars | `[ ]` Sauvegarde weddings.note_for_pros

### 7.5 Guests List

**Page:** `guests_page.dart` | **Sheet:** `add_guest_sheet.dart`

**Checklist:** `[ ]` GuestsPage | `[ ]` AddGuestSheet | `[ ]` CRUD | `[ ]` Rôles

---

## 📋 SPRINT 8: Map Integration & Documents

**Durée:** 2-3 jours | **Dépendances:** Sprint 3, 4, 5 | **Priorité:** 🟡 MOYENNE

### 8.1 Map FAB Wedding - Nouveau Comportement

**Fichier:** `map_page.dart` (~ligne 733)

**Bride:** Pas de mariage → MyWeddingPage | Mariage existe → Centrer map

**Checklist:** `[ ]` Modifier _showCreateSheet | `[ ]` Test

### 8.2 WeddingDetailsSheet - Modifications

**Bride:** Ajouter "Go to My Wedding"
**Pro participant:** Ajouter "View Wedding" + "Chat"
**Pro non-participant:** Garder "Contact"

**Checklist:** `[ ]` Bouton bride | `[ ]` Boutons pro participant | `[ ]` Test tous cas

### 8.3 WeddingCreateSheet - Simplification

Garder pour édition rapide, retirer création (passe par onboarding)

**Checklist:** `[ ]` Retirer création | `[ ]` Simplifier | `[ ]` Test

### 8.4 Document Upload in Chat

**Modifier:** `message_composer.dart` - Icône attachment → Modal choix média/document

**Checklist:** `[ ]` LynewedAttachmentModal | `[ ]` Modifier MessageComposer | `[ ]` File picker PDF | `[ ]` Upload Storage

### 8.5 Document Message Display

**Modifier:** `message_bubble.dart` - Support type document

**Checklist:** `[ ]` LynewedDocumentMessage | `[ ]` Intégrer MessageBubble | `[ ]` Download/open

### 8.6 Cancel/Resume Wedding

**Sheet:** `cancel_wedding_sheet.dart`

**Cancel:** Confirmation → status=cancelled → cancelled_at=now() → Notification pros
**Resume:** Bouton "Reprendre" → status=planning → cancelled_at=null

**Checklist:** `[ ]` CancelWeddingSheet | `[ ]` Cancel flow | `[ ]` Resume flow | `[ ]` Notifications

### 8.7 Final Polish & Testing

**Checklist:** `[ ]` Tests unitaires usecases | `[ ]` Tests intégration | `[ ]` Test manuel Bride | `[ ]` Test manuel Pro | `[ ]` Test notifications

---

## 📊 Récapitulatif Fichiers

### Fichiers CRÉÉS (Sprint 1-2) ✅

| S | Fichier | Status |
|---|---------|--------|
| 1 | `lib/core/design/widgets/lynewed_countdown_card.dart` | ✅ (inline dans my_wedding_page) |
| 1 | `lib/core/design/widgets/lynewed_team_chat_item.dart` | ⏳ Sprint 3 |
| 1 | `lib/core/design/widgets/lynewed_pro_tile.dart` | ⏳ Sprint 3 |
| 1 | `lib/core/design/widgets/lynewed_section_header.dart` | ⏳ Sprint 3 |
| 2 | `lib/features/my_wedding/domain/entities/wedding_overview.dart` | ✅ |
| 2 | `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart` | ✅ |
| 2 | `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` | ✅ |
| 2 | `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart` | ✅ |
| 2 | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` | ✅ |
| 2 | `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart` | ✅ |

### Fichiers à CRÉER (Sprint 3+)

| S | Fichier |
|---|---------|
| 3 | `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart` |
| 4 | `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart` |
| 4 | `lib/features/my_wedding/presentation/sheets/exclude_pro_sheet.dart` |
| 4 | `supabase/functions/wedding_event_reminder/index.ts` (CRON horaire, rappel 24h) |
| 5 | `lib/features/weddings_hub_pro/` (structure complète, sans pro_notes) |
| 5 | `lib/core/design/widgets/lynewed_wedding_client_card.dart` |
| 6 | `lib/core/design/widgets/lynewed_album_grid.dart` |
| 6 | `lib/core/design/widgets/lynewed_album_card.dart` |
| 6 | `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart` |
| 6 | `lib/features/my_wedding/presentation/sheets/create_album_sheet.dart` |
| 6 | `lib/features/my_wedding/presentation/pages/inspirations_page.dart` |
| 6 | `lib/features/my_wedding/presentation/pages/album_detail_page.dart` |
| 7 | `lib/core/design/widgets/lynewed_todo_item.dart` |
| 7 | `lib/core/design/widgets/lynewed_guest_tile.dart` |
| 7 | `lib/core/design/widgets/lynewed_note_card.dart` |
| 7 | `lib/features/my_wedding/presentation/pages/agenda_page.dart` |
| 7 | `lib/features/my_wedding/presentation/pages/budget_page.dart` |
| 7 | `lib/features/my_wedding/presentation/pages/guests_page.dart` |
| 7 | `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart` |
| 7 | `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart` |
| 7 | `lib/features/my_wedding/presentation/sheets/edit_note_sheet.dart` |
| 7 | `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart` |
| 8 | `lib/core/design/widgets/lynewed_attachment_modal.dart` |
| 8 | `lib/core/design/widgets/lynewed_document_message.dart` |
| 8 | `lib/features/my_wedding/presentation/sheets/cancel_wedding_sheet.dart` |

### Fichiers à MODIFIER

| S | Fichier | Modification | Status |
|---|---------|--------------|--------|
| 1 | `nav_bar_brides_widget.dart` | Nouvel ordre tabs | ✅ |
| 1 | `nav_bar_pro_widget.dart` | Nouvel ordre tabs | ✅ |
| 1 | `home_brides_widget.dart` | Settings icon | ⏳ (reporté) |
| 1 | `dashboard_pro_widget.dart` | Settings icon | ⏳ (reporté) |
| 6 | `feed_detail_viewer_widget.dart` | Icône signet | ⏳ |
| 8 | `map_page.dart` | Nouveau comportement FAB | ⏳ |
| 8 | `wedding_details_sheet.dart` | Nouveaux boutons | ⏳ |
| 8 | `message_composer.dart` | Attachment button | ⏳ |
| 8 | `message_bubble.dart` | Support document | ⏳ |

---

## ✅ Checklist Finale

### Backend (Sprint 1) ✅
- [x] Toutes migrations exécutées
- [x] Enums mis à jour
- [x] RLS policies testées
- [x] 7 triggers fonctionnels
- [x] Storage buckets configurés
- [ ] Edge Function reminder déployée (Sprint 4)

### Frontend (Sprint 1-2) ✅
- [x] Navbars modifiées
- [ ] Settings icon headers (reporté)
- [ ] 11 widgets Design System (4/11 - reste Sprint 3+)
- [x] MyWeddingPage créée
- [x] WeddingOnboardingWidget créé
- [ ] Tous sheets créés (Sprint 3+)
- [ ] Chat étendu (documents) (Sprint 8)

### Tests (Sprint 2) ✅
- [x] Test manuel onboarding Bride
- [x] Test persistence (reprise onboarding)
- [x] Test budget min/max
- [x] Test cover image upload
- [ ] Tests unitaires usecases (Sprint 3+)
- [ ] Test manuel Pro (Sprint 5)

### Documentation (Sprint 2) ✅
- [x] Mise à jour PROJECT.md
- [x] Mise à jour PROJECT_TODO.md
- [x] Mise à jour MY_WEDDING_SUITE.md
- [x] Mise à jour ce document (IMPLEMENTATION_PLAN)
- [ ] Mise à jour DESIGN_SYSTEM.md (si nouveaux widgets)
- [ ] Archiver audit après implémentation complète

---

## 📝 Notes de Suivi

| Sprint | Status | Date Début | Date Fin |
|--------|--------|------------|----------|
| 1 | ✅ TERMINÉ | 2025-12-10 | 2025-12-10 |
| 2 | ✅ TERMINÉ | 2025-12-10 | 2025-12-11 |
| 3 | ⏳ Pending | - | - |
| 4 | ⏳ Pending | - | - |
| 5 | ⏳ Pending | - | - |
| 6 | ⏳ Pending | - | - |
| 7 | ⏳ Pending | - | - |
| 8 | ⏳ Pending | - | - |

---

**Document créé:** 2025-12-10  
**Version:** 2.3 (Sprint 2 terminé 2025-12-11)  
**Changements V2.3:**
- ✅ Sprint 1 TERMINÉ (migrations, triggers, RLS, buckets, navbar)
- ✅ Sprint 2 TERMINÉ (onboarding 7 étapes, persistence, overview card)
- ✅ Onboarding simplifié: 7 étapes au lieu de 9 (Welcome + Features Preview retirés)
- ✅ Budget: stocké en devise sélectionnée (colonnes `_eur` supprimées)
- ✅ Search radius: optionnel avec checkbox + slider (10-500km)
- ✅ Cover image: upload vers bucket `wedding-covers`
- ✅ search_area_coords: maintenant populé automatiquement

**Prochaine action:** Démarrer Sprint 3 - My Wedding Page sections (Wedding Team, Agenda, Budget)
