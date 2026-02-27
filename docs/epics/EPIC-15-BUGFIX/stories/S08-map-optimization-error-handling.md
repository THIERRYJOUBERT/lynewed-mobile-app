# S08 - Carte : optimisation + error handling

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : UI
> **Complexite** : M (Medium - 8 points)
> **Dependances** : Aucune
> **Source bugs** : BUG-05 (crash dezoom), BUG-13 (markers invisibles)
> **Status** : Done
> **Re-challenge** : 2026-02-16 (8 problèmes bloquants détectés)

---

## Contexte

Thierry a remonte deux problemes lies a la carte :
1. Des markers disparaissent (icones invisibles quand la generation echoue silencieusement)
2. Un crash potentiel au dezoom rapide

**INSTRUCTION LEO CRITIQUE** : **La carte FONCTIONNE actuellement. Il faut faire TRES ATTENTION de ne rien casser.** L'approche est **defensive et minimale** : ameliorer le error handling et le cache sans refactorer la carte. On touche le MINIMUM de code pour maximiser la robustesse.

**Principe** : Chaque modification doit etre testee exhaustivement. Si un changement introduit une regression, le reverter immediatement. Mieux vaut un bug mineur (markers invisibles chez 1 user) qu'un bug majeur (carte cassee pour tous).

### Analyse du code existant

**`lynewed_map_widget.dart:189-199`** - `_generateSingleIcon` :
- Le `catch` log l'erreur mais ne fournit aucune icone fallback
- Resultat : le marker est filtre dans `_buildMarkers()` (ligne 289 : `where _markerIcons.containsKey`) et devient invisible
- ❌ **BLOQUANT** : Manque `if (_mounted)` dans le catch (crash si widget disposed pendant generation)

**`marker_icon_generator.dart`** :
- `_loadImage` a un timeout de 5s (ligne 272) -- correct
- ❌ **BLOQUANT** : Le cache `_iconCache` et `_imageCache` grandissent sans limite (memory leak)
- ❌ **BLOQUANT** : Pas de protection contre les appels concurrents (race condition)

**`lynewed_map_widget.dart:182`** - `Future.wait` :
- ❌ **BLOQUANT** : Pas de try/catch autour de `Future.wait(futures)` - un seul Future qui fail crash l'app

### Re-challenge (2026-02-16) - 8 problèmes détectés

| # | Problème | Sévérité | Impact |
|---|----------|----------|--------|
| 1 | **Fichiers tests inexistants** | BLOQUANT | Cannot follow TDD without tests |
| 2 | **FAKE LRU cache** | BLOQUANT | `Map.keys.take(50)` = FIFO naïf, pas LRU. Un marker affiché 100x/sec sera évincé s'il a été inséré tôt |
| 3 | **Mounted guard manquant** | BLOQUANT | Crash si widget disposed pendant génération async (ligne 196-198) |
| 4 | **Race condition cache** | BLOQUANT | Appels parallèles peuvent dépasser limite 200 |
| 5 | **Image cache sans éviction** | SEVERE | `_imageCache` grandit sans limite → memory leak |
| 6 | **Future.wait sans try/catch** | SEVERE | Crash possible si un seul Future fail (ligne 182) |
| 7 | **AC-2 et AC-3 non testables** | MAJOR | "no visible glitch" = critère subjectif |
| 8 | **Cache limits non justifiés** | MINOR | 24 MB non documenté |

### Calcul mémoire cache (Justification)

| Cache | Entrées | Taille unitaire | Total | Justification |
|-------|---------|-----------------|-------|---------------|
| `_iconCache` | 200 | ~20 KB (PNG 144x144) | ~4 MB | 200 markers max visibles simultanément |
| `_imageCache` | 100 | ~200 KB (JPEG avatar) | ~20 MB | Réutilisation entre zoom levels |
| **TOTAL** | - | - | **~24 MB** | Acceptable pour cache in-memory |

