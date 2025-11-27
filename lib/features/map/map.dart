/// Map feature module - Clean architecture replacement for FlutterFlow code
/// 
/// This module provides a complete, testable map feature implementation
/// replacing the verbose FlutterFlow-generated code (3600+ lines → ~2500 lines).
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:lynewed/features/map/map.dart';
/// 
/// // Simple page usage
/// MapPage(
///   userRole: 'professional',
///   config: MapPageConfig(showSearchBar: true),
/// )
/// 
/// // Widget only usage
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
///   onMarkerTap: (marker) => _showDetails(marker),
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
/// │   ├── models/       # Type mappers for compatibility
/// │   └── repositories/ # SupabaseMapRepository
/// │
/// └── presentation/     # UI layer
///     ├── widgets/      # LynewedMapWidget, FilterSheet, MarkerDetailsSheet
///     ├── state/        # MapState (ChangeNotifier)
///     ├── pages/        # MapPage (unified bride/pro)
///     └── theme/        # MapTheme, colors, sizes
/// ```
library map;

// Domain - Entities
export 'domain/entities/entities.dart';

// Domain - Repositories
export 'domain/repositories/map_repository.dart';

// Domain - Utils (Phase 3)
export 'domain/utils/marker_offset.dart';

// Domain - Use Cases (Phase 4)
export 'domain/usecases/get_marker_details.dart';

// Data - Models (compatibility)
export 'data/models/marker_type_mapper.dart';

// Data - Repositories
export 'data/repositories/supabase_map_repository.dart';

// Presentation - State
export 'presentation/state/map_state.dart';

// Presentation - Theme
export 'presentation/theme/map_theme.dart';

// Presentation - Services (Phase 3)
export 'presentation/services/marker_icon_generator.dart';

// Presentation - Widgets
export 'presentation/widgets/lynewed_map_widget.dart';
export 'presentation/widgets/filter_sheet.dart';
export 'presentation/widgets/marker_details_sheet.dart';
export 'presentation/widgets/animated_marker.dart';

// Presentation - Sheets (Phase 4)
export 'presentation/sheets/sheets.dart';

// Presentation - Pages
export 'presentation/pages/map_page.dart';

// Presentation - Legacy Wrappers (compatibilité navigation FlutterFlow)
export 'presentation/pages/map_brides_large_wrapper.dart';
export 'presentation/pages/map_pro_large_wrapper.dart';
