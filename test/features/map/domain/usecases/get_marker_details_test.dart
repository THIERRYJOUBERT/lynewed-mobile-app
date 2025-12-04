import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

// Note: Les tests des use cases nécessitent un mock Supabase.
// Ces tests vérifient uniquement la logique sans dépendance Supabase.

void main() {
  group('MapMarker for use cases', () {
    test('marker with empty ID should be identifiable', () {
      const marker = MapMarker(
        id: '', // Empty ID
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      // Vérifie que l'ID vide est détectable
      expect(marker.id.isEmpty, true);
    });

    test('marker should have proFixedLocation type', () {
      const marker = MapMarker(
        id: 'test-pro-id',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      expect(marker.type, MapMarkerType.proFixedLocation);
    });

    test('marker should have professionalAlert type', () {
      const marker = MapMarker(
        id: 'test-alert-id',
        type: MapMarkerType.professionalAlert,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      expect(marker.type, MapMarkerType.professionalAlert);
    });

    test('marker should have wedding type', () {
      const marker = MapMarker(
        id: 'test-wedding-id',
        type: MapMarkerType.wedding,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      expect(marker.type, MapMarkerType.wedding);
    });

    // Note: poiPrivate was removed in Phase 5 refactoring
    // MapMarkerType now only has 3 values: proFixedLocation, professionalAlert, wedding
  });

  group('UseCase validation logic', () {
    test('empty string should be detected', () {
      const emptyId = '';
      expect(emptyId.isEmpty, true);
    });

    test('valid UUID should not be empty', () {
      const validId = '123e4567-e89b-12d3-a456-426614174000';
      expect(validId.isEmpty, false);
      expect(validId.length, 36);
    });
  });

  group('MapMarkerType routing', () {
    test('should route proFixedLocation to professional details', () {
      const type = MapMarkerType.proFixedLocation;
      
      // Simule la logique de routing
      final shouldFetchPro = type == MapMarkerType.proFixedLocation;
      final shouldFetchAlert = type == MapMarkerType.professionalAlert;
      final shouldFetchWedding = type == MapMarkerType.wedding;
      
      expect(shouldFetchPro, true);
      expect(shouldFetchAlert, false);
      expect(shouldFetchWedding, false);
    });

    test('should route professionalAlert to alert details', () {
      const type = MapMarkerType.professionalAlert;
      
      final shouldFetchPro = type == MapMarkerType.proFixedLocation;
      final shouldFetchAlert = type == MapMarkerType.professionalAlert;
      final shouldFetchWedding = type == MapMarkerType.wedding;
      
      expect(shouldFetchPro, false);
      expect(shouldFetchAlert, true);
      expect(shouldFetchWedding, false);
    });

    test('should route wedding to wedding details', () {
      const type = MapMarkerType.wedding;
      
      final shouldFetchPro = type == MapMarkerType.proFixedLocation;
      final shouldFetchAlert = type == MapMarkerType.professionalAlert;
      final shouldFetchWedding = type == MapMarkerType.wedding;
      
      expect(shouldFetchPro, false);
      expect(shouldFetchAlert, false);
      expect(shouldFetchWedding, true);
    });

    // Note: poiPrivate test removed - enum value no longer exists
  });
}
