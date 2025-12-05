# 📱 GUIDE ÉQUIPE APP - SYSTÈME MULTI-FORMAT IMAGES

> **Version**: 3.0
> **Date**: 04/12/2025 16:20
> **Statut**: ✅ IMPLÉMENTÉ + NOUVELLES COLONNES V2

---

## 🎯 RÉSUMÉ

Le CRM génère maintenant **4 versions** de chaque photo uploadée :
- `original.jpg` - Image originale (backup)
- `crop_1x1.jpg` - Format carré (500x500) pour header slider
- `crop_3x4.jpg` - Format vertical (600x800) pour grille portfolio
- `crop_9x16.jpg` - Format fullscreen (450x800) pour vue détaillée

---

## ⚠️ IMPACT POUR L'ÉQUIPE APP

### MODIFICATION REQUISE POUR LE FULLSCREEN !

L'APP a maintenant accès à **2 formats de colonnes** :

#### 1. Colonnes LEGACY (backward compatible)
```
slideshow_images: text[]   -- URLs du crop 1:1 (carré)
portfolio_images: text[]   -- URLs du crop 3:4 (vertical)
```
Ces colonnes continuent de fonctionner comme avant.

#### 2. NOUVELLES Colonnes V2 (avec tous les formats)
```
slideshow_images_v2: jsonb  -- Header photos avec tous les crops
portfolio_images_v2: jsonb  -- Portfolio photos avec tous les crops
```

### Format des colonnes V2

```json
[
  {
    "id": "abc-123-uuid",
    "crop_1x1": "https://.../.../crop_1x1.jpg",
    "crop_3x4": "https://.../.../crop_3x4.jpg",
    "crop_9x16": "https://.../.../crop_9x16.jpg"
  },
  {
    "id": "def-456-uuid",
    "crop_1x1": "https://.../.../crop_1x1.jpg",
    "crop_3x4": "https://.../.../crop_3x4.jpg",
    "crop_9x16": "https://.../.../crop_9x16.jpg"
  }
]
```

---

## 📂 STRUCTURE STORAGE

```
professional_profiles/
└── {user_id}/
    ├── slideshow/                    # Header photos (max 4)
    │   └── {uuid}/
    │       ├── original.jpg
    │       ├── crop_1x1.jpg          ← Envoyé à l'APP
    │       ├── crop_3x4.jpg
    │       └── crop_9x16.jpg
    │
    └── portfolio/                    # Portfolio photos (5-15)
        └── {uuid}/
            ├── original.jpg
            ├── crop_1x1.jpg
            ├── crop_3x4.jpg          ← Envoyé à l'APP
            └── crop_9x16.jpg
```

---

## 📊 FORMAT DB (CRM)

### Nouveau format `PhotoWithCrops`

```typescript
interface PhotoWithCrops {
  id: string;           // UUID unique
  order: number;        // Position dans la liste
  original: string;     // Path vers original
  crop_1x1: string;     // Path vers crop carré
  crop_3x4: string;     // Path vers crop vertical
  crop_9x16: string;    // Path vers crop fullscreen
}
```

### Colonnes CRM `profiles`

```sql
slideshow_photos: jsonb  -- Header (max 4 photos)
portfolio_photos: jsonb  -- Portfolio (5-15 photos)
```

---

## 🔄 SYNC CRM → APP

La sync extrait le bon crop selon le contexte :

| Colonne CRM | Colonne APP | Crop utilisé |
|-------------|-------------|--------------|
| `slideshow_photos` | `slideshow_images` | `crop_1x1` (carré) |
| `portfolio_photos` | `portfolio_images` | `crop_3x4` (vertical) |

### Exemple de données reçues par l'APP

```json
{
  "slideshow_images": [
    "https://pjcorrkwafjskmzmimon.supabase.co/.../slideshow/abc-123/crop_1x1.jpg",
    "https://pjcorrkwafjskmzmimon.supabase.co/.../slideshow/def-456/crop_1x1.jpg"
  ],
  "portfolio_images": [
    "https://pjcorrkwafjskmzmimon.supabase.co/.../portfolio/ghi-789/crop_3x4.jpg",
    "https://pjcorrkwafjskmzmimon.supabase.co/.../portfolio/jkl-012/crop_3x4.jpg"
  ]
}
```

---

## 🎯 UTILISATION DANS L'APP (Flutter)

### Où utiliser quel format ?

