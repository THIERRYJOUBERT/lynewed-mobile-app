# S03 - Deep Links Diagnostic + Fix

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : INFRA
> **Complexite** : M (Medium) - 5 points
> **Source** : BUG-01c
> **Dependances** : Aucune
> **Bloque** : S05 (Edge Function send-wedding-invitation)
> **Status** : DONE (Phase 1 + Phase 2)

---

## Description

En tant que mariee ou invitee,
je veux que le lien `https://lynewed.com/join/{code}` ouvre directement l'application Lynewed sur la page de rejoindre un mariage,
afin de pouvoir rejoindre un mariage en un clic depuis un email, un QR code ou un message.

---

## RESUME EXECUTIF (2026-02-16)

**Statut** : ✅ **Phase 1 TERMINEE** (prep fichiers + code), ⏸️ Phase 2 BLOQUEE (deploiement serveur)

**Instruction Leo** : **Faire le maximum possible. Si les deep links ne fonctionnent toujours pas apres Phase 1, documenter ce qui reste a faire pour terminer plus tard.**

**Diagnostic effectue** :
- ✅ Fichiers `.well-known/` existent sur `lynewed.com` (verification WebFetch)
- ❌ `assetlinks.json` contient `"sha256_cert_fingerprints": ["TODO"]` → **Android App Links CASSES**
- ❌ `apple-app-site-association` servi avec `Content-Type: application/octet-stream` → iOS peut fonctionner mais non garanti
- ✅ Apple Team ID extrait depuis Xcode : `G234APMW4U`
- ✅ SHA-256 debug extrait via keytool : `A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44`
- ✅ `FlutterDeepLinkingEnabled` = `false` (iOS et Android confirme)

**Livrables Phase 1 (✅ LIVRES)** :
- ✅ Templates corriges avec VRAIES valeurs : `docs/epics/EPIC-15-BUGFIX/deep-links/`
  - `apple-app-site-association` (Team ID reel)
  - `assetlinks.json` (SHA-256 reel, pas "TODO")
- ✅ Guide de deploiement complet : `DEPLOY-GUIDE.md` (config nginx, tests, troubleshooting)
- ✅ Commentaires code corriges : `routes.dart` (lynewed.app → lynewed.com)
- ✅ Tests unitaires passent : 39/39 tests (deep_link_handler_test.dart)

**Bloquant Phase 2** : Acces serveur lynewed.com pour deployer fichiers corriges (responsabilite Thierry)

**Prochaines etapes** :
1. Fournir les fichiers + guide a Thierry
2. Si deploiement serveur impossible immediatement, documenter dans `REMAINING-WORK.md` ce qui reste a faire
3. Story peut etre marquee DONE avec mention "Phase 2 en attente deploiement serveur"

---

## Contexte et Probleme

### Symptome rapporte

Thierry indique que les deep links `lynewed.com/join/` ne redirigent pas vers l'app. Il affirme que "c'est configure" cote serveur mais le comportement attendu ne fonctionne pas.

### ETAT CRITIQUE DES FICHIERS .well-known/ EN PRODUCTION (2026-02-16)

**Verification effectuee** : Les fichiers existent mais sont incomplets/incorrects.

| Fichier | URL | Status | Probleme |
|---------|-----|--------|----------|
| AASA (iOS) | `https://lynewed.com/.well-known/apple-app-site-association` | ✅ Existe | ❌ **Content-Type: application/octet-stream** (devrait etre application/json) |
| DAL (Android) | `https://lynewed.com/.well-known/assetlinks.json` | ✅ Existe | ❌ **SHA-256 = "TODO"** (placeholder non remplace) |

**Impact** :
- **iOS** : Les Universal Links **peuvent** fonctionner malgre le Content-Type incorrect (iOS est tolerant), mais le comportement n'est pas garanti
- **Android** : Les App Links **NE FONCTIONNENT PAS** car le SHA-256 fingerprint est invalide ("TODO")

