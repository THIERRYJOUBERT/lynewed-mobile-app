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

- [ ] Le README contient les prerequis systeme (Flutter, Xcode, Android Studio)
- [ ] Instructions d'installation pas-a-pas (clone, deps, env)
- [ ] Configuration des variables d'environnement (.env) documentee
- [ ] Commandes principales documentees (run, test, build, analyze)
- [ ] Section troubleshooting avec erreurs courantes
- [ ] Liens vers documentation complementaire
- [ ] Badge de version et statut du projet

---

## Contenu Attendu

### 1. Header
- Nom du projet + description courte
- Badges: version, Flutter, plateformes

### 2. Prerequis
```markdown
- Flutter 3.32.4+
- Dart SDK >=3.0.0 <4.0.0
- Xcode 15+ (iOS)
- Android Studio (Android)
- Compte Supabase (backend)
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
| Variable | Description | Obligatoire |
|----------|-------------|-------------|
| `SUPABASE_URL` | URL projet Supabase | Oui |
| `SUPABASE_ANON_KEY` | Cle anonyme | Oui |
| `GOOGLE_PLACES_API_KEY` | API Google Places | Oui |
| `AGORA_APP_ID` | ID app Agora | Oui |

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
- Erreur CocoaPods: `cd ios && pod install --repo-update`
- Erreur Google Places: Verifier restrictions API dans Google Cloud Console
- Build iOS fail: `flutter clean && flutter pub get`

### 8. Liens
- Architecture: [ARCHITECTURE.md](./ARCHITECTURE.md)
- Contribution: [CONTRIBUTING.md](./CONTRIBUTING.md)
- Design System: [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md)

---

## Notes Techniques

### Sources d'Information Existantes
- `README.md` actuel (basique)
- `pubspec.yaml` (dependances)
- `docs/PROJECT.md` (etat projet)
- `.env.example` a creer si inexistant

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