| Écran | Colonne à utiliser | Format affiché | Au clic → Fullscreen |
|-------|-------------------|----------------|----------------------|
| **Header Slider** (profil pro) | `slideshow_images_v2` | `crop_1x1` (carré) | `crop_9x16` |
| **Portfolio Grid** (profil pro) | `portfolio_images_v2` | `crop_3x4` (vertical) | `crop_9x16` |
| **Feed** (liste des pros) | `portfolio_images_v2` | `crop_3x4` (vertical) | `crop_9x16` |

### ⚠️ IMPORTANT : Toutes les photos peuvent s'ouvrir en 9:16 !

Que la photo soit affichée en **1:1** (header) ou **3:4** (grille), quand l'utilisateur tape dessus, elle doit **TOUJOURS** s'ouvrir en **9:16** (fullscreen).

### Exemple Flutter : Header Slider (1:1 → 9:16 au clic)

```dart
// Header slider avec photos carrées
final List<dynamic> slideshowV2 = professionalDetails['slideshow_images_v2'] ?? [];

PageView.builder(
  itemCount: slideshowV2.length,
  itemBuilder: (context, index) {
    final photo = slideshowV2[index];
    return GestureDetector(
      onTap: () => _openFullscreen(photo),
      child: Image.network(photo['crop_1x1']),  // Affiche 1:1 (carré)
    );
  },
);
```

### Exemple Flutter : Portfolio Grid (3:4 → 9:16 au clic)

```dart
// Grille portfolio avec photos verticales
final List<dynamic> portfolioV2 = professionalDetails['portfolio_images_v2'] ?? [];

GridView.builder(
  itemCount: portfolioV2.length,
  itemBuilder: (context, index) {
    final photo = portfolioV2[index];
    return GestureDetector(
      onTap: () => _openFullscreen(photo),
      child: Image.network(photo['crop_3x4']),  // Affiche 3:4 (vertical)
    );
  },
);
```

### Fonction commune : Ouvrir en Fullscreen (9:16)

```dart
// Même fonction pour TOUTES les photos (header OU portfolio)
void _openFullscreen(Map<String, dynamic> photo) {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => FullscreenImage(
      imageUrl: photo['crop_9x16'],  // TOUJOURS 9:16 en fullscreen
      photoId: photo['id'],
    ),
  ));
}
```

### Matching par ID

L'`id` est le même dans les 3 crops, ce qui permet de :
- Cliquer sur une photo 3:4 dans la grille
- Ouvrir la même photo en 9:16 en fullscreen
- Naviguer entre les photos en fullscreen tout en gardant la correspondance

---

## 🔮 MIGRATION RECOMMANDÉE POUR L'APP

### Étape 1 : Utiliser les colonnes V2

Remplacer progressivement :
- `slideshow_images` → `slideshow_images_v2`
- `portfolio_images` → `portfolio_images_v2`

### Étape 2 : Adapter le code Flutter

```dart
// AVANT (legacy)
final images = details['portfolio_images'] as List<String>;
Image.network(images[0]);

// APRÈS (v2 avec fullscreen)
final imagesV2 = details['portfolio_images_v2'] as List<dynamic>;
final photo = imagesV2[0];
Image.network(photo['crop_3x4']);  // Grille
// Puis au clic:
Image.network(photo['crop_9x16']); // Fullscreen
```

---

## ✅ CHECKLIST IMPLÉMENTATION

### CRM (fait)
- [x] Modal de crop dans CRM (3 formats)
- [x] Upload 4 versions vers Storage
- [x] Nouveau format `PhotoWithCrops` en DB CRM
- [x] Edge Function sync avec colonnes V2
- [x] Backward compatible avec ancien format

### APP (à faire par l'équipe APP)
- [ ] Utiliser `slideshow_images_v2` pour le header slider
- [ ] Utiliser `portfolio_images_v2` pour la grille portfolio
- [ ] Utiliser `portfolio_images_v2` pour le feed
- [ ] Implémenter le fullscreen avec `crop_9x16`
- [ ] Tester le matching par ID

---

## 📊 RÉSUMÉ TECHNIQUE

| Base de données | Table | Colonnes |
|-----------------|-------|----------|
| **CRM** (pjcorrkwafjskmzmimon) | `profiles` | `slideshow_photos`, `portfolio_photos` (jsonb) |
| **APP** (hekyovgnovhfhmkpfrna) | `professional_details` | `slideshow_images_v2`, `portfolio_images_v2` (jsonb) |

---

## 📞 CONTACT

Questions ? Contacter l'équipe CRM.
