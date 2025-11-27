# Plan de Refactorisation - Map Feature

**Créé:** 2025-11-26 | **Version:** v1.7 | **Source:** `docs/audits/MAP_FEATURE_AUDIT.md`
**Validation:** 2025-11-27 | **Statut:** ✅ GO VALIDÉ + STRATÉGIE RÉÉCRITURE ADOPTÉE

---

## 🔥 CHANGEMENTS v1.7 - STRATÉGIE RÉÉCRITURE (2025-11-27)

### ⚠️ CONSTAT CRITIQUE : Code FlutterFlow Non-Maintenable

**Analyse du code actuel :**
| Fichier | Lignes | Problème |
|---------|--------|----------|
| `lynewed_interactive_map.dart` | 925 | Widget monolithique, logique complexe |
| `map_brides_large_widget.dart` | 892 | ~90% dupliqué avec pro_large |
| `map_pro_large_widget.dart` | 870 | Copié-collé de brides |
| `query_filters_struct.dart` | 417 | Pattern FlutterFlow verbeux (3x) |
| `layer_toggles_struct.dart` | 238 | Getters/setters inutiles |
| **TOTAL** | **3342+** | **Dette technique massive** |

**Problèmes FlutterFlow identifiés :**
1. **Imports redondants** : 20+ imports par fichier
2. **Structs verbeux** : Pattern `_field + get + set + hasField()` (3x plus de code que nécessaire)
3. **Duplication massive** : 90% code identique entre pages bride/pro
4. **Logique éparpillée** : Custom actions, custom functions, page models séparés
5. **État incohérent** : Multiples sources de vérité pour les mêmes données
6. **Non-testable** : Couplage fort, pas de dependency injection

### ✅ DÉCISION : RÉÉCRITURE COMPLÈTE

**Nouvelle approche : Créer un module map propre et indépendant**

```
lib/
├── features/           # Nouvelle structure
│   └── map/           # Module map autonome
│       ├── domain/    # Entités et use cases
│       ├── data/      # Repositories et datasources
│       ├── presentation/ # Widgets et state management
│       └── README.md  # Documentation module
```

**Objectif :** Sortir définitivement du pattern FlutterFlow verbeux et mal structuré

### 📋 PHASES RÉVISÉES

| Phase | Ancien Scope | Nouveau Scope |
|-------|--------------|---------------|
| Phase 1 | ~~Nettoyage enum~~ | ✅ TERMINÉ - Enum nettoyé (8→5 valeurs) |
| Phase 2 | Backend Wedding | **RÉÉCRITURE** - Nouveau module `/features/map/` |
| Phase 3 | Backend Alertes | Intégré dans nouvelle architecture |
| Phase 4-7 | Patches progressifs | **Remplacé** par architecture propre |

---

## 📝 CHANGEMENTS v1.6 (Validation Corrections)

### Corrections Critiques Appliquées
1. **✅ Enum subscriptionTierType**: `trial` (pas `free`) aligné avec Supabase
2. **✅ Table pro_recent_locations**: Documentée + Phase 2.5 ajoutée pour décision
3. **✅ Limites zoom**: Inversées pour correspondre au RPC (2000→50 au lieu de 0→1000)
4. **✅ connectionRequestSource**: `weddingPin`→`wedding` migration documentée
5. **✅ professional_alerts**: Migration `motif_code`→`alert_type` détaillée
6. **✅ Phase 2.5**: Migration pro_recent_locations (2-3h, décision requise)
7. **✅ Timeline**: Révisée 60-75h (+30% réaliste)
8. **✅ Seed data**: Prérequis fixed locations ajouté (table vide en dev)

### Décisions Critiques - ✅ TOUTES VALIDÉES (2025-11-27)
- **✅ pro_recent_locations**: **SUPPRIMER** MapMarkerType.proRecent (localisation temps réel abandonnée)
- **✅ connectionRequestSource**: **MIGRER** enum `weddingPin`→`wedding` (cohérence Wedding)
- **✅ professional_alerts**: **GARDER** `motif_code` pour compatibilité (migration progressive)

---

## ⏱️ TIMELINE ESTIMÉE

| Phase | Durée | Cumulé |
|-------|-------|--------|
| Phase 0: Préparation | 4-6h | 4-6h |
| Phase 1: Nettoyage Enum | 2-3h | 6-9h |
| Phase 2: Backend Wedding | 10-12h | 16-21h |
| Phase 2.5: Migration pro_recent_locations | 2-3h | 18-24h |
| Phase 3: Backend Alertes | 6-8h | 24-32h |
| Phase 4: Flutter Structs | 10-12h | 34-44h |
| Phase 5: Widgets UI | 12-14h | 46-58h |
| Phase 6: Tests | 8-10h | 54-68h |
| Phase 7: Déploiement | 6-7h | **60-75h** |

**Estimation révisée : ~1.5 semaine dev (60-75h)**

---

## 🎯 OBJECTIFS

