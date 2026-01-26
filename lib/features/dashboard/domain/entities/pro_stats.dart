/// Professional dashboard statistics entity
///
/// Immutable data class representing professional dashboard metrics.
/// Used to display key performance indicators on the dashboard.
library;

import 'package:flutter/foundation.dart';

/// Professional dashboard statistics
///
/// Contains metrics for:
/// - Profile visibility (views, saves)
/// - Engagement (messages, alerts)
/// - Performance (response rate)
@immutable
class ProStats {
  const ProStats({
    required this.profileViews,
    required this.savedCount,
    required this.messageCount,
    required this.alertCount,
    this.responseRate,
    this.lastUpdated,
  });

  /// Empty stats with all zeroes
  const ProStats.empty()
      : profileViews = 0,
        savedCount = 0,
        messageCount = 0,
        alertCount = 0,
        responseRate = null,
        lastUpdated = null;

  /// Number of times the profile was viewed
  final int profileViews;

  /// Number of times the profile was saved/wishlisted
  final int savedCount;

  /// Number of messages received
  final int messageCount;

  /// Number of active alerts created
  final int alertCount;

  /// Response rate (0.0 to 1.0)
  final double? responseRate;

  /// When stats were last updated
  final DateTime? lastUpdated;

  /// Total engagement (views + saves + messages)
  int get totalEngagement => profileViews + savedCount + messageCount;

  /// Creates a copy with updated fields
  ProStats copyWith({
    int? profileViews,
    int? savedCount,
    int? messageCount,
    int? alertCount,
    double? responseRate,
    DateTime? lastUpdated,
  }) {
    return ProStats(
      profileViews: profileViews ?? this.profileViews,
      savedCount: savedCount ?? this.savedCount,
      messageCount: messageCount ?? this.messageCount,
      alertCount: alertCount ?? this.alertCount,
      responseRate: responseRate ?? this.responseRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProStats &&
        other.profileViews == profileViews &&
        other.savedCount == savedCount &&
        other.messageCount == messageCount &&
        other.alertCount == alertCount &&
        other.responseRate == responseRate &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(
        profileViews,
        savedCount,
        messageCount,
        alertCount,
        responseRate,
        lastUpdated,
      );

  @override
  String toString() =>
      'ProStats(views: $profileViews, saved: $savedCount, messages: $messageCount, alerts: $alertCount)';
}
