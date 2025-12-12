# 🎯 MISSION: My Wedding Suite — Sprint 3.5 (Documents Chat + Cancel/Resume) + Wedding Icon Unification

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
- Sprints **3.1 → 3.4** sont terminés (Agenda, Budget, Inspirations, Guests).
- Map UX côté bride a été alignée :
  - Tap icône wedding sur map → centre sur le wedding si existant (sinon onboarding MyWedding).
  - `WeddingDetailsSheet` affiche budget **max only** + **guest count**.
  - `Edit Wedding` depuis le sheet map navigue vers `MyWeddingPage`.

### What Has Been Done (DONE)
- **Guests (Sprint 3.4):** CRUD complet + `GuestsPage` + `AddGuestSheet` + preview dans `MyWeddingPage`.
- **Map (Sprint 3.4 extension):**
  - `_showCreateSheet` (icône wedding) : centre sur `venueLat/venueLng` si `exists == true`, sinon ouvre `MyWeddingPage`.
  - `WeddingDetailsSheet` : budget = `budgetMaxOnly`, ajout `guestCount`.

### What Remains (Sprint 3.5 + polish)
1. **Documents in Chat** (PDF support)
2. **Cancel/Resume Wedding** flow
3. **Wedding Icon Unification** (remplacer le coeur utilisé pour favoris + unifier partout)
4. **Polish & Settings** (Sprint 3.6)

---

## 📁 KEY FILES TO READ FIRST (MANDATORY)

1. `docs/PROJECT.md`
2. `docs/PROJECT_TODO.md`
3. `docs/App/DESIGN_SYSTEM.md` ⭐ (obligatoire avant UI)
4. `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`

