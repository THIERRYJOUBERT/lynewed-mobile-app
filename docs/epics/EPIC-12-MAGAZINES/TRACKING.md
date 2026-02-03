# EPIC-12-MAGAZINES — Tracking

> Suivi de progression des stories
> **MAJ** : 2026-02-03

## Vue d'ensemble

| Metrique | Valeur |
|----------|--------|
| **Total stories** | 12 |
| **Completees** | 12 ✅ |
| **En cours** | 0 |
| **Estimation** | 1.5 jours |
| **Budget** | 450€ |

## Progression par Story

| Story | Titre | Status | Points | Assignee | Notes |
|-------|-------|--------|--------|----------|-------|
| S01 | Table photo_favorites | ✅ Done | 2 | Claude | Migration appliquee |
| S02 | Table magazine_selections | ✅ Done | 2 | Claude | Migration appliquee |
| S03 | Tables magazine_orders + items | ✅ Done | 5 | Claude | Migration appliquee |
| S04 | Status guest_media | ✅ Done | 2 | Claude | Colonne status + filtrage Flutter-side |
| S05 | UI Galerie multi-select | ✅ Done | 5 | Claude | Multi-select + action bar (89 tests) |
| S06 | UI Actions favorite/hide/delete | ✅ Done | 3 | Claude | Toggle favorite, hide, delete (78 tests) |
| S07 | UI Share gallery | ✅ Done | 5 | Claude | photo_shares table + dialog + badge (54 tests) |
| S08 | UI Selection magazine | ✅ Done | 5 | Claude | Reorderable grid + cubit (91 tests) |
| S09 | UI Preview magazine + Format selection | ✅ Done | 8 | Claude | 4 formats, cover, layouts (115 tests) |
| S10 | Checkout Stripe + FedEx | ✅ Done | 5 | Claude | Address form, shipping, payment (141 tests) |
| S11 | Edge Function webhook | ✅ Done | 5 | Claude | magazine-webhook-v2 deployed |
| S12 | CGVU magazine | ✅ Done | 2 | Claude | Dialog + acceptance tracking (25 tests) |

**Total Points** : 49

## Dependances (MAJ 2026-02-03)

```
EPIC-06 (Prerequisites) ✅ ──► EPIC-10 (Photos) ✅ ──► S04 (status)
                                                           │
EPIC-11 (Stripe) ✅ ───────────────────────────────────► S10, S11

S01 ──► S02 ──► S03 ──► S10 ──► S11
  │       │              │
  │       └──► S08 ──► S09 (format selection) ──► S10
  │
  └──► S05 ──► S06
         │
         └──► S07
              │
              └──► S08
```

## Decisions Techniques (2026-02-03)

| Decision | Choix | Raison |
|----------|-------|--------|
| Pas d'opt-in partage guest→bride | Automatique | Bride voit tous albums guests (EPIC-10) |
| 4 formats magazine | Pricing différencié | $29, $59, $69, $89 |
| Devise | USD | Standard e-commerce |
| Frais de port | FedEx dynamique | API Rates au checkout |
| Bucket storage | wedding-albums | Réutilisation existant |

## Historique

| Date | Action | Details |
|------|--------|---------|
| 2026-01-29 | Creation | Epic cree en remplacement de EPIC-12-REELS (abandonne) |
| 2026-02-03 | MAJ Pricing | 4 formats: GUEST EDITION ($29), ICONIC ($59), MEMORY ($69), COLLECTOR ($89) |
| 2026-02-03 | MAJ S04 | Corrige RLS (pas de shared_with_bride) |
| 2026-02-03 | MAJ S09 | Ajout selection format magazine |
| 2026-02-03 | MAJ S10 | Prix dynamique selon format + FedEx shipping |
| 2026-02-03 | Dependencies | EPIC-10 ✅, EPIC-11 ✅ - Pret a lancer |
| 2026-02-03 | S01 Done | Table photo_favorites creee avec RLS |
| 2026-02-03 | S02 Done | Table magazine_selections creee avec RLS |
| 2026-02-03 | S04 Done | Colonne status ajoutee a guest_media |
| 2026-02-03 | S03 Done | Tables magazine_orders + magazine_order_items creees avec RLS + CASCADE |
| 2026-02-03 | S05 Done | Multi-select gallery avec action bar (selection_action_bar.dart, photo_tile.dart, gallery_grid.dart) |
| 2026-02-03 | S07 Done | Share gallery: photo_shares table, SharePhotosWithGuestsUseCase, UnsharePhotosUseCase, ShareGalleryDialog, SharedBadge |
| 2026-02-03 | S11 Done | Edge Function magazine-webhook-v2: creates orders, snapshots photos, clears selections, sends notification |
| 2026-02-03 | S06 Done | UI Actions: ToggleFavoriteUseCase, HideMediaUseCase, DeleteMediaUseCase + dialogs (78 tests) |
| 2026-02-03 | S08 Done | Magazine Selection: ReorderablePhotoGrid, MagazineSelectionCubit, drag-drop reordering (91 tests) |
| 2026-02-03 | S09 Done | Magazine Preview: 4 format selector, cover, layouts (single/double/mosaic), page navigation (115 tests) |
| 2026-02-03 | S10 Done | Checkout: ShippingAddressForm, OrderSummaryCard, Stripe integration, FedEx V1 fixed rates (141 tests) |
| 2026-02-03 | S12 Done | CGVU: MagazineCgvuDialog, AcceptCgvuUseCase, audit trail (25 tests) |
| 2026-02-03 | **EPIC COMPLETE** | 12/12 stories, 593+ tests, 0 warnings, flutter analyze OK |
| 2026-02-03 | Bug Fix | Magazine Picker: PostgrestException column created_at (utilisait uploaded_at) |
| 2026-02-03 | Bug Fix | Magazine Picker: Guest images non affichées (paths vs URLs storage) |
| 2026-02-03 | Bug Fix | Magazine Selection/Preview: Guest thumbnails non chargées (getGuestMediaThumbnail) |
| 2026-02-03 | UI Fix | Magazine Picker: Filtrage vidéos (photos only), cercle vert already-selected, padding réduit |

## Notes

- **V1 = Fulfillment manuel** : Thierry gere la production avec son fournisseur
- **Pas d'API imprimeur** : Trop complexe pour V1
- **Admin panel** : Tom gere le CRM, hors scope de cet Epic
- **Budget identique aux Reels** : 1.5j / 450€
- **Prérequis satisfaits** : EPIC-10 et EPIC-11 complets
