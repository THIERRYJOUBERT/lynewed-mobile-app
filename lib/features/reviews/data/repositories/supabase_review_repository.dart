/// Supabase implementation of ReviewRepository
///
/// Uses SupabaseClient for all review data operations.
/// All queries respect RLS policies defined on the reviews table.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/pro_rating.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

/// Supabase implementation of [ReviewRepository].
///
/// Uses the Supabase client to fetch and modify reviews.
/// All operations respect RLS policies:
/// - Anyone can read reviews
/// - Only authenticated brides can create reviews
/// - Brides can only update their own reviews
class SupabaseReviewRepository implements ReviewRepository {
  /// Creates a SupabaseReviewRepository with the provided client.
  SupabaseReviewRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Select query for reviews with joined profile data.
  ///
  /// Uses the foreign key relationship `reviews_bride_id_fkey` to join
  /// the profiles table and retrieve the bride's display name and avatar.
  /// The `*` selects all columns from the reviews table.
  static const String _reviewSelectWithProfile = '''
    *,
    profiles!reviews_bride_id_fkey(full_name, avatar_url)
  ''';

  /// Gets the current authenticated user ID.
  ///
  /// Throws [StateError] if no user is authenticated.
  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user. Please log in to continue.');
    }
    return user.id;
  }

  @override
  Future<List<Review>> getReviewsForPro(String proId) async {
    final response = await _supabase
        .from('reviews')
        .select(_reviewSelectWithProfile)
        .eq('pro_id', proId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => parseReviewFromRow(row)).toList();
  }

  @override
  Future<ProRating?> getRatingForPro(String proId) async {
    final response = await _supabase
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

    final response = await _supabase
        .from('pro_ratings')
        .select()
        .inFilter('pro_id', proIds);

    final ratings = <String, ProRating>{};
    for (final row in response) {
      final rating = ProRating.fromJson(row);
      ratings[rating.proId] = rating;
    }
    return ratings;
  }

  @override
  Future<Review> createReview({
    required String proId,
    required int rating,
    String? comment,
  }) async {
    final brideId = _currentUserId;

    final response = await _supabase.from('reviews').insert({
      'pro_id': proId,
      'bride_id': brideId,
      'rating': rating,
      'comment': comment,
    }).select(_reviewSelectWithProfile).single();

    return parseReviewFromRow(response);
  }

  @override
  Future<Review> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    final response = await _supabase.from('reviews').update({
      'rating': rating,
      'comment': comment,
    }).eq('id', reviewId).select(_reviewSelectWithProfile).single();

    return parseReviewFromRow(response);
  }

  @override
  Future<bool> hasReviewedPro(String proId) async {
    final brideId = _currentUserId;

    final response = await _supabase
        .from('reviews')
        .select('id')
        .eq('pro_id', proId)
        .eq('bride_id', brideId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<Review?> getMyReviewForPro(String proId) async {
    final brideId = _currentUserId;

    final response = await _supabase
        .from('reviews')
        .select(_reviewSelectWithProfile)
        .eq('pro_id', proId)
        .eq('bride_id', brideId)
        .maybeSingle();

    if (response == null) return null;
    return parseReviewFromRow(response);
  }

  @override
  Future<List<Review>> getMyReviews() async {
    final brideId = _currentUserId;

    final response = await _supabase
        .from('reviews')
        .select(_reviewSelectWithProfile)
        .eq('bride_id', brideId)
        .order('created_at', ascending: false);

    return (response as List).map((row) => parseReviewFromRow(row)).toList();
  }

  /// Parses a review from a Supabase row with joined profile data.
  ///
  /// Handles the nested profiles object from the foreign key join.
  static Review parseReviewFromRow(Map<String, dynamic> row) {
    // Extract profile data from the joined profiles table
    final profiles = row['profiles'] as Map<String, dynamic>?;
    final brideName = profiles?['full_name'] as String?;
    final brideAvatarUrl = profiles?['avatar_url'] as String?;

    return Review(
      id: row['id'] as String,
      proId: row['pro_id'] as String,
      brideId: row['bride_id'] as String,
      rating: row['rating'] as int,
      comment: row['comment'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
      brideName: brideName,
      brideAvatarUrl: brideAvatarUrl,
    );
  }
}
