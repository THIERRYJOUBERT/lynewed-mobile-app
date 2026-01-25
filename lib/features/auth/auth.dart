/// Auth feature module for Clean Architecture.
///
/// This barrel export provides access to all auth-related domain entities,
/// repository interfaces, data layer implementations, and presentation bloc.
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/auth/auth.dart';
///
/// // Now you can use:
/// // - AuthUser entity
/// // - UserProfile entity
/// // - UserRole enum
/// // - AuthRepository interface
/// // - UpdateProfileParams
/// // - AuthRepositoryImpl
/// // - AuthRemoteDatasource
/// // - AuthCubit
/// // - AuthState (and subclasses)
/// ```
library;

// Domain layer
export 'domain/entities/entities.dart';
export 'domain/repositories/auth_repository.dart';

// Data layer
export 'data/data.dart';

// Presentation layer
export 'presentation/bloc/bloc.dart';
