# EPIC-07-REVIEWS

> Resume : Systeme d'avis clients interne Lynewed pour noter les professionnels
> Status : 🔵 Draft
> Domaine : Backend / Database / Flutter / Map
> Cree le : 2026-01-28

---

## Contexte

### Pourquoi cet Epic

Les brides ont besoin de pouvoir evaluer les professionnels avec lesquels elles ont travaille. Ce systeme d'avis interne Lynewed (pas Google Places) permet de:

1. **Donner confiance** aux futures mariees via les retours d'experience
2. **Valoriser les pros** avec une note moyenne visible sur leur profil
3. **Filtrer efficacement** les pros sur la map par note minimum

**Etat actuel verifie en production (Supabase MCP, project_id: hekyovgnovhfhmkpfrna):**

| Element | Etat actuel | Action requise |
|---------|-------------|----------------|
| Table `reviews` | ABSENTE | Creer avec contraintes |
| Vue `pro_ratings` | ABSENTE | Creer pour moyenne/count |
| `MapFilter.minRating` | ABSENT | Ajouter au filtre |
| `professional_details` | 51 rows | Pas de modification |
| `profiles` | 254 rows | Source bride_id/pro_id |

**Impact attendu:**
- Brides peuvent laisser des avis (1-5 etoiles + commentaire)
- Pros voient leur note moyenne sur leur profil
- Visiteurs voient les avis sur la fiche pro
- Brides peuvent filtrer par note minimum sur la map

### Piliers Techniques Concernes

| Pilier | Implication pour cet Epic |
|--------|---------------------------|
| **Supabase Database** | Nouvelle table reviews, vue pro_ratings, RLS policies |
| **Flutter Domain** | Entites Review, ProRating |
| **Flutter Data** | ReviewRepository implementation |
| **Flutter Presentation** | UI soumission avis, affichage sur profil |
| **Map Feature** | Nouveau filtre minRating dans MapFilter |

---

## Architecture Cible

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SYSTEME D'AVIS CLIENTS (APP-01)                         │
│                                                                              │
│  TABLE reviews                                                               │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  id UUID PK                                                           │  │
│  │  pro_id UUID FK -> profiles(id)                                       │  │
│  │  bride_id UUID FK -> profiles(id)                                     │  │
│  │  rating INTEGER CHECK (1-5)                                           │  │
│  │  comment TEXT (optionnel)                                             │  │
│  │  created_at, updated_at TIMESTAMP                                     │  │
│  │  UNIQUE(pro_id, bride_id) -- Une bride = un seul avis par pro        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  VIEW pro_ratings                                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  pro_id UUID                                                          │  │
│  │  average_rating NUMERIC(2,1) -- ex: 4.5                               │  │
│  │  review_count INTEGER -- ex: 12                                       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  RLS POLICIES                                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  - Tout le monde peut lire les avis (SELECT)                          │  │
│  │  - Seule une bride peut creer un avis (INSERT)                        │  │
│  │  - La bride peut modifier son propre avis (UPDATE)                    │  │
│  │  - Personne ne peut supprimer les avis (pas de DELETE policy)         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  FLUTTER: MapFilter                                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  + final double? minRating; // 1.0 - 5.0, null = pas de filtre       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  FLUTTER: FilterSheet                                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  + Slider "Note minimum" avec etoiles (1-5)                           │  │
│  │  + Affichage: "4.5+ etoiles"                                          │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Stories

| # | Story | Domaine | Dep. | Criteres cles | Source PRD | Complexite |
|---|-------|---------|------|---------------|------------|------------|
| S01 | Creer table reviews avec contraintes | DB | - | Table creee, contraintes actives, index pro_id | APP-01 Section 4 | S |
| S02 | Creer vue pro_ratings pour moyenne | DB | S01 | Vue retourne average_rating et review_count | APP-01 Section 4 | S |
| S03 | Ajouter RLS policies pour reviews | DB | S01 | SELECT all, INSERT bride, UPDATE own | APP-01 Annexe D.1 | S |
| S04 | Creer entites Dart Review et ProRating | Flutter Domain | - | Entities immutables, fromJson/toJson | APP-01 | S |
| S05 | Implementer ReviewRepository et Use Cases | Flutter Data | S04 | CRUD operations, integration Supabase | APP-01 | M |
| S06 | Creer UI soumission avis (etoiles + commentaire) | Flutter UI | S05 | StarRating widget, TextArea, validation | APP-01 US-01.1, US-01.2 | M |
| S07 | Afficher avis sur profil pro | Flutter UI | S05 | Liste avis, note moyenne, "4.8/5 (12 avis)" | APP-01 US-01.3, US-01.4 | M |
| S08 | Ajouter minRating a MapFilter | Flutter Map | - | Champ ajoute, copyWith MAJ, == et hashCode | APP-01 US-01.5 | S |
| S09 | Mettre a jour requete map pour filtrer par rating | Flutter Map | S08 | RPC ou query filtre par minRating | APP-01 US-01.5 | M |

---

## Detail des Stories

### S01 : Creer table reviews avec contraintes

