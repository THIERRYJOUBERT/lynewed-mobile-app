# EPIC-03: Mise a Jour des Dependances

## Vue d'ensemble

**Objectif**: Mettre a jour l'ensemble des dependances du projet Lynewed de maniere securisee et incrementale, sans impacter l'application en production.

**Contexte**:
- 45+ dependances directes identifiees comme outdated
- Application en production sur iOS et Android
- Backend Supabase avec ecosysteme complet (gotrue, postgrest, realtime, storage, functions)
- Integrations critiques: Firebase, Google Maps, Agora RTC

---

## Analyse des Risques

### Risques Majeurs

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Breaking changes Supabase | Auth/Data corrompus | Mise a jour incrementale + tests exhaustifs |
| Incompatibilite Firebase | Push notifications cassees | Tester sur device physique |
| Regression Google Maps | Fonctionnalite carte KO | Verifier SDK natifs iOS/Android |
| Agora RTC breaking | Video calls KO | Version majeure = story dediee |

### Contraintes

- **JAMAIS** mettre a jour tous les packages d'un coup
- **TOUJOURS** verifier les changelogs avant mise a jour
- **TOUJOURS** tester sur device physique pour Firebase/Maps
- Rollback possible a chaque etape

---

## Strategie de Mise a Jour

### Ordre de Priorite

1. **Packages de securite** (crypto, flutter_secure_storage)
2. **Ecosysteme Supabase** (interdependances fortes)
3. **Firebase** (notifications push critiques)
4. **Google Maps & Places** (natifs iOS/Android)
5. **UI/UX packages** (risque faible)
6. **Utilities** (risque faible)
7. **Dev dependencies** (build-time only)

### Methode par Story

```
1. Lire changelog officiel
2. Identifier breaking changes
3. Mettre a jour pubspec.yaml
4. flutter pub get
5. flutter analyze
6. flutter build ios / android
7. Test manuel des fonctionnalites impactees
8. Commit ou Rollback
```

---

## Packages a Mettre a Jour

### Securite & Stockage

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| crypto | 3.0.6 | 3.0.7 | Non |
| flutter_secure_storage | 10.0.0-beta.4 | 10.0.0 | Mineur (stable release) |

### Ecosysteme Supabase

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| supabase_flutter | 2.9.0 | 2.12.0 | Potentiel |
| supabase | 2.7.0 | 2.10.2 | Potentiel |
| gotrue | 2.12.0 | 2.18.0 | **OUI** - Auth API changes |
| postgrest | 2.4.2 | 2.6.0 | Potentiel |
| realtime_client | 2.5.0 | 2.7.0 | Potentiel |
| storage_client | 2.4.0 | 2.4.1 | Non |
| functions_client | 2.4.2 | 2.5.0 | Non |

### Firebase

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| firebase_core | 3.15.2 | 4.4.0 | **OUI** - Version majeure |
| firebase_messaging | 15.2.10 | 16.1.1 | **OUI** - Version majeure |

### Google Maps & Location

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| google_maps_flutter | 2.13.1 | 2.14.0 | Mineur |
| flutter_google_places_sdk | 0.4.2+1 | 0.4.3 | Non |
| geolocator | 14.0.2 (latest) | - | Deja a jour |

### Navigation

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| go_router | 12.1.3 | 17.0.1 | **OUI** - Version majeure |
| app_links | 6.3.2 | 7.0.0 | **OUI** - Version majeure |

### UI/UX

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| flutter_animate | 4.5.0 | 4.5.2 | Non |
| google_fonts | 6.1.0 | 8.0.0 | **OUI** - Version majeure |
| font_awesome_flutter | 10.7.0 | 10.12.0 | Mineur |
| smooth_page_indicator | 1.1.0 | 2.0.1 | **OUI** - Version majeure |
| page_transition | 2.1.0 | 2.2.1 | Mineur |
| percent_indicator | 4.2.2 | 4.2.5 | Non |
| aligned_dialog | 0.0.6 | 0.0.7 | Non |

### Images & Media

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| image_picker | 1.2.0 | 1.2.1 | Non |
| video_player | 2.10.0 | 2.10.1 | Non |
| file_picker | 8.3.7 | 10.3.8 | **OUI** - Version majeure |

### Utilities

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| path_provider | 2.1.4 | 2.1.5 | Non |
| url_launcher | 6.3.1 | 6.3.2 | Non |
| webview_flutter | 4.13.0 | 4.13.1 | Non |
| shared_preferences | 2.5.3 | 2.5.4 | Non |
| sqflite | 2.3.3+1 | 2.4.2 | Mineur |
| sqflite_common | 2.5.4+3 | 2.5.6 | Non |
| device_info_plus | 11.5.0 | 12.3.0 | **OUI** - Version majeure |
| permission_handler | 12.0.0+1 | 12.0.1 | Non |
| provider | 6.1.5 | 6.1.5+1 | Non |
| json_path | 0.7.2 | 0.9.0 | **OUI** |
| easy_debounce | 2.0.1 | 2.0.3 | Non |
| flutter_dotenv | 5.2.1 | 6.0.0 | **OUI** - Version majeure |
| uuid | 4.5.1 | 4.5.2 | Non |

