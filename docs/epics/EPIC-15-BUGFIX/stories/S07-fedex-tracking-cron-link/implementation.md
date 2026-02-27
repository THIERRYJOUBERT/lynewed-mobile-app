# Implementation Notes - S07

> Completed: 2026-02-16
> Commit: 10489d4
> Mode: auto

## Summary

Added "Track on FedEx" link for sellers in the transaction detail page. The link opens the FedEx tracking website in an external browser. This mirrors the existing buyer-side implementation in `buyer_tracking_timeline.dart`.

## Files Changed

### Modified
- `lib/features/marketplace/presentation/pages/transaction_detail_page.dart`: Added `_buildTrackingLinkSection()` widget and `_openFedExTracking()` method. Added `url_launcher` import. Section is conditionally rendered when `fedexTrackingNumber` is not null/empty.
- `test/features/marketplace/presentation/pages/transaction_detail_page_test.dart`: Added 3 new tests for seller tracking link. Adjusted existing test from `findsOneWidget` to `findsWidgets` for tracking number text (now appears in both ShippingLabelWidget and tracking section).
- `docs/epics/EPIC-15-BUGFIX/TRACKING.md`: Updated S07 status to Done, 7/10 stories.
- `docs/epics/EPIC-15-BUGFIX/stories/S07-fedex-tracking-cron-link.md`: Status updated to Done.

## Technical Decisions

| Decision | Rationale |
|----------|-----------|
| Separate section (not inside ShippingLabelWidget) | Story spec requires a "Package Tracking" section. Keeps concerns separated - label management vs tracking link. |
| Pattern copied from buyer_tracking_timeline.dart | Consistency across buyer/seller UX. Same card layout, same link style. |
| No Edge Function deployment | Story v3 simplified scope - cron job removed, deployment marked optional for future use. |

## Tests

- `transaction_detail_page_test.dart`: 3 new tests
  - Shows tracking section when tracking number exists
  - Hides tracking section when tracking number is null
  - Hides tracking section for paid status without tracking
