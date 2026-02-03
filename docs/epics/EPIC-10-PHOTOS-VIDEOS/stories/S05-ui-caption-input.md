# Story S05: UI Saisie legende (CaptionInputWidget)

> **Revision 2026-02-03** : Nouvelle story remplacant l'ancienne S05 (upload video). Le support video est maintenant integre dans S04.

## Description
En tant que **bride ou guest**, je veux **ajouter une legende facultative a mes photos et videos lors de l'upload**, afin de **contextualiser mes souvenirs avec une description personnalisee**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a CaptionInputWidget is displayed When I type text Then a character counter should show the current count (e.g., "45/500")
- [ ] Given I am typing in the caption field When I reach 500 characters Then I should not be able to type more characters
- [ ] Given a CaptionInputWidget is displayed When I leave the field empty Then the upload should still be allowed (caption is optional)
- [ ] Given I have typed 450+ characters When I continue typing Then the counter should turn orange as a warning
- [ ] Given a CaptionInputWidget When rendered Then it should use LynewedTextField from the Design System
- [ ] Given a CaptionInputWidget with a hint When rendered Then the hint text should be "Add a caption..." in English

## Fichiers Concernes

### A Creer
- `lib/features/my_wedding/presentation/widgets/caption_input_widget.dart`
- `test/features/my_wedding/presentation/widgets/caption_input_widget_test.dart`

### A Modifier
- Aucun (widget standalone reutilisable dans S04 et S06)

## Notes Techniques

### Widget Design

Le `CaptionInputWidget` encapsule `LynewedTextField` avec la logique specifique aux legendes :

```dart
// lib/features/my_wedding/presentation/widgets/caption_input_widget.dart
import 'package:flutter/material.dart';
import '/core/design/design.dart';

class CaptionInputWidget extends StatefulWidget {
  const CaptionInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.label,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? label;

  static const int maxLength = 500;
  static const int warningThreshold = 450;

  @override
  State<CaptionInputWidget> createState() => _CaptionInputWidgetState();
}

class _CaptionInputWidgetState extends State<CaptionInputWidget> {
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller.text.length;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _currentLength = widget.controller.text.length;
    });
  }

  Color _getCounterColor() {
    if (_currentLength >= CaptionInputWidget.maxLength) {
      return LynewedColors.error;
    } else if (_currentLength >= CaptionInputWidget.warningThreshold) {
      return Colors.orange;
    }
    return LynewedColors.gray500;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LynewedTextField(
          controller: widget.controller,
          label: widget.label,
          hint: 'Add a caption...',
          maxLines: 3,
          maxLength: CaptionInputWidget.maxLength,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_currentLength/${CaptionInputWidget.maxLength}',
            style: LynewedTextStyles.caption.copyWith(
              color: _getCounterColor(),
              fontWeight: _currentLength >= CaptionInputWidget.warningThreshold
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
```

### Integration Future

Ce widget sera reutilise dans :
- **S04** : Flow upload bride (AlbumDetailPage)
- **S06** : Flow upload guest (GuestAlbumPage)

Exemple d'utilisation dans un dialog d'upload :
```dart
// Dans le dialog de confirmation d'upload
CaptionInputWidget(
  controller: _captionController,
  label: 'Caption (optional)',
  onChanged: (value) => setState(() {}),
),
```

### Design System References

| Element | Reference |
|---------|-----------|
| TextField | `LynewedTextField` avec `maxLength`, `maxLines: 3` |
| Colors | `LynewedColors.error` (rouge), `LynewedColors.gray500` (gris) |
| Typography | `LynewedTextStyles.caption` pour le compteur |

### Comportement Warning

| Caracteres | Couleur compteur | Font weight |
|------------|------------------|-------------|
| 0-449 | `gray500` | normal |
| 450-499 | `orange` | w600 (bold) |
| 500 | `error` (rouge) | w600 (bold) |

## Definition of Done
- [ ] CaptionInputWidget cree avec tous les parametres
- [ ] Compteur de caracteres visible et mis a jour en temps reel
- [ ] Limite de 500 caracteres appliquee (ne peut pas depasser)
- [ ] Compteur orange a partir de 450 caracteres
- [ ] Compteur rouge a 500 caracteres
- [ ] Legende optionnelle (champ vide accepte)
- [ ] Utilise LynewedTextField du Design System
- [ ] Hint text en anglais "Add a caption..."
- [ ] Tests unitaires pour le widget
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 2
**Complexite** : Small (S)
**Risque** : Faible (widget simple, utilise composants existants)

## Dependances
- S01 (album_images enrichie avec colonne caption)

## Stories Dependantes
- S04 (UI Upload bride) - utilisera ce widget
- S06 (UI Upload guest) - utilisera ce widget
