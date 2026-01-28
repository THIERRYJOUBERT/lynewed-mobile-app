# TRACKING - EPIC-10-PHOTOS-VIDEOS

> Status : 🔵 Draft
> Stories : 0/10 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Projet Photo & Video (APP-04) |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Enrichir album_images | 🔵 Todo | - | - | - | Base pour videos et legendes |
| S02 - Creer guest_albums | 🔵 Todo | - | - | - | Depend EPIC-06 S01 (enum guest) |
| S03 - Creer guest_media | 🔵 Todo | - | - | - | Depend S02 |
| S04 - Creer gallery_access_logs | 🔵 Todo | - | - | - | Independant |
| S05 - Upload video validation | 🔵 Todo | - | - | - | Depend S01 |
| S06 - Saisie legendes | 🔵 Todo | - | - | - | Depend S01 |
| S07 - Toggle shared_with_bride | 🔵 Todo | - | - | - | Depend S02, S03 |
| S08 - Vue bride albums guests | 🔵 Todo | - | - | - | Depend S02, S03 |
| S09 - Telechargement HQ + zip | 🔵 Todo | - | - | - | Depend S01-S03 |
| S10 - Flag print_ready | 🔵 Todo | - | - | - | Depend S01, S03 |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Limites: 20MB photo, 500MB/10min video | PRD Section 6 | Balance qualite/stockage |
| 2026-01-28 | Caption max 500 chars | PRD Section 6 | UX concise |
| 2026-01-28 | shared_with_bride opt-in (default FALSE) | Privacy by design | Guest doit explicitement partager |
| 2026-01-28 | Zip generation serveur pour gros fichiers | Performance | Edge Function recommandee |
| 2026-01-28 | print_ready visible mais desactive | Anticipation futur | Prepare infrastructure |

---

## Ce qui reste pour 100%

### Database (Stories S01-S04)

- [ ] S01: Colonne media_type sur album_images
- [ ] S01: Colonne caption sur album_images
- [ ] S01: Colonnes duration_seconds, file_size_bytes sur album_images
- [ ] S01: Colonne print_ready sur album_images
- [ ] S01: Check constraints (media_type, caption length)
- [ ] S02: Table guest_albums avec UNIQUE(wedding_id, guest_user_id)
- [ ] S02: Index idx_guest_albums_wedding_shared
- [ ] S02: RLS "Guest manages own album"
- [ ] S02: RLS "Bride views shared albums"
- [ ] S03: Table guest_media avec FK vers guest_albums
- [ ] S03: Contraintes media_type et caption_length
- [ ] S03: RLS "Guest manages own media"
- [ ] S03: RLS "Bride views shared media"
- [ ] S04: Table gallery_access_logs avec index
- [ ] S04: RLS service_role only

### Flutter (Stories S05-S10)

- [ ] S05: VideoPicker avec validation duree/taille
- [ ] S05: Thumbnail generation automatique
- [ ] S05: Progress indicator upload
- [ ] S05: Gestion erreurs (trop long, trop gros, format invalide)
- [ ] S06: CaptionInputWidget avec compteur 500 chars
- [ ] S06: Preview caption sur media
- [ ] S06: Edition caption post-upload
- [ ] S07: ShareToggleWidget avec confirmation dialog
- [ ] S07: Log share_enabled/share_disabled dans gallery_access_logs
- [ ] S08: GuestAlbumsPage pour bride
- [ ] S08: GuestAlbumCard avec nom guest et count
- [ ] S08: Grille medias dans album guest
- [ ] S08: Lecture video inline
- [ ] S09: Download single file (photo/video)
- [ ] S09: Download multiple avec zip generation
- [ ] S09: Progress indicator download
- [ ] S09: Log download/download_zip dans gallery_access_logs
- [ ] S10: PrintReadyBadge (disabled avec "Coming soon")
- [ ] S10: Toggle print_ready sur medias

### Tests

- [ ] Tests unitaires migrations SQL
- [ ] Tests RLS policies (guest isolation)
- [ ] Tests unitaires use cases Flutter
- [ ] Tests widget video picker
- [ ] Tests widget caption input
- [ ] flutter analyze --fatal-infos passe
- [ ] Validation sur branche Supabase avant production

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 10 |
| Stories completees | 0 |
| Migrations SQL | 4 |
| Nouvelles tables | 3 (guest_albums, guest_media, gallery_access_logs) |
| Tables modifiees | 1 (album_images) |
| RLS Policies nouvelles | 5 |
| Use cases Flutter | ~8 (estimes) |
| Widgets Flutter | ~10 (estimes) |
| Tests a ajouter | ~30 (estimes) |
| Temps estime | 1.5 jours |

---

## Dependances Inter-Stories

```
S01 (album_images enrichi)
  |
  +---> S05 (upload video) -----> S06 (legendes)
  |
  +---> S10 (print_ready partial)

S02 (guest_albums) ---> S03 (guest_media)
  |                       |
  +-------+-------+-------+
          |
          v
        S07 (toggle share) ---> S08 (bride view)

S04 (gallery_access_logs) --- INDEPENDANT mais utilise par S07, S09

S09 (download) --- Depend de S01-S03 complets
```

---

## Dependances Inter-Epics

| Epic | Dependance | Status | Impact |
|------|------------|--------|--------|
| EPIC-06-PREREQUISITES | Bucket wedding-media | 🔵 Draft | BLOQUANT pour storage |
| EPIC-06-PREREQUISITES | Enum userRole 'guest' | 🔵 Draft | BLOQUANT pour S02-S03 |
| EPIC-09-GUESTS (APP-03) | Systeme guest complet | ⏳ A creer | Integration albums |

---

## Checklist Pre-Production

Avant de merger les migrations en production:

- [ ] EPIC-06 complete (bucket wedding-media existe)
- [ ] EPIC-09 en cours (systeme guest valide)
- [ ] Toutes les migrations testees sur branche Supabase
- [ ] Rollback teste pour chaque migration
- [ ] Pas de donnees perdues lors des tests
- [ ] RLS policies validees avec tests (guest isolation)
- [ ] Aucun warning flutter analyze
- [ ] Upload video teste avec fichiers limites (500MB, 10min)
- [ ] Documentation a jour
- [ ] Backup production fait avant migration

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
