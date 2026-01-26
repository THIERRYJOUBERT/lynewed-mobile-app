# Step 02: Analyze

> Analyse profonde avec 3 agents Sonnet en parallele.

---

## CRITICAL

🚀 **LANCER LES 3 AGENTS DANS UN SEUL MESSAGE** (execution parallele obligatoire)

---

## Task

Analyser les findings du scan avec 3 agents Sonnet:
1. **OWASP Agent** - Mapper aux OWASP Top 10 + CWE
2. **Severity Agent** - Scorer et prioriser
3. **Remediation Agent** - Estimer effort et proposer fixes

---

## Context

Utiliser `{scan_results}` du step precedent.

---

## Execution

### Launch All 3 Agents (SINGLE MESSAGE)

---

### Agent 1: OWASP Mapping

```yaml
subagent_type: Explore
model: sonnet
description: "OWASP Top 10 mapping"
prompt: |
  Analyze these security findings and map to OWASP Top 10 + CWE.

  SCAN RESULTS:
  {scan_results}

  FOR EACH FINDING:
  1. Map to OWASP Top 10 category:
     - A01: Broken Access Control
     - A02: Cryptographic Failures
     - A03: Injection
     - A04: Insecure Design
     - A05: Security Misconfiguration
     - A06: Vulnerable Components
     - A07: Auth Failures
     - A08: Software/Data Integrity
     - A09: Logging Failures
     - A10: SSRF

  2. Map to CWE if applicable (e.g., CWE-79 for XSS)

  3. Assess exploitability:
     - EASY: Requires no special skills/tools
     - MEDIUM: Requires some knowledge
     - HARD: Requires advanced skills/access

  RETURN FORMAT:
  ```yaml
  mapped_findings:
    - original_finding: {reference to scan finding}
      owasp: "A03: Injection"
      cwe: "CWE-89: SQL Injection"
      exploitability: EASY|MEDIUM|HARD
      attack_vector: "Description of how this could be exploited"
      impact: "What damage could be done"
  ```
```

---

### Agent 2: Severity Scoring

```yaml
subagent_type: Explore
model: sonnet
description: "Severity scoring"
prompt: |
  Score and prioritize these security findings.

  SCAN RESULTS:
  {scan_results}

  SCORING CRITERIA (CVSS-like):

  1. Impact (1-10):
     - Confidentiality: Can attacker access sensitive data?
     - Integrity: Can attacker modify data?
     - Availability: Can attacker disrupt service?

  2. Exploitability (1-10):
     - Attack complexity: How hard to exploit?
     - Privileges required: Auth needed?
     - User interaction: Victim action needed?

  3. Final Score = (Impact + Exploitability) / 2

  SEVERITY MAPPING:
  - 9-10: CRITICAL (fix immediately)
  - 7-8.9: HIGH (fix within days)
  - 4-6.9: MEDIUM (fix within sprint)
  - 1-3.9: LOW (backlog)

  RETURN FORMAT:
  ```yaml
  scored_findings:
    - original_finding: {reference}
      impact_score: 8
      exploitability_score: 6
      final_score: 7.0
      severity: HIGH
      priority_rank: 1  # Sorted by score desc
      justification: "Why this score"
  ```
```

---

### Agent 3: Remediation Planning

```yaml
subagent_type: Explore
model: sonnet
description: "Remediation planning"
prompt: |
  Create remediation plan for these security findings.

  SCAN RESULTS:
  {scan_results}

  FOR EACH FINDING:
  1. Effort estimation (story points):
     - XS (1): Config change, one-liner
     - S (2): Single file fix, simple logic
     - M (3): Multiple files, moderate complexity
     - L (5): Significant refactor, multiple components
     - XL (8): Architecture change, high risk

  2. Remediation approach:
     - Specific code changes needed
     - Libraries/tools to use
     - Testing requirements

  3. Dependencies:
     - Other findings that should be fixed first
     - External dependencies (library updates, etc.)

  4. Risk of fix:
     - LOW: Safe change, low regression risk
     - MEDIUM: Some testing needed
     - HIGH: May break functionality

  RETURN FORMAT:
  ```yaml
  remediation_plan:
    - original_finding: {reference}
      effort: M (3 points)
      approach: |
        1. Replace raw SQL with parameterized query
        2. Use prepared statements
        3. Add input validation layer
      code_example: |
        // Before
        query = "SELECT * FROM users WHERE id = " + userId;
        // After
        query = "SELECT * FROM users WHERE id = ?";
        stmt.setString(1, userId);
      dependencies: ["Fix auth first (finding-3)"]
      fix_risk: LOW
      testing_needed: ["Unit tests for query", "Integration test for endpoint"]
  ```
```

---

## Consolidate Results

Merger les resultats des 3 agents:

```yaml
analysis_results:
  owasp_mapping: {agent_1_results}
  severity_scores: {agent_2_results}
  remediation_plans: {agent_3_results}

findings:  # Consolidated
  - id: "SEC-001"
    # From scan
    category: INJECTION
    file: "lib/services/user_service.dart"
    line: 45
    code: "query = 'SELECT...' + userId"

    # From OWASP agent
    owasp: "A03: Injection"
    cwe: "CWE-89"
    exploitability: EASY
    attack_vector: "Attacker can inject SQL via userId parameter"
    impact: "Full database access"

    # From Severity agent
    severity: CRITICAL
    score: 9.5
    priority: 1

    # From Remediation agent
    effort: S (2 points)
    approach: "Use parameterized queries"
    fix_risk: LOW
```

---

## Quick Mode

Si `mode == quick`:
- Skip OWASP mapping (Agent 1)
- Simplified severity (auto-assign based on category)
- Basic remediation (generic recommendations)

---

## Validation

✅ Tous les agents ont termine
✅ Findings consolides avec toutes les infos
✅ Priorites calculees
✅ Effort estime pour chaque finding

---

## Next

```
Load steps/step-03-synthesize.md
```
