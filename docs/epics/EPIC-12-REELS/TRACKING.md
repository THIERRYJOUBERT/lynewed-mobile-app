# TRACKING - EPIC-12-REELS

> Suivi d'avancement pour EPIC-12: Reels Generation

**Date de creation**: 2026-01-28
**Status**: Draft
**Stories**: 13 (dont S01b = migration post-EPIC-11)

---

## Tableau de Bord

| Metrique | Valeur |
|----------|--------|
| Stories totales | 13 |
| Stories completees | 0 |
| Stories en cours | 0 |
| Stories restantes | 13 |
| Points totaux | 44 |
| Points completes | 0 |
| Progression | 0% |

---

## Stories par Statut

### A Faire (13)

| Story | Titre | Points | Priorite | Dependances |
|-------|-------|--------|----------|-------------|
| S00 | Shotstack Infrastructure Validation | 2 | P0 | - |
| S01 | Create Reels Table | 2 | P0 | EPIC-06, EPIC-10 |
| S01b | Add FK purchase_id | 1 | P2 | S01, EPIC-11 |
| S02 | RLS Policies for Reels | 2 | P0 | S01 |
| S03 | Video Selection UI | 5 | P1 | EPIC-10 |
| S04 | Validate Video Ownership | 5 | P1 | S03, EPIC-10 |
| S05 | CGVU Modal + Table | 3 | P1 | - |
| S06 | Edge Function generate-reel | 8 | P0 | S00, S01 |
| S07 | Generate Preview (480p) | 3 | P1 | S06 |
| S08 | Generate Output (1080p) | 3 | P1 | S06 |
| S09 | Notification Reel Ready | 2 | P1 | S06 |
| S10 | Download Feature | 5 | P1 | S08 |
| S11 | Instagram Handles Display | 2 | P2 | - |
| S12 | Cleanup Cron Job | 3 | P1 | S01 |

### En Cours (0)

_Aucune story en cours_

### Completees (0)

_Aucune story completee_

---

## Ordre d'Execution Recommande

```
Phase 0: Prerequis (bloquants)
├── EPIC-06 ✅ Bucket wedding-media
├── EPIC-10 ✅ Tables guest_albums, guest_media
└── EPIC-11 ✅ Table purchases (pour S01b)

Phase 1: Infrastructure Backend
├── S00: Shotstack validation
├── S01: Table reels
└── S02: RLS policies

Phase 2: UI & Validation (parallele)
├── S03: Video selection UI
├── S04: Ownership validation
└── S05: CGVU modal

Phase 3: Edge Function Core
├── S06: generate-reel (Shotstack)
├── S07: Preview generation
└── S08: Output generation

Phase 4: Completion Features
├── S09: Notification
├── S10: Download
├── S11: Instagram handles
├── S12: Cleanup cron
└── S01b: FK purchase_id (apres EPIC-11)
```

---

## Diagramme de Dependances

```
              ┌─────────────────────────────────────────────────────┐
              │                 EXTERNAL DEPS                        │
              │  EPIC-06 (bucket) ─┬─ EPIC-10 (media) ─── EPIC-11   │
              └───────────────────┼────────────────────────────────┘
                                  │
                                  ▼
              ┌─────────────────────────────────────────────────────┐
              │                    S00                               │
              │          Shotstack Validation                        │
              └─────────────────────┬───────────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                ▼                   ▼                   │
┌───────────────────────┐  ┌───────────────────┐       │
│         S01           │  │        S05        │       │
│    Reels Table        │  │   CGVU Modal      │       │
└───────────┬───────────┘  └───────────────────┘       │
            │                                          │
    ┌───────┼───────┬─────────────────────────┐       │
    ▼       ▼       ▼                         │       │
┌───────┐ ┌───────┐ ┌───────┐                 │       │
│  S02  │ │  S12  │ │ S01b  │←── EPIC-11      │       │
│  RLS  │ │ Cron  │ │  FK   │                 │       │
└───────┘ └───────┘ └───────┘                 │       │
                                              │       │
                                              ▼       │
                                       ┌─────────────────┐
                                       │      S06        │
                                       │  Edge Function  │
                                       │  generate-reel  │
                                       └───────┬─────────┘
                                               │
                           ┌───────────────────┼───────────────────┐
                           ▼                   ▼                   ▼
                    ┌───────────┐       ┌───────────┐       ┌───────────┐
                    │    S07    │       │    S08    │       │    S09    │
                    │  Preview  │       │  Output   │       │   Notif   │
                    └───────────┘       └─────┬─────┘       └───────────┘
                                              │
                                              ▼
                                       ┌───────────┐
                                       │    S10    │
                                       │  Download │
                                       └───────────┘

┌───────────────────┐  ┌───────────────────┐
│        S03        │  │        S11        │
│  Video Selection  │  │ Instagram Handles │
│    (EPIC-10 dep)  │  │   (independent)   │
└─────────┬─────────┘  └───────────────────┘
          │
          ▼
   ┌───────────┐
   │    S04    │
   │ Ownership │
   └───────────┘
```

---

## Metriques de Complexite

| Story | Complexite | Risque | Domaine |
|-------|------------|--------|---------|
| S00 | Faible | Moyen | Backend |
| S01 | Faible | Faible | Database |
| S01b | Faible | Faible | Database |
| S02 | Faible | Moyen | Database/Security |
| S03 | Moyenne | Faible | Flutter |
| S04 | Moyenne | Moyen | Flutter/Backend |
| S05 | Faible | Faible | Flutter/Database |
| S06 | Haute | Haut | Backend |
| S07 | Moyenne | Faible | Backend |
| S08 | Moyenne | Faible | Backend |
| S09 | Faible | Faible | Backend |
| S10 | Moyenne | Moyen | Flutter |
| S11 | Faible | Faible | Flutter |
| S12 | Moyenne | Moyen | Backend |

---

## Risques Identifies

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Shotstack API indisponible | CRITIQUE | Faible | Fallback ffmpeg.wasm (limite) |
| Processing timeout | Haut | Moyen | Limite 10min, monitoring |
| Cout stockage | Moyen | Faible | Retention 7 jours |
| Videos corrompues | Moyen | Faible | Validation format |
| RLS trop permissive | Haut | Faible | Tests exhaustifs |

---

## Notes

### 2026-01-28
- Creation de l'Epic et des 13 stories
- Stories suivent le format INVEST avec criteres Gherkin
- Dependances externes: EPIC-06, EPIC-10, EPIC-11
- Estimation totale: 44 points (~1.5 jours)

---

## Changelog

| Date | Story | Action | Auteur |
|------|-------|--------|--------|
| 2026-01-28 | ALL | Stories creees | Claude |
