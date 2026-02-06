/// Make Offer Sheet - Bottom sheet for submitting an offer or counter-offer.
///
/// Displays listing price, amount input, optional message, and expiration notice.
/// Validates input and checks for duplicate pending offers before submitting.
/// Works for both buyers (making offers) and sellers (counter-proposals).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_offer.dart';
import '../../domain/repositories/marketplace_chat_repository.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';

/// Bottom sheet for making an offer on a marketplace listing.
///
/// Receives the listing info for display and a repository for persistence.
/// Shows listed price, offer amount input, optional message, and
/// expiration notice. Validates before submitting.
///
/// Supports both buyer offers and seller counter-proposals via [isCounterOffer].
/// When [onOfferSent] is provided, calls the callback instead of showing a
/// snackbar (used when opened from the chat page).
class MakeOfferSheet extends StatefulWidget {
  /// Creates a make offer sheet.
  const MakeOfferSheet({
    required this.listingId,
    required this.listingTitle,
    required this.listingPriceCents,
    required this.receiverId,
    this.isCounterOffer = false,
    this.onOfferSent,
    this.repository,
    this.chatRepository,
    super.key,
  });

  /// The listing this offer is for.
  final String listingId;

  /// Listing title for display.
  final String listingTitle;

  /// Listed price in cents for display.
  final int listingPriceCents;

  /// The user who will receive the offer message.
  final String receiverId;

  /// Whether this is a counter-offer from the seller.
  final bool isCounterOffer;

  /// Called after the offer is successfully created. When provided, the sheet
  /// pops without showing a snackbar (the caller handles feedback).
  final void Function(MarketplaceOffer offer)? onOfferSent;

  /// Optional repository override for testing.
  final MarketplaceOfferRepository? repository;

  /// Optional chat repository override for testing.
  final MarketplaceChatRepository? chatRepository;

  @override
  State<MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends State<MakeOfferSheet> {
  late final MarketplaceOfferRepository _repository;
  late final MarketplaceChatRepository _chatRepository;
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ?? sl<MarketplaceOfferRepository>();
    _chatRepository =
        widget.chatRepository ?? sl<MarketplaceChatRepository>();
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
    final amountText = _amountController.text.trim().replaceAll(',', '.');
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

      final offer = await _repository.createOffer(
        listingId: widget.listingId,
        amountCents: amountCents,
        message: message.isNotEmpty ? message : null,
      );

      // Send offer message in the chat conversation.
      try {
        await _chatRepository.sendOfferMessage(
          listingId: widget.listingId,
          receiverId: widget.receiverId,
          offerId: offer.id,
          amountCents: amountCents,
          message: message.isNotEmpty ? message : null,
        );
      } catch (_) {
        // Non-critical: offer is created even if chat message fails.
      }

      if (!mounted) return;

      if (widget.onOfferSent != null) {
        // Called from chat page: callback handles feedback, just pop.
        widget.onOfferSent!(offer);
        Navigator.pop(context);
      } else {
        // Called from listing detail: pop with result + show snackbar.
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
      }
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
    final isCounter = widget.isCounterOffer;
    final title = isCounter ? 'Make a Counter-Offer' : 'Make an Offer';
    final messageHint = isCounter
        ? 'Add a note to the buyer...'
        : 'Add a note to the seller...';
    final buttonText = isCounter ? 'Send Counter-Offer' : 'Send Offer';
    final sendingText = isCounter ? 'Sending...' : 'Sending...';

    return LynewedSheet(
      title: title,
      onClose: () => Navigator.pop(context),
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
          LynewedSectionTitle(isCounter ? 'Your Counter-Offer (USD)' : 'Your Offer (USD)'),
          SizedBox(height: LynewedSpacing.labelFieldGap),
          LynewedTextField(
            controller: _amountController,
            hint: 'Enter amount',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
          ),

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Optional message.
          const LynewedSectionTitle('Message (optional)'),
          SizedBox(height: LynewedSpacing.labelFieldGap),
          LynewedTextField(
            controller: _messageController,
            hint: messageHint,
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

          SizedBox(height: LynewedSpacing.formSectionGap),

          // Submit button.
          SizedBox(
            width: double.infinity,
            child: LynewedButton(
              text: _isLoading ? sendingText : buttonText,
              onPressed: _isLoading ? null : _submitOffer,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
