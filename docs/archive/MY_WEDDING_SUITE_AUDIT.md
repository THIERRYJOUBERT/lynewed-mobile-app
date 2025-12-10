# MY WEDDING SUITE - Audit Complet & Plan d'Implémentation

**Date:** 2025-12-10  
**Status:** ✅ Ready for Implementation  
**Spec Reference:** `docs/features/MY_WEDDING_SUITE.md` (885 lignes)  
**Supabase Project:** `hekyovgnovhfhmkpfrna` (PROD)

---

## 1. AUDIT BACKEND SUPABASE

### 1.1 Table `weddings` - État Actuel

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `bride_profile_id` | uuid | NO | - | FK → profiles, UNIQUE |
| `wedding_name` | text | YES | - | ✅ Existe déjà |
| `event_date` | date | NO | - | ✅ Existe |
| `event_end_date` | date | YES | - | ✅ Existe |
| `venue_coords` | geometry | YES | - | PostGIS point |
| `venue_label` | text | YES | - | ✅ Existe |
| `search_area_coords` | geometry | YES | - | PostGIS |
| `search_radius_km` | smallint | YES | 50 | ✅ Existe |
| `budget_min` | integer | YES | - | ✅ Existe |
| `budget_max` | integer | YES | - | ✅ Existe |
| `budget_min_eur` | numeric | YES | - | Conversion EUR |
| `budget_max_eur` | numeric | YES | - | Conversion EUR |
| `currency` | text | YES | 'EUR' | ✅ Existe |
| `professions_needed` | profession[] | YES | - | ✅ Existe |
| `visibility` | wedding_visibility | YES | 'private' | ✅ Existe |
| `status` | wedding_status | YES | 'planning' | ✅ Existe (enum différent) |
| `market_region` | text | YES | 'europe' | |
| `is_deleted` | boolean | YES | false | |
| `created_at` | timestamptz | YES | now() | |
| `updated_at` | timestamptz | YES | now() | |
| `location_country_code` | text | YES | - | |

### 1.2 Table `weddings` - Modifications Requises

```sql
-- Colonnes à AJOUTER
ALTER TABLE weddings ADD COLUMN cover_image_url TEXT;
ALTER TABLE weddings ADD COLUMN note_for_pros TEXT; -- max 1000 chars (enforced in app)
ALTER TABLE weddings ADD COLUMN cancelled_at TIMESTAMPTZ;
ALTER TABLE weddings ADD COLUMN onboarding_step SMALLINT; -- null = completed, 1-9 = in progress
ALTER TABLE weddings ADD COLUMN guest_count INTEGER; -- estimation nombre d'invités

-- Note: wedding_name existe déjà (pas besoin de 'name')
-- Note: status existe déjà avec enum wedding_status (planning, confirmed, completed, cancelled)
```

**Enum `wedding_status` existant:**
- `planning` ✅ (équivalent à `active`)
- `confirmed` ✅
- `completed` ✅
- `cancelled` ✅

→ **Pas de modification d'enum nécessaire** pour `wedding_status`

---

### 1.3 Table `wedding_participants` - État Actuel

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `wedding_id` | uuid | NO | - | FK → weddings |
| `professional_profile_id` | uuid | NO | - | FK → profiles |
| `profession` | profession | YES | - | Enum |
| `status` | wedding_participant_status | YES | 'requested' | ⚠️ À modifier |
| `requested_at` | timestamptz | YES | now() | |
| `accepted_at` | timestamptz | YES | - | |

**Enum `wedding_participant_status` actuel:**
- `requested`
- `accepted`
- `declined`

### 1.4 Table `wedding_participants` - Modifications Requises

```sql
-- Modification de l'enum wedding_participant_status
-- Nouvelle logique: active (pro dans le mariage), left (pro a quitté), excluded (bride a exclu)

-- Option 1: Créer un nouvel enum (recommandé pour éviter les problèmes de migration)
CREATE TYPE wedding_participant_status_v2 AS ENUM ('active', 'left', 'excluded');

-- Ou Option 2: Modifier l'enum existant (plus risqué)
-- ALTER TYPE wedding_participant_status ADD VALUE 'active';
-- ALTER TYPE wedding_participant_status ADD VALUE 'left';
-- ALTER TYPE wedding_participant_status ADD VALUE 'excluded';

-- Colonnes à AJOUTER
ALTER TABLE wedding_participants ADD COLUMN left_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN left_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN excluded_reason TEXT;
ALTER TABLE wedding_participants ADD COLUMN excluded_at TIMESTAMPTZ;
ALTER TABLE wedding_participants ADD COLUMN is_muted BOOLEAN DEFAULT false;
ALTER TABLE wedding_participants ADD COLUMN joined_at TIMESTAMPTZ DEFAULT now();

-- Contrainte unique pour éviter les doublons
ALTER TABLE wedding_participants 
ADD CONSTRAINT wedding_participants_unique_active 
UNIQUE (wedding_id, professional_profile_id);
```

**Migration des données existantes:**
```sql
-- Mapper les anciens statuts vers les nouveaux
-- requested → active (si le pro est ajouté directement maintenant)
-- accepted → active
-- declined → left
UPDATE wedding_participants SET status = 'active' WHERE status IN ('requested', 'accepted');
UPDATE wedding_participants SET status = 'left' WHERE status = 'declined';
```

---

### 1.5 Table `chat_rooms` - État Actuel

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | gen_random_uuid() | PK |
| `type` | text | NO | - | CHECK: 'private' OR 'public' |
| `name` | text | YES | - | |
| `is_active` | boolean | NO | true | |
| `created_at` | timestamptz | NO | now() | |

### 1.6 Table `chat_rooms` - Modifications Requises

