---
name: update-config
description: "Mettre a jour intelligemment la config Claude Code depuis le template distant. Merge sans ecraser les customisations."
model: opus
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - TodoWrite
argument-hint: "[--dry-run] [--force]"
---

# Update Config

> Met a jour intelligemment la configuration Claude Code depuis le repo template distant, en preservant les customisations locales.

---

## Rules

- 🚫 JAMAIS ecraser un fichier modifie localement sans confirmation
- 🚫 JAMAIS supprimer de fichiers locaux
- ✅ TOUJOURS afficher un CHANGELOG clair des nouveautes du template
- ✅ TOUJOURS ajouter les nouveaux skills/agents/rules du template
- ✅ TOUJOURS mettre a jour les fichiers non-modifies localement
- ✅ TOUJOURS signaler les conflits et proposer des options
- ⚠️ Utiliser --dry-run pour previsualiser avant d'executer

---

## Arguments

```
$ARGUMENTS

Options:
  --dry-run    Affiche ce qui serait fait sans executer
  --force      Met a jour tous les fichiers (ecrase les modifications locales)
  --source=URL URL du repo template (default: {{PROJECT_ORG}}/claude-code-template)
```

---

## Task

Mettre a jour la configuration Claude Code de maniere intelligente :
1. **FETCH** - Telecharger le template distant
2. **CHANGELOG** - **NOUVEAU** : Analyser et afficher les changements du template
3. **ANALYZE** - Comparer local vs distant fichier par fichier
4. **CLASSIFY** - Categoriser : nouveau, identique, modifie-local, modifie-distant, conflit
5. **PROPOSE** - Presenter le plan de mise a jour avec changelog
6. **EXECUTE** - Appliquer les changements valides
7. **REPORT** - Generer rapport final

---

## Execution

### 1. FETCH - Telecharger le template

```bash
# Creer dossier temporaire
TEMP_DIR=$(mktemp -d)
TEMPLATE_REPO="https://github.com/{{PROJECT_ORG}}/claude-code-template"

# Clone shallow (rapide)
git clone --depth 1 "$TEMPLATE_REPO" "$TEMP_DIR/template"

# Capturer le hash et date du dernier commit
cd "$TEMP_DIR/template"
TEMPLATE_HASH=$(git rev-parse --short HEAD)
TEMPLATE_DATE=$(git log -1 --format=%ci)
TEMPLATE_MSG=$(git log -1 --format=%s)
```

**Validation**: Template telecharge avec succes

---

### 2. CHANGELOG - Analyser les nouveautes du template (CRITICAL!)

**Cette etape est OBLIGATOIRE pour que l'utilisateur comprenne ce qui a change.**

#### 2.1 Detecter les nouveaux workflows/skills

```bash
# Lister tous les skills dans le template
ls -d "$TEMP_DIR/template/.claude/skills/*/" 2>/dev/null | xargs -n1 basename

# Comparer avec les skills locaux
ls -d ".claude/skills/*/" 2>/dev/null | xargs -n1 basename
```

**Pour chaque NOUVEAU skill dans le template:**
- Lire son `SKILL.md` pour extraire description
- Noter dans la liste des nouveautes

#### 2.2 Detecter les skills modifies

Pour chaque skill existant dans les deux versions:

```bash
# Comparer les SKILL.md
diff ".claude/skills/$SKILL/SKILL.md" "$TEMP_DIR/template/.claude/skills/$SKILL/SKILL.md"
```

**Si different, analyser les changements:**
- Lire les deux versions
- Identifier les sections ajoutees/modifiees
- Resumer les changements cles

#### 2.3 Generer le CHANGELOG

**Format obligatoire a afficher:**

