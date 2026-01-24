# Story S-03: Audit Flux d'Authentification

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-03 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P1 - HAUTE |
| **Estimation** | 4h |
| **Statut** | NOT_STARTED |

---

## Description

En tant que **security engineer**, je veux auditer tous les flux d'authentification afin de **garantir qu'aucune faille ne permet un acces non autorise**.

---

## Contexte

L'application utilise Supabase Auth avec plusieurs methodes:
- Email/Password (signup/signin)
- Sign in with Apple
- Password reset flow
- JWT token management

### Fichiers Auth Identifies

| Fichier | Role |
|---------|------|
| `lib/auth/supabase_auth/auth_util.dart` | Utilities auth (currentUser, JWT) |
| `lib/auth/supabase_auth/email_auth.dart` | Email auth functions |
| `lib/auth/supabase_auth/supabase_user_provider.dart` | User state provider |
| `lib/auth/supabase_auth/supabase_auth_manager.dart` | Auth manager |
| `lib/auth/auth_manager.dart` | Base auth manager |
| `lib/auth/base_auth_user_provider.dart` | Base user provider |

### Pages Auth

| Page | Flow |
|------|------|
| `auth_welcome_page` | Landing page auth |
| `sign_in_email_page` | Bride sign in |
| `sign_in_email_page_pro` | Pro sign in |
| `sign_up_email_page` | Registration |
| `forgot_password_page` | Password reset request |
| `reset_password_new_page` | Password reset action |
| `set_password_page_pro` | Pro password setup |
| `startup_gate` | Auth routing gate |

---

## Criteres d'Acceptance

- [ ] Audit complet de tous les flows auth
- [ ] Verification stockage securise du JWT
- [ ] Verification expiration/refresh tokens
- [ ] Verification protection contre brute force
- [ ] Verification password reset securise
- [ ] Tests de regression auth passent
- [ ] Rapport d'audit documente

---

## Checklist Securite

### JWT Management
- [ ] JWT stocke dans flutter_secure_storage (pas SharedPreferences)
- [ ] JWT non logue en clair (debugPrint, etc.)
- [ ] Refresh token implemente correctement
- [ ] Token expiration geree cote client
- [ ] Logout invalide le token

### Password Security
- [ ] Password hashage cote Supabase (bcrypt)
- [ ] Password complexity enforced (min length, etc.)
- [ ] Password reset token expire
- [ ] Password reset one-time use
- [ ] Pas de password en clair dans les logs

### Session Management
- [ ] Session invalidee apres password change
- [ ] Concurrent sessions gerees
- [ ] Session timeout implemente
- [ ] Logout sur tous les devices possible

### Attack Vectors
- [ ] Protection brute force (rate limiting Supabase)
- [ ] Email enumeration prevention
- [ ] CSRF protection sur auth endpoints
- [ ] Secure deeplinks pour password reset

---

## Implementation

### Audit auth_util.dart

```dart
// VERIFIER: Le JWT n'est pas expose
String get currentJwtToken => _currentJwtToken ?? '';

// RISQUE: _currentJwtToken accessible globalement
String? _currentJwtToken;
final jwtTokenStream = SupaFlow.client.auth.onAuthStateChange
    .map(
      (authState) => _currentJwtToken = authState.session?.accessToken,
    )
    .asBroadcastStream();
```

**Questions a verifier:**
1. Est-ce que `_currentJwtToken` est logue quelque part?
2. Est-ce que le JWT est passe dans des URLs?
3. Comment est geree l'expiration?

### Audit supabase_auth_manager.dart

Verifier:
- Gestion des erreurs auth
- Logout proper (clear all state)
- Sign in with Apple implementation

### Audit Password Reset Flow

1. `forgot_password_page` -> Envoie email reset
2. User clique lien -> Ouvre app via deeplink
3. `reset_password_new_page` -> Permet nouveau password

**Verifier:**
- Token dans deeplink est unique et expire
- Nouveau password valide
- Session precedentes invalidees

---

## Tests de Securite

### Test 1: Session Hijacking
```dart
// Simuler vol de JWT
// Verifier qu'apres logout le JWT est invalide
```

### Test 2: Brute Force
```dart
// Verifier rate limiting sur sign in
// 5 tentatives -> lockout temporaire
```

### Test 3: Email Enumeration
```dart
// forgot_password avec email inexistant
// Ne doit pas reveler si email existe
```

### Test 4: Password Reset Token Reuse
```dart
// Utiliser meme token reset 2 fois
// 2eme doit echouer
```

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| JWT leak dans logs | CRITIQUE | Audit tous les debugPrint |
| Session fixation | HAUTE | Regenerer session apres login |
| Brute force | HAUTE | Rate limiting Supabase |
| Password reset replay | HAUTE | Tokens one-time use |

---

## Definition of Done

- [ ] Tous les flows auth audites
- [ ] JWT stocke securement
- [ ] Password reset securise
- [ ] Aucune fuite de credentials dans logs
- [ ] Tests de regression passent
- [ ] Rapport d'audit documente
- [ ] PR reviewee et mergee
