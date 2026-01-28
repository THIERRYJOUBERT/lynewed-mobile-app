# Story S19: Systeme d'offres

## Description
En tant qu'acheteuse, je veux faire une offre sur un article, afin de negocier le prix avant d'acheter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a listing detail page When buyer clicks "Make Offer" Then offer modal should appear And buyer enters amount and optional message And offer is created with 48h expiration
- [ ] Given a pending offer When seller views offers Then they can Accept or Reject And buyer is notified of decision
- [ ] Given a pending offer older than 48h When expiration check runs Then offer status should be 'expired' And buyer should be notified
- [ ] Given an accepted offer When buyer proceeds Then they go directly to checkout with the accepted price
- [ ] Given a buyer with a pending offer on a listing When trying to make another offer Then they should be blocked ("You already have a pending offer")

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/widgets/make_offer_modal.dart` - Modal pour faire offre
- `lib/features/marketplace/presentation/pages/received_offers_page.dart` - Liste offres recues (vendeur)
- `lib/features/marketplace/presentation/pages/my_offers_page.dart` - Liste mes offres (acheteur)
- `lib/features/marketplace/presentation/widgets/offer_card.dart` - Card affichage offre
- `lib/features/marketplace/data/datasources/offer_remote_datasource.dart` - API calls
- `lib/features/marketplace/data/repositories/offer_repository_impl.dart` - Repository
- `lib/features/marketplace/domain/repositories/offer_repository.dart` - Interface
- `lib/features/marketplace/domain/entities/offer.dart` - Entity
- `lib/features/marketplace/domain/usecases/make_offer.dart` - Use case
- `lib/features/marketplace/domain/usecases/respond_to_offer.dart` - Use case
- `lib/features/marketplace/domain/usecases/withdraw_offer.dart` - Use case
- `lib/features/marketplace/domain/usecases/get_offers_for_listing.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/listing_detail_page.dart` - "Make Offer" action
- `lib/features/marketplace/presentation/pages/seller_dashboard_page.dart` - Link to received offers

## Notes Techniques

### Make Offer Modal
```dart
class MakeOfferModal extends StatefulWidget {
  final ListingEntity listing;
  final Function(int amountCents, String? message) onSubmit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Make an Offer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Listing preview
          ListingMiniCard(listing: listing),

          const SizedBox(height: 16),

          // Current price display
          Text('Listed price: \$${listing.priceFormatted}'),

          const SizedBox(height: 16),

          // Offer amount input
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Your offer (USD)',
              prefixText: '\$',
            ),
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              if (amount == null || amount <= 0) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Optional message
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message (optional)',
              hintText: 'Add a note to the seller...',
            ),
          ),

          const SizedBox(height: 8),

          // Expiration notice
          Text(
            'This offer will expire in 48 hours',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitOffer,
          child: const Text('Send Offer'),
        ),
      ],
    );
  }
}
```

### Offer Card (for seller view)
```dart
class OfferCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onAccept;
  final VoidCallback onReject;

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
                CircleAvatar(backgroundImage: NetworkImage(offer.buyer.avatarUrl)),
                const SizedBox(width: 8),
                Text(offer.buyer.displayName),
              ],
            ),

            const SizedBox(height: 12),

            // Offer amount
            Text(
              '\$${offer.amountFormatted}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            // Message if present
            if (offer.message != null) ...[
              const SizedBox(height: 8),
              Text(offer.message!, style: Theme.of(context).textTheme.bodyMedium),
            ],

            const SizedBox(height: 8),

            // Expiration
            Text(
              'Expires ${_formatExpiration(offer.expiresAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _isExpiringSoon(offer.expiresAt) ? Colors.orange : null,
              ),
            ),

            const SizedBox(height: 12),

            // Actions (if pending)
            if (offer.status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ],
              )
            else
              Chip(label: Text(offer.status.toUpperCase())),
          ],
        ),
      ),
    );
  }
}
```

### Accept Offer Flow
```dart
Future<void> _acceptOffer(OfferEntity offer) async {
  // 1. Update offer status
  await ref.read(offerRepositoryProvider).respondToOffer(
    offerId: offer.id,
    response: 'accepted',
  );

  // 2. Navigate to checkout with accepted price
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CheckoutPage(
        listing: listing,
        offerId: offer.id,
        agreedPriceCents: offer.amountCents,
      ),
    ),
  );
}
```

### Duplicate Offer Prevention
```dart
Future<OfferEntity?> getPendingOfferForListing(String listingId, String buyerId) async {
  final response = await supabase
    .from('marketplace_offers')
    .select()
    .eq('listing_id', listingId)
    .eq('buyer_id', buyerId)
    .eq('status', 'pending')
    .maybeSingle();

  return response != null ? OfferEntity.fromJson(response) : null;
}

// In MakeOfferModal
void _checkExistingOffer() async {
  final existing = await ref.read(offerRepositoryProvider)
    .getPendingOfferForListing(listing.id, currentUserId);

  if (existing != null) {
    _showError('You already have a pending offer on this item');
    return;
  }
}
```

## Definition of Done
- [ ] Make offer modal complete
- [ ] Offre creee avec expiration 48h
- [ ] Received offers page (vendeur)
- [ ] Accept/Reject fonctionne
- [ ] My offers page (acheteur)
- [ ] Withdraw offer fonctionne
- [ ] Prevention double offre
- [ ] Navigation checkout si accepte
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S03 (marketplace_offers table)

## Stories Dependantes
- S20 (flow achat - utilise offre acceptee)
- S23 (notifications - offre recue, acceptee, rejetee)
