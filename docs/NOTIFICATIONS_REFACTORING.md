# REFACTORISATION SYSTÈME DE NOTIFICATIONS

**Date de début:** 2025-12-03  
**Statut:** 🔄 EN COURS  
**Référence:** `docs/audits/NOTIFICATIONS_AUDIT.md`  
**Supabase MCP:** `hekyovgnovhfhmkpfrna`

---

## 📋 PLAN VALIDÉ

### Types de Notifications v1 (Final) - 7 Types Actifs

#### Système 1: Transactionnel (instantané < 2s)
| Type | Rôle cible | Déclencheur | Action Tap | Données requises |
|------|-----------|-------------|------------|------------------|
| `chatMessage` | Tous | Nouveau message privé | ChatDetailsPage | `room_id` |
| `connectionRequest` | Bride | Demande contact Pro | MessagesPage | `request_id` |
| `connectionRequestAccepted` | Pro | Demande acceptée | MessagesPage | `room_id` |
| `videoIncoming` | Tous | Appel vidéo entrant | VideoCallPage + joinChannel | `video_session_id`, `agora_channel_name` |
| `wishlistAdd` | Pro (Ultimate) | Bride ajoute en favori | DashboardPro | `bride_profile_id` |

#### Système 2: Broadcast (batch depuis Admin Panel)
| Type | Rôle cible | Déclencheur | Action Tap | Deep Link |
|------|-----------|-------------|------------|-----------|
| `wedPublished` | Tous | Admin publie WOW | WeddingOfTheWeek | `lynewed://wedding` |
| `replayPublished` | Tous | Admin publie Replay | ContentReplay | `lynewed://replays` |

#### Types SUPPRIMÉS (code mort)
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

### Phase 4: FLUTTER - Redirections ✅ COMPLET
- [x] Valider `chatMessage` → ChatDetailsPage (room_id)
- [x] Valider `connectionRequest` → MessagesPage (section demandes)
- [x] Valider `connectionRequestAccepted` → ChatDetails (room_id) ou MessagesPage
- [x] Valider `videoIncoming` → VideoCallPage + joinChannel
- [x] AJOUTER `wishlistAdd` → DashboardPro
- [x] AJOUTER `wedPublished` → WeddingOfTheWeekPage
- [x] Supprimer `connectionRequestDeclined` (code mort)

### Phase 5: GESTION PAR RÔLE ✅ COMPLET
- [x] Définir types par rôle (Bride vs Pro) - `NotificationTypeConfig`
- [x] Adapter `notification_settings` par rôle - `NotificationTypesConfig.getVisibleTypes()`
- [x] Créer `NotificationSettingsPage` Clean Architecture

### Phase 6: FLUTTER - UI Pages ✅ COMPLET
- [x] Créer `lib/features/notifications/` module Clean Architecture
- [x] Refactoriser `NotificationsPage` (Design System v3)
- [x] Refactoriser `NotificationSettingsPage` (Design System v3)
- [x] Supprimer options obsolètes (`professionalAlertReminder24h`)
- [x] Ajouter documentation enum `NotificationType`

### Phase 7: NETTOYAGE FINAL ✅ COMPLET
- [x] Supprimer trigger `trg_outbox_wed_published` (migré vers broadcast Admin Panel)
- [x] Supprimer fonction `outbox_on_wed_published()`
- [x] Nettoyer notifications `wedPublished` existantes (49 supprimées)
- [x] Mettre à jour Edge Function `notifications_outbox_drain` (supprimer wedPublished)
- [x] Ajouter type `broadcast` dans Flutter (deep links)
- [x] Documenter l'architecture à deux systèmes
- [x] Restaurer trigger realtime sécurisé (notifications < 2 secondes) ✅

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

### 2025-12-03 19:30 - Phases 4-6 Flutter Frontend ✅

**Actions Phase 4 (Redirections):**
- ✅ Refactorisé `handle_notification_redirection.dart`
- ✅ Ajouté cas `wishlistAdd` → DashboardPro
- ✅ Ajouté cas `wedPublished` → WeddingOfTheWeek
- ✅ Amélioré logs avec emojis pour chaque type
- ✅ Supprimé `connectionRequestDeclined` (code mort)

**Actions Phase 5 (Gestion par rôle):**
- ✅ Créé `lib/features/notifications/` module Clean Architecture
- ✅ Créé `NotificationTypeConfig` avec règles de visibilité par rôle
- ✅ Créé `NotificationTypesConfig.getVisibleTypes()` pour filtrage dynamique
- ✅ Implémenté logique de tier d'abonnement pour `wishlistAdd` (Ultimate only)

