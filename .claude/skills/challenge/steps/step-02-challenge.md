# Step 02: Multi-Dimensional Challenge

> Purpose: Apply rigorous critique across 6 dimensions, generate findings with severity.

---

## MANDATORY RULES

- 🎯 ALWAYS evaluate ALL 6 dimensions - no shortcuts
- 🚫 NEVER say "looks good" without specific evidence
- 🚫 NEVER rate 100% confidence without deep justification
- ✅ ALWAYS document at least ONE observation per dimension (finding OR explicit "verified clean with specific reason")
- ✅ ALWAYS assign severity (HIGH, MEDIUM, LOW) to each finding
- ⚠️ "Zero findings" on first pass = SUSPICIOUS, dig deeper

## PROTOCOLS

- 🎯 **Goal**: Comprehensive critique covering all angles
- 💾 **Output**: `{findings}` array with severity, `{dimensions_status}`
- 📖 **Reference**: Load `references/critique-checklist.md`
- ⚡ **Performance**: Sequential evaluation, thorough

---

## CONTEXT

**Available from step-01:**
- `{target}` - What we're challenging
- `{target_type}` - Classification
- `{target_content}` - Full content
- `{target_context}` - Related context
- `{deep_mode}` - Whether to use parallel subagents
- `{complexity}` - LOW, MEDIUM, or HIGH

**Produced by this step:**
- `{dimensions_status}` - Score per dimension
- `{findings}` - List of issues found
- `{iteration}` - Set to 1

---

## TASK

### Mode Selection

```
IF {deep_mode} == true:
    → Execute "Deep Mode: Parallel Subagents" (see below)
    → Merge agent findings into unified analysis

ELSE:
    → Execute standard sequential evaluation
    → Single-agent thorough analysis
```

---

## DEEP MODE: Parallel Subagents

When `{deep_mode}` is true, launch 3 Sonnet agents in a SINGLE message for parallel execution:

```markdown
Launch 3 agents in SINGLE message:

**Agent 1 - Devil's Advocate** (model: sonnet):
You are a devil's advocate whose job is to find every way this could fail.
Target: {target}
Type: {target_type}
Content: [provide target_content]

Analyze for:
- CORRECTNESS: Logic errors, edge cases, off-by-one, wrong assumptions
- ROBUSTNESS: What would break this? Missing error handling? Fragile dependencies?

Return a structured list of findings with:
- Dimension (Correctness or Robustness)
- Severity (HIGH/MEDIUM/LOW)
- Location (specific line or section)
- Issue description
- Impact
- Recommendation

**Agent 2 - Security Auditor** (model: sonnet):
You are a security auditor and consistency checker.
Target: {target}
Type: {target_type}
Content: [provide target_content]
Context: [provide target_context]

Analyze for:
- SECURITY: Vulnerabilities, data exposure, missing validation, OWASP issues
- COHERENCE: Does this fit the project patterns? Naming consistency? Architecture alignment?

Return structured findings (same format as Agent 1).

**Agent 3 - User Advocate** (model: sonnet):
You are a user advocate and efficiency expert.
Target: {target}
Type: {target_type}
Content: [provide target_content]

Analyze for:
- CLARITY: Would a new developer understand this? Ambiguous parts? Missing docs?
- EFFICIENCY: Over-engineering? Unnecessary complexity? Could be simpler?

Return structured findings (same format as Agent 1).
```

### Merge Agent Results

After all 3 agents return:
1. Collect all findings from all agents
2. Deduplicate similar findings (keep the most detailed)
3. Validate each finding (agents can have false positives)
4. Assign final severity based on orchestrator judgment
5. Calculate dimension scores

---

## STANDARD MODE: The 6 Dimensions

Evaluate each dimension using type-specific questions:

#### Dimension 1: CORRECTNESS

**For Code:**
- Does the logic produce correct results?
- Are all edge cases handled?
- Are there off-by-one errors?
- Is the algorithm appropriate?

**For Plan/Decision:**
- Is the proposed solution feasible?
- Are all steps necessary and sufficient?
- Are dependencies correctly ordered?

**For Epic/Story:**
- Are acceptance criteria complete and unambiguous?
- Do criteria cover all user needs?
- Are there missing scenarios?

**Scoring:**
- 95-100%: Provably correct, edge cases covered
- 80-94%: Minor gaps, mostly correct
- 60-79%: Some issues need fixing
- <60%: Major correctness problems

---

#### Dimension 2: SECURITY

**For Code:**
- Input validation present?
- SQL injection, XSS, command injection possible?
- Secrets hardcoded?
- Authentication/authorization correct?
- OWASP Top 10 checked?

**For Plan/Decision:**
- Sensitive data exposure risks?
- Access control considered?
- Audit trail planned?

**For Epic/Story:**
- Security requirements included?
- Threat model considered?
- Privacy implications addressed?

**Scoring:**
- 95-100%: No security concerns, defense in depth
- 80-94%: Minor concerns, acceptable risk
- 60-79%: Issues need addressing
- <60%: Critical security problems

