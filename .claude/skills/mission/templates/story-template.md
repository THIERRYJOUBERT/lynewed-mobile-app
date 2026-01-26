# {{STORY_ID}} : {{STORY_TITLE}}

> **Status** : 🔵 {{STATUS}}
> **Points** : {{POINTS}}
> **Epic** : {{EPIC_REF}}

---

## User Story

**En tant que** {{PERSONA}},
**Je veux** {{ACTION}},
**Afin de** {{BENEFIT}}.

---

## Criteres d'Acceptance

{{GHERKIN_CRITERIA}}

---

## Taches Techniques

{{TECHNICAL_TASKS}}

---

## Fichiers a Creer/Modifier

| Action | Fichier | Description |
|--------|---------|-------------|
{{FILES_TO_MODIFY}}

---

## Dependances

### Bloque par

{{BLOCKED_BY}}

### Bloque

{{BLOCKS}}

---

## Tests Requis

### Tests Unitaires

{{UNIT_TESTS}}

### Tests Integration

{{INTEGRATION_TESTS}}

---

## Definition of Done

- [ ] Tous les criteres d'acceptation passent
- [ ] Tests unitaires ecrits et passants
- [ ] Pas de warnings (`{{LINT_CMD}}`)
- [ ] Code coherent avec Mission et Epic
- [ ] Review Adversariale effectuee
- [ ] Documentation a jour

---

## Notes

{{NOTES}}

---

<!--
INVEST Checklist (validation):
- [x] Independent: Peut etre developpee seule
- [x] Negotiable: Details peuvent etre affines
- [x] Valuable: Livre une valeur claire
- [x] Estimable: Points assignes ({{POINTS}})
- [x] Small: <= 8 points
- [x] Testable: Criteres Gherkin definis
-->
