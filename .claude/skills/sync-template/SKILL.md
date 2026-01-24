---
name: sync-template
description: "Synchroniser les workflows Claude Code vers le repo template externe. Nettoie automatiquement les references projet."
model: haiku
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Write
  - Bash
argument-hint: "[--target=<path>] [--push] [--dry-run]"
---

# Sync Template

> Synchronise les configurations Claude Code depuis ce projet vers le repo template externe pour reutilisation dans d'autres projets.

---

## Comportement

**IMPORTANT** : Ce workflow commit UNIQUEMENT dans le repo template cible, PAS dans le projet source.

- Le projet source (TRAK) n'est PAS modifie
- Les commits/push se font dans `{target_path}` (repo template)
- Pour committer les changements dans le projet source, utiliser `/commit` separement

---

## Rules

- 🚫 JAMAIS copier de contenu specifique projet (PRD, stories, epics, FDs)
- 🚫 JAMAIS ecraser des fichiers template sans nettoyer les refs projet
- 🚫 JAMAIS committer dans le projet source - ce workflow ne touche QUE le repo template
- ✅ TOUJOURS nettoyer les references specifiques (TRAK, Flutter, chemins absolus)
- ✅ TOUJOURS generer un rapport de ce qui a ete synchronise
- ⚠️ Utiliser --dry-run pour previsualiser avant d'executer

---

## Arguments

```
$ARGUMENTS

Options:
  --target=<path>  Chemin vers le repo template (default: ../claude-code-template)
  --push           Commit et push automatique apres sync
  --dry-run        Affiche ce qui serait fait sans executer
```

---

## Task

Synchroniser les fichiers de configuration Claude Code vers un repo template externe :
1. **VALIDATE** - Verifier le repo cible existe et est valide
2. **SYNC** - Copier et nettoyer les fichiers .claude/
3. **REPORT** - Generer rapport + optionnel push

---

## Execution

### 1. VALIDATE - Verification du repo cible

**Parser les arguments:**
```
target_path = --target value OR ../claude-code-template
push_mode = --push present
dry_run = --dry-run present
```

**Verifier le target:**
```bash
# Verifier que le dossier existe
ls -la {target_path}

# Verifier que c'est un repo git
ls {target_path}/.git
```

**Si target n'existe pas:**
- Message d'erreur clair
- Suggerer de cloner le repo template d'abord
- STOP

**Validation**: Target path existe et contient .git/

---

### 2. SYNC - Copie et nettoyage

**Fichiers a synchroniser:**

| Source | Destination | Action |
|--------|-------------|--------|
| `.claude/skills/` | `{target}/.claude/skills/` | Copier + Nettoyer |
| `.claude/agents/` | `{target}/.claude/agents/` | Copier + Nettoyer |
| `.claude/rules/` | `{target}/.claude/rules/` | Copier + Nettoyer |
| `.claude/context/` | `{target}/.claude/context/` | Copier + Nettoyer |
| `.claude/commands/` | `{target}/.claude/commands/` | Copier + Nettoyer |
| `docs/` structure | `{target}/docs/` | Structure vide seulement |
| `workspace/` structure | `{target}/workspace/` | Structure vide seulement |

**Fichiers a EXCLURE (ne pas copier):**
- `docs/specs/FD-*.md` (Foundation docs specifiques)
- `docs/specs/PRD-MASTER.md` (PRD specifique)
- `docs/epics/**` (Tout le contenu epics)
- `docs/detailed/**` (Details techniques projet)
- `workspace/**` (Contenu workspace)
- `.claude/settings.local.json` (Preferences locales)

**Patterns a nettoyer dans les fichiers copies:**

Lire le fichier `references/cleaning-rules.md` pour les patterns complets.

**Resume des patterns:**
```
TRAK|trak_app|trak-app → {{PROJECT_NAME}}
/Users/.*/Desktop/trak_app → {{PROJECT_ROOT}}
flutter test → {{TEST_CMD}}
flutter analyze.* → {{LINT_CMD}}
musculation|entrainement → {{PROJECT_DOMAIN}}
```

**Process pour chaque fichier:**
1. Lire le fichier source
2. Appliquer les patterns de nettoyage (regex replace)
3. Ecrire dans le target (si pas --dry-run)
4. Logger l'action

**Si --dry-run:**
- Afficher ce qui serait copie
- Afficher les patterns qui seraient nettoyes
- NE PAS ecrire de fichiers

**Validation**: Tous les fichiers copies et nettoyes

---

### 3. REPORT - Rapport et finalisation

**Generer rapport:**
```
SYNC TEMPLATE REPORT
====================

Target: {target_path}
Mode: {dry_run ? "DRY RUN" : "EXECUTED"}

FILES SYNCHRONIZED:
-------------------
.claude/skills/
  - commit/SKILL.md (cleaned: 2 patterns)
  - debug/SKILL.md (cleaned: 1 pattern)
  - ...

.claude/agents/
  - pm.md (no cleaning needed)
  - ...

CLEANING SUMMARY:
-----------------
- Total files processed: N
- Files cleaned: M
- Patterns replaced: P
- Files unchanged: K

STRUCTURE CREATED:
------------------
docs/specs/ (empty)
docs/detailed/ (empty)
docs/epics/ (empty)
workspace/current/ (empty)
workspace/archive/ (empty)
```

**Si --push:**
```bash
cd {target_path}
git add -A
git commit -m "sync: update from source project $(date +%Y-%m-%d)"
git push origin main
```

**Message final:**
```
SI --push:
  "Sync complete. Changes pushed to remote."

SI --dry-run:
  "Dry run complete. Use without --dry-run to execute."

SINON:
  "Sync complete. Changes staged locally."
  "To push: cd {target_path} && git add -A && git commit -m 'sync' && git push"
```

---

## Validation

**Avant de terminer, verifier:**
✅ Target path valide et accessible
✅ Tous les fichiers source traites
✅ Patterns de nettoyage appliques
✅ Aucun contenu projet-specifique copie
✅ Rapport genere

**Si issues:**
- Logger clairement quel fichier a pose probleme
- Continuer avec les autres fichiers si possible
- Rapport final inclut les erreurs

---

## Output

```
SYNC TEMPLATE COMPLETE

Target: ../claude-code-template
Files: 45 synchronized
Cleaned: 32 patterns replaced
Mode: EXECUTED

Next steps:
- Review changes in {target_path}
- Test with: cd {target_path} && ./install.sh --auto
```

---

## Reference

Pour les patterns de nettoyage detailles, voir:
`references/cleaning-rules.md`
