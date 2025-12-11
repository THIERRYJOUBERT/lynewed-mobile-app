# 🎯 MISSION: My Wedding Suite - Sprint 3, 4 & 5 Completion

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter/Supabase Developer** expert in:
- Flutter mobile development with Clean Architecture
- Supabase backend (database, auth, storage, edge functions)
- UI/UX implementation following Design System guidelines
- Refactoring legacy FlutterFlow code

Your approach: Surgical precision, production-grade code, data-driven decisions. Think in English, communicate in French.

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Wedding professionals marketplace
- **Version:** v2.1.0
- **Branch:** develop
- **Supabase Project ID:** hekyovgnovhfhmkpfrna (PROD)

### Current Situation
Sprint 3 est à ~80% terminé. La Wedding Team Section est fonctionnelle (liste pros, navigation, chat). Sprint 4 a commencé avec InviteProSheet et les triggers SQL corrigés. Il reste quelques tâches mineures sur Sprint 3, la majorité de Sprint 4, et tout Sprint 5 (Weddings Hub Pro).

**Scope de cette conversation:** Terminer Sprint 3, Sprint 4 et Sprint 5.

### What Has Been Done (2025-12-11)

**Sprint 3 - My Wedding Page (Bride):**
- ✅ Page Skeleton + Routing
- ✅ Wedding Countdown Card
- ✅ **WeddingEditSheet** - Date picker natif + Google Places address search
- ✅ **Wedding Team Chat Item** - Avatars, unread count, navigation
- ✅ **Wedding Team Section** - Liste pros, tap→ProDetails, long press→modal, chat icon→Chat 1-1
- ✅ **5 Sections Overview** - Agenda, Budget, Inspirations, Guests, Note for Pros (placeholders)
- ✅ **NoteForProsSheet** - Sous-titre sous header, TextField multi-lignes
- ✅ **Boutons style primaire** - Tous les boutons de sections en fond noir

**Sprint 4 - Wedding Team Features:**
- ✅ **InviteProSheet** - Liste pros contactés (RPC), recherche, Add/Remove, navigation ProDetails
- ✅ **Exclude Pro** - Via long press modal dans Wedding Team Section
- ✅ **Triggers SQL corrigés** - 5 triggers (`display_name` → `full_name`)
- ✅ **RPC `get_contacted_pros_for_bride`** créée
- ✅ **RLS policy** "Bride can update wedding participants" ajoutée
- ✅ **`inviteProToWedding`** inclut maintenant la profession

**Fixes appliqués:**
- `getActiveWeddingTeam` corrigé (profession depuis `wedding_participants`)
- `getWeddingTeam` corrigé (même fix)
- Navigation `_openProDetails` fetch Supabase + `ProDetailsWidget`
- Navigation `_openChatWithPro` via `action_blocks.contactChatRoom`

### What Remains

**Sprint 3 (restant ~20%):**
- [ ] 3.5 Filtre MessagesPage par weddingId (optionnel - déjà filtré par `RoomType.private`)
- [ ] 3.5 Menu settings mariage
- [ ] 3.7 Cancelled Wedding View

**Sprint 4 (restant ~60%):**
- [ ] 4.3 Pro Quit Flow (LeaveWeddingSheet côté Pro)
- [ ] 4.5 Edge Function `wedding_event_reminder` (CRON 24h avant)
- [ ] 4.6 Toggle Settings rappels événements
- [ ] 4.7 Chat 1-1 Access Filtré (optionnel)

**Sprint 5 - Weddings Hub Pro:**
- [ ] WeddingsHubProPage (liste mariages pour les pros)
- [ ] WeddingClientDetailPage
- [ ] Pro can leave wedding with reason
- [ ] Mute workflow

---

## 📁 KEY FILES TO READ FIRST

**MANDATORY - Read before any action:**
1. `docs/PROJECT.md` - Project state
2. `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` - Plan détaillé Sprint 3-8
3. `docs/App/DESIGN_SYSTEM.md` - UI/UX reference

**Module code:**
- `lib/features/my_wedding/presentation/pages/my_wedding_page.dart` - Page principale bride
- `lib/features/my_wedding/presentation/sheets/` - Sheets (invite_pro, note_for_pros, wedding_edit)
- `lib/features/my_wedding/data/datasources/supabase_my_wedding_datasource.dart` - Datasource

**Supabase SQL:**
- `docs/sql/MY_WEDDING_SUITE_TRIGGERS.sql` - Triggers notifications
- `docs/sql/MY_WEDDING_SUITE_RLS.sql` - Policies RLS

---

## 🎯 TASKS TO COMPLETE

### Task 1: Cancelled Wedding View (Sprint 3.7)
**Priority:** 🟡 MEDIUM
**Estimated:** 1h

**Steps:**
1. Créer widget `CancelledWeddingView` dans `my_wedding_page.dart`
2. Afficher si `wedding.status == 'cancelled'`
3. Message "Votre mariage a été annulé" + bouton "Reprendre"
4. Bouton → reset status à 'active'

