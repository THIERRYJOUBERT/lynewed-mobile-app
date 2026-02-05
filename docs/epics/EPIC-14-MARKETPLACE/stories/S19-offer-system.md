# Story S19: Offer System

## Description
As a buyer, I want to make an offer on a listing, so I can negotiate the price before purchasing.

## Acceptance Criteria (Gherkin)

- [ ] Given a listing detail page When buyer clicks "Make Offer" Then offer modal should appear And buyer enters amount and optional message And offer is created with 48h expiration
- [ ] Given a pending offer When seller views offers Then they can Accept or Reject And buyer is notified of decision
- [ ] Given a pending offer older than 48h When expiration check runs Then offer status should be 'expired' And buyer should be notified
- [ ] Given an accepted offer When buyer proceeds Then they go directly to checkout with the accepted price
- [ ] Given a buyer with a pending offer on a listing When trying to make another offer Then they should be blocked ("You already have a pending offer")
- [ ] Given a buyer with a pending offer When they want to withdraw it Then withdraw button should allow cancellation And offer status becomes 'withdrawn'

## Prerequisites

- [ ] S03 completed (marketplace_offers table exists)
- [ ] Design System components available (LynewedSheet, LynewedTextField, LynewedButton)
- [ ] notifications_outbox table exists (for notifications)
- [ ] Edge Function expire-marketplace-offers deployed (see cron jobs section)

## Entity Definitions

### OfferEntity

```dart
import 'package:flutter/foundation.dart';

/// Represents an offer made by a buyer on a marketplace listing.
@immutable
class OfferEntity {
  const OfferEntity({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.amountCents,
    this.message,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    this.buyerName,
    this.buyerAvatarUrl,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final int amountCents;
  final String? message;
  final String status; // 'pending', 'accepted', 'rejected', 'expired', 'withdrawn'
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final String? buyerName;
  final String? buyerAvatarUrl;

  double get amountFormatted => amountCents / 100;

  bool get isPending => status == 'pending';
  bool get isExpiringSoon =>
      expiresAt.difference(DateTime.now()).inHours < 6;

  factory OfferEntity.fromJson(Map<String, dynamic> json) {
    return OfferEntity(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      amountCents: json['amount_cents'] as int,
      message: json['message'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      buyerName: json['buyer_name'] as String?,
      buyerAvatarUrl: json['buyer_avatar_url'] as String?,
    );
  }

  OfferEntity copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    String? sellerId,
    int? amountCents,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? respondedAt,
    String? buyerName,
    String? buyerAvatarUrl,
  }) {
    return OfferEntity(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      amountCents: amountCents ?? this.amountCents,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      buyerName: buyerName ?? this.buyerName,
      buyerAvatarUrl: buyerAvatarUrl ?? this.buyerAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfferEntity &&
        other.id == id &&
        other.listingId == listingId &&
        other.buyerId == buyerId &&
        other.sellerId == sellerId &&
        other.amountCents == amountCents &&
        other.message == message &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.expiresAt == expiresAt &&
        other.respondedAt == respondedAt &&
        other.buyerName == buyerName &&
        other.buyerAvatarUrl == buyerAvatarUrl;
  }

  @override
  int get hashCode => Object.hash(
        id,
        listingId,
        buyerId,
        sellerId,
        amountCents,
        message,
        status,
        createdAt,
        expiresAt,
        respondedAt,
        buyerName,
        buyerAvatarUrl,
      );

  @override
  String toString() => 'OfferEntity($id, status: $status, amount: \$$amountFormatted)';
}
```

## Repository Interface

