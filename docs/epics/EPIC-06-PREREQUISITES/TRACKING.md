# TRACKING - EPIC-06-PREREQUISITES

> Status : 🔵 Draft
> Stories : 0/6 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Prerequis techniques Mission 2026 |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Enum userRole guest | 🔵 Todo | - | - | - | BLOQUANT pour autres stories |
| S02 - Colonnes weddings invite | 🔵 Todo | - | - | - | Depend de S01 |
| S03 - Table invitation_attempts | 🔵 Todo | - | - | - | Independant |
| S04 - Trigger generate_invite_code | 🔵 Todo | - | - | - | Depend de S02 |
| S05 - Colonnes wedding_guests | 🔵 Todo | - | - | - | Depend de S01 |
| S06 - Bucket wedding-media RLS | 🔵 Todo | - | - | - | Independant |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Code invitation 8 caracteres (pas 6) | Securite anti-bruteforce (D-15) | 2.8 trillions de combinaisons |
| 2026-01-28 | Expiration 30 jours par defaut | Balance securite/UX | Regeneration possible par bride |
| 2026-01-28 | Alphabet 32 chars (exclut I,O,0,1) | Lisibilite codes | Evite confusion visuelle |
| 2026-01-28 | Rate limit 5 attempts/15min | Protection bruteforce | Configurable si besoin |
| 2026-01-28 | RLS service_role pour invitation_attempts | Securite | Edge Functions uniquement |

---

## Ce qui reste pour 100%

### Database (Stories S01-S05)

- [ ] S01: Migration enum userRole avec valeur 'guest'
- [ ] S01: Verification enum en production
- [ ] S02: Colonnes invite_code et invite_code_expires_at sur weddings
- [ ] S02: Index sur invite_code
- [ ] S03: Table invitation_attempts avec index
- [ ] S03: Fonction check_invitation_rate_limit
- [ ] S04: Fonction generate_invite_code_value
- [ ] S04: Trigger trg_generate_invite_code
- [ ] S04: Fonction regenerate_wedding_invite_code
- [ ] S05: Colonnes user_id, invited_at, joined_at, status sur wedding_guests
- [ ] S05: Constraint chk_guest_status
- [ ] S05: Index sur wedding_id + status

### Storage (Story S06)

- [ ] S06: Creer bucket wedding-media (private)
- [ ] S06: Policy "Guest upload own folder"
- [ ] S06: Policy "Guest read own files"
- [ ] S06: Policy "Guest delete own files"
- [ ] S06: Policy "Bride read shared guest media"
- [ ] S06: Policy "Bride upload own folder"
- [ ] S06: Policy "Bride read own files"
- [ ] S06: Configurer file size limits (500MB max)
- [ ] S06: Configurer allowed MIME types

### Dart (Story S01)

- [ ] S01: Ajouter UserRole.guest dans enum
- [ ] S01: Mettre a jour UserRoleX.value pour guest
- [ ] S01: Mettre a jour UserRoleX.fromString pour guest
- [ ] S01: Tests unitaires UserRole

### TEST (Transversal)

- [ ] Tests unitaires pour chaque story
- [ ] Tests integration migrations
- [ ] Tests RLS policies
- [ ] flutter analyze --fatal-infos passe
- [ ] Validation sur branche Supabase avant production

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 6 |
| Stories completees | 0 |
| Migrations SQL | 6 (a creer) |
| Policies RLS | 7 (6 storage + 0 tables publiques) |
| Tests a ajouter | ~15 (estimes) |
| Temps estime | 0.5 jour |

---

## Dependances Inter-Stories

```
S01 (enum guest)
  |
  +---> S02 (weddings columns) ---> S04 (trigger)
  |
  +---> S05 (wedding_guests columns)

S03 (invitation_attempts) --- INDEPENDANT

S06 (storage bucket) --- INDEPENDANT (mais guest_albums doit exister pour policy bride)
```

**Note**: S06 necessite que la table `guest_albums` existe pour la policy "Bride read shared guest media". Cette table sera creee dans EPIC-07 (APP-04). En attendant, la policy peut etre creee mais ne fonctionnera pas completement.

---

## Checklist Pre-Production

Avant de merger les migrations en production:

- [ ] Toutes les migrations testees sur branche Supabase
- [ ] Rollback teste pour chaque migration
- [ ] Pas de donnees perdues lors des tests
- [ ] RLS policies validees avec tests
- [ ] Aucun warning flutter analyze
- [ ] Documentation a jour
- [ ] Backup production fait avant migration

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
