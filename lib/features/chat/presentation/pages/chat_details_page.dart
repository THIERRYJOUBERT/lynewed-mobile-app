/// Chat details page - Clean Architecture
/// 
/// Main page for viewing and sending messages in a chat room.
/// Supports private rooms, public rooms, and contact request review mode.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '/core/services/unread_counter_service.dart';
import '/backend/schema/enums/enums.dart' show PermissionType;
import '/backend/schema/enums/enums.dart' as app_enums show UserRole;
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart' show VideoCallPageWidget;
import '../../domain/entities/entities.dart';
import '../bloc/chat_room_notifier.dart';
import '../bloc/chat_room_state.dart';
import '../widgets/message_list.dart';
import '../widgets/message_composer.dart';
import '../widgets/fullscreen_image_viewer.dart';
import '../sheets/message_actions_sheet.dart';

/// Chat details page widget
class ChatDetailsPage extends StatefulWidget {
  const ChatDetailsPage({
    super.key,
    required this.roomId,
    this.isPublicRoom = false,
    this.pendingRequestId,
    this.initialMessage,
    this.otherProfileId,
    this.otherFullName,
    this.otherAvatarUrl,
    this.otherRole,
    this.publicRoomTitle,
    this.publicRoomCoverUrl,
    this.viewerIsReviewer = false,
    this.conversationStatus,
    this.onUnblock,
    this.onRequestAccepted,
    this.onRequestDeclined,
  });

  /// Room ID
  final String roomId;

  /// Whether this is a public room
  final bool isPublicRoom;

  /// Pending contact request ID (for Pro→Bride flow)
  final String? pendingRequestId;

  /// Initial message from the contact request (displayed as first message)
  final String? initialMessage;

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

  /// Public room cover image URL (if public)
  final String? publicRoomCoverUrl;

  /// Whether current user is the reviewer (Bride reviewing Pro request)
  final bool viewerIsReviewer;

  /// Conversation status (blocked, reported, etc.)
  final ConversationStatus? conversationStatus;

  /// Callback when user unblocks the conversation
  final Future<bool> Function()? onUnblock;

  /// Callback when contact request is accepted (to refresh parent)
  final VoidCallback? onRequestAccepted;