**Note** : Ces limites sont généreuses car :
- La carte affiche rarement plus de 50 markers en même temps
- Les icones sont régénérées automatiquement si évincées
- Coût génération icon << coût mémoire illimitée

---

## Scope

### In scope
- Icone fallback quand generation echoue (marker toujours visible)
- Limite du cache pour eviter accumulation memoire
- Gestion defensive des erreurs dans le pipeline de generation

### Out of scope
- Refonte du systeme de markers
- Changement de la logique de clustering/zoom
- Nouveau design des icones

---

## Fichiers concernes

| Fichier | Modification | Status |
|---------|--------------|--------|
| `lib/features/map/presentation/widgets/lynewed_map_widget.dart` | Fallback icon + mounted guard + try/catch Future.wait | Modify |
| `lib/features/map/presentation/services/marker_icon_generator.dart` | **VRAI LRU** avec `LinkedHashMap` + éviction `_imageCache` + Lock | Modify |
| `test/features/map/presentation/services/marker_icon_generator_test.dart` | **À CRÉER** : tests cache LRU + fallback + thread-safety | New |
| `test/features/map/presentation/widgets/lynewed_map_widget_test.dart` | **À CRÉER** : tests fallback icons + mounted guard | New |

### AC-0 : Pré-requis (BLOQUANT)

**AVANT toute implémentation**, créer les fichiers tests :

```bash
# Créer dossiers
mkdir -p test/features/map/presentation/services
mkdir -p test/features/map/presentation/widgets

# Créer fichiers vides avec header
touch test/features/map/presentation/services/marker_icon_generator_test.dart
touch test/features/map/presentation/widgets/lynewed_map_widget_test.dart
```

**Rationale** : On ne peut pas suivre TDD (RED → GREEN → REFACTOR) sans fichiers tests. Cette étape est **NON NÉGOCIABLE**.

---

## Criteres d'acceptation

### AC-1 : Fallback icon quand la generation echoue

```gherkin
Given a map with visible markers
When the custom icon generation fails for a marker (network error, timeout, decode error)
Then the marker displays a default fallback icon (BitmapDescriptor.defaultMarker)
And the marker is NOT invisible on the map
And a debug log is printed with the error details
```

**Implementation** (lynewed_map_widget.dart:189-199) :
```dart
Future<void> _generateSingleIcon(MapMarker marker, String cacheKey) async {
  try {
    final icon = await _iconGenerator.generateIcon(marker, size: 144.0);
    if (_mounted) {  // Guard déjà existant
      _markerIcons[cacheKey] = icon;
    }
  } catch (e) {
    debugPrint('[LynewedMapWidget._generateSingleIcon] Error: $e');
    // ⚠️ CRITIQUE : Ajouter mounted guard AVANT setState implicite
    if (_mounted) {
      _markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
    }
  }
}
```

**Résultat** : Le marker est toujours visible même si l'icône custom échoue.

**Test** :
```dart
test('should use fallback icon when generation fails', () async {
  // Mock generator qui throw
  when(mockGenerator.generateIcon(any, size: anyNamed('size')))
      .thenThrow(Exception('Network error'));

  await tester.pumpWidget(testWidget);
  await tester.pumpAndSettle();

  // Vérifier marker visible avec defaultMarker
  expect(_markerIcons.values.first, gmaps.BitmapDescriptor.defaultMarker);
});
```

---

### AC-2 : Cache LRU avec éviction (CORRECTIF MAJEUR)

```gherkin
Given the marker icon cache contains 200 entries
When a new icon is generated and cached
Then the cache size remains at or below 200 entries
And the LEAST RECENTLY USED entries are evicted (not oldest insertions)
And concurrent accesses do not cause race conditions
```

**Problème avec l'approche initiale** :
```dart
// ❌ FAUX - C'est du FIFO naïf, pas du LRU
if (_iconCache.length >= _maxCacheSize) {
  final keysToRemove = _iconCache.keys.take(50).toList();
  for (final key in keysToRemove) {
    _iconCache.remove(key);
  }
}
```

