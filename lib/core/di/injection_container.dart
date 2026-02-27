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
import '../../features/marketplace/data/datasources/fedex_remote_datasource.dart';
import '../../features/marketplace/data/datasources/stripe_connect_datasource.dart';
import '../../features/marketplace/data/repositories/fedex_repository_impl.dart';
import '../../features/marketplace/data/repositories/stripe_connect_repository_impl.dart';
import '../../features/marketplace/data/repositories/supabase_marketplace_chat_repository.dart';
import '../../features/marketplace/data/repositories/supabase_marketplace_offer_repository.dart';
import '../../features/marketplace/data/repositories/supabase_marketplace_repository.dart';
import '../../features/marketplace/data/repositories/supabase_marketplace_transaction_repository.dart';
import '../../features/marketplace/domain/repositories/fedex_repository.dart';
import '../../features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import '../../features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/marketplace/domain/repositories/marketplace_transaction_repository.dart';
import '../../features/marketplace/domain/repositories/stripe_connect_repository.dart';
import '../../features/marketplace/domain/usecases/calculate_shipping_rate_use_case.dart';
import '../../features/marketplace/domain/usecases/get_seller_shipping_address.dart';
import '../../features/marketplace/domain/usecases/check_stripe_status_use_case.dart';
import '../../features/marketplace/domain/usecases/generate_shipping_label_use_case.dart';
import '../../features/marketplace/domain/usecases/approve_refund_use_case.dart';
import '../../features/marketplace/domain/usecases/cancel_shipment_use_case.dart';
import '../../features/marketplace/domain/usecases/get_tracking_events_use_case.dart';
import '../../features/marketplace/domain/usecases/reject_refund_use_case.dart';
import '../../features/marketplace/domain/usecases/request_refund_use_case.dart';
import '../../features/marketplace/domain/usecases/setup_stripe_connect_use_case.dart';
import '../../features/payments/data/repositories/supabase_stripe_repository.dart';
import '../../features/payments/domain/repositories/stripe_repository.dart';
import '../../features/reviews/data/repositories/supabase_review_repository.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';

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

  // Marketplace Stripe Connect feature
  await _initMarketplaceStripe();

  // Marketplace FedEx shipping feature
  await _initMarketplaceFedEx();

  // Marketplace listing repository
  await _initMarketplace();
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

/// Initializes Marketplace Stripe Connect dependencies.
///
/// Registers datasource, repository, and use cases for Stripe Connect
/// seller onboarding flow.
Future<void> _initMarketplaceStripe() async {
  // Payments repository (shared, used by marketplace)
  if (!sl.isRegistered<StripeRepository>()) {
    sl.registerLazySingleton<StripeRepository>(
      () => SupabaseStripeRepository(SupaFlow.client),
    );
  }

  // Datasource
  sl.registerLazySingleton<StripeConnectDatasource>(
    () => SupabaseStripeConnectDatasource(SupaFlow.client),
  );

  // Repository
  sl.registerLazySingleton<StripeConnectRepository>(
    () => StripeConnectRepositoryImpl(
      datasource: sl<StripeConnectDatasource>(),
      stripeRepository: sl<StripeRepository>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<SetupStripeConnectUseCase>(
    () => SetupStripeConnectUseCase(sl<StripeConnectRepository>()),
  );
  sl.registerLazySingleton<CheckStripeStatusUseCase>(
    () => CheckStripeStatusUseCase(sl<StripeConnectRepository>()),
  );
}

/// Initializes marketplace listing repository dependencies.
///
/// Registers the MarketplaceRepository for CRUD operations on listings
/// and photo management.
Future<void> _initMarketplace() async {
  sl.registerLazySingleton<MarketplaceRepository>(
    () => SupabaseMarketplaceRepository(SupaFlow.client),
  );

  // Marketplace chat repository
  sl.registerLazySingleton<MarketplaceChatRepository>(
    () => SupabaseMarketplaceChatRepository(SupaFlow.client),
  );

  // Marketplace offer repository
  sl.registerLazySingleton<MarketplaceOfferRepository>(
    () => SupabaseMarketplaceOfferRepository(SupaFlow.client),
  );

  // Marketplace transaction repository
  sl.registerLazySingleton<MarketplaceTransactionRepository>(
    () => SupabaseMarketplaceTransactionRepository(SupaFlow.client),
  );

  // Refund use cases
  sl.registerLazySingleton<RequestRefundUseCase>(
    () => RequestRefundUseCase(sl<MarketplaceTransactionRepository>()),
  );
  sl.registerLazySingleton<ApproveRefundUseCase>(
    () => ApproveRefundUseCase(sl<MarketplaceTransactionRepository>()),
  );
  sl.registerLazySingleton<RejectRefundUseCase>(
    () => RejectRefundUseCase(sl<MarketplaceTransactionRepository>()),
  );
}

/// Initializes Marketplace FedEx shipping dependencies.
///
/// Registers datasource, repository, and use cases for FedEx shipping
/// (rate calculation, label generation, tracking events).
Future<void> _initMarketplaceFedEx() async {
  // Datasource
  sl.registerLazySingleton<FedExRemoteDatasource>(
    () => SupabaseFedExRemoteDatasource(SupaFlow.client),
  );

  // Repository
  sl.registerLazySingleton<FedExRepository>(
    () => FedExRepositoryImpl(sl<FedExRemoteDatasource>()),
  );

  // Use Cases
  sl.registerLazySingleton<GetSellerShippingAddress>(
    () => GetSellerShippingAddress(sl<AuthRemoteDatasource>()),
  );
  sl.registerLazySingleton<CalculateShippingRateUseCase>(
    () => CalculateShippingRateUseCase(sl<FedExRepository>()),
  );
  sl.registerLazySingleton<GenerateShippingLabelUseCase>(
    () => GenerateShippingLabelUseCase(sl<FedExRepository>()),
  );
  sl.registerLazySingleton<GetTrackingEventsUseCase>(
    () => GetTrackingEventsUseCase(sl<FedExRepository>()),
  );
  sl.registerLazySingleton<CancelShipmentUseCase>(
    () => CancelShipmentUseCase(sl<FedExRepository>()),
  );
}
