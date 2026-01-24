---
name: debug
description: "Debugging scientifique avec Constrained ReAct. Utiliser quand un bug est detecte et necessite investigation."
model: opus
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
  - TodoWrite
argument-hint: "[--auto] <description du bug>"
---

# /debug v2 - Scientific Debugging

<objective>
Resoudre les bugs de maniere scientifique : PROUVER la cause racine AVANT de modifier le code.
</objective>

<critical_rule>
🛑 NEVER modifier le code metier avant d'avoir PROUVE la cause racine
🛑 NEVER "essayer" des corrections au hasard (Shotgun Debugging = INTERDIT)
🛑 NEVER laisser des logs de debug en production
✅ ALWAYS collecter des FAITS avant de supposer
✅ ALWAYS proposer plusieurs solutions avant d'appliquer
✅ ALWAYS ecrire un test reproduisant le bug
</critical_rule>

<when_to_use>
**Use this skill when:**
- Un bug est detecte (test fail, comportement inattendu, erreur runtime)
- Une regression est constatee apres un changement
- Un comportement est incoherent avec les specs

**Don't use for:**
- Nouvelles features (use /dev-story ou /oneshot)
- Refactoring sans bug (just edit)
- Questions de comprehension (use /explore)
</when_to_use>

## Arguments

```
$ARGUMENTS

Modes:
  --auto : Resolution autonome (choisit automatiquement la solution recommandee)
  (defaut) : Mode interactif (propose les solutions, attend le choix utilisateur)
```

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{mode}` | enum | `auto` ou `interactive` |
| `{symptom}` | string | Description du bug fournie |
| `{context}` | object | Git status, fichiers recents, tests |
| `{facts}` | list | Faits observes (pas suppositions) |
| `{hypothesis}` | object | Hypothese + preuves |
| `{solutions}` | list | 3 solutions avec scoring |
| `{chosen_solution}` | object | Solution selectionnee |
| `{iteration}` | number | Numero d'iteration (max 5) |

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        /debug v2 WORKFLOW                                │
│                                                                          │
│  00. CAPTURE   → Capturer symptome + contexte (git, tests, fichiers)    │
│       │          → Detecter mode (--auto ou interactif)                 │
│       ↓                                                                  │
│  01. OBSERVE   → Collecter FAITS (stack trace, logs, flux)              │
│       │          → SI bug dynamique : proposer instrumentation          │
│       │          → INTERDIT : modifier code metier                      │
│       ↓                                                                  │
│  02. HYPOTHESIZE → Formuler hypothese basee sur FAITS                   │
│       │          → PROUVER via logs/tests/analyse                       │
│       │          → Si non prouvee : retour 01                           │
│       ↓                                                                  │
│  03. STRATEGIZE → Generer 3 solutions avec scoring                      │
│       │          → Effort × Risque × Impact                             │
│       │          → SI interactif : AskUserQuestion                      │
│       │          → SI auto : choisir Recommended                        │
│       ↓                                                                  │
│  04. FIX       → Appliquer solution choisie                             │
│       │          → Ecrire test reproduisant le bug                      │
│       │          → NETTOYER logs de debug                               │
│       ↓                                                                  │
│  05. VERIFY    → Tests + Analyse                                        │
│       │          → SI echec : retour 00 avec nouvelles connaissances    │
│       ↓                                                                  │
│  06. FINALIZE  → Propose sync/doc (intelligent)                         │
│                  SI fix significatif + structure modifiee               │
│                  → Mode interactif: AskUserQuestion                     │
│                  → Mode auto: Agent Sonnet                              │
│       └──────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ⚡ MAX 5 ITERATIONS avec apprentissage                                  │
│  📊 Rapport d'escalade si echec persistant                              │
└─────────────────────────────────────────────────────────────────────────┘
```

## Step Files

| Step | File | Purpose | Gate |
|------|------|---------|------|
| 00 | step-00-capture.md | Capturer symptome + detecter mode | Symptome clair |
| 01 | step-01-observe.md | Collecter faits sans modifier | Faits documentes |
| 02 | step-02-hypothesize.md | Formuler + prouver hypothese | Hypothese prouvee |
| 03 | step-03-strategize.md | Generer 3 solutions scorees | Solution choisie |
| 04 | step-04-fix.md | Appliquer correction + nettoyer | Fix applique |
| 05 | step-05-verify.md | Valider resolution | Bug resolu |
| 06 | (inline) | Finalization intelligente | Propose sync/doc si pertinent |

## References

| File | Purpose |
|------|---------|
| references/instrumentation.md | Patterns de logs temporaires par langage |

## Execution Rules

1. **Progressive Loading**: Charger UN step a la fois
2. **Constrained ReAct**: OBSERVE → HYPOTHESIZE → ACT (jamais l'inverse)
3. **Proof Before Fix**: Ne JAMAIS modifier sans preuve de la cause
4. **Self-Healing**: Max 5 iterations avec apprentissage a chaque echec
5. **Clean Exit**: Toujours nettoyer les logs de debug
6. **Intelligent Finalization**: After verification, propose sync/doc if fix was significant (see workflow-finalization pattern)

## Success Criteria

✅ Bug resolu et ne se reproduit plus
✅ Test de regression ecrit
✅ Aucun log de debug laisse dans le code
✅ Cause racine documentee

## Failure Modes

❌ Cause racine introuvable apres 5 iterations → Escalade avec rapport complet
❌ Bug non reproductible → Documenter conditions et monitoring suggere
❌ Fix introduit regression → Rollback + nouvelle iteration

<finalization_pattern>
## Étape 06 - Finalization Intelligente

Référence: `.claude/skills/sync-project/references/workflow-finalization.md`

### Logique

Après step-05 VERIFY, évaluer le travail effectué :

**Travail significatif détecté ?**
- OUI si: fix structural (nouveaux fichiers, changements architecture)
- OUI si: bug complexe avec solution non triviale documentée
- NON si: petit fix trivial (typo, off-by-one, simple correction)

### Exécution selon le mode

**SI fix significatif ET mode = interactif :**

Proposer via AskUserQuestion :

```
question: "Bug résolu avec succès. Voulez-vous synchroniser les références et/ou documenter ce fix ?"
header: "Finalisation"
options:
  - label: "Sync + Documentation (Recommandé)"
    description: "Met à jour les références + documente la cause racine et solution"
  - label: "Sync uniquement"
    description: "Met à jour les fichiers de référence (si structure modifiée)"
  - label: "Documentation uniquement"
    description: "Documente la cause racine et la solution"
  - label: "Terminer sans"
    description: "Le fix est fait, pas besoin de plus"
```

**SI fix significatif ET mode = auto :**

Lancer un agent Sonnet pour exécuter sync/doc :

```
{Task tool}
subagent_type: general-purpose
model: sonnet
description: "Debug finalization sync/doc"
prompt: |
  Bug résolu: {symptom}
  Cause racine: {hypothesis}
  Solution appliquée: {chosen_solution}

  1. SI structure modifiée: Execute /sync-project --silent
  2. Execute /documentation --auto --scope=workspace pour documenter le fix

  Exécute silencieusement, pas besoin de rapport détaillé.
```

**SI fix trivial :** Fin du workflow sans proposition.
</finalization_pattern>

<begin>
Load `steps/step-00-capture.md` to start the debugging workflow.
</begin>
