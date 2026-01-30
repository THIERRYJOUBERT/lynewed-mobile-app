/// Button widget for sending wedding invitations to guests.
///
/// Shows different states based on guest email and status:
/// - No email: hint text to add email
/// - Has email, pending: "Envoyer l'invitation" button
/// - Has email, invited: "Renvoyer l'invitation" button
/// - Loading: spinner with disabled button
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_guest.dart';
import '../../domain/usecases/send_guest_invitation.dart';

/// Button for sending wedding invitations.
///
/// Handles the invitation sending flow with loading state and feedback.
class SendInvitationButton extends StatefulWidget {
  const SendInvitationButton({
    super.key,
    required this.guestId,
    required this.weddingId,
    required this.guestEmail,
    required this.guestStatus,
    this.onSuccess,
    this.sendGuestInvitation,
  });

  final String guestId;
  final String weddingId;
  final String? guestEmail;
  final GuestStatus guestStatus;
  final VoidCallback? onSuccess;

  /// Injectable use case for testing.
  final SendGuestInvitation? sendGuestInvitation;

  @override
  State<SendInvitationButton> createState() => _SendInvitationButtonState();
}

class _SendInvitationButtonState extends State<SendInvitationButton> {
  bool _isLoading = false;
  late final SendGuestInvitation _sendInvitation;

  @override
  void initState() {
    super.initState();
    _sendInvitation = widget.sendGuestInvitation ?? SendGuestInvitation();
  }

  Future<void> _handleSend() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final result = await _sendInvitation(SendInvitationParams(
      guestId: widget.guestId,
      weddingId: widget.weddingId,
    ));

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: LynewedColors.error,
          ),
        );
      },
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invitation envoyée !',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // No email - show hint
    if (widget.guestEmail == null || widget.guestEmail!.isEmpty) {
      return Text(
        'Ajoutez un email pour envoyer une invitation',
        style: LynewedTextStyles.labelSmall.copyWith(
          color: LynewedColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final buttonText = widget.guestStatus == GuestStatus.invited
        ? "Renvoyer l'invitation"
        : "Envoyer l'invitation";

    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleSend,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send, size: 16),
        label: Text(
          buttonText,
          style: LynewedTextStyles.labelSmall.copyWith(
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: LynewedColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
