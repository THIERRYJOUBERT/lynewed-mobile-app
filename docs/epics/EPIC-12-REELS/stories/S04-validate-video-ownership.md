# Story S04: Validate Video Ownership

## Description
En tant que **systeme**, je veux **valider que l'utilisateur a le droit d'utiliser les videos selectionnees**, afin de **respecter la decision D-14 (guests peuvent UNIQUEMENT utiliser leurs propres videos)**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Video ownership validation

  Scenario: Guest can only use own videos
    Given a guest with user_id 'guest-123'
    And they own videos [vid-1, vid-2] in guest_media
    And another guest owns video [vid-3]
    When guest-123 tries to create reel with [vid-1, vid-3]
    Then validation should fail
    And error "You can only use your own videos" should appear
    And vid-3 should be flagged as unauthorized

  Scenario: Guest creates reel with own videos successfully
    Given a guest with user_id 'guest-123'
    And they own videos [vid-1, vid-2, vid-3] via guest_media
    When they create a reel with [vid-1, vid-2]
    Then validation should pass
    And reel creation should proceed to CGVU modal

  Scenario: Bride can use own videos
    Given a bride with wedding 'wedding-456'
    And she has videos [vid-1, vid-2] in her album
    When she creates a reel with [vid-1, vid-2]
    Then validation should pass

  Scenario: Bride can use shared guest videos
    Given a bride with wedding 'wedding-456'
    And guest-A has shared videos [vid-3, vid-4] (shared_with_bride = TRUE)
    When bride creates a reel with [vid-1, vid-3, vid-4]
    Then validation should pass
    And reel should proceed with all 3 videos

  Scenario: Bride cannot use unshared guest videos
    Given a bride with wedding 'wedding-456'
    And guest-B has unshared video [vid-5] (shared_with_bride = FALSE)
    When bride tries to include vid-5 in reel
    Then validation should fail
    And error "This video has not been shared with you" should appear
    And vid-5 should be flagged as unauthorized

  Scenario: Server-side validation in Edge Function
    Given a reel creation request with source_media_ids
    When the Edge Function receives the request
    Then it should verify ownership for each video ID
    And reject with 403 Forbidden if any video is unauthorized
    And include list of unauthorized video IDs in response

  Scenario: Client-side pre-validation
    Given the video selection UI
    When videos are displayed
    Then only videos the user can use should be shown
    And no unauthorized videos should appear in the grid

  Scenario: Mixed valid and invalid videos
    Given a guest with owned videos [vid-1, vid-2]
    When they try to submit [vid-1, vid-2, vid-3] (vid-3 not owned)
    Then validation should fail
    And error should specify: "1 video is not authorized: vid-3"
    And the form should highlight vid-3 for removal
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/domain/usecases/validate_video_ownership.dart`
- `lib/features/reels/data/datasources/video_ownership_datasource.dart`
- `supabase/functions/generate-reel/validate_ownership.ts` - Server-side validation module
- `test/features/reels/domain/usecases/validate_video_ownership_test.dart`

### A Modifier
- `lib/features/reels/presentation/providers/video_selection_provider.dart` - Add ownership validation
- `lib/features/reels/data/repositories/reel_repository_impl.dart` - Add validation call

## Notes Techniques

### Ownership Validation Use Case
```dart
// lib/features/reels/domain/usecases/validate_video_ownership.dart

class ValidateVideoOwnershipUseCase {
  final VideoOwnershipDatasource _datasource;

  ValidateVideoOwnershipUseCase(this._datasource);

  /// Validates that the user can use all specified videos
  /// Returns ValidationResult with success/failure and details
  Future<ValidationResult> execute({
    required String userId,
    required String userRole, // 'guest' or 'bride'
    required String weddingId,
    required List<String> mediaIds,
  }) async {
    if (mediaIds.isEmpty) {
      return ValidationResult.failure('No videos selected');
    }

    if (userRole == 'guest') {
      return _validateGuestOwnership(userId, weddingId, mediaIds);
    } else {
      return _validateBrideAccess(userId, weddingId, mediaIds);
    }
  }

  Future<ValidationResult> _validateGuestOwnership(
    String userId,
    String weddingId,
    List<String> mediaIds,
  ) async {
    // Get all videos owned by this guest in this wedding
    final ownedIds = await _datasource.getGuestOwnedVideoIds(
      userId: userId,
      weddingId: weddingId,
    );

    final unauthorized = mediaIds.where((id) => !ownedIds.contains(id)).toList();

    if (unauthorized.isNotEmpty) {
      return ValidationResult.failure(
        'You can only use your own videos',
        unauthorizedIds: unauthorized,
      );
    }

    return ValidationResult.success();
  }

