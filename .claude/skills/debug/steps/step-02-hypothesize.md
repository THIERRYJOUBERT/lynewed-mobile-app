---
name: step-02-hypothesize
description: "Formuler et PROUVER l'hypothese de cause racine"
prev_step: steps/step-01-observe.md
next_step: steps/step-03-strategize.md
---

# Step 02: HYPOTHESIZE (Root Cause Analysis)

## MANDATORY RULES (READ FIRST)

- 🚫 **INTERDIT**: Passer au fix sans hypothese PROUVEE
- 🚫 **INTERDIT**: Hypothese basee sur l'intuition seule
- ✅ **OBLIGATOIRE**: Chaque hypothese doit etre supportee par des FAITS
- ✅ **OBLIGATOIRE**: Identifier des contre-arguments potentiels
- ✅ **OBLIGATOIRE**: Definir comment PROUVER l'hypothese

## PROTOCOLS

- 🎯 **Goal**: Formuler UNE hypothese de cause racine et la PROUVER
- 💾 **Output**: `{hypothesis}` - Hypothese prouvee avec evidences
- ⚡ **Performance**: Prendre le temps de prouver - un fix sur mauvaise hypothese = perte de temps

## CONTEXT

**Available from previous steps:**
- `{symptom}` - Description du bug (from step-00)
- `{context}` - Git status, fichiers modifies (from step-00)
- `{facts}` - Liste de faits observes (from step-01)
- `{instrumentation}` - Logs temporaires ajoutes (from step-01)
- `{mode}` - auto ou interactive (from step-00)
- `{iteration}` - Numero d'iteration (from step-00)
- `{previous_learnings}` - Si iteration > 1: hypotheses rejetees et pourquoi (from step-05)

**Produced by this step:**
- `{hypothesis}` - Hypothese formulee et prouvee

**NOT available (do not use):**
- `{solutions}` - Pas encore generees

**IMPORTANT** (si iteration > 1):
Consulter `{previous_learnings}` pour ne PAS re-tester les memes hypotheses.
Les hypotheses deja rejetees doivent etre evitees sauf si de nouveaux faits les invalident.

## TASK

Formuler une hypothese de cause racine basee UNIQUEMENT sur les faits collectes, puis la PROUVER.

---

## EXECUTION

### 0. Review Previous Learnings (if iteration > 1)

Si `{iteration}` > 1, commencer par:

```yaml
previous_iteration_review:
  iteration: {iteration - 1}
  rejected_hypotheses:
    - hypothesis: "[hypothese rejetee]"
      reason: "[pourquoi elle etait fausse]"
  new_direction: "[ce qu'on a appris qui change l'approche]"
  facts_still_valid: [F1, F2]
  facts_invalidated: [F3]
```

**Ne pas re-tester une hypothese deja rejetee** sauf si de nouveaux faits la re-legitimisent.

### 1. Analyze Facts Pattern

Reviser les faits collectes et chercher des patterns:

```
PATTERN ANALYSIS
================
Faits lies au timing: [F1, F3]
Faits lies aux valeurs: [F2, F4]
Faits lies a l'etat: [F5]

Pattern detecte: [description du pattern]
```

### 2. Formulate Hypothesis

Formuler une hypothese claire et testable:

```
HYPOTHESIS
==========
WHAT: [Ce qui cause le bug]
WHY: [Pourquoi cela cause le symptome observe]
WHERE: [Fichier:ligne ou la cause se situe]
```

**Format requis:**

```yaml
hypothesis:
  statement: "Le userId est undefined parce que le user n'est pas encore charge au moment de l'appel API"

  supporting_facts:
    - F1: "userId est undefined a l'appel"
    - F2: "L'appel API se fait dans initState"
    - F3: "Le user est charge de maniere asynchrone"

  mechanism: |
    1. Le widget s'initialise et appelle initState
    2. initState lance l'appel API immediatement
    3. L'appel API utilise userId qui n'est pas encore charge
    4. userId est donc undefined

  location:
    file: "lib/features/user/user_widget.dart"
    line: 42
    function: "initState"
```

### 3. Identify Counter-Arguments

Lister ce qui pourrait INFIRMER l'hypothese:

