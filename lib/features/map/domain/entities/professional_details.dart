/// Professional details entity for map marker details
/// 
/// Complete professional profile data for display in details sheet.
/// Replaces FlutterFlow's ProDetailsStruct with clean, immutable class.
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '/core/utils/budget_formatter.dart';
import '/core/utils/distance_formatter.dart';

/// Profession enum - aligned with backend Supabase enum (20 values)
/// Backend values: PHOTOGRAPHER, FILMMAKER, PLANNER, MAKEUP, HAIRDRESSER, 
/// DESIGNER, BRIDALDESIGNER, VENUE, BRIDALSHOP, FLORIST, PHOTOMOVIE, 
/// MAKEUPARTIST, EVENTDESIGNER, OTHER
/// + 6 new market-specific professions:
/// Global (everywhere): MUSIC, STATIONERY
/// India-only: CATERER, BRIDALWEARDESIGNER
/// Global-only (not India): JEWELLER, CONTENTCREATOR
enum Profession {
  photographer,
  filmmaker,
  planner,
  makeup,
  hairdresser,
  designer,
  bridalDesigner,
  venue,
  bridalShop,
  florist,
  photoMovie,
  makeupArtist,
  eventDesigner,
  other,
  // Global professions (available everywhere)
  music,
  stationery,
  // India-only professions
  caterer,
  bridalWearDesigner,
  // Global-only professions (not in India)
  jeweller,
  contentCreator;

  String get displayName {
    switch (this) {
      case Profession.photographer:
        return 'Photographer';
      case Profession.filmmaker:
        return 'Filmmaker';
      case Profession.planner:
        return 'Wedding Planner';
      case Profession.makeup:
        return 'Makeup';
      case Profession.hairdresser:
        return 'Hairdresser';
      case Profession.designer:
        return 'Designer';
      case Profession.bridalDesigner:
        return 'Bridal Designer';
      case Profession.venue:
        return 'Venue';
      case Profession.bridalShop:
        return 'Bridal Shop';
      case Profession.florist:
        return 'Florist';
      case Profession.photoMovie:
        return 'Photo & Video';
      case Profession.makeupArtist:
        return 'Makeup Artist';
      case Profession.eventDesigner:
        return 'Event Designer';
      case Profession.other:
        return 'Other';
      // Global (everywhere)
      case Profession.music:
        return 'Music';
      case Profession.stationery:
        return 'Stationery';
      // India-only
      case Profession.caterer:
        return 'Caterer';
      case Profession.bridalWearDesigner:
        return 'Bridal Wear Designer';
      // Global-only (not in India)
      case Profession.jeweller:
        return 'Jeweller';
      case Profession.contentCreator:
        return 'Content Creator';
    }
  }

  /// Converts to the backend RPC expected value (uppercase, matches Supabase enum)
  String get toRpcValue {
    switch (this) {
      case Profession.photographer:
        return 'PHOTOGRAPHER';
      case Profession.filmmaker:
        return 'FILMMAKER';
      case Profession.planner:
        return 'PLANNER';
      case Profession.makeup:
        return 'MAKEUP';
      case Profession.hairdresser:
        return 'HAIRDRESSER';
      case Profession.designer:
        return 'DESIGNER';
      case Profession.bridalDesigner:
        return 'BRIDALDESIGNER';
      case Profession.venue:
        return 'VENUE';
      case Profession.bridalShop:
        return 'BRIDALSHOP';
      case Profession.florist:
        return 'FLORIST';
      case Profession.photoMovie:
        return 'PHOTOMOVIE';
      case Profession.makeupArtist:
        return 'MAKEUPARTIST';
      case Profession.eventDesigner:
        return 'EVENTDESIGNER';
      case Profession.other:
        return 'OTHER';
      // Global (everywhere)
      case Profession.music:
        return 'MUSIC';
      case Profession.stationery:
        return 'STATIONERY';
      // India-only
      case Profession.caterer:
        return 'CATERER';
      case Profession.bridalWearDesigner:
        return 'BRIDALWEARDESIGNER';
      // Global-only (not in India)
      case Profession.jeweller:
        return 'JEWELLER';
      case Profession.contentCreator:
        return 'CONTENTCREATOR';
    }
  }

