/// Dialog for sending bulk invitations to all pending guests.
///
/// Shows count of invitations to send and handles the bulk send operation.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/wedding_guest.dart';

/// Dialog for bulk invitation sending.
///
/// Shows preview of how many invitations will be sent,
/// handles the operation, and shows results.
class BulkInviteDialog extends StatefulWidget {
  const BulkInviteDialog({
    super.key,
    required this.weddingId,
    required this.pendingGuests,
    required this.onInvitationsSent,
  });

  /// The wedding ID.
  final String weddingId;

  /// List of pending guests with email addresses.
  final List<WeddingGuest> pendingGuests;

  /// Callback when invitations are sent.
  final VoidCallback onInvitationsSent;

  @override
  State<BulkInviteDialog> createState() => _BulkInviteDialogState();
}

class _BulkInviteDialogState extends State<BulkInviteDialog> {
  final _repository = MyWeddingRepositoryImpl();
  bool _isSending = false;
  int? _sentCount;
  String? _error;

  /// Guests with valid email addresses.
  List<WeddingGuest> get _guestsWithEmail =>
      widget.pendingGuests.where((g) => g.email != null && g.email!.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    // Show result if operation is complete
    if (_sentCount != null) {
      return _buildResultDialog();
    }

    if (_error != null) {
      return _buildErrorDialog();
    }

    return _buildConfirmationDialog();
  }

  Widget _buildConfirmationDialog() {
    final count = _guestsWithEmail.length;

    return AlertDialog(
      title: const Text('Invite All Guests'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count == 1
                ? '1 invitation will be sent'
                : '$count invitations will be sent',
            style: LynewedTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Preview list
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: _guestsWithEmail.length.clamp(0, 5),
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final guest = _guestsWithEmail[index];
                return Row(
                  children: [
                    const Icon(Icons.person_outline, size: 20, color: LynewedColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guest.name ?? 'Guest',
                            style: LynewedTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            guest.email!,
                            style: LynewedTextStyles.labelSmall.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_guestsWithEmail.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${_guestsWithEmail.length - 5} more',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendInvitations,
          style: ElevatedButton.styleFrom(
            backgroundColor: LynewedColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Send'),
        ),
      ],
    );
  }

  Widget _buildResultDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: LynewedColors.success),
          const SizedBox(width: 8),
          const Text('Invitations Sent'),
        ],
      ),
      content: Text(
        _sentCount == 1
            ? '1 invitation was sent successfully.'
            : '$_sentCount invitations were sent successfully.',
        style: LynewedTextStyles.bodyMedium,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onInvitationsSent();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: LynewedColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildErrorDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: LynewedColors.error),
          const SizedBox(width: 8),
          const Text('Error'),
        ],
      ),
      content: Text(
        _error ?? 'An error occurred while sending invitations.',
        style: LynewedTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() => _error = null);
            _sendInvitations();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: LynewedColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Future<void> _sendInvitations() async {
    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final result = await _repository.sendBulkInvitations(
        weddingId: widget.weddingId,
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _isSending = false;
            _sentCount = result.data ?? 0;
          });
        } else {
          setState(() {
            _isSending = false;
            _error = result.error;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _error = e.toString();
        });
      }
    }
  }
}

/// Shows the bulk invite dialog.
///
/// Returns true if invitations were sent, false otherwise.
Future<bool> showBulkInviteDialog({
  required BuildContext context,
  required String weddingId,
  required List<WeddingGuest> pendingGuests,
}) async {
  bool invitationsSent = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BulkInviteDialog(
      weddingId: weddingId,
      pendingGuests: pendingGuests,
      onInvitationsSent: () => invitationsSent = true,
    ),
  );

  return invitationsSent;
}
