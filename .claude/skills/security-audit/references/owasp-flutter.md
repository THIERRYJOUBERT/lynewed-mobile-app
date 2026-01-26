# OWASP Top 10 + Flutter/Dart Patterns

> Reference pour l'audit de securite.

---

## OWASP Top 10 (2021)

### A01: Broken Access Control

**Patterns a chercher:**
```dart
// Mauvais: Pas de verification de permissions
if (user.isLoggedIn) { /* access granted */ }

// Bon: Verification de role
if (user.hasRole('admin')) { /* access granted */ }
```

**Flutter specifique:**
- Missing route guards
- Client-side only auth checks
- Insecure deep links

**Grep patterns:**
```
isLoggedIn && !hasRole
Navigator.push.*without.*auth
deepLink.*without.*validation
```

---

### A02: Cryptographic Failures

**Patterns a chercher:**
```dart
// Mauvais: Stockage en clair
SharedPreferences.setString('token', jwt);

// Bon: Secure storage
FlutterSecureStorage().write(key: 'token', value: jwt);
```

**Flutter specifique:**
- SharedPreferences for sensitive data
- Hardcoded encryption keys
- HTTP instead of HTTPS

**Grep patterns:**
```
SharedPreferences.*password
SharedPreferences.*token
SharedPreferences.*secret
http://.*api
```

---

### A03: Injection

**Patterns a chercher:**
```dart
// Mauvais: SQL injection
query = "SELECT * FROM users WHERE id = $userId";

// Bon: Parameterized
query = "SELECT * FROM users WHERE id = ?";
```

**Supabase specifique:**
```dart
// Mauvais: RPC sans validation
await supabase.rpc('get_user', params: {'id': userInput});

// Verifier: RLS policies actives
```

**Grep patterns:**
```
\$.*FROM.*WHERE
string interpolation.*sql
rpc\(.*userInput
```

---

### A04: Insecure Design

**Patterns a chercher:**
- Business logic flaws
- Missing rate limiting
- Inadequate input validation

**Flutter specifique:**
- Trust client-side validation only
- No server-side verification
- Sensitive operations without confirmation

---

### A05: Security Misconfiguration

**Patterns a chercher:**
```yaml
# Mauvais: Debug en prod
flutter:
  build:
    release:
      debuggable: true

# Mauvais: Verbose errors
onError: (error) => print(error.stackTrace)
```

**Grep patterns:**
```
debuggable.*true
kDebugMode.*true.*production
print\(.*error
print\(.*exception
```

---

### A06: Vulnerable and Outdated Components

**Verifications:**
```bash
# Flutter/Dart
flutter pub outdated
flutter pub audit  # si disponible

# Check pubspec.yaml pour versions fixes
dependencies:
  http: ^0.13.0  # OK - permet updates
  crypto: 3.0.0   # Risque - version fixe
```

**CVE databases:**
- https://nvd.nist.gov/
- https://pub.dev/packages/ (security advisories)

---

### A07: Identification and Authentication Failures

**Patterns a chercher:**
```dart
// Mauvais: Weak password policy
if (password.length >= 4) { /* OK */ }

// Mauvais: No session timeout
// (pas de gestion de session)

// Mauvais: Credentials in logs
print('Login attempt: $username / $password');
```

**Supabase specifique:**
```dart
// Verifier: Auth policies
// Verifier: Row Level Security
// Verifier: JWT expiration
```

---

### A08: Software and Data Integrity Failures

**Patterns a chercher:**
- Unsigned code/updates
- Unverified dependencies
- Missing integrity checks

**Flutter specifique:**
```dart
// Verifier: Code signing
// Verifier: App integrity (SafetyNet, DeviceCheck)
// Verifier: Certificate pinning
```

---

### A09: Security Logging and Monitoring Failures

**Patterns a chercher:**
```dart
// Mauvais: Pas de logging securite
try {
  await login(credentials);
} catch (e) {
  // Silently fail
}

// Bon: Security logging
try {
  await login(credentials);
} catch (e) {
  securityLogger.warning('Failed login attempt', {
    'ip': request.ip,
    'timestamp': DateTime.now(),
    // PAS le password!
  });
}
```

---

### A10: Server-Side Request Forgery (SSRF)

**Patterns a chercher:**
```dart
// Mauvais: URL from user input
final response = await http.get(Uri.parse(userProvidedUrl));

// Bon: Whitelist validation
if (allowedHosts.contains(Uri.parse(url).host)) {
  final response = await http.get(Uri.parse(url));
}
```

---

## Flutter/Dart Specifique

### Secure Storage

```dart
// Utiliser flutter_secure_storage
final storage = FlutterSecureStorage();
await storage.write(key: 'token', value: jwt);

// PAS SharedPreferences pour secrets
```

### Network Security

```dart
// Certificate pinning
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) {
    return pinnedCerts.contains(cert.sha256);
  };
```

### Platform Channels

```dart
// Valider les donnees des channels natifs
// Ne pas faire confiance aux inputs
```

### WebView Security

```dart
// Desactiver JavaScript si pas necessaire
WebView(
  javascriptMode: JavascriptMode.disabled,
)

// Whitelist des URLs
```

---

## Severity Guide

| Finding | Typical Severity |
|---------|------------------|
| Hardcoded secrets | CRITICAL |
| SQL injection | CRITICAL |
| Missing auth | CRITICAL |
| Weak crypto | HIGH |
| Missing HTTPS | HIGH |
| Debug in prod | HIGH |
| Outdated deps with CVE | HIGH |
| Missing input validation | MEDIUM |
| Verbose error messages | MEDIUM |
| Missing rate limiting | MEDIUM |
| No security logging | LOW |
| Minor config issues | LOW |
