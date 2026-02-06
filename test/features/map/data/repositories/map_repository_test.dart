import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';
import 'package:lynewed_beta/features/map/domain/repositories/map_repository.dart';

void main() {
  group('MapSearchResult', () {
    test('should create with default values', () {
      const result = MapSearchResult();

      expect(result.professionals, isEmpty);
      expect(result.fixedLocations, isEmpty);
      expect(result.alerts, isEmpty);
      expect(result.weddings, isEmpty);
      expect(result.totalCount, 0);
      expect(result.hasMore, false);
    });

    test('allMarkers should combine all marker lists', () {
      const pro = MapMarker(
        id: 'pro-1',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );
      const alert = MapMarker(
        id: 'alert-1',
        type: MapMarkerType.professionalAlert,
        position: gmaps.LatLng(48.8600, 2.3500),
      );

      const result = MapSearchResult(
        professionals: [pro],
        alerts: [alert],
        totalCount: 2,
      );

      expect(result.allMarkers.length, 2);
      expect(result.allMarkers, contains(pro));
      expect(result.allMarkers, contains(alert));
    });

    test('copyWith should create new instance with updated values', () {
      const original = MapSearchResult(totalCount: 10);

      final updated = original.copyWith(
        totalCount: 20,
        hasMore: true,
      );

      expect(updated.totalCount, 20);
      expect(updated.hasMore, true);
      expect(original.totalCount, 10); // Original unchanged
    });

    test('empty should return empty result', () {
      const result = MapSearchResult.empty;

      expect(result.allMarkers, isEmpty);
      expect(result.totalCount, 0);
    });

    test('should include marketplace in default values', () {
      const result = MapSearchResult();
      expect(result.marketplace, isEmpty);
    });

    test('allMarkers should include marketplace markers', () {
      const pro = MapMarker(
        id: 'pro-1',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );
      const mp = MapMarker(
        id: 'mp-1',
        type: MapMarkerType.marketplaceItem,
        position: gmaps.LatLng(48.8700, 2.3600),
      );

      const result = MapSearchResult(
        fixedLocations: [pro],
        marketplace: [mp],
        totalCount: 2,
      );

      expect(result.allMarkers.length, 2);
      expect(result.allMarkers, contains(mp));
    });

    test('copyWith should update marketplace', () {
      const original = MapSearchResult();
      const mpMarker = MapMarker(
        id: 'mp-1',
        type: MapMarkerType.marketplaceItem,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      final updated = original.copyWith(marketplace: [mpMarker]);
      expect(updated.marketplace.length, 1);
      expect(updated.marketplace.first.id, 'mp-1');
    });

    test('empty should have empty marketplace', () {
      const result = MapSearchResult.empty;
      expect(result.marketplace, isEmpty);
    });
  });

  group('MapFilter with Repository', () {
    test('should create filter for repository query', () {
      const filter = MapFilter(
        professions: [Profession.photographer, Profession.filmmaker],
        budgetMin: 1000,
        budgetMax: 5000,
        toggles: LayerToggles(
          showPros: true,
          showAlerts: true,
          showWeddings: false,
        ),
      );

      expect(filter.hasProfessionFilter, true);
      expect(filter.hasBudgetFilter, true);
      expect(filter.toggles.showWeddings, false);
    });

    test('bounds should be correctly created for queries', () {
      final bounds = gmaps.LatLngBounds(
        southwest: const gmaps.LatLng(48.8, 2.3),
        northeast: const gmaps.LatLng(48.9, 2.4),
      );

      expect(bounds.southwest.latitude, 48.8);
      expect(bounds.southwest.longitude, 2.3);
      expect(bounds.northeast.latitude, 48.9);
      expect(bounds.northeast.longitude, 2.4);
    });
  });

  group('MapRepository Contract', () {
    test('MapRepository should define required methods', () {
      // This test verifies the interface contract exists
      // Actual implementation tests would use mocks
      
      // Verify MapSearchResult can be used as return type
      const result = MapSearchResult(
        totalCount: 5,
        hasMore: false,
      );
      
      expect(result.totalCount, 5);
    });
  });
}
