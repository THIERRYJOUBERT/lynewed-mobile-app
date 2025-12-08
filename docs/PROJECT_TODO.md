# PROJECT TODO - LYNEWED V1+

**Last Updated:** 2025-12-08  
**Version:** v5.0 (Post-V1 Cleanup)  
**Status:** V1 Complete - Planning next phase

---

## ✅ V1 COMPLETED MODULES

### Map Module ✅
- 100% refactored from FlutterFlow
- 63/63 tests passing
- Clean Architecture implemented

### Chat Module ✅
- Audio player/recorder refactored
- Contact request flow complete
- Moderation (report, block, unblock)
- Design System v3 applied

### Notifications System ✅
- 7/7 types functional
- < 2s delivery time
- Settings per user

### Feed MVP ✅
- Market segmentation IN/GLOBAL
- Images V2 (multi-format)
- 6 new professions added

### Cleanup ✅
- 135 files deleted
- 40,588 lines removed
- Flutter Analyze: 523 → 306 issues (-42%)

---

# PRIORITY 1 — IMMEDIATE TASKS

## 1.1 TestFlight Deployment
- [ ] Final testing on physical devices
- [ ] App Store Connect preparation
- [ ] Beta distribution setup

## 1.2 ProDetails Refactoring
- [ ] YouTube/Vimeo player widget
- [ ] FixedLocations with id/label struct
- [ ] Images V2 integration
- [ ] clickedLocationId parameter

## 1.3 Feed Improvements
- [ ] Ambassador system (`ambassador` boolean column)
- [ ] Wed of the Week for videographers
- [ ] Feed visible for Pro users (navbar adjustment)

---

# PRIORITY 2 — UX & SETTINGS

## 2.1 Onboarding
- [ ] Review complete flow
- [ ] iOS permissions handling (location, notifications, gallery)
- [ ] User preferences persistence

## 2.2 Navigation
- [ ] Fix navback bugs
- [ ] Remove "reset password" for Pro (CRM handles it)

## 2.3 Map Enhancements
- [ ] Show initials if pro has no avatar_url

---

# PRIORITY 3 — TESTING & VALIDATION

## 3.1 Testing
- [ ] End-to-end tests (Bride + Pro workflows)
- [ ] Performance testing
- [ ] RLS policies audit

---

# PRIORITY 4 — GLOBAL TASKS

## 4.1 Design System Expansion
- [ ] Apply to all remaining pages
- [ ] Document all components

## 4.2 Internationalization (i18n)
- [ ] Define supported languages (FR, EN, IT, DE, IN, ES)
- [ ] Implement i18n system
- [ ] Complete translations

## 4.3 Enum Cleanup
- [ ] Remove `trial` from subscriptionTierType
- [ ] Rename connectionRequestSource values
- [ ] Sync Flutter enums with Supabase

## 4.4 Security & Analytics
- [ ] Security audit
- [ ] User analytics implementation
- [ ] Performance monitoring

---

# PHASE 2 — FUTURE (January 2025+)

## Android
- [ ] Code standardization for Android
- [ ] Play Store preparation
- [ ] Google Places SDK Android security (SHA-1)

## Vision Features
- [ ] Photo/video → Reels transformation
- [ ] Live streaming
- [ ] QR code sharing for guests

---

**Note:** This document tracks future work. For V1 completion details, see `REFACTORING_REPORT_MVP_TO_V1.md`.
