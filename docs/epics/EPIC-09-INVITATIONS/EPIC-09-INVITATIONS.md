# EPIC-09-INVITATIONS

> Resume : Systeme d'invitations guests pour rejoindre un mariage
> Status : 🔵 Draft
> Domaine : Frontend / Backend / Auth / Deep Linking
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

Cet Epic implemente APP-03 de la Mission 2026 : **Systeme d'invitations guests**. Il permet aux mariees d'inviter leurs proches a rejoindre l'application avec un acces limite et dedie.

**IMPORTANT** : Cet Epic **ETEND** les fonctionnalites existantes, il ne recree PAS from scratch :
- Table `wedding_guests` existe (5 rows) avec: name, email, phone, role, notes
- Table `chat_rooms` existe avec `type='wedding_team'` (8 rooms) - **Decision D-17: REUSE**
- EPIC-06-PREREQUISITES ajoute les colonnes necessaires (invite_code, user_id, status)

### Dependances

| Dependance | Status | Bloquant |
|------------|--------|----------|
| EPIC-06-PREREQUISITES | 🔵 Draft | OUI - Doit etre complete AVANT |
| UserRole.guest enum | Via EPIC-06 S01 | OUI |
| weddings.invite_code | Via EPIC-06 S02/S04 | OUI |
| wedding_guests.user_id/status | Via EPIC-06 S05 | OUI |

### Etat Production Verifie (Supabase MCP)

| Element | Etat actuel | Action |
|---------|-------------|--------|
| `wedding_guests` | 5 rows (name, email, phone, role, notes) | ETENDRE |
| `chat_rooms` | 80 rows, type='wedding_team' existe (8) | REUSE (D-17) |
| `chat_messages` | 199 rows | REUSE |
| `chat_room_participants` | Existe | REUSE |
| `weddings.invite_code` | ABSENT | Ajoute par EPIC-06 |
| Bucket `wedding-media` | ABSENT | Cree par EPIC-06 |

### Decision D-17 : Reutiliser chat_rooms existante

**ANNULE** : Les tables `wedding_chat_rooms`, `wedding_chat_messages`, `wedding_chat_members` prevues initialement.

**UTILISER A LA PLACE** :
- `chat_rooms` avec `type='wedding_team'` et `wedding_id`
- `chat_messages` existante
- `chat_room_participants` existante

**Justification** : Evite duplication de code, le systeme de chat temps reel est deja robuste et production-ready.

---

## Architecture Cible

### Flow d'Onboarding Guest Complet

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        ONBOARDING GUEST FLOW                                     │
│                                                                                  │
│  ENTREE 1: Deep Link (lynewed.app/join/{code})                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  App installee? ─────► OUI ──► Ouvre app avec code pre-rempli       │        │
│  │        │                                                             │        │
│  │        └──► NON ──► App Store/Play Store ──► Installe ──► Ouvre    │        │
│  │                                              avec code en memoire    │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                                                                                  │
│  ENTREE 2: QR Code (scan depuis invitation)                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  Scanner QR ──► Decode URL ──► Meme flow que Deep Link              │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                                                                                  │
│  ENTREE 3: Code Manuel (depuis login page)                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  Login Page ──► "Rejoindre en tant qu'invite" ──► Page Join Wedding │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                                                                                  │
│                           │                                                      │
│                           ▼                                                      │
│  PAGE "REJOINDRE UN MARIAGE" (si pas de deep link)                              │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  ┌───────────────────────────────────────────────┐                  │        │
│  │  │  Entrez le code du mariage :                  │                  │        │
│  │  │  ┌───────────────────────────────────────┐    │                  │        │
│  │  │  │  _ _ _ _ _ _ _ _                      │    │  8 caracteres    │        │
│  │  │  └───────────────────────────────────────┘    │                  │        │
│  │  │                                                │                  │        │
│  │  │  [ Scanner QR Code ]                          │                  │        │
│  │  │                                                │                  │        │
│  │  │  [ Continuer → ]                              │                  │        │
│  │  └───────────────────────────────────────────────┘                  │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                           │                                                      │
│                           ▼                                                      │
│  VALIDATION CODE                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  Code valide? ──► NON ──► "Code invalide ou expire"                 │        │
│  │       │                    + Rate limit check (5/15min)             │        │
│  │       └──► OUI                                                       │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                           │                                                      │
│                           ▼                                                      │
│  CREATION COMPTE GUEST                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  Bienvenue au mariage de [Bride Name] !                             │        │
│  │                                                                      │        │
│  │  Prenom : _______________                                           │        │
│  │  Email : _______________ (pre-rempli si dans wedding_guests)        │        │
│  │  Mot de passe : _______________                                     │        │
│  │                                                                      │        │
│  │  [ ] J'accepte les conditions d'utilisation                         │        │
│  │                                                                      │        │
│  │  [ Creer mon compte invite ]                                        │        │
│  │                                                                      │        │
│  │  ──────── OU ────────                                               │        │
│  │                                                                      │        │
│  │  [ Connexion avec Apple ] [ Connexion avec Google ]                 │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                           │                                                      │
│                           ▼                                                      │
│  POST-CREATION                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  1. Creer profile avec role='guest'                                 │        │
│  │  2. Lier wedding_guests.user_id au profile                          │        │
│  │  3. Mettre status='joined', joined_at=NOW()                         │        │
│  │  4. Ajouter au chat_room type='wedding_team' du mariage             │        │
│  │  5. Creer guest_album pour ce guest                                 │        │
│  │  6. Rediriger vers interface Guest                                  │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                           │                                                      │
│                           ▼                                                      │
│  INTERFACE GUEST (3 tabs)                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │  ┌─────────────┬─────────────┬─────────────┐                        │        │
│  │  │    Album    │    Chat     │   Profil    │                        │        │
│  │  │     📸      │     💬      │     ⚙️      │                        │        │
│  │  └─────────────┴─────────────┴─────────────┘                        │        │
│  │                                                                      │        │
│  │  PAS d'acces a : Map, Feed, Wishlist, Dashboard Pro                 │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Interface Guest (3 Tabs)

