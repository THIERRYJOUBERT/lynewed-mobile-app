# TRACKING - EPIC-12-REELS

> Status : 🔵 Draft
> Stories : 0/12 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Reels feature (APP-06) |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Creer table reels | 🔵 Todo | - | - | - | Prerequis pour toutes les stories |
| S02 - RLS policies reels | 🔵 Todo | - | - | - | Depend de S01 |
| S03 - UI selection videos | 🔵 Todo | - | - | - | Depend de EPIC-10 |
| S04 - Valider ownership videos | 🔵 Todo | - | - | - | Depend de S03 |
| S05 - Modal CGVU reels | 🔵 Todo | - | - | - | Independant |
| S06 - Edge Function generate-reel | 🔵 Todo | - | - | - | COMPLEXE - FFmpeg |
| S07 - Generer preview 480p | 🔵 Todo | - | - | - | Depend de S06 |
| S08 - Generer output 1080p | 🔵 Todo | - | - | - | Depend de S06 |
| S09 - Notification reel pret | 🔵 Todo | - | - | - | Depend de S06 |
| S10 - Download feature | 🔵 Todo | - | - | - | Depend de S08 |
| S11 - Afficher @ Instagram pros | 🔵 Todo | - | - | - | Independant |
| S12 - pg_cron cleanup reels | 🔵 Todo | - | - | - | Depend de S01 |

---

## Dependances Externes

| Dependance | Epic | Statut | Bloquant pour |
|------------|------|--------|---------------|
| Bucket `wedding-media` | EPIC-06 | 🔵 Todo | S06, S07, S08 |
| Table `guest_albums` | EPIC-10 | 🔵 Todo | S04 |
| Table `guest_media` | EPIC-10 | 🔵 Todo | S03, S04 |
| Table `purchases` | EPIC-08 | 🔵 Todo | S01 (FK optionnelle) |
| Video upload support | EPIC-10 | 🔵 Todo | Tout l'Epic |

**Note importante** : Cet Epic ne peut etre TESTE qu'apres EPIC-10 (Photos/Videos), mais la DB et le code peuvent etre prepares en avance.

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Guests CAN create reels (D-14) | Override conversations precedentes | Guests limites a leurs propres videos |
| 2026-01-28 | FFmpeg MVP (pas Shotstack) | Cout minimal, MVP | Transitions fade simples uniquement |
| 2026-01-28 | Preview 480p + watermark central | Inciter au telechargement HQ | Qualite volontairement basse |
| 2026-01-28 | Output 1080p + logo discret | Partage reseaux sociaux | Logo coin inferieur droit |
| 2026-01-28 | Expiration 7 jours | Cout stockage | Cleanup automatique pg_cron |
| 2026-01-28 | Gratuit MVP, architecture paiement prete | Test marche | Champs is_paid, price_cents |
| 2026-01-28 | Max 10 videos, 2min chaque, 10min total | Performance | Limites raisonnables |

---

## Ce qui reste pour 100%

### Database (Stories S01-S02)

- [ ] S01: Table reels avec schema complet
- [ ] S01: Indexes (user, wedding, status, expires)
- [ ] S01: Constraints (creator_type, status)
- [ ] S01: FK vers profiles, weddings, purchases
- [ ] S02: Policy "User manages own reels"
- [ ] S02: Policy "Bride views wedding reels"

### Flutter UI (Stories S03, S05, S10, S11)

- [ ] S03: Page selection videos avec grid
- [ ] S03: Compteur selection (X/10)
- [ ] S03: Validation duree individuelle (max 2min)
- [ ] S03: Validation duree totale (max 10min)
- [ ] S03: Drag & drop reorder
- [ ] S05: Modal CGVU 4 checkboxes
- [ ] S05: Log acceptation dans cgvu_acceptances
- [ ] S05: Check version CGVU
- [ ] S10: Page detail reel avec preview
- [ ] S10: Bouton download avec progression
- [ ] S10: Save vers galerie device
- [ ] S10: Update downloaded_at
- [ ] S11: Section @ Instagram pros (bride only)
- [ ] S11: Bouton "Copier tout"

