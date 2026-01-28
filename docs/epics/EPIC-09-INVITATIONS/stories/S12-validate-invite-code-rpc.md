# Story S12: Creer RPC validate_invite_code

## Description
En tant que systeme, je veux pouvoir valider un code d'invitation et retourner les informations du mariage, afin de permettre aux guests de verifier leur code avant de creer un compte.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a valid invite code "ABCD1234" When the validate_invite_code RPC is called Then it should return success=true And return the wedding_id And return the bride_name And return any pre-existing guest info (email if in wedding_guests)
- [ ] Given an invalid invite code "INVALID1" When the validate_invite_code RPC is called Then it should return success=false And return error='invalid_code'
- [ ] Given an expired invite code (invite_code_expires_at < NOW) When the validate_invite_code RPC is called Then it should return success=false And return error='expired_code'
- [ ] Given a valid code When the same user calls the RPC 6 times in 15 minutes Then the 6th call should return error='rate_limited' And return retry_after timestamp
- [ ] Given a valid code And the caller's email exists in wedding_guests When the validate_invite_code RPC is called Then the response should include guest_email pre-filled

## Fichiers Concernes

### A Creer
- Migration Supabase: `20260128_create_validate_invite_code_rpc.sql`
- `lib/features/auth/data/datasources/invite_code_datasource.dart`

### A Modifier
- `lib/features/auth/data/repositories/invite_code_repository.dart` (appeler le RPC)

## Notes Techniques

### Migration RPC Function

```sql
-- Migration: 20260128_create_validate_invite_code_rpc
-- Description: RPC function to validate wedding invite codes

-- =============================================================================
-- 1. RATE LIMITING TABLE (pour tracking des tentatives)
-- =============================================================================
CREATE TABLE IF NOT EXISTS invite_code_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_identifier TEXT NOT NULL, -- IP or user_id
  attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for cleanup and lookup
CREATE INDEX IF NOT EXISTS idx_invite_code_attempts_lookup
ON invite_code_attempts (user_identifier, attempted_at);

-- Auto-cleanup old attempts (older than 1 hour)
CREATE OR REPLACE FUNCTION cleanup_old_invite_attempts()
RETURNS void AS $$
BEGIN
  DELETE FROM invite_code_attempts
  WHERE attempted_at < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 2. VALIDATE INVITE CODE RPC FUNCTION
-- =============================================================================
CREATE OR REPLACE FUNCTION validate_invite_code(
  p_invite_code VARCHAR(8),
  p_user_identifier TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_wedding RECORD;
  v_bride_name TEXT;
  v_guest_email TEXT;
  v_attempt_count INT;
  v_user_id TEXT;
BEGIN
  -- Use auth.uid() if available, otherwise use provided identifier
  v_user_id := COALESCE(auth.uid()::TEXT, p_user_identifier, 'anonymous');

  -- ==========================================================================
  -- RATE LIMITING CHECK
  -- ==========================================================================
  -- Cleanup old attempts first
  PERFORM cleanup_old_invite_attempts();

  -- Count attempts in last 15 minutes
  SELECT COUNT(*) INTO v_attempt_count
  FROM invite_code_attempts
  WHERE user_identifier = v_user_id
  AND attempted_at > NOW() - INTERVAL '15 minutes';

  -- If rate limited (5 attempts max)
  IF v_attempt_count >= 5 THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'rate_limited',
      'retry_after', EXTRACT(EPOCH FROM (
        (SELECT MIN(attempted_at) FROM invite_code_attempts
         WHERE user_identifier = v_user_id
         AND attempted_at > NOW() - INTERVAL '15 minutes')
        + INTERVAL '15 minutes'
      ))::INT
    );
  END IF;

  -- Record this attempt
  INSERT INTO invite_code_attempts (user_identifier, attempted_at)
  VALUES (v_user_id, NOW());

  -- ==========================================================================
  -- CODE VALIDATION
  -- ==========================================================================
  -- Find wedding by invite code
  SELECT w.*, p.first_name as bride_first_name
  INTO v_wedding
  FROM weddings w
  JOIN profiles p ON p.id = w.bride_profile_id
  WHERE w.invite_code = UPPER(p_invite_code);

  -- Code not found
  IF v_wedding IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'invalid_code'
    );
  END IF;

  -- Code expired
  IF v_wedding.invite_code_expires_at IS NOT NULL
     AND v_wedding.invite_code_expires_at < NOW() THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', 'expired_code'
    );
  END IF;

  -- ==========================================================================
  -- GET ADDITIONAL INFO
  -- ==========================================================================
  v_bride_name := v_wedding.bride_first_name;

  -- Check if user's email exists in wedding_guests
  IF auth.uid() IS NOT NULL THEN
    SELECT wg.email INTO v_guest_email
    FROM wedding_guests wg
    WHERE wg.wedding_id = v_wedding.id
    AND wg.email = (SELECT email FROM auth.users WHERE id = auth.uid());
  END IF;

  -- ==========================================================================
  -- SUCCESS RESPONSE
  -- ==========================================================================
  RETURN jsonb_build_object(
    'success', true,
    'wedding_id', v_wedding.id,
    'bride_name', v_bride_name,
    'guest_email', v_guest_email
  );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to authenticated and anon users
GRANT EXECUTE ON FUNCTION validate_invite_code TO authenticated;
GRANT EXECUTE ON FUNCTION validate_invite_code TO anon;

COMMENT ON FUNCTION validate_invite_code IS
  'Validates a wedding invite code and returns wedding info. Rate limited to 5 attempts per 15 minutes.';
```