```sql
-- Modifier le CHECK constraint pour ajouter 'wedding_team'
ALTER TABLE chat_rooms DROP CONSTRAINT IF EXISTS chat_rooms_type_check;
ALTER TABLE chat_rooms ADD CONSTRAINT chat_rooms_type_check 
CHECK (type = ANY (ARRAY['private'::text, 'public'::text, 'wedding_team'::text]));

-- Ajouter une référence au wedding pour les rooms wedding_team
ALTER TABLE chat_rooms ADD COLUMN wedding_id UUID REFERENCES weddings(id) ON DELETE CASCADE;

-- Index pour recherche rapide
CREATE INDEX idx_chat_rooms_wedding_id ON chat_rooms(wedding_id) WHERE wedding_id IS NOT NULL;
```

---

### 1.7 Table `chat_messages` - État Actuel

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | bigint | NO | nextval | PK |
| `room_id` | uuid | NO | - | FK → chat_rooms |
| `profile_id` | uuid | YES | - | FK → profiles |
| `content` | text | YES | - | |
| `message_type` | messageType | NO | - | Enum: text, image, audio |
| `attachment_url` | text | YES | - | |
| `is_deleted` | boolean | NO | false | |
| `created_at` | timestamptz | NO | now() | |

**Enum `messageType` actuel:**
- `text`
- `image`
- `audio`

### 1.8 Table `chat_messages` - Modifications Requises

```sql
-- Ajouter le type 'document' à l'enum messageType
ALTER TYPE "messageType" ADD VALUE 'document';

-- Colonnes pour les métadonnées des documents
ALTER TABLE chat_messages ADD COLUMN attachment_name TEXT;
ALTER TABLE chat_messages ADD COLUMN attachment_size INTEGER; -- en bytes
ALTER TABLE chat_messages ADD COLUMN attachment_mime_type TEXT; -- 'application/pdf'
```

---

### 1.9 Tables à CRÉER

#### 1.9.1 `wedding_guests`
```sql
CREATE TABLE wedding_guests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  role TEXT DEFAULT 'guest', -- 'guest', 'bridesmaid', 'best_man', 'family', etc.
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index
CREATE INDEX idx_wedding_guests_wedding_id ON wedding_guests(wedding_id);

-- RLS
ALTER TABLE wedding_guests ENABLE ROW LEVEL SECURITY;
```

#### 1.9.2 `inspiration_albums`
```sql
CREATE TABLE inspiration_albums (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  bride_profile_id UUID NOT NULL REFERENCES profiles(id),
  name TEXT NOT NULL,
  cover_image_url TEXT,
  category TEXT, -- 'florals', 'dress', 'beauty', 'decor', 'photos', 'venue', 'general'
  is_private BOOLEAN DEFAULT false, -- true = bride only, false = shared with team
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index
CREATE INDEX idx_inspiration_albums_wedding_id ON inspiration_albums(wedding_id);
CREATE INDEX idx_inspiration_albums_bride_id ON inspiration_albums(bride_profile_id);

-- RLS
ALTER TABLE inspiration_albums ENABLE ROW LEVEL SECURITY;
```

#### 1.9.3 `saved_posts`
```sql
CREATE TABLE saved_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID NOT NULL REFERENCES inspiration_albums(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(album_id, post_id)
);

-- Index
CREATE INDEX idx_saved_posts_album_id ON saved_posts(album_id);

-- RLS
ALTER TABLE saved_posts ENABLE ROW LEVEL SECURITY;
```

#### 1.9.4 `album_images`
```sql
CREATE TABLE album_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  album_id UUID NOT NULL REFERENCES inspiration_albums(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT now()
);

-- Index
CREATE INDEX idx_album_images_album_id ON album_images(album_id);

-- RLS
ALTER TABLE album_images ENABLE ROW LEVEL SECURITY;
```

#### 1.9.5 `wedding_events`
```sql
CREATE TABLE wedding_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMPTZ NOT NULL,
  event_end_date TIMESTAMPTZ,
  location TEXT,
  linked_pro_id UUID REFERENCES profiles(id),
  is_public BOOLEAN DEFAULT false, -- Visible par les pros si true
  status TEXT DEFAULT 'pending', -- 'pending', 'done', 'cancelled'
  reminder_minutes INTEGER[] DEFAULT '{1440, 60}', -- 1 jour + 1h avant
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index
CREATE INDEX idx_wedding_events_wedding_id ON wedding_events(wedding_id);
CREATE INDEX idx_wedding_events_date ON wedding_events(event_date);

-- RLS
ALTER TABLE wedding_events ENABLE ROW LEVEL SECURITY;
```

#### 1.9.6 `wedding_expenses`
```sql
CREATE TABLE wedding_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  category TEXT NOT NULL, -- 'venue', 'photographer', 'dress', 'flowers', etc.
  description TEXT,
  amount NUMERIC NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending', 'partial', 'paid'
  paid_amount NUMERIC DEFAULT 0,
  due_date DATE,
  linked_pro_id UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index
CREATE INDEX idx_wedding_expenses_wedding_id ON wedding_expenses(wedding_id);

-- RLS
ALTER TABLE wedding_expenses ENABLE ROW LEVEL SECURITY;
```

#### 1.9.7 `pro_wedding_notes`
```sql
CREATE TABLE pro_wedding_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  professional_profile_id UUID NOT NULL REFERENCES profiles(id),
  wedding_id UUID NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(professional_profile_id, wedding_id)
);

-- Index
CREATE INDEX idx_pro_wedding_notes_pro_id ON pro_wedding_notes(professional_profile_id);
CREATE INDEX idx_pro_wedding_notes_wedding_id ON pro_wedding_notes(wedding_id);

-- RLS
ALTER TABLE pro_wedding_notes ENABLE ROW LEVEL SECURITY;
```

---

### 1.10 RLS Policies à Créer

#### Pour `wedding_guests`
```sql
-- Bride can manage own wedding guests
CREATE POLICY "Bride can manage wedding guests" ON wedding_guests
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = wedding_guests.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);

-- Service role full access
CREATE POLICY "Service role full access wedding_guests" ON wedding_guests
FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');
```

#### Pour `inspiration_albums`
```sql
-- Bride can manage own albums
CREATE POLICY "Bride can manage own albums" ON inspiration_albums
FOR ALL USING (bride_profile_id = auth.uid());

-- Pros can see non-private albums of weddings they participate in
CREATE POLICY "Pros can see shared albums" ON inspiration_albums
FOR SELECT USING (
  is_private = false AND
  EXISTS (
    SELECT 1 FROM wedding_participants wp
    WHERE wp.wedding_id = inspiration_albums.wedding_id
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);
```

