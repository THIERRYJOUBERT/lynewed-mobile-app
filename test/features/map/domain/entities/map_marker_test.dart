import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

void main() {
  group('MapMarker', () {
    test('should create MapMarker with required fields', () {
      const marker = MapMarker(
        id: 'test-id',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      expect(marker.id, 'test-id');
      expect(marker.type, MapMarkerType.proFixedLocation);
      expect(marker.position.latitude, 48.8566);
      expect(marker.position.longitude, 2.3522);
    });

    test('should create MapMarker with style and metadata', () {
      const marker = MapMarker(
        id: 'test-id',
        type: MapMarkerType.professionalAlert,
        position: gmaps.LatLng(48.8566, 2.3522),
        style: MarkerStyle(
          avatarUrl: 'https://example.com/avatar.jpg',
          label: 'Test Label',
          borderColorHex: '#FF0000',
        ),
        metadata: {'name': 'Test Pro', 'profession': 'photographer'},
      );

      expect(marker.style.avatarUrl, 'https://example.com/avatar.jpg');
      expect(marker.style.label, 'Test Label');
      expect(marker.metadata['name'], 'Test Pro');
    });

    test('copyWith should create new instance with updated fields', () {
      const original = MapMarker(
        id: 'test-id',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
        style: MarkerStyle(label: 'Original'),
      );

      final updated = original.copyWith(
        style: const MarkerStyle(label: 'Updated'),
      );

      expect(updated.id, original.id);
      expect(updated.type, original.type);
      expect(updated.style.label, 'Updated');
      expect(original.style.label, 'Original'); // Original unchanged
    });

    test('equality should compare all fields', () {
      const marker1 = MapMarker(
        id: 'same-id',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      const marker2 = MapMarker(
        id: 'same-id',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      const marker3 = MapMarker(
        id: 'different-id',
        type: MapMarkerType.proFixedLocation,
        position: gmaps.LatLng(48.8566, 2.3522),
      );

      expect(marker1, equals(marker2)); // Same fields = equal
      expect(marker1, isNot(equals(marker3))); // Different ID = not equal
    });
  });

  group('MapMarkerType', () {
    test('should have correct values', () {
      // Phase 5: MapMarkerType reduced to 3 values (poiPrivate removed)
      expect(MapMarkerType.values.length, 3);
      expect(MapMarkerType.values, contains(MapMarkerType.proFixedLocation));
      expect(MapMarkerType.values, contains(MapMarkerType.professionalAlert));
      expect(MapMarkerType.values, contains(MapMarkerType.wedding));
    });
  });

  group('MarkerStyle', () {
    test('should create MarkerStyle with optional fields', () {
      const style = MarkerStyle(
        avatarUrl: 'https://example.com/avatar.jpg',
        borderColorHex: '#FF0000',
        label: 'Test',
        iconAsset: 'assets/icon.png',
      );

      expect(style.avatarUrl, 'https://example.com/avatar.jpg');
      expect(style.borderColorHex, '#FF0000');
      expect(style.label, 'Test');
      expect(style.iconAsset, 'assets/icon.png');
    });

    test('copyWith should work correctly', () {
      const original = MarkerStyle(
        avatarUrl: 'https://example.com/avatar.jpg',
        label: 'Original',
      );

      final updated = original.copyWith(label: 'Updated');

      expect(updated.avatarUrl, original.avatarUrl);
      expect(updated.label, 'Updated');
    });
  });
}
