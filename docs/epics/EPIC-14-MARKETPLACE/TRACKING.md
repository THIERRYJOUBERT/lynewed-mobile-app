# TRACKING - EPIC-14-MARKETPLACE

> Status : 🔵 Draft
> Stories : 0/26 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Marketplace Robes & Chaussures (APP-08) |
| - | - |

---

## Progression Stories

### Phase 1: Database Foundation

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Table marketplace_listings | 🔵 Todo | - | - | - | FONDATION - toutes autres stories dependent |
| S02 - Table marketplace_photos | 🔵 Todo | - | - | - | Depend de S01 |
| S03 - Table marketplace_offers | 🔵 Todo | - | - | - | Depend de S01 |
| S04 - Table marketplace_transactions | 🔵 Todo | - | - | - | Depend de S01, S03 |
| S05 - Table marketplace_messages | 🔵 Todo | - | - | - | Depend de S01 |
| S06 - Table fedex_events | 🔵 Todo | - | - | - | Depend de S04 |
| S07 - Bucket marketplace-listings | 🔵 Todo | - | - | - | Depend de S01 |

### Phase 2: CGVU & Stripe

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S08 - CGVU marketplace seller | 🔵 Todo | - | - | - | Independant |
| S09 - CGVU marketplace buyer | 🔵 Todo | - | - | - | Depend de S08 (shared table) |
| S10 - Stripe Connect onboarding | 🔵 Todo | - | - | - | BLOQUANT - Depend EPIC-11 |

### Phase 3: FedEx Integration

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S11 - Edge Function FedEx Rate | 🔵 Todo | - | - | - | Independant |
| S12 - Edge Function FedEx Ship | 🔵 Todo | - | - | - | Depend de S11 |
| S13 - Edge Function FedEx Track | 🔵 Todo | - | - | - | Depend de S12 |

### Phase 4: Frontend Core

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S14 - Formulaire creation annonce | 🔵 Todo | - | - | - | Depend de S01, S02, S07, S08, S10 |
| S15 - Page liste annonces (feed) | 🔵 Todo | - | - | - | Depend de S01 |
| S16 - Page detail annonce | 🔵 Todo | - | - | - | Depend de S01, S02 |
| S17 - Systeme de filtres | 🔵 Todo | - | - | - | Depend de S15 |
| S18 - Chat buyer/seller | 🔵 Todo | - | - | - | Depend de S05 |

### Phase 5: Transactions

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S19 - Systeme d'offres | 🔵 Todo | - | - | - | Depend de S03 |
| S20 - Flow achat complet | 🔵 Todo | - | - | - | Depend de S04, S09, S10, S11 |
| S21 - Generation etiquette FedEx | 🔵 Todo | - | - | - | Depend de S12 |
| S22 - Tracking colis | 🔵 Todo | - | - | - | Depend de S06, S13 |

### Phase 6: Polish

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S23 - Notifications marketplace | 🔵 Todo | - | - | - | Depend de S19, S20 |
| S24 - Marqueurs carte | 🔵 Todo | - | - | - | Depend de S01, EPIC-13 (optionnel) |
| S25 - Page "Mes ventes" | 🔵 Todo | - | - | - | Depend de S01, S04 |
| S26 - Navbar + Home preview | 🔵 Todo | - | - | - | Depend de S15 |

---

## Prerequis Inter-Epics

| Epic | Status | Impact sur EPIC-14 |
|------|--------|-------------------|
| EPIC-06 Prerequisites | 🔵 Todo | BLOQUANT - Enum userRole, invite_code |
| EPIC-11 Stripe Integration | 🔵 Todo | BLOQUANT - Tables stripe_accounts, purchases, stripe_events |
| EPIC-13 Map Filters | 🔵 Todo | OPTIONNEL - S24 (marqueurs map) peut etre fait sans |

**Action requise** : Completer EPIC-06 et EPIC-11 AVANT de commencer EPIC-14

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

### Database (Stories S01-S07)

- [ ] S01: Table marketplace_listings avec tous attributs
- [ ] S01: RLS policies (5 policies)
- [ ] S01: Indexes optimises
- [ ] S02: Table marketplace_photos avec CASCADE
- [ ] S02: RLS suivant acces listing parent
- [ ] S03: Table marketplace_offers avec expiration 48h
- [ ] S03: Fonction expire_marketplace_offers
- [ ] S04: Table marketplace_transactions complete
- [ ] S04: Contrainte commission 10%
- [ ] S04: Fonction complete_delivered_transactions
- [ ] S05: Table marketplace_messages avec Realtime
- [ ] S06: Table fedex_events audit log
- [ ] S07: Bucket marketplace-listings (20MB, MIME types)
- [ ] S07: RLS policies storage (4 policies)

