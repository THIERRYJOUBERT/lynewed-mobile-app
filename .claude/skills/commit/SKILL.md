---
name: commit
description: "Commit integre avec verifications {{PROJECT_NAME}} obligatoires. Bloque si tests fail ou warnings."
model: haiku
allowed-tools: Bash, Read, Glob
argument-hint: "[message optionnel]"
---

# Commit Workflow {{PROJECT_NAME}}

Tu es un **Commit Guardian**.

---

## INSTRUCTION CRITIQUE

**JAMAIS commit si tests fail ou warnings.**

Ce workflow bloque automatiquement les commits non conformes.

---

## ARGUMENT

Message optionnel: $ARGUMENTS

Si pas de message, generer un message conventionnel basé sur les changements.

---

## WORKFLOW COMMIT

```
┌──────────────────────────────────────────────────────────────────┐
│                    COMMIT WORKFLOW (5 ETAPES)                    │
│                                                                  │
│  01. VERIFY     → Tests + Lint (auto-detect: Flutter/Node/etc)   │
│       │          → BLOQUER si echec                              │
│       ↓                                                          │
│  02. CHECK      → Verifier: Tests passent ? Warnings = 0 ?       │
│       │          → BLOQUER si non conforme                       │
│       ↓                                                          │
│  03. STAGE      → git add (fichiers pertinents)                  │
│       │          → JAMAIS git add -A (risque secrets)            │
│       ↓                                                          │
│  04. COMMIT     → Message conventionnel                          │
│       ↓          → (04b: Hooks git si presents)                  │
│                                                                  │
│  05. PUSH       → Automatique vers dev (avec retry)              │
└──────────────────────────────────────────────────────────────────┘
```

---

## 01. VERIFY - Verifications Obligatoires

### Detecter le type de projet

```bash
# Detection automatique du type de projet
if [ -f "pubspec.yaml" ]; then
  PROJECT_TYPE="flutter"
elif [ -f "package.json" ]; then
  PROJECT_TYPE="node"
elif [ -f "Cargo.toml" ]; then
  PROJECT_TYPE="rust"
elif [ -f "go.mod" ]; then
  PROJECT_TYPE="go"
else
  PROJECT_TYPE="generic"
fi
```

### Executer les verifications selon le type

**Flutter:**
```bash
{{TEST_CMD}}
{{LINT_CMD}}
```

**Node.js:**
```bash
npm test
npm run lint  # ou eslint . si disponible
```

**Rust:**
```bash
cargo test
cargo clippy -- -D warnings
```

**Go:**
```bash
go test ./...
go vet ./...
```

**Generic (aucun framework detecte):**
```bash
# Pas de verifications automatiques
# Verifier manuellement ou configurer le projet
echo "Projet generique - verifications manuelles requises"
```

### Criteres de passage

| Critere | Requis | Action si echec |
|---------|--------|-----------------|
| Tests | 100% pass | BLOQUER - corriger d'abord |
| Warnings | 0 | BLOQUER - corriger d'abord |
| Lint/Analyze | 0 issues | BLOQUER - corriger d'abord |

### Si echec

```
COMMIT BLOQUE

RAISON: [Tests fail / Warnings / Infos]

PROBLEMES:
1. [Description du probleme]
2. [Description du probleme]

ACTION REQUISE:
Corriger les problemes avant de commit.
Utiliser /debug si necessaire pour investiguer.
```

**NE PAS CONTINUER** si cette etape echoue.

---

## 02. CHECK - Verification Finale

### Lister les changements

```bash
git status
git diff --staged
```

### Verifier

- [ ] Pas de fichiers sensibles (.env, credentials, secrets)
- [ ] Pas de fichiers de debug laisses
- [ ] Pas de TODO/FIXME non traites dans les nouveaux fichiers
- [ ] Changements coherents avec un seul objectif

### Si fichiers sensibles detectes

```
COMMIT BLOQUE

FICHIERS SENSIBLES DETECTES:
- .env
- credentials.json
- [autre]

ACTION REQUISE:
Retirer ces fichiers du staging avec:
git reset HEAD <fichier>
```

---

## 03. STAGE - Ajout des Fichiers

### Methode recommandee

```bash
# Ajouter fichiers specifiques (RECOMMANDE)
git add lib/specific_file.dart
git add test/specific_test.dart

# OU ajouter par pattern
git add lib/features/feature_name/
git add test/features/feature_name/
```

### INTERDIT

```bash
# NE PAS UTILISER
git add -A          # Risque d'inclure secrets
git add .           # Risque d'inclure secrets
```

---

## 04. COMMIT - Message Conventionnel

### Format

```
<type>(<scope>): <description>

[Corps optionnel]

[Footer optionnel]
```

### Types

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalite |
| `fix` | Correction de bug |
| `refactor` | Refactoring (pas de changement fonctionnel) |
| `test` | Ajout/modification de tests |
| `docs` | Documentation |
| `style` | Formatage (pas de changement de code) |
| `chore` | Maintenance (build, deps) |

### Exemples

```bash
git commit -m "feat(auth): add login form validation"
git commit -m "fix(api): handle timeout errors gracefully"
git commit -m "refactor(utils): extract date formatting helpers"
```

### Avec corps (changements importants)

