/// Marketplace Chat Page - Conversation between buyer and seller.
///
/// Full-featured chat page inspired by ChatDetailsPage with:
/// - Listing card at top showing product context
/// - Reverse message list with pointed bubble corners and avatars
/// - Full MessageComposer (text, image, audio, document)
/// - Real-time message delivery via Supabase Realtime
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '/features/chat/presentation/widgets/fullscreen_image_viewer.dart';
import '/features/chat/presentation/widgets/message_composer.dart';
import '../../domain/entities/marketplace_message.dart';
import '../../domain/repositories/marketplace_chat_repository.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/offer_bubble_widget.dart';
import '../widgets/system_message_widget.dart';
import 'checkout_page.dart';

/// Chat page for marketplace conversations.
///
/// Shows messages between the current user and another user about a listing.
/// Features:
/// - Listing card with product info at the top
/// - Reverse message list with smart spacing and avatars
/// - Full composer with text, image, audio, and document support
/// - Real-time message updates via Supabase Realtime
/// - Mark as read on open
class MarketplaceChatPage extends StatefulWidget {
  /// Creates a marketplace chat page.
  const MarketplaceChatPage({
    required this.listingId,
    required this.otherUserId,
    this.currentUserId,
    this.listingTitle,
    this.listingPriceCents,
    this.listingCoverUrl,
    this.otherUserName,
    this.otherUserAvatarUrl,
    this.repository,
    this.offerRepository,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'MarketplaceChat';

  /// The listing this conversation is about.
  final String listingId;

  /// The other user in this conversation.
  final String otherUserId;

  /// Optional listing title for the listing card.
  final String? listingTitle;

  /// Optional listing price in cents for the listing card.
  final int? listingPriceCents;

  /// Optional listing cover photo URL for the listing card.
  final String? listingCoverUrl;

  /// Optional other user display name.
  final String? otherUserName;

  /// Optional other user avatar URL.
  final String? otherUserAvatarUrl;

  /// Optional chat repository override for testing.
  final MarketplaceChatRepository? repository;

  /// Optional offer repository override for testing.
  final MarketplaceOfferRepository? offerRepository;

  /// The current authenticated user's ID. Falls back to [currentUserUid].
  final String? currentUserId;

  @override
  State<MarketplaceChatPage> createState() => _MarketplaceChatPageState();
}

class _MarketplaceChatPageState extends State<MarketplaceChatPage> {
  late final MarketplaceChatRepository _repository;
  late final MarketplaceOfferRepository _offerRepository;

  List<MarketplaceMessage> _messages = [];
  StreamSubscription<MarketplaceMessage>? _realtimeSubscription;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  /// Cached offer statuses keyed by offer ID.
  final Map<String, String> _offerStatuses = {};

  /// Cache of signed URLs for media attachments keyed by storage path.
  final Map<String, String> _signedUrlCache = {};

  String get _currentUserId => widget.currentUserId ?? currentUserUid;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceChatRepository>();
    _offerRepository =
        widget.offerRepository ?? sl<MarketplaceOfferRepository>();
    _loadMessages();
    _subscribeToNewMessages();
    _markAsRead();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _repository.getMessages(
        listingId: widget.listingId,
        otherUserId: widget.otherUserId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        // Pre-sign URLs for media messages and load offer statuses.
        _preSignMediaUrls(messages);
        _loadOfferStatuses(messages);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Pre-sign URLs for messages with attachments.
  Future<void> _preSignMediaUrls(List<MarketplaceMessage> messages) async {
    for (final msg in messages) {
      if (msg.hasAttachment && !_signedUrlCache.containsKey(msg.attachmentUrl)) {
        final url = await _repository.getSignedUrl(msg.attachmentUrl!);
        if (url != null && mounted) {
          setState(() => _signedUrlCache[msg.attachmentUrl!] = url);
        }
      }
    }
  }

  void _subscribeToNewMessages() {
    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;

    _realtimeSubscription = _repository
        .subscribeToMessages(
          listingId: widget.listingId,
          currentUserId: currentUserId,
        )
        .listen((newMessage) {
      if (mounted) {
        // Avoid duplicate messages (sent by self).
        final isDuplicate = _messages.any((m) => m.id == newMessage.id);
        if (!isDuplicate) {
          setState(() => _messages.add(newMessage));
          // Sign URL if it has an attachment.
          if (newMessage.hasAttachment) {
            _preSignMediaUrls([newMessage]);
          }
        }
        _markAsRead();
      }
    });
  }

  Future<void> _markAsRead() async {
    try {
      await _repository.markConversationAsRead(
        listingId: widget.listingId,
        otherUserId: widget.otherUserId,
      );
    } catch (_) {
      // Silently ignore mark-as-read failures (non-critical UX operation).
    }
  }

  // ─── Send callbacks for MessageComposer ───

  Future<bool> _sendTextMessage(String content) async {
    try {
      final sent = await _repository.sendMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: content,
      );
      if (mounted) {
        setState(() => _messages.add(sent));
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to send message');
      }
      return false;
    }
  }

  Future<bool> _sendImageMessage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      setState(() => _isSending = true);
      final storagePath = await _repository.uploadAttachment(
        filePath: filePath,
        fileName: fileName,
        listingId: widget.listingId,
      );
      final fileSize = File(filePath).lengthSync();
      final sent = await _repository.sendMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: '',
        messageType: 'image',
        attachmentUrl: storagePath,
        attachmentName: fileName,
        attachmentSize: fileSize,
        attachmentMimeType: _guessMimeType(fileName),
      );
      if (mounted) {
        setState(() {
          _messages.add(sent);
          _isSending = false;
        });
        _preSignMediaUrls([sent]);
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showErrorSnackBar('Failed to send image');
      }
      return false;
    }
  }

  Future<bool> _sendAudioMessage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      setState(() => _isSending = true);
      final storagePath = await _repository.uploadAttachment(
        filePath: filePath,
        fileName: fileName,
        listingId: widget.listingId,
      );
      final fileSize = File(filePath).lengthSync();
      final sent = await _repository.sendMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: '',
        messageType: 'audio',
        attachmentUrl: storagePath,
        attachmentName: fileName,
        attachmentSize: fileSize,
        attachmentMimeType: 'audio/m4a',
      );
      if (mounted) {
        setState(() {
          _messages.add(sent);
          _isSending = false;
        });
        _preSignMediaUrls([sent]);
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showErrorSnackBar('Failed to send audio');
      }
      return false;
    }
  }

  Future<bool> _sendDocumentMessage({
    required String filePath,
    required String fileName,
    required int fileSize,
  }) async {
    try {
      setState(() => _isSending = true);
      final storagePath = await _repository.uploadAttachment(
        filePath: filePath,
        fileName: fileName,
        listingId: widget.listingId,
      );
      final sent = await _repository.sendMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: '',
        messageType: 'document',
        attachmentUrl: storagePath,
        attachmentName: fileName,
        attachmentSize: fileSize,
        attachmentMimeType: 'application/pdf',
      );
      if (mounted) {
        setState(() {
          _messages.add(sent);
          _isSending = false;
        });
        _preSignMediaUrls([sent]);
      }
      return true;
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showErrorSnackBar('Failed to send document');
      }
      return false;
    }
  }

  String _guessMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textOnDark,
          ),
        ),
        backgroundColor: LynewedColors.error,
      ),
    );
  }

  // ─── Offer actions ───

  /// Fetch offer statuses for all offer-type messages.
  Future<void> _loadOfferStatuses(List<MarketplaceMessage> messages) async {
    for (final msg in messages) {
      if (msg.isOffer && msg.offerId != null && !_offerStatuses.containsKey(msg.offerId)) {
        try {
          final offer = await _offerRepository.getOfferById(msg.offerId!);
          if (mounted) {
            setState(() => _offerStatuses[msg.offerId!] = offer.status);
          }
        } catch (_) {
          // If offer not found, default to expired.
          if (mounted) {
            setState(() => _offerStatuses[msg.offerId!] = 'expired');
          }
        }
      }
    }
  }

  Future<void> _handleAcceptOffer(String offerId) async {
    try {
      await _offerRepository.acceptOffer(offerId);
      // Send system message.
      await _repository.sendSystemMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: 'Offer accepted! Buyer can now proceed to checkout.',
      );
      if (mounted) {
        setState(() => _offerStatuses[offerId] = 'accepted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offer accepted!',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textOnDark,
              ),
            ),
          ),
        );
      }
      // Reload messages to show the system message.
      await _loadMessages();
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to accept offer');
    }
  }

  Future<void> _handleRejectOffer(String offerId) async {
    try {
      await _offerRepository.rejectOffer(offerId);
      // Send system message.
      await _repository.sendSystemMessage(
        listingId: widget.listingId,
        receiverId: widget.otherUserId,
        content: 'Offer declined.',
      );
      if (mounted) {
        setState(() => _offerStatuses[offerId] = 'rejected');
      }
      await _loadMessages();
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to decline offer');
    }
  }

  Future<void> _handleProceedToCheckout(String offerId, int amountCents) async {
    try {
      // Fetch the listing to pass to CheckoutPage.
      final marketplaceRepo = sl<MarketplaceRepository>();
      final listing = await marketplaceRepo.getListingById(widget.listingId);
      if (listing == null || !mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CheckoutPage(
            listing: listing,
            offerId: offerId,
            agreedPriceCents: amountCents,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _showErrorSnackBar('Failed to load listing for checkout');
    }
  }

  // ─── Message actions ───

  void _handleImageTap(MarketplaceMessage message) async {
    if (message.attachmentUrl == null) return;

    final signedUrl = _signedUrlCache[message.attachmentUrl] ??
        await _repository.getSignedUrl(message.attachmentUrl!);

    if (signedUrl == null || !mounted) return;

    // Handle document tap - open externally.
    if (message.isDocument) {
      final uri = Uri.parse(signedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Handle image tap - show fullscreen.
    if (!mounted) return;
    FullscreenImageViewer.show(
      context,
      imageUrl: signedUrl,
      heroTag: 'marketplace_image_${message.id}',
    );
  }

  // ─── Build methods ───

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: Column(
          children: [
            _buildHeader(),
            _buildListingCard(),
            Expanded(child: _buildMessageList()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + LynewedSpacing.sm,
        left: 8,
        right: LynewedSpacing.md,
        bottom: LynewedSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200),
        ),
      ),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Conversation',
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard() {
    final hasInfo = widget.listingTitle != null ||
        widget.listingCoverUrl != null;
    if (!hasInfo) return const SizedBox.shrink();

    final priceText = widget.listingPriceCents != null
        ? '\$${(widget.listingPriceCents! / 100).toStringAsFixed(2)}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: LynewedColors.surface,
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200),
        ),
      ),
      child: Row(
        children: [
          // Listing cover photo
          _buildListingCover(),
          const SizedBox(width: 12),
          // Title + seller name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listingTitle ?? 'Listing',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.otherUserName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.otherUserName!,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Price
          if (priceText != null) ...[
            const SizedBox(width: 8),
            Text(
              priceText,
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListingCover() {
    if (widget.listingCoverUrl != null &&
        widget.listingCoverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: widget.listingCoverUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildCoverPlaceholder(),
          errorWidget: (_, __, ___) => _buildCoverPlaceholder(),
        ),
      );
    }
    return _buildCoverPlaceholder();
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.storefront_outlined,
        color: LynewedColors.gray300,
        size: 24,
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    final currentUserId = _currentUserId;
    // Reverse the messages for the reverse ListView.
    final reversed = _messages.reversed.toList();

    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.only(
        left: 0,
        right: 0,
        top: LynewedSpacing.md,
        bottom: LynewedSpacing.sm,
      ),
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final message = reversed[index];
        final isMe = message.senderId == currentUserId;

        // In reverse list, index 0 is the newest (bottom).
        // The "previous" message visually above is at index+1.
        final previousMessage =
            index < reversed.length - 1 ? reversed[index + 1] : null;
        final sameSenderAsPrevious =
            previousMessage != null &&
            previousMessage.senderId == message.senderId;

        // Show avatar for the bottom-most message in a sender group.
        // In reverse list, check the next visual message (index-1).
        final nextMessage = index > 0 ? reversed[index - 1] : null;
        final sameSenderAsNext =
            nextMessage != null &&
            nextMessage.senderId == message.senderId;
        final showAvatar = !isMe && !sameSenderAsNext;

        // Render offer-type messages with OfferBubbleWidget.
        if (message.isOffer) {
          final offerStatus = _offerStatuses[message.offerId] ?? 'pending';
          // Parse amount from JSON content for checkout navigation.
          int amountCents = 0;
          try {
            final data = _parseOfferContent(message.content);
            amountCents = data['amount_cents'] as int? ?? 0;
          } catch (_) {}

          return OfferBubbleWidget(
            message: message,
            isMe: isMe,
            offerStatus: offerStatus,
            senderName: isMe ? null : widget.otherUserName,
            showAvatar: showAvatar,
            needsLargeSpacing: !sameSenderAsPrevious,
            onAccept: message.offerId != null
                ? () => _handleAcceptOffer(message.offerId!)
                : null,
            onDecline: message.offerId != null
                ? () => _handleRejectOffer(message.offerId!)
                : null,
            onProceedToCheckout: message.offerId != null
                ? () => _handleProceedToCheckout(message.offerId!, amountCents)
                : null,
          );
        }

        // Render system messages.
        if (message.isSystem) {
          return SystemMessageWidget(
            message: message,
            needsLargeSpacing: !sameSenderAsPrevious,
          );
        }

        return ChatBubbleWidget(
          message: message,
          isMe: isMe,
          senderName: widget.otherUserName,
          senderAvatarUrl: widget.otherUserAvatarUrl,
          showAvatar: showAvatar,
          needsLargeSpacing: !sameSenderAsPrevious,
          signedMediaUrl: message.hasAttachment
              ? _signedUrlCache[message.attachmentUrl]
              : null,
          onImageTap:
              message.isImage || message.isDocument
                  ? () => _handleImageTap(message)
                  : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: LynewedColors.gray300,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'No messages yet',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Send a message to start the conversation',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: LynewedColors.error,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'Failed to load messages',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          LynewedButton(
            text: 'Retry',
            type: LynewedButtonType.secondary,
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadMessages();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return MessageComposer(
      isEnabled: !_isLoading && _error == null,
      isSending: _isSending,
      onSendText: _sendTextMessage,
      onSendImage: _sendImageMessage,
      onSendAudio: _sendAudioMessage,
      onSendDocument: _sendDocumentMessage,
      onSendingComplete: () {
        if (mounted) setState(() => _isSending = false);
      },
    );
  }

  Map<String, dynamic> _parseOfferContent(String content) {
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _repository.unsubscribeAll();
    super.dispose();
  }
}
