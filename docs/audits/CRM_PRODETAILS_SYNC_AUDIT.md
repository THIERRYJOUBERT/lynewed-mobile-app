# 📋 AUDIT - Synchronisation CRM ↔ App Mobile (Fiche Pro)

**Version:** 1.2  
**Date:** 2025-12-04  
**Statut:** ✅ IMPLÉMENTÉ - Build validé, en attente tests CRM  
**Priorité:** 🔴 HAUTE

---

## 📊 RÉSUMÉ EXÉCUTIF

Cet audit documente les modifications CRM à synchroniser avec l'app Flutter et suit leur implémentation.

### État Global

| # | Modification | Backend | Frontend | Priorité | Statut |
|---|--------------|---------|----------|----------|--------|
| 1 | **`hasCoverVideo` + Vidéo YouTube/Vimeo** | ✅ Prêt | ✅ Implémenté | 🔴 Haute | ✅ Terminé |
| 2 | **`fixedLocations` avec id/label** | ✅ Retourné par RPC | ✅ FixedLocationStruct créé | 🔴 Haute | ✅ Terminé |
| 3 | **Upcoming Travels UI** | ❌ Table absente | ✅ UI stub créé | 🟡 Moyenne | ✅ Terminé |
| 4 | **Format images crops** | ❌ Pas déployé | ❌ Non implémenté | ⏳ Attente | ⏸️ Bloqué CRM |

### Légende Statuts
- ⬜ À faire
- 🔄 En cours
- ✅ Terminé
- ⏸️ Bloqué

---

## 🔍 AUDIT DÉTAILLÉ

### 1. Vidéo YouTube/Vimeo + `hasCoverVideo`

#### État Backend (Vérifié 2025-12-04)

| Élément | Statut | Détails |
|---------|--------|---------|
| Colonne `has_cover_video` | ✅ Existe | `boolean`, nullable |
| Colonne `profile_video_url` | ✅ Existe | `text`, nullable |
| RPC `get_pro_item_details` | ✅ Retourne `hasCoverVideo` | Ligne 127 du RPC |
| Données de test | ⚠️ Aucun pro avec `has_cover_video=true` | 0 pros actuellement |
| URLs vidéo existantes | ✅ 5 pros avec YouTube/Vimeo URLs | Mais `has_cover_video=false` |

#### État Frontend (✅ IMPLÉMENTÉ 2025-12-04)

| Fichier | Statut |
|---------|--------|
| `ProDetailsStruct` | ✅ Champ `hasCoverVideo` ajouté |
| `get_pro_item_details_action.dart` | ✅ Parse `hasCoverVideo` |
| `pro_details_widget.dart` | ✅ Utilise `hasCoverVideo` + `VideoUrlHelpers` |
| `YoutubePlayerWidget` | ✅ Réutilisé pour YouTube |
| `VideoplayerFilmmaker` | ✅ Fallback pour .mp4 directs |

#### Logique Implémentée (✅ Correcte)
```dart
// pro_details_widget.dart - Méthodes _shouldShowVideo() et _buildVideoPlayer()
bool _shouldShowVideo() {
  if (!proDetails.hasCoverVideo) return false;
  if (proDetails.profileVideoUrl.isEmpty) return false;
  return VideoUrlHelpers.isValidVideoUrl(proDetails.profileVideoUrl);
}

Widget _buildVideoPlayer() {
  if (VideoUrlHelpers.isYouTubeUrl(videoUrl)) 
    return YoutubePlayerWidget(...);
  if (VideoUrlHelpers.isVimeoUrl(videoUrl)) 
    return VimeoPlaceholder(); // Phase 2
  return VideoplayerFilmmaker(...); // .mp4 fallback
}
```

---

### 2. Format Images avec Crops

#### État Backend (Vérifié 2025-12-04)

```sql
-- Résultat de la vérification
portfolio_images = text[]  -- Format simple, PAS d'objets JSON
first_element_type = "string"
sample = "https://picsum.photos/seed/..."
```

**Conclusion:** ⏸️ **Le nouveau format avec crops n'est PAS encore déployé côté CRM/Backend**

#### Action
- **Aucune implémentation pour l'instant**
- Préparer le code avec rétrocompatibilité quand le CRM déploiera
- Documenter le format attendu pour référence future

#### Format Attendu (Futur)
```json
{
  "id": "abc123",
  "order": 0,
  "original": "https://xxx.supabase.co/.../photo-1-original.jpg",
  "crops": {
    "square": "https://xxx.supabase.co/.../photo-1-square.jpg",
    "vertical": "https://xxx.supabase.co/.../photo-1-vertical.jpg",
    "fullscreen": "https://xxx.supabase.co/.../photo-1-fullscreen.jpg"
  }
}
```

