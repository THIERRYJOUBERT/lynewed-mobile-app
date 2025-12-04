# 📱 GUIDE ÉQUIPE APP MOBILE - Refonte Fiche Professionnelle

> **Date** : 04/12/2025  
> **Version** : 1.1  
> **Priorité** : 🔴 HAUTE  
> **Base de données** : `LYNEWED-V1-APP` (Project ID: `hekyovgnovhfhmkpfrna`)

---

## 📋 RÉSUMÉ EXÉCUTIF

Ce document détaille les modifications que l'équipe App Mobile doit implémenter suite à la refonte de la section "Fiche Pro" dans le CRM.

### Modifications côté Backend/CRM

| Modification | Description | Impact App |
|--------------|-------------|------------|
| **Vidéo YouTube/Vimeo** | `profile_video_url` contient maintenant des URLs YouTube/Vimeo | L'app doit utiliser un player YouTube/Vimeo |
| **Structure Mixte** | Nouvelle colonne `has_cover_video` | L'app doit adapter l'affichage |
| **Coordonnées précises** | Les coordonnées sont maintenant précises (Google Places) | Meilleure dispersion sur la map |
| **Upcoming Travels** (Phase 2) | Nouvelle table `professional_upcoming_travels` | L'app doit afficher les disponibilités |

### Modifications à implémenter

| # | Fonctionnalité | Priorité | Complexité | Estimation |
|---|----------------|----------|------------|------------|
| 1 | Lecteur vidéo YouTube/Vimeo pour fiches pro | 🔴 Haute | Faible | 1-2h |
| 2 | Logique d'affichage vidéo vs photos | 🔴 Haute | Faible | 1h |
| 3 | Affichage Upcoming Travels (Phase 2) | 🟡 Moyenne | Moyenne | 2-3h |

---

## 1️⃣ LECTEUR VIDÉO YOUTUBE/VIMEO - FICHES PROFESSIONNELLES

### Contexte

Les professionnels peuvent maintenant ajouter des **liens vidéo YouTube/Vimeo** dans leur fiche depuis le CRM. Ces liens sont stockés dans la colonne `profile_video_url` de la table `professional_details`.

### ⚠️ CHANGEMENT IMPORTANT

**AVANT** : Les vidéos étaient uploadées dans Supabase Storage :
```
https://pjcorrkwafjskmzmimon.supabase.co/storage/v1/object/public/professional_profiles/xxx.mp4
```

**APRÈS** : Les vidéos sont des liens YouTube/Vimeo :
```
https://youtube.com/watch?v=VIDEO_ID
https://youtu.be/VIDEO_ID
https://vimeo.com/VIDEO_ID
```

### Structure des données

**Table : `professional_details`**

| Colonne | Type | Description |
|---------|------|-------------|
| `profile_video_url` | text | URL YouTube ou Vimeo (ou NULL si pas de vidéo) |
| `has_cover_video` | boolean | **NOUVEAU** - `true` si le pro veut afficher la vidéo en couverture |

### Détection du type d'URL

```dart
bool isYouTubeUrl(String url) {
  return url.contains('youtube.com') || url.contains('youtu.be');
}

bool isVimeoUrl(String url) {
  return url.contains('vimeo.com');
}

bool isVideoUrl(String url) {
  return isYouTubeUrl(url) || isVimeoUrl(url);
}

// Extraction de l'ID vidéo
String? extractYouTubeId(String url) {
  final regex = RegExp(
    r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})'
  );
  final match = regex.firstMatch(url);
  return match?.group(1);
}

String? extractVimeoId(String url) {
  final regex = RegExp(r'vimeo\.com\/(\d+)');
  final match = regex.firstMatch(url);
  return match?.group(1);
}
```

### Implémentation Flutter

#### 1. Réutiliser le `VideoPlayerWidget` existant

Si vous avez déjà créé le `VideoPlayerWidget` pour le Wedding of the Week (voir `GUIDE_EQUIPE_APP_MOBILE.md`), vous pouvez le réutiliser directement.

#### 2. Modifier le widget de fiche professionnelle

```dart
Widget _buildProCover(ProfessionalDetails details) {
  // Vérifier si le pro a une vidéo ET veut l'afficher en couverture
  if (details.hasCoverVideo == true && 
      details.profileVideoUrl != null && 
      details.profileVideoUrl!.isNotEmpty &&
      isVideoUrl(details.profileVideoUrl!)) {
    
    return AspectRatio(
      aspectRatio: 1, // Carré pour la couverture
      child: VideoPlayerWidget(
        videoUrl: details.profileVideoUrl!,
        autoPlay: true,
        loop: true,
        showControls: false,
      ),
    );
  }
  
  // Sinon, afficher le slider de photos (portfolio_images)
  return _buildPhotoSlider(details.portfolioImages);
}
```