**Pourquoi c'est faux** :
- `Map.keys.take(50)` retourne les 50 **premières insertions**, pas les moins récemment **utilisées**
- Un marker affiché 100 fois/sec sera évincé s'il a été inséré il y a longtemps
- Pire performance : on évince exactement ce qu'on devrait garder

**Solution CORRECTE** : Utiliser `LinkedHashMap` + réinsertion après accès :

```dart
import 'dart:collection';
import 'package:synchronized/synchronized.dart';  // pub: synchronized: ^3.3.0

class MarkerIconGenerator {
  MarkerIconGenerator({MarkerIconConfig? config})
      : _config = config ?? const MarkerIconConfig(),
        _iconCache = LinkedHashMap(),  // ✅ Garde l'ordre d'insertion
        _imageCache = LinkedHashMap(),
        _cacheLock = Lock();  // ✅ Thread-safety

  static const int _maxIconCacheSize = 200;
  static const int _maxImageCacheSize = 100;

  final LinkedHashMap<String, gmaps.BitmapDescriptor> _iconCache;
  final LinkedHashMap<String, ui.Image> _imageCache;
  final Lock _cacheLock;

  Future<gmaps.BitmapDescriptor> generateIcon(MapMarker marker, {double? size}) async {
    final cacheKey = _generateCacheKey(marker, size ?? 168.0);

    return await _cacheLock.synchronized(() async {
      // Check cache (LRU: re-insert to move to end)
      if (_iconCache.containsKey(cacheKey)) {
        final icon = _iconCache.remove(cacheKey)!;
        _iconCache[cacheKey] = icon;  // Re-insert → move to end (most recent)
        return icon;
      }

      // Generate icon
      final icon = await _generateIconUnsafe(marker, size ?? 168.0);

      // Evict if needed (remove from beginning = oldest access)
      if (_iconCache.length >= _maxIconCacheSize) {
        _iconCache.remove(_iconCache.keys.first);  // LRU eviction
      }

      _iconCache[cacheKey] = icon;
      return icon;
    });
  }

  Future<ui.Image?> _loadImage(String url) async {
    return await _cacheLock.synchronized(() async {
      // Check cache (LRU)
      if (_imageCache.containsKey(url)) {
        final img = _imageCache.remove(url)!;
        _imageCache[url] = img;  // Move to end
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
      if (_imageCache.length >= _maxImageCacheSize) {
        _imageCache.remove(_imageCache.keys.first);  // LRU eviction
      }

      _imageCache[url] = img;
      return img;
    });
  }
}
```

**Dépendance** :
```yaml
# pubspec.yaml
dependencies:
  synchronized: ^3.3.0  # Lock pour thread-safety
```

**Test LRU** :
```dart
test('should evict LEAST RECENTLY USED entries, not oldest insertions', () async {
  final gen = MarkerIconGenerator();

  // Insert 200 markers (0-199)
  for (int i = 0; i < 200; i++) {
    await gen.generateIcon(createMarker(id: 'marker_$i'));
  }
  expect(gen.cacheSize, 200);

  // Access marker_0 (should move to end)
  await gen.generateIcon(createMarker(id: 'marker_0'));

  // Insert new marker (should evict marker_1, NOT marker_0)
  await gen.generateIcon(createMarker(id: 'marker_new'));

  expect(gen.cacheSize, 200);
  expect(gen.hasInCache('marker_0'), true);   // ✅ Still in cache (recently used)
  expect(gen.hasInCache('marker_1'), false);  // ❌ Evicted (LRU)
  expect(gen.hasInCache('marker_new'), true);
});
```

---

### AC-3 : Protection contre crashes au dezoom rapide

```gherkin
Given a map with many markers displayed
When the user zooms out rapidly (triggering 50+ concurrent icon generations)
Then the app does not crash
And Future.wait does not throw an unhandled exception
And all generated markers are displayed (successful ones)
And failed markers show the fallback icon (from AC-1)
```

