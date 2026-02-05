# Story S10: Stripe Connect onboarding Express vendeurs

## Description
En tant que vendeur, je veux configurer mon compte Stripe Connect Express, afin de recevoir les paiements de mes ventes (moins la commission 10%).

## Prerequisites

- [ ] EPIC-11 completed - Table `stripe_accounts` exists (verify via MCP list_tables)
- [ ] Stripe MCP connected with test mode keys
- [ ] Stripe Connect enabled in Stripe Dashboard
- [ ] Flutter dependency `url_launcher: ^6.3.1` added
- [ ] GoRouter configured in app

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller without Stripe account When they click "Setup payments" Then they should be redirected to Stripe Connect onboarding And a stripe_accounts record should be created with onboarding_complete=false
- [ ] Given a seller completing Stripe onboarding When Stripe sends account.updated webhook Then stripe_accounts should be updated with onboarding_complete=true, charges_enabled=true, payouts_enabled=true
- [ ] Given a seller with charges_enabled=false When they try to publish a listing Then they should be prompted to complete Stripe setup
- [ ] Given a seller with incomplete Stripe onboarding When they click "Complete setup" Then they should be redirected back to Stripe to continue
- [ ] Given a seller who completed onboarding Then they should see their account status (verified, payouts enabled) in their profile

## Files to Create/Modify

### CREATE (Clean Architecture Pattern)

```
supabase/functions/
├── create-stripe-connect-account/
│   └── index.ts                                     # Edge Function (create account + onboarding link)
└── stripe-connect-webhook/
    └── index.ts                                     # Webhook handler (NEW)

lib/features/marketplace/
├── domain/
│   ├── entities/
│   │   └── stripe_account.dart                      # Entity
│   ├── repositories/
│   │   └── stripe_connect_repository.dart           # Abstract interface
│   └── usecases/
│       ├── setup_stripe_connect.dart                # Create account + open URL
│       └── check_stripe_status.dart                 # Check charges_enabled
├── data/
│   ├── models/
│   │   └── stripe_account_model.dart                # Data model
│   ├── datasources/
│   │   └── stripe_connect_datasource.dart           # API calls
│   └── repositories/
│       └── stripe_connect_repository_impl.dart      # Repository implementation
└── presentation/
    ├── pages/
    │   └── stripe_setup_page.dart                   # Setup flow page
    └── widgets/
        └── stripe_status_widget.dart                # Status display

test/features/marketplace/
├── domain/usecases/
│   ├── setup_stripe_connect_test.dart
│   └── check_stripe_status_test.dart
├── data/repositories/
│   └── stripe_connect_repository_impl_test.dart
└── presentation/
    ├── pages/
    │   └── stripe_setup_page_test.dart
    └── widgets/
        └── stripe_status_widget_test.dart
```

### MODIFY

- `lib/core/di/injection_container.dart` - Add `_initMarketplaceStripe()`
- `lib/features/marketplace/presentation/pages/create_listing_page.dart` - Check Stripe status before publish
- `lib/core/router/app_router.dart` - Add deep link route `/stripe-connect-return`
- `ios/Runner/Info.plist` - Add URL scheme for deep link
- `android/app/src/main/AndroidManifest.xml` - Add intent filter for deep link

## Edge Function: create-stripe-connect-account

`supabase/functions/create-stripe-connect-account/index.ts`:

