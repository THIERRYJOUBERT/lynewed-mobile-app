# Story S04: Creer flow creation compte Guest

## Description
En tant que guest, je veux pouvoir creer un compte apres avoir valide le code d'invitation, afin de rejoindre le mariage et acceder a mes fonctionnalites dediees.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the user has validated invite code "ABCD1234" And the wedding belongs to bride "Marie" When the guest creation page loads Then a welcome message "Bienvenue au mariage de Marie !" should be displayed And input fields for prenom, email, password should be visible
- [ ] Given a wedding_guest entry exists with email "pierre@example.com" When the guest creation page loads Then the email field should be pre-filled with "pierre@example.com" And the email field should be editable
- [ ] Given the user fills in Prenom="Pierre", Email="pierre@example.com", Password="SecurePass123!" And the user accepts terms of service When the user taps "Creer mon compte invite" Then a profile should be created with role='guest' And wedding_guests.user_id should be linked to the profile And wedding_guests.status should be 'joined' And wedding_guests.joined_at should be set to current timestamp And a guest_album should be created for this user And the user should be added to the wedding_team chat room And the user should be navigated to the Guest home page
- [ ] Given the user taps "Connexion avec Apple" When Apple authentication succeeds Then a profile should be created with role='guest' And all the same post-creation steps should occur
- [ ] Given the user taps "Connexion avec Google" When Google authentication succeeds Then a profile should be created with role='guest' And all the same post-creation steps should occur
- [ ] Given the user has filled all fields But has not checked "J'accepte les conditions" When the user tries to tap "Creer mon compte invite" Then the button should be disabled And a message "Veuillez accepter les conditions" should appear
- [ ] Given "pierre@example.com" is already registered When the user tries to create account with that email Then an error "Cet email est deja utilise" should be displayed And a link "Se connecter" should be offered
- [ ] Given the user is on the guest signup page When the form is submitted with invalid email format Then an error "Email invalide" should be displayed

## Fichiers Concernes

### A Creer
- `lib/features/auth/presentation/pages/guest_signup_page.dart`
- `lib/features/auth/domain/usecases/create_guest_account.dart`
- `lib/features/auth/data/repositories/guest_auth_repository.dart`
- `lib/features/auth/presentation/widgets/guest_signup_form.dart`

### A Modifier
- `lib/core/navigation/app_router.dart` (route /guest-signup/:code)
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` (methode join_wedding_as_guest)

## Notes Techniques

### Backend RPC Function (migration Supabase)

```sql
-- Function: join_wedding_as_guest
-- Deja detaillee dans l'Epic, a deployer via migration Supabase
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

### Guest Signup Page Structure

```dart
// lib/features/auth/presentation/pages/guest_signup_page.dart
class GuestSignupPage extends StatefulWidget {
  final String inviteCode;
  final String? prefilledEmail;
  final String brideName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rejoindre le mariage')),
      body: Column(
        children: [
          // Welcome message
          Text(
            'Bienvenue au mariage de $brideName !',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          // Signup form
          GuestSignupForm(
            initialEmail: prefilledEmail,
            onSubmit: (firstName, email, password) async {
              // Create account + join wedding
            },
          ),

          // Divider
          const Divider(child: Text('OU')),

          // Social logins
          AppleSignInButton(onSuccess: _handleOAuthSuccess),
          GoogleSignInButton(onSuccess: _handleOAuthSuccess),

          // Terms checkbox
          TermsCheckbox(
            onChanged: (value) => setState(() => _acceptedTerms = value),
          ),
        ],
      ),
    );
  }
}
```

### UseCase Pattern

```dart
// lib/features/auth/domain/usecases/create_guest_account.dart
class CreateGuestAccount {
  final AuthRepository _authRepository;
  final GuestRepository _guestRepository;

  Future<Either<Failure, GuestAccountResult>> call(
    CreateGuestAccountParams params,
  ) async {
    // 1. Create Supabase auth account
    final authResult = await _authRepository.signUpWithEmail(
      email: params.email,
      password: params.password,
      metadata: {'first_name': params.firstName, 'role': 'guest'},
    );

    return authResult.fold(
      (failure) => Left(failure),
      (user) async {
        // 2. Join wedding
        final joinResult = await _guestRepository.joinWedding(
          userId: user.id,
          inviteCode: params.inviteCode,
        );
        return joinResult;
      },
    );
  }
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests unitaires (CreateGuestAccount usecase)
- [ ] Tests widget (GuestSignupPage, GuestSignupForm)
- [ ] Tests integration (flow complet creation compte)
- [ ] Migration Supabase deployee (join_wedding_as_guest)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] OAuth Apple et Google fonctionnels
- [ ] Validation email format et password strength

## Estimation

**Points** : 8
**Complexite** : Haute
**Risque** : Moyen (integration OAuth, migration backend)

## Dependances

- S02 (JoinWedding page - etape precedente)
- EPIC-06 complete (colonnes wedding_guests.user_id, status, joined_at)
- S10 (trigger chat room - pour que le chat existe)

## Stories Dependantes

- S05 (guest navigation - redirection apres creation)
- S11 (chat integration - guest ajoute au chat)
