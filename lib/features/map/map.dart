/// Map feature module - Clean architecture replacement for FlutterFlow code
/// 
/// This module provides a complete, testable map feature implementation
/// replacing the verbose FlutterFlow-generated code (3600+ lines → ~1000 lines).
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:lynewed/features/map/map.dart';
/// 
/// // Simple usage
/// LynewedMapWidget(
///   userRole: 'professional',
///   onMarkerTap: (marker) => _showDetails(marker),
/// )
/// 
/// // With custom config
/// LynewedMapWidget(
///   userRole: 'bride',
///   config: LynewedMapConfig(
///     initialCenter: gmaps.LatLng(48.8566, 2.3522),
///     initialZoom: 14.0,
///   ),
///   initialFilter: MapFilter(
///     professions: [Profession.photographer],
///     toggles: LayerToggles(showAlerts: false),
///   ),
/// )
/// ```
/// 
/// ## Architecture
/// 
/// ```
/// features/map/
/// ├── domain/           # Business logic layer
/// │   ├── entities/     # MapMarker, MapFilter, Wedding, Alert
/// │   └── repositories/ # MapRepository interface
/// │
/// ├── data/             # Data layer
/// │   ├── datasources/  # SupabaseMapDatasource
/// │   └── repositories/ # SupabaseMapRepository
/// │
/// └── presentation/     # UI layer
///     ├── widgets/      # LynewedMapWidget
///     ├── state/        # MapState (ChangeNotifier)
///     └── pages/        # MapPage (unified bride/pro)
/// ```
library map;

// Domain - Entities
export 'domain/entities/entities.dart';

// Domain - Repositories
export 'domain/repositories/map_repository.dart';

// Data - Repositories
export 'data/repositories/supabase_map_repository.dart';

// Presentation - State
export 'presentation/state/map_state.dart';

// Presentation - Widgets
export 'presentation/widgets/lynewed_map_widget.dart';
