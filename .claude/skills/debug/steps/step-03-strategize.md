---
name: step-03-strategize
description: "Generer et evaluer 3 solutions avant d'appliquer"
prev_step: steps/step-02-hypothesize.md
next_step: steps/step-04-fix.md
---

# Step 03: STRATEGIZE (The Strategist)

## MANDATORY RULES (READ FIRST)

- 🚫 **INTERDIT**: Appliquer directement la premiere solution qui vient
- 🚫 **INTERDIT**: Choisir en mode auto sans scoring objectif
- ✅ **OBLIGATOIRE**: Generer MINIMUM 3 solutions
- ✅ **OBLIGATOIRE**: Scorer chaque solution (Effort × Risque × Impact)
- ✅ **OBLIGATOIRE**: En mode interactif, demander choix utilisateur

## PROTOCOLS

- 🎯 **Goal**: Identifier la MEILLEURE solution, pas la premiere
- 💾 **Output**: `{solutions}`, `{chosen_solution}`
- ⚡ **Performance**: Quelques minutes de reflexion evitent des heures de regression

## CONTEXT

**Available from previous steps:**
- `{symptom}` - Description du bug (from step-00)
- `{context}` - Git status, fichiers modifies (from step-00)
- `{facts}` - Liste de faits observes (from step-01)
- `{hypothesis}` - Hypothese prouvee (from step-02)
- `{mode}` - auto ou interactive (from step-00)
- `{iteration}` - Numero d'iteration (from step-00)

**Produced by this step:**
- `{solutions}` - Liste de 3 solutions avec scoring
- `{chosen_solution}` - Solution selectionnee

## TASK

Generer au moins 3 solutions differentes, les evaluer objectivement, et en choisir une.

---

## EXECUTION

### 1. Generate Solutions

Pour chaque solution, documenter:

```yaml
solutions:
  - id: S1
    name: "[Nom court]"
    approach: |
      [Description de l'approche en 2-3 phrases]

    implementation:
      files_to_modify:
        - path: "lib/file.dart"
          change: "[Description du changement]"
      lines_of_code: ~[estimation]

    scoring:
      effort: 1-5      # 1=trivial, 5=complexe
      risk: 1-5        # 1=safe, 5=dangereux
      impact: 1-5      # 1=minimal, 5=large

    pros:
      - "[Avantage 1]"
      - "[Avantage 2]"

    cons:
      - "[Inconvenient 1]"
      - "[Inconvenient 2]"

    total_score: (6 - effort) + (6 - risk) + impact  # Plus haut = mieux
```

### 2. Types de Solutions a Considerer

Toujours envisager ces categories:

**A. Solution Minimale (Quick Fix)**
- Change le moins de code possible
- Risque minimal
- Peut ne pas etre la plus elegante

**B. Solution Propre (Clean Fix)**
- Resout le probleme correctement
- Suit les bonnes pratiques
- Effort moyen

**C. Solution Preventive (Defensive Fix)**
- Corrige le bug ET previent les similaires
- Peut inclure de la validation
- Effort plus eleve mais valeur long-terme

### 3. Score Calculation

```
Score = (6 - Effort) + (6 - Risk) + Impact

Exemple:
- Solution A: Effort=1, Risk=1, Impact=2 → Score = 5+5+2 = 12
- Solution B: Effort=3, Risk=2, Impact=3 → Score = 3+4+3 = 10
- Solution C: Effort=4, Risk=1, Impact=5 → Score = 2+5+5 = 12
```

### 4. Selection

**Mode INTERACTIVE (`{mode}` = "interactive"):**

Presenter les solutions avec AskUserQuestion:

```
AskUserQuestion:
  question: "Quelle solution voulez-vous appliquer ?"
  header: "Fix"
  options:
    - label: "S1: {name} (Score: {score}) - Recommended"
      description: "{approach courte} | Effort: {effort}/5, Risk: {risk}/5"
    - label: "S2: {name} (Score: {score})"
      description: "{approach courte} | Effort: {effort}/5, Risk: {risk}/5"
    - label: "S3: {name} (Score: {score})"
      description: "{approach courte} | Effort: {effort}/5, Risk: {risk}/5"
```

**Mode AUTO (`{mode}` = "auto"):**

Selectionner automatiquement la solution avec le meilleur score.
En cas d'egalite, preferer:
1. Risque le plus bas
2. Effort le plus bas
3. Impact le plus haut

```
{chosen_solution} = solution avec score max
```

---

## SOLUTION TEMPLATE

Utiliser ce template pour chaque solution:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ SOLUTION {id}: {name}                                    Score: {total} │
├─────────────────────────────────────────────────────────────────────────┤
│ APPROCHE:                                                               │
│ {approach}                                                              │
├─────────────────────────────────────────────────────────────────────────┤
│ FICHIERS A MODIFIER:                                                    │
│ • {file1} - {change1}                                                   │
│ • {file2} - {change2}                                                   │
├─────────────────────────────────────────────────────────────────────────┤
│ SCORING:                                                                │
│ Effort: {effort}/5  |  Risque: {risk}/5  |  Impact: {impact}/5          │
├─────────────────────────────────────────────────────────────────────────┤
│ PROS:                           │ CONS:                                 │
│ + {pro1}                        │ - {con1}                              │
│ + {pro2}                        │ - {con2}                              │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Au moins 3 solutions generees
✅ Chaque solution a un scoring complet (Effort, Risk, Impact)
✅ Pros/Cons documentes pour chaque solution
✅ Une solution est selectionnee (par user ou auto)

**Self-Critique Questions:**
- Ai-je considere une solution minimale ?
- Ai-je considere une solution preventive ?
- Les scores sont-ils objectifs ou biaises ?
- La solution choisie resout-elle vraiment la CAUSE RACINE ?

**If validation fails:**
1. Generer solutions manquantes
2. Completer les scores
3. Si bloque: demander aide utilisateur

---

## SUCCESS / FAILURE

**Success:**
✅ 3+ solutions documentees avec scoring
✅ Solution choisie de maniere justifiee
✅ Plan d'implementation clair

**Failure modes:**
❌ Une seule solution trouvee → Forcer la creativite, chercher alternatives
❌ Toutes solutions trop risquees → Escalader pour decision
❌ User ne choisit pas → Reproposer avec plus de contexte

## OUTPUT FORMAT

```
╔═══════════════════════════════════════════════════════════════╗
║                    SOLUTIONS GENERATED                         ║
╠═══════════════════════════════════════════════════════════════╣
║ S1: {name}                                    Score: {score}   ║
║     Effort: {e}/5 | Risk: {r}/5 | Impact: {i}/5               ║
║                                                                ║
║ S2: {name}                                    Score: {score}   ║
║     Effort: {e}/5 | Risk: {r}/5 | Impact: {i}/5               ║
║                                                                ║
║ S3: {name}                                    Score: {score}   ║
║     Effort: {e}/5 | Risk: {r}/5 | Impact: {i}/5               ║
╠═══════════════════════════════════════════════════════════════╣
║ CHOIX: S{n} - {name}                          [RECOMMENDED]    ║
║ Raison: {justification courte}                                 ║
╚═══════════════════════════════════════════════════════════════╝
```

## NEXT

After validation passes, load `steps/step-04-fix.md`

<critical>
Ne JAMAIS sauter cette etape meme si "la solution est evidente".
Proposer plusieurs solutions FORCE la reflexion et evite l'effet tunnel.
La meilleure solution n'est pas toujours la premiere qui vient a l'esprit.
</critical>
