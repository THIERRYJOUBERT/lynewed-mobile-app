# 🎯 CHAT MODULE - PHASE 4-6 MASTER PROMPT

**Pour:** Assistant Windsurf spécialisé  
**Date:** 2025-12-02  
**Durée totale:** 22-30 heures (Phase 4: 12-16h, Phase 5: 6-8h, Phase 6: 4-6h)  
**Complexité:** Moyenne-Élevée  

---

## 📋 CONTEXTE PROJET

### État Global LYNEWED
- **Version:** v1.1.1+59 (MVP en production)
- **Architecture:** Clean Architecture (domain/data/presentation)
- **Modules terminés:** Design System ✅, Map ✅
- **Module actuel:** Chat (Phases 1-3 terminées, Phase 4-6 en cours)
- **Codebase:** ~15,000+ lignes Dart
- **Environnement:** Supabase dev (hekyovgnovhfhmkpfrna)

### Phases Complétées
- ✅ **Phase 1 (6-8h):** Backend - Logique Contact
  - Trigger supprimé, enum renommé, RPCs créées
  - Migration: `20251202120000_chat_contact_refactoring_phase1.sql`
  
- ✅ **Phase 2 (8-10h):** Foundation Frontend
  - 7 entités domain, 8 enums, 2 repositories, 1 datasource
  - `ContactRequestSheet` + Design System 100%
  - 18 fichiers Dart créés
  
- ✅ **Phase 3 (8-12h):** Messages Page Unifiée
  - `ConversationsNotifier` (ChangeNotifier)
  - `MessagesPage` avec tabs (Conversations + Bloqués)
  - 4 widgets + 2 sheets
  - 13 fichiers Dart créés

---

## 🎯 OBJECTIF GLOBAL

**Compléter le module Chat avec ChatDetails, Realtime complet, et Modération**

### Phases restantes
- **Phase 4 (12-16h):** ChatDetails + Realtime
- **Phase 5 (6-8h):** Modération (report, block UI)
- **Phase 6 (4-6h):** Tests & Cleanup

---

## 📁 PHASE 4: CHAT DETAILS + REALTIME

### Fichiers à créer (9 fichiers)

#### State Management (3 fichiers)
```
presentation/bloc/
├── chat_room_state.dart          # États: Initial, Loading, Loaded, Error
├── chat_room_notifier.dart       # ChatRoomNotifier (ChangeNotifier)
└── bloc.dart                      # UPDATE barrel export
```

#### Widgets (4 fichiers)
```
presentation/widgets/
├── message_bubble.dart            # 1 message avec avatar + actions
├── message_list.dart              # Liste messages + pagination
├── message_composer.dart          # Input texte/image/audio
└── widgets.dart                   # UPDATE barrel export
```

#### Pages (2 fichiers)
```
presentation/pages/
├── chat_details_page.dart         # Page principale
└── pages.dart                     # UPDATE barrel export
```

### Architecture Realtime

#### ChatRoomNotifier (NEW)
```dart
class ChatRoomNotifier extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final String _roomId;
  
  ChatRoomState _state = const ChatRoomInitial();
  ChatRoomState get state => _state;
  
  StreamSubscription? _messagesSubscription;
  
  void _emit(ChatRoomState newState) {
    _state = newState;
    notifyListeners();
  }
  
  Future<void> loadMessages() async {
    _emit(const ChatRoomLoading());
    try {
      final messages = await _chatRepository.getMessages(roomId: _roomId);
      _emit(ChatRoomLoaded(messages: messages));
      _setupRealtimeMessages();
    } catch (e) {
      _emit(ChatRoomError(e.toString()));
    }
  }
  
  void _setupRealtimeMessages() {
    _messagesSubscription = _chatRepository
        .subscribeToMessages(_roomId)
        .listen((message) {
          if (state is ChatRoomLoaded) {
            final loaded = state as ChatRoomLoaded;
            final updated = [message, ...loaded.messages];
            _emit(loaded.copyWith(messages: updated));
          }
        });
  }
  
  Future<void> sendMessage({
    required String content,
    required MessageType type,
    String? attachmentUrl,
  }) async {
    try {
      await _chatRepository.sendMessage(
        roomId: _roomId,
        type: type,
        content: content,
        attachmentUrl: attachmentUrl,
      );
    } catch (e) {
      // Error handling
    }
  }
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
```

