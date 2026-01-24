# Step 02: Propose Story Decomposition

> Purpose: Propose INVEST stories with user validation checkpoint.

---

## MANDATORY RULES (READ FIRST)

- 📝 PROPOSE stories, never create without approval
- ✅ EVERY story must pass INVEST criteria
- 📊 ESTIMATE points using Fibonacci scale (1,2,3,5,8)
- 🚫 REJECT stories 13+ points - must subdivide
- 🔄 CHECKPOINT with user before proceeding

## PROTOCOLS

- 🎯 **Goal**: Validated story list approved by user
- 💾 **Output**: `{approved_stories}` ready for generation
- 📖 **Reference**: INVEST criteria table below
- ⚡ **Performance**: User validation prevents wasted generation

---

## CONTEXT

**Available from previous steps:**
- `{epic_id}` - Epic identifier (from step-00)
- `{epic_content}` - Parsed Epic (from step-01)
- `{features_to_decompose}` - Features needing stories (from step-01)

**Produced by this step:**
- `{proposed_stories}` - Initial story proposals
- `{approved_stories}` - User-validated stories
- `{file_conflicts}` - Detected file conflicts

**NOT available (do not use):**
- `{stories_created}` - Created in step-03

---

## INVEST CRITERIA REFERENCE

Each story MUST pass ALL criteria:

| Criteria | Question | Pass if... |
|----------|----------|------------|
| **I**ndependent | Can it be developed alone? | No dependencies on other stories in same Epic |
| **N**egotiable | Can details be refined? | Scope allows implementation choices |
| **V**aluable | Does it deliver value? | User or technical value is clear |
| **E**stimable | Can we estimate effort? | Clear enough to assign points |
| **S**mall | Is it achievable quickly? | 1-8 points (not 13+) |
| **T**estable | Can we write tests? | Gherkin criteria are specific |

## STORY POINTS SCALE

| Points | Complexity | Typical Duration |
|--------|------------|------------------|
| 1 | Trivial | < 30 min |
| 2 | Simple | 30 min - 2h |
| 3 | Small | 1-2h |
| 5 | Medium | 2-4h |
| 8 | Large | 4-8h |
| 13+ | **TOO BIG** | Must subdivide |

---

## TASK

Create story proposals and get user validation.

---

## EXECUTION

### 1. Generate Story Proposals

For each feature needing a story:

```yaml
proposed_stories:
  - id: "STORY-{epic_number}-01"
    title: "..."
    persona: "..."
    action: "..."
    benefit: "..."
    points: X
    invest_check:
      independent: true/false
      negotiable: true/false
      valuable: true/false
      estimable: true/false
      small: true/false
      testable: true/false
    acceptance_criteria:
      - title: "AC-1: ..."
        gherkin: |
          Scenario: ...
            Given ...
            When ...
            Then ...
    files_to_modify:
      - path: "lib/..."
        action: "CREATE|MODIFY"
    files_to_test:
      - path: "test/..."
```

### 2. Validate INVEST for Each Story

For each proposed story:

```
IF story.points >= 13:
    REJECT → Propose subdivision into smaller stories

FOR each invest_criterion:
    IF not passing:
        Document why
        Propose adjustment
```

### 3. Detect File Conflicts

Check if multiple stories modify same files:

```yaml
file_conflicts:
  - file: "lib/services/auth.dart"
    stories: ["STORY-01-01", "STORY-01-02"]
    resolution: "STORY-01-02 depends on STORY-01-01"

  - file: "lib/widgets/button.dart"
    stories: ["STORY-01-03", "STORY-01-04"]
    resolution: "Different sections - parallel OK"
```

### 4. CHECKPOINT: User Validation

**CRITICAL**: This is the mandatory user checkpoint.

Use AskUserQuestion to present and validate:

```
AskUserQuestion:
  question: "Voici les stories proposees pour {epic_id}. Validez-vous cette decomposition?"
  header: "Stories"
  options:
    - label: "Approuver"
      description: "Creer les {N} stories telles que proposees"
    - label: "Modifier"
      description: "J'ai des ajustements a faire"
    - label: "Annuler"
      description: "Arreter et ne pas creer de stories"
```

**Before asking, present summary:**

```markdown
## Stories Proposees pour {epic_id}

| ID | Titre | Points | INVEST |
|----|-------|--------|--------|
| STORY-XX-01 | ... | 3 | ✅ |
| STORY-XX-02 | ... | 5 | ✅ |
| STORY-XX-03 | ... | 8 | ✅ |

**Total**: X points

**Conflits detectes**:
- [Liste des conflits et resolutions]

**Ordre suggere**:
1. STORY-XX-01 (pas de dependances)
2. STORY-XX-02 (depend de 01)
3. STORY-XX-03 (peut etre parallele a 02)
```

### 5. Handle User Response

**If Approved:**
```yaml
approved_stories: {proposed_stories}
```

**If Modify:**
```
AskUserQuestion:
  question: "Quels ajustements souhaitez-vous?"
  header: "Ajustements"
  options:
    - "Fusionner stories"
    - "Diviser story"
    - "Changer points"
    - "Modifier scope"
```
Then iterate with adjustments.

**If Cancel:**
```
STOP workflow - inform user no stories created
```

---

## AUTO-VALIDATION

**Before proceeding, validate:**
✅ All proposed stories pass INVEST criteria
✅ No story exceeds 8 points
✅ File conflicts identified and resolved
✅ User has approved the decomposition
✅ `{approved_stories}` is populated

**Self-Critique Questions:**
- Are the stories truly independent, or forced dependencies exist?
- Are point estimates realistic based on project history?
- Did I present conflicts clearly to the user?
- Would a developer understand what to implement from each story?

**If validation fails:**
1. Review failing INVEST criteria
2. Propose story adjustments
3. Re-submit for user approval
4. Max 3 iterations before escalating

---

## SUCCESS / FAILURE

**Success:**
✅ All stories pass INVEST
✅ User approved decomposition
✅ `{approved_stories}` ready for generation
✅ Conflicts documented with resolutions

**Failure modes:**
❌ User rejects all proposals → Ask for guidance, restart
❌ Cannot make stories small enough → Propose Epic subdivision
❌ INVEST criteria repeatedly fail → Document why, ask user
❌ Too many conflicts → Suggest sequential development

## NEXT

After validation passes, load `steps/step-03-generate.md`

<critical>
NEVER proceed without user approval.
This is the ONLY checkpoint in the workflow.
User validation is MANDATORY before generating files.
</critical>
