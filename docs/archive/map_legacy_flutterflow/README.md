# Archive - Map Legacy FlutterFlow Code

**Archived:** 2025-11-27  
**Reason:** Refactorisation Phase 5 - Migration vers Clean Architecture  
**New Module:** `lib/features/map/`

## Contenu de l'archive

### Widgets
- `lynewed_interactive_map.dart` - Ancien widget map principal (~600 lignes)
- `lynewed_mini_map.dart` - Mini map pour détails

### Actions (Custom Code)
- `call_search_map_bundle_v2.dart` - Action de recherche map
- `get_pro_item_details_action.dart` - Récupération détails pro
- `get_alert_item_details_rpc.dart` - Récupération détails alerte
- `get_wedding_pin_item_details_rpc.dart` - Récupération détails mariage
- `get_poi_item_details.dart` - Récupération détails POI (deprecated)

### Structs
- `map_marker_struct.dart` - Struct FlutterFlow pour marqueurs
- `mapdatabundle_struct.dart` - Struct FlutterFlow pour bundle données

### Pages
- `map_brides_large/` - Page map pour brides
- `map_pro_large/` - Page map pour pros

## Nouveau code (remplacement)

Le nouveau module `lib/features/map/` remplace tout ce code avec :
- Architecture Clean (domain/data/presentation)
- Entités immutables
- Use cases isolés
- Widgets Material 3
- Tests possibles

## Pourquoi archiver ?

1. **Référence** - Pouvoir consulter l'ancien code si besoin
2. **Rollback** - Possibilité de restaurer en cas de problème
3. **Comparaison** - Voir les différences d'approche
4. **Historique** - Garder une trace de l'évolution

## Note importante

Ce code est **obsolète** et ne doit plus être utilisé.
Utiliser le module `lib/features/map/` à la place.
