# Step 01: Scan

> Scan rapide avec 3 agents Haiku en parallele.

---

## CRITICAL

🚀 **LANCER LES 3 AGENTS DANS UN SEUL MESSAGE** (execution parallele obligatoire)

---

## Task

Lancer 3 agents Haiku pour un scan rapide et pas cher:
1. **Frontend Agent** - XSS, CSRF, input validation
2. **Backend Agent** - Auth, injection, API security
3. **Infrastructure Agent** - Secrets, deps, config

---

## Execution

### Launch All 3 Agents (SINGLE MESSAGE)

```
Task 1: Frontend Security Scan
Task 2: Backend Security Scan
Task 3: Infrastructure Security Scan
```

---

### Agent 1: Frontend Security

```yaml
subagent_type: Explore
model: haiku
description: "Frontend security scan"
prompt: |
  Scan for frontend security issues in this {stack.type} project.

  SEARCH FOR:
  1. XSS vulnerabilities
     - User input rendered without sanitization
     - innerHTML, dangerouslySetInnerHTML usage
     - URL parameters reflected in DOM

  2. CSRF risks
     - Forms without CSRF tokens
     - State-changing GET requests

  3. Input validation
     - Missing client-side validation
     - Regex injection possibilities

  4. Sensitive data exposure
     - API keys in frontend code
     - User data logged to console
     - Credentials in localStorage

  FILES TO CHECK:
  - lib/**/*.dart (Flutter)
  - src/**/*.{ts,tsx,js,jsx} (React/Node)
  - **/*.html

  RETURN FORMAT:
  ```yaml
  findings:
    - severity: CRITICAL|HIGH|MEDIUM|LOW
      category: XSS|CSRF|INPUT|EXPOSURE
      file: path/to/file.dart
      line: 123
      code: "vulnerable code snippet"
      description: "What's wrong"
      remediation: "How to fix"
  ```
```

---

### Agent 2: Backend Security

```yaml
subagent_type: Explore
model: haiku
description: "Backend security scan"
prompt: |
  Scan for backend security issues in this {stack.type} project.

  SEARCH FOR:
  1. SQL Injection
     - Raw SQL queries with string concatenation
     - Unparameterized queries

  2. Authentication flaws
     - Hardcoded credentials
     - Weak password policies
     - Missing rate limiting

  3. Authorization bypass
     - Missing permission checks
     - IDOR vulnerabilities
     - Privilege escalation paths

  4. API security
     - Missing authentication on endpoints
     - Overly permissive CORS
     - Sensitive data in responses

  5. Supabase specific (if detected)
     - Missing RLS policies
     - Overly permissive policies
     - Service role key exposure

  FILES TO CHECK:
  - lib/**/*.dart
  - supabase/migrations/*.sql
  - supabase/functions/**/*.ts
  - api/**/*.{ts,js}

  RETURN FORMAT:
  ```yaml
  findings:
    - severity: CRITICAL|HIGH|MEDIUM|LOW
      category: INJECTION|AUTH|AUTHZ|API
      file: path/to/file
      line: 123
      code: "vulnerable code"
      description: "What's wrong"
      remediation: "How to fix"
  ```
```

---

### Agent 3: Infrastructure Security

```yaml
subagent_type: Explore
model: haiku
description: "Infrastructure security scan"
prompt: |
  Scan for infrastructure security issues.

  SEARCH FOR:
  1. Hardcoded secrets
     - API keys in code
     - Database credentials
     - JWT secrets
     - Pattern: /[a-zA-Z0-9_-]{20,}/ near "key", "secret", "password"

  2. Environment config
     - .env files in git
     - Missing .gitignore entries
     - Production secrets in dev configs

  3. Dependencies vulnerabilities
     - Check {stack.dep_file} for known CVEs
     - Outdated packages with security patches

  4. Configuration issues
     - Debug mode in production
     - Verbose error messages
     - Missing security headers

  5. Permissions
     - Overly permissive file permissions
     - World-readable sensitive files

  FILES TO CHECK:
  - .env*, *.env
  - .gitignore
  - {stack.dep_file}
  - config/**/*
  - docker-compose*.yml
  - Dockerfile*

  RETURN FORMAT:
  ```yaml
  findings:
    - severity: CRITICAL|HIGH|MEDIUM|LOW
      category: SECRETS|CONFIG|DEPS|PERMISSIONS
      file: path/to/file
      line: 123 (if applicable)
      code: "[REDACTED]" (for secrets, show pattern not value)
      description: "What's wrong"
      remediation: "How to fix"
  ```

  🛑 CRITICAL: Never include actual secret values. Use [REDACTED].
```

---

## Consolidate Results

After all 3 agents complete:

```yaml
scan_results:
  frontend: {agent_1_findings}
  backend: {agent_2_findings}
  infrastructure: {agent_3_findings}

  summary:
    total: N
    critical: X
    high: Y
    medium: Z
    low: W
```

---

## Quick Mode Shortcut

Si `mode == quick`:
- Skip Agent 1 (Frontend)
- Skip Agent 2 (Backend)
- Only run Agent 3 (Infrastructure) - secrets + deps

---

## Validation

✅ Tous les agents ont termine
✅ Resultats structures en YAML
✅ Aucun secret expose (verification [REDACTED])
✅ Findings ont file:line

---

## Next

```
Load steps/step-02-analyze.md
```
