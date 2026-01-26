# CROSS-EPIC - Coordination Inter-Epics

## Vue d'Ensemble

| Epic | Titre | Status | Progression |
|------|-------|--------|-------------|
| EPIC-01 | Migration Clean Architecture | ✅ COMPLETE | 42/42 (100%) |
| EPIC-02 | Tests additionnels | TODO | 0/7 (0%) |
| EPIC-03 | Dependencies update | TODO | 0/14 (0%) |
| EPIC-04 | Documentation | TODO | 0/5 (0%) |
| EPIC-05 | Security cleanup | TODO | 0/10 (0%) |

---

## EPIC-01: Migration Clean Architecture ✅

**Statut**: COMPLETE (2026-01-26)
**Durée**: 2 jours

### Résumé
Migration complète du code FlutterFlow legacy vers Clean Architecture, avec le module Map comme référence.

### Métriques Finales
- 42/42 stories complétées
- 3069 tests unitaires
- 0 warnings flutter analyze
- 14 modules features migrés

### Modules Créés
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

### Impact sur autres Epics
- EPIC-02 (Tests): Base testée, peut ajouter plus de couverture
- EPIC-05 (Security): Code mieux structuré facilite l'audit

---

## EPIC-02: Tests additionnels

**Statut**: TODO
**Dépendances**: EPIC-01 ✅

### Stories
1. Chat tests additionnels
2. Notifications tests
3. My Wedding domain tests
4. My Wedding data tests
5. Auth tests
6. Core utilities tests
7. Core design tests

---

## EPIC-03: Dependencies update

**Statut**: TODO
**Dépendances**: EPIC-01 ✅

### Stories (14)
Mise à jour des dépendances sécurité, utilities, UI, media, database, etc.

---

## EPIC-04: Documentation

**Statut**: TODO
**Dépendances**: EPIC-01 ✅

### Stories
1. README
2. Architecture
3. Contributing
4. API Documentation
5. ADRs

---

## EPIC-05: Security cleanup

**Statut**: TODO
**Dépendances**: EPIC-01 ✅

### Stories
- Secrets audit
- Input validation
- Auth flows
- Data exposure
- OWASP mobile
- Orphan files cleanup
- Unused functions
- Unused assets
- Unused dependencies
- FlutterFlow refactor

---

## Graphe de Dépendances

```
EPIC-01 (COMPLETE)
    ├── EPIC-02 (Tests)
    ├── EPIC-03 (Dependencies)
    ├── EPIC-04 (Documentation)
    └── EPIC-05 (Security)
```

Tous les Epics 02-05 dépendent de EPIC-01 maintenant complété.

---

## Journal

| Date | Événement |
|------|-----------|
| 2026-01-24 | Création EPIC-01 |
| 2026-01-25 | EPIC-01 S01-S29 complétées |
| 2026-01-26 | EPIC-01 S30-S42 complétées - EPIC TERMINÉ |
