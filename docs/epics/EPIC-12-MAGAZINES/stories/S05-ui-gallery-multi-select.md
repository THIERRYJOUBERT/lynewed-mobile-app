# S05 - UI Gallery with Multi-Select

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 5 points (M)
> **Domaine** : Flutter UI

---

## Description

Implementer l'interface de galerie avec mode selection multiple, similaire a l'app Photos iOS ou Vinted. Permet de selectionner plusieurs photos pour des actions batch.

## Dependances

- S01 (photo_favorites pour le toggle favorite)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Gallery with multi-select

  Scenario: Entering selection mode via long press
    Given bride viewing gallery in normal mode
    When bride long-presses on a photo
    Then selection mode should activate
    And the photo should be selected
    And checkboxes should appear on all photos
    And action bar should appear at top

  Scenario: Entering selection mode via select button
    Given bride viewing gallery
    When bride taps "Select" button in app bar
    Then selection mode should activate
    And checkboxes should appear on all photos

  Scenario: Selecting multiple photos
    Given selection mode is active
    When bride taps on photos
    Then orange checkmark should appear on selected photos
    And counter should update "X PHOTOS SELECTED"

  Scenario: Select all
    Given selection mode active with 5/20 photos selected
    When bride taps "Select all"
    Then all 20 photos should be selected
    And counter should show "20 PHOTOS SELECTED"

  Scenario: Deselecting single photo
    Given photo is selected (has checkmark)
    When bride taps the selected photo
    Then checkmark should disappear
    And counter should decrement

  Scenario: Deselect all
    Given 10 photos selected
    When bride taps "Select all" (already all selected)
    Then all photos should be deselected
    And counter should show "0 PHOTOS SELECTED"

  Scenario: Exiting selection mode
    Given selection mode is active
    When bride taps X button in action bar
    Then selection should clear
    And normal gallery view should return
    And checkboxes should disappear

  Scenario: Action bar buttons
    Given selection mode with photos selected
    Then action bar should show:
      - Share icon
      - Share as gallery icon
      - Download icon
      - Delete icon
    And all buttons should be tappable

  Scenario: Filter tabs
    Given gallery displayed
    Then filter tabs should show: [All] [Favorites] [Hidden]
    When bride taps "Favorites"
    Then only favorited photos should display
```

## Details Techniques

### UI Components

```
┌────────────────────────────────────────────────────────────────┐
│  SELECTION MODE ACTION BAR                                      │
│  ┌────────────────────────────────────────────────────────────┐│
│  │ 4 Selected    Select all                              [X]  ││
│  │─────────────────────────────────────────────────────────────││
│  │ [Share]  [Share as gallery]  [Download]  [Delete]          ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
│  GALLERY GRID (3 columns)                                       │
│  ┌─────────┬─────────┬─────────┐                               │
│  │         │    ✓    │         │  ← Orange checkmark           │
│  │  Photo  │  Photo  │  Photo  │                               │
│  │    ○    │    ●    │    ○    │  ← Selection circles          │
│  ├─────────┼─────────┼─────────┤                               │
│  │    ✓    │         │    ✓    │                               │
│  │  Photo  │  Photo  │  Photo  │                               │
│  │    ●    │    ○    │    ●    │                               │
│  └─────────┴─────────┴─────────┘                               │
│                                                                 │
│  FILTER TABS                                                    │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ [All]  [Favorites]  [Hidden]                                ││
│  └─────────────────────────────────────────────────────────────┘│
└────────────────────────────────────────────────────────────────┘
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/presentation/pages/gallery_page.dart` | Modifier existant ou creer |
| `lib/features/my_wedding/presentation/widgets/gallery_grid.dart` | Nouveau - Grid avec selection |
| `lib/features/my_wedding/presentation/widgets/selection_action_bar.dart` | Nouveau - Action bar |
| `lib/features/my_wedding/presentation/widgets/photo_tile.dart` | Nouveau - Tile avec checkbox |
| `lib/features/my_wedding/presentation/cubit/gallery_selection_cubit.dart` | Nouveau - State management |

### State Management

```dart
// gallery_selection_state.dart
class GallerySelectionState {
  final bool isSelectionMode;
  final Set<String> selectedMediaIds;
  final GalleryFilter currentFilter; // all, favorites, hidden

  int get selectedCount => selectedMediaIds.length;
  bool isSelected(String mediaId) => selectedMediaIds.contains(mediaId);
}

enum GalleryFilter { all, favorites, hidden }
```

### Animations

- Checkboxes: fade in/out on mode change
- Selection: scale animation on select/deselect
- Action bar: slide down animation

## Tests

- [ ] Long press active le mode selection
- [ ] Tap selectionne/deselectionne
- [ ] Select all / deselect all fonctionne
- [ ] Counter mis a jour en temps reel
- [ ] X ferme le mode selection
- [ ] Filtres All/Favorites/Hidden fonctionnent
- [ ] Actions batch accessibles

## UI Reference

Screenshot: "4 Selected - Select all" avec grille et checkmarks orange

## Notes

- Utiliser Cubit pour state management (coherent avec codebase)
- 3 colonnes sur mobile
- Checkmark orange (couleur accent app)
- Circle outline sur photos non selectionnees