  Future<ValidationResult> _validateBrideAccess(
    String userId,
    String weddingId,
    List<String> mediaIds,
  ) async {
    // Bride can use:
    // 1. Her own videos (album_images)
    // 2. Guest videos shared with her (shared_with_bride = TRUE)
    final accessibleIds = await _datasource.getBrideAccessibleVideoIds(
      brideId: userId,
      weddingId: weddingId,
    );

    final unauthorized = mediaIds.where((id) => !accessibleIds.contains(id)).toList();

    if (unauthorized.isNotEmpty) {
      return ValidationResult.failure(
        'Some videos have not been shared with you',
        unauthorizedIds: unauthorized,
      );
    }

    return ValidationResult.success();
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> unauthorizedIds;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.unauthorizedIds = const [],
  });

  factory ValidationResult.success() => const ValidationResult._(isValid: true);

  factory ValidationResult.failure(String message, {List<String>? unauthorizedIds}) =>
    ValidationResult._(
      isValid: false,
      errorMessage: message,
      unauthorizedIds: unauthorizedIds ?? [],
    );
}
```

### Datasource Implementation
```dart
// lib/features/reels/data/datasources/video_ownership_datasource.dart

class VideoOwnershipDatasource {
  final SupabaseClient _client;

  VideoOwnershipDatasource(this._client);

  /// Get video IDs owned by a guest in a specific wedding
  Future<List<String>> getGuestOwnedVideoIds({
    required String userId,
    required String weddingId,
  }) async {
    // Query: guest_media where album belongs to user in wedding
    final response = await _client
      .from('guest_media')
      .select('id, guest_albums!inner(guest_user_id, wedding_id)')
      .eq('guest_albums.guest_user_id', userId)
      .eq('guest_albums.wedding_id', weddingId)
      .eq('media_type', 'video');

    return (response as List).map((r) => r['id'] as String).toList();
  }

  /// Get video IDs accessible by bride (own + shared by guests)
  Future<List<String>> getBrideAccessibleVideoIds({
    required String brideId,
    required String weddingId,
  }) async {
    // 1. Bride's own videos from album_images
    final ownVideos = await _client
      .from('album_images')
      .select('id, albums!inner(wedding_id, owner_id)')
      .eq('albums.wedding_id', weddingId)
      .eq('albums.owner_id', brideId)
      .eq('media_type', 'video');

    // 2. Guest videos shared with bride
    final sharedVideos = await _client
      .from('guest_media')
      .select('id, guest_albums!inner(wedding_id, shared_with_bride)')
      .eq('guest_albums.wedding_id', weddingId)
      .eq('guest_albums.shared_with_bride', true)
      .eq('media_type', 'video');

    final ownIds = (ownVideos as List).map((r) => r['id'] as String);
    final sharedIds = (sharedVideos as List).map((r) => r['id'] as String);

    return [...ownIds, ...sharedIds];
  }
}
```

### Server-Side Validation (Edge Function)
```typescript
// supabase/functions/generate-reel/validate_ownership.ts

interface OwnershipValidation {
  isValid: boolean;
  unauthorizedIds: string[];
  error?: string;
}

export async function validateOwnership(
  supabase: SupabaseClient,
  userId: string,
  userRole: 'guest' | 'bride',
  weddingId: string,
  mediaIds: string[]
): Promise<OwnershipValidation> {
  if (userRole === 'guest') {
    // Query guest_media for owned videos
    const { data: owned } = await supabase
      .from('guest_media')
      .select('id, guest_albums!inner(guest_user_id)')
      .in('id', mediaIds)
      .eq('guest_albums.guest_user_id', userId);

    const ownedIds = new Set(owned?.map(r => r.id) || []);
    const unauthorized = mediaIds.filter(id => !ownedIds.has(id));

    return {
      isValid: unauthorized.length === 0,
      unauthorizedIds: unauthorized,
      error: unauthorized.length > 0 ? 'Guest can only use own videos' : undefined,
    };
  }

  // Bride validation - own + shared
  // Similar logic for bride...
  return { isValid: true, unauthorizedIds: [] };
}
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Tests unitaires ValidateVideoOwnershipUseCase
- [ ] Tests pour guest ownership (own only)
- [ ] Tests pour bride access (own + shared)
- [ ] Tests pour mixed valid/invalid
- [ ] Client-side validation integrated
- [ ] Server-side validation in Edge Function
- [ ] Clear error messages with video IDs
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (security-critical, D-14 compliance)

## Dependances
- S03: Video selection UI (provides selected video IDs)
- EPIC-10: guest_media and guest_albums tables must exist

## Stories Dependantes
- S06: Edge Function (calls ownership validation before processing)
