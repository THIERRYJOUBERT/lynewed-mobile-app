# Cleaning Rules for Template Sync

> Patterns to clean when synchronizing files to the template repository.
> These rules ensure the template remains generic and reusable.

---

## Pattern Categories

### 1. Project Name References

| Pattern (Regex) | Replacement | Notes |
|-----------------|-------------|-------|
| `TRAK` | `{{PROJECT_NAME}}` | Keep case-sensitive |
| `trak_app` | `{{PROJECT_NAME_SNAKE}}` | Snake case variant |
| `trak-app` | `{{PROJECT_NAME_KEBAB}}` | Kebab case variant |
| `app-trak` | `{{PROJECT_ORG}}` | GitHub org name |

**Context-aware exceptions:**
- In example code blocks: Replace with generic examples
- In URLs: Replace with `{{PROJECT_REPO_URL}}`

---

### 2. Absolute Paths

| Pattern (Regex) | Replacement | Notes |
|-----------------|-------------|-------|
| `/Users/[^/]+/Desktop/trak_app` | `{{PROJECT_ROOT}}` | macOS paths |
| `/home/[^/]+/trak_app` | `{{PROJECT_ROOT}}` | Linux paths |
| `C:\\Users\\[^\\]+\\trak_app` | `{{PROJECT_ROOT}}` | Windows paths |

---

### 3. Tech Stack Specific (Flutter/Dart)

| Pattern (Regex) | Replacement | Notes |
|-----------------|-------------|-------|
| `flutter test` | `{{TEST_CMD}}` | Test command |
| `flutter analyze[^\n]*` | `{{LINT_CMD}}` | Lint command with flags |
| `flutter run` | `{{RUN_CMD}}` | Run command |
| `flutter build` | `{{BUILD_CMD}}` | Build command |
| `dart run build_runner[^\n]*` | `{{CODEGEN_CMD}}` | Code generation |
| `pubspec\.yaml` | `{{PROJECT_CONFIG}}` | Project config file |
| `Dart` | `{{LANGUAGE}}` | Language name |
| `Flutter` | `{{FRAMEWORK}}` | Framework name |

**In tech stack sections:**
- Keep as example but mark: `(example: Flutter/Dart)`
- Or use placeholder: `{{TECH_STACK_EXAMPLE}}`

---

### 4. Domain-Specific Content

| Pattern (Regex) | Replacement | Notes |
|-----------------|-------------|-------|
| `musculation` | `{{PROJECT_DOMAIN}}` | Domain term |
| `entrainement` | `{{PROJECT_DOMAIN}}` | Domain term |
| `training app` | `{{PROJECT_DESCRIPTION}}` | Description |
| `fitness` | `{{PROJECT_DOMAIN}}` | Domain term |
| `workout` | `{{PROJECT_DOMAIN}}` | Domain term |
| `exercise` | `{{PROJECT_DOMAIN}}` | Domain term |

---

### 5. Specific File References

| Pattern (Regex) | Replacement | Notes |
|-----------------|-------------|-------|
| `FD-\d+-[A-Z-]+\.md` | `{{FD_EXAMPLE}}` | Foundation doc refs |
| `PRD-MASTER\.md` | `{{PRD_FILE}}` | PRD reference |
| `EPIC-\d+-[A-Z-]+` | `{{EPIC_EXAMPLE}}` | Epic references |
| `STORY-\d+-\d+` | `{{STORY_EXAMPLE}}` | Story references |

---

## Files to Skip Cleaning

These files should be copied as-is (no pattern replacement):

```
.claude/context/Claude Documentation Official/**
.claude/skills/claude-memory/**
.claude/skills/create-slash-commands/**
```

Reason: Official Anthropic content, should not be modified.

---

## Files to Exclude Entirely

Do NOT copy these files/directories:

```
docs/specs/FD-*.md
docs/specs/PRD-MASTER.md
docs/epics/**
docs/detailed/**
workspace/**
.claude/settings.local.json
.claude/ralph/**
```

Reason: Project-specific content that should not be in template.

---

## Special Handling

### CLAUDE.md

The root `CLAUDE.md` should be transformed into `CLAUDE.md.template`:
1. Replace project name with `{{PROJECT_NAME}}`
2. Replace tech stack with placeholders
3. Replace commands with `{{*_CMD}}` placeholders
4. Keep structure and workflow documentation intact

### project-preferences.md

Should be reset to a minimal template:
```markdown
# Project Preferences

> Configure these preferences for your project.

## Stack

| Element | Value |
|---------|-------|
| Type | {{PROJECT_TYPE}} |
| Language | {{LANGUAGE}} |
| Test command | {{TEST_CMD}} |
| Lint command | {{LINT_CMD}} |

## Workflow

| Decision | Value |
|----------|-------|
| Default model | opus |
| Default mode | supervised |

## Add your preferences below
```

---

## Regex Implementation Notes

When implementing cleaning:

```javascript
// Example implementation
const cleaningRules = [
  { pattern: /TRAK/g, replacement: '{{PROJECT_NAME}}' },
  { pattern: /trak_app/g, replacement: '{{PROJECT_NAME_SNAKE}}' },
  { pattern: /\/Users\/[^\/]+\/Desktop\/trak_app/g, replacement: '{{PROJECT_ROOT}}' },
  { pattern: /flutter test/g, replacement: '{{TEST_CMD}}' },
  { pattern: /flutter analyze[^\n]*/g, replacement: '{{LINT_CMD}}' },
  // ... etc
];

function cleanFile(content) {
  let cleaned = content;
  for (const rule of cleaningRules) {
    cleaned = cleaned.replace(rule.pattern, rule.replacement);
  }
  return cleaned;
}
```

---

## Validation

After cleaning, verify:
- [ ] No absolute paths remain
- [ ] No project name references remain (search for TRAK, trak)
- [ ] No domain-specific terms remain
- [ ] Placeholders are properly formatted `{{PLACEHOLDER}}`
- [ ] File structure is preserved
- [ ] Markdown formatting is intact
