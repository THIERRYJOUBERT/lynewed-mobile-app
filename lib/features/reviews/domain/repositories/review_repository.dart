/// Review repository interface
///
/// Defines the contract for review data operations.
/// Implementations can be Supabase, mock, or cached.
library;

import '../entities/pro_rating.dart';
import '../entities/review.dart';

/// Repository interface for review operations.
///
/// Provides methods to read and write reviews for wedding professionals.
/// All methods respect RLS policies (bride can only create/update own reviews).
abstract class ReviewRepository {
  /// Gets all reviews for a professional.
  ///
  /// Returns reviews ordered by creation date (newest first).
  /// Includes bride name and avatar from joined profiles table.
  Future<List<Review>> getReviewsForPro(String proId);

  /// Gets the aggregated rating for a professional.
  ///
  /// Returns null if the professional has no reviews.
  /// Uses the pro_ratings view for efficient aggregation.
  Future<ProRating?> getRatingForPro(String proId);

  /// Gets ratings for multiple professionals in batch.
  ///
  /// Returns a map of proId -> ProRating for pros that have reviews.
  /// Pros without reviews will not be in the map.
  Future<Map<String, ProRating>> getRatingsForPros(List<String> proIds);

  /// Creates a new review for a professional.
  ///
  /// The current authenticated user (bride) is automatically set as the reviewer.
  /// Throws if no user is authenticated.
  /// Throws if the bride has already reviewed this professional.
  Future<Review> createReview({
    required String proId,
    required int rating,
    String? comment,
  });

  /// Updates an existing review.
  ///
  /// Only the owner of the review can update it (enforced by RLS).
  /// Returns the updated review with refreshed updated_at timestamp.
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  });

  /// Checks if the current user has reviewed a professional.
  ///
  /// Throws if no user is authenticated.
  Future<bool> hasReviewedPro(String proId);

  /// Gets the current user's review for a professional.
  ///
  /// Returns null if the user hasn't reviewed this professional.
  /// Throws if no user is authenticated.
  Future<Review?> getMyReviewForPro(String proId);

  /// Gets all reviews by the current user.
  ///
  /// Returns reviews ordered by creation date (newest first).
  /// Throws if no user is authenticated.
  Future<List<Review>> getMyReviews();
}
