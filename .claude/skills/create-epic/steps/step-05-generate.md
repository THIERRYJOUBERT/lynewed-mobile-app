---
name: step-05-generate
description: Generate Epic.md, TRACKING.md, and sources.yaml using templates
prev_step: steps/step-04-synthesize.md
next_step: steps/step-06-confirm.md
---

# Step 05: Generate Epic Files

## MANDATORY EXECUTION RULES (READ FIRST):

- 🛑 NEVER deviate from templates
- 🛑 NEVER omit required sections
- 🛑 NEVER use placeholder content ("TBD", "...")
- ✅ ALWAYS load templates from templates/ directory
- ✅ ALWAYS fill ALL template placeholders with actual content
- ✅ ALWAYS include architecture diagram for INFRA/DATA domains
- 📋 YOU ARE a file generator using templates
- 💬 FOCUS on producing complete, validated files
- 🚫 FORBIDDEN to invent content not from synthesis
- 🚫 FORBIDDEN to skip sections "for brevity"

## EXECUTION PROTOCOLS:

- 🎯 Load each template, fill with state data
- 💾 Create directory structure first
- 📖 Validate each file before saving
- 🚫 FORBIDDEN to load next step until all files created

## CONTEXT BOUNDARIES:

**Available from previous steps:**
- `{epic_id}` - Epic ID (e.g., EPIC-00-FOUNDATION)
- `{epic_name}` - Epic name
- `{epic_path}` - Target directory
- `{domain}` - INFRA | DATA | UI | API
- `{sources_mapping}` - Source documents
- `{discovery_method}` - auto | manual
- `{stories}` - Enriched stories array
- `{stories_count}` - Number of stories
- `{gaps}` - Identified gaps
- `{epic_context}` - Why, pillars, risks

## YOUR TASK:

Generate all Epic files using templates, filling in all content from synthesis.

---

## EXECUTION SEQUENCE:

### 1. Create Directory Structure

```bash
mkdir -p {epic_path}/stories
```

Creates:
```
docs/epics/EPIC-XX-NAME/
├── stories/   (empty, for /create-story)
```

### 2. Load and Interpret Templates

Read templates from:
- `templates/epic.md` → EPIC-XX.md structure
- `templates/tracking.md` → TRACKING.md structure
- `templates/sources.yaml` → sources.yaml structure

**Template Interpretation Guide:**

Templates use Handlebars-like syntax. As the executing agent, YOU are the template engine.

| Syntax | Meaning | Your Action |
|--------|---------|-------------|
| `{{VARIABLE}}` | Simple substitution | Replace with state variable value |
| `{{#if CONDITION}}...{{/if}}` | Conditional block | Include block only if condition true |
| `{{#each ARRAY}}...{{/each}}` | Loop | Repeat block for each item in array |
| `{{this.property}}` | Loop item access | Access current item's property |

**DO NOT** copy templates literally with Handlebars syntax.
**DO** interpret and generate final markdown with actual content.

### 3. Generate EPIC-XX.md

**Load template and fill placeholders:**

```
{{EPIC_ID}} → {epic_id}
{{EPIC_NAME}} → {epic_name}
{{DOMAIN}} → {domain}
{{DATE}} → current date (YYYY-MM-DD)
{{WHY_THIS_EPIC}} → {epic_context.why_this_epic}
{{TECHNICAL_PILLARS}} → formatted table from {epic_context.technical_pillars}
{{ARCHITECTURE_DIAGRAM}} → ASCII diagram if INFRA/DATA, else "N/A - See UI specs"
{{STORIES_TABLE}} → formatted table from {stories}
{{STORIES_DETAIL}} → detailed sections for each story
{{RISKS_TABLE}} → formatted table from {epic_context.risks}
{{GAPS_TABLE}} → formatted table from {gaps}
{{FD_REFERENCES}} → formatted table from {sources_mapping}
```

**Stories Table Format:**

```markdown
| # | Story | Domaine | Dep. | Criteres cles | Source FD | Complexite |
|---|-------|---------|------|---------------|-----------|------------|
| 01 | Setup projet Flutter | INFRA | - | pubspec.yaml, structure lib/ | FD-09 §2.1 | M |
| 02 | Configuration Drift | DATA | 01 | Double db, Pragmas WAL | FD-09 §4.1-4.2 | L |
```

**Story Detail Format:**

```markdown
### STORY-00-01 : Setup projet Flutter

**Criteres cles** :
- Structure projet: lib/{core,features,shared}
- pubspec.yaml avec packages: riverpod ^2.5.0, go_router ^13.0.0
- {{LINT_CMD}}nfos passe

**Source** : FD-09 §2.1

**Complexite** : M

**Details techniques** :
- Chemins: lib/core/, lib/features/, lib/shared/
- Config: analysis_options.yaml strict mode
```

**Architecture Diagram (INFRA/DATA only):**