```
┌─────────────────────────────────────────────────────────────────┐
│  GUEST INTERFACE - Mariage de [Bride Name]                      │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                                                            │  │
│  │  TAB 1: ALBUM (📸)                                        │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │  Mes photos et videos                               │   │  │
│  │  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐                       │   │  │
│  │  │  │ 📷 │ │ 📷 │ │ 🎬 │ │ 📷 │                       │   │  │
│  │  │  └────┘ └────┘ └────┘ └────┘                       │   │  │
│  │  │                                                     │   │  │
│  │  │  [ + Ajouter photo/video ]                         │   │  │
│  │  │                                                     │   │  │
│  │  │  [ ] Partager avec la mariee                       │   │  │
│  │  └────────────────────────────────────────────────────┘   │  │
│  │                                                            │  │
│  │  TAB 2: CHAT (💬)                                         │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │  Groupe du mariage                                  │   │  │
│  │  │  ─────────────────────────────────────────────────  │   │  │
│  │  │  [Avatar] Marie: Hate de vous voir tous ! 🎉       │   │  │
│  │  │  [Avatar] Pierre: On arrive vers 14h               │   │  │
│  │  │  [Avatar] Sophie: Trop bien !                       │   │  │
│  │  │  ─────────────────────────────────────────────────  │   │  │
│  │  │  [  Message...  ] [Envoyer]                        │   │  │
│  │  └────────────────────────────────────────────────────┘   │  │
│  │                                                            │  │
│  │  TAB 3: PROFIL (⚙️)                                       │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │  [Photo]                                            │   │  │
│  │  │  Prenom: Pierre                                     │   │  │
│  │  │  Email: pierre@example.com                          │   │  │
│  │  │                                                     │   │  │
│  │  │  ─────────────────────────────────────────────────  │   │  │
│  │  │                                                     │   │  │
│  │  │  ⚠️ Vous organisez votre propre mariage ?          │   │  │
│  │  │  [ Passer en compte Mariee ]                       │   │  │
│  │  │  Cette action est irreversible                      │   │  │
│  │  │                                                     │   │  │
│  │  │  ─────────────────────────────────────────────────  │   │  │
│  │  │  [ Se deconnecter ]                                │   │  │
│  │  │  [ Supprimer mon compte ]                          │   │  │
│  │  └────────────────────────────────────────────────────┘   │  │
│  │                                                            │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────┬─────────────┬─────────────┐                    │
│  │    📸       │     💬      │     ⚙️      │                    │
│  │   Album     │    Chat     │   Profil    │                    │
│  └─────────────┴─────────────┴─────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Modifier login page avec bouton Guest discret | Frontend | EPIC-06 | Bouton visible, navigation vers JoinWedding | US-03.4 | S |
| S02 | Creer page "Rejoindre un mariage" (code + QR) | Frontend | S01 | Input 8 chars, scanner QR, validation | US-03.4, US-03.5 | M |
| S03 | Implementer deep link handling (lynewed.app/join/{code}) | Frontend/Config | S02 | iOS + Android config, code pre-rempli | US-03.5 | M |
| S04 | Creer flow creation compte Guest | Frontend/Backend | S02, EPIC-06 | Profile guest cree, lie au wedding, status joined | US-03.6 | M |
| S05 | Implementer navigation Guest-specific (3 tabs) | Frontend | S04 | NavBar 3 tabs, pas d'acces autres features | US-03.7 | M |
| S06 | Creer Edge Function send-wedding-invitation (Resend) | Backend | EPIC-06 | Email envoye, code + QR inclus | US-03.1, US-03.3 | M |
| S07 | Ajouter UI envoi invitation pour bride | Frontend | S06 | Bouton envoi, feedback succes/erreur | US-03.1 | S |
| S08 | Implementer tracking statut guest (pending/invited/joined) | Frontend/Backend | S04, S07 | Statuts visibles, transitions correctes | US-03.2 | S |
| S09 | Creer flow Guest → Bride upgrade avec warning | Frontend/Backend | S05 | Confirmation dialog, irreversible, role change | US-03.8 | S |
| S10 | Setup trigger chat room wedding_team par defaut | Backend | EPIC-06 | Chat cree auto pour nouveau mariage | US-03.9 | S |
| S11 | Integrer guest dans systeme chat existant | Frontend/Backend | S04, S10 | Guest ajoute au chat, messages temps reel | D-17 | M |
| S12 | Creer RPC validate_invite_code | Backend | EPIC-06 | Validation code, rate limit, retour wedding info | US-03.4 | S |

**Total Stories** : 12
**Complexite estimee** : 2 jours (conforme PRD)

---

## Detail des Stories

### S01 : Modifier login page avec bouton Guest discret

**Description** : Ajouter un bouton discret sur la page de login permettant aux invites de rejoindre un mariage.

**Criteres cles** :
- Bouton "Rejoindre en tant qu'invite" visible mais non intrusif
- Placement en bas de la page login, sous les options Bride/Pro
- Style coherent avec le design system (icone + texte discret)
- Navigation vers la page JoinWedding

**Source PRD** : US-03.4, Section 5 - Flow d'onboarding Guest

**Complexite** : S (Small) - Modification UI simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest access button on login page

  Scenario: Guest button is visible on login page
    Given the user is on the login page
    When the page loads completely
    Then a discrete button "Rejoindre en tant qu'invite" should be visible
    And it should be positioned below the Bride/Pro selection
    And it should have a person icon

  Scenario: Tapping guest button navigates to JoinWedding page
    Given the user is on the login page
    When the user taps "Rejoindre en tant qu'invite"
    Then the app should navigate to the JoinWedding page
    And the JoinWedding page should display the code input field

  Scenario: Guest button does not interfere with existing login flow
    Given the user is on the login page
    When the user selects "Bride" and proceeds to login
    Then the normal bride login flow should work unchanged
```

