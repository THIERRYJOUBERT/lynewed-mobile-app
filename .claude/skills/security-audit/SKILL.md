---
name: security-audit
description: "Audit complet securite et qualite du projet (OWASP, secrets, deps, config, tests). Genere rapport + propose Epic remediation."
model: opus
context: fork
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
  - TodoWrite
argument-hint: "[--auto] [--mode=quick|deep] [scope: code|auth|data|api|deps|config|all]"
---

# Security Audit

> Audit complet de securite et qualite pour tout projet. Detecte vulnerabilites, mauvaises pratiques, et propose un plan de remediation via Epic/Stories.

---

## Comportement

**Ce workflow:**
- Scanne l'ensemble du projet (ou scope specifie)
- Utilise 6 agents en parallele (3 Haiku scan + 3 Sonnet analyse)
- Genere un rapport detaille avec severite et remediation
- Propose de creer un Epic avec Stories pour corriger les problemes
- Multi-stack: detecte automatiquement Flutter, Node, Python, etc.

**IMPORTANT**: Audit en lecture seule. Ne modifie AUCUN fichier du projet.

---

## Rules

- 🛑 JAMAIS exposer de secrets dans le rapport (redacter: `sk_live_***[REDACTED]***`)
- 🛑 JAMAIS ignorer les vulnerabilites CRITICAL
- ✅ TOUJOURS fournir file:line pour chaque finding
- ✅ TOUJOURS estimer l'effort de remediation
- ✅ TOUJOURS proposer l'Epic meme si peu de findings
- ⚠️ Utiliser --mode=quick pour un scan rapide (deps + secrets seulement)

---

## Arguments

```
$ARGUMENTS

Options:
  --mode=quick    Scan rapide (deps + secrets + config seulement)
  --mode=deep     Scan complet avec analyse OWASP (defaut)

Scope (optionnel):
  code            Code source uniquement
  auth            Authentification et autorisation
  data            Base de donnees et stockage
  api             Endpoints et services externes
  deps            Dependances et packages
  config          Configuration et secrets
  all             Tout (defaut)

Exemples:
  /security-audit                    # Audit complet
  /security-audit --mode=quick       # Scan rapide
  /security-audit deps               # Dependances seulement
  /security-audit auth api           # Auth + API
```

---

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY AUDIT (6 STEPS)                      │
│                                                                  │
│  00. INIT      → Detecter stack, parser scope                   │
│       ↓                                                          │
│  01. SCAN      → 3 Haiku agents PARALLELE (rapide)              │
│       ↓          Frontend | Backend | Infrastructure            │
│                                                                  │
│  02. ANALYZE   → 3 Sonnet agents PARALLELE (profond)            │
│       ↓          OWASP | Severity | Remediation                 │
│                                                                  │
│  03. SYNTHESIZE → Rapport structure avec priorites              │
│       ↓                                                          │
│  04. VALIDATE  → Review APEX adversariale                       │
│       ↓                                                          │
│  05. PROPOSE   → CHECKPOINT: Creer Epic?                        │
│       ↓          Si OUI → Generer Epic + suggerer /create-story │
│                                                                  │
│  06. EPIC      → Creer Epic Security + suggerer stories         │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `{mode}` | enum | quick \| deep |
| `{scope}` | array | Domaines a auditer |
| `{stack}` | object | Stack detecte (flutter, node, etc.) |
| `{scan_results}` | array | Resultats scan Haiku |
| `{analysis_results}` | array | Resultats analyse Sonnet |
| `{findings}` | array | Tous les findings consolides |
| `{report_path}` | string | Chemin du rapport genere |
| `{create_epic}` | boolean | User veut creer Epic? |
| `{epic_id}` | string | ID de l'Epic cree |

---

## Domaines d'Audit

| Domaine | Checks | Outils |
|---------|--------|--------|
| **CODE** | Injection, XSS, validation, error handling | Grep patterns, AST analysis |
| **AUTH** | Session, JWT, permissions, RBAC | Auth flow review |
| **DATA** | Encryption, PII, RLS policies | Schema analysis |
| **API** | Rate limit, auth bypass, CORS | Endpoint mapping |
| **DEPS** | CVEs, outdated, supply chain | pub/npm audit |
| **CONFIG** | Secrets in code, .env, permissions | Pattern matching |

---

## Output

**Rapport** (toujours genere):
```
workspace/current/SECURITY-AUDIT-{DATE}.md
├── Executive Summary
├── Findings by Severity (CRITICAL → LOW)
├── Remediation Roadmap
└── Sources & Methodology
```

**Epic** (si accepte):
```
docs/epics/EPIC-XX-SECURITY/
├── EPIC-XX-SECURITY.md
├── TRACKING.md
└── sources.yaml
```

**Suggestion finale**:
```
Pour creer les stories de cet Epic:
/create-story EPIC-XX-SECURITY --auto
```

---

## Execution

### Step Loading

Charger les steps progressivement:

```
Load steps/step-00-init.md
```

---

## References

- `references/owasp-flutter.md` - OWASP Top 10 + Flutter/Dart patterns
- `references/severity-matrix.md` - Scoring et priorisation
- `templates/security-report.md` - Template rapport
- `templates/security-epic.md` - Template Epic

---

## Critical Reminders (Sandwich Pattern)

🛑 **DEBUT**:
- Ne JAMAIS exposer de secrets reels dans le rapport
- Ne JAMAIS ignorer les CRITICAL (meme si "false positive possible")

🛑 **FIN**:
- TOUJOURS proposer l'Epic (meme si 0 CRITICAL)
- TOUJOURS suggerer `/create-story --auto` apres Epic

---

<begin>
Load `steps/step-00-init.md`
</begin>
