# Step 00: Init

> Purpose: Valider le brief, scanner le projet existant, adapter le nombre d'agents.

---

## MANDATORY RULES

- 🎯 ALWAYS valider que le brief existe et est lisible
- 🎯 ALWAYS scanner la codebase pour determiner sa taille
- 🎯 ALWAYS adapter agent_counts selon la taille
- 🚫 NEVER proceder si brief introuvable

## PROTOCOLS

- 🎯 **Goal**: Preparer le contexte pour la cascade d'agents
- 💾 **Output**: `{brief_content}`, `{project_context}`, `{agent_counts}`
- ⚡ **Performance**: Execution rapide, pas d'agents ici

---

## CONTEXT

**Available from arguments:**
- `$ARGUMENTS` - Chemin vers le fichier brief

**Produced by this step:**
- `{brief_path}` - Chemin valide vers le brief
- `{brief_content}` - Contenu du brief extrait
- `{project_context}` - Contexte du projet existant
- `{agent_counts}` - Nombre d'agents par tier

---

## TASK

### 1. Parser les arguments

```yaml
parsing:
  brief_path: Extract from $ARGUMENTS (first argument)

validation:
  - Check if path is provided
  - Check if file exists
  - Check if file is readable
```

**Si path manquant ou invalide:**

```yaml
AskUserQuestion:
  question: "Quel est le chemin vers le fichier brief/devis client ?"
  header: "Brief Path"
  options:
    - label: "docs/brief-client.md"
      description: "Fichier brief dans docs/"
    - label: "workspace/current/*.md"
      description: "Fichier dans workspace courant"
```

### 2. Lire le contenu du brief

```yaml
actions:
  - Read {brief_path}
  - Store as {brief_content}
  - Validate content is not empty
  - Validate content has actionable requirements
```

**Si brief vide ou non-actionable:**

```yaml
failure:
  message: "Le brief ne contient pas de requirements actionnables"
  action: AskUserQuestion pour clarification
```

### 3. Scanner le projet existant

```yaml
scan:
  # Determiner si projet existant
  has_existing_code:
    check: ls lib/ OR ls src/ OR ls app/
    store: boolean

  # Compter les fichiers pour adapter agents
  codebase_size:
    command: find . -type f \( -name "*.dart" -o -name "*.ts" -o -name "*.py" -o -name "*.js" \) | wc -l
    store: integer
    exclude: node_modules, .git, build, .dart_tool

  # Scanner Epics existants
  existing_epics:
    command: ls -d docs/epics/EPIC-*/ 2>/dev/null | wc -l
    store: integer

  # Lister IDs existants
  epic_ids:
    command: ls docs/epics/ 2>/dev/null | grep EPIC | sed 's/EPIC-\([0-9]*\).*/\1/' | sort -n
    store: array
```

### 4. Calculer agent_counts adaptatifs

```yaml
agent_counts:
  haiku_count:
    rules:
      - if codebase_size < 50: 3
      - if codebase_size < 150: 5
      - if codebase_size < 500: 7
      - else: 10
    minimum: 3
    maximum: 10

  sonnet_count:
    rules:
      - if brief_content.length < 2000: 3
      - if brief_content.length < 5000: 4
      - else: 5
    minimum: 3
    maximum: 5
```

### 5. Compiler le project_context

```yaml
project_context:
  has_existing_code: {boolean from scan}
  codebase_size: {integer from scan}
  codebase_category: "small" | "medium" | "large" | "xlarge"
  existing_epics: {integer from scan}
  epic_ids: {array from scan}
  next_epic_id: {max(epic_ids) + 1 OR 1 if none}
  tech_stack: {detected from file extensions}
```

---

## OUTPUT

```yaml
step_output:
  brief_path: "/path/to/brief.md"
  brief_content: "..."
  project_context:
    has_existing_code: true
    codebase_size: 127
    codebase_category: "medium"
    existing_epics: 3
    epic_ids: [1, 2, 3]
    next_epic_id: 4
    tech_stack: ["dart", "flutter"]
  agent_counts:
    haiku_count: 5
    sonnet_count: 3
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] `{brief_path}` points to existing, readable file
- [ ] `{brief_content}` is not empty
- [ ] `{brief_content}` contains actionable requirements
- [ ] `{project_context}` has all required fields
- [ ] `{agent_counts}` are within valid ranges

**Self-Critique Questions:**
- Le brief est-il suffisamment detaille ?
- Ai-je detecte correctement la taille de la codebase ?
- Le next_epic_id evitera-t-il les conflits ?

**If validation fails:**
1. AskUserQuestion for missing brief path
2. Document gaps in brief content
3. Default to minimum agent counts if scan fails

---

## SUCCESS / FAILURE

**Success:**
✅ Brief lu et valide
✅ Projet scanne
✅ Agent counts calcules

**Failure modes:**
❌ Brief introuvable → AskUserQuestion
❌ Brief vide → Demander clarification
❌ Scan echoue → Defaults conservateurs

---

## NEXT

When validation passes, load `steps/step-01-scan.md`

<critical>
Ne JAMAIS proceder sans un brief valide et lisible.
Les agent counts doivent etre adaptes - ne pas utiliser de valeurs fixes.
</critical>
