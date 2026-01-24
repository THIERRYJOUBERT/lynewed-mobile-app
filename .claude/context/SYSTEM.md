# {{PROJECT_NAME}} Development System

> **Version** : 3.0.0
> **Remplace** : WORKFLOW.md + DECISIONS.md
> **Usage** : Source de vérité unique pour les workflows et l'architecture

---

## 1. Vision du Système

### Objectif

Un système de développement AI-assisté qui :
- **Fonctionne en mode autonomous** (agents travaillent seuls)
- **Fonctionne en mode supervised** (co-développement avec utilisateur)
- **Est réutilisable** dans d'autres projets (avec adaptation minimale)
- **Garantit la qualité** (TDD, Review Adversariale, Self-Healing)

### Principes Fondamentaux

| Principe | Description |
|----------|-------------|
| **"Minimal" = Parfait** | Bases parfaites sans superflu, PAS brouillon |
| **TDD Obligatoire** | RED → GREEN → REFACTOR pour chaque critère |
| **Review Adversariale** | Changer de rôle pour critiquer son propre travail |
| **Self-Healing** | Boucles de correction automatiques (max 5 tentatives) |
| **Isolation de Contexte** | Chaque phase/agent a un contexte frais |
| **Finalization Intelligente** | Sync/doc optionnel selon mode et travail effectué |

---

## 2. Architecture des Composants

### Features Officielles Claude Code

| Feature | Dossier | Usage |
|---------|---------|-------|
| **Skills** | `.claude/skills/` | Prompts réutilisables avec orchestration |
| **Subagents** | `.claude/agents/` | Agents isolés pour tâches spécialisées |
| **Commands** | `.claude/commands/` | Legacy, garder ce qui marche |
| **Rules** | `.claude/rules/` | Règles globales et path-scoped |
| **Hooks** | `.claude/settings.json` | Scripts lifecycle |

### Hiérarchie de Confiance

```
1. PRD-MASTER Section 10       ← Philosophie dev (source ultime)
2. .claude/context/SYSTEM.md   ← Ce fichier (architecture workflows)
3. .claude/rules/              ← Règles techniques
4. .claude/skills/             ← Implémentation des workflows
5. .claude/agents/             ← Subagents spécialisés
```

---

## 3. Modes de Fonctionnement

### Mode AUTONOMOUS

```
Utilisateur: /launch-epic EPIC-XX --mode=autonomous
                    │
                    ▼
            Epic Assistant (démarre seul)
                    │
        ┌───────────┴───────────────────┐
        │     Pour chaque Story         │
        ▼                               │
    Story Workflow                      │
        │                               │
        ├── 01. ANALYZE   (Read only)   │
        ├── 02. PLAN      (Strategy)    │
        ├── 03. EXECUTE   (TDD code)    │
        ├── 04. VALIDATE  (Lint/Build)  │ ← AVANT Review!
        ├── 05. EXAMINE   (Review)      │ ← Sur code validé
        ├── 06. RESOLVE   (Fix review)  │
        ├── 07. TEST LOOP ──────────────┤ (max 5 tentatives)
        │       │                       │
        │       └── Analyze → Adjust ───┤
        │                               │
        └── 08. COMMIT    (Si OK)       │
                    │                   │
                    └───────────────────┘
                    │
                    ▼
            FINALIZATION (Agent Sonnet pour sync/doc)
                    │
                    ▼
            Epic Complete → Rapport final
```