### CGVU (Stories S08-S09)

- [ ] S08: Table cgvu_acceptances (si pas dans EPIC-11)
- [ ] S08: Modal CGVU seller avec scroll detection
- [ ] S08: Logging complet (IP, user_agent, device_info)
- [ ] S09: Modal CGVU buyer
- [ ] S09: Integration checkout flow

### Stripe (Story S10)

- [ ] S10: Edge Function create-stripe-connect-account
- [ ] S10: Webhook handler account.updated
- [ ] S10: UI statut compte vendeur
- [ ] S10: Blocage publication si charges_enabled = false

### FedEx (Stories S11-S13)

- [ ] S11: Edge Function fedex-calculate-rate
- [ ] S11: Address validation integration
- [ ] S11: Multi-service rates (Ground, Express)
- [ ] S12: Edge Function fedex-create-shipment
- [ ] S12: PDF label generation
- [ ] S12: Email sending with PDF
- [ ] S13: Edge Function fedex-track (ou webhook handler)
- [ ] S13: Transaction status updates
- [ ] S13: fedex_events logging

### Frontend Core (Stories S14-S18)

- [ ] S14: Create listing page avec upload photos
- [ ] S14: Reorderable photos
- [ ] S14: Form validation complete
- [ ] S14: Integration CGVU check
- [ ] S14: Integration Stripe check
- [ ] S15: Feed page avec infinite scroll
- [ ] S15: Listing cards
- [ ] S16: Detail page avec photo carousel
- [ ] S16: Action buttons (Contact, Offer, Buy)
- [ ] S17: Filter sheet complete
- [ ] S17: All filter criteria
- [ ] S18: Chat screen Realtime
- [ ] S18: Unread indicators

### Transactions (Stories S19-S22)

- [ ] S19: Offer modal
- [ ] S19: Seller offer management
- [ ] S19: Expiration notifications
- [ ] S20: Checkout flow multi-step
- [ ] S20: Shipping address form
- [ ] S20: Order summary
- [ ] S20: Stripe payment integration
- [ ] S21: Label generation UI
- [ ] S21: PDF display inline
- [ ] S22: Tracking timeline UI
- [ ] S22: Status update notifications

### Polish (Stories S23-S26)

- [ ] S23: Push notifications setup
- [ ] S23: All notification types
- [ ] S23: Deep links
- [ ] S24: Map marker icons (dress/shoes)
- [ ] S24: Marker tap handler
- [ ] S25: Seller dashboard page
- [ ] S25: Earnings display
- [ ] S26: Navbar tab
- [ ] S26: Home page preview section

### Tests (Transversal)

- [ ] Tests unitaires pour chaque story
- [ ] Tests integration migrations
- [ ] Tests RLS policies
- [ ] Tests Edge Functions
- [ ] flutter analyze --fatal-infos passe
- [ ] Validation sur branche Supabase avant production

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 26 |
| Stories completees | 0 |
| Migrations SQL | 7 (S01-S07) |
| Edge Functions | 4 (Stripe + 3 FedEx) |
| Policies RLS | ~20 (tables + storage) |
| Tests a ajouter | ~50 (estimes) |
| Temps estime | 7 jours |

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
| FedEx Developer Account | 🔵 Todo | Creer sur developer.fedex.com |
| Sandbox API Credentials | 🔵 Todo | Client ID, Secret |
| Production API Credentials | 🔵 Todo | Apres certification |
| Account Number | 🔵 Todo | Fourni par Thierry |
| Address Validation API | 🔵 Todo | Enable in dashboard |
| Rate API | 🔵 Todo | Enable in dashboard |
| Ship API | 🔵 Todo | Enable in dashboard |
| Track API | 🔵 Todo | Enable in dashboard |

### Stripe Connect (Required - via EPIC-11)

| Item | Status | Notes |
|------|--------|-------|
| Stripe Connect enabled | 🔵 Todo | EPIC-11 |
| Express accounts enabled | 🔵 Todo | EPIC-11 |
| Webhook endpoint | 🔵 Todo | EPIC-11 |
| account.updated handling | 🔵 Todo | S10 |

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

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
