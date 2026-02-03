# S11 - Edge Function: Create Magazine Order

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Backend / Edge Function

---

## Description

Webhook Stripe pour creer la commande de magazine apres paiement reussi. Cree les enregistrements dans magazine_orders et magazine_order_items avec snapshot des photos.

## Dependances

- S03 (magazine_orders tables)
- EPIC-11 (Stripe webhook infrastructure)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine order creation webhook

  Scenario: Successful payment creates order
    Given checkout.session.completed webhook received
    And metadata contains wedding_id, bride_user_id, etc.
    When webhook is processed
    Then magazine_orders should have new row
    And status should be 'paid'
    And paid_at timestamp should be set
    And all amounts should match

  Scenario: Photo snapshots created
    Given photos in magazine_selections for the wedding
    When order is created
    Then magazine_order_items should contain one row per photo
    And each row should have storage_url (snapshot)
    And positions should be preserved

  Scenario: Storage URLs resolved
    Given album_image with id 'img-123'
    When snapshot is created
    Then storage_url should be the actual URL to the file
    And URL should work even if original is deleted later

  Scenario: Selections cleared after order
    Given successful order creation
    When webhook completes
    Then magazine_selections for this wedding should be deleted
    And user starts fresh for next magazine

  Scenario: Push notification sent
    Given order created successfully
    When webhook completes
    Then notification_outbox should have new row
    And event_type = 'magazine_order_confirmed'
    And user receives push "Your magazine order is confirmed!"

  Scenario: Stripe event logged
    Given any webhook received
    When webhook is processed
    Then stripe_events should log the event
    And stripe_event_id should be unique

  Scenario: Idempotency - duplicate webhook
    Given webhook already processed (same stripe_event_id)
    When same webhook arrives again
    Then no duplicate order should be created
    And response should be 200 OK

  Scenario: Webhook signature verification
    Given webhook with invalid signature
    When webhook arrives
    Then response should be 400
    And no order created
```

## Details Techniques

### Edge Function Implementation

```typescript
// supabase/functions/magazine-webhook-v2/index.ts
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);
const webhookSecret = Deno.env.get('STRIPE_MAGAZINE_WEBHOOK_SECRET')!;

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

