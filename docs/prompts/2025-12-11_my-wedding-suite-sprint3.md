# 🎯 MISSION: My Wedding Suite - Sprint 3 Implementation

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter/Supabase Developer** expert in:
- Flutter mobile development with Clean Architecture
- Supabase backend (PostgreSQL, RLS, Edge Functions)
- Design System implementation and UI consistency
- Refactoring legacy FlutterFlow code

Your approach: **Surgical precision** - copy existing UI patterns from the codebase to ensure visual consistency. Never invent new styles. Always verify what exists before building.

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Wedding professionals marketplace
- **Version:** v2.1.0
- **Branch:** develop
- **Supabase Project ID:** `hekyovgnovhfhmkpfrna` (PROD)

### Current Situation
Sprint 2 is COMPLETE. The Wedding Onboarding (7 steps) and Overview Card are validated and working. Sprint 3 focuses on completing the My Wedding Page sections that are currently placeholders.

### What Has Been Done (Sprint 2) ✅
- Navbar restructuring (Brides + Pros)
- `MyWeddingPage` with onboarding detection logic
- `WeddingOnboardingWidget` (7 steps, persistence)
- Wedding Overview Card (compact horizontal, 64px badge, full-width)
- Budget range (min/max as int4)
- Search radius optional (checkbox + slider 10-500km)
- Cover image upload to `wedding-covers` bucket
- DB cleanup (removed `_eur` columns, fixed `search_area_coords`)

### What Remains (Sprint 3) ⏳
- Wedding Team Chat Item (group chat access)
- Wedding Team Section (list pros, invite, exclude)
- Header icons (filter MessagesPage, settings menu)
- Sections: Agenda, Budget, Inspirations, Guests, Note for Pros
- WeddingEditSheet
- Cancelled Wedding View

---

## 📁 KEY FILES TO READ FIRST

**MANDATORY - Read before any action:**
1. `docs/PROJECT.md` - Project state
2. `docs/PROJECT_TODO.md` - Task list
3. `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` - **SOURCE OF TRUTH** for Sprint 3 tasks
4. `docs/features/MY_WEDDING_SUITE.md` - Full feature specification
5. `docs/App/DESIGN_SYSTEM.md` - **UI tokens and rules** (1041 lines)

