/// Contact request review sheet - Clean Architecture
/// 
/// Sheet for Bride to review and accept/decline a contact request.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Result of the review action
enum ContactRequestReviewResult {
  accepted,
  declined,
  cancelled,
}

/// Sheet for reviewing a contact request
class ContactRequestReviewSheet extends StatefulWidget {
  const ContactRequestReviewSheet({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final ContactRequest request;
  final Future<String?> Function() onAccept;
  final Future<bool> Function() onDecline;

  /// Show the sheet and return the result
  static Future<ContactRequestReviewResult?> show({
    required BuildContext context,
    required ContactRequest request,
    required Future<String?> Function() onAccept,
    required Future<bool> Function() onDecline,
  }) {
    return showModalBottomSheet<ContactRequestReviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactRequestReviewSheet(
        request: request,
        onAccept: onAccept,
        onDecline: onDecline,
      ),
    );
  }

  @override
  State<ContactRequestReviewSheet> createState() => _ContactRequestReviewSheetState();
}

class _ContactRequestReviewSheetState extends State<ContactRequestReviewSheet> {
  bool _isLoading = false;
  String? _loadingAction;

  Future<void> _handleAccept() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'accept';
    });

    final roomId = await widget.onAccept();
    
    if (!mounted) return;

    if (roomId != null) {
      Navigator.of(context).pop(ContactRequestReviewResult.accepted);
    } else {
      setState(() {
        _isLoading = false;
        _loadingAction = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error accepting request'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  Future<void> _handleDecline() async {
    setState(() {
      _isLoading = true;
      _loadingAction = 'decline';
    });

    final success = await widget.onDecline();
    
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(ContactRequestReviewResult.declined);
    } else {
      setState(() {
        _isLoading = false;
        _loadingAction = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error declining request'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: LynewedComponentStyles.bottomSheetDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Container(
              padding: LynewedComponentStyles.sheetHeaderPadding,
              decoration: LynewedComponentStyles.sheetHeaderDecoration(),
              child: Row(
                children: [
                  // Avatar
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Request',
                          style: LynewedTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.request.otherFullName ?? 'Professional',
                          style: LynewedTextStyles.bodySmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(ContactRequestReviewResult.cancelled),
                    icon: const Icon(Icons.close),
                    iconSize: 24,
                    color: LynewedColors.textSecondary,
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: LynewedComponentStyles.sheetContentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Source info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LynewedColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getSourceIcon(),
                          size: 18,
                          color: LynewedColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.request.source.displayLabel,
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(widget.request.createdAt),
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message
                  if (widget.request.initialMessage != null && widget.request.initialMessage!.isNotEmpty) ...[
                    Text(
                      'Message',
                      style: LynewedTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: LynewedColors.gray200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.request.initialMessage!,
                        style: LynewedTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Action buttons
                  Row(
                    children: [
                      // Decline button
                      Expanded(
                        child: SizedBox(
                          height: LynewedSpacing.buttonHeight,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleDecline,
                            style: LynewedComponentStyles.secondaryButton(),
                            child: _loadingAction == 'decline'
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: LynewedColors.primary,
                                    ),
                                  )
                                : const Text('Decline'),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Accept button
                      Expanded(
                        child: SizedBox(
                          height: LynewedSpacing.buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAccept,
                            style: LynewedComponentStyles.primaryButton(),
                            child: _loadingAction == 'accept'
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: widget.request.otherAvatarUrl != null && widget.request.otherAvatarUrl!.isNotEmpty
          ? Image.network(
              widget.request.otherAvatarUrl!,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      color: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        color: LynewedColors.gray300,
        size: 24,
      ),
    );
  }

  IconData _getSourceIcon() {
    switch (widget.request.source) {
      case ContactRequestSource.fromWishlist:
        return Icons.favorite_outline;
      case ContactRequestSource.fromWedding:
        return Icons.celebration_outlined;
      case ContactRequestSource.fromAlert:
        return Icons.notifications_outlined;
      case ContactRequestSource.fromProfile:
        return Icons.person_outline;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
