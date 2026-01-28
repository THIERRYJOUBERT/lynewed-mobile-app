# Story S07: Implementer toggle shared_with_bride

## Description
En tant que **guest invite a un mariage**, je veux **choisir explicitement de partager mon album avec la mariee via un toggle opt-in**, afin de **controler qui peut voir mes photos et videos**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a guest creates their album When viewing album settings Then shared_with_bride toggle should be OFF And label should say "Share with bride: Off"
- [ ] Given shared_with_bride is OFF When guest taps the toggle Then a confirmation dialog should appear And text should explain "The bride will be able to view your photos and videos" And options should be "Cancel" and "Share"
- [ ] Given confirmation dialog is shown When guest taps "Share" Then shared_with_bride should become TRUE And toggle should switch to ON And gallery_access_logs should record 'share_enabled'
- [ ] Given confirmation dialog is shown When guest taps "Cancel" Then shared_with_bride should remain FALSE And toggle should stay OFF And no log should be recorded
- [ ] Given shared_with_bride is TRUE When guest taps the toggle Then shared_with_bride should become FALSE immediately (no confirmation) And gallery_access_logs should record 'share_disabled'
- [ ] Given shared_with_bride is TRUE When viewing the album Then a "Shared with bride" badge should be visible

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/widgets/share_toggle_widget.dart`
- `lib/features/my_wedding/domain/usecases/toggle_album_sharing_use_case.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/guest_album_page.dart` - Ajouter le toggle
- `lib/features/my_wedding/data/repositories/guest_album_repository.dart` - Methode update sharing

## Notes Techniques

### ShareToggleWidget
```dart
// lib/features/my_wedding/presentation/widgets/share_toggle_widget.dart
import 'package:flutter/material.dart';

class ShareToggleWidget extends StatelessWidget {
  final bool isShared;
  final VoidCallback onToggle;
  final bool isLoading;

  const ShareToggleWidget({
    super.key,
    required this.isShared,
    required this.onToggle,
    this.isLoading = false,
  });

  Future<void> _handleToggle(BuildContext context) async {
    if (isShared) {
      // Disabling: no confirmation needed
      onToggle();
    } else {
      // Enabling: show confirmation dialog
      final confirmed = await _showConfirmationDialog(context);
      if (confirmed) {
        onToggle();
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share album with bride?'),
        content: const Text(
          'The bride will be able to view your photos and videos. '
          'You can disable sharing at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Share'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share with bride',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              isShared ? 'The bride can view your album' : 'Only you can see your album',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: isShared,
              onChanged: (_) => _handleToggle(context),
            ),
      ],
    );
  }
}
```

### ToggleAlbumSharingUseCase
```dart
// lib/features/my_wedding/domain/usecases/toggle_album_sharing_use_case.dart
import 'package:dartz/dartz.dart';

class ToggleAlbumSharingUseCase {
  final GuestAlbumRepository repository;
  final GalleryAccessLogRepository logRepository;

  ToggleAlbumSharingUseCase(this.repository, this.logRepository);

  Future<Either<Failure, void>> execute({
    required String albumId,
    required bool newSharedState,
    required String weddingId,
    required String guestUserId,
  }) async {
    // Update sharing state
    final result = await repository.updateSharedWithBride(
      albumId: albumId,
      shared: newSharedState,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) async {
        // Log the action
        await logRepository.logAccess(
          weddingId: weddingId,
          accessedBy: guestUserId,
          accessType: newSharedState ? 'share_enabled' : 'share_disabled',
        );
        return const Right(null);
      },
    );
  }
}
```

### Badge "Shared with bride"
```dart
// Widget badge a afficher sur l'album quand partage
class SharedBadge extends StatelessWidget {
  const SharedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Shared with bride',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
```

### Logging Access
Le toggle doit logger dans `gallery_access_logs`:
- `share_enabled` quand le guest active le partage
- `share_disabled` quand le guest desactive le partage

Note: Le log est fait via service_role depuis une Edge Function ou directement si le client a les droits.

## Definition of Done
- [ ] ShareToggleWidget cree et fonctionnel
- [ ] Confirmation dialog avant activation
- [ ] Pas de confirmation pour desactivation
- [ ] Badge "Shared with bride" visible quand partage actif
- [ ] Optimistic update (UI reactive)
- [ ] Logging dans gallery_access_logs
- [ ] Tests unitaires pour le use case
- [ ] Tests widget pour ShareToggleWidget
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S02 (table guest_albums avec colonne shared_with_bride)
- S03 (table guest_media)
- S04 (table gallery_access_logs)

## Stories Dependantes
- S08 (Vue bride albums guests - depend du toggle pour voir les albums)
