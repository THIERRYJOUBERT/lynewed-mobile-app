# {{EPIC_ID}}: Security Remediation

> **Status**: Draft
> **Priority**: CRITICAL
> **Estimated Effort**: {{TOTAL_EFFORT}} points
> **Source**: Security Audit {{DATE}}

---

## Objectif

Corriger les {{TOTAL_FINDINGS}} vulnerabilites identifiees lors de l'audit securite du {{DATE}}.

### Priorites

1. **CRITICAL** ({{CRITICAL_COUNT}} findings) - Fix immediat
2. **HIGH** ({{HIGH_COUNT}} findings) - Fix sous 1 semaine
3. **MEDIUM** ({{MEDIUM_COUNT}} findings) - Sprint suivant
4. **LOW** ({{LOW_COUNT}} findings) - Backlog

---

## Scope

### In Scope

{{SCOPE_DETAILS}}

### Out of Scope

- Audit des services externes
- Penetration testing
- Audit infrastructure cloud

---

## Stories Prevues

### Sprint 1: Critical Fixes ({{CRITICAL_EFFORT}} pts)

{{CRITICAL_STORIES_TABLE}}

### Sprint 2: High Priority ({{HIGH_EFFORT}} pts)

{{HIGH_STORIES_TABLE}}

### Backlog: Medium/Low

{{BACKLOG_STORIES_TABLE}}

---

## Criteres de Succes

- [ ] 0 vulnerabilites CRITICAL
- [ ] 0 vulnerabilites HIGH
- [ ] Audit de verification passe (`/security-audit`)
- [ ] Tests de regression OK
- [ ] Code review securite validee

---

## Dependencies

- Rapport d'audit: `{{REPORT_PATH}}`
- Standards: OWASP Top 10, CWE Top 25

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Regression lors des fixes | HIGH | Tests unitaires obligatoires |
| Scope creep | MEDIUM | Strict adherence to findings |
| Resource availability | MEDIUM | Prioriser CRITICAL |

---

## Notes

Genere automatiquement par `/security-audit` le {{DATE}}.

Pour creer les stories:
```
/create-story {{EPIC_ID}} --auto
```