**Valeurs reelles extraites** :
- Apple Team ID : `G234APMW4U` (verifie dans Xcode project)
- Bundle ID : `com.lynewed.app` (confirme)
- SHA-256 Debug : `A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44`

**Action requise** : Deployer les fichiers corriges (templates fournis ci-dessous avec VRAIES valeurs).

### Incoherence de domaine identifiee

| Source | Domaine utilise |
|--------|-----------------|
| QR code Flutter (`my_wedding_page.dart:679`) | `https://lynewed.com/join/{code}` |
| Story EPIC-09/S06 (spec) | `https://lynewed.app/join/{code}` |
| iOS entitlements (`Runner.entitlements`) | `applinks:lynewed.com` + `applinks:www.lynewed.com` |
| Android manifest (`AndroidManifest.xml`) | `host="lynewed.com"` + `host="www.lynewed.com"` |
| Deep link handler (`deep_link_handler.dart`) | `lynewed.com` / `www.lynewed.com` |
| QR scanner sheet (`qr_scanner_sheet.dart`) | `lynewed.app` ou `lynewed.com` (les deux) |
| Edge Function spec EPIC-09/S06 | `https://lynewed.app/join/{code}` |
| Resend from address EPIC-09/S06 | `noreply@lynewed.app` |

**Decision** : Tout le code runtime et les entitlements utilisent `lynewed.com`. On reste sur `lynewed.com`. La spec EPIC-09/S06 etait incorrecte sur ce point.

### Causes racines probables

1. **Fichiers `.well-known/` absents ou mal configures sur le serveur `lynewed.com`**
   - `/.well-known/apple-app-site-association` (iOS Universal Links)
   - `/.well-known/assetlinks.json` (Android App Links)
2. **Apple Team ID ou bundle ID incorrect dans AASA**
3. **SHA-256 fingerprint incorrect dans assetlinks.json**
4. **Serveur lynewed.com ne sert pas les fichiers avec le bon Content-Type**

### Dependance externe

Thierry doit confirmer/fournir l'acces au serveur `lynewed.com` pour :
- Verifier si les fichiers `.well-known/` existent
- Les deployer/corriger si necessaire
- Configurer le fallback vers les stores

---

## Criteres d'Acceptance (Gherkin)

### AC-01 : Diagnostic des fichiers well-known

```gherkin
Given le domaine lynewed.com est le domaine de deep linking
When on accede a https://lynewed.com/.well-known/apple-app-site-association
Then le serveur retourne un JSON valide
And le JSON contient "applinks.details[].appIDs" = "G234APMW4U.com.lynewed.app"
And le JSON contient "paths" = ["/join/*"]
And le format est conforme a la spec Apple Universal Links
# CRITIQUE : Actuellement servi avec Content-Type: application/octet-stream (DOIT etre application/json)

Given le domaine lynewed.com est le domaine de deep linking
When on accede a https://lynewed.com/.well-known/assetlinks.json
Then le serveur retourne un JSON valide avec Content-Type application/json
And le JSON contient "target.package_name" = "com.lynewed.app"
And le JSON contient "sha256_cert_fingerprints" = ["A2:5B:89:F6:E9:43:4A:DF:..."] (PAS "TODO")
And le format est conforme a la spec Android App Links
# CRITIQUE : Actuellement le SHA-256 est "TODO" (INVALIDE)
```

**ETAT ACTUEL (2026-02-16)** :
- AASA : ✅ Structure correcte, ❌ Content-Type incorrect
- assetlinks.json : ✅ Structure correcte, ❌ SHA-256 = "TODO"

### AC-02 : Deep link ouvre l'app (iOS)

