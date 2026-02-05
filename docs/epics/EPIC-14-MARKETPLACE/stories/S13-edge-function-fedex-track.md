# Story S13: Edge Function FedEx Track API

## Description
En tant qu'acheteuse, je veux suivre mon colis en temps reel, afin de savoir quand il sera livre.

## Prerequisites

- [ ] Story S04 COMPLETE - Table `marketplace_transactions` exists
- [ ] Story S06 COMPLETE - Table `fedex_events` exists
- [ ] Story S12 COMPLETE - Tracking numbers generated
- [ ] Story S11 COMPLETE - FedExClient with `trackShipment()` method
- [ ] Supabase extensions enabled:
  - `pg_cron` (for scheduled jobs)
  - `pg_net` (for HTTP requests from Postgres)
- [ ] Existing notification system: table `notifications_outbox` + Edge Function `notifications_outbox_drain`

## Criteres d'Acceptance (Gherkin)

- [ ] Given a shipped transaction with tracking number When FedEx reports package is in transit Then transaction status should update to 'in_transit' And fedex_events should log the event And buyer should receive notification
- [ ] Given a package out for delivery When FedEx confirms delivery Then transaction status should be 'delivered' And both buyer and seller should be notified And 7-day countdown for completion starts
- [ ] Given multiple tracking events When polling FedEx Track API Then all new events should be logged in chronological order
- [ ] Given a tracking number When querying track status Then all events with location, timestamp, and description should be returned

## Files to Create/Modify

### CREATE

```
supabase/functions/
├── fedex-track-shipment/
│   └── index.ts                                     # Edge Function (manual trigger or cron)
└── migrations/
    └── 20260204000003_setup_fedex_tracking_cron.sql # pg_cron setup

lib/features/marketplace/
├── domain/
│   ├── entities/
│   │   └── tracking_event.dart                      # Entity
│   └── usecases/
│       └── get_tracking_events.dart                 # Use case
├── data/
│   ├── models/
│   │   └── tracking_event_model.dart                # Data model
│   └── datasources/
│       └── fedex_remote_datasource.dart             # Add tracking method (MODIFY)
└── presentation/
    └── widgets/
        └── tracking_timeline_widget.dart            # Timeline UI

test/features/marketplace/
├── domain/usecases/
│   └── get_tracking_events_test.dart
└── presentation/widgets/
    └── tracking_timeline_widget_test.dart
```

### MODIFY

- `supabase/functions/_shared/fedex-client.ts` - Already has `trackShipment()` method (S11)
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart` - Add tracking

## Cron Setup Migration

`supabase/migrations/20260204000003_setup_fedex_tracking_cron.sql`:

```sql
-- EPIC-14 S13: FedEx Tracking Cron Job
-- Polls FedEx API every hour to update tracking events

-- Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Grant permissions
GRANT USAGE ON SCHEMA cron TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA cron TO postgres;

-- Enable pg_net extension for HTTP requests
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Schedule: Every hour
-- Calls fedex-track-shipment Edge Function
SELECT cron.schedule(
  'fedex-tracking-poll',
  '0 * * * *', -- Every hour at minute 0
  $$
  SELECT
    net.http_post(
      url := 'https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/fedex-track-shipment',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
      ),
      body := jsonb_build_object('mode', 'cron')
    )
  $$
);

-- View scheduled jobs
-- SELECT * FROM cron.job;

-- To unschedule (for testing):
-- SELECT cron.unschedule('fedex-tracking-poll');
```

**IMPORTANT**: The `service_role_key` must be set as a Postgres setting:
```sql
-- Run this once (in Supabase SQL Editor)
ALTER DATABASE postgres SET app.settings.service_role_key TO 'your_service_role_key_here';
```

Alternative: Store service role key in a Postgres table with RLS to protect it.

## Edge Function: fedex-track-shipment

`supabase/functions/fedex-track-shipment/index.ts`:

```typescript
// EPIC-14 S13: FedEx Tracking Poller
// Polls FedEx for tracking updates and logs events
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient } from "../_shared/fedex-client.ts";

