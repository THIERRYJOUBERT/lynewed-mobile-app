import 'package:flutter/material.dart';

import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/core/design/design.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;

/// Page de notifications refactorisée - Design System v3.
/// 
/// Affiche la liste des notifications de l'utilisateur avec:
/// - Header avec bouton retour et action "Mark all read"
/// - Liste des notifications avec icône, titre, message et timestamp
/// - Tap sur notification → redirection appropriée
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  // Constantes de route (compatibilité avec l'ancienne page FlutterFlow)
  static const String routeName = 'NotificationsPage';
  static const String routePath = '/notificationsPage';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotificationStruct> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final notifications = await actions.getNotificationsAction();
      
      setState(() {
        // RPC retourne déjà trié par created_at DESC (plus récent en premier)
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await actions.markAllNotificationsAsRead();
    await _loadNotifications();
  }

  Future<void> _handleNotificationTap(AppNotificationStruct notification) async {
    // Marquer comme lu immédiatement dans l'UI
    if (notification.notificationId.isNotEmpty) {
      // Mise à jour optimiste de l'UI
      setState(() {
        final index = _notifications.indexWhere(
          (n) => n.notificationId == notification.notificationId,
        );
        if (index != -1) {
          _notifications[index] = AppNotificationStruct(
            notificationId: notification.notificationId,
            notificationType: notification.notificationType,
            title: notification.title,
            message: notification.message,
            isRead: true, // Marquer comme lu
            createdAt: notification.createdAt,
          );
        }
      });
      
      // Marquer comme lu en backend
      await actions.markNotificationAsRead(notification.notificationId);
    }

    // Récupérer le payload et rediriger
    if (notification.notificationType != null) {
      try {
        final response = await SupaFlow.client
            .from('notifications')
            .select('payload')
            .eq('id', notification.notificationId)
            .single();

        final payload = response['payload'] as Map<String, dynamic>?;

        // Créer les données pour la redirection (même si payload est null/vide)
        final dataForRedirection = <String, dynamic>{
          'type': notification.notificationType!.name,
          ...?payload, // Spread le payload s'il existe
        };

        if (mounted) {
          await actions.handleNotificationRedirection(context, dataForRedirection);
        }
      } catch (e) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildSubheader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _notifications.isEmpty
                          ? _buildEmptyState()
                          : _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.chevron_left,
              size: 28,
              color: LynewedColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildSubheader() {
    final hasUnread = _notifications.any((n) => !n.isRead);
    
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
              onTap: _markAllAsRead,
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
  }

  Widget _buildError() {
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
            TextButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
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

  Widget _buildNotificationsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onMarkAsRead: () => _markSingleAsRead(notification),
        );
      },
    );
  }

  /// Marquer une seule notification comme lue (sans navigation)
  Future<void> _markSingleAsRead(AppNotificationStruct notification) async {
    if (notification.isRead || notification.notificationId.isEmpty) return;
    
    // Mise à jour optimiste de l'UI
    setState(() {
      final index = _notifications.indexWhere(
        (n) => n.notificationId == notification.notificationId,
      );
      if (index != -1) {
        _notifications[index] = AppNotificationStruct(
          notificationId: notification.notificationId,
          notificationType: notification.notificationType,
          title: notification.title,
          message: notification.message,
          isRead: true,
          createdAt: notification.createdAt,
        );
      }
    });
    
    // Marquer comme lu en backend
    await actions.markNotificationAsRead(notification.notificationId);
  }
}

/// Tile pour afficher une notification individuelle.
/// 
/// - Tap sur la tile → navigation + marquer comme lu
/// - Tap sur le badge "New" → marquer comme lu uniquement (sans navigation)
class _NotificationTile extends StatelessWidget {
  final AppNotificationStruct notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title.isNotEmpty 
                              ? notification.title 
                              : _getDefaultTitle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildReadBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message.isNotEmpty 
                        ? notification.message 
                        : 'Tap to view details',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (notification.createdAt != null)
                    Text(
                      _formatTimestamp(notification.createdAt!),
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: LynewedColors.gray100,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconData = _getIconForType();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: notification.isRead 
            ? LynewedColors.gray200 
            : LynewedColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 18,
        color: notification.isRead 
            ? LynewedColors.textSecondary 
            : LynewedColors.textOnPrimary,
      ),
    );
  }

  Widget _buildReadBadge() {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead 
            ? LynewedColors.gray200 
            : LynewedColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        notification.isRead ? 'Read' : 'New',
        style: LynewedTextStyles.labelSmall.copyWith(
          color: notification.isRead 
              ? LynewedColors.textSecondary 
              : LynewedColors.textOnPrimary,
        ),
      ),
    );
    
    // Si non lu, rendre le badge cliquable pour marquer comme lu sans naviguer
    if (!notification.isRead) {
      return GestureDetector(
        onTap: onMarkAsRead,
        behavior: HitTestBehavior.opaque,
        child: badge,
      );
    }
    
    return badge;
  }

  IconData _getIconForType() {
    switch (notification.notificationType) {
      case NotificationType.chatMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.connectionRequest:
        return Icons.person_add_outlined;
      case NotificationType.connectionRequestAccepted:
        return Icons.check_circle_outline;
      case NotificationType.wishlistAdd:
        return Icons.favorite_outline;
      case NotificationType.videoIncoming:
        return Icons.videocam_outlined;
      case NotificationType.wedPublished:
        return Icons.celebration_outlined;
      case NotificationType.replayPublished:
        return Icons.play_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getDefaultTitle() {
    switch (notification.notificationType) {
      case NotificationType.chatMessage:
        return 'New message';
      case NotificationType.connectionRequest:
        return 'Contact request';
      case NotificationType.connectionRequestAccepted:
        return 'Request accepted';
      case NotificationType.wishlistAdd:
        return 'Added to wishlist';
      case NotificationType.videoIncoming:
        return 'Video call';
      case NotificationType.wedPublished:
        return 'Wedding of the Week';
      case NotificationType.replayPublished:
        return 'New Replay';
      default:
        return 'Notification';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return dateTimeFormat('MMMd', timestamp);
    }
  }
}
