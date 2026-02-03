# EPIC-10-PHOTOS-VIDEOS

> Resume : Enrichir la galerie existante avec support video, legendes, et albums guests visibles par la bride
> Status : 🟢 Ready
> Domaine : Features / Media / Storage
> Cree le : 2026-01-28
> MAJ : 2026-02-03

---

## Contexte

### Pourquoi cet Epic

Cet Epic **enrichit** les fonctionnalites de galerie existantes pour supporter les videos, les legendes, et creer un systeme d'albums pour les guests automatiquement visibles par la bride.

**Etat actuel verifie en production (Supabase MCP 2026-02-03):**

| Element | Etat actuel | Contenu |
|---------|-------------|---------|
| `inspiration_albums` | ✅ Existe | 6 rows - Albums bride avec categories |
| `album_images` | ✅ Existe | 5 rows - Photos uploadees (PAS de videos, PAS de legendes) |
| `saved_posts` | ✅ Existe | 4 rows - Photos sauvees depuis feed |
| `guest_albums` | ❌ N'existe pas | Table a creer |
| `guest_media` | ❌ N'existe pas | Table a creer |
| Bucket `wedding-albums` | ✅ Existe (public) | Utilise pour albums bride |

**Colonnes manquantes dans album_images:**
- `media_type` (photo/video)
- `caption` (legende max 500 chars)
- `duration_seconds` (pour videos)
- `file_size_bytes`

**UI existante:**
- `AlbumDetailPage` : Grille photos bride avec upload FAB
- `GuestAlbumPage` : Placeholder empty state (pret pour EPIC-10)
- `GuestHomePage` : Navigation 3 tabs (Album, Messages, Settings)

### Dependances

| Dependance | Epic | Status | Impact |
|------------|------|--------|--------|
| Systeme guest | EPIC-09 | ✅ COMPLETE | Guests peuvent se connecter |
| Enum `userRole` avec `guest` | EPIC-06 | ✅ COMPLETE | Role guest disponible |

### Decisions Cles (2026-02-03)

