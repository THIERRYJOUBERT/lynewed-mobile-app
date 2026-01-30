/// Map filter entity - Clean replacement for QueryFiltersStruct
/// 
/// Replaces FlutterFlow's verbose 417-line QueryFiltersStruct with a clean,
/// immutable data class (~100 lines).
library;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import 'professional_details.dart' show Profession;

/// Toggles pour afficher/masquer les couches de la map
@immutable
class LayerToggles {
  const LayerToggles({
    this.showPros = true,
    this.showFixedLocations = true,
    this.showAlerts = true,
    this.showWeddings = true,
    this.showOnlyMyProfession = false,
  });

  final bool showPros;
  final bool showFixedLocations;
  final bool showAlerts;
  final bool showWeddings;
  final bool showOnlyMyProfession;

  /// Tous les toggles activés
  static const all = LayerToggles();

  /// Aucun toggle activé
  static const none = LayerToggles(
    showPros: false,
    showFixedLocations: false,
    showAlerts: false,
    showWeddings: false,
  );

  LayerToggles copyWith({
    bool? showPros,
    bool? showFixedLocations,
    bool? showAlerts,
    bool? showWeddings,
    bool? showOnlyMyProfession,
  }) {
    return LayerToggles(
      showPros: showPros ?? this.showPros,
      showFixedLocations: showFixedLocations ?? this.showFixedLocations,
      showAlerts: showAlerts ?? this.showAlerts,
      showWeddings: showWeddings ?? this.showWeddings,
      showOnlyMyProfession: showOnlyMyProfession ?? this.showOnlyMyProfession,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerToggles &&
        other.showPros == showPros &&
        other.showFixedLocations == showFixedLocations &&
        other.showAlerts == showAlerts &&
        other.showWeddings == showWeddings &&
        other.showOnlyMyProfession == showOnlyMyProfession;
  }

  @override
  int get hashCode => Object.hash(
        showPros,
        showFixedLocations,
        showAlerts,
        showWeddings,
        showOnlyMyProfession,
      );
}

/// Filtres de recherche pour la map
/// 
/// Remplace QueryFiltersStruct (417 lignes) par une classe immutable (~100 lignes)
@immutable
class MapFilter {
  const MapFilter({
    this.professions = const [],
    this.budgetMin,
    this.budgetMax,
    this.currency = 'EUR',
    this.center,
    this.radiusKm,
    this.countryCode,
    this.toggles = const LayerToggles(),
    this.minRating,
  });

  /// Professions à afficher (vide = toutes)
  final List<Profession> professions;

  /// Budget minimum
  final double? budgetMin;

  /// Budget maximum
  final double? budgetMax;

  /// Devise (EUR, USD, GBP, INR)
  final String currency;

  /// Centre de recherche (null = position utilisateur)
  final gmaps.LatLng? center;

  /// Rayon de recherche en km (null = pas de limite)
  final double? radiusKm;

  /// Code pays pour filtrage géographique (IN = Inde séparée)
  final String? countryCode;

  /// Toggles d'affichage des couches
  final LayerToggles toggles;

  /// Minimum rating to filter professionals (1.0 - 5.0)
  /// null = no rating filter
  final double? minRating;

  /// Filtres par défaut
  static const defaults = MapFilter();

  /// Vérifie si un filtre de budget est actif
  bool get hasBudgetFilter => budgetMin != null || budgetMax != null;

  /// Vérifie si un filtre de profession est actif
  bool get hasProfessionFilter => professions.isNotEmpty;

  /// Vérifie si un filtre géographique est actif
  bool get hasGeoFilter => center != null && radiusKm != null;

  /// Check if a rating filter is active
  bool get hasRatingFilter => minRating != null && minRating! > 0;

  MapFilter copyWith({
    List<Profession>? professions,
    double? budgetMin,
    double? budgetMax,
    String? currency,
    gmaps.LatLng? center,
    double? radiusKm,
    String? countryCode,
    LayerToggles? toggles,
    double? minRating,
    bool clearMinRating = false,
  }) {
    return MapFilter(
      professions: professions ?? this.professions,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      currency: currency ?? this.currency,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
      countryCode: countryCode ?? this.countryCode,
      toggles: toggles ?? this.toggles,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapFilter &&
        listEquals(other.professions, professions) &&
        other.budgetMin == budgetMin &&
        other.budgetMax == budgetMax &&
        other.currency == currency &&
        other.center == center &&
        other.radiusKm == radiusKm &&
        other.countryCode == countryCode &&
        other.toggles == toggles &&
        other.minRating == minRating;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(professions),
        budgetMin,
        budgetMax,
        currency,
        center,
        radiusKm,
        countryCode,
        toggles,
        minRating,
      );
}
