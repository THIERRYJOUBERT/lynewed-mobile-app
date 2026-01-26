/// Profile feature module for Clean Architecture.
///
/// This barrel export provides access to all profile-related components:
/// - Domain entities (ProfileMenuItemData)
/// - Presentation widgets (ProfileHeader, ProfileMenuItemWidget)
/// - Presentation pages (ProfilePage, ProDetailsPage, PublicProProfilePage)
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/profile/profile.dart';
///
/// // Now you can use:
/// // - ProfileMenuItemData entity
/// // - ProfileHeader widget
/// // - ProfileMenuItemWidget widget
/// // - ProfilePage
/// // - ProDetailsPage
/// // - PublicProProfilePage
/// ```
library;

// Domain layer
export 'domain/entities/profile_menu_item.dart';

// Presentation layer - widgets
export 'presentation/widgets/profile_header.dart';
export 'presentation/widgets/profile_menu_item_widget.dart';

// Presentation layer - pages
export 'presentation/pages/profile_page.dart';
export 'presentation/pages/pro_details_page.dart';
export 'presentation/pages/public_pro_profile_page.dart';
