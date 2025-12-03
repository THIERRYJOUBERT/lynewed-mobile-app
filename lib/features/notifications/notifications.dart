/// Notifications Module - Clean Architecture
/// 
/// Ce module gère les notifications in-app et push de l'application.
/// 
/// ## Types de Notifications Actifs (Backend v23)
/// - `chatMessage`: Nouveau message privé
/// - `connectionRequest`: Demande de contact (Pro→Bride)
/// - `connectionRequestAccepted`: Demande acceptée
/// - `wishlistAdd`: Bride ajoute Pro en favoris (Ultimate only)
/// - `videoIncoming`: Appel vidéo entrant
/// - `wedPublished`: Nouveau Wedding of the Week
/// 
/// ## Structure
/// ```
/// lib/features/notifications/
/// ├── notifications.dart          # Barrel export
/// ├── domain/
/// │   ├── entities/
/// │   │   └── notification_setting.dart
/// │   └── repositories/
/// │       └── notification_repository.dart
/// ├── data/
/// │   └── repositories/
/// │       └── notification_repository_impl.dart
/// └── presentation/
///     ├── pages/
///     │   ├── notifications_page.dart
///     │   └── notification_settings_page.dart
///     └── widgets/
///         └── notification_tile.dart
/// ```
library notifications;

// Domain
export 'domain/entities/notification_setting.dart';
export 'domain/entities/notification_type_config.dart';

// Presentation
export 'presentation/pages/notification_settings_page.dart';
export 'presentation/pages/notifications_page.dart';
