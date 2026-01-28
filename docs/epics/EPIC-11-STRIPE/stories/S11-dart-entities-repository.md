# Story S11: Creer entites Dart et repository Stripe

## Description
En tant que developpeur, je veux creer la couche Dart (entites, repository, datasource) pour interagir avec les tables Stripe, afin de permettre l'affichage des comptes et achats dans l'app Flutter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given la classe StripeAccount Then elle a les champs: userId, stripeAccountId, chargesEnabled, payoutsEnabled, onboardingComplete, detailsSubmitted
- [ ] Given la classe StripeAccount Then elle a une methode factory fromJson
- [ ] Given la classe StripeAccount Then elle a une methode copyWith
- [ ] Given la classe Purchase Then elle a les champs: id, userId, productType, productId, sellerId, amountCents, status, etc.
- [ ] Given la classe Purchase Then elle a une methode factory fromJson
- [ ] Given la classe Purchase Then elle a une methode copyWith
- [ ] Given l'enum PurchaseStatus Then elle contient tous les statuts: pending, processing, requires_action, succeeded, failed, canceled, refunded, partially_refunded, disputed
- [ ] Given l'enum ProductType Then elle contient: marketplace_item, reel, album, print, subscription
- [ ] Given le StripeRepository Then il a getStripeAccount(userId) qui retourne StripeAccount?
- [ ] Given le StripeRepository Then il a getPurchases(userId) qui retourne List<Purchase>
- [ ] Given le StripeRepository Then il a getPurchase(id) qui retourne Purchase?
- [ ] Given le StripeRepository Then il a getSales(sellerId) qui retourne List<Purchase>
- [ ] Given les tests unitaires Then fromJson/toJson sont testes pour toutes les entites

## Fichiers Concernes

### A Creer
- `lib/features/payments/domain/entities/stripe_account.dart`
- `lib/features/payments/domain/entities/purchase.dart`
- `lib/features/payments/domain/entities/purchase_status.dart`
- `lib/features/payments/domain/entities/product_type.dart`
- `lib/features/payments/domain/repositories/stripe_repository.dart`
- `lib/features/payments/data/repositories/supabase_stripe_repository.dart`
- `lib/features/payments/data/datasources/stripe_remote_datasource.dart`
- `test/features/payments/domain/entities/stripe_account_test.dart`
- `test/features/payments/domain/entities/purchase_test.dart`
- `test/features/payments/data/repositories/supabase_stripe_repository_test.dart`

### A Modifier
- `lib/core/di/injection_container.dart` (si injection dependencies)

## Notes Techniques

### StripeAccount Entity

```dart
// lib/features/payments/domain/entities/stripe_account.dart
import 'package:equatable/equatable.dart';

class StripeAccount extends Equatable {
  final String userId;
  final String stripeAccountId;
  final String accountType;
  final bool onboardingComplete;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final List<String> currentlyDue;
  final List<String> pastDue;
  final String? disabledReason;
  final String? country;
  final String? defaultCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StripeAccount({
    required this.userId,
    required this.stripeAccountId,
    this.accountType = 'express',
    this.onboardingComplete = false,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
    this.currentlyDue = const [],
    this.pastDue = const [],
    this.disabledReason,
    this.country,
    this.defaultCurrency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StripeAccount.fromJson(Map<String, dynamic> json) {
    return StripeAccount(
      userId: json['user_id'] as String,
      stripeAccountId: json['stripe_account_id'] as String,
      accountType: json['account_type'] as String? ?? 'express',
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      chargesEnabled: json['charges_enabled'] as bool? ?? false,
      payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
      detailsSubmitted: json['details_submitted'] as bool? ?? false,
      currentlyDue: (json['currently_due'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pastDue: (json['past_due'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      disabledReason: json['disabled_reason'] as String?,
      country: json['country'] as String?,
      defaultCurrency: json['default_currency'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  StripeAccount copyWith({
    String? userId,
    String? stripeAccountId,
    String? accountType,
    bool? onboardingComplete,
    bool? chargesEnabled,
    bool? payoutsEnabled,
    bool? detailsSubmitted,
    List<String>? currentlyDue,
    List<String>? pastDue,
    String? disabledReason,
    String? country,
    String? defaultCurrency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StripeAccount(
      userId: userId ?? this.userId,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      accountType: accountType ?? this.accountType,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      chargesEnabled: chargesEnabled ?? this.chargesEnabled,
      payoutsEnabled: payoutsEnabled ?? this.payoutsEnabled,
      detailsSubmitted: detailsSubmitted ?? this.detailsSubmitted,
      currentlyDue: currentlyDue ?? this.currentlyDue,
      pastDue: pastDue ?? this.pastDue,
      disabledReason: disabledReason ?? this.disabledReason,
      country: country ?? this.country,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => chargesEnabled && payoutsEnabled;
  bool get hasActionRequired => currentlyDue.isNotEmpty || pastDue.isNotEmpty;

  @override
  List<Object?> get props => [
        userId,
        stripeAccountId,
        accountType,
        onboardingComplete,
        chargesEnabled,
        payoutsEnabled,
        detailsSubmitted,
        currentlyDue,
        pastDue,
        disabledReason,
        country,
        defaultCurrency,
        createdAt,
        updatedAt,
      ];
}
```

