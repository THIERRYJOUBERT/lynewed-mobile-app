# 🎯 MISSION: My Wedding Suite — Sprint 3.2 (Agenda + Budget Tracker)

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter / Supabase Engineer** expert in:
- Flutter (Clean Architecture) refactoring and production-safe feature delivery
- Supabase Postgres (RLS, triggers, RPC, migrations) + Storage policies
- UX/UI premium using **Lynewed Design System V4** (`lib/core/design/`)

Your approach: **chirurgicale** (minimal changes, preuves, tests, zéro breaking prod).

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED (marketplace wedding pros)
- **Version:** v2.1.0
- **Branch Git:** `develop`
- **Supabase Project ID:** `hekyovgnovhfhmkpfrna` (PROD)

### Current Situation
- My Wedding Suite (Phase 1 + Team + Weddings Hub Pro) est en place.
- **Sprint 3.1 est terminé**: notifications wedding_* drainées + personnalisation UI + navigation OK, storage delete policy alignée.
- Sprint 3.2 vise à remplacer les sections placeholder **Agenda** et **Budget** par des écrans complets + CRUD.

### What Has Been Done (Sprint 3.1 — DONE)
- Edge Function `notifications_outbox_drain` supporte `wedding_pro_added`, `wedding_pro_excluded`, `wedding_pro_left`, `wedding_cancelled`.
- Enum DB `notificationType` étendu: `weddingProAdded`, `weddingProExcluded`, `weddingProLeft`, `weddingCancelled`.
- RPC `get_formatted_notifications` mise à jour (titres/messages FR/EN).
- Navigation in-app sur tap corrigée (routeNames corrects + `weddingId` param + auto-open wedding detail pro).
- Upload cover image aligné sur policy delete: path `auth.uid()/weddingId_timestamp.jpg`.

### What Remains (Sprint 3.2)
- **Agenda full page** (list + add/edit/delete + public/private).
- **Budget Tracker full page** (list + add/edit/delete + totals header + statuses).
- Rebrancher depuis `MyWeddingPage` (remplacer placeholders par navigation).

---

## 📁 KEY FILES TO READ FIRST (MANDATORY)

1. `docs/PROJECT.md`
2. `docs/PROJECT_TODO.md`
3. `docs/App/DESIGN_SYSTEM.md` ⭐ (obligatoire avant UI)
4. `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`

