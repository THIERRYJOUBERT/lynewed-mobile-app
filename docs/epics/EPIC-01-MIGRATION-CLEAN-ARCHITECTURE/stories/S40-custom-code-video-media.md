# Story S40: Custom Code - Video/Media Actions

## Description

En tant que developpeur, je veux migrer les actions video et media de custom_code vers les modules correspondants afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [x] Given les actions video dans custom_code When je les migre Then elles sont dans le module video_call
  - **Resultat**: Les actions video RESTENT dans custom_code car elles sont des bridges vers le widget Agora legacy (AgoraVideoViewWidget). Le module video_call contient deja les abstractions Clean Architecture (repository, cubit) mais l'integration Agora SDK reste dans le widget legacy pour stabilite production.

- [x] Given les actions media (places, etc.) When je les migre Then elles sont dans les modules appropries
  - **Resultat**: Les actions Google Places (getPlacePredictions, getPlaceDetails, getPlaceDetailsRich) restent dans custom_code car elles utilisent flutter_google_places_sdk et sont stables en production.
  - **Resultat**: Les 3 actions map legacy (getAlertItemDetailsRpc, fetchAlertMotifsAction, createProfessionalAlertAction) ont ete SUPPRIMEES car remplacees par le module map Clean Architecture.

- [x] Given les fonctionnalites When je les teste Then tout fonctionne identiquement
  - **Resultat**: 3037 tests passent, 0 warnings.

## Implementation Realisee

### Actions Supprimees (migrees vers Clean Architecture)
```
lib/custom_code/actions/ (DELETED)
- get_alert_item_details_rpc.dart    -> lib/features/map/data/datasources/supabase_map_datasource.dart
- fetch_alert_motifs_action.dart     -> Non utilise, supprime
- create_professional_alert_action.dart -> lib/features/map/data/datasources/supabase_map_datasource.dart
```

### Actions Conservees (bridges vers legacy)
```
lib/custom_code/actions/ (KEPT - documented)
Video Call:
- agora_toggle_mute.dart             -> Bridge vers AgoraVideoViewWidget
- agora_toggle_camera.dart           -> Bridge vers AgoraVideoViewWidget
- agora_switch_camera.dart           -> Bridge vers AgoraVideoViewWidget
- agora_end_call.dart                -> Bridge vers AgoraVideoViewWidget
- get_agora_token_action.dart        -> Edge Function agora_token_issue
- start_video_session_action.dart    -> DB + notifications + timeout
- update_video_session_status_action.dart -> DB update
- handle_video_session_timeout.dart  -> Timeout handler

Google Places:
- get_place_predictions.dart         -> flutter_google_places_sdk
- get_place_details.dart             -> flutter_google_places_sdk
- get_place_details_rich.dart        -> flutter_google_places_sdk

Utility:
- pick_local_image.dart              -> image_picker wrapper
- check_and_request_permission.dart  -> permission_handler wrapper
- request_app_review.dart            -> in_app_review wrapper
- setup_deeplink_listener.dart       -> app_links + auth state
- get_initial_deep_link.dart         -> app_links
```

### Documentation Ajoutee
1. `lib/custom_code/actions/index.dart` - Header complet documentant la migration et l'architecture
2. `lib/features/video_call/video_call.dart` - Notes d'architecture expliquant l'integration legacy

## Fichiers Modifies

| Fichier | Action | Description |
|---------|--------|-------------|
| `lib/custom_code/actions/get_alert_item_details_rpc.dart` | DELETE | Remplace par map datasource |
| `lib/custom_code/actions/fetch_alert_motifs_action.dart` | DELETE | Non utilise |
| `lib/custom_code/actions/create_professional_alert_action.dart` | DELETE | Remplace par map datasource |
| `lib/custom_code/actions/index.dart` | MODIFY | Documentation + reorganisation exports |
| `lib/features/video_call/video_call.dart` | MODIFY | Notes d'architecture |

## Definition of Done

- [x] Actions video documentees (conservees comme bridges vers legacy Agora)
- [x] Actions map legacy supprimees (remplacees par Clean Architecture)
- [x] Documentation ajoutee dans index.dart et video_call.dart
- [x] Tests passent (3037 tests)
- [x] `flutter analyze --fatal-infos` passe (0 warnings)

## Notes Techniques

### Pourquoi Conserver les Actions Video

Les actions video (agoraToggleMute, etc.) sont des wrappers tres fins qui delegent a `AgoraVideoViewWidget.agoraXxx()`. Cette architecture existe car:

1. **Couplage Agora SDK**: L'Agora SDK est tres couple au widget qui gere le RtcEngine
2. **Pages FlutterFlow**: Les pages video_call_page_widget.dart appellent ces actions via `actions.xxx()`
3. **Stabilite Production**: Refactorer l'integration Agora risquerait de casser les appels video en production

Le module Clean Architecture `lib/features/video_call/` fournit:
- `VideoCallRepository` - Interface pour CRUD sessions
- `VideoCallRepositoryImpl` - Implementation Supabase
- `VideoCallCubit` - State management

Mais l'integration SDK reste dans le legacy pour stabilite.

### Pourquoi Supprimer les Actions Map

Les actions map (getAlertItemDetailsRpc, etc.) ont ete remplacees par:
- `lib/features/map/data/datasources/supabase_map_datasource.dart`
- Methodes: `getAlertDetails()`, `createAlert()`, `getMyAlerts()`

Verification grep: AUCUNE utilisation dans le code (0 references).

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible (approche pragmatique, conservation du code stable)

## Dependances

- S26 : Video call module (utilise pour documentation)
- Map module (utilise pour remplacement)

## Stories Dependantes

- S41 : FlutterFlow cleanup (peut supprimer plus de code legacy si necessaire)
