/// Chat details page - Clean Architecture
/// 
/// Main page for viewing and sending messages in a chat room.
/// Supports private rooms, public rooms, and contact request review mode.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';
import '../bloc/chat_room_notifier.dart';
import '../bloc/chat_room_state.dart';
import '../widgets/message_list.dart';
import '../widgets/message_composer.dart';
import '../sheets/message_actions_sheet.dart';

/// Chat details page widget
class ChatDetailsPage extends StatefulWidget {
  const ChatDetailsPage({
    super.key,
    required this.roomId,
    this.isPublicRoom = false,
    this.pendingRequestId,
    this.otherProfileId,
    this.otherFullName,
    this.otherAvatarUrl,
    this.otherRole,
    this.publicRoomTitle,
    this.viewerIsReviewer = false,
    this.firstMessageTextOnly = false,
  });

  /// Room ID
  final String roomId;

  /// Whether this is a public room
  final bool isPublicRoom;

  /// Pending contact request ID (for Pro→Bride flow)
  final String? pendingRequestId;

  /// Other participant's profile ID
  final String? otherProfileId;

  /// Other participant's full name
  final String? otherFullName;

  /// Other participant's avatar URL
  final String? otherAvatarUrl;

  /// Other participant's role
  final UserRole? otherRole;

  /// Public room title (if public)
  final String? publicRoomTitle;

  /// Whether current user is the reviewer (Bride reviewing Pro request)
  final bool viewerIsReviewer;

  /// Whether first message must be text only
  final bool firstMessageTextOnly;

