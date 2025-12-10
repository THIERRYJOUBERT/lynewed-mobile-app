# MY WEDDING SUITE - Plan d'Implémentation Final V2

**Version:** 2.0  
**Date:** 2025-12-10  
**Status:** ✅ VALIDÉ - Prêt pour Implémentation  
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

**Checklist:** `[ ]` Exécuter | `[ ]` Vérifier via MCP

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

**Checklist:** `[ ]` ÉTAPE 1 | `[ ]` ÉTAPE 2 | `[ ]` ÉTAPE 3 | `[ ]` ÉTAPE 4 | `[ ]` Vérifier

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

**Checklist:** `[ ]` chat_rooms | `[ ]` chat_messages

### 1.4 Créer Nouvelles Tables

**Ordre FK:** 1→7

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
  reminder_minutes INTEGER[] DEFAULT '{1440, 60}', reminder_sent BOOLEAN DEFAULT false,
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

-- 7. pro_wedding_notes
CREATE TABLE IF NOT EXISTS pro_wedding_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_profile_id UUID NOT NULL REFERENCES profiles(id),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  notes TEXT, created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(professional_profile_id, wedding_id)
);
ALTER TABLE pro_wedding_notes ENABLE ROW LEVEL SECURITY;
```

**Checklist:** `[ ]` wedding_guests | `[ ]` inspiration_albums | `[ ]` saved_posts | `[ ]` album_images | `[ ]` wedding_events | `[ ]` wedding_expenses | `[ ]` pro_wedding_notes

### 1.5 RLS Policies

**Voir fichier séparé:** `docs/sql/MY_WEDDING_SUITE_RLS.sql`

**Checklist:**
- `[ ]` Policies wedding_guests
- `[ ]` Policies inspiration_albums  
- `[ ]` Policies saved_posts
- `[ ]` Policies album_images
- `[ ]` Policies wedding_events
- `[ ]` Policies wedding_expenses
- `[ ]` Policies pro_wedding_notes
- `[ ]` **Policies chat_rooms pour wedding_team** (NOUVEAU)
- `[ ]` **Policies chat_messages pour wedding_team** (NOUVEAU)

### 1.6 Triggers & Functions (8 au total)

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
| 8 | `notify_wedding_team_message()` | `trigger_notify_wedding_team_message` | Notif: message groupe |

**Checklist:** `[ ]` 1 | `[ ]` 2 | `[ ]` 3 | `[ ]` 4 | `[ ]` 5 | `[ ]` 6 | `[ ]` 7 | `[ ]` 8

### 1.7 Storage Buckets

| Bucket | Public | Max Size | MIME Types |
|--------|--------|----------|------------|
| `wedding-albums` | ✅ | 5MB | image/jpeg, image/png, image/webp |
| `chat-documents` | ❌ | 10MB | application/pdf |
| `wedding-covers` | ✅ | 5MB | image/jpeg, image/png, image/webp |

**Checklist:** `[ ]` Créer buckets | `[ ]` Policies storage

### 1.8 Widgets Design System Core

| Widget | Fichier | Description |
|--------|---------|-------------|
| `LynewedCountdownCard` | `lynewed_countdown_card.dart` | Cover, nom, date, countdown J-XX |
| `LynewedTeamChatItem` | `lynewed_team_chat_item.dart` | Avatars, badge unread |
| `LynewedProTile` | `lynewed_pro_tile.dart` | Photo, nom, profession, chat icon |
| `LynewedSectionHeader` | `lynewed_section_header.dart` | Titre + action |

**Checklist:** `[ ]` CountdownCard | `[ ]` TeamChatItem | `[ ]` ProTile | `[ ]` SectionHeader | `[ ]` Export widgets.dart

### 1.9 Navbar Restructuring

**NavBarBrides:** Home | Feed | **My Wedding** | WOTW | Replay
**NavBarPro:** Home | Feed | **Weddings** | WOTW | Replay

**Checklist:** `[ ]` NavBarBridesWidget | `[ ]` NavBarProWidget | `[ ]` Placeholder MyWeddingPage | `[ ]` Placeholder WeddingsHubProPage

### 1.10 Settings Icon in Headers

**Fichiers:** `home_brides_widget.dart` + `dashboard_pro_widget.dart`

**Checklist:** `[ ]` HomeBridesWidget | `[ ]` DashboardProWidget

### 1.11 Migration One-Time Mariages Existants

Script pour créer chat wedding_team pour mariages existants sans chat.

**Checklist:** `[ ]` Exécuter script | `[ ]` Vérifier

---

## 📋 SPRINT 2: Onboarding

**Durée:** 2-3 jours | **Dépendances:** Sprint 1.1-1.6 | **Priorité:** 🔴 HAUTE

### 2.1 Structure Module + Entities

```
lib/features/my_wedding/
├── domain/
│   ├── entities/ (7 fichiers)
│   ├── repositories/my_wedding_repository.dart
│   └── usecases/ (6 fichiers)
├── data/
│   ├── datasources/supabase_my_wedding_datasource.dart
│   └── repositories/my_wedding_repository_impl.dart
└── presentation/pages/wedding_onboarding_page.dart
```

**Entities:** wedding_onboarding, wedding_guest, wedding_event, wedding_expense, inspiration_album, saved_post, album_image

**Usecases:** get_wedding_overview, get_wedding_team, invite_pro_to_wedding, exclude_pro_from_wedding, save_post_to_album, complete_onboarding

**Checklist:** `[ ]` Structure | `[ ]` 7 entities | `[ ]` Repository interface | `[ ]` Datasource | `[ ]` Repository impl | `[ ]` 6 usecases

### 2.2 Onboarding Pages (9 écrans)

| Step | Contenu | Obligatoire | Skip |
|------|---------|-------------|------|
| 1 | Welcome | - | - |
| 2 | Date | ✅ | Non |
| 3 | Location | ✅ | Non |
| 4 | Professionals | ❌ | Oui |
| 5 | Guest Count | ❌ | Oui |
| 6 | Budget | ❌ | Oui |
| 7 | Visibility | ❌ | Oui |
| 8 | Features Preview | - | - |
| 9 | Done | - | - |

**Persistence:** Step 2 = créer wedding | Steps 3-7 = update | Step 9 = set onboarding_step=null

**Assets nécessaires:** `[ ]` Illustration Welcome | `[ ]` Icons Features Preview | `[ ]` Illustration Done

**Checklist:** `[ ]` 9 écrans | `[ ]` Progress indicator | `[ ]` Back button | `[ ]` Skip buttons | `[ ]` Assets

### 2.3 Persistence Logic

**Datasource methods:**
- `createWedding()` - Appelé step 2
- `updateOnboardingData()` - Steps 3-8
- `completeOnboarding()` - Step 9 (set null)
- `getMyWedding()` - Récupérer état
- `getContactedPros()` - Pour invitation

**Checklist:** `[ ]` 5 methods | `[ ]` Test persistence | `[ ]` Test reprise

### 2.4 Chat Wedding Team Auto-Creation

Vérifier trigger `create_wedding_team_chat` fonctionne quand onboarding_step → null

**Checklist:** `[ ]` Test trigger | `[ ]` Vérifier room créée | `[ ]` Vérifier bride participant

---

## 📋 SPRINT 3: My Wedding Page (Bride)

**Durée:** 3-4 jours | **Dépendances:** Sprint 2 | **Priorité:** 🔴 HAUTE

### 3.1 Page Skeleton + Routing

**Logique:** Pas de mariage → Onboarding | Onboarding en cours → Reprendre | Complété → My Wedding Page

**Checklist:** `[ ]` MyWeddingPage | `[ ]` Route index.dart | `[ ]` Logique conditionnelle

### 3.2 Wedding Countdown Card

**Props:** coverImageUrl, weddingName, eventDate, venueLabel, participantsCount, onEdit

**Checklist:** `[ ]` Intégrer widget | `[ ]` Upload cover | `[ ]` Calcul countdown | `[ ]` WeddingEditSheet

### 3.3 Wedding Team Chat Item

**Props:** avatarUrls, unreadCount, participantsCount, onTap

**Checklist:** `[ ]` Intégrer widget | `[ ]` Charger avatars | `[ ]` Charger unread | `[ ]` Navigation ChatDetailsPage

### 3.4 Wedding Team Section

Liste de `LynewedProTile` avec actions: Tap → ProDetails | Long press → Modal | Chat icon → Chat 1-1

**Checklist:** `[ ]` Section | `[ ]` Charger pros | `[ ]` Tap | `[ ]` Long press modal | `[ ]` Chat 1-1

### 3.5 Header avec Icônes

Chat → MessagesPage filtré | Settings → Menu mariage

**Checklist:** `[ ]` Header | `[ ]` Filtre MessagesPage | `[ ]` Menu settings

### 3.6 Sections Overview (Preview)

Agenda | Budget | Inspirations | Guests | Note for Pros

**Checklist:** `[ ]` 5 sections preview | `[ ]` Navigation vers pages détail

### 3.7 Cancelled Wedding View

Si status=cancelled: afficher écran "Mariage annulé" + bouton "Reprendre"

**Checklist:** `[ ]` CancelledWeddingView widget | `[ ]` Logique détection | `[ ]` Bouton reprendre

---

## 📋 SPRINT 4: Wedding Team Features

**Durée:** 2-3 jours | **Dépendances:** Sprint 3 | **Priorité:** 🔴 HAUTE

### 4.1 Invite Pro Flow

**Sheet:** `invite_pro_sheet.dart`
**Logique:** Recherche nom OU liste pros contactés → Sélection → Ajout auto → Notification

**Checklist:** `[ ]` InviteProSheet | `[ ]` Recherche | `[ ]` Liste contactés | `[ ]` Ajout | `[ ]` Test notif

### 4.2 Exclude Pro Flow

**Sheet:** `exclude_pro_sheet.dart`
**Logique:** Confirmation + raison → status=excluded → Retrait chat → Notification

**Checklist:** `[ ]` ExcludeProSheet | `[ ]` Confirmation | `[ ]` Update status | `[ ]` Test trigger chat | `[ ]` Test notif

### 4.3 Pro Quit Flow (côté Pro)

**Sheet:** `leave_wedding_sheet.dart`
**Logique:** Raison obligatoire → status=left → Retrait chat → Notification bride

**Checklist:** `[ ]` LeaveWeddingSheet | `[ ]` Raison obligatoire | `[ ]` Update status | `[ ]` Test trigger | `[ ]` Test notif

### 4.4 Notifications (6 types)

| Type | Destinataire | Trigger |
|------|--------------|---------|
| `wedding_pro_added` | Pro | INSERT participants (active) |
| `wedding_pro_excluded` | Pro | UPDATE participants (excluded) |
| `wedding_pro_left` | Bride | UPDATE participants (left) |
| `wedding_team_message` | Tous sauf sender | INSERT chat_messages (wedding_team) |
| `wedding_event_reminder` | Bride | **Edge Function CRON** |
| `wedding_cancelled` | Tous pros | UPDATE weddings (cancelled) |

**Checklist:** `[ ]` 5 triggers SQL | `[ ]` Edge Function reminder | `[ ]` Test toutes notifs

### 4.5 Edge Function `wedding_event_reminder`

**Fichier:** `supabase/functions/wedding_event_reminder/index.ts`

```typescript
// CRON: toutes les 15 minutes
// 1. SELECT events WHERE event_date - NOW() matches reminder_minutes AND NOT reminder_sent
// 2. Pour chaque: INSERT notifications_outbox
// 3. UPDATE reminder_sent = true
```

**Checklist:** `[ ]` Créer Edge Function | `[ ]` Config CRON | `[ ]` Test

### 4.6 Chat 1-1 Access Filtré

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
    └── sheets/leave_wedding_sheet.dart, pro_notes_sheet.dart
```

