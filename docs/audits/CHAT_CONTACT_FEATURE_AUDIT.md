# Chat & Contact Feature Audit

**Document créé:** 2025-12-02  
**Version:** v1.5 (Module Complet)  
**Dernière mise à jour:** 2025-12-03 15:30  
**Objectif:** Audit complet du module Chat & Contact pour préparer la refactorisation Clean Architecture

---

## ⚠️ DÉCISIONS VALIDÉES (2025-12-02)

> Les sections 4, 5, 9 et 10 ont été mises à jour suite aux décisions QCM validées.

---

## 🔧 CORRECTIONS RÉCENTES (2025-12-03)

### Message Spacing ✅
- Logique corrigée pour liste inversée (`reverse: true`)
- **8px** entre messages du même utilisateur
- **30px** entre messages d'utilisateurs différents
- Renommé `_isFirstFromSender` → `_needsLargeSpacing`

### Navigation Chat depuis Map Sheets ✅
- `MapActionsService.navigateToChat()` utilise maintenant `action_blocks.contactChatRoom()`
- Charge correctement les infos du contact (nom, avatar, rôle)
- Fonctionne pour: `professional_details_sheet`, `wedding_details_sheet`, `alert_details_sheet`

### Bug "Waiting for response" ✅
- `pendingRequestId` et `viewerIsReviewer` passés uniquement si `status == requestPending`
- Évite l'affichage incorrect de "Waiting for response..." pour les rooms actives

### Flux Pro→Bride: Status `requiresRequest` ✅
- Ajouté `requiresRequest` à l'enum `ChatEntryStatus` (FlutterFlow)
- Ajouté parsing dans `open_or_prepare_contact_action.dart`
- `ContactRequestSheet` intégré dans `lib/actions/actions.dart`
- Messages UX appropriés:
  - `requiresRequest` → Ouvre `ContactRequestSheet`
  - `notAllowed` + `INSUFFICIENT_TIER` → Message sur abonnement Premium requis
  - `blocked` → "Contact bloqué"

### Validation Finale Module (2025-12-03 15:30) ✅
- `ContactRequestSheet` intégré et fonctionnel
- Tous les sheets audités Design System v3
- `MessageActionsSheet` corrigé (border radius 4px, couleurs DS v3)
- `LynewedBorders.xs` (4px) ajouté au Design System
- Modération complète: report, block, unblock
- Backend RPC validé: `create_contact_request`, `accept_connection_request`, `decline_connection_request`

### Flux Contact Pro→Bride - VALIDATION COMPLÈTE (2025-12-03 16:00) ✅
- **ContactRequestSheet**: Flux complet validé
  - Sheet s'ouvre pour Pro Premium+ contactant Bride
  - Validation message (10+ caractères) 
  - Source correcte passée (fromWedding, fromProfile, etc.)
  - Textes traduits en anglais
- **ContactRequestReviewSheet**: Flux acceptation validé
  - Demandes visibles dans MessagesPage section "Contact Requests"
  - Accept crée room ET insère message initial
  - Decline supprime demande
- **Backend RPCs**: Corrigées et optimisées
  - `accept_connection_request`: Insère `initial_message` comme 1er message
  - `get_rooms_with_unread_counts`: Inclut rooms sans messages
  - `conn_req_before_insert`: Nouvelles valeurs enum
  - Données test nettoyées (demandes anormales supprimées)
- **Frontend Core**: Actions et traductions
  - `actions.dart`: Param `source`, séparation `roomReady`/`requestPending`
  - `chat_enums.dart`: `displayLabel` traduits EN
  - `contact_request_avatar.dart`: Labels "Waiting"/"New"
  - `chat_remote_datasource.dart`: Parsing `{items: [...]}` corrigé

### UX Block/Report - RÉORGANISATION TERMINÉE (2025-12-03 17:45) ✅
- **Problème résolu**: Block action déplacée de MessageActionsSheet vers ConversationActionsSheet
- **Implémentation finale**:
  - ✅ `MessageActionsSheet`: Report Message uniquement (ouvre `ReportMessageSheet`)
  - ✅ `ConversationActionsSheet`: Report User + Block User + Archive
  - ✅ `ArchivedSheet` (ex-BlockedUsersSheet): Affiche conversations archivées + users bloqués
  - ✅ Actions Unblock/Restore fonctionnelles avec mise à jour UI temps réel
  - ✅ `ReportMessageSheet` créé avec même design que `ReportUserSheet`
- **Backend corrigé**:
  - ✅ RPC `get_pending_contact_requests`: Logique corrigée (Bride voit demandes de Pros uniquement)
  - ✅ 9 demandes invalides supprimées (initiées par brides - impossible selon règles métier)

---

