# RAPPORT DE RE-CHALLENGE - S08 Map Optimization

> Date : 2026-02-16 (Round 2)
> Reviewer : Claude Senior Tech Lead (Performance & Caching)
> Story : S08-map-optimization-error-handling.md
> Challenge précédent : CHALLENGE-REPORT.md (section S08 - corrections moyennes)

---

## EXECUTIVE SUMMARY

**Verdict Round 2** : ❌ **STORY NON VALIDÉE - 8 NOUVEAUX PROBLÈMES CRITIQUES**

Le 1er round avait identifié 3 problèmes (tests manquants, LRU naïf, mounted guard incomplet).
Ce 2ème round révèle **8 problèmes supplémentaires** dont 4 BLOQUANTS.

**Estimation** : 3 SP → **8 SP** (165% augmentation)

---

## PROBLÈMES TROUVÉS (8 NOUVEAUX)

### 🔴 P1 : Fichiers de tests INEXISTANTS (BLOQUANT)

**Sévérité** : CRITIQUE

**Preuve** :
```bash
$ glob "**/marker_icon_generator_test.dart"
No files found

$ glob "**/lynewed_map_widget_test.dart"
No files found
```

**Impact** :
- Story référence 6 tests unitaires + 3 tests widget (Section "Tests requis")
- **0 fichiers de tests existent**
- Impossible de valider la story sans ces tests

**Correction requise** :
- Créer les 2 fichiers de tests AVANT implémentation
- Ajouter un AC-0 (prerequisite) : "Test files exist"

---

### 🔴 P2 : Cache eviction est un FAUX LRU (BLOQUANT)

**Sévérité** : CRITIQUE

**Code actuel** :
```dart
// marker_icon_generator.dart:39-40
final Map<String, gmaps.BitmapDescriptor> _iconCache;
final Map<String, ui.Image> _imageCache;
```

**Problème** :
La story (AC-2, ligne 90) dit :
> "supprimer les 50 premières entrées (FIFO via `_iconCache.keys.take(50)`)"

**MAIS** :
1. **Dart `Map` n'est PAS ordonné** (depuis Dart 2.0 il l'est par insertion, mais ce n'est pas un LRU)
2. `Map.keys.take(50)` supprime les **PLUS VIEILLES INSERTIONS**, pas les **MOINS RÉCEMMENT UTILISÉES**
3. Un marker affiché à l'écran depuis 1h sera supprimé s'il a été inséré tôt, même s'il est accédé 100x/sec

**Exemple de bug** :
```
1. Cache : [A, B, C, D, E] (max 5)
2. User scroll, marker A est affiché 100x/sec (hot)
3. Nouvelle icône F → eviction FIFO → supprime A
4. Frame suivante : A manquant → régénération inutile
```

**Correction requise** :
- Utiliser un **vrai LRU** avec `LinkedHashMap` et mise à jour `access time`
- OU utiliser package `lru_cache` ou `collection.LruMap`
- OU implémenter un `_touch(key)` qui supprime + réinsère

**Code correct (exemple)** :
```dart
import 'dart:collection';

class MarkerIconGenerator {
  final LinkedHashMap<String, gmaps.BitmapDescriptor> _iconCache = LinkedHashMap();
  static const _maxCacheSize = 200;

  Future<gmaps.BitmapDescriptor> generateIcon(...) async {
    final cacheKey = _generateCacheKey(...);

    // LRU access
    if (_iconCache.containsKey(cacheKey)) {
      final icon = _iconCache.remove(cacheKey)!; // Remove
      _iconCache[cacheKey] = icon; // Re-insert at end (most recent)
      return icon;
    }

    // Eviction LRU
    if (_iconCache.length >= _maxCacheSize) {
      _iconCache.remove(_iconCache.keys.first); // Remove oldest access
    }

    final icon = await _createIcon(...);
    _iconCache[cacheKey] = icon;
    return icon;
  }
}
```

---

### 🔴 P3 : Fallback icon manque mounted guard dans catch (BLOQUANT)

**Sévérité** : MAJEUR

**Code actuel** :
```dart
// lynewed_map_widget.dart:189-199
Future<void> _generateSingleIcon(MapMarker marker, String cacheKey) async {
  try {
    final icon = await _iconGenerator.generateIcon(marker, size: 144.0);
    if (_mounted) {
      _markerIcons[cacheKey] = icon;
    }
  } catch (e) {
    debugPrint('[LynewedMapWidget._generateMarkerIcon] Error: $e');
    // ❌ PAS DE FALLBACK ICI
  }
}
```

