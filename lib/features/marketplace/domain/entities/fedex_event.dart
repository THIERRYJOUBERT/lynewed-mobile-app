/// FedExEvent entity - A FedEx tracking event
///
/// Immutable data class representing a shipping tracking event.
library;

import 'package:flutter/foundation.dart';

/// Represents a FedEx tracking event.
///
/// Contains event type, description, location, timestamp, and raw payload.
@immutable
class FedExEvent {
  /// Creates a FedEx event.
  const FedExEvent({
    required this.id,
    this.transactionId,
    required this.trackingNumber,
    required this.eventType,
    this.eventDescription,
    this.eventCode,
    this.location,
    this.locationCity,
    this.locationCountry,
    this.eventTimestamp,
    this.rawPayload,
    required this.createdAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Transaction ID (nullable - linked later if needed).
  final String? transactionId;

  /// FedEx tracking number.
  final String trackingNumber;

  /// Event type (e.g., 'picked_up', 'delivered').
  final String eventType;

  /// Human-readable event description.
  final String? eventDescription;

  /// FedEx event code (e.g., 'OD', 'DL').
  final String? eventCode;

  /// Full location string.
  final String? location;

  /// Location city.
  final String? locationCity;

  /// Location country.
  final String? locationCountry;

  /// When the event actually happened (FedEx timestamp).
  final DateTime? eventTimestamp;

  /// Raw JSON payload from FedEx API.
  final Map<String, dynamic>? rawPayload;

  /// When we processed this event.
  final DateTime createdAt;

  /// Whether this is a delivery event.
  bool get isDelivered => eventType == 'delivered';

  /// Whether this is an exception/error event.
  bool get isException => eventType == 'exception';

  /// Creates a FedExEvent from Supabase JSON row.
  factory FedExEvent.fromJson(Map<String, dynamic> json) {
    return FedExEvent(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String?,
      trackingNumber: json['tracking_number'] as String,
      eventType: json['event_type'] as String,
      eventDescription: json['event_description'] as String?,
      eventCode: json['event_code'] as String?,
      location: json['location'] as String?,
      locationCity: json['location_city'] as String?,
      locationCountry: json['location_country'] as String?,
      eventTimestamp: json['event_timestamp'] != null
          ? DateTime.parse(json['event_timestamp'] as String)
          : null,
      rawPayload: json['raw_payload'] != null
          ? Map<String, dynamic>.from(json['raw_payload'] as Map)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'tracking_number': trackingNumber,
      'event_type': eventType,
      'event_description': eventDescription,
      'event_code': eventCode,
      'location': location,
      'location_city': locationCity,
      'location_country': locationCountry,
      'event_timestamp': eventTimestamp?.toIso8601String(),
      'raw_payload': rawPayload,
    };
  }

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FedExEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() =>
      'FedExEvent(id: $id, trackingNumber: $trackingNumber, '
      'eventType: $eventType)';

  /// Creates a copy with updated fields.
  FedExEvent copyWith({
    String? id,
    String? transactionId,
    String? trackingNumber,
    String? eventType,
    String? eventDescription,
    String? eventCode,
    String? location,
    String? locationCity,
    String? locationCountry,
    DateTime? eventTimestamp,
    Map<String, dynamic>? rawPayload,
    DateTime? createdAt,
  }) {
    return FedExEvent(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      eventType: eventType ?? this.eventType,
      eventDescription: eventDescription ?? this.eventDescription,
      eventCode: eventCode ?? this.eventCode,
      location: location ?? this.location,
      locationCity: locationCity ?? this.locationCity,
      locationCountry: locationCountry ?? this.locationCountry,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      rawPayload: rawPayload ?? this.rawPayload,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
