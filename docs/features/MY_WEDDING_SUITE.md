# MY WEDDING SUITE - Feature Specification

**Status:** 🟢 VALIDATED  
**Created:** 2025-12-10  
**Last Updated:** 2025-12-10  
**Priority:** HIGH - Bridal Retention Feature  
**Scope:** Production-Ready Feature (not MVP)

---

## 📋 Executive Summary

**Objectif:** Créer un espace centralisé "My Wedding Suite" pour les brides afin d'augmenter la rétention sur l'application. Actuellement, les brides n'ont pas d'intérêt à rester longtemps sur l'app après avoir trouvé leurs prestataires.

**Vision:** Transformer Lynewed en QG de wedding planning premium, remplaçant WhatsApp et autres outils fragmentés.

**Scope:** Feature complète prête à la production, pas un MVP.

---

## 🔄 Current State Analysis

### Navigation Actuelle (Brides)
| # | Tab | Page | Route |
|---|-----|------|-------|
| 1 | Home | `HomeBridesWidget` | `/homeBrides` |
| 2 | Feed | `FeedBridesWidget` | `/feedBrides` |
| 3 | Wedding | `WeddingOfTheWeekWidget` | `/weddingOfTheWeek` |
| 4 | Replay | `ContentReplayWidget` | `/contentReplay` |
| 5 | Profil | `ProfileBridesAndProWidget` | `/profileBridesAndPro` |

### Navigation Actuelle (Pros)
| # | Tab | Page | Route |
|---|-----|------|-------|
| 1 | Home | `DashboardProWidget` | `/dashboardPro` |
| 2 | Wedding | `WeddingOfTheWeekWidget` | `/weddingOfTheWeek` |
| 3 | Replay | `ContentReplayWidget` | `/contentReplay` |
| 4 | Feed | `FeedBridesWidget` | `/feedBrides` |
| 5 | Settings | `ProfileBridesAndProWidget` | `/profileBridesAndPro` |

### Tables Supabase Existantes
- **`weddings`** - 1 mariage par bride (hub central)
- **`wedding_participants`** - Pros confirmés pour un mariage (status: requested/accepted/declined)
- **`wishlist_items`** - Favoris simples (bride → pro)
- **`chat_rooms`** - Rooms privées et publiques
- **`chat_room_participants`** - Participants avec statuts
- **`chat_messages`** - Messages (text, image, audio)
- **`connection_requests`** - Demandes de contact (pending/accepted/declined)

---

## 🎯 Validated Changes

### 1. Navigation Restructuring ✅

#### Brides - New Navbar
| # | Tab | Label | Icon | Page | Notes |
|---|-----|-------|------|------|-------|
| 1 | Home | Home | `home_outlined` | `HomeBridesWidget` | Inchangé |
| 2 | Feed | Feed | `search_sharp` | `FeedBridesWidget` | Inchangé |
| 3 | **My Wedding** | My Wedding | `favorite_border` | **`MyWeddingPage`** | **NOUVEAU** |
| 4 | WOTW | WOTW | `star_border` | `WeddingOfTheWeekWidget` | Renommé |
| 5 | Replay | Replay | `mic_none` | `ContentReplayWidget` | Inchangé |

**Settings déplacé:** Icône `settings_outlined` en haut à droite de `HomeBridesWidget` (à côté des notifications/messages)

#### Pros - New Navbar
| # | Tab | Label | Icon | Page | Notes |
|---|-----|-------|------|------|-------|
| 1 | Home | Home | `home_outlined` | `DashboardProWidget` | Inchangé |
| 2 | Feed | Feed | `search_sharp` | `FeedBridesWidget` | Inchangé |
| 3 | **Weddings** | Weddings | `favorite_border` | **`WeddingsHubProPage`** | **NOUVEAU** |
| 4 | WOTW | WOTW | `star_border` | `WeddingOfTheWeekWidget` | Renommé |
| 5 | Replay | Replay | `mic_none` | `ContentReplayWidget` | Inchangé |

**Settings déplacé:** Icône `settings_outlined` en haut à droite de `DashboardProWidget`

---

## 📱 My Wedding Suite - Feature Breakdown

### 2.1 My Wedding Page (Bride) ✅

Page principale accessible depuis la navbar.

#### Si pas de mariage créé
**Onboarding guidé multi-étapes** (9 écrans) :