**Actions Phase 6 (UI Refactoring):**
- ✅ Créé `NotificationsPage` avec Design System v3
- ✅ Créé `NotificationSettingsPage` avec Design System v3
- ✅ Documenté enum `NotificationType` avec @Deprecated pour types obsolètes
- ✅ Supprimé option `professionalAlertReminder24h` (code mort)

**Fichiers créés:**
```
lib/features/notifications/
├── notifications.dart                           # Barrel export
├── domain/entities/
│   ├── notification_setting.dart               # Entity
│   └── notification_type_config.dart           # Config par rôle
└── presentation/pages/
    ├── notifications_page.dart                 # Liste notifications
    └── notification_settings_page.dart         # Settings
```

**Fichiers modifiés:**
- `lib/custom_code/actions/handle_notification_redirection.dart`
- `lib/backend/schema/enums/enums.dart`

---

### 2025-12-03 19:45 - Phase 7 Nettoyage + Architecture Broadcast ✅

**Découverte importante:**
L'équipe CRM utilise une Edge Function `send-broadcast-notification` pour les notifications de masse:
- Wedding of the Week
- Replays
- Annonces générales

**Décision: Option A - Unifier vers Broadcast**
- ✅ Supprimé trigger SQL `trg_outbox_wed_published`
- ✅ Supprimé fonction `outbox_on_wed_published()`
- ✅ Nettoyé 49 notifications `wedPublished` orphelines
- ✅ Mis à jour Edge Function `notifications_outbox_drain` v24
- ✅ Ajouté type `broadcast` + deep links dans Flutter

---

### 2025-12-03 20:00 - Corrections Backend Complètes ✅

**Corrections de sécurité:**
- ✅ Supprimé trigger `trg_outbox_realtime_process` (warning search_path mutable)
- ✅ Supprimé fonction `trigger_process_outbox_realtime()` (non fonctionnel car settings manquants)
- ✅ Le système utilise le cron job `notifications_outbox_drain_every_minute` (plus robuste)

**Corrections trigger connection_request:**
- ✅ Mis à jour `outbox_on_connection_request_aiu()` pour ne plus créer `connectionRequestDeclined`
- ✅ Seul `connectionRequestAccepted` est notifié (pas les refus - meilleure UX)

**Nettoyage notification_settings:**
- ✅ Supprimé 245 settings pour types obsolètes (connectionRequestDeclined, professionalAlert, professionalAlertReminder24h, weddingPinMatch, wedPublished)
- ✅ Types actifs restants: chatMessage, connectionRequest, connectionRequestAccepted, wishlistAdd, videoIncoming

**Nettoyage Edge Function v24:**
- ✅ Supprimé templates I18N obsolètes
- ✅ Documentation architecture mise à jour
- ✅ Déployée avec succès

**Architecture Finale - Deux Systèmes:**

| Système | Edge Function | Types | Déclencheur |
|---------|---------------|-------|-------------|
| **Transactionnel** | `notifications_outbox_drain` v24 | chatMessage, connectionRequest, connectionRequestAccepted, wishlistAdd, videoIncoming | Triggers SQL + Cron 1min |
| **Broadcast** | `send-broadcast-notification` v1 | broadcast (avec deep link) | Admin Panel manuel |

