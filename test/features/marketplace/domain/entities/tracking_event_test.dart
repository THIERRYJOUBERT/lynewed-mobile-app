/// Tests for TrackingEvent entity.
///
/// Verifies creation, fromJson, isDelivered getter, copyWith, and equality.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';

void main() {
  group('TrackingEvent', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create TrackingEvent with all fields', () {
        final event = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4, 10, 0),
          location: 'Memphis, TN US',
          city: 'Memphis',
          country: 'US',
        );

        expect(event.eventType, 'in_transit');
        expect(event.description, 'In transit');
        expect(event.timestamp, DateTime(2026, 2, 4, 10, 0));
        expect(event.location, 'Memphis, TN US');
        expect(event.city, 'Memphis');
        expect(event.country, 'US');
      });

      test('should create TrackingEvent with only required fields', () {
        final event = TrackingEvent(
          eventType: 'picked_up',
          description: 'Package picked up',
          timestamp: DateTime(2026, 2, 3, 14, 30),
        );

        expect(event.location, isNull);
        expect(event.city, isNull);
        expect(event.country, isNull);
      });
    });

    // ==============================================================
    // IS_DELIVERED GETTER
    // ==============================================================

    group('isDelivered', () {
      test('should return true when eventType is delivered', () {
        final event = TrackingEvent(
          eventType: 'delivered',
          description: 'Delivered',
          timestamp: DateTime(2026, 2, 8),
        );

        expect(event.isDelivered, true);
      });

      test('should return false when eventType is not delivered', () {
        final event = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 5),
        );

        expect(event.isDelivered, false);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should deserialize from fedex_events table row', () {
        final json = {
          'event_type': 'in_transit',
          'event_description': 'In transit',
          'event_timestamp': '2026-02-04T10:00:00Z',
          'location': 'Memphis, TN US',
          'location_city': 'Memphis',
          'location_country': 'US',
        };

        final event = TrackingEvent.fromJson(json);

        expect(event.eventType, 'in_transit');
        expect(event.description, 'In transit');
        expect(event.timestamp, DateTime.parse('2026-02-04T10:00:00Z'));
        expect(event.location, 'Memphis, TN US');
        expect(event.city, 'Memphis');
        expect(event.country, 'US');
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'event_type': 'picked_up',
          'event_description': 'Picked up',
          'event_timestamp': '2026-02-03T14:30:00Z',
        };

        final event = TrackingEvent.fromJson(json);

        expect(event.eventType, 'picked_up');
        expect(event.location, isNull);
        expect(event.city, isNull);
        expect(event.country, isNull);
      });
    });

    // ==============================================================
    // COPYWIDTH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final event = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4),
          location: 'Memphis, TN',
        );

        final copy = event.copyWith(
          eventType: 'delivered',
          description: 'Delivered',
        );

        expect(copy.eventType, 'delivered');
        expect(copy.description, 'Delivered');
        expect(copy.location, 'Memphis, TN');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields match', () {
        final event1 = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4, 10, 0),
          location: 'Memphis, TN',
        );

        final event2 = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4, 10, 0),
          location: 'Memphis, TN',
        );

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when eventType differs', () {
        final event1 = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4),
        );

        final event2 = TrackingEvent(
          eventType: 'delivered',
          description: 'Delivered',
          timestamp: DateTime(2026, 2, 4),
        );

        expect(event1, isNot(equals(event2)));
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        final event = TrackingEvent(
          eventType: 'in_transit',
          description: 'In transit',
          timestamp: DateTime(2026, 2, 4),
        );

        final str = event.toString();

        expect(str, contains('in_transit'));
      });
    });
  });
}
