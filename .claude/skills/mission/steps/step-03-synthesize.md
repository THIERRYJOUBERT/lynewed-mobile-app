# Step 03: Synthesize (Tier 3 - Opus)

> Purpose: Synthetiser toutes les analyses en MISSION.md structure avec Epics proposes.

---

## MANDATORY RULES

- 🎯 ALWAYS consolider TOUTES les analyses des tiers precedents
- 📊 ALWAYS produire une structure MISSION.md complete
- ✅ ALWAYS proposer ordre d'execution avec justification
- 🚫 NEVER generer les fichiers ici (step-05+)

## PROTOCOLS

- 🎯 **Goal**: Produire le document de mission structure
- 💾 **Output**: `{mission_document}` pret pour checkpoint
- ⚡ **Performance**: Opus (high quality synthesis)

---

## CONTEXT

**Available from previous steps:**
- `{brief_content}` - Brief original (step-00)
- `{project_context}` - Contexte projet (step-00)
- `{scan_results}` - Resultats scan Haiku (step-01)
- `{analysis_results}` - Analyse profonde Sonnet (step-02)

**Produced by this step:**
- `{mission_document}` - Document de mission structure

---

## TASK

### 1. Consolider les informations

Merger toutes les sources en une vue coherente:

```yaml
consolidation:
  sources:
    - brief_content: Source primaire des requirements
    - scan_results: Extraction structuree
    - analysis_results: Analyse profonde + groupement

  conflicts_to_resolve:
    - Si scan et analysis different sur scope
    - Si estimates different
    - Si risks contradictoires
```

### 2. Structurer la Mission

```yaml
mission_document:
  # Metadata
  metadata:
    name: "MISSION-{sanitized_name}"
    created: "{current_date}"
    source_brief: "{brief_path}"
    status: "Draft"

  # Executive Summary
  executive_summary:
    objective: "1-2 sentences describing the mission"
    scope: "What's included and excluded"
    timeline: "If mentioned in brief"
    success_criteria: "How we know we're done"

  # Scope Details
  scope:
    in_scope:
      - "Feature/requirement 1"
      - "Feature/requirement 2"
    out_of_scope:
      - "Explicitly excluded items"
    assumptions:
      - "What we assume is true"
    constraints:
      - "Limitations on implementation"

  # Epic Proposals
  epics:
    - id: "EPIC-{next_id}"
      name: "EPIC-{next_id}-FEATURE-NAME"
      objective: "What this Epic achieves"
      scope:
        - "Requirement A"
        - "Requirement B"
      domain: "INFRA" | "DATA" | "UI" | "API"
      estimated_size: "S" | "M" | "L"
      estimated_points: 1-8
      dependencies:
        blocks: []
        blocked_by: []
      risks:
        - description: "..."
          mitigation: "..."
      source_requirements: ["REQ-1", "REQ-2"]

  # Execution Plan
  execution_plan:
    phases:
      - phase: 1
        name: "Foundation"
        epics: ["EPIC-XX"]
        rationale: "Why first"
      - phase: 2
        name: "Core Features"
        epics: ["EPIC-YY", "EPIC-ZZ"]
        rationale: "After foundation"

    critical_path:
      - "EPIC-XX → EPIC-YY → EPIC-ZZ"

    parallel_opportunities:
      - epics: ["EPIC-AA", "EPIC-BB"]
        reason: "No dependencies between them"

  # Dependencies
  dependencies:
    internal:
      - from: "EPIC-XX"
        to: "EPIC-YY"
        type: "blocks"
        reason: "..."
    external:
      - system: "External API"
        impact: "..."
        mitigation: "..."

  # Risks
  risks:
    high:
      - description: "..."
        likelihood: "high"
        impact: "high"
        mitigation: "..."
    medium: [...]
    low: [...]

  # Gaps and Clarifications Needed
  gaps:
    - question: "Unclear requirement about..."
      context: "..."
      proposed_default: "..."
      blocking: true | false

  # Technical Considerations
  technical:
    architecture_changes: [...]
    new_dependencies: [...]
    breaking_changes: [...]
    performance_considerations: [...]

  # Success Metrics
  metrics:
    - name: "Metric name"
      target: "Target value"
      measurement: "How to measure"
```

### 3. Valider la coherence

```yaml
coherence_checks:
  - All requirements from brief are covered by an Epic
  - No orphan Epics (all have requirements)
  - Dependencies form a DAG (no cycles)
  - Phases respect dependencies
  - Estimates are realistic (no Epic > 8 points total)
  - Gaps are documented, not hidden
```

### 4. Preparer pour checkpoint

```yaml
checkpoint_preview:
  summary:
    total_epics: {count}
    estimated_total_points: {sum}
    critical_risks: {count of high risks}
    gaps_requiring_input: {count of blocking gaps}

  decision_points:
    - "Approve the Epic structure"
    - "Adjust specific Epics"
    - "Cancel and revise brief"
```

---

## OUTPUT

```yaml
mission_document:
  metadata: {...}
  executive_summary: {...}
  scope: {...}
  epics: [...]
  execution_plan: {...}
  dependencies: {...}
  risks: {...}
  gaps: [...]
  technical: {...}
  metrics: [...]

checkpoint_data:
  summary:
    total_epics: 5
    estimated_total_points: 34
    critical_risks: 2
    gaps_requiring_input: 1
  preview_text: |
    # Mission Summary
    ...
```

---

## AUTO-VALIDATION

**Before proceeding, verify:**
- [ ] All brief requirements mapped to Epics
- [ ] Dependencies are acyclic
- [ ] Execution plan respects dependencies
- [ ] Gaps documented with proposed defaults
- [ ] Risks have mitigations

**Self-Critique Questions:**
- Ai-je oublie des requirements du brief?
- Les Epics sont-ils de taille raisonnable (S/M/L)?
- L'ordre d'execution est-il logique?
- Les risques sont-ils realistes?

**If validation fails:**
1. Re-analyze specific gaps
2. Adjust Epic structure
3. Max 3 iterations

---

## SUCCESS / FAILURE

**Success:**
✅ Mission document complete
✅ All requirements covered
✅ Ready for checkpoint

**Failure modes:**
❌ Requirements orphans → Regroup
❌ Cyclic dependencies → Break cycle
❌ Too many gaps → Request brief clarification

---

## NEXT

When validation passes, load `steps/step-04-checkpoint.md`

<critical>
NE PAS generer de fichiers ici.
Ce step produit UNIQUEMENT la structure en memoire.
La generation se fait apres checkpoint utilisateur.
</critical>
