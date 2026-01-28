# Story S05: Implement ReviewRepository and Use Cases

## Description
En tant que developpeur Flutter, je veux implementer le repository et les use cases pour la gestion des avis, afin de pouvoir effectuer les operations CRUD sur les reviews depuis l'application.

## Criteres d'Acceptance (Gherkin)
- [ ] Given pro-A has 5 reviews in database When calling getReviewsForPro(proId: pro-A) Then a list of 5 Review entities should be returned And reviews should be ordered by createdAt descending
- [ ] Given pro-B has average rating 4.5 with 12 reviews When calling getRatingForPro(proId: pro-B) Then a ProRating entity should be returned And averageRating should be 4.5 And reviewCount should be 12
- [ ] Given bride-A is authenticated And bride-A has no review for pro-C When calling createReview(proId: pro-C, rating: 5, comment: "Excellent!") Then a Review entity should be returned And the review should be persisted in database
- [ ] Given bride-A has a 4-star review for pro-D When calling updateReview(reviewId: xxx, rating: 5) Then the review should be updated And updated_at should be refreshed
- [ ] Given bride-A has reviewed pro-E When calling hasReviewedPro(proId: pro-E) Then true should be returned
- [ ] Given bride-A has not reviewed pro-F When calling hasReviewedPro(proId: pro-F) Then false should be returned
- [ ] Given bride-A has a review for pro-G When calling getMyReviewForPro(proId: pro-G) Then the Review entity should be returned
- [ ] Given multiple proIds When calling getRatingsForPros(proIds) Then a Map<String, ProRating> should be returned with ratings for all pros that have reviews

## Fichiers Concernes
### A Creer
- `lib/features/reviews/domain/repositories/review_repository.dart`
- `lib/features/reviews/data/repositories/supabase_review_repository.dart`
- `lib/features/reviews/domain/usecases/get_reviews_for_pro.dart`
- `lib/features/reviews/domain/usecases/get_rating_for_pro.dart`
- `lib/features/reviews/domain/usecases/submit_review.dart`
- `lib/features/reviews/domain/usecases/update_review.dart`
- `test/features/reviews/data/repositories/supabase_review_repository_test.dart`
- `test/features/reviews/domain/usecases/submit_review_test.dart`

### A Modifier
- `lib/core/di/injection.dart` (register repository)

## Notes Techniques

### Repository Interface
```dart
abstract class ReviewRepository {
  Future<List<Review>> getReviewsForPro(String proId);
  Future<ProRating?> getRatingForPro(String proId);
  Future<Map<String, ProRating>> getRatingsForPros(List<String> proIds);
  Future<Review> createReview({
    required String proId,
    required int rating,
    String? comment,
  });
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  });
  Future<bool> hasReviewedPro(String proId);
  Future<Review?> getMyReviewForPro(String proId);
  Future<List<Review>> getMyReviews();
}
```

### Supabase Queries
```dart
// Get reviews with bride info
final response = await _client
    .from('reviews')
    .select('''
      *,
      profiles!reviews_bride_id_fkey(full_name, avatar_url)
    ''')
    .eq('pro_id', proId)
    .order('created_at', ascending: false);

// Get rating from view
final response = await _client
    .from('pro_ratings')
    .select()
    .eq('pro_id', proId)
    .maybeSingle();

// Batch get ratings
final response = await _client
    .from('pro_ratings')
    .select()
    .inFilter('pro_id', proIds);
```

### Error Handling
- Use Either<Failure, T> pattern for use cases
- Handle unique constraint violation gracefully (already reviewed)
- Handle RLS violation with user-friendly message

## Definition of Done
- [ ] ReviewRepository interface defini
- [ ] SupabaseReviewRepository implemente
- [ ] Use cases crees (GetReviewsForPro, GetRatingForPro, SubmitReview, UpdateReview)
- [ ] Repository enregistre dans DI container
- [ ] Tests unitaires avec mocks Supabase
- [ ] Tests integration sur branche Supabase (si dispo)
- [ ] `flutter test` passe
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (integration Supabase, gestion erreurs)

## Dependances
- S01: Table reviews must exist
- S02: View pro_ratings must exist
- S03: RLS policies must be in place
- S04: Review and ProRating entities must exist

## Stories Dependantes
- S06: UI submission (uses SubmitReview use case)
- S07: UI display (uses GetReviewsForPro, GetRatingForPro)
- S09: Map filter (uses getRatingsForPros for batch loading)
