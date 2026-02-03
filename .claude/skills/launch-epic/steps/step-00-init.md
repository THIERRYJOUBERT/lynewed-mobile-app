# Step 00: Initialisation

> Purpose: Parse arguments, charger contexte Epic, vérifier prérequis, et gérer les erreurs.

---

## MANDATORY RULES (READ FIRST)

- 📋 PARSE $ARGUMENTS pour extraire EPIC-ID et MODE
- 📂 VÉRIFIER que l'Epic existe et est valide
- ❌ ERROR HANDLING explicite avec messages clairs
- ➡️ ROUTER vers le step approprié selon le mode

## PROTOCOLS

- 🎯 **Goal**: Préparer l'exécution avec contexte validé
- 💾 **Output**: `{epic_id}`, `{mode}`, `{epic_path}`, `{stories}`
- ⚡ **Performance**: Fail fast si prérequis manquants

---

## CONTEXT

**Available from SKILL.md:**
- `$ARGUMENTS` - Arguments passés par l'utilisateur

**Produced by this step:**
- `{epic_id}` - ID de l'Epic extrait
- `{mode}` - Mode d'exécution (supervised/autonomous/autonomous-deep)
- `{deep}` - Flag mode DEEP actif (boolean)
- `{epic_path}` - Chemin complet vers l'Epic
- `{stories}` - Liste des stories à implémenter
- `{epic_content}` - Contenu de l'Epic.md
- `{coordination_file}` - (DEEP) Chemin vers COORDINATION.md

---

## EXECUTION

### 1. Parse Arguments

```yaml
argument_parsing:
  input: "$ARGUMENTS"

  patterns:
    - "EPIC-XX"                           → epic_id=EPIC-XX, mode=supervised, deep=false
    - "EPIC-XX --mode=supervised"         → epic_id=EPIC-XX, mode=supervised, deep=false
    - "EPIC-XX --mode=autonomous"         → epic_id=EPIC-XX, mode=autonomous, deep=false
    - "EPIC-XX --mode=autonomous --deep"  → epic_id=EPIC-XX, mode=autonomous, deep=true
    - "EPIC-XX --auto"                    → epic_id=EPIC-XX, mode=autonomous, deep=false
    - "EPIC-XX --auto --deep"             → epic_id=EPIC-XX, mode=autonomous, deep=true
    - ""                                  → ERROR: Epic ID manquant

  extraction:
    epic_id: Premier argument (format EPIC-XX)
    mode: Valeur après --mode= ou alias --auto (défaut: supervised)
    deep: Présence du flag --deep (défaut: false)

  aliases:
    "--auto": "--mode=autonomous"
```

**Validation du format:**

```yaml
epic_id_validation:
  pattern: "^EPIC-\\d{2}$"
  valid_examples: ["EPIC-01", "EPIC-12"]
  invalid_examples: ["epic-01", "EPIC01", "01"]
```

---

### 2. Construire Chemins

```yaml
paths:
  epic_dir: "docs/epics/{epic_id}/"
  epic_file: "docs/epics/{epic_id}/{epic_id}.md"
  stories_dir: "docs/epics/{epic_id}/stories/"
  tracking_file: "docs/epics/{epic_id}/TRACKING.md"
  system_file: ".claude/context/SYSTEM.md"
```

---

### 3. Vérifier Existence

**Vérifications obligatoires:**

```
1. Glob docs/epics/{epic_id}/ exists?
2. Read docs/epics/{epic_id}/{epic_id}.md exists and is valid?
3. Glob docs/epics/{epic_id}/stories/*.md has files?
4. Read .claude/context/SYSTEM.md exists?
```

---

### 4. Charger Contexte

**Lire l'Epic:**

```
Read docs/epics/{epic_id}/{epic_id}.md

Extract:
- Titre de l'Epic
- Objectif/Description
- Liste des stories référencées
- Dépendances éventuelles
```

**Lister les Stories:**

```
Glob docs/epics/{epic_id}/stories/*.md

Pour chaque story file:
- Extraire ID (STORY-XX-YY)
- Extraire titre
- Extraire status (À faire, En cours, Done)
- Filtrer: garder seulement À faire et En cours
```

**Charger SYSTEM.md:**

```
Read .claude/context/SYSTEM.md

Utiliser comme référence pour:
- Story Workflow 8 étapes
- Self-healing pattern
- Review adversariale
```

---

### 5. Validation Initiale

```yaml
validation_checklist:
  - epic_exists: boolean
  - epic_valid: boolean
  - stories_found: count > 0
  - stories_actionable: count > 0 (non Done)
  - system_loaded: boolean
  - no_blocking_dependencies: boolean
```

---

## ERROR HANDLING

### Epic non trouvé

```yaml
error: EPIC_NOT_FOUND
message: |
  ❌ Epic '{epic_id}' non trouvé.

  Vérifiez que:
  - Le dossier docs/epics/{epic_id}/ existe
  - Le fichier {epic_id}.md existe dans ce dossier

  Epics disponibles: {list existing epics}
action: STOP - demander clarification
```