```typescript
// EPIC-14 S10: Create Stripe Connect Express Account
// Creates a Stripe Connect Express account and returns onboarding link
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

interface CreateAccountRequest {
  user_id: string;
  email: string;
  return_url: string;
  refresh_url: string;
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
    const body: CreateAccountRequest = await req.json();

    // Security: user_id must match authenticated user
    if (body.user_id !== user.id) {
      return new Response(JSON.stringify({ error: "User ID mismatch" }), {
        status: 403,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Validate required fields
    if (!body.return_url || !body.refresh_url) {
      return new Response(JSON.stringify({ error: "Missing return_url or refresh_url" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Use service role for database operations
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Check if user already has a Stripe account
    const { data: existingAccount } = await supabaseAdmin
      .from('stripe_accounts')
      .select('stripe_account_id, onboarding_complete')
      .eq('user_id', body.user_id)
      .single();

    let stripeAccountId: string;

    if (existingAccount?.stripe_account_id) {
      // Reuse existing account
      stripeAccountId = existingAccount.stripe_account_id;
      console.log(`Reusing existing Stripe account ${stripeAccountId} for user ${body.user_id}`);
    } else {
      // Create new Express account
      const account = await stripe.accounts.create({
        type: 'express',
        email: body.email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        business_type: 'individual',
      });

      stripeAccountId = account.id;
      console.log(`Created new Stripe Connect account ${stripeAccountId} for user ${body.user_id}`);

      // Store in database
      const { error: insertError } = await supabaseAdmin
        .from('stripe_accounts')
        .insert({
          user_id: body.user_id,
          stripe_account_id: stripeAccountId,
          account_type: 'express',
          onboarding_complete: false,
          charges_enabled: false,
          payouts_enabled: false,
          created_at: new Date().toISOString(),
        });

      if (insertError) {
        console.error('Error inserting stripe_accounts record:', insertError);
        // Don't fail if account was created but DB insert failed
        // Webhook will update the record later
      }
    }

    // Create onboarding link (always, even for existing accounts that need to complete onboarding)
    const accountLink = await stripe.accountLinks.create({
      account: stripeAccountId,
      refresh_url: body.refresh_url,
      return_url: body.return_url,
      type: 'account_onboarding',
    });

    console.log(`Created onboarding link for account ${stripeAccountId}`);

    return new Response(
      JSON.stringify({
        url: accountLink.url,
        stripe_account_id: stripeAccountId,
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
    console.error("Error creating Stripe Connect account:", error);

    // Provide user-friendly error messages
    let errorMessage = (error as Error).message;
    if (errorMessage.includes('rate_limit')) {
      errorMessage = 'Too many requests. Please try again in a few minutes.';
    } else if (errorMessage.includes('api_key')) {
      errorMessage = 'Stripe configuration error. Please contact support.';
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

## Edge Function: stripe-connect-webhook

`supabase/functions/stripe-connect-webhook/index.ts`:

```typescript
// EPIC-14 S10: Stripe Connect Webhook Handler
// Handles account.updated and other Stripe Connect events
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);
const webhookSecret = Deno.env.get("STRIPE_CONNECT_WEBHOOK_SECRET")!;