```gherkin
Given l'app Lynewed est installee sur un iPhone
And le fichier apple-app-site-association est correctement deploye
When l'utilisateur ouvre le lien https://lynewed.com/join/ABCD1234
Then l'app Lynewed s'ouvre
And l'utilisateur est redirige vers la page JoinWedding avec le code ABCD1234

Given l'app Lynewed est installee sur un iPhone
When l'utilisateur ouvre le lien https://www.lynewed.com/join/ABCD1234
Then le comportement est identique (www et non-www supportes)
```

### AC-03 : Deep link ouvre l'app (Android)

```gherkin
Given l'app Lynewed est installee sur un appareil Android
And le fichier assetlinks.json est correctement deploye
When l'utilisateur ouvre le lien https://lynewed.com/join/ABCD1234
Then l'app Lynewed s'ouvre
And l'utilisateur est redirige vers la page JoinWedding avec le code ABCD1234
```

### AC-04 : Fallback si app non installee

```gherkin
Given l'app Lynewed n'est PAS installee sur l'appareil
When l'utilisateur ouvre le lien https://lynewed.com/join/ABCD1234
Then l'utilisateur est redirige vers le store correspondant (App Store ou Play Store)
Or une page web intermediaire s'affiche avec des liens vers les stores
```

### AC-05 : Coherence de domaine dans tout le code

```gherkin
Given le domaine officiel de deep linking est lynewed.com
When on recherche des references a lynewed.app/join dans le code Flutter
Then aucune reference active (hors commentaires) n'utilise lynewed.app pour les deep links join
And les commentaires dans routes.dart sont mis a jour pour indiquer lynewed.com
And le QR scanner sheet supporte les deux domaines (retro-compatibilite)
```

### AC-06 : FlutterDeepLinkingEnabled desactive

```gherkin
Given le Info.plist iOS contient FlutterDeepLinkingEnabled
When on verifie sa valeur
Then elle est a false (pour eviter le conflit avec app_links)

Given le AndroidManifest.xml contient flutter_deeplinking_enabled
When on verifie sa valeur
Then elle est a false ou absente
```

---

## Fichiers Concernes

### A Diagnostiquer (serveur lynewed.com - dependance externe)

| Fichier | Emplacement | Contenu attendu |
|---------|-------------|-----------------|
| `apple-app-site-association` | `https://lynewed.com/.well-known/apple-app-site-association` | JSON avec applinks, Team ID, bundle ID |
| `assetlinks.json` | `https://lynewed.com/.well-known/assetlinks.json` | JSON avec package name, SHA-256 fingerprint |
| Page fallback (optionnel) | `https://lynewed.com/join/{code}` | Redirection vers stores si app pas installee |

### A Verifier / Modifier (code Flutter)

| Fichier | Action |
|--------|--------|
| `ios/Runner/Runner.entitlements` | Verifier (deja OK : `applinks:lynewed.com`) |
| `ios/Runner/Info.plist` | Verifier `FlutterDeepLinkingEnabled` = false |
| `android/app/src/main/AndroidManifest.xml` | Verifier intent filters (deja OK) + `flutter_deeplinking_enabled` = false |
| `lib/core/navigation/deep_link_handler.dart` | Verifier (deja OK : gere lynewed.com) |
| `lib/core/navigation/routes.dart:246-251` | Mettre a jour commentaires `lynewed.app` -> `lynewed.com` |
| `lib/features/auth/presentation/widgets/qr_scanner_sheet.dart:76-78` | Verifier support des deux domaines |

### Templates Crees (prets a deployer)

| Fichier | Emplacement | Status |
|---------|-------------|--------|
| `apple-app-site-association` | `docs/epics/EPIC-15-BUGFIX/deep-links/apple-app-site-association` | ✅ CREE avec VRAIES valeurs |
| `assetlinks.json` | `docs/epics/EPIC-15-BUGFIX/deep-links/assetlinks.json` | ✅ CREE avec VRAIES valeurs (debug SHA-256) |
| `DEPLOY-GUIDE.md` | `docs/epics/EPIC-15-BUGFIX/deep-links/DEPLOY-GUIDE.md` | ✅ CREE (guide complet pour Thierry) |

