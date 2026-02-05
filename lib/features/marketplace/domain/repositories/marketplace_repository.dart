/// Abstract repository interface for marketplace listing operations.
///
/// Provides CRUD methods for marketplace listings and photo management.
/// Implementations handle Supabase database and storage interactions.
library;

import 'dart:typed_data';

import '../entities/listing_filter.dart';
import '../entities/marketplace_listing.dart';
import '../entities/marketplace_photo.dart';
import '../entities/seller_profile.dart';

/// Repository interface for marketplace operations.
///
/// Provides methods to create, read, update, and delete marketplace listings,
/// as well as manage listing photos in Supabase storage.
abstract class MarketplaceRepository {
  /// Creates a new listing in the database.
  ///
  /// Returns the created listing with generated ID and timestamps.
  /// Throws if validation fails or user is not authenticated.
  Future<MarketplaceListing> createListing(MarketplaceListing listing);

  /// Updates an existing listing with the given field updates.
  ///
  /// Only the owner can update (enforced by RLS).
  /// Returns the updated listing.
  Future<MarketplaceListing> updateListing(
    String id,
    Map<String, dynamic> updates,
  );

  /// Gets a listing by its ID.
  ///
  /// Returns null if not found or not accessible.
  Future<MarketplaceListing?> getListingById(String id);

  /// Gets all listings for the current authenticated user.
  ///
  /// Returns listings ordered by creation date (newest first).
  Future<List<MarketplaceListing>> getMyListings();

  /// Uploads listing photos to Supabase storage.
  ///
  /// Returns list of storage paths for the uploaded photos.
  /// Photos are uploaded to marketplace-listings/{listingId}/ bucket path.
  /// Max 10 photos per listing.
  Future<List<String>> uploadListingPhotos({
    required String listingId,
    required List<Uint8List> photoBytes,
    required List<String> fileNames,
  });

  /// Saves photo records to the marketplace_photos table.
  ///
  /// Creates MarketplacePhoto records with position ordering.
  Future<void> saveListingPhotos({
    required String listingId,
    required List<MarketplacePhoto> photos,
  });

  /// Gets photo records for a listing, ordered by position.
  Future<List<MarketplacePhoto>> getListingPhotos(String listingId);

  /// Gets active listings with pagination and optional category filter.
  ///
  /// Returns listings ordered by creation date (newest first).
  /// [category] can be 'dress', 'shoes', or null for all.
  /// [page] is 0-indexed, [pageSize] is typically 20.
  Future<List<MarketplaceListing>> getListings({
    String? category,
    int page = 0,
    int pageSize = 20,
  });

  /// Gets count of active listings with optional category filter.
  ///
  /// Used for empty state or stats.
  Future<int> getListingsCount({String? category});

  /// Gets public profile info for a seller.
  ///
  /// Returns seller name, avatar URL, and count of active listings.
  /// Returns null if the seller is not found.
  Future<SellerProfile?> getSellerInfo(String sellerId);

  /// Gets public URLs for all photos of a listing.
  ///
  /// Returns URLs ordered by position (0 = cover photo).
  /// Constructs public URLs from Supabase storage paths.
  Future<List<String>> getPhotoUrls(String listingId);

  /// Gets filtered listings with pagination.
  ///
  /// Returns listings matching ALL filter criteria (AND logic).
  /// [filter] specifies the active filters to apply.
  /// [page] is 0-indexed, [pageSize] defaults to 20.
  Future<List<MarketplaceListing>> getFilteredListings({
    required ListingFilter filter,
    int page = 0,
    int pageSize = 20,
  });

  /// Gets count of listings matching filter (for preview).
  ///
  /// Returns count without pagination for the preview badge.
  Future<int> getFilteredListingsCount(ListingFilter filter);

  /// Soft-deletes a listing by setting its status to 'deleted'.
  ///
  /// Only the owner can delete (enforced by RLS).
  Future<void> deleteListing(String id);
}
