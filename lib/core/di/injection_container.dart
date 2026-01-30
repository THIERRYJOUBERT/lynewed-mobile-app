/// Dependency Injection Container using GetIt.
///
/// Provides a service locator pattern for registering and retrieving
/// dependencies throughout the application.
///
/// Usage:
/// ```dart
/// // In main.dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initDependencies();
///   runApp(const MyApp());
/// }
///
/// // To register a dependency:
/// sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
///
/// // To retrieve a dependency:
/// final repository = sl<ChatRepository>();
/// ```
library;

import 'package:get_it/get_it.dart';

import '../../backend/supabase/supabase.dart';
import '../../features/auth/auth.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/reviews/data/repositories/supabase_review_repository.dart';

/// Global service locator instance.
///
/// Use this to register and retrieve dependencies anywhere in the app.
/// Prefer using lazy singletons for repositories and services.
final GetIt sl = GetIt.instance;

/// Initializes all application dependencies.
///
/// Call this in main() before runApp().
/// This function sets up:
/// - Core services
/// - Repositories
/// - Data sources
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initDependencies();
///   runApp(const MyApp());
/// }
/// ```
Future<void> initDependencies() async {
  // Core services
  await _initCore();

  // Feature-specific dependencies will be added here as the migration progresses
  // await _initChat();
  // await _initMap();
  // etc.
}

/// Initializes dependencies that require Supabase.
///
/// Call this in main() AFTER SupaFlow.initialize().
/// This function sets up:
/// - Auth repository and datasource
/// - Other Supabase-dependent services
///
/// Example:
/// ```dart
/// void main() async {
///   await initDependencies();
///   await SupaFlow.initialize();
///   await initSupabaseDependencies();
///   runApp(const MyApp());
/// }
/// ```
Future<void> initSupabaseDependencies() async {
  // Auth feature (requires Supabase client)
  await _initAuth();

  // Reviews feature
  await _initReviews();
}

/// Initializes core dependencies.
///
/// These are fundamental services used across the application.
Future<void> _initCore() async {
  // Placeholder for core services
  // Will be populated as features are migrated to Clean Architecture
  //
  // Example registrations:
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  // sl.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());
}

/// Initializes auth feature dependencies.
///
/// Note: This must be called AFTER SupaFlow.initialize() in main.dart.
Future<void> _initAuth() async {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(SupaFlow.client),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDatasource>()),
  );
}

/// Initializes reviews feature dependencies.
Future<void> _initReviews() async {
  // Repository (uses Supabase client)
  sl.registerLazySingleton<ReviewRepository>(
    () => SupabaseReviewRepository(SupaFlow.client),
  );
}
