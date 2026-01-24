# Categorization Rules

> Regles pour determiner ou placer chaque type de documentation.

---

## Decision Tree

```
CONTENU A DOCUMENTER
        │
        ├── Est-ce temporaire/exploratoire?
        │   └── OUI → workspace/current/
        │
        ├── Est-ce une spec technique finale?
        │   └── OUI → docs/detailed/{area}/
        │
        ├── Est-ce lie a un Epic/Story?
        │   └── OUI → docs/epics/EPIC-XX/
        │
        └── Autre
            └── workspace/current/ (defaut)
```

---

## Mapping Detaille

### workspace/current/

**Quand:**
- Session de travail en cours
- Brainstorming, exploration
- Decisions non finalisees
- Notes temporaires

**Format:** Session files dates

**Retention:** Jusqu'a archivage explicite

---

### workspace/archive/

**Quand:**
- Session terminee avec --archive
- Historique de sessions passees

**Format:** Dossiers dates avec README

**Retention:** Long terme (reference)

---

### docs/detailed/

**Quand:**
- Specs techniques finales
- Architecture decisions
- API documentation
- UI/UX specifications
- Data models

**Sous-dossiers:**
- `architecture/` - System design
- `ui-ux/` - Screens, flows
- `api/` - Endpoints, schemas
- `data/` - Models, migrations

**Format:** Documents structures

---

### docs/epics/

**Quand:**
- Progress sur Epic
- Story implementation
- Decisions Epic-level
- Blockers et solutions

**Fichiers:**
- `TRACKING.md` - Progress
- `EPIC-XX.md` - Scope et decisions
- `stories/STORY-XX-YY.md` - Details story

---

## Content Type Mapping

| Content Type | Primary Location | Backup Location |
|--------------|------------------|-----------------|
| Brainstorm | workspace/current | - |
| Session notes | workspace/current | - |
| Technical decision | docs/detailed | workspace/current |
| Architecture | docs/detailed/architecture | - |
| UI specs | docs/detailed/ui-ux | - |
| API specs | docs/detailed/api | - |
| Epic progress | docs/epics/TRACKING.md | - |
| Story details | docs/epics/stories/ | - |
| Epic decision | docs/epics/EPIC-XX.md | - |

---

## Priority Rules

1. **Epic context present** → docs/epics/
2. **Technical spec finale** → docs/detailed/
3. **Tout autre** → workspace/current/

---

## Scope Filtering

**scope=workspace:**
- Uniquement workspace/current, workspace/archive

**scope=detailed:**
- Uniquement docs/detailed/

**scope=epics:**
- Uniquement docs/epics/

**scope=all:**
- Toutes locations (defaut)

---

## Duplication Prevention

**Avant de creer:**
1. Verifier {existing_docs}
2. Si sujet deja documente:
   - Meme location → UPDATE
   - Autre location → REFERENCE seulement

**Merge Strategy:**
- Sections nouvelles → Append
- Sections existantes → Update avec timestamp
- Conflits → Conserver les deux avec dates