  static const String routeName = 'ChatDetails';
  static const String routePath = '/chatDetails';

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  late ChatRoomNotifier _notifier;
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _notifier = ChatRoomNotifier(
      roomId: widget.roomId,
      otherProfileId: widget.otherProfileId,
      otherFullName: widget.otherFullName,
      otherAvatarUrl: widget.otherAvatarUrl,
      otherRole: widget.otherRole,
      isPublicRoom: widget.isPublicRoom,
      publicRoomTitle: widget.publicRoomTitle,
      pendingRequestId: widget.pendingRequestId,
      viewerIsReviewer: widget.viewerIsReviewer,
      firstMessageTextOnly: widget.firstMessageTextOnly,
    );
    _notifier.addListener(_onStateChange);
    _notifier.loadMessages();
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChange);
    _notifier.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isPublic = widget.isPublicRoom;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + LynewedSpacing.sm,
        left: LynewedSpacing.md,
        right: LynewedSpacing.md,
        bottom: LynewedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isPublic ? LynewedColors.primary : LynewedColors.background,
        border: isPublic
            ? null
            : const Border(
                bottom: BorderSide(color: LynewedColors.border),
              ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 24,
              color: isPublic
                  ? LynewedColors.textOnPrimary
                  : LynewedColors.primary,
            ),
          ),
          const SizedBox(width: LynewedSpacing.md),

          // Avatar
          _buildHeaderAvatar(isPublic),
          const SizedBox(width: LynewedSpacing.sm),

          // Name and role/status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPublic
                      ? (widget.publicRoomTitle ?? 'Salon public')
                      : (widget.otherFullName ?? 'Conversation'),
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: isPublic
                        ? LynewedColors.textOnPrimary
                        : LynewedColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isPublic
                      ? 'Public'
                      : (widget.otherRole?.name ?? 'Professionnel'),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: isPublic
                        ? LynewedColors.textOnPrimary.withValues(alpha: 0.7)
                        : LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Video call button (private rooms only)
          if (!isPublic) _buildVideoCallButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderAvatar(bool isPublic) {
    final imageUrl = isPublic ? null : widget.otherAvatarUrl;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LynewedColors.surface,
        border: Border.all(
          color: isPublic ? LynewedColors.textOnPrimary : LynewedColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Icon(
                Icons.person,
                size: 20,
                color: LynewedColors.textSecondary,
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.person,
                size: 20,
                color: LynewedColors.textSecondary,
              ),
            )
          : Icon(
              isPublic ? Icons.groups : Icons.person,
              size: 20,
              color: isPublic
                  ? LynewedColors.textOnPrimary
                  : LynewedColors.textSecondary,
            ),
    );
  }

  Widget _buildVideoCallButton() {
    return GestureDetector(
      onTap: _handleVideoCall,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: LynewedColors.surface,
        ),
        child: const Icon(
          Icons.videocam,
          size: 22,
          color: LynewedColors.primary,
        ),
      ),
    );
  }

  Future<void> _handleVideoCall() async {
    // TODO: Implement video call using existing Agora actions
    // This preserves the Agora functionality from FlutterFlow
    // Steps:
    // 1. Check camera/microphone permissions
    // 2. Create video session via startVideoSessionAction
    // 3. Get Agora token via getAgoraTokenAction
    // 4. Navigate to VideoCallPage
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appel vidéo - Intégration Agora à préserver'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBody() {
    final state = _notifier.state;

    if (state is ChatRoomInitial || state is ChatRoomLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      );
    }

    if (state is ChatRoomError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(LynewedSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: LynewedColors.error,
              ),
              const SizedBox(height: LynewedSpacing.md),
              const Text(
                'Erreur de chargement',
                style: LynewedTextStyles.titleMedium,
              ),
              const SizedBox(height: LynewedSpacing.sm),
              Text(
                state.message,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LynewedSpacing.lg),
              ElevatedButton(
                onPressed: () => _notifier.loadMessages(),
                style: LynewedComponentStyles.primaryButton(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ChatRoomLoaded) {
      return Column(
        children: [
          // Contact request banner (if pending and viewer is reviewer)
          if (state.isPendingRequest && state.viewerIsReviewer)
            _buildContactRequestBanner(state),

          // Messages list
          Expanded(
            child: MessageList(
              state: state,
              currentUserId: _currentUserId,
              otherProfileName: widget.otherFullName,
              otherProfileAvatarUrl: widget.otherAvatarUrl,
              onLoadMore: () => _notifier.loadMoreMessages(),
              onMessageLongPress: _handleMessageLongPress,
              onImageTap: _handleImageTap,
              getSignedUrl: (path) => _notifier.getSignedUrl(path),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContactRequestBanner(ChatRoomLoaded state) {
    return Container(
      padding: const EdgeInsets.all(LynewedSpacing.md),
      decoration: const BoxDecoration(
        color: LynewedColors.surface,
        border: Border(
          bottom: BorderSide(color: LynewedColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demande de contact',
            style: LynewedTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: LynewedSpacing.sm),
          Text(
            'Ce professionnel souhaite vous contacter. Acceptez pour démarrer la conversation.',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: LynewedSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleDeclineRequest,
                  style: LynewedComponentStyles.secondaryButton(),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: LynewedSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleAcceptRequest,
                  style: LynewedComponentStyles.primaryButton(),
                  child: const Text('Accepter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAcceptRequest() async {
    final roomId = await _notifier.acceptContactRequest();
    if (roomId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande acceptée'),
          backgroundColor: LynewedColors.success,
        ),
      );
    }
  }

  Future<void> _handleDeclineRequest() async {
    final success = await _notifier.declineContactRequest();
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleMessageLongPress(ChatMessage message) {
    final isOwnMessage = message.profileId == _currentUserId;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => MessageActionsSheet(
        message: message,
        isOwnMessage: isOwnMessage,
        onDelete: isOwnMessage
            ? () async {
                Navigator.pop(sheetContext);
                await _notifier.deleteMessage(message.id);
              }
            : null,
        onReport: !isOwnMessage
            ? (reason, details) async {
                Navigator.pop(sheetContext);
                await _notifier.reportMessage(
                  messageId: message.id,
                  reason: reason,
                  details: details,
                );
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Message signalé'),
                    backgroundColor: LynewedColors.success,
                  ),
                );
              }
            : null,
        onBlock: !isOwnMessage
            ? () async {
                Navigator.pop(sheetContext);
                // Block will be handled in Phase 5
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Blocage - Phase 5'),
                  ),
                );
              }
            : null,
      ),
    );
  }

  void _handleImageTap(ChatMessage message) {
    // TODO: Implement fullscreen image viewer
    debugPrint('Image tapped: ${message.attachmentUrl}');
  }

  Widget _buildComposer() {
    final state = _notifier.state;
    final isLoaded = state is ChatRoomLoaded;

    // Disable composer for public rooms if user is not a bride
    // This logic would need to check user role
    final isEnabled = isLoaded && !widget.isPublicRoom;

    // Check if pending request and viewer is not reviewer (Pro waiting for response)
    final loadedState = isLoaded ? state : null;
    final isPendingWait = loadedState != null &&
        loadedState.isPendingRequest &&
        !loadedState.viewerIsReviewer;

    if (isPendingWait) {
      return Container(
        padding: const EdgeInsets.all(LynewedSpacing.md),
        decoration: const BoxDecoration(
          color: LynewedColors.surface,
          border: Border(
            top: BorderSide(color: LynewedColors.border),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Text(
            'En attente de réponse...',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return MessageComposer(
      isEnabled: isEnabled,
      isSending: loadedState?.isSending ?? false,
      firstMessageTextOnly: widget.firstMessageTextOnly,
      onSendText: (content) => _notifier.sendTextMessage(content),
      onSendImage: ({required filePath, required fileName}) =>
          _notifier.sendImageMessage(filePath: filePath, fileName: fileName),
      onSendAudio: ({required filePath, required fileName}) =>
          _notifier.sendAudioMessage(filePath: filePath, fileName: fileName),
    );
  }
}
