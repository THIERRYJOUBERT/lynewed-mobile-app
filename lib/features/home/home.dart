/// Home feature module for Clean Architecture.
///
/// This barrel export provides access to all home-related components:
/// - Presentation pages (HomeBridesPage)
/// - Presentation widgets (QuickActionItem, QuickActionsRow, WeddingSummaryCard)
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/home/home.dart';
///
/// // Now you can use:
/// // - HomeBridesPage
/// // - QuickActionItem widget
/// // - QuickActionsRow widget
/// // - WeddingSummaryCard widget
/// ```
library;

// Presentation layer - pages
export 'presentation/pages/home_brides_page.dart';

// Presentation layer - widgets
export 'presentation/widgets/quick_action_item.dart';
export 'presentation/widgets/quick_actions_row.dart';
export 'presentation/widgets/wedding_summary_card.dart';
