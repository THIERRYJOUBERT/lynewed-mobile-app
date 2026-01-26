# Severity Matrix

> Guide de scoring pour les vulnerabilites.

---

## Severity Levels

| Level | Score | Response Time | Description |
|-------|-------|---------------|-------------|
| **CRITICAL** | 9.0-10.0 | Immediate | Actively exploitable, high impact |
| **HIGH** | 7.0-8.9 | Days | Exploitable with effort, significant impact |
| **MEDIUM** | 4.0-6.9 | Sprint | Requires conditions, moderate impact |
| **LOW** | 0.1-3.9 | Backlog | Difficult to exploit, low impact |

---

## Scoring Formula

```
Final Score = (Impact Score + Exploitability Score) / 2
```

### Impact Score (0-10)

| Factor | Weight | Scale |
|--------|--------|-------|
| Confidentiality | 3.3 | None (0) / Low (3) / High (7) / Critical (10) |
| Integrity | 3.3 | None (0) / Low (3) / High (7) / Critical (10) |
| Availability | 3.4 | None (0) / Low (3) / High (7) / Critical (10) |

**Calculation:**
```
Impact = (C × 0.33) + (I × 0.33) + (A × 0.34)
```

### Exploitability Score (0-10)

| Factor | Weight | Scale |
|--------|--------|-------|
| Attack Complexity | 2.5 | High (2) / Low (5) / None (10) |
| Privileges Required | 2.5 | High (2) / Low (5) / None (10) |
| User Interaction | 2.5 | Required (3) / None (10) |
| Attack Vector | 2.5 | Physical (2) / Local (4) / Network (7) / Adjacent (10) |

**Calculation:**
```
Exploitability = (AC × 0.25) + (PR × 0.25) + (UI × 0.25) + (AV × 0.25)
```

---

## Common Findings Severity

### CRITICAL (9.0-10.0)

| Finding | Typical Score | Rationale |
|---------|---------------|-----------|
| Hardcoded API keys (production) | 9.5 | Full access, no auth needed |
| SQL Injection | 9.5 | Database compromise |
| RCE vulnerability | 10.0 | Full system control |
| Missing authentication | 9.0 | Unauthorized access |
| Exposed admin endpoints | 9.5 | Full app control |

### HIGH (7.0-8.9)

| Finding | Typical Score | Rationale |
|---------|---------------|-----------|
| Weak encryption | 8.0 | Data at risk |
| Missing RLS policies | 8.5 | Data leakage |
| IDOR vulnerabilities | 7.5 | Access other users' data |
| XSS (stored) | 8.0 | Account takeover possible |
| Missing HTTPS | 7.5 | Data in transit exposed |

### MEDIUM (4.0-6.9)

| Finding | Typical Score | Rationale |
|---------|---------------|-----------|
| XSS (reflected) | 5.5 | Requires user action |
| Missing input validation | 5.0 | Potential for abuse |
| Verbose error messages | 4.5 | Information disclosure |
| Debug mode in prod | 6.0 | Info + potential abuse |
| Outdated deps (no CVE) | 4.0 | Potential future risk |

### LOW (0.1-3.9)

| Finding | Typical Score | Rationale |
|---------|---------------|-----------|
| Missing security headers | 3.0 | Defense in depth |
| No rate limiting | 3.5 | DoS potential but limited |
| Missing logging | 2.0 | Detection gap |
| Minor config issues | 1.5 | Best practice |

---

## Effort Estimation

| Effort | Points | Description | Examples |
|--------|--------|-------------|----------|
| **XS** | 1 | Config change | Add header, update env |
| **S** | 2 | Simple fix | Input validation, escape output |
| **M** | 3 | Moderate | Implement auth check, add encryption |
| **L** | 5 | Significant | Refactor auth flow, add RLS |
| **XL** | 8 | Major | Architecture change, crypto overhaul |

---

## Risk Matrix

```
           │ LOW Impact │ MEDIUM Impact │ HIGH Impact │
───────────┼────────────┼───────────────┼─────────────┤
HIGH Expl. │   MEDIUM   │     HIGH      │  CRITICAL   │
───────────┼────────────┼───────────────┼─────────────┤
MED Expl.  │    LOW     │    MEDIUM     │    HIGH     │
───────────┼────────────┼───────────────┼─────────────┤
LOW Expl.  │    LOW     │     LOW       │   MEDIUM    │
```

---

## Priority Ranking

1. **Fix First**: CRITICAL with EASY exploitability
2. **Fix Soon**: CRITICAL with HARD exploitability, HIGH with EASY
3. **Plan Sprint**: HIGH with HARD, MEDIUM with EASY
4. **Backlog**: MEDIUM with HARD, all LOW

---

## False Positive Indicators

| Signal | Likely False Positive? |
|--------|------------------------|
| Test file only | Probably |
| Commented code | Probably |
| Documentation | Yes |
| Example/sample | Yes |
| Development env only | Maybe |
| Behind auth check | Review carefully |
