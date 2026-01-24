---
name: sync-project
description: Synchronise automatiquement les fichiers de reference du projet (INDEX, README, CLAUDE.md). Detecte les changements et met a jour les references. Appelable par d'autres workflows ou directement.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
model: opus
---

# /sync-project

Utilitaire autonome de synchronisation des references projet. Detecte les changements et met a jour INDEX.md, README.md, et CLAUDE.md pour maintenir la coherence.

---

## Quand Utiliser

### Appel Direct (utilisateur)
```
/sync-project              # Mode interactif complet
/sync-project --silent     # Mode silencieux (logs seulement)
```

### Appel par Workflows (intelligent)

Les workflows utilisent maintenant une **finalization intelligente** (voir `references/workflow-finalization.md`) :

| Workflow | Quand sync est proposé |
|----------|------------------------|
| `/create-epic` | Toujours (création significative) |
| `/create-story` | Toujours (nouvelles stories) |
| `/dev-story` | Toujours (implémentation complète) |
| `/launch-epic` | Toujours (Epic terminé) |
| `/oneshot` | Toujours (feature complète) |
| `/debug` | Si fix significatif ou structural |
| `/documentation` | Rarement (auto-suffisant) |

**Mode SUPERVISED** : Le workflow propose sync/doc via AskUserQuestion
**Mode AUTO** : Le workflow lance un Agent Sonnet pour sync/doc (isolation du contexte)

---

## Fichiers de Reference a Synchroniser

### Fichiers Principaux

| Fichier | Quand mettre a jour |
|---------|---------------------|
| `CLAUDE.md` | Nouveau workflow, changement phase, nouveau pattern |
| `docs/specs/INDEX.md` | Nouveau FD, Epic, ou doc de specs |
| `docs/README.md` | Changement structure docs/ |
| `docs/detailed/README.md` | Nouveau sous-dossier detailed/ |
| `workspace/README.md` | Rarement (structure stable) |
| `.claude/context/README.md` | Nouveau fichier context/ |

### Fichiers Epics (si applicable)

| Fichier | Quand mettre a jour |
|---------|---------------------|
| `docs/epics/CROSS-EPIC.md` | Nouvel Epic, dependance inter-Epic |
| `docs/epics/EPIC-XX/TRACKING.md` | Story terminee ou status change |

---

## Processus Autonome

### Phase 1 : Detection (automatique)

```
1. Lister fichiers modifies (git diff + git status)
2. Categoriser les changements :
   - skills/     → Impact CLAUDE.md (workflows)
   - docs/specs/ → Impact INDEX.md
   - docs/epics/ → Impact TRACKING.md, CROSS-EPIC.md
   - docs/detailed/ → Impact detailed/README.md
   - .claude/rules/ → Impact CLAUDE.md (regles)
   - .claude/agents/ → Impact CLAUDE.md (agents)
3. Identifier les references a verifier
```

### Phase 2 : Analyse (automatique)

Pour chaque reference identifiee :

```
1. Lire le fichier de reference actuel
2. Lire les fichiers sources concernes
3. Comparer : reference vs realite
4. Lister les divergences
```

### Phase 3 : Proposition (mode interactif) ou Execution (mode silent)

**Mode interactif** (defaut) :
```
Presenter les changements detectes et proposer les mises a jour.
AskUserQuestion pour validation avant execution.
```

**Mode silent** (`--silent`) :
```
Executer les mises a jour automatiquement.
Logger les actions effectuees.
Pas de AskUserQuestion.
```

### Phase 4 : Execution

Appliquer les mises a jour validees.

### Phase 5 : Rapport

```markdown
## Synchronisation terminee

### Fichiers mis a jour
- [x] CLAUDE.md : Ajoute workflow /debug
- [x] docs/specs/INDEX.md : Mis a jour date

### Fichiers inchanges (deja a jour)
- docs/README.md
- workspace/README.md

### Prochaine action suggeree
[Basee sur l'etat du projet]
```

---

## Regles de Detection par Type

### Nouveau Workflow (.claude/skills/)

**Detecte** : Nouveau dossier dans `.claude/skills/` avec SKILL.md

