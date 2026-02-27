# Implementation Notes - S10 Minor Fixes Batch

> Completed: 2026-02-16
> Commit: 8d44674
> Mode: autonomous

## Summary

Three minor fixes grouped in one story: hide Marketplace tab for professionals in the messages page, fix name fallback in marketplace conversations from "Unknown" to "User", and standardize border radius on marketplace product images to 4px.

## Files Changed

### Created
- `test/features/chat/presentation/pages/messages_page_test.dart`: 3 tests for Marketplace chip conditional visibility
- `test/features/marketplace/data/repositories/supabase_marketplace_chat_repository_test.dart`: 5 tests for name fallback logic

### Modified
- `lib/core/design/lynewed_borders.dart`: Added `borderRadiusXs` constant (4px)
- `lib/features/chat/presentation/bloc/conversations_cubit.dart`: Added `@visibleForTesting testState` setter for dependency injection in tests
- `lib/features/chat/presentation/pages/messages_page.dart`: Wrapped build with BlocBuilder<AuthCubit> to condition Marketplace chip on user role; added optional `notifier` parameter for testability
- `lib/features/marketplace/data/repositories/supabase_marketplace_chat_repository.dart`: Added `extractDisplayName` static method with fallback chain; added `role` to profile select query
- `lib/features/marketplace/presentation/widgets/listing_card.dart`: Changed card container borderRadius from 12 to `LynewedBorders.borderRadiusXs`
- `lib/features/marketplace/presentation/pages/seller_dashboard_page.dart`: Changed card container and thumbnail borderRadius to `LynewedBorders.borderRadiusXs`
- `test/features/marketplace/presentation/widgets/listing_card_test.dart`: Added border radius verification test

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| BlocBuilder<AuthCubit> over Supabase query | Clean Architecture pattern - reuse existing auth state instead of direct DB query |
| `extractDisplayName` as static method | Testable without mocking Supabase; reusable |
| `hide AuthState` from supabase_flutter | Avoid name conflict with app's AuthState |
| `auth_entities.UserRole` prefix | Avoid conflict with chat domain's UserRole enum |
| Optional `notifier` param on MessagesPage | Enable dependency injection for tests without modifying production flow |

## Challenges

- **Import conflicts**: Both `supabase_flutter` and our `auth_state.dart` export `AuthState`. Both `auth/domain` and `chat/domain` export `UserRole`. Resolved with `hide` and import alias.
- **No `first_name` column**: The DB profiles table only has `full_name`, not `first_name` as the story initially suggested. Simplified fallback chain to `full_name` -> `'User'`.
- **ConversationsNotifier testability**: ChangeNotifier with private `_state` field. Added `@visibleForTesting` setter instead of refactoring to Cubit.

## Tests

- `messages_page_test.dart`: Chip visibility for pro (hidden), bride (visible), initial state (visible)
- `supabase_marketplace_chat_repository_test.dart`: extractDisplayName with full_name, null, empty, null profile, missing key
- `listing_card_test.dart`: borderRadius = 4 on card container

## Notes for Future

- The `generate_label_button_test.dart` has a pre-existing compilation failure (unrelated to S10)
- Consider migrating ConversationsNotifier to Cubit for better testability in the future
