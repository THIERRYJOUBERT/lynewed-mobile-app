# Story S04: Create Dart entities Review and ProRating

## Description
En tant que developpeur Flutter, je veux creer les entites de domaine `Review` et `ProRating` immutables, afin de representer les avis et les notes agregees dans l'application.

## Criteres d'Acceptance (Gherkin)
- [ ] Given review data with id, proId, brideId, rating 5, comment "Great!" When creating a Review entity Then all properties should be accessible And the entity should be immutable (@immutable annotation)
- [ ] Given valid JSON with all review fields When calling Review.fromJson Then a valid Review entity should be created And rating should be an integer between 1-5
- [ ] Given a Review entity When calling toJson Then valid JSON should be produced And all insert fields should be present (pro_id, bride_id, rating, comment)
- [ ] Given proRating data with proId, averageRating 4.5, reviewCount 12 When creating a ProRating entity Then all properties should be accessible And displayRating should return "4.5/5 (12 reviews)"
- [ ] Given valid JSON from pro_ratings view When calling ProRating.fromJson Then a valid ProRating entity should be created And averageRating should be a double
- [ ] Given a Review entity When accessing timeAgo property Then a human-readable time difference should be returned
- [ ] Given ProRating.empty(proId) When checking hasReviews Then it should return false

## Fichiers Concernes
### A Creer
- `lib/features/reviews/domain/entities/review.dart`
- `lib/features/reviews/domain/entities/pro_rating.dart`
- `test/features/reviews/domain/entities/review_test.dart`
- `test/features/reviews/domain/entities/pro_rating_test.dart`

### A Modifier
- Aucun

## Notes Techniques

### Review Entity
```dart
/// Review entity - Client review for a professional
@immutable
class Review {
  const Review({
    required this.id,
    required this.proId,
    required this.brideId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.brideName,
    this.brideAvatarUrl,
  });

  final String id;
  final String proId;
  final String brideId;
  final int rating; // 1-5
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? brideName;
  final String? brideAvatarUrl;

  bool get hasComment => comment != null && comment!.isNotEmpty;
  String get timeAgo { /* ... */ }

  factory Review.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  Review copyWith({...});

  @override
  bool operator ==(Object other);
  @override
  int get hashCode;
}
```

### ProRating Entity
```dart
/// Aggregated rating for a professional
@immutable
class ProRating {
  const ProRating({
    required this.proId,
    required this.averageRating,
    required this.reviewCount,
  });

  final String proId;
  final double averageRating; // 1.0 - 5.0
  final int reviewCount;

  String get displayRating; // "4.5/5 (12 reviews)"
  String get shortRating;   // "4.5"
  bool get hasReviews;

  factory ProRating.fromJson(Map<String, dynamic> json);
  factory ProRating.empty(String proId);

  @override
  bool operator ==(Object other);
  @override
  int get hashCode;
}
```

### Test Patterns
```dart
group('Review', () {
  test('should create from JSON', () {
    final json = {
      'id': 'test-id',
      'pro_id': 'pro-123',
      'bride_id': 'bride-456',
      'rating': 5,
      'comment': 'Excellent!',
      'created_at': '2026-01-28T10:00:00Z',
    };
    final review = Review.fromJson(json);
    expect(review.rating, 5);
    expect(review.hasComment, true);
  });
});
```

## Definition of Done
- [ ] Review entity cree avec toutes les proprietes
- [ ] ProRating entity cree avec toutes les proprietes
- [ ] fromJson/toJson fonctionnent correctement
- [ ] copyWith fonctionne pour Review
- [ ] == et hashCode implementes
- [ ] Tests unitaires pour Review (>90% coverage)
- [ ] Tests unitaires pour ProRating (>90% coverage)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances
- Aucune (peut etre fait en parallele de S01-S03)

## Stories Dependantes
- S05: Repository implementation (uses these entities)
- S06: UI submission (uses Review entity)
- S07: UI display (uses Review and ProRating entities)
