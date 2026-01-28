# TRACKING - EPIC-11: Integration Stripe Complete

## Vue d'Ensemble

| Metrique | Valeur |
|----------|--------|
| **Total Stories** | 11 |
| **Completees** | 0 |
| **En Cours** | 0 |
| **A Faire** | 11 |
| **Progression** | 0% |

### Metriques de Validation (Cible)
| Metrique | Objectif | Resultat |
|----------|----------|----------|
| `flutter analyze` | 0 warnings | - |
| `flutter test` | 100% pass | - |
| Tables creees | 3 | 0/3 |
| RLS policies | 6 | 0/6 |
| Webhooks geres | 25+ | 0/25+ |
| Edge Function | 1 | 0/1 |

---

## Progression par Phase

### Phase 1 : Infrastructure Database (Stories S01-S03)

| Story | Titre | Statut | Points | Date Debut | Date Fin |
|-------|-------|--------|--------|------------|----------|
| S01 | Creer table `stripe_accounts` | TODO | 2 | - | - |
| S02 | Creer table `purchases` | TODO | 3 | - | - |
| S03 | Creer table `stripe_events` | TODO | 2 | - | - |

**Progression Phase 1** : 0/3 (0%)

**Dependances** : Aucune

**Deliverables** :
- [ ] Migration `create_stripe_accounts.sql`
- [ ] Migration `create_purchases.sql`
- [ ] Migration `create_stripe_events.sql`
- [ ] RLS policies pour chaque table
- [ ] Tests de validation RLS

---

### Phase 2 : Edge Function Core (Stories S04-S06)

| Story | Titre | Statut | Points | Date Debut | Date Fin |
|-------|-------|--------|--------|------------|----------|
| S04 | Edge Function `stripe-webhook` avec signature verification | TODO | 3 | - | - |
| S05 | Handlers `payment_intent.*` | TODO | 3 | - | - |
| S06 | Handlers `checkout.session.*` | TODO | 3 | - | - |

**Progression Phase 2** : 0/3 (0%)

**Dependances** : Phase 1 (tables doivent exister)

**Deliverables** :
- [ ] `supabase/functions/stripe-webhook/index.ts`
- [ ] Signature verification working
- [ ] Idempotency implemented
- [ ] 7 payment_intent handlers
- [ ] 4 checkout.session handlers
- [ ] Tests integration webhook

---

### Phase 3 : Connect & Marketplace (Stories S07-S09)

| Story | Titre | Statut | Points | Date Debut | Date Fin |
|-------|-------|--------|--------|------------|----------|
| S07 | Handler `account.updated` (Connect status) | TODO | 2 | - | - |
| S08 | Handlers `charge.dispute.*` | TODO | 3 | - | - |
| S09 | Handlers `payout.*` | TODO | 2 | - | - |

**Progression Phase 3** : 0/3 (0%)

**Dependances** : Phase 2 (Edge Function structure)

**Deliverables** :
- [ ] account.updated handler
- [ ] account.application.deauthorized handler
- [ ] 5 dispute handlers
- [ ] 5 payout handlers
- [ ] Notifications admin pour disputes
- [ ] Notifications seller pour payouts

---

### Phase 4 : Dart Layer (Stories S10-S11)

| Story | Titre | Statut | Points | Date Debut | Date Fin |
|-------|-------|--------|--------|------------|----------|
| S10 | Handlers transfers + refunds | TODO | 2 | - | - |
| S11 | Entites Dart et repository Stripe | TODO | 3 | - | - |

**Progression Phase 4** : 0/2 (0%)

**Dependances** : Phase 1 (tables), Phase 2-3 (Edge Function complete)

**Deliverables** :
- [ ] transfer.created handler
- [ ] transfer.reversed handler
- [ ] charge.refunded handler
- [ ] charge.refund.updated handler
- [ ] `lib/features/payments/domain/entities/stripe_account.dart`
- [ ] `lib/features/payments/domain/entities/purchase.dart`
- [ ] `lib/features/payments/domain/entities/purchase_status.dart`
- [ ] `lib/features/payments/domain/repositories/stripe_repository.dart`
- [ ] `lib/features/payments/data/repositories/supabase_stripe_repository.dart`
- [ ] `lib/features/payments/data/datasources/stripe_datasource.dart`
- [ ] Tests unitaires pour chaque entite
- [ ] Tests pour repository

