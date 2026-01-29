# CROSS-EPIC - Coordination Inter-Epics

## Vue d'Ensemble

### Phase 1 : Foundation (COMPLETE) ✅ → [Archive](#archive---phase-1--foundation)

| Epic | Titre | Status | Progression |
|------|-------|--------|-------------|
| EPIC-01 | Migration Clean Architecture | ✅ COMPLETE | 42/42 (100%) |
| EPIC-02 | Tests additionnels | ✅ COMPLETE | 7/7 (100%) |
| EPIC-03 | Dependencies update | ⏸️ PARTIAL | 9/14 (64%) |
| EPIC-04 | Documentation | ✅ COMPLETE | 5/5 (100%) |
| EPIC-05 | Security cleanup | ✅ COMPLETE | 10/10 (100%) |

### Phase 2 : Mission 2026 (ACTIVE)

| Epic | PRD | Titre | Status | Stories | Est. |
|------|-----|-------|--------|---------|------|
| **EPIC-06** | APP-00 | Prerequisites Migration | 🟢 DONE | 6 | 0.5j |
| **EPIC-07** | APP-01 | Reviews (Avis clients) | 🔵 DRAFT | 9 | 0.5j |
| **EPIC-08** | APP-02 | Reminders (Rappels RDV) | 🔵 DRAFT | 8 | 0.5j |
| **EPIC-09** | APP-03 | Invitations (Guests) | 🔵 DRAFT | 12 | 2j |
| **EPIC-10** | APP-04 | Photos/Videos | 🔵 DRAFT | 10 | 1.5j |
| **EPIC-11** | APP-05 | Stripe Integration | 🔵 DRAFT | 12 | 1j |
| **EPIC-12** | APP-06 | Reels Generation | 🔵 DRAFT | 14 | 1.5j |
| **EPIC-13** | APP-07 | Map Filters | 🔵 DRAFT | 9 | 1j |
| **EPIC-14** | APP-08 | Marketplace | 🔵 DRAFT | 26 | 7j |

**Total Mission 2026** : 106 stories, 15 jours estimés, 4500€

---

## Mission 2026 - Epics Actifs

### EPIC-06: Prerequisites Migration (APP-00) 🟢

**Statut**: DONE (2026-01-29) | **Déployé en Production**
**Stories**: 6 (5/6 complètes, S06 partiel - manuel requis)
**Estimation**: 0.5 jour | **Durée réelle**: ~1 jour

Migration des prerequis techniques CRITIQUES déployée en production :
- ✅ Enum userRole + 'guest' (Dart + Postgres)
- ✅ Colonnes invitation (invite_code, expires_at) sur weddings
- ✅ Table invitation_attempts avec rate limiting
- ✅ Fonction generate_secure_invite_code + trigger
- ✅ Colonnes invitation sur wedding_guests
- 🟡 Bucket wedding-media (création manuelle via Dashboard requise)

**Documentation**:
- Bilan: `EPIC-06-BILAN.md`
- Déploiement S02-S05: `S02-S05-DEPLOYMENT.md`
- Guide S06 manuel: `S06-manual-steps.md`

---

### EPIC-07: Reviews (APP-01) 🔵

**Statut**: DRAFT | **Dépendances**: Aucune
**Stories**: 9 | **Estimation**: 0.5 jour

Systeme d'avis clients interne Lynewed :
- Table reviews (1-5 etoiles + commentaire)
- Vue pro_ratings (moyenne, count)
- UI soumission + affichage profil
- Filtre minRating sur Map

---

### EPIC-08: Reminders (APP-02) 🔵

**Statut**: DRAFT | **Dépendances**: Aucune
**Stories**: 8 | **Estimation**: 0.5 jour

Notifications de rappel RDV :
- Table scheduled_notifications
- pg_cron pour envoi programme
- Templates J-7, J-1, H-2
- Preferences utilisateur

---

### EPIC-09: Invitations (APP-03) 🔵

**Statut**: DRAFT | **Dépendances**: EPIC-06 (S01-S05)
**Stories**: 12 | **Estimation**: 2 jours

Systeme d'invitations guests :
- Envoi email avec code/QR
- Onboarding guest simplifie
- Interface guest limitee (3 tabs)
- Chat groupe mariage (wedding_team)

---

### EPIC-10: Photos/Videos (APP-04) 🔵