#### Pour `saved_posts`
```sql
-- Bride can manage saved posts in own albums
CREATE POLICY "Bride can manage saved posts" ON saved_posts
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    WHERE ia.id = saved_posts.album_id
    AND ia.bride_profile_id = auth.uid()
  )
);

-- Pros can see saved posts in shared albums
CREATE POLICY "Pros can see saved posts in shared albums" ON saved_posts
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    JOIN wedding_participants wp ON wp.wedding_id = ia.wedding_id
    WHERE ia.id = saved_posts.album_id
    AND ia.is_private = false
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);
```

#### Pour `album_images`
```sql
-- Bride can manage images in own albums
CREATE POLICY "Bride can manage album images" ON album_images
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    WHERE ia.id = album_images.album_id
    AND ia.bride_profile_id = auth.uid()
  )
);

-- Pros can see images in shared albums
CREATE POLICY "Pros can see images in shared albums" ON album_images
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM inspiration_albums ia
    JOIN wedding_participants wp ON wp.wedding_id = ia.wedding_id
    WHERE ia.id = album_images.album_id
    AND ia.is_private = false
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);
```

#### Pour `wedding_events`
```sql
-- Bride can manage own wedding events
CREATE POLICY "Bride can manage wedding events" ON wedding_events
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = wedding_events.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);

-- Pros can see public events of weddings they participate in
CREATE POLICY "Pros can see public events" ON wedding_events
FOR SELECT USING (
  is_public = true AND
  EXISTS (
    SELECT 1 FROM wedding_participants wp
    WHERE wp.wedding_id = wedding_events.wedding_id
    AND wp.professional_profile_id = auth.uid()
    AND wp.status = 'active'
  )
);
```

#### Pour `wedding_expenses`
```sql
-- Bride can manage own wedding expenses
CREATE POLICY "Bride can manage wedding expenses" ON wedding_expenses
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM weddings w 
    WHERE w.id = wedding_expenses.wedding_id 
    AND w.bride_profile_id = auth.uid()
  )
);
```

#### Pour `pro_wedding_notes`
```sql
-- Pro can manage own notes
CREATE POLICY "Pro can manage own notes" ON pro_wedding_notes
FOR ALL USING (professional_profile_id = auth.uid());
```

#### Modifier `chat_rooms` pour wedding_team
```sql
-- Ajouter policy pour wedding_team rooms
CREATE POLICY "Wedding team members can see wedding_team rooms" ON chat_rooms
FOR SELECT USING (
  type = 'wedding_team' AND (
    -- Bride can see
    EXISTS (
      SELECT 1 FROM weddings w 
      WHERE w.id = chat_rooms.wedding_id 
      AND w.bride_profile_id = auth.uid()
    )
    OR
    -- Active pro can see
    EXISTS (
      SELECT 1 FROM wedding_participants wp
      WHERE wp.wedding_id = chat_rooms.wedding_id
      AND wp.professional_profile_id = auth.uid()
      AND wp.status = 'active'
    )
  )
);
```

---

### 1.11 Triggers & Functions à Créer

#### 1.11.1 Création automatique du chat wedding_team
```sql
CREATE OR REPLACE FUNCTION create_wedding_team_chat()
RETURNS TRIGGER AS $$
DECLARE
  new_room_id UUID;
BEGIN
  -- Créer la room wedding_team quand l'onboarding est terminé
  IF NEW.onboarding_step IS NULL AND (OLD.onboarding_step IS NOT NULL OR OLD IS NULL) THEN
    INSERT INTO chat_rooms (type, name, wedding_id)
    VALUES ('wedding_team', 'Wedding Team', NEW.id)
    RETURNING id INTO new_room_id;
    
    -- Ajouter la bride comme participant
    INSERT INTO chat_room_participants (room_id, profile_id, conversation_status)
    VALUES (new_room_id, NEW.bride_profile_id, 'active');
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_create_wedding_team_chat
AFTER INSERT OR UPDATE OF onboarding_step ON weddings
FOR EACH ROW
EXECUTE FUNCTION create_wedding_team_chat();
```

#### 1.11.2 Ajout automatique du pro au chat wedding_team
```sql
CREATE OR REPLACE FUNCTION add_pro_to_wedding_team_chat()
RETURNS TRIGGER AS $$
DECLARE
  team_room_id UUID;
BEGIN
  -- Quand un pro est ajouté (status = 'active')
  IF NEW.status = 'active' THEN
    -- Trouver la room wedding_team
    SELECT id INTO team_room_id
    FROM chat_rooms
    WHERE wedding_id = NEW.wedding_id AND type = 'wedding_team';
    
    IF team_room_id IS NOT NULL THEN
      -- Ajouter le pro comme participant
      INSERT INTO chat_room_participants (room_id, profile_id, conversation_status)
      VALUES (team_room_id, NEW.professional_profile_id, 'active')
      ON CONFLICT (room_id, profile_id) DO UPDATE SET conversation_status = 'active';
    END IF;
  END IF;
  
  -- Quand un pro quitte ou est exclu
  IF NEW.status IN ('left', 'excluded') AND OLD.status = 'active' THEN
    SELECT id INTO team_room_id
    FROM chat_rooms
    WHERE wedding_id = NEW.wedding_id AND type = 'wedding_team';
    
    IF team_room_id IS NOT NULL THEN
      -- Archiver le participant (ne pas supprimer pour garder l'historique)
      UPDATE chat_room_participants
      SET conversation_status = 'archived'
      WHERE room_id = team_room_id AND profile_id = NEW.professional_profile_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_add_pro_to_wedding_team_chat
AFTER INSERT OR UPDATE OF status ON wedding_participants
FOR EACH ROW
EXECUTE FUNCTION add_pro_to_wedding_team_chat();
```

