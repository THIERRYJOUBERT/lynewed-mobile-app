# Regles de Detection

> Reference pour /sync-project v2.0

---

## Mapping Chemin → References Impactees

| Chemin modifie | References a verifier |
|----------------|----------------------|
| `.claude/skills/*` | CLAUDE.md (section Workflows) |
| `.claude/rules/*` | CLAUDE.md (section Regles Detaillees) |
| `.claude/agents/*` | CLAUDE.md (section Agents), .claude/context/README.md |
| `.claude/context/*` | .claude/context/README.md |
| `docs/specs/FD-*` | docs/specs/INDEX.md |
| `docs/specs/*` | docs/specs/INDEX.md |
| `docs/epics/EPIC-*` | docs/specs/INDEX.md, docs/epics/CROSS-EPIC.md |
| `docs/epics/*/stories/*` | docs/epics/EPIC-XX/TRACKING.md |
| `docs/detailed/*` | docs/detailed/README.md, docs/specs/INDEX.md |
| `docs/*` | docs/README.md |
| `workspace/*` | workspace/README.md (rarement) |

---

## Detection par Type de Fichier

### Nouveau Workflow

**Pattern** : `.claude/skills/*/SKILL.md` (nouveau)

**Verification** :
```
1. Lire CLAUDE.md
2. Chercher le nom du workflow dans "Workflows Disponibles"
3. Si absent → divergence detectee
```

**Categorisation automatique** :
| Contient dans description | Categorie |
|---------------------------|-----------|
| "implement", "dev", "code", "test", "debug" | Developper |
| "create", "generate", "build" | Creer |
| Autre | Utilitaires |

### Nouvel Epic

**Pattern** : `docs/epics/EPIC-XX-*/EPIC-*.md` (nouveau)

**Verification** :
```
1. Lire docs/specs/INDEX.md section "Documents de Developpement"
2. Lire docs/epics/CROSS-EPIC.md
3. Verifier presence de l'Epic
4. Si absent → divergence detectee
```

### Nouvelle Story

**Pattern** : `docs/epics/EPIC-XX-*/stories/STORY-*.md` (nouveau ou modifie)

**Verification** :
```
1. Identifier l'Epic parent via le chemin
2. Lire docs/epics/EPIC-XX-*/TRACKING.md
3. Verifier presence et status de la story
4. Si absent ou status different → divergence detectee
```

### Nouvelle Regle

**Pattern** : `.claude/rules/*.md` (nouveau)

**Verification** :
```
1. Lire CLAUDE.md section "Regles Detaillees"
2. Verifier presence du fichier dans la liste
3. Si absent et regle significative → divergence detectee
```

### Nouveau Document Detailed

**Pattern** : `docs/detailed/**/*.md` (nouveau)

**Verification** :
```
1. Lire docs/detailed/README.md
2. Verifier si le sous-dossier est documente
3. Si nouveau sous-dossier non documente → divergence detectee
```

---

## Regles de Priorite

Quand plusieurs references sont impactees, les traiter dans cet ordre :

1. **CLAUDE.md** (reference principale)
2. **docs/specs/INDEX.md** (index central)
3. **docs/epics/CROSS-EPIC.md** (coordination epics)
4. **TRACKING.md** (suivi epic specifique)
5. **README.md** (documentation locale)

---

## Exclusions

Ne JAMAIS detecter comme divergence :

| Fichier/Pattern | Raison |
|-----------------|--------|
| `lib/**` | Code source, pas une reference |
| `test/**` | Tests, pas une reference |
| `*.lock` | Fichiers generes |
| `.gitignore` | Configuration git |
| `workspace/archive/**` | Archives, pas synchronisees |
| `ios/**`, `android/**` | Fichiers plateforme |

---

## Seuils de Detection

### Mode Strict (defaut)
Detecter TOUTE divergence entre realite et references.

### Mode Tolerant (`--tolerant`)
Ignorer les divergences mineures :
- Dates de mise a jour
- Ordre des elements dans les listes
- Espaces et formatting

---

## Exemples de Divergences

### Workflow manquant dans CLAUDE.md

```
Detecte : .claude/skills/debug/SKILL.md existe
Verifie : CLAUDE.md ne contient pas "/debug"
Divergence : Workflow /debug absent de CLAUDE.md
Action : Proposer ajout dans section "Developper"
```

### Epic non reference dans INDEX.md

```
Detecte : docs/epics/EPIC-03-ANALYTICS/EPIC-03-ANALYTICS.md existe
Verifie : docs/specs/INDEX.md ne reference pas EPIC-03
Divergence : Epic EPIC-03 absent de INDEX.md
Action : Proposer ajout dans section "Documents de Developpement"
```

### Story terminee non mise a jour dans TRACKING.md

```
Detecte : STORY-01-02.md modifie avec tous criteres coches
Verifie : TRACKING.md montre story en "In Progress"
Divergence : Status story desynchronise
Action : Proposer mise a jour status → "Done"
```
