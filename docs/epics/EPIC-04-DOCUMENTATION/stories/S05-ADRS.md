# Story S05: Architecture Decision Records (ADRs)

**Epic:** EPIC-04-DOCUMENTATION
**ID:** S05
**Points:** 3
**Priorite:** P3 - Nice-to-have
**Statut:** A faire
**Dependances:** S02 (ARCHITECTURE)

---

## Description

En tant que **developpeur ou mainteneur** du projet Lynewed,
je veux des **Architecture Decision Records (ADRs)** documentant les decisions techniques majeures
afin de **comprendre pourquoi certains choix ont ete faits et eviter de les remettre en question sans contexte**.

---

## Criteres d'Acceptance

- [ ] Template ADR cree et documente
- [ ] ADR-001: Choix de Clean Architecture
- [ ] ADR-002: Migration FlutterFlow vers code natif
- [ ] ADR-003: Choix Supabase comme backend
- [ ] ADR-004: Design System unifie
- [ ] ADR-005: Strategie de gestion d'etat (Provider/Cubit)
- [ ] Index des ADRs avec statuts

---

## Contenu Attendu

### Structure des Fichiers

```
docs/decisions/
├── INDEX.md           # Liste de tous les ADRs
├── TEMPLATE.md        # Template pour nouveaux ADRs
├── ADR-001-clean-architecture.md
├── ADR-002-flutterflow-migration.md
├── ADR-003-supabase-backend.md
├── ADR-004-design-system.md
└── ADR-005-state-management.md
```

### Template ADR (TEMPLATE.md)

```markdown
# ADR-XXX: [Titre de la Decision]

**Date:** YYYY-MM-DD
**Statut:** [Propose | Accepte | Deprecie | Remplace par ADR-XXX]
**Decideurs:** [Noms ou roles]

## Contexte

[Description du probleme ou de la situation qui necessite une decision]

## Decision

[La decision prise, en termes clairs]

## Consequences

### Positives
- [Avantage 1]
- [Avantage 2]

### Negatives
- [Inconvenient 1]
- [Inconvenient 2]

### Risques
- [Risque identifie et mitigation]

## Alternatives Considerees

### Alternative 1: [Nom]
- **Description:** [Breve description]
- **Avantages:** [Liste]
- **Inconvenients:** [Liste]
- **Raison du rejet:** [Pourquoi non retenue]

### Alternative 2: [Nom]
- ...

## References

- [Lien vers documentation]
- [Lien vers discussion]
```

### ADRs a Creer

#### ADR-001: Adoption de Clean Architecture

**Contexte:**
- Projet initialement genere avec FlutterFlow
- Code difficile a maintenir et tester
- Besoin de separation claire des responsabilites

**Decision:**
Adopter Clean Architecture avec 3 couches: Domain, Data, Presentation

**Consequences positives:**
- Code testable (63 tests sur module Map)
- Modules independants
- Facilite l'onboarding

**Consequences negatives:**
- Plus de fichiers/boilerplate
- Courbe d'apprentissage

---

#### ADR-002: Migration FlutterFlow vers Code Natif

**Contexte:**
- Prototype initial construit avec FlutterFlow
- Limitations de customisation
- Code genere difficile a maintenir

**Decision:**
Migrer progressivement vers du code Flutter natif tout en conservant certains utilitaires FlutterFlow

**Consequences positives:**
- Controle total du code
- Meilleure performance
- Customisation illimitee

**Consequences negatives:**
- Temps de migration (40,588 lignes supprimees)
- Legacy code a maintenir (`lib/flutter_flow/`, `lib/pages/`)

---

#### ADR-003: Supabase comme Backend

**Contexte:**
- Besoin d'un backend rapide a deployer
- Fonctionnalites requises: Auth, DB, Storage, Realtime, Edge Functions
- Equipe petite, besoin de productivite

**Decision:**
Utiliser Supabase (PostgreSQL + PostGIS + Auth + Storage + Edge Functions)

**Consequences positives:**
- Setup rapide
- PostgreSQL robuste avec PostGIS pour geodonnees
- Realtime natif pour chat
- Edge Functions pour logique serveur

**Consequences negatives:**
- Vendor lock-in partiel
- Limites du plan gratuit
- Complexite RLS

---

#### ADR-004: Design System Unifie

**Contexte:**
- UI inconsistante entre les ecrans
- Duplication de styles
- Difficulte a maintenir la coherence visuelle

**Decision:**
Creer un Design System unifie dans `lib/core/design/` avec tokens et composants

**Consequences positives:**
- UI coherente
- Developpement plus rapide
- Maintenance simplifiee

**Consequences negatives:**
- Effort initial de creation
- Discipline requise pour utiliser le systeme

---

#### ADR-005: Strategie de State Management

**Contexte:**
- Besoin de gerer l'etat global (user, preferences)
- Besoin de gerer l'etat local (listes, formulaires)
- FlutterFlow utilisait Provider

**Decision:**
- **Provider** pour l'etat global (FFAppState)
- **Cubit** pour l'etat des features (chat, etc.)
- **ValueNotifier** pour l'etat local simple

**Consequences positives:**
- Flexibilite selon le use case
- Cubit testable et predictible
- Provider familier de l'equipe

**Consequences negatives:**
- Multiple patterns a connaitre
- Pas de solution unique

---

### INDEX.md

```markdown
# Architecture Decision Records

## Qu'est-ce qu'un ADR?

Un ADR documente une decision architecturale importante, son contexte, et ses consequences.

## Liste des ADRs

| ID | Titre | Statut | Date |
|----|-------|--------|------|
| [ADR-001](./ADR-001-clean-architecture.md) | Clean Architecture | Accepte | 2025-01 |
| [ADR-002](./ADR-002-flutterflow-migration.md) | Migration FlutterFlow | Accepte | 2025-01 |
| [ADR-003](./ADR-003-supabase-backend.md) | Backend Supabase | Accepte | 2025-01 |
| [ADR-004](./ADR-004-design-system.md) | Design System Unifie | Accepte | 2025-01 |
| [ADR-005](./ADR-005-state-management.md) | State Management | Accepte | 2025-01 |

## Creer un nouvel ADR

1. Copier [TEMPLATE.md](./TEMPLATE.md)
2. Nommer `ADR-XXX-[titre-court].md`
3. Remplir toutes les sections
4. Soumettre en PR pour review
5. Mettre a jour cet INDEX
```

---

## Notes Techniques

### Sources d'Information
- `docs/PROJECT.md` - Historique du projet
- `docs/archive/` - Documentation archivee
- Discussions avec l'equipe fondatrice

### Points d'Attention
- Documenter les decisions PASSEES, pas speculer sur le futur
- Etre objectif sur les inconvenients
- Garder les ADRs courts et lisibles
- Ne pas modifier un ADR accepte - creer un nouveau si la decision change

### Format Recommande
- Michael Nygard's ADR format (adapte)
- Markdown simple
- Pas plus de 2 pages par ADR

---

## Definition of Done

- [ ] Template cree et documente
- [ ] 5 ADRs rediges (001-005)
- [ ] INDEX.md avec tous les liens
- [ ] Review par un membre senior de l'equipe
- [ ] ADRs valides comme refletant la realite du projet

---

## Estimation

| Tache | Temps estime |
|-------|--------------|
| Template + INDEX | 30min |
| ADR-001 (Clean Architecture) | 30min |
| ADR-002 (FlutterFlow migration) | 30min |
| ADR-003 (Supabase) | 30min |
| ADR-004 (Design System) | 30min |
| ADR-005 (State Management) | 30min |
| Review | 30min |
| **Total** | **3h30** |