---

#### Dimension 3: COHERENCE

**For Code:**
- Follows project patterns?
- Naming consistent with codebase?
- Architecture alignment?
- Dependencies appropriate?

**For Plan/Decision:**
- Aligns with project goals?
- Consistent with prior decisions?
- Fits team capabilities?

**For Epic/Story:**
- Aligns with PRD-MASTER?
- Consistent with other Epics?
- Follows project methodology?

**Scoring:**
- 95-100%: Perfect fit with ecosystem
- 80-94%: Minor inconsistencies
- 60-79%: Noticeable misalignment
- <60%: Contradicts existing patterns

---

#### Dimension 4: ROBUSTNESS

**For Code:**
- Error handling comprehensive?
- Failure modes documented?
- Graceful degradation?
- Recovery possible?

**For Plan/Decision:**
- Contingencies planned?
- Rollback possible?
- Failure scenarios addressed?

**For Epic/Story:**
- Edge cases in criteria?
- Error states specified?
- Dependencies noted?

**Scoring:**
- 95-100%: Handles all failures gracefully
- 80-94%: Main paths robust
- 60-79%: Some fragility
- <60%: Will break under stress

---

#### Dimension 5: CLARITY

**For Code:**
- Self-documenting?
- Complex parts explained?
- Naming intuitive?
- Flow easy to follow?

**For Plan/Decision:**
- Steps unambiguous?
- Rationale clear?
- No jargon without definition?

**For Epic/Story:**
- Criteria testable?
- Language precise?
- No ambiguous requirements?

**Scoring:**
- 95-100%: Crystal clear, anyone can understand
- 80-94%: Minor clarity improvements possible
- 60-79%: Some confusion likely
- <60%: Unclear or ambiguous

---

#### Dimension 6: EFFICIENCY

**For Code:**
- Performance acceptable?
- Unnecessary complexity?
- Over-engineering?
- Right tool for the job?

**For Plan/Decision:**
- Effort proportional to value?
- Simpler alternatives considered?
- Resources well-used?

**For Epic/Story:**
- Scope minimal viable?
- Features prioritized correctly?
- Unnecessary requirements?

**Scoring:**
- 95-100%: Optimal, no waste
- 80-94%: Minor improvements possible
- 60-79%: Some inefficiency
- <60%: Significant waste/complexity

---

### Finding Template

For each finding:

```markdown
### Finding F-{number}

**Dimension**: {dimension_name}
**Severity**: HIGH | MEDIUM | LOW
**Location**: {specific location in target}
**Issue**: {clear description of the problem}
**Impact**: {what could go wrong}
**Recommendation**: {how to fix}
**Confidence**: {how sure are you this is a real issue}
```

### Severity Definitions

| Severity | Criteria |
|----------|----------|
| HIGH | Could cause failure, security issue, or significant user impact |
| MEDIUM | Quality concern, maintenance issue, or minor user impact |
| LOW | Polish item, best practice, or theoretical concern |

---

## ANTI-COMPLACENCY CHECK

After evaluating all dimensions, verify:

```markdown
## Anti-Complacency Verification

□ Did I find at least ONE issue per dimension?
  IF NO: Re-examine that dimension with skeptic mindset

□ Is my confidence below 95% on at least one dimension?
  IF NO: I may be overlooking something

□ Did I challenge my own assumptions?
  IF NO: Play devil's advocate

□ Can I explain WHY each "no issue" case is actually fine?
  IF NO: I haven't proven the negative
```

---

## OUTPUT

```yaml
step_02_output:
  iteration: 1

  dimensions_status:
    correctness:
      score: XX
      justification: "{why this score}"
      key_finding: "{most important issue or 'verified clean'}"
    security:
      score: XX
      justification: "{why this score}"
      key_finding: "{most important issue or 'verified clean'}"
    coherence:
      score: XX
      justification: "{why this score}"
      key_finding: "{most important issue or 'verified clean'}"
    robustness:
      score: XX
      justification: "{why this score}"
      key_finding: "{most important issue or 'verified clean'}"
    clarity:
      score: XX
      justification: "{why this score}"
      key_finding: "{most important issue or 'verified clean'}"
    efficiency:
      score: XX
      justification: "{why this score}"
      key_finding: "{most important issue or 'verified clean'}"

  overall_confidence: XX  # Weighted average

  findings:
    - id: "F-1"
      dimension: "{dimension}"
      severity: "HIGH|MEDIUM|LOW"
      location: "{where}"
      issue: "{what}"
      impact: "{why it matters}"
      recommendation: "{how to fix}"

  anti_complacency_passed: true|false
```

---

## NEXT

Load `steps/step-03-iterate.md`

<critical>
Do NOT proceed without:
1. All 6 dimensions evaluated with scores
2. At least some findings documented
3. Anti-complacency check passed
4. Confidence scores justified

If "zero findings" on first pass, STOP and re-examine with attacker mindset.
</critical>
