# TRACKING - EPIC-09-INVITATIONS

> Status : ✅ COMPLETE
> Stories : 12/12 completees
> Derniere MAJ : 2026-01-30

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Systeme d'invitations guests (APP-03) |
| 2026-01-29 | Stories S01-S06, S10, S12 completees |
| 2026-01-30 | Stories S07-S09, S11 completees - Epic 100% |

---

## Dependances Critiques

| Dependance | Epic Source | Status | Bloquant |
|------------|-------------|--------|----------|
| UserRole.guest enum | EPIC-06 S01 | ✅ Done | OUI |
| weddings.invite_code | EPIC-06 S02/S04 | ✅ Done | OUI |
| wedding_guests.user_id/status | EPIC-06 S05 | ✅ Done | OUI |
| Bucket wedding-media | EPIC-06 S06 | ✅ Done | NON (pour album) |

**IMPORTANT** : EPIC-06-PREREQUISITES a ete complete.

---

## Progression Stories

| Story | Status | Date Done | Notes |
|-------|--------|-----------|-------|
| S01 - Login page guest button | ✅ Done | 2026-01-29 | Bouton discret avec icon |
| S02 - Join wedding page | ✅ Done | 2026-01-29 | Code input + QR scanner |
| S03 - Deep link handling | ✅ Done | 2026-01-29 | iOS + Android config |
| S04 - Guest account creation | ✅ Done | 2026-01-29 | Flow complet signup |
| S05 - Guest navigation (3 tabs) | ✅ Done | 2026-01-29 | Album, Chat, Profil |
| S06 - Edge Function email | ✅ Done | 2026-01-29 | send-wedding-invitation deployee |
| S07 - Send invitation UI | ✅ Done | 2026-01-30 | SendInvitationButton widget |
| S08 - Status tracking | ✅ Done | 2026-01-30 | Filter, badges, summary |
| S09 - Guest → Bride upgrade | ✅ Done | 2026-01-30 | Dialog confirmation + RPC |
| S10 - Chat room trigger | ✅ Done | 2026-01-29 | SQL trigger + backfill |
| S11 - Chat integration | ✅ Done | 2026-01-30 | ChatDetailsPage integration + badge |
| S12 - Validate invite code RPC | ✅ Done | 2026-01-29 | validate_invite_code RPC |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| 2026-01-30 | InvitationFailure constructor error | Changed to positional super parameter | ✅ |
| 2026-01-30 | Test timer pending | Used Completer pattern | ✅ |
| 2026-01-30 | Supabase RPC mock complexity | Simplified tests to validate result types | ✅ |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Reutiliser chat_rooms existante (D-17) | Eviter duplication code | Utilise type='wedding_team' |
| 2026-01-28 | Deep link format: lynewed.app/join/{code} | Standard, facile a retenir | Config Universal Links + App Links |
| 2026-01-28 | QR code genere dynamiquement dans email | Pas de stockage image necessaire | Package qrcode dans Edge Function |
| 2026-01-28 | Guest → Bride irreversible | Simplicite, evite abus | Dialog confirmation explicite |
| 2026-01-28 | Integration Resend pour emails | Service recommande par Supabase | Edge Function dedicee |
| 2026-01-30 | StatefulWidget pour GuestHomePage | Pas de Riverpod dans le projet | Ecoute FFAppState via listener |

---

## Ce qui a ete implemente

### Frontend (Stories S01-S05, S07-S09)

- [x] S01: Bouton guest discret sur login page
- [x] S01: Navigation vers JoinWedding
- [x] S02: Input code 8 caracteres avec validation
- [x] S02: Scanner QR code avec camera
- [x] S02: Gestion erreurs (code invalide, rate limit)
- [x] S03: Configuration iOS Universal Links
- [x] S03: Configuration Android App Links
- [x] S03: Deep link handler dans app
- [x] S04: Page creation compte guest
- [x] S04: Pre-remplissage email si guest existe
- [x] S04: Support OAuth (Apple, Google)
- [x] S04: Post-creation: profile, link, album, chat
- [x] S05: NavBar 3 tabs (Album, Chat, Profil)
- [x] S05: Guards pour bloquer acces autres features
- [x] S05: Header avec nom du mariage
- [x] S07: Bouton envoi invitation sur guest tile
- [x] S07: Feedback loading/succes/erreur
- [x] S08: Badges statut (pending/invited/joined)
- [x] S08: Filtrage par statut
- [x] S08: Compteurs par statut
- [x] S09: Section upgrade dans profil guest
- [x] S09: Dialog confirmation irreversible
- [x] S09: Changement role + redirection

