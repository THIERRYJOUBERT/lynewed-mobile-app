# Regles Absolues {{PROJECT_NAME}}

> Ces regles sont NON-NEGOCIABLES et s'appliquent a TOUTES les operations.
> **Source de verite** : `.claude/context/SYSTEM.md`

---

## Qualite

1. **ZERO WARNINGS** : Pas de warnings ignores, pas de TODO/FIXME non traites
2. **ZERO DETTE** : Pas de code "temporaire" qui reste
3. **TESTS PASSES** : Jamais commit avec tests fail

---

## Documentation

1. **STORY AVANT CODE** : Jamais coder sans story validee
2. **TRACKING CONTINU** : Tout dans TRACKING.md et Story.md
3. **DECISIONS DOCUMENTEES** : Chaque choix technique justifie

---

## TDD Obligatoire

```
RED    → Test qui echoue AVANT code
GREEN  → Code MINIMAL pour passer
REFACTOR → Nettoyer SANS casser
```

Jamais :
- Ecrire code avant test
- Laisser tests fail
- Skip la phase refactor

---

## Review Adversariale (APEX)

**OBLIGATOIRE** apres chaque implementation significative.

### Principe

Apres avoir ecrit du code, **changer de role** : devenir un Reviewer Senior Impitoyable dont l'unique but est de TROUVER DES PROBLEMES.

### Checklist

- [ ] Securite : Injection, secrets, validation inputs
- [ ] Logique : Edge cases, race conditions, erreurs silencieuses
- [ ] Coherence : IDs, nommage, conventions
- [ ] Tests : Cas limites, comportement d'erreur

### Regle d'or

**Si 0 probleme trouve** : C'est suspect. Re-examiner.

### Boucle de correction

```
EXAMINE → RESOLVE → EXAMINE (max 5 iterations)
Si problemes persistent → Documenter et escalader avec rapport detaille
```

**IMPORTANT** : Chaque iteration doit APPRENDRE de la precedente. Repeter la meme chose 5 fois = echec du self-healing.

---

## Coherence

1. **FDs SOURCE DE VERITE** : Tout doit aligner avec les FDs
2. **PRD-MASTER REFERENCE** : Implementation conforme au PRD
3. **SCOPE STRICT** : Ne jamais modifier fichiers hors scope story

---

## Securite

1. **PAS DE SECRETS** : Jamais de credentials en dur
2. **VALIDATION INPUTS** : Toujours valider les entrees utilisateur
3. **OWASP TOP 10** : Eviter les vulnerabilites classiques

---

## Critique Objective

1. **PAS DE COMPLAISANCE** : Etre objectif, pas complaisant
2. **QUALITE PARFAITE** : On ne valide que si parfait
3. **ESCALADER SI BLOQUE** : AskUserQuestion en dernier recours

---

## Workflow APEX (Sequence 8 Etapes)

Pour toute tache non-triviale, suivre la sequence :

```
┌──────────────────────────────────────────────────────────────┐
│                    STORY WORKFLOW (8 ETAPES)                 │
│                                                              │
│  01. ANALYZE   → Lire story, comprendre criteres             │
│  02. PLAN      → Identifier fichiers, ordre des criteres    │
│  03. EXECUTE   → TDD: RED → GREEN → REFACTOR (par critere)  │
│  04. VALIDATE  → {{TEST_CMD}} + analyze (AVANT review!)     │
│  05. EXAMINE   → REVIEW ADVERSARIALE (sur code valide)      │
│  06. RESOLVE   → Corriger problemes de review               │
│  07. TEST LOOP → Self-healing si tests fail (max 5)         │
│  08. COMMIT    → PR ou commit si tout passe                 │
└──────────────────────────────────────────────────────────────┘
```

**IMPORTANT** : VALIDATE (technique) vient AVANT EXAMINE (review). On ne fait pas de review adversariale sur du code qui ne passe pas le lint/build.

Ne JAMAIS skip les phases VALIDATE et EXAMINE.

---

## Self-Healing Intelligent

Quand quelque chose echoue (test, build, review) :

1. **Analyser** : Pourquoi ? Quelle est la cause racine ?
2. **Ajuster** : Modifier l'approche basee sur l'analyse
3. **Reessayer** : Avec la nouvelle approche
4. **Max 5 tentatives** : Si echec apres 5, escalader avec rapport

> "Chaque tentative doit APPRENDRE de la precedente. Repeter la meme chose 5 fois = echec du self-healing."