**Caractéristiques :**
- L'utilisateur ne fait RIEN après le lancement
- VALIDATE technique (lint, typecheck, build) AVANT la Review Adversariale
- Boucles self-healing intelligentes (max 5 tentatives, analyse de l'échec à chaque itération)
- Commit automatique après chaque story validée
- Finalization via Agent Sonnet (sync/doc sans polluer contexte principal)
- S'arrête seulement : Epic complete OU blocage critique (après 5 tentatives)

### Mode SUPERVISED

```
Utilisateur: /launch-epic EPIC-XX --mode=supervised
                    │
                    ▼
            Epic Assistant (dialogue)
                    │
                    ▼
            "Comment veux-tu travailler ?"
                    │
        ┌───────────┼───────────┐
        │           │           │
   Story by Story   Guide-moi   Je propose
        │           │           │
        ▼           ▼           ▼
    Pour chaque Story:
        │
        ├── Clarification (AskUserQuestion)
        ├── Story Workflow avec validation
        ├── Review interactive
        └── Commit validé par user
                    │
                    ▼
            FINALIZATION (AskUserQuestion: sync/doc?)
```

**Caractéristiques :**
- Dialogue constant avec l'utilisateur
- Décisions à chaque étape importante
- Finalization optionnelle via AskUserQuestion
- L'utilisateur peut changer d'approche à tout moment
- Plus agile, plus de contrôle

---

## 4. Story Workflow (Principal)

Le workflow principal pour implémenter une story. Utilisable en autonomous ET supervised.

### Séquence

```
┌──────────────────────────────────────────────────────────────┐
│                    STORY WORKFLOW                             │
│                                                               │
│  01. ANALYZE   → Lire story, comprendre critères             │
│       ↓                                                       │
│  02. PLAN      → Identifier fichiers, ordre des critères     │
│       ↓                                                       │
│  03. EXECUTE   → TDD: RED → GREEN → REFACTOR (par critère)   │
│       ↓                                                       │
│  04. VALIDATE  → Lint, typecheck, build (technique)          │
│       ↓         ← AVANT la review! Pas de sens reviewer      │
│       │           du code qui ne compile pas.                │
│       ↓                                                       │
│  05. EXAMINE   → REVIEW ADVERSARIALE (sur code validé!)      │
│       ↓                                                       │
│  06. RESOLVE   → Corriger problèmes de review                │
│       ↓         ↑                                             │
│       └─────────┘ (max 5 itérations)                         │
│       ↓                                                       │
│  07. TEST LOOP → Self-healing si tests fail                  │
│       ↓         ↑                                             │
│       └─────────┘ (max 5 tentatives, analyser chaque échec)  │
│       ↓                                                       │
│  08. COMMIT    → PR ou commit si tout passe                  │
│       ↓                                                       │
│  09. FINALIZE  → Sync/doc selon mode (optionnel)             │
└──────────────────────────────────────────────────────────────┘
```

**Nuance importante** : VALIDATE (technique) vient AVANT EXAMINE (review). On ne fait pas de review adversariale sur du code qui ne passe pas le lint/build.

### Détail des Phases

#### ANALYZE
- Lire la story complètement
- Comprendre critères d'acceptation (Gherkin)
- Identifier dépendances et contraintes
- **Output** : Compréhension claire du scope

#### PLAN
- Lister critères par ordre de dépendance
- Identifier fichiers à créer/modifier
- **Ne pas charger tout le contexte** - seulement ce qui est nécessaire
- **Output** : Plan d'exécution

#### EXECUTE (TDD par critère)
Pour CHAQUE critère d'acceptation :

```
RED    → Écrire test qui échoue
       → Exécuter test pour confirmer fail

GREEN  → Écrire code MINIMAL qui fait passer
       → Pas d'extras, pas d'optimisations
       → Exécuter test pour confirmer pass

REFACTOR → Nettoyer sans changer comportement
         → Tests doivent rester verts
```

**Isolation requise** : Idéalement chaque phase dans un contexte frais pour éviter le "faux TDD".

#### EXAMINE (Review Adversariale)

**CHANGEMENT DE RÔLE OBLIGATOIRE**

Tu n'es PLUS le développeur. Tu es maintenant un **Reviewer Senior Impitoyable** dont l'unique but est de TROUVER DES PROBLÈMES.

**Checklist :**
- [ ] Sécurité : Injection, secrets, validation inputs
- [ ] Logique : Edge cases, race conditions, erreurs silencieuses
- [ ] Cohérence : IDs, nommage, conventions
- [ ] Tests : Cas limites, comportement d'erreur

**Règle d'or** : Si 0 problème trouvé → Re-examiner. C'est suspect.

**Output** :
```
REVIEW ADVERSARIALE - STORY-XX-YY

PROBLÈMES TROUVÉS:
1. [CRITIQUE] Description - fichier:ligne
2. [IMPORTANT] Description - fichier:ligne
3. [MINEUR] Description - fichier:ligne

VERDICT: APPROVE | REJECT | NEEDS_WORK
```

#### RESOLVE
Pour chaque problème identifié :
1. Écrire test qui expose le problème (si pas déjà testé)
2. Corriger le code
3. Vérifier que le test passe

**Boucle** : EXAMINE → RESOLVE → EXAMINE (max 5 itérations, analyser chaque échec)

#### VALIDATE
- Exécuter tous les tests : `{{TEST_CMD}}`
- Analyse statique : `{{LINT_CMD}}`
- Mettre à jour documentation (TRACKING.md, Story status)
- Commit si tout passe

#### FINALIZE (Intelligent)
Voir Section 8 "Intelligent Finalization Pattern"

---

## 5. TDD Isolation Pattern

### Problème

Dans un seul contexte, le LLM design subconsciously les tests autour de l'implémentation prévue → **faux TDD**.

### Solution

Chaque phase TDD = **subagent isolé** avec contexte frais :

```
RED Phase      → Subagent "Test Writer" (ne connaît pas l'implémentation)
GREEN Phase    → Subagent "Implementer" (ne connaît que le test)
REFACTOR Phase → Subagent "Refactorer" (code + tests uniquement)
```

### Implémentation {{PROJECT_NAME}}

Actuellement via `story-executor.md` qui contient les 3 phases. Pour améliorer l'isolation :
- Option A : Instructions très explicites de "oublier" le contexte précédent
- Option B : Trois subagents séparés (plus de tokens, meilleure isolation)
- Option C : Hooks pour forcer l'isolation (à explorer)

---

## 6. Review Adversariale Pattern

### Origine

APEX Review Pattern (dev melvyn youtube source)

### Principes

| Élément | Description |
|---------|-------------|
| **Builder** | Génère le code (optimisé vitesse) |
| **Critic** | Évalue contre la spec (optimisé rigueur) |
| **Context Break** | Critic démarre session NEUVE |
| **Loop** | Builder → Critic → corrections → repeat |

### Résultats Documentés

- Qualité code : +40-60%
- Bugs post-deploy : -60%

### Implémentation {{PROJECT_NAME}}

Dans chaque skill/agent qui produit du code :
1. Phase EXECUTE = Builder
2. Phase EXAMINE = Critic (avec changement de rôle explicite)
3. Phase RESOLVE = Corrections
4. Repeat max 5 fois (analyse intelligente à chaque itération)

---

## 7. Self-Healing Loops

### Concept

Quand quelque chose échoue (test, build, review), ne pas abandonner immédiatement. Chaque tentative doit être **intelligente** : analyser l'échec et ajuster l'approche.

```
TENTATIVE 1: Échoue
     ↓
     ANALYSER : Pourquoi ? Quelle est la cause racine ?
     ↓
TENTATIVE 2: Échoue (approche ajustée)
     ↓
     ANALYSER : Nouvelle information ? Ajuster encore
     ↓
... (jusqu'à 5 tentatives)
     ↓
TENTATIVE 5: Échoue
     ↓
     ESCALADE avec rapport détaillé des 5 tentatives
```

### Implémentation

```
MAX_ATTEMPTS = 5

for attempt in range(MAX_ATTEMPTS):
    execute()
    if success:
        break
    else:
        # OBLIGATOIRE : comprendre l'échec avant de réessayer
        failure_analysis = analyze_failure()
        adjusted_approach = adjust_based_on_analysis(failure_analysis)
        log_attempt(attempt, failure_analysis, adjusted_approach)

if not success:
    escalate_with_full_report(all_attempts)
```

### Règle d'or

> "Chaque tentative doit APPRENDRE de la précédente. Répéter la même chose 5 fois = échec du self-healing."

---

## 8. Intelligent Finalization Pattern

### Concept

À la fin de chaque workflow significatif, proposer de synchroniser les références et/ou documenter le travail, selon :
1. Le **mode** (supervised vs autonomous)
2. Le **travail effectué** (significatif vs trivial)

### Décision Logic

```
Workflow terminé
      │
      ├── Travail significatif ?
      │         │
      │    NON ─┴─► Fin (pas de proposition)
      │         │
      │    OUI ─┬─► Mode SUPERVISED ?
      │         │         │
      │         │    OUI ─┴─► AskUserQuestion (choix utilisateur)
      │         │         │
      │         │    NON ─┴─► Agent Sonnet (sync/doc automatique)
      │         │
      └─────────┴─► Workflow complete
```

### Critères "Travail Significatif"

| Workflow | Significatif ? | Critère |
|----------|---------------|---------|
| `/dev-story` | TOUJOURS | Story = feature complète |
| `/oneshot` | TOUJOURS | Feature complète |
| `/launch-epic` | TOUJOURS | Epic = plusieurs stories |
| `/create-epic` | TOUJOURS | Nouveaux fichiers créés |
| `/create-story` | TOUJOURS | Nouveaux fichiers créés |
| `/debug` | CONDITIONNEL | Fix structural ou complexe = OUI, typo = NON |

### Mode SUPERVISED : AskUserQuestion

```
question: "Travail terminé avec succès. Voulez-vous synchroniser les références et/ou documenter ?"
header: "Finalisation"
options:
  - label: "Sync + Documentation (Recommandé)"
    description: "Met à jour les références + documente le travail"
  - label: "Sync uniquement"
    description: "Met à jour les fichiers de référence"
  - label: "Documentation uniquement"
    description: "Documente cette session de travail"
  - label: "Terminer sans"
    description: "Le travail est fait, pas besoin de plus"
```

### Mode AUTONOMOUS : Agent Sonnet

```
{Task tool}
subagent_type: general-purpose
model: sonnet
description: "Workflow finalization sync/doc"
prompt: |
  Travail terminé: {description}

  1. Execute /sync-project --silent (si structure modifiée)
  2. Execute /documentation --auto --scope=workspace

  Exécute silencieusement, pas besoin de rapport détaillé.
```

**Pourquoi Agent Sonnet ?**
- Isolation de contexte (ne pollue pas le contexte principal)
- Économie de tokens (sonnet < opus)
- Exécution silencieuse (pas de bruit dans la conversation)

### Référence

Pattern complet dans : `.claude/skills/sync-project/references/workflow-finalization.md`

---

## 9. Catalogue des Workflows

### Workflows de Développement

| Workflow | Usage | Mode |
|----------|-------|------|
| `/dev-story` | Implémenter une story formelle (TDD, Review) | supervised/auto |
| `/oneshot` | Dev rapide APEX sans Epic/Story (< 1 jour) | supervised/auto |
| `/debug` | Debugging scientifique (Constrained ReAct) | interactif/auto |
| `/commit` | Commit avec vérifications (bloque si fail) | - |

### Workflows de Création

| Workflow | Usage | Mode |
|----------|-------|------|
| `/create-epic` | Créer Epic depuis PRD-MASTER | supervised |
| `/create-story` | Décomposer Epic en Stories INVEST | supervised |
| `/create-workflow` | Créer/mettre à jour un workflow | supervised |

### Workflows d'Orchestration

| Workflow | Usage | Mode |
|----------|-------|------|
| `/launch-epic` | Lancer un Epic complet | supervised/autonomous |

### Workflows Utilitaires

| Workflow | Usage | Mode |
|----------|-------|------|
| `/sync-project` | Synchroniser INDEX, README, CLAUDE.md | silent/normal |
| `/documentation` | Générer documentation de session | auto/interactive |
| `/prompt` | Transformer prompt en anglais optimisé | - |
| `/explore` | Exploration deep codebase/docs/web | - |

---

## 10. Détail des Workflows

### /dev-story - Story Development

Implémentation complète d'une story avec qualité APEX.

```
┌──────────────────────────────────────────────────────────────────┐
│                    /dev-story WORKFLOW                            │
│                                                                   │
│  00. LOAD        → Charger story + valider prerequis             │
│       ↓           ✓ Story file loaded, criteria parsed           │
│                                                                   │
│  01. EXPLORE     → 3 Sonnet agents en PARALLELE                  │
│       ↓           ✓ Patterns, fichiers, story-context identifies │
│                                                                   │
│  02. PLAN        → Generer plan TDD par critere                  │
│       ↓           ✓ Plan complet + risques identifies            │
│       │           [si SUPERVISED: CHECKPOINT utilisateur]        │
│       ↓                                                           │
│  03. EXECUTE     → APEX Engine                                   │
│       │           ├── TDD: RED → GREEN → REFACTOR (par critere)  │
│       │           ├── VALIDATE: tests + analyze                  │
│       │           ├── EXAMINE: Review Adversariale               │
│       │           └── RESOLVE: corrections (max 5)               │
│       ↓           ✓ Code, tests, review OK                       │
│                                                                   │
│  04. VERIFY      → Validation finale                             │
│       ↓           ✓ {{TEST_CMD}} + analyze = 0 warnings          │
│                                                                   │
│  05. COMMIT      → Finalisation via /commit                      │
│       ↓           ✓ Story status "Done" + TRACKING.md updated    │
│                                                                   │
│  06. FINALIZE    → Intelligent (selon mode)                      │
│                    SUPERVISED: AskUserQuestion                   │
│                    AUTO: Agent Sonnet sync/doc                   │
└──────────────────────────────────────────────────────────────────┘
```

### /oneshot - Dev Rapide APEX

Développement rapide avec qualité APEX pour features < 1 jour.

```
┌──────────────────────────────────────────────────────────────────┐
│                    /oneshot WORKFLOW                              │
│                                                                   │
│  00. PREREQUIS   → Clarifier demande + détecter mode             │
│       ↓           ✓ Mode AUTO ou SUPERVISED défini               │
│                                                                   │
│  01. EXPLORE     → 3 Sonnet agents en PARALLELE                  │
│       ↓           ✓ Patterns, fichiers, docs identifies          │
│                                                                   │
│  02. PLAN        → Générer plan d'implémentation                 │
│       ↓           ✓ Plan complet + risques identifies            │
│       │           [si SUPERVISED: CHECKPOINT utilisateur]        │
│       ↓                                                           │
│  03. EXECUTE     → APEX Engine                                   │
│       │           ├── TDD: RED → GREEN → REFACTOR                │
│       │           ├── VALIDATE: tests + analyze                  │
│       │           ├── EXAMINE: Review Adversariale               │
│       │           └── RESOLVE: corrections (max 5)               │
│       ↓           ✓ Code, tests, review OK                       │
│                                                                   │
│  04. VERIFY      → Validation finale                             │
│       ↓           ✓ {{TEST_CMD}} + analyze = 0 warnings          │
│                                                                   │
│  05. COMMIT      → Finalisation via /commit                      │
│       ↓           ✓ Commit créé avec résumé                      │
│                                                                   │
│  06. FINALIZE    → Intelligent (selon mode)                      │
│                    SUPERVISED: AskUserQuestion                   │
│                    AUTO: Agent Sonnet sync/doc                   │
└──────────────────────────────────────────────────────────────────┘
```

### /debug - Scientific Debugging

Debugging scientifique avec Constrained ReAct (PROUVER avant de FIXER).

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        /debug WORKFLOW                                   │
│                                                                          │
│  00. CAPTURE   → Capturer symptome + contexte (git, tests, fichiers)    │
│       │          → Détecter mode (--auto ou interactif)                 │
│       ↓                                                                  │
│  01. OBSERVE   → Collecter FAITS (stack trace, logs, flux)              │
│       │          → SI bug dynamique : proposer instrumentation          │
│       │          → INTERDIT : modifier code métier                      │
│       ↓                                                                  │
│  02. HYPOTHESIZE → Formuler hypothèse basée sur FAITS                   │
│       │          → PROUVER via logs/tests/analyse                       │
│       │          → Si non prouvée : retour 01                           │
│       ↓                                                                  │
│  03. STRATEGIZE → Générer 3 solutions avec scoring                      │
│       │          → Effort × Risque × Impact                             │
│       │          → SI interactif : AskUserQuestion                      │
│       │          → SI auto : choisir Recommended                        │
│       ↓                                                                  │
│  04. FIX       → Appliquer solution choisie                             │
│       │          → Écrire test reproduisant le bug                      │
│       │          → NETTOYER logs de debug                               │
│       ↓                                                                  │
│  05. VERIFY    → Tests + Analyse                                        │
│       │          → SI échec : retour 00 avec nouvelles connaissances    │
│       ↓                                                                  │
│  06. FINALIZE  → Intelligent (si fix significatif)                      │
│                   → SUPERVISED: AskUserQuestion                         │
│                   → AUTO: Agent Sonnet sync/doc                         │
│                   → Trivial: pas de proposition                         │
└─────────────────────────────────────────────────────────────────────────┘
```

**Principe clé** : L'action "Modifier le code métier" est **INTERDITE** tant que la cause racine n'est pas **PROUVÉE**.

### /create-epic - Epic Creation

Créer un Epic depuis PRD-MASTER avec validation qualité.

```
┌──────────────────────────────────────────────────────────────────┐
│                    /create-epic WORKFLOW                          │
│                                                                   │
│  00. INIT       → Parser arguments, vérifier PRD-MASTER           │
│       ↓                                                           │
│  01. EXPLORE    → 3 agents parallèles : codebase, docs, patterns  │
│       ↓                                                           │
│  02. DESIGN     → Créer structure Epic                            │
│       ↓          [CHECKPOINT: validation utilisateur]             │
│                                                                   │
│  03. GENERATE   → Générer fichiers Epic                           │
│       ↓                                                           │
│  04. VALIDATE   → Completeness challenge                          │
│       ↓                                                           │
│  05. REGISTER   → Mettre à jour TRACKING, CROSS-EPIC              │
│       ↓                                                           │
│  06. COMMIT     → Commit initial Epic                             │
│       ↓                                                           │
│  07. FINALIZE   → Intelligent (AskUserQuestion: sync?)            │
└──────────────────────────────────────────────────────────────────┘
```

### /create-story - Story Creation

Décomposer un Epic en Stories INVEST.

```
┌──────────────────────────────────────────────────────────────────┐
│                    /create-story WORKFLOW                         │
│                                                                   │
│  00. INIT       → Vérifier Epic existe                            │
│       ↓          ✓ Epic valide et accessible                     │
│                                                                   │
│  01. ANALYZE    → Lire Epic, extraire objectifs                   │
│       ↓          ✓ Scope et features identifiés                  │
│                                                                   │
│  02. PROPOSE    → Proposer décomposition stories                  │
│       ↓          [CHECKPOINT utilisateur]                        │
│       ↓          ✓ Stories INVEST validées                       │
│                                                                   │
│  03. GENERATE   → Créer fichiers story                            │
│       ↓          ✓ Fichiers .md générés                          │
│                                                                   │
│  04. VALIDATE   → Vérifier conflits + update TRACKING             │
│       ↓          ✓ Tout cohérent et documenté                    │
│                                                                   │
│  05. FINALIZE   → Intelligent (AskUserQuestion: sync?)            │
└──────────────────────────────────────────────────────────────────┘
```

### /launch-epic - Epic Orchestration

Coordonner l'implémentation d'un Epic complet.

```
┌─────────────────────────────────────────────────────────────────┐
│                    /launch-epic WORKFLOW                         │
│                                                                  │
│  00. INIT       → Parse args, charger contexte, vérifier         │
│       ↓          (ERROR HANDLING inclus)                        │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  MODE DETECTION                                         │    │
│  │                                                         │    │
│  │  supervised?  ─────────────► Workflow interactif       │    │
│  │                              (dialogue à chaque story)  │    │
│  │                                                         │    │
│  │  autonomous?  ─────────────► Workflow automatique      │    │
│  │                              (Task tool pour chaque)    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  03. REVIEW     → Review adversariale (commun aux 2 modes)      │
│       ↓                                                          │
│                                                                  │
│  04. FINALIZE   → Rapport final, validation Epic                 │
│       ↓                                                          │
│                                                                  │
│  05. SYNC/DOC   → Intelligent (selon mode)                       │
│                   SUPERVISED: AskUserQuestion                    │
│                   AUTONOMOUS: Agent Sonnet sync/doc              │
└─────────────────────────────────────────────────────────────────┘
```

### /commit - Commit Intégré

Commit avec vérifications {{PROJECT_NAME}} obligatoires.

```
1. VERIFY     → {{TEST_CMD}} + {{LINT_CMD}}
2. CHECK      → Tests passent ? Warnings = 0 ?
3. STAGE      → git add (fichiers pertinents)
4. COMMIT     → Message conventionnel
5. PUSH       → Auto-push vers dev
```

**Contrainte** : **NE PAS commiter si tests fail ou warnings**

### /sync-project - Synchronisation

Synchroniser les fichiers de référence projet.

**Fichiers gérés** :
- `docs/specs/INDEX.md` - Index des documents
- `README.md` - README projet (si modif structure)
- `CLAUDE.md` - Instructions Claude (si nouveaux workflows)

**Modes** :
- Normal : Affiche changements, demande confirmation
- `--silent` : Exécute sans interaction (appelé par autres workflows)

### /create-workflow - Meta-Workflow

Meta-skill pour créer et mettre à jour des workflows selon les 14 best practices.

**Modes** :
- **CREATE** : `/create-workflow nom` → Créer nouveau workflow
- **UPDATE** : `/create-workflow existant` → Améliorer workflow existant

**Les 14 Patterns Encodés** :

| # | Pattern | Catégorie |
|---|---------|-----------|
| 1 | Multi-File Architecture | Architecture |
| 2 | Model Strategy (opus/sonnet) | Performance |
| 3 | APEX Self-Validation | Qualité |
| 4 | Completeness Challenge | Qualité |
| 5 | Template Vivant | Architecture |
| 6 | Parallel Agent Execution | Performance |
| 7 | Single User Interaction | UX |
| 8 | Fallback Strategies | Résilience |
| 9 | Gap Documentation | Résilience |
| 10 | Progressive Step Loading | Architecture |
| 11 | State Variable Management | Architecture |
| 12 | Universal Step Structure | Qualité |
| 13 | Sandwich Structure | Qualité |
| 14 | Injection Contextuelle | Performance |

---

## 11. Structure des Stories

### Format INVEST

| Critère | Description |
|---------|-------------|
| **I**ndependent | Peut être développée seule |
| **N**egotiable | Détails peuvent être affinés |
| **V**aluable | Délivre valeur |
| **E**stimable | Assez claire pour estimer |
| **S**mall | 1-8 points (pas XL) |
| **T**estable | A des critères Gherkin |

### Template

```markdown
# Story XX-YY : [Titre]

> **Status** : À faire | En cours | Done
> **Points** : X
> **Epic** : EPIC-XX

## User Story

**En tant que** [persona],
**Je veux** [action],
**Afin de** [bénéfice].

## Critères d'Acceptation

### AC-1: [Titre]

```gherkin
Scenario: [Nom]
  Given [contexte]
  When [action]
  Then [résultat]
```

## Fichiers à Créer/Modifier

| Action | Fichier |
|--------|---------|
| CREATE | |
| MODIFY | |

## Definition of Done

- [ ] Tous les critères d'acceptation passent
- [ ] Tests unitaires écrits et passants
- [ ] Review Adversariale effectuée
- [ ] Pas de warnings
```

---

## 12. Réutilisabilité

### Ce qui est spécifique à {{PROJECT_NAME}}

| Élément | Adaptation pour autre projet |
|---------|------------------------------|
| `{{TEST_CMD}}/analyze` | Remplacer par commandes du projet |
| Dossiers `lib/`, `test/` | Adapter à la structure |
| Story template | Adapter persona et contexte |

### Ce qui est universel

| Élément | Réutilisable tel quel |
|---------|----------------------|
| Story Workflow séquence | ANALYZE → PLAN → EXECUTE → VALIDATE → EXAMINE → RESOLVE → TEST → COMMIT → FINALIZE |
| TDD cycle | RED → GREEN → REFACTOR |
| Review Adversariale | Changement de rôle + checklist |
| Self-Healing loops | Max 5 tentatives intelligentes avant escalade |
| Modes autonomous/supervised | Architecture identique |
| Intelligent Finalization | Pattern sync/doc selon mode |

---

## 13. Références

### Pattern Finalization
- [.claude/skills/sync-project/references/workflow-finalization.md](../skills/sync-project/references/workflow-finalization.md)

### Best Practices Workflows
- [.claude/skills/create-workflow/references/best-practices.md](../skills/create-workflow/references/best-practices.md)

### Philosophie Dev
- [docs/specs/PRD-MASTER.md Section 10](../../docs/specs/PRD-MASTER.md#10-philosophie-de-developpement)

### Règles Techniques
- [.claude/rules/core-rules.md](../rules/core-rules.md)
- [.claude/rules/tdd-cycle.md](../rules/tdd-cycle.md)
