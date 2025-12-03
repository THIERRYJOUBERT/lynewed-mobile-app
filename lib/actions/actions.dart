import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import '/features/chat/presentation/pages/chat_details_page.dart';
import '/features/chat/domain/entities/chat_enums.dart' as chat_enums;
import '/core/services/unread_counter_service.dart';
import 'package:flutter/material.dart';

/// Navigate to chat with a target profile
/// Uses Clean Architecture ChatDetailsPage with full data passing
Future contactChatRoom(
  BuildContext context, {
  required String? targetProfileID,
}) async {
  if (targetProfileID == null || targetProfileID.isEmpty) {
    _showErrorDialog(context, 'Invalid target profile');
    return;
  }

  ChatEntryContextStruct? contactContext;

  contactContext = await actions.openOrPrepareContactAction(
    targetProfileID,
  );
  
  if ((contactContext.status == ChatEntryStatus.roomReady) ||
      (contactContext.status == ChatEntryStatus.requestPending)) {
    
    if (!context.mounted) return;
    
    // Only pass pendingRequestId if status is actually requestPending
    // This prevents showing "Waiting for response" when room is ready
    final bool isActuallyPending = contactContext.status == ChatEntryStatus.requestPending;
    
    // Use Clean Architecture ChatDetailsPage with full data
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: contactContext!.roomId ?? '',
          isPublicRoom: contactContext.isPublic,
          pendingRequestId: isActuallyPending ? contactContext.requestId : null,
          otherProfileId: contactContext.otherProfileId,
          otherFullName: contactContext.otherFullName,
          otherAvatarUrl: contactContext.otherAvatarUrl,
          otherRole: _convertUserRole(contactContext.otherRole),
          viewerIsReviewer: isActuallyPending ? contactContext.viewerIsReviewer : false,
          firstMessageTextOnly: contactContext.firstMessageTextOnly,
        ),
      ),
    );
    // Refresh global unread counter after returning from chat
    UnreadCounterService.instance.forceRefresh();
  } else if (contactContext.status == ChatEntryStatus.requiresRequest) {
    // Pro→Bride: Must send a contact request first
    // TODO: Show ContactRequestSheet when implemented
    if (!context.mounted) return;
    _showInfoDialog(
      context,
      title: 'Demande de contact requise',
      message: 'Pour contacter cette mariée, vous devez d\'abord envoyer une demande de contact. Cette fonctionnalité sera bientôt disponible.',
    );
  } else if (contactContext.status == ChatEntryStatus.notAllowed) {
    if (!context.mounted) return;
    _showInfoDialog(
      context,
      title: 'Contact non disponible',
      message: contactContext.reason == 'INSUFFICIENT_TIER' 
          ? 'Votre abonnement ne permet pas de contacter les mariées. Passez à Premium pour débloquer cette fonctionnalité.'
          : 'Vous ne pouvez pas contacter ce profil.',
    );
  } else if (contactContext.status == ChatEntryStatus.blocked) {
    if (!context.mounted) return;
    _showInfoDialog(
      context,
      title: 'Contact bloqué',
      message: 'Vous ne pouvez pas contacter ce profil.',
    );
  } else {
    if (!context.mounted) return;
    _showErrorDialog(context, contactContext.reason ?? 'Unable to start conversation');
  }
}

/// Convert FlutterFlow UserRole to Clean Architecture UserRole
chat_enums.UserRole? _convertUserRole(UserRole? role) {
  if (role == null) return null;
  switch (role) {
    case UserRole.bride:
      return chat_enums.UserRole.bride;
    case UserRole.professional:
      return chat_enums.UserRole.professional;
  }
}

/// Show error dialog
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (alertDialogContext) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
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

/// Show info dialog with custom title
void _showInfoDialog(BuildContext context, {required String title, required String message}) {
  showDialog(
    context: context,
    builder: (alertDialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
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

/// Navigate to chat from Messages page
/// Uses Clean Architecture ChatDetailsPage with full data passing
Future contactRoomChatMessagerie(
  BuildContext context, {
  required String? otherProfileId,
}) async {
  if (otherProfileId == null || otherProfileId.isEmpty) {
    _showErrorDialog(context, 'Invalid profile');
    return;
  }

  ChatEntryContextStruct? contactContextMessagerie;

  contactContextMessagerie = await actions.openOrPrepareContactAction(
    otherProfileId,
  );
  
  if ((contactContextMessagerie.status == ChatEntryStatus.roomReady) ||
      (contactContextMessagerie.status == ChatEntryStatus.requestPending)) {
    
    if (!context.mounted) return;
    
    // Only pass pendingRequestId if status is actually requestPending
    final bool isActuallyPending = contactContextMessagerie.status == ChatEntryStatus.requestPending;
    
    // Use Clean Architecture ChatDetailsPage with full data
    // Note: last_read_at is updated in ChatDetailsPage.initState via ChatRoomNotifier
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: contactContextMessagerie!.roomId ?? '',
          isPublicRoom: contactContextMessagerie.isPublic,
          pendingRequestId: isActuallyPending ? contactContextMessagerie.requestId : null,
          otherProfileId: contactContextMessagerie.otherProfileId,
          otherFullName: contactContextMessagerie.otherFullName,
          otherAvatarUrl: contactContextMessagerie.otherAvatarUrl,
          otherRole: _convertUserRole(contactContextMessagerie.otherRole),
          viewerIsReviewer: isActuallyPending ? contactContextMessagerie.viewerIsReviewer : false,
          firstMessageTextOnly: contactContextMessagerie.firstMessageTextOnly,
        ),
      ),
    );
    // Refresh global unread counter after returning from chat
    UnreadCounterService.instance.forceRefresh();
  } else {
    if (!context.mounted) return;
    _showErrorDialog(
      context, 
      contactContextMessagerie.reason ?? 
        'An error has occurred. Please try again.',
    );
  }
}