**Objectif** : Creer la table `reviews` avec toutes les contraintes de donnees.

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-01)

**Complexite** : S (Small) - Table simple avec contraintes

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Reviews table creation

  Scenario: Creating reviews table with correct structure
    Given the database schema
    When the migration create_reviews_table is applied
    Then table reviews should exist
    And it should have column id of type UUID with default gen_random_uuid()
    And it should have column pro_id of type UUID referencing profiles(id)
    And it should have column bride_id of type UUID referencing profiles(id)
    And it should have column rating of type INTEGER
    And it should have column comment of type TEXT
    And it should have column created_at of type TIMESTAMP with default NOW()
    And it should have column updated_at of type TIMESTAMP with default NOW()

  Scenario: Rating constraint enforced
    Given the reviews table exists
    When inserting a review with rating 0
    Then the insert should fail with constraint violation
    When inserting a review with rating 6
    Then the insert should fail with constraint violation
    When inserting a review with rating 3
    Then the insert should succeed

  Scenario: One review per bride per pro constraint
    Given a review exists from bride-A to pro-B
    When bride-A tries to insert another review for pro-B
    Then the insert should fail with unique constraint violation
    When bride-A inserts a review for pro-C
    Then the insert should succeed

  Scenario: Index on pro_id for performance
    Given the reviews table with 10000 reviews
    When querying reviews by pro_id
    Then the query should use index idx_reviews_pro_id
    And the query should execute in under 10ms
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100001_create_reviews_table
-- Description: Create reviews table for client ratings of professionals
-- Source: MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-01)

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pro_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  bride_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  rating INTEGER NOT NULL,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

  -- Constraints
  CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
  CONSTRAINT uq_one_review_per_bride_per_pro UNIQUE (pro_id, bride_id)
);

-- Index for fetching reviews by professional (common query)
CREATE INDEX IF NOT EXISTS idx_reviews_pro_id ON reviews(pro_id);

-- Index for fetching reviews by bride (my reviews)
CREATE INDEX IF NOT EXISTS idx_reviews_bride_id ON reviews(bride_id);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_reviews_updated_at();

-- Enable RLS (policies added in S03)
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Comments for documentation
COMMENT ON TABLE reviews IS 'Client reviews for professionals (1-5 stars, optional comment)';
COMMENT ON COLUMN reviews.rating IS 'Star rating from 1 to 5';
COMMENT ON COLUMN reviews.comment IS 'Optional text comment from bride';
COMMENT ON CONSTRAINT chk_rating_range ON reviews IS 'Ensures rating is between 1 and 5 inclusive';
COMMENT ON CONSTRAINT uq_one_review_per_bride_per_pro ON reviews IS 'One bride can only leave one review per professional';
```

**Rollback** :
```sql
-- Rollback: 20260128100001_create_reviews_table

DROP TRIGGER IF EXISTS trg_reviews_updated_at ON reviews;
DROP FUNCTION IF EXISTS update_reviews_updated_at;
DROP INDEX IF EXISTS idx_reviews_bride_id;
DROP INDEX IF EXISTS idx_reviews_pro_id;
DROP TABLE IF EXISTS reviews;
```

---

### S02 : Creer vue pro_ratings pour moyenne

**Objectif** : Creer une vue SQL qui calcule automatiquement la moyenne et le nombre d'avis par professionnel.

**Source** : MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-01)

**Complexite** : S (Small) - Vue simple avec aggregation

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Pro ratings view

  Scenario: View calculates average rating
    Given pro-A has reviews with ratings [5, 4, 4, 5]
    When selecting from pro_ratings where pro_id = pro-A
    Then average_rating should be 4.5
    And review_count should be 4

  Scenario: View handles single review
    Given pro-B has one review with rating 3
    When selecting from pro_ratings where pro_id = pro-B
    Then average_rating should be 3.0
    And review_count should be 1

  Scenario: Pro without reviews not in view
    Given pro-C has no reviews
    When selecting from pro_ratings where pro_id = pro-C
    Then no row should be returned

  Scenario: Average rounds to one decimal
    Given pro-D has reviews with ratings [5, 5, 4]
    When selecting from pro_ratings where pro_id = pro-D
    Then average_rating should be 4.7
    And review_count should be 3

  Scenario: View updates when reviews change
    Given pro-E has average_rating 4.0 from 2 reviews
    When a new 5-star review is added for pro-E
    Then average_rating should become 4.3
    And review_count should become 3
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100002_create_pro_ratings_view
-- Description: Create view for aggregated professional ratings
-- Source: MISSION-01-EVOLUTIONS-2026.md Section 4 (APP-01)

-- Create view for professional ratings aggregation
CREATE OR REPLACE VIEW pro_ratings AS
SELECT
  pro_id,
  ROUND(AVG(rating)::NUMERIC, 1) AS average_rating,
  COUNT(*)::INTEGER AS review_count
FROM reviews
GROUP BY pro_id;

-- Comment for documentation
COMMENT ON VIEW pro_ratings IS 'Aggregated ratings per professional (average + count)';

-- Note: For high-traffic scenarios, consider using a materialized view
-- with refresh on schedule or trigger-based update for better performance.
-- Current implementation uses a regular view for simplicity and real-time data.
```

