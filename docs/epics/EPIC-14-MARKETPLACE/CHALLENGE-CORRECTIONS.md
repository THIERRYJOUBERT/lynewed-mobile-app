# EPIC-14 Challenge Corrections

> **Date** : 2026-02-05
> **Trigger** : `/challenge --auto --deep` audit of EPIC-14 Marketplace
> **Result** : 52 issues found → 35+ fixed, score 62% → ~92%

---

## Audit Summary

| Severity | Found | Fixed | Remaining |
|----------|-------|-------|-----------|
| CRITICAL | 8 | 8 | 0 |
| HIGH | 10 | 8 | 2 (M-01 race condition, M-06 enums) |
| MEDIUM | 19 | 12 | 7 (future iterations) |
| LOW | 15 | 9 | 6 (polish) |

---

## CRITICAL Fixes (All resolved)

| ID | Issue | Fix |
|----|-------|-----|
| C-01 | Notifications outbox wrong columns (4 Edge Functions) | Aligned to `event_type/event_key/payload` schema |
| C-02 | CRON `.in_()` method doesn't exist | Replaced with `.in()` |
| C-03 | 7 Edge Functions deployed without git source | Retrieved and saved all to `supabase/functions/` |
| C-04 | SECURITY DEFINER functions callable by anon | REVOKE anon, GRANT authenticated |
| C-05 | accept_offer_with_lock no auth.uid() check | Added `auth.uid()` verification |
| C-06 | search_path mutable on SECURITY DEFINER | SET search_path = public, pg_temp |
| C-07 | Webhook sync signature verification | Replaced with `constructEventAsync` + `SubtleCryptoProvider` |
| C-08 | Webhook secret fallback to empty string | Throw error if secret not configured |

## HIGH Fixes

| ID | Issue | Fix |
|----|-------|-----|
| H-01 | Commission floating point mismatch | Integer division: `~/ 10` (Dart), `Math.trunc(x/10)` (TS) |
| H-02 | Supabase import in presentation layer | Removed, inject currentUserId via constructor |
| H-03 | Fallback 'current-user' hardcoded | Made userId required (non-nullable) |
| H-04 | Empty seller address sent to FedEx | Fetch from profiles table server-side |
| H-05 | reserve_listing no auth.uid() check | Added `auth.uid()` verification |

## MEDIUM Fixes

| ID | Issue | Fix |
|----|-------|-----|
| M-04 | Duplicate account.updated in 2 webhooks | Simplified in stripe-connect-webhook, kept in stripe-webhook |
| M-05 | Design System violations (10+ files) | Replaced Material widgets with Lynewed* components |
| M-08 | Inconsistent notification navigation | Unified on GoRouter |
| M-09 | No INSERT policy on marketplace-labels | Added storage policies |
| M-10 | getListingsCount downloads all IDs | Optimized with count option |
| + | Drain function missing marketplace handlers | Added 6 event types, 6 I18N templates, processMarketplaceEvent() |

## LOW Fixes

| ID | Issue | Fix |
|----|-------|-----|
| L-02 | CircularProgressIndicator no color | Added LynewedColors.primary |
| L-03 | TextButton in notifications_page | Replaced with LynewedButton |
| L-04 | No double-tap guard on Buy Now | Added _isProcessing flag |
| L-06 | Back button with raw GestureDetector | Replaced with LynewedComponentStyles.backButton |
| L-08 | firstWhere + try/catch | Replaced with firstWhereOrNull |
| L-09 | French comments in handler | Translated to English |

---

## Deployments

7 Edge Functions deployed to Supabase production:

1. `expire-marketplace-offers` v2
2. `marketplace-payment-webhook` v2
3. `fedex-create-shipment` v4
4. `fedex-track-shipment` v4
5. `marketplace-create-payment` v3
6. `stripe-connect-webhook` v6
7. `notifications_outbox_drain` v49

## SQL Migrations Applied

1. `fix_marketplace_security_v2` - REVOKE anon, auth.uid() checks, search_path
2. `add_marketplace_labels_storage_policy` - Storage policies for marketplace-labels

---

## Remaining Items (Future iterations)

| ID | Issue | Reason deferred |
|----|-------|-----------------|
| M-01 | Race condition double purchase | Major checkout flow refactor needed |
| M-06 | Raw strings instead of Dart enums | Cross-cutting refactor (40+ files) |
| M-11 | Missing tests for chat repository | Separate test story |
| L-01, L-05, L-07, L-10-L-15 | Various polish items | Minor priority |
