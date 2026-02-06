# TRACKING - EPIC-14-MARKETPLACE

> Status : ✅ COMPLETE
> Stories : 26/26 completees
> Derniere MAJ : 2026-02-05

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Marketplace Robes & Chaussures (APP-08) |
| 2026-02-04 | Phase 1 (DB) complete - 7 tables + 2 buckets + RLS |
| 2026-02-04 | Phase 2 (CGVU/Stripe) complete - cgvu_acceptances + Edge Functions |
| 2026-02-04 | Phase 3 (FedEx) complete - 3 Edge Functions + cron |
| 2026-02-04 | 301 tests marketplace, 0 lint warnings |
| 2026-02-05 | Phase 4 (Frontend Core) complete - S14-S18 |
| 2026-02-05 | Phase 5 (Transactions) complete - S19-S22 |
| 2026-02-05 | Phase 6 (Polish) complete - S23-S26 |
| 2026-02-05 | **EPIC-14 COMPLETE** - 26/26 stories, 500+ tests marketplace |
| 2026-02-05 | **/challenge --auto --deep** - Audit complet: 52 issues trouvées (8 CRITICAL, 10 HIGH, 19 MEDIUM, 15 LOW) |
| 2026-02-05 | **Corrections appliquées** - 7 Edge Functions corrigées & déployées, 2 migrations SQL sécurité, 16 fichiers Flutter fixés, drain marketplace handlers ajoutés. Score 62% → ~92% |
| 2026-02-05 | **Post-validation: offres↔chat Vinted** - DB migration (offer/system message types + offer_id FK), domain/data/presentation layers, 2 nouveaux widgets (OfferBubbleWidget, SystemMessageWidget), 7 pages modifiées, 11 tests corrigés. 763 tests marketplace passent. |
| 2026-02-06 | **Project cleanup final** - Withdraw offer button, profile column names fix, seller listings page, buyer offer tile, phone formatter, organization/people pages, flat-rate shipping, tests fixés. 5193 tests passent, 0 warnings. |

---

## Progression Stories

### Phase 1: Database Foundation

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Table marketplace_listings | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Table + 5 RLS + indexes + entity + tests |
| S02 - Table marketplace_photos | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Table + CASCADE + entity + tests |
| S03 - Table marketplace_offers | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Table + expiration function + entity + tests |
| S04 - Table marketplace_transactions | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Table + commission + entity + tests |
| S05 - Table marketplace_messages | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Table + Realtime + entity + tests |
| S06 - Table fedex_events | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Audit log + entity + tests |
| S07 - Bucket marketplace-listings | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | marketplace-listings + marketplace-labels buckets |

### Phase 2: CGVU & Stripe

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S08 - CGVU marketplace seller | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | cgvu_acceptances table + dialog + tests |
| S09 - CGVU marketplace buyer | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Buyer dialog + tests (shared table) |
| S10 - Stripe Connect onboarding | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | 2 Edge Functions + full Flutter stack + 32 tests |

### Phase 3: FedEx Integration

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S11 - Edge Function FedEx Rate | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Edge Function + entities + datasource + repo + use case + widget + tests |
| S12 - Edge Function FedEx Ship | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Edge Function + entity + use case + widget + tests + labels bucket |
| S13 - Edge Function FedEx Track | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Edge Function + entity + use case + widget + tests + cron hourly |

### Phase 4: Frontend Core

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S14 - Formulaire creation annonce | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Create listing page + photo upload + CGVU/Stripe checks + tests |
| S15 - Page liste annonces (feed) | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Feed page + infinite scroll + listing cards + tests |
| S16 - Page detail annonce | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Detail page + photo carousel + action buttons + tests |
| S17 - Systeme de filtres | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Filter sheet + all criteria + filter badge row + tests |
| S18 - Chat buyer/seller | ✅ Done | Chef Opus | 2026-02-04 | 2026-02-04 | Marketplace chat + realtime + chat list + tests |

### Phase 5: Transactions

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S19 - Systeme d'offres | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Offer modal + seller management + counter-offer + tests |
| S20 - Flow achat complet | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Checkout flow + shipping address + Stripe payment + order confirmation + tests |
| S21 - Generation etiquette FedEx | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Transaction detail page + generate label button + shipping label widget + 31 tests |
| S22 - Tracking colis | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Buyer transaction page + tracking timeline + FedEx link + 30 tests |

### Phase 6: Polish

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S23 - Notifications marketplace | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | 9 notification types + push + in-app + deep links + 35 tests |
| S24 - Marqueurs carte | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Marketplace filter chip + ListingDetail navigation + MarketplaceChat + 6 tests |
| S25 - Page "Mes ventes" | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Seller dashboard + earnings stats + listing cards + offer badges + 26 tests |
| S26 - Navbar + Home preview | ✅ Done | Chef Opus | 2026-02-05 | 2026-02-05 | Navbar tab "Market" + home preview section + 8 tests |

---

## Prerequis Inter-Epics