---

### 3. FixedLocations avec id/label

#### État Backend (Vérifié 2025-12-04)

Le RPC `get_pro_item_details` retourne maintenant:
```json
{
  "fixedLocations": [
    {
      "id": "uuid-location-1",
      "label": "15 Rue de Rivoli, 75001 Paris, France",
      "type": "Point",
      "coordinates": [2.3522, 48.8566]
    }
  ]
}
```

#### État Frontend (✅ IMPLÉMENTÉ 2025-12-04)

| Fichier | Statut |
|---------|--------|
| `FixedLocationStruct` | ✅ Créé avec id, label, lat, lng |
| `get_pro_item_details_action.dart` | ✅ Parse toujours `List<LatLng>` (rétrocompatible) |
| `ProDetailsStruct` | ✅ Garde `List<LatLng>` pour compatibilité |
| `ProfessionalDetails` (map module) | ✅ Inchangé |

#### Code Implémenté
```dart
// lib/backend/schema/structs/fixed_location_struct.dart
class FixedLocationStruct extends BaseStruct {
  String? id;
  String? label;
  double? latitude;
  double? longitude;
  
  LatLng toLatLng() => LatLng(latitude, longitude); // Rétrocompatibilité
  
  static FixedLocationStruct? fromGeoJson(dynamic data) {
    // Parse id, label, coordinates depuis format GeoJSON
  }
}
```

**Note:** Le struct est prêt pour usage futur. Le parsing actuel reste `List<LatLng>` pour ne pas casser le code existant.

---

### 4. Upcoming Travels

#### État Backend (Vérifié 2025-12-04)

```sql
SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'professional_upcoming_travels');
-- Result: false
```

**Table n'existe pas encore.**

#### État Frontend (✅ IMPLÉMENTÉ 2025-12-04)

| Fichier | Statut |
|---------|--------|
| `UpcomingTravelsSheet` | ✅ Créé avec Design System v3 |
| `professional_details_sheet.dart` | ✅ Bouton ajouté dans section Links |
| `pro_details_widget.dart` | ✅ Bouton ajouté à côté Instagram/Website |

#### Implémentation
- **Sheet:** `lib/features/map/presentation/sheets/upcoming_travels_sheet.dart`
- **Style:** Empty state avec icône avion, message "No upcoming travels", badge "Coming soon"
- **Bouton:** Icône `flight_takeoff` dans les deux pages

#### Action restante
- ⏳ Attendre que le dev CRM crée la table `professional_upcoming_travels`
- Quand prêt: Implémenter le fetch et l'affichage des données

---

## 🎯 PLAN D'IMPLÉMENTATION CHALLENGÉ

### ⚠️ Points Challengés

1. **`FixedLocationStruct` vs modification simple** 
   - **Décision:** Créer un nouveau struct est plus propre et réutilisable
   - **Risque:** Impact sur le code existant qui utilise `List<LatLng>`
   - **Mitigation:** Ajouter méthode `toLatLng()` pour rétrocompatibilité

2. **Vidéo: YouTube vs Vimeo vs .mp4**
   - **Constat:** `YoutubePlayerWidget` existe → ✅ Réutiliser pour YouTube
   - **Constat:** `VideoplayerFilmmaker` existe MAIS ne supporte PAS YouTube/Vimeo (fichiers .mp4 uniquement)
   - **Constat:** Vimeo nécessite un widget différent (webview ou package dédié)
   - **Décision:** Phase 1 = YouTube uniquement via `YoutubePlayerWidget`, Vimeo en Phase 2 si besoin

3. **Upcoming Travels: Où placer le sheet?**
   - **Option A:** `lib/features/pro_details/` (nouveau module)
   - **Option B:** `lib/features/map/presentation/sheets/` (avec les autres sheets pro)
   - **Décision:** Option B - cohérent avec `professional_details_sheet.dart`

4. **`pro_details_widget.dart` = code FlutterFlow legacy**
   - **Constat:** Ce fichier utilise `FlutterFlowTheme`, pas le Design System
   - **Décision:** Modifications minimales pour cette tâche, refactorisation complète en tâche séparée

---

### Phase 1: Modèles et Parsing (1.5h) 🔴

