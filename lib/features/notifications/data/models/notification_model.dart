/// Notification data model for Clean Architecture.
///
/// This model handles JSON serialization and mapping to domain entities.
/// It represents notifications from Supabase with all required fields.
library;

import '../../domain/entities/app_notification.dart';

/// Data model for notifications from Supabase.
///
/// This class handles:
/// - JSON parsing from Supabase RPC response
/// - Conversion to [AppNotification] entity
class NotificationModel {
  /// Unique identifier for the notification.
  final String id;

  /// Type of notification as string (e.g., 'chatMessage', 'connectionRequest').
  final String type;

  /// Title of the notification.
  final String title;

  /// Body/content of the notification.
  final String body;

  /// Optional image URL for the notification.
  final String? imageUrl;

  /// Additional data payload for navigation.
  final Map<String, dynamic> data;

  /// When the notification was created.
  final DateTime createdAt;

  /// When the notification was read, null if unread.
  final DateTime? readAt;

  /// Creates a NotificationModel.
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.imageUrl,
    this.readAt,
  });

  /// Creates a NotificationModel from Supabase JSON response.
  ///
  /// The JSON format matches the `get_formatted_notifications` RPC response:
  /// - notificationId -> id
  /// - notificationType -> type
  /// - message -> body
  /// - createdAt -> createdAt
  /// - isRead -> determines readAt
  /// - referenceId, senderAvatarUrl -> data
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse createdAt
    DateTime createdAt;
    final createdAtStr = json['createdAt'] as String? ?? json['created_at'] as String?;
    if (createdAtStr != null) {
      createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Parse readAt - check both isRead boolean and read_at timestamp
    DateTime? readAt;
    final isRead = json['isRead'] as bool? ?? json['is_read'] as bool? ?? false;
    final readAtStr = json['read_at'] as String?;
    if (readAtStr != null) {
      readAt = DateTime.tryParse(readAtStr);
    } else if (isRead) {
      // If isRead is true but no timestamp, use createdAt as read time
      readAt = createdAt;
    }

    // Build data map from various fields
    final Map<String, dynamic> data = {};
    if (json['referenceId'] != null) {
      // Parse referenceId based on notification type to correct key
      final type = json['notificationType'] as String? ?? json['type'] as String? ?? '';
      switch (type.toLowerCase()) {
        case 'chatmessage':
          data['chat_room_id'] = json['referenceId'];
        case 'connectionrequest':
          data['sender_id'] = json['referenceId'];
        case 'connectionrequestaccepted':
          data['accepted_by'] = json['referenceId'];
        case 'wishlistadd':
          data['bride_id'] = json['referenceId'];
        case 'videoincoming':
          data['session_id'] = json['referenceId'];
        case 'wedpublished':
          data['wedding_id'] = json['referenceId'];
        case 'replaypublished':
          data['replay_id'] = json['referenceId'];
        default:
          data['reference_id'] = json['referenceId'];
      }
    }
    if (json['data'] != null && json['data'] is Map) {
      data.addAll(json['data'] as Map<String, dynamic>);
    }

    return NotificationModel(
      id: json['notificationId'] as String? ?? json['id'] as String? ?? '',
      type: json['notificationType'] as String? ?? json['type'] as String? ?? 'chatMessage',
      title: json['title'] as String? ?? 'Notification',
      body: json['message'] as String? ?? json['body'] as String? ?? '',
      imageUrl: json['senderAvatarUrl'] as String? ?? json['image_url'] as String?,
      data: data,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      'data': data,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toUtc().toIso8601String(),
    };
  }

  /// Converts this model to an [AppNotification] entity.
  AppNotification toEntity() {
    // Parse notification type from string
    final notificationType = _parseNotificationType(type);

    return AppNotification(
      id: id,
      type: notificationType,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  /// Parses notification type string to enum.
  static NotificationType _parseNotificationType(String typeString) {
    final lowerType = typeString.toLowerCase();
    for (final notifType in NotificationType.values) {
      if (notifType.name.toLowerCase() == lowerType) {
        return notifType;
      }
    }
    // Default fallback
    return NotificationType.chatMessage;
  }

  @override
  String toString() =>
      'NotificationModel($id, $type, title: $title, read: ${readAt != null})';
}
