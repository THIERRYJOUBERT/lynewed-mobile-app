/// Wedding entity - Replaces wedding_pins and user_pois concepts
/// 
/// New unified "Wedding" concept as the central hub:
/// - 1 mariage par bride
/// - POI privé supprimé
/// - Flux: Bride favoris → Pro notifié → Demande contact → Chat
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Visibilité du mariage sur la map
enum WeddingVisibility {
  /// Privé - visible uniquement par la bride
  private,
  
  /// Visible par les pros Premium/Ultimate
  visibleToPros,
  
  /// Public - visible par tous (future feature)
  public;

  static WeddingVisibility fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'private':
        return WeddingVisibility.private;
      case 'visible_to_pros':
      case 'visibletopros':
        return WeddingVisibility.visibleToPros;
      case 'public':
        return WeddingVisibility.public;
      default:
        return WeddingVisibility.private;
    }
  }
}

/// Mariage - Hub central de la bride
/// 
/// Remplace les concepts wedding_pins et user_pois par une entité unifiée.
/// 1 bride = 1 mariage maximum.
@immutable
class Wedding {
  const Wedding({
    required this.id,
    required this.brideId,
    required this.position,
    this.eventDate,
    this.venueName,
    this.venueAddress,
    this.visibility = WeddingVisibility.private,
    this.guestCount,
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.professionsNeeded = const [],
    this.searchRadiusKm = 50,
    this.notes,
    this.createdAt,
    this.brideName,
    this.brideAvatarUrl,
  });

  /// UUID du mariage
  final String id;

  /// UUID de la bride propriétaire
  final String brideId;

  /// Position GPS du lieu de mariage
  final gmaps.LatLng position;

  /// Date du mariage
  final DateTime? eventDate;

  /// Nom du lieu
  final String? venueName;

  /// Adresse complète
  final String? venueAddress;

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

  /// Notes privées de la bride
  final String? notes;

  /// Date de création
  final DateTime? createdAt;

  /// Nom de la bride (pour affichage côté pro)
  final String? brideName;

  /// Avatar de la bride
  final String? brideAvatarUrl;

  /// Vérifie si le mariage est visible sur la map publique
  bool get isVisibleOnMap => visibility != WeddingVisibility.private;

  /// Vérifie si le mariage est passé
  bool get isPast {
    if (eventDate == null) return false;
    return DateTime.now().isAfter(eventDate!);
  }

  /// Vérifie si le mariage est à venir
  bool get isUpcoming {
    if (eventDate == null) return true; // Date non définie = à venir
    return DateTime.now().isBefore(eventDate!);
  }

  /// Jours restants avant le mariage
  int? get daysUntilWedding {
    if (eventDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(eventDate!)) return 0;
    return eventDate!.difference(now).inDays;
  }

  Wedding copyWith({
    String? id,
    String? brideId,
    gmaps.LatLng? position,
    DateTime? eventDate,
    String? venueName,
    String? venueAddress,
    WeddingVisibility? visibility,
    int? guestCount,
    double? budgetMin,
    double? budgetMax,
    String? currency,
    List<String>? professionsNeeded,
    int? searchRadiusKm,
    String? notes,
    DateTime? createdAt,
    String? brideName,
    String? brideAvatarUrl,
  }) {
    return Wedding(
      id: id ?? this.id,
      brideId: brideId ?? this.brideId,
      position: position ?? this.position,
      eventDate: eventDate ?? this.eventDate,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      visibility: visibility ?? this.visibility,
      guestCount: guestCount ?? this.guestCount,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      currency: currency ?? this.currency,
      professionsNeeded: professionsNeeded ?? this.professionsNeeded,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      brideName: brideName ?? this.brideName,
      brideAvatarUrl: brideAvatarUrl ?? this.brideAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wedding && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Wedding($id, $venueName, $eventDate)';
}
