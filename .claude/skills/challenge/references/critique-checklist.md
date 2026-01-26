# Critique Checklist Reference

> Quick reference for systematic critique across all target types.
> Use during Step-02 (Challenge) for thorough evaluation.

---

## Universal Questions (Apply to ALL types)

### The "5 Whys" Test

For any statement or decision:
1. Why is this the right choice?
2. Why is that reason valid?
3. Why do we trust that assumption?
4. Why would that assumption hold?
5. Why is there no better alternative?

If you can't answer all 5, the decision isn't fully justified.

### The "Inversion" Test

Ask the opposite:
- "Why would this FAIL?"
- "What would make this WRONG?"
- "Who would DISAGREE with this?"

Good solutions survive inversion testing.

### The "Simplicity" Test

- Can this be simpler while achieving the same goal?
- What would I remove if I had to cut 20%?
- Is any part here "just in case"?

---

## Type-Specific Checklists

### CODE Critique Checklist

#### Logic & Correctness
- [ ] All branches reachable and tested
- [ ] Edge cases: null, empty, max, min, negative
- [ ] Off-by-one errors checked
- [ ] Integer overflow considered
- [ ] Floating point precision issues
- [ ] Async race conditions
- [ ] State mutation tracked

#### Security
- [ ] Input validation present
- [ ] Output encoding correct
- [ ] SQL/NoSQL injection impossible
- [ ] XSS/script injection blocked
- [ ] Command injection prevented
- [ ] Path traversal blocked
- [ ] Secrets not hardcoded
- [ ] Authentication checked
- [ ] Authorization verified
- [ ] Rate limiting considered
- [ ] Logging doesn't expose secrets

#### Architecture
- [ ] Single responsibility respected
- [ ] Dependencies injected
- [ ] Interfaces used for contracts
- [ ] No circular dependencies
- [ ] Testable design
- [ ] Error handling consistent

#### Performance
- [ ] No N+1 queries
- [ ] Caching where appropriate
- [ ] No unnecessary allocations
- [ ] Complexity acceptable (O notation)
- [ ] No blocking operations in hot paths

---

### PLAN/DECISION Critique Checklist

#### Feasibility
- [ ] Resources available?
- [ ] Timeline realistic?
- [ ] Dependencies identified?
- [ ] Skills on team?
- [ ] Budget adequate?

#### Completeness
- [ ] All steps necessary?
- [ ] All steps sufficient?
- [ ] Order correct?
- [ ] Parallel opportunities identified?
- [ ] Milestones defined?

#### Risk
- [ ] What could go wrong?
- [ ] Mitigation for top risks?
- [ ] Rollback possible?
- [ ] Monitoring planned?
- [ ] Communication plan?

#### Alternatives
- [ ] Other approaches considered?
- [ ] Why this over alternatives?
- [ ] What would change the decision?
- [ ] Reversibility assessed?

---

### EPIC/STORY Critique Checklist

#### INVEST Criteria
- [ ] **I**ndependent: Minimal dependencies?
- [ ] **N**egotiable: Flexible implementation?
- [ ] **V**aluable: Clear user value?
- [ ] **E**stimable: Can be estimated?
- [ ] **S**mall: Fits in sprint?
- [ ] **T**estable: Clear acceptance?

#### Acceptance Criteria
- [ ] Gherkin format correct?
- [ ] All scenarios covered?
- [ ] Edge cases included?
- [ ] Error cases specified?
- [ ] Performance criteria if relevant?

#### Alignment
- [ ] Matches PRD requirements?
- [ ] Consistent with other Epics/Stories?
- [ ] Scope appropriate?
- [ ] No gold-plating?

#### Dependencies
- [ ] Prerequisites identified?
- [ ] Blockers known?
- [ ] Integration points defined?
- [ ] Data requirements clear?

---

### ARCHITECTURE Critique Checklist

#### Principles
- [ ] Separation of concerns?
- [ ] Single responsibility?
- [ ] Open/closed principle?
- [ ] Dependency inversion?
- [ ] Interface segregation?

#### Scalability
- [ ] Horizontal scaling possible?
- [ ] Bottlenecks identified?
- [ ] State management clear?
- [ ] Caching strategy?

#### Resilience
- [ ] Failure modes documented?
- [ ] Graceful degradation?
- [ ] Circuit breakers?
- [ ] Retry policies?
- [ ] Timeout handling?

#### Maintainability
- [ ] Components replaceable?
- [ ] Clear boundaries?
- [ ] Documentation adequate?
- [ ] Monitoring hooks?
- [ ] Testing strategy?

---

## Severity Assessment Guide

### HIGH Severity Indicators

- Could cause data loss
- Could expose sensitive information
- Could cause system crash
- Blocks core functionality
- Violates compliance requirements
- No workaround exists

### MEDIUM Severity Indicators

- Degrades user experience
- Affects non-critical path
- Workaround exists but inconvenient
- Technical debt accumulation
- Performance impact noticeable

### LOW Severity Indicators

- Cosmetic issues
- Code style violations
- Minor optimization opportunities
- "Nice to have" improvements
- Theoretical edge cases

---

## Red Flags (Immediate Attention)

### In Code
- `// TODO` or `// FIXME` without timeline
- Commented-out code
- Magic numbers without explanation
- Catch blocks that swallow errors
- Hardcoded credentials (ANY environment)
- `eval()` or equivalent
- Unparameterized queries

### In Plans
- "TBD" or "to be determined"
- Missing dates/owners
- Circular dependencies
- "Should be easy" assumptions
- No risk acknowledgment

### In Epics/Stories
- "And" in story titles (multiple stories)
- Vague acceptance criteria
- No definition of done
- Technical tasks without user value
- Scope larger than 2 weeks

---

## Questions to Prove the Negative

When something "looks fine," actively seek issues:

1. **What's the unhappy path?**
   - What if the network fails?
   - What if the database is slow?
   - What if the user does something unexpected?

2. **What's the attack surface?**
   - What inputs are user-controlled?
   - What could be forged?
   - What could be replayed?

3. **What changes would break this?**
   - If requirements change slightly?
   - If data volume grows 10x?
   - If another team depends on this?

4. **What's the maintenance burden?**
   - Who will understand this in 6 months?
   - What documentation is needed?
   - What monitoring is required?

---

## Quick Confidence Calibration

| Situation | Likely Real Confidence |
|-----------|------------------------|
| "Looks perfect to me" | 70% (overconfident) |
| "Found 3 issues, all minor" | 85% (reasonable) |
| "Found issues and fixed them" | 90% (good process) |
| "Found issues, can't fix all" | 75% (honest) |
| "No issues after deep dive" | 95% (thorough) |

---

## Usage

1. Select checklist based on `{target_type}`
2. Go through each item systematically
3. For each ❌, create a finding
4. For each ✅, briefly note why it passes
5. Use severity guide for each finding
6. Apply red flag detection
7. Use negative-proving questions for suspicious areas
