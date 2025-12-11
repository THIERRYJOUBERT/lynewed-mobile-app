# 🎯 MISSION: My Wedding Suite - Sprint 2 Onboarding

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter/Supabase Developer** expert in:
- Flutter mobile development with Clean Architecture
- Supabase backend (PostgreSQL, RLS, triggers)
- Multi-step onboarding flows with state persistence
- Design System implementation and UI consistency

Your approach: **Surgical precision** - minimal changes, maximum impact. You copy existing UI patterns exactly to ensure visual consistency.

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Wedding professionals marketplace
- **Version:** v2.0.0
- **Branch:** develop
- **Supabase Project ID:** hekyovgnovhfhmkpfrna (PROD)
- **Status:** 🚀 V1 IN PRODUCTION with active users

### Current Situation
Sprint 1 of "My Wedding Suite" is **COMPLETE**:
- ✅ Backend: 6 tables, 14 RLS policies, 7 triggers, 3 storage buckets
- ✅ Flutter: 4 Design System widgets, navbar restructured, placeholder pages
- ✅ UI corrected to match existing app design patterns

Sprint 2 focuses on the **9-step onboarding flow** for brides to create their wedding.

### What Has Been Done (Sprint 1)
- Tables: `wedding_guests`, `inspiration_albums`, `saved_posts`, `album_images`, `wedding_events`, `wedding_expenses`
- Columns added to `weddings`: `cover_image_url`, `note_for_pros`, `cancelled_at`, `onboarding_step`, `guest_count`
- Columns added to `wedding_participants`: `left_reason`, `left_at`, `excluded_reason`, `excluded_at`, `is_muted`, `joined_at`
- Chat support for `wedding_team` type with auto-creation trigger
- Widgets: `LynewedCountdownCard`, `LynewedTeamChatItem`, `LynewedProTile`, `LynewedSectionHeader`
- Pages: `MyWeddingPage`, `WeddingsHubProPage` (placeholders with correct UI)
- Navbar: "Wedding" tab for brides, "Weddings" tab for pros

### What Remains (Sprint 2)
- Clean Architecture module structure for `my_wedding`
- 7 domain entities
- Repository interface + implementation
- Supabase datasource
- 6 usecases
- 9 onboarding screens with persistence

---

## 📁 KEY FILES TO READ FIRST

**MANDATORY - Read before any action:**
1. `docs/PROJECT.md` - Project state
2. `docs/App/DESIGN_SYSTEM.md` - ⭐ **AUTHORITATIVE UI REFERENCE** (1041 lines)
3. `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` - Sprint 2 details (lines 261-321)
4. `docs/features/MY_WEDDING_SUITE.md` - Functional specification

**Existing UI patterns to copy:**
- `lib/pages/bride/home_brides/home_brides_widget.dart` - Header pattern (110px, divider, 18px title)
- `lib/pages/onboarding/onboarding_brides_wizard/onboarding_brides_wizard_widget.dart` - Existing onboarding flow

**Module code:**
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` - Current placeholder (Sprint 1)
- `lib/features/map/` - Reference Clean Architecture module (63 tests)
- `lib/features/chat/` - Reference Clean Architecture module

---

## 🎨 CRITICAL UI CONSTRUCTION RULES

### ⚠️ MANDATORY: Copy Existing Patterns

**NEVER create UI from scratch.** Always:
1. Find an existing screen/sheet with similar layout
2. Copy its structure exactly
3. Adapt content only

### Header Pattern (from `home_brides_widget.dart`)
```dart
Widget _buildHeader() {
  return Align(
    alignment: Alignment.topCenter,
    child: Container(
      width: double.infinity,
      height: 110.0,
      decoration: const BoxDecoration(color: LynewedColors.background),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TITLE',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
                ),
                // Icons here (32x32 containers, 24px icons)
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          const Divider(height: 1.0, thickness: 1.0, color: LynewedColors.gray200),
        ],
      ),
    ),
  );
}
```

### Page Layout Pattern (Stack-based)
```dart
Scaffold(
  backgroundColor: LynewedColors.background,
  body: SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Stack(
      children: [
        // Main content with padding for header (110) and navbar (84)
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 110.0, 20.0, 84.0),
          child: SingleChildScrollView(...),
        ),
        // Bottom Navigation
        Align(
          alignment: Alignment.bottomCenter,
          child: const NavBarBridesWidget(number: 3),
        ),
        // Header
        _buildHeader(),
      ],
    ),
  ),
)
```

### Icon Button Pattern (32x32 container)
```dart
Widget _buildHeaderIcon({required IconData icon, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 32.0,
      height: 32.0,
      child: Center(
        child: Icon(icon, color: LynewedColors.textPrimary, size: 24.0),
      ),
    ),
  );
}
```

### Design Tokens
| Element | Value |
|---------|-------|
| Header height | 110px |
| Navbar height | 84px |
| Horizontal padding | 20px |
| Title style | `LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0)` |
| Divider color | `LynewedColors.gray200` |
| Icon size | 24px in 32x32 container |
| Inter-section spacing | 30px |
| Label→content spacing | 10px |
| Font weights | w300 (inputs), w400 (default), w500 (titles max) |

---

## 🎯 TASKS TO COMPLETE

### Task 1: Clean Architecture Module Structure
**Priority:** 🔴 HIGH
**Estimated:** 2 hours

Create the module structure:
```
lib/features/my_wedding/
├── domain/
│   ├── entities/
│   │   ├── wedding_overview.dart
│   │   ├── wedding_guest.dart
│   │   ├── wedding_event.dart
│   │   ├── wedding_expense.dart
│   │   ├── inspiration_album.dart
│   │   ├── saved_post.dart
│   │   └── album_image.dart
│   ├── repositories/
│   │   └── my_wedding_repository.dart
│   └── usecases/
│       ├── get_wedding_overview.dart
│       ├── get_wedding_team.dart
│       ├── invite_pro_to_wedding.dart
│       ├── exclude_pro_from_wedding.dart
│       ├── save_post_to_album.dart
│       └── complete_onboarding.dart
├── data/
│   ├── datasources/
│   │   └── supabase_my_wedding_datasource.dart
│   └── repositories/
│       └── my_wedding_repository_impl.dart
└── presentation/
    └── pages/
        ├── my_wedding_page.dart (exists)
        └── wedding_onboarding_page.dart (new)
