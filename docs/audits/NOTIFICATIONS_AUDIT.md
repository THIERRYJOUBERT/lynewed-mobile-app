# AUDIT SYSTÈME DE NOTIFICATIONS - LYNEWED

**Date de l'audit:** 2025-12-03  
**Version:** 1.0  
**Statut:** ✅ AUDIT COMPLET  
**Projet Supabase:** `hekyovgnovhfhmkpfrna`

---

## 📊 RÉSUMÉ EXÉCUTIF

| Métrique | Valeur | État |
|----------|--------|------|
| Notifications in-app créées | **0** | 🔴 CRITIQUE |
| Events en attente (outbox) | **147** | 🔴 BLOQUÉS |
| Trigger realtime | **Actif mais timeout** | 🔴 CRITIQUE |
| Triggers source (chat, video, etc.) | **5/5** | ✅ OK |
| Types de notifications actifs | **6/10** | ⚠️ Code mort |
| Enums synchronisés | **Partiellement** | ⚠️ À corriger |

### Verdict Global
Le système de notifications est **NON FONCTIONNEL**. La cause racine est un **timeout pg_net de 5 secondes** alors que l'Edge Function traite des batches de 100 events en 5-20 secondes.

### 🔴 CAUSE RACINE IDENTIFIÉE (2025-12-03 17:31)
```
pg_net error: "Timeout of 5000 ms reached. Total time: 5000.380000 ms"
```
- **pg_net timeout:** 5 secondes
- **Edge Function temps réel:** 5-20 secondes (batch 100)
- **Résultat:** pg_net timeout → events restent bloqués

---

## 🔴 PROBLÈMES CRITIQUES

### 1. TIMEOUT PG_NET (5 secondes)

**Localisation:** Trigger `trg_outbox_realtime_process` → `pg_net.http_post`

**Erreur capturée:**
```
Timeout of 5000 ms reached. Total time: 5000.380000 ms
(DNS: 4ms, TCP/SSL: 9ms, HTTP: 4987ms)
```

**Impact:** 
- Le trigger appelle l'Edge Function via pg_net
- pg_net timeout après 5 secondes
- L'Edge Function continue en background mais pg_net ne reçoit pas la réponse
- Les events sont "claimed" mais jamais "processed"
- 147 events bloqués

**Solution:**
1. Réduire batch size de 100 → 1 (traiter 1 event par appel)
2. L'Edge Function doit terminer en < 2 secondes pour des notifs instantanées

**Note:** Le cron job `notifications_outbox_drain_every_minute` est désactivé et DOIT LE RESTER. Un cron toutes les minutes ne répond pas au besoin de notifications instantanées (< 5 secondes).

---

### 2. TABLE `notifications` VIDE

**État actuel:**
| Table | Rows | Non traités |
|-------|------|-------------|
| `notifications` | 0 | - |
| `notifications_outbox` | 147 | 147 (100%) |

**Analyse des events bloqués:**
- `claimed_at` rempli mais `processed_at = NULL`
- Aucun `last_error` enregistré
- Types d'events: `chatMessageCreated`, `connectionRequestAccepted`, `connectionRequestCreated`, `videoIncoming`

**Cause probable:**
L'Edge Function `notifications_outbox_drain` timeout (30s par défaut Supabase) lors du traitement de gros batches, mais le code ne gère pas correctement ce cas.

---

### 3. EDGE FUNCTION - PROBLÈMES IDENTIFIÉS

**Fichier:** `supabase/functions/notifications_outbox_drain/index.ts`

**Logs récents:**
- HTTP 200 (succès apparent)
- Temps d'exécution variable: 271ms → 19.298s
- Pas d'erreurs HTTP visibles

**Problèmes dans le code:**

#### 3.1 Batch trop grand
```typescript
// Ligne 203-207
const { data, error } = await supabase.rpc("claim_outbox_events", {
  p_batch_size: 100,  // ❌ Trop grand, cause des timeouts
  p_claim_ttl_minutes: 5,
  p_worker_id: workerId
});
```

#### 3.2 Erreurs silencieuses
```typescript
// Ligne 235-243
async function executeInAppInserts(actions) {
  // ...
  if (error) {
    console.error("executeInAppInserts error", error);
    return [];  // ❌ Erreur silencieuse, le traitement continue
  }
  // ...
}
```

---

## ⚠️ PROBLÈMES MODÉRÉS

### 4. ENUM DÉSYNCHRONISÉS

