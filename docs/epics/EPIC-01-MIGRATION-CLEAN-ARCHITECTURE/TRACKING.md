# TRACKING - EPIC-01: Migration Clean Architecture

## Vue d'Ensemble

| Metrique | Valeur |
|----------|--------|
| **Total Stories** | 42 |
| **Completees** | 0 |
| **En Cours** | 0 |
| **En Attente** | 42 |
| **Progression** | 0% |

## Progression par Phase

### Phase 1 : Fondations (Stories S01-S04)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S01 | Setup infrastructure et conventions | TODO | - | - | - |
| S02 | Migration FlutterFlow utilities | TODO | - | - | - |
| S03 | Core design system extraction | TODO | - | - | - |
| S04 | Navigation system refactoring | TODO | - | - | - |

**Progression Phase 1** : 0/4 (0%)

---

### Phase 2 : Chat & Notifications (Stories S05-S10)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S05 | Chat - Domain layer completion | TODO | - | - | - |
| S06 | Chat - Data layer completion | TODO | - | - | - |
| S07 | Chat - Presentation layer completion | TODO | - | - | - |
| S08 | Notifications - Domain layer | TODO | - | - | - |
| S09 | Notifications - Data layer | TODO | - | - | - |
| S10 | Notifications - Presentation completion | TODO | - | - | - |

**Progression Phase 2** : 0/6 (0%)

---

### Phase 3 : Auth (Stories S11-S16)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S11 | Auth - Domain layer | TODO | - | - | - |
| S12 | Auth - Data layer | TODO | - | - | - |
| S13 | Auth - Presentation layer | TODO | - | - | - |
| S14 | Auth - Login/Signup pages | TODO | - | - | - |
| S15 | Auth - Password reset flow | TODO | - | - | - |
| S16 | Auth - Startup gate refactoring | TODO | - | - | - |

**Progression Phase 3** : 0/6 (0%)

---

### Phase 4 : My Wedding (Stories S17-S22)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S17 | My Wedding - Domain layer completion | TODO | - | - | - |
| S18 | My Wedding - Data layer completion | TODO | - | - | - |
| S19 | My Wedding - Onboarding flow | TODO | - | - | - |
| S20 | My Wedding - Team management | TODO | - | - | - |
| S21 | My Wedding - Inspirations/Albums | TODO | - | - | - |
| S22 | My Wedding - Agenda/Budget/Guests | TODO | - | - | - |

**Progression Phase 4** : 0/6 (0%)

---

### Phase 5 : Pages Legacy (Stories S23-S35)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S23 | Shared - Profile pages | TODO | - | - | - |
| S24 | Shared - Settings pages | TODO | - | - | - |
| S25 | Shared - Support page | TODO | - | - | - |
| S26 | Shared - Video call page | TODO | - | - | - |
| S27 | Shared - Content/Replay pages | TODO | - | - | - |
| S28 | Bride - Home page | TODO | - | - | - |
| S29 | Bride - Feed pages | TODO | - | - | - |
| S30 | Bride - Messages page wrapper | TODO | - | - | - |
| S31 | Bride - Edit profile | TODO | - | - | - |
| S32 | Pro - Dashboard page | TODO | - | - | - |
| S33 | Pro - Messages page wrapper | TODO | - | - | - |
| S34 | Pro - Wishlist page | TODO | - | - | - |
| S35 | Pro - Public profile view | TODO | - | - | - |

**Progression Phase 5** : 0/13 (0%)

---

### Phase 6 : Custom Code & Cleanup (Stories S36-S42)
| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| S36 | Custom Code - Chat actions migration | TODO | - | - | - |
| S37 | Custom Code - Notification actions migration | TODO | - | - | - |
| S38 | Custom Code - Profile actions migration | TODO | - | - | - |
| S39 | Custom Code - Widgets migration | TODO | - | - | - |
| S40 | Custom Code - Video/Media actions | TODO | - | - | - |
| S41 | Flutter Flow cleanup | TODO | - | - | - |
| S42 | Final cleanup et validation | TODO | - | - | - |

**Progression Phase 6** : 0/7 (0%)

---

## Blockers Actifs

| ID | Description | Story Impactee | Date Identifie | Responsable |
|----|-------------|----------------|----------------|-------------|
| - | Aucun blocker | - | - | - |

---

## Decisions Techniques

| Date | Decision | Justification | Stories Impactees |
|------|----------|---------------|-------------------|
| 2026-01-24 | Utiliser ChangeNotifier pour state simple, Cubit pour complexe | Coherence avec module Map existant | Toutes |
| 2026-01-24 | Maintenir wrappers legacy pour navigation | Eviter big bang migration | S04, Pages |
| 2026-01-24 | Ne pas toucher lib/backend/supabase/ | Backend stable, focus sur architecture | Toutes |

---

## Metriques de Qualite

### Tests
| Metrique | Objectif | Actuel |
|----------|----------|--------|
| Couverture domain | > 90% | - |
| Couverture data | > 80% | - |
| Couverture presentation | > 60% | - |

### Code
| Metrique | Objectif | Actuel |
|----------|----------|--------|
| Warnings flutter analyze | 0 | - |
| Lignes de code reduites | -30% | - |
| Modules migres | 100% | 0% |

---

## Journal des Mises a Jour

| Date | Mise a Jour | Auteur |
|------|-------------|--------|
| 2026-01-24 | Creation de l'Epic et structure initiale | PM |

---

## Prochaines Actions

1. [ ] Valider l'Epic avec l'equipe
2. [ ] Commencer par S01 : Setup infrastructure
3. [ ] Etablir les benchmarks de performance actuels
4. [ ] Planifier les tests E2E de regression