```

**Acceptance criteria:**
- [ ] 7 entity files created with proper fields
- [ ] Repository interface with all methods
- [ ] Datasource with Supabase queries
- [ ] Repository implementation

### Task 2: Onboarding Datasource Methods
**Priority:** 🔴 HIGH
**Estimated:** 2 hours

Implement in `supabase_my_wedding_datasource.dart`:
- `createWedding(date, location)` - Called at step 2
- `updateOnboardingData(weddingId, data)` - Steps 3-8
- `completeOnboarding(weddingId)` - Step 9 (sets `onboarding_step = null`)
- `getMyWedding()` - Get current user's wedding
- `getContactedPros()` - For pro invitation step

**Acceptance criteria:**
- [ ] All 5 methods implemented
- [ ] Proper error handling
- [ ] Uses existing Supabase patterns from chat/map modules

### Task 3: Onboarding Page (9 Steps)
**Priority:** 🔴 HIGH
**Estimated:** 4 hours

Create `wedding_onboarding_page.dart` with 9 steps:

| Step | Content | Required | Skip |
|------|---------|----------|------|
| 1 | Welcome | - | - |
| 2 | Date picker | ✅ | No |
| 3 | Location (Google Places) | ✅ | No |
| 4 | Select professionals | ❌ | Yes |
| 5 | Guest count | ❌ | Yes |
| 6 | Budget range | ❌ | Yes |
| 7 | Visibility settings | ❌ | Yes |
| 8 | Features preview | - | - |
| 9 | Done/Celebration | - | - |

**UI Requirements:**
- Copy existing onboarding wizard pattern from `onboarding_brides_wizard_widget.dart`
- Progress indicator at top
- Back button (except step 1)
- Skip button for optional steps
- Consistent button styles (48px height, 0 radius)

**Persistence Logic:**
- Step 2: Create wedding record with `onboarding_step = 2`
- Steps 3-8: Update wedding with `onboarding_step = current_step`
- Step 9: Set `onboarding_step = null` (triggers chat creation)

**Acceptance criteria:**
- [ ] 9 step screens implemented
- [ ] Progress indicator working
- [ ] Back/Skip navigation working
- [ ] Data persists to Supabase
- [ ] Can resume from any step
- [ ] Step 9 triggers wedding_team chat creation

### Task 4: MyWeddingPage Routing Logic
**Priority:** 🟡 MEDIUM
**Estimated:** 1 hour

Update `my_wedding_page.dart` with conditional routing:
- No wedding → Show onboarding
- `onboarding_step` not null → Resume onboarding at that step
- `onboarding_step` null → Show wedding overview (Sprint 3)

**Acceptance criteria:**
- [ ] Routing logic implemented
- [ ] Smooth transitions between states
- [ ] Loading state while checking

---

## ⚠️ CRITICAL RULES

1. **NEVER create UI from scratch** - Always copy existing patterns
2. **Design System** - Use `lib/core/design/` for all UI, import via `import '/core/design/design.dart';`
3. **Clean Architecture** - domain/data/presentation layers strictly separated
4. **Font weights** - w400 default, w500 max for titles, NEVER w600+
5. **Spacing** - 30px inter-section, 10px label→content, 20px horizontal margins
6. **Header** - 110px height, divider at bottom, 18px title
7. **Buttons** - 48px height, 0 radius, w400 text
8. **No print()** - Use SecureLogger for debugging
9. **French communication** - Respond in French, code in English

---

## 🚫 PITFALLS TO AVOID

- ❌ Creating custom header styles (copy `home_brides` exactly)
- ❌ Using SafeArea instead of Stack layout with fixed paddings
- ❌ Using bottomNavigationBar property (use Stack with Align)
- ❌ Font weights > w500
- ❌ Hardcoding colors instead of using LynewedColors
- ❌ Creating new components when Design System widgets exist
- ❌ Skipping the trigger test for wedding_team chat creation

---

## ✅ VALIDATION

When tasks are complete:
1. Run `flutter analyze` - Should have no new errors
2. Build and test on iOS simulator: `./scripts/build_and_run.sh`
3. Test complete onboarding flow (9 steps)
4. Verify wedding_team chat is created after step 9
5. Verify can resume onboarding from any step
6. Update `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` - Mark Sprint 2 tasks as `[x]`
7. Use `/commit-github-develop` to commit changes

---

## 🚀 START HERE

1. Read the mandatory files listed above (especially DESIGN_SYSTEM.md)
2. Study `onboarding_brides_wizard_widget.dart` for existing onboarding patterns
3. Study `home_brides_widget.dart` for header/layout patterns
4. Confirm your understanding of the 9 onboarding steps
5. Propose your action plan
6. Wait for validation before executing
