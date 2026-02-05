# Story S08: Implement CGVU marketplace seller

## Description
En tant que vendeur, je veux accepter les CGVU avant de publier ma premiere annonce, afin de comprendre mes obligations legales et que l'acceptation soit tracee.

## Prerequisites

- [ ] Table `cgvu_acceptances` exists (check via MCP list_tables or create in this story)
- [ ] Edge Function `log-cgvu-acceptance` not yet deployed (created in this story)
- [ ] Supabase client initialized in app
- [ ] SharedPreferences dependency added (`shared_preferences: ^2.3.3`)
- [ ] Device Info Plus dependency added (`device_info_plus: ^11.2.0`)

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller who has never accepted marketplace CGVU When they try to publish a listing Then CGVU modal should be displayed And checkbox should be disabled until scrolled to bottom And publish should be blocked until accepted
- [ ] Given a seller accepting CGVU When they check the box and confirm Then cgvu_acceptances should contain user_id, cgvu_type='marketplace_seller', cgvu_version='1.0', ip_address, user_agent, device_info, accepted_at
- [ ] Given a seller who already accepted CGVU When they publish a new listing Then no CGVU modal should appear And listing should be published directly
- [ ] Given the CGVU modal When user has not scrolled to bottom Then the checkbox should be visually disabled (greyed out)
- [ ] Given the CGVU modal When user scrolls to the bottom (maxScrollExtent - position.pixels < 50) Then the checkbox should become enabled

## Files to Create/Modify

### CREATE (Clean Architecture Pattern)

```
lib/features/marketplace/
├── domain/
│   ├── entities/
│   │   └── cgvu_acceptance.dart                    # Entity
│   ├── repositories/
│   │   └── cgvu_repository.dart                    # Abstract interface
│   └── usecases/
│       ├── check_cgvu_acceptance.dart              # Check if accepted
│       └── accept_cgvu.dart                        # Accept CGVU use case
├── data/
│   ├── models/
│   │   └── cgvu_acceptance_model.dart              # Data model
│   ├── datasources/
│   │   └── cgvu_remote_datasource.dart             # API calls
│   └── repositories/
│       └── cgvu_repository_impl.dart               # Repository implementation
└── presentation/
    └── widgets/
        └── cgvu_seller_modal.dart                  # Modal widget

supabase/
├── migrations/
│   └── 20260204000001_create_cgvu_acceptances.sql  # Table creation
└── functions/
    └── log-cgvu-acceptance/
        └── index.ts                                 # Edge Function

test/features/marketplace/
├── domain/usecases/
│   ├── check_cgvu_acceptance_test.dart
│   └── accept_cgvu_test.dart
├── data/repositories/
│   └── cgvu_repository_impl_test.dart
└── presentation/widgets/
    └── cgvu_seller_modal_test.dart
```

### MODIFY

- `lib/core/di/injection_container.dart` - Add `_initMarketplaceCgvu()`
- `lib/features/marketplace/presentation/pages/create_listing_page.dart` - Integrate CGVU check before publish

## Edge Function Code

Create `supabase/functions/log-cgvu-acceptance/index.ts`:

