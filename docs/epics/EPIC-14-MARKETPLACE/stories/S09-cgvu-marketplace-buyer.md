# Story S09: Implement CGVU marketplace buyer

## Description
En tant qu'acheteuse, je veux accepter les CGVU avant mon premier achat, afin de comprendre mes droits et obligations et que l'acceptation soit tracee.

## Prerequisites

- [ ] Story S08 completed (table `cgvu_acceptances` created, Edge Function deployed)
- [ ] Verify table exists via MCP: `list_tables` for `cgvu_acceptances`
- [ ] Verify Edge Function exists via MCP: `list_edge_functions` for `log-cgvu-acceptance`
- [ ] SharedPreferences dependency added (`shared_preferences: ^2.3.3`)
- [ ] Device Info Plus dependency added (`device_info_plus: ^11.2.0`)

## Criteres d'Acceptance (Gherkin)

- [ ] Given a buyer who has never accepted marketplace buyer CGVU When they proceed to checkout Then CGVU modal should be displayed And payment button should be blocked until accepted
- [ ] Given a buyer accepting CGVU When they check the box and confirm Then cgvu_acceptances should have cgvu_type='marketplace_buyer', cgvu_version='1.0' with full logging (IP, device, timestamp)
- [ ] Given a buyer who already accepted CGVU When they make another purchase Then no CGVU modal should appear
- [ ] Given the checkout flow When CGVU not accepted Then the "Pay" button should be disabled
- [ ] Given the CGVU modal When user scrolls to bottom and checks the box Then acceptance should be logged before proceeding to payment

## Files to Create/Modify

### CREATE

```
lib/features/marketplace/
└── presentation/
    └── widgets/
        └── cgvu_buyer_modal.dart                    # Modal widget (similar to cgvu_seller_modal.dart)

test/features/marketplace/
└── presentation/widgets/
    └── cgvu_buyer_modal_test.dart                   # Widget tests
```

### MODIFY

- `lib/features/marketplace/presentation/pages/marketplace_checkout_page.dart` - Integrate CGVU check (NEW FILE - created in this story)

### REUSE from S08

- `lib/features/marketplace/domain/repositories/cgvu_repository.dart`
- `lib/features/marketplace/domain/usecases/check_cgvu_acceptance.dart`
- `lib/features/marketplace/domain/usecases/accept_cgvu.dart`
- `lib/features/marketplace/data/repositories/cgvu_repository_impl.dart`
- `lib/features/marketplace/data/datasources/cgvu_remote_datasource.dart`
- `supabase/functions/log-cgvu-acceptance/index.ts` (same Edge Function)

## Design System Integration

### Widgets to Use

```dart
import '/core/design/design.dart';

// Use:
// - LynewedSheet for modal base
// - LynewedButton for Accept/Cancel
// - LynewedCheckbox or CheckboxListTile
// - LynewedColors for colors
// - LynewedTextStyles for typography
```

### Reference Screens

- `lib/features/marketplace/presentation/widgets/cgvu_seller_modal.dart` (S08 - same pattern)
- `lib/features/my_wedding/presentation/dialogs/magazine_cgvu_dialog.dart` (similar scroll + checkbox)

## Flutter Widget Implementation

### 1. CGVU Buyer Modal

`lib/features/marketplace/presentation/widgets/cgvu_buyer_modal.dart`:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/core/design/design.dart';

const String _cacheKey = 'cgvu_buyer_accepted_v1';

class CgvuBuyerModal extends ConsumerStatefulWidget {
  final VoidCallback onAccepted;

  const CgvuBuyerModal({required this.onAccepted, super.key});

  @override
  ConsumerState<CgvuBuyerModal> createState() => _CgvuBuyerModalState();
}

class _CgvuBuyerModalState extends ConsumerState<CgvuBuyerModal> {
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

