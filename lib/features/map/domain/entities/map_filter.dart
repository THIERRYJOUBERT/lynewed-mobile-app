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
    this.showMarketplace = false,
  });

  final bool showPros;
  final bool showFixedLocations;
  final bool showAlerts;
  final bool showWeddings;
  final bool showOnlyMyProfession;

  /// Show marketplace items on map (EPIC-13 APP-07)
  /// Default false until EPIC-14 (Marketplace) is deployed
  final bool showMarketplace;

  /// Tous les toggles activés
  static const all = LayerToggles();

  /// Aucun toggle activé
  static const none = LayerToggles(
    showPros: false,
    showFixedLocations: false,
    showAlerts: false,
    showWeddings: false,
    showMarketplace: false,
  );

  LayerToggles copyWith({
    bool? showPros,
    bool? showFixedLocations,
    bool? showAlerts,
    bool? showWeddings,
    bool? showOnlyMyProfession,
    bool? showMarketplace,
  }) {
    return LayerToggles(
      showPros: showPros ?? this.showPros,
      showFixedLocations: showFixedLocations ?? this.showFixedLocations,
      showAlerts: showAlerts ?? this.showAlerts,
      showWeddings: showWeddings ?? this.showWeddings,
      showOnlyMyProfession: showOnlyMyProfession ?? this.showOnlyMyProfession,
      showMarketplace: showMarketplace ?? this.showMarketplace,
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
        other.showOnlyMyProfession == showOnlyMyProfession &&
        other.showMarketplace == showMarketplace;
  }

  @override
  int get hashCode => Object.hash(
        showPros,
        showFixedLocations,
        showAlerts,
        showWeddings,
        showOnlyMyProfession,
        showMarketplace,
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
    this.weddingBookFree,
    this.trailerFree,
    this.marketplaceCategory,
    this.marketplaceConditions,
    this.marketplaceMinPrice,
    this.marketplaceMaxPrice,
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

  /// Filter pros offering free wedding book (EPIC-13 APP-07)
  /// null = no filter, true = only pros with free wedding book
  final bool? weddingBookFree;

  /// Filter pros offering free trailer video (EPIC-13 APP-07)
  /// null = no filter, true = only pros with free trailer
  final bool? trailerFree;

  /// Marketplace category filter: 'dress', 'shoes', or null for all (EPIC-14)
  final String? marketplaceCategory;

  /// Marketplace condition filter: ['new', 'excellent', 'good', 'fair'] (EPIC-14)
  final List<String>? marketplaceConditions;

  /// Marketplace minimum price in cents (EPIC-14)
  final int? marketplaceMinPrice;

  /// Marketplace maximum price in cents (EPIC-14)
  final int? marketplaceMaxPrice;

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

  /// Check if special offers filter is active (EPIC-13)
  bool get hasSpecialOffersFilter =>
      weddingBookFree == true || trailerFree == true;

  /// Check if marketplace filter is active (EPIC-14)
  bool get hasMarketplaceFilter =>
      marketplaceCategory != null ||
      (marketplaceConditions != null && marketplaceConditions!.isNotEmpty) ||
      marketplaceMinPrice != null ||
      marketplaceMaxPrice != null;

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
    bool? weddingBookFree,
    bool clearWeddingBookFree = false,
    bool? trailerFree,
    bool clearTrailerFree = false,
    String? marketplaceCategory,
    bool clearMarketplaceCategory = false,
    List<String>? marketplaceConditions,
    bool clearMarketplaceConditions = false,
    int? marketplaceMinPrice,
    int? marketplaceMaxPrice,
    bool clearMarketplacePrice = false,
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
      weddingBookFree: clearWeddingBookFree
          ? null
          : (weddingBookFree ?? this.weddingBookFree),
      trailerFree:
          clearTrailerFree ? null : (trailerFree ?? this.trailerFree),
      marketplaceCategory: clearMarketplaceCategory
          ? null
          : (marketplaceCategory ?? this.marketplaceCategory),
      marketplaceConditions: clearMarketplaceConditions
          ? null
          : (marketplaceConditions ?? this.marketplaceConditions),
      marketplaceMinPrice: clearMarketplacePrice
          ? null
          : (marketplaceMinPrice ?? this.marketplaceMinPrice),
      marketplaceMaxPrice: clearMarketplacePrice
          ? null
          : (marketplaceMaxPrice ?? this.marketplaceMaxPrice),
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
        other.minRating == minRating &&
        other.weddingBookFree == weddingBookFree &&
        other.trailerFree == trailerFree &&
        other.marketplaceCategory == marketplaceCategory &&
        listEquals(other.marketplaceConditions, marketplaceConditions) &&
        other.marketplaceMinPrice == marketplaceMinPrice &&
        other.marketplaceMaxPrice == marketplaceMaxPrice;
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
        weddingBookFree,
        trailerFree,
        marketplaceCategory,
        marketplaceConditions != null
            ? Object.hashAll(marketplaceConditions!)
            : null,
        marketplaceMinPrice,
        marketplaceMaxPrice,
      );
}
