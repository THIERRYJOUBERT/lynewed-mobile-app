# Address Search Widget - Documentation Technique

## 📋 **Vue d'ensemble**

Widget Flutter unifié pour la recherche d'es avec autocomplete Google Places, remplaçant le code dupliqué dans 5 écrans de l'application.

## 🎯 **Fonctionnalités**

- **Recherche autocomplete** via Google Places SDK v0.4.2+1
- **Mode overlay** : suggestions affichées par-dessus le contenu (pas d'overflow)
- **Position flexible** : suggestions au-dessus ou en-dessous du champ
- **Gestion du focus** : fermeture automatique des suggestions
- **Callback dynamique** : ajustement de la hauteur du container parent
- **Support multilingue** : français/anglais
- **Debounce configurable** : 300ms par défaut

## 📱 **Écrans Migrés (5/5)**

| Écran | Mode | Particularités |
|-------|------|----------------|
| **feed_brides** | Overlay | Suggestions par-dessus les filtres |
| **map_brides_large** | Overlay + Container dynamique | Container s'agrandit à 420px |
| **map_pro_large** | Overlay + Container dynamique | Container s'agrandit à 420px |
| **create_edit_alert_sheet** | Overlay | Sheet scrollable, légèrement coupé mais fonctionnel |
| **create_edit_point_of_interest_sheet** | Overlay + Position "above" | Suggestions au-dessus du champ |

## 🛠️ **Utilisation**

```dart
import '/compo_finaux/address_search/address_search_widget.dart';

AddressSearchWidget(
  width: double.infinity,
  height: 50.0,
  hintText: 'Rechercher une ville ou e',
  locale: 'fr',
  debounceMs: 200,
  
  // Mode d'affichage des suggestions
  useOverlay: true,
  suggestionsPosition: SuggestionsPosition.below, // ou .above
  
  // Callbacks
  onAddressSelected: (PlaceDetailsDataStruct details) {
    _model.selectedPlace = details;
    safeSetState(() {});
  },
  onAddressCleared: () {
    _model.selectedPlace = null;
    safeSetState(() {});
  },
  onSearchTextChanged: (String text) {
    _model.searchText = text;
  },
  onSuggestionsVisibilityChanged: (bool visible) {
    // Pour ajuster dynamiquement la hauteur du container parent
    _model.suggestionsVisible = visible;
    safeSetState(() {});
  },
)
```

## 🏗️ **Architecture Technique**

### Composants Principaux
- **`AddressSearchWidget`** : Widget principal avec état interne
- **`SuggestionsPosition`** : Enum (below/above) pour positionnement
- **`CompositedTransformTarget/Follower`** : Système d'overlay
- **`AnimatedContainer`** : Animation de hauteur dans les mapLarge

### Flux de Données
```
Input Text → Debounce → Google Places API → Suggestions → Overlay
                ↓
            Callbacks → Parent Widget → UI Updates
```

## 🔧 **Paramètres Configurables**

| Paramètre | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `useOverlay` | bool | true | Mode overlay vs Column |
| `suggestionsPosition` | enum | below | Position des suggestions |
| `debounceMs` | int | 300 | Délai avant recherche API |
| `maxSuggestions` | int | 5 | Nombre max de suggestions |
| `locale` | string | auto | Langue des résultats |

### Paramètres d'Animation
- **AnimatedContainer duration** : 200ms (transition fluide)
- **Container minHeight** : 420px (optimisé pour 5 suggestions + padding)

## 📊 **Performance & Optimisations**

- **Debounce** : 300ms pour limiter les appels API
- **Session tokens** : Optimisation billing Google Places
- **Lazy loading** : Overlay créé uniquement quand nécessaire
- **Memory management** : Dispose correct des controllers et overlays

## 🚨 **Points d'Attention**

### Sécurité API Keys
- **iOS** : Sécurisé avec restrictions bundle ID
- **Android** : Configuré, en attente SHA-1 pour restrictions complètes

### Gestion des Erreurs
- **Timeout réseau** : Silent fail avec debug print
- **API quota** : Géré côté backend
- **Permissions** : Vérification des clés au démarrage

### Compatibilité
- **Flutter** : Testé sur Flutter 3.x
- **Google Places SDK** : v0.4.2+1 (migration depuis v0.3.x)
- **iOS** : iOS 12.0+
- **Android** : Android API 21+

### Ordre d'Exécution des Callbacks
1. `onSearchTextChanged` (à chaque frappe)
2. `onSuggestionsVisibilityChanged(true)` (quand suggestions apparaissent)
3. `onAddressSelected` (quand e sélectionnée)
4. `onSuggestionsVisibilityChanged(false)` (quand suggestions disparaissent)

## 🔧 **Dépannage**

### Problèmes Courants

**Overlay coupé dans ScrollView**
```dart
// Solution : envelopper dans un Container avec suffisamment d'espace
AnimatedContainer(
  constraints: BoxConstraints(
    minHeight: _model.suggestionsVisible ? 420.0 : 0.0,
  ),
  child: AddressSearchWidget(...),
)
```

**Suggestions ne s'affichent pas**
- Vérifier `useOverlay: true`
- Confirmer que le parent a assez d'espace vertical
- Vérifier les clés API dans `.env`

**Container ne se réduit pas après sélection**
- Assurez-vous d'implémenter `onSuggestionsVisibilityChanged`
- Vérifier que `safeSetState(() {})` est appelé

**Performance lente**
- Augmenter `debounceMs` à 500ms
- Réduire `maxSuggestions` à 3
- Vérifier la connexion réseau

## ⚠️ **Limitations Connues**

### create_edit_alert_sheet
- **Légèrement coupé** : Les 5 suggestions sont visibles mais le bas est légèrement tronqué
- **Impact** : Mineur, fonctionnellement acceptable
- **Solution future** : Rendre le sheet scrollable ou augmenter sa hauteur

### Mode Inline (Fallback)
Si l'overlay pose des problèmes dans des contextes spécifiques :
```dart
AddressSearchWidget(
  useOverlay: false,  // Revenir au mode Column
  suggestionsPosition: SuggestionsPosition.below,
  // ... autres paramètres
)
```

## 🔮 **Évolutions Futures**

### Priorité Haute
- [ ] **Restrictions Android** : Ajouter SHA-1 pour sécurité complète
- [ ] **Cache local** : Mémoriser les recherches récentes
- [ ] **Géolocalisation** : Intégrer position actuelle

### Priorité Moyenne
- [ ] **Types de lieux** : Filtrer par catégories (restaurants, hotels...)
- [ ] **Historique** : Afficher les es récemment recherchées
- [ ] **Autocomplete amélioré** : Suggestions basées sur les préférences utilisateur

### Priorité Basse
- [ ] **Offline mode** : Cache pour mode hors-ligne
- [ ] **Analytics** : Tracker les recherches populaires
- [ ] **Voice search** : Intégration recherche vocale

## 📁 **Fichiers Impliqués**

### Core Widget
- `lib/compo_finaux/address_search/address_search_widget.dart` (456 lignes)

### Actions Backend
- `lib/custom_code/actions/get_place_predictions.dart`
- `lib/custom_code/actions/get_place_details.dart`
- `lib/custom_code/actions/get_place_details_rich.dart`

### Configuration
- `lib/app_constants.dart` : Clés API iOS/Android
- `ios/Runner/AppDelegate.swift` : Initialisation iOS
- `android/app/src/main/AndroidManifest.xml` : Clé Android

---

**Dernière mise à jour** : 2025-11-26  
**Statut** : ✅ Production Ready (5/5 écrans migrés)
