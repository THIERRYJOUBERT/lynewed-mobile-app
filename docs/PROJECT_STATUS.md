# Project Status - Lynewed Mobile App

**Current Version:** v1.1.1+59  
**Current Branch:** develop  
**Last Updated:** 2025-11-24  
**Environment:** Development (refactoring v2.0.0)

---

## Current State

### Branch Structure
- `main`: MVP v1.1.1+59 (App Store) - protected
- `release/v1.x`: Hotfix branch for v1.x maintenance
- `develop`: Active development for v2.0.0 refactoring

### Recent Commits
- `0992be1` (main): chore: backup MVP v1.1.1+59 - stable App Store version
- `d7202bd` (develop): docs: update PROJECT_STATUS.md with GitHub branching structure
- `04eb024` (release/v1.x): docs: finalize GitHub branching structure with hotfix support

### File Map (Key Directories)
```
lib/
├── auth/                    # Authentication layer
├── backend/                 # Backend integration
│   ├── schema/             # Data models (40+ structs)
│   └── supabase/           # Database queries
├── pages/                  # Screens (71 items)
├── compo_finaux/           # Final UI components
├── custom_code/            # Custom actions (96+)
└── services/               # External services (Agora, etc.)

supabase/
├── functions/              # Edge functions (15 deployed)
└── migrations/             # Database migrations (51 applied)
```

---

## Change Log

### 2025-11-24 - Final Project Cleanup & IDE Artifacts Removal
- Removed auto-generated build artifacts: build/, .dart_tool/, .flutter-plugins-dependencies*
- Removed IDE artifacts: .idea/ folder, *.iml files (already gitignored but present)
- Removed obsolete test file: test/widget_test.dart (generic boilerplate)
- Confirmed .gitignore properly excludes all IDE and build artifacts
- Final project structure: clean root with organized docs/, guides/, scripts/ folders
- Total space recovered: ~500MB+ (build cache + IDE artifacts)
- All scripts updated with correct paths after folder reorganization

### 2025-11-24 - Project File Organization & Cleanup
- Created organized folder structure: docs/, guides/, scripts/
- Moved documentation: SETUP.md, PROJECT_STATUS.md → docs/
- Moved technical guides: BUILD_IPA_GUIDE.md, technical_specification.md → guides/
- Moved utility scripts: check_config.sh, build_and_run.sh, install_simulator.sh → scripts/
- Fixed script paths after folder reorganization (build_and_run.sh, check_config.sh)
- Removed obsolete files: README.md (generic), AGORA_PRODUCTION_READY.md, configure_notification_secrets.sh, run_ios.sh, production_schema_clean.sql
- Created new README.md with proper navigation and project structure
- Maintained root-level config files required by Flutter tooling

### 2025-11-24 - Supabase Environment Duplication Completed
- Successfully duplicated complete Supabase environment from production (odzkhcplevcqbuhzqsmq) to v1 (hekyovgnovhfhmkpfrna)
- Used Docker pg_dump/psql approach with Session Pooler connection
- Transferred 36+ tables with RLS enabled, all custom types, functions, and extensions
- Verified 0 user data rows (clean schema duplication only)
- All critical functions confirmed: claim_outbox_events, cleanup_old_notifications, get_tier_of
- Project hekyovgnovhfhmkpfrna ready for v1 development

### 2025-11-24 - Repository Restructuring
- Created GitHub branching structure (main/release/develop)
- Tagged MVP v1.1.1+59 for App Store reference
- Set up isolated hotfix workflow
- Cleaned PROJECT_STATUS.md for state tracking only

### Previous Changes (See technical_specification.md)
- Security improvements (v1.1.0)
- FlutterFlow code cleanup
- Performance optimizations

---

## Known Issues
- None critical

## Next Actions
- [x] **COMPLETED**: Duplicate Supabase environment from production (odzkhcplevcqbuhzqsmq) to v1 (hekyovgnovhfhmkpfrna)
- [ ] Begin FlutterFlow → Flutter refactoring
- [ ] Implement clean architecture layers
- [ ] Add unit test coverage
- [ ] Performance optimization pass

---

## Tags
- `v1.1.1+59`: MVP stable (App Store)
