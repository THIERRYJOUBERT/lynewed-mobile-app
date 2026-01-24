# Story S02: Migration FlutterFlow Utilities

## Description

En tant que developpeur, je veux migrer les utilitaires FlutterFlow vers des equivalents Clean Architecture afin de supprimer la dependance au code genere FlutterFlow.

## Criteres d'Acceptance (Gherkin)

- [ ] Given `lib/flutter_flow/flutter_flow_util.dart` When je cree des equivalents dans `lib/core/` Then toutes les fonctions utilitaires sont disponibles sans dependance FlutterFlow

- [ ] Given `lib/flutter_flow/flutter_flow_model.dart` When j'analyse son usage Then je documente une strategie de remplacement par ChangeNotifier/Cubit

- [ ] Given `lib/flutter_flow/form_field_controller.dart` When je cree un equivalent Then les formulaires peuvent utiliser la nouvelle implementation

- [ ] Given `lib/flutter_flow/uploaded_file.dart` When je migre vers `lib/core/` Then la gestion des fichiers uploades est independante

- [ ] Given tous les utilitaires migres When je lance les tests Then 100% des tests passent

## Fichiers Concernes

### A Analyser et Migrer
- `lib/flutter_flow/flutter_flow_util.dart` - Utilitaires generaux
- `lib/flutter_flow/flutter_flow_model.dart` - Base model FlutterFlow
- `lib/flutter_flow/form_field_controller.dart` - Controllers de formulaires
- `lib/flutter_flow/uploaded_file.dart` - Gestion fichiers uploades
- `lib/flutter_flow/lat_lng.dart` - Types geographiques
- `lib/flutter_flow/place.dart` - Type Place

### A Creer
- `lib/core/utils/extensions.dart` - Extensions Dart utiles
- `lib/core/utils/form_utils.dart` - Utilitaires formulaires
- `lib/core/utils/file_utils.dart` - Gestion fichiers
- `lib/core/models/lat_lng.dart` - Type LatLng (ou reutiliser google_maps)
- `lib/core/models/place.dart` - Type Place

### A NE PAS Toucher (pour l'instant)
- `lib/flutter_flow/flutter_flow_theme.dart` - Theme (S03)
- `lib/flutter_flow/internationalization.dart` - i18n (garder)
- `lib/flutter_flow/nav/` - Navigation (S04)

## Notes Techniques

### FlutterFlowModel Replacement
Le `FlutterFlowModel` est un pattern proprietaire. Strategies de remplacement :

1. **Pages simples** : StatefulWidget standard avec `dispose()`
2. **Pages complexes** : ChangeNotifier + Provider
3. **Pages tres complexes** : Cubit/Bloc

```dart
// Avant (FlutterFlow)
class MyPageModel extends FlutterFlowModel<MyPageWidget> {
  @override
  void initState(BuildContext context) { }
  @override
  void dispose() { }
}

// Apres (Clean)
class MyPageNotifier extends ChangeNotifier {
  MyPageNotifier() { _init(); }

  void _init() { }

  @override
  void dispose() {
    // cleanup
    super.dispose();
  }
}
```

### Extensions Utiles
```dart
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  // ... autres helpers
}
```

## Definition of Done

- [ ] Audit complet de `lib/flutter_flow/` realise
- [ ] Utilitaires critiques migres vers `lib/core/`
- [ ] Documentation de la strategie FlutterFlowModel
- [ ] Tests pour les nouveaux utilitaires
- [ ] Aucune regression sur les pages existantes
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (impact large)

## Dependances

- S01 : Setup infrastructure

## Stories Dependantes

- Toutes les stories de migration de pages
