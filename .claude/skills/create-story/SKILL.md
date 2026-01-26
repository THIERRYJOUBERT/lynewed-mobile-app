---
name: create-story
description: "Creer des user stories development-ready depuis un Epic. Utiliser pour decomposer un Epic en stories INVEST."
model: opus
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, TodoWrite, Skill
argument-hint: "[epic-id] [--auto]"
---

<objective>
Decomposer un Epic en user stories INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable) avec criteres d'acceptation Gherkin, prets pour implementation via /dev-story.
</objective>

<modes>
| Mode | Flag | Comportement |
|------|------|--------------|
| **INTERACTIVE** | default | Checkpoint a step-02 pour validation user des stories proposees |
| **AUTO** | `--auto` | 100% autonome, pas de checkpoint, genere directement |

**Arguments:**
- `[epic-id]` : ID de l'Epic (ex: "EPIC-01", "EPIC-00-FOUNDATION")
- `--auto` : Mode autonome, skip le checkpoint de validation
</modes>

<critical_rule>
🛑 NEVER creer stories sans Epic valide
🛑 NEVER creer stories XL (13+ points) - diviser obligatoirement
🛑 NEVER ecrire criteres vagues ("devrait fonctionner")
🛑 NEVER ignorer conflits de fichiers entre stories paralleles
🛑 NEVER use AskUserQuestion in --auto mode
✅ ALWAYS lire l'Epic completement avant decomposition
✅ ALWAYS proposer decomposition pour validation utilisateur (sauf --auto)
✅ ALWAYS ecrire criteres d'acceptation Gherkin
✅ ALWAYS identifier fichiers a creer/modifier
✅ ALWAYS verifier conflits pour dev parallele
✅ ALWAYS mettre a jour TRACKING.md avec IMPLEMENTATION COMPLETE
</critical_rule>

<when_to_use>
**Use this skill when:**
- Vous avez un Epic valide dans docs/epics/
- Vous devez decomposer l'Epic en stories implementables
- Vous preparez le backlog pour developpement

**Don't use for:**
- Creation d'Epic → use /create-epic
- Implementation de story → use /dev-story
- Debug ou correction → use /debug
- Dev rapide sans Epic → use /oneshot
</when_to_use>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| {mode} | enum | interactive ou auto (default: interactive) |
| {epic_id} | string | ID de l'Epic (ex: EPIC-01) |
| {epic_path} | string | Chemin vers le fichier Epic |
| {epic_content} | object | Contenu parse de l'Epic |
| {proposed_stories} | array | Stories proposees |
| {approved_stories} | array | Stories validees (ou auto-approuvees si --auto) |
| {file_conflicts} | array | Conflits detectes |
| {stories_created} | array | Fichiers story crees |
</state_variables>

<entry_point>
Load `steps/step-00-init.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|------------------|
| 00 | step-00-init.md | Parse args + Verifier Epic + mode | ✓ Epic existe, mode set |
| 01 | step-01-analyze.md | Analyser Epic + extraire scope | ✓ Scope compris |
| 02 | step-02-propose.md | Proposer decomposition (CHECKPOINT si interactive) | ✓ Stories proposees |
| 03 | step-03-generate.md | Generer fichiers story | ✓ Fichiers crees |
| 04 | step-04-validate.md | Valider + **UPDATE TRACKING.md** | ✓ TRACKING.md a jour |
| 05 | (inline) | Finalization intelligente | Propose sync si pertinent |
</step_files>

<execution_rules>
1. **Progressive Loading**: Load one step at a time
2. **Mode-Conditional Checkpoint**:
   - INTERACTIVE: Checkpoint obligatoire apres step-02 (proposition)
   - AUTO: Pas de checkpoint, stories auto-approuvees
3. **INVEST Mandatory**: Chaque story doit passer criteres INVEST
4. **Gherkin Required**: Criteres d'acceptation en format Gherkin
5. **Conflict Detection**: Verifier fichiers modifies entre stories
6. **Self-Healing**: Max 5 tentatives avec apprentissage
7. **Template Usage**: Utiliser templates/story-template.md
8. **TRACKING Update**: Step-04 DOIT mettre a jour TRACKING.md avec implementation complete
9. **Intelligent Finalization**: After step-04, propose sync based on work done (sauf --auto)
</execution_rules>

<success_criteria>
✅ Toutes stories respectent criteres INVEST
✅ Criteres d'acceptation Gherkin complets
✅ Fichiers story crees dans docs/epics/EPIC-XX/stories/
✅ Conflits de fichiers detectes et documentes
✅ TRACKING.md de l'Epic mis a jour avec:
   - Stories ajoutees a la table
   - Dependances documentees
   - Ordre d'execution suggere
✅ Stories prets pour /dev-story
</success_criteria>

<failure_modes>
❌ Epic non trouve → Fallback: AskUserQuestion pour Epic correct (si interactive)
❌ Epic incomplet → Fallback: Documenter gaps, demander clarification
❌ Story trop grosse → Fallback: Proposer sous-division
❌ Conflits non resolus → Fallback: Documenter, ordre suggere
❌ Criteres vagues → Self-healing: reformuler en Gherkin precis
</failure_modes>

<workflow_diagram>
```
┌──────────────────────────────────────────────────────────────────┐
│                    /create-story WORKFLOW                         │
│         "Epic → Stories INVEST"                                   │
│                                                                   │
│  00. INIT        → Parse args (epic-id, --auto) + verify Epic    │
│       ↓           ✓ Epic valide, mode set                         │
│                                                                   │
│  01. ANALYZE     → Lire Epic, extraire objectifs                  │
│       ↓           ✓ Scope et features identifies                  │
│                                                                   │
│  02. PROPOSE     → Proposer decomposition stories                 │
│       ↓           [si INTERACTIVE: CHECKPOINT utilisateur]        │
│       ↓           [si AUTO: auto-approve, continue]               │
│       ↓           ✓ Stories INVEST validees/auto-approuvees       │
│                                                                   │
│  03. GENERATE    → Creer fichiers story                           │
│       ↓           ✓ Fichiers .md generes                          │
│                                                                   │
│  04. VALIDATE    → Verifier conflits + UPDATE TRACKING.md         │
│       ↓           ✓ Stories in table + deps + order               │
│                                                                   │
│  05. FINALIZE    → Propose sync (intelligent)                     │
│                    SI interactive: AskUserQuestion                │
│                    SI auto: /sync-project --silent                │
│                                                                   │
│  OUTPUT: Stories prets pour /dev-story                            │
└──────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<finalization_pattern>
## Étape 05 - Finalization Intelligente

Référence: `.claude/skills/sync-project/references/workflow-finalization.md`

### Logique

Après step-04 VALIDATE, évaluer le travail effectué :

**Travail significatif détecté ?** (création stories = TOUJOURS OUI)
- Nouveaux fichiers story créés
- TRACKING.md mis à jour

### Exécution selon mode

**SI mode = INTERACTIVE:**

```
question: "Stories créées avec succès. Voulez-vous synchroniser les références projet ?"
header: "Finalisation"
options:
  - label: "Sync références (Recommandé)"
    description: "Met à jour INDEX.md avec les nouvelles stories"
  - label: "Non merci"
    description: "Les stories sont prêtes, sync plus tard"
```

SI utilisateur choisit Sync → Invoke `/sync-project --silent`
SI utilisateur decline → Fin du workflow

**SI mode = AUTO:**

Exécuter automatiquement sans question:
→ Invoke `/sync-project --silent`
→ Afficher résumé final
</finalization_pattern>

<begin>
Load `steps/step-00-init.md` to start the workflow.
</begin>
