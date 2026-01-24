# Story S36: Custom Code - Chat Actions Migration

## Description

En tant que developpeur, je veux migrer les actions chat de custom_code vers le module Chat afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [ ] Given les actions chat dans custom_code When je les migre Then elles sont dans le datasource/repository Chat

- [ ] Given les imports des actions When je les supprime Then aucune erreur de compilation

- [ ] Given les fonctionnalites When je les teste Then tout fonctionne identiquement

## Fichiers Concernes

### Actions a Migrer (vers Chat module)
```
lib/custom_code/actions/
├── send_text_message_action.dart
├── delete_own_message_action.dart
├── mark_room_read_action.dart
├── upload_and_send_images_action.dart
├── upload_and_send_audio_action.dart
├── archive_conversation_action.dart
├── report_message_action.dart
├── get_room_header_action.dart
├── get_rooms_with_unread_counts_action.dart
├── get_unread_messages_count_action.dart
├── block_user_action.dart
├── unblock_user_action.dart
├── open_or_prepare_contact_action.dart
├── get_pending_contact_requests_action.dart
├── join_public_room_if_needed_action.dart
├── get_public_chat_rooms_for_brides_action.dart
├── get_any_profile_as_room_header.dart
├── create_signed_url_for_chat_media_action.dart
├── validate_chat_details_params.dart
```

### Destination
- `lib/features/chat/data/datasources/chat_remote_datasource.dart`
- `lib/features/chat/data/repositories/chat_repository_impl.dart`
- `lib/features/chat/data/repositories/contact_repository_impl.dart`

## Notes Techniques

### Migration Pattern
Pour chaque action :

1. **Analyser** la logique de l'action
2. **Identifier** la destination (datasource ou repository)
3. **Migrer** la logique vers la methode correspondante
4. **Mettre a jour** les appels dans le code
5. **Supprimer** l'action originale

### Exemple Migration
```dart
// AVANT: lib/custom_code/actions/send_text_message_action.dart
Future<void> sendTextMessageAction(String roomId, String content) async {
  await Supabase.instance.client.from('chat_messages').insert({
    'room_id': roomId,
    'content': content,
    'sender_id': currentUserUid,
    'message_type': 'text',
  });
}

// APRES: dans ChatRemoteDatasource
@override
Future<ChatMessageModel> sendTextMessage(String roomId, String content) async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) throw NotAuthenticatedException();

  final response = await _supabase.from('chat_messages').insert({
    'room_id': roomId,
    'content': content,
    'sender_id': userId,
    'message_type': 'text',
  }).select().single();

  return ChatMessageModel.fromJson(response);
}
```

### Verification
Apres migration, verifier :
- [ ] Aucun import de l'action dans le codebase
- [ ] Tests passent
- [ ] Fonctionnalite identique

## Definition of Done

- [ ] Toutes les actions chat migrees
- [ ] Fichiers actions supprimes
- [ ] Tests passent
- [ ] Aucune regression fonctionnelle
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Elevee
**Risque** : Moyen

## Dependances

- S05-S07 : Chat module

## Stories Dependantes

- S41 : FlutterFlow cleanup
