# 🚀 PROMPT REFACTORISATION CHAT & CONTACT MODULE

**Date:** 2025-12-02  
**Version:** v1.0  
**Durée estimée:** 44-60 heures  
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
**Fichier:** `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` (v1.1)

**Sections critiques:**
- Section 4: Logiques Métier (VALIDÉ) ← **À IMPLÉMENTER**
- Section 5: Modération (VALIDÉ) ← **À IMPLÉMENTER**
- Section 9: Gaps et Problèmes Identifiés
- Section 10: Plan de Refactorisation

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

## 📅 PHASES DE REFACTORISATION (ORDRE CRITIQUE)

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

## 🎯 CRITÈRES DE SUCCÈS

### Phase 1 (Backend)
- ✅ RPC `create_contact_request` retourne demande créée
- ✅ RPC `accept_connection_request` crée room
- ✅ Enum renommé, migration appliquée

### Phase 2 (Foundation)
- ✅ Structure `lib/features/chat/` complète
- ✅ Toutes les entités définies
- ✅ ContactRequestSheet fonctionne

### Phase 3 (Messages)
- ✅ MessagesPage affiche 3 sections
- ✅ Navigation vers ChatDetails fonctionne
- ✅ Design System appliqué

### Phase 4 (Chat Details)
- ✅ Messages affichent correctement
- ✅ Realtime updates fonctionnent
- ✅ Agora vidéo préservé

### Phase 5 (Modération)
- ✅ Signalement crée ticket
- ✅ Blocage fonctionne
- ✅ Section Bloqués affiche liste

### Phase 6 (Tests)
- ✅ Tous les tests passent
- ✅ Ancien code supprimé
- ✅ README complet

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

## 🚀 DÉMARRAGE

1. **Lire en priorité:**
   - `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` (sections 4, 5, 9, 10)
   - `docs/PROJECT.md`
   - Ce prompt complet

2. **Vérifier prérequis:**
   - [ ] Supabase dev accessible
   - [ ] Flutter SDK à jour
   - [ ] Dépendances installées (`flutter pub get`)

3. **Commencer Phase 1:**
   - [ ] Créer migration Supabase pour supprimer trigger
   - [ ] Créer RPC `create_contact_request`
   - [ ] Tester via SQL

---

**Bonne chance! 🎉 Le module Map a montré que c'est possible. À toi de jouer!**
