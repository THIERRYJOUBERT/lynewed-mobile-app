/// Wedding Event entity for My Wedding Suite
///
/// Represents an event/task in the wedding agenda.
/// Simple todo list with dates and states.
library;

import 'package:flutter/foundation.dart';

/// Event status enum
enum EventStatus {
  pending,
  done,
  cancelled,
}

/// Wedding Event entity
@immutable
class WeddingEvent {
  const WeddingEvent({
    required this.id,
    required this.weddingId,
    required this.title,
    required this.eventDate,
    this.description,
    this.eventEndDate,
    this.location,
    this.linkedProId,
    this.linkedProName,
    this.isPublic = false,
    this.status = EventStatus.pending,
    this.reminderMinutes = const [1440, 60],
    this.createdAt,
  });

  /// UUID of the event
  final String id;

  /// UUID of the wedding
  final String weddingId;

  /// Event title
  final String title;

  /// Event description
  final String? description;

  /// Event date/time
  final DateTime eventDate;

  /// Event end date (optional)
  final DateTime? eventEndDate;

  /// Event location
  final String? location;

  /// Linked professional ID (optional)
  final String? linkedProId;

  /// Linked professional name (for display)
  final String? linkedProName;

  /// Is visible to wedding team pros
  final bool isPublic;

  /// Event status
  final EventStatus status;

  /// Reminder times in minutes before event
  final List<int> reminderMinutes;

  /// Creation date
  final DateTime? createdAt;

  /// Check if event is completed
  bool get isDone => status == EventStatus.done;

  /// Check if event is cancelled
  bool get isCancelled => status == EventStatus.cancelled;

  /// Check if event is in the past
  bool get isPast => DateTime.now().isAfter(eventDate);

  /// Factory from Supabase JSON
  factory WeddingEvent.fromJson(Map<String, dynamic> json) {
    return WeddingEvent(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventEndDate: json['event_end_date'] != null 
          ? DateTime.parse(json['event_end_date'] as String) 
          : null,
      location: json['location'] as String?,
      linkedProId: json['linked_pro_id'] as String?,
      linkedProName: json['linked_pro_name'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      status: _parseStatus(json['status'] as String?),
      reminderMinutes: (json['reminder_minutes'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [1440, 60],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  static EventStatus _parseStatus(String? value) {
    switch (value) {
      case 'done':
        return EventStatus.done;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding_id': weddingId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'event_end_date': eventEndDate?.toIso8601String(),
      'location': location,
      'linked_pro_id': linkedProId,
      'is_public': isPublic,
      'status': status.name,
      'reminder_minutes': reminderMinutes,
    };
  }

  WeddingEvent copyWith({
    String? id,
    String? weddingId,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? eventEndDate,
    String? location,
    String? linkedProId,
    String? linkedProName,
    bool? isPublic,
    EventStatus? status,
    List<int>? reminderMinutes,
    DateTime? createdAt,
  }) {
    return WeddingEvent(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
      location: location ?? this.location,
      linkedProId: linkedProId ?? this.linkedProId,
      linkedProName: linkedProName ?? this.linkedProName,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WeddingEvent($id, $title, $eventDate)';
}