## Table des matières
1. [Résumé Exécutif](#1-résumé-exécutif)
2. [Architecture Backend](#2-architecture-backend)
3. [Architecture Frontend](#3-architecture-frontend)
4. [Logiques Métier (VALIDÉ)](#4-logiques-métier)
5. [Modération (VALIDÉ)](#5-modération)
6. [Notifications](#6-notifications)
7. [Médias et Stockage](#7-médias-et-stockage)
8. [Agora Vidéo (Préservation)](#8-agora-vidéo-préservation)
9. [Gaps et Problèmes Identifiés (MIS À JOUR)](#9-gaps-et-problèmes-identifiés)
10. [Plan de Refactorisation (MIS À JOUR)](#10-plan-de-refactorisation)

---

## 1. Résumé Exécutif

### État Actuel
| Aspect | État | Commentaire |
|--------|------|-------------|
| Backend | ✅ Fonctionnel | Tables, RPCs, triggers en place |
| Frontend | ⚠️ FlutterFlow | Code non-Clean Architecture |
| Logique Contact | ⚠️ Complexe | Trigger `on_first_message_pro_to_bride` crée connexions auto |
| Modération | ❌ Incomplet | Signalement messages OK, blocage OK, ticket CRM NON |
| Notifications | ⚠️ Partiellement | Outbox en place, implémentation à vérifier |
| Médias | ✅ Fonctionnel | Images + Audio via Storage |
| Agora Vidéo | ✅ Fonctionnel | À ne PAS toucher |

### Fichiers Clés
- **Pages:** `chat_details_widget.dart`, `messages_brides_widget.dart`, `messages_pro_widget.dart`
- **Widgets Custom:** `chat_message_list.dart` (~1270 lignes), `chat_composer_widget.dart` (~578 lignes)
- **Actions:** `open_or_prepare_contact_action.dart`, `send_text_message_action.dart`, `report_message_action.dart`

### Estimation Refactorisation
- **Durée estimée:** 40-60 heures
- **Complexité:** Élevée (logique de contact enchevêtrée avec triggers backend)

---

## 2. Architecture Backend

### 2.1 Tables Principales

#### `chat_rooms` (20 rows)
```sql
id: uuid (PK, default gen_random_uuid())
type: text CHECK (type IN ('private', 'public'))
name: text (nullable)
is_active: boolean (default true)
created_at: timestamptz (default now())
```

#### `chat_room_participants` (40 rows)
```sql
room_id: uuid (FK → chat_rooms.id)
profile_id: uuid (FK → profiles.id)
conversation_status: conversationStatus ENUM (default 'active')
  -- Valeurs: pending, active, declined, blocked, reportedPending, archived
joined_at: timestamptz (default now())
last_read_at: timestamptz (nullable)
-- PK: (room_id, profile_id)
```

#### `chat_messages` (30 rows)
```sql
id: bigint (PK, auto-increment)
room_id: uuid (FK → chat_rooms.id)
profile_id: uuid (FK → profiles.id, nullable)
content: text (nullable)
message_type: messageType ENUM
  -- Valeurs: text, image, audio
attachment_url: text (nullable)
is_deleted: boolean (default false)
created_at: timestamptz (default now())
```

#### `connection_requests` (10 rows)
```sql
id: uuid (PK, default gen_random_uuid())
pro_profile_id: uuid (FK → profiles.id)
bride_profile_id: uuid (FK → profiles.id)
initiator_id: uuid (FK → profiles.id)
source: connectionRequestSource ENUM
  -- Valeurs: wishlist, weddingPin, map, alert, proToPro
source_id: uuid (nullable)
initial_message: text (nullable, max 1000 chars)
status: connectionRequestStatus ENUM (default 'pending')
  -- Valeurs: pending, accepted, declined
created_at: timestamptz (default now())
responded_at: timestamptz (nullable)
```

#### `public_chat_rooms` (liaison rooms publiques)
```sql
chat_room_id: uuid (FK → chat_rooms.id)
title: text
cover_image_url: text (nullable)
audience_role: userRole ENUM (default 'bride')
is_active: boolean (default true)
created_at: timestamptz (default now())
```

#### `reports` (signalements)
```sql
id: uuid (PK, default gen_random_uuid())
reporter_profile_id: uuid (FK → profiles.id)
reported_message_id: bigint (FK → chat_messages.id)
reason: text (nullable)
status: contentModerationStatus ENUM (default 'pendingReview')
created_at: timestamptz (default now())
```

#### `user_blocks` (blocages)
```sql
blocker_profile_id: uuid (FK → profiles.id)
blocked_profile_id: uuid (FK → profiles.id)
created_at: timestamptz (default now())
-- PK: (blocker_profile_id, blocked_profile_id)
```

#### `video_sessions` (10 rows)
```sql
id: uuid (PK, default gen_random_uuid())
initiator_id: uuid (FK → profiles.id)
receiver_id: uuid (FK → profiles.id)
status: videoSessionStatus ENUM (default 'pending')
  -- Valeurs: pending, accepted, declined, missed, completed, cancelled
agora_channel_name: text (unique)
created_at: timestamptz (default now())
accepted_at: timestamptz (nullable)
completed_at: timestamptz (nullable)
```

### 2.2 Enums Critiques

```sql
-- conversationStatus
pending | active | declined | blocked | reportedPending | archived

-- connectionRequestStatus  
pending | accepted | declined

-- connectionRequestSource
wishlist | weddingPin | map | alert | proToPro

-- messageType
text | image | audio

-- videoSessionStatus
pending | accepted | declined | missed | completed | cancelled

-- contentModerationStatus
pendingReview | reviewed | dismissed
```

### 2.3 RLS Policies

#### `chat_messages`
| Policy | Cmd | Description |
|--------|-----|-------------|
| `chat_messages_select` | SELECT | Room publique si bride OU participant ET non bloqué |
| `chat_messages_insert` | INSERT | Permis (vérifié par trigger) |
| `chat_messages_update_self` | UPDATE | Seulement ses propres messages |
| `chat_messages_delete_self` | DELETE | Seulement ses propres messages |

#### `chat_room_participants`
| Policy | Cmd | Description |
|--------|-----|-------------|
| `chat_participants_select` | SELECT | Soi-même OU room publique |
| `chat_participants_insert` | INSERT | Permis |
| `chat_participants_update` | UPDATE | Seulement ses propres entrées |

#### `connection_requests`
| Policy | Cmd | Description |
|--------|-----|-------------|
| `conn_req_parties_read` | SELECT | Pro ou Bride impliqué |
| `conn_req_bride_update` | UPDATE | Bride seulement |
| `conn_req_write_pro_or_bride_self` | INSERT | Permis |

#### `reports` & `user_blocks`
- Owner peut tout faire (reporter/blocker = auth.uid())

### 2.4 Triggers

#### `trg_on_first_msg_pro_bride` (chat_messages INSERT) ⚠️ CRITIQUE
```sql
-- Fonction: on_first_message_pro_to_bride()
-- Comportement:
-- 1. Si conversation privée Pro↔Bride
-- 2. Si c'est le PREMIER message de la room
-- 3. Si le PRO envoie → créer connection_request automatiquement
-- 4. Mettre conversation_status à 'pending' pour les deux
-- 5. Si le Pro essaie d'envoyer un 2e message pendant pending → BLOQUÉ (exception PENDING_REQUEST_LIMIT)
-- 6. Premier message DOIT être du texte (exception FIRST_MESSAGE_TEXT_ONLY)
```

**⚠️ IMPACT:** Ce trigger crée automatiquement des demandes de contact, ce qui peut être confus car le frontend n'a pas de contrôle direct.

#### `trg_outbox_chat_msg` (chat_messages INSERT)
```sql
-- Fonction: outbox_on_chat_message()
-- Ajoute un event dans notifications_outbox pour push notification
```

#### `trg_handle_message_report` (reports INSERT)
```sql
-- Fonction: handle_message_report()
-- Marque automatiquement le message signalé comme is_deleted=true
```

#### `trg_conn_req_before_insert` (connection_requests INSERT)
```sql
-- Fonction: conn_req_before_insert()
-- Validation avant insertion de demande
```

#### `trg_outbox_on_connection_request_aiu` (connection_requests INSERT/UPDATE)
```sql
-- Fonction: outbox_on_connection_request_aiu()
-- Notification pour nouvelles demandes/réponses
```

### 2.5 RPC Functions

| Fonction | Description | Paramètres |
|----------|-------------|------------|
| `open_or_prepare_contact_context` | Point d'entrée principal pour initier un contact | `p_target: uuid` |
| `accept_connection_request` | Bride accepte une demande | `p_request_id: uuid` |
| `decline_connection_request` | Bride refuse une demande | `p_request_id: uuid` |
| `get_pending_contact_requests` | Liste demandes en attente | - |
| `get_public_chat_rooms_for_brides` | Liste rooms publiques | - |
| `handle_message_report` | Trigger report (marque deleted) | - |

#### Détail `open_or_prepare_contact_context`
```sql
-- Retourne JSONB avec:
{
  status: 'roomReady' | 'requestPending' | 'notAllowed' | 'blocked' | 'error',
  roomId: uuid,
  requestId: uuid (si pending),
  otherProfileId: uuid,
  otherFullName: text,
  otherAvatarUrl: text,
  otherRole: userRole,
  isPublic: boolean,
  isRoomEmpty: boolean,
  firstMessageTextOnly: boolean,
  limitToSingleInitialMessage: boolean,
  viewerIsReviewer: boolean,
  conversationStatus: conversationStatus,
  reason: text (si erreur)
}

-- Logique:
-- 1. Vérifier auth, target, self-contact, blocage
-- 2. Chercher room privée existante
-- 3. Si pas de room → créer selon règles:
--    - Pro→Bride: Premium+ requis, firstTextOnly=true, limitSingle=true
--    - Bride→Pro: Toujours OK, firstTextOnly=true
--    - Pro→Pro: Premium+ requis
-- 4. Vérifier s'il y a une demande pending
-- 5. Retourner contexte complet
```

---

## 3. Architecture Frontend

### 3.1 Pages Principales

#### `ChatDetailsWidget` (chat_details_widget.dart - 777 lignes)
**Chemin:** `lib/pages/shared/chat_details/`  
**Route:** `/chatDetails`

**Paramètres:**
```dart
String? roomId
bool isPublic (default: false)
String? requestId
String? otherProfileId
bool isRoomEmpty (default: false)
bool firstMessageTextOnly (default: false)
bool viewerIsReviewer (default: false)
```

**Fonctionnalités:**
- Affiche header avec avatar/nom de l'autre participant
- Intègre `ChatMessageList` (widget custom)
- Intègre `ChatComposerWidget` (widget custom)
- Bouton appel vidéo (icône caméra) si room privée
- Gère les rooms publiques (header noir, titre salon)
- Met à jour `last_read_at` à l'ouverture

#### `MessagesBridesWidget` (messages_brides_widget.dart - 622 lignes)
**Chemin:** `lib/pages/bride/messages_brides/`  
**Route:** `/messagesBrides`

**Fonctionnalités:**
- Section "Contact request" (liste horizontale avatars)
- Section "Conversations" (liste verticale rooms actives)
- Long press → `ConversationActionsSheetWidget` (archiver)
- Filtre: `conversationStatus == active` ET `roomType == private`
- Pull-to-refresh

#### `MessagesProWidget` (messages_pro_widget.dart - 620 lignes)
**Chemin:** `lib/pages/pro/messages_pro/`  
**Route:** `/messagesPro`

**Fonctionnalités:** Quasi identique à MessagesBrides

**⚠️ OBSERVATION:** Les deux pages sont presque identiques (code dupliqué). À unifier en une seule page paramétrable.

### 3.2 Widgets Custom

#### `ChatMessageList` (1270 lignes)
**Chemin:** `lib/custom_code/widgets/chat_message_list.dart`

**Fonctionnalités:**
- Affichage messages avec pagination (scroll infini vers le haut)
- Cache mémoire par room (`_InMemoryChatCache`)
- Realtime subscription (INSERT/UPDATE/DELETE)
- Support des 3 types de messages (text, image, audio)
- Gestion des URLs signées pour médias
- Mode "demande de contact" (affiche initial_message + boutons Accept/Decline)
- Groupement visuels des messages par jour/auteur
- Long press → callback pour actions

**Points d'attention:**
- Code très long et complexe
- Mélange logique de cache, realtime, UI
- Gestion du mode "request" intégrée directement

#### `ChatComposerWidget` (578 lignes)
**Chemin:** `lib/custom_code/widgets/chat_composer_widget.dart`

**Fonctionnalités:**
- Input texte avec placeholder
- Bouton ajout images (multi-select)
- Bouton micro pour enregistrement audio
- Preview images sélectionnées avec suppression
- Preview audio avant envoi
- Logique verrouillage si:
  - Room publique et user pas bride
  - Demande de contact pending
- Règle "firstMessageTextOnly" appliquée
- Après envoi 1er message Pro→Bride → refresh contexte pour récupérer requestId

### 3.3 Sheets de Conversation

#### `ConversationActionsSheetWidget`
**Chemin:** `lib/conversation_sheet/conversation_actions_sheet/`
- Option: Archive conversation

#### `OtherMessageActionsSheetWidget`
**Chemin:** `lib/conversation_sheet/other_message_actions_sheet/`
- Option: Report message (appelle `reportMessageAction`)
- **⚠️ MANQUE:** Option bloquer utilisateur

#### `MyMessageActionsSheetWidget`
**Chemin:** `lib/conversation_sheet/my_message_actions_sheet/`
- Option: Delete message (appelle `deleteOwnMessageAction`)

### 3.4 Actions Custom

| Action | Fichier | Description |
|--------|---------|-------------|
| `openOrPrepareContactAction` | open_or_prepare_contact_action.dart | Appelle RPC, parse réponse en `ChatEntryContextStruct` |
| `sendTextMessageAction` | send_text_message_action.dart | Insert message type=text |
| `uploadAndSendImagesAction` | (non lu) | Upload images + insert messages |
| `uploadAndSendAudioAction` | (non lu) | Upload audio + insert message |
| `reportMessageAction` | report_message_action.dart | Insert dans `reports` (trigger marque deleted) |
| `blockUserAction` | block_user_action.dart | Upsert dans `user_blocks` |
| `unblockUserAction` | unblock_user_action.dart | Delete de `user_blocks` |
| `archiveConversationAction` | archive_conversation_action.dart | Met `conversation_status = 'archived'` |
| `deleteOwnMessageAction` | delete_own_message_action.dart | Met `is_deleted = true` |
| `getPendingContactRequestsAction` | get_pending_contact_requests_action.dart | Liste demandes pending |
| `getRoomsWithUnreadCountsAction` | (non lu) | Liste conversations avec compteurs |

### 3.5 Structs (DataTypes)

#### `ChatEntryContextStruct`
```dart
ChatEntryStatus? status  // roomReady, requestPending, notAllowed, blocked, error
String roomId
String requestId
bool isPublic
String otherProfileId
String otherFullName
String otherAvatarUrl
UserRole? otherRole
bool isRoomEmpty
bool firstMessageTextOnly
bool limitToSingleInitialMessage
bool viewerIsReviewer
ConversationStatus? conversationStatus
String reason
```

#### `ConversationListItemStruct`
```dart
String roomId
RoomType? roomType
ConversationStatus? conversationStatus
int unreadCount
MessageType? lastMessageType
String lastMessageText
DateTime? lastMessageAt
String otherProfileId
String otherFullName
String otherAvatarUrl
UserRole? otherRole
String publicTitle
String publicCoverUrl
UserRole? audienceRole
```

### 3.6 Action Blocks (lib/actions/actions.dart)

#### `contactChatRoom`
Utilisé depuis les sheets de la map (professional_details, alert_details, wedding_details):
```dart
1. Appelle openOrPrepareContactAction(targetProfileId)
2. Si roomReady ou requestPending → navigate to ChatDetails
3. Sinon → showDialog avec erreur
```

#### `contactRoomChatMessagerie`
Utilisé depuis les pages Messages:
```dart
// Même logique que contactChatRoom
```

---

## 4. Logiques Métier ✅ VALIDÉ

### 4.1 Plans d'Abonnement (Corrigé)

**Plans actifs pour les Professionnels:**
| Plan | Description |
|------|-------------|
| `inactive` | Pas d'abonnement actif |
| `earlyAccess` | Premier niveau payant |
| `premiumVisibility` | Visibilité accrue + contact Bride |
| `ultimateAccess` | Accès complet |

> ⚠️ **TODO:** Nettoyer les enums Supabase et Flutter pour avoir exactement ces 4 valeurs (supprimer `trial`). Voir PROJECT_TODO.

### 4.2 Règles de Contact ✅ VALIDÉ

#### Bride → Pro (Contact Direct)
| Condition | Résultat |
|-----------|----------|
| Bride avec compte actif | ✅ Peut contacter n'importe quel Pro visible |
| Bride inactive | ❌ Ne peut pas contacter |

**Flux:**
```
1. Bride tap "Contacter" sur profil Pro
2. → Création room directe (pas de demande)
3. → Navigation vers ChatDetails
4. → Conversation ouverte, messages libres
```

#### Pro → Bride (Demande de Contact) ⚠️ NOUVEAU FLUX
| Plan | Peut initier contact Bride? |
|------|----------------------------|
| `inactive` | ❌ Non |
| `earlyAccess` | ❌ Non (mais peut RÉPONDRE si contacté) |
| `premiumVisibility` | ✅ Oui (via demande) |
| `ultimateAccess` | ✅ Oui (via demande) |

**Flux (NOUVEAU - remplace le trigger actuel):**
```
1. Pro (Premium+) tap "Contacter" sur profil Bride (depuis wedding, wishlist...)
2. → Sheet "Demande de contact" s'ouvre (PAS navigation vers chat)
   - Champ texte: "Message d'introduction" (OBLIGATOIRE, pas de pré-rempli)
   - Source auto-détectée et affichée (ex: "Depuis un mariage")
3. Pro valide → connection_request créée (status: pending)
4. → Toast confirmation "Demande envoyée"
5. → Pro reste sur la page actuelle (pas de navigation)
6. Bride reçoit notification "Nouvelle demande de contact de [Pro]"
7. Bride voit demande dans onglet "Demandes" avec message d'intro
8. Bride tap → Sheet avec message + boutons Accept/Decline
9. Si Accept:
   - connection_request.status = 'accepted'
   - Room créée, conversation_status = 'active'
   - Les deux peuvent écrire librement
10. Si Decline:
    - connection_request.status = 'declined'
    - Pas de room créée
    - Pro peut re-demander? (à définir)
```

#### Pro → Pro (Contact Direct)
| Plan | Peut contacter autre Pro? |
|------|--------------------------|
| `inactive` | ❌ Non |
| `earlyAccess` | ✅ Oui (contact direct) |
| `premiumVisibility` | ✅ Oui (contact direct) |
| `ultimateAccess` | ✅ Oui (contact direct) |

**Flux:**
```
1. Pro tap "Contacter" sur profil Pro (depuis alert, profil...)
2. → Création room directe (PAS de demande)
3. → Navigation vers ChatDetails
4. → Conversation ouverte, messages libres
```

### 4.3 Sources de Contact ✅ VALIDÉ

**Sources conservées (4):**

| Source | Nouveau nom | Contexte | Type de contact |
|--------|-------------|----------|-----------------|
| `wishlist` | `fromWishlist` | Pro voit qu'il est en favoris d'une Bride → demande contact | Demande (Pro→Bride) |
| `wedding` | `fromWedding` | Pro voit mariage public intéressant → demande contact | Demande (Pro→Bride) |
| `alert` | `fromAlert` | Pro répond à alerte d'entraide d'un autre Pro | Direct (Pro→Pro) |
| `profile` | `fromProfile` | Contact depuis profil (Bride→Pro ou Pro→Pro) | Direct |

**Règles par source:**
| Source | Initiateur | Cible | Type |
|--------|------------|-------|------|
| `fromWishlist` | Pro (Premium+) | Bride | Demande |
| `fromWedding` | Pro (Premium+) | Bride | Demande |
| `fromAlert` | Pro (tous) | Pro | Direct |
| `fromProfile` | Bride ou Pro | Pro | Direct |

> **Note:** La wishlist ne crée PAS automatiquement de demande. Le Pro doit faire la demande manuellement depuis son dashboard.

### 4.4 Permissions par Abonnement ✅ VALIDÉ

| Action | Inactive | EarlyAccess | PremiumVisibility | UltimateAccess |
|--------|----------|-------------|-------------------|----------------|
| Être visible sur la map | ❌ | ✅ | ✅ | ✅ |
| Voir les pros sur map | ✅ | ✅ | ✅ | ✅ |
| Voir les mariages visibles | ❌ | ❌ | ✅ | ✅ |
| **Contacter une Bride** | ❌ | ❌ | ✅ | ✅ |
| **Contacter un Pro** | ❌ | ✅ | ✅ | ✅ |
| **Répondre si contacté** | ✅ | ✅ | ✅ | ✅ |
| Créer des alertes | ❌ | ✅ | ✅ | ✅ |
| Répondre aux alertes | ✅ | ✅ | ✅ | ✅ |
| Appel vidéo | ❌ | ❌ | ✅ | ✅ |

### 4.5 Rooms Publiques ✅ CONSERVÉ

- Créées par l'application (admin)
- `audience_role = 'bride'` → seules les Brides peuvent écrire
- Visibles sur la home page Bride
- Même interface de chat que les conversations privées
- Les Pros ne peuvent pas écrire (lecture seule si accès)
- Exemple: "Wedding Tips", "Inspiration Mariages"

---

## 5. Modération ✅ VALIDÉ

### 5.1 Signalement de Messages ✅ À AMÉLIORER

**Raisons de signalement (4 options):**
| Raison | Code | Description |
|--------|------|-------------|
| Spam | `spam` | Messages non sollicités, publicité |
| Harcèlement | `harassment` | Comportement abusif, menaces |
| Contenu inapproprié | `inappropriate_content` | Images/textes choquants |
| Autre | `other` | Autre raison (champ détails optionnel) |

**Flux de signalement:**
```
1. User long-press sur message d'un autre
2. Sheet s'ouvre avec options:
   - "Signaler ce message"
   - (Nouveau) "Bloquer cet utilisateur"
3. Si "Signaler" → Sheet choix raison:
   - 4 boutons radio (spam, harassment, inappropriate, other)
   - Champ texte "Détails (optionnel)"
   - Bouton "Envoyer le signalement"
4. → Insert dans 'reports' avec raison choisie
5. → Trigger: message.is_deleted = true (masquage immédiat)
6. → Insert dans 'support_tickets' pour CRM
```

**Action immédiate:** Masquage immédiat du message (`is_deleted=true`)
- Protection immédiate de l'utilisateur
- Si abus de signalement → contre-mesures ultérieures

### 5.2 Blocage Utilisateur ✅ À AMÉLIORER

**Accès au blocage (2 points d'entrée):**

| Point d'entrée | Contexte |
|----------------|----------|
| **Chat (rapide)** | Long-press message → "Bloquer cet utilisateur" |
| **Messagerie** | Liste conversations → voir utilisateurs bloqués |

**Flux blocage depuis chat:**
```
1. Long-press sur message
2. Tap "Bloquer cet utilisateur"
3. Confirmation dialog: "Bloquer [Nom]? Vous ne verrez plus ses messages."
4. → Insert dans 'user_blocks'
5. → Insert dans 'support_tickets' (type: block)
6. → RLS empêche de voir les messages
7. → Conversation masquée de la liste
```

**Gestion des blocages:**
- Accessible depuis la page Messagerie (pas Settings)
- Liste des conversations/utilisateurs bloqués
- Option débloquer

### 5.3 Tickets CRM (support_tickets) ✅ VALIDÉ

**Table existante `support_tickets`:**
```sql
id: uuid
profile_id: uuid (reporter)
subject: text
message: text
status: text (pending, in_progress, resolved)
admin_notes: text (nullable)
created_at: timestamptz
updated_at: timestamptz
resolved_at: timestamptz (nullable)
```

**Événements créant un ticket:**
| Événement | Subject | Message |
|-----------|---------|---------|
| Signalement message | `[REPORT] Message signalé` | Raison + détails + lien message |
| Blocage utilisateur | `[BLOCK] Utilisateur bloqué` | Infos blocker/blocked + contexte |

**Pas d'email automatique** - Les tickets sont visibles dans le CRM admin.

### 5.4 Matrice État vs. Requis (Mise à jour)

| Fonctionnalité | État Actuel | Cible | Action |
|----------------|-------------|-------|--------|
| Signaler message | ⚠️ Basique | ✅ Avec raisons | Améliorer UI |
| Choix raison signalement | ❌ Hardcodé | ✅ 4 options | Créer sheet |
| Message masqué après report | ✅ Auto | ✅ | Conserver |
| Bloquer depuis chat | ❌ Pas d'UI | ✅ | Ajouter option |
| Liste utilisateurs bloqués | ❌ Non | ✅ | Dans Messagerie |
| Débloquer utilisateur | ⚠️ Code existe | ✅ | Ajouter UI |
| Ticket CRM | ❌ Non | ✅ support_tickets | Implémenter |
| Email automatique | ❌ | ❌ | Non requis |

---

## 6. Notifications

### 6.1 Configuration Actuelle

#### Table `notifications_outbox`
```sql
-- Queue pour notifications push/in-app
-- Claim par edge function toutes les 30 secondes
id, event_type, payload (jsonb), attempts, last_error, processed_at, claimed_at
```

#### Triggers Outbox
- `trg_outbox_chat_msg` (chat_messages INSERT) → ajoute event
- `trg_outbox_on_connection_request_aiu` (connection_requests INSERT/UPDATE) → ajoute event

### 6.2 Types de Notifications Chat

| Event | Trigger | Notification |
|-------|---------|--------------|
| Nouveau message | outbox_on_chat_message | Push + In-app |
| Nouvelle demande contact | outbox_on_connection_request_aiu | Push + In-app |
| Demande acceptée | outbox_on_connection_request_aiu | Push + In-app |
| Demande refusée | outbox_on_connection_request_aiu | Push + In-app |

### 6.3 Points à Vérifier

- [ ] Edge function `notifications_outbox_drain` fonctionne-t-elle?
- [ ] Les tokens FCM sont-ils correctement stockés?
- [ ] Les templates de notification sont-ils configurés?
- [ ] Les préférences utilisateur sont-elles respectées?

---

## 7. Médias et Stockage

### 7.1 Buckets Supabase Storage

| Bucket | Usage | Accès |
|--------|-------|-------|
| `chat_images` | Images envoyées dans conversations | Signed URLs |
| `chat_audio` | Messages audio | Signed URLs |

### 7.2 Upload et Affichage

#### Images
```dart
// uploadAndSendImagesAction (non lu en détail)
1. Compression (quality: 80, maxWidth: 1440)
2. Upload vers chat_images/${room_id}/${filename}
3. Insert message type=image, attachment_url=path
```

#### Audio
```dart
// uploadAndSendAudioAction (non lu en détail)
1. Upload vers chat_audio/${room_id}/${filename}
2. Insert message type=audio, attachment_url=path
```

### 7.3 Affichage (ChatMessageList)

```dart
// Cache des URLs signées en mémoire (_mediaUrlCache)
1. Si URL en cache → afficher directement
2. Sinon → createSignedUrlForChatMediaAction(path, 3600) // 1h
3. Stocker en cache
4. Afficher Image.network ou AudioPlayerWidget
```

### 7.4 Audio Player Optimisations ✅ COMPLÉTÉES (2025-12-03)

#### Problèmes Corrigés
- **Timing URL signée**: FutureBuilder recréait une nouvelle Future à chaque rebuild
- **Player initialization**: Player recevait `attachmentUrl` brut (pas une URL valide)
- **Widget reconstruction**: AudioPlayerWidget ne gérait pas les changements d'URL

#### Solutions Implémentées
```dart
// 1. Cache synchrone avec pré-chargement
final Map<String, String> _signedUrlCache = {};
final Set<String> _loadingUrls = {};

// 2. Preload dans didUpdateWidget
void didUpdateWidget() {
  _preloadSignedUrls(); // Charge URLs en async
}

// 3. Cache synchrone dans build
Widget _buildMessageBubble() {
  final signedUrl = _getCachedSignedUrl(message.attachmentUrl);
  return MessageBubble(signedMediaUrl: signedUrl);
}

// 4. didUpdateWidget dans AudioPlayerWidget
void didUpdateWidget(oldWidget) {
  if (oldWidget.audioUrl != widget.audioUrl) {
    _initializePlayer(); // Réinitialise si URL change
  }
}
```

#### Audio Player Design Refactor
- **Layout**: Horizontal compact (FlutterFlow style)
- **Composants**: Play/pause + slider + duration + speed
- **Waveform**: Supprimée pour design épuré
- **Taille**: minWidth 220px, maxWidth 280px

#### Audio Recorder Optimisations
- **Animation**: 50ms → 100ms (2x plus lente)
- **Amplitude**: Courbe cubique, 2-20px au silence
- **Couleur**: Uniforme `textSecondary` (pas de dégradé)
- **Timer**: `w400`, `labelSmall`, 11px
- **Spacing**: 10px entre croix et waveform

### 7.5 Points d'Attention

- Les URLs signées expirent après 1h
- Le cache est en mémoire (perdu au redémarrage)
- Pas de compression côté serveur pour les avatars
- Pas de limite de taille visible côté frontend
- ✅ **Audio loading**: Cache synchrone + preloading résolu

---

## 8. Agora Vidéo (Préservation)

### 8.1 Fichiers Identifiés

| Fichier | Description |
|---------|-------------|
| `lib/custom_code/actions/get_agora_token_action.dart` | Appelle edge function pour token |
| `lib/custom_code/actions/start_video_session_action.dart` | Crée session dans video_sessions |
| `lib/custom_code/actions/update_video_session_status_action.dart` | Met à jour statut |
| `lib/custom_code/actions/handle_video_session_timeout.dart` | Gestion timeout |
| `lib/custom_code/actions/agora_end_call.dart` | Fin d'appel |
| `lib/custom_code/actions/agora_toggle_camera.dart` | Toggle caméra |
| `lib/custom_code/actions/agora_toggle_mute.dart` | Toggle micro |
| `lib/custom_code/actions/agora_switch_camera.dart` | Switch caméra |
| `lib/custom_code/widgets/agora_video_view.dart` | Widget affichage vidéo |
| `lib/services/agora_engine_manager.dart` | Singleton engine Agora |
| `lib/pages/shared/video_call_page/video_call_page_widget.dart` | Page d'appel vidéo |

### 8.2 Edge Function

```
supabase/functions/agora_token_issue/
```

### 8.3 Table `video_sessions`

Déjà documentée dans la section Backend.

### 8.4 Points Critiques ⚠️

**NE PAS TOUCHER:**
- Les fichiers Agora doivent rester fonctionnels
- La génération de tokens (edge function)
- L'interface de vidéoconférence
- Les tables video_sessions

**POINTS DE CONTACT:**
- Le bouton vidéo dans ChatDetailsWidget → appelle startVideoSessionAction
- Les notifications d'appel entrant
- Le statut de session (pending → accepted/declined/missed)

---

## 9. Gaps et Problèmes Identifiés ✅ MIS À JOUR

### 9.1 Changements Requis (Backend)

#### 1. ⚠️ Supprimer/Modifier Trigger `on_first_message_pro_to_bride`
**Problème:** Le trigger crée automatiquement des `connection_request` sur le 1er message.  
**Décision:** Le nouveau flux crée la demande AVANT d'ouvrir le chat (via sheet).  
**Action:** 
- Supprimer le trigger `trg_on_first_msg_pro_bride`
- Créer RPC `create_contact_request(target_id, source, message)` appelée depuis le sheet
- La room n'est créée qu'après acceptation

#### 2. ⚠️ Nettoyer Enum `subscriptionTierType`
**Problème:** L'enum contient `trial` qui n'est plus utilisé.  
**Action:** Supprimer `trial`, garder: `inactive`, `earlyAccess`, `premiumVisibility`, `ultimateAccess`  
**Note:** À faire dans PROJECT_TODO (pas prioritaire pour le chat)

#### 3. ⚠️ Renommer Enum `connectionRequestSource`
**Actuel:** `wishlist`, `weddingPin`, `map`, `alert`, `proToPro`  
**Cible:** `fromWishlist`, `fromWedding`, `fromAlert`, `fromProfile`  
**Action:** Migration SQL + mise à jour Flutter

### 9.2 Changements Requis (Frontend)

#### 1. Créer Sheet "Demande de Contact"
**Nouveau composant:** `ContactRequestSheet`
- Champ message obligatoire (pas de pré-rempli)
- Affichage source auto-détectée
- Bouton "Envoyer la demande"
- Toast confirmation

#### 2. Améliorer Sheet Actions Message
**Ajouter:**
- Option "Bloquer cet utilisateur"
- Option "Signaler" → ouvre sheet choix raison

#### 3. Créer Sheet Signalement
**Nouveau composant:** `ReportMessageSheet`
- 4 boutons radio (spam, harassment, inappropriate, other)
- Champ détails optionnel
- Bouton "Envoyer"

#### 4. Ajouter Section Bloqués dans Messagerie
**Dans MessagesPage:**
- Onglet ou section "Bloqués"
- Liste utilisateurs bloqués
- Option débloquer

#### 5. Unifier Pages Messages
**Problème:** `MessagesBridesWidget` et `MessagesProWidget` quasi identiques.  
**Action:** Créer une seule `MessagesPage` avec logique conditionnelle selon `UserRole`

### 9.3 Refactoring Code (Qualité)

| Composant | Problème | Action |
|-----------|----------|--------|
| `ChatMessageList` | 1270 lignes, trop complexe | Séparer en sous-composants |
| `ChatComposerWidget` | 578 lignes | Extraire logique dans BLoC |
| Pages Messages | Code dupliqué | Unifier |
| Actions FlutterFlow | Couplage fort | Migrer vers repositories |

### 9.4 Fonctionnalités Hors Scope (V2)

Ces fonctionnalités ne sont PAS dans le scope de la refactorisation actuelle:
- ❌ Indicateur "en train d'écrire" (typing indicator)
- ❌ Accusé de réception (message vu/lu)
- ❌ Recherche dans les messages
- ❌ Réactions aux messages (emoji)
- ❌ Messages vocaux en temps réel

---

## 10. Plan de Refactorisation ✅ MIS À JOUR

### 10.1 Architecture Cible

```
lib/features/chat/
├── domain/
│   ├── entities/
│   │   ├── chat_message.dart
│   │   ├── chat_room.dart
│   │   ├── conversation.dart
│   │   └── contact_request.dart
│   ├── repositories/
│   │   ├── chat_repository.dart
│   │   └── contact_repository.dart
│   └── usecases/
│       ├── send_message_usecase.dart
│       ├── get_conversations_usecase.dart
│       ├── create_contact_request_usecase.dart
│       ├── accept_contact_request_usecase.dart
│       └── report_message_usecase.dart
├── data/
│   ├── datasources/
│   │   ├── chat_remote_datasource.dart
│   │   └── chat_local_datasource.dart (cache)
│   ├── models/
│   │   ├── chat_message_model.dart
│   │   └── conversation_model.dart
│   └── repositories/
│       └── chat_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── conversations_bloc.dart
│   │   ├── chat_room_bloc.dart
│   │   └── contact_request_bloc.dart
│   ├── pages/
│   │   ├── messages_page.dart (unifiée bride/pro)
│   │   └── chat_details_page.dart
│   ├── widgets/
│   │   ├── message_bubble.dart
│   │   ├── message_composer.dart
│   │   ├── message_list.dart
│   │   ├── contact_request_card.dart
│   │   └── blocked_users_list.dart
│   └── sheets/
│       ├── contact_request_sheet.dart (NOUVEAU)
│       ├── report_message_sheet.dart (NOUVEAU)
│       ├── message_actions_sheet.dart
│       └── conversation_actions_sheet.dart
└── README.md
```

### 10.2 Phases de Refactorisation (Ordre Révisé)

> **Priorité:** Clarifier les règles/conditions AVANT de coder. La modération arrive en dernier.

#### Phase 0: Audio Player & Message Loading ✅ COMPLÉTÉE (2025-12-03)
- [x] **Audio Player Refactor**: Design compact horizontal (FlutterFlow style)
  - Removed waveform visualization
  - Added play/pause, timeline slider, duration, speed control
  - Fixed signed URL timing issue (didUpdateWidget)
- [x] **Message Loading Optimization**: Cache synchrone + preloading
  - Replaced FutureBuilder with sync cache + async preload
  - Implemented _preloadSignedUrls() in didUpdateWidget
  - Added ValueKey for widget reconstruction
- [x] **Audio Recorder UI/UX**: Animation et amplitude optimisés
  - Slowed animation (50ms → 100ms)
  - Reduced amplitude at silence (cubic curve 2-20px)
  - Unified typography with player (w400, labelSmall)
  - Reduced spacing to 10px

#### Phase 1: Backend - Logique Contact (6-8h)
- [ ] Supprimer trigger `trg_on_first_msg_pro_bride`
- [ ] Créer RPC `create_contact_request(target_id, source, message)`
- [ ] Modifier RPC `accept_connection_request` pour créer la room
- [ ] Renommer enum `connectionRequestSource` → nouvelles valeurs
- [ ] Tester les nouveaux flux via SQL

#### Phase 2: Foundation Frontend (8-10h)
- [ ] Créer structure `lib/features/chat/`
- [ ] Définir entités domain
- [ ] Créer repository interfaces
- [ ] Implémenter datasources (remote)
- [ ] Créer `ContactRequestSheet` (demande de contact Pro→Bride)

#### Phase 3: Messages Page Unifiée (8-12h)
- [ ] Créer `MessagesPage` unique (remplace bride/pro)
- [ ] Implémenter ConversationsBloc
- [ ] Section "Demandes" (contact requests pending)
- [ ] Section "Conversations" (rooms actives)
- [ ] Section "Bloqués" (utilisateurs bloqués)
- [ ] Appliquer Design System

#### Phase 4: Chat Details + Realtime (12-16h)
- [ ] Créer ChatRoomNotifier (ChangeNotifier) avec état et realtime
- [ ] Refactoriser MessageList en composants (MessageBubble, MessageList, MessageComposer)
- [ ] Implémenter Realtime messages (subscriptions Supabase)
- [ ] Ajouter Realtime MessagesPage (nouvelles demandes + messages)
- [ ] Gérer mode "contact request" (Accept/Decline dans chat)
- [ ] Préserver fonctionnalités médias (images, audio)
- [ ] Préserver bouton appel vidéo (Agora)
- [ ] Appliquer Design System 100%

#### Phase 5: Modération (6-8h) ✅ TERMINÉ
- [x] Créer `ReportMessageSheet` (4 raisons) → `MessageActionsSheet` intégré
- [x] Créer `ReportUserSheet` (signalement profil)
- [x] Améliorer `MessageActionsSheet` (+ bloquer)
- [x] Implémenter création ticket `support_tickets`
- [x] UI déblocage dans section Bloqués

#### Phase 6: Tests & Cleanup (4-6h) ✅ EN COURS
- [x] Documentation README (`lib/features/chat/README.md`)
- [x] Analyse statique (0 erreurs)
- [ ] Tests manuels en cours
- [ ] Supprimer ancien code FlutterFlow (après validation)

### 10.3 Risques et Mitigations

| Risque | Mitigation |
|--------|------------|
| Casser Agora | Isoler complètement, ne pas toucher les fichiers Agora |
| Perdre fonctionnalités | Backup complet fait (docs/archive/chat_backup_2025-12-02/) |
| Notifications cassées | Vérifier triggers outbox avant suppression |
| Nouveau flux contact confus | Tester avec vrais utilisateurs avant déploiement |
| Rooms publiques cassées | Conserver la logique existante, juste refactorer |

### 10.4 Estimation Totale (Révisée)

| Phase | Heures | Priorité |
|-------|--------|----------|
| Backend - Logique Contact | 6-8h | 🔴 Haute |
| Foundation Frontend | 8-10h | 🔴 Haute |
| Messages Page Unifiée | 8-12h | 🔴 Haute |
| Chat Details | 12-16h | 🟡 Moyenne |
| Modération | 6-8h | 🟢 Basse |
| Tests & Cleanup | 4-6h | 🟢 Basse |
| **TOTAL** | **44-60h** | |

### 10.5 Dépendances

```
Phase 1 (Backend) ──┬──► Phase 2 (Foundation) ──► Phase 3 (Messages)
                    │                                    │
                    │                                    ▼
                    │                              Phase 4 (Chat Details)
                    │                                    │
                    └────────────────────────────────────┴──► Phase 5 (Modération)
                                                              │
                                                              ▼
                                                        Phase 6 (Tests)
```

---

## 11. Sheets Terminés ✅ (2025-12-02)

### 11.1 ReportUserSheet ✅

**Fichier:** `lib/features/chat/presentation/sheets/report_user_sheet.dart`

**Fonctionnalités:**
- Signalement d'un utilisateur (professionnel) depuis les profils
- 4 raisons de signalement: spam, harassment, inappropriate_content, other
- Création de ticket dans `support_tickets` (type: `user_report`)
- Intégré dans `ProfessionalDetailsSheet` et `ProDetailsPage`

**Design System appliqué:**
- Utilise `LynewedSheet` pour le container (cohérent avec autres sheets)
- `LynewedSectionTitle` pour les titres de section
- `LynewedTextField` avec fond gris (`isValueInput: false`)
- `LynewedButton` pour le bouton d'action (48px, noir)
- Spacing: 30px inter-section, 10px label→content

### 11.2 ProfessionalDetailsSheet ✅

**Fichier:** `lib/features/map/presentation/sheets/professional_details_sheet.dart`

**Fonctionnalités:**
- Affichage détails professionnel depuis la map
- Actions: View Profile, Contact, Favorite, Report (via menu)
- Bouton Contact fonctionnel → `ChatDetailsPage`

**Design System appliqué:**
- Utilise `LynewedDetailsSheet` pour le container
- `LynewedHeaderActions` pour les actions header (fav + more menu)
- `LynewedAboutSection` pour la section About
- `LynewedButton` pour les boutons d'action
- Spacing: 12px texte→icônes, 10px entre icônes

### 11.3 MessagesPage ✅ (2025-12-02)

**Fichier:** `lib/features/chat/presentation/pages/messages_page.dart`

**Fonctionnalités:**
- Page unifiée pour Brides et Pros
- Header: Back button + titre (sheetTitle + 20px) + action circle 44px
- Section "Contact Requests" (horizontal scroll avatars)
- Section "Conversations" (list items gris clair)
- Bouton archive pour accéder aux utilisateurs bloqués

**Design System appliqué:**
- Titre page: `sheetTitle.copyWith(fontSize: 20)`
- Section titles: `sectionTitle` (16px, w500)
- Divider: `gray200`
- List items: fond `surface`, radius 4px
- Spacing: 30px entre sections, 10px label→content
- Bouton action: cercle 44px, fond `surface`

### 11.4 BlockedUsersSheet ✅ (2025-12-02)

**Fichier:** `lib/features/chat/presentation/sheets/blocked_users_sheet.dart`

**Fonctionnalités:**
- Modal sheet pour afficher les utilisateurs bloqués
- Liste avec action "Unblock" par utilisateur
- Empty state si aucun utilisateur bloqué

**Design System appliqué:**
- Header: Titre "Archived" à gauche, close icon à droite (style LynewedSheet)
- Divider: `gray200`
- Handle bar: 40x4px, `gray200`
- Max height: 70% de l'écran
- Border radius: 24px top corners

### 11.5 Règles Design System pour les Sheets

**Widgets réutilisables (`lib/core/design/widgets/`):**

| Widget | Usage |
|--------|-------|
| `LynewedSheet` | Container pour sheets de formulaire/action |
| `LynewedDetailsSheet` | Container pour sheets de détails (avec avatar/header) |
| `LynewedSectionTitle` | Titre de section (16px, w500) |
| `LynewedTextField` | Champ de texte (fond gris par défaut) |
| `LynewedButton` | Bouton d'action (48px, noir primaire) |
| `LynewedHeaderActions` | Actions header (fav + menu 3 points) |

**Spacing Design System:**
- **30px** entre sections
- **10px** entre label et contenu
- **12px** entre bloc texte et icônes header
- **10px** entre icônes dans `LynewedHeaderActions`

**Règles CRITIQUES (voir docs/App/DESIGN_SYSTEM.md):**
1. TOUJOURS utiliser les widgets du Design System
2. JAMAIS créer de styles inline, utiliser `LynewedTextStyles`
3. JAMAIS créer de couleurs inline, utiliser `LynewedColors`
4. **Font weight max w500** (sauf exceptions documentées)
5. **Dividers: `gray200`** (pas `border`)
6. **List items: fond `surface`, radius 4px**
7. **Boutons icône: cercle 44px**
8. **TOUS les textes UI doivent être en ANGLAIS** (l'app est nativement en anglais)

---

## Backup

**Emplacement:** `docs/archive/chat_backup_2025-12-02/`

**Contenu:**
```
chat_backup_2025-12-02/
├── actions.dart
├── backend/schema/structs/
│   └── chat_*, message_*, contact_*, conversation_*
├── components/
│   └── item_room_chat_*
├── conversation_sheet/
│   ├── conversation_actions_sheet/
│   ├── my_message_actions_sheet/
│   └── other_message_actions_sheet/
├── custom_code/
│   ├── actions/
│   │   └── *message*, *chat*, *contact*, block_*, archive_*
│   └── widgets/
│       └── chat_*
└── pages/
    ├── chat_details/
    ├── messages_brides/
    └── messages_pro/
```

---

## Références

- **PROJECT.md**: État projet global
- **PROJECT_TODO.md**: Section 1.1 Module Chat & Contact
- **DESIGN_SYSTEM.md**: Tokens et styles à appliquer
- **MAP_REFACTORING_COMPLETE_2025-12-01.md**: Pattern à suivre pour le refactoring

---

---

## 12. TÂCHES COMPLÉTÉES (2025-12-03)

### 12.1 ✅ ContactRequestSheet (TERMINÉ)
- [x] `ContactRequestSheet` existe dans `lib/features/chat/presentation/sheets/`
- [x] Champ message obligatoire (min 10 caractères)
- [x] Source affichée (fromWedding, fromWishlist, etc.)
- [x] Bouton "Send Request" → appelle RPC `create_contact_request`
- [x] Toast confirmation + fermeture sheet
- [x] Design System v3 appliqué
- [x] Intégré dans `lib/actions/actions.dart`

### 12.2 ✅ Vérification Conditions de Contact (TERMINÉ)
- [x] RPC `open_or_prepare_contact_context` retourne les bons status
- [x] `requiresRequest` retourné pour Pro→Bride sans room existante
- [x] `roomReady` retourné pour Bride→Pro et Pro→Pro
- [x] Conditions d'abonnement vérifiées (Premium+ pour Pro→Bride)

### 12.3 ✅ Création/Chargement de Room (TERMINÉ)
- [x] Room existante → charge correctement avec toutes les infos
- [x] Pas de room (Bride→Pro, Pro→Pro) → crée et navigue
- [x] Pas de room (Pro→Bride) → affiche ContactRequestSheet
- [x] Après acceptation demande → room créée et navigation OK

### 12.4 ✅ Logiques de Modération (TERMINÉ)
- [x] `ReportUserSheet` fonctionne depuis les profils
- [x] `MessageActionsSheet` permet de signaler/bloquer
- [x] Tickets créés dans `support_tickets`
- [x] Messages masqués après signalement (`is_deleted=true`)
- [x] Utilisateurs bloqués visibles dans `BlockedUsersSheet`

### 12.5 � Notifications In-App (À INVESTIGUER - PRIORITÉ)
**Problème identifié:** Les notifications in-app ne s'affichent pas dans la page Notifications quand un message est reçu.
**Statut:** Edge function `notifications_outbox_drain` configurée mais comportement à vérifier.
**À investiguer:**
- [ ] Triggers qui créent les events dans `notifications_outbox` (chat_messages INSERT)
- [ ] Table `notifications` ou équivalent pour stockage in-app
- [ ] Page centre de notification: quelle table lit-elle?
- [ ] Tokens FCM (push) - normal de ne pas fonctionner sur simulateur
- [ ] Distinction push vs in-app dans l'architecture

### 12.6 ✅ UI/UX Design System v3 (TERMINÉ)
**Sheets validés:**
- [x] `ContactRequestSheet` - DS v3 appliqué
- [x] `ContactRequestReviewSheet` - DS v3 appliqué
- [x] `MessageActionsSheet` - DS v3 appliqué (border radius 4px corrigé)
- [x] `ConversationActionsSheet` - DS v3 appliqué
- [x] `ReportUserSheet` - DS v3 appliqué
- [x] `BlockedUsersSheet` - DS v3 appliqué

### 12.7 Fichiers Modifiés (Session 2025-12-03)
| Fichier | Modification |
|---------|--------------|
| `lib/actions/actions.dart` | Intégration ContactRequestSheet |
| `lib/features/chat/presentation/sheets/message_actions_sheet.dart` | Simplifié en StatelessWidget, ouvre ReportMessageSheet |
| `lib/features/chat/presentation/sheets/report_message_sheet.dart` | **NOUVEAU** - Même design que ReportUserSheet |
| `lib/features/chat/presentation/sheets/conversation_actions_sheet.dart` | Ajout Block User + Report User, utilise ReportUserSheet |
| `lib/features/chat/presentation/sheets/blocked_users_sheet.dart` | Renommé ArchivedSheet, affiche conversations archivées + users bloqués |
| `lib/features/chat/presentation/widgets/archived_conversation_tile.dart` | **NOUVEAU** - Tile pour conversations archivées |
| `lib/features/chat/presentation/pages/messages_page.dart` | Utilise ArchivedSheet, compte archivés |
| `lib/features/chat/presentation/bloc/conversations_state.dart` | activeConversations inclut reportedPending |
| `lib/features/chat/presentation/bloc/conversations_cubit.dart` | reportUser ne change plus le statut conversation |
| `lib/core/design/lynewed_borders.dart` | Ajout `xs = 4.0` |
| **Supabase RPC** | `get_pending_contact_requests` corrigée (logique Bride/Pro) |

---

## 🐛 BUGS CORRIGÉS

### 1. Chat Contact Request Flow - ✅ RÉSOLU (2025-12-04)

#### Symptômes observés
- Message initial non affiché dans ChatDetailsPage
- Snackbar d'erreur sur Accept mais conversation créée partiellement
- Demande persistante en "pending" après Accept

#### Causes racines identifiées

##### 1. **ChatRoomNotifier** - Gestion incorrecte des pending requests
- **Problème**: `loadMessages()` essayait de charger des messages avec un `requestId` au lieu d'un `roomId`
- **Impact**: Erreur "No messages" pour les demandes en attente

##### 2. **ChatRoomState.copyWith()** - Impossible de mettre `pendingRequestId` à null
- **Problème**: `pendingRequestId ?? this.pendingRequestId` ne permettait pas de passer explicitement à null
- **Impact**: L'état pending ne se nettoyait pas après Accept/Decline

##### 3. **_roomId immutable** - Pas de mise à jour après Accept
- **Problème**: `_roomId` était `final`, impossible de mettre à jour avec le nouveau roomId après accept
- **Impact**: Le notifier restait avec l'ancien requestId

##### 4. **Backend RPC** - Type mismatch dans `accept_connection_request`
- **Problème**: `v_message_id uuid` mais `chat_messages.id` est `bigint`
- **Impact**: Erreur 400 lors de l'insertion du message initial

#### Solutions appliquées

##### Frontend
```dart
// ChatRoomNotifier.loadMessages()
if (_pendingRequestId != null && _viewerIsReviewer) {
  // Cas spécial: ne pas charger les messages, émettre état vide
  _emit(ChatRoomLoaded(messages: const [], ...));
  return;
}

// ChatRoomState.copyWith()
bool clearPendingRequestId = false;
pendingRequestId: clearPendingRequestId ? null : (pendingRequestId ?? this.pendingRequestId);

// _roomId mutable
String _roomId; // était final

// acceptContactRequest() complet
final newRoomId = result.data!;
_roomId = newRoomId;
await _loadMessagesAfterAccept(newRoomId);
```

##### Backend
```sql
-- Migration: fix_accept_connection_request_message_id_type
CREATE OR REPLACE FUNCTION public.accept_connection_request(p_request_id uuid)
...
DECLARE
  v_message_id bigint;  -- Corrigé: était uuid, maintenant bigint
...
```

#### Fichiers modifiés
- `lib/features/chat/presentation/bloc/chat_room_notifier.dart`
  - Gestion spéciale pending requests dans `loadMessages()`
  - `_roomId` mutable, méthode `_loadMessagesAfterAccept()`
  - Flow complet dans `acceptContactRequest()`
- `lib/features/chat/presentation/bloc/chat_room_state.dart`
  - Flag `clearPendingRequestId` dans `copyWith()`
- `lib/features/chat/data/datasources/chat_remote_datasource.dart`
  - Logging debug pour `acceptContactRequest()`
- Supabase Migration `fix_accept_connection_request_message_id_type`

#### Validation
- ✅ Message initial affiché correctement
- ✅ Accept fonctionne sans erreur, crée la conversation
- ✅ Decline fonctionne, retour à MessagesPage
- ✅ Demande supprimée de "pending" après traitement
- ✅ Chatbar active après Accept

---

**Document rédigé le:** 2025-12-02  
**Dernière mise à jour:** 2025-12-04 10:23  
**Statut:** ✅ MODULE CHAT COMPLET. Contact Request Flow corrigé et validé. 🔴 PROCHAINE PRIORITÉ: Investigation notifications in-app.  
**Prochaine étape:** Audit système de notifications (triggers, tables, page)
