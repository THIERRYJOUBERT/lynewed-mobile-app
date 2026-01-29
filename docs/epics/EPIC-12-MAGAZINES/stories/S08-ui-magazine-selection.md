# S08 - UI Magazine Photo Selection

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Flutter UI

---

## Description

Interface pour selectionner et ordonner les photos qui seront incluses dans le magazine. Supporte le drag & drop pour reordonner.

## Dependances

- S02 (magazine_selections table)
- S05 (gallery multi-select)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Magazine photo selection

  Scenario: Adding photos from gallery selection
    Given bride in gallery with 10 photos selected
    When bride taps "Add to Magazine"
    Then photos should be added to magazine_selections
    And positions should be assigned (1-10)
    And toast "10 photos added to magazine"

  Scenario: Viewing magazine selection
    Given bride taps "Magazine" tab or button
    Then magazine selection screen should open
    And selected photos should display in grid
    And photo count should show (e.g., "15 photos")

  Scenario: Maximum photos limit
    Given 50 photos already in magazine selection
    When bride tries to add more
    Then error toast "Maximum 50 photos per magazine"
    And no photos should be added

  Scenario: Reordering via drag and drop
    Given photos at positions 1, 2, 3
    When bride drags photo from position 3 to position 1
    Then photo should move to position 1
    And other photos should shift (2→3, 1→2)
    And database positions should update

  Scenario: Removing photo from magazine
    Given photo in magazine selection
    When bride taps remove icon on photo
    Then photo should be removed from selection
    And positions should recompact
    And toast "Photo removed from magazine"

  Scenario: Clear all selection
    Given 20 photos in magazine selection
    When bride taps "Clear all"
    Then confirmation "Remove all photos from magazine?"
    When confirmed
    Then all photos should be removed
    And empty state should show

  Scenario: Navigate to preview
    Given photos in magazine selection
    When bride taps "Preview Magazine"
    Then preview screen should open (S09)
    And selected photos should be passed

  Scenario: Empty state
    Given no photos in magazine selection
    Then message "Select photos to create your magazine"
    And button "Add from Gallery"
```

## Details Techniques

### UI Components

```
MAGAZINE SELECTION SCREEN
┌─────────────────────────────────────────────────────────────────┐
│  [←]  Magazine Selection                      [Clear] [Preview]│
│─────────────────────────────────────────────────────────────────│
│  15 photos selected (max 50)                                    │
│─────────────────────────────────────────────────────────────────│
│                                                                 │
│  REORDERABLE GRID                                               │
│  ┌─────────┬─────────┬─────────┐                               │
│  │    1    │    2    │    3    │  ← Position numbers           │
│  │ [PHOTO] │ [PHOTO] │ [PHOTO] │                               │
│  │   [×]   │   [×]   │   [×]   │  ← Remove buttons             │
│  ├─────────┼─────────┼─────────┤                               │
│  │    4    │    5    │    6    │                               │
│  │ [PHOTO] │ [PHOTO] │ [PHOTO] │                               │
│  │   [×]   │   [×]   │   [×]   │                               │
│  └─────────┴─────────┴─────────┘                               │
│                                                                 │
│  [+ Add more photos from gallery]                               │
│                                                                 │
│─────────────────────────────────────────────────────────────────│
│              [Create Magazine →]                                │
└─────────────────────────────────────────────────────────────────┘

EMPTY STATE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│              📖                                                 │
│                                                                 │
│   Select photos to create your magazine                         │
│                                                                 │
│   Choose your favorite moments to                               │
│   turn into a beautiful printed book                            │
│                                                                 │
│         [Add from Gallery]                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/presentation/pages/magazine_selection_page.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/reorderable_photo_grid.dart` | Nouveau |
| `lib/features/my_wedding/presentation/cubit/magazine_selection_cubit.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/add_to_magazine_use_case.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/remove_from_magazine_use_case.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/reorder_magazine_use_case.dart` | Nouveau |

### State Management

```dart
class MagazineSelectionState {
  final List<MagazinePhoto> photos; // Ordered by position
  final bool isLoading;
  final String? errorMessage;

  int get count => photos.length;
  bool get canAddMore => count < 50;
  bool get canPreview => count > 0;
}

class MagazinePhoto {
  final String id;
  final String mediaType;
  final String mediaId;
  final int position;
  final String thumbnailUrl;
}
```

### Drag & Drop Implementation

```dart
// Using ReorderableGridView or similar
ReorderableGridView.builder(
  itemCount: photos.length,
  onReorder: (oldIndex, newIndex) {
    cubit.reorderPhoto(oldIndex, newIndex);
  },
  itemBuilder: (context, index) {
    return MagazinePhotoTile(
      key: ValueKey(photos[index].id),
      photo: photos[index],
      position: index + 1,
      onRemove: () => cubit.removePhoto(photos[index].id),
    );
  },
);
```

## Tests

- [ ] Ajout photos depuis galerie
- [ ] Max 50 photos enforce
- [ ] Drag & drop reorder
- [ ] Remove photo + recompact positions
- [ ] Clear all avec confirmation
- [ ] Navigate to preview
- [ ] Empty state correct
- [ ] Position numbers affiches

## Notes

- Use `ReorderableGridView` package ou custom
- Position persist dans database
- Optimistic update pour drag fluide
- Photo 1 = couverture par defaut
