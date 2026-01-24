# Story S40: Custom Code - Video/Media Actions

## Description

En tant que developpeur, je veux migrer les actions video et media de custom_code vers les modules correspondants afin d'eliminer le code legacy.

## Criteres d'Acceptance (Gherkin)

- [ ] Given les actions video dans custom_code When je les migre Then elles sont dans le module video_call

- [ ] Given les actions media (places, etc.) When je les migre Then elles sont dans les modules appropries

- [ ] Given les fonctionnalites When je les teste Then tout fonctionne identiquement

## Fichiers Concernes

### Actions Video a Migrer
```
lib/custom_code/actions/
├── get_agora_token_action.dart           → video_call module
├── agora_toggle_camera.dart              → video_call module
├── agora_toggle_mute.dart                → video_call module
├── agora_switch_camera.dart              → video_call module
├── agora_end_call.dart                   → video_call module
├── start_video_session_action.dart       → video_call module
├── update_video_session_status_action.dart → video_call module
├── handle_video_session_timeout.dart     → video_call module
```

### Actions Media/Misc a Migrer
```
lib/custom_code/actions/
├── pick_local_image.dart                 → core/utils ou features/shared
├── get_place_predictions.dart            → core/services (Google Places)
├── get_place_details.dart                → core/services (Google Places)
├── get_place_details_rich.dart           → core/services (Google Places)
├── check_and_request_permission.dart     → core/services
├── request_app_review.dart               → core/services
├── setup_deeplink_listener.dart          → core/navigation
├── get_initial_deep_link.dart            → core/navigation
├── get_alert_item_details_rpc.dart       → map module
├── fetch_alert_motifs_action.dart        → map module
├── create_professional_alert_action.dart → map module
├── upsert_pro_recent_opt_in.dart         → dashboard module
```

## Notes Techniques

### Video Call Repository
```dart
abstract class VideoCallRepository {
  Future<Result<VideoSession>> createSession({
    required String receiverProfileId,
    required String roomId,
  });

  Future<Result<String>> getAgoraToken(String channelName);

  Future<Result<void>> updateSessionStatus(String sessionId, VideoSessionStatus status);

  Future<Result<void>> endSession(String sessionId);
}

class VideoCallRepositoryImpl implements VideoCallRepository {
  final SupabaseClient _supabase;

  VideoCallRepositoryImpl(this._supabase);

  @override
  Future<Result<VideoSession>> createSession({
    required String receiverProfileId,
    required String roomId,
  }) async {
    try {
      // Call edge function to create session and get token
      final response = await _supabase.functions.invoke(
        'create-video-session',
        body: {
          'receiver_profile_id': receiverProfileId,
          'room_id': roomId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return Success(VideoSession.fromJson(data));
    } catch (e) {
      return Failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> getAgoraToken(String channelName) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-agora-token',
        body: {'channel_name': channelName},
      );

      return Success(response.data['token'] as String);
    } catch (e) {
      return Failure(ServerFailure(e.toString()));
    }
  }
}
```

### Google Places Service
```dart
class GooglePlacesService {
  final String _apiKey;
  final http.Client _client;

  GooglePlacesService({required String apiKey, http.Client? client})
      : _apiKey = apiKey,
        _client = client ?? http.Client();

  Future<List<PlaceSuggestion>> getPlacePredictions(String query) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$query&key=$_apiKey',
    );

    final response = await _client.get(url);
    final data = json.decode(response.body);

    if (data['status'] != 'OK') return [];

    return (data['predictions'] as List)
        .map((p) => PlaceSuggestion.fromJson(p))
        .toList();
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId&key=$_apiKey'
      '&fields=name,formatted_address,geometry',
    );

    final response = await _client.get(url);
    final data = json.decode(response.body);

    if (data['status'] != 'OK') return null;

    return PlaceDetails.fromJson(data['result']);
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({...});
}

class PlaceDetails {
  final String name;
  final String formattedAddress;
  final double lat;
  final double lng;

  const PlaceDetails({...});
}
```

### Permission Service
```dart
class PermissionService {
  Future<bool> checkAndRequestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    final result = await permission.request();
    return result.isGranted;
  }

  Future<bool> requestCameraPermission() =>
      checkAndRequestPermission(Permission.camera);

  Future<bool> requestMicrophonePermission() =>
      checkAndRequestPermission(Permission.microphone);

  Future<bool> requestPhotoLibraryPermission() =>
      checkAndRequestPermission(Permission.photos);

  Future<bool> requestLocationPermission() =>
      checkAndRequestPermission(Permission.location);
}
```

### App Review Service
```dart
class AppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> requestReviewIfAppropriate() async {
    final isAvailable = await _inAppReview.isAvailable();
    if (isAvailable) {
      await _inAppReview.requestReview();
    }
  }
}
```

## Definition of Done

- [ ] Actions video migrees vers video_call module
- [ ] GooglePlacesService cree
- [ ] PermissionService cree
- [ ] AppReviewService cree
- [ ] Deep link actions migrees
- [ ] Tests
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen

## Dependances

- S26 : Video call module
- Map module

## Stories Dependantes

- S41 : FlutterFlow cleanup
