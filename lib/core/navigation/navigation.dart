/// Navigation module for Lynewed Clean Architecture.
///
/// This barrel export provides access to all navigation-related utilities
/// including route constants, guards, and page wrapper utilities.
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/core/navigation/navigation.dart';
///
/// // Route constants
/// context.go(AppRoutes.chatDetails);
///
/// // Named routes
/// context.goNamed(RouteNames.chatDetails, queryParameters: {'roomId': id});
///
/// // Auth guards
/// if (!AuthGuard.isPublicRoute(path)) { ... }
///
/// // Deep links
/// final route = DeepLinkSchemes.toAppRoute(deepLink);
///
/// // Page wrappers
/// class MyWrapper extends CleanPageWrapper { ... }
/// ```
library;

export 'routes.dart';
export 'route_guards.dart';
export 'page_wrapper.dart';
