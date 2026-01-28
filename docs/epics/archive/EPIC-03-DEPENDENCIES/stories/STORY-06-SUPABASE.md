# Story STORY-06: Mise a Jour de l'Ecosysteme Supabase

## Description

Mettre a jour l'ensemble de l'ecosysteme Supabase de maniere coordonnee. Ces packages sont interdependants et doivent etre mis a jour ensemble.

| Package | Actuel | Cible | Changelog |
|---------|--------|-------|-----------|
| supabase_flutter | 2.9.0 | 2.12.0 | [pub.dev](https://pub.dev/packages/supabase_flutter/changelog) |
| supabase | 2.7.0 | 2.10.2 | [pub.dev](https://pub.dev/packages/supabase/changelog) |
| gotrue | 2.12.0 | 2.18.0 | [pub.dev](https://pub.dev/packages/gotrue/changelog) |
| postgrest | 2.4.2 | 2.6.0 | [pub.dev](https://pub.dev/packages/postgrest/changelog) |
| realtime_client | 2.5.0 | 2.7.0 | [pub.dev](https://pub.dev/packages/realtime_client/changelog) |
| storage_client | 2.4.0 | 2.4.1 | [pub.dev](https://pub.dev/packages/storage_client/changelog) |
| functions_client | 2.4.2 | 2.5.0 | [pub.dev](https://pub.dev/packages/functions_client/changelog) |

## Criteres d'Acceptance

- [ ] Tous les packages Supabase mis a jour
- [ ] `flutter pub get` reussit sans erreur
- [ ] `flutter analyze --fatal-infos` passe sans warnings
- [ ] App compile sur iOS (`flutter build ios --no-codesign`)
- [ ] App compile sur Android (`flutter build apk --debug`)
- [ ] **Auth**: Login/Logout fonctionne (email, Apple Sign-In)
- [ ] **Auth**: Session persiste apres redemarrage
- [ ] **Auth**: Refresh token fonctionne
- [ ] **Database**: Queries Postgrest fonctionnent
- [ ] **Database**: Inserts/Updates fonctionnent
- [ ] **Realtime**: Subscriptions fonctionnent
- [ ] **Storage**: Upload/Download fichiers fonctionne
- [ ] **Functions**: Edge functions appellables

## Breaking Changes Potentiels

### gotrue 2.18.0 (ATTENTION)
- **MFA/TOTP changes**: Verifier si MFA est utilise
- **Session handling**: Changements possibles dans la gestion des sessions
- **Token refresh**: Nouvelle logique de refresh possible

### postgrest 2.6.0
- **Query builder changes**: Verifier les queries complexes
- **Error handling**: Potentiels changements dans les erreurs retournees

### realtime_client 2.7.0
- **Subscription API**: Verifier les subscriptions existantes
- **Reconnection logic**: Ameliorations de reconnexion

### supabase_flutter 2.12.0
- **Initialization**: Verifier `Supabase.initialize()`
- **Auth state changes**: Verifier les listeners

## Tests Manuels Requis

### 1. Tests d'Authentification

```
a) Login Email/Password
   - Deconnecter
   - Se connecter avec email/password
   - Verifier acces aux donnees

b) Login Apple Sign-In
   - Deconnecter
   - Se connecter via Apple
   - Verifier acces aux donnees

c) Session Persistence
   - Se connecter
   - Fermer completement l'app
   - Rouvrir
   - Verifier que l'utilisateur est toujours connecte

d) Token Refresh
   - Rester connecte > 1h
   - Verifier que la session reste active

e) Logout
   - Se deconnecter
   - Verifier que les donnees ne sont plus accessibles
```

### 2. Tests Database (Postgrest)

```
a) Read operations
   - Lister des donnees
   - Filtrer des donnees
   - Trier des donnees

b) Write operations
   - Creer un enregistrement
   - Modifier un enregistrement
   - Supprimer un enregistrement

c) Relations
   - Verifier les joins/relations
```

### 3. Tests Realtime

```
a) Subscriptions
   - S'abonner a une table
   - Modifier des donnees depuis un autre device
   - Verifier que les updates arrivent en temps reel
```

### 4. Tests Storage

```
a) Upload
   - Uploader une image
   - Verifier qu'elle est accessible

b) Download
   - Telecharger une image existante
   - Verifier l'affichage
```

### 5. Tests Edge Functions (si utilise)

```
a) Appeler une edge function
   - Verifier la reponse
```

## Rollback

```bash
# Dans pubspec.yaml, revenir a:
supabase: 2.7.0
supabase_flutter: 2.9.0
gotrue: 2.12.0
postgrest: 2.4.2
realtime_client: 2.5.0
storage_client: 2.4.0
functions_client: 2.4.2

# Puis:
flutter pub get
```

## Estimation

- **Effort**: M (4-6h) - Tests exhaustifs requis
- **Risque**: Moyen-Haut (auth et data critiques)

## Notes

### Dependances Transitives

Ces packages ont des dependances communes:
- `http`: Actuellement en dependency_override (1.4.0)
- `rxdart`: Actuellement en dependency_override (0.27.7)

Apres cette mise a jour, verifier si les overrides sont toujours necessaires.

### Migration Potentielle

Si gotrue 2.18.0 change l'API d'authentification:

```dart
// Ancien code possible
final user = supabase.auth.currentUser;

// Nouveau code possible (verifier changelog)
final session = supabase.auth.currentSession;
final user = session?.user;
```

### Ordre de Mise a Jour Recommande

1. Mettre a jour tous les packages d'un coup (interdependants)
2. `flutter pub get`
3. Corriger les erreurs de compilation si necessaire
4. `flutter analyze`
5. Tests

### Points d'Attention

- **Apple Sign-In**: Verifier que la configuration reste compatible
- **Deep Links**: Verifier que les magic links fonctionnent
- **Error Handling**: Les codes d'erreur peuvent avoir change
