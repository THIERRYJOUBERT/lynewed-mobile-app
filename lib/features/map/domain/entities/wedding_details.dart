/// Wedding details entity for map marker details
/// 
/// Complete wedding data for display in details sheet.
/// Replaces FlutterFlow's WeddingPinItemDataStruct with clean, immutable class.
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'professional_details.dart';

/// Wedding details for map marker sheet
@immutable
class WeddingDetails {
  const WeddingDetails({
    required this.id,
    required this.brideId,
    this.locationLabel,
    this.center,
    this.radiusKm,
    this.professionsNeeded = const [],
    this.eventDate,
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.isContactable = false,
    this.brideAvatarUrl,
    this.brideName,
    this.guestCount,
    this.notes,
  });

  final String id;
  final String brideId;
  final String? locationLabel;
  final gmaps.LatLng? center;
  final int? radiusKm;
  final List<Profession> professionsNeeded;
  final DateTime? eventDate;
  final int? budgetMin;
  final int? budgetMax;
  final String currency;
  final bool isContactable;
  final String? brideAvatarUrl;
  final String? brideName;
  final int? guestCount;
  final String? notes;

  /// Budget range formatted
  String get budgetRange {
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

  /// Search radius formatted
  String? get radiusFormatted {
    if (radiusKm == null) return null;
    return '$radiusKm km';
  }

  /// Factory from Supabase RPC response
  factory WeddingDetails.fromJson(Map<String, dynamic> json) {
    return WeddingDetails(
      id: json['weddingPinId']?.toString() ?? json['id']?.toString() ?? '',
      brideId: json['brideProfileId']?.toString() ?? json['brideId']?.toString() ?? '',
      locationLabel: json['locationLabel']?.toString(),
      center: _parseGeoJson(json['center']),
      radiusKm: (json['radiusKm'] as num?)?.toInt(),
      professionsNeeded: _parseProfessionsList(json['professionsNeeded']),
      eventDate: _parseDateTime(json['eventStartDate'] ?? json['eventDate']),
      budgetMin: (json['budgetMin'] as num?)?.toInt(),
      budgetMax: (json['budgetMax'] as num?)?.toInt(),
      currency: json['currency']?.toString() ?? 'EUR',
      isContactable: json['isContactable'] == true,
      brideAvatarUrl: json['brideAvatarUrl']?.toString(),
      brideName: json['brideName']?.toString(),
      guestCount: (json['guestCount'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
    );
  }

  static gmaps.LatLng? _parseGeoJson(dynamic geo) {
    if (geo is! Map<String, dynamic>) return null;
    try {
      final type = geo['type']?.toString().toUpperCase();
      if (type == 'POINT' && geo['coordinates'] is List) {
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
