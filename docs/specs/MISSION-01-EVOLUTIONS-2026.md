# PRD — Mission Lynewed App Mobile 2026

> **Version** : 2.1 (Post-Challenge Deep)
> **Client** : Thierry Joubert (LYNEWED)
> **Développeur** : Léo Berthet
> **Stack** : Flutter + Supabase + Stripe + FedEx
> **Période** : Janvier - Mars 2026
> **Budget** : 4 500€ HT (15 jours estimés, accéléré avec Claude Code)

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [APP-00 — Prérequis Migration](#2-app-00--prérequis-migration) ⚠️ NEW
3. [Utilisateurs et Rôles](#3-utilisateurs-et-rôles)
4. [APP-01 — Système d'avis clients](#4-app-01--système-davis-clients)
5. [APP-02 — Notifications de rappel RDV](#5-app-02--notifications-de-rappel-rdv)
6. [APP-03 — Système d'invitations guests](#6-app-03--système-dinvitations-guests)
7. [APP-04 — Projet Photo & Vidéo](#7-app-04--projet-photo--vidéo)
8. [APP-05 — Intégration Stripe Complète](#8-app-05--intégration-stripe-complète)
9. [APP-06 — Magazines Photo](#9-app-06--magazines-photo)
10. [APP-07 — Filtres Map additionnels](#10-app-07--filtres-map-additionnels)
11. [APP-08 — Marketplace Robes & Chaussures](#11-app-08--marketplace-robes--chaussures)
12. [CGVU & Conformité juridique](#12-cgvu--conformité-juridique)
13. [Hors périmètre](#13-hors-périmètre)
14. [Livrables & Échéances](#14-livrables--échéances)
15. [Décisions de conception](#15-décisions-de-conception)
16. [Annexes techniques](#16-annexes-techniques)

---

## 1. Vue d'ensemble

### Contexte

Lynewed est une application mobile de mise en relation entre **professionnels du mariage** et **mariées** (brides). L'app est **en production** avec **248 utilisateurs actifs** sur iOS et Android.

### Architecture existante

L'app utilise **Clean Architecture** avec 15 modules features :
- `auth`, `chat`, `content`, `dashboard`, `feed`, `home`, `map`, `my_wedding`, `notifications`, `profile`, `settings`, `support`, `video_call`, `weddings_hub_pro`, `wishlist`

**Important** : Cette mission **enrichit des fonctionnalités existantes** (my_wedding, notifications, map) plutôt que de recréer from scratch.

### Objectifs de cette mission

| # | Objectif | Impact |
|---|----------|--------|
| 1 | **Enrichir l'expérience bride** | Photos/vidéos partagées, invitations guests, rappels RDV |
| 2 | **Créer une marketplace** | Vente de robes ET chaussures entre brides (style Vinted) |
| 3 | **Monétiser (préparation)** | Stripe Connect avec commission 10%, commande magazines photo |
| 4 | **Protéger juridiquement** | CGVU, logs de consentement, droit à l'image |

### Principes de développement

- **Qualité production** : Code maintenable, 0 warnings, tests
- **Architecture existante** : Respecter Clean Architecture en place
- **Cohérence UI** : Réutiliser les widgets, sheets, pages existantes (model map ou wedding comme base)
- **Sécurité** : RLS Supabase, validation inputs, OWASP, tous webhooks gérés

---

## 2. APP-00 — Prérequis Migration

> **Estimation** : 0.5 jour | **Prix** : 150€
> **CRITIQUE** : Doit être exécuté AVANT toute autre APP

### Contexte

Le challenge deep (3 agents Sonnet en parallèle) a identifié des prérequis techniques BLOQUANTS pour les features Guest.

### 2.1 Migration Enum userRole

**État actuel** (vérifié en production) :
```sql
CREATE TYPE "public"."userRole" AS ENUM ('bride', 'professional');
```

**Migration requise** :
```sql
-- Migration: add_guest_role
-- ATTENTION: Exécuter en période de faible trafic (nuit)

-- 1. Ajouter la valeur 'guest' à l'enum
ALTER TYPE "public"."userRole" ADD VALUE 'guest';

-- 2. Mettre à jour l'entité Dart correspondante
-- lib/features/auth/domain/entities/user_role.dart
-- enum UserRole { bride, professional, guest }
```

### 2.2 RLS Policies pour nouvelles tables

**CHAQUE nouvelle table** doit avoir des RLS policies AVANT utilisation.

#### Template RLS par type de table

**Tables Guest-owned** (`guest_albums`, `guest_media`) :
```sql
-- Le guest ne voit que SES propres données
CREATE POLICY "Guest can CRUD own data" ON {table_name}
FOR ALL USING (user_id = auth.uid());

-- La bride voit les données partagées
CREATE POLICY "Bride can view shared data" ON {table_name}
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = {table_name}.wedding_id
    AND w.bride_profile_id = auth.uid()
    AND {table_name}.shared_with_bride = TRUE
  )
);
```

**Tables Marketplace** (`marketplace_listings`, `marketplace_transactions`) :
```sql
-- Tout le monde peut voir les listings actifs
CREATE POLICY "Anyone can view active listings" ON marketplace_listings
FOR SELECT USING (status = 'active');

-- Seul le vendeur peut modifier
CREATE POLICY "Seller can manage own listings" ON marketplace_listings
FOR ALL USING (seller_id = auth.uid());

-- Seuls buyer/seller voient leur transaction
CREATE POLICY "Transaction participants only" ON marketplace_transactions
FOR SELECT USING (seller_id = auth.uid() OR buyer_id = auth.uid());
```

### 2.3 Sécurisation Code Invitation

**Problème identifié** : Code 6 caractères = ~2 milliards de combinaisons, bruteforce possible.

**Solution** :
```sql
-- 1. Augmenter à 8 caractères (2.8 trillions de combinaisons)
ALTER TABLE weddings
  ADD COLUMN invite_code VARCHAR(8) UNIQUE;

-- 2. Ajouter expiration
ALTER TABLE weddings
  ADD COLUMN invite_code_expires_at TIMESTAMP;

-- 3. Rate limiting (Edge Function)
CREATE TABLE invitation_attempts (
  ip_address VARCHAR(50),
  attempted_at TIMESTAMP DEFAULT NOW(),
  success BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_invitation_attempts_ip ON invitation_attempts(ip_address, attempted_at);

-- 4. Fonction de génération sécurisée
CREATE OR REPLACE FUNCTION generate_secure_invite_code()
RETURNS TRIGGER AS $$
BEGIN
  NEW.invite_code := UPPER(SUBSTR(ENCODE(GEN_RANDOM_BYTES(6), 'base64'), 1, 8));
  NEW.invite_code_expires_at := NOW() + INTERVAL '30 days';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2.4 Storage Bucket Policies

**Nouveau bucket** : `wedding-media` avec isolation par guest
```sql
-- Politique: Guest accède uniquement à son dossier
CREATE POLICY "Guest can access own media folder" ON storage.objects
FOR ALL USING (
  bucket_id = 'wedding-media' AND
  (storage.foldername(name))[3] = auth.uid()::text
);

-- Politique: Bride accède aux médias partagés
CREATE POLICY "Bride can view shared guest media" ON storage.objects
FOR SELECT USING (
  bucket_id = 'wedding-media' AND
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE w.bride_profile_id = auth.uid()
    AND ga.shared_with_bride = TRUE
    AND ga.guest_user_id::text = (storage.foldername(name))[3]
  )
);
```

### Critères d'acceptation APP-00

- [ ] Enum `userRole` contient 'guest'
- [ ] Entité Dart `UserRole` mise à jour
- [ ] RLS policies définies pour TOUTES les nouvelles tables
- [ ] Code invitation 8 caractères + expiration 30j
- [ ] Rate limiting sur endpoint `/join/{code}`
- [ ] Storage bucket `wedding-media` avec RLS

---

## 3. Utilisateurs et Rôles

### Rôles existants

| Rôle | Description | Accès |
|------|-------------|-------|
| **Bride** | Mariée organisant son mariage | Map, Feed, Chat, My Wedding, Marketplace, Wishlist |
| **Pro** | Professionnel du mariage | Map, Feed, Chat, Dashboard Pro, Alerts |
| **Pro Ultimate** | Pro avec abonnement premium | + Voir brides sur map, contacter directement |

### Nouveau rôle : Guest

| Rôle | Description | Accès limité |
|------|-------------|--------------|
| **Guest** | Invité au mariage | Album perso, Chat groupe mariage, Upload photos/vidéos |

**Interface Guest** : Totalement différente de Bride. Accès uniquement à :
- Son album personnel (upload photos/vidéos)
- Le chat groupe du mariage (style WhatsApp)
- Création de reels avec ses propres vidéos
- **PAS d'accès** à : Map, Feed, Wishlist, autres features Bride/Pro

### Upgrade de rôle

Un **Guest** peut devenir **Bride** via un bandeau/bouton :
- Action **irréversible** (bien avertir)
- Conserve ses données (photos, compte)
- Peut ensuite créer son propre mariage

---

## 3. APP-01 — Système d'avis clients

> **Estimation** : 0.5 jour | **Prix** : 150€

### Description

Système d'avis interne Lynewed permettant aux brides de noter les pros (pas Google Places).

### User Stories

| ID | Story |
|----|-------|
| US-01.1 | En tant que bride, je peux noter un pro (1 à 5 étoiles) après avoir travaillé avec lui |
| US-01.2 | En tant que bride, je peux laisser un commentaire écrit avec ma note |
| US-01.3 | En tant que pro, je vois ma note moyenne sur mon profil |
| US-01.4 | En tant que visiteur, je vois les avis et la note moyenne sur la fiche d'un pro |
| US-01.5 | En tant que bride, je peux filtrer les pros par note sur la map |

### Spécifications techniques

#### Base de données

```sql
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pro_id UUID REFERENCES profiles(id) NOT NULL,
  bride_id UUID REFERENCES profiles(id) NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(pro_id, bride_id) -- Une bride = un seul avis par pro
);

CREATE INDEX idx_reviews_pro_id ON reviews(pro_id);

-- Vue pour note moyenne (performance)
CREATE VIEW pro_ratings AS
SELECT
  pro_id,
  AVG(rating)::NUMERIC(2,1) as average_rating,
  COUNT(*) as review_count
FROM reviews
GROUP BY pro_id;
```

#### Intégration Map

Ajouter filtre "Note minimum" dans `MapFilter` :
```dart
final double? minRating; // 1.0 - 5.0
```

### Critères d'acceptation

- [ ] Note de 1 à 5 étoiles (tap sur étoiles)
- [ ] Commentaire optionnel
- [ ] Une bride ne peut laisser qu'un seul avis par pro
- [ ] Note moyenne calculée automatiquement
- [ ] Affichage : "4.8/5 (12 avis)" sur fiche pro
- [ ] Filtre par note minimum sur la map

---

## 4. APP-02 — Notifications de rappel RDV

> **Estimation** : 0.5 jour | **Prix** : 150€

### Contexte existant

**Table existante** : `wedding_events` avec :
- `title`, `description`, `event_date`, `event_end_date`, `location`
- `reminder_sent` (boolean) - Placeholder, pas implémenté
- `reminderMinutes` dans l'entité (default: [1440, 60] = 1 jour + 1 heure)

**Système notifications existant** :
- FCM implémenté et production-ready
- Queue `notifications_outbox` pour delivery async
- Manque : **scheduled notifications**

### Description

**Enrichir** l'agenda existant dans my_wedding pour permettre les rappels programmés. Ne PAS recréer une nouvelle fonctionnalité.

### User Stories

| ID | Story |
|----|-------|
| US-02.1 | En tant que bride, je peux choisir mes rappels lors de la création/édition d'un event |
| US-02.2 | En tant que bride, je peux sélectionner : 1 semaine, 1 jour, 1 heure (multi-sélection) |
| US-02.3 | En tant que bride, je reçois une notification push au moment choisi |
| US-02.4 | En tant que bride, je peux modifier/supprimer mes rappels |

### Spécifications techniques

#### Modifications base de données

```sql
-- Ajouter colonnes à wedding_events existante
ALTER TABLE wedding_events
  ADD COLUMN reminder_1_week BOOLEAN DEFAULT FALSE,
  ADD COLUMN reminder_1_day BOOLEAN DEFAULT FALSE,
  ADD COLUMN reminder_1_hour BOOLEAN DEFAULT FALSE;

-- Table des notifications programmées
CREATE TABLE scheduled_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES wedding_events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  scheduled_at TIMESTAMP NOT NULL,
  notification_type VARCHAR(20) NOT NULL, -- '1_week', '1_day', '1_hour'
  sent BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_scheduled_pending ON scheduled_notifications(scheduled_at)
  WHERE sent = FALSE;
```

#### Edge Function (pg_cron)

```sql
-- Cron job toutes les minutes
SELECT cron.schedule(
  'send-scheduled-notifications',
  '* * * * *',
  $$
    INSERT INTO notifications_outbox (event_type, payload)
    SELECT
      'event_reminder',
      jsonb_build_object(
        'user_id', sn.user_id,
        'event_id', sn.event_id,
        'event_title', we.title,
        'reminder_type', sn.notification_type
      )
    FROM scheduled_notifications sn
    JOIN wedding_events we ON we.id = sn.event_id
    WHERE sn.scheduled_at <= NOW()
      AND sn.sent = FALSE;

    UPDATE scheduled_notifications
    SET sent = TRUE, sent_at = NOW()
    WHERE scheduled_at <= NOW() AND sent = FALSE;
  $$
);
```

#### Intégration UI

Modifier le formulaire de création/édition d'event existant pour ajouter :
- 3 checkboxes : "1 semaine avant", "1 jour avant", "1 heure avant"
- Multi-sélection possible

### Critères d'acceptation

- [ ] Multi-sélection des rappels possible
- [ ] Notifications push même app fermée (via FCM existant)
- [ ] Suppression event → annulation notifications programmées (CASCADE)
- [ ] Format : "Rappel : [Titre] dans [durée]"
- [ ] Intégration transparente avec l'agenda existant

---

## 5. APP-03 — Système d'invitations guests

> **Estimation** : 2 jours | **Prix** : 600€

### Contexte existant

**Table existante** : `wedding_guests` avec :
- `name`, `email`, `phone`, `role` (guest, bridesmaid, best_man, family, witness, other)
- `notes` (notes privées bride)
- **Manque** : invitation, join, user_id lié

**Fonctionnalités existantes** :
- Ajout manuel d'invités (name/email/phone)
- Pas d'envoi d'invitation
- Pas de lien avec compte utilisateur

### Description

**Étendre** la gestion des invités existante pour permettre :
1. Envoi d'invitations (email avec lien/QR code)
2. Onboarding Guest simplifié
3. Chat groupe privé du mariage
4. Interface Guest dédiée (différente de Bride)

### Flow d'onboarding Guest

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ONBOARDING GUEST FLOW                                │
│                                                                              │
│  ÉCRAN LOGIN (existant modifié)                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  [  BRIDE  ]  [  PRO  ]                                              │   │
│  │                                                                       │   │
│  │  ──────────────────────────────────────────────────                  │   │
│  │                                                                       │   │
│  │  Vous êtes invité(e) à un mariage ?                                  │   │
│  │  [ 👤 Rejoindre en tant qu'invité ]  ← Icône discrète               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           ▼                                                  │
│  PAGE "REJOINDRE UN MARIAGE"                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Entrez le code du mariage :                                         │   │
│  │  ┌───────────────────────────────────────┐                          │   │
│  │  │  A B C 1 2 3 X Y                      │  ← Code 8 caractères     │   │
│  │  └───────────────────────────────────────┘                          │   │
│  │                                                                       │   │
│  │  [ 📷 Scanner QR Code ]                                              │   │
│  │                                                                       │   │
│  │  [ Continuer → ]                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│    Via Deep Link/QR ──────┴──────► Pré-rempli, skip cette page             │
│                           │                                                  │
│                           ▼                                                  │
│  CRÉATION COMPTE GUEST                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Bienvenue au mariage de [Bride Name] ! 💍                          │   │
│  │                                                                       │   │
│  │  Prénom : _______________                                            │   │
│  │  Email : _______________                                             │   │
│  │  Mot de passe : _______________                                      │   │
│  │                                                                       │   │
│  │  [ ☑ ] J'accepte les conditions d'utilisation                       │   │
│  │                                                                       │   │
│  │  [ Créer mon compte invité ]                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                           │                                                  │
│                           ▼                                                  │
│  INTERFACE GUEST (limitée)                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  NavBar : [ 📸 Album ] [ 💬 Chat ] [ ⚙️ Profil ]                    │   │
│  │                                                                       │   │
│  │  Pas d'accès à : Map, Feed, Wishlist, etc.                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### User Stories

| ID | Story |
|----|-------|
| US-03.1 | En tant que bride, je peux envoyer une invitation par email à mes invités existants |
| US-03.2 | En tant que bride, je vois le statut de chaque invité (pending, invited, joined) |
| US-03.3 | En tant que guest, je reçois un email avec lien + QR code |
| US-03.4 | En tant que guest, je peux scanner le QR code ou entrer le code manuellement |
| US-03.5 | En tant que guest, via deep link je skip la page de code |
| US-03.6 | En tant que guest, je crée mon compte lié au mariage |
| US-03.7 | En tant que guest, j'accède UNIQUEMENT à : mon album, le chat groupe |
| US-03.8 | En tant que guest, je peux passer en compte Bride (irréversible) |
| US-03.9 | En tant que bride, je peux créer des groupes de discussion |

### Spécifications techniques

#### Modifications base de données

```sql
-- Enrichir wedding_guests existante
ALTER TABLE wedding_guests
  ADD COLUMN invited_at TIMESTAMP,
  ADD COLUMN joined_at TIMESTAMP,
  ADD COLUMN user_id UUID REFERENCES profiles(id),
  ADD COLUMN status VARCHAR(20) DEFAULT 'pending'; -- 'pending', 'invited', 'joined'

-- Code unique par mariage (8 caractères pour sécurité - voir APP-00)
-- NOTE: La fonction de génération sécurisée est définie dans APP-00
ALTER TABLE weddings
  ADD COLUMN invite_code VARCHAR(8) UNIQUE,
  ADD COLUMN invite_code_expires_at TIMESTAMP,
  ADD COLUMN invite_qr_url TEXT;

-- ⚠️ CHAT: Réutiliser chat_rooms existante avec type='wedding_team'
-- Les tables wedding_chat_rooms, wedding_chat_messages, wedding_chat_members
-- sont ANNULÉES (voir Décision D-17). Utiliser à la place :
--   - chat_rooms (avec type='wedding_team', wedding_id)
--   - chat_messages (existante)
--   - chat_room_participants (existante)

-- Créer chat room wedding_team par défaut automatiquement
CREATE OR REPLACE FUNCTION create_default_wedding_chat()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO chat_rooms (type, name, is_active, wedding_id)
  VALUES ('wedding_team', 'Groupe du mariage', TRUE, NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_wedding_default_chat
  AFTER INSERT ON weddings
  FOR EACH ROW
  EXECUTE FUNCTION create_default_wedding_chat();
```

#### Deep Linking

- **URL** : `https://lynewed.app/join/{invite_code}`
- **App installée** : Ouvre directement, skip page code
- **App non installée** : Redirige vers App Store / Play Store, puis ouvre avec code

#### Envoi d'emails (Resend via Edge Function)

```typescript
// Edge Function: send-wedding-invitation
const template = `
  <h1>Vous êtes invité(e) au mariage de ${bride_name} ! 💍</h1>
  <p>Téléchargez l'app Lynewed et rejoignez le mariage.</p>
  <p><strong>Code mariage :</strong> ${invite_code}</p>
  <img src="${qr_code_url}" alt="QR Code" />
  <a href="https://lynewed.app/join/${invite_code}">Rejoindre le mariage</a>
`;
```

### Interface Guest

L'interface Guest est **minimaliste** et **séparée** :

```
┌─────────────────────────────────────────┐
│  NavBar Guest (3 tabs)                  │
│  ┌─────────┬─────────┬─────────┐       │
│  │ 📸      │ 💬      │ ⚙️      │       │
│  │ Album   │ Chat    │ Profil  │       │
│  └─────────┴─────────┴─────────┘       │
│                                         │
│  TAB Album :                            │
│  - Mes photos/vidéos                    │
│  - Upload (+ légende)                   │
│  - Créer un reel                        │
│                                         │
│  TAB Chat :                             │
│  - Chat groupe mariage                  │
│  - Messages temps réel                  │
│                                         │
│  TAB Profil :                           │
│  - Infos compte                         │
│  - [ Passer en compte Bride ]           │
│  - Déconnexion                          │
└─────────────────────────────────────────┘
```

### Critères d'acceptation

- [ ] Modification login page avec bouton Guest discret
- [ ] Page "Rejoindre un mariage" avec code + scanner QR
- [ ] Deep link skip la page de code
- [ ] Création compte Guest lié au mariage
- [ ] Interface Guest minimaliste (3 tabs)
- [ ] Chat groupe temps réel (Supabase Realtime)
- [ ] Upgrade vers Bride avec avertissement irréversible
- [ ] Email d'invitation avec code + QR + lien

---

## 6. APP-04 — Projet Photo & Vidéo

> **Estimation** : 1.5 jours | **Prix** : 450€

### Contexte existant

**Tables existantes** :
- `inspiration_albums` : Albums avec catégories (dress, decor, flowers, venue, etc.)
- `album_images` : Photos uploadées depuis device
- `saved_posts` : Photos sauvées depuis le feed

**Fonctionnalités existantes** :
- Multiple albums avec catégories
- Upload depuis galerie device
- Privacy control (bride-only ou team-visible)
- Pas de vidéos, pas de légendes

### Description

**Enrichir** la galerie existante pour :
1. Support vidéos (avec limites)
2. Légendes sur photos/vidéos
3. Albums guests (séparés des albums bride)
4. Téléchargement haute qualité
5. Préparer commande impressions (futur)
6. Préparer achat album complet guests (futur)

### User Stories — Bride

| ID | Story |
|----|-------|
| US-04.1 | En tant que bride, je peux uploader des vidéos (max 10 min) |
| US-04.2 | En tant que bride, je peux ajouter une légende à mes médias |
| US-04.3 | En tant que bride, je vois les albums des guests (opt-in par guest) |
| US-04.4 | En tant que bride, je peux télécharger tout en haute qualité |
| US-04.5 | En tant que bride, je peux organiser mes albums |
| US-04.6 | En tant que bride, je peux créer des reels avec toutes mes vidéos |

### User Stories — Guest

| ID | Story |
|----|-------|
| US-04.7 | En tant que guest, j'ai mon propre album personnel |
| US-04.8 | En tant que guest, je peux uploader photos et vidéos (max 10 min) |
| US-04.9 | En tant que guest, je peux ajouter des légendes |
| US-04.10 | En tant que guest, je vois UNIQUEMENT mon album |
| US-04.11 | En tant que guest, je peux choisir de partager avec la bride (opt-in) |
| US-04.12 | En tant que guest, je peux créer des reels avec MES vidéos uniquement |

### Spécifications techniques

#### Modifications base de données

```sql
-- Enrichir album_images pour supporter vidéos et légendes
ALTER TABLE album_images
  ADD COLUMN media_type VARCHAR(10) DEFAULT 'photo' CHECK (media_type IN ('photo', 'video')),
  ADD COLUMN caption TEXT CHECK (length(caption) <= 500),
  ADD COLUMN duration_seconds INTEGER, -- Pour vidéos
  ADD COLUMN file_size_bytes BIGINT;

-- Albums guests (séparés des inspiration_albums de la bride)
CREATE TABLE guest_albums (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  guest_user_id UUID REFERENCES profiles(id) NOT NULL,
  shared_with_bride BOOLEAN DEFAULT FALSE, -- Opt-in
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(wedding_id, guest_user_id) -- Un album par guest par mariage
);

CREATE TABLE guest_media (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  album_id UUID REFERENCES guest_albums(id) ON DELETE CASCADE,
  media_type VARCHAR(10) CHECK (media_type IN ('photo', 'video')) NOT NULL,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  caption TEXT CHECK (length(caption) <= 500),
  duration_seconds INTEGER,
  file_size_bytes BIGINT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index pour récupérer médias partagés avec bride
CREATE INDEX idx_guest_albums_shared ON guest_albums(wedding_id)
  WHERE shared_with_bride = TRUE;

-- Logs d'accès pour traçabilité
CREATE TABLE gallery_access_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wedding_id UUID REFERENCES weddings(id),
  accessed_by UUID REFERENCES profiles(id),
  access_type VARCHAR(50), -- 'view', 'download', 'share_enabled', 'share_disabled'
  ip_address VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### Limites fichiers

| Type | Limite | Raison |
|------|--------|--------|
| Photo | 20 MB | Qualité suffisante |
| Vidéo durée | **10 minutes max** | Éviter abus storage |
| Vidéo taille | 500 MB | Balance qualité/coût |
| Vidéo pour reel | **2 minutes max par vidéo** | Reels exploitables |
| Légende | 500 caractères | UX concise |

#### Storage (Supabase Storage)

```
Bucket: wedding-media
Structure:
├── {wedding_id}/
│   ├── bride/
│   │   └── {filename}
│   └── guests/
│       └── {guest_user_id}/
│           └── {filename}
```

#### Anticipation : Impressions & Achat Album

Préparer les tables/flags pour futur :
```sql
-- Flag pour médias imprimables (futur)
ALTER TABLE album_images ADD COLUMN print_ready BOOLEAN DEFAULT FALSE;
ALTER TABLE guest_media ADD COLUMN print_ready BOOLEAN DEFAULT FALSE;

-- Table commandes impressions (futur, placeholder)
-- CREATE TABLE print_orders (...);

-- Table achat albums (futur, placeholder)
-- CREATE TABLE album_purchases (...);
```

### Critères d'acceptation

- [ ] Upload vidéos (max 10 min, 500 MB)
- [ ] Légendes sur tous les médias (max 500 chars)
- [ ] Album guest séparé par utilisateur
- [ ] Opt-in partage avec bride
- [ ] Bride voit albums guests partagés
- [ ] Téléchargement haute qualité (zip si plusieurs)
- [ ] Logs d'accès pour traçabilité
- [ ] Cohérence UI avec albums existants

---

## 7. APP-05 — Intégration Stripe Complète

> **Estimation** : 1 jour | **Prix** : 300€

### Description

Intégration Stripe **complète et sécurisée** pour :
1. Marketplace (Stripe Connect)
2. Reels payants (futur)
3. Autres achats potentiels

**Important** : Configuration via MCP Stripe. Gérer **TOUS** les webhooks et events possibles.

### Fonctionnalités Stripe

#### Stripe Connect (Marketplace)

Pour les vendeuses de la marketplace :
- Onboarding Express (simplifié)
- Paiements avec commission 10%
- Transferts automatiques

#### Payment Intents (Achats)

Pour acheteuses et futurs achats (reels, etc.)

### Spécifications techniques

#### Base de données

```sql
-- Comptes Stripe Connect des vendeuses
CREATE TABLE stripe_accounts (
  user_id UUID REFERENCES profiles(id) PRIMARY KEY,
  stripe_account_id VARCHAR(255) NOT NULL,
  account_type VARCHAR(20) DEFAULT 'express', -- 'express', 'standard', 'custom'
  onboarding_complete BOOLEAN DEFAULT FALSE,
  charges_enabled BOOLEAN DEFAULT FALSE,
  payouts_enabled BOOLEAN DEFAULT FALSE,
  details_submitted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Achats (reels, marketplace, futurs)
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  product_type VARCHAR(50) NOT NULL, -- 'marketplace_item', 'reel', 'album', 'print'
  product_id UUID,

  -- Montants (en centimes)
  amount INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',
  platform_fee INTEGER, -- Commission Lynewed

  -- Stripe IDs
  stripe_payment_intent_id VARCHAR(255),
  stripe_checkout_session_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),
  stripe_charge_id VARCHAR(255),

  -- Statut
  status VARCHAR(50) DEFAULT 'pending',
  -- 'pending', 'processing', 'succeeded', 'failed', 'canceled', 'refunded', 'disputed'

  -- Métadonnées
  metadata JSONB,
  error_message TEXT,

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  paid_at TIMESTAMP,
  refunded_at TIMESTAMP
);

-- Events Stripe (audit complet)
CREATE TABLE stripe_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  stripe_event_id VARCHAR(255) UNIQUE NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  payload JSONB NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMP,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_stripe_events_type ON stripe_events(event_type);
CREATE INDEX idx_stripe_events_unprocessed ON stripe_events(created_at) WHERE processed = FALSE;
```

#### Webhooks Stripe à gérer (TOUS)

**Paiements :**
```
payment_intent.created
payment_intent.processing
payment_intent.succeeded ✓ (marquer purchase "succeeded")
payment_intent.payment_failed ✓ (marquer "failed", notifier user)
payment_intent.canceled
payment_intent.amount_capturable_updated
payment_intent.requires_action
```

**Checkout :**
```
checkout.session.completed ✓ (finaliser achat)
checkout.session.expired
checkout.session.async_payment_succeeded
checkout.session.async_payment_failed
```

**Connect :**
```
account.updated ✓ (mettre à jour onboarding_complete, charges_enabled)
account.application.deauthorized
account.external_account.created
account.external_account.updated
account.external_account.deleted
```

**Transferts :**
```
transfer.created
transfer.updated
transfer.reversed
```

**Disputes :**
```
charge.dispute.created ✓ (notifier, bloquer vendeuse si nécessaire)
charge.dispute.updated
charge.dispute.closed
charge.dispute.funds_reinstated
charge.dispute.funds_withdrawn
```

**Refunds :**
```
charge.refunded ✓ (marquer purchase "refunded")
charge.refund.updated
```

**Payout (versements vendeuses) :**
```
payout.created
payout.updated
payout.paid ✓ (notifier vendeuse)
payout.failed ✓ (notifier, investiguer)
payout.canceled
```

#### Edge Function : Webhook Handler

```typescript
// Edge Function: stripe-webhook
import Stripe from 'stripe';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!;

Deno.serve(async (req) => {
  const signature = req.headers.get('stripe-signature')!;
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    return new Response('Webhook signature verification failed', { status: 400 });
  }

  // Log event pour audit
  await supabase.from('stripe_events').insert({
    stripe_event_id: event.id,
    event_type: event.type,
    payload: event.data.object
  });

  // Traitement par type
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSucceeded(event.data.object);
      break;
    case 'payment_intent.payment_failed':
      await handlePaymentFailed(event.data.object);
      break;
    case 'account.updated':
      await handleAccountUpdated(event.data.object);
      break;
    case 'charge.dispute.created':
      await handleDisputeCreated(event.data.object);
      break;
    // ... tous les autres
  }

  // Marquer comme traité
  await supabase.from('stripe_events')
    .update({ processed: true, processed_at: new Date() })
    .eq('stripe_event_id', event.id);

  return new Response('OK', { status: 200 });
});
```

### Critères d'acceptation

- [ ] Stripe Connect onboarding Express fonctionnel
- [ ] Tous les webhooks listés ci-dessus gérés
- [ ] Tous les events loggés dans stripe_events
- [ ] Gestion erreurs avec messages user-friendly
- [ ] Gestion disputes avec notification
- [ ] Paiements monde entier (multi-country)
- [ ] Tests mode sandbox + production
- [ ] Configuration via MCP Stripe

---

## 8. APP-06 — Magazines Photo

> **Estimation** : 1.5 jours | **Prix** : 450€
> **NOTE** : Remplace les Reels (abandonnés) - Décision Thierry 28/01/2026

### Description

Système de commande de **magazines photo imprimés** pour les mariages. La bride sélectionne ses photos préférées (y compris celles des guests), prévisualise un mockup magazine style éditorial, et commande via Stripe. **Fulfillment manuel par Thierry en V1** (pas d'intégration API imprimeur).

### Parcours Utilisateur

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  1. GALERIE  →  2. SÉLECTION  →  3. PREVIEW  →  4. CHECKOUT  →  5. ORDER   │
│                                                                              │
│  Bride voit     Bride marque     Mockup        Paiement       Thierry       │
│  toutes ses     favorites,       magazine      Stripe +       produit       │
│  photos +       sélectionne      avec          adresse        manuellement  │
│  guests         pour magazine    couverture    livraison                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### User Stories — Galerie

| ID | Story |
|----|-------|
| US-06.1 | En tant que bride, je peux voir toutes mes photos + celles des guests partagées |
| US-06.2 | En tant que bride, je peux marquer des photos en favoris |
| US-06.3 | En tant que bride, je peux masquer des photos guests de ma vue |
| US-06.4 | En tant que bride, je peux supprimer (soft) des photos de ma galerie |
| US-06.5 | En tant que bride, je peux filtrer : Toutes / Favoris / Masquées |
| US-06.6 | En tant que bride, je peux partager une sélection avec les guests |

### User Stories — Magazine

| ID | Story |
|----|-------|
| US-06.7 | En tant que bride, je peux sélectionner jusqu'à 50 photos pour le magazine |
| US-06.8 | En tant que bride, je peux réordonner les photos (drag & drop) |
| US-06.9 | En tant que bride, je vois une prévisualisation du magazine avec couverture |
| US-06.10 | En tant que bride, je peux commander et payer via Stripe |
| US-06.11 | En tant que bride, je reçois une confirmation et un suivi de commande |

### Spécifications techniques

#### Limites

| Limite | Valeur | Raison |
|--------|--------|--------|
| Photos par magazine | 50 max | Taille raisonnable, coût production |
| Prix magazine | $49.00 | Base, configurable |
| Frais port USA | $15.00 | FedEx domestic |
| Frais port International | $35.00 | FedEx international |

#### Base de données

```sql
-- Favoris photos (bride peut favoriser album_images ET guest_media)
CREATE TABLE photo_favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  media_type VARCHAR(20) NOT NULL, -- 'album_image' | 'guest_media'
  media_id UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, media_type, media_id)
);

-- Sélection pour magazine avec ordre
CREATE TABLE magazine_selections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  user_id UUID REFERENCES profiles(id) NOT NULL,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  position INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(wedding_id, media_type, media_id)
);

-- Commandes magazines
CREATE TABLE magazine_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID REFERENCES weddings(id) NOT NULL,
  bride_user_id UUID REFERENCES profiles(id) NOT NULL,

  -- Stripe
  stripe_payment_intent_id VARCHAR(255),
  stripe_checkout_session_id VARCHAR(255),

  -- Montants (centimes)
  magazine_price_cents INTEGER NOT NULL,
  shipping_cost_cents INTEGER NOT NULL,
  total_paid_cents INTEGER NOT NULL,
  currency VARCHAR(3) DEFAULT 'USD',

  -- Shipping
  shipping_name VARCHAR(255) NOT NULL,
  shipping_address_line1 VARCHAR(255) NOT NULL,
  shipping_address_line2 VARCHAR(255),
  shipping_city VARCHAR(255) NOT NULL,
  shipping_zip VARCHAR(50) NOT NULL,
  shipping_country VARCHAR(100) NOT NULL,
  shipping_phone VARCHAR(50),

  -- Magazine
  magazine_title VARCHAR(255) NOT NULL,
  magazine_date DATE,
  photo_count INTEGER NOT NULL,

  -- Status: pending → paid → in_production → shipped → delivered
  status VARCHAR(30) DEFAULT 'pending',
  tracking_number VARCHAR(255),
  tracking_url TEXT,

  created_at TIMESTAMP DEFAULT NOW(),
  paid_at TIMESTAMP,
  shipped_at TIMESTAMP
);

-- Snapshot photos au moment de la commande
CREATE TABLE magazine_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES magazine_orders(id) ON DELETE CASCADE,
  media_type VARCHAR(20) NOT NULL,
  media_id UUID NOT NULL,
  position INTEGER NOT NULL,
  storage_url TEXT NOT NULL, -- Snapshot URL, préservé même si original supprimé
  caption TEXT
);

-- Config prix magazine (administrable)
INSERT INTO app_config (key, value) VALUES
('magazine_pricing', '{
  "base_price_cents": 4900,
  "currency": "USD",
  "max_photos": 50,
  "shipping_domestic_cents": 1500,
  "shipping_international_cents": 3500
}')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
```

#### Ajout status à guest_media

```sql
-- Permettre bride de masquer/supprimer photos guests
ALTER TABLE guest_media
  ADD COLUMN status VARCHAR(20) DEFAULT 'active';
-- 'active', 'hidden_by_bride', 'deleted_by_bride'
```

### Preview Magazine

Le preview affiche un mockup style magazine éditorial :

**Couverture** :
- "DIGITAL EDITION" + date
- "LYNEWED" branding
- Photo de couverture (première sélectionnée ou choisie)
- Nom des mariés (ex: "Jessica & Kyle")
- "Captured by our loved ones"

**Pages intérieures** :
- Layouts variés automatiques (1 photo, 2 photos, mosaïque 4-6)
- Sections : "The Party", "Guest Moments", "Celebration"
- Numérotation des pages

### Critères d'acceptation

- [ ] Galerie avec sélection multiple
- [ ] Actions favorite/hide/delete sur photos
- [ ] Filtres All/Favorites/Hidden
- [ ] Partage sélection avec guests
- [ ] Sélection magazine avec reorder (drag & drop)
- [ ] Max 50 photos par magazine
- [ ] Preview magazine avec couverture personnalisée
- [ ] Checkout Stripe avec adresse livraison
- [ ] CGVU magazine obligatoire (scroll + checkbox)
- [ ] Webhook création commande après paiement
- [ ] Push notification confirmation commande
- [ ] Admin panel pour gestion commandes (service_role)

### Fulfillment V1 (Manuel)

**Important** : En V1, pas d'intégration API imprimeur.

1. Bride commande et paie via Stripe
2. Commande créée dans `magazine_orders`
3. Thierry voit la commande dans l'admin panel (CRM Tom)
4. Thierry télécharge les photos et crée le magazine manuellement
5. Thierry paie le fournisseur et envoie à l'adresse
6. Thierry met à jour le status et ajoute le tracking
7. Bride reçoit notification de livraison

---

## 9. APP-07 — Filtres Map additionnels

> **Estimation** : 1 jour | **Prix** : 300€

### Contexte existant

**Map existante** avec :
- 3 types de marqueurs : pros, alerts, weddings
- Filtres : professions (20 types), budget, layer toggles
- Vue différenciée bride/pro
- **Guests n'ont PAS accès à la map**

### Description

**Ajouter** à la map existante :
1. 2 nouveaux filtres : "Wedding book free", "Trailer free"
2. Nouveau marqueur : Articles marketplace
3. Filtre par note client (avis)

### User Stories

| ID | Story |
|----|-------|
| US-07.1 | En tant que bride, je peux filtrer les pros offrant un wedding book gratuit |
| US-07.2 | En tant que bride, je peux filtrer les pros offrant un trailer gratuit |
| US-07.3 | En tant que bride, je vois les articles marketplace sur la carte |
| US-07.4 | En tant que bride, je peux filtrer les pros par note minimum |
| US-07.5 | En tant que visiteur, je peux cliquer sur un article pour voir les détails |

### Spécifications techniques

#### Modifications base de données

```sql
-- Ajouter champs aux pros (si pas déjà fait)
ALTER TABLE professional_details
  ADD COLUMN IF NOT EXISTS offers_free_wedding_book BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS offers_free_trailer BOOLEAN DEFAULT FALSE;
```

#### Modifications MapFilter

```dart
// Dans map_filter.dart
class MapFilter {
  // Existants
  final List<Profession> professions;
  final double? budgetMin;
  final double? budgetMax;
  final String currency;
  final LayerToggles toggles;

  // NOUVEAUX
  final bool? weddingBookFree; // null = pas de filtre
  final bool? trailerFree;
  final double? minRating; // 1.0 - 5.0
}

class LayerToggles {
  // Existants
  final bool showPros;
  final bool showAlerts;
  final bool showWeddings;

  // NOUVEAU
  final bool showMarketplace; // Articles à vendre
}
```

#### Nouveau type de marqueur

```dart
// Dans map_marker_type.dart
enum MapMarkerType {
  proFixedLocation,
  professionalAlert,
  wedding,
  marketplaceItem, // NOUVEAU
}
```

#### Icône marketplace

Créer icône dans `marker_icon_generator.dart` :
- Robe : 👗 ou icône custom
- Chaussure : 👠 ou icône custom
- Style cohérent avec autres marqueurs

### UI/UX Filter Sheet

Ajouter dans le filter sheet existant :

```
┌─────────────────────────────────────────┐
│  FILTRES                                │
│                                         │
│  Profession : [chips existants]         │
│                                         │
│  Budget : [slider existant]             │
│                                         │
│  Note minimum :                         │
│  ⭐ ⭐ ⭐ ⭐ ⭐  (slider 1-5)           │
│                                         │
│  Offres spéciales :                     │
│  [ ] Wedding book gratuit               │
│  [ ] Trailer gratuit                    │
│                                         │
│  Afficher :                             │
│  [Pros] [Alerts] [Weddings] [Robes]    │
│                                         │
└─────────────────────────────────────────┘
```

### Critères d'acceptation

- [ ] Toggle "Wedding book free" dans filtres
- [ ] Toggle "Trailer free" dans filtres
- [ ] Slider/input "Note minimum" (1-5)
- [ ] Marqueur marketplace sur la carte
- [ ] Tap marqueur → ouvre détails article
- [ ] Cohérence UI avec filtres existants
- [ ] Guests toujours SANS accès map

---

## 10. APP-08 — Marketplace Robes & Chaussures

> **Estimation** : 7 jours | **Prix** : 2 100€

### Description

Marketplace style Vinted pour vendre **robes ET chaussures** de mariage. Commission 10% via Stripe Connect. Expédition FedEx mondiale.

**Placement** : Nouvel onglet dans la navbar (côté bride uniquement). Possibilité d'afficher une preview sur la home page pour aguicher.

### Principes de conception

1. **Cohérence UI** : Réutiliser widgets, sheets, pages existantes (style my_wedding)
2. **Simplicité Stripe Connect** : Onboarding Express le plus rapide possible
3. **FedEx robuste** : Gérer tous les cas d'erreur, tous les pays
4. **Non responsable** : CGVU claires, logs complets, pas de garantie
5. **Historique complet** : Tout conserver dans Supabase (transactions, events)

### Structure de données

```sql
-- Annonces
CREATE TABLE marketplace_listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID REFERENCES profiles(id) NOT NULL,

  -- Infos produit
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(20) CHECK (category IN ('dress', 'shoes')) NOT NULL,

  -- Prix (en centimes USD)
  price_cents INTEGER NOT NULL,
  display_currency VARCHAR(3) DEFAULT 'USD', -- Pour affichage préférence user

  -- Attributs
  designer_brand VARCHAR(255),
  size VARCHAR(50),
  condition VARCHAR(20) CHECK (condition IN ('new', 'excellent', 'good', 'fair')),

  -- Attributs robe
  sleeve_length VARCHAR(20), -- 'long', '3/4', 'short', 'cap', 'sleeveless', 'strapless'

  -- Localisation
  city VARCHAR(255),
  country VARCHAR(100) NOT NULL,
  country_code VARCHAR(2),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),

  -- Statut
  status VARCHAR(20) DEFAULT 'active',
  -- 'draft', 'active', 'reserved', 'sold', 'deleted'

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  sold_at TIMESTAMP
);

CREATE INDEX idx_listings_status ON marketplace_listings(status) WHERE status = 'active';
CREATE INDEX idx_listings_location ON marketplace_listings(latitude, longitude);

-- Photos annonces (5-10 obligatoires)
CREATE TABLE marketplace_photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID REFERENCES marketplace_listings(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  position INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Offres
CREATE TABLE marketplace_offers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  buyer_id UUID REFERENCES profiles(id) NOT NULL,
  amount_cents INTEGER NOT NULL,
  message TEXT,
  status VARCHAR(20) DEFAULT 'pending',
  -- 'pending', 'accepted', 'rejected', 'expired', 'withdrawn'
  expires_at TIMESTAMP DEFAULT (NOW() + INTERVAL '48 hours'),
  created_at TIMESTAMP DEFAULT NOW(),
  responded_at TIMESTAMP
);

-- Transactions
CREATE TABLE marketplace_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  offer_id UUID REFERENCES marketplace_offers(id),
  seller_id UUID REFERENCES profiles(id) NOT NULL,
  buyer_id UUID REFERENCES profiles(id) NOT NULL,

  -- Montants (en centimes USD)
  item_price_cents INTEGER NOT NULL,
  shipping_cost_cents INTEGER NOT NULL,
  platform_fee_cents INTEGER NOT NULL, -- 10% de item_price
  seller_payout_cents INTEGER NOT NULL, -- item_price - platform_fee
  total_paid_cents INTEGER NOT NULL, -- item_price + shipping

  -- Stripe
  stripe_payment_intent_id VARCHAR(255),
  stripe_transfer_id VARCHAR(255),

  -- FedEx
  fedex_tracking_number VARCHAR(255),
  fedex_label_url TEXT,
  fedex_rate_id VARCHAR(255),

  -- Adresses
  shipping_from_address JSONB,
  shipping_to_address JSONB,

  -- Statut
  status VARCHAR(20) DEFAULT 'pending',
  -- 'pending', 'paid', 'label_created', 'shipped', 'in_transit', 'delivered', 'completed', 'disputed', 'refunded', 'canceled'

  -- Timestamps
  created_at TIMESTAMP DEFAULT NOW(),
  paid_at TIMESTAMP,
  shipped_at TIMESTAMP,
  delivered_at TIMESTAMP,
  completed_at TIMESTAMP
);

-- Messages conversation (chat achat)
CREATE TABLE marketplace_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  listing_id UUID REFERENCES marketplace_listings(id) NOT NULL,
  sender_id UUID REFERENCES profiles(id) NOT NULL,
  receiver_id UUID REFERENCES profiles(id) NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- FedEx Events (audit complet)
CREATE TABLE fedex_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID REFERENCES marketplace_transactions(id),
  tracking_number VARCHAR(255),
  event_type VARCHAR(100) NOT NULL,
  event_description TEXT,
  location TEXT,
  event_timestamp TIMESTAMP,
  raw_payload JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### User Stories — Vendeuse

| ID | Story |
|----|-------|
| US-08.1 | En tant que bride, je peux créer une annonce (robe ou chaussures) |
| US-08.2 | En tant que vendeuse, je dois uploader 5-10 photos |
| US-08.3 | En tant que vendeuse, je remplis : titre, description, prix, taille, marque, état, localisation |
| US-08.4 | En tant que vendeuse, je dois accepter les CGVU (scroll + checkbox) |
| US-08.5 | En tant que vendeuse, je configure mon compte Stripe Connect (onboarding simple) |
| US-08.6 | En tant que vendeuse, je reçois des notifications (offre, message, vente) |
| US-08.7 | En tant que vendeuse, je peux accepter/refuser les offres |
| US-08.8 | En tant que vendeuse, je génère l'étiquette FedEx après paiement |
| US-08.9 | En tant que vendeuse, je reçois 90% du prix (- 10% commission) |

### User Stories — Acheteuse

| ID | Story |
|----|-------|
| US-08.10 | En tant qu'acheteuse, je vois les annonces dans un feed |
| US-08.11 | En tant qu'acheteuse, je vois les annonces sur la carte |
| US-08.12 | En tant qu'acheteuse, je filtre par catégorie, taille, marque, état, prix, localisation |
| US-08.13 | En tant qu'acheteuse, je peux contacter la vendeuse via chat |
| US-08.14 | En tant qu'acheteuse, je peux faire une offre |
| US-08.15 | En tant qu'acheteuse, je peux acheter au prix affiché |
| US-08.16 | En tant qu'acheteuse, je dois accepter les CGVU avant paiement |
| US-08.17 | En tant qu'acheteuse, je paie prix + frais de port (calculés FedEx) |
| US-08.18 | En tant qu'acheteuse, je suis le tracking de mon colis |

### Stripe Connect — Onboarding Express

Flow simplifié :
```
1. Vendeuse clique "Configurer paiements"
2. Redirection Stripe Connect Onboarding (Express)
3. Stripe collecte : email, téléphone, identité, compte bancaire
4. Retour app avec account_id
5. Webhook account.updated → charges_enabled = true
6. Vendeuse peut recevoir des paiements
```

### FedEx — Intégration Complète

#### APIs à intégrer

| API | Usage |
|-----|-------|
| **Address Validation** | Vérifier adresses avant envoi |
| **Rate API** | Calculer frais de port (affichés à l'acheteuse) |
| **Ship API** | Générer étiquette d'expédition |
| **Track API** | Suivre le colis |
| **Pickup API** | Programmer enlèvement (optionnel) |

#### Flow expédition

```
1. Paiement confirmé (Stripe webhook)
2. Appel FedEx Rate API pour confirmer frais
3. Vendeuse clique "Générer étiquette"
4. Appel FedEx Address Validation (from + to)
5. Si erreur adresse → demander correction
6. Appel FedEx Ship API
7. Stocker tracking_number, label_url
8. Envoyer email vendeuse avec PDF étiquette
9. Polling/webhook FedEx Track API
10. Mettre à jour statut à chaque event
11. Livraison confirmée → statut "delivered"
12. Après 7 jours sans contestation → "completed"
```

#### Gestion des erreurs FedEx

| Erreur | Action |
|--------|--------|
| Adresse invalide | Demander correction à l'utilisateur |
| Service indisponible | Proposer alternatives |
| Rate trop élevé | Avertir avant confirmation |
| Tracking perdu | Ouvrir investigation |
| Colis endommagé | Procédure de réclamation |
| Non livré | Relancer ou rembourser |

### Devises

- **Stockage** : USD (centimes) dans Supabase
- **Affichage** : Selon préférence utilisateur (conversion à l'affichage)
- **Paiement Stripe** : USD toujours
- **Frais FedEx** : USD (FedEx facture en USD pour international)

### UI/UX — Cohérence

#### Structure des écrans

Réutiliser les patterns de my_wedding :
- Liste avec cards (style albums)
- Detail sheet (style event details)
- Formulaire (style création event/guest)
- Chat (style chat existant)

#### Navbar (côté bride)

```
┌──────────────────────────────────────────┐
│  [ Home ] [ Map ] [ 🛍️ ] [ Chat ] [ ☰ ]  │
│                    ↑                      │
│              Marketplace                  │
└──────────────────────────────────────────┘
```

#### Home Page — Preview (optionnel)

Ajouter section "Articles récents" sur home page bride :
```
┌──────────────────────────────────────────┐
│  🛍️ Marketplace                          │
│  ──────────────────────────────────────  │
│  [ Robe $800 ] [ Shoes $150 ] [ +3 ]    │
│  ──────────────────────────────────────  │
│  [ Voir tout → ]                         │
└──────────────────────────────────────────┘
```

### Responsabilité & Litiges

**Lynewed n'est PAS responsable** de :
- Qualité/conformité des articles
- Litiges entre vendeur/acheteur
- Problèmes de livraison FedEx
- Disputes de paiement

**En cas de litige** :
1. Encourager résolution entre parties (chat)
2. Si échec → dispute Stripe
3. Stripe tranche selon leurs règles
4. Lynewed ne rembourse pas de sa poche

**Tout est loggé** pour preuve en cas de procédure.

### Critères d'acceptation

- [ ] Création annonce avec 5-10 photos obligatoires
- [ ] CGVU obligatoires (scroll + checkbox) pour vendeuse ET acheteuse
- [ ] Stripe Connect onboarding Express fonctionnel
- [ ] Commission 10% prélevée automatiquement
- [ ] Frais port calculés via FedEx Rate API
- [ ] Étiquette FedEx générée et envoyée par email
- [ ] Tracking en temps réel
- [ ] Notifications : offre, message, vente, expédition, livraison
- [ ] Chat entre vendeur/acheteur
- [ ] Articles visibles sur carte avec icône
- [ ] Cohérence UI avec reste de l'app
- [ ] Tout historisé dans Supabase

---

## 11. CGVU & Conformité juridique

### Types de CGVU

| Type | Moment | Format | Fréquence |
|------|--------|--------|-----------|
| **Photo/Vidéo** | 1ère utilisation | 4 checkboxes | Une fois |
| **Magazine** | 1ère commande | Scroll + checkbox | Une fois |
| **Galerie partage** | Activation partage | 1 checkbox | Chaque activation |
| **Marketplace vendeuse** | 1ère annonce | Scroll + checkbox | Une fois |
| **Marketplace acheteuse** | 1er achat | Scroll + checkbox | Une fois |

### Traçabilité (logs obligatoires)

```sql
CREATE TABLE cgvu_acceptances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  cgvu_type VARCHAR(50) NOT NULL,
  cgvu_version VARCHAR(20) NOT NULL, -- '1.0', '1.1', etc.
  ip_address VARCHAR(50),
  user_agent TEXT,
  device_info JSONB, -- OS, app version, etc.
  accepted_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_cgvu_user_type ON cgvu_acceptances(user_id, cgvu_type);
```

### Textes CGVU (rédigés professionnellement)

#### Photo/Vidéo — 4 checkboxes (EN)

```
PHOTO & VIDEO SERVICE — TERMS OF USE

By using the Lynewed Photo & Video service, you acknowledge and agree to the following:

☐ 1. ACCEPTANCE OF TERMS
I accept the Terms of Service for the Lynewed Photo & Video feature and understand that my use is subject to these terms.

☐ 2. CONTENT RESPONSIBILITY
I am solely responsible for all photos and videos I capture, upload, or share through this service. I understand that Lynewed does not review, verify, or endorse any user-generated content.

☐ 3. RIGHTS AND PERMISSIONS
I confirm that I have obtained all necessary rights, permissions, and consents from:
  • All individuals appearing in the content
  • Property owners of any locations shown
  • Copyright holders of any third-party materials
I will not upload content that infringes on any third party's intellectual property, privacy, or other rights.

☐ 4. PLATFORM ROLE
I understand that Lynewed acts solely as a technical platform and hosting service. Lynewed:
  • Does not control, monitor, or verify uploaded content
  • Is not responsible for any claims arising from content I share
  • May remove content that violates these terms without notice
  • Bears no liability for any damages resulting from my use of this service

By checking these boxes, I confirm I have read, understood, and agree to these terms.
```

#### Magazine Purchase — Scroll + checkbox (EN)

```
LYNEWED MAGAZINE — TERMS OF PURCHASE

Please read these terms carefully before ordering your magazine.

1. PRODUCT DESCRIPTION
The Lynewed Wedding Magazine is a custom-printed photo book featuring photos you have selected from your wedding gallery. Each magazine is uniquely created based on your selections.

2. PRODUCTION & DELIVERY
• Magazines are produced manually by our partner printing service
• Production typically takes 5-10 business days
• Shipping time varies by location (7-21 days)
• You will receive tracking information once shipped

3. CUSTOM PRODUCT POLICY
As each magazine is custom-made with your personal photos:
• Orders cannot be cancelled once production begins
• Refunds are not available for delivered products
• Exchanges are only possible for production defects

4. PHOTO QUALITY
• Final print quality depends on original photo resolution
• We recommend high-resolution photos for best results
• Lynewed is not responsible for print quality issues caused by low-resolution source images

5. INTELLECTUAL PROPERTY
• You confirm you have rights to all photos included
• By ordering, you grant Lynewed permission to print your photos
• Photos are not shared or used for any other purpose

6. SHIPPING
• Shipping costs are calculated at checkout
• Risk of loss transfers upon delivery to carrier
• Lynewed is not responsible for shipping delays or damage by carriers

7. LIMITATION OF LIABILITY
Lynewed's liability is limited to the order value. We are not liable for indirect damages or delays beyond our control.

By scrolling to the bottom and checking the box below, you confirm you have read and accept these terms.

☐ I have read and accept the Lynewed Magazine Terms of Purchase
```

#### Gallery Sharing — 1 checkbox (EN)

```
GALLERY SHARING — ACKNOWLEDGMENT

☐ I understand that by enabling gallery sharing:
  • I am creating a shareable link that allows others to view my gallery
  • I am solely responsible for who I share this link with
  • Anyone with the link can view the content until I disable sharing
  • Lynewed is not responsible for any third-party use or redistribution of my content
  • I can disable sharing at any time from my gallery settings
```

#### Marketplace Seller — Scroll + checkbox (EN)

```
LYNEWED MARKETPLACE — SELLER TERMS OF USE

Please read these terms carefully before listing an item for sale.

1. PLATFORM ROLE
Lynewed Marketplace is a digital platform that facilitates connections between users wishing to sell and purchase wedding-related items. Lynewed acts EXCLUSIVELY as a technical intermediary and is NOT a party to any sales transaction between users.

2. YOUR RESPONSIBILITIES AS A SELLER
By listing an item, you represent and warrant that:
  • You are the legal owner of the item or authorized to sell it
  • Your listing description, photos, and pricing are accurate
  • The item is authentic and not counterfeit
  • The item meets the condition you have described
  • You will ship the item within the timeframe specified
  • You will respond to buyer inquiries in a timely manner

3. PROHIBITED ITEMS
You may NOT list items that are:
  • Counterfeit or replica items
  • Stolen property
  • Items you do not own or have authority to sell
  • Items prohibited by applicable law

4. PRICING AND FEES
  • You set your own price for items
  • Lynewed charges a commission of 10% on the sale price (excluding shipping)
  • Shipping costs are paid by the buyer and calculated via FedEx
  • Commission is automatically deducted via Stripe Connect

5. PAYMENT PROCESSING
  • Payments are processed through Stripe Connect
  • Lynewed does not directly handle or hold your funds
  • You must complete Stripe Connect onboarding to receive payments
  • Stripe's terms and conditions apply to all payment processing

6. SHIPPING
  • You are responsible for properly packaging and shipping items
  • Shipping labels are generated through FedEx via our platform
  • You must ship within 5 business days of payment confirmation
  • Any shipping delays, damages, or losses are between you and FedEx

7. DISPUTES AND RETURNS
  • Lynewed does not mediate disputes between buyers and sellers
  • Any returns or refunds must be arranged directly between parties
  • Stripe may handle chargebacks according to their policies
  • Lynewed is not responsible for resolving transaction disputes

8. LIMITATION OF LIABILITY
Lynewed shall not be held liable for:
  • Disputes between buyers and sellers
  • Quality, authenticity, or condition of items
  • Payment processing issues handled by Stripe
  • Shipping issues handled by FedEx
  • Any indirect, incidental, or consequential damages

By scrolling to the bottom and checking the box below, you confirm you have read and accept these terms.

☐ I have read and accept the Lynewed Marketplace Seller Terms of Use
```

#### Marketplace Buyer — Scroll + checkbox (EN)

```
LYNEWED MARKETPLACE — BUYER TERMS OF USE

Please read these terms carefully before making a purchase.

1. PLATFORM ROLE
Lynewed Marketplace is a digital platform that connects buyers with sellers of wedding-related items. Lynewed is NOT the seller and does not own, inspect, or guarantee any items listed.

2. YOUR RESPONSIBILITIES AS A BUYER
By making a purchase, you acknowledge that:
  • You are transacting directly with another user, not with Lynewed
  • You have reviewed the listing carefully before purchasing
  • You will communicate respectfully with sellers
  • You will provide accurate shipping information

3. ITEM CONDITION
  • Items are sold "as described" by the seller
  • Lynewed does NOT verify item condition, authenticity, or quality
  • Review all photos and descriptions carefully before purchasing
  • Contact the seller with questions before buying

4. PAYMENT
  • Payments are processed securely through Stripe
  • You pay the item price plus shipping costs
  • Lynewed charges the seller a 10% commission (not you)
  • Your payment is released to the seller after shipment

5. SHIPPING
  • Shipping is handled by FedEx
  • Tracking information will be provided after shipment
  • Delivery times depend on FedEx and your location
  • Shipping delays are handled by FedEx, not Lynewed

6. DISPUTES AND RETURNS
  • Lynewed does not mediate buyer-seller disputes
  • Contact the seller directly for any issues
  • Returns must be arranged between you and the seller
  • Chargebacks through Stripe are subject to Stripe's policies

7. LIMITATION OF LIABILITY
Lynewed shall not be held liable for:
  • The quality, authenticity, or condition of purchased items
  • Seller failure to ship or respond
  • Shipping delays, damages, or losses
  • Any disputes arising from your purchase

By scrolling to the bottom and checking the box below, you confirm you have read and accept these terms.

☐ I have read and accept the Lynewed Marketplace Buyer Terms of Use
```

### Critères d'acceptation CGVU

- [ ] Tous les textes implémentés en anglais
- [ ] Modal avec checkboxes obligatoires
- [ ] Scroll obligatoire pour marketplace (bouton disabled jusqu'au scroll)
- [ ] Tous les consentements loggés avec : user_id, IP, user_agent, device_info, date
- [ ] Indicateur visible "Terms accepted on [date]" dans les interfaces concernées

---

## 12. Hors périmètre

| Élément | Responsable | Notes |
|---------|-------------|-------|
| CRM web | Tom | Dashboard galerie pro, etc. |
| Back-end galerie CRM | Tom | Upload photos pro → bride |
| Intégration impression photos | À définir | Partenaire à trouver |
| Wedding slot exchange notifications | Tom | Sauf si 100% app |
| Avis Google Places | Abandonné | Système interne uniquement |
| Système sans compte | Abandonné | Trop complexe |
| Essayage robes | Future version | Champ `allows_try_on` |
| Montage intelligent reels | Future version | OpusClip/Shotstack V2 |
| Modification header home page | Annulé | Pas de changement |

---

## 13. Livrables & Échéances

### Planning estimatif

| Semaine | Dates | Phases |
|---------|-------|--------|
| S1 | 25-31 jan | Setup, APP-01, APP-02 |
| S2 | 1-7 fév | APP-03 (invitations), APP-07 (filtres) |
| S3 | 8-14 fév | APP-04 (photos), APP-05 (Stripe) |
| S4 | 15-21 fév | APP-06 (magazines), Marketplace (début) |
| S5 | 22-28 fév | Marketplace (suite) |
| S6 | 1-7 mars | Marketplace (fin), CGVU |
| S7 | 8-14 mars | Tests, corrections, déploiement |

**Note** : Jours estimés, accéléré avec Claude Code.

### Paiements

| Date | Montant |
|------|---------|
| 15 février 2026 | 2 250€ (50%) |
| 28 mars 2026 | 2 250€ (50%) |

### Livrables

1. **Code source** : Repository à jour, Clean Architecture
2. **App iOS** : Mise à jour App Store
3. **App Android** : Mise à jour Play Store
4. **Stripe** : Configuration complète via MCP
5. **FedEx** : Certification étiquettes
6. **Documentation** : Schéma DB mis à jour
7. **Tests** : Suite de tests mise à jour
8. **Période maintenance** : Corrections bugs post-livraison

---

## 14. Décisions de conception

| # | Décision | Justification |
|---|----------|---------------|
| D-01 | Enrichir my_wedding existant, pas recréer | Cohérence, moins de code, réutilisation |
| D-02 | Interface Guest séparée de Bride | Sécurité, UX claire, accès limité |
| D-03 | Guest ne voit que SES photos | Protection vie privée, droit à l'image |
| D-04 | CGVU une seule fois + logs complets | UX non intrusive, traçabilité juridique |
| D-05 | Magazines avec paiement Stripe Checkout | Revenus directs, fulfillment manuel par Thierry |
| D-06 | Magazine preview local, pas de génération PDF | Coût minimal, preview mockup suffisant |
| D-07 | USD comme devise interne | Simplifie Stripe et FedEx |
| D-08 | Tous webhooks Stripe gérés | Sécurité, pas de cas non gérés |
| D-09 | Marketplace dans navbar + preview home | Visibilité maximale |
| D-10 | Cohérence UI avec my_wedding | Utilisateurs familiers avec l'app |
| D-11 | Limites vidéos (10min upload) | Éviter abus storage |
| D-12 | Bride peut utiliser vidéos guests partagés | Flexibilité pour mariée |
| D-13 | Guests n'ont pas accès à la map | Map = feature bride/pro uniquement |
| D-14 | **Guests NE PEUVENT PAS commander de magazines** | Seule la bride peut commander un magazine avec les photos sélectionnées |
| D-15 | Code invitation 8 caractères + expiration | Sécurité anti-bruteforce (challenge finding) |
| D-16 | RLS obligatoires avant toute table | Sécurité données multi-tenant |
| D-17 | Réutiliser `chat_rooms` existante pour chat mariage | Éviter duplication code, type='wedding_team' existe |

---

## 15. Annexes techniques

### A. Tables Supabase à créer/modifier

#### Nouvelles tables

| Table | Description |
|-------|-------------|
| `reviews` | Avis clients sur pros |
| `scheduled_notifications` | Notifications de rappel programmées |
| ~~`wedding_chat_rooms`~~ | ❌ ANNULÉ : Réutiliser `chat_rooms` existante (type='wedding_team') |
| ~~`wedding_chat_messages`~~ | ❌ ANNULÉ : Réutiliser `chat_messages` existante |
| ~~`wedding_chat_members`~~ | ❌ ANNULÉ : Réutiliser `chat_room_participants` existante |
| `guest_albums` | Albums photos des guests |
| `guest_media` | Médias des guests |
| `gallery_access_logs` | Logs accès galerie |
| `photo_favorites` | Photos favorites de la bride |
| `magazine_selections` | Sélection photos pour magazine |
| `magazine_orders` | Commandes de magazines |
| `magazine_order_items` | Photos dans une commande |
| `stripe_accounts` | Comptes Stripe Connect |
| `purchases` | Achats (marketplace, reels, etc.) |
| `stripe_events` | Audit events Stripe |
| `marketplace_listings` | Annonces marketplace |
| `marketplace_photos` | Photos annonces |
| `marketplace_offers` | Offres sur annonces |
| `marketplace_transactions` | Transactions |
| `marketplace_messages` | Chat vendeur/acheteur |
| `fedex_events` | Audit events FedEx |
| `cgvu_acceptances` | Logs consentements CGVU |

#### Tables à modifier

| Table | Modifications |
|-------|---------------|
| `wedding_events` | + reminder_1_week, reminder_1_day, reminder_1_hour |
| `wedding_guests` | + invited_at, joined_at, user_id, status |
| `weddings` | + invite_code, invite_qr_url |
| `album_images` | + media_type, caption, duration_seconds, file_size_bytes |
| `professional_details` | + offers_free_wedding_book, offers_free_trailer |

### B. Edge Functions à créer

| Function | Trigger | Description |
|----------|---------|-------------|
| `send-scheduled-notifications` | pg_cron (1 min) | Envoie rappels programmés |
| `send-wedding-invitation` | HTTP | Envoie email invitation |
| `create-magazine-checkout` | HTTP | Crée session Stripe Checkout pour magazine |
| `magazine-order-webhook` | Webhook Stripe | Crée commande après paiement |
| `stripe-webhook` | Webhook Stripe | Gère tous events Stripe |
| `fedex-webhook` | Webhook FedEx | Gère tracking events |

### C. Intégrations externes

| Service | Usage | Configuration |
|---------|-------|---------------|
| **Stripe** | Paiements, Connect | Via MCP Stripe |
| **FedEx** | Expédition | API credentials Thierry |
| **Resend** | Emails transactionnels | À configurer |
| **Firebase/FCM** | Push notifications | Déjà configuré |

### D. RLS Policies complètes (Challenge Deep Finding)

> **CRITIQUE** : Appliquer ces policies LORS de la création de chaque table.

#### D.1 Reviews (APP-01)
```sql
-- Tout le monde peut lire les avis
CREATE POLICY "Reviews readable by all" ON reviews FOR SELECT USING (true);

-- Seule la bride peut créer un avis
CREATE POLICY "Bride can create review" ON reviews FOR INSERT
WITH CHECK (
  bride_id = auth.uid() AND
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'bride')
);

-- La bride peut modifier son propre avis
CREATE POLICY "Bride can update own review" ON reviews FOR UPDATE
USING (bride_id = auth.uid());
```

#### D.2 Scheduled Notifications (APP-02)
```sql
-- L'utilisateur ne voit que ses propres notifications
CREATE POLICY "User sees own scheduled notifications" ON scheduled_notifications
FOR ALL USING (user_id = auth.uid());
```

#### D.3 Guest Albums & Media (APP-03, APP-04)
```sql
-- Guest gère son propre album
CREATE POLICY "Guest manages own album" ON guest_albums
FOR ALL USING (guest_user_id = auth.uid());

-- Guest gère ses propres médias
CREATE POLICY "Guest manages own media" ON guest_media
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    WHERE ga.id = guest_media.album_id
    AND ga.guest_user_id = auth.uid()
  )
);

-- Bride voit les albums partagés de son mariage
CREATE POLICY "Bride views shared albums" ON guest_albums
FOR SELECT USING (
  shared_with_bride = TRUE AND
  EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = guest_albums.wedding_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- Bride voit les médias des albums partagés
CREATE POLICY "Bride views shared media" ON guest_media
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM guest_albums ga
    JOIN weddings w ON w.id = ga.wedding_id
    WHERE ga.id = guest_media.album_id
    AND ga.shared_with_bride = TRUE
    AND w.bride_profile_id = auth.uid()
  )
);
```

#### D.4 Reels (APP-06)
```sql
-- Créateur gère ses propres reels
CREATE POLICY "User manages own reels" ON reels
FOR ALL USING (user_id = auth.uid());

-- Bride voit les reels de son mariage
CREATE POLICY "Bride views wedding reels" ON reels
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = reels.wedding_id
    AND w.bride_profile_id = auth.uid()
  )
);
```

#### D.5 Marketplace (APP-08)
```sql
-- Listings actifs visibles par tous les brides
CREATE POLICY "Active listings visible" ON marketplace_listings
FOR SELECT USING (
  status = 'active' AND
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'bride')
);

-- Vendeur gère ses propres listings
CREATE POLICY "Seller manages listings" ON marketplace_listings
FOR ALL USING (seller_id = auth.uid());

-- Photos accessibles si listing accessible
CREATE POLICY "Photos follow listing access" ON marketplace_photos
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_photos.listing_id
    AND (ml.status = 'active' OR ml.seller_id = auth.uid())
  )
);

-- Offres : buyer ou seller uniquement
CREATE POLICY "Offer parties only" ON marketplace_offers
FOR SELECT USING (
  buyer_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM marketplace_listings ml
    WHERE ml.id = marketplace_offers.listing_id
    AND ml.seller_id = auth.uid()
  )
);

-- Transactions : parties impliquées
CREATE POLICY "Transaction parties only" ON marketplace_transactions
FOR SELECT USING (seller_id = auth.uid() OR buyer_id = auth.uid());

-- Messages : participants de la conversation
CREATE POLICY "Message participants only" ON marketplace_messages
FOR SELECT USING (sender_id = auth.uid() OR receiver_id = auth.uid());
```

#### D.6 Stripe & CGVU (APP-05)
```sql
-- Chaque utilisateur voit son propre compte Stripe
CREATE POLICY "User sees own stripe account" ON stripe_accounts
FOR SELECT USING (user_id = auth.uid());

-- Stripe events : admin only (pas de policy publique)
-- ALTER TABLE stripe_events ENABLE ROW LEVEL SECURITY;
-- Accès via service_role uniquement

-- CGVU : chaque utilisateur voit ses propres acceptances
CREATE POLICY "User sees own cgvu" ON cgvu_acceptances
FOR SELECT USING (user_id = auth.uid());
```

### E. Résumé Challenge Deep

| Finding | Status | Resolution |
|---------|--------|------------|
| F-01: Tables n'existent pas | ✅ Invalidé | Vérification Supabase : tables EXISTENT |
| F-02: reminder_sent wrong table | ✅ Invalidé | Existe bien dans wedding_events |
| F-03: Guest role absent enum | ✅ Corrigé | APP-00 migration ajoutée |
| F-04: RLS manquantes | ✅ Corrigé | Section D ajoutée ci-dessus |
| F-05: Code invitation bruteforce | ✅ Corrigé | 8 chars + expiration + rate limit |
| F-07: Chat dupliqué | ✅ Corrigé | Réutiliser chat_rooms existante |
| F-10: Guest/Reels contradiction | ✅ Décidé | D-14: Guests AVEC reels (override Thierry) |

**Confidence finale post-corrections : 90%+** ✅

---

*Document mis à jour le 28 janvier 2026 — Version 2.1 (Post-Challenge Deep)*
