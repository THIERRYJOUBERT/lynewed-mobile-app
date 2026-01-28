# Story S13: Edge Function FedEx Track API

## Description
En tant qu'acheteuse, je veux suivre mon colis en temps reel, afin de savoir quand il sera livre.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a shipped transaction with tracking number When FedEx reports package is in transit Then transaction status should update to 'in_transit' And fedex_events should log the event And buyer should receive notification
- [ ] Given a package out for delivery When FedEx confirms delivery Then transaction status should be 'delivered' And both buyer and seller should be notified And 7-day countdown for completion starts
- [ ] Given multiple tracking events When polling FedEx Track API Then all new events should be logged in chronological order
- [ ] Given a tracking number When querying track status Then all events with location, timestamp, and description should be returned

## Fichiers Concernes

### A Creer
- `supabase/functions/fedex-track-shipment/index.ts` - Edge Function (polling ou webhook)
- `supabase/functions/fedex-track-cron/index.ts` - Cron job for polling
- `lib/features/marketplace/domain/usecases/get_tracking_events.dart` - Use case

### A Modifier
- `supabase/functions/_shared/fedex-client.ts` - Add trackShipment method
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart` - Add tracking

## Notes Techniques

### Architecture: Polling vs Webhook

**Option 1: Polling (Recommande pour MVP)**
- Cron job toutes les heures pour transactions 'shipped' ou 'in_transit'
- Simple a implementer
- Pas de configuration webhook FedEx necessaire

**Option 2: FedEx Track Webhook (Future)**
- Temps reel
- Necessite endpoint public et configuration FedEx

### Cron Job Structure
```typescript
// fedex-track-cron - scheduled via pg_cron or Supabase scheduled functions
Deno.serve(async () => {
  // Get all transactions with tracking that need updates
  const { data: transactions } = await supabase
    .from('marketplace_transactions')
    .select('id, fedex_tracking_number')
    .in('status', ['shipped', 'in_transit', 'label_created']);

  for (const tx of transactions) {
    await trackAndUpdateTransaction(tx);
  }

  return new Response(JSON.stringify({ tracked: transactions.length }));
});

async function trackAndUpdateTransaction(tx) {
  const events = await fedex.trackShipment(tx.fedex_tracking_number);

  // Get last logged event timestamp
  const { data: lastEvent } = await supabase
    .from('fedex_events')
    .select('event_timestamp')
    .eq('transaction_id', tx.id)
    .order('event_timestamp', { ascending: false })
    .limit(1)
    .single();

  // Filter new events only
  const newEvents = events.filter(e =>
    !lastEvent || new Date(e.timestamp) > new Date(lastEvent.event_timestamp)
  );

  // Insert new events
  for (const event of newEvents) {
    await supabase.from('fedex_events').insert({
      transaction_id: tx.id,
      tracking_number: tx.fedex_tracking_number,
      event_type: mapFedExEvent(event.code),
      event_description: event.description,
      event_code: event.code,
      location: event.location,
      location_city: event.city,
      location_country: event.country,
      event_timestamp: event.timestamp,
      raw_payload: event,
    });

    // Update transaction status if needed
    await updateTransactionStatus(tx.id, event);
  }
}
```

### FedEx Track API
```typescript
// In FedExClient
async trackShipment(trackingNumber: string): Promise<TrackingEvent[]> {
  // POST /track/v1/trackingnumbers
}
```

### Event Mapping
```typescript
function mapFedExEvent(fedexCode: string): string {
  const mapping = {
    'PU': 'picked_up',
    'IT': 'in_transit',
    'OD': 'out_for_delivery',
    'DL': 'delivered',
    'DE': 'exception',
    // ... more codes
  };
  return mapping[fedexCode] || 'unknown';
}
```

### Transaction Status Updates
```typescript
async function updateTransactionStatus(txId: string, event: TrackingEvent) {
  const statusMap = {
    'picked_up': 'shipped',
    'in_transit': 'in_transit',
    'delivered': 'delivered',
  };

  const newStatus = statusMap[event.type];
  if (newStatus) {
    await supabase
      .from('marketplace_transactions')
      .update({
        status: newStatus,
        ...(newStatus === 'shipped' && { shipped_at: new Date() }),
        ...(newStatus === 'delivered' && { delivered_at: new Date() }),
      })
      .eq('id', txId);

    // Send notification
    await sendTrackingNotification(txId, newStatus);
  }
}
```

## Definition of Done
- [ ] Edge Function deployee
- [ ] Cron job configure (hourly)
- [ ] Events logges dans fedex_events
- [ ] Transaction status mis a jour
- [ ] Notifications envoyees
- [ ] Tests en sandbox
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (polling, rate limits FedEx)

## Dependances
- S04 (marketplace_transactions)
- S06 (fedex_events)
- S12 (tracking number genere)

## Stories Dependantes
- S22 (tracking colis frontend)
- S23 (notifications marketplace)