```dart
import 'package:dartz/dartz.dart';
import '../entities/offer_entity.dart';

abstract class OfferRepository {
  /// Create a new offer on a listing.
  /// Returns failure if buyer already has pending offer.
  Future<Either<String, OfferEntity>> createOffer({
    required String listingId,
    required String buyerId,
    required String sellerId,
    required int amountCents,
    String? message,
  });

  /// Accept an offer (seller only).
  /// Uses SELECT FOR UPDATE to prevent race conditions.
  Future<Either<String, void>> acceptOffer(String offerId);

  /// Reject an offer (seller only).
  Future<Either<String, void>> rejectOffer(String offerId);

  /// Withdraw an offer (buyer only, pending only).
  Future<Either<String, void>> withdrawOffer(String offerId);

  /// Get all offers for a listing (for seller).
  Future<Either<String, List<OfferEntity>>> getOffersForListing(String listingId);

  /// Get pending offer for a buyer on a specific listing.
  /// Returns null if no pending offer.
  Future<Either<String, OfferEntity?>> getPendingOfferForListing(
    String listingId,
    String buyerId,
  );

  /// Get buyer's own offers (all statuses).
  Future<Either<String, List<OfferEntity>>> getMyOffers(String buyerId);
}
```

## Files to Create/Modify

### To Create

**Domain Layer:**
- `lib/features/marketplace/domain/entities/offer_entity.dart` - Offer entity (see above)
- `lib/features/marketplace/domain/repositories/offer_repository.dart` - Repository interface
- `lib/features/marketplace/domain/usecases/create_offer.dart` - Create offer use case
- `lib/features/marketplace/domain/usecases/respond_to_offer.dart` - Accept/reject use case
- `lib/features/marketplace/domain/usecases/withdraw_offer.dart` - Withdraw offer use case
- `lib/features/marketplace/domain/usecases/get_offers_for_listing.dart` - Get offers (seller)
- `lib/features/marketplace/domain/usecases/get_my_offers.dart` - Get offers (buyer)
- `lib/features/marketplace/domain/usecases/get_pending_offer.dart` - Check duplicate

**Data Layer:**
- `lib/features/marketplace/data/repositories/offer_repository_impl.dart` - Repository implementation
- `lib/features/marketplace/data/datasources/offer_remote_datasource.dart` - Supabase API calls

**Presentation Layer:**
- `lib/features/marketplace/presentation/pages/received_offers_page.dart` - Seller's offers list
- `lib/features/marketplace/presentation/pages/my_offers_page.dart` - Buyer's offers list
- `lib/features/marketplace/presentation/widgets/make_offer_sheet.dart` - Modal to make offer
- `lib/features/marketplace/presentation/widgets/offer_card.dart` - Offer display card
- `lib/features/marketplace/presentation/providers/offer_providers.dart` - Riverpod providers

**Edge Functions:**
- `supabase/functions/expire-marketplace-offers/index.ts` - Expire old offers (cron job)
- `supabase/functions/marketplace-offer-notify/index.ts` - Send offer notifications

### To Modify

- `lib/features/marketplace/presentation/pages/listing_detail_page.dart` - Add "Make Offer" button
- `lib/features/marketplace/presentation/pages/seller_dashboard_page.dart` - Link to received offers
- `lib/core/di/injection_container.dart` - Register offer dependencies
- `lib/core/navigation/routes.dart` - Add offer routes

## Race Condition Handling

### Accept Offer Race Condition

**Problem**: 2 buyers make offers, seller accepts both simultaneously → double-spend.

**Solution**: Row-level lock in Edge Function.

```typescript
// In marketplace-offer-notify/index.ts (or accept-offer/index.ts)
Deno.serve(async (req: Request) => {
  const { offer_id, seller_id } = await req.json();

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  try {
    // BEGIN transaction with row lock
    const { data: offer, error: lockError } = await supabase.rpc('accept_offer_with_lock', {
      p_offer_id: offer_id,
      p_seller_id: seller_id,
    });

    if (lockError) throw new Error(lockError.message);
    if (!offer) throw new Error('Offer not found or already processed');

    // Notification via notifications_outbox
    await supabase.from('notifications_outbox').insert({
      user_id: offer.buyer_id,
      title: 'Offer accepted!',
      body: `Your offer of $${offer.amount_cents / 100} was accepted`,
      data: {
        type: 'marketplace',
        subtype: 'offer_accepted',
        offer_id: offer_id,
        listing_id: offer.listing_id,
      },
    });

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error('Accept offer error:', error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

**SQL Function with Lock:**

```sql
-- Migration: accept_offer_with_lock function
CREATE OR REPLACE FUNCTION accept_offer_with_lock(
  p_offer_id UUID,
  p_seller_id UUID
)
RETURNS TABLE(
  id UUID,
  listing_id UUID,
  buyer_id UUID,
  amount_cents INT,
  status TEXT
) AS $$
DECLARE
  v_offer RECORD;
  v_listing RECORD;