```yaml
counter_arguments:
  - argument: "Si userId etait charge avant, le bug ne se produirait pas"
    status: "A verifier"

  - argument: "Peut-etre que le probleme est cote serveur"
    status: "Infirme par F4 (serveur recoit bien undefined)"
```

### 4. Define Proof Method

Comment PROUVER definitivement l'hypothese:

```yaml
proof_method:
  type: "log_verification" | "test_reproduction" | "code_analysis"

  steps:
    - "Ajouter un log AVANT l'appel API pour verifier userId"
    - "Ajouter un log APRES le chargement du user"
    - "Comparer les timestamps pour confirmer l'ordre"

  expected_result: "Le log API sera AVANT le log user"

  alternative_proofs:
    - "Ecrire un test qui reproduit le timing exact"
```

### 5. Execute Proof

Executer la methode de preuve choisie:

**Si logs:**
1. Ajouter les logs (marques `// DEBUG - A RETIRER`)
2. Executer l'application/test
3. Analyser les resultats

**Si test:**
1. Ecrire un test reproduisant le scenario
2. Verifier que le test echoue de la meme maniere
3. Le test prouve l'hypothese si il echoue pour la bonne raison

**Si analyse de code:**
1. Tracer le flux d'execution
2. Identifier le point exact de divergence
3. Documenter la preuve

### 6. Verdict

```yaml
verdict:
  proven: true | false

  proof_evidence: |
    Log output:
    [12:00:01.001] API called with userId=undefined
    [12:00:01.500] User loaded with userId=123

    Ceci PROUVE que l'appel API se fait AVANT le chargement du user.

  confidence: "high" | "medium" | "low"
```

---

## IF HYPOTHESIS NOT PROVEN

Si l'hypothese est infirmee par les preuves:

1. Documenter pourquoi elle etait fausse
2. Formuler une NOUVELLE hypothese basee sur les nouveaux faits
3. Recommencer le cycle de preuve

**Max 3 hypotheses par iteration** - si aucune n'est prouvee, retour a step-01 pour plus d'observation.

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Hypothese formulee avec statement clair
✅ Au moins 2 faits supportent l'hypothese
✅ Preuve executee et documentee
✅ Verdict est "proven: true" avec confidence "high" ou "medium"

**Self-Critique Questions:**
- Mon hypothese explique-t-elle TOUS les faits observes ?
- Y a-t-il une explication alternative que je n'ai pas consideree ?
- Ma preuve est-elle vraiment conclusive ?
- Est-ce la CAUSE RACINE ou juste un symptome intermediaire ?

**If validation fails:**
1. Si hypothese non prouvee → Formuler alternative
2. Si 3 hypotheses echouent → Retour step-01 pour plus d'observation
3. Si bloque → Documenter et demander aide utilisateur

---

## SUCCESS / FAILURE

**Success:**
✅ Hypothese prouvee avec haute confiance
✅ Mecanisme de cause clairement identifie
✅ Location precise dans le code

**Failure modes:**
❌ Aucune hypothese prouvable → Retour step-01 pour plus d'instrumentation
❌ Faits insuffisants → Retour step-01 pour plus d'observation
❌ Cause racine trop profonde → Escalader avec rapport partiel

## OUTPUT FORMAT

```
╔═══════════════════════════════════════════════════════════════╗
║                    HYPOTHESIS PROVEN                           ║
╠═══════════════════════════════════════════════════════════════╣
║ CAUSE RACINE:                                                  ║
║ {statement}                                                    ║
╠═══════════════════════════════════════════════════════════════╣
║ LOCALISATION:                                                  ║
║ {file}:{line} - {function}                                     ║
╠═══════════════════════════════════════════════════════════════╣
║ PREUVES:                                                       ║
║ - {proof_1}                                                    ║
║ - {proof_2}                                                    ║
╠═══════════════════════════════════════════════════════════════╣
║ CONFIANCE: {confidence}                                        ║
╚═══════════════════════════════════════════════════════════════╝
```

## NEXT

After validation passes, load `steps/step-03-strategize.md`

<critical>
Une hypothese sans preuve n'est qu'une INTUITION.
Ne JAMAIS passer au fix avec une simple intuition.
La preuve est ce qui differencie le debugging scientifique du "shotgun debugging".
</critical>