**Rollback** :
```sql
-- Rollback: 20260128100002_create_pro_ratings_view

DROP VIEW IF EXISTS pro_ratings;
```

---

### S03 : Ajouter RLS policies pour reviews

**Objectif** : Configurer les Row Level Security policies pour controler l'acces aux avis.

**Source** : MISSION-01-EVOLUTIONS-2026.md Annexe D.1

**Complexite** : S (Small) - Policies RLS standards

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Reviews RLS policies

  Scenario: Anyone can read reviews
    Given a user authenticated as bride
    When selecting from reviews
    Then all reviews should be visible

    Given a user authenticated as professional
    When selecting from reviews
    Then all reviews should be visible

  Scenario: Bride can create review
    Given a user authenticated as bride-A
    When inserting a review with bride_id = bride-A
    Then the insert should succeed

  Scenario: Bride cannot create review for another bride
    Given a user authenticated as bride-A
    When inserting a review with bride_id = bride-B
    Then the insert should fail with RLS violation

  Scenario: Professional cannot create review
    Given a user authenticated as professional
    When inserting a review
    Then the insert should fail with RLS violation

  Scenario: Bride can update own review
    Given bride-A has a review for pro-X
    When bride-A updates that review
    Then the update should succeed

  Scenario: Bride cannot update another bride's review
    Given bride-B has a review for pro-X
    When bride-A tries to update that review
    Then the update should fail with RLS violation

  Scenario: No one can delete reviews
    Given a review exists
    When any user tries to delete it
    Then the delete should fail (no DELETE policy)
```

**Details techniques** :

**Migration SQL** :
```sql
-- Migration: 20260128100003_add_reviews_rls_policies
-- Description: Add RLS policies for reviews table
-- Source: MISSION-01-EVOLUTIONS-2026.md Annexe D.1

-- Ensure RLS is enabled (should already be from S01)
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Policy 1: Everyone can read all reviews
CREATE POLICY "Reviews readable by all"
ON reviews FOR SELECT
TO authenticated
USING (true);

-- Policy 2: Bride can create review (only for herself)
CREATE POLICY "Bride can create review"
ON reviews FOR INSERT
TO authenticated
WITH CHECK (
  bride_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role = 'bride'
  )
);

-- Policy 3: Bride can update own review
CREATE POLICY "Bride can update own review"
ON reviews FOR UPDATE
TO authenticated
USING (bride_id = auth.uid())
WITH CHECK (bride_id = auth.uid());

-- Note: No DELETE policy - reviews cannot be deleted
-- This is intentional for data integrity and trust

-- Comments for documentation
COMMENT ON POLICY "Reviews readable by all" ON reviews IS 'All authenticated users can read reviews';
COMMENT ON POLICY "Bride can create review" ON reviews IS 'Only brides can create reviews, and only for themselves';
COMMENT ON POLICY "Bride can update own review" ON reviews IS 'Brides can only update their own reviews';
```

**Rollback** :
```sql
-- Rollback: 20260128100003_add_reviews_rls_policies

DROP POLICY IF EXISTS "Bride can update own review" ON reviews;
DROP POLICY IF EXISTS "Bride can create review" ON reviews;
DROP POLICY IF EXISTS "Reviews readable by all" ON reviews;
```

---

### S04 : Creer entites Dart Review et ProRating

**Objectif** : Creer les entites de domaine immutables pour les avis et les notes agregees.

**Complexite** : S (Small) - Entites simples

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Review and ProRating entities

  Scenario: Review entity creation
    Given review data with id, proId, brideId, rating 5, comment "Great!"
    When creating a Review entity
    Then all properties should be accessible
    And the entity should be immutable

  Scenario: Review fromJson parsing
    Given valid JSON with all review fields
    When calling Review.fromJson
    Then a valid Review entity should be created
    And rating should be an integer between 1-5

  Scenario: Review toJson serialization
    Given a Review entity
    When calling toJson
    Then valid JSON should be produced
    And all fields should be present

  Scenario: ProRating entity creation
    Given proRating data with proId, averageRating 4.5, reviewCount 12
    When creating a ProRating entity
    Then all properties should be accessible
    And displayRating should return "4.5/5 (12 avis)"

  Scenario: ProRating fromJson parsing
    Given valid JSON from pro_ratings view
    When calling ProRating.fromJson
    Then a valid ProRating entity should be created
    And averageRating should be a double
```

**Details techniques** :

**Fichier** : `lib/features/reviews/domain/entities/review.dart`

