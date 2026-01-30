/// Chat page for guests.
///
/// Displays the wedding team chat room.
/// Uses existing chat infrastructure from EPIC-01.
library;

import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../chat/presentation/pages/chat_details_page.dart';

/// Chat page for the wedding team.
///
/// Shows the group chat where all guests and the bride
/// can communicate about the wedding.
class GuestChatPage extends StatelessWidget {
  /// The chat room ID for the wedding team.
  final String? chatRoomId;

  /// Creates a guest chat page.
  const GuestChatPage({
    this.chatRoomId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (chatRoomId == null) {
      return _buildNoChatState(context);
    }

    // Use existing chat system with wedding team configuration
    return ChatDetailsPage(
      roomId: chatRoomId!,
      isWeddingTeamChat: true,
      publicRoomTitle: 'Groupe du mariage',
      hideVideoCall: true,
    );
  }

  Widget _buildNoChatState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LynewedSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: LynewedColors.textSecondary,
            ),
            SizedBox(height: LynewedSpacing.lg),
            Text(
              'Groupe du mariage',
              style: LynewedTextStyles.headlineSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'Le chat sera disponible une fois que la mariée aura créé le groupe.',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
