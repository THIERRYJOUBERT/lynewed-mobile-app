# Template: Epic Update

> Pour mettre a jour la documentation dans docs/epics/

---

## Target Files

| File | When to Update |
|------|----------------|
| `TRACKING.md` | Progress, blockers, decisions |
| `EPIC-XX.md` | Scope changes, architecture decisions |
| `stories/STORY-XX-YY.md` | Implementation details |

---

## TRACKING.md Update Template

```markdown
## Progress Update - {YYYY-MM-DD}

### Stories Status
| Story | Status | Notes |
|-------|--------|-------|
| STORY-XX-01 | {status} | {notes} |
| STORY-XX-02 | {status} | {notes} |

### Recent Progress
- {progress_1}
- {progress_2}

### Blockers
- [ ] {blocker_1} - {status}

### Decisions Made
| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| {decision} | {choice} | {why} | {date} |

### Next Actions
- [ ] {action_1}
- [ ] {action_2}
```

---

## EPIC-XX.md Update Template

**Quand:** Changements de scope, decisions architecturales majeures

```markdown
## Update: {YYYY-MM-DD}

### Scope Change
{Description du changement si applicable}

### Architecture Decision
**Context**: {contexte}
**Decision**: {decision}
**Consequences**: {consequences}

### Risks Update
| Risk | Status | Mitigation |
|------|--------|------------|
| {risk} | {open/mitigated/closed} | {action} |
```

---

## Story Update Template

**Quand:** Implementation details, solutions trouvees

```markdown
## Implementation Notes - {YYYY-MM-DD}

### Approach
{Description de l'approche}

### Key Files
| File | Purpose | Status |
|------|---------|--------|
| `path/file.dart` | {purpose} | {created/modified} |

### Challenges & Solutions
| Challenge | Solution |
|-----------|----------|
| {challenge} | {solution} |

### Tests
- [x] Unit: {test_name}
- [ ] Integration: {test_name}

### Review Notes
{Notes de review si applicable}
```

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| {YYYY-MM-DD} | Date ISO | 2026-01-24 |
| {status} | Story status | Todo/In Progress/Done |
| {notes} | Brief notes | "Blocked by API" |

---

## Quality Checklist

- [ ] Date presente sur chaque update
- [ ] Status des stories a jour
- [ ] Decisions documentees avec rationale
- [ ] Blockers clairs avec status
- [ ] Next actions definies
- [ ] Files impactes listes
