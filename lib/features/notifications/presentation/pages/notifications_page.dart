/// NotificationsPage - Clean Architecture
///
/// Displays the list of notifications for the current user.
/// Uses NotificationsNotifier for state management via ChangeNotifier pattern.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/features/marketplace/presentation/pages/buyer_transaction_page.dart';
import '/features/marketplace/presentation/pages/listing_detail_page.dart';
import '/features/marketplace/presentation/pages/marketplace_chat_page.dart';
import '/features/marketplace/presentation/pages/received_offers_page.dart';
import '/features/marketplace/presentation/pages/transaction_detail_page.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_tile.dart';
import '../../domain/entities/app_notification.dart';

/// Page displaying the list of notifications.
///
/// Uses [NotificationsNotifier] for reactive state management.
/// Displays notifications with:
/// - Header with back button and "Mark all read" action
/// - List of notifications with icons, titles, messages, and timestamps
/// - Tap on notification to navigate and mark as read
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Route constants for compatibility with existing navigation
  static const String routeName = 'NotificationsPage';
  static const String routePath = '/notificationsPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildSubheader(context),
            Expanded(
              child: Consumer<NotificationsNotifier>(
                builder: (context, notifier, _) {
                  final state = notifier.state;

                  if (state is NotificationsLoading) {
                    return const Center(child: CircularProgressIndicator(color: LynewedColors.primary));
                  }

                  if (state is NotificationsError) {
                    return _buildError(context, state.message, notifier);
                  }

                  if (state is NotificationsLoaded) {
                    if (state.notifications.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildNotificationsList(context, state, notifier);
                  }

                  // Initial state - show loading
                  return const Center(child: CircularProgressIndicator(color: LynewedColors.primary));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'NOTIFICATIONS',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubheader(BuildContext context) {
    return Consumer<NotificationsNotifier>(
      builder: (context, notifier, _) {
        final state = notifier.state;
        final hasUnread = state is NotificationsLoaded && state.hasUnread;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Below are some recent alerts for you.',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              if (hasUnread)
                GestureDetector(
                  onTap: () => notifier.markAllAsRead(),
                  child: Text(
                    'Mark read',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    NotificationsNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load notifications',
              style: LynewedTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.ghost,
              onPressed: () => notifier.loadNotifications(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 64,
              color: LynewedColors.gray200,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet.',
              style: LynewedTextStyles.bodyLarge.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    NotificationsLoaded state,
    NotificationsNotifier notifier,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: state.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(context, notification, notifier),
          onMarkAsRead: notification.isRead
              ? null
              : () => notifier.markAsRead(notification.id),
        );
      },
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
    NotificationsNotifier notifier,
  ) {
    // Mark as read
    if (!notification.isRead) {
      notifier.markAsRead(notification.id);
    }

    // Navigate based on notification type
    final nav = notification.navigation;
    if (nav != null) {
      _navigateToDestination(context, nav);
    }
  }

  void _navigateToDestination(
    BuildContext context,
    NotificationNavigation nav,
  ) {
    // Navigate based on route type
    switch (nav.route) {
      case NotificationRoute.chat:
        final roomId = nav.params['roomId'] as String?;
        if (roomId != null) {
          Navigator.of(context).pushNamed(
            '/chatRoom',
            arguments: {'roomId': roomId},
          );
        }

      case NotificationRoute.profile:
        final profileId = nav.params['profileId'] as String?;
        if (profileId != null) {
          Navigator.of(context).pushNamed(
            '/profile',
            arguments: {'profileId': profileId},
          );
        }

      case NotificationRoute.videoCall:
        final sessionId = nav.params['sessionId'] as String?;
        final channelName = nav.params['channelName'] as String?;
        if (sessionId != null) {
          Navigator.of(context).pushNamed(
            '/videoCall',
            arguments: {
              'sessionId': sessionId,
              if (channelName != null) 'channelName': channelName,
            },
          );
        }

      case NotificationRoute.weddingOfTheWeek:
        Navigator.of(context).pushNamed('/weddingOfTheWeek');

      case NotificationRoute.replays:
        Navigator.of(context).pushNamed('/replays');

      case NotificationRoute.notificationsList:
        // Already on notifications page, do nothing
        break;

      case NotificationRoute.marketplaceOffers:
        final listingId = nav.params['listingId'] as String?;
        if (listingId != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ReceivedOffersPage(listingId: listingId),
            ),
          );
        }

      case NotificationRoute.marketplaceListing:
        final listingId = nav.params['listingId'] as String?;
        if (listingId != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ListingDetailPage(listingId: listingId),
            ),
          );
        }

      case NotificationRoute.marketplaceChat:
        final listingId = nav.params['listingId'] as String?;
        final otherUserId = nav.params['otherUserId'] as String?;
        if (listingId != null && otherUserId != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MarketplaceChatPage(
                listingId: listingId,
                otherUserId: otherUserId,
              ),
            ),
          );
        }

      case NotificationRoute.marketplaceSellerTransaction:
        final transactionId = nav.params['transactionId'] as String?;
        if (transactionId != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TransactionDetailPage(
                transactionId: transactionId,
              ),
            ),
          );
        }

      case NotificationRoute.marketplaceBuyerTransaction:
        final transactionId = nav.params['transactionId'] as String?;
        if (transactionId != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BuyerTransactionPage(
                transactionId: transactionId,
              ),
            ),
          );
        }
    }
  }
}