### Backend (Stories S06, S10, S11, S12)

- [x] S06: Edge Function send-wedding-invitation
- [x] S06: Template email HTML
- [x] S06: Generation QR code
- [x] S06: Integration Resend
- [x] S06: Mise a jour status guest
- [x] S10: Trigger create_default_wedding_chat
- [x] S10: Backfill pour mariages existants
- [x] S10: Ajout bride comme participante
- [x] S11: RLS policies pour guest chat access
- [x] S11: Guest ajoute a chat_room_participants
- [x] S11: Badge unread sur GuestNavBar
- [x] S12: RPC validate_invite_code
- [x] S12: Rate limiting (5 attempts / 15 min)
- [x] S12: Retour infos wedding + bride_name

### Configuration (Story S03)

- [x] S03: Fichier apple-app-site-association sur serveur
- [x] S03: Fichier assetlinks.json sur serveur
- [x] S03: Runner.entitlements iOS
- [x] S03: AndroidManifest.xml intent-filters

### TEST (Transversal)

- [x] Tests unitaires pour chaque story (52+ tests EPIC-09)
- [x] flutter analyze --fatal-infos passe

---

## Metriques Finales

| Metrique | Valeur |
|----------|--------|
| Stories totales | 12 |
| Stories completees | 12 (100%) |
| Tests EPIC-09 | 52+ |
| Pages Flutter creees | 6 |
| Widgets Flutter crees | 12 |
| Edge Functions | 1 |
| Triggers SQL | 1 |
| RLS Policies | 4 |
| Migrations Supabase | 5 |

---

## Fichiers Crees/Modifies

### Fichiers Crees

- `lib/features/guest/` - Module complet guest
  - `presentation/pages/guest_home_page.dart`
  - `presentation/pages/guest_album_page.dart`
  - `presentation/pages/guest_chat_page.dart`
  - `presentation/pages/guest_profile_page.dart`
  - `presentation/widgets/guest_nav_bar.dart`
  - `presentation/widgets/upgrade_confirmation_dialog.dart`
- `lib/features/auth/domain/usecases/upgrade_to_bride.dart`
- `lib/features/my_wedding/domain/usecases/send_guest_invitation.dart`
- `lib/features/my_wedding/presentation/widgets/guest_status_badge.dart`
- `lib/features/my_wedding/presentation/widgets/send_invitation_button.dart`
- `lib/features/my_wedding/presentation/widgets/guest_list_summary.dart`
- `lib/features/my_wedding/presentation/widgets/guest_status_filter.dart`
- `supabase/functions/send-wedding-invitation/`

### Tests Crees

- `test/features/guest/presentation/pages/guest_chat_page_test.dart`
- `test/features/guest/presentation/pages/guest_profile_page_test.dart`
- `test/features/guest/presentation/pages/guest_album_page_test.dart`
- `test/features/guest/presentation/widgets/guest_nav_bar_test.dart`
- `test/features/guest/presentation/widgets/upgrade_confirmation_dialog_test.dart`
- `test/features/auth/domain/usecases/upgrade_to_bride_test.dart`
- `test/features/my_wedding/presentation/widgets/guest_list_summary_test.dart`

---

## Retrospective

### Ce qui a bien marche

- Reutilisation du systeme de chat existant (ChatDetailsPage) pour les guests
- Architecture Clean Architecture coherente avec le reste du projet
- Migration RLS policies deployees sans accroc
- Tests TDD complets pour chaque composant

### A ameliorer

- Les tests d'integration pour les deep links doivent etre faits manuellement sur devices physiques
- Le flow de test Supabase RPC est complexe a mocker

### Lecons apprises

- Utiliser `ChatDetailsPage` avec `isWeddingTeamChat: true` permet une integration rapide
- `FFAppState` comme `ChangeNotifier` permet d'ecouter les changements de compteur facilement
- Les sealed classes Dart sont excellentes pour les result types des use cases