### Flutter Datasource

```dart
// lib/features/auth/data/datasources/invite_code_datasource.dart
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InviteCodeDatasource {
  final SupabaseClient _supabase;

  InviteCodeDatasource(this._supabase);

  /// Validates an invite code and returns wedding information
  Future<Either<InviteCodeError, InviteCodeValidation>> validateCode(
    String code,
  ) async {
    try {
      final response = await _supabase.rpc(
        'validate_invite_code',
        params: {'p_invite_code': code.toUpperCase()},
      );

      if (response == null) {
        return Left(InviteCodeError.unknown);
      }

      final data = response as Map<String, dynamic>;

      if (data['success'] == true) {
        return Right(InviteCodeValidation(
          weddingId: data['wedding_id'] as String,
          brideName: data['bride_name'] as String,
          guestEmail: data['guest_email'] as String?,
        ));
      }

      // Handle errors
      final error = data['error'] as String?;
      switch (error) {
        case 'invalid_code':
          return Left(InviteCodeError.invalidCode);
        case 'expired_code':
          return Left(InviteCodeError.expiredCode);
        case 'rate_limited':
          final retryAfter = data['retry_after'] as int?;
          return Left(InviteCodeError.rateLimited(
            retryAfter: retryAfter != null
                ? DateTime.fromMillisecondsSinceEpoch(retryAfter * 1000)
                : null,
          ));
        default:
          return Left(InviteCodeError.unknown);
      }
    } catch (e) {
      return Left(InviteCodeError.networkError);
    }
  }
}

// Models
class InviteCodeValidation {
  final String weddingId;
  final String brideName;
  final String? guestEmail;

  InviteCodeValidation({
    required this.weddingId,
    required this.brideName,
    this.guestEmail,
  });
}

sealed class InviteCodeError {
  String get message;

  static const invalidCode = InvalidCodeError();
  static const expiredCode = ExpiredCodeError();
  static const unknown = UnknownError();
  static const networkError = NetworkError();
  static RateLimitedError rateLimited({DateTime? retryAfter}) =>
      RateLimitedError(retryAfter: retryAfter);
}

class InvalidCodeError implements InviteCodeError {
  const InvalidCodeError();
  @override
  String get message => 'Code invalide ou inexistant';
}

class ExpiredCodeError implements InviteCodeError {
  const ExpiredCodeError();
  @override
  String get message => 'Ce code d\'invitation a expire';
}

class RateLimitedError implements InviteCodeError {
  final DateTime? retryAfter;
  const RateLimitedError({this.retryAfter});
  @override
  String get message => 'Trop de tentatives. Reessayez dans quelques minutes.';
}

class UnknownError implements InviteCodeError {
  const UnknownError();
  @override
  String get message => 'Une erreur est survenue';
}

class NetworkError implements InviteCodeError {
  const NetworkError();
  @override
  String get message => 'Erreur de connexion';
}
```

### Integration dans S02 (JoinWeddingPage)

```dart
// Dans join_wedding_page.dart - utilisation du datasource
Future<void> _validateCode() async {
  if (_code.length != 8) return;

  setState(() => _isValidating = true);

  final result = await ref.read(inviteCodeDatasourceProvider).validateCode(_code);

  setState(() => _isValidating = false);

  result.fold(
    (error) {
      setState(() => _errorMessage = error.message);

      // Handle rate limiting UI
      if (error is RateLimitedError && error.retryAfter != null) {
        _startCountdown(error.retryAfter!);
      }
    },
    (validation) {
      // Navigate to guest signup with wedding info
      context.push(
        '/guest-signup',
        extra: GuestSignupParams(
          inviteCode: _code,
          weddingId: validation.weddingId,
          brideName: validation.brideName,
          prefilledEmail: validation.guestEmail,
        ),
      );
    },
  );
}
```

## Definition of Done

- [ ] Criteres valides
- [ ] Migration RPC deployee sur Supabase
- [ ] Tests manuels (code valide, invalide, expire, rate limit)
- [ ] Tests unitaires (InviteCodeDatasource)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Rate limiting fonctionne (5 attempts / 15 min)
- [ ] Erreurs bien mappees cote Flutter

## Estimation

**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances

- EPIC-06 complete (colonnes invite_code, invite_code_expires_at)

## Stories Dependantes

- S02 (join wedding page - appelle ce RPC)
- S04 (guest account creation - utilise le wedding_id retourne)

## Notes Securite

### Rate Limiting

- 5 tentatives maximum par utilisateur par tranche de 15 minutes
- Tracking par auth.uid() si connecte, sinon par identifiant fourni
- Les tentatives sont auto-nettoyees apres 1 heure

### Permissions

- Fonction SECURITY DEFINER pour acceder aux tables internes
- Accessible aux utilisateurs anonymes (pour validation avant signup)
- Ne retourne que les informations necessaires (pas de donnees sensibles)

### Validation

- Code toujours converti en majuscules
- Verification expiration stricte
- Pas de leaking d'information (meme message pour code invalide vs inexistant)
