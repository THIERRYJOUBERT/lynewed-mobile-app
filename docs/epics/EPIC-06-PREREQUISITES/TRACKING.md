# TRACKING - EPIC-06-PREREQUISITES

> Status : 🟡 In Progress
> Stories : 5/6 completees (1 partielle)
> Derniere MAJ : 2026-01-29

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Prerequis techniques Mission 2026 |
| 2026-01-29 | S01-S05 Deployes en production |
| 2026-01-29 | S06 Partiel (RLS via Dashboard requis) |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Enum userRole guest | ✅ Done | Claude | 2026-01-29 | 2026-01-29 | Migration OK en prod |
| S02 - Colonnes weddings invite | ✅ Done | Claude | 2026-01-29 | 2026-01-29 | Migration OK en prod |
| S03 - Table invitation_attempts | ✅ Done | Claude | 2026-01-29 | 2026-01-29 | Migration OK en prod |
| S04 - Trigger generate_invite_code | ✅ Done | Claude | 2026-01-29 | 2026-01-29 | Migration OK en prod |
| S05 - Colonnes wedding_guests | ✅ Done | Claude | 2026-01-29 | 2026-01-29 | Migration OK en prod |
| S06 - Bucket wedding-media RLS | 🟡 Partial | Claude | 2026-01-29 | - | Bucket manuel + RLS Dashboard |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| 2026-01-29 | S06: RLS storage requires owner priv | Manuel via Dashboard | 🟡 En attente |

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

- [x] S01: Migration enum userRole avec valeur 'guest'
- [x] S01: Verification enum en production
- [x] S02: Colonnes invite_code et invite_code_expires_at sur weddings
- [x] S02: Index sur invite_code
- [x] S03: Table invitation_attempts avec index
- [x] S03: Fonction check_invitation_rate_limit
- [x] S04: Fonction generate_invite_code_value
- [x] S04: Trigger trg_generate_invite_code
- [x] S04: Fonction regenerate_wedding_invite_code
- [x] S05: Colonnes user_id, invited_at, joined_at, status sur wedding_guests
- [x] S05: Constraint chk_guest_status
- [x] S05: Index sur wedding_id + status

### Storage (Story S06)

- [ ] S06: Creer bucket wedding-media (private) - MANUEL VIA DASHBOARD
- [ ] S06: Policy "Guest upload own folder" - MANUEL VIA DASHBOARD
- [ ] S06: Policy "Guest read own files" - MANUEL VIA DASHBOARD
- [ ] S06: Policy "Guest delete own files" - MANUEL VIA DASHBOARD
- [ ] S06: Policy "Bride read shared guest media" - MANUEL VIA DASHBOARD
- [ ] S06: Policy "Bride upload own folder" - MANUEL VIA DASHBOARD
- [ ] S06: Policy "Bride read own files" - MANUEL VIA DASHBOARD
- [ ] S06: Configurer file size limits (500MB max) - MANUEL VIA DASHBOARD
- [ ] S06: Configurer allowed MIME types - MANUEL VIA DASHBOARD

### Dart (Story S01)

- [x] S01: Ajouter UserRole.guest dans enum
- [x] S01: Mettre a jour UserRoleX.value pour guest
- [x] S01: Mettre a jour UserRoleX.fromString pour guest
- [x] S01: Tests unitaires UserRole (16 tests passent)

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
| Stories completees | 5 |
| Stories partielles | 1 (S06) |
| Migrations SQL | 5 appliquees en prod |
| Policies RLS | 6 en attente (manuel) |
| Tests ajoutes | 5 nouveaux tests UserRole |
| Temps realise | ~1h |

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
