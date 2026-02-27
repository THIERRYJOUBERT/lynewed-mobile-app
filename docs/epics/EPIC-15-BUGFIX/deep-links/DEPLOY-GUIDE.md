# Deep Links Deployment Guide

> **Destinataire** : Thierry (admin serveur lynewed.com)
> **Objectif** : Corriger les fichiers `.well-known/` pour activer les Universal Links (iOS) et App Links (Android)
> **Date** : 2026-02-16

---

## PROBLEMES ACTUELS IDENTIFIES

### 1. Android App Links - BLOQUANT

**Fichier** : `https://lynewed.com/.well-known/assetlinks.json`

**Probleme** : Le SHA-256 fingerprint est "TODO" (placeholder non remplace)

```json
// ACTUEL (INVALIDE)
"sha256_cert_fingerprints": ["TODO"]
```

**Impact** : Les deep links Android NE FONCTIONNENT PAS. Le systeme Android rejette le fichier car "TODO" n'est pas un fingerprint valide.

### 2. iOS Universal Links - PROBLEME MINEUR

**Fichier** : `https://lynewed.com/.well-known/apple-app-site-association`

**Probleme** : Le fichier est servi avec `Content-Type: application/octet-stream` au lieu de `application/json`

**Impact** : iOS est generalement tolerant et peut accepter le fichier malgre le mauvais Content-Type, mais le comportement n'est pas garanti. Apple recommande fortement `application/json`.

---

## FICHIERS A DEPLOYER

Les fichiers corriges sont fournis dans ce dossier :

| Fichier | Destination serveur | Notes |
|---------|-------------------|-------|
| `apple-app-site-association` | `/.well-known/apple-app-site-association` | Pas d'extension .json |
| `assetlinks.json` | `/.well-known/assetlinks.json` | Extension .json requise |

---

## ETAPES DE DEPLOIEMENT

### Etape 1 : Deployer assetlinks.json (Android)

1. Copier le fichier `assetlinks.json` fourni vers le serveur :
   ```bash
   scp assetlinks.json serveur:/var/www/lynewed.com/.well-known/assetlinks.json
   ```

2. Verifier les permissions :
   ```bash
   chmod 644 /var/www/lynewed.com/.well-known/assetlinks.json
   ```

3. Tester l'URL :
   ```bash
   curl -I https://lynewed.com/.well-known/assetlinks.json
   ```

   Doit retourner :
   - Status : `200 OK`
   - `Content-Type: application/json`

### Etape 2 : Deployer apple-app-site-association (iOS)

1. Copier le fichier (SANS extension .json) :
   ```bash
   scp apple-app-site-association serveur:/var/www/lynewed.com/.well-known/apple-app-site-association
   ```

2. Verifier les permissions :
   ```bash
   chmod 644 /var/www/lynewed.com/.well-known/apple-app-site-association
   ```

3. **CRITIQUE** : Configurer le Content-Type dans nginx/apache

   **Nginx** (recommande) :
   ```nginx
   location /.well-known/apple-app-site-association {
       default_type application/json;
       add_header Content-Type application/json;
   }
   ```

   **Apache** :
   ```apache
   <Files "apple-app-site-association">
       ForceType application/json
   </Files>
   ```

4. Recharger le serveur web :
   ```bash
   sudo nginx -s reload
   # OU
   sudo systemctl reload apache2
   ```

5. Tester l'URL :
   ```bash
   curl -I https://lynewed.com/.well-known/apple-app-site-association
   ```

   Doit retourner :
   - Status : `200 OK`
   - `Content-Type: application/json` (PAS octet-stream)

### Etape 3 : Verifier les deux domaines

Les fichiers doivent etre accessibles sur les deux domaines :

```bash
curl https://lynewed.com/.well-known/assetlinks.json
curl https://www.lynewed.com/.well-known/assetlinks.json

curl https://lynewed.com/.well-known/apple-app-site-association
curl https://www.lynewed.com/.well-known/apple-app-site-association
```

Si `www.lynewed.com` redirige vers `lynewed.com`, s'assurer que les fichiers `.well-known/` sont accessibles AVANT la redirection (ou deployer sur les deux).

### Etape 4 : Purger le cache CDN (si applicable)

Si le serveur utilise un CDN (Cloudflare, etc.), purger le cache pour les URLs :
- `/.well-known/assetlinks.json`
- `/.well-known/apple-app-site-association`

