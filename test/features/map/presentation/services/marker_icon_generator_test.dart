import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import 'package:lynewed_beta/features/map/domain/entities/map_marker.dart';
import 'package:lynewed_beta/features/map/presentation/services/marker_icon_generator.dart';

/// Helper to create a test marker with unique style (forces unique cache key).
MapMarker _createMarker({
  required String id,
  String? avatarUrl,
  String? label,
  String? borderColorHex,
  MapMarkerType type = MapMarkerType.proFixedLocation,
}) {
  return MapMarker(
    id: id,
    type: type,
    position: const gmaps.LatLng(48.8566, 2.3522),
    style: MarkerStyle(
      avatarUrl: avatarUrl,
      label: label ?? id, // Unique label = unique cache key
      borderColorHex: borderColorHex ?? '#FF5722',
    ),
  );
}

void main() {
  group('MarkerIconGenerator - Cache LRU', () {
    late MarkerIconGenerator generator;

    setUp(() {
      generator = MarkerIconGenerator();
    });

    test('should cache icon on first generation and return cached on second call', () async {
      final marker = _createMarker(id: 'marker_1');

      final icon1 = await generator.generateIcon(marker, size: 144.0);
      expect(generator.cacheSize, 1);

      final icon2 = await generator.generateIcon(marker, size: 144.0);
      expect(generator.cacheSize, 1); // Same entry, not duplicated
      expect(identical(icon1, icon2), isTrue); // Same instance from cache
    });

    test('should generate different cache entries for different markers', () async {
      final marker1 = _createMarker(id: 'marker_1', label: 'Alpha');
      final marker2 = _createMarker(id: 'marker_2', label: 'Beta');

      await generator.generateIcon(marker1, size: 144.0);
      await generator.generateIcon(marker2, size: 144.0);

      expect(generator.cacheSize, 2);
    });

    test('should evict LEAST RECENTLY USED entries, not oldest insertions', () async {
      // Use a generator with small max cache for testability
      generator = MarkerIconGenerator(maxIconCacheSize: 5);

      // Insert 5 markers (fills cache)
      for (int i = 0; i < 5; i++) {
        await generator.generateIcon(
          _createMarker(id: 'marker_$i'),
          size: 144.0,
        );
      }
      expect(generator.cacheSize, 5);

      // Access marker_0 (moves to end = most recently used)
      await generator.generateIcon(
        _createMarker(id: 'marker_0'),
        size: 144.0,
      );

      // Insert new marker -> should evict marker_1 (LRU), NOT marker_0
      await generator.generateIcon(
        _createMarker(id: 'marker_new'),
        size: 144.0,
      );

      expect(generator.cacheSize, 5);
      expect(generator.hasInCache(_cacheKey(_createMarker(id: 'marker_0'), 144.0)), isTrue,
          reason: 'marker_0 was recently accessed, should NOT be evicted');
      expect(generator.hasInCache(_cacheKey(_createMarker(id: 'marker_1'), 144.0)), isFalse,
          reason: 'marker_1 is LRU, should be evicted');
      expect(generator.hasInCache(_cacheKey(_createMarker(id: 'marker_new'), 144.0)), isTrue);
    });

    test('should not exceed max cache size under sequential inserts', () async {
      generator = MarkerIconGenerator(maxIconCacheSize: 10);

      for (int i = 0; i < 20; i++) {
        await generator.generateIcon(
          _createMarker(id: 'marker_$i'),
          size: 144.0,
        );
      }

      expect(generator.cacheSize, lessThanOrEqualTo(10));
    });

    test('should clear both icon and image caches', () async {
      await generator.generateIcon(
        _createMarker(id: 'marker_1'),
        size: 144.0,
      );
      expect(generator.cacheSize, 1);

      generator.clearCache();
      expect(generator.cacheSize, 0);
      expect(generator.imageCacheSize, 0);
    });

    test('cacheSize and imageCacheSize should reflect actual entries', () async {
      expect(generator.cacheSize, 0);
      expect(generator.imageCacheSize, 0);

      await generator.generateIcon(
        _createMarker(id: 'marker_1'),
        size: 144.0,
      );

      expect(generator.cacheSize, 1);
    });
  });

  group('MarkerIconGenerator - Thread Safety', () {
    late MarkerIconGenerator generator;

    setUp(() {
      generator = MarkerIconGenerator(maxIconCacheSize: 50);
    });

    test('should handle concurrent access without exceeding cache limit', () async {
      // Launch 100 parallel icon generations (50 unique markers)
      final futures = <Future<gmaps.BitmapDescriptor>>[];
      for (int i = 0; i < 100; i++) {
        final markerId = 'marker_${i % 50}'; // 50 unique markers
        futures.add(
          generator.generateIcon(
            _createMarker(id: markerId),
            size: 144.0,
          ),
        );
      }

      final results = await Future.wait(futures);

      // All should return valid icons
      expect(results.length, 100);
      for (final icon in results) {
        expect(icon, isNotNull);
      }

      // Cache should never exceed limit
      expect(generator.cacheSize, lessThanOrEqualTo(50));
    });

    test('should not crash under rapid sequential access patterns', () async {
      // Rapid generate-access-evict cycle
      for (int i = 0; i < 200; i++) {
        await generator.generateIcon(
          _createMarker(id: 'marker_${i % 30}'),
          size: 144.0,
        );
      }

      expect(generator.cacheSize, lessThanOrEqualTo(50));
    });
  });

  group('MarkerIconGenerator - Image Cache Eviction', () {
    test('should evict oldest image cache entries when limit reached', () async {
      // This test validates that _imageCache also has eviction.
      // Since _loadImage is internal and requires network, we test indirectly
      // by generating markers with avatarUrl (which will fail in test = null image)
      // and verifying generator doesn't crash.
      final generator = MarkerIconGenerator(maxImageCacheSize: 5);

      for (int i = 0; i < 10; i++) {
        await generator.generateIcon(
          _createMarker(
            id: 'marker_$i',
            avatarUrl: 'https://example.com/avatar_$i.jpg',
          ),
          size: 144.0,
        );
      }

      // Should not crash and image cache should be bounded
      expect(generator.imageCacheSize, lessThanOrEqualTo(5));
    });
  });

  group('MarkerIconGenerator - Error Handling', () {
    test('should handle image load failure gracefully (returns icon without avatar)', () async {
      final generator = MarkerIconGenerator();
      final marker = _createMarker(
        id: 'marker_bad_url',
        avatarUrl: 'https://nonexistent.invalid/avatar.jpg',
        label: 'Test User',
      );

      // Should not throw, should return icon (with initials fallback)
      final icon = await generator.generateIcon(marker, size: 144.0);
      expect(icon, isNotNull);
      expect(generator.cacheSize, 1);
    });
  });
}

/// Helper to compute cache key matching generator's internal logic.
String _cacheKey(MapMarker marker, double size) {
  return '${marker.type.name}|${marker.style.borderColorHex}|${marker.style.avatarUrl}|${marker.style.label}|$size';
}
