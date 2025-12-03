# 🚀 PROMPT REFACTORISATION CHAT & CONTACT MODULE

**Date:** 2025-12-03  
**Version:** v2.0 (Mise à jour avec corrections récentes)  
**Durée estimée:** 35-50 heures (Phase 0 terminée)  
**Priorité:** 🔴 Haute

---

## 📋 CONTEXTE PROJET

### État Global
- **Projet:** LYNEWED Mobile App (Flutter + Supabase)
- **Version:** v1.1.1+59 (develop branch)
- **Environnement:** Supabase dev (hekyovgnovhfhmkpfrna)
- **Architecture:** Clean Architecture (domain/data/presentation)
- **Design System:** ✅ Unifié dans `lib/core/design/`

### Module Précédent (Référence)
- **Map Module:** ✅ 100% terminé (2025-12-01)
  - 50 heures de travail
  - 63/63 tests passants
  - 4200 lignes Clean Architecture
  - Pattern à suivre: `lib/features/map/` → `lib/features/chat/`

### Règles Absolues du Projet
- ❌ **JAMAIS** réutiliser code FlutterFlow (`lib/compo_finaux/`, `lib/components/`)
- ✅ **TOUJOURS** créer dans `lib/features/chat/` (Clean Architecture)
- ✅ **TOUJOURS** appliquer Design System (`import '/core/design/design.dart'`)
- ✅ **TOUJOURS** suivre pattern: domain/data/presentation

---

## 🎯 OBJECTIF PRINCIPAL

Refactoriser le module Chat & Contact de FlutterFlow vers Clean Architecture en appliquant les **décisions métier validées** et en créant une **logique de contact claire et cohérente**.

### Livrables Attendus
1. ✅ Module `lib/features/chat/` complet et autonome
2. ✅ Toutes les décisions métier implémentées
3. ✅ Tests unitaires pour repositories et use cases
4. ✅ Documentation README du module
5. ✅ Ancien code FlutterFlow supprimé

---

## 📖 DOCUMENTS DE RÉFÉRENCE (À LIRE EN PRIORITÉ)

### 1. Audit Complet (SOURCE DE VÉRITÉ)
**Fichier:** `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` (v1.4)

**Sections critiques:**
- **Section 🔧 CORRECTIONS RÉCENTES** ← Travail déjà fait (2025-12-03)
- Section 4: Logiques Métier (VALIDÉ) ← **À IMPLÉMENTER**
- Section 5: Modération (VALIDÉ) ← **À IMPLÉMENTER**
- Section 9: Gaps et Problèmes Identifiés
- Section 10: Plan de Refactorisation
- **Section 12: TÂCHES PRIORITAIRES RESTANTES** ← **FOCUS PRINCIPAL**

### 2. Décisions Métier Validées
**Résumé rapide:**

#### Plans d'Abonnement
```
inactive → earlyAccess → premiumVisibility → ultimateAccess
```

#### Règles de Contact
| Initiateur | Cible | Type | Plan requis |
|------------|-------|------|-------------|
| Bride | Pro | Direct (chat) | Compte actif |
| Pro | Bride | **Demande (sheet)** | Premium+ |
| Pro | Pro | Direct (chat) | EarlyAccess+ |

#### Sources de Contact (Renommées)
- `fromWishlist` → Pro contacte Bride qui l'a favori
- `fromWedding` → Pro contacte Bride depuis mariage
- `fromAlert` → Pro répond à alerte (Pro→Pro direct)
- `fromProfile` → Contact depuis profil

#### Modération
- **Raisons:** `spam`, `harassment`, `inappropriate_content`, `other`
- **Action:** Masquage immédiat + ticket `support_tickets`
- **Blocage:** UI dans chat + liste dans Messagerie

### 3. Références Projet
- `docs/PROJECT.md` - État global, architecture
- `docs/PROJECT_TODO.md` - Tâches futures
- `docs/App/DESIGN_SYSTEM.md` - Tokens UI/UX
- `lib/features/map/README.md` - Pattern à suivre

### 4. Backup Code Existant
**Emplacement:** `docs/archive/chat_backup_2025-12-02/`
- Pages, widgets, actions, sheets
- À consulter pour comprendre la logique actuelle
- **À NE PAS réutiliser directement**

