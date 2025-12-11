# PROJECT TODO - LYNEWED V1+

**Last Updated:** 2025-12-11  
**Version:** v6.0 (Sprint 2 Complete)  
**Status:** My Wedding Suite Phase 1 Complete - Sprint 3 Planning

---

## ✅ Sprint 2 - COMPLETED (2025-12-11)

### My Wedding Suite - Phase 1
- [x] Navbar restructuring (Brides + Pros) ✅
- [x] My Wedding Page with onboarding detection ✅
- [x] Wedding Onboarding Widget (7 steps, persistence) ✅
- [x] Wedding Overview Card (compact horizontal design) ✅
- [x] Budget range selection (min/max as int4) ✅
- [x] Search radius optional (checkbox + slider 10-500km) ✅
- [x] Cover image upload (wedding-covers bucket) ✅
- [x] DB cleanup (removed budget_min_eur/budget_max_eur) ✅
- [x] search_area_coords now populated correctly ✅

### Technical Decisions Made
- **Budget storage:** Values stored in selected currency (not converted to USD)
- **search_area_coords:** Same as venue_coords, used for PostGIS spatial queries
- **Cover image bucket:** `wedding-covers` (public)
- **Onboarding steps:** 7 (was 9 in spec, simplified: removed Welcome + Features Preview)

---

## ⏳ Sprint 3 - My Wedding Suite Phase 2

### Wedding Team Section
- [ ] Wedding Team list (pros added to wedding)
- [ ] Invite Pro sheet (search + add)
- [ ] Pro tile with chat icon
- [ ] Exclude pro functionality
- [ ] Wedding Team Chat item (group chat access)

### Placeholder Sections (Coming Soon)
- [ ] Agenda section (todo list with dates)
- [ ] Budget section (expense tracking)
- [ ] Inspirations section (moodboard albums)

### Weddings Hub Pro
- [ ] WeddingsHubProPage (list of client weddings)
- [ ] WeddingClientDetailPage (pro view of wedding)
- [ ] Pro can leave wedding with reason
- [ ] Pro private notes per wedding

---

## ⏳ Sprint 4 - My Wedding Suite Phase 3

### Content Features
- [ ] Moodboard / Inspirations (albums Wedding + Private)
- [ ] Save post to album from Feed
- [ ] Upload images from gallery to album
- [ ] Documents in chats (PDF support)

### Planning Features
- [ ] Agenda full page (events list)
- [ ] Budget full page (expenses list)
- [ ] Note for Pros (single note, max 1000 chars)
- [ ] Wedding Guests list (anticipation)

---

## Android
- [ ] Code standardization for Android
- [ ] Play Store preparation
- [ ] Google Places SDK Android security (SHA-1)

## Vision Features
- [ ] Photo/video → Reels transformation
- [ ] Live streaming
- [ ] QR code sharing for guests

---

## 📝 Technical Notes

### Database Schema Changes (Sprint 2)
```sql
-- Columns removed from weddings table:
-- budget_min_eur (numeric) - REMOVED
-- budget_max_eur (numeric) - REMOVED

-- Budget now stored in selected currency:
-- budget_min (int4) - Min budget in user's currency
-- budget_max (int4) - Max budget in user's currency
-- currency (text) - Currency code (default 'EUR')

-- search_area_coords now populated:
-- Same value as venue_coords, used for PostGIS spatial index
```

### New Files Created (Sprint 2)
```
lib/features/my_wedding/
├── domain/
│   ├── entities/wedding_overview.dart
│   └── repositories/my_wedding_repository.dart
├── data/
│   ├── datasources/supabase_my_wedding_datasource.dart
│   └── repositories/my_wedding_repository_impl.dart
└── presentation/
    ├── pages/my_wedding_page.dart
    └── widgets/wedding_onboarding_widget.dart
```

---

**Note:** For full My Wedding Suite specification, see `docs/features/MY_WEDDING_SUITE.md`.
