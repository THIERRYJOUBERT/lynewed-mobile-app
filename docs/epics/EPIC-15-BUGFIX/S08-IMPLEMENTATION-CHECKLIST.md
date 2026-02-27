# S08 Implementation Checklist

> **Quick reference** pour implémenter S08 étape par étape
> **Story complète** : [S08-map-optimization-error-handling.md](stories/S08-map-optimization-error-handling.md)

---

## Phase 0 : Setup (15 min)

### 1. Créer fichiers tests

```bash
mkdir -p test/features/map/presentation/services
mkdir -p test/features/map/presentation/widgets
touch test/features/map/presentation/services/marker_icon_generator_test.dart
touch test/features/map/presentation/widgets/lynewed_map_widget_test.dart
```

### 2. Ajouter dépendance

```yaml
# pubspec.yaml
dependencies:
  synchronized: ^3.3.0
```

```bash
flutter pub get
```

**Validation** : `flutter pub get` passe sans erreur

---

## Phase 1 : RED (Tests) - 3h

### marker_icon_generator_test.dart (2h)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/map/presentation/services/marker_icon_generator.dart';

void main() {
  group('MarkerIconGenerator - Cache LRU', () {
    late MarkerIconGenerator generator;

    setUp(() {
      generator = MarkerIconGenerator();
    });

    test('should return cached icon on second call (LRU)', () async {
      // TODO: Implement
    });

    test('should evict LEAST RECENTLY USED entries, not oldest insertions', () async {
      // TODO: Test critique - voir exemple dans AC-2
    });

    test('should handle concurrent access without race conditions', () async {
      // TODO: 50 appels parallèles
    });

    test('should handle image load failure gracefully', () async {
      // TODO: Mock HTTP fail
    });

    test('should respect timeout on slow image loads', () async {
      // TODO: Mock slow response > 5s
    });

    test('should evict oldest image cache entries when limit reached', () async {
      // TODO: Vérifier _imageCache limite 100
    });

    test('cacheSize should reflect actual cache entries', () {
      // TODO: Vérifier getter
    });

    test('clearCache should empty both icon and image caches', () {
      // TODO: Vérifier clearCache()
    });
  });
}
```

**Commande** : `flutter test --no-pub test/features/map/presentation/services/marker_icon_generator_test.dart`

### lynewed_map_widget_test.dart (1h)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LynewedMapWidget - Fallback & Error Handling', () {
    test('should display fallback icon when generation fails', () async {
      // TODO: Mock generator throw
    });

    test('should not crash when widget is disposed during generation', () async {
      // TODO: Dispose pendant Future.wait
    });

    test('should display all markers even if some icons fail', () async {
      // TODO: 50 markers, 5 fail → 50 visible
    });

    test('should protect fallback assignment with mounted guard', () async {
      // TODO: Vérifier if (_mounted)
    });

    test('should handle Future.wait exception gracefully', () async {
      // TODO: Future.wait wrapped in try/catch
    });
  });
}
```

**Commande** : `flutter test --no-pub test/features/map/presentation/widgets/lynewed_map_widget_test.dart`

---

## Phase 2 : GREEN (Implementation) - 2h30

### marker_icon_generator.dart (2h)

#### Étape 1 : Imports + Types

```dart
import 'dart:collection';  // LinkedHashMap
import 'package:synchronized/synchronized.dart';  // Lock
```

#### Étape 2 : Champs privés

```dart
class MarkerIconGenerator {
  MarkerIconGenerator({MarkerIconConfig? config})
      : _config = config ?? const MarkerIconConfig(),
        _iconCache = LinkedHashMap(),  // ✅ Remplacer Map par LinkedHashMap
        _imageCache = LinkedHashMap(),  // ✅ Remplacer Map par LinkedHashMap
        _cacheLock = Lock();  // ✅ Ajouter Lock

  static const int _maxIconCacheSize = 200;  // ✅ Ajouter
  static const int _maxImageCacheSize = 100;  // ✅ Ajouter

  final LinkedHashMap<String, gmaps.BitmapDescriptor> _iconCache;
  final LinkedHashMap<String, ui.Image> _imageCache;
  final Lock _cacheLock;  // ✅ Ajouter
  // ...
}
```

#### Étape 3 : Réécrire generateIcon (LRU + Lock)

```dart
Future<gmaps.BitmapDescriptor> generateIcon(
  MapMarker marker, {
  double? size,
}) async {
  final actualSize = size ?? 168.0;
  final cacheKey = _generateCacheKey(marker, actualSize);

  return await _cacheLock.synchronized(() async {  // ✅ Lock
    // LRU: Check cache + re-insert
    if (_iconCache.containsKey(cacheKey)) {
      final icon = _iconCache.remove(cacheKey)!;  // ✅ Remove
      _iconCache[cacheKey] = icon;  // ✅ Re-insert (move to end)
      return icon;
    }

    // Generate icon
    gmaps.BitmapDescriptor icon;
    switch (marker.type) {
      case MapMarkerType.professionalAlert:
        icon = await _createAlertIcon(marker, actualSize);
        break;
      // ... autres types
    }

    // Evict if needed (remove FIRST = oldest access)
    if (_iconCache.length >= _maxIconCacheSize) {
      _iconCache.remove(_iconCache.keys.first);  // ✅ LRU eviction
    }

    _iconCache[cacheKey] = icon;
    return icon;
  });
}
```

#### Étape 4 : Réécrire _loadImage (LRU + Lock + Eviction)

