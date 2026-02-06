/// Map repository interface
/// 
/// Defines the contract for map data operations.
/// Implementations can be Supabase, mock, or cached.
library;

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../entities/entities.dart';

/// Résultat d'une recherche map avec tous les marqueurs
class MapSearchResult {
  const MapSearchResult({
    this.professionals = const [],
    this.fixedLocations = const [],
    this.alerts = const [],
    this.weddings = const [],
    this.marketplace = const [],
    this.totalCount = 0,
    this.hasMore = false,
  });

  final List<MapMarker> professionals;
  final List<MapMarker> fixedLocations;
  final List<MapMarker> alerts;
  final List<MapMarker> weddings;

  /// Marketplace listing markers (EPIC-14)
  final List<MapMarker> marketplace;

  final int totalCount;
  final bool hasMore;

  /// Tous les marqueurs combinés
  List<MapMarker> get allMarkers => [
        ...professionals,
        ...fixedLocations,
        ...alerts,
        ...weddings,
        ...marketplace,
      ];

  /// Vide
  static const empty = MapSearchResult();

  MapSearchResult copyWith({
    List<MapMarker>? professionals,
    List<MapMarker>? fixedLocations,
    List<MapMarker>? alerts,
    List<MapMarker>? weddings,
    List<MapMarker>? marketplace,
    int? totalCount,
    bool? hasMore,
  }) {
    return MapSearchResult(
      professionals: professionals ?? this.professionals,
      fixedLocations: fixedLocations ?? this.fixedLocations,
      alerts: alerts ?? this.alerts,
      weddings: weddings ?? this.weddings,
      marketplace: marketplace ?? this.marketplace,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Interface du repository map
/// 
/// Abstraction pour accéder aux données map depuis Supabase ou autre source.
abstract class MapRepository {
  /// Recherche les marqueurs dans une zone avec filtres
  /// 
  /// [bounds] - Zone géographique visible
  /// [filter] - Filtres actifs (professions, budget, toggles)
  /// [userRole] - Rôle de l'utilisateur (bride/professional) pour permissions
  /// [zoomLevel] - Niveau de zoom pour adapter les limites de résultats
  Future<MapSearchResult> searchMarkers({
    required gmaps.LatLngBounds bounds,
    required MapFilter filter,
    required String userRole,
    double zoomLevel = 12.0,
  });

  /// Récupère les détails d'un professionnel
  Future<Map<String, dynamic>?> getProfessionalDetails(String professionalId);

  /// Récupère les détails d'une alerte
  Future<ProfessionalAlert?> getAlertDetails(String alertId);

  /// Récupère les détails d'un mariage
  Future<Wedding?> getWeddingDetails(String weddingId);

  /// Crée ou met à jour une alerte
  Future<ProfessionalAlert> saveAlert(ProfessionalAlert alert);

  /// Supprime une alerte
  Future<void> deleteAlert(String alertId);

  /// Crée ou met à jour un mariage
  Future<Wedding> saveWedding(Wedding wedding);

  /// Récupère le mariage de l'utilisateur courant (bride)
  Future<Wedding?> getCurrentUserWedding();

  /// Stream des alertes (temps réel)
  Stream<List<ProfessionalAlert>> watchAlerts(gmaps.LatLngBounds bounds);

  /// Dispose les ressources
  void dispose();
}