**Fichiers a modifier** :
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/widgets/` (si nouveau widget)

---

### S02 : Creer page "Rejoindre un mariage" (code + QR)

**Description** : Page permettant aux guests de saisir le code du mariage ou scanner un QR code.

**Criteres cles** :
- Input pour code 8 caracteres (auto-uppercase, validation format)
- Bouton scanner QR code (ouvre camera)
- Bouton Continuer (disabled si code invalide)
- Rate limiting affiche si bloque (message erreur)
- Code peut etre pre-rempli via deep link

**Source PRD** : US-03.4, US-03.5, Section 5 - Flow d'onboarding Guest

**Complexite** : M (Medium) - Page avec logique validation + camera

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Join Wedding page with code input and QR scanner

  Scenario: Code input accepts 8 alphanumeric characters
    Given the user is on the JoinWedding page
    When the user types "abc12345"
    Then the input should display "ABC12345" (uppercase)
    And the Continue button should be enabled

  Scenario: Code input validates format
    Given the user is on the JoinWedding page
    When the user types "abc" (less than 8 chars)
    Then the Continue button should be disabled
    And a helper text "8 caracteres requis" should be displayed

  Scenario: QR scanner opens camera
    Given the user is on the JoinWedding page
    When the user taps "Scanner QR Code"
    Then the camera should open with QR scanner overlay
    And the scanner should detect QR codes

  Scenario: QR code with valid invite link is parsed
    Given the QR scanner is open
    When a QR code containing "https://lynewed.app/join/ABCD1234" is scanned
    Then the code "ABCD1234" should be extracted
    And the input field should be populated with "ABCD1234"
    And the scanner should close automatically

  Scenario: Valid code submits for validation
    Given the user has entered code "ABCD1234"
    When the user taps "Continuer"
    Then the app should call the validate_invite_code API
    And show a loading indicator during validation

  Scenario: Invalid code shows error message
    Given the user has entered an invalid code
    When the validation returns "invalid"
    Then an error message "Code invalide ou expire" should be displayed
    And the user should remain on the JoinWedding page

  Scenario: Rate limited user sees appropriate message
    Given the user has made 5 failed attempts in 15 minutes
    When the user tries again
    Then an error message "Trop de tentatives. Reessayez dans quelques minutes." should be displayed
    And the Continue button should be disabled temporarily

  Scenario: Deep link pre-fills the code
    Given the user opens the app via deep link "lynewed.app/join/WXYZ5678"
    When the JoinWedding page loads
    Then the code input should be pre-filled with "WXYZ5678"
    And validation should start automatically
```

**Fichiers a creer** :
- `lib/features/auth/presentation/pages/join_wedding_page.dart`
- `lib/features/auth/presentation/widgets/invite_code_input.dart`
- `lib/features/auth/presentation/widgets/qr_scanner_widget.dart`

**Dependencies** :
- Package **`mobile_scanner`** (recommandé) pour QR - https://pub.dev/packages/mobile_scanner
  - Plus maintenu que qr_code_scanner
  - Support MLKit (Google) et Vision (Apple)
  - Compatible iOS 12+ et Android 5+
  - Installation: `flutter pub add mobile_scanner`

---

### S03 : Implementer deep link handling (lynewed.app/join/{code})

**Description** : Configuration iOS et Android pour gerer les deep links d'invitation.

**Criteres cles** :
- URL format: `https://lynewed.app/join/{invite_code}`
- iOS: Universal Links configure
- Android: App Links configure
- App installee: ouvre directement avec code
- App non installee: redirige vers store puis ouvre avec code

**Source PRD** : US-03.5, Section 5 - Deep Linking

**Complexite** : M (Medium) - Configuration plateforme + logique routing

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Deep link handling for wedding invitations

  Background:
    Given the deep link format is "https://lynewed.app/join/{code}"

  Scenario: iOS Universal Link opens app with code (app installed)
    Given the Lynewed app is installed on iOS
    When the user taps a link "https://lynewed.app/join/ABCD1234"
    Then the Lynewed app should open
    And the JoinWedding page should display with code "ABCD1234" pre-filled
    And validation should start automatically

  Scenario: Android App Link opens app with code (app installed)
    Given the Lynewed app is installed on Android
    When the user taps a link "https://lynewed.app/join/ABCD1234"
    Then the Lynewed app should open
    And the JoinWedding page should display with code "ABCD1234" pre-filled

  Scenario: Deep link when app not installed (iOS)
    Given the Lynewed app is NOT installed on iOS
    When the user taps a link "https://lynewed.app/join/ABCD1234"
    Then the user should be redirected to the App Store
    And after installation and first launch, the code should be retrieved
    And the JoinWedding page should pre-fill the code

  Scenario: Deep link when app not installed (Android)
    Given the Lynewed app is NOT installed on Android
    When the user taps a link "https://lynewed.app/join/ABCD1234"
    Then the user should be redirected to the Play Store
    And after installation and first launch, the code should be retrieved

  Scenario: Deep link with expired code
    Given the user opens the app via deep link with an expired code
    When validation occurs
    Then an error "Ce code d'invitation a expire" should be displayed
    And the user should be able to enter a different code

  Scenario: Deep link handling when user is already logged in as Guest
    Given the user is already logged in as a Guest for wedding A
    When the user taps a deep link for wedding B
    Then a message "Vous etes deja connecte a un mariage" should be displayed
    And the user should have option to logout and join new wedding
```

**Configuration iOS** (ios/Runner/Runner.entitlements):
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:lynewed.app</string>
</array>
```

**Configuration Android** (android/app/src/main/AndroidManifest.xml):
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="lynewed.app" android:pathPrefix="/join" />
</intent-filter>
```

**Fichiers a modifier/creer** :
- `ios/Runner/Runner.entitlements`
- `android/app/src/main/AndroidManifest.xml`
- `lib/core/navigation/deep_link_handler.dart`
- `lib/core/navigation/app_router.dart`

---

### S04 : Creer flow creation compte Guest

**Description** : Flow complet de creation de compte pour un guest apres validation du code.

**Criteres cles** :
- Page creation compte avec: prenom, email, mot de passe
- Email pre-rempli si guest existe dans wedding_guests
- Support OAuth (Apple, Google)
- Creation profile avec role='guest'
- Liaison wedding_guests.user_id
- Mise a jour status='joined', joined_at
- Creation guest_album automatique
- Ajout au chat_room wedding_team

**Source PRD** : US-03.6, Section 5 - Creation Compte Guest

**Complexite** : M (Medium) - Flow multi-etapes avec backend

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest account creation flow

  Background:
    Given the user has validated invite code "ABCD1234"
    And the wedding belongs to bride "Marie"

  Scenario: Guest creation page shows wedding info
    When the guest creation page loads
    Then a welcome message "Bienvenue au mariage de Marie !" should be displayed
    And input fields for prenom, email, password should be visible

  Scenario: Email is pre-filled if guest exists in wedding_guests
    Given a wedding_guest entry exists with email "pierre@example.com"
    When the guest creation page loads
    Then the email field should be pre-filled with "pierre@example.com"
    And the email field should be editable

  Scenario: Creating account with email/password
    Given the user fills in:
      | Field | Value |
      | Prenom | Pierre |
      | Email | pierre@example.com |
      | Password | SecurePass123! |
    And the user accepts terms of service
    When the user taps "Creer mon compte invite"
    Then a profile should be created with role='guest'
    And wedding_guests.user_id should be linked to the profile
    And wedding_guests.status should be 'joined'
    And wedding_guests.joined_at should be set to current timestamp
    And a guest_album should be created for this user
    And the user should be added to the wedding_team chat room
    And the user should be navigated to the Guest home page

  Scenario: Creating account with Apple Sign-In
    Given the user taps "Connexion avec Apple"
    When Apple authentication succeeds
    Then a profile should be created with role='guest'
    And all the same post-creation steps should occur

  Scenario: Creating account with Google Sign-In
    Given the user taps "Connexion avec Google"
    When Google authentication succeeds
    Then a profile should be created with role='guest'
    And all the same post-creation steps should occur

  Scenario: Terms acceptance is required
    Given the user has filled all fields
    But has not checked "J'accepte les conditions"
    When the user tries to tap "Creer mon compte invite"
    Then the button should be disabled
    And a message "Veuillez accepter les conditions" should appear

  Scenario: Email already registered shows appropriate message
    Given "pierre@example.com" is already registered
    When the user tries to create account with that email
    Then an error "Cet email est deja utilise" should be displayed
    And a link "Se connecter" should be offered
```

