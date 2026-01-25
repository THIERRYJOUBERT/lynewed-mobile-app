/// Result type for Clean Architecture - simplified Either pattern.
///
/// Use Result to represent operations that can succeed or fail without
/// throwing exceptions. This makes error handling explicit and type-safe.
///
/// Example:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await datasource.fetchUser(id);
///     return Success(user);
///   } on ServerException catch (e) {
///     return Failure(ServerFailure(e.message));
///   }
/// }
///
/// // Using the result with pattern matching (Dart 3):
/// final result = await getUser('123');
/// switch (result) {
///   case Success(:final data):
///     print('User: ${data.name}');
///   case Failure(:final failure):
///     print('Error: ${failure.message}');
/// }
///
/// // Or using fold:
/// final message = result.fold(
///   onSuccess: (user) => 'Welcome, ${user.name}',
///   onFailure: (failure) => 'Error: ${failure.message}',
/// );
/// ```
library;

import 'package:lynewed_beta/core/error/failures.dart';

/// Sealed class representing either a success or failure.
///
/// Use [Success] for successful operations and [Failure] for errors.
sealed class Result<T> {
  /// Creates a Result.
  const Result();

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the data if [Success], null otherwise.
  T? getOrNull() => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  /// Returns the data if [Success], [defaultValue] otherwise.
  T getOrElse(T defaultValue) => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => defaultValue,
      };

  /// Returns the failure if [Failure], null otherwise.
  AppFailure? failureOrNull() => switch (this) {
        Success<T>() => null,
        Failure<T>(:final failure) => failure,
      };

  /// Transforms the result using the appropriate function.
  ///
  /// Calls [onSuccess] if this is a [Success], [onFailure] otherwise.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Failure<T>(:final failure) => onFailure(failure),
      };

  /// Maps the success value to a new type.
  ///
  /// If this is a [Success], applies [transform] to the data and returns
  /// a new [Success] with the transformed value.
  /// If this is a [Failure], returns a [Failure] with the same error.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(:final data) => Success(transform(data)),
        Failure<T>(:final failure) => Failure(failure),
      };
}

/// Represents a successful result containing [data].
class Success<T> extends Result<T> {
  /// The success value.
  final T data;

  /// Creates a successful result with [data].
  const Success(this.data);

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result containing a [failure].
class Failure<T> extends Result<T> {
  /// The failure describing what went wrong.
  final AppFailure failure;

  /// Creates a failed result with [failure].
  const Failure(this.failure);

  @override
  String toString() => 'Failure(${failure.message})';
}
