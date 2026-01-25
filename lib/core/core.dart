/// Core module for Lynewed Clean Architecture.
///
/// This barrel export provides easy access to all core utilities,
/// error handling, and dependency injection infrastructure.
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/core/core.dart';
///
/// // Now you can use:
/// // - Result<T> for operation results
/// // - AppFailure and subclasses for error handling
/// // - AppException and subclasses for exceptions
/// // - sl for dependency injection
/// // - Common typedefs (FutureResult, Json, etc.)
/// ```
library;

// Error handling
export 'error/failures.dart';
export 'error/exceptions.dart';

// Utilities
export 'utils/result.dart';
export 'utils/typedefs.dart';
export 'utils/extensions.dart';
export 'utils/form_utils.dart';
export 'utils/file_utils.dart';

// Models
export 'models/lat_lng.dart';
export 'models/place.dart';

// Dependency injection
export 'di/injection_container.dart';

// Navigation
export 'navigation/navigation.dart';