#### 3. Logique d'affichage complète

```dart
Widget _buildProfessionalProfile(ProfessionalDetails details) {
  return Column(
    children: [
      // HAUT DE LA FICHE
      if (details.hasCoverVideo == true && details.profileVideoUrl != null)
        // Option 1: Vidéo en couverture
        _buildVideoCover(details.profileVideoUrl!)
      else
        // Option 2: Slider 4 photos (portfolio_images)
        _buildPhotoSlider(details.portfolioImages),
      
      // BAS DE LA FICHE - Toujours 4 photos cliquables
      _buildThumbnailGrid(details.portfolioImages),
      
      // ALBUM - Accessible en cliquant sur les thumbnails
      // slideshow_images contient l'album complet (5-15 photos)
    ],
  );
}

Widget _buildVideoCover(String videoUrl) {
  return AspectRatio(
    aspectRatio: 1,
    child: VideoPlayerWidget(
      videoUrl: videoUrl,
      autoPlay: true,
      loop: true,
      showControls: false,
    ),
  );
}

Widget _buildPhotoSlider(List<String> images) {
  // Slider horizontal des 4 premières images
  return SizedBox(
    height: 300,
    child: PageView.builder(
      itemCount: images.take(4).length,
      itemBuilder: (context, index) {
        return Image.network(
          images[index],
          fit: BoxFit.cover,
        );
      },
    ),
  );
}

Widget _buildThumbnailGrid(List<String> images) {
  // Grille 2x2 des 4 photos
  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
    ),
    itemCount: 4,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () => _openFullscreenGallery(context, index),
        child: Image.network(
          images[index],
          fit: BoxFit.cover,
        ),
      );
    },
  );
}
```

---

## 2️⃣ NOUVELLE COLONNE `has_cover_video`

### Description

Une nouvelle colonne `has_cover_video` (boolean) a été ajoutée à la table `professional_details`. Elle indique si le professionnel souhaite afficher sa vidéo en couverture de sa fiche.

### Valeurs possibles

| `has_cover_video` | `profile_video_url` | Affichage |
|-------------------|---------------------|-----------|
| `true` | URL valide | Vidéo en couverture |
| `true` | NULL ou vide | Slider photos (fallback) |
| `false` | N'importe | Slider photos |
| `NULL` | N'importe | Slider photos (défaut) |

### Mise à jour du modèle Dart

```dart
class ProfessionalDetails {
  final String profileId;
  final String businessName;
  final String? description;
  final List<String> portfolioImages;
  final List<String> slideshowImages;
  final String? profileVideoUrl;
  final bool? hasCoverVideo;  // NOUVEAU
  final String profession;
  // ... autres champs

  factory ProfessionalDetails.fromJson(Map<String, dynamic> json) {
    return ProfessionalDetails(
      profileId: json['profile_id'],
      businessName: json['business_name'],
      description: json['description'],
      portfolioImages: List<String>.from(json['portfolio_images'] ?? []),
      slideshowImages: List<String>.from(json['slideshow_images'] ?? []),
      profileVideoUrl: json['profile_video_url'],
      hasCoverVideo: json['has_cover_video'],  // NOUVEAU
      profession: json['profession'],
      // ...
    );
  }
}
```

---

## 3️⃣ NOUVEAU FORMAT DES IMAGES (IMPORTANT)

### ⚠️ CHANGEMENT MAJEUR

**AVANT** : Les images étaient stockées en un seul format, l'app faisait le crop.

**APRÈS** : Chaque image est stockée en **4 versions** (original + 3 crops). L'app doit utiliser la bonne version selon le contexte.

### Nouvelle structure des données

Les colonnes `portfolio_images` et `slideshow_images` contiennent maintenant des **objets JSON** au lieu de simples URLs :

```dart
// AVANT (ancien format - à supporter pour rétrocompatibilité)
List<String> portfolioImages = [
  "https://xxx.supabase.co/storage/v1/object/public/professional_profiles/photo1.jpg",
  "https://xxx.supabase.co/storage/v1/object/public/professional_profiles/photo2.jpg",
];

// APRÈS (nouveau format)
List<PhotoWithCrops> portfolioImages = [
  {
    "id": "abc123",
    "order": 0,
    "original": "https://xxx.supabase.co/.../photo-1-original.jpg",
    "crops": {
      "square": "https://xxx.supabase.co/.../photo-1-square.jpg",
      "vertical": "https://xxx.supabase.co/.../photo-1-vertical.jpg",
      "fullscreen": "https://xxx.supabase.co/.../photo-1-fullscreen.jpg"
    }
  },
  // ...
];
```

