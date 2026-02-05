# Story S12: Edge Function FedEx Ship API

## Description
En tant que vendeur, je veux generer une etiquette d'expedition FedEx, afin d'envoyer l'article vendu a l'acheteuse.

## Prerequisites

- [ ] Story S04 COMPLETE - Table `marketplace_transactions` exists (verify via MCP list_tables)
- [ ] Story S06 COMPLETE - Table `fedex_events` exists (verify via MCP list_tables)
- [ ] Story S11 COMPLETE - Shared FedExClient deployed in `_shared/fedex-client.ts`
- [ ] Supabase Storage bucket `marketplace-labels` created (verify via MCP or create in this story)
- [ ] Existing notification system: table `notifications_outbox` + Edge Function `notifications_outbox_drain`
- [ ] FedEx credentials configured in Supabase Secrets

## Criteres d'Acceptance (Gherkin)

- [ ] Given a paid transaction with validated addresses When seller requests label generation Then FedEx Ship API should return tracking_number and label_url (PDF)
- [ ] Given successful label generation Then transaction should be updated with fedex_tracking_number and fedex_label_url
- [ ] Given successful label generation Then fedex_events should log 'label_created' event with full payload
- [ ] Given successful label generation Then email should be sent to seller with PDF link via notifications_outbox
- [ ] Given a network error with FedEx When label generation is attempted Then error should be logged And seller should see retry option

## Files to Create/Modify

### CREATE

```
supabase/functions/
├── fedex-create-shipment/
│   └── index.ts                                     # Edge Function (NEW)
└── migrations/
    └── 20260204000002_create_marketplace_labels_bucket.sql  # Storage bucket (if not exists)

lib/features/marketplace/
├── domain/
│   ├── entities/
│   │   └── shipping_label.dart                      # Entity
│   └── usecases/
│       └── generate_shipping_label.dart             # Use case
├── data/
│   ├── models/
│   │   └── shipping_label_model.dart                # Data model
│   └── datasources/
│       └── fedex_remote_datasource.dart             # Add label generation method (MODIFY)
└── presentation/
    └── widgets/
        └── shipping_label_widget.dart               # Display PDF + download

test/features/marketplace/
├── domain/usecases/
│   └── generate_shipping_label_test.dart
└── presentation/widgets/
    └── shipping_label_widget_test.dart
```

### MODIFY

- `supabase/functions/_shared/fedex-client.ts` - Already has `createShipment()` method (S11)
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart` - Add label generation
- `lib/core/di/injection_container.dart` - Add label use case

## Storage Bucket Migration

`supabase/migrations/20260204000002_create_marketplace_labels_bucket.sql`:

```sql
-- EPIC-14 S12: Marketplace Labels Storage Bucket
-- Stores FedEx shipping labels (PDFs)

-- Create bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('marketplace-labels', 'marketplace-labels', false)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies
-- Sellers can read their own labels
CREATE POLICY "Sellers can read own labels"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'marketplace-labels' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Service role can insert labels (via Edge Function)
-- No direct INSERT policy for users
```

## Edge Function: fedex-create-shipment

`supabase/functions/fedex-create-shipment/index.ts`:

```typescript
// EPIC-14 S12: Generate FedEx Shipping Label
// Creates shipment, uploads label to Storage, logs event, sends email
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient } from "../_shared/fedex-client.ts";

interface CreateShipmentRequest {
  transaction_id: string;
  service_type: string; // e.g., 'FEDEX_GROUND', 'FEDEX_2_DAY'
}

// Package details by category
const PACKAGE_DETAILS_BY_CATEGORY: Record<string, { weight: { units: 'KG'; value: number }; dimensions: { units: 'CM'; length: number; width: number; height: number } }> = {
  dress: {
    weight: { units: 'KG', value: 3 },
    dimensions: { units: 'CM', length: 60, width: 40, height: 20 },
  },
  shoes: {
    weight: { units: 'KG', value: 2 },
    dimensions: { units: 'CM', length: 35, width: 25, height: 15 },
  },
  accessories: {
    weight: { units: 'KG', value: 1 },
    dimensions: { units: 'CM', length: 30, width: 20, height: 10 },
  },
  decoration: {
    weight: { units: 'KG', value: 5 },
    dimensions: { units: 'CM', length: 50, width: 50, height: 30 },
  },
  other: {
    weight: { units: 'KG', value: 3 },
    dimensions: { units: 'CM', length: 40, width: 30, height: 20 },
  },
};