#### 1.11.3 Notifications automatiques
```sql
-- Fonction pour créer une notification dans l'outbox
CREATE OR REPLACE FUNCTION queue_wedding_notification(
  p_event_type TEXT,
  p_payload JSONB
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO notifications_outbox (event_type, payload, event_key)
  VALUES (
    p_event_type,
    p_payload,
    p_event_type || '_' || (p_payload->>'wedding_id')::TEXT || '_' || now()::TEXT
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour notifications wedding_pro_added
CREATE OR REPLACE FUNCTION notify_wedding_pro_added()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'active' THEN
    PERFORM queue_wedding_notification(
      'wedding_pro_added',
      jsonb_build_object(
        'wedding_id', NEW.wedding_id,
        'pro_profile_id', NEW.professional_profile_id,
        'recipient_id', NEW.professional_profile_id
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_notify_wedding_pro_added
AFTER INSERT ON wedding_participants
FOR EACH ROW
WHEN (NEW.status = 'active')
EXECUTE FUNCTION notify_wedding_pro_added();
```

---

## 1.12 Audit Module Map - Wedding Integration

### État Actuel

#### Fichiers Existants
| Fichier | Rôle | Lignes |
|---------|------|--------|
| `lib/features/map/presentation/pages/map_page.dart` | Page map unifiée bride/pro | 1253 |
| `lib/features/map/presentation/sheets/wedding_create_sheet.dart` | Création/édition mariage | 920 |
| `lib/features/map/presentation/sheets/wedding_details_sheet.dart` | Détails mariage (tap sur pin) | 370 |
| `lib/features/map/domain/entities/wedding.dart` | Entité Wedding | 167 |
| `lib/features/map/domain/entities/wedding_details.dart` | Détails enrichis | - |
| `lib/features/map/presentation/widgets/map_controls.dart` | Boutons map (back, location, zoom) | 143 |

#### Comportement Actuel - Icône Wedding (FAB gauche)

**Bride Side (`map_page.dart` lignes 267-286):**
- FAB circulaire 40x40, icône `push_pin`
- Tap → Charge le wedding existant via `_datasource.getMyWedding()`
- Si wedding existe → Ouvre `WeddingCreateSheet` en mode édition
- Si pas de wedding → Ouvre `WeddingCreateSheet` en mode création

**Pro Side:**
- FAB circulaire 40x40, icône `crisis_alert_rounded`
- Tap → Ouvre `AlertCreateSheet`

#### Filter Chips (lignes 505-555)
- **Bride:** "Professionals" + "My Wedding"
- **Pro:** "Professionals" + "Alerts" + "Weddings"
- Toggle `showWeddings` contrôle l'affichage du pin wedding

#### WeddingCreateSheet - État Actuel
**Champs gérés:**
- `wedding_name` (optionnel)
- `event_date` (obligatoire)
- `event_end_date` (optionnel)
- `venue` (adresse + coordonnées)
- `search_radius_km` (slider 5-500km)
- `budget_min` / `budget_max` (optionnel)
- `currency` (EUR par défaut)
- `visibility` (private/visible_to_pros)
- `professions_needed` (chips multi-sélection)

**Actions:**
- Save → Crée ou met à jour le wedding
- Delete → Supprime le wedding (si existant)

#### WeddingDetailsSheet - État Actuel
**Affichage:**
- Header: Icône pin + Nom wedding + Countdown "X days to go" + Badge status
- Section Details: Date, Location, Budget
- Section Professions needed (chips)
- Section Bride info

**Actions:**
- **Bride:** Bouton "Edit" → Ouvre `WeddingCreateSheet`
- **Pro:** Bouton "Contact" → Demande de contact

### Modifications Requises pour My Wedding Suite

#### 1. Comportement FAB Wedding (Bride)

**Nouveau comportement selon spec:**
```
Si pas de mariage → Navigue vers MyWeddingPage (onboarding)
Si mariage existe → Centre la map sur le point du mariage
```

**Code à modifier (`map_page.dart` lignes 733-801):**
```dart
void _showCreateSheet(BuildContext ctx) async {
  if (!_mounted) return;
  final isBride = widget.userRole == 'bride';
  
  if (isBride) {
    // NOUVEAU: Vérifier si mariage existe
    final existingWedding = await _datasource.getMyWedding();
    
    if (existingWedding == null) {
      // Pas de mariage → Naviguer vers MyWeddingPage (onboarding)
      context.pushNamed(MyWeddingPage.routeName);
    } else {
      // Mariage existe → Centrer la map sur le point
      final lat = existingWedding['venueLat'] as double?;
      final lng = existingWedding['venueLng'] as double?;
      if (lat != null && lng != null && _mapController != null) {
        await _mapController!.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(
            gmaps.LatLng(lat, lng),
            14.0,
          ),
        );
      }
    }
  } else {
    // Pro: AlertCreateSheet (inchangé)
  }
}
```

#### 2. WeddingDetailsSheet - Modifications

**Bride Side:**
- Ajouter bouton "Go to My Wedding" → Navigue vers `MyWeddingPage`
- Garder bouton "Edit" pour édition rapide

**Pro Side:**
- Si pro est participant actif du mariage:
  - Ajouter bouton "View Wedding" → Navigue vers `WeddingClientDetailPage`
  - Ajouter bouton "Chat" → Ouvre chat 1-1 avec bride
- Si pro n'est pas participant:
  - Garder bouton "Contact" (demande de contact)

#### 3. WeddingCreateSheet - Décision

**Option A: Garder pour édition rapide depuis la map**
- Simplifié: seulement les champs essentiels (date, lieu, visibility)
- Accès via "Edit" dans WeddingDetailsSheet

**Option B: Supprimer et rediriger vers MyWeddingPage**
- Toute édition passe par `WeddingEditSheet` dans MyWeddingPage
- Plus cohérent avec le nouveau flux

**Recommandation:** Option A - Garder `WeddingCreateSheet` pour édition rapide, mais:
- Retirer la création (passe par onboarding)
- Renommer en `WeddingQuickEditSheet`
- Simplifier les champs

#### 4. Nouvelles Colonnes à Gérer

