# 🔒 Recommandations de Sécurité - Lynewed Alpha

**Date:** 7 novembre 2025  
**Status:** Corrections appliquées + Recommandations additionnelles

---

## ✅ Corrections Appliquées

### 1. Migration des Secrets vers .env ✅
**Problème résolu:** Clés API hardcodées dans le code source  
**Fichiers modifiés:**
- `lib/backend/supabase/supabase.dart`
- `lib/firebase_options.dart`
- `.env.example`

**Impact:** Les secrets ne sont plus extractibles depuis les binaires APK/IPA.

### 2. Cleanup Agora Engine Manager ✅
**Problème résolu:** Memory leaks potentiels  
**Fichiers modifiés:**
- `lib/services/agora_engine_manager.dart`
- `lib/main.dart`

**Impact:** Ressources Agora correctement libérées au shutdown de l'app.

### 3. Error Boundaries & Validation ✅
**Ajouts:**
- `lib/utils/error_handler.dart` (nouveau fichier utilitaire)
- Validation des variables d'environnement dans `supabase.dart`
- Warnings pour clés API manquantes dans `app_constants.dart`

**Impact:** Erreurs détectées au démarrage au lieu de crashs silencieux.

---

## 🔐 Recommandations Additionnelles (À Implémenter)

### 1. Restreindre Google Places API Key ⚠️ PRIORITÉ HAUTE

**Action requise:**
1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionner le projet `lynewed-app`
3. APIs & Services → Credentials
4. Éditer la clé API `GOOGLE_PLACES_API_KEY`
5. Ajouter les restrictions:
   - **iOS:** Restriction par bundle ID `com.lynewed.app`
   - **Android:** Restriction par package name `com.lynewed.app`
   - **APIs autorisées:** Places API, Maps SDK for iOS, Maps SDK for Android, Geocoding API

**Risque si non fait:** Abus de quota, coûts imprévus si la clé fuite.

### 2. Configurer Firebase App Check 🔥

**Action requise:**
```bash
# Activer App Check dans Firebase Console
# iOS: Utiliser DeviceCheck
# Android: Utiliser Play Integrity API
```

**Bénéfice:** Protection contre les requêtes non autorisées vers FCM.

### 3. Implémenter Rate Limiting sur Edge Functions

**Fonctions concernées:**
- `agora_token_issue` (risque d'abus)
- `notifications_outbox_drain`

**Solution:** Utiliser Supabase Rate Limiting ou Upstash Redis.

### 4. Activer Crash Reporting

**Action requise:**
Décommenter dans `lib/utils/error_handler.dart`:
```dart
// TODO: Send to crash reporting service
FirebaseCrashlytics.instance.recordError(error, stackTrace);
```

**Dépendance à ajouter:**
```yaml
firebase_crashlytics: ^3.4.0
```

### 5. Sécuriser les Edge Functions CRM

**Fonctions concernées:**
- `sync-professional-profile`
- `upload-professional-images`
- `sync-wedding-article`

**Solution recommandée:**
- Ajouter un secret partagé (API key) dans les headers
- Valider l'origine des requêtes (IP whitelist)
- Implémenter un système de webhooks signés

**Exemple d'implémentation:**
```typescript
// Dans chaque Edge Function
const API_SECRET = Deno.env.get('CRM_API_SECRET');
const authHeader = req.headers.get('X-API-Key');

if (authHeader !== API_SECRET) {
  return new Response(
    JSON.stringify({ error: 'Unauthorized' }),
    { status: 401 }
  );
}
```

### 6. Activer HTTPS Pinning (Certificate Pinning)

**Pour:** Supabase API, Agora API  
**Package:** `flutter_ssl_pinning` ou `dio` avec pinning

**Bénéfice:** Protection contre les attaques Man-in-the-Middle.

### 7. Obfuscation du Code Flutter

**Action requise:**
```bash
# Build avec obfuscation
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
flutter build ios --obfuscate --split-debug-info=build/ios/outputs/symbols
```

**Bénéfice:** Rend le reverse engineering plus difficile.

### 8. Configurer ProGuard/R8 (Android)

**Fichier:** `android/app/proguard-rules.pro`

**Règles recommandées:**
```proguard
-keep class io.flutter.** { *; }
-keep class com.agora.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.agora.**
```

### 9. Implémenter Biometric Authentication

**Pour:** Actions sensibles (suppression compte, paiements)  
**Package:** `local_auth: ^2.1.0`

### 10. Audit des Permissions

**À vérifier régulièrement:**
- Permissions demandées vs. réellement utilisées
- Supprimer les permissions inutilisées

---

## 📊 Checklist de Sécurité Pre-Production

- [x] Secrets migrés vers .env
- [x] RLS activé sur toutes les tables
- [x] Error handling centralisé
- [x] Resource cleanup (Agora)
- [ ] Google Places API key restreinte
- [ ] Firebase App Check activé
- [ ] Rate limiting sur Edge Functions
- [ ] Crash reporting configuré
- [ ] Edge Functions CRM sécurisées (API key)
- [ ] HTTPS Pinning implémenté
- [ ] Code obfuscation activée
- [ ] ProGuard configuré (Android)
- [ ] Biometric auth pour actions sensibles
- [ ] Audit permissions finalisé

---

## 🔍 Tests de Sécurité Recommandés

### Tests Manuels
1. **Test extraction secrets:** Décompiler APK/IPA et vérifier qu'aucune clé n'est visible
2. **Test RLS:** Tenter d'accéder aux données d'un autre user via API
3. **Test Edge Functions:** Appeler sans auth JWT et vérifier le rejet

### Tests Automatisés
1. **SAST (Static Analysis):** Utiliser `flutter analyze` + `dart analyze`
2. **Dependency Audit:** `flutter pub outdated` + vérifier CVEs
3. **Penetration Testing:** Engager un auditeur externe avant production

---

## 📞 Contact Sécurité

Pour signaler une vulnérabilité: security@lynewed.com

**Dernière révision:** 7 novembre 2025