**Fichiers a creer** :
- `lib/features/auth/presentation/pages/guest_signup_page.dart`
- `lib/features/auth/domain/usecases/create_guest_account.dart`
- `lib/features/auth/data/repositories/guest_auth_repository.dart`

**Backend (Edge Function ou RPC)** :
```sql
-- Function: join_wedding_as_guest
CREATE OR REPLACE FUNCTION join_wedding_as_guest(
  p_user_id UUID,
  p_invite_code VARCHAR(8)
)
RETURNS JSONB AS $$
DECLARE
  v_wedding RECORD;
  v_guest_id UUID;
  v_chat_room_id UUID;
  v_album_id UUID;
BEGIN
  -- 1. Validate invite code and get wedding
  SELECT * INTO v_wedding FROM weddings
  WHERE invite_code = p_invite_code
  AND invite_code_expires_at > NOW();

  IF v_wedding IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_code');
  END IF;

  -- 2. Find or create wedding_guest entry
  SELECT id INTO v_guest_id FROM wedding_guests
  WHERE wedding_id = v_wedding.id
  AND (user_id = p_user_id OR email = (SELECT email FROM auth.users WHERE id = p_user_id));

  IF v_guest_id IS NULL THEN
    INSERT INTO wedding_guests (wedding_id, user_id, name, status, joined_at)
    VALUES (v_wedding.id, p_user_id,
            (SELECT raw_user_meta_data->>'first_name' FROM auth.users WHERE id = p_user_id),
            'joined', NOW())
    RETURNING id INTO v_guest_id;
  ELSE
    UPDATE wedding_guests
    SET user_id = p_user_id, status = 'joined', joined_at = NOW()
    WHERE id = v_guest_id;
  END IF;

  -- 3. Get wedding_team chat room
  SELECT id INTO v_chat_room_id FROM chat_rooms
  WHERE wedding_id = v_wedding.id AND type = 'wedding_team';

  -- 4. Add guest to chat room participants
  INSERT INTO chat_room_participants (room_id, user_id, joined_at)
  VALUES (v_chat_room_id, p_user_id, NOW())
  ON CONFLICT DO NOTHING;

  -- 5. Create guest album
  INSERT INTO guest_albums (wedding_id, guest_user_id, shared_with_bride)
  VALUES (v_wedding.id, p_user_id, false)
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_album_id;

  RETURN jsonb_build_object(
    'success', true,
    'wedding_id', v_wedding.id,
    'bride_name', (SELECT first_name FROM profiles WHERE id = v_wedding.bride_profile_id),
    'chat_room_id', v_chat_room_id,
    'album_id', v_album_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

### S05 : Implementer navigation Guest-specific (3 tabs)

**Description** : Interface de navigation dediee aux guests avec 3 onglets uniquement.

**Criteres cles** :
- NavBar avec 3 tabs: Album, Chat, Profil
- Pas d'acces aux autres features (Map, Feed, Wishlist, etc.)
- Detection role guest au login pour router vers cette interface
- Header affiche nom du mariage

**Source PRD** : US-03.7, Section 5 - Interface Guest

**Complexite** : M (Medium) - Nouvelle structure navigation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest-specific navigation with 3 tabs

  Background:
    Given the user is logged in with role='guest'
    And the user belongs to wedding of "Marie"

  Scenario: Guest sees 3-tab navigation bar
    When the guest home page loads
    Then a bottom navigation bar should be visible
    And it should have exactly 3 tabs: Album, Chat, Profil
    And the Album tab should be selected by default

  Scenario: Album tab shows guest's personal album
    Given the user is on the Guest home page
    When the user taps the Album tab
    Then the guest's album page should load
    And it should show "Mes photos et videos" header
    And a button to add photos/videos should be visible

  Scenario: Chat tab shows wedding group chat
    Given the user is on the Guest home page
    When the user taps the Chat tab
    Then the wedding team chat should load
    And the chat room name should be "Groupe du mariage"
    And the user should see messages from other guests and bride

  Scenario: Profil tab shows guest profile
    Given the user is on the Guest home page
    When the user taps the Profil tab
    Then the guest profile page should load
    And the user's name and email should be displayed
    And a "Passer en compte Mariee" button should be visible

  Scenario: Guest cannot access Map feature
    Given the user is logged in as guest
    When the user tries to navigate to "/map" directly
    Then the user should be redirected to the Guest home page
    And a message "Cette fonctionnalite n'est pas disponible pour les invites" should appear

  Scenario: Guest cannot access Feed feature
    Given the user is logged in as guest
    When the user tries to navigate to "/feed" directly
    Then the user should be redirected to the Guest home page

  Scenario: Guest cannot access Wishlist feature
    Given the user is logged in as guest
    When the user tries to navigate to "/wishlist" directly
    Then the user should be redirected to the Guest home page

  Scenario: Header shows wedding name
    Given the user is on any Guest tab
    Then the app bar should display "Mariage de Marie"
```

**Fichiers a creer** :
- `lib/features/guest/presentation/pages/guest_home_page.dart`
- `lib/features/guest/presentation/pages/guest_album_page.dart`
- `lib/features/guest/presentation/pages/guest_chat_page.dart`
- `lib/features/guest/presentation/pages/guest_profile_page.dart`
- `lib/features/guest/presentation/widgets/guest_nav_bar.dart`

**Modification routing** :
- `lib/core/navigation/app_router.dart` - Ajouter routes guest + guards

---

### S06 : Creer Edge Function send-wedding-invitation (Resend)

**Description** : Edge Function pour envoyer les emails d'invitation aux guests.