**Checklist:** `[ ]` Structure | `[ ]` Entity | `[ ]` Repository | `[ ]` Datasource

### 5.2 Weddings Hub Page

Liste `LynewedWeddingClientCard` | Tap → Detail | Long press → Modal (mute, quitter)

**Checklist:** `[ ]` LynewedWeddingClientCard (Design System) | `[ ]` WeddingsHubPage | `[ ]` Charger mariages | `[ ]` Tap | `[ ]` Long press

### 5.3 Wedding Client Detail Page

**Sections:** Header | Bride Info | Wedding Team Chat | Chat with Bride | Shared Albums | Shared Events | Bride's Note | My Notes

**Checklist:** `[ ]` Page | `[ ]` 8 sections | `[ ]` Actions menu

### 5.4 Mute Workflow

Long press → Modal → Toggle `is_muted`

**Checklist:** `[ ]` Modal | `[ ]` Toggle | `[ ]` Test

### 5.5 Pro Notes

**Sheet:** `pro_notes_sheet.dart` - CRUD notes privées

**Checklist:** `[ ]` ProNotesSheet | `[ ]` CRUD | `[ ]` Test

### 5.6 Mute Global Settings (Optionnel)

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

### Fichiers à CRÉER (Sprint → Fichier)

| S | Fichier |
|---|---------|
| 1 | `lib/core/design/widgets/lynewed_countdown_card.dart` |
| 1 | `lib/core/design/widgets/lynewed_team_chat_item.dart` |
| 1 | `lib/core/design/widgets/lynewed_pro_tile.dart` |
| 1 | `lib/core/design/widgets/lynewed_section_header.dart` |
| 2 | `lib/features/my_wedding/` (structure complète) |
| 3 | `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` |
| 3 | `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart` |
| 4 | `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart` |
| 4 | `lib/features/my_wedding/presentation/sheets/exclude_pro_sheet.dart` |
| 4 | `supabase/functions/wedding_event_reminder/index.ts` |
| 5 | `lib/features/weddings_hub_pro/` (structure complète) |
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