**Acceptance criteria:**
- [ ] Widget affiché si status=cancelled
- [ ] Bouton reprendre fonctionne
- [ ] Retour à la vue normale après reprise

### Task 2: Pro Quit Flow - LeaveWeddingSheet (Sprint 4.3)
**Priority:** 🔴 HIGH
**Estimated:** 2h

**Steps:**
1. Créer `lib/features/weddings_hub_pro/presentation/sheets/leave_wedding_sheet.dart`
2. TextField pour raison (obligatoire)
3. Bouton "Leave Wedding" → `leaveWedding` datasource method
4. Update status='left', left_reason, left_at
5. Trigger retire pro du chat wedding_team
6. Notification bride

**Acceptance criteria:**
- [ ] Sheet avec raison obligatoire
- [ ] Update status dans wedding_participants
- [ ] Pro retiré du chat groupe
- [ ] Notification envoyée à la bride

### Task 3: Weddings Hub Pro - Structure Module (Sprint 5.1)
**Priority:** 🔴 HIGH
**Estimated:** 1h

**Structure à créer:**
```
lib/features/weddings_hub_pro/
├── domain/
│   ├── entities/wedding_client.dart
│   └── repositories/weddings_hub_repository.dart
├── data/
│   ├── datasources/supabase_weddings_hub_datasource.dart
│   └── repositories/weddings_hub_repository_impl.dart
└── presentation/
    ├── pages/weddings_hub_page.dart
    ├── pages/wedding_client_detail_page.dart
    └── sheets/leave_wedding_sheet.dart
```

**Entity `WeddingClient`:**
```dart
class WeddingClient {
  final String weddingId;
  final String brideName;
  final String? brideAvatarUrl;
  final String? weddingName;
  final DateTime? eventDate;
  final String? venueAddress;
  final String? coverImageUrl;
  final String? noteForPros;
  final String? teamChatRoomId;
  final bool isMuted;
  final DateTime joinedAt;
}
```

### Task 4: Weddings Hub Pro Page (Sprint 5.2)
**Priority:** 🔴 HIGH
**Estimated:** 2h

**Steps:**
1. Créer `WeddingsHubPage` basé sur pattern `my_wedding_page.dart`
2. Datasource `getMyWeddingsAsPro()` - SELECT weddings WHERE pro is active participant
3. Card pour chaque mariage (copier pattern `_buildWeddingOverviewCard`)
4. Tap → `WeddingClientDetailPage`
5. Long press → Modal (mute, leave)

**UI Pattern:**
- Header "WEDDINGS" (comme "WEDDING" côté bride)
- Liste de cards avec: cover image, bride name, date, venue
- Empty state si aucun mariage

**Acceptance criteria:**
- [ ] Liste des mariages où le pro est participant actif
- [ ] Card avec: bride name, wedding date, venue, cover image
- [ ] Navigation vers détail
- [ ] Long press modal

### Task 5: Wedding Client Detail Page (Sprint 5.3)
**Priority:** 🔴 HIGH
**Estimated:** 2h

**Structure basée sur `my_wedding_page.dart`:**

**Sections à implémenter:**
1. **Header Card** - Cover image + bride name + date + venue (read-only)
2. **Wedding Team Chat** - Accès au groupe chat (comme côté bride)
3. **Chat with Bride** - Bouton pour ouvrir chat 1-1
4. **Bride's Note** - Affichage read-only de `noteForPros`
5. **Actions** - Boutons Mute / Leave Wedding

**Navigation:**
- Wedding Team Chat → `ChatDetailsPage` avec `roomId`
- Chat with Bride → `action_blocks.contactChatRoom`
- Leave Wedding → `LeaveWeddingSheet`

**Acceptance criteria:**
- [ ] Affichage infos mariage (read-only)
- [ ] Accès chat groupe
- [ ] Accès chat 1-1 bride
- [ ] Affichage note bride
- [ ] Bouton Leave fonctionnel

### Task 6: Mute Workflow (Sprint 5.4)
**Priority:** 🟡 MEDIUM
**Estimated:** 1h

**Steps:**
1. Toggle `is_muted` dans `wedding_participants`
2. UI: icône mute dans card + modal option
3. Quand muted: pas de notifications pour ce mariage

**Acceptance criteria:**
- [ ] Toggle mute fonctionne
- [ ] État mute visible dans UI
- [ ] Notifications filtrées si muted

---

## ⚠️ CRITICAL RULES

