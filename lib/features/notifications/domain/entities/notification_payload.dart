/// Push notification payload entity for Clean Architecture.
///
/// Represents the data received from a push notification (FCM).
/// Can be converted to an AppNotification for display.
library;

import 'app_notification.dart';

/// Represents the payload of a push notification.
///
/// This is the raw data received from Firebase Cloud Messaging (FCM).
/// It contains the notification type, content, and any additional data
/// needed for navigation.
class NotificationPayload {
  /// Type of notification.
  final NotificationType type;

  /// Title of the notification.
  final String title;

  /// Body/content of the notification.
  final String body;

  /// Optional image URL for the notification.
  final String? imageUrl;

  /// Additional data payload from the push notification.
  /// Contains navigation parameters and other metadata.
  final Map<String, dynamic> data;

  /// Creates a NotificationPayload.
  const NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data = const {},
  });

  /// Navigation information for this payload.
  ///
  /// Delegates to AppNotification's navigation logic.
  NotificationNavigation? get navigation {
    // Create a temporary AppNotification to get navigation
    // This ensures consistent navigation logic across both classes
    return AppNotification(
      id: '',
      type: type,
      title: title,
      body: body,
      data: data,
      createdAt: DateTime.now(),
    ).navigation;
  }

  /// Creates a NotificationPayload from a JSON map.
  ///
  /// The JSON typically comes from an FCM push notification.
  /// Standard fields (type, title, body, image_url) are extracted,
  /// and all other fields are stored in [data] for navigation use.
  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final parsedType = NotificationTypeExtension.fromString(typeString);

    // Extract standard fields
    final title = json['title'] as String? ?? '';
    final body = json['body'] as String? ?? '';
    final imageUrl = json['image_url'] as String?;

    // All other fields go to data
    final data = <String, dynamic>{};
    const standardFields = {'type', 'title', 'body', 'image_url'};

    for (final entry in json.entries) {
      if (!standardFields.contains(entry.key)) {
        data[entry.key] = entry.value;
      }
    }

    return NotificationPayload(
      type: parsedType ?? NotificationType.chatMessage,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
    );
  }

  /// Converts this payload to a JSON map.
  ///
  /// Flattens the data map into the top level, as expected by FCM.
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'title': title,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      ...data,
    };
  }

  /// Converts this payload to an AppNotification.
  ///
  /// If [id] is not provided, uses notification_id from data,
  /// or generates a unique ID based on timestamp.
  AppNotification toAppNotification({String? id}) {
    final notificationId = id ??
        data['notification_id'] as String? ??
        _generateId();

    return AppNotification(
      id: notificationId,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      createdAt: DateTime.now(),
      readAt: null, // New notifications are unread
    );
  }

  /// Generates a unique ID for the notification.
  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'push_$timestamp';
  }

  @override
  String toString() =>
      'NotificationPayload(${type.value}, title: $title)';
}
