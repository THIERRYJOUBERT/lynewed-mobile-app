# Story S21: Generation etiquette FedEx (vendeur)

## Description
En tant que vendeur, je veux generer l'etiquette d'expedition apres une vente, afin d'envoyer l'article a l'acheteuse.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a paid transaction When seller opens the transaction Then "Generate Shipping Label" button should be visible
- [ ] Given seller clicks "Generate Shipping Label" When FedEx Ship API is called Then label PDF should display inline And email with PDF should be sent to seller And transaction status should become 'label_created'
- [ ] Given a generated label When seller views transaction Then "Download Label" and "Print Label" options should be available
- [ ] Given FedEx API error When generating label Then error message should display And retry button should be available
- [ ] Given a label already generated When seller views transaction Then "Generate Label" button should be replaced by "View Label"

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/pages/transaction_detail_page.dart` - Transaction view
- `lib/features/marketplace/presentation/widgets/shipping_label_widget.dart` - Label display/download
- `lib/features/marketplace/presentation/widgets/generate_label_button.dart` - Action button
- `lib/features/marketplace/domain/usecases/generate_shipping_label.dart` - Use case
- `lib/features/marketplace/data/datasources/shipping_remote_datasource.dart` - API calls

### A Modifier
- `lib/features/marketplace/presentation/pages/seller_dashboard_page.dart` - Link to transaction

## Notes Techniques

### Transaction Detail Page (Seller View)
```dart
class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Sale Details')),
      body: txAsync.when(
        data: (tx) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing preview
              ListingMiniCard(listing: tx.listing),

              const SizedBox(height: 16),

              // Buyer info
              _BuyerInfoSection(buyer: tx.buyer, shippingAddress: tx.shippingToAddress),

              const SizedBox(height: 16),

              // Transaction status
              _StatusSection(status: tx.status),

              const SizedBox(height: 16),

              // Shipping Label Section
              if (tx.status == 'paid')
                GenerateLabelButton(
                  transactionId: tx.id,
                  onSuccess: () => ref.refresh(transactionDetailProvider(transactionId)),
                )
              else if (tx.fedexLabelUrl != null)
                ShippingLabelWidget(
                  labelUrl: tx.fedexLabelUrl!,
                  trackingNumber: tx.fedexTrackingNumber!,
                ),

              const SizedBox(height: 16),

              // Price breakdown
              _PriceBreakdownSection(tx: tx),
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

### Generate Label Button
```dart
class GenerateLabelButton extends ConsumerStatefulWidget {
  final String transactionId;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.local_shipping, size: 48),
            const SizedBox(height: 8),
            const Text('Generate your FedEx shipping label'),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Column(
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _generateLabel,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: _generateLabel,
                icon: const Icon(Icons.print),
                label: const Text('Generate Shipping Label'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateLabel() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(shippingRepositoryProvider).generateLabel(widget.transactionId);
      widget.onSuccess();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Shipping Label Widget
```dart
class ShippingLabelWidget extends StatelessWidget {
  final String labelUrl;
  final String trackingNumber;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 8),
            const Text('Shipping label ready!'),

            const SizedBox(height: 16),

            // Tracking number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tracking: '),
                SelectableText(
                  trackingNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyToClipboard(trackingNumber),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _viewPdf(labelUrl),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _downloadPdf(labelUrl),
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Instructions
            Text(
              'Print this label and attach it to your package.\n'
              'Drop off at any FedEx location.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _viewPdf(String url) {
    // Open PDF in viewer (url_launcher or PDF viewer)
    launchUrl(Uri.parse(url));
  }

  void _downloadPdf(String url) {
    // Download PDF to device
    // Use dio or flutter_downloader
  }
}
```

### Edge Function Call
```dart
Future<void> generateLabel(String transactionId) async {
  final response = await supabase.functions.invoke(
    'fedex-create-shipment',
    body: {'transaction_id': transactionId},
  );

  if (response.data['error'] != null) {
    throw Exception(response.data['error']);
  }
}
```

## Definition of Done
- [ ] Transaction detail page (seller)
- [ ] Generate label button avec loading/error states
- [ ] Label widget avec view/download
- [ ] Tracking number affiche et copiable
- [ ] Email envoye avec PDF
- [ ] Status mis a jour (label_created)
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (integration FedEx)

## Dependances
- S12 (FedEx Ship API Edge Function)

## Stories Dependantes
- S22 (tracking colis - utilise tracking number)