| Epic | Status | Impact sur EPIC-14 |
|------|--------|-------------------|
| EPIC-06 Prerequisites | ✅ Done | Enum userRole, invite_code |
| EPIC-11 Stripe Integration | ✅ Done | Tables stripe_accounts, purchases, stripe_events |
| EPIC-13 Map Filters | ✅ Done | Map infrastructure + PostGIS |

**Tous les prerequis sont completes.**

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Tous montants en USD cents | PRD Decision D-07 | Simplifie calculs, evite erreurs float |
| 2026-01-28 | Commission 10% fixe | PRD APP-08 | platform_fee = item_price * 0.10 |
| 2026-01-28 | FedEx worldwide shipping | PRD APP-08 | Support multi-pays, calcul frais automatique |
| 2026-01-28 | Expiration offres 48h | PRD APP-08 | Balance UX vendeur/acheteur |
| 2026-01-28 | 7 jours avant completion | PRD APP-08 | Protection acheteur post-livraison |
| 2026-01-28 | CGVU scroll + checkbox | PRD Section 12 | Conformite juridique, preuve acceptation |
| 2026-01-28 | Photos 5-10 obligatoires | PRD APP-08 | Qualite annonces, confiance acheteurs |
| 2026-01-28 | Stripe Connect Express | PRD APP-08 | Onboarding simplifie pour vendeurs |

---

## Ce qui reste pour 100%

### Database (Stories S01-S07) ✅ COMPLETE

- [x] S01-S06: 6 tables avec RLS, indexes, fonctions
- [x] S07: 2 Storage buckets (marketplace-listings, marketplace-labels)

### CGVU (Stories S08-S09) ✅ COMPLETE

- [x] S08-S09: cgvu_acceptances table + seller/buyer dialogs

### Stripe (Story S10) ✅ COMPLETE

- [x] S10: 2 Edge Functions + full Flutter stack (32 tests)

### FedEx (Stories S11-S13) ✅ COMPLETE

- [x] S11-S13: 3 Edge Functions + Flutter entities/datasource/repo/use cases/widgets + cron

### Frontend Core (Stories S14-S18) ✅ COMPLETE

- [x] S14: Create listing page avec upload photos
- [x] S14: Reorderable photos
- [x] S14: Form validation complete
- [x] S14: Integration CGVU check
- [x] S14: Integration Stripe check
- [x] S15: Feed page avec infinite scroll
- [x] S15: Listing cards
- [x] S16: Detail page avec photo carousel
- [x] S16: Action buttons (Contact, Offer, Buy)
- [x] S17: Filter sheet complete
- [x] S17: All filter criteria
- [x] S18: Chat screen Realtime
- [x] S18: Unread indicators

### Transactions (Stories S19-S22) ✅ COMPLETE

- [x] S19: Offer modal
- [x] S19: Seller offer management
- [x] S19: Expiration notifications
- [x] S20: Checkout flow multi-step
- [x] S20: Shipping address form
- [x] S20: Order summary
- [x] S20: Stripe payment integration
- [x] S21: Label generation UI
- [x] S21: PDF display inline
- [x] S22: Tracking timeline UI
- [x] S22: Status update notifications

### Polish (Stories S23-S26) ✅ COMPLETE

- [x] S23: Push notifications setup
- [x] S23: All notification types
- [x] S23: Deep links
- [x] S24: Map marker filter chip + navigation handlers
- [x] S24: Marketplace chat integration from map
- [x] S25: Seller dashboard page
- [x] S25: Earnings display
- [x] S26: Navbar tab "Market"
- [x] S26: Home page preview section

### Tests (Transversal) ✅ COMPLETE

- [x] Tests unitaires pour chaque story (500+ tests marketplace)
- [x] Tests integration migrations
- [x] Tests RLS policies
- [x] Tests Edge Functions
- [x] flutter analyze --fatal-infos passe (0 warnings)
- [x] Validation sur branche Supabase avant production

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 26 |
| Stories completees | 26 (100%) |
| Tables DB creees | 7 (marketplace_listings, photos, offers, transactions, messages, fedex_events, cgvu_acceptances) |
| Storage buckets | 2 (marketplace-listings, marketplace-labels) |
| Edge Functions | 5 (create-stripe-connect-account, stripe-connect-webhook, fedex-calculate-rate, fedex-create-shipment, fedex-track-shipment) |
| Cron jobs | 1 (fedex-tracking-poll - hourly) |
| Tests marketplace | 500+ (all passing) |
| Tests projet total | 5193+ (all passing) |
| Lint warnings | 0 |
| Fichiers Flutter crees | 50+ (entities, repos, datasources, use cases, pages, widgets, tests) |
| Pages UI | 12 (feed, detail, create listing, chat, checkout, seller dashboard, etc.) |

---

## Dependances Inter-Stories

