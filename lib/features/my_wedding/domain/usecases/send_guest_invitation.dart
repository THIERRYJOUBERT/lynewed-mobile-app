/// Use case for sending a wedding invitation to a guest.
///
/// Calls the send-wedding-invitation Edge Function to send
/// an email with QR code and deep link to the guest.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/core.dart';

/// Parameters for sending a guest invitation.
class SendInvitationParams {
  const SendInvitationParams({
    required this.guestId,
    required this.weddingId,
  });

  final String guestId;
  final String weddingId;
}

/// Failure type for invitation errors.
class InvitationFailure extends AppFailure {
  const InvitationFailure({
    required String message,
    String? code,
  }) : super(message, code: code);
}

/// Use case for sending wedding invitations to guests.
///
/// Invokes the Edge Function which:
/// - Sends email with QR code and deep link
/// - Updates guest status to 'invited'
class SendGuestInvitation {
  SendGuestInvitation({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Sends an invitation email to the specified guest.
  ///
  /// Returns [Success] if the email was sent successfully,
  /// or [Failure] with an appropriate error message.
  Future<Result<void>> call(SendInvitationParams params) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-wedding-invitation',
        body: {
          'guest_id': params.guestId,
          'wedding_id': params.weddingId,
        },
      );

      if (response.status != 200) {
        final data = response.data as Map<String, dynamic>?;
        final error = data?['error'] as String?;
        return Failure(InvitationFailure(
          message: _mapErrorToMessage(error),
          code: error,
        ));
      }

      return const Success(null);
    } on FunctionException catch (e) {
      return Failure(InvitationFailure(
        message: _mapErrorToMessage(e.reasonPhrase),
        code: e.reasonPhrase,
      ));
    } catch (e) {
      return Failure(InvitationFailure(
        message: 'Failed to send invitation',
      ));
    }
  }

  String _mapErrorToMessage(String? error) {
    switch (error) {
      case 'invalid_email':
        return 'Invalid email address';
      case 'guest_not_found':
        return 'Guest not found';
      case 'rate_limited':
        return 'Too many requests, please try again later';
      case 'email_service_error':
        return 'Email service error';
      case 'unauthorized':
        return 'Unauthorized';
      default:
        return 'Failed to send invitation';
    }
  }
}
