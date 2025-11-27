# Lynewed Mobile App

Application Flutter de mise en relation pour les mariages avec architecture Clean Architecture et Design System unifié.

## 🚀 Démarrage rapide

Voir le guide d'installation complet : **[guides/technical_specification.md](guides/technical_specification.md)**

## 📁 Structure du projet

```
├── docs/                    # Documentation spécialisée
│   ├── PROJECT.md           # État condensé du projet
│   ├── PROJECT_TODO.md      # Idées et tâches futures
│   ├── MAP_REFACTORING.md   # Travail actuel module map
│   ├── App/                 # Documentation app
│   │   ├── DESIGN_SYSTEM.md # Design System unifié
│   │   ├── APP_SOURCE_OF_TRUTH.md
│   │   └── ENUMS.md
│   ├── USERS/               # Données utilisateurs et tests
│   └── audits/              # Références techniques
│       └── MAP_FEATURE_AUDIT.md
├── lib/                     # Code source Flutter
│   ├── core/                # Code partagé
│   │   └── design/          # Design System unifié ✨
│   └── features/            # modules Clean Architecture
│       └── map/             # Module map (refactorisation)
├── guides/                  # Guides techniques
│   ├── BUILD_IPA_GUIDE.md   # Build iOS production
│   └── technical_specification.md
├── scripts/                 # Scripts utilitaires
│   ├── check_config.sh      # Vérification configuration
│   ├── build_and_run.sh     # Build automatique
│   └── install_simulator.sh
├── assets/                  # Ressources
└── supabase/               # Backend Supabase
    ├── migrations/          # Migrations base de données
    └── functions/           # Edge Functions
```

## 🛠️ Scripts utiles

```bash
# Vérifier la configuration du projet
./scripts/check_config.sh

# Builder et lancer sur simulateur
./scripts/build_and_run.sh

# Installer un simulateur iOS
./scripts/install_simulator.sh
```

## 📚 Documentation

### Documentation principale
- **État du projet** : [docs/PROJECT.md](docs/PROJECT.md) - Vue d'ensemble condensée
- **Tâches futures** : [docs/PROJECT_TODO.md](docs/PROJECT_TODO.md) - Idées et roadmap
- **Travail en cours** : [docs/MAP_REFACTORING.md](docs/MAP_REFACTORING.md) - Refactorisation module map

### Documentation applicative
- **Design System** : [docs/App/DESIGN_SYSTEM.md](docs/App/DESIGN_SYSTEM.md) - Tokens et composants unifiés
- **Source de vérité** : [docs/App/APP_SOURCE_OF_TRUTH.md](docs/App/APP_SOURCE_OF_TRUTH.md) - Architecture complète
- **Énumérations** : [docs/App/ENUMS.md](docs/App/ENUMS.md) - Valeurs des enums

### Documentation technique
- **Build iOS** : [guides/BUILD_IPA_GUIDE.md](guides/BUILD_IPA_GUIDE.md)
- **Spécifications** : [guides/technical_specification.md](guides/technical_specification.md)
- **Audit module map** : [docs/audits/MAP_FEATURE_AUDIT.md](docs/audits/MAP_FEATURE_AUDIT.md)

### Architecture
- **Clean Architecture** : `lib/features/` - Modules organisés en domain/data/presentation
- **Design System** : `lib/core/design/` - Tokens et styles unifiés
- **Backend** : Supabase avec migrations et Edge Functions

---
**Version** : v1.2.0+100 | **Flutter** : 3.32.4 | **Platformes** : iOS/Android | **Architecture** : Clean Architecture + Design System