```typescript
// EPIC-14 S08: Log CGVU Acceptance with IP Address
// Logs marketplace seller/buyer CGVU acceptances with full audit trail
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface CgvuAcceptanceRequest {
  user_id: string;
  cgvu_type: 'marketplace_seller' | 'marketplace_buyer';
  cgvu_version: string;
  user_agent: string;
  device_info: {
    platform: string;
    version: string;
    appVersion: string;
    buildNumber: string;
  };
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
    const body: CgvuAcceptanceRequest = await req.json();

    // Validate required fields
    if (!body.cgvu_type || !body.cgvu_version) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Security: user_id must match authenticated user
    if (body.user_id !== user.id) {
      return new Response(JSON.stringify({ error: "User ID mismatch" }), {
        status: 403,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Extract IP address from request headers
    const ip_address = req.headers.get('x-forwarded-for')?.split(',')[0].trim() ||
                       req.headers.get('x-real-ip') ||
                       'unknown';

    // Use service role to insert (bypass RLS if needed)
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Insert acceptance record
    const { data, error } = await supabaseAdmin
      .from('cgvu_acceptances')
      .insert({
        user_id: body.user_id,
        cgvu_type: body.cgvu_type,
        cgvu_version: body.cgvu_version,
        ip_address,
        user_agent: body.user_agent,
        device_info: body.device_info,
        accepted_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (error) {
      console.error('Error inserting CGVU acceptance:', error);
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    console.log(`CGVU ${body.cgvu_type} accepted by user ${body.user_id} from IP ${ip_address}`);

    return new Response(
      JSON.stringify({ success: true, acceptance: data }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error logging CGVU acceptance:", error);
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

## Migration SQL

Create `supabase/migrations/20260204000001_create_cgvu_acceptances.sql`:

```sql
-- EPIC-14 S08: CGVU Acceptances Table
-- Stores legal acceptance records for marketplace CGVU (seller/buyer)
CREATE TABLE IF NOT EXISTS cgvu_acceptances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  cgvu_type VARCHAR(50) NOT NULL CHECK (cgvu_type IN ('marketplace_seller', 'marketplace_buyer', 'magazine_purchase')),
  cgvu_version VARCHAR(20) NOT NULL DEFAULT '1.0',
  ip_address VARCHAR(50),
  user_agent TEXT,
  device_info JSONB,
  accepted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

  UNIQUE(user_id, cgvu_type, cgvu_version)
);

-- Index for fast lookups
CREATE INDEX idx_cgvu_acceptances_user_type ON cgvu_acceptances(user_id, cgvu_type);

-- RLS Policies
ALTER TABLE cgvu_acceptances ENABLE ROW LEVEL SECURITY;

-- Users can read their own acceptances
CREATE POLICY "Users can read own CGVU acceptances"
  ON cgvu_acceptances
  FOR SELECT
  USING (auth.uid() = user_id);

-- Insertion via Edge Function only (service role)
-- No direct INSERT policy for regular users

-- Grant access
GRANT SELECT ON cgvu_acceptances TO authenticated;
```

## Design System Integration

### Widgets to Use

```dart
import '/core/design/design.dart';

