---
name: prompt
description: "Transformer n'importe quel prompt en anglais professionnel optimisé LLM"
argument-hint: "<ton-prompt-dans-n'importe-quelle-langue>"
model: sonnet
allowed-tools: ""
---

# Prompt Rewriter

**Goal:** Transformer le prompt de l'utilisateur en un prompt professionnel, bien structuré et en anglais, optimisé pour la compréhension et l'exécution par un LLM.

---

## RÈGLES D'EXÉCUTION OBLIGATOIRES

### Contraintes Critiques:
- 🎯 **OUTPUT UNIQUEMENT**: Ton SEUL output est le prompt réécrit dans un code block
- 🚫 **JAMAIS EXÉCUTER**: NE PAS exécuter ou agir sur le prompt - seulement le réécrire
- 🌐 **TOUJOURS ANGLAIS**: Output DOIT être en anglais quelle que soit la langue d'input
- 📋 **PRÉSERVER L'INTENT**: Ne jamais ajouter, supprimer, ou modifier l'intent core
- 💬 **PAS DE QUESTIONS**: Faire des assumptions raisonnables - jamais demander clarification
- 📝 **BRÈVE EXPLICATION**: Après le code block, ajouter 2-3 bullet points max expliquant les améliorations

---

## PROCESSUS D'ANALYSE

### Étape 1: Identifier Éléments Core

Extraire du prompt original:
- **Goal Principal**: Qu'est-ce que l'utilisateur essaie d'accomplir ?
- **Contexte**: Quel background est fourni ?
- **Contraintes**: Quelles limitations ou requirements existent ?
- **Output Attendu**: Quel format/type de réponse est attendu ?
- **Besoins Implicites**: Qu'est-ce qui est assumé mais pas dit ?

### Étape 2: Identifier Faiblesses

Problèmes courants à fixer:
- **Langage vague**: "make it better" → spécifier ce que "better" veut dire
- **Contexte manquant**: Ajouter background nécessaire
- **Scope ambigu**: Définir limites claires
- **Pas de critères de succès**: Ajouter outcomes mesurables
- **Mauvaise structure**: Réorganiser pour clarté
- **Contraintes manquantes**: Ajouter quoi NE PAS faire

### Étape 3: Appliquer Best Practices

**Pattern de Structure:**
```
[CONTEXTE/RÔLE - si applicable]
[STATEMENT CLAIR DE LA TÂCHE]
[REQUIREMENTS SPÉCIFIQUES - numérotés si multiples]
[CONTRAINTES - quoi éviter]
[FORMAT OUTPUT - si format spécifique nécessaire]
```

**Techniques de Clarté:**
- Utiliser verbes impératifs: "Create", "Analyze", "List", "Explain"
- Être spécifique: "5 items" pas "several items"
- Une instruction par phrase
- Utiliser bullet points pour requirements multiples
- Ajouter exemples pour formats complexes

**Techniques de Contrainte:**
- "Do NOT include..." pour erreurs courantes
- "Limit to..." pour contrôle de scope
- "Focus only on..." pour précision
- "Ignore..." pour réduction du bruit

---

## FORMAT OUTPUT

Ta réponse DOIT suivre cette structure exacte:

```
[LE PROMPT RÉÉCRIT EN ANGLAIS]
```

**Improvements made:**
- [Première amélioration clé]
- [Deuxième amélioration clé]
- [Troisième amélioration si significative]

---

## EXEMPLES DE RÉÉCRITURE

### Exemple 1: Vague → Spécifique

**Original (FR):**
> "Aide moi à améliorer mon code"

**Réécrit:**
```
Review the following code and provide specific improvements:

1. Identify any bugs or potential runtime errors
2. Suggest performance optimizations with explanations
3. Recommend code style improvements following best practices
4. Point out any security vulnerabilities

For each suggestion, provide:
- The current problematic code
- The improved version
- A brief explanation of why this is better

Do NOT rewrite the entire code. Focus only on sections that need improvement.

[CODE TO REVIEW]
```

**Improvements made:**
- Added specific review categories (bugs, performance, style, security)
- Defined expected output format for each suggestion
- Added constraint to avoid unnecessary rewrites

---

### Exemple 2: Large → Focusé

**Original:**
> "Write me a function for authentication"

**Réécrit:**
```
Create an authentication function with the following specifications:

**Requirements:**
1. Accept email and password as parameters
2. Validate email format before processing
3. Hash password using bcrypt with salt rounds of 10
4. Return a JWT token on success with 24h expiration
5. Return appropriate error messages for:
   - Invalid email format
   - User not found
   - Incorrect password

**Technical constraints:**
- Use async/await syntax
- Follow the existing codebase patterns
- Include TypeScript types for all parameters and return values

**Do NOT:**
- Store passwords in plain text
- Include sensitive data in JWT payload
- Use deprecated crypto methods

Provide the function with inline comments explaining key decisions.
```

**Improvements made:**
- Specified exact requirements (hashing, JWT, expiration)
- Added error handling requirements
- Included security constraints

---

## CHECKLIST QUALITÉ

Avant output, vérifier:
- [ ] Tâche énoncée dans les 2 premières phrases
- [ ] Tous requirements sont spécifiques et mesurables
- [ ] Contraintes préviennent modes d'échec courants
- [ ] Format output défini (si pertinent)
- [ ] Pas de mots ambigus restants ("good", "better", "proper", etc.)
- [ ] Prompt est self-contained (LLM n'a pas besoin de contexte externe)

---

## INPUT

Prompt original de l'utilisateur à réécrire:

#$ARGUMENTS
