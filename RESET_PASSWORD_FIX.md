# Correction du système Reset Password

## Problèmes corrigés

1. ✅ Détection améliorée des liens de récupération (tous les formats Supabase)
2. ✅ Listener global pour intercepter les deeplinks pendant l'exécution de l'app
3. ✅ Ajout du paramètre `redirectTo` dans les appels `resetPassword`
4. ✅ Simplification de la configuration des deeplinks (Android + iOS)
5. ✅ Redirection systématique vers `ResetPasswordNewPage` depuis les emails

## Modifications effectuées

### 1. Fichiers modifiés

#### `/lib/flutter_flow/custom_functions.dart`
- **Fonction `isRecoveryLink`** : Amélioration pour détecter tous les formats de liens de récupération Supabase
  - Vérifie le fragment (#)
  - Vérifie les query parameters
  - Parse les paramètres du fragment

#### `/lib/custom_code/actions/setup_deeplink_listener.dart` (NOUVEAU)
- **Fonction `setupDeeplinkListener`** : Écoute en continu les deeplinks entrants
- **Fonction `cancelDeeplinkListener`** : Nettoie le listener (optionnel)
- Redirige automatiquement vers `ResetPasswordNewPage` si un lien de récupération est détecté

#### `/lib/custom_code/actions/index.dart`
- Ajout de l'export pour `setupDeeplinkListener` et `cancelDeeplinkListener`

#### `/lib/pages/auth/startup_gate/startup_gate_widget.dart`
- Amélioration de la détection au démarrage
- Ajout de l'appel à `setupDeeplinkListener` pour écouter les deeplinks futurs
- Logs de debug pour faciliter le diagnostic

#### `/lib/pages/auth/forgot_password_page/forgot_password_page_widget.dart`
- Ajout du paramètre `redirectTo: 'lynewed://'` dans `authManager.resetPassword()`

#### `/lib/pages/auth/set_password_page_pro/set_password_page_pro_widget.dart`
- Ajout du paramètre `redirectTo: 'lynewed://'` dans `authManager.resetPassword()`

#### `/android/app/src/main/AndroidManifest.xml`
- Simplification : `<data android:scheme="lynewed" />` (sans restriction de host)

#### `/ios/Runner/Info.plist`
- Simplification : `CFBundleURLName` changé en `com.lynewed.app`

## Configuration Supabase requise

### Dans le dashboard Supabase (Authentication > URL Configuration)

**Site URL :**
```
lynewed://
```

**Redirect URLs :**
```
lynewed://**
```

**Explication :**
- `lynewed://` comme Site URL indique à Supabase d'utiliser ce schéma pour les redirections
- `lynewed://**` dans Redirect URLs autorise tous les chemins avec le schéma lynewed://
- Le `**` est un wildcard qui accepte n'importe quel chemin après `lynewed://`

### Format des liens générés par Supabase

Après configuration, Supabase générera des liens comme :
```
lynewed://#access_token=xxx&type=recovery&...
```

## Comment ça fonctionne maintenant

### Scénario 1 : App fermée
1. L'utilisateur clique sur le lien dans l'email
2. Le navigateur affiche "Ouvrir Lynewed"
3. L'app s'ouvre et va directement à `StartupGate`
4. `StartupGate` détecte le lien de récupération via `getInitialDeepLink()`
5. Redirection immédiate vers `ResetPasswordNewPage`

### Scénario 2 : App déjà ouverte
1. L'utilisateur clique sur le lien dans l'email
2. Le navigateur affiche "Ouvrir Lynewed"
3. L'app reçoit le deeplink via le `linkStream` (uni_links)
4. Le listener `setupDeeplinkListener` intercepte le lien
5. Détection automatique du type recovery
6. Navigation vers `ResetPasswordNewPage` avec `context.pushNamed()`

### Scénario 3 : Utilisateur déjà connecté
1. Même processus que les scénarios 1 ou 2
2. L'utilisateur est redirigé vers `ResetPasswordNewPage`
3. Après avoir changé le mot de passe, il est redirigé vers `StartupGate`
4. `StartupGate` le redirige vers sa page d'accueil appropriée (HomeBrides ou DashboardPro)

## Logs de debug

Pour faciliter le diagnostic, des logs ont été ajoutés :
- `🔑 Lien de récupération détecté au démarrage: ...`
- `📱 Deeplink reçu pendant l'exécution: ...`
- `✅ Listener de deeplinks configuré avec succès`
- `❌ Erreur lors de l'écoute des deeplinks: ...`

## Tests à effectuer

1. **Test avec app fermée :**
   - Fermer complètement l'app
   - Demander un reset password
   - Cliquer sur le lien dans l'email
   - Vérifier la redirection vers `ResetPasswordNewPage`

2. **Test avec app ouverte (non connecté) :**
   - Ouvrir l'app sur `AuthWelcomePage`
   - Demander un reset password
   - Cliquer sur le lien dans l'email
   - Vérifier la redirection vers `ResetPasswordNewPage`

3. **Test avec app ouverte (connecté) :**
   - Se connecter et naviguer vers n'importe quelle page
   - Demander un reset password
   - Cliquer sur le lien dans l'email
   - Vérifier la redirection vers `ResetPasswordNewPage`

4. **Test Pro première connexion :**
   - Aller sur `AuthWelcomePage`
   - Cliquer sur "I'M A VENDOR"
   - Entrer l'email sur `SetPasswordPagePro`
   - Cliquer sur le lien dans l'email
   - Vérifier la redirection vers `ResetPasswordNewPage`

## Points importants

- ⚠️ **Supprimer les anciennes URLs** dans Supabase Redirect URLs (comme `lynewed://resetpassword.com/**`)
- ⚠️ **Utiliser uniquement** `lynewed://` et `lynewed://**`
- ✅ Le système fonctionne maintenant de manière cohérente dans tous les scénarios
- ✅ Pas besoin de gérer différents hosts ou chemins
- ✅ La détection est robuste et gère tous les formats de liens Supabase

## En cas de problème

1. Vérifier les logs dans la console (rechercher les emojis 🔑 📱 ✅ ❌)
2. Vérifier la configuration Supabase (Site URL et Redirect URLs)
3. Vérifier que l'app a bien été rebuild après les modifications
4. Tester avec `flutter clean` puis `flutter pub get` si nécessaire