// Use:
// - LynewedSheet for modal base
// - LynewedButton for Accept/Cancel
// - LynewedColors for colors
// - LynewedTextStyles for typography
// - LynewedSpacing for consistent spacing
```

### Reference Screens

- `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart` (similar pattern)
- `lib/features/guest/presentation/widgets/report_user_sheet.dart` (sheet with scrollable content)

### Flutter Widget Implementation

`lib/features/marketplace/presentation/widgets/cgvu_seller_modal.dart`:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/core/design/design.dart';

const String _cacheKey = 'cgvu_seller_accepted_v1';

class CgvuSellerModal extends ConsumerStatefulWidget {
  final VoidCallback onAccepted;

  const CgvuSellerModal({required this.onAccepted, super.key});

  @override
  ConsumerState<CgvuSellerModal> createState() => _CgvuSellerModalState();
}

class _CgvuSellerModalState extends ConsumerState<CgvuSellerModal> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _isChecked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    // Threshold: 50 pixels from bottom
    if (position.maxScrollExtent - position.pixels < 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  Future<void> _accept() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Collect device info
      final deviceInfo = await _getDeviceInfo();
      final userAgent = _getUserAgent();

      // Call Edge Function via use case
      await ref.read(acceptCgvuUseCaseProvider).call(
        cgvuType: 'marketplace_seller',
        cgvuVersion: '1.0',
        userAgent: userAgent,
        deviceInfo: deviceInfo,
      );

      // Cache acceptance locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cacheKey, true);

      if (mounted) {
        Navigator.pop(context, true);
        widget.onAccepted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting terms: $e'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      return {
        'platform': 'iOS',
        'version': iosInfo.systemVersion,
        'model': iosInfo.model,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      return {
        'platform': 'Android',
        'version': androidInfo.version.release,
        'model': androidInfo.model,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    }

    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  String _getUserAgent() {
    return '${Platform.operatingSystem}/${Platform.operatingSystemVersion}';
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Marketplace Seller Terms',
      onClose: () => Navigator.pop(context, false),
      bottomAction: LynewedButton(
        text: 'Accept Terms',
        onPressed: _isChecked && !_isLoading ? _accept : null,
        isLoading: _isLoading,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scrollable CGVU text
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Text(
                _cgvuSellerText,
                style: LynewedTextStyles.bodyMedium,
              ),
            ),
          ),

          const Divider(),

          // Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_hasScrolledToBottom)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Please scroll to read all terms',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                CheckboxListTile(
                  value: _isChecked,
                  onChanged: _hasScrolledToBottom
                      ? (value) => setState(() => _isChecked = value ?? false)
                      : null,
                  title: Text(
                    'I have read and accept the Marketplace Seller Terms',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: _hasScrolledToBottom
                          ? LynewedColors.textPrimary
                          : LynewedColors.textSecondary,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CGVU Text Content (English)
const String _cgvuSellerText = '''
LYNEWED MARKETPLACE — SELLER TERMS AND CONDITIONS

Please read these terms carefully before listing items for sale.

1. MARKETPLACE OVERVIEW
The Lynewed Marketplace allows wedding professionals and brides to sell wedding-related items (dresses, accessories, decorations, etc.). By listing items, you agree to these terms.

2. SELLER OBLIGATIONS
• You must provide accurate item descriptions, photos, and pricing
• Items must be in the condition described
• You are responsible for packaging items securely
• You must ship items within 3 business days after payment
• You warrant that you own the items and have the right to sell them

3. PROHIBITED ITEMS
You may not sell:
• Counterfeit or replica items
• Stolen goods
• Items that violate intellectual property rights
• Illegal or dangerous items
• Items prohibited by applicable laws

4. PRICING AND FEES
• You set your own prices
• Lynewed charges a 10% commission on each sale
• Payment processing fees apply (approx. 3%)
• You receive 87% of the sale price
• Payments are processed via Stripe Connect

5. SHIPPING
• You are responsible for shipping items to buyers
• Shipping labels are provided via FedEx integration
• Shipping costs are paid by the buyer
• You must provide accurate package dimensions and weight
• Risk of loss transfers upon delivery to carrier

6. RETURNS AND DISPUTES
• You set your own return policy (if any)
• Buyers can dispute items not as described
• Lynewed may mediate disputes but is not liable
• Refunds must be processed within 5 business days if applicable

7. PAYMENTS
• Payments are deposited to your Stripe Connect account
• Payouts occur 2 business days after delivery confirmation
• You must complete Stripe onboarding to receive payments
• Lynewed reserves the right to hold funds in case of disputes

8. ACCOUNT SUSPENSION
Lynewed may suspend or terminate your seller account for:
• Fraudulent activity
• Repeated policy violations
• Failure to ship items
• Selling prohibited items

9. LIABILITY
• You are solely responsible for your listings
• Lynewed is not liable for disputes between buyers and sellers
• Lynewed does not guarantee sales or buyer satisfaction
• You indemnify Lynewed against claims related to your items

10. DATA AND PRIVACY
• Your data is processed according to our Privacy Policy
• Buyer shipping addresses are provided for shipping only
• You may not use buyer data for marketing or other purposes

11. CHANGES TO TERMS
Lynewed may update these terms at any time. Continued use of the marketplace constitutes acceptance of new terms.

By checking the box below, you confirm you have read and accept these Marketplace Seller Terms.
''';
```

## Tests Required

Create comprehensive tests for each AC:

### Unit Tests

