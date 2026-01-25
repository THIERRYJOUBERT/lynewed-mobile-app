/// Common type aliases for Clean Architecture.
///
/// These typedefs reduce boilerplate and improve code readability.
///
/// Example:
/// ```dart
/// // Instead of:
/// Future<Result<User>> getUser(String id);
///
/// // You can write:
/// FutureResult<User> getUser(String id);
/// ```
library;

import 'package:lynewed_beta/core/utils/result.dart';

/// A Future that resolves to a Result.
///
/// Use this for async operations that can succeed or fail.
typedef FutureResult<T> = Future<Result<T>>;

/// A Future that resolves to void.
///
/// Use this for async operations that don't return a value.
typedef FutureVoid = Future<void>;

/// A Future that resolves to a boolean.
///
/// Use this for async operations that return success/failure as bool.
typedef FutureBool = Future<bool>;

/// A JSON object represented as a Map.
///
/// Use this when working with JSON data from APIs.
typedef Json = Map<String, dynamic>;

/// A list of JSON objects.
///
/// Use this when working with JSON arrays from APIs.
typedef JsonList = List<Map<String, dynamic>>;