### PurchaseStatus Enum

```dart
// lib/features/payments/domain/entities/purchase_status.dart
enum PurchaseStatus {
  pending,
  processing,
  requiresAction,
  succeeded,
  failed,
  canceled,
  refunded,
  partiallyRefunded,
  disputed;

  static PurchaseStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PurchaseStatus.pending;
      case 'processing':
        return PurchaseStatus.processing;
      case 'requires_action':
        return PurchaseStatus.requiresAction;
      case 'succeeded':
        return PurchaseStatus.succeeded;
      case 'failed':
        return PurchaseStatus.failed;
      case 'canceled':
        return PurchaseStatus.canceled;
      case 'refunded':
        return PurchaseStatus.refunded;
      case 'partially_refunded':
        return PurchaseStatus.partiallyRefunded;
      case 'disputed':
        return PurchaseStatus.disputed;
      default:
        return PurchaseStatus.pending;
    }
  }

  String toJson() {
    switch (this) {
      case PurchaseStatus.pending:
        return 'pending';
      case PurchaseStatus.processing:
        return 'processing';
      case PurchaseStatus.requiresAction:
        return 'requires_action';
      case PurchaseStatus.succeeded:
        return 'succeeded';
      case PurchaseStatus.failed:
        return 'failed';
      case PurchaseStatus.canceled:
        return 'canceled';
      case PurchaseStatus.refunded:
        return 'refunded';
      case PurchaseStatus.partiallyRefunded:
        return 'partially_refunded';
      case PurchaseStatus.disputed:
        return 'disputed';
    }
  }

  bool get isTerminal => [
        PurchaseStatus.succeeded,
        PurchaseStatus.failed,
        PurchaseStatus.canceled,
        PurchaseStatus.refunded,
      ].contains(this);

  bool get isSuccessful => this == PurchaseStatus.succeeded;
}
```

### ProductType Enum

```dart
// lib/features/payments/domain/entities/product_type.dart
enum ProductType {
  marketplaceItem,
  reel,
  album,
  print,
  subscription;

  static ProductType fromString(String value) {
    switch (value) {
      case 'marketplace_item':
        return ProductType.marketplaceItem;
      case 'reel':
        return ProductType.reel;
      case 'album':
        return ProductType.album;
      case 'print':
        return ProductType.print;
      case 'subscription':
        return ProductType.subscription;
      default:
        return ProductType.marketplaceItem;
    }
  }

  String toJson() {
    switch (this) {
      case ProductType.marketplaceItem:
        return 'marketplace_item';
      case ProductType.reel:
        return 'reel';
      case ProductType.album:
        return 'album';
      case ProductType.print:
        return 'print';
      case ProductType.subscription:
        return 'subscription';
    }
  }
}
```

### Purchase Entity

