# Story S01: README.md Complet

**Epic:** EPIC-04-DOCUMENTATION
**ID:** S01
**Points:** 3
**Priorite:** P1 - Critique
**Statut:** A faire

---

## Description

En tant que **nouveau developpeur** rejoignant le projet Lynewed,
je veux un **README.md complet et a jour**
afin de **pouvoir installer et lancer le projet en moins de 30 minutes**.

---

## Criteres d'Acceptance

- [ ] Le README contient les prerequis systeme (Flutter, Xcode, Android Studio, **iOS 15.0+**)
- [ ] Instructions d'installation pas-a-pas (clone, deps, env)
- [ ] **Fichier `.env.example` cree** avec toutes les variables requises
- [ ] Configuration des variables d'environnement (.env) documentee avec **ou les obtenir**
- [ ] Commandes principales documentees (run, test, build, analyze)
- [ ] Section troubleshooting avec erreurs courantes **incluant Firebase/GoogleService-Info.plist**
- [ ] Liens vers documentation complementaire
- [ ] Badge de version et statut du projet (**v1.2.4+70** - synchronise avec pubspec.yaml)

---

## Contenu Attendu

### 1. Header
- Nom du projet + description courte
- Badges: version, Flutter, plateformes

### 2. Prerequis
```markdown
- Flutter 3.32.4+ (Dart 3.8.1+)
- Dart SDK >=3.0.0 <4.0.0
- Xcode 15+ (iOS) - **iOS 15.0 minimum deployment target**
- Android Studio (Android)
- Compte Supabase (backend)
- Fichier .env configure (voir section Configuration)
```

### 3. Installation Rapide
```bash
# Clone
git clone [repo]
cd lynewed_v1

# Dependances
flutter pub get

# Configuration
cp .env.example .env
# Editer .env avec vos cles API

# iOS
cd ios && pod install && cd ..

# Lancer
flutter run
```

### 4. Variables d'Environnement

> **IMPORTANT**: Le projet utilise `flutter_dotenv` pour charger les secrets au runtime.
> Un fichier `.env` est OBLIGATOIRE a la racine du projet.

**Creer `.env.example` avec ce contenu:**
```bash
# Supabase (requis)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Google Places (requis)
GOOGLE_PLACES_API_KEY_IOS=your-ios-key
GOOGLE_PLACES_API_KEY_ANDROID=your-android-key

# Agora Video (requis)
AGORA_APP_ID=your-agora-app-id

# Firebase (configure via google-services.json / GoogleService-Info.plist)
```

| Variable | Description | Obligatoire | Ou l'obtenir |
|----------|-------------|-------------|--------------|
| `SUPABASE_URL` | URL projet Supabase | Oui | Dashboard Supabase > Settings > API |
| `SUPABASE_ANON_KEY` | Cle anonyme publique | Oui | Dashboard Supabase > Settings > API |
| `GOOGLE_PLACES_API_KEY_IOS` | API Google Places iOS | Oui | Google Cloud Console (restreindre au bundle ID) |
| `GOOGLE_PLACES_API_KEY_ANDROID` | API Google Places Android | Oui | Google Cloud Console (restreindre au package) |
| `AGORA_APP_ID` | ID application Agora | Oui | Console Agora.io |

### 5. Commandes Utiles
```bash
flutter run                    # Lancer en dev
flutter test                   # Tests
flutter analyze --fatal-infos  # Linting
flutter build ios              # Build iOS
flutter build apk              # Build Android
```

### 6. Structure du Projet (apercu)
```
lib/
├── core/           # Code partage (design system, services)
├── features/       # Modules Clean Architecture
├── backend/        # Schema Supabase
└── pages/          # Pages legacy
```

### 7. Troubleshooting

#### Erreurs courantes

| Erreur | Cause | Solution |
|--------|-------|----------|
| CocoaPods conflict | Versions incompatibles | `cd ios && rm Podfile.lock && pod install --repo-update` |
| Google Places fail | Restrictions API | Verifier bundle ID/package dans Google Cloud Console |
| Build iOS fail | Cache corrompu | `flutter clean && flutter pub get && cd ios && pod install` |
| SIGABRT Firebase | GoogleService-Info.plist absent | Verifier que le fichier est dans Xcode (pas juste dans le dossier) |
| Ecran blanc au lancement | .env manquant ou incomplet | Verifier que `.env` existe avec TOUTES les variables |
| iOS deployment error | Version iOS trop basse | Appareil doit etre iOS 15.0+ (Firebase 12.x requirement) |

#### Firebase iOS Setup
Le fichier `GoogleService-Info.plist` doit etre:
1. Present dans `ios/Runner/`
2. **Reference dans le projet Xcode** (pas juste copie dans le dossier)
   - Ouvrir Xcode > Runner > Add Files > Selectionner GoogleService-Info.plist

### 8. Liens
- Architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)
- Contribution: [CONTRIBUTING.md](./CONTRIBUTING.md)
- Design System: [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md)

---

## Notes Techniques

### Sources d'Information Existantes
- `README.md` actuel (basique)
- `pubspec.yaml` (dependances, version 1.2.4+70)
- `docs/PROJECT.md` (etat projet)
- `docs/epics/EPIC-01-MIGRATION-CLEAN-ARCHITECTURE/stories/SESSION-2026-01-25-IOS-BUILD-FIX.md` (troubleshooting iOS)

### Livrables Additionnels
- **CREER** `.env.example` a la racine avec toutes les variables documentees
- **VERIFIER** que la version README correspond a pubspec.yaml (v1.2.4+70)

### Fichier a Modifier
- `/README.md` (racine du projet)

### Points d'Attention
- Ne pas exposer de secrets dans la documentation
- Garder les instructions generiques (pas de chemins absolus)
- Tester les commandes avant de documenter

---

## Definition of Done

- [ ] README mis a jour avec tous les contenus
- [ ] Un collegue peut suivre les instructions et lancer le projet
- [ ] Aucun secret expose
- [ ] Liens internes fonctionnels
- [ ] Review par un autre developpeur

---

## Estimation

| Tache | Temps estime |
|-------|--------------|
| Redaction sections 1-4 | 1h |
| Redaction sections 5-8 | 1h |
| Test des instructions | 30min |
| Review et ajustements | 30min |
| **Total** | **3h** |
