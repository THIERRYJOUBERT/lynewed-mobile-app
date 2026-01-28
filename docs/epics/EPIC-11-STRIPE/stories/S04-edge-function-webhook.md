# Story S04: Creer Edge Function stripe-webhook avec signature verification

## Description
En tant que developpeur, je veux creer l'Edge Function `stripe-webhook` qui recoit tous les webhooks Stripe, verifie la signature, log les events et dispatch aux handlers, afin d'avoir un point d'entree securise pour tous les events Stripe.

## Criteres d'Acceptance (Gherkin)

- [ ] Given une requete webhook avec signature Stripe valide When la fonction est appelee Then elle retourne HTTP 200 et l'event est logge dans stripe_events
- [ ] Given une requete webhook avec signature invalide When la fonction est appelee Then elle retourne HTTP 400 et aucun event n'est logge
- [ ] Given une requete webhook sans header stripe-signature When la fonction est appelee Then elle retourne HTTP 400
- [ ] Given un event deja traite (processed=true) When le meme event est recu Then la fonction retourne HTTP 200 sans re-traiter
- [ ] Given un event non traite When la fonction le traite avec succes Then processed=true et processed_at est mis a jour
- [ ] Given une erreur de traitement When la fonction echoue Then elle retourne HTTP 500 et processing_attempts est incremente
- [ ] Given processing_attempts >= 5 When la fonction echoue Then elle retourne HTTP 200 (stop retries) et notifie l'admin
- [ ] Given un event quelconque When il est recu Then il est TOUJOURS logge dans stripe_events (meme si handler echoue)
- [ ] Given les secrets Stripe When la fonction demarre Then STRIPE_SECRET_KEY et STRIPE_WEBHOOK_SECRET sont disponibles

## Fichiers Concernes

### A Creer
- `supabase/functions/stripe-webhook/index.ts`
- `supabase/functions/stripe-webhook/deno.json`

### A Modifier
- Aucun

## Notes Techniques

### Structure Edge Function

```typescript
// supabase/functions/stripe-webhook/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@14";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-12-18.acacia",
});

const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;

Deno.serve(async (req: Request) => {
  // 1. Verify signature
  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Missing signature", { status: 400 });
  }

  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return new Response("Invalid signature", { status: 400 });
  }

  // 2. Create Supabase client with service_role
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 3. Log event for audit (idempotent - UPSERT)
  const { error: logError } = await supabase
    .from("stripe_events")
    .upsert({
      stripe_event_id: event.id,
      event_type: event.type,
      api_version: event.api_version,
      payload: event.data.object,
      livemode: event.livemode,
      stripe_created_at: new Date(event.created * 1000).toISOString(),
    }, { onConflict: "stripe_event_id" });

  if (logError) {
    console.error("Failed to log event:", logError);
  }

  // 4. Check if already processed (idempotency)
  const { data: existing } = await supabase
    .from("stripe_events")
    .select("processed")
    .eq("stripe_event_id", event.id)
    .single();

  if (existing?.processed) {
    return new Response("Already processed", { status: 200 });
  }

  // 5. Process by event type (handlers in future stories)
  try {
    await processEvent(supabase, event);

    // 6. Mark as processed
    await supabase
      .from("stripe_events")
      .update({
        processed: true,
        processed_at: new Date().toISOString()
      })
      .eq("stripe_event_id", event.id);

  } catch (err) {
    // Error handling with retry logic...
    return handleProcessingError(supabase, event, err);
  }

  return new Response("OK", { status: 200 });
});

async function processEvent(supabase: any, event: Stripe.Event) {
  // Stub - handlers implemented in S05-S10
  console.log(`Processing event: ${event.type}`);
}

async function handleProcessingError(supabase: any, event: Stripe.Event, err: Error) {
  const { data: eventData } = await supabase
    .from("stripe_events")
    .select("processing_attempts")
    .eq("stripe_event_id", event.id)
    .single();

  const attempts = (eventData?.processing_attempts || 0) + 1;
  const MAX_ATTEMPTS = 5;

  await supabase
    .from("stripe_events")
    .update({
      error_message: err.message,
      processing_attempts: attempts,
    })
    .eq("stripe_event_id", event.id);

  if (attempts >= MAX_ATTEMPTS) {
    console.error(`ALERT: Webhook ${event.id} failed after ${MAX_ATTEMPTS} attempts`);
    await supabase.from("notifications_outbox").insert({
      event_type: "webhook_dead_letter",
      payload: {
        event_id: event.id,
        event_type: event.type,
        error: err.message,
        attempts: attempts
      },
      recipient_id: null
    });
    return new Response("Max retries reached", { status: 200 });
  }

  return new Response("Processing error", { status: 500 });
}
```

### Configuration deno.json

```json
{
  "imports": {
    "stripe": "npm:stripe@14"
  }
}
```

### Secrets Requis

- `STRIPE_SECRET_KEY` : Cle API Stripe
- `STRIPE_WEBHOOK_SECRET` : Secret du webhook endpoint (whsec_...)
- `SUPABASE_URL` : Auto-disponible
- `SUPABASE_SERVICE_ROLE_KEY` : Auto-disponible

### Securite

- **Signature verification** : OBLIGATOIRE avant tout traitement
- **Service role** : Pour bypass RLS sur stripe_events
- **Idempotency** : Meme event traite une seule fois
- **Dead letter** : Notification admin apres 5 echecs

## Definition of Done

- [ ] Edge Function creee et deployee
- [ ] Signature verification fonctionnelle
- [ ] Logging dans stripe_events fonctionne
- [ ] Idempotency testee (meme event 2x)
- [ ] Error handling avec retry logic
- [ ] Dead letter notification implementee
- [ ] Secrets configures dans Supabase
- [ ] Tests manuels avec Stripe CLI (stripe trigger)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Moyen (securite critique)

## Dependances

- S01: stripe_accounts (table doit exister)
- S02: purchases (table doit exister)
- S03: stripe_events (table doit exister pour logging)

## Stories Dependantes

- S05: Handlers payment_intent.*
- S06: Handlers checkout.session.*
- S07: Handler account.updated
- S08: Handlers charge.dispute.*
- S09: Handlers payout.*
- S10: Handlers transfers + refunds
