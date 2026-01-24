---
name: update-config
description: "Mettre a jour intelligemment la config Claude Code depuis le template distant. Merge sans ecraser les customisations."
model: sonnet
allowed-tools:
  - Read
  - Glob
  - Write
  - Bash
  - AskUserQuestion
argument-hint: "[--dry-run] [--force]"
---

# Update Config

> Met a jour intelligemment la configuration Claude Code depuis le repo template distant, en preservant les customisations locales.

---

## Rules

- 🚫 JAMAIS ecraser un fichier modifie localement sans confirmation
- 🚫 JAMAIS supprimer de fichiers locaux
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
  --source=URL URL du repo template (default: app-trak/claude-code-template)
```

---

## Task

Mettre a jour la configuration Claude Code de maniere intelligente :
1. **FETCH** - Telecharger le template distant
2. **ANALYZE** - Comparer local vs distant fichier par fichier
3. **CLASSIFY** - Categoriser : nouveau, identique, modifie-local, modifie-distant, conflit
4. **PROPOSE** - Presenter le plan de mise a jour
5. **EXECUTE** - Appliquer les changements valides
6. **REPORT** - Generer rapport final

---

## Execution

### 1. FETCH - Telecharger le template

```bash
# Creer dossier temporaire
TEMP_DIR=$(mktemp -d)
TEMPLATE_REPO="https://github.com/app-trak/claude-code-template"

# Clone shallow (rapide)
git clone --depth 1 "$TEMPLATE_REPO" "$TEMP_DIR/template"
```

**Validation**: Template telecharge avec succes

---

### 2. ANALYZE - Comparer les fichiers

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
    - path: ".claude/skills/new-skill/SKILL.md"
      action: "ADD"
  identical_files:
    - path: ".claude/skills/commit/SKILL.md"
      action: "SKIP"
  updated_files:
    - path: ".claude/rules/core-rules.md"
      action: "UPDATE"
      reason: "Local unchanged, template has updates"
  conflicts:
    - path: ".claude/rules/project-preferences.md"
      action: "CONFLICT"
      local_preview: "..."
      remote_preview: "..."
```

---

### 3. CLASSIFY - Categoriser les changements

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

---

### 4. PROPOSE - Presenter le plan

**Si --dry-run** : Afficher et terminer

**Sinon** : Presenter via AskUserQuestion

```
UPDATE CONFIG - Plan de mise a jour
===================================

📥 NOUVEAUX FICHIERS (seront ajoutes) :
  + .claude/skills/new-workflow/SKILL.md
  + .claude/agents/new-agent.md

🔄 FICHIERS A METTRE A JOUR (non modifies localement) :
  ~ .claude/skills/debug/SKILL.md
  ~ .claude/rules/core-rules.md

⚠️ CONFLITS (modifies localement ET dans template) :
  ! .claude/skills/commit/SKILL.md
    → Local: 15 lignes modifiees
    → Template: 23 lignes modifiees

✓ FICHIERS IDENTIQUES (rien a faire) : 45

⏭️ FICHIERS IGNORES (toujours locaux) :
  - CLAUDE.md
  - .claude/rules/project-preferences.md
```

**AskUserQuestion pour conflits** :
```
question: "Comment gerer les conflits ?"
options:
  - "Garder local (ignorer updates template)"
  - "Prendre template (ecraser local)"
  - "Review un par un"
```

---

### 5. EXECUTE - Appliquer les changements

**Pour chaque fichier selon decision** :

```
NOUVEAU → cp template_file local_path
METTRE_A_JOUR → cp template_file local_path
CONFLIT (prendre template) → cp template_file local_path
CONFLIT (garder local) → skip
```

**Creer backup avant ecrasement** :
```bash
# Si fichier existe et sera ecrase
cp local_file local_file.backup-$(date +%Y%m%d)
```

---

### 6. REPORT - Rapport final

```
UPDATE CONFIG COMPLETE
======================

✅ Fichiers ajoutes: 3
  + .claude/skills/new-workflow/SKILL.md
  + .claude/skills/new-workflow/manifest.yaml
  + .claude/agents/new-agent.md

🔄 Fichiers mis a jour: 5
  ~ .claude/skills/debug/SKILL.md
  ~ .claude/rules/core-rules.md
  ...

⏭️ Fichiers ignores (custom local): 2
  - .claude/rules/project-preferences.md
  - CLAUDE.md

📦 Backups crees: 1
  .claude/skills/commit/SKILL.md.backup-20250124

Version template: [commit hash]
```

---

## Validation

**Avant de terminer, verifier** :
✅ Tous les nouveaux fichiers ajoutes
✅ Fichiers non-modifies mis a jour
✅ Conflits geres selon choix utilisateur
✅ Backups crees pour fichiers ecrases
✅ Fichiers locaux critiques preserves

**Si issues** :
- Logger clairement quel fichier a pose probleme
- Proposer rollback si backup existe

---

## Output

```
UPDATE CONFIG COMPLETE

Added: 3 files
Updated: 5 files
Skipped: 47 files (identical or local custom)
Conflicts resolved: 1

Your Claude Code config is now up to date!
Run /sync-project to update references if needed.
```

---

## Edge Cases

### Projet sans config existante
→ Rediriger vers `install.sh` :
```
Aucune config Claude Code detectee.
Pour une installation complete:
  curl -sSL https://raw.githubusercontent.com/.../install.sh | bash
```

### Template inaccessible
→ Message d'erreur clair avec suggestions (verifier URL, connexion)

### Fichiers binaires ou tres gros
→ Skip avec warning (ne pas comparer/merger)

---

## Reference

Pour les patterns de detection de modifications, voir:
`references/diff-patterns.md`