**Current My Wedding Module:**
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` - Main page (VALIDATED)
- `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart` - Onboarding (VALIDATED)
- `lib/features/my_wedding/domain/entities/wedding_overview.dart`
- `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart`
- `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`

**UI PATTERNS TO COPY (CRITICAL):**
- `lib/pages/bride/home_brides/home_brides_widget.dart` - Header pattern, section pattern, tile pattern
- `lib/features/chat/presentation/pages/messages_page.dart` - Chat list pattern
- `lib/features/chat/presentation/widgets/` - Chat UI components

---

## 🎯 TASKS TO COMPLETE

### Task 1: Audit Current State
**Priority:** 🔴 HIGH
**Estimated:** 30 min

**Steps:**
1. Read `my_wedding_page.dart` entirely
2. Identify what's working vs what's placeholder
3. Read `home_brides_widget.dart` to understand UI patterns
4. Confirm Design System tokens in `docs/App/DESIGN_SYSTEM.md`

**Acceptance criteria:**
- [ ] Clear understanding of current page structure
- [ ] List of UI patterns to reuse

---

### Task 2: Wedding Team Chat Item
**Priority:** 🔴 HIGH
**Estimated:** 1-2 hours

**Spec (from MY_WEDDING_SUITE.md):**
- Style similar to public chat room tiles in `home_brides_widget.dart`
- Shows 3-4 circular avatars of pros
- Badge with unread message count
- Number of participants
- Tap → Opens `ChatDetailsPage` for wedding_team room

**Steps:**
1. Create `_buildWeddingTeamChatItem()` method in `my_wedding_page.dart`
2. Copy tile pattern from `_PublicChatRoomTile` in `home_brides_widget.dart`
3. Adapt for wedding team (avatars row instead of cover image)
4. Load wedding team chat room from Supabase
5. Navigate to `ChatDetailsPage` on tap

**Acceptance criteria:**
- [ ] Chat item displays with avatars
- [ ] Unread count badge works
- [ ] Tap navigates to chat

---

### Task 3: Wedding Team Section (Pros List)
**Priority:** 🔴 HIGH
**Estimated:** 2-3 hours

**Current state:** Placeholder "No professionals yet" + button "Invite Professionals"

**Spec:**
- List of pros added to wedding (`wedding_participants` table)
- Each pro tile: photo, name, profession, chat icon
- Tap → `ProDetailsPage`
- Long press → Modal (exclude, report)
- Chat icon → Chat 1-1

**Steps:**
1. Create `_buildWeddingTeamSection()` method
2. Query `wedding_participants` where `status = 'active'`
3. Create `_WeddingTeamProTile` widget (copy pattern from existing tiles)
4. Implement tap → ProDetailsPage
5. Implement long press → show modal
6. Implement chat icon → navigate to 1-1 chat

**Acceptance criteria:**
- [ ] Pros list displays correctly
- [ ] Empty state shows "No professionals yet" + invite button
- [ ] All interactions work

---

### Task 4: Invite Pro Sheet
**Priority:** 🔴 HIGH
**Estimated:** 2 hours

**Spec:**
- Search by name OR list of already contacted pros (priority)
- Select pro → Auto-add to wedding (no validation needed)
- Notification sent to pro

**Steps:**
1. Create `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart`
2. Copy sheet pattern from existing sheets in codebase
3. Implement search field
4. Query contacted pros from `connection_requests` or `chat_rooms`
5. Add pro to `wedding_participants` with status='active'
6. Trigger notification (via existing trigger)

**Acceptance criteria:**
- [ ] Sheet opens from "Invite Professionals" button
- [ ] Search works
- [ ] Pro is added to wedding team
- [ ] Pro appears in list after adding

---

### Task 5: Sections Overview (Agenda, Budget, etc.)
**Priority:** 🟡 MEDIUM
**Estimated:** 1-2 hours

**Current state:** "Coming in Sprint 3" placeholders

**Spec:**
- Agenda section preview (next events)
- Budget section preview (total spent / budget)
- Inspirations section preview (album count)
- Guests section preview (guest count)
- Note for Pros section (editable note)

**Steps:**
1. Create section widgets following `home_brides_widget.dart` pattern
2. Each section: title + preview content + "See all" action
3. For now, show placeholder data or "Coming soon"
4. Navigation to detail pages (can be placeholder pages)

**Acceptance criteria:**
- [ ] All 5 sections visible
- [ ] Consistent styling with rest of app
- [ ] Tap actions defined (even if pages not implemented)

---

### Task 6: WeddingEditSheet
**Priority:** 🟡 MEDIUM
**Estimated:** 2 hours

**Spec:**
- Edit wedding details: name, date, location, budget, visibility, cover image
- Reuse form components from onboarding

**Steps:**
1. Create `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart`
2. Copy form fields from `wedding_onboarding_widget.dart`
3. Pre-populate with current wedding data
4. Save changes to Supabase
5. Refresh page after save

**Acceptance criteria:**
- [ ] Sheet opens from edit icon on Overview Card
- [ ] All fields editable
- [ ] Changes saved correctly

---

## ⚠️ CRITICAL RULES

1. **COPY UI PATTERNS** - Never invent new styles. Find similar UI in codebase and copy.
2. **Design System** - Use `import '/core/design/design.dart';` for ALL UI
3. **Font weights** - w400 default, w500 max (titles only). NEVER > w500
4. **Spacing** - 30px inter-section, 10px label→content, 20px horizontal padding
5. **Colors** - Black, White, Grays only. Color = states only (error, success)
6. **Buttons** - 48px height, 0 radius, w400 text
7. **Items/Cards** - 4px radius
8. **Clean Architecture** - domain/data/presentation layers

---

## 🚫 PITFALLS TO AVOID

- **DON'T** create new Design System widgets unless absolutely necessary
- **DON'T** use FlutterFlow components (`lib/compo_finaux/`, `lib/components/`)
- **DON'T** hardcode strings - use existing patterns
- **DON'T** forget to handle loading and error states
- **DON'T** break existing onboarding or overview card functionality
- **DON'T** use fontWeight > w500

---

## 📋 UI PATTERNS REFERENCE

### Header Pattern (from home_brides_widget.dart)
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
                Text('TITLE', style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0)),
                Row(children: [/* icons */]),
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

### Section Pattern (from home_brides_widget.dart)
```dart
Widget _buildSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('SECTION TITLE', style: LynewedTextStyles.sectionTitle),
      const SizedBox(height: 4.0),
      Text('Subtitle', style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary)),
      const SizedBox(height: 14.0),
      // Content
    ],
  );
}
```

### Tile Pattern (from _PublicChatRoomTile)
```dart
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12.0),
  decoration: BoxDecoration(
    color: LynewedColors.textPrimary, // Black background
    borderRadius: BorderRadius.circular(4.0),
  ),
  child: Row(
    children: [
      // Image 48x48
      ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: CachedNetworkImage(/*...*/),
      ),
      const SizedBox(width: 12.0),
      // Info
      Expanded(child: Column(/*...*/)),
      // Arrow
      const Icon(Icons.arrow_forward_ios, color: LynewedColors.gray300, size: 16.0),
    ],
  ),
)
```

---

## ✅ VALIDATION

When tasks are complete:
1. Run `flutter analyze` - Should have no new errors
2. Test on iOS simulator with `/build-and-run-app-simulator`
3. Test full flow: Home → Wedding tab → My Wedding Page
4. Verify all interactions work
5. Update `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` with completed tasks
6. Use `/update-docs-after-work` to document progress

---

## 🚀 START HERE

1. **Read the mandatory files** listed above (especially `MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md`)
2. **Read `my_wedding_page.dart`** to understand current state
3. **Read `home_brides_widget.dart`** to understand UI patterns to copy
4. **Confirm your understanding** of Sprint 3 tasks
5. **Propose your action plan** with order of implementation
6. **Wait for validation** before executing

---

## 📊 Sprint 3 Checklist (from IMPLEMENTATION_PLAN)

### 3.1 Page Skeleton + Routing ✅ DONE
### 3.2 Wedding Countdown Card ✅ DONE (missing WeddingEditSheet)
### 3.3 Wedding Team Chat Item ⏳ TODO
### 3.4 Wedding Team Section ⏳ TODO (placeholder exists)
### 3.5 Header avec Icônes ⏳ TODO (basic header exists)
### 3.6 Sections Overview ⏳ TODO (2 placeholders exist)
### 3.7 Cancelled Wedding View ⏳ TODO

---

**Generated:** 2025-12-11  
**For:** My Wedding Suite Sprint 3  
**Previous Sprint:** Sprint 2 (Onboarding + Overview Card) - VALIDATED
