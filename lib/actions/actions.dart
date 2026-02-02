import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/features/chat/presentation/pages/chat_details_page.dart';
import '/features/chat/domain/entities/chat_enums.dart' as chat_enums;
import '/features/chat/domain/entities/entities.dart' show ContactRequestSource;
import '/features/chat/presentation/sheets/contact_request_sheet.dart';
import '/core/services/unread_counter_service.dart';
import 'package:flutter/material.dart';

/// Navigate to chat with a target profile
/// Uses Clean Architecture ChatDetailsPage with full data passing
/// [source] - Origin of contact (fromWedding, fromWishlist, fromProfile, fromAlert)
Future contactChatRoom(
  BuildContext context, {
  required String? targetProfileID,
  ContactRequestSource source = ContactRequestSource.fromProfile,
}) async {
  if (targetProfileID == null || targetProfileID.isEmpty) {
    _showErrorDialog(context, 'Invalid target profile');
    return;
  }

  ChatEntryContextStruct? contactContext;

  contactContext = await actions.openOrPrepareContactAction(
    targetProfileID,
  );
  
  if (contactContext.status == ChatEntryStatus.roomReady) {
    // Room exists - navigate to chat
    if (!context.mounted) return;
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailsPage(
          roomId: contactContext!.roomId,
          isPublicRoom: contactContext.isPublic,
          pendingRequestId: null,
          otherProfileId: contactContext.otherProfileId,
          otherFullName: contactContext.otherFullName,
          otherAvatarUrl: contactContext.otherAvatarUrl,
          otherRole: _convertUserRole(contactContext.otherRole),
          viewerIsReviewer: false,
        ),
      ),
    );
    // Refresh global unread counter after returning from chat
    UnreadCounterService.instance.forceRefresh();
  } else if (contactContext.status == ChatEntryStatus.requestPending) {
    // Request is pending - show info to user
    // Pro (sender): Show "waiting for response" message
    // Bride (receiver): Should see this in MessagesPage pending requests section
    if (!context.mounted) return;
    
    final bool isReviewer = contactContext.viewerIsReviewer;
    if (isReviewer) {
      // Bride viewing - navigate to pending request review (handled in MessagesPage)
      _showInfoDialog(
        context,
        title: 'Pending Request',
        message: 'You have a pending contact request from ${contactContext.otherFullName}. Check your Messages to review it.',
      );
    } else {
      // Pro viewing their own pending request
      _showInfoDialog(
        context,
        title: 'Request Pending',
        message: 'Your contact request to ${contactContext.otherFullName} is waiting for a response.',
      );
    }
  } else if (contactContext.status == ChatEntryStatus.requiresRequest) {
    // Pro→Bride: Must send a contact request first
    if (!context.mounted) return;
    await ContactRequestSheet.show(
      context: context,
      targetProfileId: targetProfileID,
      targetName: contactContext.otherFullName,
      source: source,
      targetAvatarUrl: contactContext.otherAvatarUrl,
    );
  } else if (contactContext.status == ChatEntryStatus.notAllowed) {
    if (!context.mounted) return;
    _showInfoDialog(
      context,
      title: 'Contact Unavailable',
      message: contactContext.reason == 'INSUFFICIENT_TIER' 
          ? 'Your subscription does not allow contacting brides. Upgrade to Premium to unlock this feature.'
          : 'You cannot contact this profile.',
    );
  } else if (contactContext.status == ChatEntryStatus.blocked) {
    if (!context.mounted) return;
    _showInfoDialog(
      context,
      title: 'Contact Blocked',
      message: 'You cannot contact this profile.',
    );
  } else {
    if (!context.mounted) return;
    _showErrorDialog(context, contactContext.reason);
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
    case UserRole.guest:
      // Guests don't participate in Pro-Bride chat, return null
      return null;
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
          roomId: contactContextMessagerie!.roomId,
          isPublicRoom: contactContextMessagerie.isPublic,
          pendingRequestId: isActuallyPending ? contactContextMessagerie.requestId : null,
          otherProfileId: contactContextMessagerie.otherProfileId,
          otherFullName: contactContextMessagerie.otherFullName,
          otherAvatarUrl: contactContextMessagerie.otherAvatarUrl,
          otherRole: _convertUserRole(contactContextMessagerie.otherRole),
          viewerIsReviewer: isActuallyPending ? contactContextMessagerie.viewerIsReviewer : false,
        ),
      ),
    );
    // Refresh global unread counter after returning from chat
    UnreadCounterService.instance.forceRefresh();
  } else {
    if (!context.mounted) return;
    _showErrorDialog(context, contactContextMessagerie.reason);
  }
}