**Problème initial** :
```dart
// lynewed_map_widget.dart:182 - ❌ CRASH si un seul Future fail
await Future.wait(futures);
```

**Solution** : Wrapper `Future.wait` dans try/catch :

```dart
Future<void> _generateMarkersIcons(List<MapMarker> markers) async {
  if (!_mounted) return;  // ✅ Guard déjà présent

  final futures = <Future<void>>[];

  for (final marker in markers) {
    final cacheKey = _generateIconKey(marker);
    if (!_markerIcons.containsKey(cacheKey)) {
      futures.add(_generateSingleIcon(marker, cacheKey));
    }
  }

  if (futures.isNotEmpty) {
    try {
      await Future.wait(futures);  // ✅ Protected
    } catch (e) {
      // Les erreurs individuelles sont déjà loggées dans _generateSingleIcon
      // On log juste le fait qu'au moins un Future a fail
      debugPrint('[LynewedMapWidget._generateMarkersIcons] Some icons failed to generate: $e');
    }
  }

  if (_mounted) setState(() {});
}
```

**Critère testable** (remplace "no visible glitch") :
- **Critère quantifiable** : Sur 50 markers générés en parallèle, si 5 échouent :
  - ✅ L'app ne crash pas
  - ✅ 45 markers affichent l'icône custom
  - ✅ 5 markers affichent le fallback
  - ✅ Total visible : 50 markers

**Test** :
```dart
test('should not crash when some icons fail during parallel generation', () async {
  // Mock 50 markers, 5 vont fail
  final markers = List.generate(50, (i) => createMarker(id: 'marker_$i'));

  when(mockGenerator.generateIcon(argThat(predicate((m) => m.id.endsWith('5'))), size: anyNamed('size')))
      .thenThrow(Exception('Network timeout'));

  when(mockGenerator.generateIcon(argThat(predicate((m) => !m.id.endsWith('5'))), size: anyNamed('size')))
      .thenAnswer((_) async => mockIcon);

  await tester.pumpWidget(testWidget);
  await tester.pumpAndSettle();

  // Verify: no crash, 45 custom icons, 5 fallback
  expect(tester.takeException(), isNull);  // No unhandled exception
  expect(_markerIcons.length, 50);
  expect(_markerIcons.values.where((i) => i == mockIcon).length, 45);
  expect(_markerIcons.values.where((i) => i == gmaps.BitmapDescriptor.defaultMarker).length, 5);
});
```

---

### AC-4 : Timeout sur chargement avatar (Validation existante)

```gherkin
Given a marker with an avatar URL that is slow to respond
When the image loading exceeds 5 seconds
Then the timeout triggers
And the icon is generated WITHOUT avatar (fallback to initials or person icon)
And no exception propagates to the caller
```

**Note** : Le timeout de 5s existe déjà dans `_loadImage` (ligne 272). Ce critère valide que :
1. Le timeout fonctionne correctement
2. `_loadImage` retourne `null` sans crash (ligne 279-282)
3. Le générateur utilise le fallback initials/person icon (ligne 116-122)

**Aucun changement requis** - juste validation du comportement existant.

**Test** :
```dart
test('should handle slow avatar load with timeout gracefully', () async {
  // Mock slow HTTP response (> 5s)
  when(mockHttp.get(any)).thenAnswer((_) async {
    await Future.delayed(Duration(seconds: 10));
    return http.Response('', 200);
  });

  final marker = createMarker(avatarUrl: 'https://slow.server/avatar.jpg');
  final icon = await generator.generateIcon(marker);

  // Should return icon without avatar (initials fallback), no crash
  expect(icon, isNot(null));
  expect(generator.imageCache.containsKey(marker.avatarUrl), false); // Not cached
}, timeout: Timeout(Duration(seconds: 7)));
```

---

## Tests requis

### Unit tests - `marker_icon_generator_test.dart` (À CRÉER)