1. **Design System V4** - Utiliser `lib/core/design/` pour toute UI
2. **Clean Architecture** - domain/data/presentation layers
3. **LynewedSheet** - Pour tous les bottom sheets
4. **Boutons primaires** - Fond noir pour actions principales
5. **full_name** - Jamais `display_name` (n'existe pas dans profiles)
6. **Profession** - Stockée dans `wedding_participants`, pas fetch depuis `professional_details`

---

## 🎨 DESIGN RULES - UNIFICATION UI/UX

**PRINCIPE FONDAMENTAL:** Réutiliser les bases existantes pour unifier le design entre les écrans.

### Sheets (Bottom Sheets)
- **TOUJOURS** utiliser `LynewedSheet` comme base
- **Référence:** `lib/features/my_wedding/presentation/sheets/invite_pro_sheet.dart`
- **Structure:**
  - Title dans le header
  - Sous-titre dans le `child` (pas dans le header)
  - `bottomAction` pour le bouton principal
  - Spacing: 30px entre sections, 10px label→content

### Pages
- **Référence bride:** `lib/features/my_wedding/presentation/pages/my_wedding_page.dart`
- **Pattern sections:** Titre uppercase + contenu + spacing 30px
- **Empty states:** Icon 32px + texte + bouton primaire

### Items/Tiles
- **Pro tile référence:** `_buildProTile` dans `my_wedding_page.dart`
- **Structure:** Avatar 48px + Column(name, subtitle) + action icon
- **Tap:** Navigation vers détail
- **Long press:** Modal options

### Widgets Design System à utiliser
```dart
import '/core/design/design.dart';

// Sheets
LynewedSheet(title:, onClose:, bottomAction:, child:)

// Buttons
LynewedButton(text:, onPressed:, isLoading:, width:)
LynewedButton(text:, onPressed:, type: LynewedButtonType.secondary)

// Text fields
LynewedTextField(controller:, hint:, prefixIcon:, onChanged:)

// Chips
LynewedChip(label:, selected:, onTap:)
```

### Tokens Design
| Element | Value |
|---------|-------|
| **Font weights** | w300 (inputs), w400 (default), w500 (titles max) |
| **Inter-section** | 30px |
| **Label→Content** | 10px |
| **Horizontal margins** | 20px |
| **Buttons** | 48px height, 0 radius |
| **Sheets** | 24px top radius |
| **Items/Chips** | 4px radius |
| **Avatar** | 48px (tiles), 24px (small) |

### Patterns à copier
| Nouveau composant | Copier depuis |
|-------------------|---------------|
| Nouveau sheet | `invite_pro_sheet.dart` |
| Nouvelle page bride | `my_wedding_page.dart` |
| Nouvelle page pro | À créer basé sur `my_wedding_page.dart` |
| Pro tile | `_buildProTile` dans `my_wedding_page.dart` |
| Wedding card | `_buildWeddingOverviewCard` dans `my_wedding_page.dart` |
| Section avec empty state | `_buildEmptyTeamState` dans `my_wedding_page.dart` |

---

## 🚫 PITFALLS TO AVOID

- ❌ Ne pas utiliser `display_name` - utiliser `full_name` de profiles
- ❌ Ne pas joindre `professional_details` pour la profession dans wedding team - elle est dans `wedding_participants`
- ❌ Ne pas créer de composants FlutterFlow - utiliser Design System
- ❌ Ne pas oublier les imports (`go_router`, `supabase_flutter`, etc.)
- ❌ Ne pas créer de nouveaux styles - réutiliser `LynewedTextStyles` et `LynewedColors`
- ❌ Ne pas inventer de nouveaux patterns UI - copier les existants pour unifier

---

## ✅ VALIDATION

When tasks are complete:
1. Run `flutter analyze lib/features/my_wedding/` - No new errors
2. Run `flutter analyze lib/features/weddings_hub_pro/` - No new errors
3. Test on iOS simulator
4. Update `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md`
5. Use `/commit-github-develop` for safe commits

---

## 🚀 START HERE

1. Read `docs/MY_WEDDING_SUITE_IMPLEMENTATION_PLAN.md` (sections Sprint 3, 4, 5)
2. Read `lib/features/my_wedding/presentation/pages/my_wedding_page.dart`
3. Confirm understanding of remaining tasks
4. Propose action plan (which task first)
5. Wait for validation before executing

---

## 📝 NOTES TECHNIQUES

### MessagesPage Filtering
Le filtre par `RoomType.private` est déjà en place dans `messages_brides_widget.dart:278`. Cela exclut les chats `wedding_team`. Le filtre par `weddingId` mentionné dans le plan est optionnel.

### Triggers SQL corrigés
Les 5 triggers suivants ont été corrigés pour utiliser `full_name` au lieu de `display_name`:
- `notify_pro_added_to_wedding`
- `notify_pro_excluded_from_wedding`
- `notify_wedding_pro_added`
- `notify_wedding_pro_excluded`
- `notify_wedding_pro_left`

### RPC créée
```sql
CREATE OR REPLACE FUNCTION get_contacted_pros_for_bride(p_bride_id uuid)
RETURNS TABLE (profile_id uuid, full_name text, avatar_url text, profession text, business_name text)
```
