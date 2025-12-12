# 🎯 MISSION: My Wedding Suite — Sprint 3.4 (Guests)

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter / Supabase Engineer** expert in:
- Flutter (Clean Architecture) feature delivery in production apps
- Supabase Postgres (RLS, triggers, RPC, migrations) + Storage policies
- UX/UI premium using **Lynewed Design System V4** (`lib/core/design/`) and **design unification**

Your approach: **chirurgicale** (minimal changes, preuves, tests, zéro breaking prod).

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED (marketplace wedding pros)
- **Version:** v2.1.0
- **Branch Git:** `develop`
- **Supabase Project ID:** `hekyovgnovhfhmkpfrna` (PROD)

### Current Situation
- My Wedding Suite est en production.
- **Sprint 3.1** terminé: notifications `wedding_*` drainées + navigation OK, storage cover delete policy alignée.
- **Sprint 3.2** terminé (100%): Agenda + Budget Tracker complets (CRUD) + previews sur `MyWeddingPage` + multi-devise sur `wedding_expenses.currency_code`.
- **Sprint 3.3** terminé (100%): Inspirations / Moodboard complet (albums + upload + save/remove depuis feed) + preview Bride/Pro + mode read-only Pro.
- **Décision produit:** **Pro Private Notes est hors-scope** (ne pas implémenter).

### What Has Been Done (Sprints 3.1–3.3 — DONE)
- `AgendaPage` + `AddEventSheet` + CRUD events + preview.
- `BudgetPage` + `AddExpenseSheet` + CRUD expenses + multi-devise + preview.
- `InspirationsPage` + `CreateAlbumSheet` + `AlbumDetailPage` + `SaveToAlbumSheet`.
- Bookmark toggle dans `FeedDetailViewer` (save + remove) + état temps réel.
- Preview Inspirations côté bride (`MyWeddingPage`) et côté pro (`WeddingsHubProPage` détail mariage).

### What Remains (Sprint 3.4)
- Implémenter **Guests** (liste + CRUD + intégration `MyWeddingPage`).

---

## 📁 KEY FILES TO READ FIRST (MANDATORY)

1. `docs/PROJECT.md`
2. `docs/PROJECT_TODO.md`
3. `docs/App/DESIGN_SYSTEM.md` ⭐ (obligatoire avant UI)
4. `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`

### Existing My Wedding module (reference patterns)
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` (patterns sections + previews)
- `lib/features/my_wedding/presentation/pages/agenda_page.dart` (pattern page CRUD)
- `lib/features/my_wedding/presentation/pages/budget_page.dart` (pattern page CRUD)
- `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart` (pattern sheet formulaire)
- `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart` (pattern sheet formulaire)
- `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`
- `lib/features/my_wedding/data/repositories/my_wedding_repository_impl.dart`
- `lib/features/my_wedding/domain/repositories/my_wedding_repository.dart`

---

## 🎯 TASKS TO COMPLETE

### Task 1 — Confirm Supabase schema for Guests
**Priority:** 🔴 HIGH
**Estimated:** 0.5h

**Goal:** verify real DB columns to avoid assumptions.

**Steps:**
1. Inspect table `public.wedding_guests` (via MCP / Supabase schema).
2. Confirm required fields and their types.
3. Confirm RLS policies (bride-only write; pro read? or bride-only read depending on spec).

**Acceptance criteria:**
- [ ] Columns list confirmed and documented in the PR / notes
- [ ] RLS behavior confirmed (who can read/write)

---

### Task 2 — Guests domain/data layer
**Priority:** 🔴 HIGH
**Estimated:** 0.5–1h

**Steps:**
1. Create/confirm entity `WeddingGuest` in `lib/features/my_wedding/domain/entities/`.
2. Add datasource methods in `supabase_my_wedding_datasource.dart`:
   - `getWeddingGuests(weddingId)`
   - `createWeddingGuest(weddingId, name, ... )`
   - `updateWeddingGuest(guestId, ...)`
   - `deleteWeddingGuest(guestId)`
3. Wire repository interface + implementation (RepositoryResult pattern).

**Acceptance criteria:**
- [ ] CRUD methods available in repository
- [ ] Errors handled consistently (RepositoryResult.failure)
- [ ] No breaking changes in existing flows

---

### Task 3 — Guests UI (page + sheets)
**Priority:** 🔴 HIGH
**Estimated:** 1–2 jours

**UI requirements (Design System V4):**
- 20px horizontal padding
- 30px inter-section spacing
- 10px label→input spacing
- Buttons 48px height, radius 0
- Font weights: w400 default, w500 max

**Steps:**
1. Create `GuestsPage`:
   - `lib/features/my_wedding/presentation/pages/guests_page.dart`
   - List guests + empty state + loading + error state
   - Add button to create guest
2. Create `AddGuestSheet`:
   - `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart`
   - Fields per schema (ex: name, role, email/phone if present)
   - Submit creates or updates guest
3. Add long-press options per item (edit/delete) using same pattern as other pages.

**Acceptance criteria:**
- [ ] Bride can add/edit/delete guests
- [ ] UI 100% DS, consistent with Agenda/Budget patterns
- [ ] No pro edit actions (if pros can view, they must be read-only)

---

### Task 4 — Integrate Guests preview in MyWeddingPage
**Priority:** 🟡 MEDIUM
**Estimated:** 0.5h

**Goal:** replace Guests placeholder with a preview (like Agenda/Budget/Inspirations).

**Steps:**
1. Load guests list (or count) in `MyWeddingPage` state.
2. Display up to N items preview + "View all".
3. Navigation to `GuestsPage`.

**Acceptance criteria:**
- [ ] Guests section no longer placeholder
- [ ] Navigation works

---

## ⚠️ CRITICAL RULES

1. ✅ **Design System V4 mandatory**: `import '/core/design/design.dart';`
2. ✅ **Design unification mandatory**: noir/blanc/gris (couleur uniquement pour états)
3. ✅ Clean Architecture: domain/data/presentation
4. ❌ No `print()` — use `SecureLogger`
5. ❌ **NEVER** reuse FlutterFlow legacy components (`lib/compo_finaux/`, `lib/components/`, etc.)
6. **Zéro supposition**: toute affirmation doit être prouvée (code/SQL). Sinon écrire “Non vérifié”.
7. **Pro Private Notes hors scope**: ne pas créer table/UI associée.

---

## 🚫 PITFALLS TO AVOID

- Oublier de vérifier `wedding_guests` schema réel (types/nullable)
- Mélanger UI legacy FlutterFlow avec DS V4
- Introduire des fontWeights > w500
- Ajouter des features hors-scope (ex: Pro Private Notes)

---

## ✅ VALIDATION

When tasks are complete:
1. Run `flutter analyze` (pas de nouvelles erreurs)
2. Build & test iOS simulator: `./scripts/build_and_run.sh`
3. Tests manuels:
   - Create guest
   - Edit guest
   - Delete guest
   - Verify list updates + preview updates
4. Update docs:
   - `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`
   - `docs/PROJECT.md`
5. Commit via `/commit-github-develop`

---

## 🚀 START HERE

1. Lire les fichiers mandatory
2. Confirmer le schema réel `wedding_guests`
3. Proposer un plan (2-5 milestones)
4. Attendre validation avant migrations DB / policy changes
