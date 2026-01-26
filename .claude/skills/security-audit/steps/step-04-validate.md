# Step 04: Validate

> Review APEX adversariale du rapport.

---

## CRITICAL

Tu es maintenant un **Security Reviewer Senior Impitoyable**.
Ton unique but est de TROUVER DES PROBLEMES dans le rapport.

---

## Task

Valider le rapport contre ces criteres:
1. **Completude** - Tous les domaines couverts?
2. **Accuracy** - file:line verifie?
3. **Actionability** - Remediation claire?
4. **Secrets** - Aucun secret expose?

---

## Execution

### 1. Checklist Completude

| Domaine | Couvert? | Gaps |
|---------|----------|------|
| CODE (XSS, injection) | ✅/❌ | {gaps} |
| AUTH (session, JWT) | ✅/❌ | {gaps} |
| DATA (encryption, RLS) | ✅/❌ | {gaps} |
| API (endpoints, CORS) | ✅/❌ | {gaps} |
| DEPS (CVEs, outdated) | ✅/❌ | {gaps} |
| CONFIG (secrets, env) | ✅/❌ | {gaps} |

**Si gaps**: Documenter dans le rapport section "Limitations"

### 2. Verification Accuracy

Pour chaque finding CRITICAL et HIGH:

```
1. Lire le fichier reference (file:line)
2. Verifier que le code vulnerable existe
3. Confirmer que la description est correcte
4. Valider la severite assignee
```

**Si erreur trouvee**:
- Corriger le finding
- Recalculer les stats
- Mettre a jour le rapport

### 3. Verification Actionability

Pour chaque remediation:

```
✅ Approche concrete (pas vague)
✅ Code example fourni
✅ Effort realiste
✅ Dependencies identifiees
```

**Si remediation vague**:
- Ajouter des details specifiques
- Fournir code example si manquant

### 4. Verification Secrets

```
Grep dans le rapport pour:
- Patterns API keys: /[a-zA-Z0-9_-]{20,}/
- Passwords: /password\s*[:=]\s*['"]\S+/
- Tokens: /token\s*[:=]\s*['"]\S+/
```

**Si secret trouve**:
- REMPLACER par [REDACTED]
- Logger l'incident

### 5. Self-Critique Questions

- [ ] Ai-je rate des vulnerabilites evidentes?
- [ ] Les severites sont-elles justifiees?
- [ ] Un autre auditeur arriverait-il aux memes conclusions?
- [ ] Le rapport est-il exploitable par un dev?

---

## Iterations

**Max 3 iterations** pour corriger les problemes:

```
Iteration 1: Corriger gaps completude
Iteration 2: Fixer accuracy issues
Iteration 3: Ameliorer actionability
```

Si problemes persistent apres 3 iterations:
- Documenter dans "Limitations"
- Continuer avec le rapport actuel

---

## Validation Score

| Critere | Score (0-100) |
|---------|---------------|
| Completude | {X} |
| Accuracy | {Y} |
| Actionability | {Z} |
| No Secrets | {W} |
| **TOTAL** | {avg} |

**Seuil**: 80% minimum pour passer

---

## Output

```yaml
validation:
  score: {total}
  passed: true|false
  iterations_needed: N
  gaps_documented: [...]
  corrections_made: [...]
```

---

## Next

```
IF validation.passed:
  Load steps/step-05-propose.md
ELSE:
  Re-run step-04 (max 3 times)
  IF still failing after 3:
    Load steps/step-05-propose.md (with warning)
```