| Problème | Solution | Priorité |
|----------|----------|----------|
| MapMarkerType: 8 valeurs confuses | Réduire à 4 valeurs | HAUTE |
| 2 sources de coords pros | `professional_fixed_locations` uniquement | HAUTE |
| POI vs WeddingPin mal pensés | Concept "Wedding" unifié | HAUTE |
| Markers superposés | Offset léger + adresses précises | MOYENNE |
| Clustering bulles | ❌ Supprimer (style Uber/Relay) | HAUTE |
| Pas de séparation marché indien | Filtrage par `market_region` | BASSE (post-refacto) |

---

## 📋 DÉCISIONS VALIDÉES (2025-11-26)

| Élément | Décision | Status |
|---------|----------|--------|
| `proRecent` | ❌ Supprimer | À faire |
| `user` | ❌ Supprimer | À faire |
| `searchTarget` | 🔄 Overlay non-cliquable | À faire |
| `professional` + `fixedLocation` | 🔄 Fusionner → `proFixedLocation` | À faire |
| `poiPrivate` + `weddingPin` | 🔄 Fusionner → Concept "Wedding" | ✅ Défini |
| POI privé bride | ❌ Supprimer (aucune valeur) | ✅ Validé |

### Nouveau MapMarkerType
```dart
enum MapMarkerType {
  proFixedLocation,   // Positions pros
  professionalAlert,  // Alertes temporaires
  myWedding,          // Mariage de la bride (unique, central)
  visibleWedding,     // Mariages opt-in visibles par pros
}
```

---

## 💍 CONCEPT "WEDDING" - DÉCISION FINALE

### Contexte
Les concepts POI privé et WeddingPin étaient confus et mal pensés :
- POI privé = note morte sans action
- WeddingPin = déclenchait une "wishlist" pro (illogique)

### Décision: Option A+ "Wedding Event Centré"
**1 mariage par bride** = hub central de l'expérience

### Flux Utilisateur Validé

```
BRIDE                                    PRO
  │                                        │
  ├─ S'inscrit, explore l'app              │
  │                                        │
  ├─ Crée son mariage (quand prête)        │
  │   - Date, lieu, budget, professions    │
  │   - Visibilité: privé | visible        │
  │                                        │
  ├─ Cherche des pros (map/feed)           │
  │                                        │
  ├─ Ajoute un pro en favoris ────────────→│ Notification "Sophie D. vous a ajouté"
  │                                        │
  │                                        ├─ Voit: "Sophie D. | Juin 2025 | Paris"
  │                                        │   (si mariage visible: voir fiche)
  │                                        │
  │←──────────────────────────────────────┼─ Demande de contact
  │                                        │
  ├─ Accepte/Refuse                        │
  │                                        │
  └─ Si accepté → Chat ouvert ────────────→│ Chat + devient "participant"
                                           │
                                           └─ Après mariage → Album partagé
```

### Schéma de Données

```sql
-- Table principale (1 par bride)
CREATE TABLE weddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bride_profile_id uuid UNIQUE REFERENCES profiles(id),  -- 1 mariage actif/bride
  
  -- Informations du mariage
  wedding_name text,                        -- "Mariage de Sophie & Thomas"
  event_date date NOT NULL,                 -- Date du mariage
  
  -- Localisation (via AddressSearchWidget)
  venue_coords geometry(Point, 4326),       -- Lieu précis si connu
  venue_label text,                         -- "Château de Versailles"
  search_area_coords geometry(Point, 4326), -- Zone de recherche
  search_radius_km int DEFAULT 50,          -- Rayon de recherche
  
  -- Budget & besoins
  budget_min numeric,
  budget_max numeric,
  currency text DEFAULT 'EUR',
  professions_needed profession[],
  
  -- Visibilité & status
  visibility text DEFAULT 'private' CHECK (visibility IN ('private', 'visible_to_pros')),
  status text DEFAULT 'planning' CHECK (status IN ('planning', 'confirmed', 'completed')),
  
  -- Région pour segmentation
  market_region text DEFAULT 'europe',
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Pros confirmés (préparation album partagé)
CREATE TABLE wedding_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wedding_id uuid REFERENCES weddings(id) ON DELETE CASCADE,
  professional_profile_id uuid REFERENCES profiles(id),
  
  profession profession,                    -- Profession au moment de l'acceptation
  status text DEFAULT 'requested' CHECK (status IN ('requested', 'accepted', 'declined')),
  
  requested_at timestamptz DEFAULT now(),
  accepted_at timestamptz,
  
  UNIQUE(wedding_id, professional_profile_id)
);

-- Index pour performance
CREATE INDEX idx_weddings_search_area ON weddings USING gist(search_area_coords);
CREATE INDEX idx_weddings_visibility ON weddings(visibility) WHERE visibility = 'visible_to_pros';
CREATE INDEX idx_weddings_market_region ON weddings(market_region);
```

### Règles Métier

| Règle | Description |
|-------|-------------|
| **1 mariage/bride** | `bride_profile_id UNIQUE` - simplifie tout |
| **Création flexible** | Hors onboarding, quand la bride est prête |
| **Pro ne voit pas le profil** | Seulement prénom + initiale (ex: "Sophie D.") |
| **Demande de contact** | Pro → Bride, pas l'inverse |
| **Participant** | Pro accepté = contributeur futur album |

