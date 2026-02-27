# S08 - RÉSUMÉ ROUNDS 1 & 2

## Round 1 (Initial Challenge)
**Verdict** : ⚠️ Corrections moyennes requises
**Problèmes** : 3
**Estimation** : 3 SP → 5 SP

## Round 2 (Re-Challenge)
**Verdict** : ❌ BLOQUÉ
**Nouveaux problèmes** : 8
**Estimation** : 5 SP → **8 SP** (165% augmentation)

---

## PROBLÈMES CRITIQUES DÉCOUVERTS (Round 2)

### 🔴 1. Fichiers de tests INEXISTANTS
- `marker_icon_generator_test.dart` : NOT FOUND
- `lynewed_map_widget_test.dart` : NOT FOUND
- Story référence 9 tests, 0 fichiers existent

### 🔴 2. LRU est un FAUX LRU
**Code actuel** : `Map<String, BitmapDescriptor>` (non-ordonné)
**Story propose** : `_iconCache.keys.take(50)` (FIFO, pas LRU)

**Problème** :
- Supprime les PLUS VIEILLES INSERTIONS, pas les MOINS RÉCEMMENT UTILISÉES
- Marker affiché 100x/sec peut être évincé s'il a été inséré tôt
- **Ce n'est PAS un LRU**, c'est un FIFO naïf

**Solution** :
```dart
import 'dart:collection';

final LinkedHashMap<String, gmaps.BitmapDescriptor> _iconCache = LinkedHashMap();

Future<gmaps.BitmapDescriptor> generateIcon(...) async {
  if (_iconCache.containsKey(cacheKey)) {
    final icon = _iconCache.remove(cacheKey)!; // Remove
    _iconCache[cacheKey] = icon; // Re-insert (most recent access)
    return icon;
  }
  // Eviction LRU
  if (_iconCache.length >= _maxCacheSize) {
    _iconCache.remove(_iconCache.keys.first); // Remove oldest ACCESS
  }
  ...
}
```

### 🔴 3. Fallback icon sans mounted guard
**Code proposé par story** :
```dart
catch (e) {
  debugPrint('...');
  _markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker; // ❌ NO GUARD
}
```

**Crash** : Si widget disposed pendant la génération, setState sur widget mort

**Fix** :
```dart
catch (e) {
  debugPrint('...');
  if (_mounted) { // ✅ GUARD
    _markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
  }
}
```

### 🔴 4. Race condition cache eviction
**Problème** :
- `_generateSingleIcon` appelé en parallèle (`Future.wait(futures)`)
- Plusieurs futures atteignent `_iconCache.length >= 200` simultanément
- Éviction concurrente → cache final peut dépasser 200

**Solution** : Protéger avec Lock ou gérer éviction dans `generateIcon` uniquement

### 🔴 5. Image cache sans éviction
**Code actuel** :
```dart
_imageCache[url] = frame.image; // ❌ NO EVICTION
```

**Impact** : Memory leak (cache grandit sans limite)

**Fix** : Implémenter même logique d'éviction pour `_imageCache`

### 🔴 6. Future.wait sans try/catch
**Code actuel** :
```dart
await Future.wait(futures); // ❌ Si 1 future throw, tout crash
```

**Fix** :
```dart
try {
  await Future.wait(futures);
} catch (e) {
  debugPrint('Some icons failed to generate: $e');
}
```

### 🟡 7. AC-2 non testable
> "And the eviction does not cause any visible glitch on the map"

Comment valider "no visible glitch" dans un test unitaire ?

**Fix** : Reformuler en critère testable :
```gherkin
Then the cache size remains <= 200
And cached icons still visible on screen are retained
```

### 🟡 8. Cache limits non justifiés
**Story** : `_maxCacheSize = 200`, `_maxImageCacheSize = 100`

**Calcul mémoire** :
- 1 icône 144x144 RGBA = 81 KB
- 200 icônes = 16.2 MB
- 100 images = 8.1 MB
- **Total = 24 MB** (non documenté)

**Fix** : Documenter le calcul dans la story

---

## VERDICT FINAL

**Status** : ❌ BLOQUÉ

**Peut démarrer** : NON

**Raisons** :
1. 4 problèmes BLOQUANTS non résolus
2. Code proposé causerait des bugs en production
3. Tests inexistants (0/9)
4. Estimation sous-évaluée de 165%

**Estimation réaliste** : **8 SP** (7h dev + 1h review)

---

## ACTIONS REQUISES

### Critiques (AVANT implémentation)
1. ✅ Créer fichiers de tests
2. ✅ Implémenter VRAI LRU (LinkedHashMap + touch)
3. ✅ Ajouter mounted guard dans catch
4. ✅ Réécrire AC-2/AC-3 (testables)

### Majeures (RECOMMANDÉ)
5. ✅ Documenter calcul mémoire
6. ✅ Protéger cache avec Lock
7. ✅ Implémenter éviction image cache
8. ✅ Ajouter try/catch Future.wait

---

## RECOMMANDATIONS STRATÉGIQUES

### 1. Diviser S08 en 2 stories
- **S08a** : Fallback Icons (3 SP)
- **S08b** : Cache Optimization (5 SP)

### 2. Utiliser package `lru_cache`
```yaml
dependencies:
  lru_cache: ^1.0.0
```

Au lieu d'implémenter un LRU thread-safe custom (error-prone).

### 3. Ajouter AC-0 (Prerequisite)
```gherkin
Given the test files exist
When I run `flutter test test/features/map/`
Then the test runner finds marker_icon_generator_test.dart
And the test runner finds lynewed_map_widget_test.dart
```

---

**Rapport complet** : `S08-RECHALLENGE-REPORT.md` (15 pages, analyse exhaustive)