#### ConversationsNotifier (UPDATE)
```dart
class ConversationsNotifier extends ChangeNotifier {
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _requestsSubscription;
  
  void _setupRealtimeListeners() {
    // 1. Écouter nouveaux messages (refresh conversations)
    _messagesSubscription = _chatRepository
        .subscribeToConversationUpdates()
        .listen((_) => refresh());
    
    // 2. Écouter nouvelles demandes de contact
    _requestsSubscription = _contactRepository
        .subscribeToContactRequests()
        .listen((request) {
          if (state is ConversationsLoaded) {
            final loaded = state as ConversationsLoaded;
            final updated = [...loaded.pendingRequests, request];
            _emit(loaded.copyWith(pendingRequests: updated));
          }
        });
  }
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _requestsSubscription?.cancel();
    super.dispose();
  }
}
```

### Widgets à implémenter

#### MessageBubble
- Affiche 1 message (texte/image/audio)
- Avatar + nom + timestamp
- Actions: Delete (own), Report (other)
- Design System 100%

#### MessageList
- Liste messages (récents en bas)
- Pagination: charger anciens au scroll top
- Nouveaux messages apparaissent en bas
- Scroll auto vers bas
- Loading/Error states

#### MessageComposer
- Input texte (max 1000 chars)
- Image picker button
- Audio recorder button
- Send button
- Validation: non-vide

#### ChatDetailsPage
- Header: profil info + bouton Agora
- MessageList au centre
- MessageComposer en bas
- Mode "contact request" (Accept/Decline)

### Fonctionnalités Phase 4
- ✅ Affichage messages avec pagination
- ✅ Envoi texte/image/audio
- ✅ Realtime messages (subscriptions)
- ✅ Realtime MessagesPage (nouvelles demandes)
- ✅ Mode "contact request" (Accept/Decline)
- ✅ Agora video préservé
- ✅ Design System 100%
- ✅ Aucune erreur compilation

---

## 📁 PHASE 5: MODÉRATION

### Fichiers à créer (6 fichiers)

#### Widgets (3 fichiers)
```
presentation/widgets/
├── message_report_sheet.dart      # Sheet pour reporter message
├── user_block_sheet.dart          # Sheet pour bloquer utilisateur
└── moderation_widgets.dart        # Widgets modération
```

#### Pages (2 fichiers)
```
presentation/pages/
├── blocked_users_page.dart        # Page utilisateurs bloqués
└── moderation_pages.dart          # Barrel export
```

#### Updates (1 fichier)
```
presentation/widgets/widgets.dart  # UPDATE barrel export
```

