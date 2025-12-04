# Source de Vérité - LYNEWED App

**Document créé:** 2025-11-26  
**Objectif:** Documentation complète de l'application - architecture, flux, bugs critiques et apprentissages  
**Version:** v1.5

## 📋 **Version History**
- **v1.4 (2025-12-01):** 🎉 Module Map 100% complet - Clean Architecture, Design System, 63 tests passants
- **v1.3 (2025-11-26):** Mise à jour complète map - Concept Wedding, abonnements, alertes tous pros
- **v1.2 (2025-11-26):** Ajout sections Testing Scenarios, Known Limitations
- **v1.1 (2025-11-26):** Documentation bug portfolio/slideshow, Storage, Edge Functions
- **v1.0 (2025-11-26):** Création initiale

## 🗺️ **Module Map - TERMINÉ**

Le module Map a été entièrement refactorisé en Clean Architecture (2025-12-01).

| Aspect | Détail |
|--------|--------|
| **Code** | `lib/features/map/` (~4200 lignes) |
| **Architecture** | Clean Architecture (domain/data/presentation) |
| **Design System** | 100% appliqué (`lib/core/design/`) |
| **Tests** | 63/63 passants |
| **Documentation** | `lib/features/map/README.md` |
| **Rapport Final** | `docs/archive/MAP_REFACTORING_COMPLETE_2025-12-01.md` |