### Modèle Dart à créer

```dart
class PhotoWithCrops {
  final String id;
  final int order;
  final String original;
  final PhotoCrops crops;

  PhotoWithCrops({
    required this.id,
    required this.order,
    required this.original,
    required this.crops,
  });

  factory PhotoWithCrops.fromJson(Map<String, dynamic> json) {
    return PhotoWithCrops(
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      original: json['original'] ?? '',
      crops: PhotoCrops.fromJson(json['crops'] ?? {}),
    );
  }
  
  // Rétrocompatibilité : si c'est juste une string (ancien format)
  factory PhotoWithCrops.fromLegacyUrl(String url, int index) {
    return PhotoWithCrops(
      id: 'legacy_$index',
      order: index,
      original: url,
      crops: PhotoCrops(
        square: url,      // Fallback: utiliser l'original
        vertical: url,
        fullscreen: url,
      ),
    );
  }
}

class PhotoCrops {
  final String square;     // 1:1 - pour thumbnails
  final String vertical;   // 3:4 - pour slideshow
  final String fullscreen; // 9:16 - pour vue plein écran

  PhotoCrops({
    required this.square,
    required this.vertical,
    required this.fullscreen,
  });

  factory PhotoCrops.fromJson(Map<String, dynamic> json) {
    return PhotoCrops(
      square: json['square'] ?? '',
      vertical: json['vertical'] ?? '',
      fullscreen: json['fullscreen'] ?? '',
    );
  }
}
```

### Parser les images (avec rétrocompatibilité)

```dart
List<PhotoWithCrops> parseImages(dynamic imagesData) {
  if (imagesData == null) return [];
  
  final List<dynamic> imagesList = imagesData is List ? imagesData : [];
  
  return imagesList.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    
    // Nouveau format : objet avec crops
    if (item is Map<String, dynamic> && item.containsKey('crops')) {
      return PhotoWithCrops.fromJson(item);
    }
    
    // Ancien format : simple URL string
    if (item is String) {
      return PhotoWithCrops.fromLegacyUrl(item, index);
    }
    
    // Format intermédiaire : objet avec juste 'path'
    if (item is Map<String, dynamic> && item.containsKey('path')) {
      final url = item['path'] as String;
      return PhotoWithCrops.fromLegacyUrl(url, index);
    }
    
    return null;
  }).whereType<PhotoWithCrops>().toList();
}
```

### Utilisation selon le contexte

| Contexte d'affichage | Propriété à utiliser | Ratio |
|---------------------|----------------------|-------|
| Grille thumbnails (2x2) | `photo.crops.square` | 1:1 |
| Slider en haut de fiche | `photo.crops.vertical` | 3:4 |
| Clic sur photo → fullscreen | `photo.crops.fullscreen` | 9:16 |
| Téléchargement/partage | `photo.original` | Original |

### Widgets mis à jour

```dart
Widget _buildThumbnailImage(PhotoWithCrops photo) {
  return AspectRatio(
    aspectRatio: 1, // Carré 1:1
    child: Image.network(
      photo.crops.square,  // Utiliser le crop carré
      fit: BoxFit.cover,
    ),
  );
}

Widget _buildSlideshowImage(PhotoWithCrops photo) {
  return AspectRatio(
    aspectRatio: 3/4, // Vertical 3:4
    child: Image.network(
      photo.crops.vertical,  // Utiliser le crop vertical
      fit: BoxFit.cover,
    ),
  );
}

Widget _buildFullscreenImage(PhotoWithCrops photo) {
  return AspectRatio(
    aspectRatio: 9/16, // Vertical 9:16
    child: Image.network(
      photo.crops.fullscreen,  // Utiliser le crop fullscreen
      fit: BoxFit.cover,
    ),
  );
}
```

---

## 4️⃣ COORDONNÉES GPS PRÉCISES

### Contexte

Les coordonnées GPS des professionnels sont maintenant plus précises grâce à l'intégration de **Google Places API** dans le CRM (04/12/2025).

### Impact

- **Avant** : Tous les pros de "Paris" étaient au même point (centre ville)
- **Après** : Chaque pro a des coordonnées précises (adresse exacte)

### ⚠️ CHANGEMENT IMPORTANT (04/12/2025)

**Colonne `location_coords` supprimée de `professional_details`**

Les coordonnées ne sont plus stockées dans `professional_details.location_coords`. Toutes les localisations sont maintenant dans la table `professional_fixed_locations`.

### Table concernée

