# 🎯 MISSION: My Wedding Suite — Sprint 3.3 (Inspirations / Moodboard)

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
- My Wedding Suite est en production (Phase 1 + Team + Weddings Hub Pro).
- **Sprint 3.1** terminé: notifications `wedding_*` drainées + navigation OK, storage cover delete policy alignée.
- **Sprint 3.2** terminé (100%): Agenda + Budget Tracker complets (CRUD) + previews sur `MyWeddingPage` + multi-devise sur `wedding_expenses.currency_code` + budget précis + currency dans `WeddingEditSheet`.
- **Sprint 3.3** vise à remplacer la section placeholder **Inspirations / Moodboard** par un module complet (albums + sauvegarde depuis le feed + upload images).

### What Has Been Done (Sprints 3.1–3.2 — DONE)
- `AgendaPage` + `AddEventSheet` + CRUD events.
- `BudgetPage` + `AddExpenseSheet` + CRUD expenses.
- Multi-devise par dépense: stockage `currency_code` + conversion UI vers la devise préférée user.
- Previews (Agenda/Budget) sur `MyWeddingPage` (max 5 items).

### What Remains (Sprint 3.3)
- `InspirationsPage` (albums)
- `AlbumDetailPage` (contenu de l’album)
- `CreateAlbumSheet`
- `SaveToAlbumSheet` (depuis feed)
- Upload d’images (gallery → Storage → rows DB)
- Brancher navigation depuis `MyWeddingPage` (remplacer placeholder Inspirations)

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

### Existing feed (save flow entry point)
- `lib/pages/` feed detail / viewer (identifier où ajouter l’icône signet)

### Design System V4 (mandatory reuse)
- **Doc:** `docs/App/DESIGN_SYSTEM.md` (authoritative)
- **Implementation:** `lib/core/design/`
- **Import unique (screens/components):**
  ```dart
  import '/core/design/design.dart';
  ```

**Design unification (non negotiable):**
- Zéro styles “one-off”: utiliser tokens DS (couleurs noir/blanc/gris).
- **Font weights:** w400 default, w500 max (except CTA si déjà validé ailleurs).
- **Spacing:** 30px inter-sections, 10px label→content.
- **Buttons:** height 48px, radius 0, text w400.
- **Sheets:** radius top 24px, padding horizontal 20px.
- **Cards/items:** radius 4px.

---

## 🎯 TASKS TO COMPLETE

### Task 1 — InspirationsPage (Albums list)
**Priority:** 🔴 HIGH
**Estimated:** 1 jour

**Requirements**
- Page `InspirationsPage` (Design System V4)
- 2 types d’albums:
  - **Wedding albums** (visibles pros) → `is_private=false`
  - **Private albums** (bride only) → `is_private=true`
- Liste d’albums avec:
  - nom
  - compteur items (si dispo)
  - badge “Private” si `is_private=true` (couleur état uniquement)
- Actions:
  - create (CreateAlbumSheet)
  - open album (AlbumDetailPage)
  - rename (optionnel)
  - delete (si souhaité)

**Implementation steps**
1. Créer `InspirationsPage`:
   - `lib/features/my_wedding/presentation/pages/inspirations_page.dart`
2. Datasource/repository: list/create/update/delete albums (si pas déjà)
3. Navigation depuis `MyWeddingPage` (remplacer placeholder Inspirations)

**Acceptance criteria**
- [ ] Bride peut créer un album wedding ou privé
- [ ] Liste albums affiche correctement les deux sections (ou tabs)
- [ ] UI 100% DS (spacing 30/10, weights <= w500)

---

### Task 2 — AlbumDetailPage (Images list + upload)
**Priority:** 🔴 HIGH
**Estimated:** 1-2 jours

**Requirements**
- Page `AlbumDetailPage`:
  - grille d’images
  - empty state DS
  - actions: upload, delete image
- Upload depuis galerie:
  - picker
  - upload vers Storage (bucket `wedding-albums` si déjà présent)
  - enregistrer rows en DB (`album_images`)

**Implementation steps**
1. Créer `AlbumDetailPage`:
   - `lib/features/my_wedding/presentation/pages/album_detail_page.dart`
2. Implémenter upload:
   - choisir image(s)
   - upload storage
   - insert `album_images`
3. Afficher images (pagination si nécessaire)

**Acceptance criteria**
- [ ] Bride peut uploader une image dans un album
- [ ] L’image apparaît immédiatement dans la grille
- [ ] Suppression image fonctionne (RLS OK)

---

### Task 3 — SaveToAlbumSheet (depuis Feed)
**Priority:** 🟡 MEDIUM
**Estimated:** 0.5-1 jour

**Requirements**
- Sheet listant albums (wedding + private)
- Permet de sauvegarder un post du feed dans un album
- Persistance via table `saved_posts` (album_id + post_id)

**Implementation steps**
1. Créer `SaveToAlbumSheet`:
   - `lib/features/my_wedding/presentation/sheets/save_to_album_sheet.dart`
2. Ajouter un point d’entrée UI dans le feed:
   - icône signet dans le viewer post (à identifier précisément)
3. Datasource CRUD minimal:
   - insert/delete `saved_posts`
   - list saved posts par album

**Acceptance criteria**
- [ ] Bride peut sauvegarder un post dans un album
- [ ] Un post ne se duplique pas dans le même album (unique constraint ou guard côté app)

---

### Task 4 — Validation & Non-regression
**Priority:** 🟡 MEDIUM

**Checklist**
1. `flutter analyze` (pas de nouvelles erreurs bloquantes)
2. Smoke test iOS simulator
3. Vérifier RLS:
   - bride only pour albums privés
   - pros ne voient que `is_private=false`
4. Test manuel minimal:
   - Create album (private + wedding)
   - Upload image
   - Save post to album
   - Delete image / remove saved post
5. Update docs: `docs/PROJECT.md` + `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`

---

## ⚠️ CRITICAL RULES

1. ❌ **NEVER** reuse FlutterFlow legacy components (`lib/compo_finaux/`, `lib/components/` legacy, etc.)
2. ✅ **Design System V4 mandatory**: `import '/core/design/design.dart';`
3. ✅ **Design unification mandatory**: noir/blanc/gris (couleur uniquement pour états)
4. ✅ Clean Architecture: domain/data/presentation
5. ❌ No `print()` — use `SecureLogger`
6. **Zéro supposition**: toute affirmation doit être prouvée (code/SQL). Sinon écrire “Non vérifié”.
7. **Pas de migration DB sans validation** (si unique constraints / index nécessaires, proposer d’abord).

---

## 🚫 PITFALLS TO AVOID

- Réinventer des composants UI (réutiliser DS + patterns `LynewedSheet`, `LynewedTextField`, `LynewedButton`)
- Créer des pages en dehors de `lib/features/my_wedding/`
- Casser la séparation private/wedding albums (RLS + filtres)
- Upload storage sans conventions de path (définir un path stable)
- Oublier l’unification design (mêmes rayons, mêmes paddings, mêmes styles)

---

## 🚀 START HERE

1. Lire les fichiers mandatory
2. Confirmer le schema réel:
   - `inspiration_albums` (colonnes: `wedding_id`, `bride_profile_id`, `is_private`, `category`?)
   - `saved_posts` (album_id + post_id)
   - `album_images` (album_id + image_url)
   - bucket storage `wedding-albums`
3. Proposer un plan (2-5 milestones)
4. Attendre validation avant migrations DB / policy changes