### My Wedding module (bride)
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart`
- `lib/features/my_wedding/presentation/widgets/wedding_onboarding_widget.dart`

### Map module (bride wedding interactions)
- `lib/features/map/presentation/pages/map_page.dart`
- `lib/features/map/presentation/sheets/wedding_details_sheet.dart`
- `lib/features/map/domain/entities/wedding_details.dart`
- Supabase RPC source of truth: `supabase/migrations/00000000000000_initial_schema.sql` (`get_my_wedding()`)

### Chat module (documents)
- `lib/features/chat/presentation/widgets/message_composer.dart`
- `lib/features/chat/presentation/pages/chat_details_page.dart`
- `lib/features/chat/presentation/widgets/` (bubbles)
- DB enum + storage policies: `supabase/migrations/`

---

## 🎯 TASKS TO COMPLETE

### Task 1 — Documents in Chat (PDF)
**Priority:** 🔴 HIGH
**Estimated:** 1–2 jours

**Goal:** permettre l’envoi/réception de documents (PDF) dans les chats (notamment Wedding Team Chat).

**Steps:**
1. Vérifier l’existant:
   - enum DB `messageType` (actuel: `text`, `image`, `audio`).
   - tables/messages actuels et logique d’upload.
2. Supabase:
   - Migration: ajouter `document` à l’enum `messageType` (si repo utilise enum DB).
   - Storage: créer/configurer bucket `chat-documents` si absent.
   - Policies: upload/download sécurisé (auth) + règles cohérentes (ne pas casser prod).
3. Flutter:
   - Ajouter une option attachment dans `MessageComposer`.
   - Upload PDF → Storage → insérer message type `document` (avec URL + metadata utile).
   - Créer `DocumentMessageBubble` (download/open).

**Acceptance criteria:**
- [ ] Un user peut envoyer un PDF dans un chat
- [ ] L’autre user voit le message document et peut ouvrir/télécharger
- [ ] Aucun impact sur text/image/audio
- [ ] Aucun usage de composants FlutterFlow legacy

---

### Task 2 — Cancel/Resume Wedding
**Priority:** 🔴 HIGH
**Estimated:** 1 jour

**Goal:** permettre à la bride d’annuler et reprendre un mariage, avec UI claire.

**Steps:**
1. Vérifier schema weddings: `cancelled_at`, `status`, etc.
2. UI:
   - Créer `CancelWeddingSheet` (confirmation + message).
   - Implémenter `resume` action.
3. Datasource/repository:
   - Ajouter méthodes si manquantes (update status / cancelled_at).
4. MyWeddingPage:
   - Afficher un état "Mariage annulé" + CTA "Resume".
5. Tests:
   - Cancel → UI change
   - Resume → retour normal

**Acceptance criteria:**
- [ ] Bride peut annuler (confirmation)
- [ ] Bride peut reprendre
- [ ] `MyWeddingPage` reflète correctement l’état

---

### Task 3 — Wedding Icon Unification (Design + code)
**Priority:** 🔴 HIGH
**Estimated:** 0.5–1 jour

**Problem:** l’icône wedding n’est pas unifiée (pin sur map, coeur dans navbar, etc.). Le coeur est déjà utilisé pour favoris.

**Goal:** choisir **un nouvel icône unique** pour représenter “Wedding / My Wedding Suite”, puis l’appliquer partout.

**Steps:**
1. Audit usages actuels:
   - Map: icône bride (actuel `Icons.push_pin`).
   - Navbar brides: item Wedding (actuellement coeur).
   - Autres endroits: headers, sheets, sections.
2. Proposer 2-3 options d’icônes Material cohérentes (ex: `Icons.celebration`, `Icons.diamond_outlined`, `Icons.rings` n’existe pas nativement, etc.).
3. Valider avec le user l’icône finale.
4. Implémenter remplacement **partout** où “Wedding” est représenté.

**Acceptance criteria:**
- [ ] 1 seule icône “Wedding” utilisée partout
- [ ] Le coeur reste réservé aux favoris
- [ ] Aucun regress UI / DS V4 respecté

---

### Task 4 — Sprint 3.6 (Polish & Settings)
**Priority:** 🟡 MEDIUM
**Estimated:** 1–2 jours

**Steps:**
1. Global mute toggle (Settings) pour muter les wedding team chats.
2. Vérifier “Wedding Team Chat improvements” (badge unread, avatars stack) → confirmer DONE ou implémenter.
3. Tests manuels end-to-end Bride + Pro.

**Acceptance criteria:**
- [ ] Toggle global mute fonctionne
- [ ] Flows Bride/Pro testés

---

## ⚠️ CRITICAL RULES

1. ✅ **Design System V4 mandatory**: `import '/core/design/design.dart';`
2. ✅ Clean Architecture: domain/data/presentation
3. ❌ No `print()` — use `SecureLogger`
4. ❌ **NEVER** reuse FlutterFlow legacy components (`lib/compo_finaux/`, `lib/components/`, etc.)
5. ✅ Font weights: **max w500** (except CTAs)
6. ✅ Spacing: 30px inter-section, 10px label→content
7. **Zéro supposition**: toute affirmation doit être prouvée (code/SQL). Sinon écrire “Non vérifié”.

---

## 🚫 PITFALLS TO AVOID

- Casser l’enum `messageType` sans migration correctement compatible
- Exposer documents storage sans policies strictes
- Réutiliser l’icône coeur pour Wedding (déjà favoris)
- Mélanger UI legacy FlutterFlow avec DS V4

---

## ✅ VALIDATION

When tasks are complete:
1. Run `flutter analyze` (pas de nouvelles erreurs)
2. Build & test iOS simulator: `./scripts/build_and_run.sh`
3. Tests manuels:
   - Document PDF send/receive
   - Cancel + resume wedding
   - Wedding icon consistent everywhere
4. Update docs:
   - `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN_V2.md`
   - `docs/PROJECT.md` si besoin
5. Commit via `/commit-github-develop`

---

## 🚀 START HERE

1. Lire les fichiers mandatory
2. Confirmer la stratégie DB pour `messageType` + storage bucket
3. Faire un audit rapide de toutes les occurrences de l’icône wedding
4. Proposer un plan (2-5 milestones) + attendre validation avant migrations