BEGIN
  -- Lock offer row (prevents concurrent accepts)
  SELECT * INTO v_offer
  FROM marketplace_offers
  WHERE marketplace_offers.id = p_offer_id
    AND marketplace_offers.seller_id = p_seller_id
    AND marketplace_offers.status = 'pending'
  FOR UPDATE NOWAIT;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Offer not found or already processed';
  END IF;

  -- Check listing still active (also locked)
  SELECT * INTO v_listing
  FROM marketplace_listings
  WHERE marketplace_listings.id = v_offer.listing_id
    AND marketplace_listings.status = 'active'
  FOR UPDATE NOWAIT;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Listing no longer available';
  END IF;

  -- Update offer status
  UPDATE marketplace_offers
  SET status = 'accepted', responded_at = NOW()
  WHERE marketplace_offers.id = p_offer_id;

  -- Reject all other pending offers on this listing
  UPDATE marketplace_offers
  SET status = 'rejected', responded_at = NOW()
  WHERE listing_id = v_offer.listing_id
    AND id != p_offer_id
    AND status = 'pending';

  RETURN QUERY
  SELECT v_offer.id, v_offer.listing_id, v_offer.buyer_id, v_offer.amount_cents, 'accepted'::TEXT;
END;
$$ LANGUAGE plpgsql;
```

## Cron Jobs

### Expire Old Offers

**Mechanism**: pg_cron (Supabase built-in) invoking Edge Function every hour.

```sql
-- Enable pg_cron extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule cron job (run every hour)
SELECT cron.schedule(
  'expire-marketplace-offers',
  '0 * * * *', -- Every hour at :00
  $$
    SELECT
      net.http_post(
        url := 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/expire-marketplace-offers',
        headers := jsonb_build_object('Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')),
        body := '{}'::jsonb
      ) AS request_id;
  $$
);
```

**Edge Function: expire-marketplace-offers/index.ts**

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Find expired offers (pending + older than 48h)
    const { data: expiredOffers, error: fetchError } = await supabase
      .from('marketplace_offers')
      .select('id, buyer_id, listing_id, amount_cents')
      .eq('status', 'pending')
      .lt('expires_at', new Date().toISOString());

    if (fetchError) throw new Error(fetchError.message);

    if (!expiredOffers || expiredOffers.length === 0) {
      console.log('No expired offers found');
      return new Response(JSON.stringify({ expired_count: 0 }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Update status to expired
    const offerIds = expiredOffers.map(o => o.id);
    const { error: updateError } = await supabase
      .from('marketplace_offers')
      .update({ status: 'expired' })
      .in('id', offerIds);

    if (updateError) throw new Error(updateError.message);

    // Notify buyers via notifications_outbox
    const notifications = expiredOffers.map(offer => ({
      user_id: offer.buyer_id,
      title: 'Offer expired',
      body: `Your offer of $${offer.amount_cents / 100} expired`,
      data: {
        type: 'marketplace',
        subtype: 'offer_expired',
        offer_id: offer.id,
        listing_id: offer.listing_id,
      },
    }));

    await supabase.from('notifications_outbox').insert(notifications);

    console.log(`Expired ${expiredOffers.length} offers`);

    return new Response(JSON.stringify({ expired_count: expiredOffers.length }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error('Expire offers error:', error);
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

## Design System Usage

**IMPORTANT**: Use Lynewed* components (never Material brut).

### Make Offer Sheet

```dart
import '/core/design/design.dart';

