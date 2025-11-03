# 🔍 VRAIE SOLUTION DEEPLINK RESET PASSWORD

## ❌ POURQUOI ÇA NE MARCHE PAS

### Problème identifié:
1. Supabase Flutter appelle `_handleInitialUri()` pendant `Supabase.initialize()`
2. Cela se passe **AVANT** que notre listener `onAuthStateChange` soit configuré
3. L'événement `AuthChangeEvent.passwordRecovery` est émis mais **personne ne l'écoute**
4. Supabase crée une session temporaire et l'app navigue vers la page par défaut
5. Quand notre listener est enfin configuré, c'est **TROP TARD**

### Preuve:
- Issue GitHub officielle: https://github.com/supabase/supabase-flutter/issues/937
- "it seems to be impossible to catch that event in the supabase.auth.onAuthStateChange listener"
- "For password recovery it to us seems impossible to direct the user to the \"reset your password\" screen when the app was fully closed."

## ✅ VRAIE SOLUTION

### Option 1: Désactiver le handling automatique de Supabase
```dart
// Dans supabase.dart
static Future initialize() => Supabase.initialize(
  url: _kSupabaseUrl,
  anonKey: _kSupabaseAnonKey,
  authOptions: FlutterAuthClientOptions(
    authFlowType: AuthFlowType.implicit,
    autoRefreshToken: true,
    // ✅ DÉSACTIVER le handling automatique
    detectSessionInUri: false,  // <-- CLEF
  ),
);
```

Puis gérer manuellement dans `main.dart` ou `startup_gate`:
```dart
// Récupérer le deeplink initial
final initialLink = await getInitialLink();

if (initialLink != null && initialLink.contains('type=recovery')) {
  // Extraire le token
  final uri = Uri.parse(initialLink);
  final accessToken = uri.fragment.split('&')
      .firstWhere((e) => e.startsWith('access_token='))
      .split('=')[1];
  
  // Vérifier le token avec Supabase
  await SupaFlow.client.auth.verifyOtp(
    type: OtpType.recovery,
    token: accessToken,
  );
  
  // Naviguer vers reset password
  context.goNamed(ResetPasswordNewPageWidget.routeName);
}
```

### Option 2: Utiliser un redirect URL vers une page web intermédiaire
Au lieu de `lynewed://`, utiliser une page web qui redirige vers l'app:
```dart
await authManager.resetPassword(
  email: email,
  context: context,
  redirectTo: 'https://lynewed.com/auth/reset-password',
);
```

La page web `https://lynewed.com/auth/reset-password`:
```html
<!DOCTYPE html>
<html>
<head>
  <script>
    // Extraire le token de l'URL
    const hash = window.location.hash;
    // Rediriger vers l'app avec le token
    window.location.href = `lynewed://reset-password${hash}`;
  </script>
</head>
<body>Redirecting...</body>
</html>
```

### Option 3: Vérifier la session au démarrage (PLUS SIMPLE)
Dans `startup_gate_widget.dart`:
```dart
SchedulerBinding.instance.addPostFrameCallback((_) async {
  // Vérifier si on a une session Supabase active
  final session = SupaFlow.client.auth.currentSession;
  
  if (session != null) {
    // Vérifier si c'est une session de recovery
    // Une session de recovery a un user mais pas de refresh token complet
    final user = SupaFlow.client.auth.currentUser;
    
    if (user != null && user.recoverySentAt != null) {
      // C'est une session de recovery !
      print('🔑 Session de recovery détectée');
      context.goNamedAuth(ResetPasswordNewPageWidget.routeName, context.mounted);
      return;
    }
  }
  
  // Sinon, flux normal...
});
```

## 🎯 RECOMMANDATION

**Option 1** est la plus robuste mais nécessite de gérer manuellement le deeplink.
**Option 3** est la plus simple et devrait fonctionner si Supabase expose `recoverySentAt`.

## 📝 PROCHAINES ÉTAPES

1. Vérifier si `user.recoverySentAt` existe dans Supabase Flutter
2. Si oui, implémenter Option 3
3. Sinon, implémenter Option 1 avec `detectSessionInUri: false`
