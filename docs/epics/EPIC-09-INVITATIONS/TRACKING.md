# TRACKING - EPIC-09-INVITATIONS

> Status : 🔵 Draft
> Stories : 0/12 completees
> Derniere MAJ : 2026-01-28

---

## Timeline

| Date | Evenement |
|------|-----------|
| 2026-01-28 | Epic cree - Systeme d'invitations guests (APP-03) |
| - | - |

---

## Dependances Critiques

| Dependance | Epic Source | Status | Bloquant |
|------------|-------------|--------|----------|
| UserRole.guest enum | EPIC-06 S01 | 🔵 Todo | OUI |
| weddings.invite_code | EPIC-06 S02/S04 | 🔵 Todo | OUI |
| wedding_guests.user_id/status | EPIC-06 S05 | 🔵 Todo | OUI |
| Bucket wedding-media | EPIC-06 S06 | 🔵 Todo | NON (pour album) |

**IMPORTANT** : EPIC-06-PREREQUISITES doit etre complete AVANT de commencer cet Epic.

---

## Progression Stories

| Story | Status | Assignee | Date Start | Date Done | Notes |
|-------|--------|----------|------------|-----------|-------|
| S01 - Login page guest button | 🔵 Todo | - | - | - | Depend EPIC-06 |
| S02 - Join wedding page | 🔵 Todo | - | - | - | Depend S01 |
| S03 - Deep link handling | 🔵 Todo | - | - | - | Config iOS + Android |
| S04 - Guest account creation | 🔵 Todo | - | - | - | Flow complet |
| S05 - Guest navigation (3 tabs) | 🔵 Todo | - | - | - | Nouvelle feature |
| S06 - Edge Function email | 🔵 Todo | - | - | - | Integration Resend |
| S07 - Send invitation UI | 🔵 Todo | - | - | - | Depend S06 |
| S08 - Status tracking | 🔵 Todo | - | - | - | UI + logique |
| S09 - Guest → Bride upgrade | 🔵 Todo | - | - | - | Irreversible |
| S10 - Chat room trigger | 🔵 Todo | - | - | - | SQL trigger |
| S11 - Chat integration | 🔵 Todo | - | - | - | Reutilise chat existant (D-17) |
| S12 - Validate invite code RPC | 🔵 Todo | - | - | - | Backend validation + rate limit |

---

## Problemes Rencontres

| Date | Probleme | Resolution | Status |
|------|----------|------------|--------|
| - | *Aucun pour l'instant* | - | - |

---

## Decisions Techniques

| Date | Decision | Contexte | Impact |
|------|----------|----------|--------|
| 2026-01-28 | Reutiliser chat_rooms existante (D-17) | Eviter duplication code | Utilise type='wedding_team' |
| 2026-01-28 | Deep link format: lynewed.app/join/{code} | Standard, facile a retenir | Config Universal Links + App Links |
| 2026-01-28 | QR code genere dynamiquement dans email | Pas de stockage image necessaire | Package qrcode dans Edge Function |
| 2026-01-28 | Guest → Bride irreversible | Simplicite, evite abus | Dialog confirmation explicite |
| 2026-01-28 | Integration Resend pour emails | Service recommande par Supabase | Edge Function dedicee |

---

## Ce qui reste pour 100%

### Frontend (Stories S01-S05, S07-S09)

- [ ] S01: Bouton guest discret sur login page
- [ ] S01: Navigation vers JoinWedding
- [ ] S02: Input code 8 caracteres avec validation
- [ ] S02: Scanner QR code avec camera
- [ ] S02: Gestion erreurs (code invalide, rate limit)
- [ ] S03: Configuration iOS Universal Links
- [ ] S03: Configuration Android App Links
- [ ] S03: Deep link handler dans app
- [ ] S04: Page creation compte guest
- [ ] S04: Pre-remplissage email si guest existe
- [ ] S04: Support OAuth (Apple, Google)
- [ ] S04: Post-creation: profile, link, album, chat
- [ ] S05: NavBar 3 tabs (Album, Chat, Profil)
- [ ] S05: Guards pour bloquer acces autres features
- [ ] S05: Header avec nom du mariage
- [ ] S07: Bouton envoi invitation sur guest tile
- [ ] S07: Feedback loading/succes/erreur
- [ ] S08: Badges statut (pending/invited/joined)
- [ ] S08: Filtrage par statut
- [ ] S08: Compteurs par statut
- [ ] S09: Section upgrade dans profil guest
- [ ] S09: Dialog confirmation irreversible
- [ ] S09: Changement role + redirection

