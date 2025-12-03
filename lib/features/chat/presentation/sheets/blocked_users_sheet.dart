/// Archived sheet - Clean Architecture
/// 
/// Modal sheet displaying archived/blocked conversations and blocked users.
/// Design System v2 applied.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../widgets/blocked_user_tile.dart';
import '../widgets/archived_conversation_tile.dart';

/// Sheet displaying archived conversations and blocked users
class ArchivedSheet extends StatefulWidget {
  const ArchivedSheet({
    super.key,
    required this.archivedConversations,
    required this.blockedUsers,
    required this.onUnarchive,
    required this.onUnblock,
  });

  final List<Conversation> archivedConversations;
  final List<BlockedUser> blockedUsers;
  final Future<void> Function(Conversation conversation) onUnarchive;
  final Future<bool> Function(BlockedUser user) onUnblock;

  /// Show the sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required List<Conversation> archivedConversations,
    required List<BlockedUser> blockedUsers,
    required Future<void> Function(Conversation conversation) onUnarchive,
    required Future<bool> Function(BlockedUser user) onUnblock,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArchivedSheet(
        archivedConversations: archivedConversations,
        blockedUsers: blockedUsers,
        onUnarchive: onUnarchive,
        onUnblock: onUnblock,
      ),
    );
  }

  @override
  State<ArchivedSheet> createState() => _ArchivedSheetState();
}

class _ArchivedSheetState extends State<ArchivedSheet> {
  late List<Conversation> _archivedConversations;
  late List<BlockedUser> _blockedUsers;

  @override
  void initState() {
    super.initState();
    _archivedConversations = List.from(widget.archivedConversations);
    _blockedUsers = List.from(widget.blockedUsers);
  }

  bool get _isEmpty => _archivedConversations.isEmpty && _blockedUsers.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LynewedBorders.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LynewedColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header - same style as LynewedSheet (title left, close right)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Archived',
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: LynewedColors.gray300,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider - same as LynewedSheet
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Divider(height: 1, color: LynewedColors.gray200),
          ),
          
          // Content
          Flexible(
            child: _isEmpty
                ? _buildEmptyState()
                : _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.archive_outlined,
              size: 48,
              color: LynewedColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No archived items',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      children: [
        // Archived conversations section
        if (_archivedConversations.isNotEmpty) ...[
          Text(
            'Archived Conversations',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 10),
          ..._archivedConversations.map((conversation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ArchivedConversationTile(
              conversation: conversation,
              onAction: () async {
                if (conversation.conversationStatus == ConversationStatus.blocked) {
                  // Unblock - need to find the blocked user
                  final blockedUser = _blockedUsers.firstWhere(
                    (u) => u.blockedProfileId == conversation.otherProfileId,
                    orElse: () => BlockedUser(
                      blockedProfileId: conversation.otherProfileId ?? '',
                      createdAt: DateTime.now(),
                      fullName: conversation.displayName,
                    ),
                  );
                  final success = await widget.onUnblock(blockedUser);
                  if (success && mounted) {
                    setState(() {
                      _archivedConversations.removeWhere((c) => c.roomId == conversation.roomId);
                      _blockedUsers.removeWhere((u) => u.blockedProfileId == conversation.otherProfileId);
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${conversation.displayName} unblocked'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } else {
                  // Unarchive
                  await widget.onUnarchive(conversation);
                  if (mounted) {
                    setState(() {
                      _archivedConversations.removeWhere((c) => c.roomId == conversation.roomId);
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${conversation.displayName} restored'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          )),
          const SizedBox(height: 20),
        ],
        
        // Blocked users section (users blocked but no conversation)
        if (_blockedUsers.where((u) => !_archivedConversations.any((c) => c.otherProfileId == u.blockedProfileId)).isNotEmpty) ...[
          Text(
            'Blocked Users',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 10),
          ..._blockedUsers
              .where((u) => !_archivedConversations.any((c) => c.otherProfileId == u.blockedProfileId))
              .map((user) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BlockedUserTile(
              blockedUser: user,
              onUnblock: () async {
                final success = await widget.onUnblock(user);
                if (success && mounted) {
                  setState(() {
                    _blockedUsers.removeWhere((u) => u.blockedProfileId == user.blockedProfileId);
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${user.fullName ?? 'User'} unblocked'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
          )),
        ],
      ],
    );
  }
}
