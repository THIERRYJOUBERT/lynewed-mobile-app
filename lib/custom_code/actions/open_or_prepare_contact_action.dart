// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
ChatEntryStatus _entryStatusFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'roomready':
      return ChatEntryStatus.roomReady;
    case 'requestpending':
      return ChatEntryStatus.requestPending;
    case 'notallowed':
      return ChatEntryStatus.notAllowed;
    case 'blocked':
      return ChatEntryStatus.blocked;
    case 'error':
    default:
      return ChatEntryStatus.error;
  }
}

UserRole? _userRoleFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'professional':
      return UserRole.professional;
    case 'bride':
      return UserRole.bride;
    default:
      return null;
  }
}

ConversationStatus _conversationStatusFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'pending':
      return ConversationStatus.pending;
    case 'declined':
      return ConversationStatus.declined;
    case 'blocked':
      return ConversationStatus.blocked;
    case 'reportedpending':
      return ConversationStatus.reportedPending;
    case 'archived':
      return ConversationStatus.archived;
    case 'active':
    default:
      return ConversationStatus.active;
  }
}

// --- Action principale ---

Future<ChatEntryContextStruct> openOrPrepareContactAction(
    String targetProfileId) async {
  // Vérification initiale des paramètres
  if (targetProfileId.isEmpty) {
    return ChatEntryContextStruct(
      status: ChatEntryStatus.error,
      reason: 'invalid_target',
      isPublic: false,
      isRoomEmpty: false,
      firstMessageTextOnly: false,
      limitToSingleInitialMessage: false,
      viewerIsReviewer: false,
    );
  }
  try {
    // Appel de la fonction RPC créée dans Supabase
    final data =
        await SupaFlow.client.rpc('open_or_prepare_contact_context', params: {
      'p_target': targetProfileId,
    });

    // Gestion d'une réponse inattendue du backend
    if (data is! Map) {
      return ChatEntryContextStruct(
        status: ChatEntryStatus.error,
        reason: 'bad_payload',
        isPublic: false,
        isRoomEmpty: false,
        firstMessageTextOnly: false,
        limitToSingleInitialMessage: false,
        viewerIsReviewer: false,
      );
    }

    // Conversion de la réponse JSON en notre DataType FlutterFlow `ChatEntryContextStruct`
    return ChatEntryContextStruct(
      status: _entryStatusFromString(data['status']?.toString()),
      roomId: data['roomId']?.toString(),
      requestId: data['requestId']?.toString(),
      isPublic: (data['isPublic'] == true),
      otherProfileId: data['otherProfileId']?.toString(),
      otherFullName: data['otherFullName']?.toString(),
      otherAvatarUrl:
          stringToImagePath(data['otherAvatarUrl']?.toString() ?? ''),
      otherRole: _userRoleFromString(data['otherRole']?.toString()),
      isRoomEmpty: data['isRoomEmpty'] == true,
      firstMessageTextOnly: data['firstMessageTextOnly'] == true,
      limitToSingleInitialMessage: data['limitToSingleInitialMessage'] == true,
      viewerIsReviewer: data['viewerIsReviewer'] == true,
      conversationStatus:
          _conversationStatusFromString(data['conversationStatus']?.toString()),
      reason: data['reason']?.toString(),
    );
  } catch (e) {
    // Gestion des erreurs réseau ou des exceptions levées par la RPC (ex: RLS)
    return ChatEntryContextStruct(
      status: ChatEntryStatus.error,
      reason: e.toString(),
      isPublic: false,
      isRoomEmpty: false,
      firstMessageTextOnly: false,
      limitToSingleInitialMessage: false,
      viewerIsReviewer: false,
    );
  }
}
