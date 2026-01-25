/// Support feature module for Clean Architecture.
///
/// This barrel export provides access to all support-related components:
/// - Presentation widgets (QuickActionCard, FaqSection, ContactForm)
/// - Presentation pages (SupportPage)
/// - Data models (FaqItem)
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/support/support.dart';
///
/// // Now you can use:
/// // - SupportPage
/// // - QuickActionCard widget
/// // - FaqSection widget (with FaqItem model)
/// // - ContactForm widget
/// ```
library;

// Presentation layer - widgets
export 'presentation/widgets/quick_action_card.dart';
export 'presentation/widgets/faq_section.dart';
export 'presentation/widgets/contact_form.dart';

// Presentation layer - pages
export 'presentation/pages/support_page.dart';