**Criteres cles** :
- Integration Resend pour envoi email
- Template HTML avec: nom mariee, code, QR code, lien deep link
- QR code genere dynamiquement
- Mise a jour wedding_guests.status='invited', invited_at
- Gestion erreurs (email invalide, rate limit Resend)

**Source PRD** : US-03.1, US-03.3, Section 5 - Envoi d'emails

**Complexite** : M (Medium) - Edge Function avec integration externe

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Send wedding invitation email via Edge Function

  Background:
    Given the wedding has invite_code "ABCD1234"
    And the bride name is "Marie"

  Scenario: Sending invitation email successfully
    Given a guest with email "pierre@example.com"
    When the Edge Function send-wedding-invitation is called with:
      | guest_id | wedding_id |
      | {uuid}   | {uuid}     |
    Then an email should be sent to "pierre@example.com"
    And the email subject should be "Vous etes invite(e) au mariage de Marie !"
    And the email body should contain the invite code "ABCD1234"
    And the email should contain a QR code image
    And the email should contain a deep link "https://lynewed.app/join/ABCD1234"
    And wedding_guests.status should be updated to 'invited'
    And wedding_guests.invited_at should be set to current timestamp

  Scenario: Email template content
    When the invitation email is generated
    Then it should contain:
      | Element | Content |
      | Header | "Vous etes invite(e) au mariage de Marie !" |
      | Instructions | "Telechargez l'app Lynewed et rejoignez le mariage." |
      | Code | "Code mariage : ABCD1234" |
      | QR Code | [QR image encoding the deep link] |
      | Button | "Rejoindre le mariage" linking to deep link |
      | Footer | "Ce code expire dans 30 jours" |

  Scenario: QR code encodes the deep link URL
    When the QR code is generated
    Then it should encode "https://lynewed.app/join/ABCD1234"
    And scanning the QR code should resolve to that URL

  Scenario: Handling invalid email address
    Given a guest with invalid email "not-an-email"
    When the Edge Function is called
    Then it should return an error "invalid_email"
    And no email should be sent
    And wedding_guests.status should remain unchanged

  Scenario: Handling Resend rate limit
    Given Resend rate limit has been exceeded
    When the Edge Function is called
    Then it should return an error "rate_limited"
    And the response should include retry_after timestamp

  Scenario: Handling missing guest
    Given a non-existent guest_id
    When the Edge Function is called
    Then it should return an error "guest_not_found"

  Scenario: Multiple invitations to same guest
    Given a guest already has status='invited'
    When the Edge Function is called again
    Then a new email should be sent (re-invitation)
    And invited_at should be updated to current timestamp
```

**Edge Function Code** :
```typescript
// supabase/functions/send-wedding-invitation/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "npm:resend@2.0.0";
import QRCode from "npm:qrcode@1.5.3";

const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