**Problème** :
- Story AC-1 (ligne 72) dit : "ajouter dans le `catch` : `_markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;`"
- **Le code actuel n'a PAS de fallback**
- **Pire** : le code proposé par la story n'a PAS de `_mounted` guard → crash si widget disposed

**Correction requise** :
```dart
catch (e) {
  debugPrint('[LynewedMapWidget._generateMarkerIcon] Error: $e');
  if (_mounted) {
    _markerIcons[cacheKey] = gmaps.BitmapDescriptor.defaultMarker;
  }
}
```

---

### 🔴 P4 : AC-2 validation impossible (BLOQUANT)

**Sévérité** : MAJEUR

**Story AC-2 (ligne 86)** :
> "And the eviction does not cause any visible glitch on the map"

**Problème** :
- Comment valider "no visible glitch" dans un test unitaire ?
- Aucun test widget ne couvre ce cas (Section "Tests requis" ligne 137-143)
- L'AC est **NON TESTABLE** de manière automatisée

**Correction requise** :
- Reformuler AC-2 en critère testable :
  ```gherkin
  Then the cache size remains <= 200
  And cached icons still visible on screen are retained
  And only off-screen icons are evicted first
  ```
- Ajouter un test widget :
  ```dart
  test('should not evict icons of visible markers', () {
    // Setup: 201 markers, 50 visible
    // Assert: visible markers' icons still cached
  });
  ```

---

### 🟡 P5 : Cache size limits non justifiés

**Sévérité** : MAJEUR

**Story AC-2 (ligne 89)** :
> `_maxCacheSize = 200` et `_maxImageCacheSize = 100`

**Questions non répondues** :
1. **Pourquoi 200 ?** Basé sur quoi ? Mémoire ? Nombre de markers ?
2. **Pourquoi 100 images pour 200 icônes ?** Ratio 1:2 non justifié
3. **Consommation mémoire** : Combien de MB pour 200 icônes 144x144 ?

**Calcul théorique** :
```
1 icône 144x144 RGBA = 144 * 144 * 4 = 82,944 bytes ≈ 81 KB
200 icônes = 16.2 MB
100 images (avatars 144x144) = 8.1 MB
Total = ~24 MB
```

**Impact** :
- 24 MB semble raisonnable MAIS pas documenté
- Si le device a 2GB RAM, OK. Si 1GB, peut-être trop

**Correction requise** :
- Documenter le calcul mémoire dans la story
- Justifier les limites (ex: "24 MB max, < 2% RAM sur iPhone 11")
- OU implémenter un cache adaptatif basé sur `availableMemory`

---

### 🟡 P6 : Race condition dans cache eviction

**Sévérité** : MAJEUR

**Code proposé par story (ligne 90)** :
```dart
if (_iconCache.length >= _maxCacheSize) {
  // Supprimer 50 premières entrées
  _iconCache.keys.take(50).forEach(_iconCache.remove);
}
_iconCache[cacheKey] = icon;
```

**Problème** :
- `_generateSingleIcon` est appelé en **parallèle** (ligne 176 : `futures.add(...)`)
- Plusieurs futures peuvent atteindre `_iconCache.length >= 200` **simultanément**
- Résultat : **éviction multiple concurrente** → cache final peut dépasser 200

**Exemple de race** :
```
Thread 1: _iconCache.length = 200 → evict 50 → insert A → 151
Thread 2: _iconCache.length = 200 → evict 50 → insert B → 152
Concurrent: Les 2 evict en même temps → cache final = 102 au lieu de 151
```

**Correction requise** :
- Protéger le cache avec un `Lock` ou `Mutex`
- OU gérer l'éviction dans `generateIcon` (pas dans le caller)
- Le `MarkerIconGenerator` doit être **thread-safe**

**Code correct** :
```dart
// Ajouter un lock
final _lock = Lock();

Future<gmaps.BitmapDescriptor> generateIcon(...) async {
  return await _lock.synchronized(() async {
    // Cache check + eviction + insert atomique
  });
}
```

---

### 🟡 P7 : Image cache eviction oubliée

**Sévérité** : MOYEN

**Code actuel** :
```dart
// marker_icon_generator.dart:267-276
if (_imageCache.containsKey(url)) {
  return _imageCache[url];
}
// ... load image ...
_imageCache[url] = frame.image;
```

**Problème** :
- AC-2 mentionne `_imageCache` avec limite 100 (ligne 92)
- **Le code actuel n'a AUCUNE éviction pour `_imageCache`**
- Résultat : `_imageCache` grandit sans limite → memory leak

