/// TrackingEvent entity - A shipping tracking event
///
/// Immutable data class representing a tracking event from
/// the fedex_events table, used to display shipment timeline.
library;

import 'package:flutter/foundation.dart';

/// Represents a FedEx tracking event.
///
/// Maps from the `fedex_events` table columns:
/// event_type, event_description, event_timestamp, location,
/// location_city, location_country.
@immutable
class TrackingEvent {
  /// Creates a tracking event.
  const TrackingEvent({
    required this.eventType,
    required this.description,
    required this.timestamp,
    this.location,
    this.city,
    this.country,
  });

  /// Event type (e.g., 'picked_up', 'in_transit', 'delivered', 'exception').
  final String eventType;

  /// Human-readable event description.
  final String description;

  /// When the event occurred.
  final DateTime timestamp;

  /// Full location string (e.g., 'Memphis, TN US').
  final String? location;

  /// City where the event occurred.
  final String? city;

  /// Country where the event occurred.
  final String? country;

  /// Whether this event indicates delivery completion.
  bool get isDelivered => eventType == 'delivered';

  /// Creates from fedex_events table row JSON.
  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      eventType: json['event_type'] as String,
      description: json['event_description'] as String,
      timestamp: DateTime.parse(json['event_timestamp'] as String),
      location: json['location'] as String?,
      city: json['location_city'] as String?,
      country: json['location_country'] as String?,
    );
  }

  /// Creates a copy with updated fields.
  TrackingEvent copyWith({
    String? eventType,
    String? description,
    DateTime? timestamp,
    String? location,
    String? city,
    String? country,
  }) {
    return TrackingEvent(
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  /// Equality based on all fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingEvent &&
          runtimeType == other.runtimeType &&
          eventType == other.eventType &&
          description == other.description &&
          timestamp == other.timestamp &&
          location == other.location &&
          city == other.city &&
          country == other.country;

  @override
  int get hashCode => Object.hash(
        eventType,
        description,
        timestamp,
        location,
        city,
        country,
      );

  @override
  String toString() =>
      'TrackingEvent(eventType: $eventType, '
      'description: $description)';
}