| # | Tâche | Fichier | Statut |
|---|-------|---------|--------|
| 1.1 | Créer `FixedLocationStruct` | `lib/backend/schema/structs/fixed_location_struct.dart` | ✅ |
| 1.2 | Exporter dans index | `lib/backend/schema/structs/index.dart` | ✅ |
| 1.3 | Ajouter `hasCoverVideo` à `ProDetailsStruct` | `lib/backend/schema/structs/pro_details_struct.dart` | ✅ |
| 1.4 | Modifier parsing `get_pro_item_details_action` | `lib/custom_code/actions/get_pro_item_details_action.dart` | ✅ |
| 1.5 | Ajouter `hasCoverVideo` à `ProfessionalDetails` (map) | `lib/features/map/domain/entities/professional_details.dart` | ✅ |

### Phase 2: Logique Vidéo (1h) 🔴

| # | Tâche | Fichier | Statut |
|---|-------|---------|--------|
| 2.1 | Créer helpers vidéo URL | `lib/core/utils/video_url_helpers.dart` | ✅ |
| 2.2 | Modifier logique affichage vidéo | `lib/pages/shared/pro_details/pro_details_widget.dart` | ✅ |

### Phase 3: Upcoming Travels UI (1.5h) 🟡

| # | Tâche | Fichier | Statut |
|---|-------|---------|--------|
| 3.1 | Créer `UpcomingTravelsSheet` (Design System) | `lib/features/map/presentation/sheets/upcoming_travels_sheet.dart` | ✅ |
| 3.2 | Ajouter bouton dans `ProfessionalDetailsSheet` | `lib/features/map/presentation/sheets/professional_details_sheet.dart` | ✅ |
| 3.3 | Ajouter bouton dans `pro_details_widget.dart` | `lib/pages/shared/pro_details/pro_details_widget.dart` | ✅ |

### Phase 4: Tests et Validation (30min)

| # | Tâche | Statut |
|---|-------|--------|
| 4.1 | Build et test compilation | ✅ |
| 4.2 | flutter analyze (0 erreurs) | ✅ |
| 4.3 | Build iOS Simulator | ✅ |
| 4.4 | Test navigation vers ProDetails | ✅ Validé par utilisateur |
| 4.5 | Test Upcoming Travels sheet | ✅ Validé par utilisateur |
| 4.6 | Test vidéo YouTube | ⏳ En attente CRM (`has_cover_video=true`) |

### Pour chaque phase terminée:
1. **Build:** `@[/build-and-run-app-simulator]` (exécute `scripts/build_and_run.sh`)
2. **Analyzer:** `flutter analyze` (vérifier les erreurs statiques)
3. **Test:** Navigation Map → ProDetails
4. **Mise à jour audit:** Marquer les tâches ✅ dans `docs/audits/CRM_PRODETAILS_SYNC_AUDIT.md`

---

## 📁 FICHIERS

### Nouveaux Fichiers à Créer

| Fichier | Description | Design System |
|---------|-------------|---------------|
| `lib/backend/schema/structs/fixed_location_struct.dart` | Struct avec id, label, lat, lng | N/A |
| `lib/core/utils/video_url_helpers.dart` | Helpers YouTube/Vimeo URL | N/A |
| `lib/features/map/presentation/sheets/upcoming_travels_sheet.dart` | Sheet placeholder | ✅ `LynewedSheet` |

### Fichiers à Modifier

| Fichier | Modifications |
|---------|---------------|
| `lib/backend/schema/structs/pro_details_struct.dart` | + `hasCoverVideo` |
| `lib/backend/schema/structs/index.dart` | + export `fixed_location_struct.dart` |
| `lib/custom_code/actions/get_pro_item_details_action.dart` | Parser `hasCoverVideo` + `fixedLocations` avec id/label |
| `lib/pages/shared/pro_details/pro_details_widget.dart` | Logique vidéo + bouton Upcoming Travels |
| `lib/features/map/domain/entities/professional_details.dart` | + `hasCoverVideo` |
| `lib/features/map/presentation/sheets/professional_details_sheet.dart` | + bouton Upcoming Travels |

---

## 🎬 ANALYSE WIDGETS VIDÉO EXISTANTS

### Widgets Disponibles

| Widget | Package | Supporte | Adapté ProDetails? |
|--------|---------|----------|-------------------|
| `YoutubePlayerWidget` | `youtube_player_flutter` | YouTube uniquement | ✅ OUI |
| `VideoplayerFilmmaker` | `video_player` | Fichiers .mp4 directs | ❌ NON (pas YouTube/Vimeo) |

### Détails Techniques