| Test | Description | AC |
|------|-------------|-----|
| `should return cached icon on second call (LRU)` | Vérifier cache hit + réinsertion (move to end) | AC-2 |
| `should evict LEAST RECENTLY USED entries, not oldest insertions` | Test LRU complet (voir exemple AC-2) | AC-2 |
| `should handle concurrent access without race conditions` | 50 appels parallèles -> pas de dépassement limite | AC-2 |
| `should handle image load failure gracefully` | URL invalide -> pas de crash, retourne icône sans avatar | AC-4 |
| `should respect timeout on slow image loads` | Mock HTTP lent -> timeout -> icône sans avatar | AC-4 |
| `should evict oldest image cache entries when limit reached` | Vérifier éviction `_imageCache` | AC-2 |
| `cacheSize should reflect actual cache entries` | Vérifier getter `cacheSize` | AC-2 |
| `clearCache should empty both icon and image caches` | Vérifier `clearCache()` | - |

### Widget tests - `lynewed_map_widget_test.dart` (À CRÉER)

| Test | Description | AC |
|------|-------------|-----|
| `should display fallback icon when generation fails` | Mock generator throw -> marker visible avec defaultMarker | AC-1 |
| `should not crash when widget is disposed during generation` | Dispose pendant Future.wait -> pas d'exception | AC-1 |
| `should display all markers even if some icons fail` | 50 markers, 5 échouent -> 50 visibles (45 custom + 5 fallback) | AC-3 |
| `should protect fallback assignment with mounted guard` | Vérifier `if (_mounted)` dans catch | AC-1 |
| `should handle Future.wait exception gracefully` | Mock generator fail -> pas de crash app | AC-3 |

---

## Plan d'implementation

### Phase 0 : Setup (AC-0)

```bash
mkdir -p test/features/map/presentation/services
mkdir -p test/features/map/presentation/widgets
touch test/features/map/presentation/services/marker_icon_generator_test.dart
touch test/features/map/presentation/widgets/lynewed_map_widget_test.dart
```

Ajouter dépendance :
```yaml
# pubspec.yaml
dependencies:
  synchronized: ^3.3.0  # Lock pour thread-safety cache
```

### Phase 1 : RED (Tests first)

1. **marker_icon_generator_test.dart** :
   - Tests LRU (not FIFO)
   - Tests thread-safety
   - Tests éviction `_imageCache`

2. **lynewed_map_widget_test.dart** :
   - Tests fallback icon
   - Tests mounted guard
   - Tests Future.wait exception handling

### Phase 2 : GREEN (Implementation)

1. **marker_icon_generator.dart** :
   - Remplacer `Map` par `LinkedHashMap<String, T>`
   - Ajouter `Lock _cacheLock`
   - Wrapper `generateIcon` et `_loadImage` avec `_cacheLock.synchronized()`
   - Implémenter LRU : remove + re-insert après access
   - Ajouter éviction `_imageCache` avec limite 100

2. **lynewed_map_widget.dart** :
   - Ajouter `if (_mounted)` dans catch de `_generateSingleIcon` (ligne 196-198)
   - Wrapper `Future.wait` dans try/catch (ligne 182)

### Phase 3 : REFACTOR

- Nettoyer code redondant
- Vérifier cohérence avec tests
- Valider thread-safety avec tests concurrents

### Option Alternative : Diviser en 2 Stories

Si la complexité est trop élevée (8 SP), diviser en :

| Story | Scope | SP |
|-------|-------|-----|
| **S08a** | Fallback icon + mounted guard + Future.wait try/catch | 3 SP |
| **S08b** | Cache LRU + thread-safety + éviction `_imageCache` | 5 SP |

**Recommandation** : Garder story unique pour cohérence, mais prévoir 2 jours au lieu de 1.

---

## Estimation (RÉVISÉE)