### Anticipation Album Partagé

```sql
-- Future table (pas maintenant, mais structure prête)
CREATE TABLE wedding_albums (
  id uuid PRIMARY KEY,
  wedding_id uuid REFERENCES weddings(id),
  contributor_id uuid REFERENCES wedding_participants(professional_profile_id),
  photos jsonb,  -- URLs des photos
  is_public boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);
```

La structure `wedding_participants` avec `status = 'accepted'` permet de savoir quels pros peuvent contribuer à l'album.

### Migration des Données Existantes

```sql
-- Tables à supprimer
-- user_pois → Supprimés (aucune valeur réelle, 0 records)
-- pro_recent_locations → À supprimer si proRecent est retiré de MapMarkerType

-- wedding_pins → Migrés vers weddings (10 records en dev)

INSERT INTO weddings (bride_profile_id, event_date, venue_coords, ...)
SELECT bride_profile_id, event_start_date, location_coords, ...
FROM wedding_pins
WHERE is_deleted = false;

-- NOTE: pro_recent_locations contient les positions récentes des pros
-- Décision requise: garder la table et le type proRecent, ou supprimer les deux?
-- Si suppression: désactiver section 3 du RPC search_map_bundle
```

---

## �️ RÈGLES D'AFFICHAGE MAP - DÉCISION FINALE

### Principe Fondamental
**Style Uber/Mondial Relay : Chaque marker est individuel et identifiable.**
- ❌ PAS de clustering (bulles "13 markers")
- ❌ PAS de regroupement au zoom arrière
- ✅ Markers individuels avec gestion intelligente de la densité

---

### 1. Gestion du Zoom