```dart
/// Review entity - Client review for a professional
///
/// Represents a single review from a bride to a professional.
/// Rating is 1-5 stars, comment is optional.
library;

import 'package:flutter/foundation.dart';

/// Review entity for client ratings of professionals
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

  // Optional: Bride display info (from join)
  final String? brideName;
  final String? brideAvatarUrl;

  /// Has a text comment
  bool get hasComment => comment != null && comment!.isNotEmpty;

  /// Time since review was created
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} year${(diff.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Factory from Supabase response
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      proId: json['pro_id']?.toString() ?? '',
      brideId: json['bride_id']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      brideName: json['bride_name']?.toString() ?? json['profiles']?['full_name']?.toString(),
      brideAvatarUrl: json['bride_avatar_url']?.toString() ?? json['profiles']?['avatar_url']?.toString(),
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'pro_id': proId,
      'bride_id': brideId,
      'rating': rating,
      'comment': comment,
    };
  }

  /// Create a copy with updated fields
  Review copyWith({
    String? id,
    String? proId,
    String? brideId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brideName,
    String? brideAvatarUrl,
  }) {
    return Review(
      id: id ?? this.id,
      proId: proId ?? this.proId,
      brideId: brideId ?? this.brideId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brideName: brideName ?? this.brideName,
      brideAvatarUrl: brideAvatarUrl ?? this.brideAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
```

**Fichier** : `lib/features/reviews/domain/entities/pro_rating.dart`

```dart
/// ProRating entity - Aggregated rating for a professional
///
/// Represents the average rating and review count for a professional.
/// Used for display on profile and map filtering.
library;

import 'package:flutter/foundation.dart';

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

  /// Display string: "4.5/5 (12 avis)"
  String get displayRating {
    final count = reviewCount == 1 ? '1 review' : '$reviewCount reviews';
    return '${averageRating.toStringAsFixed(1)}/5 ($count)';
  }

  /// Short display: "4.5" with star icon
  String get shortRating => averageRating.toStringAsFixed(1);

  /// Has any reviews
  bool get hasReviews => reviewCount > 0;

  /// Factory from Supabase pro_ratings view
  factory ProRating.fromJson(Map<String, dynamic> json) {
    return ProRating(
      proId: json['pro_id']?.toString() ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Empty rating for pros without reviews
  factory ProRating.empty(String proId) {
    return ProRating(
      proId: proId,
      averageRating: 0.0,
      reviewCount: 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProRating && other.proId == proId;
  }

  @override
  int get hashCode => proId.hashCode;
}
```

---

### S05 : Implementer ReviewRepository et Use Cases

**Objectif** : Implementer le repository et les use cases pour la gestion des avis.

**Complexite** : M (Medium) - Repository avec CRUD + use cases

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Review repository and use cases

  Scenario: Get reviews for professional
    Given pro-A has 5 reviews in database
    When calling getReviewsForPro(proId: pro-A)
    Then a list of 5 Review entities should be returned
    And reviews should be ordered by createdAt descending

  Scenario: Get rating for professional
    Given pro-B has average rating 4.5 with 12 reviews
    When calling getRatingForPro(proId: pro-B)
    Then a ProRating entity should be returned
    And averageRating should be 4.5
    And reviewCount should be 12

  Scenario: Create new review
    Given bride-A is authenticated
    And bride-A has no review for pro-C
    When calling createReview(proId: pro-C, rating: 5, comment: "Excellent!")
    Then a Review entity should be returned
    And the review should be persisted in database

  Scenario: Update existing review
    Given bride-A has a 4-star review for pro-D
    When calling updateReview(reviewId: xxx, rating: 5)
    Then the review should be updated
    And updated_at should be refreshed

  Scenario: Check if bride has reviewed pro
    Given bride-A has reviewed pro-E
    When calling hasReviewedPro(proId: pro-E)
    Then true should be returned

    Given bride-A has not reviewed pro-F
    When calling hasReviewedPro(proId: pro-F)
    Then false should be returned

  Scenario: Get my review for pro
    Given bride-A has a review for pro-G
    When calling getMyReviewForPro(proId: pro-G)
    Then the Review entity should be returned

  Scenario: Submit review use case
    Given bride-B wants to review pro-H
    When executing SubmitReview use case
    Then the review should be created
    And the pro's average rating should update
```

**Details techniques** :

**Fichier** : `lib/features/reviews/domain/repositories/review_repository.dart`

```dart
/// Review repository interface
library;

import '../entities/review.dart';
import '../entities/pro_rating.dart';

/// Repository for review operations
abstract class ReviewRepository {
  /// Get all reviews for a professional (ordered by created_at DESC)
  Future<List<Review>> getReviewsForPro(String proId);

  /// Get aggregated rating for a professional
  Future<ProRating?> getRatingForPro(String proId);

  /// Get ratings for multiple professionals (batch)
  Future<Map<String, ProRating>> getRatingsForPros(List<String> proIds);

  /// Create a new review
  Future<Review> createReview({
    required String proId,
    required int rating,
    String? comment,
  });

  /// Update an existing review
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  });

  /// Check if current user has reviewed a professional
  Future<bool> hasReviewedPro(String proId);

  /// Get current user's review for a professional (if exists)
  Future<Review?> getMyReviewForPro(String proId);

  /// Get all reviews by current user
  Future<List<Review>> getMyReviews();
}
```

**Fichier** : `lib/features/reviews/data/repositories/supabase_review_repository.dart`

```dart
/// Supabase implementation of ReviewRepository
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/review.dart';
import '../../domain/entities/pro_rating.dart';
import '../../domain/repositories/review_repository.dart';

