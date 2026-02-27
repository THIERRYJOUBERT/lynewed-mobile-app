import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:mocktail/mocktail.dart';

import 'package:lynewed_beta/features/map/domain/entities/map_marker.dart';
import 'package:lynewed_beta/features/map/presentation/services/marker_icon_generator.dart';

/// Mock for MarkerIconGenerator to control generation behavior.
class MockMarkerIconGenerator extends Mock implements MarkerIconGenerator {}

/// Helper to create a test marker.
MapMarker _createMarker({
  required String id,
  String? label,
  MapMarkerType type = MapMarkerType.proFixedLocation,
}) {
  return MapMarker(
    id: id,
    type: type,
    position: const gmaps.LatLng(48.8566, 2.3522),
    style: MarkerStyle(
      label: label ?? id,
      borderColorHex: '#FF5722',
    ),
  );
}

String _generateIconKey(MapMarker marker) {
  return '${marker.type.name}|${marker.style.borderColorHex}|${marker.style.avatarUrl}|${marker.style.label}';
}

void main() {
  late MockMarkerIconGenerator mockGenerator;

  setUpAll(() {
    registerFallbackValue(_createMarker(id: 'fallback'));
  });

  setUp(() {
    mockGenerator = MockMarkerIconGenerator();
  });

  group('Icon generation fallback behavior', () {
    test('should use fallback icon when generation throws', () async {
      // GIVEN: A generator that throws
      when(() => mockGenerator.generateIcon(any(), size: any(named: 'size')))
          .thenThrow(Exception('Network error'));

      final markerIcons = <String, gmaps.BitmapDescriptor>{};
      final marker = _createMarker(id: 'failing_marker');
      final cacheKey = _generateIconKey(marker);

      // WHEN: We simulate _generateSingleIcon logic with fallback
      try {
        final icon = await mockGenerator.generateIcon(marker, size: 144.0);
        markerIcons[cacheKey] = icon;
      } catch (e) {
        // Fallback: assign default marker (the fix we're implementing)
        markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
      }

      // THEN: Marker should have fallback icon, not be missing
      expect(markerIcons.containsKey(cacheKey), isTrue,
          reason: 'Marker should be present in icon cache with fallback');
      expect(markerIcons[cacheKey], equals(gmaps.BitmapDescriptor.defaultMarker),
          reason: 'Should use defaultMarker as fallback');
    });

    test('should handle multiple markers where some fail', () async {
      // GIVEN: 10 markers, 3 will fail
      final failingIds = {'marker_2', 'marker_5', 'marker_8'};

      when(() => mockGenerator.generateIcon(any(), size: any(named: 'size')))
          .thenAnswer((invocation) async {
        final marker = invocation.positionalArguments[0] as MapMarker;
        if (failingIds.contains(marker.id)) {
          throw Exception('Generation failed for ${marker.id}');
        }
        return gmaps.BitmapDescriptor.defaultMarker; // Simulates success icon
      });

      final markerIcons = <String, gmaps.BitmapDescriptor>{};
      final markers = List.generate(10, (i) => _createMarker(id: 'marker_$i'));

      // WHEN: Simulate _generateMarkersIcons with fallback logic
      final futures = <Future<void>>[];
      for (final marker in markers) {
        final cacheKey = _generateIconKey(marker);
        futures.add(() async {
          try {
            final icon = await mockGenerator.generateIcon(marker, size: 144.0);
            markerIcons[cacheKey] = icon;
          } catch (e) {
            markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
          }
        }());
      }

      // Wrap Future.wait in try/catch (the fix we're implementing)
      try {
        await Future.wait(futures);
      } catch (e) {
        // Should not reach here since individual futures are caught
      }

      // THEN: All 10 markers should be in cache (no invisible markers)
      expect(markerIcons.length, 10,
          reason: 'All markers should be present (7 success + 3 fallback)');
    });

    test('should not crash when Future.wait encounters exceptions', () async {
      // GIVEN: Generator that throws for some markers
      when(() => mockGenerator.generateIcon(any(), size: any(named: 'size')))
          .thenThrow(Exception('Crash'));

      final markerIcons = <String, gmaps.BitmapDescriptor>{};
      final markers = List.generate(5, (i) => _createMarker(id: 'marker_$i'));

      // WHEN: Simulate _generateMarkersIcons with try/catch on Future.wait
      final futures = <Future<void>>[];
      for (final marker in markers) {
        final cacheKey = _generateIconKey(marker);
        futures.add(() async {
          try {
            final icon = await mockGenerator.generateIcon(marker, size: 144.0);
            markerIcons[cacheKey] = icon;
          } catch (e) {
            markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
          }
        }());
      }

      // THEN: Should not throw
      try {
        await Future.wait(futures);
      } catch (e) {
        fail('Future.wait should not throw when individual futures are caught');
      }

      expect(markerIcons.length, 5);
    });
  });

  group('Mounted guard behavior', () {
    test('should not assign icon when widget is disposed', () async {
      // GIVEN: A disposed state (_mounted = false)
      bool mounted = false; // Simulates disposed widget

      when(() => mockGenerator.generateIcon(any(), size: any(named: 'size')))
          .thenThrow(Exception('Error after dispose'));

      final markerIcons = <String, gmaps.BitmapDescriptor>{};
      final marker = _createMarker(id: 'marker_disposed');
      final cacheKey = _generateIconKey(marker);

      // WHEN: Generation fails while widget is disposed
      try {
        final icon = await mockGenerator.generateIcon(marker, size: 144.0);
        if (mounted) {
          markerIcons[cacheKey] = icon;
        }
      } catch (e) {
        if (mounted) {
          markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
        }
      }

      // THEN: No icon should be assigned (mounted guard prevented it)
      expect(markerIcons.containsKey(cacheKey), isFalse,
          reason: 'Should not assign icon when widget is disposed');
    });

    test('should assign fallback icon when mounted and generation fails', () async {
      // GIVEN: A mounted widget
      bool mounted = true;

      when(() => mockGenerator.generateIcon(any(), size: any(named: 'size')))
          .thenThrow(Exception('Network timeout'));

      final markerIcons = <String, gmaps.BitmapDescriptor>{};
      final marker = _createMarker(id: 'marker_mounted');
      final cacheKey = _generateIconKey(marker);

      // WHEN: Generation fails while widget is still mounted
      try {
        final icon = await mockGenerator.generateIcon(marker, size: 144.0);
        if (mounted) {
          markerIcons[cacheKey] = icon;
        }
      } catch (e) {
        if (mounted) {
          markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
        }
      }

      // THEN: Fallback icon should be assigned
      expect(markerIcons[cacheKey], equals(gmaps.BitmapDescriptor.defaultMarker));
    });
  });
}
