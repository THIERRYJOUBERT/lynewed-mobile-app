# 🚀 GUIDE DE LANCEMENT - LYNEWED ALPHA
**Méthode : Build et Run depuis Xcode**

---

## ✅ ÉTAPE 1 : Xcode est Ouvert

Xcode devrait maintenant être ouvert avec le workspace `Runner.xcworkspace`.

---

## 📱 ÉTAPE 2 : Sélectionner le Simulateur

1. **En haut de la fenêtre Xcode**, à côté du bouton Play ▶️, vous verrez :
   ```
   Runner > [Device actuel]
   ```

2. **Cliquez sur le nom du device** (à droite de "Runner >")

3. **Sélectionnez** : `iPhone 16e` (ou n'importe quel simulateur iOS)

---

## ⚙️ ÉTAPE 3 : Configurer la Signature (Si Nécessaire)

**Si vous voyez une erreur de signature :**

1. Dans la barre latérale gauche, **cliquez sur le projet "Runner"** (icône bleue en haut)

2. **Sélectionnez le target "Runner"** dans la liste

3. **Onglet "Signing & Capabilities"**

4. **Décochez** "Automatically manage signing"

5. **Team** : Sélectionnez votre équipe ou "None"

6. **Signing Certificate** : Sélectionnez "Sign to Run Locally" ou "Development"

---

## ▶️ ÉTAPE 4 : Lancer l'Application

1. **Cliquez sur le bouton Play ▶️** en haut à gauche

2. **Attendez** que le build se termine (barre de progression en haut)

3. **Le simulateur va s'ouvrir** et l'application va se lancer automatiquement

---

## 🎯 ÉTAPE 5 : Tester l'Application

### Tests de Sécurité à Effectuer

#### 1. **Vérifier les Logs (Console Xcode)**
- En bas de Xcode, ouvrez la console (icône 💬)
- **Vérifiez qu'aucun log sensible n'apparaît** :
  - ❌ Pas de tokens exposés
  - ❌ Pas de passwords
  - ❌ Pas de clés API
  - ✅ Seulement des logs SecureLogger

#### 2. **Tester Google Places API**
- Allez dans la recherche de lieux
- Tapez une adresse
- **Vérifiez que l'autocomplétion fonctionne**
- ✅ Si ça fonctionne : L'API key est correctement chargée depuis `.env`

#### 3. **Tester Agora Video**
- Lancez un appel vidéo
- **Vérifiez que la caméra/micro fonctionnent**
- ✅ Si ça fonctionne : L'Agora App ID est correctement chargé

#### 4. **Tester Supabase**
- Créez un compte ou connectez-vous
- Envoyez un message
- **Vérifiez que les données sont sauvegardées**
- ✅ Si ça fonctionne : Supabase est correctement configuré

#### 5. **Tester les RLS Policies**
- Essayez de créer un profil
- Envoyez un message
- **Vérifiez qu'aucune erreur de permission n'apparaît**
- ✅ Si ça fonctionne : Les policies RLS sont correctes

---

## 🐛 DÉPANNAGE

### Erreur : "Command CodeSign failed"

**Solution :**
1. Allez dans "Signing & Capabilities"
2. Décochez "Automatically manage signing"
3. Sélectionnez "Sign to Run Locally"

### Erreur : "No such module 'flutter_dotenv'"

**Solution :**
```bash
cd /Users/leoberthet/Desktop/lynewed_alpha_v1.0.26+29
flutter pub get
cd ios
pod install
```

### Le Simulateur ne Démarre Pas

**Solution :**
```bash
# Redémarrer le simulateur
xcrun simctl shutdown all
xcrun simctl boot 53D436C5-C951-4341-B4B4-A3206DBD2D22
open -a Simulator
```

### L'App Crash au Démarrage

**Vérifiez dans la console Xcode :**
1. Ouvrez la console (💬 en bas)
2. Cherchez les erreurs rouges
3. Vérifiez que `.env` est bien chargé :
   ```
   Loaded .env file
   ```

---

## 📊 CHECKLIST DE VALIDATION

### Avant de Lancer
- [x] Xcode ouvert
- [x] Simulateur sélectionné
- [x] Pods installés
- [x] `.env` configuré

### Après le Lancement
- [ ] Application démarre sans crash
- [ ] Aucun log sensible dans la console
- [ ] Google Places fonctionne
- [ ] Agora Video fonctionne
- [ ] Supabase fonctionne
- [ ] RLS Policies fonctionnent

---

## 🎉 SUCCÈS !

Si tous les tests passent, **l'application est 100% fonctionnelle et sécurisée !**

**Score de sécurité : 7.5/10 🟢 BON**

---

## 📝 NOTES

### Logs Attendus dans la Console

**✅ Logs Normaux (SecureLogger) :**
```
ℹ️ [INFO] Application started
🔐 [SANITIZED] User data loaded
✅ [FUNCTION] fetchData completed
```

**❌ Logs à NE PAS Voir :**
```
Token: eyJhbGciOiJIUzI1NiIs...
Password: mypassword123
API Key: AIzaSyCLOe2yCKXS...
```

### Performance

**Temps de Build Attendu :**
- Premier build : 30-60 secondes
- Builds suivants : 10-20 secondes

**Temps de Lancement :**
- Simulateur : 5-10 secondes
- Device réel : 3-5 secondes

---

## 🔄 PROCHAINES ÉTAPES

### Si Tout Fonctionne
1. ✅ Tester toutes les fonctionnalités
2. ✅ Vérifier les logs de sécurité
3. ✅ Faire un build Release
4. ✅ Tester sur device réel

### Si Problèmes
1. Vérifier la console Xcode
2. Consulter `BUILD_TEST_REPORT.md`
3. Vérifier `.env` est bien chargé
4. Réinstaller les pods si nécessaire

---

**📅 Guide créé le 4 Novembre 2025 à 11:55 UTC+01:00**