```markdown
╔══════════════════════════════════════════════════════════════════╗
║                    TEMPLATE CHANGELOG                             ║
╠══════════════════════════════════════════════════════════════════╣
║  Version: {TEMPLATE_HASH}                                         ║
║  Date: {TEMPLATE_DATE}                                            ║
║  Message: {TEMPLATE_MSG}                                          ║
╚══════════════════════════════════════════════════════════════════╝

## 🆕 NOUVEAUX WORKFLOWS

| Workflow | Description |
|----------|-------------|
| /security-audit | Audit complet securite + qualite, genere Epic remediation |
| /setup-ralph | Configure autonomous AI coding loop |

## 📝 WORKFLOWS MODIFIES

### /create-epic
- **NOUVEAU**: Mode `--auto` pour selection automatique du premier Epic non-cree
- **NOUVEAU**: Parse arguments pour epic name direct

### /create-story
- **NOUVEAU**: Mode `--auto` pour generation sans checkpoint
- **FIX**: TRACKING.md maintenant correctement mis a jour avec stories + deps

### /dev-story
- **NOUVEAU**: Step-06 documentation - cree dossier story avec implementation.md
- **NOUVEAU**: Structure docs par story

### /launch-epic
- **FIX**: Epic-level TRACKING.md update complet a la fin

## 📁 NOUVEAUX FICHIERS

- `.claude/skills/security-audit/` (13 fichiers)
- `.claude/skills/create-epic/templates/tracking-canonical.md`
- `.claude/skills/dev-story/steps/step-06-document.md`

## 🔧 FICHIERS MODIFIES

- `.claude/skills/create-epic/SKILL.md` (+modes, +argument-hint)
- `.claude/skills/create-story/SKILL.md` (+modes --auto)
- `.claude/skills/create-story/steps/step-04-validate.md` (TRACKING implementation)
- `.claude/skills/dev-story/SKILL.md` (+step-06, +story_folder)
- `.claude/skills/launch-epic/steps/step-04-finalize.md` (Epic tracking)
```

**IMPORTANT**: Toujours afficher ce changelog AVANT de proposer les actions.

---

### 3. ANALYZE - Comparer les fichiers

Pour chaque fichier dans le template `.claude/` :

```
1. Verifier si le fichier existe localement
2. Si existe : calculer checksum des deux versions
3. Determiner le status :
   - NOUVEAU : existe dans template, pas en local
   - IDENTIQUE : meme checksum
   - MODIFIE_DISTANT : local non-modifie, template different
   - MODIFIE_LOCAL : local modifie, template identique a l'original
   - CONFLIT : local ET template modifies differemment
```

**Detection des modifications locales** :
- Comparer avec le dernier commit git si disponible
- Sinon, supposer que le fichier local peut etre modifie

**Structure de resultat** :
```yaml
analysis:
  new_files:
    - path: ".claude/skills/security-audit/SKILL.md"
      action: "ADD"
      description: "Audit securite complet"
  identical_files:
    - path: ".claude/skills/commit/SKILL.md"
      action: "SKIP"
  updated_files:
    - path: ".claude/skills/create-epic/SKILL.md"
      action: "UPDATE"
      changes: "Added --auto mode"
  conflicts:
    - path: ".claude/rules/project-preferences.md"
      action: "CONFLICT"
      local_preview: "..."
      remote_preview: "..."
```

---

### 4. CLASSIFY - Categoriser les changements

**Categories d'action** :

| Status | Action par defaut | Avec --force |
|--------|-------------------|--------------|
| NOUVEAU | Ajouter | Ajouter |
| IDENTIQUE | Skip | Skip |
| MODIFIE_DISTANT | Mettre a jour | Mettre a jour |
| MODIFIE_LOCAL | Skip (conserver local) | Ecraser |
| CONFLIT | Demander | Ecraser |

**Fichiers a ne JAMAIS mettre a jour** (toujours locaux) :
- `CLAUDE.md` (racine du projet)
- `.claude/rules/project-preferences.md`
- `.claude/settings.local.json`
- Tout fichier dans `workspace/`

---

### 5. PROPOSE - Presenter le plan

**TOUJOURS afficher le CHANGELOG d'abord (etape 2), puis le plan d'action.**

**Si --dry-run** : Afficher et terminer

**Sinon** : Presenter via AskUserQuestion

```
UPDATE CONFIG - Plan de mise a jour
===================================

📥 NOUVEAUX FICHIERS ({count}) :
  + .claude/skills/security-audit/ (13 fichiers)
  + .claude/skills/dev-story/steps/step-06-document.md
  + .claude/skills/create-epic/templates/tracking-canonical.md

🔄 FICHIERS A METTRE A JOUR ({count}) :
  ~ .claude/skills/create-epic/SKILL.md (added --auto mode)
  ~ .claude/skills/create-story/SKILL.md (added --auto mode)
  ~ .claude/skills/create-story/steps/step-04-validate.md (TRACKING fix)
  ~ .claude/skills/dev-story/SKILL.md (added step-06)
  ~ .claude/skills/launch-epic/steps/step-04-finalize.md (Epic tracking)

⚠️ CONFLITS ({count}) :
  ! .claude/skills/xxx/SKILL.md
    → Vous avez modifie ce fichier localement
    → Le template a aussi des updates

✓ FICHIERS IDENTIQUES : {count}

⏭️ FICHIERS IGNORES (toujours locaux) :
  - CLAUDE.md
  - .claude/rules/project-preferences.md
```

