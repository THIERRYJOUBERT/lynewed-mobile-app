# Step 04: Checkpoint

> Purpose: Presenter la Mission synthetisee pour validation utilisateur avant generation.

---

## MANDATORY RULES

- 🎯 ALWAYS presenter un resume clair de la Mission
- 🎯 ALWAYS permettre a l'utilisateur de valider, ajuster ou annuler
- 📊 ALWAYS montrer les Epics proposes avec estimations
- 🚫 NEVER proceder a la generation sans approbation explicite

## PROTOCOLS

- 🎯 **Goal**: Obtenir validation utilisateur
- 💾 **Output**: `{user_decision}` (approve/adjust/cancel)
- ⚡ **Performance**: Interaction utilisateur

---

## CONTEXT

**Available from previous steps:**
- `{mission_document}` - Mission structuree (step-03)
- `{project_context}` - Contexte projet (step-00)

**Produced by this step:**
- `{user_decision}` - approve, adjust, ou cancel
- `{adjustments}` - Modifications demandees (si adjust)

---

## TASK

### 1. Generer le resume de presentation

Presenter clairement:

```markdown
# Mission: {mission_document.metadata.name}

## Resume Executif

{mission_document.executive_summary.objective}

**Scope**: {mission_document.executive_summary.scope}
**Timeline**: {mission_document.executive_summary.timeline}

---

## Epics Proposes ({count})

| # | Epic | Domaine | Points | Dependances |
|---|------|---------|--------|-------------|
| 1 | EPIC-XX-NAME | UI | 8 | Aucune |
| 2 | EPIC-YY-NAME | API | 5 | EPIC-XX |
| 3 | EPIC-ZZ-NAME | DATA | 3 | EPIC-YY |

**Total estime**: {total_points} points

---

## Plan d'Execution

### Phase 1: {name}
- EPIC-XX (prerequis)

### Phase 2: {name}
- EPIC-YY, EPIC-ZZ (en parallele possible)

---

## Risques Critiques ({count})

| Risque | Impact | Mitigation |
|--------|--------|------------|
| {description} | High | {mitigation} |

---

## Points a Clarifier ({count})

- {gap.question}
  → Proposition: {gap.proposed_default}

---

## Ce qui sera genere

- `docs/specs/MISSION-{name}.md`
- `docs/epics/EPIC-XX-NAME/` ({N} fichiers)
  - EPIC-XX-NAME.md
  - TRACKING.md
  - stories/ ({M} stories)
- Update `docs/epics/CROSS-EPIC.md`
```

### 2. Demander validation

```yaml
AskUserQuestion:
  question: "Cette structure de Mission te convient ?"
  header: "Validation Mission"
  options:
    - label: "Approuver et generer (Recommande)"
      description: "Creer MISSION.md + {N} Epics + Stories"
    - label: "Ajuster les Epics"
      description: "Modifier la structure avant generation"
    - label: "Clarifier les gaps d'abord"
      description: "Repondre aux questions en suspens"
    - label: "Annuler"
      description: "Arreter sans generer"
```

### 3. Gerer la reponse

**Si Approuver:**
```yaml
user_decision: "approve"
action: Proceed to step-05
```

**Si Ajuster:**
```yaml
follow_up:
  AskUserQuestion:
    question: "Quels ajustements ?"
    header: "Ajustements"
    options:
      - label: "Fusionner des Epics"
        description: "Combiner plusieurs Epics en un"
      - label: "Separer un Epic"
        description: "Decouper un Epic trop gros"
      - label: "Changer l'ordre"
        description: "Modifier le plan d'execution"
      - label: "Autre"
        description: "Expliquer l'ajustement souhaite"

action_after_adjust:
  - Apply adjustments to {mission_document}
  - Return to step-03 for re-synthesis
  - Max 3 adjustment cycles
```

**Si Clarifier gaps:**
```yaml
action:
  For each blocking gap:
    AskUserQuestion:
      question: "{gap.question}"
      header: "Clarification"
      options:
        - label: "Utiliser la proposition"
          description: "{gap.proposed_default}"
        - label: "Autre reponse"
          description: "Specifier une autre approche"

  After clarifications:
    - Update mission_document with answers
    - Return to checkpoint presentation
```

**Si Annuler:**
```yaml
user_decision: "cancel"
action:
  - Save draft to workspace/current/MISSION-{name}-draft.md
  - Report: "Mission sauvegardee en draft. Reprendre avec /mission {draft_path}"
  - STOP workflow
```

---

## OUTPUT

```yaml
step_output:
  user_decision: "approve" | "adjust" | "cancel"
  adjustments:  # Only if adjust
    type: "merge" | "split" | "reorder" | "custom"
    details: "..."
  clarifications:  # Only if gaps clarified
    gap_1: "user answer"
    gap_2: "user answer"
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] User has explicitly chosen an option
- [ ] If adjust: adjustments are actionable
- [ ] If clarify: all blocking gaps answered

**Self-Critique Questions:**
- Le resume etait-il clair?
- L'utilisateur a-t-il eu assez d'info pour decider?
- Les options proposees couvrent-elles tous les cas?

---

## SUCCESS / FAILURE

**Success:**
✅ User decision captured
✅ Ready for next action

**Failure modes:**
❌ User confused → Clarify and re-present
❌ Too many adjustment cycles → Suggest revising brief

---

## NEXT

Based on `{user_decision}`:
- **approve** → Load `steps/step-05-generate-mission.md`
- **adjust** → Return to `steps/step-03-synthesize.md` with adjustments
- **cancel** → STOP (draft saved)

<critical>
JAMAIS generer sans approbation explicite.
Le checkpoint est le dernier moment pour corriger avant creation des fichiers.
</critical>
