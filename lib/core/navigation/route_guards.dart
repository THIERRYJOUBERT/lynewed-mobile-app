/// Route guards and navigation patterns for the Lynewed application.
///
/// This module documents the navigation patterns used by FlutterFlow and
/// provides utility classes for route protection and deep linking.
///
/// The FlutterFlow navigation system uses:
/// - [FFRoute] wrapper around go_router's [GoRoute]
/// - [FFParameters] for parameter extraction and deserialization
/// - [TransitionInfo] for custom page transitions
/// - [AppStateNotifier] for auth state management
library;

import 'package:flutter/foundation.dart' show immutable;

import 'routes.dart';

/// Authentication guard for route protection.
///
/// Determines which routes require authentication and handles redirects
/// for unauthenticated users.
///
/// Example usage:
/// ```dart
/// if (!AuthGuard.isPublicRoute(currentPath) && !isLoggedIn) {
///   return AuthGuard.defaultRedirectPath;
/// }
/// ```
abstract final class AuthGuard {
  /// Routes that do not require authentication.
  static const Set<String> publicRoutes = {
    AppRoutes.root,
    AppRoutes.authWelcome,
    AppRoutes.signIn,
    AppRoutes.signUp,
    AppRoutes.forgotPassword,
    AppRoutes.signInPro,
    AppRoutes.setPasswordPro,
    AppRoutes.resetPassword,
  };

  /// Default redirect path for unauthenticated users.
  static const String defaultRedirectPath = AppRoutes.authWelcome;

  /// Check if a route is public (doesn't require authentication).
  ///
  /// Handles paths with query parameters by extracting the base path.
  static bool isPublicRoute(String path) {
    // Extract base path without query parameters
    final basePath = path.split('?').first;
    return publicRoutes.contains(basePath);
  }

  /// Get redirect path based on authentication state.
  ///
  /// Returns:
  /// - `null` if no redirect needed (authenticated or public route)
  /// - [defaultRedirectPath] if redirect needed
  static String? getRedirectPath({
    required bool isLoggedIn,
    required String currentPath,
  }) {
    if (isPublicRoute(currentPath)) {
      return null;
    }
    if (isLoggedIn) {
      return null;
    }
    return defaultRedirectPath;
  }
}

/// Documentation of FlutterFlow navigation patterns.
///
/// This class provides static descriptions of the navigation patterns
/// used in the codebase, helping developers understand how to integrate
/// Clean Architecture pages with the existing FlutterFlow navigation.
abstract final class NavigationPatterns {
  /// Description of the FFRoute pattern.
  ///
  /// FFRoute is a wrapper around go_router's GoRoute that adds:
  /// - requireAuth flag for protected routes
  /// - asyncParams for lazy parameter loading
  /// - Custom page builder with FFParameters
  static const String ffRouteDescription = '''
FFRoute Pattern (go_router wrapper):

FFRoute is the core navigation building block used by FlutterFlow.
It wraps go_router's GoRoute with additional features:

1. Route Definition:
   FFRoute(
     name: 'PageName',
     path: '/pagePath',
     builder: (context, params) => PageWidget(),
   )

2. Auth Protection:
   FFRoute(
     ...
     requireAuth: true, // Redirects to authWelcome if not logged in
   )

3. Async Parameters:
   FFRoute(
     ...
     asyncParams: {
       'docRef': (ref) => SomeTable().get(ref),
     },
   )

4. The FFRoute.toRoute() method converts to a GoRoute with:
   - Redirect handling for auth
   - Custom page builder with transitions
   - Loading state handling
''';

  /// Description of parameter handling.
  ///
  /// FFParameters provides type-safe parameter extraction from routes.
  static const String parameterHandlingDescription = '''
FFParameters Pattern:

FFParameters wraps GoRouterState to provide type-safe parameter extraction.

Key methods:
- getParam<T>(name, ParamType, {isList, structBuilder})

Parameter sources (merged in allParams):
- pathParameters: /path/:id
- queryParameters: ?key=value
- extra: Additional data passed to navigation

Supported types via ParamType enum:
- Primitives: int, double, String, bool
- Dates: DateTime, DateTimeRange
- Geo: LatLng
- UI: Color
- Complex: FFPlace, FFUploadedFile, JSON
- Custom: DataStruct (with structBuilder), Enum, SupabaseRow

Example:
  params.getParam('roomId', ParamType.String)
  params.getParam('proDetails', ParamType.DataStruct,
    structBuilder: ProDetailsStruct.fromSerializableMap)
''';

