# Story S07: Display reviews on professional profile

## Description
En tant que visiteur ou mariee, je veux voir la note moyenne et la liste des avis sur la fiche profil d'un professionnel, afin de pouvoir evaluer sa reputation avant de le contacter.

## Criteres d'Acceptance (Gherkin)
- [ ] Given pro-A has average rating 4.5 with 12 reviews When viewing pro-A's profile Then "4.5/5 (12 reviews)" should be displayed And 4.5 stars should be visually shown (4 full + half star)
- [ ] Given pro-B has 5 reviews When expanding the reviews section Then all 5 reviews should be listed And each review should show bride name, rating, comment, and date
- [ ] Given pro-C has no reviews When viewing pro-C's profile Then "Not rated yet" message should be displayed And "No reviews yet" should appear in the reviews section
- [ ] Given bride is viewing pro-D's profile And bride has not reviewed pro-D When seeing the reviews section Then "Write a review" button should be displayed
- [ ] Given bride has already reviewed pro-E When viewing pro-E's profile Then "Edit your review" button should be displayed instead of "Write a review"
- [ ] Given professional is viewing their own profile When seeing the reviews section Then no "Write a review" button should be displayed (pros can't review themselves)
- [ ] Given a review has no comment When displaying the review card Then only the rating and metadata should be shown (no empty comment space)

## Fichiers Concernes
### A Creer
- `lib/features/reviews/presentation/widgets/reviews_section.dart`
- `lib/features/reviews/presentation/widgets/review_card.dart`
- `lib/features/reviews/presentation/bloc/reviews_bloc.dart`
- `lib/features/reviews/presentation/bloc/reviews_event.dart`
- `lib/features/reviews/presentation/bloc/reviews_state.dart`
- `test/features/reviews/presentation/widgets/reviews_section_test.dart`
- `test/features/reviews/presentation/bloc/reviews_bloc_test.dart`

### A Modifier
- `lib/features/profile/presentation/pages/professional_profile_page.dart` (add ReviewsSection)
- `lib/features/profile/presentation/bloc/professional_profile_bloc.dart` (load reviews data)

## Notes Techniques

### ReviewsSection Widget
```dart
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.rating,
    required this.reviews,
    this.myReview,
    this.onWriteReview,
    this.onEditReview,
    this.isLoading = false,
  });

  final ProRating? rating;
  final List<Review> reviews;
  final Review? myReview;
  final VoidCallback? onWriteReview;
  final VoidCallback? onEditReview;
  final bool isLoading;
}
```

### ReviewCard Widget
```dart
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});
  final Review review;
}
```

Features:
- Avatar with bride initial or image
- Bride name
- Star rating (read-only)
- Time ago (e.g., "2 days ago")
- Comment (if present)

### Bloc States
```dart
sealed class ReviewsState {}
class ReviewsInitial extends ReviewsState {}
class ReviewsLoading extends ReviewsState {}
class ReviewsLoaded extends ReviewsState {
  final ProRating? rating;
  final List<Review> reviews;
  final Review? myReview;
}
class ReviewsError extends ReviewsState {
  final String message;
}
```

### Integration Point
In `ProfessionalProfilePage`:
```dart
// After existing content sections
BlocProvider(
  create: (_) => ReviewsBloc(repository: sl())
    ..add(LoadReviews(proId: profile.id)),
  child: BlocBuilder<ReviewsBloc, ReviewsState>(
    builder: (context, state) {
      if (state is ReviewsLoaded) {
        return ReviewsSection(
          rating: state.rating,
          reviews: state.reviews,
          myReview: state.myReview,
          onWriteReview: _canReview ? () => _openReviewSheet(context) : null,
          onEditReview: state.myReview != null ? () => _openReviewSheet(context, state.myReview) : null,
        );
      }
      return const SizedBox.shrink();
    },
  ),
),
```

## Definition of Done
- [ ] ReviewsSection widget cree
- [ ] ReviewCard widget cree
- [ ] ReviewsBloc cree avec LoadReviews, SubmitReview events
- [ ] Integration dans ProfessionalProfilePage
- [ ] Affichage note moyenne avec etoiles
- [ ] Liste des avis avec pagination (si >10 avis, bouton "Show more")
- [ ] Bouton Write/Edit review selon contexte
- [ ] Etat vide "No reviews yet"
- [ ] Tests widget pour ReviewsSection
- [ ] Tests bloc pour ReviewsBloc
- [ ] `flutter test` passe
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible

## Dependances
- S04: Review and ProRating entities
- S05: Repository (getReviewsForPro, getRatingForPro, getMyReviewForPro)
- S06: StarRatingDisplay widget, ReviewSubmitSheet

## Stories Dependantes
- Aucune (fin de chaine pour l'affichage)
