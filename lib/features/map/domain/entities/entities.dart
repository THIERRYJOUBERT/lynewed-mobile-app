/// Map feature domain entities barrel export
/// 
/// Clean, immutable data classes replacing FlutterFlow's verbose structs.
/// Total: ~800 lines vs FlutterFlow's 1200+ lines for same functionality.
library;

// Core map entities
export 'map_marker.dart';
export 'map_filter.dart';
export 'professional_alert.dart';
export 'wedding.dart';

// Details entities for sheets (Phase 4) - canonical source for Profession and AlertType
export 'professional_details.dart';
export 'alert_details.dart';
export 'wedding_details.dart';
