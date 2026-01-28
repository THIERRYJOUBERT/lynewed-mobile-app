# Story S12: Edge Function FedEx Ship API

## Description
En tant que vendeur, je veux generer une etiquette d'expedition FedEx, afin d'envoyer l'article vendu a l'acheteuse.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a paid transaction with validated addresses When seller requests label generation Then FedEx Ship API should return tracking_number and label_url (PDF)
- [ ] Given successful label generation Then transaction should be updated with fedex_tracking_number and fedex_label_url
- [ ] Given successful label generation Then fedex_events should log 'label_created' event with full payload
- [ ] Given successful label generation Then email should be sent to seller with PDF attachment
- [ ] Given a network error with FedEx When label generation is attempted Then error should be logged And seller should see retry option

## Fichiers Concernes

### A Creer
- `supabase/functions/fedex-create-shipment/index.ts` - Edge Function
- `lib/features/marketplace/domain/usecases/generate_shipping_label.dart` - Use case
- `lib/features/marketplace/presentation/widgets/shipping_label_widget.dart` - Display PDF

### A Modifier
- `supabase/functions/_shared/fedex-client.ts` - Add createShipment method
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart` - Add label generation

## Notes Techniques

### Edge Function Structure
```typescript
Deno.serve(async (req) => {
  const { transaction_id, service_type } = await req.json();

  // 1. Get transaction with addresses
  const { data: transaction } = await supabase
    .from('marketplace_transactions')
    .select('*, listing:marketplace_listings(*)')
    .eq('id', transaction_id)
    .single();

  // 2. Create shipment with FedEx
  const shipment = await fedex.createShipment({
    shipper: transaction.shipping_from_address,
    recipient: transaction.shipping_to_address,
    serviceType: service_type,
    packageDetails: getPackageDetails(transaction.listing.category),
  });

  // 3. Update transaction
  await supabase
    .from('marketplace_transactions')
    .update({
      fedex_tracking_number: shipment.trackingNumber,
      fedex_label_url: shipment.labelUrl,
      status: 'label_created',
    })
    .eq('id', transaction_id);

  // 4. Log event
  await supabase.from('fedex_events').insert({
    transaction_id,
    tracking_number: shipment.trackingNumber,
    event_type: 'label_created',
    event_description: 'Shipping label generated',
    raw_payload: shipment.rawResponse,
  });

  // 5. Send email to seller
  await sendLabelEmail(transaction.seller_id, shipment.labelUrl);

  return new Response(JSON.stringify({
    tracking_number: shipment.trackingNumber,
    label_url: shipment.labelUrl,
  }));
});
```

### FedEx Ship API
```typescript
// In FedExClient
async createShipment(params: ShipmentParams): Promise<ShipmentResult> {
  // POST /ship/v1/shipments
  // labelResponseOptions: 'URL_ONLY' for PDF URL
  // or 'LABEL' for base64 encoded PDF
}
```

### Label Format
- PDF format prefere (imprimable)
- Taille 4x6 inches (standard shipping label)
- Include return label option (future enhancement)

### Email avec Resend (ou autre service)
```typescript
async function sendLabelEmail(sellerId: string, labelUrl: string) {
  const { data: seller } = await supabase
    .from('profiles')
    .select('email, display_name')
    .eq('id', sellerId)
    .single();

  await resend.emails.send({
    to: seller.email,
    subject: 'Your FedEx shipping label is ready',
    html: `<p>Hi ${seller.display_name},</p>
           <p>Your shipping label is ready: <a href="${labelUrl}">Download PDF</a></p>`,
  });
}
```

## Definition of Done
- [ ] Edge Function deployee
- [ ] FedEx Ship API integree
- [ ] Transaction mise a jour avec tracking
- [ ] Event fedex_events logge
- [ ] Email envoye avec label
- [ ] Tests en sandbox
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (API externe, couts par etiquette)

## Dependances
- S04 (marketplace_transactions)
- S06 (fedex_events)
- S11 (FedEx client partage)

## Stories Dependantes
- S13 (FedEx Track API)
- S21 (generation etiquette frontend)