```
┌─────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE CIBLE                       │
│                                                             │
│  ┌─────────────┐        ┌─────────────┐                    │
│  │   user.db   │        │   ref.db    │                    │
│  │ (encrypted) │        │ (read-only) │                    │
│  └──────┬──────┘        └──────┬──────┘                    │
│         │                      │                           │
│         └──────────┬───────────┘                           │
│                    │                                       │
│            ┌───────┴───────┐                               │
│            │   Drift DAO   │                               │
│            └───────┬───────┘                               │
│                    │                                       │
│            ┌───────┴───────┐                               │
│            │   Isolate     │                               │
│            │  (compute)    │                               │
│            └───────────────┘                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.5 ADAPTIVE SECTIONS (Template Vivant)

Le template est une BASE, pas une contrainte rigide. L'agent DOIT ajouter des sections pertinentes selon le contexte de l'Epic.

**Principe : Le template s'adapte à l'Epic, pas l'inverse.**

**Checklist de sections conditionnelles :**

```
┌─────────────────────────────────────────────────────────────┐
│              ADAPTIVE SECTIONS CHECK                         │
│                                                              │
│  Après avoir généré l'Epic avec le template de base,        │
│  vérifier si ces sections sont nécessaires :                │
│                                                              │
│  □ DÉPENDANCES EPIC                                         │
│    → Cet Epic bloque-t-il d'autres Epics ?                  │
│    → Est-il bloqué par d'autres ?                           │
│    → Si oui : ajouter diagramme des dépendances             │
│                                                              │
│  □ ORDRE D'EXÉCUTION                                        │
│    → Les stories ont-elles des dépendances complexes ?      │
│    → Y a-t-il des groupes logiques à respecter ?            │
│    → Si oui : ajouter groupement recommandé                 │
│                                                              │
│  □ MIGRATIONS DB                                             │
│    → L'Epic touche-t-il au schéma de base de données ?      │
│    → Y a-t-il des données existantes à migrer ?             │
│    → Si oui : ajouter plan de migration avec rollback       │
│                                                              │
│  □ BUDGETS PERFORMANCE                                       │
│    → L'Epic a-t-il des contraintes de performance ?         │
│    → Des métriques cibles sont-elles définies ?             │
│    → Si oui : ajouter tableau des budgets perf              │
│                                                              │
│  □ RÉFÉRENCES WIREFRAMES                                     │
│    → L'Epic est-il UI-heavy ?                               │
│    → Y a-t-il des wireframes spécifiques à suivre ?         │
│    → Si oui : ajouter liste des wireframes concernés        │
│                                                              │
│  □ DÉCISIONS D'ARCHITECTURE                                  │
│    → Y a-t-il des choix techniques importants ?             │
│    → Des alternatives ont-elles été considérées ?           │
│    → Si oui : ajouter section ADR (Architecture Decision)   │
│                                                              │
│  □ INTÉGRATIONS EXTERNES                                     │
│    → L'Epic interagit-il avec des services externes ?       │
│    → Y a-t-il des APIs tierces à intégrer ?                 │
│    → Si oui : ajouter section intégrations avec specs       │
│                                                              │
│  □ SÉCURITÉ                                                  │
│    → L'Epic manipule-t-il des données sensibles ?           │
│    → Y a-t-il des considérations auth/authz ?               │
│    → Si oui : ajouter section sécurité                      │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Format des sections adaptatives :**

```markdown
## [Nom de la Section Adaptive]

[Contenu spécifique au contexte de l'Epic]

> Note: Section ajoutée car [raison contextuelle]
```

**Exemples de sections adaptatives :**

1. **Pour un Epic bloquant (ex: FOUNDATION):**
```markdown
## Dépendances

Cet Epic est **BLOQUANT** pour tous les autres :

​```
EPIC-00-FOUNDATION
    │
    ├──► EPIC-01-AUTH
    ├──► EPIC-02-PROFILE-SETTINGS
    ├──► EPIC-03-HOME
    └──► ... (tous les autres Epics)
​```

**Aucun autre Epic ne peut démarrer avant que celui-ci soit 100% complété.**
```

2. **Pour un Epic avec migrations DB:**
```markdown
## Plan de Migration

| Version | Action | Rollback |
|---------|--------|----------|
| v1 → v2 | Add column X | Drop column X |
| v2 → v3 | Create index Y | Drop index Y |

**Stratégie** : Migration incrémentale, testée sur copie avant prod.
```

3. **Pour un Epic UI-heavy:**
```markdown
## Wireframes de Référence

| Screen | Wireframe | Status |
|--------|-----------|--------|
| Home | docs/detailed/wireframes/home-v2.png | Validé |
| Settings | docs/detailed/wireframes/settings-v1.png | Draft |

Voir FD-08 pour design tokens à utiliser.
```

**Règle** : Une section adaptive doit TOUJOURS apporter de la valeur. Ne pas ajouter de sections vides "au cas où".

---

### 4. Generate TRACKING.md

**Load template and fill placeholders:**