  /// Parse profession from string (handles backend RPC values)
  static Profession fromString(String? value) {
    if (value == null || value.isEmpty) return Profession.other;
    
    final upper = value.toUpperCase();
    
    switch (upper) {
      case 'PHOTOGRAPHER':
        return Profession.photographer;
      case 'FILMMAKER':
        return Profession.filmmaker;
      case 'PLANNER':
        return Profession.planner;
      case 'MAKEUP':
        return Profession.makeup;
      case 'HAIRDRESSER':
        return Profession.hairdresser;
      case 'DESIGNER':
        return Profession.designer;
      case 'BRIDALDESIGNER':
        return Profession.bridalDesigner;
      case 'VENUE':
        return Profession.venue;
      case 'BRIDALSHOP':
        return Profession.bridalShop;
      case 'FLORIST':
        return Profession.florist;
      case 'PHOTOMOVIE':
        return Profession.photoMovie;
      case 'MAKEUPARTIST':
        return Profession.makeupArtist;
      case 'EVENTDESIGNER':
        return Profession.eventDesigner;
      // Global (everywhere)
      case 'MUSIC':
        return Profession.music;
      case 'STATIONERY':
        return Profession.stationery;
      // India-only
      case 'CATERER':
        return Profession.caterer;
      case 'BRIDALWEARDESIGNER':
        return Profession.bridalWearDesigner;
      // Global-only (not in India)
      case 'JEWELLER':
        return Profession.jeweller;
      case 'CONTENTCREATOR':
        return Profession.contentCreator;
      case 'OTHER':
      default:
        // Fallback: try matching by clean enum name
        final normalized = value.toLowerCase().replaceAll('_', '');
        return Profession.values.firstWhere(
          (e) => e.name.toLowerCase() == normalized,
          orElse: () => Profession.other,
        );
    }
  }
}

/// Subscription tier enum
enum SubscriptionTier {
  inactive,
  trial,
  earlyAccess,
  premiumVisibility,
  ultimateAccess;

  String get displayName {
    switch (this) {
      case SubscriptionTier.inactive:
        return 'Inactive';
      case SubscriptionTier.trial:
        return 'Trial';
      case SubscriptionTier.earlyAccess:
        return 'Early Access';
      case SubscriptionTier.premiumVisibility:
        return 'Premium';
      case SubscriptionTier.ultimateAccess:
        return 'Ultimate';
    }
  }

  static SubscriptionTier fromString(String? value) {
    if (value == null) return SubscriptionTier.inactive;
    switch (value.toLowerCase()) {
      case 'premiumvisibility':
      case 'premium_visibility':
      case 'premium':
        return SubscriptionTier.premiumVisibility;
      case 'ultimateaccess':
      case 'ultimate_access':
      case 'ultimate':
        return SubscriptionTier.ultimateAccess;
      case 'earlyaccess':
      case 'early_access':
      case 'early':
        return SubscriptionTier.earlyAccess;
      case 'trial':
        return SubscriptionTier.trial;
      default:
        return SubscriptionTier.inactive;
    }
  }
}