serve(async (req) => {
  const { guest_id, wedding_id } = await req.json();

  // 1. Get guest and wedding info from Supabase
  const supabase = createClient(...);

  const { data: guest } = await supabase
    .from('wedding_guests')
    .select('*, weddings!inner(invite_code, bride_profile_id, profiles!bride_profile_id(first_name))')
    .eq('id', guest_id)
    .single();

  if (!guest) {
    return new Response(JSON.stringify({ error: 'guest_not_found' }), { status: 404 });
  }

  const inviteCode = guest.weddings.invite_code;
  const brideName = guest.weddings.profiles.first_name;
  const deepLink = `https://lynewed.app/join/${inviteCode}`;

  // 2. Generate QR code
  const qrCodeDataUrl = await QRCode.toDataURL(deepLink, { width: 200 });

  // 3. Send email via Resend
  const { data, error } = await resend.emails.send({
    from: 'Lynewed <noreply@lynewed.app>',
    to: guest.email,
    subject: `Vous etes invite(e) au mariage de ${brideName} !`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h1 style="color: #D4A574;">Vous etes invite(e) au mariage de ${brideName} !</h1>
        <p>Telechargez l'app Lynewed et rejoignez le mariage pour partager vos photos et discuter avec les autres invites.</p>
        <p><strong>Code mariage :</strong> <span style="font-size: 24px; letter-spacing: 4px;">${inviteCode}</span></p>
        <div style="text-align: center; margin: 30px 0;">
          <img src="${qrCodeDataUrl}" alt="QR Code" style="width: 200px; height: 200px;" />
        </div>
        <div style="text-align: center;">
          <a href="${deepLink}" style="background-color: #D4A574; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; display: inline-block;">
            Rejoindre le mariage
          </a>
        </div>
        <p style="color: #666; font-size: 12px; margin-top: 30px;">Ce code expire dans 30 jours.</p>
      </div>
    `,
  });

  if (error) {
    return new Response(JSON.stringify({ error: 'email_failed', details: error }), { status: 500 });
  }

  // 4. Update guest status
  await supabase
    .from('wedding_guests')
    .update({ status: 'invited', invited_at: new Date().toISOString() })
    .eq('id', guest_id);

  return new Response(JSON.stringify({ success: true, email_id: data.id }), { status: 200 });
});
```

---

### S07 : Ajouter UI envoi invitation pour bride

**Description** : Interface permettant a la mariee d'envoyer des invitations a ses guests.

**Criteres cles** :
- Bouton "Envoyer invitation" sur chaque guest dans la liste
- Action disponible uniquement si guest a un email
- Feedback visuel: loading, succes, erreur
- Mise a jour statut visible apres envoi

**Source PRD** : US-03.1

**Complexite** : S (Small) - Modification UI existante

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Bride can send invitations to guests

  Background:
    Given the bride is logged in
    And is viewing her wedding guests list

  Scenario: Send invitation button is visible for guests with email
    Given a guest "Pierre" has email "pierre@example.com"
    When viewing the guest details
    Then a "Envoyer l'invitation" button should be visible

  Scenario: Send invitation button is hidden for guests without email
    Given a guest "Marie" has no email
    When viewing the guest details
    Then the "Envoyer l'invitation" button should NOT be visible
    And a message "Ajoutez un email pour envoyer une invitation" should appear

  Scenario: Sending invitation shows loading state
    Given a guest with valid email
    When the bride taps "Envoyer l'invitation"
    Then the button should show a loading spinner
    And the button should be disabled during loading

  Scenario: Successful invitation shows confirmation
    Given the invitation email was sent successfully
    When the loading completes
    Then a success toast "Invitation envoyee !" should appear
    And the guest status should change to "Invite"
    And a green checkmark badge should appear next to the guest

  Scenario: Failed invitation shows error
    Given the email service fails
    When the loading completes
    Then an error toast "Echec de l'envoi. Verifiez l'email." should appear
    And the guest status should remain unchanged

  Scenario: Re-sending invitation to already invited guest
    Given a guest already has status "Invite"
    When viewing the guest details
    Then a "Renvoyer l'invitation" button should be visible
    And tapping it should send another email

  Scenario: Status badges are displayed correctly
    Given the guests list
    Then guests with status "pending" should show no badge
    And guests with status "invited" should show "Invite" badge (yellow)
    And guests with status "joined" should show "Rejoint" badge (green)
```

**Fichiers a modifier** :
- `lib/features/my_wedding/presentation/pages/wedding_guests_page.dart`
- `lib/features/my_wedding/presentation/widgets/guest_tile.dart`
- `lib/features/my_wedding/domain/usecases/send_guest_invitation.dart`

---

### S08 : Implementer tracking statut guest (pending/invited/joined)

**Description** : Affichage et gestion des statuts d'invitation des guests.

**Criteres cles** :
- Affichage visuel du statut (badge colore)
- Filtrage par statut dans la liste guests
- Compteurs par statut (ex: "3 invites, 2 ont rejoint")
- Transitions correctes entre statuts

**Source PRD** : US-03.2

**Complexite** : S (Small) - UI + logique simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest invitation status tracking

  Scenario: Status counters are displayed
    Given the wedding has:
      | Status | Count |
      | pending | 5 |
      | invited | 3 |
      | joined | 2 |
    When viewing the guests list
    Then a summary "10 invites - 3 invitations envoyees - 2 ont rejoint" should be displayed

  Scenario: Filter guests by status
    Given the guests list with mixed statuses
    When the bride taps the filter icon
    Then filter options "Tous", "En attente", "Invites", "Ont rejoint" should appear

    When the bride selects "Ont rejoint"
    Then only guests with status='joined' should be displayed

  Scenario: Status transition: pending → invited
    Given a guest with status "pending"
    When an invitation is sent successfully
    Then the status should change to "invited"
    And the invited_at timestamp should be set

  Scenario: Status transition: invited → joined
    Given a guest with status "invited"
    When the guest creates an account and joins
    Then the status should change to "joined"
    And the joined_at timestamp should be set
    And the user_id should be linked

  Scenario: Status badges use correct colors
    Then status "pending" should display gray badge
    And status "invited" should display yellow badge with envelope icon
    And status "joined" should display green badge with checkmark icon
```

**Fichiers a modifier** :
- `lib/features/my_wedding/presentation/widgets/guest_status_badge.dart`
- `lib/features/my_wedding/presentation/pages/wedding_guests_page.dart`

---

### S09 : Creer flow Guest → Bride upgrade avec warning

**Description** : Permettre a un guest de passer en compte Bride (irreversible).

**Criteres cles** :
- Bouton "Passer en compte Mariee" dans profil guest
- Dialog de confirmation avec avertissement irreversible
- Changement de role profile: guest → bride
- Conservation des donnees existantes
- Redirection vers interface Bride apres upgrade

**Source PRD** : US-03.8, Section 3 - Upgrade de role

**Complexite** : S (Small) - Flow simple avec confirmation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest to Bride account upgrade

  Background:
    Given the user is logged in as a guest

  Scenario: Upgrade button is visible in profile
    When viewing the guest profile page
    Then a section "Vous organisez votre propre mariage ?" should be visible
    And a button "Passer en compte Mariee" should be displayed
    And a warning text "Cette action est irreversible" should appear

  Scenario: Tapping upgrade shows confirmation dialog
    When the user taps "Passer en compte Mariee"
    Then a confirmation dialog should appear
    And it should contain:
      | Element | Content |
      | Title | "Passer en compte Mariee" |
      | Warning | "Attention : cette action est irreversible. Vous ne pourrez plus revenir en compte invite." |
      | Info | "Vous conserverez vos photos et votre compte." |
      | Cancel button | "Annuler" |
      | Confirm button | "Je confirme" |

  Scenario: Canceling upgrade returns to profile
    Given the confirmation dialog is displayed
    When the user taps "Annuler"
    Then the dialog should close
    And the user should remain on the guest profile page
    And the user role should still be 'guest'

  Scenario: Confirming upgrade changes role
    Given the confirmation dialog is displayed
    When the user taps "Je confirme"
    Then a loading indicator should appear
    And the profile.role should be updated to 'bride'
    And the user should be navigated to the Bride home page
    And a success message "Bienvenue ! Vous pouvez maintenant creer votre mariage." should appear

  Scenario: Upgraded user can create wedding
    Given the user has just upgraded to bride
    When viewing the Bride home page
    Then a button "Creer mon mariage" should be visible
    And tapping it should open the wedding creation flow

  Scenario: Upgraded user keeps existing data
    Given the guest has uploaded 5 photos
    When the user upgrades to bride
    Then the photos should still be accessible
    And the account email and profile info should be unchanged

  Scenario: Upgrade failure shows error
    Given a network error occurs during upgrade
    When the user confirms the upgrade
    Then an error message "Une erreur est survenue. Reessayez." should appear
    And the user should remain as guest
    And the user can retry the upgrade
```

**Backend** :
```sql
-- Function: upgrade_guest_to_bride
CREATE OR REPLACE FUNCTION upgrade_guest_to_bride(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Verify current role is guest
  IF NOT EXISTS (
    SELECT 1 FROM profiles WHERE id = p_user_id AND role = 'guest'
  ) THEN
    RAISE EXCEPTION 'User is not a guest';
  END IF;

  -- Update role
  UPDATE profiles
  SET role = 'bride', updated_at = NOW()
  WHERE id = p_user_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Fichiers a modifier/creer** :
- `lib/features/guest/presentation/pages/guest_profile_page.dart`
- `lib/features/guest/presentation/widgets/upgrade_to_bride_section.dart`
- `lib/features/auth/domain/usecases/upgrade_to_bride.dart`

---

### S10 : Setup trigger chat room wedding_team par defaut

**Description** : Creer automatiquement un chat room wedding_team quand un nouveau mariage est cree.

**Criteres cles** :
- Trigger sur INSERT weddings
- Cree chat_room avec type='wedding_team', name='Groupe du mariage'
- Ajoute la bride comme premiere participante

**Source PRD** : US-03.9, Decision D-17

**Complexite** : S (Small) - Trigger SQL simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Automatic wedding_team chat room creation

  Scenario: Chat room created when wedding is created
    Given a bride creates a new wedding
    When the wedding is inserted into the database
    Then a new chat_room should be created automatically
    And the chat_room.type should be 'wedding_team'
    And the chat_room.name should be 'Groupe du mariage'
    And the chat_room.wedding_id should reference the new wedding
    And the chat_room.is_active should be TRUE

  Scenario: Bride is added as first participant
    Given a wedding is created with bride_profile_id
    When the chat_room is created
    Then the bride should be added to chat_room_participants
    And the bride should have joined_at timestamp set

  Scenario: Existing weddings without chat room
    Given existing weddings created before this trigger
    When running a backfill migration
    Then each wedding without a wedding_team chat should get one created
    And all brides should be added as participants

  Scenario: Multiple weddings create separate chat rooms
    Given bride A creates wedding 1
    And bride B creates wedding 2
    When both weddings are created
    Then wedding 1 should have its own chat_room
    And wedding 2 should have its own separate chat_room
    And each chat_room should reference the correct wedding_id
```

**Migration SQL** :
```sql
-- Migration: create_default_wedding_chat_trigger
-- Description: Automatically create wedding_team chat room when wedding is created

-- Trigger function
CREATE OR REPLACE FUNCTION create_default_wedding_chat()
RETURNS TRIGGER AS $$
DECLARE
  v_room_id UUID;
BEGIN
  -- Create the chat room
  INSERT INTO chat_rooms (type, name, is_active, wedding_id)
  VALUES ('wedding_team', 'Groupe du mariage', TRUE, NEW.id)
  RETURNING id INTO v_room_id;

  -- Add bride as first participant
  INSERT INTO chat_room_participants (room_id, user_id, joined_at)
  VALUES (v_room_id, NEW.bride_profile_id, NOW());

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trg_wedding_default_chat ON weddings;
CREATE TRIGGER trg_wedding_default_chat
  AFTER INSERT ON weddings
  FOR EACH ROW
  EXECUTE FUNCTION create_default_wedding_chat();

-- Backfill: Create chat rooms for existing weddings without one
DO $$
DECLARE
  r RECORD;
  v_room_id UUID;
BEGIN
  FOR r IN
    SELECT w.id as wedding_id, w.bride_profile_id
    FROM weddings w
    WHERE NOT EXISTS (
      SELECT 1 FROM chat_rooms cr
      WHERE cr.wedding_id = w.id AND cr.type = 'wedding_team'
    )
  LOOP
    INSERT INTO chat_rooms (type, name, is_active, wedding_id)
    VALUES ('wedding_team', 'Groupe du mariage', TRUE, r.wedding_id)
    RETURNING id INTO v_room_id;

    INSERT INTO chat_room_participants (room_id, user_id, joined_at)
    VALUES (v_room_id, r.bride_profile_id, NOW())
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;

COMMENT ON FUNCTION create_default_wedding_chat IS 'Creates wedding_team chat room and adds bride when wedding is created';
```

---

### S11 : Integrer guest dans systeme chat existant

**Description** : Permettre aux guests d'utiliser le chat wedding_team avec le systeme existant.

**Criteres cles** :
- Guest ajoute a chat_room_participants lors du join
- Utilisation du ChatRemoteDatasource existant
- Messages temps reel via Supabase Realtime
- Coherence UI avec chat existant

**Source PRD** : Decision D-17

**Complexite** : M (Medium) - Integration avec systeme existant

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Guest integration with existing chat system

  Background:
    Given the guest has joined the wedding
    And was added to chat_room_participants

  Scenario: Guest can view wedding team chat
    When the guest opens the Chat tab
    Then the wedding_team chat room should be displayed
    And all previous messages should be visible
    And participant avatars should show other guests and bride

  Scenario: Guest can send text messages
    Given the guest is in the wedding_team chat
    When the guest types "Bonjour tout le monde !" and sends
    Then the message should appear in the chat immediately
    And other participants should receive the message in real-time

  Scenario: Guest receives real-time messages
    Given the guest has the chat open
    When the bride sends a message "Bienvenue Pierre !"
    Then the message should appear in the guest's chat within 1 second
    And a notification sound should play (if enabled)

  Scenario: Guest can send images
    Given the guest is in the wedding_team chat
    When the guest taps the image button and selects a photo
    Then the image should be uploaded
    And the image message should appear in the chat

  Scenario: Chat uses existing ChatRemoteDatasource
    When the guest opens the chat
    Then the ChatRemoteDatasource should be used to fetch messages
    And the same Supabase Realtime subscription should be used

  Scenario: Guest sees correct participant list
    Given the wedding has:
      | Participant | Role |
      | Marie | Bride |
      | Pierre | Guest |
      | Sophie | Guest |
    When viewing the chat info
    Then all 3 participants should be listed
    And their avatars should be displayed

  Scenario: Guest cannot create new chat rooms
    Given the guest is on the Chat tab
    Then there should be no "New chat" button
    And only the wedding_team chat should be accessible

  Scenario: Guest can see unread message count
    Given the guest has unread messages in the chat
    When viewing the bottom navigation
    Then the Chat tab should show an unread badge
```

**Fichiers a modifier** :
- `lib/features/guest/presentation/pages/guest_chat_page.dart` (wrapper around existing chat)
- `lib/features/chat/data/datasources/chat_remote_datasource.dart` (verify guest access works)

**RLS Policy update** (if needed):
```sql
-- Ensure guests can access their wedding_team chat
CREATE POLICY "Guest can access wedding_team chat" ON chat_rooms
FOR SELECT USING (
  type = 'wedding_team' AND
  EXISTS (
    SELECT 1 FROM wedding_guests wg
    WHERE wg.wedding_id = chat_rooms.wedding_id
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);

CREATE POLICY "Guest can read wedding_team messages" ON chat_messages
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN wedding_guests wg ON wg.wedding_id = cr.wedding_id
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);

CREATE POLICY "Guest can send wedding_team messages" ON chat_messages
FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM chat_rooms cr
    JOIN wedding_guests wg ON wg.wedding_id = cr.wedding_id
    WHERE cr.id = chat_messages.room_id
    AND cr.type = 'wedding_team'
    AND wg.user_id = auth.uid()
    AND wg.status = 'joined'
  )
);
```

---

## Deep Linking Configuration

### iOS Configuration

**File: `ios/Runner/Runner.entitlements`**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:lynewed.app</string>
        <string>applinks:www.lynewed.app</string>
    </array>
</dict>
</plist>
```

**File: `ios/Runner/Info.plist`** (add):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>lynewed</string>
        </array>
    </dict>
</array>
```

### Android Configuration

**File: `android/app/src/main/AndroidManifest.xml`** (add inside `<activity>`):
```xml
<!-- Deep Links for Wedding Invitations -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="lynewed.app"
        android:pathPrefix="/join" />
</intent-filter>
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="www.lynewed.app"
        android:pathPrefix="/join" />
</intent-filter>
<!-- Custom scheme fallback -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="lynewed" android:host="join" />
</intent-filter>
```

### Server Configuration

> ⚠️ **IMPORTANT**: Ces fichiers doivent être hébergés sur lynewed.app AVANT de tester les deep links.

#### iOS: Apple App Site Association (AASA)

**File: `/.well-known/apple-app-site-association`** (hosted on https://lynewed.app):
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.lynewed.app",
        "paths": ["/join/*"]
      }
    ]
  }
}
```

**Configuration requise**:
1. Fichier servi depuis `https://lynewed.app/.well-known/apple-app-site-association`
2. Content-Type: `application/json` (PAS `application/pkcs7-mime`)
3. HTTPS obligatoire (pas de redirect HTTP → HTTPS)
4. Remplacer `TEAM_ID` par l'ID d'équipe Apple Developer (format: `A1B2C3D4E5`)
5. Le fichier doit être accessible sans authentification

**Pour obtenir TEAM_ID**:
```bash
# Dans Apple Developer Portal > Membership > Team ID
# Ou via Xcode: Preferences > Accounts > Team
```

**Tester la configuration iOS**:
```bash
# Valider le fichier AASA
curl -I https://lynewed.app/.well-known/apple-app-site-association

# Doit retourner:
# HTTP/2 200
# content-type: application/json

# Outil Apple de validation:
# https://search.developer.apple.com/appsearch-validation-tool/
```

#### Android: Asset Links

**File: `/.well-known/assetlinks.json`** (hosted on https://lynewed.app):
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.lynewed.app",
    "sha256_cert_fingerprints": ["SHA256_FINGERPRINT"]
  }
}]
```

**Pour obtenir SHA256_FINGERPRINT**:
```bash
# Pour le keystore de release:
keytool -list -v -keystore ~/upload-keystore.jks -alias upload

