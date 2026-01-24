# Step 00: Detect

> Purpose: Detecter le mode d'invocation, parser les arguments, initialiser les variables.

---

## MANDATORY RULES (READ FIRST)

- 🎯 ALWAYS parser les arguments correctement (--auto, --scope, --archive)
- 🚫 NEVER poser de questions si --auto est present
- ✅ ALWAYS initialiser toutes les variables d'etat
- ⚠️ ALWAYS appliquer les defauts si arguments manquants

## PROTOCOLS

- 🎯 **Goal**: Detecter mode et initialiser workflow
- 💾 **Output**: {mode}, {scope}, {archive_after}
- 📖 **Reference**: None
- ⚡ **Performance**: Etape rapide, pas d'exploration

---

## CONTEXT

**Available from previous steps:**
- Arguments passes par l'utilisateur ou le workflow appelant

**Produced by this step:**
- `{mode}` - interactive ou auto
- `{scope}` - workspace, detailed, epics, ou all
- `{archive_after}` - boolean

**NOT available (do not use):**
- `{conversation_insights}` - Pas encore cree (step-01)
- `{git_changes}` - Pas encore cree (step-01)
- `{documentation_plan}` - Pas encore cree (step-02)

---

## TASK

1. Parser les arguments fournis
2. Detecter le mode d'invocation
3. Initialiser les variables d'etat
4. Afficher overview si mode interactif

---

## EXECUTION

### 1. Parser les Arguments

**Arguments possibles:**
- `--auto` : Mode autonome (pas de questions)
- `--scope=VALUE` : Limiter scope (workspace|detailed|epics|all)
- `--archive` : Archiver workspace/current apres

**Regles de parsing:**
```
SI "--auto" present:
    {mode} = "auto"
SINON:
    {mode} = "interactive"

SI "--scope=" present:
    {scope} = valeur extraite (valider: workspace|detailed|epics|all)
SINON:
    {scope} = "all"

SI "--archive" present:
    {archive_after} = true
SINON:
    {archive_after} = false
```

### 2. Valider les Valeurs

**Scope valide:**
- `workspace` : Uniquement workspace/current et workspace/archive
- `detailed` : Uniquement docs/detailed/
- `epics` : Uniquement docs/epics/
- `all` : Tous les emplacements (defaut)

**Si scope invalide:** Utiliser "all" avec warning.

### 3. Afficher Overview (Interactive Only)

**Si mode = interactive:**

```markdown
## /documentation - Overview

**Mode**: Interactive
**Scope**: {scope}
**Archive apres**: {archive_after ? "Oui" : "Non"}

Je vais analyser:
- La conversation pour extraire decisions et travaux
- Les changements git pour identifier fichiers modifies
- La documentation existante pour eviter duplication

Puis je genererai de la documentation dense, datee et sourcee.
```

**Si mode = auto:** Ne rien afficher, continuer directement.

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ `{mode}` est "interactive" ou "auto"
✅ `{scope}` est une valeur valide
✅ `{archive_after}` est un boolean

**Self-Critique Questions:**
- Ai-je correctement parse tous les arguments?
- Le mode est-il coherent avec les attentes?
- Les defauts sont-ils appliques correctement?

**If validation fails:**
1. Appliquer les valeurs par defaut
2. Logger warning si argument invalide
3. Continuer avec configuration valide

---

## SUCCESS / FAILURE

**Success:**
✅ Variables {mode}, {scope}, {archive_after} initialisees
✅ Mode detecte correctement
✅ Overview affiche si interactif

**Failure modes:**
❌ Arguments malformes → Appliquer defauts avec warning
❌ Scope invalide → Utiliser "all"

## NEXT

After validation passes, load `steps/step-01-analyze.md`

<critical>
En mode --auto, NE JAMAIS poser de questions.
C'est critique pour l'integration avec d'autres workflows.
</critical>
