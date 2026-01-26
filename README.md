# Lynewed Mobile App

[![Version](https://img.shields.io/badge/version-1.2.4+70-blue.svg)](pubspec.yaml)
[![Flutter](https://img.shields.io/badge/Flutter-3.32.4-02569B.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2.svg?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)]()
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000.svg?logo=apple)]()

Application Flutter de mise en relation mariées/professionnels du mariage avec architecture Clean Architecture et Design System unifié.

---

## Prérequis

| Outil | Version | Notes |
|-------|---------|-------|
| Flutter | 3.32.4+ | `flutter --version` |
| Dart SDK | >=3.0.0 <4.0.0 | Inclus avec Flutter |
| Xcode | 15+ | iOS development |
| iOS Deployment | **15.0+** | Firebase 12.x requirement |
| Android Studio | Latest | Android development |
| CocoaPods | 1.14+ | `pod --version` |
| Git | Latest | Version control |

---

## Installation Rapide

### 1. Clone et Dépendances

```bash
# Clone le repository
git clone [repo-url]
cd lynewed_v1

# Installer les dépendances Flutter
flutter pub get

# iOS: Installer les pods
cd ios && pod install && cd ..
```

### 2. Configuration Environnement

```bash
# Copier le template
cp .env.example .env

# Éditer avec vos clés API
# Voir section "Variables d'Environnement" ci-dessous
```

### 3. Firebase Setup (iOS)

Le fichier `GoogleService-Info.plist` doit être:
1. Présent dans `ios/Runner/`
2. **Référencé dans le projet Xcode** (pas juste copié dans le dossier)

Pour l'ajouter dans Xcode:
- Ouvrir `ios/Runner.xcworkspace`
- Clic droit sur Runner > Add Files to "Runner"
- Sélectionner `GoogleService-Info.plist`
- Cocher "Copy items if needed"

### 4. Lancer l'Application

```bash
# Lancer sur simulateur/device
flutter run

# Ou via le script (inclut checks)
./scripts/build_and_run.sh
```

---

## Variables d'Environnement

Le projet utilise `flutter_dotenv` pour charger les secrets au runtime. Un fichier `.env` est **obligatoire** à la racine.

| Variable | Description | Obligatoire | Où l'obtenir |
|----------|-------------|-------------|--------------|
| `SUPABASE_URL` | URL projet Supabase | Oui | Dashboard Supabase > Settings > API |
| `SUPABASE_ANON_KEY` | Clé anonyme publique | Oui | Dashboard Supabase > Settings > API |
| `GOOGLE_PLACES_API_KEY_IOS` | API Google Places iOS | Oui | Google Cloud Console (restreindre au bundle ID) |
| `GOOGLE_PLACES_API_KEY_ANDROID` | API Google Places Android | Oui | Google Cloud Console (restreindre au package) |
| `AGORA_APP_ID` | ID application Agora | Oui | Console Agora.io |

Voir [`.env.example`](.env.example) pour le template complet.

---

## Commandes Principales

```bash
# Développement
flutter run                        # Lancer en mode debug
flutter run --release              # Lancer en mode release

# Tests
flutter test                       # Tous les tests (3069 tests)
flutter test test/unit/            # Tests unitaires uniquement

# Qualité
flutter analyze --fatal-infos      # Linting (0 warnings obligatoire)

# Build
flutter build ios                  # Build iOS
flutter build apk                  # Build Android APK
flutter build appbundle            # Build Android App Bundle

# Nettoyage
flutter clean                      # Nettoyer le cache
```

---

## Structure du Projet

```
lynewed_v1/
├── lib/
│   ├── main.dart                # Point d'entrée
│   ├── core/                    # Code partagé
│   │   ├── design/              # Design System unifié
│   │   ├── services/            # Services partagés
│   │   └── utils/               # Utilitaires
│   ├── features/                # 15 modules Clean Architecture
│   │   ├── auth/                # Authentification
│   │   ├── chat/                # Messagerie temps réel
│   │   ├── map/                 # Carte interactive
│   │   ├── my_wedding/          # Suite mariage (Bride)
│   │   ├── notifications/       # Notifications push
│   │   └── ...                  # 10 autres modules
│   └── backend/                 # Schéma Supabase
├── ios/                         # Projet iOS natif
├── android/                     # Projet Android natif
├── supabase/                    # Backend Supabase
│   ├── migrations/              # Migrations DB
│   └── functions/               # 16 Edge Functions
├── docs/                        # Documentation
├── scripts/                     # Scripts utilitaires
└── test/                        # Tests (3069)
```

---

## Troubleshooting

### Erreurs Courantes

| Erreur | Cause | Solution |
|--------|-------|----------|
| CocoaPods conflict | Versions incompatibles | `cd ios && rm Podfile.lock && pod install --repo-update` |
| Google Places fail | Restrictions API | Vérifier bundle ID/package dans Google Cloud Console |
| Build iOS fail | Cache corrompu | `flutter clean && flutter pub get && cd ios && pod install` |
| SIGABRT Firebase | GoogleService-Info.plist absent | Vérifier que le fichier est référencé dans Xcode |
| Écran blanc | .env manquant/incomplet | Vérifier que `.env` existe avec TOUTES les variables |
| iOS deployment error | Version iOS trop basse | Appareil doit être iOS 15.0+ |

### Firebase iOS - Checklist

Si crash Firebase au lancement:
1. `GoogleService-Info.plist` présent dans `ios/Runner/`?
2. Fichier **référencé** dans Xcode (pas juste copié)?
3. Bundle ID correspond à celui configuré dans Firebase Console?

### Reset Complet

```bash
# Reset Flutter
flutter clean
rm -rf ~/.pub-cache
flutter pub get

# Reset iOS
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData
pod install --repo-update
cd ..
```

---

## Documentation

### Architecture
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Structure projet, patterns, modules
- **[docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md)** - Design System (1041 lignes)

### Guides
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guide de contribution
- **[guides/BUILD_IPA_GUIDE.md](guides/BUILD_IPA_GUIDE.md)** - Build iOS production
- **[guides/technical_specification.md](guides/technical_specification.md)** - Specs techniques

### État du Projet
- **[docs/PROJECT.md](docs/PROJECT.md)** - Vue d'ensemble
- **[docs/epics/](docs/epics/)** - Epics et stories de développement

---

## État du Projet

| Métrique | Valeur |
|----------|--------|
| **Version** | 1.2.4+70 |
| **Tests** | 3069 |
| **Warnings** | 0 |
| **Modules CA** | 15 |
| **Edge Functions** | 16 |
| **Users Production** | 248 |

| Epic | Status |
|------|--------|
| EPIC-01 Migration CA | ✅ 100% |
| EPIC-02 Tests | ✅ 100% |
| EPIC-03 Dependencies | ⏸️ 64% |
| EPIC-04 Documentation | 🚧 En cours |
| EPIC-05 Security | ✅ 100% |

---

## Stack Technique

| Catégorie | Technologie |
|-----------|-------------|
| **Framework** | Flutter 3.32.4 |
| **Langage** | Dart 3.8.1 |
| **Architecture** | Clean Architecture (15 modules) |
| **State Management** | Provider + Cubit + ValueNotifier |
| **Navigation** | GoRouter |
| **Backend** | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| **Video** | Agora RTC |
| **Maps** | Google Maps + Google Places SDK |
| **Notifications** | Firebase Cloud Messaging |

---

## Scripts Utiles

```bash
./scripts/check_config.sh       # Vérifier configuration projet
./scripts/build_and_run.sh      # Build et lancer sur simulateur
./scripts/install_simulator.sh  # Installer simulateur iOS
```

---

## Licence

Propriétaire - Lynewed © 2024-2026
