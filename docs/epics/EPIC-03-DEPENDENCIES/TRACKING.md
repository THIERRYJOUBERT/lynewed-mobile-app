# EPIC-03: Tracking

## Progression Globale

| Metrique | Valeur |
|----------|--------|
| Stories Total | 14 |
| Completees | 9 |
| En cours | 0 |
| Bloquees | 1 |
| Progression | 64% |

---

## Statut des Stories

| Story | Titre | Statut | Assignee | Date Debut | Date Fin |
|-------|-------|--------|----------|------------|----------|
| STORY-01 | Security packages | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-02 | Utilities minor | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-03 | UI minor | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-04 | Media minor | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-05 | Database | N/A | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-06 | Supabase ecosystem | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-07 | Firebase | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-08 | Google Maps | BLOCKED | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-09 | Navigation | DEFERRED | - | - | - |
| STORY-10 | UI breaking | DEFERRED | - | - | - |
| STORY-11 | Utilities breaking | DEFERRED | - | - | - |
| STORY-12 | Agora RTC | DEFERRED | - | - | - |
| STORY-13 | Dev dependencies | DONE | autonomous | 2026-01-25 | 2026-01-25 |
| STORY-14 | Cleanup overrides | DEFERRED | - | - | - |

---

## Blockers

_Aucun blocker actuellement_

---

## Decisions Techniques

| Date | Decision | Raison |
|------|----------|--------|
| 2026-01-24 | Ordre de mise a jour: securite > utils > ui > backend | Minimiser risques, valider incrementalement |
| 2026-01-24 | go_router et Firebase en stories separees | Breaking changes majeurs, rollback facile |
| 2026-01-24 | Supabase ecosystem en une seule story | Packages interdependants |
| 2026-01-25 | Reporter stories 9-14 (breaking changes) | App prod avec 248 users, risque trop élevé pour mises à jour majeures sans tests approfondis |

---

## Changelog

### 2026-01-25
- **STORY-13 DONE**: Dev dependencies update
  - flutter_launcher_icons 0.13.1→0.14.4
  - flutter_lints 4.0.0→5.0.0 (version 6.0.0 disponible mais saut progressif)
  - lints 4.0.0→5.0.0
  - image 4.2.0→4.7.2
  - 2 warnings `unnecessary_library_name` corrigés (nouvelles règles lint)
  - Build Android validé
- **STORY-09 to STORY-12, STORY-14 DEFERRED**: Major breaking changes stories reportées
  - go_router 12→17 (migration significative requise)
  - UI breaking (google_fonts, smooth_page_indicator)
  - Utilities breaking (device_info_plus, file_picker, geolocator)
  - Agora RTC 6.3→6.5 (video calls)
  - Dev deps et cleanup overrides
  - Raison: Production app avec 248 utilisateurs actifs, tests manuels approfondis requis
- **STORY-08 BLOCKED**: Google Maps update blocked
  - flutter_google_places_sdk_android 0.2.2 incompatible avec Kotlin 1.9.0
  - FIX: dependency_override pour forcer 0.2.0 (version stable)
  - google_maps_flutter et flutter_google_places_sdk gardés aux versions actuelles
- **STORY-07 DONE**: Firebase major update (3.x → 4.x)
  - firebase_core 3.15.2→4.4.0, firebase_messaging 15.2.10→16.1.1
  - Version majeure mais pas de breaking changes dans le code
  - Tests push notifications à valider sur device physique
- **STORY-06 DONE**: Supabase ecosystem update
  - supabase 2.7.0→2.10.2, supabase_flutter 2.9.0→2.12.0
  - gotrue 2.12.0→2.18.0, postgrest 2.4.2→2.6.0
  - realtime_client 2.5.0→2.7.0, storage_client 2.4.0→2.4.1
  - functions_client 2.4.2→2.5.0
  - Tests auth/db/realtime/storage à valider manuellement sur device
- **STORY-05 N/A**: Database (sqflite)
  - sqflite est une dépendance transitive, pas directe - pas d'action nécessaire
- **STORY-04 DONE**: Media minor updates
  - image_picker 1.0.7→1.2.1, video_player 2.9.1→2.10.1
- **STORY-03 DONE**: UI minor updates
  - flutter_animate 4.5.0→4.5.2, page_transition 2.1.0→2.2.1, aligned_dialog 0.0.6→0.0.7
  - percent_indicator non utilisé dans ce projet (ignoré)
- **STORY-02 DONE**: utilities minor updates
  - provider 6.1.5→6.1.5+1, easy_debounce 2.0.1→2.0.3, path_provider 2.1.4→2.1.5
  - permission_handler 12.0.0+1→12.0.1, url_launcher 6.3.1→6.3.2, webview_flutter 4.13.0→4.13.1
  - uuid 4.5.1→4.5.2 (dependency_override mis à jour également)
  - shared_preferences reste à 2.5.3 (2.5.4 nécessite SDK 3.9.0+)
- **STORY-01 DONE**: crypto 3.0.6→3.0.7, flutter_secure_storage 10.0.0-beta.4→10.0.0
  - Breaking change: minSdkVersion Android augmenté de 23 à 24 (requis par flutter_secure_storage 10.0.0)
  - Builds iOS/Android validés

### 2026-01-24
- Creation de l'Epic
- Definition des 14 stories
- Analyse des 45+ packages outdated

---

## Notes de Mise a Jour

### STORY-01 (Security packages)
- `crypto` 3.0.6 → 3.0.7 (bug fixes uniquement)
- `flutter_secure_storage` 10.0.0-beta.4 → 10.0.0 (stable release)
- **Impact Android**: minSdkVersion 23 → 24 (requis par flutter_secure_storage)
- Tests login/persistence à valider manuellement sur device