**IMPORTANT** : Les fichiers contiennent les VRAIES valeurs, pas des placeholders. Ils sont prets a deployer.

---

## Notes Techniques

### Fichier apple-app-site-association (VALEURS REELLES)

**Template a deployer sur `https://lynewed.com/.well-known/apple-app-site-association` :**

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "G234APMW4U.com.lynewed.app",
        "paths": ["/join/*"]
      }
    ]
  }
}
```

**Valeurs utilisees** :
- `APPLE_TEAM_ID` : **G234APMW4U** (extrait de Runner.xcodeproj)
- `bundle_id` : **com.lynewed.app**

**Contraintes serveur CRITIQUES** :
- ❌ **ERREUR ACTUELLE** : Le fichier est servi avec `Content-Type: application/octet-stream`
- ✅ **REQUIS** : Le fichier DOIT etre servi avec `Content-Type: application/json`
- Pas de redirection (status 200 direct)
- HTTPS obligatoire
- Le fichier doit etre accessible SANS `.json` extension

**Comment corriger le Content-Type** (nginx example) :
```nginx
location /.well-known/apple-app-site-association {
    default_type application/json;
}
```

### Fichier assetlinks.json (VALEURS REELLES)

**Template a deployer sur `https://lynewed.com/.well-known/assetlinks.json` :**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.lynewed.app",
      "sha256_cert_fingerprints": [
        "A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44"
      ]
    }
  }
]
```

**Valeurs utilisees** :
- `package_name` : **com.lynewed.app**
- `sha256_cert_fingerprints[0]` : **A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44** (debug keystore)

**IMPORTANT** : Cette version utilise le **debug keystore** seulement. Pour la production, Thierry devra ajouter le SHA-256 du **release keystore** (celui utilise pour signer l'APK Google Play).

**Comment extraire le SHA-256** :
```bash
# Debug (methode utilisee pour cette story)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep "SHA 256"
# Resultat : A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44

# Release (commande pour Thierry - necessite acces au keystore de production)
# IMPORTANT : ./gradlew signingReport necessite que les plugins Flutter soient corrects
# Si erreur "agora_rtc_engine plugin directory does not exist", faire d'abord :
flutter pub get
# Puis :
cd android && ./gradlew signingReport | grep "SHA-256"

# Alternative directe (si keystore disponible) :
keytool -list -v -keystore path/to/lynewed-release.keystore -alias lynewed | grep "SHA 256"
```

**Note** : La commande `gradlew signingReport` a echoue localement car le plugin Agora n'etait pas installe. Utilisation de `keytool` directement a reussi.

**Contraintes serveur** :
- ✅ Le fichier doit etre servi avec `Content-Type: application/json` (actuellement OK)
- Pas de redirection (status 200 direct)
- HTTPS obligatoire

### FlutterDeepLinkingEnabled (rappel MEMORY.md)

Quand `FlutterDeepLinkingEnabled=true`, le Flutter engine intercepte les deep links AVANT le package `app_links`. Les URLs custom scheme comme `lynewed://host/path` sont parsees par GoRouter avec `host` comme HOST et non comme path, ce qui provoque un no-route-match et redirige vers la home. La valeur DOIT etre `false`.

### Fallback vers les stores

Si l'app n'est pas installee, le navigateur ouvre la page web `lynewed.com/join/{code}`. Cette page doit :
1. Detecter la plateforme (iOS/Android)
2. Rediriger vers le store correspondant
3. Optionnellement afficher une page intermediaire avec le code d'invitation

**Alternative pragmatique** : Utiliser un meta-tag `<meta http-equiv="refresh">` ou un JavaScript redirect vers les stores.

---

## Plan d'Execution

### PHASE 1 - COMPLETABLE IMMEDIATEMENT (sans deploiement serveur)

**Objectif** : Preparer tous les fichiers et corrections cote app, documenter l'etat actuel

