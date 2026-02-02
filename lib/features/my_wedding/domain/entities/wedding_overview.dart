/// Wedding Overview entity for My Wedding Suite
///
/// Extended version of Wedding with additional fields for the bride's dashboard.
/// Includes onboarding state, cover image, note for pros, and status.
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '/features/map/domain/entities/wedding_details.dart' show WeddingVisibility;

/// Wedding status enum
enum WeddingStatus {
  active,
  cancelled,
}

/// Wedding Overview - Extended wedding data for bride dashboard
@immutable
class WeddingOverview {
  const WeddingOverview({
    required this.id,
    required this.brideId,
    this.name,
    this.position,
    this.eventDate,
    this.eventEndDate,
    this.venueName,
    this.venueAddress,
    this.countryCode,
    this.visibility = WeddingVisibility.private,
    this.guestCount,
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.professionsNeeded = const [],
    this.searchRadiusKm = 50,
    this.coverImageUrl,
    this.noteForPros,
    this.status = WeddingStatus.active,
    this.onboardingStep,
    this.cancelledAt,
    this.createdAt,
    this.teamChatRoomId,
    this.participantsCount = 0,
    this.inviteCode,
    this.inviteCodeExpiresAt,
  });

  /// UUID du mariage
  final String id;

  /// UUID de la bride propriétaire
  final String brideId;

  /// Nom du mariage (ex: "Sophie & Thomas Wedding")
  final String? name;

  /// Position GPS du lieu de mariage
  final gmaps.LatLng? position;

  /// Date du mariage
  final DateTime? eventDate;

  /// Date de fin (si mariage sur plusieurs jours)
  final DateTime? eventEndDate;

  /// Nom du lieu
  final String? venueName;

  /// Adresse complète
  final String? venueAddress;

  /// Code pays (déduit de la position)
  final String? countryCode;

  /// Visibilité sur la map
  final WeddingVisibility visibility;

  /// Nombre d'invités estimé
  final int? guestCount;

  /// Budget minimum
  final double? budgetMin;

  /// Budget maximum
  final double? budgetMax;

  /// Devise
  final String currency;

  /// Professions recherchées par la bride
  final List<String> professionsNeeded;

  /// Rayon de recherche en km
  final int searchRadiusKm;

  /// Alias for searchRadiusKm
  int? get searchRadius => searchRadiusKm;

  /// Image de couverture
  final String? coverImageUrl;

  /// Note unique pour les pros (max 1000 chars)
  final String? noteForPros;

  /// Statut du mariage
  final WeddingStatus status;

  /// Étape d'onboarding en cours (null = terminé)
  final int? onboardingStep;

  /// Date d'annulation
  final DateTime? cancelledAt;

  /// Date de création
  final DateTime? createdAt;

  /// ID du chat room de la wedding team
  final String? teamChatRoomId;

  /// Nombre de participants (pros) dans la wedding team
  final int participantsCount;

  /// Invitation code for guests (8 characters)
  final String? inviteCode;

  /// Invitation code expiration date
  final DateTime? inviteCodeExpiresAt;

  /// Vérifie si l'onboarding est terminé
  bool get isOnboardingComplete => onboardingStep == null;

  /// Vérifie si le mariage est actif
  bool get isActive => status == WeddingStatus.active;

  /// Vérifie si le mariage est annulé
  bool get isCancelled => status == WeddingStatus.cancelled;

  /// Jours restants avant le mariage
  int? get daysUntilWedding {
    if (eventDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(eventDate!)) return 0;
    return eventDate!.difference(now).inDays;
  }

  /// Vérifie si le mariage est passé
  bool get isPast {
    if (eventDate == null) return false;
    return DateTime.now().isAfter(eventDate!);
  }

  /// Factory from Supabase JSON
  factory WeddingOverview.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    final id = json['id'];
    final brideId = json['bride_profile_id'];
    
    if (id == null || brideId == null) {
      throw ArgumentError('Missing required fields: id or bride_profile_id');
    }
    
