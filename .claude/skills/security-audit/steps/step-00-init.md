# Step 00: Init

> Detecter le stack technique et parser les arguments.

---

## Task

1. Parser les arguments (mode, scope)
2. Detecter le stack technique du projet
3. Initialiser les variables d'etat
4. Valider les prerequis

---

## Execution

### 1. Parser les Arguments

```yaml
# Defaults
mode: deep
scope: [all]

# Parse $ARGUMENTS
if "--mode=quick" in args:
  mode = quick

if scope specified:
  scope = parsed_scopes  # [code, auth, data, api, deps, config]
else:
  scope = [all]
```

### 2. Detecter le Stack

```bash
# Detection automatique
if [ -f "pubspec.yaml" ]; then
  stack="flutter"
  test_cmd="{{TEST_CMD}}"
  lint_cmd="{{LINT_CMD}}nfos"
  dep_file="pubspec.yaml"
elif [ -f "package.json" ]; then
  stack="node"
  test_cmd="npm test"
  lint_cmd="npm run lint"
  dep_file="package.json"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  stack="python"
  test_cmd="pytest"
  lint_cmd="ruff check ."
  dep_file="requirements.txt"
elif [ -f "Cargo.toml" ]; then
  stack="rust"
  test_cmd="cargo test"
  lint_cmd="cargo clippy"
  dep_file="Cargo.toml"
elif [ -f "go.mod" ]; then
  stack="go"
  test_cmd="go test ./..."
  lint_cmd="go vet ./..."
  dep_file="go.mod"
else
  stack="generic"
fi
```

### 3. Detecter Services Externes

```yaml
# Supabase
if exists "supabase/" or grep "supabase" in dep_file:
  services.supabase = true

# Firebase
if grep "firebase" in dep_file:
  services.firebase = true

# AWS
if exists ".aws/" or grep "aws-sdk" in dep_file:
  services.aws = true
```

### 4. Initialiser State

```yaml
state:
  mode: {mode}
  scope: {scope}
  stack:
    type: {stack}
    test_cmd: {test_cmd}
    lint_cmd: {lint_cmd}
    dep_file: {dep_file}
  services: {detected_services}
  scan_results: []
  analysis_results: []
  findings: []
  report_path: null
  create_epic: null
  epic_id: null
```

### 5. Afficher Resume

```markdown
## Security Audit Initialized

**Mode**: {mode}
**Scope**: {scope}
**Stack**: {stack}

**Services detected**:
- Supabase: {yes/no}
- Firebase: {yes/no}
- AWS: {yes/no}

Starting {mode} audit on {scope} domains...
```

---

## Validation

✅ Mode valide (quick | deep)
✅ Scope valide (domaines reconnus)
✅ Stack detecte
✅ State initialise

---

## Next

```
IF mode == "quick":
  Load steps/step-01-scan.md (only deps + config agents)
ELSE:
  Load steps/step-01-scan.md (all 3 agents)
```