```dart
// lib/features/payments/domain/entities/purchase.dart
import 'package:equatable/equatable.dart';
import 'purchase_status.dart';
import 'product_type.dart';

class Purchase extends Equatable {
  final String id;
  final String userId;
  final ProductType productType;
  final String? productId;
  final String? sellerId;
  final int amountCents;
  final String currency;
  final int platformFeeCents;
  final int? sellerAmountCents;
  final int shippingCents;
  final String? stripePaymentIntentId;
  final String? stripeCheckoutSessionId;
  final String? stripeTransferId;
  final String? stripeChargeId;
  final PurchaseStatus status;
  final Map<String, dynamic> metadata;
  final String? errorMessage;
  final String? errorCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final DateTime? disputedAt;

  const Purchase({
    required this.id,
    required this.userId,
    required this.productType,
    this.productId,
    this.sellerId,
    required this.amountCents,
    this.currency = 'USD',
    this.platformFeeCents = 0,
    this.sellerAmountCents,
    this.shippingCents = 0,
    this.stripePaymentIntentId,
    this.stripeCheckoutSessionId,
    this.stripeTransferId,
    this.stripeChargeId,
    this.status = PurchaseStatus.pending,
    this.metadata = const {},
    this.errorMessage,
    this.errorCode,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.refundedAt,
    this.disputedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productType: ProductType.fromString(json['product_type'] as String),
      productId: json['product_id'] as String?,
      sellerId: json['seller_id'] as String?,
      amountCents: json['amount_cents'] as int,
      currency: json['currency'] as String? ?? 'USD',
      platformFeeCents: json['platform_fee_cents'] as int? ?? 0,
      sellerAmountCents: json['seller_amount_cents'] as int?,
      shippingCents: json['shipping_cents'] as int? ?? 0,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeCheckoutSessionId: json['stripe_checkout_session_id'] as String?,
      stripeTransferId: json['stripe_transfer_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      status: PurchaseStatus.fromString(json['status'] as String? ?? 'pending'),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      refundedAt: json['refunded_at'] != null
          ? DateTime.parse(json['refunded_at'] as String)
          : null,
      disputedAt: json['disputed_at'] != null
          ? DateTime.parse(json['disputed_at'] as String)
          : null,
    );
  }

  // Computed properties
  double get amountInCurrency => amountCents / 100;
  double get platformFeeInCurrency => platformFeeCents / 100;
  double? get sellerAmountInCurrency =>
      sellerAmountCents != null ? sellerAmountCents! / 100 : null;

  bool get isMarketplace => sellerId != null;
  bool get isPaid => status == PurchaseStatus.succeeded;
  bool get hasFailed => status == PurchaseStatus.failed;

  Purchase copyWith({
    String? id,
    String? userId,
    ProductType? productType,
    String? productId,
    String? sellerId,
    int? amountCents,
    String? currency,
    int? platformFeeCents,
    int? sellerAmountCents,
    int? shippingCents,
    String? stripePaymentIntentId,
    String? stripeCheckoutSessionId,
    String? stripeTransferId,
    String? stripeChargeId,
    PurchaseStatus? status,
    Map<String, dynamic>? metadata,
    String? errorMessage,
    String? errorCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? refundedAt,
    DateTime? disputedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productType: productType ?? this.productType,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      platformFeeCents: platformFeeCents ?? this.platformFeeCents,
      sellerAmountCents: sellerAmountCents ?? this.sellerAmountCents,
      shippingCents: shippingCents ?? this.shippingCents,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeCheckoutSessionId:
          stripeCheckoutSessionId ?? this.stripeCheckoutSessionId,
      stripeTransferId: stripeTransferId ?? this.stripeTransferId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      refundedAt: refundedAt ?? this.refundedAt,
      disputedAt: disputedAt ?? this.disputedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        productType,
        productId,
        sellerId,
        amountCents,
        currency,
        platformFeeCents,
        sellerAmountCents,
        shippingCents,
        stripePaymentIntentId,
        stripeCheckoutSessionId,
        stripeTransferId,
        stripeChargeId,
        status,
        metadata,
        errorMessage,
        errorCode,
        createdAt,
        updatedAt,
        paidAt,
        refundedAt,
        disputedAt,
      ];
}
```

### Repository Interface

```dart
// lib/features/payments/domain/repositories/stripe_repository.dart
import '../entities/stripe_account.dart';
import '../entities/purchase.dart';

abstract class StripeRepository {
  Future<StripeAccount?> getStripeAccount(String userId);
  Future<List<Purchase>> getPurchases(String userId);
  Future<Purchase?> getPurchase(String id);
  Future<List<Purchase>> getSales(String sellerId);
}
```

### Supabase Implementation

```dart
// lib/features/payments/data/repositories/supabase_stripe_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/stripe_account.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/stripe_repository.dart';

class SupabaseStripeRepository implements StripeRepository {
  final SupabaseClient _supabase;

  SupabaseStripeRepository(this._supabase);

  @override
  Future<StripeAccount?> getStripeAccount(String userId) async {
    final response = await _supabase
        .from('stripe_accounts')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return StripeAccount.fromJson(response);
  }

  @override
  Future<List<Purchase>> getPurchases(String userId) async {
    final response = await _supabase
        .from('purchases')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Purchase.fromJson(json))
        .toList();
  }

  @override
  Future<Purchase?> getPurchase(String id) async {
    final response = await _supabase
        .from('purchases')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Purchase.fromJson(response);
  }

  @override
  Future<List<Purchase>> getSales(String sellerId) async {
    final response = await _supabase
        .from('purchases')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Purchase.fromJson(json))
        .toList();
  }
}
```

## Definition of Done

- [ ] StripeAccount entity avec fromJson et copyWith
- [ ] Purchase entity avec fromJson et copyWith
- [ ] PurchaseStatus enum avec fromString et toJson
- [ ] ProductType enum avec fromString et toJson
- [ ] StripeRepository interface
- [ ] SupabaseStripeRepository implementation
- [ ] Tests unitaires pour StripeAccount.fromJson
- [ ] Tests unitaires pour Purchase.fromJson
- [ ] Tests unitaires pour enums
- [ ] Tests pour repository (avec mocks)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation

**Points** : 3
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S01: Table stripe_accounts (schema)
- S02: Table purchases (schema)

## Stories Dependantes

- EPIC-12: Reels Generation (utilise Purchase pour achats)
- EPIC-14: Marketplace (utilise StripeAccount et Purchase)