| Étape | Contenu | Obligatoire | Skip | Notes |
|-------|---------|-------------|------|-------|
| 1 | **Welcome** | - | - | Intro "Let's plan your wedding" + visuel inspirant |
| 2 | **Date** | ✅ Oui | Non | "Quand est ton mariage ?" + mention "modifiable plus tard" |
| 3 | **Location** | ✅ Oui | Non | "Où se passe ton mariage ?" + mention "modifiable plus tard" |
| 4 | **Professionals** | ❌ Non | Oui | "Quels pros recherches-tu ?" - Sélection multiple |
| 5 | **Guest Count** | ❌ Non | Oui | "Combien d'invités prévus ?" - Estimation |
| 6 | **Budget** | ❌ Non | Oui | "Quel est ton budget ?" - Slider min/max |
| 7 | **Visibility** | ❌ Non | Oui | "Veux-tu être visible des pros ?" - Default: private |
| 8 | **Features Preview** | - | - | Écran marketing : présentation Agenda + Notes (informatif, pas d'action) |
| 9 | **Done** | - | - | Récap + "Start planning!" |

**Écran 8 - Features Preview (Marketing) :**
- Titre : "Organise ton mariage comme une pro"
- Présentation visuelle des fonctionnalités :
  - 📅 "Ajoute tes rendez-vous et tâches dans ton agenda"
  - 📝 "Garde une note visible par tes prestataires"
  - 💰 "Suis ton budget en un coup d'œil"
  - 📸 "Crée des albums d'inspiration"
- Pas d'action, juste "Continuer" pour passer à l'écran Done
- Objectif : montrer la valeur de l'outil avant de commencer

**Notes importantes :**
- L'onboarding reste **simple et rapide** (~2 min)
- Seuls Date et Location sont obligatoires
- Toutes les autres fonctionnalités sont accessibles **après** dans My Wedding Page
- Chaque étape obligatoire affiche "Tu pourras modifier ces informations plus tard"

**Persistence :** Sauvegarde automatique à chaque étape. Si la bride quitte et revient, elle reprend où elle s'est arrêtée.

**Storage :** Utiliser `weddings` table avec un nouveau champ `onboarding_step` (nullable, 1-9). Si null → onboarding terminé.

```sql
ALTER TABLE weddings ADD COLUMN onboarding_step SMALLINT; -- null = completed
```

**À la fin de l'onboarding :**
- Mariage créé avec status `active`
- Chat Wedding Team créé (vide, prêt à recevoir des messages)
- Bride redirigée vers My Wedding Page

> Note: `WeddingCreateSheet` sera potentiellement supprimé ou simplifié.

#### Si mariage existe - My Wedding Page Layout

**Header :**
- Icône **Chat** (droite) → Navigue vers `MessagesPage` filtré par pros actifs du mariage
- Icône **Settings** (droite) → Menu mariage (edit, cancel, etc.)

**Sections (ordre hiérarchique) :**

| # | Section | Contenu | Actions |
|---|---------|---------|---------|
| 1 | **Wedding Countdown Card** | Cover image, nom, date, lieu, countdown J-XX, nombre de participants | Tap "Edit" → Sheet d'édition |
| 2 | **Wedding Team Chat** | Item style salon (avatars pros, nb messages non lus, nb participants) | Tap → `ChatDetailsPage` du groupe |
| 3 | **Wedding Team** | Liste des pros ajoutés (photo, nom, profession, icône chat) | Tap → `ProDetailsPage` / Long press → Modal (exclure, report) / Tap icône chat → Chat 1-1 |
| 4 | **Agenda** | Prochains événements (todo list avec états) | Tap → Page agenda complète |
| 5 | **Budget** | Résumé dépenses (todo list avec états) | Tap → Page budget complète |
| 6 | **Inspirations** | Grille albums (Wedding + Privés) | Tap → Page albums / Tap album → Détail |
| 7 | **Guests** | Liste invités (anticipation future) | Tap → Page guests |
| 8 | **Note for Pros** | Note unique de la bride (max 1000 chars) visible par tous les pros | Tap → Éditer la note |

**Wedding Team Chat Item :**
- Style similaire aux salons brides existants
- Affiche 3-4 avatars circulaires des pros (ou bride si vu côté pro)
- Badge nombre de messages non lus
- Nombre de participants
- Tap → Ouvre `ChatDetailsPage` du groupe wedding_team

### 2.2 Wedding Team ✅

#### Flux d'invitation des Pros
1. **Bride invite un pro** depuis My Wedding :
   - Recherche par nom OU liste des pros déjà contactés (prioritaire)
   - Sélection du pro → Ajout automatique (pas de validation côté pro)
2. **Pro reçoit notification** : "Vous avez été ajouté au mariage de [Bride]"
3. **Pro voit le mariage** dans son onglet "Weddings"
4. **Pro peut quitter** : Sheet similaire à "report_user" avec raison obligatoire

#### Gestion par la Bride
- **Bride est maître de son mariage** : elle peut tout faire
- **Exclure un pro** : Sheet avec confirmation → Pro retiré du groupe + notification
- **Voir l'historique** : Pros actuels + pros qui ont quitté/été exclus

#### Wedding Team Chat
- **Nouveau type de room** : `wedding_team` (pas un flag sur `private`)
- Tous les pros ajoutés + la bride sont participants
- Messages : text, image, audio, **document** (nouveau)
- **Notifications** : Push pour chaque message
- **Mute option** : Pro ET Bride peuvent muter le groupe (pas de push mais visible dans l'app)
- **Settings notifications** : Option globale pour désactiver les push des groupes mariage (Brides + Pros)

#### Table `wedding_participants` (existante, à adapter)
```sql
-- Modification du statut enum
-- Avant: requested, accepted, declined
-- Après: active, left, excluded

ALTER TYPE wedding_participant_status ADD VALUE 'excluded';
ALTER TYPE wedding_participant_status RENAME VALUE 'requested' TO 'active';
ALTER TYPE wedding_participant_status RENAME VALUE 'declined' TO 'left';
-- 'accepted' devient obsolète

-- Ajout colonnes
ALTER TABLE wedding_participants ADD COLUMN left_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN left_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN excluded_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN excluded_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN is_muted BOOLEAN DEFAULT false;
```

### 2.3 Wedding Guests (Anticipation Future) ✅

Liste des invités au mariage pour anticipation des features futures (album photos partagé, lien unique par invité).

**Nouvelle table :**
```sql
CREATE TABLE wedding_guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  phone TEXT,
  role TEXT, -- 'guest', 'bridesmaid', 'best_man', 'family', etc.
  notes TEXT,
  -- Future: invitation_token, has_app_access, etc.
  created_at TIMESTAMPTZ DEFAULT now()
);
```

**UX :**
- Ajout simple : nom + email OU téléphone
- Pas d'invitation envoyée (juste stockage)
- Préparation pour features futures

### 2.4 Moodboard / Inspirations ✅

#### Concept
La bride peut créer des albums d'inspiration de deux types :
1. **Albums Wedding (partagés)** - Visibles par la Wedding Team
2. **Albums Privés** - Uniquement pour la bride

#### Sources d'images
| Source | Albums Wedding | Albums Privés |
|--------|----------------|---------------|
| Feed (posts) | ✅ Oui | ✅ Oui |
| Galerie photo | ✅ Oui | ✅ Oui |

#### Flux 1 : Depuis le Feed
1. Bride ouvre une photo en plein écran (`feed_detail_viewer_widget.dart`)
2. Tap sur **icône signet** (bookmark)
3. **Modal** s'ouvre avec :
   - Section "Wedding Albums" (partagés avec team)
   - Section "Private Albums" (bride only)
   - Option "Create new album" (choix type)
4. Sélection album → Photo sauvegardée

#### Flux 2 : Depuis My Wedding (Galerie)
1. Bride va dans section "Inspirations" de My Wedding
2. Ouvre un album (Wedding ou Privé)
3. Tap "Add photos" → Accès galerie téléphone
4. Sélection multiple → Upload vers album

#### Tables
```sql
CREATE TABLE inspiration_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
  bride_profile_id UUID REFERENCES profiles(id), -- Owner
  name TEXT NOT NULL,
  cover_image_url TEXT,
  category TEXT, -- 'florals', 'dress', 'beauty', 'decor', 'photos', 'venue', 'general'
  is_private BOOLEAN DEFAULT false, -- true = bride only, false = shared with team
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Pour les images du Feed
CREATE TABLE saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID REFERENCES inspiration_albums(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(album_id, post_id)
);

-- Pour les images uploadées depuis galerie
CREATE TABLE album_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID REFERENCES inspiration_albums(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT now()
);
```

#### Visibilité & Catégories
| Type Album | Bride | Pros (Wedding Team) |
|------------|-------|---------------------|
| Wedding (is_private=false) | ✅ Voir + Edit | ✅ Voir seulement |
| Private (is_private=true) | ✅ Voir + Edit | ❌ Non visible |

#### Catégories & Noms personnalisés
- **Catégories prédéfinies :** `dress`, `decor`, `flowers`, `venue`, `beauty`, `photos`, `stationery`, `general`
- **Catégories custom :** La bride peut créer ses propres catégories/tags
- **Nom d'album :** Libre (ex: "Robes coup de cœur", "Déco table", etc.)

**Conversion privé ↔ public :** Un album privé peut devenir public (visible dans le mariage) à tout moment. L'inverse est aussi possible.

### 2.5 Agenda ✅

**Concept simplifié :** Todo list avec dates et états (pas un calendrier complexe).

```sql
CREATE TABLE wedding_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMPTZ NOT NULL,
  event_end_date TIMESTAMPTZ,
  location TEXT,
  linked_pro_id UUID REFERENCES profiles(id), -- Pro associé (optionnel)
  is_public BOOLEAN DEFAULT false, -- Visible par les pros si true
  status TEXT DEFAULT 'pending', -- 'pending', 'done', 'cancelled'
  reminder_minutes INTEGER[] DEFAULT '{1440, 60}', -- 1 jour + 1h avant
  created_at TIMESTAMPTZ DEFAULT now()
);
```

**UX :**
- Vue liste chronologique (pas de calendrier complexe)
- Chaque item : titre, date, statut (à faire / fait / annulé)
- Push notifications pour rappels (bride uniquement)
- Lien vers le chat du pro si associé
- Toggle public/privé par événement

### 2.6 Budget Tracker ✅

**Concept simplifié :** Todo list de dépenses avec états (pas un outil comptable complexe).

```sql
CREATE TABLE wedding_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
  category TEXT NOT NULL, -- 'venue', 'photographer', 'dress', 'flowers', etc.
  description TEXT,
  amount NUMERIC NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'partial', 'paid'
  paid_amount NUMERIC DEFAULT 0,
  due_date DATE,
  linked_pro_id UUID REFERENCES profiles(id), -- Pro associé (optionnel)
  created_at TIMESTAMPTZ DEFAULT now()
);
```

**UX :**
- Header avec budget total (si défini via `budget_max`) + dépensé + restant
- Barre de progression visuelle (optionnelle)
- Liste des dépenses
- Chaque item : description, montant, statut (à payer / acompte / payé)
- Possibilité de lier à un pro du mariage

### 2.7 Note for Pros ✅

**Concept simplifié :** Une seule note publique de la bride pour donner des indications générales aux pros.

**Caractéristiques :**
- **Une seule note** par mariage (pas de liste de notes)
- **Max 1000 caractères**
- **Visible par tous les pros** de la Wedding Team
- **Éditable** uniquement par la bride
- **Optionnelle** (peut rester vide)

**Exemples d'utilisation :**
- "Notre thème est bohème chic, couleurs pastel"
- "Le lieu est difficile d'accès, prévoir 30min de plus"
- "Ma mère est allergique aux fleurs de lys"

```sql
-- Pas de nouvelle table, on ajoute une colonne à weddings
ALTER TABLE weddings ADD COLUMN note_for_pros TEXT; -- max 1000 chars (enforced in app)
```

> **Décision :** On évite une table `wedding_notes` avec plusieurs notes pour ne pas surcharger les pros avec trop d'informations à lire.

### 2.8 Documents dans les Chats ✅

Nouveau type de message pour les documents (PDF uniquement pour V1).

#### UX dans ChatDetailsPage
- **Icône attachment** (gauche de la chat bar, avant le champ texte)
- **Tap** → Modal avec choix :
  - "Envoyer une photo/vidéo" (existant)
  - "Envoyer un document" (nouveau)
- **Sélection document** → File picker (PDF uniquement)
- **Upload** → Message avec preview du document

#### Affichage du message document
- Item spécifique dans le chat
- Icône PDF + nom du fichier + taille
- Tap → Télécharger / Ouvrir le fichier

```sql
-- Ajout du type 'document' à l'enum messageType
ALTER TYPE "messageType" ADD VALUE 'document';

-- La colonne attachment_url stocke déjà l'URL du fichier
-- Ajout de colonnes pour les métadonnées
ALTER TABLE chat_messages ADD COLUMN attachment_name TEXT;
ALTER TABLE chat_messages ADD COLUMN attachment_size INTEGER; -- en bytes
ALTER TABLE chat_messages ADD COLUMN attachment_mime_type TEXT; -- 'application/pdf'
```

**Scope :**
- ✅ Chats privés 1-1 (bride ↔ pro)
- ✅ Wedding Team chat
- ❌ Salons publics brides (pas de documents)

**Format supporté V1 :** PDF uniquement (extensible plus tard)

---

## 🔧 Pro Side: Weddings Hub ✅

### Page Weddings Hub (Liste)
Liste de tous les mariages où le pro est participant actif.

**Affichage par mariage (Card/Item) :**
- Cover image du mariage
- Nom de la bride
- Date + countdown (J-XX)
- Lieu
- Nombre de participants (pros + estimation invités)
- Badge messages non lus

**Actions sur l'item :**
- **Tap** → Ouvre `WeddingClientDetailPage`
- **Long press** → Modal avec options :
  - "Muter les notifications" (toggle)
  - "Quitter ce mariage"

---

### Page Wedding Client Detail (Vue Pro)

Vue similaire à My Wedding Page mais avec sections réduites.

**Header :**
- Cover image du mariage
- Nom, date, lieu, countdown
- Nombre de participants (pros + estimation invités)

**Sections :**

| # | Section | Contenu | Actions |
|---|---------|---------|---------|
| 1 | **Bride Info** | Photo, nom, profession (si applicable) | Tap → Profil bride |
| 2 | **Wedding Team Chat** | Item style salon (avatars, nb messages non lus) | Tap → `ChatDetailsPage` du groupe |
| 3 | **Chat with Bride** | Accès direct au chat 1-1 | Tap → `ChatDetailsPage` privé |
| 4 | **Shared Albums** | Albums marqués publics par la bride | Tap → Voir album (lecture seule) |
| 5 | **Shared Events** | Événements marqués publics par la bride | Lecture seule |
| 6 | **Bride's Note** | Note de la bride (si remplie) | Lecture seule |
| 7 | **My Notes** | Notes privées du pro sur ce mariage | Tap → Éditer |

**Actions (menu ou footer) :**
- **Muter les notifications** : Toggle pour ce mariage
- **Quitter ce mariage** : Sheet avec raison obligatoire

---

### Notes Pro Privées
```sql
CREATE TABLE pro_wedding_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_profile_id UUID REFERENCES profiles(id),
  wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(professional_profile_id, wedding_id)
);
```

---

### Mute Workflow (Pro)

**Option 1 : Mute un mariage spécifique**
1. Long press sur un item mariage dans Weddings Hub
2. Modal → "Muter les notifications"
3. Toggle ON → Plus de push pour ce mariage (mais visible dans l'app)

**Option 2 : Mute tous les groupes mariage (global)**
1. Settings → Notifications
2. Toggle "Notifications groupes mariage" OFF
3. → Plus aucun push pour les Wedding Team Chats

---

## 🗺️ Map Integration ✅

### Icône "Pin my wedding" dans Map Large

**Comportement :**
- **Si pas de mariage** → Navigue vers `MyWeddingPage` pour l'onboarding
- **Si mariage existe** → Centre la map sur le point du mariage

**Tap sur le point du mariage :**
- Ouvre `WeddingDetailsSheet` (à revoir pour bride et pro)
- Bouton "Go to My Wedding" pour naviguer vers la page complète

---

## ✅ Decisions Validated (All Sessions)

| Sujet | Décision |
|-------|----------|
| **Navigation Brides** | Home, Feed, My Wedding, WOTW, Replay |
| **Navigation Pros** | Home, Feed, Weddings, WOTW, Replay |
| **Settings location** | Header top-right (à côté notifications) |
| **Onboarding** | 9 étapes, persistence, mention "modifiable plus tard" |
| **Onboarding - Obligatoire** | Seulement Date + Location |
| **Onboarding - Optionnel** | Professionals, Guest Count, Budget, Visibility |
| **Onboarding - Marketing** | Écran Features Preview (informatif, pas d'action) |
| **Chat groupe créé** | Dès la fin de l'onboarding (même vide) |
| **Accès chats 1-1** | Icône chat dans header → MessagesPage filtré |
| **Wedding Team Chat** | Item style salon avec avatars, tap → ChatDetailsPage |
| **Tap sur pro** | → ProDetailsPage + icône chat pour 1-1 |
| **Long press sur pro** | → Modal (exclure, report) |
| **Pro invitation** | Auto-ajouté, notification, peut quitter avec raison |
| **Bride can exclude** | Oui, avec confirmation + notification |
| **Documents in chat** | PDF uniquement, modal choix média/document |
| **Moodboard** | 2 types (Wedding/Private), catégories custom, noms libres |
| **Moodboard sources** | Feed + Galerie pour les deux types d'albums |
| **Moodboard conversion** | Privé ↔ Public à tout moment |
| **Agenda** | Todo list avec états, public/privé par item |
| **Budget** | Todo list avec états (à payer/acompte/payé) |
| **Notes bride** | UNE seule note, max 1000 chars, visible par tous les pros |
| **Notes pro** | Notes privées par pro par mariage |
| **Mute mariage (pro)** | Long press sur item → Modal mute |
| **Mute global** | Setting notifications pour tous les groupes mariage |
| **Annulation mariage** | Pas suppression, récupérable 6 mois |
| **Appels vidéo** | ❌ Pas maintenant |

---

## ✅ Points Clarifiés (Session 3)

### Budget Tracker → ✅ VALIDÉ
- **Version simple** : Liste de dépenses par catégorie
- **Budget total** : Utilise `budget_max` existant (optionnel)
- **Évolutif** : Pourra être enrichi plus tard

### Moodboard → ✅ VALIDÉ
- **Albums Wedding** : Visibles par pros, images du Feed + Galerie
- **Albums Privés** : Bride only, images du Feed + Galerie
- **Catégories** : Plusieurs albums par catégorie (dress, decor, flowers, etc.)
- **Conversion** : Album privé peut devenir public et vice-versa

---

## ✅ Points Clarifiés (Session 4)

### 1. Wedding Team Chat → ✅ VALIDÉ
- **Création** : Dès la fin de l'onboarding (même sans pros)
- **Bride peut envoyer** : Oui, même sans interlocuteurs
- **Accès chats individuels** : Icône chat dans header → MessagesPage filtré par pros du mariage

### 2. Notifications → ✅ VALIDÉ
Types confirmés :
- `wedding_pro_added` - Pro ajouté au mariage (→ Pro)
- `wedding_pro_excluded` - Pro exclu du mariage (→ Pro)
- `wedding_pro_left` - Pro a quitté le mariage (→ Bride)
- `wedding_team_message` - Nouveau message dans le groupe (→ Tous sauf sender)
- `wedding_event_reminder` - Rappel d'événement (→ Bride)
- `wedding_cancelled` - Mariage annulé (→ Tous les pros)

### 3. Agenda Visibilité → ✅ VALIDÉ
- **Par défaut** : Privé (bride only)
- **Option** : Peut rendre un événement public (visible par Wedding Team)

### 4. Modification mariage → ✅ VALIDÉ
- Oui, via bouton "Edit" sur le Countdown Card

### 5. Annulation mariage → ✅ VALIDÉ (pas suppression)
- **Annuler** (pas supprimer) : Données conservées
- **Notification** : Tous les pros sont notifiés (`wedding_cancelled`)
- **Récupération** : Bride peut reprendre son mariage jusqu'à 6 mois après la date prévue
- **Après 6 mois** : Données archivées/supprimées automatiquement

### 6. Chat Permissions → ✅ VALIDÉ
- Bride : ✅ Peut envoyer
- Pros actifs : ✅ Peuvent envoyer
- Pros exclus/partis : ❌ Plus dans le chat

---

## ✅ Points Clarifiés (Session 5)

### 1. Pro dans le mariage = accès chat groupe → ✅ VALIDÉ
- **Décision** : Tous les pros ont accès au chat groupe (pas d'option par pro)

### 2. Agenda événements publics → ✅ VALIDÉ
- **Décision** : Pros peuvent voir seulement (lecture), pas de notification de rappel

---

## 📋 Wedding Data Model - Données Personnalisables

### Données collectées à l'Onboarding

| Étape | Champ | Type | Obligatoire | Notes |
|-------|-------|------|-------------|-------|
| 2 | `event_date` | Date | ✅ Oui | "Tu pourras modifier plus tard" |
| 3 | `venue_name` | String | ❌ Non | Nom du lieu |
| 3 | `position` (lat/lng) | Point | ✅ Oui | "Tu pourras modifier plus tard" |
| 3 | `country_code` | String | ✅ Auto | Déduit de la position |
| 4 | `professions_needed` | String[] | ❌ Non | Sélection multiple (skippable) |
| 5 | `guest_count` | Int | ❌ Non | Estimation pour les pros (skippable) |
| 6 | `budget_min` | Numeric | ❌ Non | Budget minimum (skippable) |
| 6 | `budget_max` | Numeric | ❌ Non | Budget maximum (skippable) |
| 7 | `visibility` | Enum | ❌ Non | Default: private (skippable) |

### Données additionnelles (post-onboarding)

| Champ | Type | Où l'éditer | Notes |
|-------|------|-------------|-------|
| `name` | String | Edit sheet | Nom du mariage (ex: "Wedding Smith-Jones") |
| `cover_image_url` | String | Edit sheet | Photo de couverture |
| `event_end_date` | Date | Edit sheet | Si mariage sur plusieurs jours |
| `budget_min` | Numeric | Edit sheet | Budget minimum |
| `budget_max` | Numeric | Edit sheet | Budget maximum (utilisé pour Budget Tracker) |
| `search_radius_km` | Int | Edit sheet | Rayon de recherche pros (default 50) |
| `note_for_pros` | Text | My Wedding Page | Note unique max 1000 chars |
| `status` | Enum | Actions | `active`, `cancelled` |

### Table `weddings` - Colonnes à ajouter

```sql
-- Nouvelles colonnes pour My Wedding Suite
ALTER TABLE weddings ADD COLUMN name TEXT;
ALTER TABLE weddings ADD COLUMN cover_image_url TEXT;
ALTER TABLE weddings ADD COLUMN note_for_pros TEXT; -- max 1000 chars
ALTER TABLE weddings ADD COLUMN status TEXT DEFAULT 'active'; -- 'active', 'cancelled'
ALTER TABLE weddings ADD COLUMN cancelled_at TIMESTAMPTZ;
ALTER TABLE weddings ADD COLUMN onboarding_step SMALLINT; -- null = completed
```

### Statuts du mariage

| Status | Description | Actions possibles |
|--------|-------------|-------------------|
| `active` | Mariage en cours de planification | Tout |
| `cancelled` | Mariage annulé par la bride | Reprendre (jusqu'à 6 mois après date) |

### Écrans d'édition

#### 1. Wedding Edit Sheet (depuis Countdown Card)
Champs éditables :
- Nom du mariage
- Date(s)
- Lieu (recherche Google Places)
- Budget min/max
- Visibilité
- Professions recherchées
- Nombre d'invités
- Thème
- Photo de couverture

#### 2. Cancel Wedding Flow
1. Tap "Cancel Wedding" (dans settings ou menu)
2. Confirmation sheet avec warning
3. Raison optionnelle
4. Confirmation finale
5. → Status = `cancelled`, notification aux pros

#### 3. Resume Wedding Flow (si annulé)
1. Bride va sur My Wedding
2. Affiche écran "Mariage annulé"
3. Bouton "Reprendre mon mariage"
4. Confirmation
5. → Status = `active`, notification aux pros (optionnel ?)

---

## �📊 Implementation Phases

### Phase 1: Core Structure
1. Restructuration navbar (Brides + Pros)
2. Settings déplacé en header
3. My Wedding Page (onboarding + overview)
4. Wedding Team (invitation + chat)
5. Weddings Hub Pro
6. Documents dans les chats

### Phase 2: Content Features
1. Moodboard / Inspirations
2. Wedding Guests list
3. Map integration update

### Phase 3: Planning Features
1. Agenda Premium
2. Budget Tracker
3. Notes Privées

### Future (Non-scope)
- Bridesmaids Room (système d'invitation complexe)
- VIP Family (trombinoscope)
- Appels Vidéo groupe
- Album photos invités (lien unique)

---

## 📁 File Structure Proposal

```
lib/features/my_wedding/
├── domain/
│   ├── entities/
│   │   ├── wedding_guest.dart
│   │   ├── wedding_event.dart
│   │   ├── wedding_expense.dart
│   │   ├── inspiration_album.dart
│   │   ├── saved_post.dart
│   │   └── wedding_note.dart
│   ├── repositories/
│   │   └── my_wedding_repository.dart
│   └── usecases/
│       ├── get_wedding_overview.dart
│       ├── get_wedding_team.dart
│       ├── invite_pro_to_wedding.dart
│       ├── save_post_to_album.dart
│       └── leave_wedding.dart
├── data/
│   ├── datasources/
│   │   └── supabase_my_wedding_datasource.dart
│   └── repositories/
│       └── my_wedding_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── my_wedding_page.dart              # Main page (bride)
    │   ├── wedding_onboarding_page.dart      # Onboarding if no wedding
    │   ├── wedding_team_page.dart            # Team list + chat access
    │   ├── wedding_guests_page.dart          # Guests list
    │   ├── inspirations_page.dart            # Moodboard albums
    │   ├── album_detail_page.dart            # Single album view
    │   ├── agenda_page.dart                  # Events list
    │   ├── budget_page.dart                  # Budget tracker
    │   └── notes_page.dart                   # Private notes
    ├── widgets/
    │   ├── wedding_countdown_card.dart
    │   ├── wedding_section_card.dart         # Reusable section card
    │   ├── wedding_team_tile.dart
    │   ├── wedding_guest_tile.dart
    │   ├── expense_item.dart
    │   ├── event_item.dart
    │   ├── album_grid.dart
    │   └── note_tile.dart
    └── sheets/
        ├── invite_pro_sheet.dart             # Search & invite pro
        ├── add_guest_sheet.dart              # Add guest (name + email/phone)
        ├── save_to_album_sheet.dart          # Save post modal
        ├── create_album_sheet.dart
        ├── add_event_sheet.dart
        ├── add_expense_sheet.dart
        ├── add_note_sheet.dart
        └── leave_wedding_sheet.dart          # Pro leaves with reason

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
    │   ├── weddings_hub_page.dart            # List of client weddings
    │   └── wedding_client_detail_page.dart   # Single wedding view
    ├── widgets/
    │   ├── wedding_client_tile.dart
    │   └── shared_album_tile.dart
    └── sheets/
        ├── leave_wedding_sheet.dart          # Leave with reason
        └── pro_notes_sheet.dart              # Edit private notes
```

---

## 🔗 Dependencies

### Existing Systems to Reuse
- Chat system (`lib/features/chat/`) - Extend for `wedding_team` room type
- Design System (`lib/core/design/`)
- Notifications system (`lib/features/notifications/`)
- Wedding entities (`lib/features/map/domain/entities/wedding.dart`)

### New Dependencies
- `file_picker` - Pour upload de documents (PDF, etc.)
- Pas de calendar package complexe (vue liste simple)

### Files to Modify
- `lib/components/nav/nav_bar_brides/nav_bar_brides_widget.dart` - New order
- `lib/components/nav/nav_bar_pro/nav_bar_pro_widget.dart` - New order
- `lib/pages/bride/home_brides/home_brides_widget.dart` - Add settings icon
- `lib/pages/pro/dashboard_pro/dashboard_pro_widget.dart` - Add settings icon
- `lib/features/chat/` - Add `document` message type
- `lib/pages/shared/feed_detail_viewer/feed_detail_viewer_widget.dart` - Add save icon
- `lib/features/map/presentation/widgets/` - Update pin behavior

---

## 📝 Notes de Session

### 2025-12-10 - Session 1 (Brainstorming)
- Analyse de l'architecture existante
- Création du document initial
- Questions identifiées

### 2025-12-10 - Session 2 (Validation)
- Navigation validée
- Flux d'invitation pro validé
- Documents dans chats validé
- Moodboard : icône signet dans feed_detail_viewer
- Scope : Feature complète, pas MVP

### 2025-12-10 - Session 3 (Clarifications)
- Budget Tracker : version simple (todo list)
- Moodboard : 2 types, catégories custom, conversion privé↔public

### 2025-12-10 - Session 4 (Clarifications)
- Chat groupe créé dès l'onboarding
- Notifications : 6 types validés
- Annulation mariage (pas suppression)

### 2025-12-10 - Session 5 (Clarifications)
- Tous les pros ont accès au chat groupe
- Agenda événements publics : lecture seule pour pros

### 2025-12-10 - Session 6 (Finalisation)
- My Wedding Page : layout hiérarchique avec Wedding Team Chat en item
- Accès chats 1-1 via icône header
- Tap pro → ProDetails / Long press → Modal exclure/report
- Vue Pro : sections réduites (Bride Info, Chat, Albums, Events, Notes)
- Mute : long press sur item mariage
- Documents : modal choix média/document, PDF uniquement
- Albums : catégories custom + noms libres
- Agenda/Budget : todo lists avec états
- Note bride : UNE seule, max 1000 chars, visible par tous

### 2025-12-10 - Session 7 (Validation Finale)
- Onboarding : 9 étapes (Date + Location obligatoires, reste optionnel)
- Professionals : optionnel (pas obligatoire)
- Budget : ajouté dans l'onboarding (optionnel)
- Features Preview : écran marketing informatif (pas d'action)
- ✅ SPEC VALIDÉE - Prêt pour implémentation

---

## 🚀 Next Steps

**➡️ Plan d'Implémentation Final:** `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md`

Le plan d'implémentation détaillé avec toutes les tâches, fichiers et SQL est disponible dans le document ci-dessus.

### Résumé des étapes:

1. **Créer les migrations Supabase** :
   - Modifier `weddings` (name, cover_image_url, note_for_pros, status, cancelled_at, onboarding_step)
   - Modifier `wedding_participants` (status enum + colonnes mute/left/excluded)
   - Créer `wedding_guests`
   - Créer `inspiration_albums` + `saved_posts` + `album_images`
   - Créer `wedding_events` (avec is_public, status)
   - Créer `wedding_expenses` (avec status)
   - Créer `pro_wedding_notes`
   - Modifier `chat_messages` (document type + colonnes)
   - Modifier `chat_rooms` (wedding_team type)

2. **Phase 1 Implementation** :
   - Navbar restructuring (Brides + Pros)
   - Settings in header
   - My Wedding Page (onboarding + overview)
   - Wedding Team Chat (item + ChatDetailsPage)
   - Wedding Team (liste pros + actions)
   - Weddings Hub Pro (liste + detail page)

3. **Phase 2 Implementation** :
   - Moodboard / Inspirations
   - Documents dans les chats
   - Agenda (todo list)
   - Budget (todo list)

4. **Phase 3 Implementation** :
   - Note for Pros
   - Wedding Guests
   - Map integration update