---

## VALEURS UTILISEES

### Android (assetlinks.json)

| Champ | Valeur |
|-------|--------|
| `package_name` | `com.lynewed.app` |
| `sha256_cert_fingerprints[0]` | `A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44` |

**Note** : Cette valeur est le SHA-256 du **debug keystore**. Pour la production Google Play, il faudra ajouter le SHA-256 du **release keystore**.

Pour extraire le SHA-256 release (quand disponible) :
```bash
keytool -list -v -keystore path/to/lynewed-release.keystore -alias lynewed
```

Puis ajouter le fingerprint dans le tableau :
```json
"sha256_cert_fingerprints": [
  "A2:5B:89:F6:E9:43:4A:DF:47:F3:2C:7F:72:F7:16:DC:6D:F4:5C:1B:86:06:95:90:88:D5:98:C7:7B:EF:06:44",
  "XX:XX:XX:XX:..." // SHA-256 release
]
```

### iOS (apple-app-site-association)

| Champ | Valeur |
|-------|--------|
| `appID` | `G234APMW4U.com.lynewed.app` |
| `paths` | `["/join/*"]` |

**Note** : `G234APMW4U` est l'Apple Team ID du compte developpeur.

---

## TESTS POST-DEPLOIEMENT

### Test 1 : Validation Google (Android)

Google fournit un outil de test officiel :

```
https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://lynewed.com&relation=delegate_permission/common.handle_all_urls
```

Resultat attendu : Le JSON doit contenir `"com.lynewed.app"` et le SHA-256.

### Test 2 : Validation Apple (iOS)

Apple ne fournit pas d'outil public, mais on peut tester via :

1. **Simulator iOS** : Ouvrir Safari, taper `https://lynewed.com/join/TESTCODE` et verifier que l'app s'ouvre
2. **Device physique** : Envoyer le lien par iMessage/Mail et cliquer dessus

### Test 3 : Deep link reel

1. Creer un code d'invitation test (ex: `TESTCODE`)
2. Sur iOS : Ouvrir `https://lynewed.com/join/TESTCODE` dans Safari → l'app doit s'ouvrir
3. Sur Android : Ouvrir `https://lynewed.com/join/TESTCODE` dans Chrome → l'app doit s'ouvrir

---

## TROUBLESHOOTING

### Probleme : Android App Links ne fonctionne pas apres deploiement

**Causes possibles** :
1. Le SHA-256 release n'est pas ajoute (si l'app est en prod Google Play)
2. Le package name est incorrect
3. Le fichier n'est pas accessible (erreur 404)
4. Cache CDN pas purge

**Debug** :
```bash
# Verifier le fichier
curl https://lynewed.com/.well-known/assetlinks.json

# Verifier avec l'outil Google
curl "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://lynewed.com&relation=delegate_permission/common.handle_all_urls"

# Verifier depuis l'appareil Android
adb shell pm get-app-links com.lynewed.app
```

### Probleme : iOS Universal Links ne fonctionne pas

**Causes possibles** :
1. Content-Type toujours en octet-stream (nginx pas recharge)
2. Le fichier a l'extension `.json` (il ne doit PAS en avoir)
3. L'app est installee via Xcode direct (les Universal Links ne fonctionnent pas en mode debug Xcode)

**Debug** :
```bash
# Verifier Content-Type
curl -I https://lynewed.com/.well-known/apple-app-site-association

# Verifier le contenu
curl https://lynewed.com/.well-known/apple-app-site-association | jq .

# Verifier depuis l'appareil iOS
# Settings > Developer > Universal Links Testing > App-Site Association (si mode dev actif)
```

### Probleme : www vs non-www

Si les deep links fonctionnent sur `lynewed.com` mais pas sur `www.lynewed.com` :

1. Verifier que les fichiers sont accessibles sur les deux :
   ```bash
   curl https://www.lynewed.com/.well-known/assetlinks.json
   ```

2. Si redirection 301/302, s'assurer que les fichiers `.well-known/` sont servis AVANT la redirection.

---

## CONTACT

En cas de probleme ou question, contacter l'equipe dev avec :
- L'URL testee
- Le resultat du curl
- Les logs serveur web (nginx/apache error.log)
- Capture d'ecran du comportement sur mobile

---

**Fichiers a deployer** : Voir dossier `docs/epics/EPIC-15-BUGFIX/deep-links/`