**`professional_fixed_locations`** (seule source de vérité pour les locations) :

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | uuid | Identifiant unique |
| `professional_profile_id` | uuid | FK vers profiles |
| `label` | text | Adresse complète (ex: "15 Rue de Rivoli, 75001 Paris, France") |
| `location_coords` | geometry | Coordonnées GPS au format WKB (`POINT(lng lat)`) |
| `location_country_code` | text | Code pays ISO (ex: "FR", "US") |
| `created_at` | timestamptz | Date de création |

### Recommandation pour les adresses

> 💡 **Conseil** : Encouragez les professionnels à saisir des adresses précises (rue, numéro) plutôt que juste le nom de la ville. Cela évite que plusieurs pros soient au même point sur la carte.

### Migration requise côté App

Si votre code utilisait `professional_details.location_coords`, vous devez maintenant utiliser `professional_fixed_locations` :

```dart
// AVANT (ne fonctionne plus)
final coords = professionalDetails.locationCoords;

// APRÈS
final locations = await supabase
  .from('professional_fixed_locations')
  .select()
  .eq('professional_profile_id', profileId);

final primaryLocation = locations.isNotEmpty ? locations.first : null;
final coords = primaryLocation?['location_coords'];
```

---

## 5️⃣ UPCOMING TRAVELS (PHASE 2)

> ⚠️ **Note** : Cette fonctionnalité sera implémentée en Phase 2. Ce document sera mis à jour avec les détails d'implémentation.

### Objectif

Permettre aux couples de voir les déplacements futurs des professionnels et de les contacter s'ils seront dans leur région à une date donnée.

### Nouvelle table : `professional_upcoming_travels`

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | uuid | Identifiant unique |
| `professional_profile_id` | uuid | FK vers profiles |
| `location_label` | text | Adresse/ville du déplacement |
| `location_city` | text | Ville |
| `location_country_code` | text | Code pays ISO |
| `location_coords` | geometry | Coordonnées GPS |
| `start_date` | date | Date de début |
| `end_date` | date | Date de fin |

### Affichage proposé

```dart
Widget _buildUpcomingTravels(List<UpcomingTravel> travels) {
  if (travels.isEmpty) return SizedBox.shrink();
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Upcoming Travels',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      ...travels.map((travel) => _buildTravelCard(travel)),
    ],
  );
}

Widget _buildTravelCard(UpcomingTravel travel) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.flight_takeoff, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.locationLabel,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${formatDate(travel.startDate)} → ${formatDate(travel.endDate)}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

---

## 📋 CHECKLIST D'IMPLÉMENTATION

### Phase 1 : Vidéo YouTube/Vimeo (Priorité haute)

- [ ] Vérifier que `VideoPlayerWidget` existe (sinon le créer)
- [ ] Ajouter la détection d'URL YouTube/Vimeo
- [ ] Modifier l'affichage de la couverture de fiche pro
- [ ] Ajouter le champ `hasCoverVideo` au modèle `ProfessionalDetails`
- [ ] Implémenter la logique d'affichage vidéo vs photos
- [ ] Tester avec des URLs YouTube et Vimeo

### Phase 2 : Upcoming Travels (À venir)

- [ ] Créer le modèle `UpcomingTravel`
- [ ] Ajouter la requête pour récupérer les travels
- [ ] Créer le widget d'affichage
- [ ] Intégrer dans la fiche pro
- [ ] Intégrer dans les filtres de recherche

---

## 🧪 TESTS À EFFECTUER

### Lecteur Vidéo

1. Fiche pro avec vidéo YouTube + `has_cover_video = true` → Doit afficher la vidéo
2. Fiche pro avec vidéo Vimeo + `has_cover_video = true` → Doit afficher la vidéo
3. Fiche pro avec vidéo + `has_cover_video = false` → Doit afficher le slider photos
4. Fiche pro sans vidéo → Doit afficher le slider photos
5. Fiche pro avec URL invalide → Doit fallback sur le slider photos

### Formats d'images

1. Thumbnails affichés en carré 1:1
2. Slideshow affiché en 3:4
3. Fullscreen affiché en 9:16

---

## 📊 DONNÉES DE TEST

### Profil avec vidéo YouTube

```sql
UPDATE professional_details 
SET 
  profile_video_url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  has_cover_video = true
WHERE profile_id = 'xxx';
```

### Profil avec vidéo Vimeo

```sql
UPDATE professional_details 
SET 
  profile_video_url = 'https://vimeo.com/123456789',
  has_cover_video = true
WHERE profile_id = 'xxx';
```

### Profil sans vidéo en couverture

```sql
UPDATE professional_details 
SET 
  profile_video_url = 'https://www.youtube.com/watch?v=xxx',
  has_cover_video = false  -- La vidéo existe mais n'est pas affichée en couverture
