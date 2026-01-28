# Story S22: Tracking colis (acheteur)

## Description
En tant qu'acheteuse, je veux suivre mon colis en temps reel, afin de savoir quand il sera livre.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a shipped transaction When buyer views transaction Then tracking timeline should show all status steps: Order placed, Label created, Shipped, In transit, Delivered
- [ ] Given FedEx reports new status When buyer views tracking Then timeline should be updated with latest status
- [ ] Given each tracking update Then buyer should receive push notification
- [ ] Given the tracking timeline When user taps on tracking number Then it should open FedEx website for detailed tracking
- [ ] Given package delivered When 7 days pass without dispute Then transaction status should become 'completed'

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/buyer_transaction_page.dart` - Buyer view
- `lib/features/marketplace/presentation/widgets/tracking_timeline.dart` - Timeline widget
- `lib/features/marketplace/presentation/widgets/tracking_step_widget.dart` - Step item
- `lib/features/marketplace/domain/usecases/get_tracking_events.dart` - Use case

### A Modifier
- `lib/features/marketplace/presentation/pages/my_purchases_page.dart` - Link to transaction

## Notes Techniques

### Buyer Transaction Page
```dart
class BuyerTransactionPage extends ConsumerWidget {
  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionDetailProvider(transactionId));
    final eventsAsync = ref.watch(trackingEventsProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: txAsync.when(
        data: (tx) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              ListingMiniCard(listing: tx.listing),

              const SizedBox(height: 16),

              // Current status highlight
              _CurrentStatusCard(status: tx.status),

              const SizedBox(height: 16),

              // Tracking timeline
              if (tx.fedexTrackingNumber != null)
                TrackingTimeline(
                  transactionId: transactionId,
                  trackingNumber: tx.fedexTrackingNumber!,
                  events: eventsAsync.valueOrNull ?? [],
                  currentStatus: tx.status,
                ),

              const SizedBox(height: 16),

              // Seller info
              _SellerInfoSection(seller: tx.seller),

              const SizedBox(height: 16),

              // Price paid
              _PriceSummarySection(tx: tx),
            ],
          ),
        ),
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorWidget(error: e),
      ),
    );
  }
}
```

### Tracking Timeline Widget
```dart
class TrackingTimeline extends StatelessWidget {
  final String transactionId;
  final String trackingNumber;
  final List<FedexEventEntity> events;
  final String currentStatus;

  // Define all steps
  static const steps = [
    TrackingStep(id: 'ordered', label: 'Order Placed', icon: Icons.shopping_bag),
    TrackingStep(id: 'paid', label: 'Payment Confirmed', icon: Icons.payment),
    TrackingStep(id: 'label_created', label: 'Label Created', icon: Icons.qr_code),
    TrackingStep(id: 'shipped', label: 'Shipped', icon: Icons.local_shipping),
    TrackingStep(id: 'in_transit', label: 'In Transit', icon: Icons.flight),
    TrackingStep(id: 'delivered', label: 'Delivered', icon: Icons.home),
    TrackingStep(id: 'completed', label: 'Completed', icon: Icons.check_circle),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with tracking number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _openFedexTracking(trackingNumber),
                  child: Row(
                    children: [
                      Text(
                        trackingNumber,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Timeline
            ...steps.map((step) => TrackingStepWidget(
              step: step,
              isCompleted: _isStepCompleted(step.id, currentStatus),
              isCurrent: _isCurrentStep(step.id, currentStatus),
              event: _findEventForStep(step.id, events),
            )),
          ],
        ),
      ),
    );
  }

  bool _isStepCompleted(String stepId, String currentStatus) {
    final statusOrder = ['ordered', 'paid', 'label_created', 'shipped', 'in_transit', 'delivered', 'completed'];
    return statusOrder.indexOf(stepId) <= statusOrder.indexOf(currentStatus);
  }

  void _openFedexTracking(String trackingNumber) {
    launchUrl(Uri.parse('https://www.fedex.com/fedextrack/?trknbr=$trackingNumber'));
  }
}
```

### Tracking Step Widget
```dart
class TrackingStepWidget extends StatelessWidget {
  final TrackingStep step;
  final bool isCompleted;
  final bool isCurrent;
  final FedexEventEntity? event;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline indicator
          Column(
            children: [
              // Dot
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                ),
                child: Icon(
                  step.icon,
                  size: 14,
                  color: isCompleted ? Colors.white : Colors.grey,
                ),
              ),
              // Line
              if (!_isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (event != null) ...[
                    Text(
                      _formatDateTime(event!.eventTimestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (event!.location != null)
                      Text(
                        event!.location!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Auto-refresh Tracking
```dart
// In provider
final trackingEventsProvider = StreamProvider.family<List<FedexEventEntity>, String>((ref, transactionId) {
  // Poll every 5 minutes while on page
  return Stream.periodic(const Duration(minutes: 5), (_) async {
    final response = await supabase
      .from('fedex_events')
      .select()
      .eq('transaction_id', transactionId)
      .order('event_timestamp', ascending: true);

    return response.map((json) => FedexEventEntity.fromJson(json)).toList();
  }).asyncMap((future) => future);
});
```

## Definition of Done
- [ ] Buyer transaction page complete
- [ ] Tracking timeline avec toutes les etapes
- [ ] Events affiches avec date/location
- [ ] Tracking number clickable (FedEx website)
- [ ] Current step highlighted
- [ ] Auto-refresh des events
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S06 (fedex_events table)
- S13 (FedEx Track API)

## Stories Dependantes
- S23 (notifications - tracking updates)
