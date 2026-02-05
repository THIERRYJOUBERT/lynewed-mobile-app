/// Make Offer Sheet - Bottom sheet for buyers to submit an offer.
///
/// Displays listing price, amount input, optional message, and expiration notice.
/// Validates input and checks for duplicate pending offers before submitting.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';

/// Bottom sheet for making an offer on a marketplace listing.
///
/// Receives the listing info for display and a repository for persistence.
/// Shows listed price, offer amount input, optional message, and
/// expiration notice. Validates before submitting.
class MakeOfferSheet extends StatefulWidget {
  /// Creates a make offer sheet.
  const MakeOfferSheet({
    required this.listingId,
    required this.listingTitle,
    required this.listingPriceCents,
    this.repository,
    super.key,
  });

  /// The listing this offer is for.
  final String listingId;

  /// Listing title for display.
  final String listingTitle;

  /// Listed price in cents for display.
  final int listingPriceCents;

  /// Optional repository override for testing.
  final MarketplaceOfferRepository? repository;

  @override
  State<MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends State<MakeOfferSheet> {
  late final MarketplaceOfferRepository _repository;
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? sl<MarketplaceOfferRepository>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _formatPrice(int cents) {
    return (cents / 100).toStringAsFixed(2);
  }

  Future<void> _submitOffer() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check for existing pending offer first.
      final existing =
          await _repository.getPendingOfferForListing(widget.listingId);

      if (existing != null) {
        if (!mounted) return;
        _showError('You already have a pending offer on this listing');
        setState(() => _isLoading = false);
        return;
      }

      // Create the offer.
      final amountCents = (amount * 100).round();
      final message = _messageController.text.trim();

      await _repository.createOffer(
        listingId: widget.listingId,
        amountCents: amountCents,
        message: message.isNotEmpty ? message : null,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offer sent successfully!',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textOnDark,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
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

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Make an Offer',
      onClose: () => Navigator.pop(context),
      bottomAction: LynewedButton(
        text: _isLoading ? 'Sending...' : 'Send Offer',
        onPressed: _isLoading ? null : _submitOffer,
        isLoading: _isLoading,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listed price.
          const LynewedSectionTitle('Listed Price'),
          SizedBox(height: LynewedSpacing.labelFieldGap),
          Text(
            '\$${_formatPrice(widget.listingPriceCents)}',
            style: LynewedTextStyles.headlineMedium.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Offer amount input.
          const LynewedSectionTitle('Your Offer (USD)'),
          SizedBox(height: LynewedSpacing.labelFieldGap),
          LynewedTextField(
            controller: _amountController,
            hint: 'Enter amount',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Optional message.
          const LynewedSectionTitle('Message (optional)'),
          SizedBox(height: LynewedSpacing.labelFieldGap),
          LynewedTextField(
            controller: _messageController,
            hint: 'Add a note to the seller...',
            maxLines: 3,
          ),

          SizedBox(height: LynewedSpacing.lg),

          // Expiration notice.
          Text(
            'This offer will expire in 48 hours',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