WHERE profile_id = 'xxx';
```

---

## 📞 CONTACT

Pour toute question sur ces modifications :
- **CRM / Backend** : Équipe Web
- **Base de données** : Supabase Project ID `hekyovgnovhfhmkpfrna`

---

## 6️⃣ MIGRATION COMPLÈTE DES LOCALISATIONS (04/12/2025)

> **⚠️ CHANGEMENT MAJEUR** : Cette section documente la migration de `professional_details.location_coords` vers `professional_fixed_locations` uniquement.

### 📋 CONTEXTE ET OBJECTIF

#### Situation AVANT (ancienne logique)

```
professional_details
├── location_coords (geometry)     ← "Based At" = localisation principale
├── location_country_code (text)   ← Code pays principal
└── location_label (text)          ← Label de la localisation principale

professional_fixed_locations
├── location_coords (geometry)     ← Localisations additionnelles (1 à 5)
├── location_country_code (text)
└── label (text)
```

**Problème** : Duplication de données, logique complexe, le "Based At" n'apportait pas de valeur ajoutée.

#### Situation APRÈS (nouvelle logique)

```
professional_details
├── location_country_code (text)   ← Code pays principal (synchronisé depuis CRM)
└── location_label (text)          ← Label (optionnel, pour affichage)
                                   ❌ location_coords SUPPRIMÉ

professional_fixed_locations       ← SEULE SOURCE DE VÉRITÉ pour les coordonnées
├── location_coords (geometry)     ← 1 à 5 localisations par pro
├── location_country_code (text)   ← Code pays de chaque localisation
└── label (text)                   ← Adresse complète (Google Places)
```

**Avantages** :
- Un pro peut avoir **1 à 5 localisations** (selon son plan)
- Chaque localisation apparaît sur la map comme un **point distinct**
- Plus de duplication de données
- Coordonnées précises grâce à Google Places API

---

### � FONCTIONS RPC MODIFIÉES

#### 1. `search_map_bundle` - Affichage sur la Map

**AVANT** :
```
Section 1) "Pros live" → Affiche UN marker par pro à pd.location_coords
Section 2) "Fixed locations" → Affiche des markers additionnels
```

**APRÈS** :
```
Section 1) "Pros live" → ❌ SUPPRIMÉE
Section 2) "Fixed locations" → Affiche TOUS les markers (1 à 5 par pro)
```

**Impact pour l'équipe App** :
- Chaque pro apparaît sur la map à **chacune de ses localisations**
- Un pro avec 3 localisations = 3 points sur la map
- Le type de marker reste `'fixedLocation'` avec `profileId` dans `styleInfo`
- Quand l'utilisateur clique sur un marker, il faut **mémoriser quelle localisation** a été cliquée (voir section `get_pro_item_details`)

**Données retournées par marker** :
```json
{
  "id": "uuid-de-la-fixed-location",
  "type": "fixedLocation",
  "position": {"type": "Point", "coordinates": [lng, lat]},
  "styleInfo": {
    "avatarUrl": "https://...",
    "borderColorHex": "#FF5733",
    "profileId": "uuid-du-pro",
    "locationLabel": "15 Rue de Rivoli, 75001 Paris, France"
  }
}
```

---

#### 2. `get_feed_professionals` - Feed des Professionnels

**AVANT** :
```sql
-- Filtre sur la localisation principale
ST_DWithin(pd.location_coords::geography, v_center::geography, v_radius_km*1000)

-- Calcul de distance pour le tri
ST_Distance(pd.location_coords::geography, v_center::geography) AS distance_meters
```

**APRÈS** :
```sql
-- Filtre : le pro est affiché si AU MOINS UNE de ses fixed_locations est dans le radius
EXISTS (
  SELECT 1 FROM professional_fixed_locations pfl
  WHERE pfl.professional_profile_id = pd.profile_id
    AND ST_DWithin(pfl.location_coords::geography, v_center::geography, v_radius_km*1000)
)

