# Step 00: Init

> Parse arguments, valider topic, preparer le pipeline.

---

## Objectif

Extraire et valider les arguments de /learn pour demarrer le pipeline d'acquisition de connaissance.

---

## Process

### 1. Parser $ARGUMENTS

```
Format: <topic> [--depth=quick|standard|deep]

Extraction:
- topic: Tout sauf le flag --depth
- depth: Valeur du flag ou "standard" par defaut
```

**Exemples**:
```
"/learn auth-system"              → topic="auth-system", depth="standard"
"/learn state-management --depth=deep" → topic="state-management", depth="deep"
"/learn 'workout tracking'"       → topic="workout tracking", depth="standard"
```

### 2. Valider le Topic

**Validation**:
- Topic non vide
- Topic suffisamment specifique (pas "tout" ou "le projet")
- Topic comprehensible

**Si topic vague**, utiliser AskUserQuestion:
```
question: "Le topic '{topic}' est trop vague. Peux-tu preciser ?"
header: "Clarification"
options:
  - label: "Feature specifique"
    description: "Ex: auth-system, state-management, workout-tracking"
  - label: "Concept technique"
    description: "Ex: Riverpod providers, Supabase integration"
  - label: "Pattern"
    description: "Ex: TDD workflow, error handling"
```

### 3. Sanitizer le Topic pour Output Path

```dart
// Sanitization
final sanitized = topic
  .toLowerCase()
  .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
  .replaceAll(RegExp(r'-+'), '-')
  .replaceAll(RegExp(r'^-|-$'), '');

// Result
output_path = "workspace/current/${sanitized}/"
```

**Exemples**:
```
"auth-system"        → "auth-system"
"State Management"   → "state-management"
"workout tracking"   → "workout-tracking"
"lib/features/auth"  → "lib-features-auth"
```

### 4. Creer le Dossier Output

Verifier que workspace/current/ existe, puis creer le dossier topic:

```bash
mkdir -p workspace/current/{sanitized_topic}
```

### 5. Configurer le Pipeline selon Depth

| Depth | Scan Agents | Understand Agents | Iterations |
|-------|-------------|-------------------|------------|
| `quick` | 3 Haiku | Skip | 1 |
| `standard` | 3 Haiku | 3 Sonnet | 2 |
| `deep` | 3 Haiku | 3 Sonnet (x2) | 3 |

---

## Output

```yaml
step_00_output:
  topic: "{raw_topic}"
  topic_sanitized: "{sanitized}"
  depth: "quick" | "standard" | "deep"
  output_path: "workspace/current/{sanitized}/"
  pipeline_config:
    scan_agents: 3
    understand_agents: 0 | 3 | 6  # Selon depth
    max_iterations: 1 | 2 | 3
```

---

## Auto-Validation

✅ Topic non vide et specifique
✅ Depth valide (quick|standard|deep)
✅ Output path sanitized et cree
✅ Pipeline config definie

---

## Next

Charger `steps/step-01-scan.md` pour lancer la phase de scan.