**`YoutubePlayerWidget`** (`lib/custom_code/widgets/youtube_player_widget.dart`)
- ✅ Extrait automatiquement l'ID vidéo via `YoutubePlayer.convertUrlToId()`
- ✅ AutoPlay, barre de progression, HD forcé
- ⚠️ Utilise `FlutterFlowTheme` (à migrer vers Design System si refactorisé)
- ✅ **RÉUTILISABLE pour ProDetails**

**`VideoplayerFilmmaker`** (`lib/custom_code/widgets/videoplayer_filmmaker.dart`)
- ❌ Utilise `VideoPlayerController.networkUrl()` = fichiers directs uniquement
- ❌ **NE PEUT PAS lire YouTube/Vimeo**
- ✅ Muet, boucle, autoplay (style background video)

### Décision Vidéo

| Type URL | Widget à Utiliser | Action |
|----------|-------------------|--------|
| YouTube (`youtube.com`, `youtu.be`) | `YoutubePlayerWidget` | ✅ Réutiliser |
| Vimeo (`vimeo.com`) | ❌ Aucun existant | ⏳ Phase 2 (webview ou package) |
| Fichier direct (`.mp4`) | `VideoplayerFilmmaker` | ✅ Réutiliser (fallback) |

---

## 🎨 DESIGN SYSTEM - RÈGLES OBLIGATOIRES

### ⚠️ RÈGLES CRITIQUES (À TOUJOURS RESPECTER)

| Règle | Valeur | Contexte |
|-------|--------|----------|
| **Font Weight Max** | w500 | Tous les textes (sauf exceptions documentées) |
| **Border Radius Items** | 4px | Chips, cards, list items, inputs |
| **Border Radius Sheets** | 24px | Top corners des bottom sheets uniquement |
| **Divider Color** | `gray200` (0xFFD9D9D9) | Tous les dividers |
| **Cibles Tactiles** | 44px min | Boutons, icônes interactives |
| **Spacing Sections** | 30px | Entre sections dans sheets/pages |
| **Spacing Label→Content** | 10px | Entre titre de section et contenu |
| **Boutons Hauteur** | 48px | Tous les boutons |
| **Boutons Radius** | 0px | Carrés (pas arrondis) |

### Import Obligatoire
```dart
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
```

### Widgets Design System à Utiliser

| Widget | Usage |
|--------|-------|
| `LynewedSheet` | Wrapper bottom sheet (handle bar, header, divider) |
| `LynewedButton` | Boutons (primary, secondary, ghost, destructive) |
| `LynewedSectionTitle` | Titres de section (16px, w500) |
| `LynewedInfoRow` | Ligne info avec icône |
| `LynewedLocationRow` | Location + distance |
| `LynewedChip` | Chips sélectionnables (radius 4px, w300) |

### Structure Sheet Standard
```dart
LynewedSheet(
  title: 'Sheet Title',           // sheetTitle + fontSize 20
  onClose: () => Navigator.pop(), // Close icon à droite
  bottomAction: LynewedButton(...),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section 1
      const LynewedSectionTitle(title: 'Section 1'),
      // Contenu...
      const SizedBox(height: 30), // Entre sections
      
      // Section 2
      const LynewedSectionTitle(title: 'Section 2'),
      // Contenu...
    ],
  ),
)
```

### Sheets Validés (Références)
- `lib/features/map/presentation/sheets/alert_create_sheet.dart` - Pattern form
- `lib/features/map/presentation/sheets/professional_details_sheet.dart` - Pattern détails
- `lib/features/chat/presentation/sheets/blocked_users_sheet.dart` - Pattern liste

---

## ⚠️ POINTS D'ATTENTION

### 1. Rétrocompatibilité
- `FixedLocationStruct` doit avoir une méthode `toLatLng()` pour compatibilité
- Le parsing doit gérer l'ancien format (juste coordonnées) ET le nouveau (avec id/label)

### 2. Données de Test
- Aucun pro n'a `has_cover_video=true` actuellement
- Demander au dev CRM de configurer le compte Tom Berthet pour tester

### 3. Format Images (Futur)
- Ne PAS implémenter maintenant
- Garder en tête pour quand le CRM déploiera

### 4. `pro_details_widget.dart` = Code FlutterFlow Legacy
- ⚠️ Ce fichier utilise `FlutterFlowTheme`, pas le Design System
- **Pour cette tâche:** Modifications minimales (logique vidéo + bouton Upcoming Travels)
- **Refactorisation complète:** Tâche séparée (priorité "ProDetails - Refonte Complète")
- Quand on refactorisera, créer `lib/features/pro_details/` avec Clean Architecture

