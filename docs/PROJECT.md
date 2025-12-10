# LYNEWED PROJECT - V1 IN PRODUCTION 🚀

**Version:** v2.0.0  
**Last Updated:** 2025-12-10  
**Status:** 🚀 **V1 IN PRODUCTION** - Active users on App Store

---

## 📊 Project Overview

### GitHub Branch Structure
| Branch | Role | Status |
|--------|------|--------|
| `main` | Production release | 🚀 V1 deployed |
| `develop` | Development | 🔧 New features |

**Workflow**: `develop` → PR → `main` pour production releases

### Supabase Architecture
| Environment | Project ID | Branch | Usage |
|-------------|------------|--------|-------|
| **PRODUCTION** | `hekyovgnovhfhmkpfrna` | `main` | 🚀 Live users - **NEVER modify directly** |
| **DEVELOPMENT** | `hazegrtuypjvfwbsrcoc` | `dev` | 🔧 New features - **Default for all changes** |

**⚠️ Projet `odzkhcplevcqbuhzqsmq` (Tom Leo App Lynewed) - À SUPPRIMER**

### V1 Accomplishments
- ✅ **Complete FlutterFlow removal** - 100% autonomous code
- ✅ **Clean Architecture** - domain/data/presentation separation
- ✅ **Unified Design System** - `lib/core/design/`
- ✅ **Module Map** - 100% complete (63 tests passing)
- ✅ **Module Chat** - 100% complete with moderation
- ✅ **Notifications System** - 7/7 types functional
- ✅ **Feed MVP** - Market segmentation IN/GLOBAL
- ✅ **Images V2** - Multi-format (1:1, 3:4, 9:16)
- ✅ **Security** - RLS, secrets, API key restrictions
- ✅ **Cleanup** - 135 files deleted, 40,588 lines removed

### Key Metrics
| Metric | Value |
|--------|-------|
| Codebase | ~71,500 lines Dart |
| Files | ~400 Dart files |
| Architecture | Clean Architecture |
| Completed Modules | Design System, Map, Chat, Notifications, Feed |
| SQL Migrations | 58 applied |
| Map Tests | 63/63 passing |
| External APIs | 4 certified (Supabase, Google Places, Agora, FCM) |
| Flutter Analyze | 306 issues (vs 523 before = -42%) |

---

## 🏗️ Architecture

### Completed Modules

```
lib/
├── core/                    # Shared code (~4,500 lines)
│   ├── design/              # Unified Design System (22 files)
│   ├── constants/           # App constants
│   ├── services/            # Shared services
│   └── utils/               # Utilities
│
├── features/                # Clean Architecture modules (~21,000 lines)
│   ├── map/                 # Map module (37 files, ~4,200 lines)
│   ├── chat/                # Chat module (45 files, ~8,500 lines)
│   ├── notifications/       # Notifications (5 files, ~1,200 lines)
│   └── dashboard/           # Dashboard module
│
├── pages/                   # Legacy pages (migration in progress)
├── custom_code/             # Custom actions and widgets
└── backend/                 # Supabase schema
```

### Design System V4
- **Location:** `lib/core/design/`
- **Documentation:** `docs/App/DESIGN_SYSTEM.md` (1041 lines - authoritative reference)
- **Import:** `import '/core/design/design.dart';`
- **Tokens:** Colors, Typography, Spacing, Borders, Component Styles
- **Font:** Haas Grot Text Trial
- **Buttons:** 48px height, 0 radius, **w400** text
- **Sheets:** 24px top radius, 20px horizontal padding
- **Items:** 4px radius
- **Spacing:** 30px inter-section, 10px label→content
- **Weight Rules:** w300 (inputs), w400 (default), w500 (max - titles only)

### Validated Integrations
| Service | Version | Status |
|---------|---------|--------|
| Supabase | PostgreSQL + PostGIS + RLS | ✅ Certified |
| Google Places SDK | 0.4.2+1 | ✅ Certified |
| Agora Video | Token generation | ✅ Certified |
| Firebase FCM | Push notifications | ✅ Certified |
| Resend Email | Transactional | ✅ Configured |

---

## 📁 Documentation Structure

```
docs/
├── PROJECT.md                      # This file - project state
├── PROJECT_TODO.md                 # Future tasks and ideas
├── App/
│   ├── DESIGN_SYSTEM.md            # ⭐ Design System V4 (authoritative)
│   ├── APP_SOURCE_OF_TRUTH.md      # Application flows and guidelines
│   └── ENUMS.md                    # All enums reference
├── audits/                         # Technical audits
└── archive/                        # Historical documentation
```

### Key Documentation
| Document | Purpose |
|----------|---------|
| `docs/App/DESIGN_SYSTEM.md` | **Primary UI reference** - All tokens, widgets, patterns |
| `docs/App/APP_SOURCE_OF_TRUTH.md` | Application flows, bugs, testing |
| `lib/features/map/README.md` | Map module architecture |

---

## 🎯 Next Priorities

| Priority | Task | Description |
|----------|------|-------------|
| 1 | **TestFlight** | Prepare and deploy beta |
| 2 | **ProDetails** | Complete refactoring with Images V2 |
| 3 | **Auth Module** | Clean Architecture refactoring |
| 4 | **Profile Pages** | Refactoring |
| 5 | **Performance** | Cache, images, lazy loading |

---

## 🔧 Development Workflow

1. **Start task:** Read `PROJECT.md` + `PROJECT_TODO.md`
2. **New screen:** Follow `docs/App/DESIGN_SYSTEM.md` (authoritative reference)
3. **New module:** Follow pattern in `lib/features/map/`
4. **Commit:** Use `/commit-github-develop` workflow

### Rules
- ❌ **NEVER** reuse FlutterFlow components
- ❌ **NEVER** use fontWeight > w500
- ✅ **ALWAYS** create new components in `lib/features/` or `lib/core/`
- ✅ **ALWAYS** apply Design System (`import '/core/design/design.dart';`)
- ✅ **ALWAYS** follow Clean Architecture patterns
- ✅ **ALWAYS** use 30px inter-section spacing, 10px label→content

---

**Last Updated:** 2025-12-08  
**Status:** ✅ V1 Complete - Environment cleaned and ready for next development phase
