/// Handler for deep links in the application.
///
/// Processes incoming deep links from:
/// - Custom scheme: lynewed://join/{code}
/// - HTTPS links: https://lynewed.com/join/{code}
library;

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Handles deep link routing for the application.
///
/// Supports wedding invitation links in the format:
/// - `https://lynewed.com/join/{code}`
/// - `https://www.lynewed.com/join/{code}`
/// - `lynewed://join/{code}`
class DeepLinkHandler {
  /// Creates a deep link handler.
  DeepLinkHandler({
    required GoRouter router,
    AppLinks? appLinks,
  })  : _router = router,
        _appLinks = appLinks ?? AppLinks();

  final GoRouter _router;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;
  bool _initialized = false;

  /// Initializes the deep link handler.
  ///
  /// Should be called early in app initialization.
  /// Handles both initial links (app was closed) and
  /// incoming links while the app is running.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Get initial link (app was closed)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      // Ignore errors getting initial link
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (_) {
        // Ignore errors in link stream
      },
    );
  }

  /// Disposes the handler and cancels subscriptions.
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _initialized = false;
  }

  /// Processes a deep link URI and navigates accordingly.
  void _handleDeepLink(Uri uri) {
    final inviteCode = extractInviteCode(uri);
    if (inviteCode != null) {
      _navigateToJoinWedding(inviteCode);
      return;
    }

    // Handle other deep links here if needed in the future
  }

  /// Extracts the invitation code from a deep link URI.
  ///
  /// Supported formats:
  /// - `https://lynewed.com/join/ABCD1234`
  /// - `https://www.lynewed.com/join/ABCD1234`
  /// - `lynewed://join/ABCD1234`
  /// - `lynewed://join?code=ABCD1234`
  ///
  /// Returns null if the URI is not a valid invitation link
  /// or the code is not exactly 8 alphanumeric characters.
  static String? extractInviteCode(Uri uri) {
    // Check for join path - handle both HTTPS and custom scheme
    // For HTTPS: pathSegments = ['join', 'CODE']
    // For custom scheme: host = 'join', pathSegments = ['CODE'] or []
    final isHttpsJoinPath =
        uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'join';
    final isCustomSchemeJoin = uri.scheme == 'lynewed' && uri.host == 'join';

    if (!isHttpsJoinPath && !isCustomSchemeJoin) return null;

    String? code;

    if (isHttpsJoinPath) {
      // HTTPS format: /join/{code}
      if (uri.pathSegments.length >= 2) {
        code = uri.pathSegments[1];
      }
    } else if (isCustomSchemeJoin) {
      // Custom scheme format: lynewed://join/{code}
      // Here 'join' is the host, code is in pathSegments[0]
      if (uri.pathSegments.isNotEmpty) {
        code = uri.pathSegments.first;
      }
    }

    // Query format: /join?code={code} or lynewed://join?code={code}
    if (code == null || code.isEmpty) {
      code = uri.queryParameters['code'];
    }

    // Validate code format
    if (code == null || code.isEmpty) return null;
    code = code.toUpperCase();

    if (!_isValidInviteCode(code)) return null;

    return code;
  }

  /// Validates that a code is exactly 8 alphanumeric characters.
  static bool _isValidInviteCode(String code) {
    return RegExp(r'^[A-Z0-9]{8}$').hasMatch(code);
  }

  /// Navigates to the JoinWedding page with the given code.
  void _navigateToJoinWedding(String code) {
    _router.go('/joinWedding?code=$code');
  }
}
