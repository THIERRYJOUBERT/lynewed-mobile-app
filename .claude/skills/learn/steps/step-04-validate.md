# Step 04: Validate

> Review adversariale de la documentation générée.

---

## Objectif

Garantir que la documentation produite est de qualité production : dense, correcte, sourcée, et utile pour Claude.

---

## Review Adversariale

Changer de rôle : devenir un **Reviewer Impitoyable** dont l'unique but est de TROUVER DES PROBLÈMES.

### Checklist Obligatoire

#### 1. Références (file:line)

```yaml
Pour chaque référence dans la doc:
  - [ ] Le fichier existe
  - [ ] La ligne existe
  - [ ] Le contenu à cette ligne correspond à la description
  - [ ] Pas de références inventées ou approximatives
```

**Test** : Prendre 5 références au hasard, vérifier avec Read tool.

#### 2. Densité

```yaml
Pour chaque section:
  - [ ] Pas de phrases vides ("This is important because...")
  - [ ] Pas de répétitions entre fichiers
  - [ ] Ratio information/mots élevé
  - [ ] Chaque bullet apporte de la valeur
```

**Test** : Relire INDEX.md, compter les phrases qu'on pourrait supprimer sans perte.

#### 3. Structure

```yaml
Pour chaque fichier:
  - [ ] Headers hiérarchiques cohérents
  - [ ] Tables utilisées quand approprié
  - [ ] Code blocks avec syntaxe correcte
  - [ ] Navigation claire (liens internes)
```

**Test** : Un Claude démarrant une conversation peut-il trouver ce qu'il cherche en <30 sec ?

#### 4. Complétude

```yaml
Selon comprehension_level:
  - [ ] Gaps documentés explicitement
  - [ ] Pas de "TBD" ou "TODO" cachés
  - [ ] Sections "Unknown" si applicable
  - [ ] Honest about limitations
```

**Test** : Y a-t-il des affirmations sans source ?

#### 5. Utilité

```yaml
Pour context.md spécifiquement:
  - [ ] Copy-paste block fonctionne tel quel
  - [ ] Common tasks sont réellement communs
  - [ ] Steps sont exécutables
```

**Test** : Simuler mentalement l'utilisation par un nouvel agent.

---

## Scoring

```yaml
validation_score:
  references:
    checked: N
    valid: N
    score: 0-100

  density:
    fluff_sentences: N
    total_sentences: N
    score: 0-100

  structure:
    issues_found: N
    score: 0-100

  completeness:
    gaps_documented: N
    undocumented_gaps: N
    score: 0-100

  utility:
    usable_sections: N
    total_sections: N
    score: 0-100

  overall: average of all scores
```

---

## Fix Loop

Si `overall < 80` ou problèmes critiques trouvés :

```yaml
For each issue found:
  1. Identify: What's wrong and where
  2. Fix: Edit the specific file
  3. Verify: Re-check the fix

Max iterations: 3
If still failing after 3: Document remaining issues in INDEX.md "Known Limitations"
```

### Types de Corrections

| Issue Type | Action |
|------------|--------|
| Invalid reference | Verify correct location, update |
| Fluff content | Remove or densify |
| Missing source | Add source or mark as inference |
| Structure issue | Reorganize section |
| Incomplete section | Add content or document as gap |

---

## Validation Output

```yaml
validation_results:
  passed: true | false
  overall_score: N

  issues_found: N
  issues_fixed: N
  issues_remaining: N

  iterations_used: N

  known_limitations:
    - description: "..."
      impact: "low" | "medium" | "high"
      reason: "Why not fixed"

  quality_certification:
    references_verified: true | false
    density_acceptable: true | false
    structure_valid: true | false
    completeness_honest: true | false
    utility_confirmed: true | false
```

---

## Threshold Decision

```yaml
IF overall_score >= 80 AND no critical issues:
  → PASS: Continue to step-05-finalize

ELIF iterations < 3:
  → RETRY: Fix issues and re-validate

ELSE:
  → PASS WITH CAVEATS: Document limitations in INDEX.md
  → Continue to step-05-finalize
```

---

## Next

Charger `steps/step-05-finalize.md` pour le résumé et la finalisation.