# Copier la ligne SHA256 (format: AA:BB:CC:DD:...)
```

**Tester la configuration Android**:
```bash
# Valider le fichier assetlinks
curl https://lynewed.app/.well-known/assetlinks.json

# Outil Google de validation:
# https://developers.google.com/digital-asset-links/tools/generator
```

#### Déploiement serveur (Supabase/Vercel)

Si lynewed.app est sur Supabase ou Vercel, ajouter ces fichiers:

**Option Vercel** (`vercel.json`):
```json
{
  "rewrites": [
    { "source": "/.well-known/apple-app-site-association", "destination": "/api/aasa" },
    { "source": "/.well-known/assetlinks.json", "destination": "/api/assetlinks" }
  ]
}
```

**Option Supabase Edge Function**:
```typescript
// supabase/functions/aasa/index.ts
Deno.serve(() => new Response(JSON.stringify({
  applinks: { apps: [], details: [{ appID: "TEAM_ID.com.lynewed.app", paths: ["/join/*"] }] }
}), { headers: { "content-type": "application/json" } }));
```

---

## Edge Function Specifications

### send-wedding-invitation

| Attribute | Value |
|-----------|-------|
| **Name** | send-wedding-invitation |
| **Trigger** | HTTP POST |
| **Auth** | JWT Required (bride only) |
| **Rate Limit** | 10 invitations/minute |

**Request Body**:
```json
{
  "guest_id": "uuid",
  "wedding_id": "uuid"
}
```

**Response Success**:
```json
{
  "success": true,
  "email_id": "resend_email_id",
  "status": "invited"
}
```

**Response Errors**:
```json
{ "error": "guest_not_found" }
{ "error": "invalid_email" }
{ "error": "rate_limited", "retry_after": 1706450400 }
{ "error": "email_service_error", "details": "..." }
```

**Dependencies**:
- Resend API Key (env: `RESEND_API_KEY`)
- QR Code generation library (`qrcode`)

---

## Risques et Mitigations

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Deep links ne fonctionnent pas sur certains devices | MOYEN | Moyenne | Code manuel toujours disponible, tests sur multiples devices |
| QR code illisible dans email | MOYEN | Faible | Taille 200x200 minimum, contraste eleve, code texte en backup |
| Rate limiting trop strict | FAIBLE | Moyenne | Configurable (5 attempts/15min), message d'erreur clair |
| Resend service down | MOYEN | Faible | Retry automatique, queue pour retry differe |
| Guest tente d'acceder a features bride | FAIBLE | Elevee | Guards sur toutes les routes, redirection automatique |
| Collision email entre guests | FAIBLE | Faible | Verification email unique par wedding |

---

## Ordre d'Execution Recommande

```
EPIC-06 (PREREQUIS) ← DOIT ETRE COMPLETE AVANT