### Backend (Stories S06, S10, S11, S12)

- [ ] S06: Edge Function send-wedding-invitation
- [ ] S06: Template email HTML
- [ ] S06: Generation QR code
- [ ] S06: Integration Resend
- [ ] S06: Mise a jour status guest
- [ ] S10: Trigger create_default_wedding_chat
- [ ] S10: Backfill pour mariages existants
- [ ] S10: Ajout bride comme participante
- [ ] S11: RLS policies pour guest chat access
- [ ] S11: Guest ajoute a chat_room_participants
- [ ] S11: Verification realtime fonctionne pour guests
- [ ] S12: RPC validate_invite_code
- [ ] S12: Rate limiting (5 attempts / 15 min)
- [ ] S12: Retour infos wedding + bride_name

### Configuration (Story S03)

- [ ] S03: Fichier apple-app-site-association sur serveur
- [ ] S03: Fichier assetlinks.json sur serveur
- [ ] S03: Runner.entitlements iOS
- [ ] S03: AndroidManifest.xml intent-filters

### TEST (Transversal)

- [ ] Tests unitaires pour chaque story
- [ ] Tests integration deep links (iOS)
- [ ] Tests integration deep links (Android)
- [ ] Tests flow complet end-to-end
- [ ] Tests Edge Function
- [ ] flutter analyze --fatal-infos passe

---

## Metriques

| Metrique | Valeur |
|----------|--------|
| Stories totales | 12 |
| Stories completees | 0 |
| Pages Flutter a creer | 5 |
| Widgets Flutter a creer | ~8 |
| Edge Functions | 1 |
| Triggers SQL | 1 |
| RLS Policies | ~3 |
| Temps estime | 2 jours |

---

## Dependances Inter-Stories

```
EPIC-06 (PREREQUIS) ← BLOQUANT

S12 (Validate RPC) ◄── EPIC-06
        │
S01 ──► S02 ──► S03 (Deep links)
        │
        └──► S04 (Account creation)
                │
                ├──► S05 (Navigation)
                │       │
                │       └──► S09 (Upgrade)
                │
                └──► S11 (Chat) ◄── S10 (Trigger)

S06 (Email) ──► S07 (UI) ──► S08 (Status)
```

**Parallelisable:**
- S10 peut etre fait en parallele avec S01-S03
- S06 peut etre fait en parallele avec S01-S04

---

## Tests sur Devices Physiques

### Deep Links a tester

| Test | iOS | Android |
|------|-----|---------|
| Tap lien dans email (app installee) | [ ] | [ ] |
| Tap lien dans email (app non installee) | [ ] | [ ] |
| Scan QR code depuis camera native | [ ] | [ ] |
| Scan QR code depuis app | [ ] | [ ] |
| Tap lien dans Messages/SMS | [ ] | [ ] |
| Tap lien dans WhatsApp | [ ] | [ ] |

### Flow Guest Complet

| Test | Status |
|------|--------|
| Guest entre code manuellement | [ ] |
| Guest scanne QR code | [ ] |
| Guest cree compte email/password | [ ] |
| Guest cree compte Apple | [ ] |
| Guest cree compte Google | [ ] |
| Guest voit album vide | [ ] |
| Guest envoie message chat | [ ] |
| Guest recoit message realtime | [ ] |
| Guest upgrade vers Bride | [ ] |

---

## Checklist Pre-Production

Avant de deployer en production:

- [ ] EPIC-06-PREREQUISITES complete et deployee
- [ ] Tous les tests passent
- [ ] Deep links testes sur iOS physique
- [ ] Deep links testes sur Android physique
- [ ] Edge Function deployee et testee
- [ ] Fichiers .well-known deployes sur serveur web
- [ ] Template email valide avec Resend
- [ ] RLS policies testees
- [ ] flutter analyze --fatal-infos passe
- [ ] Documentation a jour
- [ ] Backup production fait avant migration

---

## Retrospective

### Ce qui a bien marche

- *A completer en fin d'Epic*

### A ameliorer

- *A completer en fin d'Epic*

### Lecons apprises

- *A completer en fin d'Epic*
