/// Application failure types for Clean Architecture.
///
/// Failures represent errors that have been caught and handled.
/// Use these in the domain layer to communicate errors without
/// exposing implementation details.
///
/// Example:
/// ```dart
/// Result<User> getUser(String id) async {
///   try {
///     final user = await datasource.fetchUser(id);
///     return Success(user);
///   } on ServerException catch (e) {
///     return Failure(ServerFailure(e.message, code: e.statusCode?.toString()));
///   }
/// }
/// ```
library;

/// Base class for all application failures.
///
/// Failures are domain-level error representations that don't expose
/// implementation details like exceptions do.
abstract class AppFailure {
  /// Human-readable error message.
  final String message;

  /// Optional error code for programmatic handling.
  final String? code;

  /// Creates an application failure with a message and optional code.
  const AppFailure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure from server/API errors.
///
/// Use when remote data source operations fail due to server issues.
class ServerFailure extends AppFailure {
  /// Creates a server failure with a message and optional error code.
  const ServerFailure(super.message, {super.code});
}

/// Failure from local cache operations.
///
/// Use when local storage read/write operations fail.
class CacheFailure extends AppFailure {
  /// Creates a cache failure with a message and optional error code.
  const CacheFailure(super.message, {super.code});
}

/// Failure from network connectivity issues.
///
/// Use when the device has no internet connection or requests timeout.
class NetworkFailure extends AppFailure {
  /// Creates a network failure with a message and optional error code.
  const NetworkFailure(super.message, {super.code});
}

/// Failure from input validation.
///
/// Use when user input or data doesn't meet validation requirements.
class ValidationFailure extends AppFailure {
  /// Creates a validation failure with a message and optional error code.
  const ValidationFailure(super.message, {super.code});
}

/// Failure from authentication/authorization issues.
///
/// Use when user is not authenticated or doesn't have permission.
class AuthFailure extends AppFailure {
  /// Creates an auth failure with a message and optional error code.
  const AuthFailure(super.message, {super.code});
}

/// Failure for unexpected/unknown errors.
///
/// Use as a fallback when the error type is not recognized.
class UnknownFailure extends AppFailure {
  /// Creates an unknown failure with a message and optional error code.
  const UnknownFailure(super.message, {super.code});
}