## 📖 **Table des Matières**
- [🚨 Critical Gotchas](#-critical-gotchas---à-connaître-impérativement)
- [🏗️ Architecture Technique](#️-architecture-technique---supabase)
- [📊 Data Model Deep Dive](#-data-model-deep-dive---mapping-ui--db)
- [📋 Vue d'ensemble des Rôles](#-vue-densemble-des-rôles)
- [🎯 Flux de Contact et Conversation](#-flux-de-contact-et-conversation)
- [📍 Système de Localisation](#-système-de-localisation)
- [🔔 Système d'Alertes](#-système-dalertes)
- [💎 Restrictions par Abonnement](#-restrictions-par-abonnement)
- [🔄 État des Demandes de Contact](#-état-des-demandes-de-contact)
- [🎨 Scénarios d'Utilisation Typiques](#-scénarios-dutilisation-typiques)
- [🗄️ Storage Buckets & RLS Policies](#️-storage-buckets--rls-policies)
- [🔌 Edge Functions & API Endpoints](#-edge-functions--api-endpoints)
- [📱 State Management - FFAppState](#-state-management---ffappstate)
- [🚨 FlutterFlow Gotchas](#-flutterflow-gotchas---pièges-à-éviter)
- [🧪 Testing Scenarios](#-testing-scenarios---cas-de-test-critiques)
- [⚠️ Known Limitations](#️-known-limitations---contraintes-techniques)
- [🐛 Apprentissages & Bugs Découverts](#-apprentissages--bugs-découverts)
- [⚙️ Guide de Développement](#️-guide-de-développement---éviter-les-bugs)
- [📝 Checklist de Développement](#-checklist-de-développement)

## ⚡ **Quick Reference - Réponses Rapides**

| Question | Réponse | Section |
|----------|---------|---------|
| **Slider images ?** | `slideshow_images` | [Data Model](#-data-model-deep-dive---mapping-ui--db) |
| **Grille portfolio ?** | `portfolio_images` | [Data Model](#-data-model-deep-dide---mapping-ui--db) |
| **Syntaxe enum PostgreSQL ?** | `CAST('value' AS "enumType")` | [Guide Dev](#️-guide-de-développement---éviter-les-bugs) |
| **Coordonnées PostGIS ?** | `ST_SetSRID(ST_MakePoint(lng, lat), 4326)` | [Guide Dev](#️-guide-de-développement---éviter-les-bugs) |
| **Bride→Pro direct ?** | Conversation immédiate | [Flux Contact](#-flux-de-contact-et-conversation) |
| **Pro→Bride via wedding ?** | Demande d'attente obligatoire | [Flux Contact](#-flux-de-contact-et-conversation) |
| **Free visible sur map ?** | NON (incitation Early+) | [Restrictions](#-restrictions-par-abonnement) |
| **Alertes qui voit ?** | TOUS les pros (entraide) | [Alertes](#️-système-dalertes---entraide-communautaire) |
| **Code safe zones ?** | `custom_code/`, `compo_finaux/` | [FlutterFlow Gotchas](#-flutterflow-gotchas---pièges-à-éviter) |
| **Bucket avatars ?** | `avatars` (public) | [Storage](#️-storage-buckets--rls-policies) |
| **RPC principal ?** | `get_pro_item_details()` | [API](#-edge-functions--api-endpoints) |
| **Map clustering ?** | ❌ Supprimé (style Uber/Relay) | [audits/MAP_FEATURE_AUDIT.md](../audits/MAP_FEATURE_AUDIT.md) |
| **Concept Wedding ?** | 1 mariage/bride, remplace pins/POI | [audits/MAP_FEATURE_AUDIT.md](../audits/MAP_FEATURE_AUDIT.md) |

## 📄 **Migration Notice**
**⚠️ IMPORTANT:** `APP_FLOWS_BUSINESS_RULES.md` est maintenant **déprécié**.  
Utilisez `APP_SOURCE_OF_TRUTH.md` comme source de vérité unique pour tout développement.  

---

## 🚨 **CRITICAL GOTCHAS - À CONNAÎTRE IMPÉRATIVEMENT**

### ⚠️ **Dualité des Images Professionnelles (BUG CRITIQUE)**
**NE PAS CONFONDRE :**
- `professional_details.portfolio_images` → Utilisé par la **grille portfolio** en bas
- `professional_details.slideshow_images` → Utilisé par le **slider** en haut  

**Le piège :** Les deux colonnes existent mais sont indépendantes. Si vous remplissez l'une sans l'autre, soit le slider soit la grille sera vide.

**Solution :** Maintenir les deux synchronisées ou utiliser la logique de fallback appropriée.

### ⚠️ **Trigger problématique pour seeding**
`trg_on_first_msg_pro_bride` crée automatiquement des connection_requests lors de l'insertion de messages. **Désactiver pendant le seeding** pour éviter violations de contraintes uniques.

### ⚠️ **PostgreSQL Enums - Syntaxe stricte**
```sql
-- ❌ NE FONCTIONNE PAS
'ultimateAccess'::subscriptionTierType

-- ✅ SYNTAXE OBLIGATOIRE
CAST('ultimateAccess' AS "subscriptionTierType")
```

---

## 🏗️ **Architecture Technique - Supabase**

### Base de données PostgreSQL avec PostGIS

**Tables principales:**
- `auth.users` - Utilisateurs Supabase (trigger automatique vers profiles)
- `profiles` - Profils utilisateurs (créés automatiquement par trigger)
- `bride_details` - Détails spécifiques brides (schéma simplifié: profile_id, created_at, updated_at)
- `professional_details` - Détails professionnels avec localisation PostGIS (pas de colonne phone)
- `professional_subscriptions` - Abonnements (free, earlyAccess, premiumVisibility, ultimateAccess)
- `professional_fixed_locations` - es fixes supplémentaires (précises obligatoires)
- `chat_rooms` / `chat_room_participants` / `chat_messages` - Système de messagerie
- `video_sessions` - Sessions vidéo avec Agora
- `weddings` - **NOUVEAU** Mariages (1 par bride, remplace wedding_pins)
- `wedding_participants` - **NOUVEAU** Participants aux mariages
- `wishlist_items` - Favoris brides→professionnels
- `connection_requests` - Demandes de connexion
- `professional_alerts` - Alertes professionnels (tous les pros, entraide)
- `user_preferences` - Préférences utilisateur

**Tables dépréciées (à supprimer):**
- `wedding_pins` - Remplacé par `weddings`
- `user_pois` - POI privés supprimés (aucune valeur)

**Enums critiques:**
- `userRole`: bride, professional
- `subscriptionTierType`: free, earlyAccess, premiumVisibility, ultimateAccess
- `profession`: PHOTOGRAPHER, FILMMAKER, PLANNER, MAKEUP, HAIRDRESSER, DESIGNER, BRIDALDESIGNER, VENUE, BRIDALSHOP, FLORIST, PHOTOMOVIE, MAKEUPARTIST, EVENTDESIGNER, OTHER
- `conversationStatus`: pending, active, declined, blocked, reportedPending, archived
- `videoSessionStatus`: pending, accepted, declined, missed, completed, cancelled
- `alertStatus`: active, cancelled, expired
- `alertType`: backup_needed, gear_emergency, team_member, emergency_help
- `weddingVisibility`: private, visible_to_pros
- `connectionRequestSource`: wishlist, wedding, map, alert, proToPro
- `messageType`: text, image, audio
- `connectionRequestStatus`: pending, accepted, declined

**Triggers automatiques:**
- `on_auth_user_created()` - Crée automatiquement un profile dans la table profiles lors de l'insertion dans auth.users
- `trg_on_first_msg_pro_bride` - Crée automatiquement une connection_request lors du premier message pro→bride (PROBLÉMATIQUE POUR SEEDING)
- `trg_outbox_chat_msg` - Gère les notifications après insertion de messages

**Données spatiales (PostGIS):**
- Utilisation de `geometry` avec SRID 4326 (WGS84)
- Format: `ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)`
- Tables concernées: professional_details, professional_fixed_locations, wedding_pins, professional_alerts

**UUIDs et Identifiants:**
- `gen_random_uuid()` pour les IDs uniques
- `instance_id` fixe: `00000000-0000-0000-0000-000000000000` (standard Supabase)
- Agora channel names: `'agora_' || gen_random_uuid()::text`

---

## 📊 **Data Model Deep Dive - Mapping UI ↔ DB**

### Professional Details - Double Structure Images
| Composant UI | Champ DB | Usage | Remarques |
|-------------|----------|-------|-----------|
| **Slider principal** (pro_details) | `slideshow_images` | Images défilantes en haut | Était vide → bug corrigé |
| **Grille portfolio** (pro_details) | `portfolio_images` | Grille d'images en bas | Fonctionnait déjà |
| **Fallback** (public_pro_profile_view) | `slideshow_images` → `portfolio_images` | Logique de secours | Plus robuste |

### Mapping Complet des Champs
| Champ Flutter | Champ Supabase | Type | Notes |
|---------------|----------------|------|-------|
| `avatarUrl` | `profiles.avatar_url` | text | URL image profil |
| `fullName` | `profiles.full_name` | text | Nom affiché |
| `businessName` | `professional_details.business_name` | text | Nom entreprise |
| `profession` | `professional_details.profession` | enum | Type de métier |
| `description` | `professional_details.description` | text | Description pro |
| `portfolioImages` | `professional_details.portfolio_images` | text[] | Grille portfolio |
| `slideshowImages` | `professional_details.slideshow_images` | text[] | Slider images |
| `profileVideoUrl` | `professional_details.profile_video_url` | text | URL vidéo |
| `instagramUrl` | `professional_details.instagram_url` | text | Social |
| `websiteUrl` | `professional_details.website_url` | text | Site web |

### Fonctions RPC Critiques
**`get_pro_item_details(p_pro_profile_id)`**
Retourne : `portfolioImages` + `slideshowImages` + toutes les infos pro

**Mapping des retours RPC :**
```sql
'portfolioImages', COALESCE(to_jsonb(v_portfolio), '[]'::jsonb),
'slideshowImages', COALESCE(to_jsonb(v_slideshow), '[]'::jsonb),
```

---

## 📋 **Vue d'ensemble des Rôles**

### BRIDE (Mariée)
- **Objectif principal:** Trouver des professionnels pour son mariage
- **Actions possibles:** 
  - Créer son **Wedding** (1 mariage actif par bride)
    - Date, lieu, budget, professions recherchées
    - Visibilité: private ou visible_to_pros
  - Contacter directement les professionnels
  - Ajouter des professionnels en wishlist/favoris
  - Accepter/décliner les demandes de contact des pros

### PROFESSIONAL (Professionnel)
- **Objectif principal:** Trouver des clients et collaborer avec d'autres pros
- **Actions possibles:**
  - Créer des alertes professionnelles (entraide communautaire, visibles par TOUS les pros)
    - Types: backup_needed, gear_emergency, team_member, emergency_help
    - Pas de rémunération (entraide uniquement)
  - Avoir une e principale + es supplémentaires (précises obligatoires)
  - Contacter les brides (via mariage visible ou wishlist)
  - Contacter d'autres professionnels
  - Publier des articles
  - Voir les demandes de contact en attente

---

## 🎯 **Flux de Contact et Conversation**

### 1. BRIDE → PROFESSIONAL (Contact direct)
```
Bride consulte page ProDetails
↓
Bride clique sur "Contacter"
↓
Conversation créée DIRECTEMENT
↓
Pas de demande d'attente
↓
Pro reçoit notification de nouveau message
```

**Conditions:**
- Aucune restriction pour la bride
- Valable pour tous les types d'abonnement pro

### 2. BRIDE → PROFESSIONAL (Wishlist)
```
Bride ajoute un pro en favoris/wishlist
↓
Si pro est PREMIUM ou ULTIMATE:
→ Pro voit la bride dans sa wishlist
→ Pro peut initier la conversation
↓
Si pro est TRIAL:
→ Pro ne voit pas la wishlist
→ Impossible d'initier le contact
```

**Conditions:**
- Bride: tous abonnements
- Pro: PREMIUM_VISIBILITY ou ULTIMATE_ACCESS uniquement

### 3. PROFESSIONAL → BRIDE (via Wedding visible)
```
Pro consulte la carte et voit un Wedding visible (visibility = 'visible_to_pros')
↓
Pro voit: prénom + initiale bride, date, budget, professions recherchées
↓
Pro clique sur "Demander contact" depuis le Wedding
↓
Demande de contact CRÉÉE pour la bride
↓
Bride reçoit notification "Nouvelle demande de contact"
↓
Bride doit ACCEPTER ou DÉCLINER
↓
Si accepté → Conversation créée + Pro devient participant
Si décliné → Aucune conversation
```

**Conditions:**
- Pro: Premium Visibility ou Ultimate Access uniquement
- Wedding doit être visible (visible_to_pros)
- Pro doit matcher les professions recherchées OU budget
- Zone de recherche du pro doit inclure le wedding

### 4. PROFESSIONAL → PROFESSIONAL (Contact pro-à-pro)
```
Pro consulte la carte ou recherche d'autres pros
↓
Pro clique sur "Contacter" un autre professionnel
↓
Demande de contact CRÉÉE pour le pro destinataire
↓
Pro destinataire doit ACCEPTER ou DÉCLINER
↓
Si accepté → Conversation créée
Si décliné → Aucune conversation
```

**Conditions:**
- Pro initiateur: tous abonnements
- Pro destinataire: tous abonnements
- Utile pour collaborations (ex: photographe + vidéaste)

---

## 📍 **Système de Localisation - PROBLÈMES CRITIQUES IDENTIFIÉS**

### 🚨 **Architecture Actuelle - Problèmes Fondamentaux**

#### Flux de Données Actuel (brisé)
```
CRM → Supabase (professionals_details) → Backend RPC → App (ProDetailsStruct) → Map (MapMarkerStruct)
                                                    ↓
                                            ProSummaryStruct (PERTE DE DONNÉES)
```

#### Structures de Données - Incohérence Critique
| Structure | Contenu | Problème Fondamental |
|-----------|---------|---------------------|
| **ProDetailsStruct** | `fixedLocations: List<LatLng>` + `locationLabel: String` | ✅ **Contient les coordonnées précises** |
| **ProSummaryStruct** | `locationLabel: String` + `distanceKm: Double` | ❌ **PERD les fixedLocations** |
| **MapMarkerStruct** | `position: LatLng` + `type: MapMarkerType` | ❌ **Position calculée côté app** |

### 🚨 **Problèmes Identifiés**

#### 1. **Perte de Données dans le Feed**
- **Cause** : `get_feed_professionals_action.dart` ignore `fixedLocations` lors de la création de `ProSummaryStruct`
- **Conséquence** : Les markers sur la map utilisent `locationLabel` au lieu des coordonnées précises
- **Impact** : Superposition de markers, positions imprécises

#### 2. **Gestion Locale vs CRM**
- **Actuel** : L'app calcule les distances et gère les localisations côté client
- **Problème** : Non tenable à grande échelle, duplication de logique
- **Solution requise** : Déplacer la logique dans le CRM/backend

#### 3. **Affichage des Markers**
- **Actuel** : Probablement utilise `locationLabel` pour créer les markers
- **Problème** : Ignore `fixedLocations` précis du CRM
- **Solution requise** : Utiliser uniquement `fixedLocations` pour les markers pros

#### 4. **Points Groupés (Clustering)**
- **Actuel** : Logique existe dans `LynewedInteractiveMap` mais état incertain
- **Problème** : Peut être cassé ou mal optimisé
- **Solution requise** : Vérifier et corriger l'algorithme de clustering

### 🏗️ **Architecture PostGIS (correcte mais sous-utilisée)**
- **professional_details.location** : Point PostGIS principal (e professionnelle)
- **professional_fixed_locations** : es fixes supplémentaires ( GeoJSON )
- **wedding_pins** : Zones de recherche mariage (PostGIS)
- **Requêtes spatiales** : `ST_DWithin`, `ST_Distance` pour la proximité

### 🔄 **Flux de Localisation Idéal (à implémenter)**
1. **CRM gère les localisations** → fixedLocations dans professional_details
2. **Backend calcule les distances** → RPC functions optimisées
3. **App reçoit les coordonnées** → ProSummaryStruct avec fixedLocations
4. **Map affiche les markers précis** → Utilisation des fixedLocations
5. **Clustering optimisé** → Algorithmes côté backend si nécessaire

### 🔍 **Questions Critiques à Résoudre Avant Refactoring**

#### Questions Techniques
1. **Backend RPC Data** : Le RPC `get_feed_professionals` envoie-t-il réellement les `fixedLocations` dans la réponse ?
2. **Map Rendering Source** : La map utilise-t-elle `ProSummaryStruct` ou `ProDetailsStruct` pour l'affichage initial ?
3. **Clustering Algorithm** : L'algorithme de clustering actuel fonctionne-t-il avec les données existantes ?
4. **Performance Impact** : Ajouter `fixedLocations` à `ProSummaryStruct` impacte-t-il les performances du feed ?

#### Questions Architecture
1. **Single Source of Truth** : Les `fixedLocations` devraient-ils être la seule source pour les markers pros ?
2. **Distance Calculations** : Calculer les distances côté backend ou garder une partie côté client pour l'UX ?
3. **Data Consistency** : Comment garantir la cohérence entre CRM et app pour les localisations ?
4. **Fallback Strategy** : Que faire si `fixedLocations` est vide mais `locationLabel` existe ?

#### Questions Business
1. **User Experience** : Les utilisateurs comprennent-ils la différence entre e principale et zones de travail ?
2. **Data Quality** : Les professionnels remplissent-ils correctement leurs `fixedLocations` dans le CRM ?
3. **Map Performance** : Combien de markers peuvent être affichés simultanément sans dégradation ?

### 📋 **Apprentissages Techniques Clés**

1. **Séparation des responsabilités** : CRM gère, App affiche - éviter la duplication de logique
2. **Single source of truth** : `fixedLocations` > `locationLabel` pour les coordonnées précises
3. **Performance** : Calculs côté backend, pas client - essentiel pour la scalabilité
4. **Scalabilité** : Clustering optimisé pour grandes quantités de markers
5. **Maintenabilité** : Structures de données unifiées pour éviter les incohérences
6. **Data Flow Integrity** : Vérifier chaque étape de transformation des données
7. **Backward Compatibility** : Ajouter des champs optionnels sans casser l'existant

### PROFESSIONAL
- **e principale:** Dans `professional_details`
  - Obligatoire pour tous les pros
  - Siège social ou e principale d'activité

- **es supplémentaires:** Dans `fixed_point`
  - **TRIAL:** 0 e supplémentaire
  - **PREMIUM_VISIBILITY:** Jusqu'à 2 es supplémentaires
  - **ULTIMATE_ACCESS:** Jusqu'à 4 es supplémentaires
  - Chaque e a sa propre zone de couverture

---

## 🔔 **Système d'Alertes - ENTRAIDE COMMUNAUTAIRE**

### Règle Fondamentale
**TOUS les professionnels peuvent créer et voir les alertes (valeur communautaire)**

### Types d'Alertes Structurées
```sql
alert_type ENUM (
  'backup_needed',      -- "Je cherche un remplaçant pour [date]"
  'gear_emergency',     -- "Je cherche à louer [équipement] pour [date]"
  'team_member',        -- "Je cherche un second shooter/assistant pour [date]"
  'emergency_help'      -- "Urgence sur événement, aide immédiate nécessaire"
)
```

### Règles Métier
- **Qui peut créer ?** Tous les pros (Free, Early, Premium, Ultimate)
- **Qui peut voir ?** Tous les pros (pas les brides)
- **Rémunération ?** ❌ Non (entraide communautaire uniquement)
- **Durée de vie :** Jusqu'à `event_date + 1 jour` (auto-expiration)
- **Limite :** 3 alertes actives maximum par pro
- **Réponse :** Bouton "Je peux aider" → Chat direct avec l'auteur

### Pourquoi cette règle?
- Valeur communautaire : entraide entre pros
- Pas de paywall : accessible à tous les pros
- Pas de rémunération : maintient l'esprit d'entraide
- Les brides ne voient pas les alertes (évite saturation)

---

## 💎 **Restrictions par Abonnement - MATRICE MAP**

| Fonctionnalité | Free | Early Access | Premium Visibility | Ultimate Access |
|----------------|------|--------------|-------------------|-----------------|
| **Voir pros sur map** | ✅ | ✅ | ✅ | ✅ |
| **Être visible sur map** | ❌ | ✅ | ✅ | ✅ |
| **Voir alertes** | ✅ | ✅ | ✅ | ✅ |
| **Créer alertes** | ✅ | ✅ | ✅ | ✅ |
| **Voir mariages visibles** | ❌ | ❌ | ✅ | ✅ |
| **Demander contact bride** | ❌ | ❌ | ✅ | ✅ |
| **CRM clients** | ❌ | 5 | 10 | ∞ |
| **Vendor-to-vendor chat** | ❌ | ❌ | ✅ | ✅ |
| **Contrats SignNow** | ❌ | ❌ | ✅ | ✅ |
| **Wedding Slot Exchange** | ❌ | ❌ | ❌ | ✅ |
| **Lead Transfer** | ❌ | ❌ | ❌ | ✅ |

### Règles Clés
- **Pro Free** peut explorer mais n'est pas visible (incitation à payer)
- **Alertes** accessibles à tous (valeur communautaire, pas de paywall)
- **Mariages visibles** réservés Premium+ (fonctionnalité premium)
- **Être visible sur map** nécessite Early Access minimum

---

## 🔄 **État des Demandes de Contact**

### Pour la BRIDE
- **Pending:** En attente de décision (accepter/décliner)
- **Accepted:** Conversation active + Pro devient wedding participant
- **Declined:** Contact refusé

### Pour le PROFESSIONNEL
- **Pending:** En attente de décision (accepter/décliner)
- **Accepted:** Conversation active
- **Declined:** Contact refusé

### Notification System
- **Bride:** "Nouvelle demande de contact de [Prénom Pro.]"
- **Pro:** "Nouvelle demande de contact de [Prénom Bride.]"
- **Email:** Notification email pour les deux parties
- **Push:** Notification push dans l'app

---

## 🗺️ **MiniMap - Comportement**

### Utilisation
La MiniMap est utilisée dans les pages home et certains sheets pour afficher un point de référence statique.

### Comportement
- **Affichage:** 1 seul marker statique (pas interactif)
- **Coordonnées:** Transmises via paramètres au widget
- **Sources possibles:**
  - Position actuelle de l'utilisateur
  - e d'un professionnel
  - Localisation d'un mariage
- **Interaction:** Tap sur la MiniMap → ouvre la mapLarge complète
- **Style:** Simple, sans clustering, sans contrôles de zoom

### Cas d'usage typiques
- **Home Bride:** Affiche la position de l'utilisateur
- **Fiche Pro:** Affiche l'e principale du professionnel
- **Sheet mariage:** Affiche la localisation du mariage

---

## ⚡ **États Transitoires et Cas Limites**

### Suppression Wedding
- **Si demandes en attente:** Notifications envoyées aux pros "Le mariage a été supprimé"
- **Si participants acceptés:** Conversation reste active, statut wedding = 'completed'
- **Markers:** Disparaissent immédiatement de la map

### Downgrade Abonnement Pro
- **Immédiat:** Plus visible sur la map (Free)
- **Mariages visibles:** Plus accès aux mariages visibles
- **Demandes en cours:** Restent actives (pas de rétroactivité)

### Expiration Alerte
- **Auto:** `event_date + 1 jour` → statut = 'expired'
- **Notification:** Email à l'auteur "Votre alerte a expiré"
- **Map:** Plus visible après expiration

### Network Error
- **Tap marker:** Message "Impossible de charger. Réessayer ?"
- **Chargement map:** Skeleton markers + retry automatique après 5s
- **Offline:** Mode dégradé avec cache des derniers markers

### Performance - Cas Limites
- **Max markers par viewport:** 1000 (zoom 15+)
- **Max fixed locations par pro:** 5 (Ultimate), 3 (Premium), 1 (Early)
- **Timeout requête:** 5 secondes avant retry
- **Cache:** 50% de marge autour du viewport pour éviter le flash

---

## ⚠️ **MODIFICATIONS RPC À PRÉVOIR**

### search_map_bundle - Changements requis
**À modifier pendant Phase 1 de la refactorisation:**

```sql
-- Limites par zoom (nouvelles règles)
v_limit_each := CASE
  WHEN p_zoom <= 5 THEN 0      -- Message "Zoomez pour découvrir"
  WHEN p_zoom BETWEEN 6 AND 8 THEN 100   -- Réduit (était 800)
  WHEN p_zoom BETWEEN 9 AND 11 THEN 300  -- Inchangé
  WHEN p_zoom BETWEEN 12 AND 14 THEN 500 -- Augmenté (était 100)
  ELSE 1000                               -- Augmenté (était 50)
END;

-- Remplacer wedding_pins par weddings
-- FROM public.wedding_pins wp
-- ↓
FROM public.weddings w

-- Ajouter alert_type dans les retours
'alertType', a.alert_type,
'title', a.title,
'description', a.description,
'eventDate', a.event_date

-- Supprimer section proRecent (type supprimé)
-- Supprimer section user_pois (POI supprimé)
```

**Impact:** Ces changements sont critiques pour les nouvelles règles d'affichage et le concept Wedding.

---

## 🎨 **Scénarios d'Utilisation Typiques**

### Scénario 1: Mariée cherche photographe
```
1. Marie crée son Wedding (juin 2025, Paris, budget 5000€, photographe recherché)
2. Marie met visibility = 'visible_to_pros'
3. Pierre (photographe Premium) voit le Wedding sur la map
4. Pierre voit: "Sophie D. | Juin 2025 | Paris | Photographe recherché"
5. Pierre clique "Demander contact"
6. Marie reçoit notification et accepte
7. Conversation créée + Pierre devient wedding participant
```

### Scénario 2: Pro contacté via wishlist
```
1. Sophie ajoute Laurent (planner) en wishlist
2. Laurent (Premium Visibility) voit "Sophie D. vous a ajouté en favoris"
3. Laurent initie conversation directement
4. Conversation créée sans demande d'attente
```

### Scénario 3: Alerte d'entraide pro
```
1. David (vidéaste) a un problème: son second shooter est malade pour 15 juin
2. David crée une alerte: type='backup_needed', date=15 juin, lieu=Paris
3. Tous les pros dans la zone voient l'alerte sur la map
4. Marie (photographe) clique "Je peux aider"
5. Chat direct ouvert entre David et Marie
6. L'alerte reste active jusqu'au 16 juin (auto-expiration)
```

### Scénario 3: Collaboration pro-à-pro
```
1. David (vidéaste) cherche photographe pour collaboration
2. David trouve Pierre et envoie demande de contact
3. Pierre accepte la collaboration
4. Conversation professionnelle créée
```

---

## 🐛 **APPRENTISSAGES & BUGS DÉCOUVERTS**

### 📅 **26 Novembre 2025 - Bug Critique Images Portfolio**
**Problème:** Le slider dans les fiches pros n'affichait jamais d'images
**Cause:** Utilisait `slideshow_images` (vide) au lieu de `portfolio_images` (rempli)
**Solution:** Remplir `slideshow_images` avec les mêmes images que `portfolio_images`
**Leçon:** Double structure de données = double maintenance nécessaire

### 📅 **25 Novembre 2025 - Bug Authentification**
**Problème:** "Erreur de session" à la connexion
**Cause:** Permissions manquantes pour roles `authenticated`/`anon` sur schema `public`
**Solution:** Grants SELECT/INSERT/UPDATE/DELETE pour authenticated, SELECT pour anon

### 📅 **26 Novembre 2025 - Migration Google Places API vers SDK Natif**
**Problème:** HTTP REST API contournait les restrictions bundle ID, exposant la clé API
**Solution:** Migration vers `flutter_google_places_sdk` avec validation bundle ID
**Fichiers modifiés:**
- `pubspec.yaml` - Ajout flutter_google_places_sdk: ^0.3.2
- `get_place_predictions.dart` - Utilisation de places.findAutocompletePredictions()
- `get_place_details.dart` - Utilisation de places.fetchPlace() avec PlaceField.LatLng
- `get_place_details_rich.dart` - Utilisation de places.fetchPlace() avec champs enrichis
- `ios/Runner/AppDelegate.swift` - Ajout GooglePlaces import + GMSPlacesClient.provideAPIKey()

**Bundle IDs configurés:**
- iOS: `com.lynewed.app` ✅ (sécurisé avec restrictions)
- Android: `com.lynewed.app` ⚠️ (en attente configuration SHA-1)

**🔧 TODO - Sécurisation Android (quand SHA disponible):**
1. Générer le SHA-1 de la keystore:
   ```bash
   # Pour debug builds:
   keytool -list -v -keystore ~/.android/debug.keystore
   
   # Pour release builds (utiliser la keystore de production):
   keytool -list -v -keystore path/to/production.keystore
   ```
2. Ajouter le SHA-1 dans Google Cloud Console → API Key "Google maps Android"
3. Activer les restrictions "Package names" avec `com.lynewed.app` + SHA-1

**⚠️ PROCÉDURE ROLLBACK (SI BLOCAGE):**
1. Google Cloud Console → APIs & Services → Credentials
2. Google Places API Key → Edit API Key
3. Sous "Application restrictions" → Désactiver "HTTP referrers" et "Package names"
4. Sauvegarder → L'app fonctionnera de nouveau en 30 secondes

**Leçon:** SDK natif requis pour sécurité bundle ID sur mobile

---

## ⚙️ **Guide de Développement - Éviter les Bugs**

### 🖼️ **Gestion des Images Professionnelles**
```dart
// ❌ FAUX - Ne remplit qu'une colonne
UPDATE professional_details SET portfolio_images = [...]

// ✅ CORRECT - Remplir les deux colonnes
UPDATE professional_details 
SET portfolio_images = [...], slideshow_images = [...]
```

### 🔐 **Permissions et RLS**
Toujours vérifier que les roles `authenticated` et `anon` ont les permissions nécessaires sur les nouvelles tables.

### 🎯 **Syntaxe Enums PostgreSQL**
```sql
-- ✅ Toujours utiliser CAST
CAST('ultimateAccess' AS "subscriptionTierType")
```

### 🌍 **Coordonnées PostGIS**
```sql
-- ✅ Format standard obligatoire
ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
```

### 🔄 **Seeding et Triggers**
```sql
-- ✅ Désactiver les triggers problématiques pendant le seeding
ALTER TABLE chat_messages DISABLE TRIGGER trg_on_first_msg_pro_bride;
-- ... faire les insertions ...
ALTER TABLE chat_messages ENABLE TRIGGER trg_on_first_msg_pro_bride;
```

---

## 🗄️ **Storage Buckets & RLS Policies**

### Structure des Buckets Supabase
| Bucket | Public | Usage | Permissions |
|--------|--------|-------|-------------|
| `avatars` | true | Avatars utilisateurs | Authenticated: read/write |
| `portfolio` | true | Portfolio images pros | Authenticated: read/write |
| `chat_images` | false | Images conversation | Participants only |
| `chat-audio` | false | Messages audio | Participants only |
| `chat_attachments` | false | Fichiers conversation | Participants only |
| `public_images` | true | Images publiques générales | Everyone: read |
| `replays` | true | Replays sessions vidéo | Authenticated: read/write |
| `users_profiles` | true | Profils utilisateurs alternatifs | Authenticated: read/write |

### RLS Policies Critiques
```sql
-- Exemple de politique pour avatars
CREATE POLICY "Users can upload own avatar" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Exemple de politique pour portfolio
CREATE POLICY "Pros can manage portfolio" ON storage.objects
FOR ALL USING (
  bucket_id = 'portfolio' AND 
  auth.uid() IN (SELECT profile_id FROM professional_details WHERE profile_id = auth.uid())
);
```

---

## 🔌 **Edge Functions & API Endpoints**

### Fonctions RPC Critiques
**`get_pro_item_details(p_pro_profile_id)`**
- **Input:** UUID du professionnel
- **Output:** JSON complet avec portfolioImages + slideshowImages
- **Permissions:** Authenticated users only

**`get_favorited_professionals()`**
- **Input:** Aucun (utilise auth.uid())
- **Output:** Liste des pros favoris de l'utilisateur
- **Permissions:** Brides only

### Edge Functions Déployées (15)
| Fonction | Usage | CRM Integration |
|----------|-------|-----------------|
| `sync-wed-articles-to-app` | Synchronisation articles | ✅ |
| `sync-professional-to-app` | Sync pro CRM → App | ✅ |
| `create-or-sync-user` | Création/mise à jour user | ✅ |
| `send-verification-email` | Email vérification | ✅ |
| `account_delete` | Suppression compte | ✅ |

**Note:** Toutes les fonctions pointent vers CRM: `pjcorrkwafjskmzmimon`

---

## 📱 **State Management - FFAppState**

### Variables d'État Critiques
```dart
// État utilisateur courant
FFAppState().currentUserRole        // bride | professional
FFAppState().currentUserId          // UUID utilisateur
FFAppState().isAuthenticated        // bool

// État de navigation
FFAppState().currentLocation        // LatLng position
FFAppState().selectedProfession     // filtre profession
FFAppState().searchRadius           // rayon recherche

// État UI
FFAppState().showProOnly           // bool - filtre pros only
FFAppState().selectedWeddingPin    // WeddingPin selectionné
```

### Quand utiliser FFAppState vs Local State
- **FFAppState:** Données partagées entre pages, état utilisateur, filtres globaux
- **Local State:** État temporaire de formulaire, état UI non partagé

---

## 🚨 **FlutterFlow Gotchas - Pièges à Éviter**

### ⚠️ **Code Regeneration Risks**
**Problème:** FlutterFlow peut écraser les modifications manuelles lors de la regénération
**Solution:** Utiliser `custom_code/` pour tout code non-généré

**Fichiers à risque:**
- `pages/*/widget.dart` - Peut être régénéré
- `backend/schema/structs/` - Peut être régénéré
- `actions/actions.dart` - Peut être régénéré

**Safe zones:**
- `custom_code/` - Jamais régénéré
- `compo_finaux/` - Composants personnalisés
- `auth/` - Logique auth personnalisée

### ⚠️ **Data Binding Patterns**
```dart
// ❌ Éviter - Direct binding sans null safety
Text(widget.proDetails!.businessName)

// ✅ Préférer - Safe binding avec fallback
Text(valueOrDefault<String>(
  widget.proDetails?.businessName,
  'Business Name...'
))
```

### ⚠️ **Image Loading Patterns**
```dart
// ❌ Éviter - Pas de gestion d'erreur
Image.network(imageUrl)

// ✅ Préférer - Avec errorBuilder
Image.network(
  imageUrl,
  errorBuilder: (context, error, stackTrace) => 
    Image.asset('assets/images/placeholder.png'),
)
```

---

## 🧪 **Testing Scenarios - Cas de Test Critiques**

### Flux Bride → Professionnel
**Scenario 1: Contact direct depuis ProDetails**
1. Bride se connecte
2. Navigate vers page d'un professionnel
3. Clique sur "Contacter"
4. Vérifie: Conversation créée immédiatement
5. Vérifie: Pro reçoit notification

**Scenario 2: Wishlist → Contact pro**
1. Bride ajoute pro en wishlist
2. Pro (Premium/Ultimate) se connecte
3. Vérifie: Bride visible dans wishlist du pro
4. Pro initie conversation depuis wishlist
5. Vérifie: Conversation créée sans demande d'attente

### Flux Professionnel → Bride
**Scenario 1: Contact via Wedding Pin**
1. Pro crée Wedding Pin public
2. Autre pro consulte la carte
3. Clique "Contacter" depuis le pin
4. Vérifie: Demande de contact créée
5. Bride reçoit notification
6. Bride accepte la demande
7. Vérifie: Conversation créée

### Flux Professionnel → Professionnel
**Scenario 1: Contact pro-à-pro**
1. Pro A consulte la carte
2. Trouve Pro B et clique "Contacter"
3. Vérifie: Demande de contact créée pour Pro B
4. Pro B accepte
5. Vérifie: Conversation professionnelle créée

### Tests de Permissions
**Scenario 1: Trial ne peut pas voir wishlist**
1. Pro Trial se connecte
2. Vérifie: Wishlist vide/indisponible
3. Bride ajoute pro en wishlist
4. Vérifie: Pro Trial ne voit toujours pas la bride

**Scenario 2: Premium/Ultimate voit wishlist**
1. Pro Premium se connecte
2. Bride ajoute pro en wishlist
3. Vérifie: Bride visible dans wishlist
4. Pro peut initier conversation

### Tests Images et Médias
**Scenario 1: Portfolio et Slider fonctionnent**
1. Pro avec portfolio_images et slideshow_images remplis
2. Consulte page ProDetails
3. Vérifie: Slider affiche images (slideshow_images)
4. Vérifie: Grille affiche images (portfolio_images)

**Scenario 2: Gestion d'erreur images**
1. Pro avec URLs images invalides
2. Consulte page ProDetails
3. Vérifie: Placeholder affiché, pas de crash

---

## ⚠️ **Known Limitations - Contraintes Techniques**

### Conception Intentionnelle
**Double structure d'images (portfolio_images + slideshow_images)**
- **Raison:** Flexibilité UI pour différents composants
- **Limitation:** Double maintenance requise
- **Ne pas "fixer" sans:** Refonte complète de l'architecture UI

**Trigger automatique de connection_requests**
- **Raison:** Historique pour compatibilité avec anciennes versions
- **Limitation:** Problématique pendant le seeding
- **Ne pas "fixer" sans:** Validation impact sur flux existants

### Dette Technique Connue
**FlutterFlow Code Generation**
- **Limitation:** Risque d'écraser code personnalisé
- **Workaround:** Utiliser `custom_code/` pour modifications persistantes
- **Future:** Migration vers code Flutter natif planifiée

**PostGIS Performance**
- **Limitation:** Requêtes géospatiales potentiellement lentes avec grand volume
- **Workaround:** Indexes spatiaux déjà en place
- **Future:** Cache local pour requêtes fréquentes

**Supabase Storage URLs**
- **Limitation:** URLs publiques peuvent être bookmarkées/shared
- **Workaround:** RLS policies restrict access via signed URLs
- **Future:** Migration vers CDN avec tokens temporaires

### Scalability Constraints
**Chat Messages en temps réel**
- **Limitation:** Pas de pagination côté client actuellement
- **Workaround:** Nettoyage automatique des vieux messages
- **Future:** Implémentation pagination infinie

**Video Sessions Agora**
- **Limitation:** Coût par minute d'utilisation
- **Workaround:** Limitation durée des sessions
- **Future:** Intégration WebRTC alternative pour sessions courtes

---

## 📝 **Checklist de Développement**

- [ ] Vérifier les permissions RLS pour les nouvelles tables
- [ ] Utiliser la syntaxe CAST correcte pour les enums
- [ ] Maintenir portfolio_images ET slideshow_images synchronisés
- [ ] Désactiver les triggers problématiques pendant le seeding
- [ ] Utiliser le format PostGIS correct pour les coordonnées
- [ ] Tester les flux avec différents rôles et abonnements
- [ ] Vérifier que les buckets Supabase sont correctement configurés

---

**Ce document sert de référence unique pour toute l'application LYNEWED. Toute modification d'architecture ou découverte de bug doit être documentée ici pour maintenir la cohérence de l'équipe de développement.**