### 5. Widgets Vidéo
- `YoutubePlayerWidget` = ✅ Réutilisable pour YouTube
- `VideoplayerFilmmaker` = ❌ NE SUPPORTE PAS YouTube/Vimeo (fichiers .mp4 uniquement)
- Vimeo = ⏳ Nécessite nouveau widget (Phase 2 si besoin)

---

## 📝 HISTORIQUE DES VALIDATIONS

| Date | Phase | Tâches | Validé par |
|------|-------|--------|------------|
| 2025-12-04 | Audit | Analyse complète backend/frontend | Cascade |
| 2025-12-04 | 1.1 | `FixedLocationStruct` créé | Cascade |
| 2025-12-04 | 1.2 | Export ajouté | Cascade |
| 2025-12-04 | 1.3 | `hasCoverVideo` ajouté à `ProDetailsStruct` | Cascade |
| 2025-12-04 | 1.4 | Parsing mis à jour | Cascade |
| 2025-12-04 | 1.5 | `ProfessionalDetails` mis à jour | Cascade |
| 2025-12-04 | 2.1 | Helpers vidéo créés | Cascade |
| 2025-12-04 | 2.2 | Logique vidéo modifiée | Cascade |
| 2025-12-04 | 3.1 | `UpcomingTravelsSheet` créé | Cascade |
| 2025-12-04 | 3.2 | Bouton ajouté dans sheet map | Cascade |
| 2025-12-04 | 3.3 | Bouton ajouté dans ProDetails | Cascade |
| 2025-12-04 | 4.1 | Build validé (flutter analyze) | Cascade |
| 2025-12-04 | 4.2 | Build iOS Simulator réussi | Cascade |
| 2025-12-04 | 4.3 | Correction enums obsolètes dans tests | Cascade |
| 2025-12-04 | 4.4 | Nettoyage archives (backups code supprimés) | Cascade |
| 2025-12-04 | 4.5 | Validation utilisateur (ProDetails + Upcoming Travels) | Utilisateur |

---

## 🔗 RÉFÉRENCES

- **Doc CRM:** `docs/GUIDE_EQUIPE_APP_MOBILE_FICHE_PRO.md`
- **Design System:** `docs/App/DESIGN_SYSTEM.md` v3.0
- **Widgets Design:** `lib/core/design/widgets/`
- **Sheets Validés (à s'inspirer):** 
  - `lib/features/map/presentation/sheets/alert_create_sheet.dart` - Pattern form
  - `lib/features/map/presentation/sheets/professional_details_sheet.dart` - Pattern détails
  - `lib/features/chat/presentation/sheets/blocked_users_sheet.dart` - Pattern liste

---

## 📌 NOTES POUR LE DEV CRM

1. **Test vidéo:** Configurer `has_cover_video=true` sur le compte Tom Berthet
2. **Format images crops:** Notifier quand déployé en prod
3. **Upcoming Travels:** Notifier quand la table sera créée

---

**Estimation totale:** 4.5 heures  
**Temps réel:** ~3 heures  
**Dernière mise à jour:** 2025-12-04 12:28

---

## ✅ RÉSUMÉ FINAL

### Fichiers Créés
| Fichier | Description |
|---------|-------------|
| `lib/backend/schema/structs/fixed_location_struct.dart` | Struct avec id, label, lat, lng + `toLatLng()` |
| `lib/core/utils/video_url_helpers.dart` | Détection YouTube/Vimeo/MP4 |
| `lib/features/map/presentation/sheets/upcoming_travels_sheet.dart` | Sheet placeholder Design System v3 |

### Fichiers Modifiés
| Fichier | Modifications |
|---------|---------------|
| `lib/backend/schema/structs/index.dart` | Export `FixedLocationStruct` |
| `lib/backend/schema/structs/pro_details_struct.dart` | + `hasCoverVideo` |
| `lib/custom_code/actions/get_pro_item_details_action.dart` | Parse `hasCoverVideo` |
| `lib/features/map/domain/entities/professional_details.dart` | + `hasCoverVideo` |
| `lib/features/map/presentation/sheets/professional_details_sheet.dart` | + bouton Upcoming Travels |
| `lib/pages/shared/pro_details/pro_details_widget.dart` | Logique vidéo + bouton Upcoming Travels |

### En Attente CRM
1. **Test vidéo:** Configurer `has_cover_video=true` sur un compte test
2. **Format images crops:** Notifier quand déployé
3. **Upcoming Travels:** Créer table `professional_upcoming_travels`