-- Calcul de distance pour le tri : distance vers la PLUS PROCHE fixed_location
(
  SELECT MIN(ST_Distance(pfl.location_coords::geography, v_center::geography))
  FROM professional_fixed_locations pfl
  WHERE pfl.professional_profile_id = pd.profile_id
) AS distance_meters
```

**Logique métier** :
1. Si l'utilisateur cherche à **Paris** et le pro a une localisation à Paris → **AFFICHÉ**
2. Si l'utilisateur cherche à **Marseille** et le pro a une localisation à Marseille → **AFFICHÉ**
3. Si l'utilisateur cherche à **Paris ET Marseille** et le pro a les 2 localisations → **AFFICHÉ UNE SEULE FOIS**
4. Si le pro a 5 localisations dont 3 correspondent au filtre → **AFFICHÉ UNE SEULE FOIS**

**⚠️ IMPORTANT - Pas de doublons** :
Le pro apparaît **UNE SEULE FOIS** dans le feed, même si plusieurs de ses localisations correspondent au filtre. La requête retourne un seul enregistrement par `profile_id`.

**⚠️ IMPORTANT - Tri par distance** :
Le feed trie les pros par distance. La distance utilisée est celle vers la **plus proche** `fixed_location` du pro (pas la moyenne, pas la première).

**Impact pour l'équipe App** :
- Aucun changement côté App pour le feed
- La logique de dédoublonnage est gérée côté base de données
- Les photos du pro apparaissent une seule fois
- Le champ `distanceKm` retourné correspond à la distance vers la plus proche localisation

---

#### 3. `get_portfolio_feed` - Feed des Photos (Explore)

**Même logique que `get_feed_professionals`** :
- Un pro est affiché si **au moins une** de ses `fixed_locations` correspond au filtre
- Chaque photo apparaît **une seule fois** même si le pro a plusieurs localisations correspondantes

---

#### 4. `get_pro_item_details` - Fiche Détaillée du Pro

**AVANT** :
```sql
-- Récupère la localisation principale + les fixed_locations (sans ID ni label)
v_all_locations := [pd.location_coords] + [professional_fixed_locations]

-- Format retourné (incomplet)
{"type": "Point", "coordinates": [lng, lat]}
```

**APRÈS** :
```sql
-- Récupère UNIQUEMENT les fixed_locations AVEC ID et label
SELECT jsonb_agg(
  jsonb_build_object(
    'id', fl.id,
    'label', fl.label,
    'type', 'Point',
    'coordinates', jsonb_build_array(ST_X(fl.location_coords), ST_Y(fl.location_coords))
  )
)
FROM professional_fixed_locations fl
WHERE fl.professional_profile_id = p_pro_profile_id
```

**Données retournées (NOUVEAU FORMAT)** :
```json
{
  "fixedLocations": [
    {
      "id": "uuid-location-1",
      "label": "15 Rue de Rivoli, 75001 Paris, France",
      "type": "Point",
      "coordinates": [2.3522, 48.8566]
    },
    {
      "id": "uuid-location-2",
      "label": "25 Cours Mirabeau, 13100 Aix-en-Provence, France",
      "type": "Point",
      "coordinates": [5.3698, 43.2965]
    }
  ]
}
```

**⚠️ LOGIQUE D'AFFICHAGE POUR L'ÉQUIPE APP** :

| Scénario | Localisation à afficher en priorité |
|----------|-------------------------------------|
| L'utilisateur a cliqué sur un marker de la map | Afficher la localisation du marker cliqué |
| L'utilisateur vient du feed (pas de marker cliqué) | Afficher la **première** `fixedLocation` |
| Le pro n'a aucune `fixedLocation` | Ne pas afficher de map (cas rare) |

**Implémentation suggérée** :

```dart
class ProDetailsScreen extends StatelessWidget {
  final String proProfileId;
  final String? clickedLocationId; // ID de la fixed_location cliquée (optionnel)
  
  Widget build(BuildContext context) {
    // Récupérer les détails du pro
    final proDetails = await getProItemDetails(proProfileId);
    
    // Déterminer quelle localisation afficher
    LatLng displayedLocation;
    
    if (clickedLocationId != null) {
      // L'utilisateur a cliqué sur un marker spécifique
      displayedLocation = findLocationById(proDetails.fixedLocations, clickedLocationId);
    } else {
      // Fallback: première localisation
      displayedLocation = proDetails.fixedLocations.isNotEmpty 
        ? proDetails.fixedLocations.first 
        : null;
    }
    
    return Column(
      children: [
        // ... autres widgets
        if (displayedLocation != null)
          MiniMap(center: displayedLocation),
      ],
    );
  }
}
```

**Passage du `clickedLocationId`** :

Quand l'utilisateur clique sur un marker de la map, passez l'ID de la `fixed_location` :

```dart
// Dans la map, au clic sur un marker
onMarkerTap: (marker) {
  if (marker.type == 'fixedLocation') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProDetailsScreen(
          proProfileId: marker.styleInfo['profileId'],
          clickedLocationId: marker.id, // ID de la fixed_location
        ),
      ),
    );
  }
}
```

---

#### 5. `get_favorited_professionals` - Liste des Favoris

**AVANT** :
```sql
'fixedLocations', CASE 
  WHEN pd.location_coords IS NOT NULL THEN
    [pd.location_coords] + [professional_fixed_locations]
  ELSE
    [professional_fixed_locations]
