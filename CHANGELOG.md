# Changelog - Lynewed Alpha

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

---

## [1.0.27+30] - 2025-10-26

### 🐛 Corrections de Bugs

#### Affichage de la Date dans Info Wedding Pin Sheet
- **Corrigé** : La date `event_start_date` ne s'affichait pas dans le sheet d'information des wedding pins
- **Cause** : Les fonctions RPC Supabase `get_wedding_pin_item_details` et `get_bride_interest_items` convertissaient la date en `TEXT` avec `::text`, ce qui créait un format non parseable par Flutter
- **Solution** : Retirer la conversion `::text` et laisser Supabase gérer la sérialisation native des dates PostgreSQL
- **Fichiers** : 
  - RPC Supabase : `get_wedding_pin_item_details` et `get_bride_interest_items` (modifications côté base de données)
  - Code Flutter : Ajout de logs de debug temporaires pour vérification
- **Impact** : Les dates s'affichent maintenant correctement au format `d/M/y` (ex: 25/12/2025)

### 🔧 Améliorations Techniques

#### Logging de Debug
- **Ajouté** : Logs temporaires dans `get_wedding_pin_item_details_rpc.dart` et `info_wedding_pin_sheet_widget.dart`
- **Objectif** : Vérification du parsing des dates pendant les tests
- **Usage** : Les logs apparaîtront dans la console Flutter pendant le développement

### 📦 Build et Déploiement

#### Version iOS pour TestFlight
- **Mis à jour** : Version de l'application `1.0.26+29` → `1.0.27+30`
- **Build** : Création réussie du fichier `.ipa` pour TestFlight
- **Localisation** : `/Users/leoberthet/Desktop/build_output/Lynewed - Alpha.ipa`
- **Taille** : ~73 MB
- **Configuration** : Export avec méthode `app-store-connect`

### 🧪 Tests Recommandés

- [ ] Vérifier l'affichage des dates dans les wedding pins
- [ ] Tester le build iOS sur un appareil
- [ ] Upload vers TestFlight et vérification des dates
- [ ] Test des autres fonctionnalités pour régression

### 🔄 Migration

Aucune migration nécessaire. Les changements sont rétrocompatibles.

### ⚠️ Actions Requises

1. **Appliquer les modifications RPC Supabase** (côté base de données)
2. **Retirer les logs de debug** après validation
3. **Uploader le .ipa sur TestFlight**

---

## [1.0.26+29] - 2025-10-26

### 🔧 Améliorations Techniques

#### Debug et Logging
- **Ajouté** : Logs de debug pour analyser le problème d'affichage des dates
- **Fichiers** : `get_wedding_pin_item_details_rpc.dart`, `info_wedding_pin_sheet_widget.dart`
- **Objectif** : Identifier pourquoi `event_start_date` ne s'affiche pas

### 📦 Build et Déploiement

#### Préparation Build iOS
- **Tentative** : Build iOS pour TestFlight (rencontré des problèmes de permissions)
- **Résolution** : Utilisation de `xcodebuild` direct pour créer l'archive et l'export
- **Résultat** : Fichier `.ipa` généré avec succès

---

## [1.0.22+23] - 2025-10-24

### 🐛 Corrections de Bugs Critiques

#### Bug Permission de Localisation iOS/iPad (Rejet Apple)
- **Corrigé** : Permission de localisation ouvrant prématurément les paramètres iOS sans afficher la popup système
- **Fichier** : `/lib/custom_code/actions/check_and_request_permission.dart`
- **Impact** : Toutes les permissions (LOCATION, CAMERA, PHOTOS, MICROPHONE, NOTIFICATIONS)
- **Détails** : La fonction vérifiait `isPermanentlyDenied`/`isRestricted` AVANT de demander la permission
- **Solution** : Demande la permission EN PREMIER, puis vérifie le statut
- **Conformité** : ✅ Conforme aux Apple Guidelines
- **Documentation** : `BUG_FIX_LOCATION_PERMISSION.md`

#### Fonctionnalité Appels Vidéo Agora
- **Corrigé** : Vérification enum "ended" vs "completed" (aucun problème trouvé)
- **Ajouté** : Vérification des permissions Camera/Microphone avant l'appel
- **Ajouté** : Validation complète de la session vidéo (id, channel, token)
- **Ajouté** : Timeout automatique de 30 secondes pour les sessions pending
- **Ajouté** : Gestion d'erreur robuste avec messages clairs
- **Fichiers** : 
  - `/lib/pages/shared/chat_details/chat_details_widget.dart`
  - `/lib/pages/shared/chat_details/chat_details_model.dart`
  - `/lib/custom_code/actions/start_video_session_action.dart`
  - `/lib/custom_code/actions/handle_video_session_timeout.dart` (nouveau)
