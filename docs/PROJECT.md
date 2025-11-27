# LYNEWED PROJECT - State & Architecture

**Version:** v1.1.1+59  
**Branch:** develop  
**Last Updated:** 2025-11-27  
**Environment:** Development (hekyovgnovhfhmkpfrna)  

---

## 📊 Project Overview (200-300 lines)

### Branch Structure
- `main`: MVP v1.1.1+59 (App Store) - protected
- `develop`: Active development for v2.0.0 refactoring

**Workflow**: All development and testing happens in `develop` → When ready, merge to `main` for production releases

### Current Status
- ✅ Environment secured and functional
- ✅ Authentication working (login/signup)
- ✅ Database permissions fixed
- ✅ Data seeding completed (40 users with full relationships)
- ✅ Documentation reorganized and updated
- ✅ Design System unified and implemented (Phase 0 completed)
- ⚠️ Map refactorisation: Backend OK, UI/UX corrections in progress
- 🔄 Phase 1: Layout Map Restoration (active work)

### Key Metrics
- **Codebase**: ~15,000+ lines of Dart code
- **Architecture**: Clean Architecture pattern adopted
- **Modules**: Design System completed, Map module in progress
- **Database**: 52 migrations applied, 40 users seeded
- **APIs**: 4 external services certified (Agora, FCM, Resend, Google Places)
- **Tests**: 63/63 unit tests passing for map module

---

## 🏗️ Architecture Technique (100 lines)

### Completed Modules
- ✅ **Design System** (`lib/core/design/`) - Unified visual identity
  - 9 token files (colors, typography, spacing, borders, components)
  - API mirroring FlutterFlowTheme for seamless migration
  - Complete documentation at `docs/App/DESIGN_SYSTEM.md`

- ✅ **Authentication** (`lib/auth/supabase_auth/`) - Fixed and functional
- ✅ **Backend Integration** - Supabase schema validated
- 🔄 **Map Module** (`lib/features/map/`) - Clean Architecture implemented
  - ~3400 lines of clean, testable code
  - 100% autonomous from FlutterFlow dependencies
  - Navigation migrated, legacy code archived

### Architecture Patterns
- **Clean Architecture**: domain/data/presentation layers
- **Dependency Injection**: Service providers pattern
- **State Management**: BLoC/Cubit pattern for business logic
- **Testing**: Unit tests with mocks, 100% coverage for core logic

### Validated Integrations
- **Supabase**: PostgreSQL + PostGIS + RLS + Edge Functions
- **Google Places SDK**: v0.4.2+1 with API key security
- **Agora Video**: Token generation and video calls
- **Firebase FCM**: Push notifications infrastructure
- **Resend Email**: Transactional emails

---

## 📈 Progression (50 lines)

### Timeline Real vs Estimated
- **Design System Phase 0**: Completed in 4 hours (estimated 2-3h)
- **Map Module Phases 1-5**: Completed in ~40 hours (estimated 35-45h)
- **Backend Validation**: 100% compatible, 44ms response times
- **Current Work**: UI/UX corrections (Phase 1 of correction plan)

### Key Lessons Learned
1. **Clean Architecture**: Eliminates FlutterFlow technical debt effectively
2. **Design System**: Critical for UI consistency across refactored modules
3. **Testing**: Essential for maintaining functionality during refactoring
4. **Performance**: PostGIS queries optimized with proper indexing

### Critical Architectural Decisions
1. **Complete Rewrite**: Better than patching FlutterFlow code
2. **Module Autonomy**: Each feature independent and testable
3. **Legacy Archive**: Preserve old code for reference during migration
4. **API Compatibility**: Maintain existing Supabase contracts

---

## 🔗 Références (20 lines)

### Primary References
- **Future Tasks & Ideas**: `PROJECT_TODO.md` - Detailed thoughts and improvements
- **Current Map Work**: `MAP_REFACTORING.md` - Active corrections and context
- **Technical Knowledge Base**: `audits/MAP_FEATURE_AUDIT.md` - Complete technical documentation
- **Design System**: `docs/App/DESIGN_SYSTEM.md` - UI/UX guidelines and tokens

### Development Workflow
1. **Starting Any Task**: Read PROJECT.md + PROJECT_TODO.md
2. **Creating Screens**: Reference Design System documentation
3. **Map Development**: Consult MAP_REFACTORING.md for current work
4. **Technical Details**: Use `audits/MAP_FEATURE_AUDIT.md` for deep technical reference

### Next Immediate Priorities
1. **Phase 1**: Complete Map Layout Restoration (UI/UX corrections)
2. **Phase 2**: Map Filters correction and functionality
3. **Phase 3**: Markers styling (avatar circles for pros)
4. **Future**: Begin next module refactoring (auth/chat)

---

**Last Updated**: 2025-11-27  
**Status**: Phase 0 Design System Completed, Phase 1 Map Corrections In Progress  
**Next Milestone**: Map Module UI/UX Validation
