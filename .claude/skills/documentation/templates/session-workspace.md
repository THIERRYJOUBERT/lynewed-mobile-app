# Template: Session Workspace

> Pour documenter une session de travail dans workspace/current/

---

## Naming Convention

```
workspace/current/YYYY-MM-DD-{topic-slug}.md
```

Example: `workspace/current/2026-01-24-auth-implementation.md`

---

## Template

```markdown
# Session: {topic}

**Date**: {YYYY-MM-DD}
**Duree**: ~{N}h
**Source**: Conversation {timestamp_start} - {timestamp_end}

---

## Contexte

{1-2 phrases sur le contexte de la session}

---

## Decisions

| Decision | Choix | Raison |
|----------|-------|--------|
| {decision_1} | {choix} | {raison} |
| {decision_2} | {choix} | {raison} |

---

## Travail Effectue

### {Feature/Task 1}
- **Status**: Complete/En cours
- **Fichiers**: `path/to/file.dart`
- **Details**: {description concise}

### {Feature/Task 2}
- **Status**: Complete/En cours
- **Fichiers**: `path/to/file.dart`
- **Details**: {description concise}

---

## Problemes Resolus

| Probleme | Solution | Impact |
|----------|----------|--------|
| {probleme_1} | {solution} | {impact} |

---

## Git

**Commits**: {hash1}, {hash2}
**Branch**: {branch_name}
**Files Changed**: {N}

---

## Next Steps

- [ ] {action_1}
- [ ] {action_2}

---

## Notes

{Notes additionnelles si pertinentes}
```

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| {topic} | Sujet principal | Auth Implementation |
| {YYYY-MM-DD} | Date ISO | 2026-01-24 |
| {duration} | Duree estimee | ~3h |
| {timestamp_start/end} | Periode conversation | 14:00 - 17:30 |

---

## Quality Checklist

- [ ] Titre descriptif
- [ ] Date presente
- [ ] Source (conversation) referencee
- [ ] Decisions avec raisons
- [ ] Travail liste avec fichiers
- [ ] Problemes documentes avec solutions
- [ ] Git references (commits, branch)
- [ ] Next steps clairs