/// Professional details for map marker sheet
@immutable
class ProfessionalDetails {
  const ProfessionalDetails({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.businessName,
    required this.profession,
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.subscriptionTier = SubscriptionTier.inactive,
    this.distanceKm,
    this.locationLabel,
    this.coverImageUrl,
    this.isFavorited = false,
    this.isLive = false,
    this.description,
    this.portfolioImages = const [],
    this.slideshowImages = const [],
    this.fixedLocations = const [],
    this.instagramUrl,
    this.websiteUrl,
    this.profileVideoUrl,
    this.canBeContactedByBride = false,
    this.canContactBride = false,
    this.hasCoverVideo = false,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? businessName;
  final Profession profession;
  final int? budgetMin;
  final int? budgetMax;
  final String currency;
  final SubscriptionTier subscriptionTier;
  final double? distanceKm;
  final String? locationLabel;
  final String? coverImageUrl;
  final bool isFavorited;
  final bool isLive;
  final String? description;
  final List<String> portfolioImages;
  final List<String> slideshowImages;
  final List<gmaps.LatLng> fixedLocations;
  final String? instagramUrl;
  final String? websiteUrl;
  final String? profileVideoUrl;
  final bool canBeContactedByBride;
  final bool canContactBride;
  final bool hasCoverVideo;

  /// Display name (business name or full name)
  String get displayName => businessName?.isNotEmpty == true ? businessName! : fullName;

  /// Budget range formatted (in user's preferred currency)
  String get budgetRange {
    return BudgetFormatter.format(
      min: budgetMin,
      max: budgetMax,
      sourceCurrency: currency,
    );
  }

  /// Budget range in original currency (no conversion)
  String get budgetRangeOriginal {
    if (budgetMin == null && budgetMax == null) return 'Not specified';
    if (budgetMin == null) return 'Up to $budgetMax $currency';
    if (budgetMax == null) return 'From $budgetMin $currency';
    return '$budgetMin - $budgetMax $currency';
  }

  /// Distance formatted (in user's preferred unit: km or miles)
  String? get distanceFormatted {
    return DistanceFormatter.formatOrNull(distanceKm);
  }

  /// Distance formatted in original km (no conversion)
  String? get distanceFormattedKm {
    if (distanceKm == null) return null;
    if (distanceKm! < 1) return '${(distanceKm! * 1000).round()} m';
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  /// Has social links
  bool get hasSocialLinks => instagramUrl != null || websiteUrl != null;

  /// Has portfolio
  bool get hasPortfolio => portfolioImages.isNotEmpty;

  /// Has slideshow
  bool get hasSlideshow => slideshowImages.isNotEmpty;

  /// Factory from Supabase RPC response
  factory ProfessionalDetails.fromJson(Map<String, dynamic> json) {
    return ProfessionalDetails(
      id: json['proProfileId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      businessName: json['businessName']?.toString(),
      profession: Profession.fromString(json['profession']?.toString()),
      budgetMin: (json['budgetMin'] as num?)?.toInt(),
      budgetMax: (json['budgetMax'] as num?)?.toInt(),
      currency: json['currency']?.toString() ?? 'EUR',
      subscriptionTier: SubscriptionTier.fromString(json['subscriptionTier']?.toString()),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      locationLabel: json['locationLabel']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      isFavorited: json['isFavorited'] == true,
      isLive: json['isLive'] == true,
      description: json['description']?.toString(),
      portfolioImages: _parseStringList(json['portfolioImages']),
      slideshowImages: _parseStringList(json['slideshowImages']),
      fixedLocations: _parseLatLngList(json['fixedLocations']),
      instagramUrl: _extractSocialUrl(json, 'instagramUrl'),
      websiteUrl: _extractSocialUrl(json, 'websiteUrl'),
      profileVideoUrl: json['profileVideoUrl']?.toString(),
      canBeContactedByBride: json['canBeContactedByBride'] == true,
      canContactBride: json['canContactBride'] == true,
      hasCoverVideo: json['hasCoverVideo'] == true,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  static List<gmaps.LatLng> _parseLatLngList(dynamic value) {
    if (value is! List) return [];
    final result = <gmaps.LatLng>[];
    for (final item in value) {
      final latLng = _parseGeoJson(item);
      if (latLng != null) result.add(latLng);
    }
    return result;
  }

  static gmaps.LatLng? _parseGeoJson(dynamic geo) {
    if (geo is! Map<String, dynamic>) return null;
    try {
      if (geo['type'] == 'Point' && geo['coordinates'] is List) {
        final coords = geo['coordinates'] as List;
        if (coords.length >= 2) {
          return gmaps.LatLng(
            (coords[1] as num).toDouble(),
            (coords[0] as num).toDouble(),
          );
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _extractSocialUrl(Map<String, dynamic> json, String key) {
    if (json['socials'] is Map) {
      return json['socials'][key]?.toString();
    }
    return json[key]?.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalDetails && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