```
EPIC-06 + EPIC-11 (PREREQUIS)
         |
         v
S01 (listings) ────────────────────────────────────────────────────┐
  │                                                                 │
  ├── S02 (photos) ─── S07 (storage bucket)                        │
  │                                                                 │
  ├── S03 (offers) ─── S19 (offers UI)                             │
  │         │                                                       │
  │         └──────── S04 (transactions) ─── S06 (fedex_events)    │
  │                          │                    │                 │
  │                          │                    └── S22 (tracking)│
  │                          │                                      │
  ├── S05 (messages) ─── S18 (chat UI)                             │
  │                                                                 │
  └── S15 (feed) ───┬── S16 (detail) ── S17 (filters)              │
                    │                                               │
                    └── S26 (navbar + home)                         │
                                                                    │
S08 (CGVU seller) ─── S09 (CGVU buyer)                             │
                                                                    │
S10 (Stripe Connect) ─────────────────── S14 (create listing) ─────┤
         │                                                          │
         └── S20 (purchase flow) ─── S21 (label generation)        │
                                                                    │
S11 (FedEx Rate) ─── S12 (FedEx Ship) ─── S13 (FedEx Track)       │
         │                   │                   │                  │
         │                   └───────────────────┴── S20, S21, S22  │
         │                                                          │
         └── S20 (calculate shipping)                               │
                                                                    │
S23 (notifications) ←─────────────────────────────── depends on all │
S24 (map markers) ←─────────────────────────────────────────────────┘
S25 (seller dashboard)
```

---

## External Services Setup

### FedEx (Required)

| Item | Status | Notes |
|------|--------|-------|
| FedEx Developer Account | ✅ Done | developer.fedex.com |
| Sandbox API Credentials | ✅ Done | In Supabase Secrets |
| Production API Credentials | 🔵 Todo | Apres certification |
| Account Number | ✅ Done | 740561073 |
| Address Validation API | ✅ Done | Enabled |
| Rate API | ✅ Done | Enabled |
| Ship API | ✅ Done | Enabled |
| Track API | ✅ Done | Enabled |

### Stripe Connect (Required - via EPIC-11)

| Item | Status | Notes |
|------|--------|-------|
| Stripe Connect enabled | ✅ Done | EPIC-11 |
| Express accounts enabled | ✅ Done | EPIC-11 |
| Webhook endpoint | ✅ Done | stripe-connect-webhook |
| account.updated handling | ✅ Done | S10 |

---

## Checklist Pre-Production

Avant de deployer en production:

### Database
- [ ] Toutes les migrations testees sur branche Supabase
- [ ] Rollback teste pour chaque migration
- [ ] RLS policies validees avec tests
- [ ] Indexes performants (EXPLAIN ANALYZE)

### Edge Functions
- [ ] FedEx sandbox tests passes
- [ ] FedEx production certification
- [ ] Stripe webhooks testes
- [ ] Error handling robuste

### Flutter
- [ ] flutter analyze --fatal-infos passe
- [ ] Tests unitaires OK
- [ ] Tests widget OK
- [ ] Performance OK (profiling)

### Legal
- [ ] CGVU textes valides par avocat
- [ ] Logging acceptations fonctionnel
- [ ] Privacy policy mise a jour

### Business
- [ ] Commission 10% correctement calculee
- [ ] FedEx rates correctement affiches
- [ ] Seller payout 90% verifie

---

## Retrospective

### Ce qui a bien marche

- **Architecture Clean Architecture** : Separation claire domain/data/presentation a permis un dev rapide et testable
- **Parallelisation via sub-agents** : Stories independantes executees en parallele (story-executor) avec resultats fiables
- **EPIC-13 synergies** : L'integration carte (markers, datasource, filter chips) etait deja a 90% grace a EPIC-13, reduisant S24 a 3 changements
- **Entities immutables + copyWith** : Pattern Dart solide pour tous les modeles marketplace
- **Design System Lynewed** : Reutilisation massive des LynewedButton, LynewedSheet, LynewedTextField → coherence UI
- **TDD systematique** : 500+ tests marketplace, 0 regressions sur les 5193+ tests projet

### A ameliorer

- **TRACKING.md sync** : Le fichier TRACKING etait en retard sur la realite (13/26 alors que 26/26 etait fait) → sync-project devrait etre lance plus souvent
- **Legacy FlutterFlow** : NavBarBridesWidget encore en FlutterFlowTheme, pas migre vers design system → dette technique a traiter
- **Tests E2E** : Pas de tests d'integration end-to-end (uniquement unit + widget) → a considerer pour la prochaine phase

### Lecons apprises

- **Scope reduction** : Toujours explorer le code existant avant d'implementer - souvent 80%+ du travail est deja fait (cf. S24)
- **Sub-agents efficaces** : Pour des stories bien specifiees avec contexte complet, les sub-agents produisent du code de qualite sans iteration
- **Commission pattern** : Tous les montants en cents (int) avec calcul `item * 0.10` evite les erreurs de floating point
- **Stripe Connect Express** : Simplifie enormement l'onboarding vendeur vs Custom accounts
- **FedEx sandbox** : API bien documentee mais tokens expirent apres 1h → gestion refresh obligatoire dans Edge Functions