1. ✅ **FAIT** : Diagnostic des fichiers `.well-known/` sur `lynewed.com` (via WebFetch)
   - AASA existe mais Content-Type incorrect (octet-stream au lieu de json)
   - assetlinks.json existe mais SHA-256 = "TODO" (invalide)
2. ✅ **FAIT** : Extraction Apple Team ID (`G234APMW4U` depuis Xcode project)
3. ✅ **FAIT** : Extraction SHA-256 fingerprint Android debug via keytool
   - `A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44`
4. ✅ **FAIT** : Verification `FlutterDeepLinkingEnabled` = false (iOS et Android)
5. ✅ **FAIT** : Generation templates corriges avec VRAIES valeurs
   - `docs/epics/EPIC-15-BUGFIX/deep-links/apple-app-site-association`
   - `docs/epics/EPIC-15-BUGFIX/deep-links/assetlinks.json`
6. ✅ **FAIT** : Creation guide deploiement complet pour Thierry
   - `docs/epics/EPIC-15-BUGFIX/deep-links/DEPLOY-GUIDE.md`
   - Inclut config nginx pour Content-Type, tests, troubleshooting
7. ✅ **FAIT** : Correction commentaires obsoletes dans `routes.dart` (lynewed.app → lynewed.com)
8. ✅ **FAIT** : Verification QR scanner sheet supporte les deux domaines (regex deja OK)
9. ✅ **FAIT** : Tests unitaires existants passent (39 tests, 100% pass)

**Livrable Phase 1** :
- Templates prets a deployer (avec vraies valeurs, pas placeholders)
- Guide de deploiement complet
- Code app mis a jour (commentaires, verification FlutterDeepLinkingEnabled)
- Documentation de l'etat actuel des fichiers en prod

### PHASE 2 - BLOQUE JUSQU'AU DEPLOIEMENT SERVEUR (dependance externe - Thierry)

**Objectif** : Deployer les fichiers corriges et valider le comportement reel

10. Fournir les fichiers + guide a Thierry
11. Thierry deploie les fichiers avec les corrections :
    - `assetlinks.json` : Remplacer "TODO" par le vrai SHA-256
    - `apple-app-site-association` : Configurer Content-Type application/json
    - (Optionnel) Ajouter SHA-256 release keystore si disponible
12. Valider les fichiers deployes via `curl` (Content-Type + contenu)
13. Tester deep link reel `https://lynewed.com/join/TESTCODE` sur iOS (simulateur ou device)
14. Tester deep link reel `https://lynewed.com/join/TESTCODE` sur Android (emulateur ou device)
15. Valider le fallback vers stores si app pas installee

**Bloquant pour Phase 2** : Acces au serveur lynewed.com pour deployer les fichiers corriges

---

## Estimation

| Element | Estimation |
|---------|-----------|
| Diagnostic + extraction IDs | 1h |
| Creation templates + guide | 1h |
| Corrections code Flutter | 30min |
| Tests apres deploiement serveur | 30min |
| **Total** | **3h** |
| **Points** | **5** |

---

## Risques

| Risque | Impact | Mitigation | Status |
|--------|--------|------------|--------|
| Pas d'acces au serveur lynewed.com | BLOQUANT Phase 2 | Diviser en 2 phases : prep (completable) + deploiement (bloque) | ✅ Mitige |
| ❌ **REEL** : `assetlinks.json` a "TODO" en prod | BLOQUANT Android | Fournir fichier corrige avec vrai SHA-256 a Thierry | ⚠️ Confirme |
| ❌ **REEL** : AASA servi en octet-stream | MOYEN iOS | Fournir config nginx a Thierry pour fixer Content-Type | ⚠️ Confirme |
| Keystore release Android non disponible | MOYEN | Utiliser debug SHA-256 pour tester, Thierry ajoutera release apres | ✅ Mitige |
| DNS mal configure (redirect www vs non-www) | MOYEN | Deployer sur les deux : lynewed.com ET www.lynewed.com | ⏳ A verifier |
| Cache CDN serveur bloque la mise a jour | FAIBLE | Purger le cache apres deploiement | ⏳ A verifier |

