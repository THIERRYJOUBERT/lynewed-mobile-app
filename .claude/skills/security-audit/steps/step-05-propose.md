# Step 05: Propose

> CHECKPOINT: Proposer la creation d'un Epic.

---

## Task

Afficher le resume des findings et proposer de creer un Epic.

---

## Execution

### 1. Afficher Resume Final

```markdown
## Security Audit Complete

### Rapport genere

📄 `{report_path}`

### Findings Summary

| Severite | Count | Effort |
|----------|-------|--------|
| 🔴 CRITICAL | {X} | {effort} pts |
| 🟠 HIGH | {Y} | {effort} pts |
| 🟡 MEDIUM | {Z} | {effort} pts |
| 🟢 LOW | {W} | {effort} pts |
| **TOTAL** | {total} | {total_effort} pts |

### Top 3 Issues

1. **{critical_1.title}** - {critical_1.file}:{critical_1.line}
2. **{critical_2.title}** - {critical_2.file}:{critical_2.line}
3. **{high_1.title}** - {high_1.file}:{high_1.line}

### Effort Estimation

- **Total points**: {total_effort}
- **Sprints estimes**: {sprints} (~20 pts/sprint)
- **Focus recommande**: CRITICAL first, puis HIGH
```

### 2. Proposer Epic

```
AskUserQuestion:
  question: "Voulez-vous creer un Epic de remediation securite?"
  header: "Epic"
  options:
    - label: "Creer Epic (Recommande)"
      description: "Genere EPIC-XX-SECURITY avec toutes les Stories"
    - label: "Rapport seulement"
      description: "Garder le rapport, creer l'Epic plus tard"
    - label: "Epic partiel"
      description: "Epic avec CRITICAL et HIGH seulement"
```

### 3. Capturer Decision

```yaml
IF user.choice == "Creer Epic":
  create_epic = true
  epic_scope = all

ELIF user.choice == "Epic partiel":
  create_epic = true
  epic_scope = critical_high_only

ELSE:
  create_epic = false
```

---

## Output

```yaml
proposal:
  create_epic: {boolean}
  epic_scope: all | critical_high_only | none
```

---

## Next

```
IF create_epic:
  Load steps/step-06-epic.md
ELSE:
  # Finalize without Epic
  Output:
    "Audit termine. Rapport disponible: {report_path}"
    "Pour creer l'Epic plus tard:"
    "1. Relire le rapport"
    "2. Lancer /create-epic security-remediation"
```