---

## 🏗️ ARCHITECTURE CIBLE

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
├── README.md
└── test/
    ├── domain/
    ├── data/
    └── presentation/
```

---

## ✅ TRAVAIL DÉJÀ COMPLÉTÉ (2025-12-03)

### Phase 0: Audio + Corrections ✅ TERMINÉE
- ✅ **Audio Player**: Design compact, signed URL fix
- ✅ **Message Loading**: Cache synchrone + preloading
- ✅ **Audio Recorder**: Animation + amplitude optimisés
- ✅ **Message Spacing**: 8px same user, 30px different user
- ✅ **Navigation Map Sheets**: `MapActionsService` utilise `action_blocks.contactChatRoom()`
- ✅ **Bug "Waiting"**: `pendingRequestId` passé seulement si `status == requestPending`
- ✅ **Status `requiresRequest`**: Ajouté à enum + parsing + UX messages

### Fichiers Modifiés
| Fichier | Modification |
|---------|--------------|
| `lib/features/chat/presentation/widgets/message_list.dart` | Spacing logic |
| `lib/features/chat/presentation/widgets/message_bubble.dart` | needsLargeSpacing |
| `lib/features/map/presentation/services/map_actions_service.dart` | Use action_blocks |
| `lib/actions/actions.dart` | Handle requiresRequest, notAllowed, blocked |
| `lib/backend/schema/enums/enums.dart` | Add requiresRequest |
| `lib/custom_code/actions/open_or_prepare_contact_action.dart` | Parse requiresRequest |

---

## 📅 PHASES DE REFACTORISATION (ORDRE CRITIQUE)

### Phase 0.5: ContactRequestSheet (2-4h) 🔴 CRITIQUE - À FAIRE MAINTENANT
**Problème actuel:** Quand un Pro tente de contacter une Bride via wedding/wishlist, un popup placeholder s'affiche au lieu du sheet de demande.

**Tâches:**
- [ ] Créer `lib/features/chat/presentation/sheets/contact_request_sheet.dart`
- [ ] Champ message obligatoire (pas de pré-rempli)
- [ ] Source auto-détectée et affichée (fromWedding, fromWishlist, etc.)
- [ ] Bouton "Envoyer la demande" → appelle RPC `create_contact_request`
- [ ] Toast confirmation + retour page précédente
- [ ] Modifier `lib/actions/actions.dart` pour ouvrir le sheet au lieu du dialog
- [ ] Appliquer Design System v3

**Validation:**
- [ ] Pro→Bride depuis wedding sheet → ContactRequestSheet s'ouvre
- [ ] Message obligatoire validé
- [ ] Demande créée en base (connection_requests)
- [ ] Toast confirmation affiché

---

### Phase 1: Backend - Logique Contact (6-8h) 🔴 HAUTE PRIORITÉ
**Objectif:** Modifier les RPCs et triggers pour supporter le nouveau flux

**Tâches:**
- [ ] Supprimer trigger `trg_on_first_msg_pro_bride`
- [ ] Créer RPC `create_contact_request(target_id, source, message)`
- [ ] Modifier RPC `accept_connection_request` pour créer la room
- [ ] Renommer enum `connectionRequestSource` (SQL migration)
- [ ] Tester les nouveaux flux via SQL

**Fichiers Supabase:**
- `supabase/migrations/` - Créer migration pour trigger/RPC
- `supabase/functions/` - Vérifier edge functions existantes

**Validation:**
- [ ] RPC `create_contact_request` retourne `connection_request` créée
- [ ] RPC `accept_connection_request` crée la room et active la conversation
- [ ] Enum `connectionRequestSource` a 4 valeurs correctes

---

### Phase 2: Foundation Frontend (8-10h) 🔴 HAUTE PRIORITÉ
**Objectif:** Créer la structure Clean Architecture et les bases

**Tâches:**
- [ ] Créer structure `lib/features/chat/` complète
- [ ] Définir entités domain (ChatMessage, ChatRoom, Conversation, ContactRequest)
- [ ] Créer repository interfaces (ChatRepository, ContactRepository)
- [ ] Implémenter datasources (remote + local cache)
- [ ] Créer `ContactRequestSheet` (demande Pro→Bride)

**Fichiers à créer:**
- `lib/features/chat/domain/entities/*.dart`
- `lib/features/chat/domain/repositories/*.dart`
- `lib/features/chat/data/datasources/*.dart`
- `lib/features/chat/data/models/*.dart`
- `lib/features/chat/presentation/sheets/contact_request_sheet.dart`

**Validation:**
- [ ] Toutes les entités compilent
- [ ] Repositories ont les signatures correctes
- [ ] ContactRequestSheet affiche message obligatoire + source

---

### Phase 3: Messages Page Unifiée (8-12h) 🔴 HAUTE PRIORITÉ
**Objectif:** Créer une seule page Messages pour bride et pro

**Tâches:**
- [ ] Créer `MessagesPage` unique (remplace bride/pro)
- [ ] Implémenter `ConversationsBloc` (state management)
- [ ] Section "Demandes" (contact requests pending)
- [ ] Section "Conversations" (rooms actives)
- [ ] Section "Bloqués" (utilisateurs bloqués)
- [ ] Appliquer Design System (LynewedTheme)

**Fichiers à créer:**
- `lib/features/chat/presentation/bloc/conversations_bloc.dart`
- `lib/features/chat/presentation/pages/messages_page.dart`
- `lib/features/chat/presentation/widgets/contact_request_card.dart`
- `lib/features/chat/presentation/widgets/blocked_users_list.dart`

**Validation:**
- [ ] Page affiche 3 sections (Demandes, Conversations, Bloqués)
- [ ] Tap demande → ouvre sheet Accept/Decline
- [ ] Tap conversation → navigation ChatDetails
- [ ] Design System appliqué (couleurs, typographie, spacing)

---

### Phase 4: Chat Details Refactorisé (12-16h) 🟡 MOYENNE PRIORITÉ
**Objectif:** Refactoriser la page de conversation avec Clean Architecture

**⚠️ DESIGN CRITICAL:** Le design de ChatDetails doit rester **EXACTEMENT** le même que l'actuel, déjà validé par l'utilisateur. Seuls spacing/padding peuvent être ajustés. DO NOT changer:
- Bulles de chat (couleurs, formes, positions)
- Typographies dans les messages
- Barre d'input du chat
- Couleurs des messages (envoyé/reçu)
- Disposition générale de l'interface

**Tâches:**
- [ ] Créer `ChatRoomBloc` (état, realtime, messages)
- [ ] Refactoriser `MessageList` en composants plus petits (garder design identique)
- [ ] Refactoriser `MessageComposer` (extraire logique dans BLoC, UI identique)
- [ ] Gérer mode "contact request" (Accept/Decline buttons)
- [ ] Préserver fonctionnalités médias (images, audio)
- [ ] Préserver bouton appel vidéo (Agora)
- [ ] **IMPORTANT:** Copier exactement le design visuel actuel

**Fichiers à créer:**
- `lib/features/chat/presentation/bloc/chat_room_bloc.dart`
- `lib/features/chat/presentation/pages/chat_details_page.dart`
- `lib/features/chat/presentation/widgets/message_bubble.dart`
- `lib/features/chat/presentation/widgets/message_list.dart`
- `lib/features/chat/presentation/widgets/message_composer.dart`

**Validation:**
- [ ] Messages affichent correctement (text, image, audio)
- [ ] Realtime updates fonctionnent
- [ ] Mode "contact request" affiche Accept/Decline
- [ ] Appel vidéo fonctionne (Agora préservé)
- [ ] **DESIGN:** Bulles, couleurs, typographies identiques à l'actuel
- [ ] **DESIGN:** Barre d'input identique à l'actuel

---

### Phase 5: Modération (6-8h) 🟢 BASSE PRIORITÉ
**Objectif:** Implémenter signalement et blocage avec tickets CRM

**Tâches:**
- [ ] Créer `ReportMessageSheet` (4 raisons)
- [ ] Améliorer `MessageActionsSheet` (+ bloquer)
- [ ] Implémenter création ticket `support_tickets`
- [ ] UI déblocage dans section Bloqués

**Fichiers à créer:**
- `lib/features/chat/presentation/sheets/report_message_sheet.dart`
- `lib/features/chat/presentation/sheets/message_actions_sheet.dart`

**Validation:**
- [ ] Signalement crée ticket `support_tickets`
- [ ] Blocage crée aussi un ticket
- [ ] Section Bloqués affiche liste + option débloquer

---

### Phase 6: Tests & Cleanup (4-6h) 🟢 BASSE PRIORITÉ
**Objectif:** Tester et nettoyer le code

**Tâches:**
- [ ] Tests unitaires repositories
- [ ] Tests widgets critiques
- [ ] Supprimer ancien code FlutterFlow
- [ ] Documentation README du module

**Fichiers à créer:**
- `lib/features/chat/test/domain/repositories/*.dart`
- `lib/features/chat/test/data/datasources/*.dart`
- `lib/features/chat/README.md`

**Validation:**
- [ ] Tous les tests passent
- [ ] Ancien code FlutterFlow supprimé
- [ ] README complet avec exemples

---

## ⚠️ PIÈGES À ÉVITER

### 1. Réutiliser Code FlutterFlow
❌ **MAUVAIS:**
```dart
// Ne pas copier depuis lib/custom_code/widgets/chat_message_list.dart
```

✅ **BON:**
```dart
// Créer nouveau composant dans lib/features/chat/presentation/widgets/
// S'inspirer de la logique, mais réécrire proprement
```

### 2. Oublier les Décisions Métier
❌ **MAUVAIS:** Implémenter le trigger auto Pro→Bride
✅ **BON:** Créer RPC + sheet pour demande explicite

### 3. Casser Agora Vidéo
❌ **MAUVAIS:** Toucher les fichiers Agora
✅ **BON:** Préserver complètement, juste intégrer dans ChatDetails

### 4. Design System - ATTENTION SPÉCIALE
⚠️ **CHAT DETAILS UNIQUEMENT:** NE PAS appliquer Design System v2 sur ChatDetails
- ✅ **ChatDetails:** Garder design actuel identique (bulles, couleurs, typos)
- ✅ **Messages Page & Sheets:** Appliquer Design System v2
- ✅ **Autres pages:** Appliquer Design System v2

❌ **MAUVAIS:** Changer les couleurs de bulles de chat
❌ **MAUVAIS:** Modifier la typographie des messages
✅ **BON:** Copier exactement le design visuel actuel de ChatDetails

### 5. Négliger les Tests
❌ **MAUVAIS:** Pas de tests
✅ **BON:** Tests pour repositories, use cases, BLoCs critiques

### 6. Oublier Rooms Publiques
❌ **MAUVAIS:** Supprimer la logique des rooms publiques
✅ **BON:** Conserver, juste refactoriser

---

## 🔍 POINTS DE VALIDATION CRITIQUES

### Avant de commencer Phase 2
- [ ] Phase 1 (Backend) 100% terminée et testée
- [ ] RPC `create_contact_request` fonctionne
- [ ] Enum `connectionRequestSource` renommé

### Avant de commencer Phase 3
- [ ] Phase 2 (Foundation) complet
- [ ] Toutes les entités compilent
- [ ] ContactRequestSheet affiche correctement

### Avant de commencer Phase 4
- [ ] Phase 3 (Messages) complet
- [ ] MessagesPage affiche 3 sections
- [ ] Navigation fonctionne

### Avant de commencer Phase 5
- [ ] Phase 4 (Chat Details) complet
- [ ] Messages affichent correctement
- [ ] Agora vidéo fonctionne

### Avant de commencer Phase 6
- [ ] Phase 5 (Modération) complet
- [ ] Signalement et blocage fonctionnent
- [ ] Tickets CRM créés

---

## 📚 RESSOURCES DISPONIBLES

### Code Existant à Consulter
- `lib/features/map/` - Pattern Clean Architecture à suivre
- `docs/archive/chat_backup_2025-12-02/` - Code FlutterFlow à comprendre
- `lib/core/design/` - Design System tokens

### Commandes Utiles
```bash
# Vérifier compilation
flutter analyze

# Lancer tests
flutter test

# Format code
dart format lib/features/chat/

# Build app
flutter build apk --debug
```

### Fichiers de Configuration
- `pubspec.yaml` - Dépendances (BLoC, Supabase, etc.)
- `analysis_options.yaml` - Règles linting
- `lib/main.dart` - Point d'entrée app

---

## 🎯 CRITÈRES DE SUCCÈS - VALIDATION 100%

### ✅ Phase 0.5 (ContactRequestSheet) - CRITIQUE
- [ ] Sheet s'ouvre quand Pro tente de contacter Bride
- [ ] Champ message obligatoire validé
- [ ] Source affichée (fromWedding, fromWishlist, etc.)
- [ ] RPC `create_contact_request` appelée avec succès
- [ ] Toast confirmation affiché
- [ ] Retour page précédente automatique

### ✅ Phase 1 (Backend)
- [ ] Trigger `trg_on_first_msg_pro_bride` supprimé
- [ ] RPC `create_contact_request` retourne demande créée
- [ ] RPC `accept_connection_request` crée room + met status active
- [ ] Enum `connectionRequestSource` renommé (4 valeurs)
- [ ] Migration SQL appliquée sans erreur

### ✅ Phase 2 (Foundation)
- [ ] Structure `lib/features/chat/` complète
- [ ] Toutes les entités domain définies
- [ ] Repository interfaces implémentées
- [ ] Datasources remote + local créées
- [ ] Design System v3 appliqué sur tous nouveaux composants

### ✅ Phase 3 (Messages Unifiée)
- [ ] MessagesPage unifiée bride/pro fonctionnelle
- [ ] 3 sections: Demandes, Conversations, Bloqués
- [ ] Tap demande → AcceptDeclineSheet
- [ ] Tap conversation → ChatDetails
- [ ] Tap bloqué → option débloquer
- [ ] Pull-to-refresh fonctionnel
- [ ] Compteurs unread corrects

### ✅ Phase 4 (Chat Details)
- [ ] Messages affichent (text, image, audio)
- [ ] Realtime updates instantanés
- [ ] Reconnexion après perte réseau
- [ ] Mode "contact request" (Accept/Decline)
- [ ] Médias uploadent correctement
- [ ] URLs signées pré-chargées
- [ ] Agora vidéo préservé et fonctionnel
- [ ] Design gardé IDENTIQUE à l'actuel

### ✅ Phase 5 (Modération Complète)
- [ ] ReportMessageSheet (4 raisons) → ticket `support_tickets`
- [ ] ReportUserSheet → ticket `support_tickets`
- [ ] Message signalé masqué immédiatement (`is_deleted=true`)
- [ ] Blocage utilisateur → RLS empêche voir messages
- [ ] Utilisateurs bloqués listés dans BlockedUsersSheet
- [ ] Déblocage fonctionne
- [ ] Archive conversation → `conversation_status = 'archived'`
- [ ] Conversations archivées masquées liste principale

### ✅ Phase 6 (Notifications)
- [ ] Trigger `trg_outbox_chat_msg` crée events
- [ ] Edge function `notifications_outbox_drain` traite
- [ ] Tokens FCM stockés correctement
- [ ] Push notifications reçues
- [ ] Centre de notification affiche messages
- [ ] Badge compteur unread mis à jour

### ✅ Phase 7 (Tests & Validation)
- [ ] Tests unitaires repositories (90%+ couverture)
- [ ] Tests widgets critiques
- [ ] Tests d'intégration RPCs
- [ ] Tests manuels ALL flows:
  - Pro→Bride: demande → acceptation → chat
  - Pro→Pro: chat direct (tous plans)
  - Bride→Pro: chat direct
  - Signalement → masquage + ticket
  - Blocage → messages cachés
  - Archive → disparition liste
- [ ] Tests edge cases:
  - Demande simultanée Pro↔Bride
  - Perte connexion envoi média
  - URL signée expirée
  - Contact utilisateur bloqué
- [ ] Ancien code FlutterFlow supprimé
- [ ] README complet avec architecture
- [ ] Performance: <100ms chargement messages
- [ ] Mémoire: <50MB pour 1000 messages

### ✅ Phase 8 (UI/UX Design System v3)
- [ ] TOUS les sheets utilisent `LynewedSheet`
- [ ] TOUS les boutons utilisent `LynewedButton`
- [ ] TOUS les inputs utilisent `LynewedTextField`
- [ ] Spacing: 30px sections, 10px label→content
- [ ] Font weight max w500 (sauf exceptions)
- [ ] Border radius: 24px sheets, 4px items
- [ ] Couleurs: `LynewedColors` uniquement
- [ ] Aucun style inline ou couleur hardcodée
- [ ] Audit visuel: cohérence avec MessagesPage

---

## 📞 COMMUNICATION

### Statut Attendu
- Après chaque phase: résumé des changements + points de validation
- Avant chaque phase: confirmation que prérequis sont satisfaits
- En cas de blocage: clarifier avec les décisions de l'audit

### Documentation
- Mettre à jour `PROJECT.md` après Phase 6
- Créer `lib/features/chat/README.md` avec architecture
- Documenter les décisions métier implémentées

---

## � TÂCHES PRIORITAIRES IMMÉDIATES

### 1. ContactRequestSheet (CRITIQUE)
**Fichier à créer:** `lib/features/chat/presentation/sheets/contact_request_sheet.dart`
**Modifier:** `lib/actions/actions.dart` - Remplacer `_showInfoDialog` par ouverture du sheet

### 2. Vérifier Conditions de Contact
- RPC `open_or_prepare_contact_context` retourne les bons status
- `requiresRequest` pour Pro→Bride sans room
- `roomReady` pour Bride→Pro et Pro→Pro
- Conditions d'abonnement (Premium+ pour Pro→Bride)

### 3. Notifications Centre de Notification
**Problème:** Les notifications de nouveaux messages n'apparaissent pas.
**À investiguer:**
- Trigger `trg_outbox_chat_msg`
- Edge function `notifications_outbox_drain`
- Tokens FCM
- Page centre de notification

### 4. UI/UX Design System v3
**Sheets/Modals à refactoriser:**
- `ChatDetailsPage` - Header, composer, message bubbles
- `MessageActionsSheet` - Actions sur messages
- `ConversationActionsSheet` - Actions sur conversations
- `AcceptDeclineSheet` - Pour demandes de contact pending
- `ReportMessageSheet` - 4 raisons de signalement
- `ReportUserSheet` - Signalement profil
- `BlockedUsersSheet` - Liste utilisateurs bloqués
- `ArchiveConversationSheet` - Archivage conversations
- Tous les dialogs d'erreur/confirmation du module chat

### 5. Tests de Validation End-to-End
**Flows critiques à tester:**
- Pro→Bride: demande → acceptation → chat
- Pro→Pro: chat direct (tous plans)
- Bride→Pro: chat direct
- Signalement message → masquage immédiat + ticket
- Blocage utilisateur → messages masqués + RLS
- Archive conversation → disparition liste principale
- Notifications push + centre notification
- Realtime: message instantané, reconnexion
- Médias: upload images/audio, URLs signées

### 6. Edge Cases & Gestion Erreurs
**Scénarios à gérer:**
- Pro envoie demande pendant que Bride contacte simultanément
- Perte connexion pendant envoi message avec médias
- URL signée expirée pendant lecture audio
- Tentative contact utilisateur bloqué
- Double soumission demande de contact
- Room créée mais participant supprimé
- Échec upload média (stockage plein, réseau)
- Notification push non reçue (fallback in-app)

---

## �🚀 DÉMARRAGE

1. **Lire en priorité:**
   - `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` (sections 🔧, 4, 5, 12)
   - `docs/PROJECT.md`
   - Ce prompt complet

2. **Vérifier prérequis:**
   - [ ] Supabase dev accessible
   - [ ] Flutter SDK à jour
   - [ ] Dépendances installées (`flutter pub get`)

3. **Commencer Phase 0.5 (ContactRequestSheet):**
   - [ ] Créer le sheet avec Design System v3
   - [ ] Modifier `lib/actions/actions.dart`
   - [ ] Tester depuis wedding_details_sheet

4. **Ensuite Phase 1 (Backend):**
   - [ ] Créer migration Supabase pour supprimer trigger
   - [ ] Créer RPC `create_contact_request`
   - [ ] Tester via SQL

---

**Bonne chance! 🎉 Le module Map a montré que c'est possible. À toi de jouer!**
