# Template: Detailed Documentation

> Pour documenter des specs techniques dans docs/detailed/

---

## Naming Convention

```
docs/detailed/{area}/{topic}.md
```

Examples:
- `docs/detailed/architecture/data-flow.md`
- `docs/detailed/ui-ux/home-screen.md`
- `docs/detailed/api/auth-endpoints.md`

---

## Template

```markdown
# {Title}

> **Last Updated**: {YYYY-MM-DD}
> **Status**: Draft | Review | Approved
> **Owner**: {owner}

---

## Overview

{2-3 phrases decrivant le sujet et son importance}

---

## Context

### Background
{Pourquoi ce document existe, quel probleme il resout}

### Related Documents
- [FD-XX](../specs/FD-XX.md) - {relation}
- [EPIC-XX](../epics/EPIC-XX/EPIC-XX.md) - {relation}

---

## Specification

### {Section 1}

{Contenu technique detaille}

**Key Points:**
- Point 1
- Point 2

### {Section 2}

{Contenu technique detaille}

```
{Code ou schema si applicable}
```

---

## Implementation Notes

| Aspect | Decision | Notes |
|--------|----------|-------|
| {aspect_1} | {decision} | {notes} |
| {aspect_2} | {decision} | {notes} |

---

## Considerations

### Constraints
- {constraint_1}
- {constraint_2}

### Risks
| Risk | Mitigation |
|------|------------|
| {risk_1} | {mitigation} |

---

## References

- **Source**: {d'ou vient cette spec}
- **Related**: {documents lies}
- **FDs**: {FDs pertinents}

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| {YYYY-MM-DD} | Initial creation | {author} |
```

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| {Title} | Titre du document | Authentication Flow |
| {YYYY-MM-DD} | Date ISO | 2026-01-24 |
| {Status} | Draft/Review/Approved | Draft |
| {owner} | Responsable | Leo |
| {area} | Domaine | architecture, ui-ux, api |

---

## Quality Checklist

- [ ] Titre clair et descriptif
- [ ] Date de mise a jour
- [ ] Status defini
- [ ] Overview concis
- [ ] Context avec background
- [ ] Specs techniques detaillees
- [ ] Considerations (constraints, risks)
- [ ] References aux sources
- [ ] Changelog maintenu
