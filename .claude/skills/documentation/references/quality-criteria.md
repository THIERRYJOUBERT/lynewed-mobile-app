# Quality Criteria

> Criteres pour evaluer la qualite de la documentation generee.

---

## Core Principles

### 1. Dense (pas Verbose)

**Definition:** Chaque phrase apporte de l'information. Pas de fluff.

**Red Flags:**
- "Il est important de noter que..."
- "Comme mentionne precedemment..."
- Repetitions du meme point
- Paragraphes sans contenu actionable

**Good Example:**
```markdown
JWT choisi pour auth (raison: stateless, scalable)
```

**Bad Example:**
```markdown
Apres avoir longuement discute des differentes options d'authentification,
nous avons finalement decide d'utiliser JWT car c'est une solution moderne
qui presente de nombreux avantages pour notre architecture.
```

---

### 2. Date (Timestamp)

**Definition:** Chaque entree a un timestamp clair.

**Format:** `YYYY-MM-DD` ou `YYYY-MM-DD HH:MM`

**Placement:**
- En-tete du document
- Chaque section majeure
- Chaque decision

**Red Flags:**
- Pas de date
- "Recemment", "il y a quelques jours"
- Dates ambigues

---

### 3. Source (Reference)

**Definition:** Chaque information cite sa source.

**Types de sources:**
- Conversation: "Conversation 2026-01-24 14:00"
- Git: "Commit abc1234"
- Fichier: "Ref: FD-05-PRODUCT.md"
- Decision: "Decision team 2026-01-24"

**Red Flags:**
- "D'apres la conversation..."
- "Comme discute..."
- Aucune reference

---

### 4. Structure (Parsable)

**Definition:** Document facile a scanner et parser.

**Elements:**
- Headers clairs (## Section)
- Tables pour donnees comparatives
- Listes pour enumeration
- Code blocks pour code/config

**Red Flags:**
- Mur de texte
- Pas de sections
- Mixte de formats

---

### 5. Exploitable (Actionable)

**Definition:** Claude peut utiliser cette doc pour travailler.

**Tests:**
- Une nouvelle conversation peut comprendre le contexte?
- Les decisions sont claires et justifiees?
- Les next steps sont definis?

**Red Flags:**
- Trop vague pour agir
- Manque de contexte
- Decisions sans rationale

---

## Scoring Rubric

| Critere | 0 points | 1 point | 2 points |
|---------|----------|---------|----------|
| Dense | Verbose, fluff | Quelques repetitions | Chaque phrase utile |
| Date | Pas de date | Date partielle | Date complete |
| Source | Pas de source | Source vague | Source precise |
| Structure | Pas de structure | Structure basique | Structure claire |
| Exploitable | Inutilisable | Partiellement utile | Totalement actionable |

**Total: /10**

| Score | Status |
|-------|--------|
| 8-10 | PASS |
| 6-7 | PASS_WITH_WARNINGS |
| 0-5 | NEEDS_FIX |

---

## Review Checklist

### Quick Scan (30s)
- [ ] Date visible en haut?
- [ ] Headers clairs?
- [ ] Pas de mur de texte?

### Deep Review (2min)
- [ ] Chaque phrase apporte info?
- [ ] Sources presentes et precises?
- [ ] Decisions avec rationale?
- [ ] Next steps definis?
- [ ] Claude peut agir sur cette doc?

---

## Common Issues & Fixes

| Issue | Detection | Fix |
|-------|-----------|-----|
| Fluff | Phrases sans info | Supprimer ou condenser |
| Missing date | Pas de timestamp | Ajouter YYYY-MM-DD |
| Vague source | "D'apres..." | Specifier conversation/commit |
| No structure | Paragraphes longs | Ajouter headers, tables |
| Not actionable | Trop abstrait | Ajouter exemples concrets |

---

## Examples

### PASS (Score 9/10)

```markdown
# Session: Auth Implementation - 2026-01-24

**Source**: Conversation 14:00-17:30, Commits abc123, def456

## Decisions
| Decision | Choix | Raison |
|----------|-------|--------|
| Auth method | JWT | Stateless, scalable |
| Token expiry | 1h access, 7d refresh | Security/UX balance |

## Implementation
- `lib/features/auth/` cree
- Provider: auth_provider.dart
- Service: auth_service.dart

## Next
- [ ] Tests integration
- [ ] Error handling UI
```

### NEEDS_FIX (Score 4/10)

```markdown
# Authentication

We implemented authentication today. After discussing various options,
we decided to use JWT because it's a modern solution. The implementation
went well and we created several files for handling authentication.

We should probably write some tests later.
```

**Issues:**
- Pas de date precise
- Verbose sans details
- Pas de sources
- Next steps vagues