**ConnectionRequestSource:**
| Flutter | Supabase |
|---------|----------|
| `wishlist` | `fromWishlist` |
| `weddingPin` | `fromWedding` |
| `map` | `fromProfile` |
| `alert` | `fromAlert` |
| `proToPro` | *(n'existe pas)* |

**Fichiers concernés:**
- Flutter: `lib/backend/schema/enums/enums.dart` (lignes 61-67)
- Supabase: enum `connectionRequestSource`

---

### 5. CODE MORT - TYPES DE NOTIFICATIONS

| Type | Utilisé | Trigger Existe | Raison |
|------|---------|----------------|--------|
| `chatMessage` | ✅ | ✅ `outbox_on_chat_message` | Fonctionnel |
| `connectionRequest` | ✅ | ✅ `outbox_on_connection_request_aiu` | Fonctionnel |
| `connectionRequestAccepted` | ✅ | ✅ | Fonctionnel |
| `connectionRequestDeclined` | ✅ | ✅ | Fonctionnel |
| `wishlistAdd` | ✅ | ✅ `outbox_on_wishlist_add` | Fonctionnel |
| `videoIncoming` | ✅ | ✅ `outbox_on_video_session_created` | Fonctionnel |
| `professionalAlert` | ❌ | ❌ | **CODE MORT** - Jamais déclenché |
| `professionalAlertReminder24h` | ❌ | ❌ | **CODE MORT** - Pas de cron job |
| `wedPublished` | ❌ | ❌ | **CODE MORT** - Jamais déclenché |
| `weddingPinMatch` | ❌ | ❌ | **CODE MORT** - Concept obsolète |

---

### 6. MARK READ NON LIÉ AUX CONVERSATIONS

**Problème:** Ouvrir `ChatDetailsPage` ne marque pas automatiquement les notifications `chatMessage` de cette room comme lues.

**Fichiers concernés:**
- `lib/custom_code/actions/mark_notification_as_read.dart` - Marque une seule notification
- `lib/pages/chat/chat_details/chat_details_widget.dart` - Ne marque pas les notifications

**Solution requise:**
Créer RPC `mark_notifications_read_by_room(room_id)` et l'appeler à l'ouverture de ChatDetailsPage.

---

### 7. PAS DE REALTIME SUR NOTIFICATIONS

**Problème:** Le badge de notifications n'est pas mis à jour en temps réel.

**État actuel:**
- Le compteur est rafraîchi uniquement sur réception de push ou navigation
- Pas de subscription Supabase Realtime sur la table `notifications`

---

### 8. REDIRECTION INCOMPLÈTE

**Fichier:** `lib/custom_code/actions/handle_notification_redirection.dart`

**Cas non gérés:**
| Type | Comportement actuel | Attendu |
|------|---------------------|---------|
| `wishlistAdd` | ❌ Non géré (fallback Dashboard) | → Profil de la Bride |
| `connectionRequest` sans room_id | → MessagesPage générique | → Section "Demandes" |
| `professionalAlertReminder24h` | ❌ Non géré | À supprimer (code mort) |

---

## 🏗️ ARCHITECTURE ACTUELLE

### Backend Supabase

#### Tables
```
notifications
├── id (uuid, PK)
├── profile_id (uuid, FK → profiles)
├── type (notificationType enum)
├── payload (jsonb)
├── is_read (boolean, default false)
└── created_at (timestamptz)

notifications_outbox
├── id (uuid, PK)
├── event_type (text)
├── payload (jsonb)
├── event_key (text, unique)
├── attempts (int, default 0)
├── last_error (text, nullable)
├── claimed_at (timestamptz, nullable)
├── claimed_by (text, nullable)
├── processed_at (timestamptz, nullable)
└── created_at (timestamptz)
```

#### Triggers (Tous actifs ✅)
| Trigger | Table Source | Fonction |
|---------|--------------|----------|
| `trg_outbox_chat_msg` | `chat_messages` | `outbox_on_chat_message()` |
| `trg_outbox_on_connection_request_aiu` | `connection_requests` | `outbox_on_connection_request_aiu()` |
| `trg_wishlist_items_after_insert_enqueue_notification` | `wishlist_items` | `outbox_on_wishlist_add()` |
| `trg_outbox_on_video_session` | `video_sessions` | `outbox_on_video_session_created()` |
| `trg_outbox_realtime_process` | `notifications_outbox` | `trigger_process_outbox_realtime()` |

#### Edge Function
- **Nom:** `notifications_outbox_drain`
- **Version:** 18
- **Déclenchement:** Trigger realtime + Cron (désactivé)

### Frontend Flutter

#### Fichiers clés
```
lib/
├── custom_code/actions/
│   ├── init_push_notifications.dart      ✅ Complet
│   ├── get_notifications_action.dart     ✅ Complet
│   ├── handle_notification_redirection.dart  ⚠️ Incomplet
│   ├── mark_notification_as_read.dart    ✅ Complet
│   ├── mark_all_notifications_as_read.dart  ✅ Complet
│   └── get_unread_notifications_count.dart  ✅ Complet
├── pages/shared/
│   ├── notifications_page/               ⚠️ FlutterFlow legacy
│   └── notification_settings/            ⚠️ FlutterFlow legacy
└── backend/schema/enums/enums.dart       ⚠️ Désynchronisé
```

---

## 📋 CHECKLIST AUDIT

### Backend Supabase
- [x] Triggers existent et sont actifs
- [x] Fonctions trigger correctement implémentées
- [x] `notifications_outbox` reçoit les events ✅
- [ ] `notifications` reçoit les inserts ❌ **0 rows**
- [x] Logs Edge Function analysés (pas d'erreur HTTP)
- [ ] Cron job actif ❌ **DÉSACTIVÉ**

### Frontend Flutter
- [x] `init_push_notifications.dart` - Initialisation correcte ✅
- [x] `handle_notification_redirection.dart` - Partiellement ⚠️
- [x] `notifications_page_widget.dart` - Fonctionnel (si données existent)
- [x] `notification_settings_widget.dart` - Fonctionnel
- [ ] Enums synchronisés ❌ **ConnectionRequestSource**

---

## 🔧 CONFIGURATION ACTUELLE

### notification_settings (49 utilisateurs configurés)
| Type | Users | In-App Enabled | Push Enabled |
|------|-------|----------------|--------------|
| chatMessage | 49 | 49 (100%) | 49 (100%) |
| connectionRequest | 49 | 49 (100%) | 49 (100%) |
| connectionRequestAccepted | 49 | 49 (100%) | 49 (100%) |
| connectionRequestDeclined | 49 | 49 (100%) | 49 (100%) |
| wishlistAdd | 49 | 49 (100%) | 49 (100%) |
| videoIncoming | 49 | 49 (100%) | 49 (100%) |
| professionalAlert | 49 | 49 (100%) | 49 (100%) |
| professionalAlertReminder24h | 49 | 49 (100%) | 49 (100%) |
| wedPublished | 49 | 49 (100%) | 49 (100%) |
| weddingPinMatch | 49 | 49 (100%) | 49 (100%) |

---

## 📈 PROCHAINES ÉTAPES

Voir **PLAN D'ACTION** ci-dessous pour les corrections à apporter.

---

## 🎯 PLAN D'ACTION PROPOSÉ

### Phase 1: CORRECTIONS URGENTES (2-3h)
**Objectif:** Rétablir le fonctionnement de base

1. **Activer le cron job**
   ```sql
   SELECT cron.alter_job(6, active => true);
   ```

2. **Traiter les events bloqués manuellement**
   - Reset les `claimed_at` pour permettre le retraitement
   - Réduire le batch size dans l'Edge Function

3. **Corriger l'Edge Function**
   - Réduire `p_batch_size` de 100 à 20
   - Améliorer la gestion d'erreurs

### Phase 2: NETTOYAGE CODE MORT (1-2h)
**Objectif:** Supprimer les types inutilisés

1. **Supprimer de l'enum Supabase:**
   - `professionalAlert`
   - `professionalAlertReminder24h`
   - `wedPublished`
   - `weddingPinMatch`

2. **Supprimer de l'enum Flutter:**
   - Mêmes types
   - Synchroniser `ConnectionRequestSource`

3. **Nettoyer `notification_settings`:**
   - Supprimer les lignes pour types obsolètes

### Phase 3: AMÉLIORATIONS FONCTIONNELLES (4-6h)
**Objectif:** Compléter les features manquantes

1. **Créer RPC `mark_notifications_read_by_room`**
2. **Appeler cette RPC à l'ouverture de ChatDetailsPage**
3. **Ajouter subscription Realtime sur `notifications`**
4. **Compléter `handleNotificationRedirection`:**
   - Gérer `wishlistAdd` → Profil Bride
   - Améliorer navigation `connectionRequest`

### Phase 4: REFACTORISATION UI (8-12h)
**Objectif:** Migrer vers Design System v3

1. **Refactoriser `NotificationsPage`**
   - Utiliser `lib/core/design/`
   - Supprimer références FlutterFlow
   - Grouper notifications par conversation

2. **Refactoriser `NotificationSettingsWidget`**
   - Supprimer options pour types obsolètes
   - Appliquer Design System

---

## ⏱️ ESTIMATION TOTALE

| Phase | Heures | Priorité |
|-------|--------|----------|
| Phase 1: Corrections urgentes | 2-3h | 🔴 CRITIQUE |
| Phase 2: Nettoyage code mort | 1-2h | 🟡 HAUTE |
| Phase 3: Améliorations | 4-6h | 🟡 MOYENNE |
| Phase 4: Refactorisation UI | 8-12h | 🟢 NORMALE |
| **TOTAL** | **15-23h** | - |

---

*Audit réalisé par Cascade - 2025-12-03*