| Decision | Choix | Raison |
|----------|-------|--------|
| **Storage** | Reutiliser `wedding-albums` | Pas de creation manuelle, bride accede a tout |
| **Partage guest→bride** | Automatique (pas d'opt-in) | Simplicite UX, guests uploadent, bride voit |
| **gallery_access_logs** | Supprime | Pas necessaire V1 |
| **print_ready** | Supprime | Futur, pas maintenant |

---

## Architecture Cible

### Structure de Stockage

```
Bucket: wedding-albums (EXISTANT - public)
└── {wedding_id}/
    ├── bride/
    │   └── {filename}          # Medias de la bride (existant)
    └── guests/
        └── {guest_user_id}/
            └── {filename}      # Medias du guest
```

### Schema de Donnees

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SCHEMA PHOTOS & VIDEOS (APP-04)                           │
│                                                                              │
│  album_images (ENRICHIR - existante)                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id, album_id, image_url, thumbnail_url, uploaded_at (existants)     │   │
│  │  + media_type VARCHAR(10) DEFAULT 'photo' CHECK (photo|video)        │   │
│  │  + caption TEXT CHECK (length <= 500)                                │   │
│  │  + duration_seconds INTEGER (pour videos)                            │   │
│  │  + file_size_bytes BIGINT                                            │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  guest_albums (NOUVELLE)                                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  wedding_id UUID REFERENCES weddings(id)                             │   │
│  │  guest_user_id UUID REFERENCES profiles(id)                          │   │
│  │  created_at TIMESTAMPTZ                                              │   │
│  │  UNIQUE(wedding_id, guest_user_id)  ← 1 album par guest par mariage │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  guest_media (NOUVELLE)                                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  id UUID PRIMARY KEY                                                 │   │
│  │  album_id UUID REFERENCES guest_albums(id) ON DELETE CASCADE         │   │
│  │  media_type VARCHAR(10) CHECK (photo|video)                          │   │
│  │  storage_path TEXT NOT NULL                                          │   │
│  │  thumbnail_path TEXT                                                 │   │
│  │  caption TEXT CHECK (length <= 500)                                  │   │
│  │  duration_seconds INTEGER (pour videos)                              │   │
│  │  file_size_bytes BIGINT                                              │   │
│  │  created_at TIMESTAMPTZ                                              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Limites de Fichiers

| Type | Limite | Raison |
|------|--------|--------|
| **Photo** | 20 MB max | Qualite suffisante |
| **Video duree** | 10 minutes max | Eviter abus storage |
| **Video taille** | 500 MB max | Balance qualite/cout |
| **Legende** | 500 caracteres max | UX concise |
| **Formats video** | mp4, mov, m4v | Standards iOS/Android |

---

## Stories (8)

| # | Story | Domaine | Dep. | Description | Complexite |
|---|-------|---------|------|-------------|------------|
| S01 | Enrichir album_images | DB | - | Ajouter media_type, caption, duration, file_size | S |
| S02 | Creer guest_albums + RLS | DB | - | Table avec 1 album/guest/wedding, RLS | S |
| S03 | Creer guest_media + RLS | DB | S02 | Table medias guest avec contraintes | S |
| S04 | UI Upload media - Bride | Flutter | S01 | Support video dans AlbumDetailPage | M |
| S05 | UI Saisie legende | Flutter | S01 | CaptionInput widget 500 chars | S |
| S06 | UI Upload media - Guest | Flutter | S02,S03 | GuestAlbumPage fonctionnel | M |
| S07 | UI Bride vue albums guests | Flutter | S02,S03 | Nouvelle page liste albums guests | M |
| S08 | Download media | Flutter | S01-S03 | Download single + multiple (zip) | M |

---

## Detail des Stories

### S01 : Enrichir album_images pour video + legendes

**Fichier** : `stories/S01-enrich-album-images.md`

**Objectif** : Ajouter le support video et legendes a la table existante.

**Colonnes a ajouter** :
- `media_type VARCHAR(10) DEFAULT 'photo'` avec CHECK (photo|video)
- `caption TEXT` avec CHECK (length <= 500)
- `duration_seconds INTEGER` (NULL pour photos)
- `file_size_bytes BIGINT`

**Migration SQL** : Voir fichier story pour details.

**Complexite** : S (Small)

---

### S02 : Creer table guest_albums avec RLS

**Fichier** : `stories/S02-create-guest-albums.md`

**Objectif** : Permettre a chaque guest d'avoir un album par mariage.

**Structure** :
- 1 album par guest par mariage (UNIQUE constraint)
- Bride voit TOUS les albums de son mariage (pas d'opt-in)
- Guest gere uniquement son propre album

**RLS Policies** :
1. Guest : CRUD son propre album
2. Bride : SELECT tous les albums de son mariage

**Complexite** : S (Small)

---

### S03 : Creer table guest_media avec RLS

**Fichier** : `stories/S03-create-guest-media.md`

**Objectif** : Stocker les photos/videos des guests.

**Contraintes** :
- FK vers guest_albums avec ON DELETE CASCADE
- media_type CHECK (photo|video)
- caption max 500 chars
- duration_seconds max 600 (10 min)
- file_size_bytes max 500MB video, 20MB photo

**RLS Policies** :
1. Guest : CRUD ses medias via album ownership
2. Bride : SELECT tous les medias de son mariage

**Complexite** : S (Small)

---

### S04 : UI Upload media - Bride (video support)

**Fichier** : `stories/S04-ui-upload-bride.md`

**Objectif** : Ajouter le support video dans `AlbumDetailPage`.

**Modifications** :
- `_pickAndUploadImage()` → `_pickAndUploadMedia()` (photo + video)
- Validation video : duree ≤ 10min, taille ≤ 500MB
- Formats acceptes : mp4, mov, m4v
- Thumbnail generation pour videos
- Progress indicator pendant upload

**Reference UI** : `album_detail_page.dart` existant

**Complexite** : M (Medium)

---

### S05 : UI Saisie legende

**Fichier** : `stories/S05-ui-caption-input.md`

**Objectif** : Permettre d'ajouter une legende lors de l'upload.

**Widget** : `CaptionInputWidget`
- TextField avec maxLength=500
- Compteur caracteres visible (ex: "45/500")
- Optionnel (peut etre vide)
- Utilise `LynewedTextField`

**Integration** :
- Dans flow upload bride (S04)
- Dans flow upload guest (S06)

**Reference UI** : `LynewedTextField` avec maxLength

**Complexite** : S (Small)

---

### S06 : UI Upload media - Guest

**Fichier** : `stories/S06-ui-upload-guest.md`

**Objectif** : Transformer `GuestAlbumPage` en galerie fonctionnelle.

**Implementation** :
- Grille photos/videos (style `album_detail_page.dart`)
- FAB upload (photo + video)
- Auto-creation album si inexistant
- Caption input (reutiliser S05)
- Empty state elegant (existant)

**Reference UI** : `album_detail_page.dart` + `guest_album_page.dart`

**Complexite** : M (Medium)

---

### S07 : UI Bride vue albums guests

**Fichier** : `stories/S07-ui-bride-guest-albums.md`

**Objectif** : Permettre a la bride de voir tous les albums guests.

**Implementation** :
- Nouvelle page `GuestAlbumsPage` dans my_wedding
- Liste des albums guests avec nom + count medias
- Navigation vers detail (grille medias)
- Empty state si aucun album

**Reference UI** : `messages_page.dart` (liste) + `album_detail_page.dart` (detail)

**Complexite** : M (Medium)

---

### S08 : Download media

**Fichier** : `stories/S08-download-media.md`

**Objectif** : Permettre le telechargement de medias.

**Fonctionnalites** :
- Download single : photo ou video originale
- Download multiple : generation zip
- Progress indicator
- Fonctionne pour bride (ses albums + albums guests)

**Note** : Generation zip cote serveur recommandee (Edge Function) pour gros fichiers.

**Complexite** : M (Medium)

---

## RLS Policies Summary

| Table | Policy | Access |
|-------|--------|--------|
| `album_images` | Existantes | Bride via album ownership |
| `guest_albums` | Guest manages own | Guest CRUD own album |
| `guest_albums` | Bride views all | Bride SELECT all from her wedding |
| `guest_media` | Guest manages own | Guest CRUD via album ownership |
| `guest_media` | Bride views all | Bride SELECT all from her wedding |

**Principe** : Guest gere son album, Bride voit tout automatiquement.

---

## UI/UX - References Obligatoires

> Voir `.claude/rules/ui-design-system.md` pour details complets.

| Ecran a creer | Reference |
|---------------|-----------|
| Upload media (bride/guest) | `album_detail_page.dart` |
| Caption input | `LynewedTextField` avec maxLength |
| Liste albums guests | `messages_page.dart` |
| Detail album guest | `album_detail_page.dart` |

**Widgets obligatoires** :
- `LynewedButton`, `LynewedTextField`, `LynewedSheet`
- Import : `import '/core/design/design.dart';`

---

## Ordre d'Execution

```
S01 (album_images) ─┬─► S04 (upload bride) ─┬─► S05 (caption)
                    │                        │
S02 (guest_albums) ─┼─► S03 (guest_media) ──┼─► S06 (upload guest)
                    │                        │
                    └────────────────────────┼─► S07 (bride view)
                                             │
                                             └─► S08 (download)
```

**Ordre sequentiel recommande** :
1. S01 - Enrichir album_images
2. S02 - Creer guest_albums
3. S03 - Creer guest_media
4. S04 - UI Upload bride (video)
5. S05 - UI Caption input
6. S06 - UI Upload guest
7. S07 - UI Bride vue guests
8. S08 - Download media

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Upload video echoue gros fichiers | MOYEN | Chunked upload, retry auto |
| RLS mal configuree | HAUT | Tests exhaustifs avant deploy |
| Zip generation lente | MOYEN | Edge Function, progress indicator |
| Thumbnail video lent | FAIBLE | Async generation, placeholder |

---

## Checklist Pre-Production

- [ ] Toutes migrations testees
- [ ] RLS policies validees (bride voit guests, guest isole)
- [ ] flutter analyze --fatal-infos = 0 warnings
- [ ] Tests unitaires pour chaque use case
- [ ] Upload video teste (500MB, 10min)
- [ ] UI coherente avec Design System

---

## References

| Document | Lien |
|----------|------|
| PRD Section 6 | `docs/specs/MISSION-01-EVOLUTIONS-2026.md` |
| Design System UI | `.claude/rules/ui-design-system.md` |
| TRACKING | `TRACKING.md` |