interface TrackRequest {
  mode: 'cron' | 'manual';
  tracking_number?: string; // Optional: track specific shipment
}

// Map FedEx event codes to internal event types
function mapFedExEvent(fedexCode: string): string {
  const mapping: Record<string, string> = {
    'PU': 'picked_up',
    'IT': 'in_transit',
    'AR': 'arrived_at_facility',
    'DP': 'departed_facility',
    'OD': 'out_for_delivery',
    'DL': 'delivered',
    'DE': 'delivery_exception',
    'CA': 'cancelled',
    'RS': 'return_to_shipper',
    'OC': 'shipment_created',
  };
  return mapping[fedexCode] || 'unknown';
}

// Determine transaction status from event type
function getTransactionStatus(eventType: string): string | null {
  const statusMapping: Record<string, string> = {
    'picked_up': 'shipped',
    'in_transit': 'in_transit',
    'out_for_delivery': 'out_for_delivery',
    'delivered': 'delivered',
    'delivery_exception': 'exception',
  };
  return statusMapping[eventType] || null;
}

async function trackAndUpdateTransaction(
  supabase: any,
  fedex: FedExClient,
  transaction: any
): Promise<{ success: boolean; newEventsCount: number }> {
  try {
    console.log(`Tracking shipment for transaction ${transaction.id}, tracking: ${transaction.fedex_tracking_number}`);

    // Get tracking events from FedEx
    const events = await fedex.trackShipment(transaction.fedex_tracking_number);

    if (events.length === 0) {
      console.log(`No events found for tracking ${transaction.fedex_tracking_number}`);
      return { success: true, newEventsCount: 0 };
    }

    // Get last logged event timestamp
    const { data: lastEvent } = await supabase
      .from('fedex_events')
      .select('event_timestamp')
      .eq('transaction_id', transaction.id)
      .order('event_timestamp', { ascending: false })
      .limit(1)
      .maybeSingle();

    // Filter new events only
    const newEvents = lastEvent
      ? events.filter(e => new Date(e.timestamp) > new Date(lastEvent.event_timestamp))
      : events;

    if (newEvents.length === 0) {
      console.log(`No new events for transaction ${transaction.id}`);
      return { success: true, newEventsCount: 0 };
    }

    console.log(`Found ${newEvents.length} new events for transaction ${transaction.id}`);

    // Insert new events
    let latestStatus: string | null = null;
    for (const event of newEvents) {
      const eventType = mapFedExEvent(event.code);

      await supabase.from('fedex_events').insert({
        transaction_id: transaction.id,
        tracking_number: transaction.fedex_tracking_number,
        event_type: eventType,
        event_description: event.description,
        event_code: event.code,
        location: event.location,
        location_city: event.city,
        location_country: event.country,
        event_timestamp: event.timestamp,
        raw_payload: event,
        created_at: new Date().toISOString(),
      });

      // Determine if this event should update transaction status
      const newStatus = getTransactionStatus(eventType);
      if (newStatus) {
        latestStatus = newStatus;
      }
    }

    // Update transaction status if changed
    if (latestStatus && latestStatus !== transaction.status) {
      console.log(`Updating transaction ${transaction.id} status to ${latestStatus}`);

      const updateData: any = {
        status: latestStatus,
        updated_at: new Date().toISOString(),
      };

      // Set timestamps for specific statuses
      if (latestStatus === 'shipped') {
        updateData.shipped_at = new Date().toISOString();
      } else if (latestStatus === 'delivered') {
        updateData.delivered_at = new Date().toISOString();
      }

      await supabase
        .from('marketplace_transactions')
        .update(updateData)
        .eq('id', transaction.id);

      // Send notifications
      await sendTrackingNotification(supabase, transaction, latestStatus);
    }

    return { success: true, newEventsCount: newEvents.length };
  } catch (error) {
    console.error(`Error tracking transaction ${transaction.id}:`, error);
    return { success: false, newEventsCount: 0 };
  }
}