Deno.serve(async (req) => {
  // 1. Verify signature
  const signature = req.headers.get('stripe-signature')!;
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    console.error('Signature verification failed:', err);
    return new Response('Invalid signature', { status: 400 });
  }

  // 2. Log event for audit
  const { error: logError } = await supabase
    .from('stripe_events')
    .insert({
      stripe_event_id: event.id,
      event_type: event.type,
      payload: event.data.object,
    });

  if (logError?.code === '23505') {
    // Duplicate event (idempotency)
    console.log('Duplicate event, skipping:', event.id);
    return new Response('Already processed', { status: 200 });
  }

  // 3. Only process completed checkout
  if (event.type !== 'checkout.session.completed') {
    return new Response('Event type ignored', { status: 200 });
  }

  const session = event.data.object as Stripe.Checkout.Session;
  const metadata = session.metadata!;

  // 3.5 VALIDATE metadata to prevent injection/IDOR
  const { wedding_id, bride_user_id, photo_count, magazine_price_cents, shipping_cost_cents } = metadata;

  // Verify wedding belongs to bride
  const { data: wedding, error: weddingError } = await supabase
    .from('weddings')
    .select('bride_profile_id')
    .eq('id', wedding_id)
    .single();

  if (weddingError || wedding?.bride_profile_id !== bride_user_id) {
    console.error('Wedding/bride mismatch');
    return new Response('Unauthorized wedding access', { status: 403 });
  }

  // Validate photo_count is reasonable
  const photoCountNum = parseInt(photo_count);
  if (isNaN(photoCountNum) || photoCountNum < 1 || photoCountNum > 100) {
    console.error('Invalid photo count:', photo_count);
    return new Response('Invalid photo count', { status: 400 });
  }

  // Validate amounts match Stripe session
  const expectedTotal = parseInt(magazine_price_cents) + parseInt(shipping_cost_cents);
  if (session.amount_total !== expectedTotal) {
    console.error('Amount mismatch:', { expected: expectedTotal, actual: session.amount_total });
    return new Response('Amount mismatch', { status: 400 });
  }

  // Verify selections exist and match count
  const { data: selectionsCheck, count } = await supabase
    .from('magazine_selections')
    .select('id', { count: 'exact' })
    .eq('wedding_id', wedding_id)
    .eq('user_id', bride_user_id);

  if (!selectionsCheck || count === 0) {
    console.error('No photos in selection');
    return new Response('No photos selected', { status: 400 });
  }

  // 4. Create order
  const { data: order, error: orderError } = await supabase
    .from('magazine_orders')
    .insert({
      wedding_id: metadata.wedding_id,
      bride_user_id: metadata.bride_user_id,
      stripe_checkout_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent as string,
      magazine_price_cents: parseInt(metadata.magazine_price_cents),
      shipping_cost_cents: parseInt(metadata.shipping_cost_cents),
      total_paid_cents: session.amount_total,
      currency: session.currency?.toUpperCase() || 'USD',
      shipping_name: session.shipping_details?.name || '',
      shipping_address_line1: session.shipping_details?.address?.line1 || '',
      shipping_address_line2: session.shipping_details?.address?.line2,
      shipping_city: session.shipping_details?.address?.city || '',
      shipping_zip: session.shipping_details?.address?.postal_code || '',
      shipping_country: session.shipping_details?.address?.country || '',
      magazine_title: metadata.magazine_title,
      magazine_date: metadata.magazine_date || null,
      photo_count: parseInt(metadata.photo_count),
      status: 'paid',
      paid_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (orderError) {
    console.error('Order creation failed:', orderError);
    return new Response('Order creation failed', { status: 500 });
  }

  // 5. Get selections and create order items
  const { data: selections } = await supabase
    .from('magazine_selections')
    .select('*')
    .eq('wedding_id', metadata.wedding_id)
    .eq('user_id', metadata.bride_user_id)
    .order('position');

  const orderItems = [];
  for (const sel of selections || []) {
    let storageUrl = '';

    // Get actual storage URL based on media type
    if (sel.media_type === 'album_image') {
      const { data: img } = await supabase
        .from('album_images')
        .select('image_url')
        .eq('id', sel.media_id)
        .single();
      storageUrl = img?.image_url || '';
    } else if (sel.media_type === 'guest_media') {
      const { data: media } = await supabase
        .from('guest_media')
        .select('storage_path')
        .eq('id', sel.media_id)
        .single();

      // Generate signed URL for guest media
      if (media?.storage_path) {
        const { data: urlData } = await supabase.storage
          .from('wedding-media')
          .createSignedUrl(media.storage_path, 60 * 60 * 24 * 365); // 1 year
        storageUrl = urlData?.signedUrl || media.storage_path;
      }
    }

    orderItems.push({
      order_id: order.id,
      media_type: sel.media_type,
      media_id: sel.media_id,
      position: sel.position,
      storage_url: storageUrl,
    });
  }

  // Insert all order items
  const { error: itemsError } = await supabase
    .from('magazine_order_items')
    .insert(orderItems);

  if (itemsError) {
    console.error('Order items creation failed:', itemsError);
    // Order already created, log error but don't fail
  }

  // 6. Clear selections
  await supabase
    .from('magazine_selections')
    .delete()
    .eq('wedding_id', metadata.wedding_id)
    .eq('user_id', metadata.bride_user_id);

  // 7. Send push notification
  await supabase.from('notifications_outbox').insert({
    event_type: 'magazine_order_confirmed',
    payload: {
      user_id: metadata.bride_user_id,
      order_id: order.id,
      title: 'Magazine Order Confirmed!',
      body: 'Your wedding magazine is being prepared.',
    },
  });

  // 8. Mark stripe event as processed
  await supabase
    .from('stripe_events')
    .update({ processed: true, processed_at: new Date().toISOString() })
    .eq('stripe_event_id', event.id);

  return new Response(JSON.stringify({ success: true, order_id: order.id }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' },
  });
});
```

### Stripe Webhook Setup

```bash
# Configure webhook in Stripe Dashboard or CLI
stripe listen --forward-to https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/magazine-webhook-v2

# Events to listen:
# - checkout.session.completed
```

### Fichiers a Creer

| Fichier | Action |
|---------|--------|
| `supabase/functions/magazine-webhook-v2/index.ts` | Nouveau |
| `supabase/functions/create-magazine-checkout/index.ts` | Nouveau (S10) |

## Tests

- [ ] Signature verification fonctionne
- [ ] Order cree avec tous les champs
- [ ] Order items avec storage URLs
- [ ] Selections effacees apres order
- [ ] Push notification envoyee
- [ ] Stripe event logged
- [ ] Idempotency (pas de doublon)
- [ ] Error handling robuste

## Notes

- Signed URLs pour guest_media (1 an de validite)
- Idempotency via stripe_event_id UNIQUE constraint
- Selections effacees = fresh start pour prochain magazine
- Admin (Thierry) voit les orders via service_role dans CRM