  /// Description of transition handling.
  static const String transitionDescription = '''
TransitionInfo Pattern:

Custom page transitions are configured via the kTransitionInfoKey extra:

TransitionInfo(
  hasTransition: true,
  transitionType: PageTransitionType.fade,
  duration: Duration(milliseconds: 300),
  alignment: Alignment.center,
)

This is passed in the extra map when navigating:
context.pushNamed('Page', extra: {
  kTransitionInfoKey: TransitionInfo(...),
});

The FFRoute.toRoute() pageBuilder checks for this and applies the transition.
''';

  /// Description of auth redirect pattern.
  static const String authRedirectDescription = '''
Auth Redirect Pattern:

The navigation system handles authentication redirects automatically:

1. AppStateNotifier tracks:
   - loggedIn: Current auth state
   - shouldRedirect: Whether a redirect is pending
   - redirectLocation: The pending redirect URL

2. FFRoute.toRoute() redirect callback:
   - If shouldRedirect is true, returns the stored redirect location
   - If requireAuth is true and not logged in, stores current URL and redirects

3. Navigation extensions:
   - goNamedAuth: Navigates with redirect handling
   - pushNamedAuth: Pushes with redirect handling
   - safePop: Pops or goes to root if stack is empty

4. GoRouter extensions:
   - prepareAuthEvent: Prepares for sign in/out
   - shouldRedirect: Checks if redirect is needed
   - clearRedirectLocation: Clears pending redirect
''';

  /// List of supported parameter types in FlutterFlow navigation.
  static const List<String> supportedParamTypes = [
    'int',
    'double',
    'String',
    'bool',
    'DateTime',
    'DateTimeRange',
    'LatLng',
    'Color',
    'FFPlace',
    'FFUploadedFile',
    'JSON',
    'DataStruct',
    'Enum',
    'SupabaseRow',
  ];
}

/// Deep link handling for the Lynewed app.
///
/// Supports the following deep link patterns:
/// - lynewed://chat/{roomId}
/// - lynewed://profile/{profileId}
/// - lynewed://wedding/{weddingId}
abstract final class DeepLinkSchemes {
  /// The app's custom URL scheme.
  static const String scheme = 'lynewed';

  /// Path for chat deep links.
  static const String chatPath = 'chat';

  /// Path for profile deep links.
  static const String profilePath = 'profile';

  /// Path for wedding deep links.
  static const String weddingPath = 'wedding';

  /// Build a deep link URI.
  ///
  /// Example:
  /// ```dart
  /// buildDeepLink('chat', pathParams: {'roomId': 'abc123'})
  /// // Returns: lynewed://chat/abc123
  /// ```
  static String buildDeepLink(
    String path, {
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
  }) {
    var uri = '$scheme://$path';

    // Add path parameters (first value as path segment)
    if (pathParams != null && pathParams.isNotEmpty) {
      final firstParam = pathParams.values.first;
      uri = '$uri/$firstParam';
    }

    // Add query parameters if any
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString =
          queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      uri = '$uri?$queryString';
    }

    return uri;
  }

  /// Parse a deep link URI.
  ///
  /// Returns a [DeepLinkResult] with the path and extracted parameters,
  /// or null if the URI is invalid or doesn't use the lynewed scheme.
  static DeepLinkResult? parseDeepLink(String uriString) {
    try {
      final uri = Uri.parse(uriString);

      // Check scheme
      if (uri.scheme != scheme) {
        return null;
      }

      // Extract path and ID
      final path = uri.host;
      final pathSegments = uri.pathSegments;
      final id = pathSegments.isNotEmpty ? pathSegments.first : null;

      return DeepLinkResult(
        path: path,
        params: {
          if (id != null) 'id': id,
          ...uri.queryParameters,
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Convert a deep link to an app route path.
  ///
  /// Example:
  /// ```dart
  /// toAppRoute('lynewed://chat/room123')
  /// // Returns: /chatDetailsPage?roomId=room123
  /// ```
  static String? toAppRoute(String uriString) {
    final result = parseDeepLink(uriString);
    if (result == null) {
      return null;
    }

    switch (result.path) {
      case chatPath:
        final roomId = result.params['id'];
        if (roomId == null) return null;
        return '${AppRoutes.chatDetails}?roomId=$roomId';

      case profilePath:
        final profileId = result.params['id'];
        if (profileId == null) return null;
        return '${AppRoutes.proDetails}?profileId=$profileId';

      case weddingPath:
        final weddingId = result.params['id'];
        if (weddingId == null) return null;
        return '${AppRoutes.myWedding}?weddingId=$weddingId';

      default:
        return null;
    }
  }
}

/// Result of parsing a deep link.
@immutable
class DeepLinkResult {
  /// The path component (e.g., 'chat', 'profile').
  final String path;

  /// Extracted parameters from path segments and query string.
  final Map<String, String> params;

  /// Creates a [DeepLinkResult].
  const DeepLinkResult({
    required this.path,
    required this.params,
  });
}
