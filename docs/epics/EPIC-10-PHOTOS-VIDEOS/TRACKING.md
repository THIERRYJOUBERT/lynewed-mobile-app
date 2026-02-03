# TRACKING - EPIC-10-PHOTOS-VIDEOS

> Status : 🟢 Ready
> Stories : 0/8 completees
> Derniere MAJ : 2026-02-03

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Projet Photo & Video (APP-04) |
| 2026-02-03 | Epic revise - Simplification (10→8 stories, suppression opt-in/logs/print_ready) |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Enrichir album_images | 🔵 Todo | - | - | - | +media_type, caption, duration, file_size |
| S02 - Creer guest_albums | 🔵 Todo | - | - | - | 1 album/guest/wedding, RLS bride voit tout |
| S03 - Creer guest_media | 🔵 Todo | - | - | - | Depend S02, contraintes fichiers |
| S04 - UI Upload bride (video) | 🔵 Todo | - | - | - | Depend S01, video support |
| S05 - UI Caption input | 🔵 Todo | - | - | - | Depend S01, CaptionInputWidget |
| S06 - UI Upload guest | 🔵 Todo | - | - | - | Depend S02+S03+S05, GuestAlbumPage |
| S07 - UI Bride vue guests | 🔵 Todo | - | - | - | Depend S02+S03, GuestAlbumsPage |
| S08 - Download media | 🔵 Todo | - | - | - | Depend S01-S03, single+zip |

---

## Decisions Techniques (2026-02-03)

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-02-03 | Reutiliser bucket `wedding-albums` | Pas de creation manuelle | Structure: {wedding_id}/guests/{user_id}/ |
| 2026-02-03 | Pas d'opt-in partage guest→bride | Simplicite UX | Bride voit tout automatiquement |
| 2026-02-03 | Suppression gallery_access_logs | Pas necessaire V1 | Moins de complexite |
| 2026-02-03 | Suppression print_ready | Futur | Focus sur core features |
| 2026-02-03 | 8 stories au lieu de 10 | Simplification | S07 toggle + S10 print_ready supprimes |

---

## Ce qui reste pour 100%

### Database (Stories S01-S03)

- [ ] S01: Colonne media_type sur album_images
- [ ] S01: Colonne caption sur album_images (max 500)
- [ ] S01: Colonnes duration_seconds, file_size_bytes sur album_images
- [ ] S01: Check constraints
- [ ] S02: Table guest_albums avec UNIQUE(wedding_id, guest_user_id)
- [ ] S02: RLS "Guest manages own album"
- [ ] S02: RLS "Bride views all albums"
- [ ] S03: Table guest_media avec FK vers guest_albums
- [ ] S03: Contraintes media_type, caption, duration, file_size
- [ ] S03: RLS "Guest manages own media"
- [ ] S03: RLS "Bride views all media"

### Flutter (Stories S04-S08)

- [ ] S04: Support video dans AlbumDetailPage
- [ ] S04: Validation duree ≤ 10min, taille ≤ 500MB
- [ ] S04: Thumbnail generation video
- [ ] S04: Progress indicator upload
- [ ] S05: CaptionInputWidget avec compteur 500 chars
- [ ] S05: Integration dans flow upload
- [ ] S06: GuestAlbumPage fonctionnel (grille + FAB)
- [ ] S06: Auto-creation album guest
- [ ] S06: Caption input integre
- [ ] S07: GuestAlbumsPage (liste albums guests)
- [ ] S07: Navigation vers detail album
- [ ] S07: Empty state
- [ ] S08: Download single file
- [ ] S08: Download multiple avec zip
- [ ] S08: Progress indicator download

### Tests & Qualite

- [ ] Tests unitaires migrations SQL
- [ ] Tests RLS policies
- [ ] Tests unitaires use cases Flutter
- [ ] Tests widgets (upload, caption, download)
- [ ] flutter analyze --fatal-infos = 0
- [ ] UI coherente Design System

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 8 |
| Stories completees | 0 |
| Migrations SQL | 3 |
| Nouvelles tables | 2 (guest_albums, guest_media) |
| Tables modifiees | 1 (album_images) |
| RLS Policies nouvelles | 4 |
| Use cases Flutter | ~6 |
| Widgets Flutter | ~4 |
| Tests a ajouter | ~25 |
| Temps estime | 1 jour |

---

## Dependances

### Internes (EPIC-10)

```
S01 ───┬─► S04 ─► S05
       │
S02 ──►S03 ──┬─► S06
             ├─► S07
             └─► S08
```

### Inter-Epics

| Epic | Dependance | Status |
|------|------------|--------|
| EPIC-06 | Enum userRole 'guest' | ✅ COMPLETE |
| EPIC-09 | Systeme guest complet | ✅ COMPLETE |
| EPIC-12 | Utilise guest_media | ⏳ Apres EPIC-10 |

---

## Checklist Pre-Production

- [ ] Migrations testees sur branche Supabase
- [ ] Rollback teste pour chaque migration
- [ ] RLS policies validees (bride voit guests)
- [ ] Upload video teste (500MB, 10min, formats)
- [ ] UI coherente avec screens de reference
- [ ] Aucun warning flutter analyze
- [ ] Documentation a jour

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