function getPackageDetails(category: string) {
  return PACKAGE_DETAILS_BY_CATEGORY[category] || PACKAGE_DETAILS_BY_CATEGORY.other;
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

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    // Verify user
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Parse request
    const body: CreateShipmentRequest = await req.json();

    if (!body.transaction_id || !body.service_type) {
      return new Response(JSON.stringify({ error: "Missing transaction_id or service_type" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Use service role for database operations
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // 1. Get transaction with addresses and listing details
    console.log(`Fetching transaction ${body.transaction_id}...`);
    const { data: transaction, error: txError } = await supabaseAdmin
      .from('marketplace_transactions')
      .select(`
        id,
        seller_id,
        buyer_id,
        shipping_from_address,
        shipping_to_address,
        status,
        listing:marketplace_listings(
          id,
          title,
          category,
          seller:profiles(id, email, display_name)
        )
      `)
      .eq('id', body.transaction_id)
      .single();

    if (txError || !transaction) {
      console.error('Transaction not found:', txError);
      return new Response(JSON.stringify({ error: "Transaction not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Security: verify user is the seller
    if (transaction.seller_id !== user.id) {
      return new Response(JSON.stringify({ error: "Only seller can generate label" }), {
        status: 403,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Check transaction status (must be paid)
    if (transaction.status !== 'paid' && transaction.status !== 'label_created') {
      return new Response(
        JSON.stringify({ error: `Cannot generate label for transaction with status: ${transaction.status}` }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // 2. Initialize FedEx client
    const fedex = new FedExClient({
      clientId: Deno.env.get('FEDEX_CLIENT_ID')!,
      clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!,
      accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!,
      environment: (Deno.env.get('FEDEX_ENV') || 'sandbox') as 'sandbox' | 'production',
    });

    // 3. Get package details based on category
    const category = transaction.listing?.category || 'other';
    const packageDetails = getPackageDetails(category);

    console.log(`Creating shipment with service ${body.service_type}, category ${category}...`);

    // 4. Create shipment with FedEx
    const shipment = await fedex.createShipment({
      shipper: {
        ...transaction.shipping_from_address,
        personName: transaction.listing?.seller?.display_name || 'Seller',
        phoneNumber: '0000000000', // TODO: Get from seller profile
      },
      recipient: {
        ...transaction.shipping_to_address,
        personName: 'Buyer', // TODO: Get from buyer profile
        phoneNumber: '0000000000', // TODO: Get from buyer profile
      },
      serviceType: body.service_type,
      packageDetails,
      referenceId: transaction.id, // Link to transaction
    });

    console.log(`Shipment created with tracking number: ${shipment.trackingNumber}`);

    // 5. Upload label to Supabase Storage
    const labelFileName = `${user.id}/${transaction.id}_${shipment.trackingNumber}.pdf`;
    const labelBuffer = Uint8Array.from(atob(shipment.labelBase64!), c => c.charCodeAt(0));

    const { error: uploadError } = await supabaseAdmin.storage
      .from('marketplace-labels')
      .upload(labelFileName, labelBuffer, {
        contentType: 'application/pdf',
        upsert: true,
      });

    if (uploadError) {
      console.error('Error uploading label to Storage:', uploadError);
      throw new Error(`Failed to upload label: ${uploadError.message}`);
    }

    // Get public URL (signed URL for private bucket)
    const { data: urlData } = await supabaseAdmin.storage
      .from('marketplace-labels')
      .createSignedUrl(labelFileName, 60 * 60 * 24 * 7); // 7 days

    const labelUrl = urlData?.signedUrl || '';

    console.log(`Label uploaded to Storage: ${labelFileName}`);

    // 6. Update transaction
    const { error: updateError } = await supabaseAdmin
      .from('marketplace_transactions')
      .update({
        fedex_tracking_number: shipment.trackingNumber,
        fedex_label_url: labelUrl,
        status: 'label_created',
        updated_at: new Date().toISOString(),
      })
      .eq('id', body.transaction_id);

    if (updateError) {
      console.error('Error updating transaction:', updateError);
      // Don't fail - label was created successfully
    }

    // 7. Log event in fedex_events
    const { error: eventError } = await supabaseAdmin
      .from('fedex_events')
      .insert({
        transaction_id: body.transaction_id,
        tracking_number: shipment.trackingNumber,
        event_type: 'label_created',
        event_description: 'Shipping label generated',
        event_timestamp: new Date().toISOString(),
        raw_payload: shipment.rawResponse,
      });

    if (eventError) {
      console.error('Error logging fedex_events:', eventError);
      // Don't fail - label was created successfully
    }

    // 8. Send email notification to seller via notifications_outbox
    const { error: notifError } = await supabaseAdmin
      .from('notifications_outbox')
      .insert({
        user_id: transaction.seller_id,
        notification_type: 'marketplace_label_ready',
        title: 'Shipping Label Ready',
        body: `Your shipping label for "${transaction.listing?.title}" is ready to download.`,
        data: {
          transaction_id: transaction.id,
          tracking_number: shipment.trackingNumber,
          label_url: labelUrl,
        },
        created_at: new Date().toISOString(),
      });

    if (notifError) {
      console.error('Error creating notification:', notifError);
      // Don't fail - label was created successfully
    }

    console.log(`Label generation complete for transaction ${body.transaction_id}`);

    return new Response(
      JSON.stringify({
        tracking_number: shipment.trackingNumber,
        label_url: labelUrl,
        service_type: body.service_type,
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
    console.error("Error creating shipment:", error);

    // Friendly error messages
    let errorMessage = (error as Error).message;
    if (errorMessage.includes('timeout')) {
      errorMessage = 'Request timeout. Please try again.';
    } else if (errorMessage.includes('rate_limit')) {
      errorMessage = 'Too many requests. Please wait a moment.';
    } else if (errorMessage.includes('address')) {
      errorMessage = 'Invalid shipping address. Please verify addresses.';
    }

    return new Response(
      JSON.stringify({ error: errorMessage }),
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

## Design System Integration

### Widgets to Use

```dart
import '/core/design/design.dart';

// Use:
// - LynewedButton for "Generate Label" / "Download Label"
// - LynewedColors for status indicators
// - LynewedTextStyles for tracking number display
// - LynewedIconButton for download action
```

### Shipping Label Widget

`lib/features/marketplace/presentation/widgets/shipping_label_widget.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/core/design/design.dart';

class ShippingLabelWidget extends StatelessWidget {
  final String trackingNumber;
  final String labelUrl;
  final VoidCallback? onDownload;

  const ShippingLabelWidget({
    required this.trackingNumber,
    required this.labelUrl,
    this.onDownload,
    super.key,
  });

  Future<void> _downloadLabel() async {
    final uri = Uri.parse(labelUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open label URL');
    }
    onDownload?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LynewedColors.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: LynewedColors.success),
                const SizedBox(width: 8),
                Text(
                  'Shipping Label Ready',
                  style: LynewedTextStyles.titleSmall.copyWith(
                    color: LynewedColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tracking Number',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    trackingNumber,
                    style: LynewedTextStyles.titleSmall.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                LynewedIconButton(
                  icon: Icons.copy,
                  onPressed: () {
                    // TODO: Copy to clipboard
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            LynewedButton(
              text: 'Download Label (PDF)',
              icon: Icons.download,
              onPressed: _downloadLabel,
              isFullWidth: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Print this label and attach it to your package. Drop off at any FedEx location.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Tests Required

### Unit Tests

```dart
// test/features/marketplace/domain/usecases/generate_shipping_label_test.dart
group('GenerateShippingLabelUseCase', () {
  test('calls Edge Function with transaction_id and service_type', () async {
    // Arrange: mock datasource
    // Act: call use case
    // Assert: datasource called with correct params
  });

  test('returns tracking number and label URL', () async {
    // Arrange: mock returns shipment result
    // Act: call use case
    // Assert: result contains tracking_number and label_url
  });

  test('throws exception when transaction not found', () async {
    // Arrange: mock throws 404
    // Act & Assert: expect exception
  });

  test('throws exception when user is not seller', () async {
    // Arrange: mock throws 403
    // Act & Assert: expect exception
  });
});
```

### Widget Tests

```dart
// test/features/marketplace/presentation/widgets/shipping_label_widget_test.dart
group('ShippingLabelWidget', () {
  testWidgets('displays tracking number and download button', (tester) async {
    // Arrange & Act: pump widget
    // Assert: tracking number visible, button visible
  });

  testWidgets('calls url_launcher when download tapped', (tester) async {
    // Arrange: pump widget
    // Act: tap download button
    // Assert: launchUrl called with label URL
  });
});
```

## Error Handling

| Error | Code | User Message | Retry? |
|-------|------|-------------|--------|
| Transaction not found | `not_found` | "Transaction not found. Please refresh." | No |
| Not seller | `unauthorized` | "Only the seller can generate labels." | No |
| Invalid status | `invalid_status` | "Cannot generate label for this transaction status." | No |
| FedEx API error | `fedex_error` | "Error creating shipment. Please try again." | Yes |
| Timeout | `timeout` | "Request timeout. Please try again." | Yes |
| Storage error | `storage_error` | "Error saving label. Please contact support." | Yes |
| Invalid address | `invalid_address` | "Invalid address. Please verify addresses." | No |

## Notification Pattern

The notification is sent via the existing `notifications_outbox` system:

1. Insert into `notifications_outbox` table
2. Edge Function `notifications_outbox_drain` processes the queue (already deployed in EPIC-06)
3. Email sent to seller with label link

**Notification Data:**
```json
{
  "notification_type": "marketplace_label_ready",
  "title": "Shipping Label Ready",
  "body": "Your shipping label for \"Wedding Dress\" is ready to download.",
  "data": {
    "transaction_id": "uuid",
    "tracking_number": "123456789",
    "label_url": "https://..."
  }
}
```

## Definition of Done

- [ ] Edge Function `fedex-create-shipment` deployed
- [ ] Storage bucket `marketplace-labels` created with RLS policies
- [ ] FedExClient `createShipment()` method works correctly (from S11)
- [ ] Transaction updated with tracking_number and label_url
- [ ] Event logged in `fedex_events` table
- [ ] Notification sent via `notifications_outbox` (email with label link)
- [ ] Label stored as Base64 PDF in Supabase Storage
- [ ] Package details map complete by category (dress, shoes, accessories, decoration, other)
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] `flutter analyze --fatal-infos` passes
- [ ] Tested in sandbox with test shipments

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (API externe, costs per label)

## Dependances

### Requires
- S04 COMPLETE (table `marketplace_transactions`)
- S06 COMPLETE (table `fedex_events`)
- S11 COMPLETE (FedExClient with `createShipment()`)
- EPIC-06 COMPLETE (notifications_outbox system)

### Provides
- Label generation capability for sellers
- Tracking number for buyers

### Blocks
- S13 (FedEx Track - requires tracking_number)
- S21 (frontend label generation flow)

## Stories Dependantes
- S13 (FedEx Track API - uses tracking_number)
- S21 (generation etiquette frontend)

## Notes

### Label Format

FedEx returns labels in multiple formats:
- **PDF** (used here): 4x6 inches, standard thermal label size
- **PNG**: Image format
- **ZPL**: Zebra printer format

We use PDF for maximum compatibility (printable on any printer).

### Storage vs Direct Return

We store the label in Supabase Storage instead of returning the base64 directly because:
1. Labels can be large (100KB+)
2. Sellers need to access labels later
3. Storage provides signed URLs with expiration
4. Better for bandwidth and caching

### Package Details by Category

| Category | Weight (kg) | Dimensions (L×W×H cm) |
|----------|-------------|----------------------|
| dress | 3 | 60×40×20 |
| shoes | 2 | 35×25×15 |
| accessories | 1 | 30×20×10 |
| decoration | 5 | 50×50×30 |
| other | 3 | 40×30×20 |

Sellers can override these defaults in future stories.

### Cost per Label

Each label generation costs money with FedEx. In sandbox mode, labels are free. In production:
- Label generation: ~$0.10-0.50 per label (included in shipping cost)
- Track API calls: Free (reasonable usage)

### Return Label (Future Enhancement)

FedEx supports return labels. This can be added in a future story by setting `returnShipmentDetail` in the Ship API request.