### Backend Validation (Story S04)

- [ ] S04: Validation guest = own videos only
- [ ] S04: Validation bride = own + shared
- [ ] S04: Rejet cote serveur (Edge Function)
- [ ] S04: Messages d'erreur clairs

### Edge Functions (Stories S06-S09, S12)

- [ ] S06: Edge Function generate-reel deployee
- [ ] S06: Download videos depuis Storage
- [ ] S06: Concatenation FFmpeg avec fade 1s
- [ ] S06: Gestion statuts (pending → processing → ready/failed)
- [ ] S06: Gestion erreurs avec error_message
- [ ] S06: Timeout 10 minutes
- [ ] S07: Preview 480p generation
- [ ] S07: Watermark "LYNEWED" central
- [ ] S08: Output 1080p generation
- [ ] S08: Logo Lynewed coin inferieur droit
- [ ] S09: Notification FCM "Reel pret"
- [ ] S09: Insert notifications_outbox
- [ ] S12: pg_cron job cleanup-expired-reels
- [ ] S12: Suppression fichiers Storage
- [ ] S12: Update status = 'expired'

### Tests

- [ ] Tests unitaires table reels
- [ ] Tests RLS policies
- [ ] Tests validation ownership
- [ ] Tests UI selection
- [ ] Tests Edge Function (mock FFmpeg)
- [ ] Tests notification
- [ ] flutter analyze --fatal-infos passe

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 12 |
| Stories completees | 0 |
| Migrations SQL | 3 (table, RLS, cron) |
| Edge Functions | 2 (generate-reel, cleanup) |
| RLS Policies | 2 |
| Tests a ajouter | ~25 (estimes) |
| Temps estime | 1.5 jours |
| Complexite principale | S06 (FFmpeg integration) |

---

## Dependances Inter-Stories

```
S01 (table reels)
  |
  +---> S02 (RLS policies)
  |
  +---> S06 (Edge Function) ──> S07 (preview)
  |                         |
  |                         +──> S08 (output) ──> S10 (download)
  |                         |
  |                         +──> S09 (notification)
  |
  +---> S12 (cleanup cron)

S03 (UI selection) ──> S04 (ownership validation)
     |
     +---> Depend de EPIC-10 (guest_media, album_images)

S05 (CGVU modal) --- INDEPENDANT

S11 (Instagram pros) --- INDEPENDANT
```

---

## FFmpeg Integration Notes

### Option 1: Deno + WASM FFmpeg (Recommandee MVP)
- Utiliser `ffmpeg-wasm` dans Edge Function
- Limite: Performance, taille memoire
- Pro: Tout dans Supabase

### Option 2: Service Externe
- Utiliser un service comme Shotstack, Creatomate
- Pro: Performance, features avancees
- Con: Cout, dependance externe

### Option 3: Self-hosted Worker
- Deployer un worker avec FFmpeg installe
- Pro: Controle total
- Con: Maintenance, infra

**Decision MVP**: Commencer avec Option 1, evaluer performance, migrer si necessaire.

---

## Checklist Pre-Production

Avant de merger les migrations en production:

- [ ] Toutes les migrations testees sur branche Supabase
- [ ] EPIC-10 complete (tables guest_albums, guest_media existent)
- [ ] Edge Functions deployees et testees
- [ ] FFmpeg fonctionne sur Edge Runtime
- [ ] RLS policies validees avec tests
- [ ] CGVU textes valides juridiquement
- [ ] Notification FCM fonctionne
- [ ] Download save vers galerie fonctionne
- [ ] pg_cron cleanup fonctionne
- [ ] Aucun warning flutter analyze
- [ ] Documentation a jour
- [ ] Logo Lynewed prepare (PNG transparent)
- [ ] Backup production fait avant migration

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