**Statut**: DRAFT | **Dépendances**: EPIC-06 (S06)
**Stories**: 10 | **Estimation**: 1.5 jours

Projet Photo & Video :
- Upload videos (max 10min, 500MB)
- Legendes sur medias
- Album guest separe
- Partage opt-in avec bride

---

### EPIC-11: Stripe Integration (APP-05) 🔵

**Statut**: DRAFT | **Dépendances**: Aucune
**Stories**: 12 | **Estimation**: 1 jour

Integration Stripe complete :
- Stripe Connect Express (vendeuses)
- Tables stripe_accounts, purchases, stripe_events
- Webhook handler (tous events)
- Edge Function stripe-webhook

---

### EPIC-12: Reels Generation (APP-06) 🔵

**Statut**: DRAFT | **Dépendances**: EPIC-06 → EPIC-10 → EPIC-11 (ordre strict)
**Stories**: 13 (S00-S12 + S01b) | **Estimation**: 1.5 jours

Generation de reels :
- Guest: ses propres videos uniquement
- Bride: toutes videos + guests partages
- **Shotstack API** (cloud video processing - remplace FFmpeg)
- Cleanup automatique 7 jours
- CGVU acceptance avec version tracking

---

### EPIC-13: Map Filters (APP-07) 🔵

**Statut**: DRAFT | **Dépendances**: EPIC-07 (minRating)
**Stories**: 9 | **Estimation**: 1 jour

Filtres Map additionnels :
- offers_free_wedding_book
- offers_free_trailer
- minRating (1-5)
- Marqueur marketplace

---

### EPIC-14: Marketplace (APP-08) 🔵

**Statut**: DRAFT | **Dépendances**: EPIC-06, EPIC-11, EPIC-13
**Stories**: 26 | **Estimation**: 7 jours

Marketplace Robes & Chaussures :
- 7 tables (listings, photos, offers, transactions, messages, fedex_events, cgvu_acceptances)
- Stripe Connect 10% commission
- FedEx worldwide shipping
- Nouvel onglet navbar bride

---

## Graphe de Dépendances

```
PHASE 1 : FOUNDATION (COMPLETE)
═══════════════════════════════

EPIC-01 (COMPLETE) ──┬── EPIC-02 (COMPLETE)
                     ├── EPIC-03 (PARTIAL 64%)
                     ├── EPIC-04 (COMPLETE)
                     └── EPIC-05 (COMPLETE)


PHASE 2 : MISSION 2026
══════════════════════

                            EPIC-07 (Reviews)
                           /
EPIC-06 (Prerequisites) ──┼── EPIC-08 (Reminders) ────────────────────────┐
   APP-00 BLOQUANT        │                                                │
                          ├── EPIC-09 (Invitations) ──► EPIC-10 (Photos) ──┤
                          │                                                │
                          │                              EPIC-12 (Reels) ◄─┘
                          │                                    │
EPIC-11 (Stripe) ─────────┼────────────────────────────────────┤
   Independant            │                                    │
                          └── EPIC-13 (Map Filters) ◄─ EPIC-07 │
                                    │                          │
                                    └───────► EPIC-14 (Marketplace)
                                              26 stories, 7 jours

ORDRE D'EXECUTION RECOMMANDE :
1. EPIC-06 (BLOQUANT - tous les autres en dépendent)
2. EPIC-07, EPIC-08 (parallelisables, sans dépendances)
3. EPIC-09 (dépend de EPIC-06)
4. EPIC-11 (Stripe - peut démarrer en parallèle)
5. EPIC-10 (dépend de EPIC-06, EPIC-09)
6. EPIC-12 (dépend de EPIC-06 → EPIC-10 → EPIC-11, utilise Shotstack API)
7. EPIC-13 (dépend de EPIC-07 pour minRating - feature flags si pas prêt)
8. EPIC-14 (le plus gros - dépend de EPIC-06, EPIC-11, EPIC-13)
```

---

## Journal