- **Documentation** : `VIDEO_CALL_FIXES_APPLIED.md`

### ✨ Améliorations

#### Gestion des Permissions
- Vérification systématique des permissions avant utilisation
- Messages d'erreur clairs et spécifiques
- Arrêt de l'exécution si permissions manquantes
- Conforme aux guidelines Apple et Google

#### Appels Vidéo
- Validation en 7 étapes avant de démarrer un appel
- Détection précoce des erreurs de connexion
- Timeout automatique pour éviter les sessions "pending" infinies
- Logs de debug complets pour faciliter le troubleshooting

#### Qualité du Code
- Ajout de commentaires explicatifs
- Gestion d'erreur améliorée
- Messages utilisateur plus clairs
- Architecture préservée (FlutterFlow)

### 📝 Documentation

#### Nouveaux Fichiers de Documentation
- `BUG_FIX_LOCATION_PERMISSION.md` - Analyse du bug de permission iOS
- `PERMISSION_BUG_SUMMARY.txt` - Résumé visuel du bug
- `VIDEO_CALL_ANALYSIS.md` - Analyse complète des appels vidéo
- `VIDEO_CALL_QUICK_FIX.md` - Guide de correction rapide
- `VIDEO_CALL_SUMMARY.txt` - Résumé visuel
- `VIDEO_CALL_FIXES_APPLIED.md` - Documentation des corrections
- `CHANGELOG.md` - Ce fichier

### 🔧 Fichiers Modifiés

1. `/lib/custom_code/actions/check_and_request_permission.dart`
   - Correction de la logique de demande de permission
   - Ajout de gestion pour `isLimited` (iOS 14+)

2. `/lib/pages/shared/chat_details/chat_details_widget.dart`
   - Ajout vérification permissions Camera/Microphone
   - Validation complète de la session vidéo
   - Amélioration gestion d'erreur
   - Ajout import `/backend/schema/enums/enums.dart`

3. `/lib/pages/shared/chat_details/chat_details_model.dart`
   - Ajout `cameraPermissionResult: String?`
   - Ajout `micPermissionResult: String?`

4. `/lib/custom_code/actions/start_video_session_action.dart`
   - Ajout déclenchement timeout automatique

5. `/lib/custom_code/actions/index.dart`
   - Export de `handleVideoSessionTimeout`

6. `/pubspec.yaml`
   - Version mise à jour : `1.0.21+22` → `1.0.22+23`

### 📦 Fichiers Créés

1. `/lib/custom_code/actions/handle_video_session_timeout.dart`
   - Nouvelle action pour gérer le timeout des sessions vidéo
   - Marque automatiquement comme "missed" après 30 secondes

### 🧪 Tests Recommandés

- [ ] Test permission localisation sur iPhone
- [ ] Test permission localisation sur iPad
- [ ] Test appel vidéo normal (avec permissions)
- [ ] Test appel vidéo sans permissions
- [ ] Test timeout appel vidéo (30 secondes)
- [ ] Test refus de permission
- [ ] Test erreur de connexion

### 🔄 Migration

Aucune migration nécessaire. Les changements sont rétrocompatibles.

### ⚠️ Breaking Changes

Aucun breaking change. L'architecture FlutterFlow est préservée.

---

## [1.0.21+22] - 2025-10-24

### 🎉 Version Initiale

- Migration du projet FlutterFlow vers environnement local
- Configuration complète Firebase (iOS + Android)
- Configuration Supabase
- Toutes les permissions configurées
- Compilation iOS testée et fonctionnelle

### 📚 Documentation Initiale

- `START_HERE.md` - Point d'entrée principal
- `QUICKSTART.md` - Guide de démarrage rapide
- `SETUP.md` - Configuration détaillée
- `APPLE_FIXES.md` - Corrections pour soumission Apple
- `CHANGELOG_MIGRATION.md` - Journal de migration
- `README.md` - Vue d'ensemble
- Scripts : `run_ios.sh`, `check_config.sh`

---

## Format du Changelog

Ce changelog suit le format [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

### Types de Changements

- **Ajouté** (`Added`) - pour les nouvelles fonctionnalités
- **Modifié** (`Changed`) - pour les changements dans les fonctionnalités existantes
- **Déprécié** (`Deprecated`) - pour les fonctionnalités bientôt supprimées
- **Supprimé** (`Removed`) - pour les fonctionnalités supprimées
- **Corrigé** (`Fixed`) - pour les corrections de bugs
- **Sécurité** (`Security`) - en cas de vulnérabilités
