# TRACKING - EPIC-08-REMINDERS

> Status : 🔵 Draft
> Stories : 0/7 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Notifications de rappel RDV (APP-02) |
| - | - |

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Colonnes reminder wedding_events | 🔵 Todo | - | - | - | Migration DB simple |
| S02 - Table scheduled_notifications | 🔵 Todo | - | - | - | Avec CASCADE et RLS |
| S03 - pg_cron job processing | 🔵 Todo | - | - | - | Depend de S02 |
| S04 - Entite WeddingEvent Dart | 🔵 Todo | - | - | - | Depend de S01 |
| S05 - UI checkboxes formulaire | 🔵 Todo | - | - | - | Depend de S04 |
| S06 - Repository scheduling | 🔵 Todo | - | - | - | Depend de S02, S04 |
| S07 - Integration notifications_outbox | 🔵 Todo | - | - | - | Depend de S03, S06 |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | 3 rappels fixes (1 semaine, 1 jour, 1 heure) | Simplicite UX vs flexibilite | Couvre 95% des cas d'usage |
| 2026-01-28 | UNIQUE constraint sur (event_id, notification_type) | Eviter doublons | Pas de notifications multiples du meme type |
| 2026-01-28 | CASCADE delete sur event_id | Nettoyage automatique | Pas de notifications orphelines |
| 2026-01-28 | pg_cron toutes les minutes | Precision vs performance | Acceptable pour ~100 notifications/jour |
| 2026-01-28 | Skip des rappels dans le passe | Event proche = rappels limites | 1 heure avant si event dans 6h |
| 2026-01-28 | Format "Rappel : [titre] dans [duree]" | Coherence notifications | Message clair et concis |

---

## Ce qui reste pour 100%

### Database (Stories S01-S03)

- [ ] S01: Migration colonnes reminder_1_week, reminder_1_day, reminder_1_hour
- [ ] S01: Index sur events avec rappels actifs
- [ ] S01: Verification existance colonnes
- [ ] S02: Table scheduled_notifications avec toutes colonnes
- [ ] S02: Contrainte chk_notification_type ('1_week', '1_day', '1_hour')
- [ ] S02: Contrainte UNIQUE (event_id, notification_type)
- [ ] S02: Index idx_scheduled_pending pour performance
- [ ] S02: RLS policies user
- [ ] S03: Extension pg_cron activee
- [ ] S03: Fonction process_scheduled_notifications()
- [ ] S03: Job cron 'send-scheduled-notifications' schedule

### Dart (Stories S04-S06)

- [ ] S04: Ajouter reminder1Week, reminder1Day, reminder1Hour a WeddingEvent
- [ ] S04: Mettre a jour WeddingEventModel.fromJson avec backward compat
- [ ] S04: Mettre a jour WeddingEventModel.toJson
- [ ] S04: Mettre a jour copyWith
- [ ] S04: Tests unitaires serialization
- [ ] S05: Section "Rappels" dans formulaire event
- [ ] S05: 3 CheckboxListTile avec labels francais
- [ ] S05: Desactiver checkboxes pour events passes
- [ ] S05: Binding avec cubit/bloc state
- [ ] S06: Methode _scheduleReminders dans repository
- [ ] S06: Delete existing + insert new notifications
- [ ] S06: Calcul dates (event_date - 7 days, - 1 day, - 1 hour)
- [ ] S06: Skip si scheduled_at dans le passe
- [ ] S06: Tests unitaires repository

### Integration (Story S07)

- [ ] S07: Verifier format payload notifications_outbox
- [ ] S07: Mettre a jour FCM worker si necessaire
- [ ] S07: Format message "Rappel : [titre] dans [duree]"
- [ ] S07: Test E2E du flow complet
- [ ] S07: Documentation integration

### TEST (Transversal)

- [ ] Tests unitaires entite WeddingEvent
- [ ] Tests unitaires repository scheduling
- [ ] Tests widget formulaire checkboxes
- [ ] Tests integration migrations
- [ ] Tests fonction process_scheduled_notifications
- [ ] flutter analyze --fatal-infos passe
- [ ] Validation sur branche Supabase avant production

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 7 |
| Stories completees | 0 |
| Migrations SQL | 3 (S01, S02, S03) |
| Policies RLS | 2 (scheduled_notifications) |
| Tests a ajouter | ~20 (estimes) |
| Temps estime | 0.5 jour |

---

## Dependances Inter-Stories

```
S01 (reminder columns)
  |
  +---> S04 (Dart entity) ---> S05 (UI checkboxes)
                |
                +---> S06 (repository)
                        |
S02 (scheduled table) --+---> S06
  |
  +---> S03 (pg_cron) ---> S07 (integration)
```

**Execution parallele possible:**
- S01 et S02 peuvent etre faites en parallele
- S03 depend uniquement de S02
- S04 depend uniquement de S01
- S05 depend de S04
- S06 depend de S02 et S04
- S07 depend de S03 et S06

---

## Dependances Externes

| Dependance | Status | Notes |
|------------|--------|-------|
| EPIC-06 Prerequisites | 🔵 Pas bloquant | APP-02 ne depend pas de guest role |
| notifications_outbox | ✅ Existe | 247 rows en prod |
| FCM Worker | ✅ Existe | Doit supporter event_reminder type |
| wedding_events | ✅ Existe | 9 rows en prod |
| pg_cron extension | ✅ Disponible | Extension Supabase standard |

---

## Checklist Pre-Production

Avant de merger les migrations en production:

- [ ] Toutes les migrations testees sur branche Supabase
- [ ] Rollback teste pour chaque migration
- [ ] pg_cron job fonctionne correctement
- [ ] Pas de notifications orphelines possibles
- [ ] RLS policies validees avec tests
- [ ] Aucun warning flutter analyze
- [ ] Documentation a jour
- [ ] Backup production fait avant migration
- [ ] FCM worker mis a jour si necessaire

---

## Test Plan

### Tests Manuels

1. **Creation event avec rappels**
   - Creer un event avec les 3 rappels actives
   - Verifier scheduled_notifications contient 3 entries
   - Verifier les dates sont correctes

2. **Modification event**
   - Modifier un event pour changer les rappels
   - Verifier old notifications supprimees
   - Verifier new notifications creees

3. **Suppression event**
   - Supprimer un event avec rappels
   - Verifier CASCADE a supprime les notifications

4. **pg_cron execution**
   - Creer notification dans le passe
   - Attendre 1 minute
   - Verifier insertion dans notifications_outbox
   - Verifier sent = TRUE

5. **Push notification**
   - Declencher notification via cron
   - Verifier reception sur device
   - Verifier format message

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
