/// Notifications Module - Clean Architecture
///
/// This module handles in-app and push notifications for the application.
///
/// ## Notification Types (Backend v23)
/// - `chatMessage`: New private message
/// - `connectionRequest`: Contact request (Pro to Bride)
/// - `connectionRequestAccepted`: Request accepted
/// - `wishlistAdd`: Bride adds Pro to wishlist (Ultimate only)
/// - `videoIncoming`: Incoming video call
/// - `wedPublished`: New Wedding of the Week
/// - `replayPublished`: New replay video available
///
/// ## Structure
/// ```
/// lib/features/notifications/
/// ├── notifications.dart          # Barrel export
/// ├── domain/
/// │   ├── entities/
/// │   │   ├── app_notification.dart
/// │   │   ├── notification_payload.dart
/// │   │   ├── notification_setting.dart
/// │   │   ├── notification_type_config.dart
/// │   │   └── entities.dart       # Barrel export
/// │   └── repositories/
/// │       └── notification_repository.dart
/// ├── data/
/// │   ├── models/
/// │   │   └── notification_model.dart
/// │   ├── datasources/
/// │   │   └── notification_remote_datasource.dart
/// │   └── repositories/
/// │       └── notification_repository_impl.dart
/// └── presentation/
///     ├── bloc/
///     │   ├── notifications_cubit.dart
///     │   └── notifications_state.dart
///     ├── pages/
///     │   ├── notifications_page.dart
///     │   └── notification_settings_page.dart
///     └── widgets/
///         ├── notification_badge.dart
///         └── notification_tile.dart
/// ```
library;

// Domain - Entities
export 'domain/entities/app_notification.dart';
export 'domain/entities/entities.dart';
export 'domain/entities/notification_payload.dart';
export 'domain/entities/notification_setting.dart';
export 'domain/entities/notification_type_config.dart';

// Domain - Repositories
export 'domain/repositories/notification_repository.dart';

// Data - Repositories
export 'data/repositories/notification_repository_impl.dart';

// Presentation - State Management
export 'presentation/bloc/notifications_cubit.dart';
export 'presentation/bloc/notifications_state.dart';

// Presentation - Pages
export 'presentation/pages/notification_settings_page.dart';
export 'presentation/pages/notifications_page.dart';

// Presentation - Widgets
export 'presentation/widgets/notification_badge.dart';
export 'presentation/widgets/notification_tile.dart';
