# Step 02: Categorize

> Purpose: Determiner intelligemment quoi documenter et ou, basé sur l'analyse.

---

## MANDATORY RULES (READ FIRST)

- 🎯 ALWAYS categoriser selon le type de contenu, pas juste la source
- 🚫 NEVER documenter deux fois la meme chose (verifier existing_docs)
- ✅ ALWAYS prioriser par significance (high > medium > low)
- 📊 ALWAYS afficher le plan si mode interactif

## PROTOCOLS

- 🎯 **Goal**: Generer un plan de documentation intelligent
- 💾 **Output**: {documentation_plan}
- 📖 **Reference**: references/categorization-rules.md
- ⚡ **Performance**: Decision rapide basee sur regles

---

## CONTEXT

**Available from previous steps:**
- `{mode}` - interactive ou auto (from step-00)
- `{scope}` - workspace, detailed, epics, ou all (from step-00)
- `{conversation_insights}` - Decisions, problemes, implementations (from step-01)
- `{git_changes}` - Fichiers modifies (from step-01)
- `{existing_docs}` - Documentation existante (from step-01)

**Produced by this step:**
- `{documentation_plan}` - Array de cibles de documentation

**NOT available (do not use):**
- `{files_created}` - Pas encore cree (step-03)
- `{validation_status}` - Pas encore cree (step-04)

---

## TASK

1. Analyser les candidats de documentation
2. Appliquer les regles de categorisation
3. Eliminer les duplications
4. Prioriser par significance
5. Generer le plan final

---

## EXECUTION

### 1. Regles de Categorisation

**Mapping Type → Destination:**

| Type de Contenu | Destination | Quand |
|-----------------|-------------|-------|
| Session de travail | workspace/current/ | Conversation longue avec multiples taches |
| Decisions temporaires | workspace/current/ | Choix non finalises, exploratoire |
| Brainstorming | workspace/current/ | Idees, options, comparaisons |
| Specs techniques | docs/detailed/ | Architecture, data models, API design |
| Wireframes, UI | docs/detailed/ui-ux/ | Design decisions finales |
| Story progress | docs/epics/EPIC-XX/ | Implementation de story |
| Epic decisions | docs/epics/EPIC-XX/ | Decisions au niveau Epic |

**Regles de priorite:**
- `high`: Decisions architecturales, problemes critiques resolus
- `medium`: Implementations significatives, choix techniques
- `low`: Minor details, preferences, notes

### 2. Filtrer par Scope

**Si scope ≠ "all":**

```
SI scope = "workspace":
    Garder uniquement: workspace destinations
SI scope = "detailed":
    Garder uniquement: docs/detailed/ destinations
SI scope = "epics":
    Garder uniquement: docs/epics/ destinations
```

### 3. Eliminer Duplications

Pour chaque candidat:
1. Verifier dans {existing_docs} si deja documente
2. Si oui et contenu similaire → SKIP
3. Si oui mais contenu different → UPDATE (pas create)

### 4. Generer Plan

**Structure du plan:**

```yaml
documentation_plan:
  - id: "DOC-001"
    action: "create|update|append"
    target_path: "workspace/current/2026-01-24-session.md"
    content_type: "session"
    topics:
      - "Decision A"
      - "Problem B solved"
    sources:
      - type: "conversation"
        summary: "Discussion about X"
      - type: "git"
        commits: ["abc123"]
    priority: "high|medium|low"
    estimated_lines: N

summary:
  total_items: N
  creates: N
  updates: N
  skipped: N (duplications)
  locations:
    workspace: N
    detailed: N
    epics: N
```

### 5. Afficher Plan (Interactive Only)

**Si mode = interactive:**

```markdown
## Plan de Documentation

**Items a documenter**: {total_items}
**Creations**: {creates} | **Mises a jour**: {updates}

### Par location:
- workspace/: {N} items
- docs/detailed/: {N} items
- docs/epics/: {N} items

### Details:

| # | Action | Path | Topics | Priority |
|---|--------|------|--------|----------|
| 1 | create | workspace/current/... | Decision A, Problem B | high |
| 2 | update | docs/epics/EPIC-01/... | Story progress | medium |

Voulez-vous proceder ou ajuster?
```

**Si mode = auto:** Ne rien afficher, continuer directement.

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ Plan genere (meme si vide)
✅ Pas de duplications dans le plan
✅ Toutes les cibles sont dans le scope
✅ Priorites attribuees

**Self-Critique Questions:**
- Le plan couvre-t-il tout le travail significatif?
- Les destinations sont-elles appropriees?
- Ai-je evite les duplications?
- Le plan est-il realiste en taille?

**If validation fails:**
1. Verifier regles de categorisation
2. Ajuster mappings si incoherent
3. Si plan vide mais travail evident → forcer creation minimale

---

## SUCCESS / FAILURE

**Success:**
✅ {documentation_plan} genere avec au moins 0 items (vide = rien a documenter)
✅ Plan coherent avec scope
✅ Pas de duplications

**Failure modes:**
❌ Aucune donnee d'entree → Plan vide, workflow termine proprement
❌ Toutes duplications → Plan vide avec rapport "deja documente"
❌ Conflict de categorisation → Utiliser destination par defaut

## NEXT

After validation passes, load `steps/step-03-generate.md`

<critical>
Si le plan est vide (rien a documenter), c'est un succes, pas un echec.
Ne pas forcer de la documentation inutile.
</critical>