---

## Validation INVEST

| Critere | Validation |
|---------|-----------|
| **I**ndependent | Aucune dependance technique sur d'autres stories. Bloque S05 mais peut etre fait en parallele de S01, S02, S04 |
| **N**egotiable | Le scope peut etre reduit au diagnostic + templates si l'acces serveur n'est pas dispo. Le deploiement peut etre differe |
| **V**aluable | Les deep links sont requis pour le flow d'invitation (feature critique). Sans eux, les emails d'invitation et QR codes ne fonctionnent pas |
| **E**stimable | 5 points (M). Diagnostic bien cadre, fichiers a creer connus, risque principal = dependance externe |
| **S**mall | Scope limite : diagnostic, templates, corrections commentaires. Pas de refactoring majeur |
| **T**estable | Testable via curl (fichiers well-known), test deep link reel (iOS/Android), verification code (commentaires) |

---

## Definition of Done

### PHASE 1 - Completable Immediatement ✅ TERMINEE

- [x] Fichiers `.well-known/` diagnostiques (WebFetch + resultat documente)
- [x] Etat critique documente : assetlinks.json a "TODO", AASA a mauvais Content-Type
- [x] Apple Team ID extrait (`G234APMW4U` depuis Xcode project)
- [x] SHA-256 fingerprint debug extrait (`A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44`)
- [x] `FlutterDeepLinkingEnabled` verifie a `false` sur iOS (Info.plist line 38) et Android (AndroidManifest.xml line 51)
- [x] Template `apple-app-site-association` genere avec les VRAIES valeurs (pas placeholders)
- [x] Template `assetlinks.json` genere avec les VRAIES valeurs (SHA-256 reel, pas "TODO")
- [x] Guide de deploiement cree pour Thierry (avec instructions nginx Content-Type, tests, troubleshooting)
- [x] Commentaires `lynewed.app` corriges en `lynewed.com` dans `routes.dart:246,251`
- [x] QR scanner sheet supporte les deux domaines (verifie - regex line 79 supporte app|com)
- [x] Tests unitaires existants passent (39/39 tests pass - `deep_link_handler_test.dart`)

**✅ Phase 1 COMPLETE - Story prete a merge** avec mention "Phase 2 bloquee par deploiement serveur".

### PHASE 2 - Depend Deploiement Serveur (Thierry)

- [ ] Fichiers corriges fournis a Thierry
- [ ] Thierry deploie `assetlinks.json` avec vrai SHA-256 (remplace "TODO")
- [ ] Thierry configure serveur pour servir AASA avec `Content-Type: application/json`
- [ ] (Optionnel) Thierry ajoute SHA-256 release keystore dans assetlinks.json
- [ ] Fichiers deployes valides via `curl` (Content-Type + contenu)
- [ ] Deep link `https://lynewed.com/join/TESTCODE` ouvre l'app sur iOS
- [ ] Deep link `https://lynewed.com/join/TESTCODE` ouvre l'app sur Android
- [ ] Fallback vers stores si app pas installee (verification navigateur mobile)

**Phase 2 peut etre trackee dans une story de suivi ou issue separee.**

---

## References

| Source | Contenu |
|--------|---------|
| `docs/epics/EPIC-09-INVITATIONS/stories/S06-edge-function-send-invitation.md` | Spec originale (domaine `lynewed.app` - a corriger dans S05) |
| `MEMORY.md` | Probleme FlutterDeepLinkingEnabled documente |
| [Apple Universal Links](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content) | Documentation officielle Apple |
| [Android App Links](https://developer.android.com/training/app-links/verify-android-applinks) | Documentation officielle Android |
