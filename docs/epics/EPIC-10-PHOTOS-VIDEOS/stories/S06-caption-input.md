# Story S06: Ajouter saisie legende a l'upload media

## Description
En tant que **bride ou guest**, je veux **ajouter une legende a mes photos et videos lors de l'upload**, afin de **decrire le contexte et les souvenirs associes a chaque media**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a user has selected a photo or video When the upload screen is displayed Then a caption text field should be visible And placeholder text "Add a caption (optional)" should be shown
- [ ] Given a user typing a caption When the user types "Hello" Then counter should show "5/500"
- [ ] Given a user typing a caption When the user types 500 characters Then counter should show "500/500" And the text should turn orange as a warning
- [ ] Given a caption with 500 characters When the user tries to type more Then no additional characters should be accepted And counter should remain at "500/500"
- [ ] Given a user on the upload screen When the user leaves caption empty Then upload should proceed successfully And caption should be NULL in database
- [ ] Given a user has typed a caption When viewing the media preview Then the caption should be displayed below the media
- [ ] Given a media with an existing caption When the user taps "Edit caption" Then the caption text field should appear with existing text And user should be able to modify and save

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/widgets/caption_input_widget.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/media_upload_page.dart` - Integrer CaptionInputWidget
- `lib/features/my_wedding/presentation/pages/media_detail_page.dart` - Afficher et editer caption

## Notes Techniques

### CaptionInputWidget
```dart
// lib/features/my_wedding/presentation/widgets/caption_input_widget.dart
import 'package:flutter/material.dart';

class CaptionInputWidget extends StatefulWidget {
  final String? initialCaption;
  final ValueChanged<String?> onCaptionChanged;
  final bool showPreview;

  const CaptionInputWidget({
    super.key,
    this.initialCaption,
    required this.onCaptionChanged,
    this.showPreview = true,
  });

  @override
  State<CaptionInputWidget> createState() => _CaptionInputWidgetState();
}

class _CaptionInputWidgetState extends State<CaptionInputWidget> {
  static const int maxLength = 500;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCaption);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onCaptionChanged(text.isEmpty ? null : text);
  }

  Color _getCounterColor() {
    final length = _controller.text.length;
    if (length >= maxLength) return Colors.red;
    if (length >= maxLength * 0.9) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          maxLength: maxLength,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add a caption (optional)',
            counterText: '', // Hide default counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              return Text(
                '${value.text.length}/$maxLength',
                style: TextStyle(
                  color: _getCounterColor(),
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Integration dans media_upload_page.dart
```dart
// Dans le formulaire d'upload
CaptionInputWidget(
  initialCaption: null,
  onCaptionChanged: (caption) {
    setState(() {
      _caption = caption;
    });
  },
),

// Lors de l'upload
await uploadMediaUseCase.execute(
  file: selectedFile,
  albumId: albumId,
  caption: _caption, // Peut etre null
  mediaType: isVideo ? 'video' : 'photo',
);
```

### Use Case update_caption
```dart
// lib/features/my_wedding/domain/usecases/update_caption_use_case.dart
class UpdateCaptionUseCase {
  final MediaRepository repository;

  UpdateCaptionUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String mediaId,
    required String? caption,
    required bool isGuestMedia,
  }) async {
    // Validate caption length
    if (caption != null && caption.length > 500) {
      return Left(ValidationFailure('Caption must be 500 characters or less'));
    }

    return repository.updateCaption(
      mediaId: mediaId,
      caption: caption,
      isGuestMedia: isGuestMedia,
    );
  }
}
```

### Comportements UX
| Situation | Comportement |
|-----------|--------------|
| Champ vide | Placeholder visible, caption = NULL en DB |
| < 450 chars | Compteur gris normal |
| 450-499 chars | Compteur orange (warning) |
| 500 chars | Compteur rouge, plus de saisie possible |
| Emojis | Supportes (comptent comme caracteres) |

## Definition of Done
- [ ] CaptionInputWidget cree et fonctionnel
- [ ] Compteur de caracteres affiche correctement
- [ ] Limite 500 caracteres respectee
- [ ] Couleur warning (orange) a 90%
- [ ] Couleur erreur (rouge) a 100%
- [ ] Caption optionnel (NULL accepte)
- [ ] Edition caption post-upload fonctionnelle
- [ ] Tests unitaires pour le widget
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- S01 (colonne caption dans album_images)

## Stories Dependantes
- Aucune directement (amelioration UX standalone)