### Real-time & Video

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| agora_rtc_engine | 6.3.2 | 6.5.3 | Mineur |

### Dev Dependencies

| Package | Actuel | Cible | Breaking Changes |
|---------|--------|-------|------------------|
| flutter_launcher_icons | 0.13.1 | 0.14.4 | Mineur |
| flutter_lints | 4.0.0 | 6.0.0 | **OUI** - Nouvelles regles |
| lints | 4.0.0 | 6.0.0 | **OUI** |
| image | 4.2.0 | 4.7.2 | Mineur |

---

## Stories

### Phase 1: Securite & Stockage (Risque faible)
- [STORY-01](stories/STORY-01-SECURITY.md): Mettre a jour crypto et flutter_secure_storage

### Phase 2: Utilities Low-Risk (Risque faible)
- [STORY-02](stories/STORY-02-UTILITIES-MINOR.md): Mettre a jour path_provider, url_launcher, webview_flutter, shared_preferences, permission_handler, provider, easy_debounce, uuid

### Phase 3: UI/UX Minor Updates (Risque faible)
- [STORY-03](stories/STORY-03-UI-MINOR.md): Mettre a jour flutter_animate, percent_indicator, aligned_dialog, page_transition

### Phase 4: Images & Media (Risque faible)
- [STORY-04](stories/STORY-04-MEDIA-MINOR.md): Mettre a jour image_picker, video_player

### Phase 5: Database (Risque moyen)
- [STORY-05](stories/STORY-05-DATABASE.md): Mettre a jour sqflite et sqflite_common

### Phase 6: Supabase Ecosystem (Risque moyen-haut)
- [STORY-06](stories/STORY-06-SUPABASE.md): Mettre a jour l'ecosysteme Supabase complet

### Phase 7: Firebase (Risque haut)
- [STORY-07](stories/STORY-07-FIREBASE.md): Mettre a jour Firebase core et messaging (version majeure)

### Phase 8: Google Maps (Risque moyen)
- [STORY-08](stories/STORY-08-GOOGLE-MAPS.md): Mettre a jour google_maps_flutter et flutter_google_places_sdk

### Phase 9: Navigation (Risque haut)
- [STORY-09](stories/STORY-09-NAVIGATION.md): Mettre a jour go_router et app_links (versions majeures)

### Phase 10: UI Breaking Changes (Risque moyen)
- [STORY-10](stories/STORY-10-UI-BREAKING.md): Mettre a jour google_fonts, font_awesome_flutter, smooth_page_indicator

### Phase 11: Utilities Breaking Changes (Risque moyen)
- [STORY-11](stories/STORY-11-UTILITIES-BREAKING.md): Mettre a jour device_info_plus, flutter_dotenv, json_path, file_picker

### Phase 12: Agora RTC (Risque moyen)
- [STORY-12](stories/STORY-12-AGORA.md): Mettre a jour agora_rtc_engine

### Phase 13: Dev Dependencies (Risque faible)
- [STORY-13](stories/STORY-13-DEV-DEPS.md): Mettre a jour flutter_launcher_icons, flutter_lints, lints, image

### Phase 14: Cleanup Dependency Overrides (Risque moyen)
- [STORY-14](stories/STORY-14-CLEANUP-OVERRIDES.md): Supprimer les dependency_overrides obsoletes

---

## Definition of Done (Epic)

- [ ] Tous les packages outdated sont mis a jour
- [ ] Aucun dependency_override n'est necessaire
- [ ] `flutter analyze` passe sans warnings
- [ ] App compile sur iOS et Android
- [ ] Tests manuels passes sur les fonctionnalites critiques:
  - [ ] Authentification (Supabase/Apple Sign-In)
  - [ ] Push notifications (Firebase)
  - [ ] Carte et recherche de lieux (Google Maps)
  - [ ] Appels video (Agora)
  - [ ] Navigation et deep links
- [ ] Pas de regression sur l'UX

---

## Estimation

| Phase | Stories | Effort estime |
|-------|---------|---------------|
| 1-4 (Low risk) | 4 | 1 jour |
| 5-8 (Medium risk) | 4 | 2 jours |
| 9-11 (High risk) | 3 | 2-3 jours |
| 12-14 (Cleanup) | 3 | 1 jour |
| **Total** | **14** | **6-7 jours** |

---

## Notes

- Les dependency_overrides actuelles (http, rxdart, uuid) devront etre revisitees apres mise a jour de Supabase
- go_router 17.x est un saut majeur depuis 12.x - prevoir temps pour migration
- Firebase 4.x necessite potentiellement mise a jour des fichiers natifs iOS/Android