| S | Fichier | Modification |
|---|---------|--------------|
| 1 | `nav_bar_brides_widget.dart` | Nouvel ordre tabs |
| 1 | `nav_bar_pro_widget.dart` | Nouvel ordre tabs |
| 1 | `home_brides_widget.dart` | Settings icon |
| 1 | `dashboard_pro_widget.dart` | Settings icon |
| 6 | `feed_detail_viewer_widget.dart` | Icône signet |
| 8 | `map_page.dart` | Nouveau comportement FAB |
| 8 | `wedding_details_sheet.dart` | Nouveaux boutons |
| 8 | `message_composer.dart` | Attachment button |
| 8 | `message_bubble.dart` | Support document |

---

## ✅ Checklist Finale

### Backend
- [ ] Toutes migrations exécutées
- [ ] Enums mis à jour
- [ ] RLS policies testées
- [ ] 8 triggers fonctionnels
- [ ] Storage buckets configurés
- [ ] Edge Function reminder déployée

### Frontend
- [ ] Navbars modifiées
- [ ] Settings icon headers
- [ ] 12 widgets Design System
- [ ] Toutes pages créées
- [ ] Tous sheets créés
- [ ] Chat étendu (documents)

### Tests
- [ ] Tests unitaires usecases
- [ ] Tests intégration flows
- [ ] Test manuel Bride
- [ ] Test manuel Pro
- [ ] Test 6 notifications

### Documentation
- [ ] Mise à jour PROJECT.md
- [ ] Mise à jour DESIGN_SYSTEM.md
- [ ] Archiver audit après implémentation

---

## 📝 Notes de Suivi

| Sprint | Status | Date Début | Date Fin |
|--------|--------|------------|----------|
| 1 | ⏳ Pending | - | - |
| 2 | ⏳ Pending | - | - |
| 3 | ⏳ Pending | - | - |
| 4 | ⏳ Pending | - | - |
| 5 | ⏳ Pending | - | - |
| 6 | ⏳ Pending | - | - |
| 7 | ⏳ Pending | - | - |
| 8 | ⏳ Pending | - | - |

---

**Document créé:** 2025-12-10  
**Version:** 2.0 (post-audit critique)  
**Prochaine action:** Démarrer Sprint 1 - Migrations Supabase