**AskUserQuestion pour validation** :
```yaml
question: "Appliquer ces mises a jour ?"
header: "Update"
options:
  - label: "Oui, mettre a jour (Recommande)"
    description: "Ajoute nouveaux fichiers + met a jour les non-modifies"
  - label: "Dry-run seulement"
    description: "Afficher le detail sans appliquer"
  - label: "Annuler"
    description: "Ne rien faire"
```

**Si conflits, question supplementaire** :
```yaml
question: "Comment gerer les {count} conflits ?"
header: "Conflits"
options:
  - label: "Garder local"
    description: "Ignorer les updates template pour ces fichiers"
  - label: "Prendre template"
    description: "Ecraser avec la version template (backup cree)"
  - label: "Review un par un"
    description: "Decider pour chaque fichier"
```

---

### 6. EXECUTE - Appliquer les changements

**Pour chaque fichier selon decision** :

```bash
# NOUVEAU → copier
cp -r "$TEMP_DIR/template/$file" "$local_path"

# METTRE_A_JOUR → copier
cp "$TEMP_DIR/template/$file" "$local_path"

# CONFLIT (prendre template) → backup + copier
cp "$local_file" "$local_file.backup-$(date +%Y%m%d)"
cp "$TEMP_DIR/template/$file" "$local_path"
```

**Gerer les dossiers** :
- Si nouveau skill avec plusieurs fichiers, copier tout le dossier
- Preserver la structure (steps/, templates/, references/)

---

### 7. REPORT - Rapport final

```markdown
╔══════════════════════════════════════════════════════════════════╗
║                    UPDATE CONFIG COMPLETE                         ║
╚══════════════════════════════════════════════════════════════════╝

## Resume

| Action | Count |
|--------|-------|
| ✅ Fichiers ajoutes | 15 |
| 🔄 Fichiers mis a jour | 8 |
| ⏭️ Fichiers ignores | 45 |
| 📦 Backups crees | 1 |

## Nouveaux Workflows Disponibles

- `/security-audit` - Audit securite complet
- `/setup-ralph` - Autonomous AI coding loop

## Workflows Ameliores

- `/create-epic --auto` - Mode 100% autonome
- `/create-story --auto` - Generation sans checkpoint
- `/dev-story` - Documentation stories dans dossiers

## Prochaines Etapes

1. Tester les nouveaux workflows
2. Verifier que vos customisations fonctionnent
3. Lancer `/sync-project` si besoin

Version template: {TEMPLATE_HASH} ({TEMPLATE_DATE})
```

---

## Validation

**Avant de terminer, verifier** :
✅ Changelog affiche clairement les nouveautes
✅ Tous les nouveaux fichiers ajoutes
✅ Fichiers non-modifies mis a jour
✅ Conflits geres selon choix utilisateur
✅ Backups crees pour fichiers ecrases
✅ Fichiers locaux critiques preserves

---

## Edge Cases

### Projet sans config existante
→ Rediriger vers installation :
```
Aucune config Claude Code detectee.
Pour une installation complete:
  git clone https://github.com/{{PROJECT_ORG}}/claude-code-template /tmp/cc && bash /tmp/cc/install.sh
```

### Template inaccessible (repo prive)
→ Message d'erreur avec solution :
```
Impossible d'acceder au template (repo prive?).
Solution: git clone manuellement puis copier les fichiers.
```

### Fichiers binaires ou tres gros
→ Skip avec warning (ne pas comparer/merger)

---

## Changelog Detection Logic

Pour detecter intelligemment les changements, comparer :

1. **Nouveaux dossiers** : `ls -d template/.claude/skills/*/` vs local
2. **SKILL.md modifies** : `diff` sur les fichiers existants
3. **Sections ajoutees** : Chercher `<modes>`, `--auto`, nouveaux steps
4. **Templates ajoutes** : Nouveaux fichiers dans `templates/`
5. **Steps ajoutes** : Nouveaux fichiers `step-XX-*.md`

**Keywords a detecter dans les diffs** :
- `--auto` → Mode automatique ajoute
- `<modes>` → Section modes ajoutee
- `step-06` → Nouveau step
- `TRACKING` → Fix tracking
- `documentation` → Documentation ajoutee