---

## Resume des Webhooks a Implementer

### Checklist Webhooks

#### Payment Intents (7 events)
- [ ] `payment_intent.created`
- [ ] `payment_intent.processing`
- [ ] `payment_intent.succeeded`
- [ ] `payment_intent.payment_failed`
- [ ] `payment_intent.canceled`
- [ ] `payment_intent.amount_capturable_updated`
- [ ] `payment_intent.requires_action`

#### Checkout Sessions (4 events)
- [ ] `checkout.session.completed`
- [ ] `checkout.session.expired`
- [ ] `checkout.session.async_payment_succeeded`
- [ ] `checkout.session.async_payment_failed`

#### Connect Accounts (5 events)
- [ ] `account.updated`
- [ ] `account.application.deauthorized`
- [ ] `account.external_account.created`
- [ ] `account.external_account.updated`
- [ ] `account.external_account.deleted`

#### Transfers (3 events)
- [ ] `transfer.created`
- [ ] `transfer.updated`
- [ ] `transfer.reversed`

#### Disputes (5 events)
- [ ] `charge.dispute.created`
- [ ] `charge.dispute.updated`
- [ ] `charge.dispute.closed`
- [ ] `charge.dispute.funds_reinstated`
- [ ] `charge.dispute.funds_withdrawn`

#### Refunds (2 events)
- [ ] `charge.refunded`
- [ ] `charge.refund.updated`

#### Payouts (5 events)
- [ ] `payout.created`
- [ ] `payout.updated`
- [ ] `payout.paid`
- [ ] `payout.failed`
- [ ] `payout.canceled`

**Total Webhooks** : 31 types d'events

---

## Points de Vigilance

### Securite
- [ ] Signature verification TOUJOURS active
- [ ] Service role pour updates sensibles
- [ ] RLS bloque acces non autorises
- [ ] Pas de secrets en dur

### Performance
- [ ] Index sur stripe_event_id
- [ ] Index sur colonnes de recherche frequentes
- [ ] Idempotency pour eviter traitement en double

### Monitoring
- [ ] Logs d'erreur pour events echoues
- [ ] Compteur processing_attempts
- [ ] Alertes pour disputes et payout failures

---

## Blockers et Risques

| ID | Blocker/Risque | Statut | Resolution |
|----|----------------|--------|------------|
| B1 | STRIPE_SECRET_KEY absent | OPEN | Configurer dans Supabase secrets |
| B2 | STRIPE_WEBHOOK_SECRET absent | OPEN | Configurer apres creation endpoint |
| B3 | Test mode vs Live mode | OPEN | Utiliser test mode pour dev |

---

## Notes de Session

### Session 1 - 2026-01-28 : Creation Epic
- Creation de EPIC-11-STRIPE.md
- Creation de TRACKING.md
- Creation de sources.yaml
- Definition des 11 stories
- Schema complet des tables

### Prochaines Actions
1. Executer S01 (table stripe_accounts)
2. Executer S02 (table purchases)
3. Executer S03 (table stripe_events)
4. Deployer Edge Function (S04)

---

## Historique des Changements

| Date | Story | Action | Details |
|------|-------|--------|---------|
| 2026-01-28 | EPIC | Creation | Epic et stories definies |

---

## Validation Finale

### Pre-Merge Checklist
- [ ] Toutes les migrations testees sur dev
- [ ] Rollback teste pour chaque migration
- [ ] RLS policies validees avec tests
- [ ] Edge Function deployee et testee
- [ ] Webhooks configures dans Stripe Dashboard
- [ ] No flutter analyze warnings
- [ ] Production backup cree

### Post-Merge Checklist
- [ ] Tables existent en production
- [ ] Edge Function repond aux webhooks
- [ ] Logs d'events fonctionnels
- [ ] Notifications envoyees correctement
- [ ] Documentation a jour
