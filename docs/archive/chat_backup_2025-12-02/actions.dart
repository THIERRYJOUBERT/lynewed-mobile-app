import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';

Future contactChatRoom(
  BuildContext context, {
  required String? targetProfileID,
}) async {
  ChatEntryContextStruct? contactContext;

  contactContext = await actions.openOrPrepareContactAction(
    targetProfileID!,
  );
  if ((contactContext.status == ChatEntryStatus.roomReady) ||
      (contactContext.status == ChatEntryStatus.requestPending)) {
    context.pushNamed(
      ChatDetailsWidget.routeName,
      queryParameters: {
        'roomId': serializeParam(
          contactContext.roomId,
          ParamType.String,
        ),
        'isPublic': serializeParam(
          false,
          ParamType.bool,
        ),
        'requestId': serializeParam(
          contactContext.requestId,
          ParamType.String,
        ),
        'otherProfileId': serializeParam(
          contactContext.otherProfileId,
          ParamType.String,
        ),
        'isRoomEmpty': serializeParam(
          contactContext.isRoomEmpty,
          ParamType.bool,
        ),
        'firstMessageTextOnly': serializeParam(
          contactContext.firstMessageTextOnly,
          ParamType.bool,
        ),
        'viewerIsReviewer': serializeParam(
          contactContext.viewerIsReviewer,
          ParamType.bool,
        ),
      }.withoutNulls,
    );
  } else {
    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(contactContext!.reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}

Future contactRoomChatMessagerie(
  BuildContext context, {
  required String? otherProfileId,
}) async {
  ChatEntryContextStruct? contactContextMessagerie;

  contactContextMessagerie = await actions.openOrPrepareContactAction(
    otherProfileId!,
  );
  if ((contactContextMessagerie.status == ChatEntryStatus.roomReady) ||
      (contactContextMessagerie.status == ChatEntryStatus.requestPending)) {
    // ❌ NE PAS mettre à jour last_read_at ici!
    // Cela marque les messages comme lus AVANT d'ouvrir la conversation
    // last_read_at sera mis à jour dans ChatDetails quand la conversation est ouverte
    // await ChatRoomParticipantsTable().update(
    //   data: {
    //     'last_read_at': supaSerialize<DateTime>(getCurrentTimestamp),
    //   },
    //   matchingRows: (rows) => rows
    //       .eqOrNull(
    //         'room_id',
    //         contactContextMessagerie?.roomId,
    //       )
    //       .eqOrNull(
    //         'profile_id',
    //         currentUserUid,
    //       ),
    // );

    context.pushNamed(
      ChatDetailsWidget.routeName,
      queryParameters: {
        'roomId': serializeParam(
          contactContextMessagerie.roomId,
          ParamType.String,
        ),
        'isPublic': serializeParam(
          false,
          ParamType.bool,
        ),
        'requestId': serializeParam(
          contactContextMessagerie.requestId,
          ParamType.String,
        ),
        'otherProfileId': serializeParam(
          contactContextMessagerie.otherProfileId,
          ParamType.String,
        ),
        'isRoomEmpty': serializeParam(
          contactContextMessagerie.isRoomEmpty,
          ParamType.bool,
        ),
        'firstMessageTextOnly': serializeParam(
          contactContextMessagerie.firstMessageTextOnly,
          ParamType.bool,
        ),
        'viewerIsReviewer': serializeParam(
          contactContextMessagerie.viewerIsReviewer,
          ParamType.bool,
        ),
      }.withoutNulls,
    );
  } else {
    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(valueOrDefault<String>(
            contactContextMessagerie?.reason,
            'An error has occurred. Please try again by refreshing the page or contacting support. ',
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
