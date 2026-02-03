/// Magazine Checkout State for MagazineCheckoutCubit.
///
/// Manages the state for magazine checkout including address, pricing,
/// CGVU acceptance, and payment status.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/magazine_format.dart';
import '../../domain/entities/shipping_address.dart';

/// Checkout step enum.
enum CheckoutStep {
  /// Address and order summary step.
  addressEntry,

  /// Processing payment.
  processing,

  /// Payment successful.
  success,

  /// Payment failed.
  failed,
}

/// State for the magazine checkout Cubit.
@immutable
class MagazineCheckoutState {
  /// Creates a magazine checkout state.
  const MagazineCheckoutState({
    required this.weddingId,
    required this.brideUserId,
    required this.format,
    required this.photoCount,
    required this.weddingTitle,
    this.weddingDate,
    this.coverPhotoId,
    this.coverPhotoUrl,
    this.address,
    this.cgvuAccepted = false,
    this.step = CheckoutStep.addressEntry,
    this.checkoutUrl,
    this.checkoutSessionId,
    this.orderId,
    this.errorMessage,
  });

  /// Wedding ID for the order.
  final String weddingId;

  /// Bride user ID for the order.
  final String brideUserId;

  /// Selected magazine format.
  final MagazineFormat format;

  /// Number of photos in the magazine.
  final int photoCount;

  /// Wedding title for the cover.
  final String weddingTitle;

  /// Wedding date (optional).
  final DateTime? weddingDate;

  /// Cover photo ID (optional).
  final String? coverPhotoId;

  /// Cover photo URL for preview (optional).
  final String? coverPhotoUrl;

  /// Shipping address.
  final ShippingAddress? address;

  /// Whether CGVU/Terms are accepted.
  final bool cgvuAccepted;

  /// Current checkout step.
  final CheckoutStep step;

  /// Stripe Checkout URL.
  final String? checkoutUrl;

  /// Stripe Checkout session ID.
  final String? checkoutSessionId;

  /// Order ID after successful payment.
  final String? orderId;

  /// Error message if something went wrong.
  final String? errorMessage;

  /// Returns the magazine price in cents.
  int get magazinePriceCents => format.priceCents;

  /// Returns the shipping cost in cents based on country.
  int get shippingCostCents =>
      ShippingCosts.calculateCents(address?.country ?? 'US');

  /// Returns the total price in cents.
  int get totalCents => magazinePriceCents + shippingCostCents;

  /// Returns the formatted magazine price.
  String get magazinePriceFormatted => format.priceFormatted;

  /// Returns the formatted shipping cost.
  String get shippingCostFormatted => ShippingCosts.format(shippingCostCents);

  /// Returns the formatted total price.
  String get totalFormatted => _formatCents(totalCents);

  /// Returns whether the checkout can proceed.
  bool get canProceed =>
      address != null && address!.isValid && cgvuAccepted && !isProcessing;

  /// Returns whether we're currently processing.
  bool get isProcessing => step == CheckoutStep.processing;

  /// Returns whether payment was successful.
  bool get isSuccess => step == CheckoutStep.success;

  /// Returns whether payment failed.
  bool get isFailed => step == CheckoutStep.failed;

  /// Helper to format cents as dollars.
  String _formatCents(int cents) {
    final dollars = cents ~/ 100;
    final remainder = cents % 100;
    if (remainder == 0) {
      return '\$$dollars.00';
    }
    return '\$$dollars.${remainder.toString().padLeft(2, '0')}';
  }

  /// Creates a copy with updated values.
  MagazineCheckoutState copyWith({
    String? weddingId,
    String? brideUserId,
    MagazineFormat? format,
    int? photoCount,
    String? weddingTitle,
    DateTime? weddingDate,
    bool clearWeddingDate = false,
    String? coverPhotoId,
    bool clearCoverPhotoId = false,
    String? coverPhotoUrl,
    bool clearCoverPhotoUrl = false,
    ShippingAddress? address,
    bool? cgvuAccepted,
    CheckoutStep? step,
    String? checkoutUrl,
    bool clearCheckoutUrl = false,
    String? checkoutSessionId,
    bool clearCheckoutSessionId = false,
    String? orderId,
    bool clearOrderId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MagazineCheckoutState(
      weddingId: weddingId ?? this.weddingId,
      brideUserId: brideUserId ?? this.brideUserId,
      format: format ?? this.format,
      photoCount: photoCount ?? this.photoCount,
      weddingTitle: weddingTitle ?? this.weddingTitle,
      weddingDate:
          clearWeddingDate ? null : (weddingDate ?? this.weddingDate),
      coverPhotoId:
          clearCoverPhotoId ? null : (coverPhotoId ?? this.coverPhotoId),
      coverPhotoUrl:
          clearCoverPhotoUrl ? null : (coverPhotoUrl ?? this.coverPhotoUrl),
      address: address ?? this.address,
      cgvuAccepted: cgvuAccepted ?? this.cgvuAccepted,
      step: step ?? this.step,
      checkoutUrl:
          clearCheckoutUrl ? null : (checkoutUrl ?? this.checkoutUrl),
      checkoutSessionId: clearCheckoutSessionId
          ? null
          : (checkoutSessionId ?? this.checkoutSessionId),
      orderId: clearOrderId ? null : (orderId ?? this.orderId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MagazineCheckoutState &&
        other.weddingId == weddingId &&
        other.brideUserId == brideUserId &&
        other.format == format &&
        other.photoCount == photoCount &&
        other.weddingTitle == weddingTitle &&
        other.weddingDate == weddingDate &&
        other.coverPhotoId == coverPhotoId &&
        other.coverPhotoUrl == coverPhotoUrl &&
        other.address == address &&
        other.cgvuAccepted == cgvuAccepted &&
        other.step == step &&
        other.checkoutUrl == checkoutUrl &&
        other.checkoutSessionId == checkoutSessionId &&
        other.orderId == orderId &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        weddingId,
        brideUserId,
        format,
        photoCount,
        weddingTitle,
        weddingDate,
        coverPhotoId,
        coverPhotoUrl,
        address,
        cgvuAccepted,
        step,
        checkoutUrl,
        checkoutSessionId,
        orderId,
        errorMessage,
      );
}
