/// Représente les paramètres de notification d'un utilisateur pour un type donné.
class NotificationSetting {
  final String id;
  final String profileId;
  final String notificationType;
  final bool inAppEnabled;
  final bool pushEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationSetting({
    required this.id,
    required this.profileId,
    required this.notificationType,
    required this.inAppEnabled,
    required this.pushEnabled,
    this.createdAt,
    this.updatedAt,
  });

  NotificationSetting copyWith({
    String? id,
    String? profileId,
    String? notificationType,
    bool? inAppEnabled,
    bool? pushEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSetting(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      notificationType: notificationType ?? this.notificationType,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      notificationType: json['notification_type'] as String? ?? '',
      inAppEnabled: json['in_app_enabled'] as bool? ?? true,
      pushEnabled: json['push_enabled'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'notification_type': notificationType,
      'in_app_enabled': inAppEnabled,
      'push_enabled': pushEnabled,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() => 'NotificationSetting($notificationType: inApp=$inAppEnabled, push=$pushEnabled)';
}
