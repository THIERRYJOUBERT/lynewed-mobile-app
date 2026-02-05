/// Supabase implementation of the MarketplaceRepository.
///
/// Handles CRUD operations for marketplace listings and photo management
/// through Supabase Database and Storage APIs.
library;

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/listing_filter.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/entities/marketplace_photo.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/marketplace_repository.dart';

/// Supabase-backed implementation of [MarketplaceRepository].
///
/// Uses Supabase tables `marketplace_listings` and `marketplace_photos`,
/// plus the `marketplace-listings` storage bucket for photo uploads.
class SupabaseMarketplaceRepository implements MarketplaceRepository {
  /// Creates a repository with the given Supabase client.
  SupabaseMarketplaceRepository(this._client);

  final SupabaseClient _client;

  /// Maximum title length allowed.
  static const int maxTitleLength = 255;

  /// Maximum number of photos per listing.
  static const int maxPhotos = 10;

  /// Validates listing data before insert.
  void _validateListing(MarketplaceListing listing) {
    if (listing.title.length > maxTitleLength) {
      throw ArgumentError(
        'Title must be less than $maxTitleLength characters',
      );
    }
    if (listing.priceCents <= 0) {
      throw ArgumentError('Price must be greater than 0');
    }
  }

  @override
  Future<MarketplaceListing> createListing(MarketplaceListing listing) async {
    _validateListing(listing);

    final json = listing.toJson();
    final response = await _client
        .from('marketplace_listings')
        .insert(json)
        .select()
        .single();

    return MarketplaceListing.fromJson(response);
  }

  @override
  Future<MarketplaceListing> updateListing(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _client
        .from('marketplace_listings')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return MarketplaceListing.fromJson(response);
  }

  @override
  Future<MarketplaceListing?> getListingById(String id) async {
    final response = await _client
        .from('marketplace_listings')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MarketplaceListing.fromJson(response);
  }

  @override
  Future<List<MarketplaceListing>> getMyListings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('marketplace_listings')
        .select()
        .eq('seller_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(MarketplaceListing.fromJson)
        .toList();
  }