class MakeOfferSheet extends ConsumerStatefulWidget {
  final ListingEntity listing;

  const MakeOfferSheet({required this.listing, super.key});

  @override
  ConsumerState<MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends ConsumerState<MakeOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Make an Offer',
      onClose: () => Navigator.pop(context),
      bottomAction: LynewedButton(
        label: _isLoading ? 'Sending...' : 'Send Offer',
        onPressed: _isLoading ? null : _submitOffer,
        isLoading: _isLoading,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Listing preview
            ListingMiniCard(listing: widget.listing),

            const SizedBox(height: 30),

            // Listed price
            LynewedSectionTitle('Listed price: \$${widget.listing.priceFormatted}'),
            const SizedBox(height: 10),

            // Offer amount
            LynewedSectionTitle('Your offer (USD)'),
            const SizedBox(height: 10),
            LynewedTextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixText: '\$',
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            // Optional message
            LynewedSectionTitle('Message (optional)'),
            const SizedBox(height: 10),
            LynewedTextField(
              controller: _messageController,
              maxLines: 3,
              hintText: 'Add a note to the seller...',
            ),

            const SizedBox(height: 10),

            // Expiration notice
            Text(
              'This offer will expire in 48 hours',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check for existing pending offer first
      final existingOffer = await ref
          .read(offerRepositoryProvider)
          .getPendingOfferForListing(widget.listing.id, currentUserId);

      existingOffer.fold(
        (error) => throw Exception(error),
        (offer) {
          if (offer != null) {
            throw Exception('You already have a pending offer on this item');
          }
        },
      );

      // Create offer
      final amountCents = (double.parse(_amountController.text) * 100).round();
      final result = await ref.read(offerRepositoryProvider).createOffer(
            listingId: widget.listing.id,
            buyerId: currentUserId,
            sellerId: widget.listing.sellerId,
            amountCents: amountCents,
            message: _messageController.text.isNotEmpty ? _messageController.text : null,
          );

      result.fold(
        (error) => throw Exception(error),
        (offer) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offer sent successfully!')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
```

### Offer Card (Seller View)

```dart
import '/core/design/design.dart';

class OfferCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OfferCard({
    required this.offer,
    required this.onAccept,
    required this.onReject,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buyer info
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(offer.buyerAvatarUrl ?? '')),
                const SizedBox(width: 8),
                Text(
                  offer.buyerName ?? 'Buyer',
                  style: LynewedTextStyles.titleSmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Offer amount
            Text(
              '\$${offer.amountFormatted}',
              style: LynewedTextStyles.headlineMedium.copyWith(
                color: LynewedColors.primary,
              ),
            ),

            // Message if present
            if (offer.message != null) ...[
              const SizedBox(height: 8),
              Text(offer.message!, style: LynewedTextStyles.bodyMedium),
            ],

            const SizedBox(height: 8),

            // Expiration
            Text(
              'Expires ${_formatExpiration(offer.expiresAt)}',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: offer.isExpiringSoon ? LynewedColors.warning : LynewedColors.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // Actions (if pending)
            if (offer.isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LynewedButton(
                    label: 'Decline',
                    type: LynewedButtonType.secondary,
                    onPressed: onReject,
                  ),
                  const SizedBox(width: 8),
                  LynewedButton(
                    label: 'Accept',
                    onPressed: onAccept,
                  ),
                ],
              )
            else
              Chip(
                label: Text(offer.status.toUpperCase()),
                backgroundColor: _getStatusColor(offer.status),
              ),
          ],
        ),
      ),
    );
  }