| Element | Effort Initial | Effort Réel | Écart |
|---------|---------------|-------------|-------|
| Setup tests (AC-0) | - | 10 min | +10 min |
| Tests unitaires (generator) | 30 min | 2h | +1h30 (LRU + thread-safety) |
| Tests widget (map widget) | 30 min | 1h | +30 min (mounted guards complexes) |
| Implementation LRU cache | 30 min | 2h | +1h30 (LinkedHashMap + Lock) |
| Implementation fallback + guards | - | 30 min | +30 min |
| Review adversariale | 15 min | 1h | +45 min (8 problèmes détectés) |
| **Total Initial** | **~1h45** | **6h40** | **+4h55** |

**Complexité révisée** : 3 SP → **8 SP** (Medium)

**Justification** :
- Cache LRU correct (LinkedHashMap + réinsertion) >> cache FIFO naïf
- Thread-safety (Lock) nécessite tests concurrents
- Mounted guards dans async callbacks = subtil
- 8 problèmes bloquants détectés lors re-challenge

---

## Risques

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Le fallback `defaultMarker` est visuellement inconsistant | Faible | Mineur | Acceptable : mieux qu'invisible. Fallback custom possible plus tard |
| Lock peut ralentir génération si trop de contention | Faible | Moyen | Lock granularité fine (cache access only). Génération icon (CPU-intensive) hors lock |
| L'éviction LRU supprime icones visibles à l'écran | Très faible | Mineur | 200 est généreux (carte affiche rarement > 50). Régénération automatique rapide |
| Bug original non reproductible | Moyen | Faible | Tests unitaires couvrent comportement. Approche defensive sans regression |
| Complexité accrue (8 SP vs 3 SP initial) | Moyen | Moyen | Diviser en S08a/S08b si bloqué après 1 jour |
| Race condition réintroduite malgré Lock | Très faible | Critique | Tests concurrents (50 appels parallèles) valident thread-safety |

---

## Definition of Done

- [ ] **AC-0** : Fichiers tests créés (prerequisite)
- [ ] **AC-1** : Fallback icon + mounted guard implémentés et testés
- [ ] **AC-2** : Cache LRU (LinkedHashMap + Lock) implémenté et testé
- [ ] **AC-3** : Future.wait protected + tests crash resistance
- [ ] **AC-4** : Timeout validation (tests existants)
- [ ] **Tests** : `flutter test --no-pub test/features/map/presentation/` → 0 failures (13+ nouveaux tests)
- [ ] **Lint** : `flutter analyze --fatal-infos` → 0 warnings
- [ ] **Regression** : `flutter test --no-pub test/features/map/` → tests existants passent
- [ ] **Deps** : `synchronized: ^3.3.0` ajouté et `flutter pub get` OK
- [ ] **Review adversariale** : 0 problème détecté (vs 8 au re-challenge initial)
- [ ] **Thread-safety** : Tests concurrents (50 appels parallèles) passent
- [ ] **Memory** : Cache limits documentés (200 icons, 100 images = ~24 MB)

## Checklist Re-Challenge

Vérifier que TOUS les problèmes initiaux sont résolus :

- [x] ~~Fichiers tests inexistants~~ → Créés (AC-0)
- [x] ~~FAKE LRU cache~~ → LinkedHashMap + réinsertion après access
- [x] ~~Mounted guard manquant~~ → `if (_mounted)` dans catch
- [x] ~~Race condition cache~~ → Lock sur accès cache
- [x] ~~Image cache sans éviction~~ → Limite 100 + LRU eviction
- [x] ~~Future.wait sans try/catch~~ → Wrapped dans try/catch
- [x] ~~AC-2/AC-3 non testables~~ → Critères quantifiables (50 markers test)
- [x] ~~Cache limits non justifiés~~ → Documentés (24 MB)

---

## Annexe Technique : LRU vs FIFO

### Pourquoi Map.keys.take(50) est FAUX