S01 (Login page guest button)
  │
  └──► S02 (Join wedding page) ──► S03 (Deep links)
                │
                └──► S04 (Guest account creation)
                        │
                        ├──► S05 (Guest navigation 3 tabs)
                        │       │
                        │       └──► S09 (Guest → Bride upgrade)
                        │
                        └──► S11 (Chat integration) ◄── S10 (Chat trigger)

S06 (Edge Function email) ──► S07 (Send invitation UI) ──► S08 (Status tracking)
```

**Ordre sequentiel suggere pour developpement:**
1. S10 - Trigger chat room (backend, peut etre fait en parallele)
2. S01 - Login page modification
3. S02 - Join wedding page
4. S06 - Edge Function (backend, peut etre fait en parallele)
5. S03 - Deep links configuration
6. S04 - Guest account creation
7. S05 - Guest navigation
8. S11 - Chat integration
9. S07 - Send invitation UI
10. S08 - Status tracking
11. S09 - Guest → Bride upgrade

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 5 (APP-03) | Specifications completes du systeme d'invitation |
| Section 3 | Role Guest definition, upgrade vers Bride |
| Decision D-14 | Guests peuvent creer des reels (pour futur Epic) |
| Decision D-15 | Code 8 caracteres + expiration 30j |
| Decision D-17 | Reutiliser chat_rooms avec type='wedding_team' |
| Section 12 | CGVU - Termes acceptation compte |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Completer EPIC-06-PREREQUISITES (bloquant)
2. Executer `/create-story EPIC-09` pour decomposer en stories individuelles
3. Commencer par S01 + S10 en parallele
4. Valider deep links sur devices physiques iOS et Android
5. Tester le flow complet end-to-end
6. Passer a EPIC-10 (APP-04 Projet Photo & Video)
