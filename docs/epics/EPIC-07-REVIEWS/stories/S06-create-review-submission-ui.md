# Story S06: Create review submission UI (stars + comment)

## Description
En tant que mariee (bride), je veux pouvoir soumettre un avis avec une notation par etoiles et un commentaire optionnel, afin de partager mon experience avec un professionnel.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the ReviewSubmitSheet is open When the user sees the star rating widget Then 5 empty stars should be displayed And stars should be tappable
- [ ] Given the ReviewSubmitSheet is open When the user taps the 4th star Then stars 1-4 should be filled And star 5 should be empty And the rating value should be 4
- [ ] Given the user has selected 3 stars When the user taps the 5th star Then all 5 stars should be filled And the rating value should be 5
- [ ] Given the user has selected a rating When the comment field is empty Then the submit button should be enabled (comment is optional)
- [ ] Given the ReviewSubmitSheet is open When no rating is selected Then the submit button should be disabled
- [ ] Given the user has selected 5 stars And the user has entered "Amazing photographer!" When the user taps Submit Then the review should be saved And the sheet should close And a success message should be shown
- [ ] Given the user has already reviewed this pro When opening the review sheet Then the existing rating should be pre-filled And the existing comment should be pre-filled And the button text should be "Update Review"
- [ ] Given the user is submitting When an error occurs Then an error message should be displayed And the sheet should remain open

## Fichiers Concernes
### A Creer
- `lib/features/reviews/presentation/widgets/star_rating_input.dart`
- `lib/features/reviews/presentation/widgets/star_rating_display.dart`
- `lib/features/reviews/presentation/sheets/review_submit_sheet.dart`
- `test/features/reviews/presentation/widgets/star_rating_input_test.dart`
- `test/features/reviews/presentation/sheets/review_submit_sheet_test.dart`

### A Modifier
- Aucun (integration dans profil pro sera faite en S07)

## Notes Techniques

### StarRatingInput Widget
```dart
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 40.0,
    this.starColor = LynewedColors.primary,
    this.emptyColor = LynewedColors.gray300,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final Color starColor;
  final Color emptyColor;
}
```

### StarRatingDisplay Widget (read-only)
```dart
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.rating, // double for partial stars
    this.starSize = 16.0,
    this.showValue = true,
  });

  final double rating;
  final double starSize;
  final bool showValue;
}
```

### ReviewSubmitSheet
```dart
class ReviewSubmitSheet extends StatefulWidget {
  const ReviewSubmitSheet({
    super.key,
    required this.proId,
    required this.proName,
    this.existingReview, // For edit mode
    required this.onSubmit,
  });
}
```

### Rating Labels
| Rating | Label |
|--------|-------|
| 1 | Poor |
| 2 | Fair |
| 3 | Good |
| 4 | Very Good |
| 5 | Excellent |

### Design System Integration
- Use `LynewedColors.primary` for filled stars
- Use `LynewedColors.gray300` for empty stars
- Use `LynewedTextStyles` for all text
- Use `LynewedSpacing` for padding/margins
- Use `LynewedComponentStyles.primaryButton()` for submit button

## Definition of Done
- [ ] StarRatingInput widget cree et fonctionnel
- [ ] StarRatingDisplay widget cree (pour affichage read-only)
- [ ] ReviewSubmitSheet cree avec mode creation et edition
- [ ] Validation: rating requis, commentaire optionnel (max 500 chars)
- [ ] Etats de chargement pendant la soumission
- [ ] Gestion des erreurs avec messages utilisateur
- [ ] Tests widget pour StarRatingInput
- [ ] Tests widget pour ReviewSubmitSheet
- [ ] `flutter test` passe
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S04: Review entity (for edit mode)
- S05: Repository/Use cases (for submission)

## Stories Dependantes
- S07: UI display (uses StarRatingDisplay widget)