**Correction requise** :
- Implémenter la même logique d'éviction pour `_imageCache`
- Ajouter un test : `should evict oldest images when image cache exceeds max size`

---

### 🟡 P8 : AC-3 "pas de crash au dezoom rapide" NON TESTABLE

**Sévérité** : MOYEN

**Story AC-3 (ligne 95)** :
> "Given a map with many markers displayed
> When the user zooms out rapidly (triggering multiple concurrent icon generations)
> Then the app does not crash"

**Problème** :
- Comment simuler un "zoom rapide" dans un test unitaire ?
- Aucun test widget ne couvre ce cas (Section "Tests requis" ligne 137-143)
- L'AC-3 dit "Le fallback icon couvre déjà ce cas" (ligne 106) → **FAUX**

**Pourquoi c'est faux** :
- Le fallback icon couvre les **erreurs de génération**, pas les **race conditions de dispose**
- Un "crash au dezoom rapide" peut être :
  1. `setState` sur widget disposed → **résolu par `_mounted` guard** (AC-3 ligne 107)
  2. Future.wait qui throw → **NON résolu** (pas de try/catch dans `_generateMarkersIcons`)

**Code problématique** :
```dart
// lynewed_map_widget.dart:180-183
if (futures.isNotEmpty) {
  await Future.wait(futures); // ❌ Si 1 future throw, tout crash
}
```

**Correction requise** :
- Ajouter un try/catch autour de `Future.wait`
- OU utiliser `Future.wait(..., eagerError: false)` pour ignorer les erreurs
- Reformuler AC-3 en critère testable :
  ```gherkin
  When multiple markers fail to generate concurrently
  Then the app displays fallback icons for failed markers
  And the map does not freeze or crash
  ```

---

## PROBLÈMES DÉJÀ IDENTIFIÉS (Round 1)

### ✅ P0 : Fichiers de tests manquants
→ **Confirmé** : 0 fichiers de tests existent (voir P1)

### ✅ P0 : LRU naïf
→ **Confirmé + aggravé** : Map non-ordonné + race conditions (voir P2 + P6)

### ✅ P0 : Mounted guard incomplet
→ **Confirmé** : Le fallback icon proposé n'a pas de guard (voir P3)

---

## MÉTRIQUES GLOBALES

| Métrique | Round 1 | Round 2 | Delta |
|----------|---------|---------|-------|
| Problèmes trouvés | 3 | 11 | +8 |
| Problèmes BLOQUANTS | 1 | 4 | +3 |
| Fichiers à créer | 2 | 2 | 0 |
| Estimation (SP) | 3 → 5 | 5 → 8 | +3 |
| Durée estimée | 1h45 → 3h30 | 3h30 → 6h | +2.5h |

---

## CORRECTIONS REQUISES (PRIORITÉ)

### 🔴 CRITIQUES (AVANT IMPLÉMENTATION)

1. **P1** : Créer les fichiers de tests (marker_icon_generator_test.dart, lynewed_map_widget_test.dart)
2. **P2** : Implémenter un VRAI LRU avec LinkedHashMap + touch sur access
3. **P3** : Ajouter `if (_mounted)` dans le catch du fallback icon
4. **P4** : Réécrire AC-2 pour être testable (no "visible glitch")

### 🟡 MAJEURES (RECOMMANDÉ)

5. **P5** : Documenter calcul mémoire (24 MB pour 200 icônes)
6. **P6** : Protéger cache avec Lock (thread-safety)
7. **P7** : Implémenter éviction pour `_imageCache`
8. **P8** : Ajouter try/catch autour de Future.wait

### 🟢 MINEURES (BONUS)

9. Ajouter un test de charge : "200+ markers, cache stays under limit"
10. Documenter le trade-off LRU vs FIFO (pourquoi LRU est meilleur ici)

---

## PLAN D'IMPLÉMENTATION RÉVISÉ

### Phase 1 : Préparation (1h)
1. Créer `test/features/map/presentation/services/marker_icon_generator_test.dart`
2. Créer `test/features/map/presentation/widgets/lynewed_map_widget_test.dart`
3. Documenter calcul mémoire + justifier limites cache

### Phase 2 : TDD (3h)
1. **RED** : Écrire tests LRU (access order, eviction, concurrency)
2. **GREEN** : Implémenter LRU avec LinkedHashMap + Lock
3. **REFACTOR** : Nettoyer, extraire `_evictOldest()`