Deno.serve(async (req: Request) => {
  try {
    // Get the signature from headers
    const signature = req.headers.get("stripe-signature");
    if (!signature) {
      return new Response(JSON.stringify({ error: "No signature" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Get raw body
    const body = await req.text();

    // Verify webhook signature
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
    } catch (err) {
      console.error('Webhook signature verification failed:', err);
      return new Response(JSON.stringify({ error: 'Invalid signature' }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    console.log(`Received Stripe event: ${event.type}`);

    // Initialize Supabase admin client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Handle different event types
    switch (event.type) {
      case 'account.updated': {
        const account = event.data.object as Stripe.Account;

        console.log(`Updating stripe_accounts for account ${account.id}`);

        const { error } = await supabase
          .from('stripe_accounts')
          .update({
            onboarding_complete: account.details_submitted ?? false,
            charges_enabled: account.charges_enabled ?? false,
            payouts_enabled: account.payouts_enabled ?? false,
            updated_at: new Date().toISOString(),
          })
          .eq('stripe_account_id', account.id);

        if (error) {
          console.error('Error updating stripe_accounts:', error);
          return new Response(JSON.stringify({ error: error.message }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
          });
        }

        console.log(`Successfully updated account ${account.id} - onboarding: ${account.details_submitted}, charges: ${account.charges_enabled}, payouts: ${account.payouts_enabled}`);
        break;
      }

      case 'account.external_account.created':
      case 'account.external_account.updated':
      case 'account.external_account.deleted': {
        const account = event.account;
        console.log(`External account event for ${account} - refreshing account data`);

        // Fetch fresh account data
        const fullAccount = await stripe.accounts.retrieve(account as string);

        const { error } = await supabase
          .from('stripe_accounts')
          .update({
            onboarding_complete: fullAccount.details_submitted ?? false,
            charges_enabled: fullAccount.charges_enabled ?? false,
            payouts_enabled: fullAccount.payouts_enabled ?? false,
            updated_at: new Date().toISOString(),
          })
          .eq('stripe_account_id', account);

        if (error) {
          console.error('Error updating stripe_accounts:', error);
        }
        break;
      }

      case 'capability.updated': {
        const capability = event.data.object as Stripe.Capability;
        console.log(`Capability ${capability.id} updated for account ${capability.account}`);

        // Refresh account data
        const account = await stripe.accounts.retrieve(capability.account as string);

        const { error } = await supabase
          .from('stripe_accounts')
          .update({
            onboarding_complete: account.details_submitted ?? false,
            charges_enabled: account.charges_enabled ?? false,
            payouts_enabled: account.payouts_enabled ?? false,
            updated_at: new Date().toISOString(),
          })
          .eq('stripe_account_id', capability.account);

        if (error) {
          console.error('Error updating stripe_accounts:', error);
        }
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return new Response(
      JSON.stringify({ received: true }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error processing webhook:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
```

## Deep Link Configuration

### iOS (Info.plist)

Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>com.lynewed.app</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>lynewed</string>
    </array>
  </dict>
</array>
```

### Android (AndroidManifest.xml)

Add to `android/app/src/main/AndroidManifest.xml` inside `<activity>`:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="lynewed" android:host="stripe-connect-return" />
</intent-filter>
```

### GoRouter Configuration

Modify `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/stripe-connect-return',
  builder: (context, state) {
    // Query parameters: success=true or error=reason
    final success = state.uri.queryParameters['success'] == 'true';
    final error = state.uri.queryParameters['error'];

    if (success) {
      // Show success message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stripe account setup complete!')),
        );
      });
      return const StripeSetupSuccessPage();
    } else {
      // Show error
      return StripeSetupErrorPage(error: error ?? 'Unknown error');
    }
  },
),
```

## Flutter Implementation

### URL Launcher Pattern

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openStripeOnboarding(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication, // Open in external browser
  )) {
    throw Exception('Could not launch Stripe onboarding URL');
  }
}
```

### Return URLs

```dart
// In Flutter app
const returnUrl = 'lynewed://stripe-connect-return?success=true';
const refreshUrl = 'lynewed://stripe-connect-return?error=refresh_required';
```

## Design System Integration

### Widgets to Use

```dart
import '/core/design/design.dart';

// Use:
// - LynewedButton for "Setup Payments" / "Complete Setup"
// - LynewedColors for status indicators (green for verified, red for incomplete)
// - LynewedTextStyles for status text
// - LynewedIconButton for refresh status
```

### Status Widget

`lib/features/marketplace/presentation/widgets/stripe_status_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '/core/design/design.dart';

class StripeStatusWidget extends StatelessWidget {
  final bool onboardingComplete;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final VoidCallback? onSetupTap;

  const StripeStatusWidget({
    required this.onboardingComplete,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    this.onSetupTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!onboardingComplete || !chargesEnabled) {
      return Card(
        color: LynewedColors.warning.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: LynewedColors.warning),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Setup Incomplete',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your Stripe setup to receive payments from sales.',
                style: LynewedTextStyles.bodySmall,
              ),
              const SizedBox(height: 12),
              LynewedButton(
                text: 'Complete Setup',
                onPressed: onSetupTap,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: LynewedColors.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: LynewedColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Setup Complete',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Charges: ${chargesEnabled ? "Enabled" : "Disabled"} • Payouts: ${payoutsEnabled ? "Enabled" : "Disabled"}',
                    style: LynewedTextStyles.bodySmall,
                  ),
                ],
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

### Mock Stripe Pattern

```dart
// test/features/marketplace/mocks/mock_stripe.dart
class MockStripe extends Mock {
  Future<Map<String, dynamic>> createConnectAccount({
    required String userId,
    required String email,
    required String returnUrl,
    required String refreshUrl,
  }) async {
    return {
      'url': 'https://connect.stripe.com/express/onboarding/test',
      'stripe_account_id': 'acct_test123',
    };
  }
}
```

### Unit Tests

```dart
// test/features/marketplace/domain/usecases/setup_stripe_connect_test.dart
group('SetupStripeConnectUseCase', () {
  test('calls Edge Function with correct parameters', () async {
    // Arrange: mock datasource
    // Act: call use case
    // Assert: datasource called with user_id, email, return_url, refresh_url
  });

  test('throws exception when Edge Function fails', () async {
    // Arrange: mock datasource throws error
    // Act & Assert: expect exception
  });
});

// test/features/marketplace/domain/usecases/check_stripe_status_test.dart
group('CheckStripeStatusUseCase', () {
  test('returns true when charges_enabled=true', () async {
    // Arrange: mock repository returns account with charges_enabled=true
    // Act: call use case
    // Assert: returns true
  });

  test('returns false when charges_enabled=false', () async {
    // Arrange: mock repository returns account with charges_enabled=false
    // Act: call use case
    // Assert: returns false
  });
});
```

## Error Handling

| Error | Code | User Message | Retry? |
|-------|------|-------------|--------|
| No internet | `no_connection` | "No internet connection. Please try again." | Yes |
| Stripe API error | `stripe_error` | "Error connecting to Stripe. Please try again." | Yes |
| Rate limit | `rate_limit` | "Too many requests. Please wait a few minutes." | Yes (after delay) |
| Invalid credentials | `api_key_error` | "Configuration error. Please contact support." | No |
| User mismatch | `unauthorized` | "Authentication error. Please log in again." | No |
| Database error | `db_error` | "Error saving account. Please contact support." | No |

## Definition of Done

- [ ] Edge Function `create-stripe-connect-account` deployed
- [ ] Edge Function `stripe-connect-webhook` deployed
- [ ] Webhook configured in Stripe Dashboard (URL + secret)
- [ ] Table `stripe_accounts` verified (EPIC-11)
- [ ] Deep link configured (iOS Info.plist + Android AndroidManifest.xml)
- [ ] GoRouter route added for `/stripe-connect-return`
- [ ] url_launcher opens Stripe URL in external browser
- [ ] Status widget displays account state correctly
- [ ] Create listing page checks charges_enabled before allowing publish
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] `flutter analyze --fatal-infos` passes

## Estimation
**Points** : 8
**Complexite** : Haute
**Risque** : Haut (integration Stripe, webhooks, deep links)

## Dependances

### Requires
- EPIC-11 COMPLETE (table `stripe_accounts` created)
- Stripe Dashboard: Connect enabled, webhook endpoint configured

### Provides
- Stripe Connect accounts for sellers
- Payment receiving capability for marketplace

### Blocks
- S14 (create listing - requires charges_enabled check)
- S20 (purchase flow - requires connected account for payouts)

## Stories Dependantes
- S14 (create listing - check Stripe status)
- S20 (flow achat - paiement vers connected account)

## Notes

### Stripe Connect Webhook Setup

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://hekyovgnovhfhmkpfrna.supabase.co/functions/v1/stripe-connect-webhook`
3. Select events:
   - `account.updated`
   - `account.external_account.created`
   - `account.external_account.updated`
   - `account.external_account.deleted`
   - `capability.updated`
4. Copy webhook secret to Supabase Secrets: `STRIPE_CONNECT_WEBHOOK_SECRET`

### Return URL vs Refresh URL

- **return_url**: User completes onboarding successfully
- **refresh_url**: Onboarding link expires or needs to be refreshed

Both should deep link back to the app.

### Testing in Sandbox

Use Stripe test mode accounts. Test onboarding flow with test bank accounts provided by Stripe.
