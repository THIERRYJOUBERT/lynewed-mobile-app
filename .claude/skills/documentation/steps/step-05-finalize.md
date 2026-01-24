# Step 05: Finalize

> Purpose: Archiver si demande, invoquer sync, generer rapport final.

---

## MANDATORY RULES (READ FIRST)

- 📦 ALWAYS archiver workspace/current si --archive
- 🔄 ALWAYS invoquer /sync-project si documentation affecte references
- 📊 ALWAYS generer rapport clair et concis
- ✅ ALWAYS confirmer completion au user (sauf mode auto)

## PROTOCOLS

- 🎯 **Goal**: Finaliser workflow proprement
- 💾 **Output**: {report}
- 📖 **Reference**: None
- ⚡ **Performance**: Etape rapide de cleanup

---

## CONTEXT

**Available from previous steps:**
- `{mode}` - interactive ou auto (from step-00)
- `{archive_after}` - boolean (from step-00)
- `{files_created}` - Fichiers crees (from step-03)
- `{files_updated}` - Fichiers mis a jour (from step-03)
- `{validation_status}` - PASS ou autre (from step-04)

**Produced by this step:**
- `{report}` - Rapport final du workflow

**NOT available (do not use):**
- Tous les outputs precedents sont disponibles

---

## TASK

1. Archiver workspace/current si --archive
2. Determiner si /sync-project necessaire
3. Invoquer /sync-project si pertinent
4. Generer rapport final
5. Afficher rapport (sauf mode auto)

---

## EXECUTION

### 1. Archive (si --archive)

**Si {archive_after} = true:**

```bash
# Determiner nom d'archive
archive_name = "YYYY-MM-DD-{topic-slug}"

# Creer dossier archive
mkdir -p workspace/archive/{archive_name}

# Deplacer contenu de current
mv workspace/current/* workspace/archive/{archive_name}/

# Optionnel: creer README dans archive
echo "# Archive: {topic}" > workspace/archive/{archive_name}/README.md
```

**Topic slug:**
- Extraire du contenu documente
- Max 30 caracteres
- kebab-case

### 2. Determiner Besoin Sync

**Invoquer /sync-project SI:**
- Documentation creee dans docs/epics/ (affecte TRACKING, CROSS-EPIC)
- Documentation creee dans docs/detailed/ (affecte INDEX)
- Nouveaux fichiers de reference crees

**NE PAS invoquer SI:**
- Uniquement workspace/current modifie
- Aucun fichier de reference affecte

### 3. Invoquer Sync (si necessaire)

**Si sync necessaire:**

```
Invoke Skill: /sync-project --silent
```

Note: --silent car le workflow gere son propre output.

### 4. Generer Rapport

**Structure du rapport:**

```markdown
## Documentation Complete

**Status**: {validation_status}
**Date**: {timestamp}

### Fichiers Crees ({N})
| Path | Topics | Lines |
|------|--------|-------|
| {path} | {topics} | {N} |

### Fichiers Mis a Jour ({N})
| Path | Action | Sections |
|------|--------|----------|
| {path} | {update/append} | {sections} |

### Archive
{si archive_after: "workspace/current → workspace/archive/{name}"}
{sinon: "Non demande"}

### Sync
{si sync invoque: "/sync-project execute"}
{sinon: "Non necessaire"}

### Qualite
- Validation: {status}
- Issues resolues: {N}
- Warnings: {list ou "Aucun"}
```

### 5. Afficher Rapport

**Si mode = interactive:**
- Afficher rapport complet
- Confirmer completion

**Si mode = auto:**
- Ne rien afficher
- Workflow termine silencieusement

---

## AUTO-VALIDATION

**Before completing, validate:**
✅ Archive effectuee si demande
✅ Sync invoque si necessaire
✅ Rapport genere
✅ Tous les fichiers accessibles

**Self-Critique Questions:**
- L'archive est-elle complete?
- Ai-je oublie d'invoquer sync?
- Le rapport est-il clair?

**If validation fails:**
1. Retenter operation echouee
2. Si archive echoue → continuer sans
3. Si sync echoue → warning dans rapport

---

## OUTPUT STRUCTURE

```yaml
report:
  status: "complete|partial"
  timestamp: "YYYY-MM-DD HH:MM"

  documentation:
    created: N
    updated: N
    total_lines: N
    locations:
      workspace: N
      detailed: N
      epics: N

  archive:
    performed: true|false
    destination: "workspace/archive/{name}" ou null

  sync:
    invoked: true|false
    reason: "Pourquoi" ou "Non necessaire"

  quality:
    validation_status: "PASS|PASS_WITH_WARNINGS"
    issues_resolved: N
    warnings: []

  summary: "Documentation {N} fichiers, {N} lignes. {Archive status}. {Sync status}."
```

---

## SUCCESS / FAILURE

**Success:**
✅ Workflow complete
✅ Documentation generee et validee
✅ Archive effectuee si demande
✅ Sync invoque si pertinent
✅ Rapport genere

**Failure modes:**
❌ Archive echoue → Warning mais pas bloquant
❌ Sync echoue → Warning mais pas bloquant
❌ Rapport vide → Generer rapport minimal

## WORKFLOW COMPLETE

Le workflow /documentation est termine.

<critical>
Ce workflow peut etre appele en mode --auto par d'autres workflows.
Il doit toujours terminer proprement, meme si certaines etapes echouent.
Jamais de blocage silencieux.
</critical>