| Niveau Zoom | Échelle | Limite Markers | Comportement |
|-------------|---------|----------------|--------------|
| ≤ 5 | Continent | 2000 | Maximum markers (vue d'ensemble) |
| 6-8 | Pays | 800 | Vue régionale élargie |
| 9-11 | Région | 300 | Affichage standard |
| 12-14 | Ville | 100 | Limité pour performance |
| ≥ 15 | Rue/Quartier | 50 | Très limité (vue détaillée) |

#### Priorité d'Affichage (si limite atteinte)
```sql
ORDER BY 
  CASE WHEN avatar_url IS NOT NULL THEN 0 ELSE 1 END,  -- 1. Avatar présent
  subscription_tier DESC,                               -- 2. Abonnement élevé
  created_at DESC                                       -- 3. Plus récent
```

---

### 2. Taille des Markers selon le Zoom

| Niveau Zoom | Taille Marker | Avatar | Bordure | Détails |
|-------------|---------------|--------|---------|---------|
| 6-8 | **Petit** (24px) | ❌ Non | Fine (1px) | Couleur profession uniquement |
| 9-11 | **Moyen** (32px) | ✅ Miniature | Normale (2px) | Couleur profession |
| 12-14 | **Standard** (44px) | ✅ Visible | Normale (2px) | Couleur + forme |
| ≥ 15 | **Grand** (56px) | ✅ Détaillé | Épaisse (3px) | Couleur + forme + badge |

#### Spécifications Visuelles
```dart
class MarkerSizeConfig {
  static const Map<int, MarkerSize> zoomSizes = {
    6: MarkerSize(diameter: 24, avatarVisible: false, borderWidth: 1),
    9: MarkerSize(diameter: 32, avatarVisible: true, borderWidth: 2),
    12: MarkerSize(diameter: 44, avatarVisible: true, borderWidth: 2),
    15: MarkerSize(diameter: 56, avatarVisible: true, borderWidth: 3),
  };
}
```

---

### 3. Gestion des Superpositions (Offset)

#### Contexte
Avec des adresses précises obligatoires, les superpositions seront rares.
Cas possibles : même immeuble, même studio partagé.

#### Règle d'Offset
```dart
/// Applique un décalage circulaire pour les markers proches
/// Distance offset : ~10-15 mètres (suffisant pour tap précis)
LatLng applyProximityOffset(LatLng original, int index, int totalAtLocation) {
  if (totalAtLocation <= 1) return original;
  
  const double offsetDistance = 0.00012; // ~12 mètres
  final double angle = (2 * pi * index) / totalAtLocation;
  
  return LatLng(
    original.latitude + offsetDistance * cos(angle),
    original.longitude + offsetDistance * sin(angle),
  );
}
```

#### Détection des Markers Proches
```dart
/// Seuil de proximité : 20 mètres
const double proximityThresholdMeters = 20.0;
const double proximityThresholdDegrees = 0.00018; // ~20m à l'équateur

bool areMarkersClose(LatLng a, LatLng b) {
  return (a.latitude - b.latitude).abs() < proximityThresholdDegrees &&
         (a.longitude - b.longitude).abs() < proximityThresholdDegrees;
}
```

#### Algorithme de Groupement
```
1. Trier les markers par coordonnées
2. Identifier les groupes de markers proches (< 20m)
3. Pour chaque groupe > 1 marker :
   - Appliquer offset circulaire
   - Index 0 = position originale
   - Index 1+ = décalés en cercle autour
4. Résultat : tous les markers sont "tappables" individuellement
```

---

### 4. Contraintes d'Adresses

#### Règle Fondamentale
**Les adresses génériques sont interdites pour les professionnels.**

| Type | Exemple | Autorisé |
|------|---------|----------|
| Adresse précise | "123 Rue de Rivoli, 75001 Paris" | ✅ Oui |
| Ville seule | "Paris" | ❌ Non |
| Code postal seul | "75001" | ❌ Non |
| Région | "Île-de-France" | ❌ Non |

#### Validation Backend
```sql
-- Contrainte sur professional_fixed_locations
ALTER TABLE professional_fixed_locations
ADD CONSTRAINT check_precise_address 
CHECK (
  location_label IS NOT NULL 
  AND length(location_label) > 10
  AND location_label ~ '\d'  -- Contient au moins un chiffre (numéro de rue)
);
```

#### Validation Flutter (AddressSearchWidget)
```dart
bool isAddressPrecise(PlaceDetails place) {
  // Doit avoir un numéro de rue OU un nom de lieu précis
  return place.addressComponents.any((c) => 
    c.types.contains('street_number') || 
    c.types.contains('premise') ||
    c.types.contains('establishment')
  );
}
```

---

### 5. Comportement par Type de Marker

| Type | Taille | Priorité zIndex | Couleur Bordure | Tap Action |
|------|--------|-----------------|-----------------|------------|
| `proFixedLocation` | Variable (zoom) | 3 | Couleur profession | → Sheet Pro |
| `professionalAlert` | Fixe (48px) | 5 (top) | Rouge urgence | → Sheet Alerte |
| `myWedding` | Fixe (56px) | 4 | Or/Doré | → Sheet Mon Mariage |
| `visibleWedding` | Variable (zoom) | 3.5 | Rose/Mariage | → Sheet Mariage |

#### zIndex (Ordre d'empilement)
```dart
double zIndexForType(MapMarkerType type) {
  switch (type) {
    case MapMarkerType.professionalAlert: return 5.0;  // Toujours au-dessus
    case MapMarkerType.myWedding: return 4.0;          // Priorité bride
    case MapMarkerType.visibleWedding: return 3.5;     // Mariages visibles
    case MapMarkerType.proFixedLocation: return 3.0;   // Pros standard
  }
}
```

---

### 6. Animations et Transitions

| Action | Animation | Durée |
|--------|-----------|-------|
| Apparition marker | Fade in + scale | 200ms |
| Disparition marker | Fade out | 150ms |
| Changement taille (zoom) | Scale smooth | 100ms |
| Tap marker | Bounce léger | 150ms |
| Chargement nouveaux markers | Fade in progressif | 300ms |

---

### 7. Performance

#### Debounce Camera
```dart
// Délai avant rechargement des markers après mouvement camera
const Map<int, int> debounceByZoom = {
  6: 800,   // Zoom faible = délai long (moins de précision nécessaire)
  9: 500,   // Zoom moyen = délai standard
  12: 300,  // Zoom élevé = délai court (précision importante)
  15: 200,  // Zoom max = réactivité maximale
};
```

#### Cache Markers
```dart
// Garder en cache les markers du viewport précédent
// Évite le "flash" lors de petits mouvements
const double cacheBufferRatio = 1.5; // 50% de marge autour du viewport
```

---

### 8. Messages Utilisateur

| Situation | Message (FR) | Message (EN) |
|-----------|--------------|--------------|
| Zoom trop faible | "Zoomez pour découvrir les professionnels" | "Zoom in to discover professionals" |
| Aucun résultat | "Aucun professionnel dans cette zone" | "No professionals in this area" |
| Chargement | Skeleton markers animés | - |
| Erreur réseau | "Impossible de charger la carte. Réessayer ?" | "Unable to load map. Retry?" |

---

### 9. Résumé des Règles

```
┌─────────────────────────────────────────────────────────────────┐
│                    RÈGLES D'AFFICHAGE MAP                       │
├─────────────────────────────────────────────────────────────────┤
│ ❌ PAS de clustering (bulles de regroupement)                   │
│ ❌ PAS d'adresses génériques (ville seule interdite)            │
│ ✅ Markers individuels toujours                                 │
│ ✅ Taille variable selon zoom (24px → 56px)                     │
│ ✅ Offset automatique si markers < 20m                          │
│ ✅ Limite par zoom (0 → 100 → 300 → 500 → 1000)                 │
│ ✅ Priorité : avatar > abonnement > récent                      │
│ ✅ Animations fluides (fade, scale)                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## � ALERTES PROFESSIONNELLES - DÉCISION FINALE

### Contexte
**Pitch Lynewed:** "Community Alert - When help can't wait, the community responds."

**Problèmes identifiés:**
- Concept trop vague ("J'ai un problème")
- Pas actionnable (que fait le pro qui voit ?)
- Durée arbitraire (1 semaine max, pourquoi ?)

### Décision: Alertes Structurées par Type

```sql
CREATE TYPE alert_type AS ENUM (
  'backup_needed',      -- "Je cherche un remplaçant pour [date]"
  'gear_emergency',     -- "Je cherche à louer [équipement] pour [date]"
  'team_member',        -- "Je cherche un second shooter/assistant pour [date]"
  'emergency_help'      -- "Urgence sur événement, aide immédiate nécessaire"
);
```

### Schéma de Données

```sql
professional_alerts (mise à jour)
├── id, author_profile_id
├── alert_type: alert_type (ENUM)        -- Type d'aide demandée (NOUVEAU)
├── title: text (max 100)                -- "Besoin photographe 15 juin Paris"
├── description: text (max 500)          -- Détails
├── location_coords: geometry            -- Où
├── event_date: date NOT NULL            -- Quand (obligatoire, NOUVEAU)
├── budget_offered: numeric?             -- ❌ Supprimé (entraide, pas rémunération)
├── profession_needed: profession?       -- Quelle profession cherchée
├── expires_at: timestamptz              -- Auto: event_date + 1 jour
├── motif_code: text?                    -- EXISTANT (référence alert_motifs.code)
├── duration_hours: smallint?            -- EXISTANT (utilisé pour expires_at)
├── status: 'active' | 'resolved' | 'expired'
├── created_at
```

### Migration professional_alerts

**État actuel (12 records en dev):**
- `motif_code`: text vers `alert_motifs.code` (table de référence)
- `duration_hours` + `expires_at` (calculé depuis duration)
- Pas de `event_date` ni `alert_type`

**Migration requise:**
```sql
-- 1. Créer enum alert_type (déjà dans le plan)
CREATE TYPE alert_type AS ENUM (
  'backup_needed', 'gear_emergency', 'team_member', 'emergency_help'
);

-- 2. Ajouter colonnes
ALTER TABLE professional_alerts
ADD COLUMN alert_type alert_type,
ADD COLUMN event_date date;

-- 3. Migrer motif_code → alert_type (mapping à définir)
-- Besoin de mapper les codes existants vers les 4 nouveaux types

-- 4. Décision: garder motif_code pour compatibilité ou supprimer?
```

### Règles Métier Alertes

| Règle | Valeur |
|-------|--------|
| **Qui peut créer ?** | Tous les pros (tous tiers) |
| **Qui voit ?** | Tous les pros (valeur communautaire) |
| **Durée de vie** | Jusqu'à `event_date + 1 jour` |
| **Limite** | 3 alertes actives max par pro |
| **Réponse** | Bouton "Je peux aider" → Chat direct |
| **Filtrable par profession ?** | Oui (optionnel) |
| **Rémunération ?** | ❌ Non (entraide communautaire uniquement) |

### Flux Utilisateur

```
PRO CRÉE                                  AUTRE PRO
  │                                          │
  ├─ Choisit type (backup/gear/team/help)    │
  ├─ Remplit: titre, description,            │
  │   date, lieu, (profession)               │
  │   ❌ PAS de budget (entraide)             │
  │                                          │
  └─ Publie ────────────────────────────────→│ Voit sur map
                                             │
                                             ├─ Tap → Voir détails
                                             ├─ "Je peux aider" → Notif auteur
                                             └─ Chat direct ouvert
```

---

## 💰 ABONNEMENTS - IMPACT SUR LA MAP

### Tiers Validés

| Tier | Prix/mois | Prix/an |
|------|-----------|---------|
| **Trial** | $0 | $0 |  <!-- NOTE: "Trial" pas "Free" dans Supabase enum -->
| **Early Access** | $42 | $444 |
| **Premium Visibility** | $64 | $700 |
| **Ultimate Access** | $94 | $1000 |

### Matrice Visibilité Map

| Élément Map | Trial | Early | Premium | Ultimate |
|-------------|-------|-------|---------|----------|
| **Voir pros sur map** | ✅ | ✅ | ✅ | ✅ |
| **Être visible sur map** | ❌ | ✅ | ✅ | ✅ |

### Règles Clés

1. **Pro inactive** ne peut pas utiliser la map (compte désactivé)
2. **Pro trial** peut explorer la map mais n'est pas visible (visibilité limitée)
3. **Alertes** accessibles à tous (valeur communautaire, pas de paywall)
4. **Mariages visibles** réservés Premium+ (fonctionnalité premium)
5. **Être visible sur map** = Early Access minimum

---

## PLAN D'ACTION COMPLET

### Phase 0: Préparation & Sécurité 🔒 (4-6h)
| Tâche | Description | Risque | Validation |
|-------|-------------|--------|------------|
| **Backup complet** | Export DB + code tag v1.3-before-map-refactor | Nul | ✅ Backup vérifié |
| **Feature flags** | Créer `map_refactor_enabled` dans `user_preferences` | Faible | ✅ Flag testé |
| **Rollback plan** | Script de restauration automatique | Faible | ✅ Script testé |
| **Environnement test** | Clone staging avec données réelles | Faible | ✅ Staging prêt |
| **Monitoring** | Alertes performance + erreurs map | Faible | ✅ Dashboards ok |
| **Seed data fixed locations** | Créer 10+ professional_fixed_locations pour tests | Faible | ⚠️ À FAIRE |

### Phase 1: Nettoyage Enum & Code Mort 🧹 (2-3h)
| Tâche | Fichier | Risque | Dépendance |
|-------|---------|--------|------------|
| Supprimer `proRecent` | `enums.dart` | Nul | Aucune |
| Supprimer `user` | `enums.dart` | Nul | Aucune |
| `searchTarget` → overlay | `lynewed_interactive_map.dart` | Faible | Aucune |
| Renommer `fixedLocation` → `proFixedLocation` | Multiple | Faible | Aucune |
| Supprimer code mort | `lynewed_interactive_map.dart` | Nul | Aucune |

**✅ Validation Phase 1:** App compile + tests existants passent

---

### Phase 2: Backend Wedding + RPC 💍 (10-12h)
| Tâche | Description | Risque | Dépendance |
|-------|-------------|--------|------------|
| **Créer table `weddings`** | Migration SQL + RLS + Index PostGIS | Moyen | Phase 1 |
| **Créer table `wedding_participants`** | Migration SQL + RLS + triggers | Faible | weddings |
| **Migrer données `wedding_pins`** | Script migration + validation doublons | Élevé | weddings |
| **Mettre à jour `search_map_bundle`** | Remplacer wedding_pins par weddings | Élevé | Migration OK |
| **Mettre à jour autres RPCs** | `get_wedding_details`, `insert_wedding`, etc. | Moyen | weddings |
| **Mettre à jour RLS** | Politiques weddings par bride | Moyen | weddings |
| **Supprimer table `user_pois`** | Après validation complète | Faible | Tests OK |
| **Migrer connectionRequestSource** | `weddingPin`→`wedding` enum value | Moyen | Tests OK |

**✅ Validation Phase 2:** API retourne weddings + migration 100% + RLS sécurisé

**Migration connectionRequestSource:**
```sql
-- Migrer les données existantes
UPDATE connection_requests 
SET source = 'wedding' 
WHERE source = 'weddingPin';

-- Renommer la valeur dans l'enum
ALTER TYPE "connectionRequestSource" RENAME VALUE 'weddingPin' TO 'wedding';
```

---

### Phase 2.5: Migration pro_recent_locations 🔄 (2-3h) - ✅ DÉCISION PRISE
| Tâche | Description | Risque | Dépendance |
|-------|-------------|--------|------------|
| ~~**Décider sur proRecent**~~ | ✅ **SUPPRIMER** MapMarkerType.proRecent | - | ✅ Décidé |
| **Désactiver section 3 RPC** | Retirer proRecent de search_map_bundle | Moyen | Phase 2 |
| **Archiver table** | Archiver pro_recent_locations (pas supprimer) | Faible | RPC désactivé |
| **Supprimer toggle UI** | Retirer showProRecent des filtres Flutter | Faible | Aucune |
| **Mettre à jour enums Flutter** | Supprimer proRecent de MapMarkerType | Moyen | Aucune |

**✅ Décision validée (2025-11-27):**
- **SUPPRIMER proRecent** - Fonctionnalité localisation temps réel abandonnée
- Table archivée (pas supprimée) pour historique

**✅ Validation Phase 2.5:** proRecent supprimé + table archivée + UI nettoyée

---

### Phase 3: Backend Alertes & Abonnements 🚨 (6-8h)
| Tâche | Description | Risque | Dépendance |
|-------|-------------|--------|------------|
| **Créer `alert_type` enum** | 4 types d'entraide (backup, gear, team, emergency) | Faible | Aucune |
| **Mettre à jour `professional_alerts`** | Ajouter `event_date`, supprimer `budget_offered` | Moyen | alert_type |
| **Mettre à jour `search_map_bundle`** | Ajouter alert_type dans retours | Faible | Phase 2 |
| **Mettre à jour RLS alertes** | Tous les pros peuvent voir/créer | Faible | Aucune |
| **Mettre à jour abonnements** | Matrice Free/Early/Premium/Ultimate | Faible | Aucune |

**✅ Validation Phase 3:** Alertes avec types + abonnements cohérents

---

### Phase 4: Flutter Structs & Logique 📦 (6-8h)
| Tâche | Description | Risque | Dépendance |
|-------|-------------|--------|------------|
| **Créer `WeddingStruct`** | Flutter struct + JSON serialization | Faible | Phase 2 |
| **Créer `AlertStruct`** | Flutter struct avec types structurés | Faible | Phase 3 |
| **Implémenter offset markers** | Algorithme décalage 20m + zIndex | Moyen | Aucune |
| **Créer `MarkerSizeConfig`** | Configuration centralisée tailles | Faible | Aucune |
| **Mettre à jour actions** | `getMapMarkersAction`, `getWeddingDetailsAction` | Moyen | Structs |

**✅ Validation Phase 4:** Structs parsent correctement + offset fonctionne

---

### Phase 5: Widgets Flutter & UI 📱 (8-10h)
| Tâche | Description | Risque | Dépendance |
|-------|-------------|--------|------------|
| **Supprimer clustering** | Retirer FlutterMapCluster tout le code | Moyen | Phase 4 |
| **Taille variable par zoom** | 24px → 56px selon niveau zoom | Faible | MarkerSizeConfig |
| **Mettre à jour `LynewedInteractiveMap`** | Nouveaux types + offset + taille variable | Moyen | Phase 4 |
| **Créer `WeddingMarkerWidget`** | Component réutilisable mariages | Faible | WeddingStruct |
| **Mettre à jour `AlertMarkerWidget`** | Nouveaux types d'alertes | Faible | AlertStruct |
| **Mettre à jour sheets** | ProDetails, WeddingDetails, AlertDetails | Moyen | Widgets |
| **Implémenter MiniMap** | Widget statique + paramètres coords | Faible | Aucune |
| **Messages utilisateur** | Français/anglais + erreurs réseau | Faible | Aucune |

**✅ Validation Phase 5:** Map affiche correctement tous les types + UI responsive

---

### Phase 6: Tests & Validation ✅ (4-6h)
| Tâche | Description | Risque | Dépendance |
|-------|-------------|--------|------------|
| **Tests unitaires backend** | RPCs + RLS + migrations | Moyen | Phase 2-3 |
| **Tests intégration Flutter** | Widgets + navigation + offline | Moyen | Phase 5 |
| **Tests performance** | 1000 markers + charge concurrente | Moyen | Phase 5 |
| **Tests cross-platform** | iOS + Android + responsive | Faible | Phase 5 |
| **Validation utilisateur** | Scénarios critiques + edge cases | Faible | Tout |
| **Documentation finale** | README + guide déploiement | Nul | Tout |

**✅ Validation Phase 6:** Coverage >80% + benchmarks OK + UAT validé

---

### Phase 7: Déploiement & Monitoring 🚀 (4-6h)
| Tâche | Description | Risque | Validation |
|-------|-------------|--------|------------|
| **Déploiement progressif** | 10% → 50% → 100% avec feature flag | Moyen | ✅ Monitoring OK |
| **Rollback automatique** | Si erreurs > seuil critique | Faible | ✅ Script testé |
| **Documentation post-déploiement** | Guide utilisateur + support | Nul | ✅ Docs livrées |
| **Formation équipe** | Support + nouvelles fonctionnalités | Faible | ✅ Équipe formée |

---

## 🔄 STRATÉGIE ROLLBACK

### Si Phase 2 échoue (Wedding)
```sql
-- Restaurer wedding_pins depuis backup
-- Supprimer tables weddings/wedding_participants
-- Réactiver code ancien (feature flag = false)
```

### Si Phase 4 échoue (Performance)
```dart
// Réactiver clustering avec paramètres conservateurs
// Revenir aux anciennes limites RPC
// Monitoring accru pendant 48h
```

### Temps de rollback cible
- **Phase 1-2:** < 30 minutes (backup DB)
- **Phase 3-4:** < 15 minutes (feature flag)
- **Phase 5-6:** < 60 minutes (hotfix)

---

## 📊 MÉTRIQUES DE SUCCÈS

| Métrique | Cible | Mesure |
|----------|-------|--------|
| **Performance map** | < 2s pour 1000 markers | Benchmark automatique |
| **Taux d'erreur** | < 0.1% requêtes map | Monitoring |
| **Adoption** | > 80% pros utilisent nouvelles alertes | Analytics |
| **Satisfaction** | > 4.5/5 feedback utilisateurs | Sondages |
| **Zero downtime** | Aucune interruption production | Uptime monitoring |

---

## 📚 RÉFÉRENCES CROISÉES

### Documents Connexes
- **`docs/App/APP_SOURCE_OF_TRUTH.md`** - Source de vérité complète app (v1.3)
  - Architecture technique, flux métier, schéma DB
  - Aligné avec ce plan pour cohérence totale
- **`docs/audits/MAP_FEATURE_AUDIT.md`** - Audit complet fonctionnalité map
  - Inventaire code existant, problèmes identifiés
  - Base technique pour cette refactorisation
- **`docs/PROJECT_TODO.md`** - Tâches et améliorations futures
  - Feed Pro, Ambassadeurs, évolutions post-refactorisation

### Validation Cohérence
Avant implémentation, vérifier que :
- [ ] `APP_SOURCE_OF_TRUTH.md` mentionne bien `connectionRequestSource: wedding` (pas `weddingPin`)
- [ ] Les enums `subscriptionTierType` et `alertType` sont identiques dans les 2 documents
- [ ] Les règles d'abonnement (matrice Free/Early/Premium/Ultimate) sont cohérentes

---

## ✅ CHECKLIST PRÉ-IMPLÉMENTATION

### Environnement & Sécurité 🔒
- [ ] **Backup complet** réalisé et vérifié (DB + code tag v1.4)
- [ ] **Staging** cloné avec données de production anonymisées
- [ ] **Feature flags** déployés en production (`map_refactor_enabled = false`)
- [ ] **Monitoring** configuré (alertes performance + erreurs map)
- [ ] **Rollback scripts** testés sur staging

### Équipe & Communication 👥
- [ ] **Équipe dev** briefée sur les 7 phases et dépendances
- [ ] **Support** formé aux nouvelles fonctionnalités (Wedding, Alertes)
- [ ] **Documentation** utilisateur préparée (guides, FAQ)
- [ ] **Planning communication** clients défini (maintenance, nouveautés)

### Technique & Outils 🛠️
- [ ] **Outils migration** SQL préparés et testés
- [ ] **Scripts seeding** mis à jour avec nouvelles adresses précises
- [ ] **Tests automatisés** existants passent sur code actuel
- [ ] **CI/CD** prêt pour déploiement progressif
- [ ] **Dashboards** monitoring créés (performance, erreurs, adoption)

### Validation Finale ✨
- [ ] **Revue complète** des 2 documents (cohérence 100%)
- [ ] **Sign-off** technique lead sur architecture
- [ ] **Sign-off** product owner sur fonctionnalités
- [ ] **Go/No-Go** meeting pré-implémentation planifié

---

**⚠️ POINT CRITIQUE :** Ne pas commencer Phase 1 avant que TOUS les items de cette checklist soient validés.

---

## 📝 CHANGELOG

### 2025-11-26
- **[17:15]** Audit map complet terminé
- **[17:20]** Décisions stratégiques validées
- **[17:25]** Création document de refactorisation
- **[17:50]** Concept "Wedding" défini (Option A+)
  - 1 mariage par bride
  - POI privé supprimé
  - Pro ne voit pas le profil bride
  - Demande de contact pro → bride
  - Anticipation album partagé via `wedding_participants`
- **[18:15]** Alertes repensées
  - 4 types structurés (backup, gear, team, emergency_help)
  - ❌ PAS de rémunération (entraide communautaire uniquement)
  - Expiration auto (event_date + 1 jour)
  - Bouton "Je peux aider" → Chat direct
  - Accessible à tous les tiers (valeur communautaire)
- **[18:20]** Abonnements clarifiés
  - Free: voir map, pas visible
  - Early: visible sur map
  - Premium+: voir mariages, contacter brides
  - Alertes: tous les tiers (pas de paywall)
- **[18:30]** Règles d'affichage map définies
  - ❌ Suppression clustering (style Uber/Relay)
  - ✅ Taille markers variable selon zoom (24px → 56px)
  - ✅ Offset automatique pour markers proches (< 20m)
  - ✅ Adresses précises obligatoires (pas de ville seule)
  - ✅ Limites par zoom (0 → 100 → 300 → 500 → 1000)
  - ✅ Priorité affichage : avatar > abonnement > récent
- **[18:45]** Plan d'action finalisé (v1.4)
  - Phase 0: Backup + Feature flags + Sécurité
  - 7 phases complètes avec validation et rollback
  - Checklist pré-implémentation + Références croisées
  - Timeline estimée: ~40-50h total
- **[18:50]** Challenge final et corrections (v1.5)
  - Réorganisation phases avec dépendances claires
  - Phase 2: Backend Wedding + RPC (fusionné)
  - Phase 4: Flutter Structs & Logique (nouveau)
  - Validation par phase ajoutée
  - Timeline en haut du document
  - Marché indien → post-refactorisation

---

## ❓ QUESTIONS RÉSOLUES

| Question | Réponse |
|----------|---------|
| Utilité POI privé ? | ❌ Aucune → Supprimé |
| Wishlist pro→bride logique ? | ❌ Non → Remplacé par "demande de contact" |
| 1 ou plusieurs mariages/bride ? | 1 seul actif (simplifie UX) |
| Création à l'onboarding ? | Non, quand la bride est prête |
| Comment préparer album ? | `wedding_participants` avec `status = 'accepted'` |
| Alertes: C'est quoi exactement ? | 4 types: backup, gear, team, last_minute_booking |
| Alertes: Durée de vie ? | Auto-expiration: `event_date + 1 jour` |
| Alertes: Qui peut créer/voir ? | Tous les pros (valeur communautaire) |
| Alertes: Comment répondre ? | Bouton "Je peux aider" → Chat direct |
| Pro Free visible sur map ? | ❌ Non (incitation à payer Early+) |
| Mariages visibles: Qui voit ? | Premium + Ultimate uniquement |
| Feed Pro: Condition visibilité ? | Paiement séparé $900/an (pas lié à l'abonnement) |
| Clustering bulles ? | ❌ Supprimé (style Uber/Relay) |
| Markers superposés ? | Offset automatique ~12m si < 20m de distance |
| Adresses génériques ? | ❌ Interdites (adresse précise obligatoire) |
| Taille markers variable ? | ✅ Oui, selon zoom (24px → 56px) |
| Limite markers par zoom ? | 0 → 100 → 300 → 500 → 1000 |

---

## 📊 MÉTRIQUES CIBLES

- **MapMarkerType:** 8 → 4 valeurs
- **Tables map:** Suppression `user_pois`, création `weddings` + `wedding_participants`
- **Markers superposés:** 0
- **Performance:** <2s pour 1000 markers

---

**Prochaine action:** Phase 1 - Nettoyage Enum
