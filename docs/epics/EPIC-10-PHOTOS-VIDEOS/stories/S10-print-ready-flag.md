# Story S10: Preparer flag print_ready pour futur

## Description
En tant que **bride**, je veux **marquer mes photos preferees comme "pretes pour impression"**, afin de **les retrouver facilement quand la fonctionnalite de commande d'impressions sera disponible**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a user viewing their media When the media options are displayed Then "Order Print" option should be visible And option should be grayed out And "Coming soon" badge should be shown
- [ ] Given a user taps "Order Print" (disabled) When the tap is registered Then a snackbar should say "Print ordering coming soon!" And no action should be taken
- [ ] Given a bride viewing their media When the bride taps "Mark for future print" Then print_ready should be set to TRUE And a bookmark icon should appear on the media
- [ ] Given a media marked as print_ready = TRUE When the user taps "Remove from print list" Then print_ready should be set to FALSE And bookmark icon should disappear
- [ ] Given 5 media marked as print_ready When navigating to "Print Ready" section Then 5 media should be displayed And message "These items will be available when Print ordering launches" should be shown

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/widgets/print_ready_badge.dart`
- `lib/features/my_wedding/domain/usecases/toggle_print_ready_use_case.dart`
- `lib/features/my_wedding/presentation/pages/print_ready_page.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/media_detail_page.dart` - Ajouter option print
- `lib/features/my_wedding/presentation/widgets/media_grid_item.dart` - Afficher badge print_ready

## Notes Techniques

### PrintReadyBadge Widget
```dart
// lib/features/my_wedding/presentation/widgets/print_ready_badge.dart
import 'package:flutter/material.dart';

class PrintReadyBadge extends StatelessWidget {
  const PrintReadyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.bookmark,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}
```

### Coming Soon Badge pour Order Print
```dart
class OrderPrintButton extends StatelessWidget {
  const OrderPrintButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: ListTile(
        leading: const Icon(Icons.print, color: Colors.grey),
        title: const Text(
          'Order Print',
          style: TextStyle(color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Coming soon',
            style: TextStyle(fontSize: 10, color: Colors.blue),
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Print ordering coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
```

### TogglePrintReadyUseCase
```dart
// lib/features/my_wedding/domain/usecases/toggle_print_ready_use_case.dart
class TogglePrintReadyUseCase {
  final MediaRepository repository;

  TogglePrintReadyUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String mediaId,
    required bool printReady,
    required bool isGuestMedia,
  }) async {
    if (isGuestMedia) {
      return repository.updateGuestMediaPrintReady(
        mediaId: mediaId,
        printReady: printReady,
      );
    } else {
      return repository.updateAlbumImagePrintReady(
        mediaId: mediaId,
        printReady: printReady,
      );
    }
  }
}
```

### PrintReadyPage
```dart
// lib/features/my_wedding/presentation/pages/print_ready_page.dart
class PrintReadyPage extends StatelessWidget {
  final String weddingId;

  const PrintReadyPage({super.key, required this.weddingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Ready'),
      ),
      body: BlocBuilder<PrintReadyBloc, PrintReadyState>(
        builder: (context, state) {
          if (state is PrintReadyLoaded) {
            if (state.media.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: [
                _buildInfoBanner(),
                Expanded(child: _buildMediaGrid(state.media)),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'These items will be available when Print ordering launches',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No photos marked for printing',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Mark your favorite photos to easily\nfind them when printing launches',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(List<Media> media) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: media.length,
      itemBuilder: (context, index) {
        return MediaGridItem(
          media: media[index],
          showPrintBadge: true,
        );
      },
    );
  }
}
```

### Query pour medias print_ready
```sql
-- Get all print_ready media for a wedding
SELECT
  id,
  image_url as url,
  thumbnail_url,
  media_type,
  caption,
  'bride' as source
FROM album_images ai
JOIN inspiration_albums ia ON ia.id = ai.album_id
WHERE ia.profile_id = :bride_profile_id
  AND ai.print_ready = TRUE

UNION ALL

SELECT
  id,
  storage_path as url,
  thumbnail_path as thumbnail_url,
  media_type,
  caption,
  'guest' as source
FROM guest_media gm
JOIN guest_albums ga ON ga.id = gm.album_id
WHERE ga.wedding_id = :wedding_id
  AND ga.shared_with_bride = TRUE
  AND gm.print_ready = TRUE
ORDER BY created_at DESC;
```

### Integration dans media_detail_page
```dart
// Ajouter dans les options du media
PopupMenuButton<String>(
  itemBuilder: (context) => [
    // ... autres options
    const PopupMenuItem(
      value: 'toggle_print',
      child: Row(
        children: [
          Icon(Icons.bookmark),
          SizedBox(width: 8),
          Text('Mark for future print'),
        ],
      ),
    ),
  ],
  onSelected: (value) {
    if (value == 'toggle_print') {
      context.read<MediaBloc>().add(
        TogglePrintReady(
          mediaId: media.id,
          printReady: !media.printReady,
        ),
      );
    }
  },
),
```

## Definition of Done
- [ ] Bouton "Order Print" visible mais desactive avec "Coming soon"
- [ ] Snackbar affiche quand on tap sur Order Print
- [ ] Option "Mark for future print" fonctionnelle
- [ ] Badge bookmark sur medias marques
- [ ] Page "Print Ready" avec liste des medias
- [ ] Message explicatif sur la page Print Ready
- [ ] Empty state quand aucun media marque
- [ ] Toggle print_ready persiste en DB
- [ ] Tests unitaires pour use case
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (colonne print_ready dans album_images)
- S03 (colonne print_ready dans guest_media)

## Stories Dependantes
- Aucune (fonctionnalite standalone preparatoire)
