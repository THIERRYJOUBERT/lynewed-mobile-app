# TRACKING - EPIC-15-BUGFIX

> Status : 🟡 In Progress
> Stories : 8/10 completees
> Derniere MAJ : 2026-02-16

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-02-16 | Retour Thierry recu (mail + Whimsical) |
| 2026-02-16 | Document de feedback challenge cree (docs/THIERRY-FEEDBACK-2026-02-16.md) |
| 2026-02-16 | Epic cree avec /create-epic (14 stories initiales) |
| 2026-02-16 | Scope reduit a 11 stories / 3 vagues apres corrections Leo |
| 2026-02-16 | S09 (brides sur carte) supprimee - fonctionne deja si mariage public → 10 stories finales |
| 2026-02-16 | S02 DONE - Trigger verifie, fonction retry loop deployee, 7 mariages backfilles, TEST1234 regenere |
| 2026-02-16 | S03 Phase 1 DONE - Templates .well-known/ prets, commentaires corriges, guide deploiement cree. Phase 2 bloquee (deploiement serveur Thierry) |
| 2026-02-16 | S03 Phase 2 DONE - assetlinks.json deploye (SHA-256 reel), vercel.json Content-Type fixe. Deep links 100% operationnels |
| 2026-02-16 | S01 DONE - Credentials validees (curl OK), 4 secrets configures Supabase, error handling ameliore, 4 Edge Functions redeployees |
| 2026-02-16 | S05 DONE - Edge Function send-wedding-invitation deployee (Resend + QR code, template EN, domaine lynewed.com). EPIC-09/S06 mise a jour avec note deprecation |
| 2026-02-16 | S04 DONE - Modal CGUV upload photos guest (dialog bloquant, scroll obligatoire, 14 tests widget, guard race condition) |
| 2026-02-16 | S08 DONE - Carte optimisee (fallback icons, LRU cache LinkedHashMap, thread-safety Lock, 13 tests, BUG-05 + BUG-13 resolus) |
| 2026-02-16 | S07 DONE - Lien "Track on FedEx" cote seller (transaction_detail_page), 3 tests widget, pattern identique buyer |
| 2026-02-16 | S06 DONE - FedEx dynamic shipping rates (weightKg entity+UI, GetSellerShippingAddress use case, checkout 4-step flow, error+retry, 17 checkout tests) |
| 2026-02-16 | S09 DONE - Magazine quantity selector (dropdown 1-10, server-side clamp, Stripe line_items quantity, webhook+DB, 20+ tests) |

---

## Progression Stories

### Vague 1 - Debloquer les flux critiques

| Story | Status | Assignee | Date Start | Date Done |
|-------|--------|----------|------------|-----------|
| S01 - FedEx OAuth debug | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S02 - Backfill invite codes | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S03 - Deep links diagnostic | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S04 - CGUV photos modal | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |

### Vague 2 - Completer les flux (depend Vague 1)

| Story | Status | Assignee | Date Start | Date Done |
|-------|--------|----------|------------|-----------|
| S05 - Edge Fn invitation Resend | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S06 - FedEx shipping dynamique | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S07 - FedEx tracking lien | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S08 - Carte optimisation | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |

### Vague 3 - Polish fonctionnel

| Story | Status | Assignee | Date Start | Date Done |
|-------|--------|----------|------------|-----------|
| S09 - Quantite magazine | ✅ Done | Claude | 2026-02-16 | 2026-02-16 |
| S10 - Fixes mineurs batch | 🔵 Todo | - | - | - |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-02-16 | FedEx dynamique avec fallback flat-rate | Thierry veut des frais bases sur le poids reel | Checkout doit appeler `fedex-calculate-rate` |
| 2026-02-16 | Prioriser fonctionnel, UI en dernier | Budget serre, l'app doit marcher | Vagues 1-3 avant tout |
| 2026-02-16 | lynewed.com/join deja configure par Thierry | Diagnostic a faire sur pourquoi ca ne marche pas | S03 doit diagnostiquer avant de deployer |
| 2026-02-16 | Scope reduit : pas de Suits, header redesign, dark marketplace, couples pro | Hors devis ou trop complexe | 14 → 11 stories |
| 2026-02-16 | Border radius marketplace : 0-4px max | Coherence visuelle demandee par Leo | S11 batch |

---

## Ce qui reste pour 100%

### INFRA (Stories S01, S03, S07)

- [x] Secrets FedEx verifies/corriges dans Supabase (4 secrets configures via CLI)
- [x] Fichiers .well-known deployes sur lynewed.com (assetlinks.json SHA-256 + AASA Content-Type fixe)
- [ ] Cron job tracking FedEx configure

### DATA (Stories S02) ✅

- [x] Trigger invite codes verifie/applique en prod
- [x] Migration backfill invite codes
- [x] Fonction regenerate_wedding_invite_code avec retry loop deployee
- [x] 9/9 mariages avec codes valides

### API (Stories S05, S06)

- [x] Edge Function send-wedding-invitation deployee (Resend + QR code, template EN)
- [ ] FedEx dynamic rates branche dans checkout

### UI (Stories S04, S08, S09, S10)

- [x] Modal CGUV upload photos guest (dialog bloquant, 14 tests widget)
- [x] Carte optimisee (fallback icons, LRU cache, thread-safety, 13 tests)
- [x] Selecteur quantite magazine (dropdown 1-10, prix dynamique, server-side clamp)
- [ ] Fixes mineurs (onglet marketplace pro, chat prenom, border radius)

### TEST (Transversal)

- [ ] Tests unitaires pour chaque story
- [ ] Tests integration
- [ ] flutter analyze --fatal-infos passe

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 10 |
| Stories completees | 9 |
| Bugs bloquants resolus | 3/3 (~~invite codes~~, ~~FedEx~~, ~~deep links~~) |
| Bugs fonctionnels resolus | 3/5 (~~CGUV~~, ~~invitation~~, shipping, tracking, ~~carte~~) |
| Bugs mineurs resolus | 0/3 (marketplace tab, prenom, border radius) |
| Tests ajoutes | - |

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