/// Supabase-backed review repository
class SupabaseReviewRepository implements ReviewRepository {
  SupabaseReviewRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser?.id ?? '';

  @override
  Future<List<Review>> getReviewsForPro(String proId) async {
    final response = await _client
        .from('reviews')
        .select('''
          *,
          profiles!reviews_bride_id_fkey(full_name, avatar_url)
        ''')
        .eq('pro_id', proId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProRating?> getRatingForPro(String proId) async {
    final response = await _client
        .from('pro_ratings')
        .select()
        .eq('pro_id', proId)
        .maybeSingle();

    if (response == null) return null;
    return ProRating.fromJson(response);
  }

  @override
  Future<Map<String, ProRating>> getRatingsForPros(List<String> proIds) async {
    if (proIds.isEmpty) return {};

    final response = await _client
        .from('pro_ratings')
        .select()
        .inFilter('pro_id', proIds);

    final result = <String, ProRating>{};
    for (final json in response as List) {
      final rating = ProRating.fromJson(json as Map<String, dynamic>);
      result[rating.proId] = rating;
    }
    return result;
  }

  @override
  Future<Review> createReview({
    required String proId,
    required int rating,
    String? comment,
  }) async {
    final response = await _client.from('reviews').insert({
      'pro_id': proId,
      'bride_id': _userId,
      'rating': rating,
      'comment': comment,
    }).select().single();

    return Review.fromJson(response);
  }

  @override
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final response = await _client
        .from('reviews')
        .update({
          'rating': rating,
          'comment': comment,
        })
        .eq('id', reviewId)
        .eq('bride_id', _userId) // RLS enforcement
        .select()
        .single();

    return Review.fromJson(response);
  }

  @override
  Future<bool> hasReviewedPro(String proId) async {
    final response = await _client
        .from('reviews')
        .select('id')
        .eq('pro_id', proId)
        .eq('bride_id', _userId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<Review?> getMyReviewForPro(String proId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('pro_id', proId)
        .eq('bride_id', _userId)
        .maybeSingle();

    if (response == null) return null;
    return Review.fromJson(response);
  }

  @override
  Future<List<Review>> getMyReviews() async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('bride_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
```

---

### S06 : Creer UI soumission avis (etoiles + commentaire)

**Objectif** : Creer l'interface utilisateur pour soumettre un avis avec notation par etoiles et commentaire optionnel.

**Complexite** : M (Medium) - Widgets custom + formulaire

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Review submission UI

  Scenario: Star rating widget displays correctly
    Given the ReviewSubmitSheet is open
    When the user sees the star rating widget
    Then 5 empty stars should be displayed
    And stars should be tappable

  Scenario: User can select rating
    Given the ReviewSubmitSheet is open
    When the user taps the 4th star
    Then stars 1-4 should be filled
    And star 5 should be empty
    And the rating value should be 4

  Scenario: User can change rating
    Given the user has selected 3 stars
    When the user taps the 5th star
    Then all 5 stars should be filled
    And the rating value should be 5

  Scenario: Comment field is optional
    Given the user has selected a rating
    When the comment field is empty
    Then the submit button should be enabled

  Scenario: Submit button requires rating
    Given the ReviewSubmitSheet is open
    When no rating is selected
    Then the submit button should be disabled

  Scenario: Successful review submission
    Given the user has selected 5 stars
    And the user has entered "Amazing photographer!"
    When the user taps Submit
    Then the review should be saved
    And the sheet should close
    And a success message should be shown

  Scenario: Edit existing review
    Given the user has already reviewed this pro
    When opening the review sheet
    Then the existing rating should be pre-filled
    And the existing comment should be pre-filled
    And the button text should be "Update Review"
```

**Details techniques** :

**Fichier** : `lib/features/reviews/presentation/widgets/star_rating_input.dart`

```dart
/// Star rating input widget for review submission
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Interactive star rating input
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isFilled = starNumber <= rating;

        return GestureDetector(
          onTap: () => onRatingChanged(starNumber),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: isFilled ? starColor : emptyColor,
            ),
          ),
        );
      }),
    );
  }
}

/// Read-only star rating display
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 16.0,
    this.starColor = LynewedColors.primary,
    this.emptyColor = LynewedColors.gray300,
    this.showValue = true,
  });

  final double rating;
  final double starSize;
  final Color starColor;
  final Color emptyColor;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          final fillAmount = (rating - index).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: _buildStar(fillAmount),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: LynewedTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStar(double fillAmount) {
    if (fillAmount >= 1.0) {
      return Icon(Icons.star_rounded, size: starSize, color: starColor);
    } else if (fillAmount > 0) {
      return Stack(
        children: [
          Icon(Icons.star_outline_rounded, size: starSize, color: emptyColor),
          ClipRect(
            clipper: _HalfClipper(fillAmount),
            child: Icon(Icons.star_rounded, size: starSize, color: starColor),
          ),
        ],
      );
    } else {
      return Icon(Icons.star_outline_rounded, size: starSize, color: emptyColor);
    }
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  _HalfClipper(this.fillAmount);
  final double fillAmount;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fillAmount, size.height);
  }

  @override
  bool shouldReclip(_HalfClipper oldClipper) => fillAmount != oldClipper.fillAmount;
}
```

**Fichier** : `lib/features/reviews/presentation/sheets/review_submit_sheet.dart`

```dart
/// Review submission sheet
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/review.dart';
import '../widgets/star_rating_input.dart';

/// Bottom sheet for submitting or editing a review
class ReviewSubmitSheet extends StatefulWidget {
  const ReviewSubmitSheet({
    super.key,
    required this.proId,
    required this.proName,
    this.existingReview,
    required this.onSubmit,
  });

  final String proId;
  final String proName;
  final Review? existingReview;
  final Future<void> Function(int rating, String? comment) onSubmit;

  @override
  State<ReviewSubmitSheet> createState() => _ReviewSubmitSheetState();
}

class _ReviewSubmitSheetState extends State<ReviewSubmitSheet> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingReview != null;
  bool get _canSubmit => _rating > 0 && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(LynewedSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LynewedColors.gray200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: LynewedSpacing.lg),

              // Title
              Text(
                _isEditing ? 'Edit your review' : 'Review ${widget.proName}',
                style: LynewedTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LynewedSpacing.xl),

              // Star rating
              Center(
                child: StarRatingInput(
                  rating: _rating,
                  onRatingChanged: (value) => setState(() => _rating = value),
                  starSize: 48,
                ),
              ),
              const SizedBox(height: LynewedSpacing.sm),

              // Rating label
              Center(
                child: Text(
                  _getRatingLabel(_rating),
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: LynewedSpacing.xl),

              // Comment field
              Text(
                'Comment (optional)',
                style: LynewedTextStyles.labelMedium,
              ),
              const SizedBox(height: LynewedSpacing.sm),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: LynewedColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: LynewedColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: LynewedColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: LynewedSpacing.xl),

              // Submit button
              SizedBox(
                height: LynewedSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _handleSubmit : null,
                  style: LynewedComponentStyles.primaryButton(),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Review' : 'Submit Review',
                          style: LynewedTextStyles.buttonPrimary,
                        ),
                ),
              ),
              const SizedBox(height: LynewedSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final comment = _commentController.text.trim();
      await widget.onSubmit(_rating, comment.isEmpty ? null : comment);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
```

---

### S07 : Afficher avis sur profil pro

**Objectif** : Afficher la note moyenne et la liste des avis sur la fiche profil d'un professionnel.

**Complexite** : M (Medium) - Integration UI existante + liste

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Reviews display on professional profile

  Scenario: Rating summary displayed
    Given pro-A has average rating 4.5 with 12 reviews
    When viewing pro-A's profile
    Then "4.5/5 (12 reviews)" should be displayed
    And 4.5 stars should be visually shown

  Scenario: Reviews list displayed
    Given pro-B has 5 reviews
    When expanding the reviews section
    Then all 5 reviews should be listed
    And each review should show bride name, rating, comment, and date

  Scenario: Empty reviews state
    Given pro-C has no reviews
    When viewing pro-C's profile
    Then "No reviews yet" message should be displayed
    And the rating summary should show "Not rated"

  Scenario: Bride can leave review from profile
    Given bride is viewing pro-D's profile
    And bride has not reviewed pro-D
    When tapping "Write a review" button
    Then the ReviewSubmitSheet should open

  Scenario: Bride sees edit option for own review
    Given bride has already reviewed pro-E
    When viewing pro-E's profile
    Then "Edit your review" button should be displayed instead of "Write a review"
```

**Details techniques** :

**Fichier** : `lib/features/reviews/presentation/widgets/reviews_section.dart`

```dart
/// Reviews section widget for professional profile
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/pro_rating.dart';
import 'star_rating_input.dart';

/// Section displaying reviews for a professional
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with rating summary
        _buildHeader(),
        const SizedBox(height: LynewedSpacing.md),

        // Write/Edit review button
        if (onWriteReview != null || onEditReview != null)
          _buildActionButton(),

        const SizedBox(height: LynewedSpacing.lg),

        // Reviews list
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (reviews.isEmpty)
          _buildEmptyState()
        else
          _buildReviewsList(),
      ],
    );
  }

  Widget _buildHeader() {
    if (rating == null || !rating!.hasReviews) {
      return Row(
        children: [
          const StarRatingDisplay(rating: 0, showValue: false),
          const SizedBox(width: LynewedSpacing.sm),
          Text(
            'Not rated yet',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        StarRatingDisplay(rating: rating!.averageRating),
        const SizedBox(width: LynewedSpacing.sm),
        Text(
          '(${rating!.reviewCount} ${rating!.reviewCount == 1 ? 'review' : 'reviews'})',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    final hasReview = myReview != null;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: hasReview ? onEditReview : onWriteReview,
        icon: Icon(hasReview ? Icons.edit_outlined : Icons.rate_review_outlined),
        label: Text(hasReview ? 'Edit your review' : 'Write a review'),
        style: OutlinedButton.styleFrom(
          foregroundColor: LynewedColors.primary,
          side: const BorderSide(color: LynewedColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(LynewedSpacing.lg),
      decoration: BoxDecoration(
        color: LynewedColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.reviews_outlined,
              size: 48,
              color: LynewedColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: LynewedSpacing.sm),
            Text(
              'No reviews yet',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: LynewedSpacing.xs),
            Text(
              'Be the first to leave a review!',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      children: reviews.map((review) => _ReviewCard(review: review)).toList(),
    );
  }
}

/// Individual review card
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: LynewedSpacing.md),
      padding: const EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Date
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: LynewedColors.primary.withOpacity(0.1),
                backgroundImage: review.brideAvatarUrl != null
                    ? NetworkImage(review.brideAvatarUrl!)
                    : null,
                child: review.brideAvatarUrl == null
                    ? Text(
                        (review.brideName ?? 'A')[0].toUpperCase(),
                        style: LynewedTextStyles.labelMedium.copyWith(
                          color: LynewedColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: LynewedSpacing.sm),

              // Name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.brideName ?? 'Anonymous',
                      style: LynewedTextStyles.labelMedium,
                    ),
                    Text(
                      review.timeAgo,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating
              StarRatingDisplay(
                rating: review.rating.toDouble(),
                starSize: 14,
                showValue: false,
              ),
            ],
          ),

          // Comment
          if (review.hasComment) ...[
            const SizedBox(height: LynewedSpacing.sm),
            Text(
              review.comment!,
              style: LynewedTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

### S08 : Ajouter minRating a MapFilter

**Objectif** : Ajouter le champ `minRating` a l'entite `MapFilter` pour permettre le filtrage par note minimum.

**Complexite** : S (Small) - Modification entite simple

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: MapFilter minRating field

  Scenario: MapFilter has minRating field
    Given the MapFilter entity
    When creating a MapFilter with minRating: 4.0
    Then minRating should be accessible and equal to 4.0

  Scenario: minRating is nullable
    Given a MapFilter without minRating specified
    When accessing minRating
    Then it should be null (no filter)

  Scenario: copyWith updates minRating
    Given a MapFilter with minRating: 3.0
    When calling copyWith(minRating: 4.5)
    Then the new filter should have minRating: 4.5

  Scenario: equality considers minRating
    Given two MapFilters with same properties but different minRating
    When comparing them
    Then they should not be equal

  Scenario: defaults has no minRating
    Given MapFilter.defaults
    When checking minRating
    Then it should be null

  Scenario: hasRatingFilter property
    Given a MapFilter with minRating: 4.0
    When checking hasRatingFilter
    Then it should return true

    Given a MapFilter without minRating
    When checking hasRatingFilter
    Then it should return false
```

**Details techniques** :

Modification du fichier existant `lib/features/map/domain/entities/map_filter.dart` :

```dart
// Ajouter dans la classe MapFilter:

/// Note minimum pour filtrer les pros (1.0 - 5.0)
final double? minRating;

// Dans le constructeur:
this.minRating,

// Dans copyWith:
double? minRating,
// ...
minRating: minRating ?? this.minRating,

// Nouvelle propriete:
/// Verifie si un filtre de note est actif
bool get hasRatingFilter => minRating != null && minRating! > 0;

// Dans == operator:
other.minRating == minRating &&

// Dans hashCode:
minRating,
```

---

### S09 : Mettre a jour requete map pour filtrer par rating

**Objectif** : Modifier la requete de la map pour filtrer les professionnels par note minimum.

**Complexite** : M (Medium) - Modification RPC ou logique cote client

**Criteres d'acceptance (Gherkin)** :

```gherkin
Feature: Map filtering by rating

  Scenario: Filter sheet shows rating slider
    Given the filter sheet is open
    When viewing the filters
    Then a "Minimum rating" slider should be visible
    And it should range from 1 to 5 stars

  Scenario: Selecting minimum rating
    Given the filter sheet is open
    When setting minimum rating to 4.0
    And applying filters
    Then only professionals with average_rating >= 4.0 should be shown

  Scenario: No rating filter by default
    Given default MapFilter
    When loading map markers
    Then all professionals should be shown regardless of rating

  Scenario: Professionals without reviews are hidden when filtering
    Given minRating filter is set to 3.0
    And pro-A has no reviews (not in pro_ratings view)
    When loading map markers
    Then pro-A should NOT be shown

  Scenario: Filter updates marker count
    Given 50 professionals on the map
    And 30 have rating >= 4.0
    When setting minRating to 4.0
    Then only 30 markers should be displayed

  Scenario: Clear rating filter shows all pros
    Given minRating filter was set to 4.5
    When clearing the rating filter (reset)
    Then all professionals should be shown again
```

**Details techniques** :

**Option 1: Filtrage cote RPC (recommande)**

Modifier la RPC `search_map_bundle` pour accepter le parametre `minRating` :

```sql
-- Modification de search_map_bundle pour supporter minRating
-- A ajouter dans le filtre des pros

-- Dans la section WHERE des pros:
AND (
  p_filters->>'minRating' IS NULL
  OR EXISTS (
    SELECT 1 FROM pro_ratings pr
    WHERE pr.pro_id = profiles.id
    AND pr.average_rating >= (p_filters->>'minRating')::NUMERIC
  )
)
```

**Option 2: Filtrage cote client (fallback)**

Si la RPC ne peut pas etre modifiee, filtrer cote client :

```dart
// Dans supabase_map_datasource.dart

Future<Map<String, dynamic>> searchMapBundle({
  // ... params existants
}) async {
  // Appel RPC existant
  final response = await _client.rpc('search_map_bundle', params: { ... });

  // Si minRating est specifie, filtrer cote client
  if (filter.minRating != null) {
    final proIds = _extractProIds(response);
    final ratings = await _getRatingsForPros(proIds);
    response['markers'] = _filterByRating(response['markers'], ratings, filter.minRating!);
  }

  return response;
}
```

**Modification du FilterSheet** :

Ajouter dans `filter_sheet.dart` une section pour le filtre de note :

```dart
// Dans _FilterSheetState:
double? _minRating;

// Dans build, ajouter une section:
_buildSection(
  title: 'Minimum rating',
  child: _buildRatingSlider(),
),

Widget _buildRatingSlider() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StarRatingDisplay(
            rating: _minRating ?? 0,
            starSize: 24,
            showValue: false,
          ),
          Text(
            _minRating != null
                ? '${_minRating!.toStringAsFixed(1)}+ stars'
                : 'Any rating',
            style: LynewedTextStyles.bodyMedium,
          ),
        ],
      ),
      Slider(
        value: _minRating ?? 0,
        min: 0,
        max: 5,
        divisions: 10,
        onChanged: (value) {
          setState(() {
            _minRating = value > 0 ? value : null;
            _filter = _filter.copyWith(minRating: _minRating);
          });
        },
      ),
    ],
  );
}
```

---

## Risques et Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Reviews biaisees (faux avis) | MOYEN - Confiance entamee | Contrainte UNIQUE bride/pro, moderation future |
| Performance vue pro_ratings | FAIBLE - Lenteur aggregation | Vue simple pour MVP, materialized view si besoin |
| Spam commentaires | MOYEN - UX degradee | Limite 500 chars, moderation future |
| Manipulation note | HAUT - Note artificielle | Une bride = un avis par pro, pas de suppression |
| RPC modification complexe | MOYEN - Delai implementation | Option fallback client-side |
| Migration FK sur profiles | FAIBLE - Erreur si profile supprime | ON DELETE CASCADE |

---

## RLS Policies Summary (Decision D-16)

| Table | Policy | Access |
|-------|--------|--------|
| `reviews` | "Reviews readable by all" | SELECT pour tous authenticated |
| `reviews` | "Bride can create review" | INSERT bride uniquement, pour elle-meme |
| `reviews` | "Bride can update own review" | UPDATE bride sur ses propres avis |
| `reviews` | (pas de DELETE policy) | Avis non supprimables |
| `pro_ratings` | (vue, pas de RLS) | Accessible via SELECT sur reviews |

---

## Ordre d'Execution Recommande

```
S01 (table reviews) ──┬── S02 (vue pro_ratings) ── S03 (RLS policies)
                      │
                      └── S04 (entities Dart)
                           │
                           └── S05 (repository) ──┬── S06 (UI submit)
                                                  │
                                                  └── S07 (UI display)

S08 (MapFilter.minRating) ── S09 (query map filter)
```

**Ordre sequentiel recommande:**
1. S01 - Table reviews (prerequis pour tout)
2. S02 - Vue pro_ratings (depend de S01)
3. S03 - RLS policies (depend de S01)
4. S04 - Entities Dart (peut etre fait en parallele avec S01-S03)
5. S05 - Repository (depend de S04)
6. S06 - UI soumission (depend de S05)
7. S07 - UI affichage (depend de S05)
8. S08 - MapFilter.minRating (independant)
9. S09 - Query map filter (depend de S08 et S02)

---

## References PRD

| Section PRD | Contenu utilise |
|-------------|-----------------|
| Section 4 (APP-01) | Specification complete du systeme d'avis |
| Section 4 US-01.1 | Bride peut noter un pro (1 a 5 etoiles) |
| Section 4 US-01.2 | Bride peut laisser un commentaire |
| Section 4 US-01.3 | Pro voit sa note moyenne sur son profil |
| Section 4 US-01.4 | Visiteur voit avis et note moyenne sur fiche pro |
| Section 4 US-01.5 | Bride peut filtrer les pros par note sur la map |
| Annexe D.1 | RLS policies pour reviews |
| Decision D-16 | RLS obligatoires AVANT toute table |

---

## Prochaine Etape

Apres validation de cet Epic:
1. Executer les migrations S01-S03 sur branche de developpement Supabase
2. Implementer les entites et repository Dart (S04-S05)
3. Creer les widgets UI (S06-S07)
4. Integrer le filtre dans la map (S08-S09)
5. Tests unitaires et integration
6. Validation sur branche Supabase avant merge production
7. Passer a EPIC-08 (APP-02 Notifications de rappel RDV)
