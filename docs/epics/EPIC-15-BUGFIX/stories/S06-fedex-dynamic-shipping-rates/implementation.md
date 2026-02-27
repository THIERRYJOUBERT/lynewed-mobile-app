# Implementation Notes - S06 FedEx Dynamic Shipping Rates

> Completed: 2026-02-16
> Commit: f5dbd2d
> Mode: autonomous

## Summary

Replaced flat-rate shipping in the marketplace checkout with dynamic FedEx rate calculation. Added a weight field to listings, created a seller address retrieval use case, and refactored the checkout flow from 3 to 4 steps (Address -> Shipping -> Review -> Confirm).

## Files Changed

### Created
- `lib/features/marketplace/domain/usecases/get_seller_shipping_address.dart`: Use case to fetch seller profile and extract/validate shipping address. Includes `SellerAddressException` for error differentiation.
- `test/features/marketplace/domain/usecases/get_seller_shipping_address_test.dart`: 6 tests covering valid address, missing profile, null address, empty countryCode/city/postalCode.

### Modified
- `lib/features/marketplace/domain/entities/marketplace_listing.dart`: Added `weightKg` field (double?), updated constructor, fromJson, toJson, copyWith.
- `lib/features/marketplace/presentation/pages/create_listing_page.dart`: Added weight input field with `validateWeight()` (0.1-50kg range), dynamic hint per category.
- `lib/features/marketplace/domain/repositories/fedex_repository.dart`: Added `weightKg` param to `calculateRates()`.
- `lib/features/marketplace/data/repositories/fedex_repository_impl.dart`: Propagated `weightKg` to datasource.
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart`: Added `weightKg` param, sends as `package_weight_kg` to Edge Function.
- `lib/features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart`: Added `weightKg` param.
- `lib/features/marketplace/presentation/pages/checkout_page.dart`: Major refactor - 4-step flow, FedEx dynamic rates, ShippingRateSelector, error/retry handling.
- `lib/core/di/injection_container.dart`: Registered `GetSellerShippingAddress` in `_initMarketplaceFedEx()`.
- `docs/epics/EPIC-15-BUGFIX/TRACKING.md`: Updated S06 status to Done.

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Exception-based error handling (not Either/dartz) | Entire codebase uses try/catch pattern; consistency over functional purity |
| Auto-select cheapest FedEx rate | Better UX - buyer can change but starts with most affordable option |
| No flat-rate fallback on error | Per AC-3: show error + retry button, block checkout to prevent incorrect shipping costs |
| Checkout 4-step flow (was 3) | Dedicated shipping step allows rate selection before review, cleaner UX |
| Constructor injection for testing | Added `calculateShippingRateUseCase` and `getSellerShippingAddress` params to CheckoutPage |

## Challenges

- **Duplicate files**: The codebase has many `"... 2/"` duplicate directories (untracked) that interfere with `flutter analyze` and `flutter test` on parent directories. Worked around by testing specific subdirectories.
- **UserProfileModel constructor**: Test initially used wrong field names (uid, email). Fixed after reading actual model to use correct fields (id, authUserId, role as UserRole enum).
- **Timer leak in test**: `Future.delayed` caused pending timer assertion. Fixed by using `Completer` pattern instead.

## Tests

- `test/features/marketplace/domain/entities/marketplace_listing_test.dart`: 8 new tests for weightKg field
- `test/features/marketplace/domain/usecases/get_seller_shipping_address_test.dart`: 6 tests (address validation)
- `test/features/marketplace/domain/usecases/calculate_shipping_rate_use_case_test.dart`: 1 new test for weightKg propagation
- `test/features/marketplace/presentation/pages/create_listing_page_test.dart`: 8 new tests for weight validation
- `test/features/marketplace/presentation/pages/checkout_page_test.dart`: 17 tests (rewritten for 4-step FedEx flow)

## Notes for Future

- DB migration for `weight_kg` column on `marketplace_listings` table is needed before production deployment.
- Edge Function `fedex-calculate-rate` already supports `package_weight_kg` parameter - no server changes needed.
- `MarketplaceShippingCosts` (flat-rate) class in `sizes_data.dart` is no longer used by checkout but kept for potential offline fallback consideration.
