# Story S36: Custom Code - Chat Actions Migration

## Status: COMPLETE

**Completed**: 2026-01-26

## Description

En tant que developpeur, je veux migrer les actions chat de custom_code vers le module Chat afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [x] Given les actions chat dans custom_code When je les migre Then elles sont dans le datasource/repository Chat
- [x] Given les imports des actions When je les supprime Then aucune erreur de compilation
- [x] Given les fonctionnalites When je les teste Then tout fonctionne identiquement

## Implementation Summary

### Actions SUPPRIMEES (deja dans Clean Architecture)

Ces 9 actions ont ete supprimees car leurs equivalents existent deja dans le module Chat:

| Action Supprimee | Equivalent Clean Architecture |
|-----------------|-------------------------------|
| `deleteOwnMessageAction` | `ChatRepositoryImpl.deleteMessage()` |
| `markRoomReadAction` | `ChatRepositoryImpl.markRoomAsRead()` |
| `archiveConversationAction` | `ChatRepositoryImpl.archiveConversation()` |
| `blockUserAction` | `ContactRepositoryImpl.blockUser()` |
| `unblockUserAction` | `ContactRepositoryImpl.unblockUser()` |
| `reportMessageAction` | `ContactRepositoryImpl.reportMessage()` |
| `getRoomHeaderAction` | `ChatRepositoryImpl.getOtherParticipantInfo()` |
| `getAnyProfileAsRoomHeader` | Non utilise |
| `validateChatDetailsParams` | Non utilise |

### Actions CONSERVEES (utilisees par pages legacy)

Ces actions sont encore necessaires car utilisees par des composants FlutterFlow legacy en production:

| Action | Utilisation |
|--------|-------------|
| `sendTextMessageAction` | `chat_composer_widget.dart` |
| `uploadAndSendImagesAction` | `chat_composer_widget.dart` |
| `uploadAndSendAudioAction` | `chat_composer_widget.dart` |
| `openOrPrepareContactAction` | `chat_composer_widget.dart`, `actions.dart` |
| `createSignedUrlForChatMediaAction` | `chat_message_list.dart` |
| `getRoomsWithUnreadCountsAction` | `messages_pro_widget.dart`, `messages_brides_widget.dart` |
| `getUnreadMessagesCountAction` | `unread_counter_service.dart` |
| `getPendingContactRequestsAction` | Pages messages legacy |
| `getPublicChatRoomsForBridesAction` | `home_brides_widget.dart` |
| `joinPublicRoomIfNeededAction` | `home_brides_widget.dart` |

### Rationale

La decision de conserver certaines actions est pragmatique:

1. **Stabilite Production**: 248 utilisateurs actifs utilisent ces pages
2. **Migration Graduelle**: Les pages legacy (FlutterFlow) seront migrees dans d'autres stories
3. **Pas de Breaking Changes**: Les actions supprimees n'etaient appelees nulle part

### Fichiers Modifies

```
DELETED:
- lib/custom_code/actions/delete_own_message_action.dart
- lib/custom_code/actions/mark_room_read_action.dart
- lib/custom_code/actions/archive_conversation_action.dart
- lib/custom_code/actions/block_user_action.dart
- lib/custom_code/actions/unblock_user_action.dart
- lib/custom_code/actions/report_message_action.dart
- lib/custom_code/actions/get_room_header_action.dart
- lib/custom_code/actions/get_any_profile_as_room_header.dart
- lib/custom_code/actions/validate_chat_details_params.dart

MODIFIED:
- lib/custom_code/actions/index.dart (exports removed)
```

## Validation

- `flutter analyze --fatal-infos`: PASS (0 warnings)
- `flutter test`: PASS (3069 tests)

## Definition of Done

- [x] Actions chat redondantes supprimees
- [x] Actions necessaires conservees pour compatibilite
- [x] Index mis a jour
- [x] Tests passent
- [x] Aucune regression fonctionnelle
- [x] `flutter analyze --fatal-infos` passe

## Future Work

Pour completer la migration, les stories suivantes devront migrer les pages legacy:

1. Migration de `chat_composer_widget.dart` vers Clean Architecture
2. Migration de `chat_message_list.dart` vers Clean Architecture
3. Migration des pages `messages_*_widget.dart` vers MessagesPage Clean Arch
4. Migration de `home_brides_widget.dart` vers Clean Architecture

## Notes Techniques

Le module Chat Clean Architecture (`lib/features/chat/`) contient deja toutes les implementations necessaires:

- `ChatRemoteDatasource`: Operations Supabase
- `ChatRepositoryImpl`: Logique metier chat
- `ContactRepositoryImpl`: Logique contact/blocking/reporting

Les actions restantes dans `custom_code` sont des wrappers temporaires qui seront elimines lors de la migration des widgets FlutterFlow correspondants.
