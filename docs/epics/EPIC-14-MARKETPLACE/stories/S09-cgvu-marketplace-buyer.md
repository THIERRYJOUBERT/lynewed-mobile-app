# Story S09: Implement CGVU marketplace buyer

## Description
En tant qu'acheteuse, je veux accepter les CGVU avant mon premier achat, afin de comprendre mes droits et obligations et que l'acceptation soit tracee.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a buyer who has never accepted marketplace buyer CGVU When they proceed to checkout Then CGVU modal should be displayed And payment button should be blocked until accepted
- [ ] Given a buyer accepting CGVU When they check the box and confirm Then cgvu_acceptances should have cgvu_type='marketplace_buyer' with full logging (IP, device, timestamp)
- [ ] Given a buyer who already accepted CGVU When they make another purchase Then no CGVU modal should appear
- [ ] Given the checkout flow When CGVU not accepted Then the "Pay" button should be disabled
- [ ] Given the CGVU modal When user scrolls to bottom and checks the box Then acceptance should be logged before proceeding to payment

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/widgets/cgvu_buyer_modal.dart` - Modal widget

### A Modifier
- `lib/features/marketplace/presentation/pages/checkout_page.dart` - Integrate CGVU check
- Reuse data layer from S08 (cgvu_remote_datasource, repository, usecases)

## Notes Techniques

### Differences avec CGVU Seller (S08)
- `cgvu_type = 'marketplace_buyer'` (vs 'marketplace_seller')
- Affiche dans le checkout flow (vs create listing flow)
- Texte CGVU different (droits acheteur vs obligations vendeur)

### Flutter Widget Pattern
```dart
class CgvuBuyerModal extends StatefulWidget {
  final VoidCallback onAccepted;

  // Same pattern as CgvuSellerModal
  // Scroll detection, checkbox enable, logging
}
```

### Checkout Flow Integration
```dart
// In CheckoutPage
void _proceedToPayment() async {
  final hasAccepted = await ref.read(cgvuRepositoryProvider)
    .hasAccepted(userId, 'marketplace_buyer');

  if (!hasAccepted) {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => CgvuBuyerModal(onAccepted: () => Navigator.pop(context, true)),
    );
    if (accepted != true) return;
  }

  // Proceed with payment
  _processPayment();
}
```

### Contenu CGVU Buyer (a fournir par legal)
- Pas de garantie Lynewed sur l'etat de l'article
- Politique de retour (via vendeur uniquement)
- Frais de port non remboursables
- Delai de livraison estimatif (FedEx)
- Protection des donnees

## Definition of Done
- [ ] Modal CGVU buyer implementee
- [ ] Integration dans checkout flow
- [ ] Logging complet (meme format que S08)
- [ ] Cache local
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible (reutilise S08)
**Risque** : Moyen (compliance legale)

## Dependances
- S08 (table cgvu_acceptances, data layer partage)

## Stories Dependantes
- S20 (flow achat - integre check CGVU buyer)