async function sendTrackingNotification(
  supabase: any,
  transaction: any,
  status: string
): Promise<void> {
  const notificationMessages: Record<string, { title: string; body: string }> = {
    'shipped': {
      title: 'Package Shipped',
      body: 'Your package has been picked up and is on its way!',
    },
    'in_transit': {
      title: 'Package in Transit',
      body: 'Your package is moving through the FedEx network.',
    },
    'out_for_delivery': {
      title: 'Out for Delivery',
      body: 'Your package is out for delivery today!',
    },
    'delivered': {
      title: 'Package Delivered',
      body: 'Your package has been delivered. Enjoy!',
    },
    'exception': {
      title: 'Delivery Exception',
      body: 'There was an issue with your delivery. Check tracking for details.',
    },
  };

  const message = notificationMessages[status];
  if (!message) return;

  // Notify buyer
  await supabase.from('notifications_outbox').insert({
    user_id: transaction.buyer_id,
    notification_type: 'marketplace_tracking_update',
    title: message.title,
    body: message.body,
    data: {
      transaction_id: transaction.id,
      tracking_number: transaction.fedex_tracking_number,
      status,
    },
    created_at: new Date().toISOString(),
  });

  // Notify seller for delivered status
  if (status === 'delivered') {
    await supabase.from('notifications_outbox').insert({
      user_id: transaction.seller_id,
      notification_type: 'marketplace_tracking_update',
      title: 'Package Delivered',
      body: 'Your package was successfully delivered to the buyer.',
      data: {
        transaction_id: transaction.id,
        tracking_number: transaction.fedex_tracking_number,
        status,
      },
      created_at: new Date().toISOString(),
    });
  }
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    // Verify authorization
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Parse request
    const body: TrackRequest = await req.json();

    // Use service role for database operations
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Initialize FedEx client
    const fedex = new FedExClient({
      clientId: Deno.env.get('FEDEX_CLIENT_ID')!,
      clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!,
      accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!,
      environment: (Deno.env.get('FEDEX_ENV') || 'sandbox') as 'sandbox' | 'production',
    });

    // Determine which transactions to track
    let transactions;

    if (body.tracking_number) {
      // Manual mode: track specific shipment
      const { data } = await supabase
        .from('marketplace_transactions')
        .select('id, fedex_tracking_number, status, buyer_id, seller_id')
        .eq('fedex_tracking_number', body.tracking_number)
        .single();

      transactions = data ? [data] : [];
    } else {
      // Cron mode: track all active shipments
      const { data } = await supabase
        .from('marketplace_transactions')
        .select('id, fedex_tracking_number, status, buyer_id, seller_id')
        .in('status', ['shipped', 'in_transit', 'out_for_delivery', 'label_created'])
        .not('fedex_tracking_number', 'is', null);

      transactions = data || [];
    }

    console.log(`Tracking ${transactions.length} transactions...`);

    // Track each transaction
    const results = [];
    for (const tx of transactions) {
      const result = await trackAndUpdateTransaction(supabase, fedex, tx);
      results.push({
        transaction_id: tx.id,
        ...result,
      });

      // Graceful degradation: don't fail entire batch if one fails
      if (!result.success) {
        console.error(`Failed to track transaction ${tx.id}, continuing...`);
      }
    }

    const totalNewEvents = results.reduce((sum, r) => sum + r.newEventsCount, 0);
    const successCount = results.filter(r => r.success).length;

    console.log(`Tracking complete: ${successCount}/${transactions.length} successful, ${totalNewEvents} new events`);

    return new Response(
      JSON.stringify({
        tracked: transactions.length,
        successful: successCount,
        total_new_events: totalNewEvents,
        results,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error tracking shipments:", error);

    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});
```

## FedEx Event Codes (Top 15)

| Code | Event Type | Description | Transaction Status |
|------|-----------|-------------|-------------------|
| `OC` | `shipment_created` | Shipment information sent to FedEx | `label_created` |
| `PU` | `picked_up` | Package picked up by FedEx | `shipped` |
| `IT` | `in_transit` | Package in transit | `in_transit` |
| `AR` | `arrived_at_facility` | Arrived at FedEx facility | `in_transit` |
| `DP` | `departed_facility` | Departed FedEx facility | `in_transit` |
| `OD` | `out_for_delivery` | Out for delivery | `out_for_delivery` |
| `DL` | `delivered` | Delivered | `delivered` |
| `DE` | `delivery_exception` | Delivery exception (delay, address issue) | `exception` |
| `CA` | `cancelled` | Shipment cancelled | `cancelled` |
| `RS` | `return_to_shipper` | Returning to shipper | `return` |
| `AO` | `at_local_facility` | At local FedEx facility | `in_transit` |
| `OX` | `shipment_exception` | Shipment exception (weather, etc.) | `exception` |
| `CD` | `clearance_delay` | Customs clearance delay | `in_transit` |
| `BR` | `broker_release` | Released by customs broker | `in_transit` |
| `AF` | `at_fedex_destination` | At destination FedEx facility | `out_for_delivery` |

## Design System Integration

### Widgets to Use

```dart
import '/core/design/design.dart';

// Use:
// - LynewedColors for timeline dots (status colors)
// - LynewedTextStyles for event descriptions
// - LynewedIconButton for refresh tracking
// - Timeline widget pattern for events
```

### Tracking Timeline Widget

`lib/features/marketplace/presentation/widgets/tracking_timeline_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '../../domain/entities/tracking_event.dart';

class TrackingTimelineWidget extends StatelessWidget {
  final List<TrackingEvent> events;
  final VoidCallback? onRefresh;

  const TrackingTimelineWidget({
    required this.events,
    this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: LynewedSpacing.lg),
            Text(
              'No Tracking Events Yet',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tracking History',
              style: LynewedTextStyles.titleMedium,
            ),
            if (onRefresh != null)
              LynewedIconButton(
                icon: Icons.refresh,
                onPressed: onRefresh,
              ),
          ],
        ),
        const SizedBox(height: LynewedSpacing.lg),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;
          return _buildTimelineItem(event, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(TrackingEvent event, bool isLast) {
    final color = _getEventColor(event.eventType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: LynewedColors.gray300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Event details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (event.location != null)
                    Text(
                      event.location!,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(event.timestamp),
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'delivered':
        return LynewedColors.success;
      case 'out_for_delivery':
        return LynewedColors.primary;
      case 'in_transit':
      case 'picked_up':
        return LynewedColors.info;
      case 'delivery_exception':
      case 'exception':
        return LynewedColors.error;
      default:
        return LynewedColors.gray300;
    }
  }
}
```

## Tests Required

### Unit Tests

```dart
// test/features/marketplace/domain/usecases/get_tracking_events_test.dart
group('GetTrackingEventsUseCase', () {
  test('calls repository to get events for tracking number', () async {
    // Arrange: mock repository
    // Act: call use case
    // Assert: repository called with tracking_number
  });

  test('returns events sorted by timestamp', () async {
    // Arrange: mock returns unsorted events
    // Act: call use case
    // Assert: events sorted chronologically
  });
});
```

### Widget Tests

```dart
// test/features/marketplace/presentation/widgets/tracking_timeline_widget_test.dart
group('TrackingTimelineWidget', () {
  testWidgets('displays empty state when no events', (tester) async {
    // Arrange & Act: pump widget with empty list
    // Assert: empty state message shown
  });

  testWidgets('displays timeline with all events', (tester) async {
    // Arrange: list of events
    // Act: pump widget
    // Assert: all events visible in timeline
  });

  testWidgets('uses correct colors for event types', (tester) async {
    // Arrange: events with different types
    // Act: pump widget
    // Assert: colors match event types (delivered=green, exception=red, etc.)
  });
});
```

## Error Handling

| Error | Code | User Message | Retry? |
|-------|------|-------------|--------|
| Tracking not found | `not_found` | "Tracking information not available yet." | Yes (later) |
| FedEx API error | `fedex_error` | "Error fetching tracking. Please try again." | Yes |
| Timeout | `timeout` | "Request timeout. Please try again." | Yes |
| Rate limit | `rate_limit` | "Too many requests. Please wait a moment." | Yes (after delay) |
| Invalid tracking number | `invalid_tracking` | "Invalid tracking number." | No |

## Polling Interval

**Recommended**: 1 hour (compromise between cost and UX)

- More frequent = higher API costs + rate limit risk
- Less frequent = delayed updates for buyers

**Alternatives**:
- Every 30 minutes (more expensive, better UX)
- Every 2 hours (cheaper, acceptable for non-urgent shipments)

## Graceful Degradation

If tracking fails for one transaction:
1. Log the error
2. Continue tracking other transactions
3. Don't fail the entire batch
4. Retry on next cycle (1 hour later)

This ensures one bad tracking number doesn't break tracking for all shipments.

## Definition of Done

- [ ] Edge Function `fedex-track-shipment` deployed
- [ ] pg_cron extension enabled and configured
- [ ] Cron job scheduled (every hour)
- [ ] Service role key configured in Postgres settings
- [ ] FedExClient `trackShipment()` works correctly (from S11)
- [ ] Events logged in `fedex_events` with correct mapping
- [ ] Transaction status updated based on events
- [ ] Notifications sent to buyer/seller via `notifications_outbox`
- [ ] Graceful degradation: errors logged, batch continues
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] `flutter analyze --fatal-infos` passes
- [ ] Tested with sandbox tracking numbers

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (polling, rate limits FedEx, cron configuration)

## Dependances

### Requires
- S04 COMPLETE (table `marketplace_transactions`)
- S06 COMPLETE (table `fedex_events`)
- S12 COMPLETE (tracking numbers generated)
- S11 COMPLETE (FedExClient with `trackShipment()`)
- EPIC-06 COMPLETE (notifications_outbox system)
- Supabase extensions: `pg_cron`, `pg_net`

### Provides
- Automated tracking updates for marketplace shipments
- Real-time status for buyers and sellers

### Blocks
- S22 (tracking frontend - consumes tracking events)
- S23 (marketplace notifications - triggered by tracking events)

## Stories Dependantes
- S22 (tracking colis frontend)
- S23 (notifications marketplace)

## Notes

### Supabase pg_cron Setup

**Enable extension:**
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;
```

**View scheduled jobs:**
```sql
SELECT * FROM cron.job;
```

**View job run history:**
```sql
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
```

**Unschedule (for testing):**
```sql
SELECT cron.unschedule('fedex-tracking-poll');
```

### Alternative: External Cron

If pg_cron is not available, use an external cron service (e.g., GitHub Actions, AWS Lambda) to call the Edge Function every hour:

```bash
curl -X POST \
  https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/fedex-track-shipment \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{"mode": "cron"}'
```

### Cost Considerations

**FedEx Track API:**
- Free for reasonable usage (~100 requests/hour)
- Rate limits apply

**Supabase:**
- pg_cron runs are free
- Edge Function invocations: free tier allows 500K/month

With 100 active shipments and hourly polling, that's ~2400 invocations/day = ~72K/month (well within limits).

### 7-Day Completion Window

When status = `delivered`, the buyer has 7 days to confirm receipt or report issues. After 7 days, the transaction auto-completes. This logic is in a future story (S20 or S24).

### Manual Tracking (Future Enhancement)

The Edge Function supports manual tracking via `tracking_number` parameter. This allows sellers/buyers to manually refresh tracking in the app:

```typescript
{
  "mode": "manual",
  "tracking_number": "123456789"
}
```