### Phase 3 : Fallback + Edge Cases (1.5h)
1. **RED** : Tests fallback icon + mounted guard
2. **GREEN** : Ajouter fallback dans catch + try/catch Future.wait
3. **REFACTOR** : Documenter error handling

### Phase 4 : Widget tests (1h)
1. Écrire 3 tests widget (fallback, dispose, partial failure)
2. Valider visuellement sur simulateur iOS

### Phase 5 : Review + Polish (0.5h)
1. Review adversariale
2. Vérifier tous les AC passent
3. Documenter limitations (ex: "eviction peut cause re-render si marker off-screen revient")

**Total** : **7h** (au lieu de 1h45 initial)

---

## RISQUES IDENTIFIÉS (NOUVEAUX)

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| LRU complexifie le code | Haute | Moyen | Utiliser package `lru_cache` au lieu de custom impl |
| Lock cause performance hit | Moyenne | Moyen | Mesurer avec profiler, accepter overhead si < 5ms |
| Cache éviction cause re-render visible | Moyenne | Majeur | Tester avec 200+ markers, ajuster limite si glitch |
| Tests widget flaky (timing) | Haute | Moyen | Utiliser `pumpAndSettle` + timeouts généreux |

---

## VERDICT FINAL

**Status** : ❌ **STORY NON VALIDÉE**

**Raisons** :
- 4 problèmes BLOQUANTS non résolus
- Code proposé (LRU naïf) va causer des bugs en production
- Tests inexistants (0/9 fichiers)
- Estimation sous-évaluée de 165%

**Peut démarrer ?** : **NON**

**Actions requises** :
1. Réécrire AC-2 et AC-3 (testables)
2. Créer fichiers de tests
3. Implémenter LRU correct (pas FIFO)
4. Protéger cache avec Lock
5. Ajouter fallback icon avec mounted guard
6. Documenter calcul mémoire

**Estimation réaliste** : **8 SP** (7h dev + 1h review)

---

## RECOMMANDATIONS STRATÉGIQUES

### 1. Diviser S08 en 2 Stories

**S08a - Fallback Icons (3 SP)** :
- AC-1 : Fallback icon quand génération échoue
- AC-4 : Timeout sur chargement avatar
- Tests : widget tests (fallback, dispose)

**S08b - Cache Optimization (5 SP)** :
- AC-2 : LRU cache avec éviction
- AC-3 : Pas de crash concurrent
- Tests : unit tests (LRU, thread-safety, eviction)

**Bénéfice** : Réduire risque, livrer incrémental (S08a peut ship sans S08b)

### 2. Utiliser package `lru_cache`

**Raison** : Implémenter un LRU thread-safe est complexe et error-prone

**Alternative** :
```yaml
dependencies:
  lru_cache: ^1.0.0
```

**Code simplifié** :
```dart
import 'package:lru_cache/lru_cache.dart';

class MarkerIconGenerator {
  final LruCache<String, gmaps.BitmapDescriptor> _iconCache = LruCache(maxSize: 200);

  Future<gmaps.BitmapDescriptor> generateIcon(...) async {
    final cacheKey = _generateCacheKey(...);
    return _iconCache.get(cacheKey) ?? await _generate(cacheKey);
  }
}
```

**Trade-off** : Dépendance externe vs implémentation custom

### 3. Ajouter AC-0 (Prerequisite)

**Contenu** :
```gherkin
Given the test files exist
When I run `flutter test test/features/map/`
Then the test runner finds marker_icon_generator_test.dart
And the test runner finds lynewed_map_widget_test.dart
```

**Bénéfice** : Bloquer dev si fichiers manquants (INVEST "Testable")

---

## CONCLUSION

La story S08 semblait "acceptable avec corrections moyennes" au Round 1.

Le Round 2 révèle que **les fondations sont cassées** :
- Le LRU proposé n'est pas un LRU
- Les tests n'existent pas
- Le fallback icon est incomplet
- Les race conditions ne sont pas gérées

**L'implémentation actuelle causerait des bugs en production** :
- Cache qui grandit sans limite (image cache)
- Markers qui disparaissent (LRU naïf évince les mauvais)
- Crash sur dezoom rapide (Future.wait sans catch)

**Recommandation** : **BLOQUER** la story, corriger les 8 problèmes, diviser en 2 stories.

**Durée corrections** : 1 jour (review + rewrite story + validation)

---

**Rapport généré par** : Review Adversariale APEX (Round 2)
**Méthodologie** : 0 complaisance, vérification fichiers, analyse concurrency, calcul mémoire
**Next steps** : Attendre corrections avant re-challenge Round 3