END

-- Format : [{"lat": 48.8566, "lng": 2.3522}, ...]
```

**APRÈS** :
```sql
'fixedLocations', (
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', fl.id,
      'label', fl.label,
      'lat', ST_Y(fl.location_coords),
      'lng', ST_X(fl.location_coords)
    )
  )
  FROM professional_fixed_locations fl
  WHERE fl.professional_profile_id = pd.profile_id
)

-- Format : [{"id": "uuid", "label": "Adresse", "lat": 48.8566, "lng": 2.3522}, ...]
```

**Impact pour l'équipe App** :
- `fixedLocations` contient maintenant **uniquement** les `professional_fixed_locations`
- Plus de "localisation principale" distincte
- Chaque localisation inclut maintenant `id` et `label` pour l'affichage

---

### 🗑️ ÉLÉMENTS SUPPRIMÉS

#### 1. Fonction `move_first_fixed_to_main_location`

**Ce qu'elle faisait** : Copiait la première `fixed_location` vers `professional_details.location_coords` quand celle-ci était vide ou invalide (0,0).

**Pourquoi supprimée** : Avec la nouvelle logique, `professional_details.location_coords` n'existe plus. Toutes les localisations sont dans `professional_fixed_locations`.

#### 2. Trigger `trigger_auto_populate_country_code`

**Ce qu'il faisait** : Calculait automatiquement `location_country_code` à partir de `location_coords` via reverse geocoding.

**Pourquoi supprimé** : Le `location_country_code` est maintenant synchronisé directement depuis le CRM (table `profiles.location_country_code`). Pas besoin de le calculer.

#### 3. Colonne `professional_details.location_coords`

**Ce qu'elle contenait** : Les coordonnées GPS de la "localisation principale" (Based At).

**Pourquoi supprimée** : Remplacée par `professional_fixed_locations`. Un pro a maintenant 1 à 5 localisations, toutes égales.

---

### 📊 STRUCTURE FINALE DES TABLES

#### `professional_details` (après migration)

| Colonne | Type | Description |
|---------|------|-------------|
| `profile_id` | uuid | PK, FK vers profiles |
| `business_name` | text | Nom du studio/entreprise |
| `profession` | enum | Type de profession |
| `location_label` | text | Label d'affichage (optionnel) |
| `location_country_code` | text | Code pays principal (sync CRM) |
| `is_live` | boolean | Profil visible sur l'app |
| ... | ... | Autres colonnes inchangées |
| ~~`location_coords`~~ | ~~geometry~~ | ❌ **SUPPRIMÉE** |

#### `professional_fixed_locations` (inchangée, devient la source unique)

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | uuid | PK |
| `professional_profile_id` | uuid | FK vers profiles |
| `label` | text | Adresse complète (Google Places) |
| `location_coords` | geometry | Coordonnées GPS `POINT(lng lat)` |
| `location_country_code` | text | Code pays ISO (FR, US, etc.) |
| `created_at` | timestamptz | Date de création |

**Index existant** : `professional_fixed_locations_location_coords_idx` (GIST) pour les requêtes géographiques.

---

### 🔄 SYNCHRONISATION CRM → APP

#### Flux de données

```
CRM (profiles.locations)
    ↓
Edge Function (create-or-sync-user)
    ↓