      // Call Edge Function via use case (reuse from S08)
      await ref.read(acceptCgvuUseCaseProvider).call(
        cgvuType: 'marketplace_buyer',
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
      title: 'Marketplace Buyer Terms',
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
                _cgvuBuyerText,
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
                    'I have read and accept the Marketplace Buyer Terms',
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

// CGVU Buyer Text Content (English)
const String _cgvuBuyerText = '''
LYNEWED MARKETPLACE — BUYER TERMS AND CONDITIONS

Please read these terms carefully before making a purchase.

1. MARKETPLACE OVERVIEW
The Lynewed Marketplace is a peer-to-peer platform connecting buyers and sellers of wedding-related items. Lynewed facilitates transactions but does not sell items directly.

2. BUYER RESPONSIBILITIES
• You are responsible for reading item descriptions carefully
• You must provide accurate shipping address
• You must inspect items upon delivery
• You must communicate with sellers regarding any issues

3. NO WARRANTY
• Lynewed does not guarantee item condition or quality
• Items are sold "as-is" by individual sellers
• Sellers are responsible for accurate descriptions
• Lynewed is not liable for misrepresented items

4. PRICING
• Prices are set by sellers
• All prices are in USD
• Shipping costs are additional and calculated at checkout
• Total price is final once payment is confirmed

5. PAYMENT
• Payments are processed securely via Stripe
• Your payment is held until delivery confirmation
• Sellers receive payment 2 business days after delivery
• Refunds are subject to seller's return policy

6. SHIPPING
• Shipping is handled by sellers via FedEx
• Shipping costs are paid by buyers
• Estimated delivery times are provided but not guaranteed
• Buyers can track shipments via tracking number
• Risk of loss transfers upon delivery

7. RETURNS AND REFUNDS
• Return policies are set by individual sellers
• Contact sellers directly for return requests
• Returns must be initiated within 7 days of delivery
• Buyers pay return shipping unless item is defective
• Refunds are processed by sellers
• Lynewed may mediate disputes but does not guarantee refunds

8. DISPUTES
• Contact the seller first for any issues
• If unresolved, contact Lynewed support within 14 days
• Lynewed may mediate but is not liable
• Chargebacks may result in account suspension

9. PROHIBITED CONDUCT
You may not:
• Purchase items for resale without seller permission
• Provide false shipping information
• Request refunds fraudulently
• Harass or threaten sellers

10. SHIPPING COSTS NON-REFUNDABLE
• Shipping costs are non-refundable
• This applies even if you return the item
• Only the item price may be refunded

11. DELIVERY TIMEFRAMES
• Delivery estimates are provided by FedEx
• Delays may occur due to weather, holidays, or carrier issues
• Lynewed is not responsible for shipping delays

12. DATA PROTECTION
• Your data is processed according to our Privacy Policy
• Sellers receive your shipping address for delivery only
• Payment information is never shared with sellers

13. ACCOUNT SUSPENSION
Lynewed may suspend your account for:
• Fraudulent activity
• Chargebacks
• Harassment or abusive behavior
• Violation of these terms

14. LIMITATION OF LIABILITY
• Lynewed's liability is limited to the transaction value
• Lynewed is not liable for indirect or consequential damages
• Lynewed does not guarantee seller performance
• You agree to resolve disputes directly with sellers

15. CHANGES TO TERMS
Lynewed may update these terms at any time. Continued use constitutes acceptance of new terms.

By checking the box below, you confirm you have read and accept these Marketplace Buyer Terms.
''';
```

### 2. Checkout Page Integration

`lib/features/marketplace/presentation/pages/marketplace_checkout_page.dart` (NEW FILE):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/design/design.dart';
import '../widgets/cgvu_buyer_modal.dart';

class MarketplaceCheckoutPage extends ConsumerStatefulWidget {
  final String listingId;
  final String offerId;

  const MarketplaceCheckoutPage({
    required this.listingId,
    required this.offerId,
    super.key,
  });

  @override
  ConsumerState<MarketplaceCheckoutPage> createState() =>
      _MarketplaceCheckoutPageState();
}

class _MarketplaceCheckoutPageState extends ConsumerState<MarketplaceCheckoutPage> {
  bool _cgvuAccepted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCgvuAcceptance();
  }

  Future<void> _checkCgvuAcceptance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check local cache first
      final prefs = await SharedPreferences.getInstance();
      final hasAcceptedLocally = prefs.getBool('cgvu_buyer_accepted_v1') ?? false;

      if (hasAcceptedLocally) {
        setState(() {
          _cgvuAccepted = true;
          _isLoading = false;
        });
        return;
      }

      // Check remote
      final hasAcceptedRemote = await ref
          .read(checkCgvuAcceptanceUseCaseProvider)
          .call('marketplace_buyer');

      if (hasAcceptedRemote) {
        // Cache for future
        await prefs.setBool('cgvu_buyer_accepted_v1', true);
      }

      setState(() {
        _cgvuAccepted = hasAcceptedRemote;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _proceedToPayment() async {
    if (!_cgvuAccepted) {
      // Show CGVU modal
      final accepted = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: CgvuBuyerModal(
            onAccepted: () => Navigator.pop(context, true),
          ),
        ),
      );

      if (accepted != true) {
        return; // User declined
      }

      setState(() {
        _cgvuAccepted = true;
      });
    }

    // Proceed with Stripe payment
    _processPayment();
  }

  Future<void> _processPayment() async {
    // TODO: Implement Stripe payment flow (future story)
    print('Processing payment for offer ${widget.offerId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: LynewedTextStyles.titleLarge,
                  ),
                  const SizedBox(height: LynewedSpacing.lg),

                  // TODO: Display item details, price, shipping

                  const Spacer(),

                  // Terms checkbox (display only)
                  CheckboxListTile(
                    value: _cgvuAccepted,
                    onChanged: null, // Read-only, modal handles acceptance
                    title: GestureDetector(
                      onTap: () async {
                        // Show modal to read/accept terms
                        await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: CgvuBuyerModal(
                              onAccepted: () {
                                Navigator.pop(context, true);
                                setState(() {
                                  _cgvuAccepted = true;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'I accept the Marketplace Buyer Terms',
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: LynewedSpacing.lg),

                  // Pay button
                  LynewedButton(
                    text: 'Pay Now',
                    onPressed: _cgvuAccepted ? _proceedToPayment : null,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
    );
  }
}
```

## Tests Required

### Widget Tests

```dart
// test/features/marketplace/presentation/widgets/cgvu_buyer_modal_test.dart
group('CgvuBuyerModal', () {
  testWidgets('shows buyer CGVU text and disabled checkbox initially', (tester) async {
    // Arrange & Act: pump widget
    // Assert: checkbox disabled, text contains "Marketplace Buyer"
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

  testWidgets('saves acceptance to local cache', (tester) async {
    // Arrange: pump widget, scroll, check
    // Act: tap Accept
    // Assert: SharedPreferences has cgvu_buyer_accepted_v1 = true
  });
});
```

### Integration Tests

```dart
// test/features/marketplace/presentation/pages/marketplace_checkout_page_test.dart
group('MarketplaceCheckoutPage', () {
  testWidgets('shows CGVU modal when buyer has not accepted', (tester) async {
    // Arrange: hasAccepted returns false
    // Act: pump page, tap Pay
    // Assert: modal shown
  });

  testWidgets('does not show modal when buyer has already accepted', (tester) async {
    // Arrange: hasAccepted returns true
    // Act: pump page, tap Pay
    // Assert: payment proceeds directly
  });

  testWidgets('Pay button disabled until CGVU accepted', (tester) async {
    // Arrange: hasAccepted returns false
    // Act: pump page
    // Assert: Pay button disabled
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

Same as S08:

```dart
// Check local cache first
final prefs = await SharedPreferences.getInstance();
final hasAcceptedLocally = prefs.getBool('cgvu_buyer_accepted_v1') ?? false;

if (hasAcceptedLocally) {
  return true; // Skip remote check
}

// Otherwise, check remote
final hasAcceptedRemote = await repository.hasAccepted(userId, 'marketplace_buyer');

if (hasAcceptedRemote) {
  // Cache for future
  await prefs.setBool('cgvu_buyer_accepted_v1', true);
}

return hasAcceptedRemote;
```

## Definition of Done

- [ ] Modal CGVU buyer implementee avec pattern identique a S08
- [ ] Integration dans checkout flow (marketplace_checkout_page.dart cree)
- [ ] Logging complet (meme format que S08: IP, user_agent, device_info)
- [ ] Cache local avec key `cgvu_buyer_accepted_v1`
- [ ] Reutilisation data layer S08 (repository, use cases)
- [ ] cgvu_type = 'marketplace_buyer', cgvu_version = '1.0'
- [ ] All widget tests pass
- [ ] All integration tests pass
- [ ] `flutter analyze --fatal-infos` passes

## Estimation
**Points** : 3
**Complexite** : Faible (reutilise S08)
**Risque** : Moyen (compliance legale)

## Dependances

### Requires
- S08 COMPLETE (table, Edge Function, data layer)

### Blocks
- S20 (flow achat complet - integre CGVU buyer check)

## Stories Dependantes
- S20 (purchase flow - integre check CGVU buyer)

## Notes

### Differences avec S08 (Seller)

| Aspect | Seller (S08) | Buyer (S09) |
|--------|--------------|-------------|
| cgvu_type | `marketplace_seller` | `marketplace_buyer` |
| Texte CGVU | Obligations vendeur | Droits acheteur |
| Flow | Create listing | Checkout |
| Cache key | `cgvu_seller_accepted_v1` | `cgvu_buyer_accepted_v1` |
| Table | Same (`cgvu_acceptances`) | Same (`cgvu_acceptances`) |
| Edge Function | Same (`log-cgvu-acceptance`) | Same (`log-cgvu-acceptance`) |
| Data layer | Create | Reuse |

### CGVU Version

Both seller and buyer use `cgvu_version = '1.0'`. This allows tracking if terms change in the future (e.g., v1.1, v2.0) and requiring re-acceptance.
