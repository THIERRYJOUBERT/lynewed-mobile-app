# REFACTORISATION SYSTÈME DE NOTIFICATIONS

**Date de début:** 2025-12-03  
**Statut:** 🔄 EN COURS  
**Référence:** `docs/audits/NOTIFICATIONS_AUDIT.md`  
**Supabase MCP:** `hekyovgnovhfhmkpfrna`

---

## 📋 PLAN VALIDÉ

### Types de Notifications v1 (Final)

| Type | Rôle cible | Déclencheur | Action Tap | Données requises |
|------|-----------|-------------|------------|------------------|
| `chatMessage` | Tous | Nouveau message privé | ChatDetailsPage | `room_id` |
| `connectionRequest` | Bride | Demande contact Pro | MessagesPage | `request_id` |
| `connectionRequestAccepted` | Pro | Demande acceptée | MessagesPage | `room_id` |
| `videoIncoming` | Tous | Appel vidéo entrant | VideoCallPage + joinChannel | `video_session_id`, `agora_channel_name` |
| `wishlistAdd` | Pro (Ultimate) | Bride ajoute en favori | DashboardPro | `bride_profile_id` |
| `wedPublished` | Tous | Nouveau Wedding of Week | WeddingOfTheWeekPage | `article_id` |

### Types SUPPRIMÉS (code mort)
- ~~`connectionRequestDeclined`~~ - On ne notifie que le succès
- ~~`professionalAlert`~~ - Jamais déclenché
- ~~`professionalAlertReminder24h`~~ - Jamais déclenché
- ~~`weddingPinMatch`~~ - Concept obsolète

---

## 🔧 PHASES DE TRAVAIL

### Phase 1: NETTOYAGE & PRÉPARATION ✅ COMPLET
- [x] Vider `notifications_outbox` (147 events bloqués)
- [x] Vider `notifications` (données de test)
- [x] Vérifier structure `device_tokens` (OK, vide en dev)
- [x] Valider configuration FCM (clés présentes, ENABLE_PUSH=false en dev)

### Phase 2: EDGE FUNCTION - Traitement instantané ✅ COMPLET
- [x] Modifier pour batch size 5 (plus sûr que 100)
- [x] Ajouter mode realtime (single event via event_id)
- [x] Temps d'exécution: ~400ms ✅
- [x] Créer RPC `claim_single_outbox_event` (fix syntaxe Supabase JS)
- [x] Ajouter GRANTs `service_role` sur tables chat
- [x] Test flux complet: message → trigger → Edge Function → notification ✅
- [x] Optimiser broadcast `wedPublished`: in-app par trigger SQL, push par cron ✅

### Phase 3: TRIGGERS BACKEND ✅ COMPLET
- [x] Vérifier trigger `chatMessage` ✅
- [x] Vérifier trigger `connectionRequest` ✅
- [x] Vérifier trigger `connectionRequestAccepted` ✅
- [x] Vérifier trigger `videoIncoming` ✅
- [x] Vérifier trigger `wishlistAdd` ✅
- [x] CRÉER trigger `wedPublished` (table `wed_articles`) ✅
- [x] SUPPRIMER code pour `connectionRequestDeclined` ✅

### Phase 4: FLUTTER - Redirections ⏳
- [ ] Valider `chatMessage` → ChatDetailsPage (room_id)
- [ ] Valider `connectionRequest` → MessagesPage
- [ ] Valider `connectionRequestAccepted` → MessagesPage (room_id)
- [ ] Valider `videoIncoming` → VideoCallPage + joinChannel
- [ ] AJOUTER `wishlistAdd` → DashboardPro
- [ ] AJOUTER `wedPublished` → WeddingOfTheWeekPage

### Phase 5: GESTION PAR RÔLE ⏳
- [ ] Définir types par rôle (Bride vs Pro)
- [ ] Adapter `notification_settings` par rôle
- [ ] Adapter `NotificationSettingsWidget` UI

### Phase 6: FLUTTER - UI Pages ⏳
- [ ] Refactoriser `NotificationsPage` (Design System v3)
- [ ] Refactoriser `NotificationSettingsWidget` (Design System v3)
- [ ] Supprimer options obsolètes

