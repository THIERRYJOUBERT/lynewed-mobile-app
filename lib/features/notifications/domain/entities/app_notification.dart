/// In-app notification entity for Clean Architecture.
///
/// Represents a notification received by the user, either in-app or push.
/// Each notification has a type, content, and optional navigation data.
library;

/// Types of notifications supported by the application.
///
/// These match the backend notification types (v23):
/// - Transactional: chatMessage, connectionRequest, connectionRequestAccepted,
///   wishlistAdd, videoIncoming
/// - Broadcast: wedPublished, replayPublished
enum NotificationType {
  /// New message in a private conversation
  chatMessage,

  /// Contact request from a professional to a bride
  connectionRequest,

  /// Contact request was accepted
  connectionRequestAccepted,

  /// Bride added professional to wishlist (Ultimate tier only)
  wishlistAdd,

  /// Incoming video call
  videoIncoming,

  /// New Wedding of the Week published
  wedPublished,

  /// New replay video available
  replayPublished,
}

/// Extension for NotificationType string conversion.
extension NotificationTypeExtension on NotificationType {
  /// Returns the string value of this notification type.
  String get value => name;

  /// Parses a string to a NotificationType, returns null if not found.
  static NotificationType? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return NotificationType.values.cast<NotificationType?>().firstWhere(
          (e) => e?.name == value,
          orElse: () => null,
        );
  }
}

/// Routes for notification navigation.
enum NotificationRoute {
  /// Navigate to chat room
  chat,

  /// Navigate to profile page
  profile,

  /// Navigate to video call screen
  videoCall,

  /// Navigate to Wedding of the Week
  weddingOfTheWeek,

  /// Navigate to replays
  replays,

  /// Navigate to notifications list
  notificationsList,
}

/// Navigation information for a notification.
class NotificationNavigation {
  /// The route to navigate to.
  final NotificationRoute route;

  /// Parameters for the navigation.
  final Map<String, dynamic> params;

  /// Creates a notification navigation.
  const NotificationNavigation({
    required this.route,
    this.params = const {},
  });
}

/// Represents an in-app notification.
///
/// This entity contains all information needed to display a notification
/// and handle user interaction (navigation).
class AppNotification {
  /// Unique identifier for the notification.
  final String id;

  /// Type of notification.
  final NotificationType type;

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

  /// Creates an AppNotification.
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.imageUrl,
    this.readAt,
  });

  /// Whether this notification has been read.
  bool get isRead => readAt != null;

  /// Navigation information for this notification, if applicable.
  ///
  /// Returns null if the notification data is missing required parameters.
  NotificationNavigation? get navigation {
    switch (type) {
      case NotificationType.chatMessage:
        final roomId = data['chat_room_id'] as String?;
        if (roomId == null) return null;
        return NotificationNavigation(
          route: NotificationRoute.chat,
          params: {'roomId': roomId},
        );

      case NotificationType.connectionRequest:
        final senderId = data['sender_id'] as String?;
        if (senderId == null) return null;
        return NotificationNavigation(
          route: NotificationRoute.profile,
          params: {'profileId': senderId},
        );

      case NotificationType.connectionRequestAccepted:
        final acceptedBy = data['accepted_by'] as String?;
        if (acceptedBy == null) return null;
        return NotificationNavigation(
          route: NotificationRoute.profile,
          params: {'profileId': acceptedBy},
        );

      case NotificationType.wishlistAdd:
        final brideId = data['bride_id'] as String?;
        if (brideId == null) return null;
        return NotificationNavigation(
          route: NotificationRoute.profile,
          params: {'profileId': brideId},
        );

      case NotificationType.videoIncoming:
        final sessionId = data['session_id'] as String?;
        final channelName = data['channel_name'] as String?;
        if (sessionId == null) return null;
        return NotificationNavigation(
          route: NotificationRoute.videoCall,
          params: {
            'sessionId': sessionId,
            if (channelName != null) 'channelName': channelName,
          },
        );

      case NotificationType.wedPublished:
        final weddingId = data['wedding_id'] as String?;
        return NotificationNavigation(
          route: NotificationRoute.weddingOfTheWeek,
          params: {
            if (weddingId != null) 'weddingId': weddingId,
          },
        );

      case NotificationType.replayPublished:
        final replayId = data['replay_id'] as String?;
        return NotificationNavigation(
          route: NotificationRoute.replays,
          params: {
            if (replayId != null) 'replayId': replayId,
          },
        );
    }
  }

  /// Creates an AppNotification from a JSON map.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String?;
    final parsedType = NotificationTypeExtension.fromString(typeString);

    DateTime createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    DateTime? readAt;
    final readAtStr = json['read_at'] as String?;
    if (readAtStr != null) {
      readAt = DateTime.tryParse(readAtStr);
    }

    return AppNotification(
      id: json['id'] as String? ?? '',
      type: parsedType ?? NotificationType.chatMessage,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  /// Converts this notification to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      'data': data,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toUtc().toIso8601String(),
    };
  }

  /// Creates a copy of this notification with the given fields replaced.
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() =>
      'AppNotification($id, ${type.value}, title: $title, read: $isRead)';
}
