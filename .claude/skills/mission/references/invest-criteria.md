# INVEST Criteria Reference

> Criteres obligatoires pour toutes les Stories generees par /mission.

---

## Les 6 Criteres INVEST

| Lettre | Critere | Description | Validation |
|--------|---------|-------------|------------|
| **I** | Independent | Peut etre developpee seule | Pas de couplage dur |
| **N** | Negotiable | Details peuvent etre affines | Pas de specs figees |
| **V** | Valuable | Livre une valeur claire | User story explicite |
| **E** | Estimable | Peut etre estimee | Points assignes |
| **S** | Small | Assez petite | 1-8 points max |
| **T** | Testable | Peut etre testee | Criteres Gherkin |

---

## I - Independent

La Story doit pouvoir etre developpee independamment des autres.

### Valide ✅

```
STORY-01-01: Creer formulaire de login
STORY-01-02: Implementer validation email
```
→ Chaque story peut etre developpee seule

### Invalide ❌

```
STORY-01-01: Creer la moitie du formulaire
STORY-01-02: Finir le formulaire
```
→ 01-02 ne peut pas exister sans 01-01

### Comment corriger

- Regrouper les stories dependantes
- Decouper par feature complete, pas par etape

---

## N - Negotiable

Les details de l'implementation peuvent etre discutes et affines.

### Valide ✅

```
En tant qu'utilisateur,
Je veux pouvoir me connecter,
Afin d'acceder a mon compte.
```
→ Le "comment" est ouvert

### Invalide ❌

```
Creer un bouton bleu de 44x44 pixels avec border-radius 8
qui appelle POST /api/v1/auth/login avec body JSON {email, password}
```
→ Trop prescriptif, pas de place pour refinement

---

## V - Valuable

La Story doit apporter une valeur claire a l'utilisateur ou au business.

### Valide ✅

```
En tant qu'utilisateur,
Je veux recevoir un email de confirmation,
Afin de verifier mon adresse email.
```
→ Valeur claire pour l'utilisateur

### Invalide ❌

```
Refactorer le module auth pour utiliser le nouveau pattern
```
→ Pas de valeur directe pour l'utilisateur

### Comment corriger

- Toujours formuler en "En tant que... Je veux... Afin de..."
- Si technique, reformuler en impact utilisateur

---

## E - Estimable

L'equipe doit pouvoir estimer l'effort requis.

### Valide ✅

```
Story: Ajouter validation email
Points: 3
Rationale: Pattern similaire a validation telephone (deja fait)
```

### Invalide ❌

```
Story: Integrer le systeme legacy
Points: ???
Rationale: On ne sait pas ce que contient le systeme legacy
```

### Comment corriger

- Ajouter une spike story pour investiguer
- Decomposer en parties connues + spike

---

## S - Small

La Story doit etre assez petite pour etre completee en quelques jours.

### Echelle de points

| Points | Taille | Duree typique |
|--------|--------|---------------|
| 1 | XS | Quelques heures |
| 2 | S | 1 jour |
| 3 | M | 1-2 jours |
| 5 | L | 2-3 jours |
| 8 | XL | 3-5 jours |
| > 8 | XXL | **DECOMPOSER** |

### Invalide ❌

```
Story: Implementer tout le module d'authentification
Points: 21
```

### Comment decomposer

| Story originale (21 pts) | Stories decomposees |
|--------------------------|---------------------|
| Auth complete | Login (3) + Register (3) + Forgot (2) + Session (3) + Logout (1) + Tests (3) |

---

## T - Testable

La Story doit avoir des criteres d'acceptance clairs et testables.

### Format obligatoire : Gherkin

```gherkin
Scenario: Login reussi avec credentials valides
  Given un utilisateur enregistre avec email "test@example.com"
  And mot de passe "SecurePass123"
  When l'utilisateur soumet le formulaire de login
  Then il est redirige vers le dashboard
  And un token JWT est stocke en session
```

### Invalide ❌

```
Criteres:
- Le login doit marcher
- UX fluide
- Pas de bugs
```
→ Non testable, trop vague

### Structure Gherkin

```gherkin
Scenario: {Description courte}
  Given {Contexte initial}
  And {Contexte additionnel si necessaire}
  When {Action de l'utilisateur}
  Then {Resultat attendu}
  And {Resultat additionnel si necessaire}
```

---

## Checklist de validation

Avant de valider une Story, verifier :

```markdown
## INVEST Checklist

- [ ] **I**ndependent : Peut etre developpee seule
- [ ] **N**egotiable : Details non figees
- [ ] **V**aluable : Valeur utilisateur claire
- [ ] **E**stimable : Points assignes (1-8)
- [ ] **S**mall : Pas plus de 8 points
- [ ] **T**estable : Gherkin scenarios presents
```

---

## Actions si critere echoue

| Critere | Probleme | Action |
|---------|----------|--------|
| I | Dependance dure | Fusionner ou reordonner |
| N | Trop prescriptif | Reformuler en user story |
| V | Pas de valeur | Reformuler ou supprimer |
| E | Non estimable | Ajouter spike story |
| S | Trop grosse | Decomposer |
| T | Non testable | Ajouter Gherkin |

---

## References

- Workflow: `/mission` step-07
- Template: `templates/story-template.md`
- Patterns: `/create-story` workflow
