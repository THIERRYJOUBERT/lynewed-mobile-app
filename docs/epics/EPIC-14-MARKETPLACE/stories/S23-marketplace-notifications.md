# Story S23: Notifications marketplace

## Description
En tant qu'utilisatrice du marketplace, je veux recevoir des notifications pour les evenements importants, afin de ne rien manquer.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller with active listing When buyer makes an offer Then seller receives push notification "New offer on [item]"
- [ ] Given a buyer with pending offer When seller responds (accept/reject) Then buyer receives notification
- [ ] Given a seller When their item is purchased Then they receive push "Your [item] sold for $X!"
- [ ] Given a buyer after purchase When tracking status changes Then buyer receives notification
- [ ] Given a user When they receive notification And tap on it Then they are deep-linked to relevant screen
- [ ] Given marketplace notifications Then they should also appear in in-app notification center

## Fichiers Concernes

### A Creer
- `supabase/functions/marketplace-notify/index.ts` - Edge Function notifications
- `lib/features/marketplace/domain/entities/marketplace_notification.dart` - Entity
- `lib/features/marketplace/data/datasources/notification_remote_datasource.dart` - API

### A Modifier
- `lib/features/notifications/presentation/pages/notifications_page.dart` - Add marketplace notifications
- `lib/core/services/push_notification_service.dart` - Handle marketplace deep links
- `supabase/functions/stripe-webhook/index.ts` - Trigger notification on payment
- `supabase/functions/fedex-track-cron/index.ts` - Trigger notification on tracking update

## Notes Techniques

### Notification Types
```typescript
type MarketplaceNotificationType =
  | 'new_offer'           // Seller: someone made an offer
  | 'offer_accepted'      // Buyer: seller accepted your offer
  | 'offer_rejected'      // Buyer: seller rejected your offer
  | 'offer_expired'       // Buyer: your offer expired
  | 'new_message'         // Both: new chat message
  | 'item_sold'           // Seller: your item was purchased
  | 'order_confirmed'     // Buyer: your order is confirmed
  | 'label_created'       // Buyer: seller created shipping label
  | 'package_shipped'     // Buyer: package shipped
  | 'package_in_transit'  // Buyer: package in transit
  | 'package_delivered'   // Both: package delivered
  | 'transaction_complete' // Both: transaction completed, funds released
```

### Edge Function: marketplace-notify
```typescript
Deno.serve(async (req) => {
  const { type, user_id, data } = await req.json();

  // 1. Build notification content
  const notification = buildNotification(type, data);

  // 2. Insert into notifications_outbox (existing table)
  await supabase.from('notifications_outbox').insert({
    user_id,
    title: notification.title,
    body: notification.body,
    data: {
      type: 'marketplace',
      subtype: type,
      ...data,
    },
    created_at: new Date(),
  });

  // 3. In-app notification (optional separate table)
  await supabase.from('marketplace_notifications').insert({
    user_id,
    type,
    title: notification.title,
    body: notification.body,
    data,
    read: false,
    created_at: new Date(),
  });

  return new Response(JSON.stringify({ success: true }));
});

function buildNotification(type: string, data: any) {
  switch (type) {
    case 'new_offer':
      return {
        title: 'New offer received',
        body: `${data.buyer_name} offered $${data.amount} for "${data.listing_title}"`,
      };
    case 'offer_accepted':
      return {
        title: 'Offer accepted!',
        body: `Your offer of $${data.amount} for "${data.listing_title}" was accepted`,
      };
    case 'item_sold':
      return {
        title: 'Congratulations! Item sold',
        body: `Your "${data.listing_title}" sold for $${data.amount}`,
      };
    case 'package_shipped':
      return {
        title: 'Package shipped',
        body: `Your order is on its way! Tracking: ${data.tracking_number}`,
      };
    case 'package_delivered':
      return {
        title: 'Package delivered',
        body: `Your order has been delivered!`,
      };
    // ... other types
  }
}
```

### Deep Link Handling
```dart
// In push_notification_service.dart
void _handleNotificationTap(Map<String, dynamic> data) {
  if (data['type'] != 'marketplace') return;

  final subtype = data['subtype'];
  final transactionId = data['transaction_id'];
  final listingId = data['listing_id'];
  final offerId = data['offer_id'];

  switch (subtype) {
    case 'new_offer':
    case 'offer_accepted':
    case 'offer_rejected':
      // Navigate to offers page
      _router.push('/marketplace/offers/$offerId');
      break;

    case 'new_message':
      // Navigate to chat
      _router.push('/marketplace/chat/$listingId');
      break;

    case 'item_sold':
    case 'label_created':
      // Seller: navigate to transaction detail
      _router.push('/marketplace/sales/$transactionId');
      break;

    case 'order_confirmed':
    case 'package_shipped':
    case 'package_in_transit':
    case 'package_delivered':
      // Buyer: navigate to order tracking
      _router.push('/marketplace/orders/$transactionId');
      break;
  }
}
```

### Trigger Points

**From Stripe Webhook (payment success):**
```typescript
// In stripe-webhook/index.ts
case 'payment_intent.succeeded':
  // ... create transaction ...

  // Notify seller
  await supabase.functions.invoke('marketplace-notify', {
    body: {
      type: 'item_sold',
      user_id: transaction.seller_id,
      data: { listing_title, amount, transaction_id },
    },
  });

  // Notify buyer
  await supabase.functions.invoke('marketplace-notify', {
    body: {
      type: 'order_confirmed',
      user_id: transaction.buyer_id,
      data: { listing_title, transaction_id },
    },
  });
  break;
```

**From FedEx Track Cron:**
```typescript
// In fedex-track-cron/index.ts
async function updateTransactionStatus(txId, event) {
  // ... update status ...

  // Notify buyer
  await supabase.functions.invoke('marketplace-notify', {
    body: {
      type: `package_${event.type}`,
      user_id: transaction.buyer_id,
      data: { tracking_number, location, transaction_id },
    },
  });
}
```

## Definition of Done
- [ ] Edge Function marketplace-notify deployee
- [ ] Tous types de notifications implementes
- [ ] Push notifications envoyees
- [ ] Deep links fonctionnels
- [ ] In-app notifications listees
- [ ] Triggers depuis webhooks/cron
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible (infrastructure notifications existante)

## Dependances
- S19 (offres - trigger new_offer)
- S20 (achat - trigger item_sold)
- S13 (tracking - trigger shipping updates)
- Infrastructure notifications existante (notifications_outbox, FCM)

## Stories Dependantes
- Aucune