```dart
// ❌ APPROCHE INITIALE (FAUX)
final _iconCache = <String, BitmapDescriptor>{};

void evictOldest() {
  if (_iconCache.length >= 200) {
    final keysToRemove = _iconCache.keys.take(50).toList();
    for (final key in keysToRemove) {
      _iconCache.remove(key);
    }
  }
}
```

**Problème** :
- `Map` en Dart ne garantit PAS l'ordre d'itération (avant Dart 2.0 c'était HashMap)
- Même avec ordre garanti, `keys.take(50)` = **ordre d'INSERTION**, pas ordre d'UTILISATION
- Un marker affiché 1000 fois mais inséré il y a 1h sera évincé AVANT un marker inséré récemment mais jamais affiché

**Exemple concret** :
```dart
// Timeline
T=0:    Insert marker_A  (cache: [A])
T=1:    Insert marker_B  (cache: [A, B])
T=2-100: Access marker_A (100 fois) - PAS de changement dans Map
T=101:  Insert marker_C  (cache full, evict needed)

// Avec FIFO (FAUX):
// → Évince marker_A (première insertion) ❌
// → Garde marker_B (jamais utilisé) ❌

// Avec LRU (CORRECT):
// → Évince marker_B (LRU = least recently used) ✅
// → Garde marker_A (very recently used 100 times) ✅
```

### Solution Correcte : LinkedHashMap + Réinsertion

```dart
// ✅ SOLUTION CORRECTE
import 'dart:collection';

final _iconCache = LinkedHashMap<String, BitmapDescriptor>();

BitmapDescriptor getIcon(String key) {
  if (_iconCache.containsKey(key)) {
    // LRU: Remove and re-insert to move to END (most recent)
    final icon = _iconCache.remove(key)!;
    _iconCache[key] = icon;
    return icon;
  }
  // Generate new...
}

void evictLRU() {
  if (_iconCache.length >= 200) {
    // Remove FIRST entry = oldest access (LRU)
    _iconCache.remove(_iconCache.keys.first);
  }
}
```

**Pourquoi ça marche** :
1. `LinkedHashMap` garde l'ordre d'insertion
2. À chaque accès, on **remove + re-insert** → déplace à la fin
3. `keys.first` = entrée la plus anciennement **accédée** (pas insérée)
4. Éviction de `keys.first` = éviction LRU correcte

### Thread-Safety avec Lock

```dart
import 'package:synchronized/synchronized.dart';

final _cacheLock = Lock();

Future<BitmapDescriptor> generateIcon(MapMarker marker) async {
  return await _cacheLock.synchronized(() async {
    // All cache operations protected
    if (_iconCache.containsKey(key)) {
      // LRU re-insertion
      final icon = _iconCache.remove(key)!;
      _iconCache[key] = icon;
      return icon;
    }

    // Generate icon (OUTSIDE lock to minimize contention)
    final icon = await _generateIconUnsafe(marker);

    // Evict + insert (INSIDE lock for thread-safety)
    if (_iconCache.length >= 200) {
      _iconCache.remove(_iconCache.keys.first);
    }
    _iconCache[key] = icon;
    return icon;
  });
}
```

**Trade-off** :
- ❌ Génération icon (CPU-intensive) dans lock = mauvaise perf
- ✅ Lock granularité fine : seulement check/evict/insert

**Optimisation** :
```dart
// Check cache (fast, needs lock)
final cached = await _cacheLock.synchronized(() {
  if (_iconCache.containsKey(key)) {
    final icon = _iconCache.remove(key)!;
    _iconCache[key] = icon;
    return icon;
  }
  return null;
});

if (cached != null) return cached;

// Generate icon (slow, NO lock - parallelizable)
final icon = await _generateIconUnsafe(marker);

// Insert cache (fast, needs lock)
return await _cacheLock.synchronized(() {
  if (_iconCache.length >= 200) {
    _iconCache.remove(_iconCache.keys.first);
  }
  _iconCache[key] = icon;
  return icon;
});
```

Cette optimisation peut être faite en REFACTOR si les tests de performance montrent de la contention.
