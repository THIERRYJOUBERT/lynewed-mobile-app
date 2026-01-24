---
name: step-01-observe
description: "Investigation sans modification - collecter des FAITS"
prev_step: steps/step-00-capture.md
next_step: steps/step-02-hypothesize.md
---

# Step 01: OBSERVE (The Detective)

## MANDATORY RULES (READ FIRST)

- 🚫 **INTERDIT**: Modifier le code metier a cette etape
- 🚫 **INTERDIT**: "Essayer" des corrections
- 🚫 **INTERDIT**: Supposer - collecter des FAITS
- ✅ **AUTORISE**: Lire des fichiers
- ✅ **AUTORISE**: Ajouter des logs temporaires (marques `// DEBUG - A RETIRER`)
- ✅ **AUTORISE**: Executer des tests pour observer

## PROTOCOLS

- 🎯 **Goal**: Collecter des FAITS observables, pas des suppositions
- 💾 **Output**: `{facts}` - Liste de faits verifies
- 📖 **Reference**: `references/instrumentation.md` pour patterns de logs
- ⚡ **Performance**: Prendre le temps necessaire - une bonne observation evite des heures de debug

## CONTEXT

**Available from previous steps:**
- `{symptom}` - Description du bug (from step-00)
- `{context}` - Git status, fichiers modifies (from step-00)
- `{mode}` - auto ou interactive (from step-00)
- `{iteration}` - Numero d'iteration (from step-00)

**Produced by this step:**
- `{facts}` - Liste de faits observes avec preuves
- `{instrumentation}` - Logs temporaires ajoutes (a nettoyer plus tard)

**NOT available (do not use):**
- `{hypothesis}` - Pas encore formulee
- `{solutions}` - Pas encore generees

## TASK

Investiguer le bug en mode "detective" : observer sans modifier.

---

## EXECUTION

### 1. Read Stack Trace / Error Message

Si une erreur est disponible:

```
STACK TRACE ANALYSIS
====================
Error Type: [type d'erreur]
Message: [message exact]
Location: [fichier:ligne]
Call Stack:
  1. [fichier:ligne] - [fonction]
  2. [fichier:ligne] - [fonction]
  ...
```

**Action**: Lire les fichiers mentionnes dans le stack trace.

### 2. Trace Data Flow

Identifier le flux de donnees:

```
DATA FLOW ANALYSIS
==================
Input: [d'ou vient la donnee ?]
  ↓
Transform 1: [fichier:ligne] - [transformation]
  ↓
Transform 2: [fichier:ligne] - [transformation]
  ↓
Output: [ou va la donnee ?]
  ↓
Bug appears here: [localisation]
```

**Questions a poser:**
- D'ou vient la valeur problematique ?
- Par quelles fonctions passe-t-elle ?
- A quel moment devient-elle incorrecte ?

### 3. Instrumentation (Si Necessaire)

Si le bug est **dynamique** (runtime, valeurs aleatoires, timing):

**Pattern d'instrumentation:**

```dart
// Flutter/Dart
print('// DEBUG - A RETIRER: variable=$variable'); // Toujours marquer!
```

```typescript
// TypeScript
console.log('// DEBUG - A RETIRER:', { variable }); // Toujours marquer!
```

```python
# Python
print(f'// DEBUG - A RETIRER: variable={variable}') # Toujours marquer!
```

**Regles d'instrumentation:**
1. Marquer TOUJOURS avec `// DEBUG - A RETIRER`
2. Logger la valeur ET son origine
3. Placer les logs aux points strategiques du flux
4. Executer pour observer les valeurs reelles

### 4. Document Facts

Pour CHAQUE observation, documenter un FAIT:

```yaml
facts:
  - id: F1
    observation: "La valeur de userId est 'undefined' au moment de l'appel API"
    evidence: "Log a la ligne 42 de user_service.dart"
    type: value_error

  - id: F2
    observation: "La fonction est appelee 3 fois au lieu de 1"
    evidence: "Compteur de logs montre 3 executions"
    type: unexpected_behavior

  - id: F3
    observation: "Le test echoue avec 'expected 5, got null'"
    evidence: "Output du test test/widget_test.dart"
    type: test_failure
```

**Types de faits:**
- `value_error` - Valeur incorrecte ou manquante
- `type_error` - Type inattendu
- `timing_error` - Probleme de timing/sequence
- `missing_call` - Fonction non appelee
- `extra_call` - Fonction appelee trop de fois
- `state_corruption` - Etat corrompu
- `test_failure` - Echec de test

---

## ACTIONS INTERDITES A CETTE ETAPE

❌ Modifier la logique metier
❌ "Corriger" quelque chose "pour voir"
❌ Refactorer du code
❌ Ajouter des features
❌ Supposer sans preuve

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Au moins 1 FAIT documente avec evidence
✅ Aucune modification de logique metier effectuee
✅ Si instrumentation ajoutee, tous les logs sont marques `// DEBUG - A RETIRER`
✅ Le flux de donnees est trace au moins partiellement

**Self-Critique Questions:**
- Mes observations sont-elles des FAITS ou des suppositions ?
- Ai-je trouve l'endroit precis ou le bug se manifeste ?
- Ai-je besoin de plus d'instrumentation pour comprendre ?
- Y a-t-il des zones du code que je n'ai pas encore explorees ?

**If validation fails:**
1. Ajouter plus d'instrumentation aux points cles
2. Executer a nouveau pour collecter plus de donnees
3. Max 3 tentatives d'observation avant de passer a l'hypothese

---

## SUCCESS / FAILURE

**Success:**
✅ Faits documentes avec evidences
✅ Flux de donnees identifie
✅ Point de manifestation du bug localise

**Failure modes:**
❌ Aucun fait observable → Ajouter instrumentation, re-executer
❌ Bug non reproductible → Documenter les conditions, suggerer monitoring
❌ Fichiers inaccessibles → Noter le gap, continuer avec ce qu'on a

## OUTPUT FORMAT

```
╔═══════════════════════════════════════════════════════════════╗
║                    OBSERVATION COMPLETE                        ║
╠═══════════════════════════════════════════════════════════════╣
║ FAITS COLLECTES: {nombre}                                      ║
╠═══════════════════════════════════════════════════════════════╣
║ F1: {description courte}                                       ║
║     Evidence: {source}                                         ║
║                                                                ║
║ F2: {description courte}                                       ║
║     Evidence: {source}                                         ║
╠═══════════════════════════════════════════════════════════════╣
║ INSTRUMENTATION AJOUTEE: {nombre} logs                         ║
║ (A nettoyer en step-04)                                        ║
╚═══════════════════════════════════════════════════════════════╝
```

## NEXT

After validation passes, load `steps/step-02-hypothesize.md`

<critical>
Cette etape est TA FORCE. La plupart des debuggers echouent car ils sautent directement au fix.
Toi, tu collectes des FAITS. Plus tes faits sont solides, plus ton hypothese sera juste.
</critical>