    // Parse venue_coords (PostGIS geometry) - format: "POINT(lng lat)" or null
    gmaps.LatLng? position;
    final venueCoords = json['venue_coords'];
    if (venueCoords != null && venueCoords is String) {
      final match = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)').firstMatch(venueCoords);
      if (match != null) {
        final lng = double.tryParse(match.group(1) ?? '');
        final lat = double.tryParse(match.group(2) ?? '');
        if (lat != null && lng != null) {
          position = gmaps.LatLng(lat, lng);
        }
      }
    }
    
    return WeddingOverview(
      id: id as String,
      brideId: brideId as String,
      name: json['wedding_name'] as String?,
      position: position,
      eventDate: json['event_date'] != null 
          ? DateTime.parse(json['event_date'] as String) 
          : null,
      eventEndDate: json['event_end_date'] != null 
          ? DateTime.parse(json['event_end_date'] as String) 
          : null,
      venueName: json['venue_label'] as String?,
      venueAddress: json['venue_label'] as String?,
      countryCode: json['location_country_code'] as String?,
      visibility: _parseVisibility(json['visibility'] as String?),
      guestCount: json['guest_count'] as int?,
      budgetMin: (json['budget_min'] as num?)?.toDouble(),
      budgetMax: (json['budget_max'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      professionsNeeded: (json['professions_needed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      searchRadiusKm: json['search_radius_km'] as int? ?? 50,
      coverImageUrl: json['cover_image_url'] as String?,
      noteForPros: json['note_for_pros'] as String?,
      status: _parseStatus(json['status'] as String?),
      onboardingStep: json['onboarding_step'] as int?,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      teamChatRoomId: json['team_chat_room_id'] as String?,
      participantsCount: json['participants_count'] as int? ?? 0,
      inviteCode: json['invite_code'] as String?,
      inviteCodeExpiresAt: json['invite_code_expires_at'] != null
          ? DateTime.parse(json['invite_code_expires_at'] as String)
          : null,
    );
  }

  static WeddingVisibility _parseVisibility(String? value) {
    switch (value) {
      case 'visible_to_pros':
        return WeddingVisibility.visibleToPros;
      default:
        return WeddingVisibility.private;
    }
  }

  static WeddingStatus _parseStatus(String? value) {
    switch (value) {
      case 'cancelled':
        return WeddingStatus.cancelled;
      default:
        return WeddingStatus.active;
    }
  }

  WeddingOverview copyWith({
    String? id,
    String? brideId,
    String? name,
    gmaps.LatLng? position,
    DateTime? eventDate,
    DateTime? eventEndDate,
    String? venueName,
    String? venueAddress,
    String? countryCode,
    WeddingVisibility? visibility,
    int? guestCount,
    double? budgetMin,
    double? budgetMax,
    String? currency,
    List<String>? professionsNeeded,
    int? searchRadiusKm,
    String? coverImageUrl,
    String? noteForPros,
    WeddingStatus? status,
    int? onboardingStep,
    DateTime? cancelledAt,
    DateTime? createdAt,
    String? teamChatRoomId,
    int? participantsCount,
    String? inviteCode,
    DateTime? inviteCodeExpiresAt,
  }) {
    return WeddingOverview(
      id: id ?? this.id,
      brideId: brideId ?? this.brideId,
      name: name ?? this.name,
      position: position ?? this.position,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      countryCode: countryCode ?? this.countryCode,
      visibility: visibility ?? this.visibility,
      guestCount: guestCount ?? this.guestCount,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      currency: currency ?? this.currency,
      professionsNeeded: professionsNeeded ?? this.professionsNeeded,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      noteForPros: noteForPros ?? this.noteForPros,
      status: status ?? this.status,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      teamChatRoomId: teamChatRoomId ?? this.teamChatRoomId,
      participantsCount: participantsCount ?? this.participantsCount,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteCodeExpiresAt: inviteCodeExpiresAt ?? this.inviteCodeExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingOverview && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WeddingOverview($id, $name, step: $onboardingStep)';
}
