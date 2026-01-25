/// Application exception types for Clean Architecture.
///
/// Exceptions are thrown in the data layer and caught in repositories
/// to be converted to Failures for the domain layer.
///
/// Example:
/// ```dart
/// class UserRemoteDatasource {
///   Future<User> fetchUser(String id) async {
///     final response = await http.get('/users/$id');
///     if (response.statusCode != 200) {
///       throw ServerException('Failed to fetch user', statusCode: response.statusCode);
///     }
///     return User.fromJson(response.body);
///   }
/// }
/// ```
library;

/// Base class for all application exceptions.
///
/// Provides a common interface for exception handling.
abstract class AppException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Creates an application exception with a message.
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception from server/API errors.
///
/// Thrown when remote data source operations fail due to server issues.
class ServerException extends AppException {
  /// HTTP status code if available.
  final int? statusCode;

  /// Creates a server exception with a message and optional status code.
  ServerException(super.message, {this.statusCode});

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Exception from local cache operations.
///
/// Thrown when local storage read/write operations fail.
class CacheException extends AppException {
  /// Creates a cache exception with a message.
  CacheException(super.message);
}

/// Exception from network connectivity issues.
///
/// Thrown when the device has no internet connection or requests timeout.
class NetworkException extends AppException {
  /// Creates a network exception with a message.
  NetworkException(super.message);
}

/// Exception from input validation.
///
/// Thrown when user input or data doesn't meet validation requirements.
class ValidationException extends AppException {
  /// The field that failed validation, if applicable.
  final String? field;

  /// Creates a validation exception with a message and optional field name.
  ValidationException(super.message, {this.field});

  @override
  String toString() =>
      'ValidationException: $message${field != null ? ' (field: $field)' : ''}';
}

/// Exception from authentication/authorization issues.
///
/// Thrown when user is not authenticated or doesn't have permission.
class AuthException extends AppException {
  /// Creates an auth exception with a message.
  AuthException(super.message);
}
