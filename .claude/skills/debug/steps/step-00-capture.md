---
name: step-00-capture
description: "Capturer le symptome et le contexte initial du bug"
prev_step: null
next_step: steps/step-01-observe.md
---

# Step 00: CAPTURE (Initial Context)

## MANDATORY RULES (READ FIRST)

- 🎯 Objectif : Comprendre clairement le symptome AVANT d'investiguer
- 🚫 INTERDIT : Commencer a chercher la cause avant d'avoir capture le contexte
- ✅ OBLIGATOIRE : Detecter le mode (--auto ou interactif)

## PROTOCOLS

- 🎯 **Goal**: Capturer symptome + contexte + mode d'execution
- 💾 **Output**: `{symptom}`, `{context}`, `{mode}`, `{iteration}`
- ⚡ **Performance**: Rapide - juste de la lecture et parsing

## CONTEXT

**Available from invocation:**
- `$ARGUMENTS` - Description du bug fournie par l'utilisateur

**Produced by this step:**
- `{mode}` - `auto` ou `interactive`
- `{symptom}` - Description nettoyee du bug
- `{context}` - Git status, tests recents, fichiers modifies
- `{iteration}` - Numero d'iteration (1 pour debut)

## TASK

1. Parser les arguments pour detecter le mode
2. Extraire la description du symptome
3. Collecter le contexte environnemental
4. Initialiser le compteur d'iteration

---

## EXECUTION

### 1. Detect Mode

Parser `$ARGUMENTS` pour detecter `--auto`:

```
SI $ARGUMENTS contient "--auto":
    {mode} = "auto"
    {symptom} = $ARGUMENTS sans "--auto"
SINON:
    {mode} = "interactive"
    {symptom} = $ARGUMENTS
```

Si aucun argument fourni, demander:

```
AskUserQuestion:
  question: "Quel bug voulez-vous investiguer ?"
  header: "Symptome"
  options:
    - label: "Tests echouent"
      description: "Un ou plusieurs tests ne passent plus"
    - label: "Erreur runtime"
      description: "L'application crash ou affiche une erreur"
    - label: "Comportement incorrect"
      description: "Ca ne fonctionne pas comme prevu"
```

### 2. Capture Symptom

Formater le symptome de maniere structuree:

```
SYMPTOM CAPTURE
===============
Description: {description fournie}
Type: [Test Failure | Runtime Error | Unexpected Behavior | Regression]
Severity: [Critical | High | Medium | Low]
```

### 3. Collect Context

Collecter automatiquement le contexte via commandes:

```bash
# Git status
git status --porcelain | head -20

# Fichiers recemment modifies
git diff --name-only HEAD~5

# Derniers commits
git log --oneline -5

# Tests recents (si disponible)
# {{TEST_CMD}} --reporter compact 2>&1 | tail -20
```

Stocker dans `{context}`:

```yaml
context:
  branch: <branch actuelle>
  modified_files: <liste fichiers modifies>
  recent_commits: <5 derniers commits>
  last_test_run: <resultat si disponible>
```

### 4. Initialize Iteration

```
{iteration} = 1
```

Si c'est une re-iteration (retour de step-05):
- Incrementer `{iteration}`
- Conserver les apprentissages precedents

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ `{mode}` est soit "auto" soit "interactive"
✅ `{symptom}` est non-vide et comprehensible
✅ `{context}` contient au minimum la branche git
✅ `{iteration}` est initialise (1 ou incremente)

**Self-Critique Questions:**
- Le symptome est-il assez precis pour guider l'investigation ?
- Ai-je capture tous les elements de contexte pertinents ?
- Le mode est-il correctement detecte ?

**If validation fails:**
1. Demander clarification a l'utilisateur
2. Si toujours flou, noter comme gap et continuer avec ce qu'on a

---

## SUCCESS / FAILURE

**Success:**
✅ Symptome clairement capture et categorise
✅ Contexte environnemental collecte
✅ Mode d'execution determine

**Failure modes:**
❌ Aucun symptome fourni → AskUserQuestion pour description
❌ Git non disponible → Continuer sans contexte git, noter le gap
❌ Arguments malformes → Interpreter au mieux, demander confirmation

## OUTPUT FORMAT

Avant de passer a l'etape suivante, afficher:

```
╔═══════════════════════════════════════════════════════════════╗
║                    DEBUG SESSION STARTED                       ║
╠═══════════════════════════════════════════════════════════════╣
║ Mode: {mode}                                                   ║
║ Iteration: {iteration}/5                                       ║
╠═══════════════════════════════════════════════════════════════╣
║ SYMPTOM:                                                       ║
║ {symptom}                                                      ║
╠═══════════════════════════════════════════════════════════════╣
║ CONTEXT:                                                       ║
║ Branch: {branch}                                               ║
║ Modified: {nombre fichiers} files                              ║
╚═══════════════════════════════════════════════════════════════╝
```

## NEXT

After validation passes, load `steps/step-01-observe.md`

<critical>
Ne JAMAIS passer a l'observation sans avoir un symptome clair.
Un symptome vague mene a une investigation vague.
</critical>