```bash
git commit -m "$(cat <<'EOF'
feat(analysis): implement SCE score calculation

- Add SCE formula from analysis engine
- Add unit tests for edge cases
- Story: STORY-01-03

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

## 04b. HOOKS GIT - Interaction avec Pre-commit

### Comportement avec hooks existants

Si le projet a des **pre-commit hooks** (`.git/hooks/pre-commit` ou via Husky/lefthook):

| Situation | Comportement |
|-----------|--------------|
| Hook passe | Commit procede normalement |
| Hook echoue | Commit BLOQUE (comportement git natif) |
| Hook timeout | Commit BLOQUE, investiguer le hook |

### Si hook pre-commit echoue

```
COMMIT BLOQUE PAR PRE-COMMIT HOOK

Le hook pre-commit a echoue. Ceci est INDEPENDANT des verifications /commit.

CAUSES POSSIBLES:
1. Lint additionnel dans le hook (prettier, eslint fix)
2. Tests supplementaires
3. Verification de secrets (detect-secrets, gitleaks)
4. Formatage automatique qui modifie les fichiers

ACTIONS:
1. Lire le message d'erreur du hook
2. Corriger les problemes identifies
3. Re-stager les fichiers modifies si necessaire
4. Relancer /commit
```

### Hooks recommandes vs /commit

| Verification | Dans /commit | Dans pre-commit hook |
|--------------|--------------|----------------------|
| Tests unitaires | OUI | Optionnel (peut dupliquer) |
| Linting | OUI | Recommande (formatage auto) |
| Secrets | NON | FORTEMENT RECOMMANDE |
| Formatting | NON | Recommande (auto-fix) |

**Note**: `/commit` fait ses propres verifications AVANT d'appeler `git commit`.
Les hooks s'executent APRES que git commit est lance.

---

## 05. PUSH - Envoi Automatique vers dev

### Strategie de Branches

```
dev (push automatique)     ──PR manuelle──>     main (stable)
```

- **dev** : Branche de travail, push automatique apres chaque commit
- **main** : Branche stable, PR manuelle quand l'utilisateur decide

### Execution avec Retry

```bash
# Verifier la branche actuelle
CURRENT_BRANCH=$(git branch --show-current)

# Si sur main, switcher vers dev d'abord
if [ "$CURRENT_BRANCH" = "main" ]; then
  git checkout dev
  git merge main --no-edit
fi

# Push automatique vers dev avec retry (max 3 tentatives)
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if git push origin dev 2>&1; then
    echo "Push reussi"
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "Push echoue, tentative $RETRY_COUNT/$MAX_RETRIES..."
      sleep 2
    fi
  fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "PUSH ECHOUE apres $MAX_RETRIES tentatives"
  echo "Commit local effectue. Push manuel requis: git push origin dev"
fi
```

### Regles de Push

| Branche | Action |
|---------|--------|
| `dev` | Push automatique TOUJOURS (avec retry) |
| `main` | Checkout vers dev, merge, puis push dev |
| autre | Push vers la branche courante |

### Gestion des Erreurs Reseau

| Erreur | Action |
|--------|--------|
| Timeout | Retry automatique (max 3x) |
| Auth fail | Stopper, demander verification credentials |
| Remote reject | Stopper, pull --rebase peut etre requis |

**COMPORTEMENT** : Push automatique vers `dev` avec retry.
Si echec persistant, commit local OK, push manuel requis.

---

## OUTPUT

### Commit reussi

```
COMMIT EFFECTUE

HASH: [hash court]
MESSAGE: [message du commit]

FICHIERS INCLUS:
- lib/xxx.dart
- test/xxx_test.dart

VERIFICATIONS:
- Tests: PASS
- Warnings: 0
- Analyze: PASS

PUSH: origin/dev (automatique)
```

### Commit bloque

```
COMMIT BLOQUE

RAISON: [Tests fail / Warnings / Fichiers sensibles]

PROBLEMES:
[Liste des problemes]

ACTION REQUISE:
[Instructions pour corriger]
```

---

## AUTO-VALIDATION

**Avant de considerer le commit termine, verifier:**

✅ Tests passent (100%)
✅ Warnings = 0 (lint/analyze)
✅ Pas de fichiers sensibles stages (.env, credentials)
✅ Message suit le format conventionnel
✅ Commit effectue localement
✅ Push vers dev reussi (ou echec documente)

**Si echec a une etape:**
1. STOP - ne pas continuer
2. Reporter le probleme clairement
3. Suggerer l'action corrective
4. Ne PAS bypass les verifications

---

## INSTRUCTIONS CRITIQUES (SANDWICH - FIN)

**RAPPEL FINAL:**

1. **JAMAIS** commit si tests fail
2. **JAMAIS** commit si warnings > 0
3. **JAMAIS** git add -A ou git add .
4. **TOUJOURS** verifier avant de commit
5. **TOUJOURS** message conventionnel

### Ce workflow est utilisable par:
- Developpeurs humains
- Agents autonomes (Epic Assistant, Story Executor)
- Mode supervised et autonomous

---

## BEGIN

1. VERIFY : Detecter type projet, executer tests + lint
2. CHECK : Verifier pas de fichiers sensibles
3. STAGE : git add fichiers specifiques
4. COMMIT : Message conventionnel (hooks git si presents)
5. PUSH : Automatique vers dev avec retry (3 tentatives max)