```
{{EPIC_ID}} → {epic_id}
{{EPIC_NAME}} → {epic_name}
{{DATE}} → current date
{{STORIES_COUNT}} → {stories_count}
{{STORIES_PROGRESS}} → formatted table (all 🔵 Todo initially)
{{DOMAIN_CHECKLIST}} → grouped by domain from {stories}
```

**Progress Table Format:**

```markdown
| Story | Status | Assignee | Date Start | Date Done |
|-------|--------|----------|------------|-----------|
| STORY-00-01 | 🔵 Todo | - | - | - |
| STORY-00-02 | 🔵 Todo | - | - | - |
```

**Domain Checklist Format:**

```markdown
### INFRA (Stories 01, 02)

- [ ] pubspec.yaml avec packages requis
- [ ] Structure lib/{core,features,shared}
- [ ] {{LINT_CMD}}

### DATA (Stories 03, 04, 05)

- [ ] Tables: sessions, sets, exercises
- [ ] Indexes: idx_sessions_user, idx_sets_session
- [ ] Pragmas SQLCipher configures
```

### 5. Generate sources.yaml

**Load template and fill:**

```yaml
# Sources for {{EPIC_ID}}
# Generated by /create-epic v6

epic: {{EPIC_ID}}
version: 1
created_at: {{DATE}}
last_updated: {{DATE}}

discovery:
  method: {{DISCOVERY_METHOD}}
  confidence: {{CONFIDENCE}}

sources:
  primary:
    file: {{PRIMARY_FD_PATH}}
    sections: {{PRIMARY_SECTIONS}}
    mentions_in_prd: {{MENTIONS_COUNT}}

  secondary:
    {{SECONDARY_FDS}}

  detailed:
    {{DETAILED_DOCS}}

gaps:
  {{GAPS_LIST}}

validation:
  status: approved
  by: user
  date: {{DATE}}
```

### 6. Write All Files

Create files using Write tool:

```
Write: {epic_path}/EPIC-{epic_id}.md
Content: [filled Epic template]

Write: {epic_path}/TRACKING.md
Content: [filled Tracking template]

Write: {epic_path}/sources.yaml
Content: [filled sources template]
```

### 7. Verify Files Created

```bash
ls -la {epic_path}/
```

Expected:
```
EPIC-XX-NAME.md
TRACKING.md
sources.yaml
stories/
```

---

## AUTO-VALIDATION (APEX SELF-CRITIQUE)

**Before proceeding to next step, validate EPIC.md has:**

✅ Section "Contexte - Pourquoi cet Epic" present and filled
✅ Section "Piliers Techniques Concernes" present and filled
✅ Architecture diagram present (if INFRA or DATA domain)
✅ Stories table with ALL columns filled (no empty cells)
✅ Story details with COMPLETE criteria (no "...")
✅ Risks table present
✅ Gaps table present (if gaps exist)
✅ References FD table present
✅ ADAPTIVE SECTIONS CHECK executed
✅ Relevant adaptive sections added based on Epic context

**Validate TRACKING.md has:**

✅ Timeline section with creation date
✅ Progress table with all stories
✅ Problems section (even if empty placeholder)
✅ Decisions section (even if empty placeholder)
✅ Domain checklist grouped correctly
✅ Retrospective section (even if empty placeholder)

**Validate sources.yaml has:**

✅ Correct epic ID
✅ Discovery method recorded
✅ Primary source listed
✅ Secondary sources listed (if any)
✅ Gaps documented (if any)

**Self-Critique Questions:**
- Would a developer find all needed information in Epic.md?
- Are there any empty sections or placeholder text?
- Does the architecture diagram match the technical specs?
- Is TRACKING.md ready to track progress immediately?

**If validation fails:**
1. Identify missing sections
2. Fill from state variables (don't invent)
3. If data missing → check synthesis step
4. Regenerate failed file

---

## SUCCESS METRICS:

✅ Directory structure created
✅ EPIC-XX.md generated with all sections
✅ TRACKING.md generated with all sections
✅ sources.yaml generated correctly
✅ No placeholder content in any file
✅ Architecture diagram included (if applicable)
✅ All files validated before proceeding

## FAILURE MODES:

❌ Missing required sections in Epic.md
❌ Placeholder text ("TBD", "...", "N/A" where content should exist)
❌ Empty stories table
❌ Missing architecture diagram for INFRA/DATA
❌ Incorrect file paths
❌ Template not followed

## GENERATION PROTOCOLS:

- ALWAYS load template first
- ALWAYS fill ALL placeholders
- ALWAYS validate after writing
- NEVER skip sections for brevity
- NEVER add content not from synthesis
- Use exact formatting from templates

## NEXT STEP:

After all files generated and validated, load `steps/step-06-confirm.md`

<critical>
Templates exist for a reason - CONSISTENCY.
NEVER deviate from template structure.
NEVER omit sections.
Every Epic should look identical in structure.
</critical>
