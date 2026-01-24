# Step 03: Generate

> Purpose: Creer et mettre a jour les fichiers de documentation selon le plan.

---

## MANDATORY RULES (READ FIRST)

- 📝 ALWAYS utiliser les templates pour chaque type de documentation
- 🎯 ALWAYS dater et sourcer chaque entree
- 📊 ALWAYS format dense et exploitable (pas de fluff)
- 🔄 ALWAYS merge intelligent pour updates (pas d'ecrasement)

## PROTOCOLS

- 🎯 **Goal**: Generer documentation de qualite
- 💾 **Output**: {files_created}, {files_updated}
- 📖 **Reference**: templates/session-workspace.md, templates/detailed-doc.md
- ⚡ **Performance**: Traiter items par priorite (high first)

---

## CONTEXT

**Available from previous steps:**
- `{mode}` - interactive ou auto (from step-00)
- `{documentation_plan}` - Plan de documentation (from step-02)
- `{conversation_insights}` - Source de contenu (from step-01)
- `{git_changes}` - Source de contenu (from step-01)

**Produced by this step:**
- `{files_created}` - Liste des fichiers crees
- `{files_updated}` - Liste des fichiers mis a jour

**NOT available (do not use):**
- `{validation_status}` - Pas encore cree (step-04)

---

## TASK

Pour chaque item dans {documentation_plan}:
1. Determiner le type de template
2. Collecter le contenu des sources
3. Formater selon template
4. Ecrire ou merger le fichier

---

## EXECUTION

### 1. Processing par Priorite

Traiter les items dans l'ordre:
1. `high` priority first
2. `medium` priority
3. `low` priority

### 2. Selection Template

| content_type | Template |
|--------------|----------|
| session | templates/session-workspace.md |
| detailed | templates/detailed-doc.md |
| epic-update | templates/epic-update.md |

### 3. Generation de Contenu

**Pour chaque item:**

```python
SI action = "create":
    1. Charger template
    2. Remplir avec contenu des sources
    3. Write fichier

SI action = "update":
    1. Read fichier existant
    2. Identifier section a mettre a jour
    3. Merger nouveau contenu
    4. Edit fichier

SI action = "append":
    1. Read fichier existant
    2. Ajouter nouvelle section a la fin
    3. Edit fichier
```

### 4. Format de Documentation

**Regles de format (CRITIQUE):**

1. **Dense**: Pas de phrases vides, pas de fluff
2. **Date**: Timestamp sur chaque entree
3. **Source**: Reference a conversation/commit/fichier
4. **Structure**: Sections claires, parsables
5. **Exploitable**: Claude doit pouvoir utiliser cette doc

**Exemple de format dense:**

```markdown
## 2026-01-24 - Feature Auth Implementation

**Source**: Conversation + commits abc123, def456

### Decisions
- JWT over sessions (raison: stateless, scalable)
- Refresh tokens avec 7j expiry

### Implementation
- `lib/features/auth/` cree
- Provider: `auth_provider.dart`
- Service: `auth_service.dart`

### Problems Solved
- Token refresh race condition → mutex pattern

### Next Steps
- [ ] Tests integration
- [ ] Error handling UI
```

### 5. Gestion des Erreurs

**Si Write echoue:**
1. Logger l'erreur
2. Continuer avec les autres items
3. Reporter dans {files_created} avec status "failed"

**Si Read echoue (pour update):**
1. Convertir en "create" avec warning
2. Documenter que fichier original introuvable

---

## OUTPUT TRACKING

```yaml
files_created:
  - path: "workspace/current/2026-01-24-session.md"
    status: "success|failed"
    lines: N
    topics: ["topic1", "topic2"]

files_updated:
  - path: "docs/epics/EPIC-01/TRACKING.md"
    status: "success|failed"
    action: "update|append"
    sections_modified: ["Section A"]

generation_summary:
  total_planned: N
  successful: N
  failed: N
  total_lines_written: N
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Tous les items du plan traites
✅ Format dense et date pour chaque fichier
✅ Sources referees dans chaque fichier
✅ Pas de placeholders (TBD, TODO non intentionnels)

**Self-Critique Questions:**
- La documentation est-elle vraiment dense?
- Chaque entree a-t-elle sa source?
- Claude pourrait-il utiliser cette doc?
- Ai-je evite le fluff?

**If validation fails:**
1. Identifier fichiers problematiques
2. Re-generer avec format corrige
3. Max 2 tentatives de correction

---

## SUCCESS / FAILURE

**Success:**
✅ Tous les fichiers prevus crees/mis a jour
✅ Format respecte (dense, date, source)
✅ Pret pour validation APEX

**Failure modes:**
❌ Write echoue → Logger et continuer
❌ Template manquant → Utiliser format inline
❌ Contenu vide → Skip item avec warning

## NEXT

After validation passes, load `steps/step-04-validate.md`

<critical>
Documentation DENSE = valeur.
Documentation VERBOSE = bruit.
Chaque ligne doit apporter de l'information.
</critical>