Le `WeddingCreateSheet` devra gérer les nouvelles colonnes si on le garde:
- `cover_image_url` → Upload image
- `note_for_pros` → Textarea (ou rediriger vers MyWeddingPage)
- `guest_count` → Input numérique

### SQL - Aucune Modification Supplémentaire

Les modifications de la table `weddings` sont déjà couvertes dans la section 1.2.

---

## 2. AUDIT FRONTEND FLUTTER

### 2.1 Navbars - État Actuel

#### NavBarBrides (`lib/components/nav/nav_bar_brides/nav_bar_brides_widget.dart`)

| # | Tab | Label | Icon | Route | Notes |
|---|-----|-------|------|-------|-------|
| 1 | Home | Home | `home_outlined` | `HomeBridesWidget` | ✅ Garder |
| 2 | Feed | Feed | `search_sharp` | `FeedBridesWidget` | ✅ Garder |
| 3 | Wedding | Wedding | `star_border` | `WeddingOfTheWeekWidget` | ⚠️ À modifier |
| 4 | Replay | Replay | `mic_none` | `ContentReplayWidget` | ✅ Garder |
| 5 | Profil | Profil | `person_outlined` | `ProfileBridesAndProWidget` | ⚠️ À supprimer |

#### NavBarPro (`lib/components/nav/nav_bar_pro/nav_bar_pro_widget.dart`)

| # | Tab | Label | Icon | Route | Notes |
|---|-----|-------|------|-------|-------|
| 1 | Home | Home | `home_outlined` | `DashboardProWidget` | ✅ Garder |
| 2 | Wedding | Wedding | `star_border` | `WeddingOfTheWeekWidget` | ⚠️ À déplacer |
| 3 | Replay | Replay | `mic_none` | `ContentReplayWidget` | ✅ Garder |
| 4 | Feed | Feed | `search_sharp` | `FeedBridesWidget` | ⚠️ À déplacer |
| 5 | Settings | Settings | `settings_outlined` | `ProfileBridesAndProWidget` | ⚠️ À supprimer |

### 2.2 Navbars - Modifications Requises

#### NavBarBrides - Nouvel Ordre

| # | Tab | Label | Icon | Route | Notes |
|---|-----|-------|------|-------|-------|
| 1 | Home | Home | `home_outlined` | `HomeBridesWidget` | Inchangé |
| 2 | Feed | Feed | `search_sharp` | `FeedBridesWidget` | Inchangé |
| 3 | **My Wedding** | My Wedding | `favorite_border` | **`MyWeddingPage`** | **NOUVEAU** |
| 4 | WOTW | WOTW | `star_border` | `WeddingOfTheWeekWidget` | Renommé |
| 5 | Replay | Replay | `mic_none` | `ContentReplayWidget` | Inchangé |

#### NavBarPro - Nouvel Ordre

| # | Tab | Label | Icon | Route | Notes |
|---|-----|-------|------|-------|-------|
| 1 | Home | Home | `home_outlined` | `DashboardProWidget` | Inchangé |
| 2 | Feed | Feed | `search_sharp` | `FeedBridesWidget` | Déplacé |
| 3 | **Weddings** | Weddings | `favorite_border` | **`WeddingsHubProPage`** | **NOUVEAU** |
| 4 | WOTW | WOTW | `star_border` | `WeddingOfTheWeekWidget` | Renommé |
| 5 | Replay | Replay | `mic_none` | `ContentReplayWidget` | Inchangé |

### 2.3 Pages à Modifier

#### HomeBridesWidget (`lib/pages/bride/home_brides/home_brides_widget.dart`)

**État actuel du header (lignes 159-189):**
- Favorites icon → `FavProListWidget`
- Notifications icon (avec badge) → `NotificationsPage`
- Messages icon (avec badge) → `MessagesPage`

**Modification requise:**
- Ajouter **Settings icon** (`settings_outlined`) après Messages icon
- Settings → `ProfileBridesAndProWidget`

#### DashboardProWidget

**Modification requise:**
- Ajouter **Settings icon** dans le header (même pattern que HomeBrides)
- Settings → `ProfileBridesAndProWidget`

#### FeedDetailViewerWidget (`lib/pages/bride/feed_detail_viewer/feed_detail_viewer_widget.dart`)

**Modification requise:**
- Ajouter **icône signet** (bookmark) pour sauvegarder dans un album
- Tap → Ouvre `SaveToAlbumSheet`

### 2.4 Module Chat - Extensions Requises

**Fichiers existants:**
- `lib/features/chat/presentation/pages/chat_details_page.dart`
- `lib/features/chat/presentation/widgets/message_composer.dart`
- `lib/features/chat/presentation/widgets/message_bubble.dart`

**Modifications requises:**

1. **MessageComposer** - Ajouter bouton attachment:
   - Icône attachment à gauche du champ texte
   - Tap → Modal choix média/document

2. **MessageBubble** - Ajouter support type `document`:
   - Affichage icône PDF + nom + taille
   - Tap → Télécharger/Ouvrir

3. **ChatDetailsPage** - Support `wedding_team` room type:
   - Header adapté (nom du mariage, avatars participants)
   - Accès aux infos du mariage

---

## 3. AUDIT DESIGN SYSTEM

### 3.1 Widgets Existants (`lib/core/design/widgets/`)

| Widget | Fichier | Usage |
|--------|---------|-------|
| `LynewedSheet` | `lynewed_sheet.dart` | ✅ Form sheets |
| `LynewedDetailsSheet` | `lynewed_details_sheet.dart` | ✅ Details sheets |
| `LynewedButton` | `lynewed_button.dart` | ✅ Buttons |
| `LynewedTextField` | `lynewed_text_field.dart` | ✅ Text inputs |
| `LynewedChip` | `lynewed_chip.dart` | ✅ Chips |
| `LynewedSlider` | `lynewed_slider.dart` | ✅ Single slider |
| `LynewedRangeSlider` | `lynewed_range_slider.dart` | ✅ Range slider |
| `LynewedBudgetSlider` | `lynewed_budget_slider.dart` | ✅ Budget slider |
| `LynewedDistanceSlider` | `lynewed_distance_slider.dart` | ✅ Distance slider |
| `LynewedSectionTitle` | `lynewed_section_title.dart` | ✅ Section titles |
| `LynewedHeaderActions` | `lynewed_header_actions.dart` | ✅ Header actions |
| `LynewedMoreMenu` | `lynewed_more_menu.dart` | ✅ Popup menus |
| `LynewedInfoRow` | `lynewed_info_row.dart` | ✅ Info rows |
| `LynewedAboutSection` | `lynewed_about_section.dart` | ✅ About sections |

