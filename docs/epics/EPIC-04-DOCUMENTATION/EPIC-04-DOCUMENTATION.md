# EPIC-04: Documentation Projet Lynewed

**Version:** 1.0
**Date de creation:** 2025-01-24
**Statut:** A faire
**Priorite:** Haute

---

## Resume

Creer une documentation complete et maintenable pour le projet Lynewed afin de faciliter l'onboarding des nouveaux developpeurs, documenter les decisions architecturales, et assurer la perennite du projet.

---

## Contexte

### Problematique

Le projet Lynewed est une application Flutter mature (v1.2.4+70) en production avec:
- ~71,500 lignes de code Dart
- ~400 fichiers Dart
- Architecture Clean Architecture
- Backend Supabase avec 58 migrations
- Integration de 4 APIs externes (Supabase, Google Places, Agora, FCM)

**Probleme:** La documentation actuelle est fragmentee et incomplete:
- README.md basique sans instructions detaillees d'installation
- Pas de guide de contribution
- Architecture documentee partiellement dans `docs/PROJECT.md`
- Pas d'ADRs (Architecture Decision Records)
- Documentation API inexistante

### Impact

- **Onboarding difficile:** Un nouveau developpeur met plusieurs jours a comprendre le projet
- **Decisions perdues:** Les choix architecturaux ne sont pas documentes
- **Maintenance complexe:** Difficulte a maintenir le code sans contexte
- **Bus factor:** Dependance excessive aux developpeurs actuels

---

## Objectifs

1. **README complet:** Installation en moins de 30 minutes pour un nouveau dev
2. **Architecture claire:** Comprendre la structure en lisant un seul document
3. **Guide de contribution:** Standards et conventions documentees
4. **Documentation API:** Reference des services et repositories
5. **ADRs:** Tracer les decisions architecturales importantes

---

## Perimetre

### Inclus

| Document | Description | Priorite |
|----------|-------------|----------|
| `README.md` | Setup, installation, commandes | P1 - Critique |
| `ARCHITECTURE.md` | Structure projet, patterns, modules | P1 - Critique |
| `CONTRIBUTING.md` | Guide contribution, conventions | P2 - Important |
| `docs/api/` | Documentation services/repositories | P2 - Important |
| `docs/decisions/` | ADRs pour decisions cles | P3 - Nice-to-have |

### Exclus

- Documentation utilisateur (UI/UX)
- Documentation Supabase (deja dans migrations)
- Tutoriels video
- Documentation marketing

---

## Stories

| ID | Titre | Points | Priorite | Dependances |
|----|-------|--------|----------|-------------|
| S01 | README.md complet | 3 | P1 | - |
| S02 | ARCHITECTURE.md | 5 | P1 | - |
| S03 | CONTRIBUTING.md | 3 | P2 | S01 |
| S04 | Documentation API | 5 | P2 | S02 |
| S05 | ADRs initiaux | 3 | P3 | S02 |

**Total:** 19 points

---

## Criteres de succes

- [ ] Un nouveau developpeur peut installer et lancer le projet en < 30 min avec le README
- [ ] L'architecture est comprehensible sans lire le code
- [ ] Les conventions de code sont documentees
- [ ] Les services principaux ont une documentation d'utilisation
- [ ] Les 5 decisions architecturales majeures sont documentees en ADR

---

## Stack Technique Documentee

### Frontend Flutter
- **Version:** Flutter 3.32.4, Dart SDK >=3.0.0 <4.0.0
- **Architecture:** Clean Architecture (domain/data/presentation)
- **State Management:** Provider, Cubit
- **Navigation:** GoRouter
- **Design System:** Custom (`lib/core/design/`)

### Backend Supabase
- **Database:** PostgreSQL avec PostGIS
- **Auth:** Supabase Auth + Apple Sign-In
- **Storage:** Buckets pour images/videos
- **Edge Functions:** 17 fonctions TypeScript
- **Security:** Row Level Security (RLS)

### Integrations
- **Google Places SDK:** Recherche de lieux
- **Agora RTC:** Appels video
- **Firebase FCM:** Push notifications
- **Resend:** Emails transactionnels

---

## Risques

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Documentation obsolete rapidement | Moyen | Haute | Regles de mise a jour dans CONTRIBUTING |
| Trop de details = maintenance lourde | Moyen | Moyenne | Documenter le "pourquoi" pas le "comment" |
| Documentation non lue | Faible | Moyenne | README concis, liens pertinents |

---

## Timeline Suggeree

| Semaine | Stories | Objectif |
|---------|---------|----------|
| 1 | S01, S02 | Documentation critique |
| 2 | S03, S04 | Guide contribution + API |
| 3 | S05 | ADRs |

---

## References

- `docs/PROJECT.md` - Etat actuel du projet
- `docs/App/DESIGN_SYSTEM.md` - Design System (1041 lignes)
- `docs/App/APP_SOURCE_OF_TRUTH.md` - Flows applicatifs
- `.claude/context/SYSTEM.md` - Architecture workflows Claude