  @override
  Future<List<String>> uploadListingPhotos({
    required String listingId,
    required List<Uint8List> photoBytes,
    required List<String> fileNames,
  }) async {
    if (photoBytes.length > maxPhotos) {
      throw ArgumentError('Maximum $maxPhotos photos allowed');
    }

    final storagePaths = <String>[];

    for (var i = 0; i < photoBytes.length; i++) {
      final fileName = fileNames[i];
      final storagePath = '$listingId/$fileName';

      await _client.storage
          .from('marketplace-listings')
          .uploadBinary(
            storagePath,
            photoBytes[i],
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      storagePaths.add(storagePath);
    }

    return storagePaths;
  }

  @override
  Future<void> saveListingPhotos({
    required String listingId,
    required List<MarketplacePhoto> photos,
  }) async {
    final rows = photos.map((photo) => photo.toJson()).toList();
    await _client.from('marketplace_photos').insert(rows);
  }

  @override
  Future<List<MarketplacePhoto>> getListingPhotos(String listingId) async {
    final response = await _client
        .from('marketplace_photos')
        .select()
        .eq('listing_id', listingId)
        .order('position');

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(MarketplacePhoto.fromJson)
        .toList();
  }

  @override
  Future<List<MarketplaceListing>> getListings({
    String? category,
    int page = 0,
    int pageSize = 20,
  }) async {
    // Apply filters before transform operations (order/range).
    var filterQuery = _client
        .from('marketplace_listings')
        .select('*, marketplace_photos(storage_path, position)')
        .eq('status', 'active');

    if (category != null) {
      filterQuery = filterQuery.eq('category', category);
    }

    final response = await filterQuery
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((json) {
      final listing = MarketplaceListing.fromJson(json);
      // If cover photo path is available, construct the public URL.
      if (listing.coverPhotoStoragePath != null) {
        final publicUrl = _client.storage
            .from('marketplace-listings')
            .getPublicUrl(listing.coverPhotoStoragePath!);
        return listing.copyWith(coverPhotoStoragePath: publicUrl);
      }
      return listing;
    }).toList();
  }

  @override
  Future<int> getListingsCount({String? category}) async {
    var query = _client
        .from('marketplace_listings')
        .select()
        .eq('status', 'active');

    if (category != null) {
      query = query.eq('category', category);
    }

    final response = await query.count(CountOption.exact);
    return response.count;
  }

  @override
  Future<SellerProfile?> getSellerInfo(String sellerId) async {
    // Query profiles table for seller name and avatar.
    final profileResponse = await _client
        .from('profiles')
        .select('id, display_name, photo_url')
        .eq('id', sellerId)
        .maybeSingle();

    if (profileResponse == null) return null;

    // Count active listings for this seller.
    // Default to 0 if count query fails to avoid losing the whole profile.
    var listingsCount = 0;
    try {
      final listingsResponse = await _client
          .from('marketplace_listings')
          .select('id')
          .eq('seller_id', sellerId)
          .eq('status', 'active');

      listingsCount = (listingsResponse as List<dynamic>).length;
    } catch (_) {
      // Silently default to 0 listings count.
    }

    return SellerProfile.fromJson({
      'id': profileResponse['id'] as String,
      'name': profileResponse['display_name'] as String? ?? 'Unknown',
      'avatar_url': profileResponse['photo_url'] as String?,
      'listings_count': listingsCount,
    });
  }

  @override
  Future<List<String>> getPhotoUrls(String listingId) async {
    final response = await _client
        .from('marketplace_photos')
        .select('storage_path')
        .eq('listing_id', listingId)
        .order('position');

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((row) {
      final storagePath = row['storage_path'] as String;
      return _client.storage
          .from('marketplace-listings')
          .getPublicUrl(storagePath);
    }).toList();
  }

  @override
  Future<List<MarketplaceListing>> getFilteredListings({
    required ListingFilter filter,
    int page = 0,
    int pageSize = 20,
  }) async {
    // Build base query with photo join.
    var query = _client
        .from('marketplace_listings')
        .select('*, marketplace_photos(storage_path, position)')
        .eq('status', 'active');

    // Apply filter criteria (AND logic).
    if (filter.category != null) {
      query = query.eq('category', filter.category!);
    }
    if (filter.minPriceCents != null) {
      query = query.gte('price_cents', filter.minPriceCents!);
    }
    if (filter.maxPriceCents != null) {
      query = query.lte('price_cents', filter.maxPriceCents!);
    }
    if (filter.sizes != null && filter.sizes!.isNotEmpty) {
      query = query.inFilter('size', filter.sizes!);
    }
    if (filter.brands != null && filter.brands!.isNotEmpty) {
      query = query.inFilter('designer_brand', filter.brands!);
    }
    if (filter.conditions != null && filter.conditions!.isNotEmpty) {
      query = query.inFilter('condition', filter.conditions!);
    }
    if (filter.country != null) {
      query = query.eq('country', filter.country!);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((json) {
      final listing = MarketplaceListing.fromJson(json);
      // Construct public URL for cover photo if available.
      if (listing.coverPhotoStoragePath != null) {
        final publicUrl = _client.storage
            .from('marketplace-listings')
            .getPublicUrl(listing.coverPhotoStoragePath!);
        return listing.copyWith(coverPhotoStoragePath: publicUrl);
      }
      return listing;
    }).toList();
  }

  @override
  Future<int> getFilteredListingsCount(ListingFilter filter) async {
    var query = _client
        .from('marketplace_listings')
        .select('id')
        .eq('status', 'active');

    // Apply same filters as getFilteredListings.
    if (filter.category != null) {
      query = query.eq('category', filter.category!);
    }
    if (filter.minPriceCents != null) {
      query = query.gte('price_cents', filter.minPriceCents!);
    }
    if (filter.maxPriceCents != null) {
      query = query.lte('price_cents', filter.maxPriceCents!);
    }
    if (filter.sizes != null && filter.sizes!.isNotEmpty) {
      query = query.inFilter('size', filter.sizes!);
    }
    if (filter.brands != null && filter.brands!.isNotEmpty) {
      query = query.inFilter('designer_brand', filter.brands!);
    }
    if (filter.conditions != null && filter.conditions!.isNotEmpty) {
      query = query.inFilter('condition', filter.conditions!);
    }
    if (filter.country != null) {
      query = query.eq('country', filter.country!);
    }

    final response = await query;
    return (response as List<dynamic>).length;
  }
}