### 3.2 Widgets à CRÉER (`lib/core/design/widgets/`)

| Widget | Fichier | Specs |
|--------|---------|-------|
| **LynewedCountdownCard** | `lynewed_countdown_card.dart` | Cover image, nom, date, lieu, countdown J-XX, nb participants |
| **LynewedTeamChatItem** | `lynewed_team_chat_item.dart` | Style salon: avatars circulaires, badge unread, nb participants |
| **LynewedProTile** | `lynewed_pro_tile.dart` | Photo, nom, profession, icône chat |
| **LynewedTodoItem** | `lynewed_todo_item.dart` | Item todo list avec états (pending/done/cancelled) |
| **LynewedAlbumGrid** | `lynewed_album_grid.dart` | Grille d'albums (2 colonnes) |
| **LynewedAlbumCard** | `lynewed_album_card.dart` | Card album avec cover, nom, count |
| **LynewedGuestTile** | `lynewed_guest_tile.dart` | Tile invité (nom, role, email/phone) |
| **LynewedNoteCard** | `lynewed_note_card.dart` | Card note (bride note for pros) |
| **LynewedDocumentMessage** | `lynewed_document_message.dart` | Message document dans chat |
| **LynewedAttachmentModal** | `lynewed_attachment_modal.dart` | Modal choix média/document |
| **LynewedWeddingClientCard** | `lynewed_wedding_client_card.dart` | Card mariage pour Weddings Hub Pro |
| **LynewedSectionHeader** | `lynewed_section_header.dart` | Header de section avec titre + action optionnelle |

### 3.3 Sheets à CRÉER (`lib/features/my_wedding/presentation/sheets/`)

| Sheet | Fichier | Specs |
|-------|---------|-------|
| **InviteProSheet** | `invite_pro_sheet.dart` | Recherche pro + sélection |
| **AddGuestSheet** | `add_guest_sheet.dart` | Nom + email/phone + role |
| **SaveToAlbumSheet** | `save_to_album_sheet.dart` | Liste albums + create new |
| **CreateAlbumSheet** | `create_album_sheet.dart` | Nom + catégorie + privacy |
| **AddEventSheet** | `add_event_sheet.dart` | Titre + date + description + visibility |
| **AddExpenseSheet** | `add_expense_sheet.dart` | Catégorie + montant + status |
| **EditNoteSheet** | `edit_note_sheet.dart` | Textarea max 1000 chars |
| **LeaveWeddingSheet** | `leave_wedding_sheet.dart` | Raison obligatoire (pro side) |
| **ExcludeProSheet** | `exclude_pro_sheet.dart` | Confirmation + raison (bride side) |
| **CancelWeddingSheet** | `cancel_wedding_sheet.dart` | Warning + confirmation |
| **WeddingEditSheet** | `wedding_edit_sheet.dart` | Édition infos mariage |

### 3.4 Modals à CRÉER

| Modal | Usage |
|-------|-------|
| **ProActionsModal** | Long press sur pro: exclure, report |
| **WeddingActionsModal** | Long press sur wedding (pro side): mute, quitter |
| **AttachmentChoiceModal** | Chat: choix média/document |

---

## 4. PLAN D'IMPLÉMENTATION

### Sprint 1: Foundation (Backend + Core UI)
**Durée estimée:** 3-4 jours  
**Dépendances:** Aucune

#### 1.1 Migrations Supabase
- [ ] Modifier table `weddings` (cover_image_url, note_for_pros, cancelled_at, onboarding_step, guest_count)
- [ ] Modifier table `wedding_participants` (colonnes + enum status)
- [ ] Modifier table `chat_rooms` (type check + wedding_id)
- [ ] Modifier table `chat_messages` (document type + colonnes)
- [ ] Créer table `wedding_guests`
- [ ] Créer table `inspiration_albums`
- [ ] Créer table `saved_posts`
- [ ] Créer table `album_images`
- [ ] Créer table `wedding_events`
- [ ] Créer table `wedding_expenses`
- [ ] Créer table `pro_wedding_notes`

#### 1.2 RLS Policies
- [ ] Policies pour `wedding_guests`
- [ ] Policies pour `inspiration_albums`
- [ ] Policies pour `saved_posts`
- [ ] Policies pour `album_images`
- [ ] Policies pour `wedding_events`
- [ ] Policies pour `wedding_expenses`
- [ ] Policies pour `pro_wedding_notes`
- [ ] Modifier policies `chat_rooms` pour wedding_team

#### 1.3 Triggers & Functions
- [ ] Trigger création chat wedding_team
- [ ] Trigger ajout/retrait pro du chat
- [ ] Functions notifications (wedding_pro_added, etc.)

#### 1.4 Widgets Design System Core
- [ ] `LynewedCountdownCard`
- [ ] `LynewedTeamChatItem`
- [ ] `LynewedProTile`
- [ ] `LynewedSectionHeader`

#### 1.5 Navbar Restructuring
- [ ] Modifier `NavBarBridesWidget` (nouvel ordre)
- [ ] Modifier `NavBarProWidget` (nouvel ordre)
- [ ] Créer routes pour nouvelles pages

#### 1.6 Settings Icon in Headers
- [ ] Ajouter settings icon dans `HomeBridesWidget`
- [ ] Ajouter settings icon dans `DashboardProWidget`

---

### Sprint 2: Onboarding
**Durée estimée:** 2-3 jours  
**Dépendances:** Sprint 1.1 (migrations)

