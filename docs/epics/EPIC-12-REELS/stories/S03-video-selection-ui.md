# Story S03: Implement Video Selection UI

## Description
En tant que **utilisateur (guest ou bride)**, je veux **selectionner les videos a inclure dans mon reel**, afin de **creer un montage personnalise avec mes moments preferes**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Video selection UI for reels

  Scenario: Display available videos
    Given a user with 5 videos in their gallery
    When they open the reel creation screen
    Then they should see all 5 videos in a responsive grid
    And each video should show:
      | element      | description                    |
      | thumbnail    | first frame or generated thumb |
      | duration     | formatted as "MM:SS"           |
      | checkbox     | selection state indicator      |
    And videos should be sorted by date (newest first)

  Scenario: Select videos with counter
    Given a user viewing video selection
    When they tap on a video thumbnail
    Then the video should be marked as selected (checkbox checked)
    And the counter should update (e.g., "1/10")
    And the video should show a selection order number

  Scenario: Maximum 10 videos limit
    Given a user has already selected 10 videos
    When they try to select an 11th video
    Then selection should be blocked
    And a snackbar should show "Maximum 10 videos reached"
    And the 11th video should remain unselected

  Scenario: Deselect videos
    Given videos A, B, C are selected (order 1, 2, 3)
    When user taps on video B to deselect
    Then video B should be unselected
    And counter should update to "2/10"
    And order numbers should recompute (A=1, C=2)

  Scenario: Validate individual video duration
    Given a video with duration 150 seconds (2.5 min)
    When the user tries to select it
    Then selection should be blocked
    And snackbar "Video exceeds 2 minute limit" should appear
    And video should show a warning icon/overlay

  Scenario: Validate total duration
    Given 6 videos selected totaling 540 seconds (9 min)
    And another video of 120 seconds (2 min) available
    When user tries to select the 2-minute video
    Then selection should be blocked
    And snackbar "Total duration would exceed 10 minutes" should appear
    And current total should be displayed: "Total: 9:00 / 10:00"

  Scenario: Reorder selected videos with drag and drop
    Given videos A, B, C selected in that order
    When user long-presses video C and drags to position 1
    Then the order should become C, A, B
    And order numbers should update accordingly
    And the preview section should reflect new order

  Scenario: Empty state
    Given a user with 0 videos in their gallery
    When they open the reel creation screen
    Then an empty state should be displayed
    And message "No videos available. Upload videos first." should appear
    And "Create reel" button should be disabled

  Scenario: Create button state management
    Given 0 videos selected
    Then "Create reel" button should be disabled

    Given 1 valid video selected
    Then "Create reel" button should be enabled

    Given 3 valid videos selected
    When total duration is within limits
    Then "Create reel" button should be enabled
    And button should show "Create reel (3 videos)"

  Scenario: Summary display
    Given 4 videos selected totaling 5:30
    Then the summary section should show:
      | field          | value             |
      | video count    | "4 videos"        |
      | total duration | "5:30"            |
      | estimated time | "~3-5 min"        |
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/presentation/pages/video_selection_page.dart`
- `lib/features/reels/presentation/widgets/video_grid.dart`
- `lib/features/reels/presentation/widgets/video_tile.dart`
- `lib/features/reels/presentation/widgets/selection_counter.dart`
- `lib/features/reels/presentation/widgets/duration_summary.dart`
- `lib/features/reels/presentation/providers/video_selection_provider.dart`
- `lib/features/reels/domain/entities/video_selection.dart`
- `lib/features/reels/domain/entities/selectable_video.dart`
- `test/features/reels/presentation/pages/video_selection_page_test.dart`
- `test/features/reels/presentation/providers/video_selection_provider_test.dart`

### A Modifier
- `lib/core/router/app_router.dart` - Add route for video_selection_page

## Notes Techniques

### Video Selection State
```dart
// lib/features/reels/domain/entities/video_selection.dart

class VideoSelection {
  final List<String> selectedIds;
  final int maxVideos;
  final int maxDurationPerVideo; // seconds
  final int maxTotalDuration; // seconds

  const VideoSelection({
    this.selectedIds = const [],
    this.maxVideos = 10,
    this.maxDurationPerVideo = 120, // 2 minutes
    this.maxTotalDuration = 600, // 10 minutes
  });

  bool canSelect(int videoDurationSeconds, int currentTotalSeconds) {
    if (selectedIds.length >= maxVideos) return false;
    if (videoDurationSeconds > maxDurationPerVideo) return false;
    if (currentTotalSeconds + videoDurationSeconds > maxTotalDuration) return false;
    return true;
  }

  String get validationError {
    if (selectedIds.length >= maxVideos) return 'Maximum 10 videos reached';
    return '';
  }
}
```

### Selectable Video Entity
```dart
// lib/features/reels/domain/entities/selectable_video.dart

class SelectableVideo {
  final String id;
  final String thumbnailUrl;
  final int durationSeconds;
  final DateTime createdAt;
  final bool isSelected;
  final int? selectionOrder;
  final bool exceedsDurationLimit;

  const SelectableVideo({
    required this.id,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.createdAt,
    this.isSelected = false,
    this.selectionOrder,
    this.exceedsDurationLimit = false,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
```

### Provider Structure
```dart
// lib/features/reels/presentation/providers/video_selection_provider.dart

@riverpod
class VideoSelectionNotifier extends _$VideoSelectionNotifier {
  @override
  VideoSelectionState build() => const VideoSelectionState();

  void toggleSelection(String videoId, int durationSeconds) {
    if (state.selectedIds.contains(videoId)) {
      _deselect(videoId);
    } else {
      _select(videoId, durationSeconds);
    }
  }

  void reorder(int oldIndex, int newIndex) {
    // Implement drag & drop reordering
  }
}
```

### UI Components
```dart
// VideoTile widget showing thumbnail, duration, selection state
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Thumbnail
      CachedNetworkImage(imageUrl: video.thumbnailUrl),

      // Duration badge (bottom-right)
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(video.formattedDuration, style: TextStyle(color: Colors.white)),
        ),
      ),

      // Selection indicator (top-right)
      if (video.isSelected)
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text('${video.selectionOrder}'),
          ),
        ),

      // Warning overlay for exceeded duration
      if (video.exceedsDurationLimit)
        Positioned.fill(
          child: Container(
            color: Colors.red.withOpacity(0.3),
            child: Icon(Icons.warning, color: Colors.white),
          ),
        ),
    ],
  );
}
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Tests unitaires pour VideoSelectionProvider
- [ ] Tests widget pour VideoSelectionPage
- [ ] Grid displays videos correctly
- [ ] Selection/deselection works
- [ ] Counter updates in real-time
- [ ] Duration validation enforced
- [ ] Drag & drop reordering works
- [ ] Empty state handled
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- EPIC-10: Video data must exist (guest_media table)

## Stories Dependantes
- S04: Validate ownership videos (validates selection before submission)
- S05: CGVU modal (shown after "Create reel" button)