**Actions** :
1. Verifier presence dans CLAUDE.md section "Workflows Disponibles"
2. Si absent → Proposer ajout avec description
3. Categoriser : Developper, Creer, ou Utilitaires

### Nouvelle Story/Epic (docs/epics/)

**Detecte** : Nouveau fichier EPIC-XX.md ou STORY-XX-YY.md

**Actions** :
1. Verifier docs/specs/INDEX.md section "Documents de Developpement"
2. Verifier CROSS-EPIC.md si nouvel Epic
3. Mettre a jour TRACKING.md de l'Epic parent

### Nouveau Document Detailed (docs/detailed/)

**Detecte** : Nouveau fichier ou dossier dans `docs/detailed/`

**Actions** :
1. Verifier docs/detailed/README.md
2. Verifier docs/specs/INDEX.md si pertinent

### Nouvelle Regle (.claude/rules/)

**Detecte** : Nouveau fichier .md dans `.claude/rules/`

**Actions** :
1. Verifier CLAUDE.md section "Regles Detaillees"
2. Proposer ajout si regle significative

### Nouvel Agent (.claude/agents/)

**Detecte** : Nouveau fichier .md dans `.claude/agents/`

**Actions** :
1. Verifier CLAUDE.md (mention agents)
2. Verifier .claude/context/README.md

---

## Implementation

### Etape 1 : Collecter les changements

```bash
# Fichiers modifies (tracked)
git diff --name-only HEAD 2>/dev/null || echo ""

# Fichiers non-trackes
git status --porcelain 2>/dev/null | grep "^??" | cut -c4-

# Fichiers staged
git diff --cached --name-only 2>/dev/null || echo ""
```

### Etape 2 : Categoriser

```
Pour chaque fichier modifie :
  - Extraire le chemin racine (skills/, docs/, rules/, etc.)
  - Determiner les references impactees
  - Ajouter a la liste des verifications
```

### Etape 3 : Verifier chaque reference

```
Pour chaque reference a verifier :
  1. Read le fichier de reference
  2. Read/Glob les fichiers sources
  3. Comparer contenu attendu vs actuel
  4. Si divergence → ajouter a la liste des mises a jour
```

### Etape 4 : Appliquer (apres validation si interactif)

```
Pour chaque mise a jour :
  - Edit le fichier de reference
  - Logger l'action
```

---

## Regles Absolues

1. **DETECTION AUTONOME** : Ne jamais demander quoi synchroniser - le detecter
2. **JAMAIS MODIFIER** : Code source (lib/, test/), FDs (contenu), PRD-MASTER
3. **TOUJOURS PROPOSER** : En mode interactif, proposer avant d'executer
4. **MODE SILENT** : Quand appele par autre workflow, executer sans interaction
5. **RAPPORT OBLIGATOIRE** : Toujours terminer par un rapport des actions
6. **IDEMPOTENT** : Appeler plusieurs fois ne doit pas creer de doublons

---

## Arguments

| Argument | Effet |
|----------|-------|
| (aucun) | Mode interactif complet |
| `--silent` | Mode silencieux, pas de AskUserQuestion |
| `--dry-run` | Afficher ce qui serait fait sans executer |
| `--scope=skills` | Limiter a la synchronisation des skills |
| `--scope=docs` | Limiter a la synchronisation des docs |
| `--scope=all` | Tout synchroniser (defaut) |

---

## Exemples d'Utilisation

### Par l'utilisateur (appel direct)
```
User: /sync-project
→ Detecte changements, propose mises a jour, execute apres validation
```

### Par workflow SUPERVISED (fin de workflow)
```
[Workflow] AskUserQuestion: "Voulez-vous synchroniser les références ?"
[User] Choisit "Sync + Documentation"
[Workflow] Invoke /sync-project --silent puis /documentation --auto
```

### Par workflow AUTO (fin de workflow)
```
[Workflow] Lancer Agent Sonnet:
  → Execute /sync-project --silent
  → Execute /documentation --auto
  → Pas d'interruption du workflow principal
```

---

## References

- `references/detection-rules.md` : Regles detaillees de detection
- `references/file-templates.md` : Templates pour les mises a jour
- `references/workflow-finalization.md` : Pattern de finalization intelligente pour workflows