  String _formatExpiration(DateTime expiresAt) {
    final now = DateTime.now();
    final diff = expiresAt.difference(now);
    if (diff.isNegative) return 'expired';
    if (diff.inDays > 0) return 'in ${diff.inDays}d ${diff.inHours % 24}h';
    return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return LynewedColors.success;
      case 'rejected':
      case 'expired':
        return LynewedColors.error;
      default:
        return LynewedColors.warning;
    }
  }
}
```

## Screen States

### Make Offer Sheet
- **Loading**: Button disabled, "Sending..." text
- **Empty**: Initial form state
- **Error**: Validation errors or duplicate offer error
- **Success**: Close sheet, show snackbar

### Received Offers Page (Seller)
- **Loading**: CircularProgressIndicator
- **Empty**: "No offers yet" with icon
- **Data**: List of OfferCard widgets
- **Error**: Error message with retry button

### My Offers Page (Buyer)
- **Loading**: CircularProgressIndicator
- **Empty**: "You haven't made any offers yet"
- **Data**: List of offer cards with status badges
- **Error**: Error message with retry button

## Tests Required

### Unit Tests (offer_repository_impl_test.dart)
- `createOffer_success_returnsOffer`
- `createOffer_duplicatePending_returnsError`
- `acceptOffer_validPending_updatesStatus`
- `acceptOffer_alreadyAccepted_returnsError`
- `rejectOffer_validPending_updatesStatus`
- `withdrawOffer_buyerOwned_updatesStatus`
- `withdrawOffer_notBuyerOwned_returnsError`
- `getPendingOfferForListing_exists_returnsOffer`
- `getPendingOfferForListing_notExists_returnsNull`

### Widget Tests (make_offer_sheet_test.dart)
- `makeOfferSheet_validAmount_enablesSendButton`
- `makeOfferSheet_invalidAmount_showsError`
- `makeOfferSheet_duplicateOffer_showsError`
- `makeOfferSheet_submit_callsCreateOffer`

### Widget Tests (offer_card_test.dart)
- `offerCard_pendingOffer_showsActions`
- `offerCard_acceptedOffer_showsStatusChip`
- `offerCard_expiringSoon_showsWarning`
- `offerCard_accept_callsOnAccept`

### Integration Tests
- `offer_flow_makeOffer_sellerSeesInList`
- `offer_flow_acceptOffer_buyerNotified`
- `offer_flow_rejectOffer_buyerNotified`

## Definition of Done

- [ ] OfferEntity with all fields
- [ ] OfferRepository interface complete
- [ ] OfferRepositoryImpl with Supabase calls
- [ ] All use cases implemented
- [ ] Make offer sheet with Design System
- [ ] Offer card with Design System
- [ ] Received offers page (seller)
- [ ] My offers page (buyer)
- [ ] Duplicate offer prevention
- [ ] Withdraw offer functionality
- [ ] Accept/reject with race condition handling
- [ ] Edge Function expire-marketplace-offers deployed
- [ ] Edge Function marketplace-offer-notify deployed
- [ ] pg_cron job scheduled
- [ ] SQL function accept_offer_with_lock created
- [ ] Notifications via notifications_outbox
- [ ] Navigation from listing detail
- [ ] Navigation from seller dashboard
- [ ] Routes registered
- [ ] Dependencies registered in injection_container
- [ ] All tests passing
- [ ] `flutter analyze --fatal-infos` passes

## Estimation
**Points**: 5
**Complexity**: Medium
**Risk**: Medium (race conditions, cron jobs)

## Dependencies
- S03 (marketplace_offers table)

## Dependent Stories
- S20 (checkout flow uses accepted offer)
- S23 (notifications for offer events)

## Notes

**COUNTER-OFFER EXCLUDED**: For MVP, counter-offer functionality is out of scope. Seller can only accept or reject. Future enhancement can add counter-offer via S19-ENHANCEMENT-01.

**NOTIFICATIONS**: Use existing notifications_outbox pattern (same as reviews/payments). No need to wait for S23.

**ENGLISH ONLY**: All UI text must be in English.

**RACE CONDITIONS**: Accept offer MUST use SELECT FOR UPDATE via SQL function to prevent concurrent accepts.