| Date | Événement |
|------|-----------|
| 2026-01-24 | Création EPIC-01 |
| 2026-01-25 | EPIC-01 S01-S29 complétées |
| 2026-01-25 | SESSION iOS BUILD FIX (flutter_dotenv revert) |
| 2026-01-26 | EPIC-01 S30-S42 complétées - EPIC TERMINÉ |
| 2026-01-26 | EPIC-02 et EPIC-05 marqués COMPLETE |
| 2026-01-26 | EPIC-04 challengé --deep, corrections appliquées |
| 2026-01-26 | EPIC-04 complété - Documentation production-ready |
| 2026-01-28 | EPIC-06 créé - Prerequisites Migration (APP-00) - Mission 2026 |
| 2026-01-28 | EPIC-07 à EPIC-14 créés - Mission 2026 complète (9 Epics, 102 stories) |
| 2026-01-28 | Challenge Deep /challenge --deep (EPIC-06 à EPIC-14) - Score 82→92/100 |
| 2026-01-28 | Corrections appliquées : FFmpeg→Shotstack, TIMESTAMPTZ, RLS, Storage cleanup, FedEx docs |
| 2026-01-28 | Reorganisation CROSS-EPIC : Phase 1 (EPIC-01 à 05) déplacée en archive |
| 2026-01-28 | **Stories créées** : 106 stories INVEST via 9 agents Opus parallèles (EPIC-06 à EPIC-14) |
| 2026-01-29 | **EPIC-06 TERMINÉ** : 5/6 stories déployées en production (LYNEWED-V1-APP) |
| 2026-01-29 | S06 partiel : Bucket wedding-media nécessite création manuelle via Dashboard |

---

## Archive - Phase 1 : Foundation

> Epics complétés de la phase de refonte technique (2026-01-24 à 2026-01-26)

### EPIC-01: Migration Clean Architecture ✅

**Statut**: COMPLETE (2026-01-26)
**Durée**: 2 jours

#### Résumé
Migration complète du code FlutterFlow legacy vers Clean Architecture, avec le module Map comme référence.

#### Métriques Finales
- 42/42 stories complétées
- 3069 tests unitaires
- 0 warnings flutter analyze
- **15 modules features** (auth, chat, content, dashboard, feed, home, map, my_wedding, notifications, profile, settings, support, video_call, weddings_hub_pro, wishlist)

#### Modules Créés
| Module | Description |
|--------|-------------|
| auth | Authentification complète |
| chat | Messagerie temps réel |
| content | Articles/Replays/Vidéos |
| dashboard | Dashboard pro |
| feed | Feed de professionnels |
| home | Page d'accueil mariées |
| map | Carte (référence) |
| my_wedding | Gestion du mariage |
| notifications | Système de notifications |
| profile | Profil utilisateur |
| settings | Paramètres |
| support | Support/FAQ |
| video_call | Appels vidéo Agora |
| wishlist | Liste de favoris pro |
| weddings_hub_pro | Hub mariages côté pro |

#### Impact sur autres Epics
- EPIC-02 (Tests): ✅ Complété - 3069 tests
- EPIC-05 (Security): ✅ Complété - Secrets migrés, input validation

---

### EPIC-02: Tests additionnels ✅

**Statut**: COMPLETE
**Dépendances**: EPIC-01 ✅

#### Résumé
Tests additionnels couvrant tous les modules Clean Architecture.

#### Métriques
- 7/7 stories complétées
- 3069 tests totaux

---

### EPIC-03: Dependencies update ⏸️

**Statut**: PARTIAL (64%)
**Dépendances**: EPIC-01 ✅

#### Progression
- 9/14 stories complétées
- 25+ packages mis à jour
- Firebase 4.x, Supabase 2.12
- En pause: certaines dépendances nécessitent migration majeure

---

### EPIC-04: Documentation ✅

**Statut**: COMPLETE (2026-01-26)
**Dépendances**: EPIC-01 ✅, EPIC-05 ✅

#### Stories (5)
1. S01: README complet
2. S02: Architecture (15 modules, 16 Edge Functions)
3. S03: Contributing
4. S04: API Documentation (11 repos, 5 services)
5. S05: ADRs (6 ADRs incluant ADR-006 secrets)

#### Notes Post-Challenge
- Statistiques corrigées (données réelles du codebase)
- ADR-006 ajouté (flutter_dotenv vs --dart-define)
- iOS 15.0 minimum documenté

---

### EPIC-05: Security cleanup ✅

**Statut**: COMPLETE
**Dépendances**: EPIC-01 ✅

#### Résumé
- Secrets migrés (flutter_dotenv - voir ADR-006)
- Input validation
- Auth flows sécurisés
- OWASP compliance
- Cleanup fichiers orphelins
