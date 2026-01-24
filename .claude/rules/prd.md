---
paths: docs/specs/**/*.md
---
# Regles Documents de Fondation & PRD

## Hierarchie des Documents

```
docs/specs/
├── FD-01-VISION.md            # a FD-10-LAUNCH-STRATEGY.md
├── PRD-MASTER.md              # Synthese executable (apres tous FDs)
└── INDEX.md                   # Index de la documentation
```

## Structure Document de Fondation

Tout FD DOIT avoir cet en-tete :

```markdown
# FD-XX-NOM

> **Version** : 1.0.0
> **Status** : ⏳ A faire | 🔄 En cours | ✅ VALIDE
> **Derniere MAJ** : YYYY-MM-DD

**Dependances** : [FDs requis]
**Role de ce FD** : [Description du role unique de ce document]
```

## Structure PRD-MASTER

```markdown
# PRD-MASTER

> **Version** : 1.0.0
> **Status** : ⏳ A faire | ✅ VALIDE
> **Derniere MAJ** : YYYY-MM-DD

**Base** : FD-01 a FD-10 valides

## Sections
1. Executive Summary
2. Vision & Mission (depuis FD-01)
3. Personas (depuis FD-02)
4. Features (depuis FD-05-PRODUCT)
5. Architecture (depuis FD-09-TECHNICAL-FOUNDATION)
6. Roadmap (depuis FD-10-LAUNCH-STRATEGY)
7. Index des Epics
```

## Regles ABSOLUES

### Phase 1 (Documents de Fondation)
1. **NEVER** valider un FD sans AskUserQuestion section par section
2. **ALWAYS** mettre a jour CLAUDE.md tracking quand FD valide
3. **ALWAYS** citer les sources legacy utilisees
4. **NEVER** creer PRD-MASTER avant tous les FDs valides

### Phase 2 (Epics/Stories)
1. **ALWAYS** baser les Epics sur PRD-MASTER
2. **ALWAYS** referencer le FD source dans chaque Epic
3. **NEVER** coder sans Story validee

## Lien FD → Epic → Story

```
FD-05-PRODUCT (Document de Fondation)
    └── EPIC-01-AUTH (Epic)
        └── STORY-01-01 (Story INVEST)
            └── Tasks (Todos)
```
