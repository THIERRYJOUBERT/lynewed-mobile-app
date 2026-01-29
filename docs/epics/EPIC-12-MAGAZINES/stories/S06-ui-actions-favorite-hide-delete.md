# S06 - UI Actions: Favorite, Hide, Delete

> **Epic** : EPIC-12-MAGAZINES
> **Status** : 🔵 Draft
> **Estimation** : 3 points (S)
> **Domaine** : Flutter UI

---

## Description

Implementer les actions sur photos: favorite (coeur), hide (oeil), delete (poubelle). Ces actions fonctionnent sur une photo individuelle ou en batch sur la selection.

## Dependances

- S04 (status column in guest_media)
- S05 (gallery multi-select UI)
- S01 (photo_favorites table)

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Photo actions (favorite, hide, delete)

  # === FAVORITE ===
  Scenario: Favoriting a single photo
    Given a photo in gallery view
    When bride taps heart icon
    Then heart should fill with color
    And photo should be added to photo_favorites
    And photo should appear in Favorites filter

  Scenario: Unfavoriting a photo
    Given a favorited photo (heart filled)
    When bride taps heart icon again
    Then heart should become outline
    And row should be removed from photo_favorites

  Scenario: Batch favorite
    Given 5 photos selected
    When bride taps favorite in action bar
    Then all 5 photos should be favorited
    And toast "5 photos added to favorites"

  # === HIDE ===
  Scenario: Hiding a photo
    Given a shared guest photo in gallery
    When bride taps hide icon (eye)
    Then photo should fade out and disappear
    And status should become 'hidden_by_bride'
    And photo should appear in Hidden filter

  Scenario: Unhiding from Hidden filter
    Given bride in Hidden filter view
    When bride taps unhide icon on photo
    Then photo should be restored to main gallery
    And status should become 'active'

  Scenario: Batch hide
    Given 3 photos selected
    When bride taps hide in action bar
    Then all 3 photos should be hidden
    And toast "3 photos hidden"

  # === DELETE ===
  Scenario: Deleting a photo shows confirmation
    Given a photo selected
    When bride taps delete icon
    Then confirmation dialog should appear
    And message "This photo will be removed from your gallery. The guest will still see it in their album."

  Scenario: Confirming delete
    Given delete confirmation dialog
    When bride taps "Delete"
    Then photo should be soft deleted
    And status should become 'deleted_by_bride'
    And toast "Photo removed"

  Scenario: Canceling delete
    Given delete confirmation dialog
    When bride taps "Cancel"
    Then dialog should close
    And photo should remain unchanged

  Scenario: Batch delete
    Given 4 photos selected
    When bride taps delete
    Then confirmation "Remove 4 photos?"
    When confirmed
    Then all 4 should be soft deleted
    And toast "4 photos removed"

  # === INDIVIDUAL PHOTO VIEW ===
  Scenario: Actions in full photo view
    Given bride viewing single photo full screen
    Then action buttons should be visible:
      - Heart (favorite)
      - Eye (hide)
      - Trash (delete)
      - Download
      - Share
```

## Details Techniques

### UI Components

```
PHOTO TILE OVERLAY (on hover/long press)
┌─────────────────────────────────────┐
│                        [♡] [👁] [🗑]│
│                                     │
│          [PHOTO]                    │
│                                     │
│ ○ selection circle                  │
└─────────────────────────────────────┘

FULL PHOTO VIEW ACTION BAR
┌─────────────────────────────────────┐
│  [←]                    [♡] [👁] [🗑]│
│─────────────────────────────────────│
│                                     │
│                                     │
│          [FULL PHOTO]               │
│                                     │
│                                     │
│─────────────────────────────────────│
│      [Share]  [Download]            │
└─────────────────────────────────────┘

CONFIRMATION DIALOG (Delete)
┌─────────────────────────────────────┐
│       Remove photo?                 │
│                                     │
│  This photo will be removed from    │
│  your gallery. The guest will       │
│  still see it in their album.       │
│                                     │
│      [Cancel]     [Delete]          │
└─────────────────────────────────────┘
```

### Fichiers a Creer/Modifier

| Fichier | Action |
|---------|--------|
| `lib/features/my_wedding/domain/usecases/toggle_favorite_use_case.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/hide_media_use_case.dart` | Nouveau |
| `lib/features/my_wedding/domain/usecases/delete_media_use_case.dart` | Nouveau |
| `lib/features/my_wedding/presentation/widgets/photo_action_buttons.dart` | Nouveau |
| `lib/features/my_wedding/presentation/dialogs/delete_confirmation_dialog.dart` | Nouveau |

### API Calls

```dart
// Toggle favorite
Future<void> toggleFavorite(String mediaId, String mediaType, bool isFavorited) async {
  if (isFavorited) {
    await supabase.from('photo_favorites').delete()
      .eq('user_id', userId)
      .eq('media_id', mediaId);
  } else {
    await supabase.from('photo_favorites').insert({
      'user_id': userId,
      'media_type': mediaType,
      'media_id': mediaId,
    });
  }
}

// Hide/Unhide
Future<void> updateMediaStatus(String mediaId, String status) async {
  await supabase.from('guest_media').update({
    'status': status, // 'active', 'hidden_by_bride', 'deleted_by_bride'
  }).eq('id', mediaId);
}
```

## Tests

- [ ] Toggle favorite fonctionne (add/remove)
- [ ] Hide change le status
- [ ] Delete avec confirmation
- [ ] Batch actions sur selection
- [ ] Toast de confirmation
- [ ] Hidden filter affiche photos masquees
- [ ] Unhide restaure la photo

## Notes

- Soft delete = pas de suppression physique
- Guest n'est pas impacte (voit toujours ses photos)
- Optimistic update pour UX rapide
- Animate fade out on hide/delete