### Fonctionnalités Phase 5
- ✅ Signaler message (spam, harassment, inappropriate, other)
- ✅ Bloquer utilisateur (UI dans chat + liste)
- ✅ Ticket CRM automatique (pas d'email)
- ✅ Masquage immédiat message
- ✅ Liste utilisateurs bloqués
- ✅ Déblocage facile
- ✅ Design System 100%

---

## 📁 PHASE 6: TESTS & CLEANUP

### Fichiers à créer (8 fichiers)

#### Tests (6 fichiers)
```
test/features/chat/
├── domain/
│   ├── entities/
│   │   ├── conversation_test.dart
│   │   ├── contact_request_test.dart
│   │   └── blocked_user_test.dart
│   └── repositories/
│       ├── chat_repository_test.dart
│       └── contact_repository_test.dart
├── presentation/
│   ├── bloc/
│   │   ├── conversations_notifier_test.dart
│   │   └── chat_room_notifier_test.dart
│   └── widgets/
│       └── message_bubble_test.dart
```

#### Documentation (2 fichiers)
```
docs/
├── CHAT_MODULE_COMPLETE.md        # Rapport final
└── CHAT_TESTING_GUIDE.md          # Guide tests
```

### Fonctionnalités Phase 6
- ✅ Tests unitaires entities
- ✅ Tests repositories
- ✅ Tests notifiers
- ✅ Tests widgets
- ✅ Code cleanup
- ✅ Documentation finale
- ✅ Performance check

---

## 🔌 DATASOURCE METHODS

### Déjà implémentées (Phase 2)
```dart
// Chat
Future<List<ChatMessage>> getMessages({required String roomId, int limit = 50, int? beforeId})
Future<ChatMessage> sendMessage({required String roomId, required MessageType type, String? content, String? attachmentUrl})
Stream<ChatMessage> subscribeToMessages(String roomId)
Future<void> deleteMessage(int messageId)
Future<void> markRoomAsRead(String roomId)

// Contact
Future<List<ContactRequest>> getPendingContactRequests()
Future<String?> acceptContactRequest(String requestId)
Future<bool> declineContactRequest(String requestId)
Future<bool> blockUser(String profileId)
Future<bool> unblockUser(String profileId)
Future<List<BlockedUser>> getBlockedUsers()
```

### À ajouter (Phase 4)
```dart
// Realtime MessagesPage
Stream<List<Conversation>> subscribeToConversationUpdates()
Stream<ContactRequest> subscribeToContactRequests()
```

---

## 🎨 DESIGN SYSTEM

### Import obligatoire
```dart
import '/core/design/design.dart';
```

### Tokens à utiliser
```dart
// Couleurs
LynewedColors.primary
LynewedColors.background
LynewedColors.surface
LynewedColors.textPrimary
LynewedColors.textSecondary
LynewedColors.error

// Typography
LynewedTextStyles.titleSmall
LynewedTextStyles.titleMedium
LynewedTextStyles.bodyLarge
LynewedTextStyles.bodyMedium
LynewedTextStyles.bodySmall
LynewedTextStyles.labelMedium

// Spacing
LynewedSpacing.xs  // 4px
LynewedSpacing.sm  // 8px
LynewedSpacing.md  // 16px
LynewedSpacing.lg  // 24px
LynewedSpacing.xl  // 32px

// Components
LynewedComponentStyles.primaryButton()
LynewedComponentStyles.secondaryButton()
LynewedComponentStyles.formInputDecoration()
LynewedComponentStyles.bottomSheetDecoration()
LynewedComponentStyles.cardDecoration()
```

---

## ⚠️ PIÈGES À ÉVITER

### ❌ NE PAS FAIRE
1. ❌ Réutiliser code FlutterFlow (`lib/compo_finaux/`, `lib/components/`)
2. ❌ Utiliser `flutter_bloc` (pas dans pubspec.yaml)
3. ❌ Modifier logique Agora
4. ❌ Créer subscriptions sans dispose()
5. ❌ Oublier `notifyListeners()` après changement état
6. ❌ Faire UI rendering dans le notifier
7. ❌ Hardcoder les IDs utilisateurs
8. ❌ Ignorer les erreurs de connexion Realtime

### ✅ À FAIRE
1. ✅ Créer nouveaux widgets propres dans `lib/features/chat/`
2. ✅ Utiliser ChangeNotifier pour state management
3. ✅ Appliquer Design System sur tous les widgets
4. ✅ Disposer correctement les streams
5. ✅ Gérer les erreurs avec messages clairs
6. ✅ Tester realtime avec plusieurs devices
7. ✅ Documenter les méthodes publiques
8. ✅ Suivre le pattern des phases précédentes

---

## 🧪 SCENARIOS DE TEST

### Phase 4 - ChatDetails
| Scenario | Résultat attendu |
|----------|------------------|
| Ouvrir ChatDetails | Messages chargés + realtime activé |
| Envoyer message | Message apparaît immédiatement |
| Recevoir message | Message apparaît en temps réel (< 1s) |
| Nouvelle demande | Apparaît dans MessagesPage immédiatement |
| Accepter demande | Room créée + visible pour les deux |
| Refuser demande | Demande disparaît pour les deux |
| Archiver conversation | Disparaît de MessagesPage |
| Bloquer utilisateur | Conversation cachée |
| Appel vidéo | Agora fonctionne (pas de régression) |

### Phase 5 - Modération
| Scenario | Résultat attendu |
|----------|------------------|
| Signaler message | Message masqué + ticket CRM créé |
| Bloquer utilisateur | Conversation cachée + ajouté liste bloqués |
| Débloquer utilisateur | Retiré liste bloqués |
| Voir liste bloqués | Affiche tous utilisateurs bloqués |
| Reporter spam | Ticket CRM avec raison "spam" |

### Phase 6 - Tests
| Test | Couverture |
|------|------------|
| Entities | 100% properties validation |
| Repositories | Mock + success/error cases |
| Notifiers | State transitions + realtime |
| Widgets | UI rendering + interactions |

---

## 📊 MÉTRIQUES DE SUCCÈS

| Phase | Fichiers | Lignes code | Durée | Complexité |
|-------|----------|-------------|-------|------------|
| 4 | 9 | 2000-2500 | 12-16h | Moyenne-Élevée |
| 5 | 6 | 800-1200 | 6-8h | Moyenne |
| 6 | 8 | 600-1000 | 4-6h | Faible |
| **Total** | **23** | **3400-4700** | **22-30h** | **Moyenne-Élevée** |

---

## 🚀 WORKFLOW DÉVELOPPEMENT

### Phase 4 (Jour 1-3)
```
Jour 1 (4-5h): Setup + ChatRoomState + ChatRoomNotifier
Jour 2 (4-5h): MessageBubble + MessageList + MessageComposer
Jour 3 (4-6h): ChatDetailsPage + Realtime + Validation
```

### Phase 5 (Jour 4)
```
Jour 4 (6-8h): Modération widgets + sheets + tests
```

### Phase 6 (Jour 5)
```
Jour 5 (4-6h): Tests unitaires + cleanup + documentation
```

---

## 📚 FICHIERS DE RÉFÉRENCE

### Documentation
- `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` - Contexte métier complet
- `lib/features/chat/README.md` - Documentation module Chat
- `docs/App/DESIGN_SYSTEM.md` - Design System tokens

### Code existant
- `lib/features/chat/domain/` - Entities + Repositories (Phase 2)
- `lib/features/chat/data/` - Datasources + Implementations (Phase 2)
- `lib/features/chat/presentation/bloc/conversations_cubit.dart` - Pattern ChangeNotifier
- `lib/features/chat/presentation/pages/messages_page.dart` - Pattern page
- `lib/features/map/` - Référence Clean Architecture

### Backup FlutterFlow
- `docs/archive/chat_backup_2025-12-02/` - Code original à consulter

---

## ✅ CHECKLIST FINALE

### Phase 4 - ChatDetails + Realtime
- [ ] ChatRoomState créé
- [ ] ChatRoomNotifier créé + Realtime
- [ ] MessageBubble widget
- [ ] MessageList widget
- [ ] MessageComposer widget
- [ ] ChatDetailsPage créée
- [ ] ConversationsNotifier updated (Realtime)
- [ ] flutter analyze = 0 errors
- [ ] Realtime messages ✅
- [ ] Realtime demandes ✅
- [ ] Agora préservé ✅

### Phase 5 - Modération
- [ ] MessageReportSheet widget
- [ ] UserBlockSheet widget
- [ ] BlockedUsersPage créée
- [ ] Signalement message ✅
- [ ] Blocage utilisateur ✅
- [ ] Ticket CRM ✅
- [ ] Liste bloqués ✅

### Phase 6 - Tests & Cleanup
- [ ] Tests entities ✅
- [ ] Tests repositories ✅
- [ ] Tests notifiers ✅
- [ ] Tests widgets ✅
- [ ] Code cleanup ✅
- [ ] Documentation finale ✅
- [ ] Performance check ✅

---

## 🎯 RÉSUMÉ FINAL

**À créer:**
- Phase 4: 1 Notifier + 1 State + 3 Widgets + 1 Page + Realtime
- Phase 5: 2 Sheets + 1 Page + widgets modération
- Phase 6: 8 Tests + documentation

**Tout doit:**
- ✅ Compiler sans erreurs
- ✅ Utiliser ChangeNotifier
- ✅ Appliquer Design System
- ✅ Avoir Realtime fonctionnel
- ✅ Préserver Agora
- ✅ Suivre Clean Architecture
- ✅ Être testé

**Durée totale:** 22-30 heures  
**Complexité:** Moyenne-Élevée  
**Prérequis:** Phases 1-3 ✅

**Commencer par:** Lire `docs/audits/CHAT_CONTACT_FEATURE_AUDIT.md` puis implémenter Phase 4

---

**Bonne chance! 🚀**
