/// Settings feature module for Clean Architecture.
///
/// This barrel export provides access to all settings-related components:
/// - Presentation widgets (SettingsTile)
/// - Presentation pages (SettingsPage, PermissionsPage)
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/settings/settings.dart';
///
/// // Now you can use:
/// // - SettingsTile widget
/// // - SettingsPage
/// // - PermissionsPage
/// ```
library;

// Presentation layer - widgets
export 'presentation/widgets/settings_tile.dart';

// Presentation layer - pages
export 'presentation/pages/settings_page.dart';
export 'presentation/pages/permissions_page.dart';
