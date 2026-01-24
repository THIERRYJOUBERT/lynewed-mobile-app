---
name: documentation
description: "Creer et mettre a jour intelligemment la documentation projet en analysant la conversation et les changements git. Utiliser apres une session de travail ou automatiquement par d'autres workflows."
model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - Task
  - AskUserQuestion
  - Skill
argument-hint: "[--auto] [--scope=workspace|detailed|epics|all] [--archive]"
---

<objective>
Creer et mettre a jour intelligemment la documentation projet en analysant la conversation et les changements git. Detecte automatiquement quoi documenter et ou. Documentation dense, datee, sourcee, exploitable par Claude.
</objective>

<critical_rule>
🛑 NEVER generer documentation verbose ou floue - toujours dense et exploitable
🛑 NEVER documenter sans sources (conversation, commit, fichier)
🛑 NEVER ecraser documentation existante sans merge intelligent
🛑 NEVER utiliser AskUserQuestion en mode --auto
✅ ALWAYS dater et sourcer chaque entree de documentation
✅ ALWAYS lancer 3 agents Sonnet en parallele (UN message)
✅ ALWAYS invoquer /sync-project a la fin si pertinent
✅ ALWAYS adapter le style au type de documentation (workspace vs detailed vs epics)
</critical_rule>

<when_to_use>
**Use this skill when:**
- Apres une session de travail significative necessitant documentation
- Quand des decisions techniques ont ete prises dans la conversation
- Apres implementation de features sans story formelle
- Pour archiver workspace/current vers archive

**Don't use for:**
- Simples corrections de typos → edit direct
- Story formelle avec tracking → /dev-story gere le tracking
- Mise a jour references uniquement → /sync-project
</when_to_use>

<modes>
| Mode | Flag | Comportement |
|------|------|--------------|
| **INTERACTIVE** | default | Questions si ambiguite, affiche plan avant generation |
| **AUTO** | `--auto` | 100% autonome, pas de questions, pour workflows |

**Arguments:**
- `--scope=workspace|detailed|epics|all` : Limiter le scope (default: all)
- `--archive` : Archiver workspace/current apres documentation
</modes>

<state_variables>
| Variable | Type | Description |
|----------|------|-------------|
| {mode} | enum | interactive ou auto |
| {scope} | enum | workspace, detailed, epics, ou all |
| {archive_after} | boolean | Archiver workspace/current apres |
| {conversation_insights} | object | Decisions, problemes, choix extraits |
| {git_changes} | array | Fichiers modifies avec resume |
| {existing_docs} | object | Documentation existante pertinente |
| {documentation_plan} | array | Plan: quoi documenter ou |
| {files_created} | array | Fichiers crees |
| {files_updated} | array | Fichiers mis a jour |
| {validation_status} | enum | PASS ou NEEDS_FIX |
</state_variables>

<entry_point>
Load `steps/step-00-detect.md`
</entry_point>

<step_files>
| Step | File | Purpose | Auto-Validation |
|------|------|---------|------------------|
| 00 | step-00-detect.md | Detecter mode, scope, flags | ✓ Variables initialisees |
| 01 | step-01-analyze.md | 3 agents Sonnet paralleles | ✓ Synthese disponible |
| 02 | step-02-categorize.md | Determiner quoi/ou documenter | ✓ Plan genere |
| 03 | step-03-generate.md | Creer/modifier documentation | ✓ Fichiers ecrits |
| 04 | step-04-validate.md | APEX review adversariale | ✓ Qualite validee |
| 05 | step-05-finalize.md | Archive + sync + rapport | ✓ Workflow complete |
</step_files>

<execution_rules>
1. **Progressive Loading**: Charger UN step a la fois, completer avant suivant
2. **Parallel Agents**: 3 agents en UN message pour step-01 (conversation, git, docs)
3. **Model Strategy**: opus orchestration, sonnet exploration (cout optimise)
4. **Mode Detection**: step-00 detecte mode, aucune question apres si --auto
5. **Intelligent Categorization**: step-02 decide intelligemment ou va chaque doc
6. **Dense Format**: Documentation compacte, datee, sourcee, exploitable
7. **Merge vs Replace**: Toujours preferer merge intelligent a remplacement
8. **Self-Healing**: Max 3 tentatives de fix en step-04 si issues
9. **Sync Integration**: Invoquer /sync-project --silent a la fin si pertinent
10. **Archive Optional**: --archive deplace workspace/current vers archive
</execution_rules>

<success_criteria>
✅ Documentation creee pour tout le travail pertinent
✅ Format dense, date, source (pas de fluff)
✅ Fichiers au bon endroit (workspace/detailed/epics selon contexte)
✅ Merge intelligent avec existant (pas d'ecrasement)
✅ APEX review validee (exploitable par Claude)
✅ Archive effectuee si demande
✅ /sync-project invoque si pertinent
</success_criteria>

<failure_modes>
❌ Conversation vide → Fallback git-only, rapport minimal si rien
❌ Git indisponible → Fallback conversation-only avec warning
❌ Scope trop large → Prioriser, compacter agressivement
❌ Documentation existante incoherente → Flag et demander user si interactif
❌ Validation echoue 3x → Accepter avec gaps documentes
</failure_modes>

<workflow_diagram>
```
┌─────────────────────────────────────────────────────────────────────┐
│                    /documentation WORKFLOW                           │
│         "Documentation intelligente conversation + git"              │
│                                                                      │
│  00. DETECT      → Mode (auto/interactive), scope, flags             │
│       ↓           ✓ Variables initialisees                           │
│                                                                      │
│  01. ANALYZE     → 3 agents Sonnet en PARALLELE                      │
│       │           ├── Agent 1: Conversation → insights               │
│       │           ├── Agent 2: Git → changes                         │
│       │           └── Agent 3: Docs → existing coverage              │
│       ↓           ✓ Synthese consolidee                              │
│                                                                      │
│  02. CATEGORIZE  → Determiner: quoi documenter + ou                  │
│       ↓           ✓ Plan de documentation                            │
│       │           [si interactive: afficher plan]                    │
│                                                                      │
│  03. GENERATE    → Creer/mettre a jour fichiers documentation        │
│       │           ├── workspace/current/ (sessions)                  │
│       │           ├── docs/detailed/ (specs techniques)              │
│       │           └── docs/epics/ (tracking stories)                 │
│       ↓           ✓ Fichiers crees/modifies                          │
│                                                                      │
│  04. VALIDATE    → APEX Review Adversariale                          │
│       │           ├── Dense? Date? Source?                           │
│       │           └── Si issues → fix loop (max 3)                   │
│       ↓           ✓ Documentation validee                            │
│                                                                      │
│  05. FINALIZE    → Archive + Sync + Rapport                          │
│       │           ├── Archive workspace/current si --archive         │
│       │           ├── Invoke /sync-project --silent si pertinent     │
│       │           └── Generer rapport final                          │
│       ↓                                                              │
│                                                                      │
│  OUTPUT: Documentation creee + rapport                               │
└─────────────────────────────────────────────────────────────────────┘
```
</workflow_diagram>

<begin>
Load `steps/step-00-detect.md` to start the workflow.
</begin>