```dart
// test/features/marketplace/domain/usecases/check_cgvu_acceptance_test.dart
group('CheckCgvuAcceptanceUseCase', () {
  test('returns true when user has accepted CGVU', () async {
    // Arrange: mock repository returns acceptance record
    // Act: call use case
    // Assert: returns true
  });

  test('returns false when user has not accepted CGVU', () async {
    // Arrange: mock repository returns null
    // Act: call use case
    // Assert: returns false
  });

  test('checks local cache before remote', () async {
    // Arrange: local cache has acceptance
    // Act: call use case
    // Assert: does not call remote
  });
});

// test/features/marketplace/domain/usecases/accept_cgvu_test.dart
group('AcceptCgvuUseCase', () {
  test('calls Edge Function with correct parameters', () async {
    // Arrange: mock datasource
    // Act: call use case
    // Assert: datasource called with user_id, cgvu_type, etc.
  });

  test('throws exception when Edge Function fails', () async {
    // Arrange: mock datasource throws error
    // Act & Assert: expect exception
  });
});
```

### Widget Tests

```dart
// test/features/marketplace/presentation/widgets/cgvu_seller_modal_test.dart
group('CgvuSellerModal', () {
  testWidgets('shows CGVU text and disabled checkbox initially', (tester) async {
    // Arrange & Act: pump widget
    // Assert: checkbox disabled, text visible
  });

  testWidgets('enables checkbox after scrolling to bottom', (tester) async {
    // Arrange: pump widget
    // Act: scroll to bottom
    // Assert: checkbox enabled
  });

  testWidgets('calls onAccepted when user accepts', (tester) async {
    // Arrange: pump widget, scroll, check
    // Act: tap Accept button
    // Assert: onAccepted called, modal closes
  });

  testWidgets('does not call onAccepted when user cancels', (tester) async {
    // Arrange: pump widget
    // Act: tap Cancel
    // Assert: onAccepted not called
  });
});
```

## Error Handling

| Error | Code | User Message | Retry? |
|-------|------|-------------|--------|
| No internet | `no_connection` | "No internet connection. Please try again." | Yes |
| Edge Function error | `server_error` | "Error accepting terms. Please try again." | Yes |
| Invalid user | `unauthorized` | "Authentication error. Please log in again." | No |
| Database error | `db_error` | "Error saving acceptance. Please contact support." | No |

## Local Cache Strategy

```dart
// Check local cache first to avoid redundant API calls
final prefs = await SharedPreferences.getInstance();
final hasAcceptedLocally = prefs.getBool('cgvu_seller_accepted_v1') ?? false;

if (hasAcceptedLocally) {
  return true; // Skip remote check
}

// Otherwise, check remote
final hasAcceptedRemote = await repository.hasAccepted(userId, 'marketplace_seller');

if (hasAcceptedRemote) {
  // Cache for future
  await prefs.setBool('cgvu_seller_accepted_v1', true);
}

return hasAcceptedRemote;
```

## Definition of Done

- [ ] Migration creates table `cgvu_acceptances` with correct schema
- [ ] Edge Function `log-cgvu-acceptance` deployed and tested
- [ ] Modal with scroll detection implemented using LynewedSheet
- [ ] Checkbox disabled until scroll threshold (maxScrollExtent - pixels < 50)
- [ ] Logging complet (IP from Edge Function, user_agent via Platform, device via device_info_plus)
- [ ] Local cache using SharedPreferences with key `cgvu_seller_accepted_v1`
- [ ] Clean Architecture: all layers implemented (domain/entities, repositories, data sources, presentation)
- [ ] DI configured in injection_container.dart
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] `flutter analyze --fatal-infos` passes
- [ ] Integration with create_listing_page.dart complete

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (compliance legale)

## Dependances

### Requires
- Aucune dependance technique bloquante

### Provides
- Table `cgvu_acceptances` (used by S09)
- Edge Function `log-cgvu-acceptance` (used by S09)
- Data layer (repository, use cases) reused by S09

## Stories Dependantes
- S09 (CGVU buyer - reutilise table et data layer)
- S14 (create listing form - integre check CGVU)
