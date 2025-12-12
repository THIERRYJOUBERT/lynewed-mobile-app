/// Wedding details entity for map marker details
/// 
/// Complete wedding data for display in details sheet.
/// Phase 5: Updated to use new `weddings` table (hub central per bride).
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '/core/utils/budget_formatter.dart';
import '/core/utils/distance_formatter.dart';
import 'professional_details.dart';

/// Wedding visibility enum
enum WeddingVisibility {
  private,
  visibleToPros;

  String get displayName {
    switch (this) {
      case WeddingVisibility.private:
        return 'Private';
      case WeddingVisibility.visibleToPros:
        return 'Visible to Pros';
    }
  }

  static WeddingVisibility fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'visible_to_pros':
      case 'visibletopros':
        return WeddingVisibility.visibleToPros;
      default:
        return WeddingVisibility.private;
    }
  }
}

/// Wedding status enum
enum WeddingStatus {
  planning,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case WeddingStatus.planning:
        return 'Planning';
      case WeddingStatus.confirmed:
        return 'Confirmed';
      case WeddingStatus.completed:
        return 'Completed';
      case WeddingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static WeddingStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'confirmed':
        return WeddingStatus.confirmed;
      case 'completed':
        return WeddingStatus.completed;
      case 'cancelled':
        return WeddingStatus.cancelled;
      default:
        return WeddingStatus.planning;
    }
  }
}

/// Wedding details for map marker sheet
/// Updated for Phase 5: Uses new `weddings` table structure
@immutable
class WeddingDetails {
  const WeddingDetails({
    required this.id,
    required this.brideId,
    this.weddingName,
    this.venueLabel,
    this.venueCoords,
    this.searchRadiusKm,
    this.professionsNeeded = const [],
    this.eventDate,
    this.eventEndDate,
    this.guestCount,
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.visibility = WeddingVisibility.private,
    this.status = WeddingStatus.planning,
    this.isOwn = false,
    this.brideAvatarUrl,
    this.brideFullName,
    this.createdAt,
  });

  final String id;
  final String brideId;
  final String? weddingName;
  final String? venueLabel;
  final gmaps.LatLng? venueCoords;
  final int? searchRadiusKm;
  final List<Profession> professionsNeeded;
  final DateTime? eventDate;
  final DateTime? eventEndDate;
  final int? guestCount;
  final int? budgetMin;
  final int? budgetMax;
  final String currency;
  final WeddingVisibility visibility;
  final WeddingStatus status;
  final bool isOwn;
  final String? brideAvatarUrl;
  final String? brideFullName;
  final DateTime? createdAt;

  /// Bride name for display
  String? get brideName {
    if (brideFullName != null && brideFullName!.isNotEmpty) {
      return brideFullName;
    }
    return null;
  }

  /// Budget range formatted (in user's preferred currency)
  String get budgetRange {
    return BudgetFormatter.format(
      min: budgetMin,
      max: budgetMax,
      sourceCurrency: currency,
    );
  }

  /// Budget formatted using only budgetMax (in user's preferred currency)
  String get budgetMaxOnly {
    return BudgetFormatter.format(
      min: null,
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

  /// Event date formatted
  String? get eventDateFormatted {
    if (eventDate == null) return null;
    return '${eventDate!.day}/${eventDate!.month}/${eventDate!.year}';
  }

  /// Days until wedding
  int? get daysUntilWedding {
    if (eventDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(eventDate!)) return 0;
    return eventDate!.difference(now).inDays;
  }

  /// Is past wedding
  bool get isPast {
    if (eventDate == null) return false;
    return DateTime.now().isAfter(eventDate!);
  }

  /// Is upcoming wedding
  bool get isUpcoming => !isPast;

  /// Has professions needed
  bool get hasProfessionsNeeded => professionsNeeded.isNotEmpty;

  /// Professions needed formatted
  String get professionsNeededFormatted {
    if (professionsNeeded.isEmpty) return 'Not specified';
    return professionsNeeded.map((p) => p.displayName).join(', ');
  }

  /// Search radius formatted (in user's preferred unit: km or miles)
  String? get radiusFormatted {
    if (searchRadiusKm == null) return null;
    return DistanceFormatter.format(searchRadiusKm!.toDouble());
  }

  /// Search radius formatted in original km (no conversion)
  String? get radiusFormattedKm {
    if (searchRadiusKm == null) return null;
    return '$searchRadiusKm km';
  }

  /// Is visible to professionals
  bool get isVisibleToPros => visibility == WeddingVisibility.visibleToPros;

  /// Factory from Supabase RPC response (Phase 5: new get_wedding_details RPC)
  factory WeddingDetails.fromJson(Map<String, dynamic> json) {
    // Handle brideInfo nested object from new RPC
    final brideInfo = json['brideInfo'] as Map<String, dynamic>? ?? {};
    
    return WeddingDetails(
      id: json['id']?.toString() ?? '',
      brideId: json['brideProfileId']?.toString() ?? '',
      weddingName: json['weddingName']?.toString(),
      venueLabel: json['venueLabel']?.toString(),
      venueCoords: null, // Not returned in details RPC for privacy
      searchRadiusKm: (json['searchRadiusKm'] as num?)?.toInt(),
      professionsNeeded: _parseProfessionsList(json['professionsNeeded']),
      eventDate: _parseDateTime(json['eventDate']),
      eventEndDate: _parseDateTime(json['eventEndDate']),
      guestCount: (json['guestCount'] as num?)?.toInt() ?? (json['guest_count'] as num?)?.toInt(),
      budgetMin: (json['budgetMin'] as num?)?.toInt(),
      budgetMax: (json['budgetMax'] as num?)?.toInt(),
      currency: json['currency']?.toString() ?? 'EUR',
      visibility: WeddingVisibility.fromString(json['visibility']?.toString()),
      status: WeddingStatus.fromString(json['status']?.toString()),
      isOwn: json['isOwn'] == true,
      brideAvatarUrl: brideInfo['avatarUrl']?.toString() ?? json['brideAvatarUrl']?.toString(),
      brideFullName: brideInfo['fullName']?.toString(),  // FIXED: was displayName/firstName
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static List<Profession> _parseProfessionsList(dynamic value) {
    if (value is! List) return [];
    return value
        .map((p) => Profession.fromString(p?.toString()))
        .toList();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      final normalized = value.replaceAll('"', '').trim();
      if (normalized.isEmpty) return null;
      return DateTime.tryParse(normalized);
    }
    return DateTime.tryParse(value.toString());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingDetails && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
