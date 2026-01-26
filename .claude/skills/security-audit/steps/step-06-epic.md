# Step 06: Epic

> Creer l'Epic de remediation securite.

---

## Task

1. Determiner le prochain ID d'Epic
2. Creer la structure Epic
3. Generer le fichier Epic
4. Suggerer la creation des Stories

---

## Execution

### 1. Determiner Epic ID

```bash
# Trouver le dernier Epic
last_epic=$(ls docs/epics/ | grep "EPIC-" | sort -V | tail -1)

# Calculer le prochain ID
if last_epic exists:
  next_id = extract_number(last_epic) + 1
else:
  next_id = 1

epic_id = "EPIC-{next_id:02d}-SECURITY"
epic_path = "docs/epics/{epic_id}/"
```

### 2. Creer Structure

```bash
mkdir -p {epic_path}/stories
```

### 3. Generer Epic.md

Utiliser template `templates/security-epic.md`:

```markdown
# {epic_id}: Security Remediation

> **Status**: Draft
> **Priority**: CRITICAL
> **Estimated Effort**: {total_effort} points
> **Source**: Security Audit {date}

---

## Objectif

Corriger les {total_findings} vulnerabilites identifiees lors de l'audit securite du {date}.

### Priorites

1. **CRITICAL** ({critical} findings) - Fix immediat
2. **HIGH** ({high} findings) - Fix sous 1 semaine
3. **MEDIUM** ({medium} findings) - Sprint suivant
4. **LOW** ({low} findings) - Backlog

---

## Scope

### In Scope

{for each finding category with count > 0}
- **{category}**: {count} findings ({effort} pts)
{end for}

### Out of Scope

- Audit des services externes
- Penetration testing
- Audit infrastructure cloud

---

## Stories Prevues

### Sprint 1: Critical Fixes ({critical_effort} pts)

| Story | Description | Effort |
|-------|-------------|--------|
{for each critical finding}
| STORY-{epic_num}-{story_num} | Fix: {finding.title} | {finding.effort} |
{end for}

### Sprint 2: High Priority ({high_effort} pts)

{similar table for HIGH findings}

### Backlog: Medium/Low

{similar table for MEDIUM and LOW}

---

## Criteres de Succes

- [ ] 0 vulnerabilites CRITICAL
- [ ] 0 vulnerabilites HIGH
- [ ] Audit de verification passe
- [ ] Tests de regression OK

---

## Dependencies

- Rapport d'audit: `{report_path}`
- Standards: OWASP Top 10, CWE Top 25

---

## Notes

Genere automatiquement par `/security-audit` le {date}.

Pour creer les stories:
```
/create-story {epic_id} --auto
```
```

### 4. Generer TRACKING.md

```markdown
# {epic_id} - Tracking

## Progress

| Metric | Value |
|--------|-------|
| Total Stories | {story_count} |
| Completed | 0 |
| In Progress | 0 |
| Remaining | {story_count} |
| Points Done | 0 / {total_effort} |

## Stories

| ID | Title | Status | Points |
|----|-------|--------|--------|
{for each finding}
| STORY-{epic_num}-{story_num} | {finding.title} | Todo | {finding.effort} |
{end for}

## Timeline

- **Created**: {date}
- **Target**: TBD
- **Last Updated**: {date}
```

### 5. Generer sources.yaml

```yaml
epic_id: "{epic_id}"
created: "{date}"
source: "security-audit"

discovery:
  method: "automated-audit"
  tool: "/security-audit --mode={mode}"
  report: "{report_path}"

references:
  - type: "audit-report"
    path: "{report_path}"
  - type: "owasp"
    url: "https://owasp.org/Top10/"

findings_summary:
  critical: {critical}
  high: {high}
  medium: {medium}
  low: {low}
  total: {total}
  total_effort: {total_effort}
```

### 6. Output Final

```markdown
## Epic Created

📁 **Path**: `{epic_path}`

### Files Generated

- `{epic_id}.md` - Epic definition
- `TRACKING.md` - Progress tracking
- `sources.yaml` - Audit references

### Stories Preview

{story_count} stories prevues:
- {critical} CRITICAL fixes
- {high} HIGH priority fixes
- {medium} MEDIUM improvements
- {low} LOW enhancements

---

## Next Step

Pour creer automatiquement toutes les stories:

```
/create-story {epic_id} --auto
```

Ou creer manuellement:

```
/create-story {epic_id}
```

---

*Epic genere par /security-audit*
```

---

## Validation

✅ Epic directory created
✅ Epic.md genere
✅ TRACKING.md genere
✅ sources.yaml genere
✅ Suggestion /create-story affichee

---

## Complete

Workflow termine. Output:
- Rapport: `{report_path}`
- Epic: `{epic_path}`
- Next: `/create-story {epic_id} --auto`
