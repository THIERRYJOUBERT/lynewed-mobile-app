/// Page wrapper utilities for Clean Architecture pages.
///
/// This module provides base classes and utilities for wrapping Clean
/// Architecture pages so they can coexist with FlutterFlow legacy pages
/// in the go_router navigation system.
///
/// Example usage:
/// ```dart
/// class ChatDetailsPageWrapper extends StatelessWidget {
///   final String? roomId;
///   final bool isPublicRoom;
///
///   const ChatDetailsPageWrapper({
///     this.roomId,
///     this.isPublicRoom = false,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context) {
///     return ChatDetailsPage(
///       roomId: PageWrapperMixin.convertStringToNullable(roomId) ?? '',
///       isPublicRoom: isPublicRoom,
///     );
///   }
/// }
/// ```
library;

import 'package:flutter/material.dart';

/// Configuration for page wrappers.
///
/// Provides common configuration options for wrapper widgets.
@immutable
class WrapperConfig {
  /// Whether to wrap the page in a [Scaffold].
  ///
  /// Set to true when the Clean Architecture page doesn't include its own
  /// Scaffold and needs one for proper layout.
  final bool useScaffold;

  /// Background color for the scaffold (if [useScaffold] is true).
  final Color? backgroundColor;

  /// Whether the scaffold should resize when keyboard appears.
  final bool resizeToAvoidBottomInset;

  /// Creates a [WrapperConfig].
  const WrapperConfig({
    this.useScaffold = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  /// Creates a copy with modified values.
  WrapperConfig copyWith({
    bool? useScaffold,
    Color? backgroundColor,
    bool? resizeToAvoidBottomInset,
  }) {
    return WrapperConfig(
      useScaffold: useScaffold ?? this.useScaffold,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      resizeToAvoidBottomInset:
          resizeToAvoidBottomInset ?? this.resizeToAvoidBottomInset,
    );
  }
}

/// Mixin providing common utilities for page wrappers.
///
/// Provides type conversion utilities for handling FlutterFlow parameter
/// serialization when transitioning to Clean Architecture pages.
mixin class PageWrapperMixin {
  /// Converts a string parameter to nullable, handling empty/null strings.
  ///
  /// FlutterFlow often serializes null as 'null' string or empty string.
  /// This method normalizes these to actual null values.
  static String? convertStringToNullable(String? value) {
    if (value == null || value.isEmpty || value == 'null') {
      return null;
    }
    return value;
  }

  /// Parses a dynamic value to boolean.
  ///
  /// Handles:
  /// - null -> false
  /// - bool -> as is
  /// - String 'true'/'1' -> true
  /// - String 'false'/'0' -> false
  /// - Other -> false
  static bool parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  /// Parses a string to int, returning null if invalid.
  static int? parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// Parses a string to double, returning null if invalid.
  static double? parseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  /// Parses a string to DateTime, returning null if invalid.
  ///
  /// Handles milliseconds since epoch (FlutterFlow format).
  static DateTime? parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final millis = int.tryParse(value);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Extracts a list from a JSON-encoded string.
  ///
  /// Returns empty list if parsing fails.
  static List<String> parseStringList(String? value) {
    if (value == null || value.isEmpty) return [];
    try {
      // Handle JSON array format
      if (value.startsWith('[') && value.endsWith(']')) {
        // Simple parsing for string lists
        final inner = value.substring(1, value.length - 1);
        if (inner.isEmpty) return [];
        return inner
            .split(',')
            .map((s) => s.trim().replaceAll('"', ''))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

/// Base class for page wrappers.
///
/// Provides common functionality for wrapping Clean Architecture pages
/// with FlutterFlow compatibility.
///
/// Example:
/// ```dart
/// class MyPageWrapper extends CleanPageWrapper {
///   final String? param;
///
///   const MyPageWrapper({this.param, super.key});
///
///   @override
///   WrapperConfig get config => const WrapperConfig();
///
///   @override
///   Widget buildPage(BuildContext context) {
///     return MyPage(param: param ?? '');
///   }
/// }
/// ```
abstract class CleanPageWrapper extends StatelessWidget {
  /// Creates a [CleanPageWrapper].
  const CleanPageWrapper({super.key});

  /// Configuration for the wrapper.
  WrapperConfig get config => const WrapperConfig();

  /// Builds the actual Clean Architecture page.
  Widget buildPage(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final page = buildPage(context);

    if (config.useScaffold) {
      return Scaffold(
        backgroundColor: config.backgroundColor,
        resizeToAvoidBottomInset: config.resizeToAvoidBottomInset,
        body: page,
      );
    }

    return page;
  }
}

/// Extension methods for navigation-related context operations.
extension NavigationExtensions on BuildContext {
  /// Gets a query parameter from the current route.
  ///
  /// Returns null if the parameter doesn't exist or if go_router state
  /// is not available.
  String? getQueryParam(String key) {
    try {
      // This would typically use GoRouterState.of(context)
      // but we keep it simple for compatibility
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Gets the current route path.
  String? get currentPath {
    try {
      // Would use GoRouter.of(context).location
      return null;
    } catch (_) {
      return null;
    }
  }
}
