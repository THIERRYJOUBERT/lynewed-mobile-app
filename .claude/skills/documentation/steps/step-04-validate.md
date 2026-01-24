# Step 04: Validate

> Purpose: APEX Review Adversariale de la documentation generee.

---

## MANDATORY RULES (READ FIRST)

- 🔍 ALWAYS changer de role: devenir Reviewer Senior Impitoyable
- 🎯 ALWAYS verifier: Dense? Date? Source? Exploitable?
- 🔄 ALWAYS corriger les issues trouvees (max 3 iterations)
- ⚠️ Si 0 probleme trouve → suspect, re-examiner

## PROTOCOLS

- 🎯 **Goal**: Valider qualite de la documentation
- 💾 **Output**: {validation_status}, {issues}
- 📖 **Reference**: references/quality-criteria.md
- ⚡ **Performance**: Review approfondie mais efficace

---

## CONTEXT

**Available from previous steps:**
- `{files_created}` - Fichiers crees (from step-03)
- `{files_updated}` - Fichiers mis a jour (from step-03)
- `{mode}` - interactive ou auto (from step-00)

**Produced by this step:**
- `{validation_status}` - PASS ou NEEDS_FIX
- `{issues}` - Liste des problemes trouves

**NOT available (do not use):**
- `{report}` - Pas encore cree (step-05)

---

## TASK

1. Changer de role: Reviewer Adversarial
2. Examiner chaque fichier genere
3. Appliquer criteres de qualite
4. Corriger issues si trouvees
5. Iterer jusqu'a PASS ou max 3 tentatives

---

## EXECUTION

### 1. Changement de Role

**CRITIQUE: Changer de perspective.**

Tu n'es plus le generateur bienveillant.
Tu es maintenant un **Reviewer Senior Impitoyable** dont l'unique but est de TROUVER DES PROBLEMES.

Mental model:
- "Cette doc est probablement mediocre"
- "Il y a surement du fluff cache"
- "Les sources sont-elles vraiment la?"
- "Claude pourrait-il utiliser ca?"

### 2. Criteres de Qualite

**Pour chaque fichier, verifier:**

| Critere | Question | Red Flag |
|---------|----------|----------|
| **Dense** | Chaque phrase apporte-t-elle de l'info? | Phrases vides, repetitions |
| **Date** | Y a-t-il un timestamp? | Pas de date, date vague |
| **Source** | References claires? | "D'apres la conversation", sans details |
| **Structure** | Sections parsables? | Mur de texte, pas de headers |
| **Exploitable** | Claude peut-il utiliser? | Trop vague, pas actionable |
| **Complete** | Tout le travail couvert? | Gaps evidents |

### 3. Checklist de Review

```markdown
## Review: {filename}

**Densite**
- [ ] Pas de phrases de remplissage
- [ ] Pas de repetitions
- [ ] Chaque paragraphe a un but

**Dating**
- [ ] Timestamp present
- [ ] Format coherent (YYYY-MM-DD)

**Sourcing**
- [ ] Chaque section a sa source
- [ ] Sources specifiques (commit hash, etc.)

**Structure**
- [ ] Headers clairs
- [ ] Sections logiques
- [ ] Facile a scanner

**Exploitabilite**
- [ ] Decisions sont claires
- [ ] Context suffisant
- [ ] Actionable si applicable
```

### 4. Scoring

**Calculer score par fichier:**

```
score = (criteres_passes / total_criteres) * 100

SI score >= 80%: PASS
SI score 60-79%: PASS_WITH_WARNINGS
SI score < 60%: NEEDS_FIX
```

### 5. Correction Loop

**Si issues trouvees:**

```
iteration = 0
WHILE issues AND iteration < 3:
    1. Identifier issues
    2. Corriger fichiers
    3. Re-evaluer
    iteration++

SI iteration = 3 AND issues:
    Accepter avec gaps documentes
```

**Types de corrections:**
- Fluff → Supprimer
- Missing date → Ajouter timestamp
- Missing source → Ajouter reference
- Structure → Reorganiser
- Incomplete → Completer si info disponible

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Tous les fichiers examines
✅ Issues documentees
✅ Corrections appliquees si necessaire
✅ Status final determine

**Self-Critique Questions:**
- Ai-je ete assez critique?
- Les corrections sont-elles suffisantes?
- La doc est-elle vraiment exploitable?
- Ai-je manque quelque chose?

**If validation fails:**
1. Nouvelle iteration de review
2. Max 3 iterations
3. Si toujours issues → accepter avec documentation des gaps

---

## OUTPUT STRUCTURE

```yaml
validation_status: "PASS|PASS_WITH_WARNINGS|NEEDS_FIX"

validation_details:
  files_reviewed: N
  issues_found: N
  issues_fixed: N
  iterations: N

issues:
  - file: "path/to/file.md"
    issue: "Description du probleme"
    severity: "high|medium|low"
    status: "fixed|accepted|documented"

quality_scores:
  - file: "path/to/file.md"
    score: N%
    criteria:
      dense: true|false
      dated: true|false
      sourced: true|false
      structured: true|false
      exploitable: true|false
```

---

## SUCCESS / FAILURE

**Success:**
✅ {validation_status} = PASS ou PASS_WITH_WARNINGS
✅ Issues critiques corrigees
✅ Documentation exploitable

**Failure modes:**
❌ Issues non corrigibles → Documenter et accepter
❌ Fichier illisible → Re-generer depuis step-03
❌ Review trop permissive → Re-examiner avec rigueur

## NEXT

After validation passes, load `steps/step-05-finalize.md`

<critical>
Regle d'or de Review Adversariale:
Si tu trouves 0 probleme, tu n'as pas cherche assez.
Re-examiner.
</critical>
