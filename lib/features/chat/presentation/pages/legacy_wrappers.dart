/// Legacy page wrappers for backward compatibility
///
/// These wrappers redirect the old MessagesBridesWidget and MessagesProWidget
/// routes to the new unified MessagesPage.
library;

import 'package:flutter/material.dart';
import 'messages_page.dart';

/// Wrapper for the legacy MessagesBrides page
///
/// Maintains backward compatibility with existing navigation routes
/// while redirecting to the unified MessagesPage.
class MessagesBridesPageWrapper extends StatelessWidget {
  const MessagesBridesPageWrapper({super.key});

  /// Route name matching the legacy MessagesBridesWidget
  static const String routeName = 'MessagesBrides';

  /// Route path matching the legacy MessagesBridesWidget
  static const String routePath = '/messagesBrides';

  @override
  Widget build(BuildContext context) {
    // Redirect to unified MessagesPage
    return const MessagesPage();
  }
}

/// Wrapper for the legacy MessagesPro page
///
/// Maintains backward compatibility with existing navigation routes
/// while redirecting to the unified MessagesPage.
class MessagesProPageWrapper extends StatelessWidget {
  const MessagesProPageWrapper({super.key});

  /// Route name matching the legacy MessagesProWidget
  static const String routeName = 'MessagesPro';

  /// Route path matching the legacy MessagesProWidget
  static const String routePath = '/messagesPro';

  @override
  Widget build(BuildContext context) {
    // Redirect to unified MessagesPage
    return const MessagesPage();
  }
}
