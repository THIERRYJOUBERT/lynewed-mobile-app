# EPIC-12-MAGAZINES — Tracking

> Suivi de progression des stories

## Vue d'ensemble

| Metrique | Valeur |
|----------|--------|
| **Total stories** | 12 |
| **Completees** | 0 |
| **En cours** | 0 |
| **Estimation** | 1.5 jours |
| **Budget** | 450€ |

## Progression par Story

| Story | Titre | Status | Points | Assignee | Notes |
|-------|-------|--------|--------|----------|-------|
| S01 | Table photo_favorites | 🔵 Draft | 2 | - | - |
| S02 | Table magazine_selections | 🔵 Draft | 2 | - | Depend S01 |
| S03 | Tables magazine_orders + items | 🔵 Draft | 5 | - | Depend S02 |
| S04 | Status guest_media | 🔵 Draft | 2 | - | Depend EPIC-10 |
| S05 | UI Galerie multi-select | 🔵 Draft | 5 | - | Depend S01 |
| S06 | UI Actions favorite/hide/delete | 🔵 Draft | 3 | - | Depend S04, S05 |
| S07 | UI Share gallery | 🔵 Draft | 5 | - | Depend S05 |
| S08 | UI Selection magazine | 🔵 Draft | 5 | - | Depend S02, S05 |
| S09 | UI Preview magazine | 🔵 Draft | 8 | - | Depend S08, L |
| S10 | Checkout Stripe | 🔵 Draft | 5 | - | Depend S03, EPIC-11 |
| S11 | Edge Function webhook | 🔵 Draft | 5 | - | Depend S03 |
| S12 | CGVU magazine | 🔵 Draft | 2 | - | Depend S10 |

**Total Points** : 49

## Dependances

```
EPIC-06 (Prerequisites) ──► EPIC-10 (Photos) ──► S04 (status)
                                                     │
EPIC-11 (Stripe) ─────────────────────────────────► S10, S11

S01 ──► S02 ──► S03 ──► S10 ──► S11
  │       │              │
  │       └──► S08 ──► S09
  │
  └──► S05 ──► S06
         │
         └──► S07
              │
              └──► S08
```

## Historique

| Date | Action | Details |
|------|--------|---------|
| 2026-01-29 | Creation | Epic cree en remplacement de EPIC-12-REELS (abandonne) |

## Notes

- **V1 = Fulfillment manuel** : Thierry gere la production avec son fournisseur
- **Pas d'API imprimeur** : Trop complexe pour V1
- **Admin panel** : Tom gere le CRM, hors scope de cet Epic
- **Budget identique aux Reels** : 1.5j / 450€