APP (professional_fixed_locations)
```

#### Format des données CRM

```json
{
  "locations": {
    "additional": [
      "15 Rue de Rivoli, 75001 Paris, France",
      "25 Cours Mirabeau, 13100 Aix-en-Provence, France"
    ],
    "plan": "ultimate"
  }
}
```

#### Traitement par l'Edge Function

1. Supprime toutes les `fixed_locations` existantes du pro
2. Pour chaque adresse dans `additional[]` :
   - Géocode l'adresse via Nominatim
   - Insère dans `professional_fixed_locations`
3. Synchronise `location_country_code` depuis `profiles.location_country_code` du CRM

---

### ✅ CHECKLIST ÉQUIPE APP

#### Modifications requises

- [ ] **Map** : Mémoriser l'ID de la `fixed_location` cliquée pour le passer à la fiche pro
- [ ] **Fiche Pro** : Afficher la localisation cliquée OU la première `fixed_location` par défaut
- [ ] **Fiche Pro** : Utiliser le nouveau format `fixedLocations` avec `id`, `label`, `coordinates`
- [ ] **Modèle Dart** : Mettre à jour le modèle `FixedLocation` pour inclure `id` et `label`
- [ ] **Modèle Dart** : Supprimer toute référence à `professional_details.location_coords`
- [ ] **Feed** : Aucun changement (le dédoublonnage est géré côté DB)
- [ ] **Favoris** : Adapter au nouveau format `fixedLocations` avec `id` et `label`

#### Tests à effectuer

1. **Map** : Un pro avec 3 localisations doit avoir 3 markers distincts
2. **Map → Fiche** : Cliquer sur le marker de Paris → la fiche affiche Paris avec le bon label
3. **Map → Fiche** : Cliquer sur le marker de Marseille → la fiche affiche Marseille avec le bon label
4. **Feed → Fiche** : Venir du feed → la fiche affiche la première localisation
5. **Feed** : Un pro avec 3 localisations dans le radius n'apparaît qu'une fois
6. **Favoris** : Les `fixedLocations` sont correctement affichées avec leurs labels
7. **Distance** : Le `distanceKm` affiché correspond à la plus proche localisation

---

### 📞 QUESTIONS FRÉQUENTES

**Q: Que se passe-t-il si un pro n'a aucune `fixed_location` ?**
A: Il n'apparaît pas sur la map. C'est un cas rare car le CRM oblige à saisir au moins une localisation.

**Q: Comment savoir quelle localisation afficher dans la fiche pro ?**
A: Si l'utilisateur vient de la map, utilisez l'ID du marker cliqué. Sinon, utilisez la première `fixed_location`.

**Q: Le `location_country_code` de `professional_details` est-il toujours utilisé ?**
A: Oui, pour le filtrage par marché (Europe, Inde, etc.). Il est synchronisé depuis le CRM.

**Q: Pourquoi ne pas utiliser la première `fixed_location` comme "principale" ?**
A: Toutes les localisations sont égales. L'ordre est basé sur `created_at` mais n'a pas de signification métier.

---

## 📜 HISTORIQUE

| Date | Version | Changement |
|------|---------|------------|
| 03/12/2025 | 1.0 | Création du document |
| 04/12/2025 | 1.1 | Ajout `has_cover_video`, intégration Google Places |
| 04/12/2025 | 1.2 | **MIGRATION MAJEURE** : Suppression `location_coords` de `professional_details`, migration vers `professional_fixed_locations` uniquement |

---

## 🔧 MIGRATIONS APPLIQUÉES (04/12/2025)

Les migrations suivantes ont été appliquées sur la base de données `LYNEWED-V1-APP` (hekyovgnovhfhmkpfrna) :

| # | Migration | Description | Status |
|---|-----------|-------------|--------|
| 1 | `migration_step1_search_map_bundle_remove_pros_section` | Suppression section "Pros live", pros affichés uniquement via fixed_locations | ✅ OK |
| 2 | `migration_step2_get_feed_professionals_use_fixed_locations` | Filtre et distance basés sur professional_fixed_locations | ✅ OK |
| 3 | `migration_step3_get_portfolio_feed_use_fixed_locations` | Filtre géographique basé sur professional_fixed_locations | ✅ OK |
| 4 | `migration_step4_get_pro_item_details_use_fixed_locations` | fixedLocations avec id et label, suppression pd.location_coords | ✅ OK |
| 5 | `migration_step5_get_favorited_professionals_use_fixed_locations` | fixedLocations avec id et label | ✅ OK |
| 6 | `migration_step6_drop_move_first_fixed_to_main_location` | Suppression fonction obsolète | ✅ OK |
| 7 | `migration_step7_drop_auto_populate_country_code_trigger` | Suppression trigger (country_code sync depuis CRM) | ✅ OK |
| 8 | `migration_step8_drop_location_coords_from_professional_details` | **Suppression colonne location_coords** | ✅ OK |

### Fonctions modifiées

| Fonction | Changement principal |
|----------|---------------------|
| `search_map_bundle` | Section "Pros live" supprimée, tous les pros via fixed_locations |
| `get_feed_professionals` | `EXISTS` + `MIN(distance)` sur fixed_locations |
| `get_portfolio_feed` | `EXISTS` sur fixed_locations pour filtre géographique |
| `get_pro_item_details` | `fixedLocations` inclut maintenant `id` et `label` |
| `get_favorited_professionals` | `fixedLocations` inclut maintenant `id` et `label` |

### Éléments supprimés

| Élément | Type | Raison |
|---------|------|--------|
| `move_first_fixed_to_main_location` | Fonction | Obsolète (plus de location principale) |
| `trigger_move_first_fixed_after_insert` | Fonction trigger | Obsolète |
| `trigger_auto_populate_country_code` | Trigger | country_code sync depuis CRM |
| `professional_details.location_coords` | Colonne | Remplacée par professional_fixed_locations |