```dart
Future<ui.Image?> _loadImage(String url) async {
  return await _cacheLock.synchronized(() async {  // ✅ Lock
    // LRU: Check cache + re-insert
    if (_imageCache.containsKey(url)) {
      final img = _imageCache.remove(url)!;  // ✅ Remove
      _imageCache[url] = img;  // ✅ Re-insert (move to end)
      return img;
    }

    // Load image
    ui.Image? img;
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final codec = await ui.instantiateImageCodec(response.bodyBytes);
        final frame = await codec.getNextFrame();
        img = frame.image;
      }
    } catch (e) {
      debugPrint('[MarkerIconGenerator._loadImage] Error: $e');
      return null;
    }

    // Evict if needed
    if (_imageCache.length >= _maxImageCacheSize) {  // ✅ Ajouter
      _imageCache.remove(_imageCache.keys.first);  // ✅ LRU eviction
    }

    if (img != null) {
      _imageCache[url] = img;
    }
    return img;
  });
}
```

### lynewed_map_widget.dart (30 min)

#### Étape 1 : Ajouter mounted guard dans catch (ligne 196-198)

```dart
Future<void> _generateSingleIcon(MapMarker marker, String cacheKey) async {
  try {
    final icon = await _iconGenerator.generateIcon(marker, size: 144.0);
    if (_mounted) {
      _markerIcons[cacheKey] = icon;
    }
  } catch (e) {
    debugPrint('[LynewedMapWidget._generateSingleIcon] Error: $e');
    if (_mounted) {  // ✅ AJOUTER GUARD
      _markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
    }
  }
}
```

#### Étape 2 : Wrapper Future.wait dans try/catch (ligne 182)

```dart
Future<void> _generateMarkersIcons(List<MapMarker> markers) async {
  if (!_mounted) return;

  final futures = <Future<void>>[];

  for (final marker in markers) {
    final cacheKey = _generateIconKey(marker);
    if (!_markerIcons.containsKey(cacheKey)) {
      futures.add(_generateSingleIcon(marker, cacheKey));
    }
  }

  if (futures.isNotEmpty) {
    try {  // ✅ AJOUTER TRY/CATCH
      await Future.wait(futures);
    } catch (e) {
      debugPrint('[LynewedMapWidget._generateMarkersIcons] Some icons failed: $e');
    }
  }

  if (_mounted) setState(() {});
}
```

---

## Phase 3 : Validation - 1h

### Tests unitaires

```bash
# Tests generator
flutter test --no-pub test/features/map/presentation/services/marker_icon_generator_test.dart

# Tests widget
flutter test --no-pub test/features/map/presentation/widgets/lynewed_map_widget_test.dart

# Tous les tests map (regression)
flutter test --no-pub test/features/map/
```

**Attendu** : 0 failures, 13+ nouveaux tests passent

### Lint

```bash
flutter analyze --fatal-infos lib/features/map/presentation/services/marker_icon_generator.dart
flutter analyze --fatal-infos lib/features/map/presentation/widgets/lynewed_map_widget.dart
```

**Attendu** : 0 warnings

### Review Adversariale

Checklist re-challenge (8 problèmes) :

- [x] ~~Fichiers tests inexistants~~ → Créés
- [x] ~~FAKE LRU cache~~ → LinkedHashMap + réinsertion
- [x] ~~Mounted guard manquant~~ → `if (_mounted)` dans catch
- [x] ~~Race condition cache~~ → Lock sur accès cache
- [x] ~~Image cache sans éviction~~ → Limite 100 + LRU
- [x] ~~Future.wait sans try/catch~~ → Wrapped
- [x] ~~AC-2/AC-3 non testables~~ → Critères quantifiables
- [x] ~~Cache limits non justifiés~~ → Documentés

---

## Critères de Succès

| Critère | Commande | Attendu |
|---------|----------|---------|
| Tests passent | `flutter test --no-pub test/features/map/presentation/` | 0 failures |
| Lint OK | `flutter analyze --fatal-infos` | 0 warnings |
| Regression OK | `flutter test --no-pub test/features/map/` | Tests existants passent |
| Deps OK | `flutter pub get` | No errors |
| Review OK | Checklist re-challenge | 8/8 résolus |

---

## Timeline Attendue

| Phase | Durée | Cumul |
|-------|-------|-------|
| Phase 0 : Setup | 15 min | 15 min |
| Phase 1 : Tests | 3h | 3h15 |
| Phase 2 : Implem | 2h30 | 5h45 |
| Phase 3 : Validation | 1h | 6h45 |

**Total** : ~6h45 (vs 1h45 initial = +281%)

---

## Dépannage

### "Output too large" pendant tests

```bash
# Tester fichier par fichier
flutter test --no-pub test/features/map/presentation/services/marker_icon_generator_test.dart
```

### Lock timeout

Si tests thread-safety timeout (> 30s) :
1. Vérifier que `_generateIconUnsafe` est appelé HORS lock
2. Réduire nombre d'appels parallèles dans test (50 → 10)

### Tests fail après implem LRU

Vérifier ordre LinkedHashMap :
```dart
test('LinkedHashMap preserves insertion order', () {
  final map = LinkedHashMap<String, int>();
  map['a'] = 1;
  map['b'] = 2;
  map['c'] = 3;
  expect(map.keys.first, 'a');  // Oldest insertion
  expect(map.keys.last, 'c');   // Newest insertion
});
```

---

## Références

- [Story complète S08](stories/S08-map-optimization-error-handling.md)
- [Re-challenge summary](S08-RE-CHALLENGE-SUMMARY.md)
- [Package synchronized](https://pub.dev/packages/synchronized)
- [LinkedHashMap docs](https://api.dart.dev/stable/dart-collection/LinkedHashMap-class.html)
