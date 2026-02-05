/// Magazine Checkout Cubit for managing checkout state.
///
/// Handles CGVU acceptance and Stripe payment initiation.
/// Shipping address is collected by Stripe Checkout directly.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/magazine_format.dart';
import 'magazine_checkout_state.dart';

/// Cubit for managing magazine checkout state.
class MagazineCheckoutCubit extends Cubit<MagazineCheckoutState> {
  /// Creates a MagazineCheckoutCubit.
  MagazineCheckoutCubit({
    required String weddingId,
    required String brideUserId,
    required MagazineFormat format,
    required int photoCount,
    required String weddingTitle,
    DateTime? weddingDate,
    String? coverPhotoId,
    String? coverPhotoUrl,
    SupabaseClient? supabaseClient,
  })  : _supabase = supabaseClient ?? Supabase.instance.client,
        super(MagazineCheckoutState(
          weddingId: weddingId,
          brideUserId: brideUserId,
          format: format,
          photoCount: photoCount,
          weddingTitle: weddingTitle,
          weddingDate: weddingDate,
          coverPhotoId: coverPhotoId,
          coverPhotoUrl: coverPhotoUrl,
        ));

  final SupabaseClient _supabase;

  /// Toggles CGVU acceptance.
  void toggleCgvuAccepted() {
    emit(state.copyWith(cgvuAccepted: !state.cgvuAccepted, clearError: true));
  }

  /// Sets CGVU acceptance state.
  void setCgvuAccepted(bool accepted) {
    emit(state.copyWith(cgvuAccepted: accepted, clearError: true));
  }

  /// Initiates Stripe Checkout.
  ///
  /// Calls the Edge Function to create a checkout session and opens
  /// the Stripe Checkout URL.
  Future<void> initiateCheckout() async {
    if (!state.canProceed) return;

    emit(state.copyWith(step: CheckoutStep.processing, clearError: true));

    try {
      final response = await _supabase.functions.invoke(
        'create-magazine-checkout',
        body: {
          'wedding_id': state.weddingId,
          'bride_user_id': state.brideUserId,
          'magazine_format': state.format.id,
          'magazine_price_cents': state.magazinePriceCents,
          'photo_count': state.photoCount,
          'magazine_title': state.weddingTitle,
          'magazine_date': state.weddingDate?.toIso8601String(),
          'cover_photo_id': state.coverPhotoId,
          'success_url': 'lynewed://magazine-order-success?session_id={CHECKOUT_SESSION_ID}',
          'cancel_url': 'lynewed://magazine-checkout',
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to create checkout session');
      }

      final data = response.data as Map<String, dynamic>;
      final checkoutUrl = data['checkout_url'] as String?;
      final sessionId = data['session_id'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('No checkout URL returned');
      }

      emit(state.copyWith(
        checkoutUrl: checkoutUrl,
        checkoutSessionId: sessionId,
      ));

      // Open Stripe Checkout in browser
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open checkout URL');
      }

      // Stay in processing state - will be updated when deep link returns
    } catch (e) {
      emit(state.copyWith(
        step: CheckoutStep.failed,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Called when payment succeeds (deep link callback).
  ///
  /// Validates the sessionId matches the one we created to prevent
  /// tampering attacks via crafted deep links.
  void onPaymentSuccess(String sessionId, {String? orderId}) {
    // SECURITY: Validate sessionId matches the one we created
    if (state.checkoutSessionId != null &&
        sessionId != state.checkoutSessionId) {
      emit(state.copyWith(
        step: CheckoutStep.failed,
        errorMessage: 'Session ID mismatch - invalid callback',
      ));
      return;
    }

    emit(state.copyWith(
      step: CheckoutStep.success,
      checkoutSessionId: sessionId,
      orderId: orderId,
      clearError: true,
    ));
  }

  /// Called when payment is cancelled or fails.
  void onPaymentCancelled() {
    emit(state.copyWith(
      step: CheckoutStep.addressEntry,
      clearCheckoutUrl: true,
      clearCheckoutSessionId: true,
      clearError: true,
    ));
  }

  /// Called when payment fails with an error.
  void onPaymentFailed(String error) {
    emit(state.copyWith(
      step: CheckoutStep.failed,
      errorMessage: error,
    ));
  }

  /// Retries the checkout after a failure.
  void retryCheckout() {
    emit(state.copyWith(
      step: CheckoutStep.addressEntry,
      clearError: true,
      clearCheckoutUrl: true,
      clearCheckoutSessionId: true,
    ));
  }
}