#### 2.1 Onboarding Pages
- [ ] Créer `WeddingOnboardingPage` (container)
- [ ] Écran 1: Welcome
- [ ] Écran 2: Date (obligatoire)
- [ ] Écran 3: Location (obligatoire)
- [ ] Écran 4: Professionals (optionnel)
- [ ] Écran 5: Guest Count (optionnel)
- [ ] Écran 6: Budget (optionnel)
- [ ] Écran 7: Visibility (optionnel)
- [ ] Écran 8: Features Preview (marketing)
- [ ] Écran 9: Done

#### 2.2 Persistence Logic
- [ ] Sauvegarde automatique à chaque étape
- [ ] Reprise où l'utilisateur s'est arrêté
- [ ] Gestion du champ `onboarding_step`

#### 2.3 Wedding Creation Flow
- [ ] Création du wedding en DB
- [ ] Validation des champs obligatoires
- [ ] Redirection vers My Wedding Page

#### 2.4 Chat Wedding Team Auto-Creation
- [ ] Vérifier trigger Supabase
- [ ] Tester création automatique

---

### Sprint 3: My Wedding Page (Bride)
**Durée estimée:** 3-4 jours  
**Dépendances:** Sprint 2

#### 3.1 Page Skeleton + Routing
- [ ] Créer `MyWeddingPage`
- [ ] Routing depuis navbar
- [ ] Gestion état (pas de mariage vs mariage existant)

#### 3.2 Wedding Countdown Card
- [ ] Implémenter `LynewedCountdownCard`
- [ ] Cover image upload
- [ ] Calcul countdown J-XX

#### 3.3 Wedding Team Chat Item
- [ ] Implémenter `LynewedTeamChatItem`
- [ ] Avatars participants
- [ ] Badge unread count
- [ ] Navigation vers ChatDetailsPage

#### 3.4 Wedding Team Section
- [ ] Liste des pros (`LynewedProTile`)
- [ ] Tap → ProDetailsPage
- [ ] Long press → Modal actions
- [ ] Icône chat → Chat 1-1

#### 3.5 Header avec Icônes
- [ ] Icône Chat → MessagesPage filtré
- [ ] Icône Settings → Menu mariage

#### 3.6 Sections Overview
- [ ] Section Agenda (preview)
- [ ] Section Budget (preview)
- [ ] Section Inspirations (preview)
- [ ] Section Guests (preview)
- [ ] Section Note for Pros

---

### Sprint 4: Wedding Team Features
**Durée estimée:** 2-3 jours  
**Dépendances:** Sprint 3

#### 4.1 Invite Pro Flow
- [ ] Créer `InviteProSheet`
- [ ] Recherche par nom
- [ ] Liste pros déjà contactés
- [ ] Ajout automatique (pas de validation)

#### 4.2 Exclude Pro Flow
- [ ] Créer `ExcludeProSheet`
- [ ] Confirmation + raison
- [ ] Mise à jour status participant
- [ ] Retrait du chat wedding_team

#### 4.3 Pro Quit Flow
- [ ] Créer `LeaveWeddingSheet`
- [ ] Raison obligatoire
- [ ] Mise à jour status participant

#### 4.4 Notifications
- [ ] `wedding_pro_added` → Pro
- [ ] `wedding_pro_excluded` → Pro
- [ ] `wedding_pro_left` → Bride

#### 4.5 Chat 1-1 Access Filtré
- [ ] MessagesPage avec filtre wedding
- [ ] Afficher uniquement pros du mariage

---

### Sprint 5: Weddings Hub Pro
**Durée estimée:** 2-3 jours  
**Dépendances:** Sprint 1

#### 5.1 Weddings Hub Page
- [ ] Créer `WeddingsHubProPage`
- [ ] Liste des mariages (participant actif)
- [ ] `LynewedWeddingClientCard`

#### 5.2 Wedding Client Detail Page
- [ ] Créer `WeddingClientDetailPage`
- [ ] Header (cover, nom, date, countdown)
- [ ] Section Bride Info
- [ ] Section Wedding Team Chat
- [ ] Section Chat with Bride
- [ ] Section Shared Albums
- [ ] Section Shared Events
- [ ] Section Bride's Note
- [ ] Section My Notes

#### 5.3 Mute Workflow
- [ ] Long press → Modal mute
- [ ] Toggle `is_muted` dans `wedding_participants`

#### 5.4 Pro Notes
- [ ] Créer `ProNotesSheet`
- [ ] CRUD notes privées

#### 5.5 Shared Content Access
- [ ] Accès albums publics (lecture seule)
- [ ] Accès events publics (lecture seule)

---

### Sprint 6: Moodboard
**Durée estimée:** 3-4 jours  
**Dépendances:** Sprint 3

#### 6.1 Albums CRUD
- [ ] Créer `CreateAlbumSheet`
- [ ] Liste albums dans My Wedding
- [ ] `LynewedAlbumGrid` + `LynewedAlbumCard`

#### 6.2 Save from Feed Flow
- [ ] Ajouter icône signet dans `FeedDetailViewerWidget`
- [ ] Créer `SaveToAlbumSheet`
- [ ] Sauvegarde dans `saved_posts`

#### 6.3 Upload from Gallery
- [ ] Picker images
- [ ] Upload vers Storage
- [ ] Sauvegarde dans `album_images`

#### 6.4 Album Detail Page
- [ ] Créer `AlbumDetailPage`
- [ ] Grille images
- [ ] Actions (supprimer, etc.)

#### 6.5 Privacy Toggle
- [ ] Switch privé/public
- [ ] Mise à jour `is_private`

---

### Sprint 7: Planning Features
**Durée estimée:** 3-4 jours  
**Dépendances:** Sprint 3

#### 7.1 Agenda
- [ ] Créer `AgendaPage`
- [ ] `LynewedTodoItem` pour events
- [ ] `AddEventSheet`
- [ ] Toggle public/privé

#### 7.2 Budget Tracker
- [ ] Créer `BudgetPage`
- [ ] Header avec totaux
- [ ] `LynewedTodoItem` pour expenses
- [ ] `AddExpenseSheet`