### Existing My Wedding module (reference patterns)
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart`
- `lib/features/my_wedding/presentation/sheets/` (patterns sheets)
- `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`

### Design System V4 (mandatory reuse)
- **Doc:** `docs/App/DESIGN_SYSTEM.md` (authoritative)
- **Implementation:** `lib/core/design/`
- **Import unique (screens/components):**
  ```dart
  import '/core/design/design.dart';
  ```

**UI constraints (non negotiable):**
- **Font weights:** w400 default, w500 max (except CTA if already validated elsewhere)
- **Spacing:** 30px inter-sections, 10px label→content
- **Sheets:** radius top 24px, padding horizontal 20px
- **Buttons:** height 48px, radius 0, text w400
- **Colors:** black/white/grays (color only for states)

**Reuse patterns:**
- Use the **same page structure** as `MyWeddingPage` (header, sections, list items, bottom sheets).
- Use existing **sheet layouts** in `lib/features/my_wedding/presentation/sheets/` (title, content spacing, primary CTA).
- Prefer **Design System widgets** (text fields, buttons, sheets) over custom styling.
- If a new reusable component is needed:
  - Create it in `lib/features/my_wedding/presentation/widgets/` (feature-scoped)
  - Or `lib/core/design/widgets/` only if cross-feature reusable

### DB tables (already exist per audit)
- `public.wedding_events`
- `public.wedding_expenses`

---

## 🎯 TASKS TO COMPLETE

### Task 1 — Agenda Page (CRUD)
**Priority:** 🔴 HIGH
**Estimated:** 1-2 jours

**Requirements**
- Page `AgendaPage` (Design System V4)
- Liste des événements (tri par date)
- Actions:
  - create (AddEventSheet)
  - edit
  - delete
  - toggle `is_public`

**Implementation steps**
1. Créer `AgendaPage`:
   - `lib/features/my_wedding/presentation/pages/agenda_page.dart`
2. Créer `AddEventSheet`:
   - `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart`
3. Implémenter datasource/repository methods dans:
   - `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart`
4. Brancher navigation depuis `MyWeddingPage` (remplacer placeholder Agenda).

**Challenge (questions à trancher avant d'écrire beaucoup de UI):**
1. L'agenda doit-il afficher les événements **passés** ? (sinon filtrer `event_date >= today`)
2. Quel est le comportement attendu côté pro pour les événements `is_public=true` ? (lecture-only)
3. Faut-il gérer une timezone spécifique (wedding timezone) ou utiliser UTC+locale device ?

**Acceptance criteria**
- [ ] Bride peut créer/modifier/supprimer des événements
- [ ] Toggle public/privé persiste en DB
- [ ] UI conforme DS (spacing 30/10, weights <= w500)

---

### Task 2 — Budget Tracker Page (CRUD + Totaux)
**Priority:** 🔴 HIGH
**Estimated:** 1-2 jours

**Requirements**
- Page `BudgetPage`
- Liste des dépenses (tri par date)
- Totaux: budget (min/max/currency) vs total dépenses
- Statuts: `pending`, `partial`, `paid` (si déjà en DB; sinon fallback sans migration)
- Actions: create/edit/delete (AddExpenseSheet)

**Implementation steps**
1. Créer `BudgetPage`:
   - `lib/features/my_wedding/presentation/pages/budget_page.dart`
2. Créer `AddExpenseSheet`:
   - `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart`
3. Datasource CRUD expenses:
   - `supabase_my_wedding_datasource.dart`
4. Brancher depuis `MyWeddingPage` (placeholder Budget).

**Challenge (questions à trancher avant d'implémenter les statuts):**
1. Le status expense existe-t-il déjà en DB ? (sinon **pas de migration** sans validation)
2. Le total doit-il être calculé sur:
   - toutes les dépenses
   - ou seulement `paid`
   - ou grouped par status
3. La devise affichée doit être celle du wedding (`currency`) (source of truth), pas une conversion.

**Acceptance criteria**
- [ ] Bride peut créer/modifier/supprimer des dépenses
- [ ] Totaux affichés correctement
- [ ] Aucun breaking sur onboarding/budget_min/budget_max existants

---

### Task 3 — Validation & Non-regression
**Priority:** 🟡 MEDIUM

**Checklist**
1. `flutter analyze` (pas de nouvelles erreurs)
2. Smoke test iOS simulator
3. Vérifier RLS: bride only pour CRUD wedding_events/wedding_expenses
4. Test manuel minimal:
   - Create/edit/delete agenda event
   - Toggle public
   - Create/edit/delete expense
   - Totals update
5. Update docs (PROJECT.md / PROJECT_TODO.md) si milestone atteinte

---

## ⚠️ CRITICAL RULES

1. ❌ **NEVER** reuse FlutterFlow legacy components (`lib/compo_finaux/`, `lib/components/` legacy, etc.)
2. ✅ **Design System V4 mandatory**: `import '/core/design/design.dart';`
3. ✅ Clean Architecture: domain/data/presentation
4. ❌ No `print()` — use `SecureLogger`
5. **Zéro supposition**: toute affirmation doit être prouvée (code/SQL). Sinon écrire “Non vérifié”.

---

## 🚫 PITFALLS TO AVOID

- Introduire des styles ad-hoc (doit utiliser tokens DS)
- Créer des routes/deeplinks non existants
- Ajouter une migration DB inutile (préférer utiliser schema existant)
- Régression sur MyWedding onboarding / Weddings Hub Pro
- Implémenter un écran “Agenda/Budget” en dehors de `lib/features/my_wedding/` (respecter Clean Architecture)
- Duplicater des patterns existants (réutiliser les sheets + spacing DS)

---

## 🚀 START HERE

1. Lire les fichiers mandatory
2. Confirmer le schema réel des tables `wedding_events` et `wedding_expenses` (colonnes, RLS)
3. Proposer un plan (2-5 milestones)
4. Attendre validation avant migrations DB