### Phase 7: NETTOYAGE FINAL ⏳
- [ ] Supprimer cron job définitivement
- [ ] Nettoyer enums Supabase
- [ ] Nettoyer enums Flutter
- [ ] Synchroniser `ConnectionRequestSource`

---

## 📝 JOURNAL DE TRAVAIL

### 2025-12-03 17:45 - Début refactorisation

**Actions:**
- Créé ce fichier de suivi
- Audit complet disponible dans `NOTIFICATIONS_AUDIT.md`

**Cause racine identifiée:**
- pg_net timeout (5s) vs Edge Function (5-20s)
- Solution: batch size 1, traitement < 2s

---

### 2025-12-03 17:50 - Edge Function refactorisée

**Actions:**
- ✅ Vidé `notifications_outbox` (147 events)
- ✅ Vidé `notifications` 
- ✅ Déployé Edge Function v20 (batch size 5, mode realtime)
- ✅ Créé trigger `trg_outbox_wed_published` sur `wed_articles`
- ✅ Ajouté processeur `wedPublished`
- ✅ Supprimé `connectionRequestDeclined` et `professionalAlertReminder24h`

**Tests réalisés:**
- ✅ Insert direct dans `notifications` fonctionne
- ✅ Trigger `chatMessage` crée bien l'event dans outbox
- ✅ Trigger realtime appelle l'Edge Function (< 5s)
- ⚠️ Edge Function: erreur silencieuse dans le processeur (markFailed ne s'exécute pas)

**Problème identifié:**
L'Edge Function retourne "failed: 1" mais `markFailed` ne met pas à jour la DB.
Le SQL direct fonctionne - problème isolé dans le code TypeScript.

**Workaround temporaire:**
Les notifications peuvent être créées manuellement via SQL - le flux backend est fonctionnel.

---

### 2025-12-03 18:05 - EDGE FUNCTION FIXÉE ✅

**Problèmes identifiés et résolus:**

1. **Syntaxe Supabase JS `.is("processed_at", null)`** ne fonctionnait pas
   - Solution: Créé RPC `claim_single_outbox_event` en PL/pgSQL

2. **`executeInAppInserts` avalait les erreurs silencieusement**
   - Solution: `throw new Error()` au lieu de `return []`

3. **`service_role` n'avait pas les GRANTs sur `chat_messages`**
   - Solution: Migration `grant_service_role_access_for_notifications`

**Résultat final:**
- Edge Function v22 déployée
- Temps d'exécution: ~400-450ms (vs 15-20s avant)
- Flux complet testé et validé:
  - INSERT chat_message → trigger crée event
  - Trigger realtime appelle Edge Function
  - Edge Function traite et crée notification
  - Tout en < 1 seconde !

---

### 2025-12-03 18:15 - OPTIMISATION BROADCAST (wedPublished) ✅

**Problème:** `wedPublished` prenait 7+ secondes car il notifiait tous les users via Edge Function.

**Solution implémentée:**
1. **In-app:** Le trigger SQL insère directement les notifications en batch (instantané)
2. **Push:** Un event `wedPublishedPush` est créé pour traitement par cron (pas realtime)

**Nouveau flux wedPublished:**
```
INSERT wed_articles (is_published=true)
  → Trigger SQL insère 49 notifications in-app (instantané)
  → Trigger SQL crée 1 event wedPublishedPush (pour cron)
  → Cron traite les push notifications plus tard
```

**Résultat:**
- Edge Function v23 déployée
- Notifications in-app: instantanées (< 100ms)
- Push: différé (cron)

---

## 🔍 EN CAS DE DOUTE

1. **Consulter:** `docs/audits/NOTIFICATIONS_AUDIT.md`
2. **Vérifier via MCP Supabase:** projet `hekyovgnovhfhmkpfrna`
3. **Edge Function:** `supabase/functions/notifications_outbox_drain/index.ts`
4. **Flutter actions:** `lib/custom_code/actions/`

---

## 📊 MÉTRIQUES DE TEST

| Test | Avant | Après | Statut |
|------|-------|-------|--------|
| Notifications créées | 0 | - | ⏳ |
| Events traités | 0/147 | - | ⏳ |
| Temps traitement | 5-20s | < 2s | ⏳ |
| Push FCM reçus | ❌ | - | ⏳ |

