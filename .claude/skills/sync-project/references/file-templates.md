# Templates de Mise a Jour

> Reference pour /sync-project v2.0
> Templates pour les mises a jour des fichiers de reference

---

## CLAUDE.md

### Ajouter un Workflow

**Section cible** : `## Workflows Disponibles`

**Sous-section selon categorie** :
- Developper : `/dev-story`, `/oneshot`, `/debug`, `/commit`
- Creer : `/create-epic`, `/create-story`, `/create-workflow`, `/launch-epic`
- Utilitaires : `/prompt`, `/explore`, `/sync-project`

**Format ligne** :
```markdown
| `/nom-workflow` | Description courte de quand l'utiliser |
```

**Exemple** :
```markdown
| `/debug` | Bug detecte → Investigation scientifique (Constrained ReAct) |
```

### Ajouter une Regle

**Section cible** : `## Regles Detaillees`

**Format ligne** :
```markdown
| `nom-fichier.md` | Description du contenu |
```

---

## docs/specs/INDEX.md

### Ajouter un Epic

**Section cible** : `## Documents de Developpement`

**Format** :
```markdown
| `docs/epics/EPIC-XX/EPIC-XX.md` | Description Epic | `/create-epic` | `/launch-epic` |
```

### Mettre a jour la date

**Ligne cible** : `> **Derniere MAJ** :`

**Format** :
```markdown
> **Derniere MAJ** : YYYY-MM-DD
```

---

## docs/epics/CROSS-EPIC.md

### Ajouter un Epic

**Section** : Ajouter apres le dernier Epic documente

**Format** :
```markdown
## EPIC-XX : Nom de l'Epic

**Status** : 🟡 En cours | 🟢 Termine | ⚪ Planifie
**Stories** : X/Y terminees
**Dependances** : EPIC-YY (si applicable)

### Description
[Resume de l'objectif de l'Epic]

### Impact sur autres Epics
[Dependencies ou impacts]
```

---

## docs/epics/EPIC-XX/TRACKING.md

### Mettre a jour status story

**Chercher** : Ligne avec le nom de la story

**Remplacer status** :
```
⚪ Backlog → 🔵 Ready → 🟡 In Progress → 🟢 Done → ✅ Validated
```

**Exemple avant** :
```markdown
| STORY-01-02 | Configuration Supabase | 🟡 In Progress |
```

**Exemple apres** :
```markdown
| STORY-01-02 | Configuration Supabase | 🟢 Done |
```

---

## docs/detailed/README.md

### Ajouter un sous-dossier

**Section cible** : Liste des sous-dossiers

**Format** :
```markdown
| `sous-dossier/` | Description du contenu |
```

**Exemple** :
```markdown
| `ui-ux/` | Wireframes, mockups, flows utilisateur |
| `api/` | Specifications API, schemas |
| `analysis-system/` | Documentation systeme d'analyse |
```

---

## .claude/context/README.md

### Ajouter un fichier context

**Section cible** : Liste des fichiers

**Format** :
```markdown
| `nom-fichier.md` | Role et description |
```

---

## workspace/README.md

> Rarement modifie - structure stable

### Structure standard
```markdown
# Workspace

Espace de travail temporaire (non commite).

## current/
Fichiers de la mission en cours.
Vide entre les missions.

## archive/
Sessions archivees par theme : `YYYY-MM-DD-theme/`
```

---

## Format du Rapport de Synchronisation

```markdown
## Synchronisation terminee

**Date** : YYYY-MM-DD HH:MM
**Mode** : interactif | silent
**Scope** : all | skills | docs

### Fichiers mis a jour
- [x] `CLAUDE.md` : [description changement]
- [x] `docs/specs/INDEX.md` : [description changement]

### Fichiers verifies (aucun changement)
- `docs/README.md`
- `workspace/README.md`

### Divergences ignorees
- [liste si mode tolerant]

### Statistiques
- Fichiers analyses : X
- Divergences detectees : Y
- Mises a jour appliquees : Z
```

---

## Regles de Formatting

1. **Toujours** utiliser le meme style que le fichier existant
2. **Toujours** respecter l'indentation existante
3. **Toujours** ajouter a la fin de la section appropriee
4. **Jamais** reorganiser l'ordre existant
5. **Jamais** modifier le contenu non concerne par la divergence