  /// Callback when contact request is declined (to refresh parent)
  final VoidCallback? onRequestDeclined;

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
    );
    _notifier.addListener(_onStateChange);
    _notifier.loadMessages();
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChange);
    _notifier.dispose();
    // Refresh global unread counter when leaving chat (messages were read)
    UnreadCounterService.instance.forceRefresh();
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
    final state = _notifier.state;
    
    // Get display name from state if available, fallback to widget params
    String displayName;
    String? displayAvatarUrl;
    String displayRole;
    
    if (state is ChatRoomLoaded) {
      displayName = state.otherFullName ?? widget.otherFullName ?? 'Conversation';
      displayAvatarUrl = state.otherAvatarUrl ?? widget.otherAvatarUrl;
      displayRole = state.otherRole?.name ?? widget.otherRole?.name ?? 'Professional';
    } else {
      displayName = widget.otherFullName ?? 'Conversation';
      displayAvatarUrl = widget.otherAvatarUrl;
      displayRole = widget.otherRole?.name ?? 'Professional';
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + LynewedSpacing.sm,
        left: 8,
        right: LynewedSpacing.md,
        bottom: LynewedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isPublic ? LynewedColors.primary : LynewedColors.background,
        border: isPublic
            ? null
            : const Border(
                bottom: BorderSide(color: LynewedColors.gray200),
              ),
      ),
      child: Row(
        children: [
          // Back button - Standard 24x24 icon with 44px tap target
          LynewedComponentStyles.backButton(
            context,
            iconColor: isPublic
                ? LynewedColors.textOnPrimary
                : LynewedColors.textPrimary,
          ),
          const SizedBox(width: 4),

          // Avatar - use cover image for public rooms
          _buildHeaderAvatar(isPublic, isPublic ? widget.publicRoomCoverUrl : displayAvatarUrl),
          const SizedBox(width: LynewedSpacing.sm),

          // Name and role/status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPublic
                      ? (widget.publicRoomTitle ?? 'Public room')
                      : displayName,
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
                  isPublic ? 'Public' : displayRole,
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

  Widget _buildHeaderAvatar(bool isPublic, String? avatarUrl) {
    // Use the avatarUrl directly (can be cover image for public rooms)
    final imageUrl = avatarUrl;
    const double avatarSize = 44.0;
    const double imageSize = 40.0; // Slightly smaller to prevent crop

    // Fallback icon based on room type
    final fallbackIcon = Icon(
      isPublic ? Icons.groups : Icons.person,
      size: 20,
      color: isPublic ? LynewedColors.textOnPrimary : LynewedColors.textSecondary,
    );

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPublic ? LynewedColors.surface.withValues(alpha: 0.2) : LynewedColors.surface,
        border: Border.all(
          color: isPublic ? LynewedColors.textOnPrimary : LynewedColors.border,
          width: 1,
        ),
      ),
      child: Center(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? ClipOval(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => fallbackIcon,
                    errorWidget: (_, __, ___) => fallbackIcon,
                  ),
                ),
              )
            : fallbackIcon,
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
    final state = _notifier.state;
    if (state is! ChatRoomLoaded) return;
    
    final otherProfileId = state.otherProfileId ?? widget.otherProfileId;
    if (otherProfileId == null || otherProfileId.isEmpty) {
      _showSnackBar('Unable to start video call', isError: true);
      return;
    }

    // Step 1: Check camera permission
    final cameraPermission = await actions.checkAndRequestPermission(
      PermissionType.CAMERA,
    );
    if (cameraPermission != 'granted') {
      if (!mounted) return;
      _showSnackBar(
        'Camera permission is required for video calls',
        isError: true,
      );
      return;
    }

    // Step 2: Check microphone permission
    final micPermission = await actions.checkAndRequestPermission(
      PermissionType.MICROPHONE,
    );
    if (micPermission != 'granted') {
      if (!mounted) return;
      _showSnackBar(
        'Microphone permission is required for video calls',
        isError: true,
      );
      return;
    }

    // Step 3: Create video session
    final videoSession = await actions.startVideoSessionAction(otherProfileId);
    if (videoSession == null) {
      if (!mounted) return;
      _showSnackBar(
        'Unable to create video session. Please try again.',
        isError: true,
      );
      return;
    }

    // Step 4: Validate session data
    if (videoSession.id.isEmpty || videoSession.agoraChannelName.isEmpty) {
      if (!mounted) return;
      _showSnackBar(
        'Invalid video session. Please try again.',
        isError: true,
      );
      return;
    }

    // Step 5: Get Agora token
    final agoraToken = await actions.getAgoraTokenAction(
      videoSession.agoraChannelName,
      _currentUserId,
    );
    if (agoraToken == null || agoraToken.isEmpty) {
      if (!mounted) return;
      _showSnackBar(
        'Unable to get video token. Please try again.',
        isError: true,
      );
      return;
    }

    // Step 6: Navigate to video call page
    if (!mounted) return;
    context.goNamed(
      VideoCallPageWidget.routeName,
      queryParameters: {
        'videoSessionId': serializeParam(videoSession.id, ParamType.String),
        'channelName': serializeParam(videoSession.agoraChannelName, ParamType.String),
        'agoraToken': serializeParam(agoraToken, ParamType.String),
        'isInitiator': serializeParam(true, ParamType.bool),
      }.withoutNulls,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LynewedColors.error : LynewedColors.primary,
        duration: const Duration(seconds: 3),
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
                'Loading Error',
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ChatRoomLoaded) {
      return MessageList(
        state: state,
        currentUserId: _currentUserId,
        otherProfileName: widget.otherFullName,
        otherProfileAvatarUrl: widget.otherAvatarUrl,
        initialMessage: widget.initialMessage,
        showInitialMessage: state.isPendingRequest && state.viewerIsReviewer,
        onLoadMore: () => _notifier.loadMoreMessages(),
        onMessageLongPress: _handleMessageLongPress,
        onImageTap: _handleImageTap,
        getSignedUrl: (path) => _notifier.getSignedUrl(path),
      );
    }

    return const SizedBox.shrink();
  }

  bool _isAccepting = false;
  bool _isDeclining = false;

  Future<void> _handleAcceptRequest() async {
    if (_isAccepting) return;
    
    setState(() => _isAccepting = true);
    
    final roomId = await _notifier.acceptContactRequest();
    
    if (!mounted) return;
    
    setState(() => _isAccepting = false);
    
    if (roomId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted - You can now chat!'),
          backgroundColor: LynewedColors.success,
        ),
      );
      // Notify parent to refresh
      widget.onRequestAccepted?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accepting request'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  Future<void> _handleDeclineRequest() async {
    if (_isDeclining) return;
    
    setState(() => _isDeclining = true);
    
    final success = await _notifier.declineContactRequest();
    
    if (!mounted) return;
    
    if (success) {
      // Notify parent to refresh before popping
      widget.onRequestDeclined?.call();
      Navigator.of(context).pop();
    } else {
      setState(() => _isDeclining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error declining request'),
          backgroundColor: LynewedColors.error,
        ),
      );
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
                // Note: MessageActionsSheet already pops itself before opening ReportMessageSheet
                // ReportMessageSheet pops itself after successful submission
                // So we don't need to pop here - just handle the report
                await _notifier.reportMessage(
                  messageId: message.id,
                  reason: reason,
                  details: details,
                );
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Message reported'),
                    backgroundColor: LynewedColors.success,
                  ),
                );
              }
            : null,
        // NOTE: Block User moved to ConversationActionsSheet (long press on conversation in MessagesPage)
      ),
    );
  }

  void _handleImageTap(ChatMessage message) async {
    if (message.attachmentUrl == null) return;

    // Get signed URL for the image
    final signedUrl = await _notifier.getSignedUrl(message.attachmentUrl!);
    if (signedUrl == null || !mounted) return;

    FullscreenImageViewer.show(
      context,
      imageUrl: signedUrl,
      heroTag: 'image_${message.id}',
    );
  }

  Widget _buildComposer() {
    final state = _notifier.state;
    final isLoaded = state is ChatRoomLoaded;

    // For public rooms, only brides can write
    // For private rooms, always enabled when loaded
    bool isEnabled;
    if (widget.isPublicRoom) {
      // Public rooms: enabled only for brides
      final currentUserRole = FFAppState().currentUserRole;
      isEnabled = isLoaded && currentUserRole == app_enums.UserRole.bride;
    } else {
      // Private rooms: always enabled when loaded
      isEnabled = isLoaded;
    }

    // Check if pending request and viewer is not reviewer (Pro waiting for response)
    final loadedState = isLoaded ? state : null;
    final isPendingWait = loadedState != null &&
        loadedState.isPendingRequest &&
        !loadedState.viewerIsReviewer;

    // Check if pending request and viewer IS the reviewer (Bride reviewing Pro request)
    final isPendingReview = loadedState != null &&
        loadedState.isPendingRequest &&
        loadedState.viewerIsReviewer;

    // Check if conversation is blocked
    final isBlocked = widget.conversationStatus == ConversationStatus.blocked;

    if (isBlocked) {
      return _buildUnblockBar();
    }

    // Bride reviewing a contact request - show Accept/Decline buttons
    if (isPendingReview) {
      return _buildContactRequestBar();
    }

    // Pro waiting for Bride response
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
            'Waiting for response...',
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
      onSendText: (content) => _notifier.sendTextMessage(content),
      onSendImage: ({required filePath, required fileName}) =>
          _notifier.sendImageMessage(filePath: filePath, fileName: fileName),
      onSendAudio: ({required filePath, required fileName}) =>
          _notifier.sendAudioMessage(filePath: filePath, fileName: fileName),
      onSendingComplete: () => _notifier.markSendingComplete(),
    );
  }

  /// Build the Accept/Decline bar for Bride reviewing a contact request
  Widget _buildContactRequestBar() {
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
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _isDeclining ? null : _handleDeclineRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LynewedColors.textPrimary,
                    side: const BorderSide(color: LynewedColors.border),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: _isDeclining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LynewedColors.textSecondary,
                          ),
                        )
                      : const Text('Decline'),
                ),
              ),
            ),
            const SizedBox(width: LynewedSpacing.md),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isAccepting ? null : _handleAcceptRequest,
                  style: LynewedComponentStyles.primaryButton(),
                  child: _isAccepting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LynewedColors.textOnPrimary,
                          ),
                        )
                      : const Text('Accept'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnblockBar() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have blocked this user',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LynewedSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleUnblock,
                style: LynewedComponentStyles.secondaryButton(),
                child: const Text('Unblock'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUnblock() async {
    if (widget.onUnblock == null) return;

    final success = await widget.onUnblock!();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User unblocked'),
          backgroundColor: LynewedColors.success,
        ),
      );
      // Pop back to messages list to refresh
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error unblocking user'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }
}