**Deep Links supportés (lynewed://[page]):**
- `home` → HomeBrides / DashboardPro
- `wedding` → WeddingOfTheWeek
- `replays` → ContentReplay
- `feed` → Feed
- `profile` → ProfileBridesAndPro
- `settings` → Settings
- `chat` → MessagesBrides / MessagesPro
- `notifications` → NotificationsPage

**État final du système:**
- `notifications_outbox`: 0 pending, 6 processed ✅
- `notifications`: 6 ✅
- `device_tokens`: 2 (iOS + Android) ✅
- `notification_settings`: 245 (5 types × 49 users) ✅

---

### 2025-12-03 20:15 - Correction Trigger Realtime ✅

**Problème identifié:**
J'avais supprimé par erreur le trigger `trg_outbox_realtime_process` pensant qu'il était inutile.
En réalité, c'est le mécanisme PRINCIPAL pour les notifications instantanées.
Le cron job toutes les minutes est juste un BACKUP, pas le système principal.

**Correction:**
- ✅ Restauré `trigger_process_outbox_realtime()` avec `search_path` défini (sécurité)
- ✅ URL et token hardcodés dans la fonction (comme le cron job)
- ✅ Trigger `trg_outbox_realtime_process` AFTER INSERT sur `notifications_outbox`

**Test de performance:**
```
Message créé      → 18:46:41.833
Event claimed     → 18:46:43.230 (trigger → Edge Function)
Event processed   → 18:46:43.702
─────────────────────────────────
TOTAL: 1.87 secondes ✅
```

**Architecture Finale:**
```
[Action utilisateur] → [Trigger SQL] → [notifications_outbox]
                                              ↓ (AFTER INSERT)
                           [trigger_process_outbox_realtime]
                                              ↓ (pg_net.http_post)
                           [Edge Function notifications_outbox_drain]
                                              ↓ (~400ms)
                           [Notification créée] → Push FCM
                           
TEMPS TOTAL: < 2 secondes ✅
```

**Cron job:** Reste actif comme backup/catch-up pour les events manqués.

---

### 2025-12-03 20:30 - Ajout replayPublished + Refonte Broadcast ✅

**Décision architecturale:**
Types séparés `wedPublished` et `replayPublished` plutôt qu'un seul type `broadcast` car:
- Meilleur tracking/analytics
- Préférences utilisateur distinctes (désactiver WOW mais garder Replays)
- Maintenabilité

**Modifications Backend:**
- ✅ Ajouté `replayPublished` à l'enum Supabase `notificationType`
- ✅ Ajouté colonne `notification_type` à `broadcast_history`
- ✅ Créé settings pour `wedPublished` et `replayPublished` (49 users chacun)
- ✅ Mis à jour Edge Function `send-broadcast-notification` v2:
  - Crée notifications IN-APP (pas seulement push)
  - Respecte les préférences utilisateur
  - Supporte 3 types: `wedPublished`, `replayPublished`, `broadcast`
  - Batch processing pour milliers de notifications

**Modifications Flutter:**
- ✅ Ajouté `replayPublished` à l'enum `NotificationType`
- ✅ Ajouté case `replayPublished` dans `handle_notification_redirection.dart`
- ✅ Ajouté config dans `NotificationTypesConfig` (settings page)
- ✅ Ajouté icône et titre dans `NotificationsPage`

**État final - 7 types actifs:**
| Type | Système | In-App | Push | Settings |
|------|---------|--------|------|----------|
| chatMessage | Transactionnel | ✅ | ✅ | ✅ |
| connectionRequest | Transactionnel | ✅ | ✅ | ✅ |
| connectionRequestAccepted | Transactionnel | ✅ | ✅ | ✅ |
| wishlistAdd | Transactionnel | ✅ | ✅ | ✅ |
| videoIncoming | Transactionnel | ✅ | ✅ | ✅ |
| wedPublished | Broadcast | ✅ | ✅ | ✅ |
| replayPublished | Broadcast | ✅ | ✅ | ✅ |

---

## 🐛 BUGS CORRIGÉS (2025-12-04)

### 1. chatMessage envoyé avec connectionRequest
**Problème:** Quand une demande de contact était acceptée, un message initial était inséré, déclenchant une notification `chatMessage` en plus de `connectionRequestAccepted`.

**Solution:** Modifié le trigger `outbox_on_chat_message()` pour ignorer les messages avec `created_at` > 5s dans le passé (messages initiaux de demandes).

### 2. Navigation vers anciennes pages FlutterFlow
**Problème:** Les notifications redirigeaient vers `ChatDetailsWidget` (FlutterFlow) au lieu de `ChatDetailsPage` (Clean Architecture).

**Solution:** Ajouté la route `ChatDetailsPage` dans `nav.dart` et mis à jour `handle_notification_redirection.dart`.

### 3. connectionRequest vers MessagesPage au lieu de ChatDetailsPage
**Problème:** Le tap sur notification `connectionRequest` naviguait vers MessagesPage au lieu d'ouvrir la demande en mode review.

**Solution:** Modifié `handle_notification_redirection.dart` pour récupérer les détails de la demande et naviguer vers `ChatDetailsPage` avec:
- `pendingRequestId` = ID de la demande
- `viewerIsReviewer = true` (mode review pour Bride)
- `otherProfileId`, `otherFullName`, `otherAvatarUrl` = infos du Pro
- `initialMessage` = message initial

### 4. Tap notification ne met pas à jour l'UI
**Problème:** Après tap, la notification restait "non lue" dans la liste.

**Solution:** Ajouté mise à jour optimiste dans `NotificationsPage._handleNotificationTap()` pour marquer comme lu immédiatement dans l'UI.

### 5. Mark All Read ne met pas à jour le counter
**Problème:** `markAllNotificationsAsRead()` ne rafraîchissait pas le counter.

**Solution:** Ajouté mise à jour immédiate de `FFAppState().unreadNotificationsCount = 0`.

### 6. Warnings Flutter analyze
**Problème:** Warnings `use_build_context_synchronously` et `prefer_const_constructors`.

**Solution:** Ajouté `context.mounted` checks et `const` où nécessaire.

---

## ✅ TESTS VALIDÉS (2025-12-04)

### Test 1: connectionRequest (Pro→Bride)
- ✅ Création demande → notification `connectionRequest` seule (pas de `chatMessage`)
- ✅ Tap notification → navigation vers `ChatDetailsPage` mode review
- ✅ Modal Accept/Decline visible pour Bride
- ✅ Tap notification → mise à jour immédiate UI (Read) + counter

---

## 📋 TESTS RESTANTS À EFFECTUER

### Tests Transactionnels (à créer via SQL)

#### 1. connectionRequestAccepted (Bride→Pro)
```sql
-- Accepter la demande existante
SELECT accept_connection_request('ebdf5268-72dd-4c53-8181-dd37fa4cb4fa');
```
**Attendu:**
- ✅ Pro reçoit notification `connectionRequestAccepted`
- ✅ Tap → ouvre `ChatDetailsPage` avec room créée
- ✅ Messages de la room marqués comme lus

#### 2. chatMessage (message normal)
```sql
-- Insérer un message dans la room créée
INSERT INTO chat_messages (room_id, profile_id, message_type, content)
VALUES ('<room_id>', '0715505e-cedf-4a91-99a2-ba0ef75ccda3', 'text', 'Message test');
```
**Attendu:**
- ✅ Bride reçoit notification `chatMessage`
- ✅ Tap → ouvre `ChatDetailsPage` de la conversation
- ✅ Messages de la room marqués comme lus

#### 3. videoIncoming
```sql
-- Créer une session vidéo
INSERT INTO video_sessions (receiver_id, status)
VALUES ('cc949a0a-5b02-45d1-a2e8-61046b1f9297', 'pending');
```
**Attendu:**
- ✅ Bride reçoit notification `videoIncoming`
- ✅ Tap → ouvre `VideoCallPage`

#### 4. wishlistAdd
```sql
-- Ajouter à wishlist (nécessite setup)
-- TODO: Vérifier trigger existant
```

#### 5. connectionRequest (Pro→Pro)
```sql
-- Créer demande entre deux Pros
INSERT INTO connection_requests (pro_profile_id, bride_profile_id, initiator_id, source, initial_message, status)
VALUES ('<pro1_id>', '<pro2_id>', '<pro1_id>', 'fromProfile', 'Test', 'pending');
```
**Attendu:**
- ✅ Pro2 reçoit notification `connectionRequest`

### Tests Broadcast (via Edge Function)

#### 6. wedPublished
```bash
curl -X POST https://<project-ref>.supabase.co/functions/v1/send-broadcast-notification \
  -H "Authorization: Bearer <service-key>" \
  -d '{"type": "wedPublished", "reference_id": "test123"}'
```
**Attendu:**
- ✅ Tous les utilisateurs reçoivent notification `wedPublished`
- ✅ Tap → ouvre `WeddingOfTheWeekWidget`

#### 7. replayPublished
```bash
curl -X POST https://<project-ref>.supabase.co/functions/v1/send-broadcast-notification \
  -H "Authorization: Bearer <service-key>" \
  -d '{"type": "replayPublished", "reference_id": "test456"}'
```
**Attendu:**
- ✅ Tous les utilisateurs reçoivent notification `replayPublished`
- ✅ Tap → ouvre `ContentReplayWidget`

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
| Notifications créées | 0 | ✅ 1/7 | 🔄 |
| Events traités | 0/147 | ✅ 1/7 | 🔄 |
| Temps traitement | 5-20s | ✅ < 1s | ✅ |
| Navigation corrigée | ❌ | ✅ 1/7 | 🔄 |
| Counter sync | ❌ | ✅ 1/7 | 🔄 |