### Aucune story trouvée

```yaml
error: NO_STORIES_FOUND
message: |
  ❌ Aucune story trouvée pour '{epic_id}'.

  Le dossier docs/epics/{epic_id}/stories/ est vide ou n'existe pas.

  **Action requise:**
  Créez des stories avec: `/create-story {epic_id}`

  Cette commande va:
  1. Lire l'Epic et ses objectifs
  2. Générer des stories INVEST avec critères Gherkin
  3. Les sauvegarder dans docs/epics/{epic_id}/stories/
action: STOP - suggérer création stories
```

### Toutes stories terminées

```yaml
error: ALL_STORIES_DONE
message: |
  ✅ Toutes les stories de '{epic_id}' sont déjà terminées!

  Stories: {count} Done

  Rien à faire.
action: STOP - informer et terminer
```

### Mode invalide

```yaml
error: INVALID_MODE
message: |
  ❌ Mode '{mode}' invalide.

  Modes disponibles:
  - supervised (défaut): Travail interactif avec validation utilisateur
  - autonomous: Exécution automatique sans interruption

  Exemple: /launch-epic EPIC-01 --mode=autonomous
action: STOP - demander mode valide
```

### SYSTEM.md manquant

```yaml
error: SYSTEM_MISSING
message: |
  ⚠️ Fichier .claude/context/SYSTEM.md non trouvé.

  Ce fichier est recommandé pour les patterns de workflow.
  Continuant sans...
action: WARN - continuer avec defaults
```

---

## OUTPUT

```yaml
step_00_output:
  epic_id: "{EPIC-XX}"
  mode: "supervised" | "autonomous" | "autonomous-deep"
  deep: true | false
  epic_path: "docs/epics/{epic_id}/"
  epic_content:
    title: "..."
    description: "..."
  stories:
    - id: "STORY-XX-01"
      title: "..."
      status: "À faire"
      path: "docs/epics/{epic_id}/stories/STORY-XX-01.md"
    - id: "STORY-XX-02"
      title: "..."
      status: "En cours"
      path: "..."
  total_stories: N
  actionable_stories: M
  # Mode DEEP only:
  coordination_file: "{scratchpad}/COORDINATION-{epic_id}.md"
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Epic ID extrait et valide
✅ Mode déterminé (supervised ou autonomous)
✅ Epic file lu et parsé
✅ Stories listées et filtrées
✅ Au moins 1 story actionable
✅ Aucune erreur bloquante

**Self-Critique Questions:**
- Ai-je bien vérifié TOUS les fichiers requis?
- Les messages d'erreur sont-ils clairs et actionnables?
- Le mode par défaut est-il correctement appliqué?

---

## ROUTING

Après validation réussie:

```yaml
routing:
  IF mode == "supervised":
    LOAD: steps/step-01-supervised.md

  IF mode == "autonomous" AND deep == false:
    LOAD: steps/step-02-autonomous.md

  IF mode == "autonomous" AND deep == true:
    LOAD: steps/step-02-autonomous-deep.md
    # Créer aussi COORDINATION.md dans le scratchpad
```

### Mode DEEP - Initialisation supplémentaire

Si `deep == true`:

1. **Créer COORDINATION.md:**
   ```yaml
   coordination_init:
     file: "{scratchpad}/COORDINATION-{epic_id}.md"
     template: references/coordination-deep.md
     action: Write initial structure with all stories listed
   ```

2. **Lire Design System:**
   ```yaml
   design_system:
     file: ".claude/rules/ui-design-system.md"
     action: Read and keep in context for Chef Opus
   ```

---

## SUCCESS / FAILURE

**Success:**
✅ Contexte chargé dans variables d'état
✅ Stories actionables identifiées
✅ Prêt pour exécution du mode choisi

**Failure modes:**
❌ Epic non trouvé → Message d'erreur, STOP
❌ Pas de stories → Message d'erreur, STOP
❌ Mode invalide → Message d'erreur, STOP
❌ Toutes stories Done → Message info, STOP (succès technique)

---

## NEXT

Après validation, charger le step approprié selon `{mode}` et `{deep}`:
- supervised → `steps/step-01-supervised.md`
- autonomous → `steps/step-02-autonomous.md`
- autonomous + deep → `steps/step-02-autonomous-deep.md`

<critical>
FAIL FAST: Si prérequis manquants, échouer immédiatement avec message clair.
ERROR MESSAGES: Toujours donner des messages actionnables avec solutions.
DEFAULT MODE: Si mode non spécifié, utiliser "supervised" (plus sûr).
DEFAULT DEEP: Si --deep non spécifié, utiliser false.
MODE DEEP: Si --deep actif, initialiser COORDINATION.md ET lire Design System.
</critical>