#### 7.3 Note for Pros
- [ ] `EditNoteSheet`
- [ ] Max 1000 chars
- [ ] Affichage dans My Wedding

#### 7.4 Guests List
- [ ] Créer `GuestsPage`
- [ ] `LynewedGuestTile`
- [ ] `AddGuestSheet`

#### 7.5 Public/Private Visibility
- [ ] Toggle par event
- [ ] Affichage côté pro

---

### Sprint 8: Map Integration & Documents
**Durée estimée:** 2-3 jours  
**Dépendances:** Sprint 3, 4, 5

#### 8.1 Map FAB Wedding - Nouveau Comportement
- [ ] Modifier `map_page.dart` - FAB bride: si pas de mariage → MyWeddingPage
- [ ] Modifier `map_page.dart` - FAB bride: si mariage existe → centrer sur le point
- [ ] Tester le nouveau flux

#### 8.2 WeddingDetailsSheet - Modifications
- [ ] Bride: Ajouter bouton "Go to My Wedding" → `MyWeddingPage`
- [ ] Pro participant: Ajouter bouton "View Wedding" → `WeddingClientDetailPage`
- [ ] Pro participant: Ajouter bouton "Chat" → Chat 1-1 avec bride
- [ ] Pro non-participant: Garder bouton "Contact" (inchangé)

#### 8.3 WeddingCreateSheet - Simplification
- [ ] Décider: garder pour édition rapide OU supprimer
- [ ] Si gardé: retirer la création (passe par onboarding)
- [ ] Si gardé: renommer en `WeddingQuickEditSheet`
- [ ] Mettre à jour les références

#### 8.4 Document Upload in Chat
- [ ] `LynewedAttachmentModal`
- [ ] File picker (PDF)
- [ ] Upload vers Storage

#### 8.5 Document Message Display
- [ ] `LynewedDocumentMessage`
- [ ] Intégration dans `MessageBubble`
- [ ] Download/Open action

#### 8.6 Cancel/Resume Wedding
- [ ] `CancelWeddingSheet`
- [ ] Resume flow
- [ ] Notifications aux pros

#### 8.7 Final Polish & Testing
- [ ] Tests unitaires
- [ ] Tests d'intégration
- [ ] Test manuel complet

---

## 5. STRUCTURE DES MODULES

### Module My Wedding (Bride)
```
lib/features/my_wedding/
├── domain/
│   ├── entities/
│   │   ├── wedding_guest.dart
│   │   ├── wedding_event.dart
│   │   ├── wedding_expense.dart
│   │   ├── inspiration_album.dart
│   │   └── saved_post.dart
│   ├── repositories/
│   │   └── my_wedding_repository.dart
│   └── usecases/
│       ├── get_wedding_overview.dart
│       ├── get_wedding_team.dart
│       ├── invite_pro_to_wedding.dart
│       ├── exclude_pro_from_wedding.dart
│       └── save_post_to_album.dart
├── data/
│   ├── datasources/
│   │   └── supabase_my_wedding_datasource.dart
│   └── repositories/
│       └── my_wedding_repository_impl.dart
└── presentation/
    ├── pages/
    │   ├── my_wedding_page.dart
    │   ├── wedding_onboarding_page.dart
    │   ├── wedding_team_page.dart
    │   ├── guests_page.dart
    │   ├── inspirations_page.dart
    │   ├── album_detail_page.dart
    │   ├── agenda_page.dart
    │   └── budget_page.dart
    ├── widgets/
    │   └── (module-specific widgets)
    └── sheets/
        ├── invite_pro_sheet.dart
        ├── add_guest_sheet.dart
        ├── save_to_album_sheet.dart
        ├── create_album_sheet.dart
        ├── add_event_sheet.dart
        ├── add_expense_sheet.dart
        ├── edit_note_sheet.dart
        ├── exclude_pro_sheet.dart
        ├── cancel_wedding_sheet.dart
        └── wedding_edit_sheet.dart
```

### Module Weddings Hub Pro
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
    ├── widgets/
    │   └── (module-specific widgets)
    └── sheets/
        ├── leave_wedding_sheet.dart
        └── pro_notes_sheet.dart
```

---

## 6. CHECKLIST FINALE

### Backend
- [ ] Toutes les tables créées
- [ ] Tous les enums mis à jour
- [ ] RLS policies en place et testées
- [ ] Triggers fonctionnels
- [ ] Storage buckets configurés (albums, documents)

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
- [ ] Mise à jour PROJECT.md
- [ ] Mise à jour DESIGN_SYSTEM.md si nouveaux patterns

---

## 7. RISQUES & MITIGATIONS

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Migration enum `wedding_participant_status` | HIGH | Créer nouvel enum v2, migrer données, puis supprimer ancien |
| Performance avec beaucoup de participants | MEDIUM | Index sur `wedding_id`, pagination |
| Storage pour albums/documents | MEDIUM | Configurer buckets avec quotas |
| Notifications en temps réel | MEDIUM | Utiliser système existant (notifications_outbox) |
| Complexité onboarding | LOW | Persistence à chaque étape, UX simple |

---

## 8. DÉPENDANCES EXTERNES

### Packages Flutter à ajouter
```yaml
# pubspec.yaml
dependencies:
  file_picker: ^6.0.0  # Pour upload documents
  # Autres packages déjà présents
```

### Storage Buckets Supabase
```sql
-- Créer bucket pour albums
INSERT INTO storage.buckets (id, name, public)
VALUES ('wedding-albums', 'wedding-albums', true);

-- Créer bucket pour documents chat
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-documents', 'chat-documents', false);
```

---

**Document créé:** 2025-12-10  
**Auteur:** Cascade AI  
**Status:** ✅ Audit terminé - Plan d'implémentation créé

---

## 📎 Document Suivant

**➡️ Plan d'Implémentation Final:** `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md`

Ce document d'audit a servi de base pour créer le plan d'implémentation détaillé. 
Utiliser le plan d'implémentation comme référence principale pour le développement.
