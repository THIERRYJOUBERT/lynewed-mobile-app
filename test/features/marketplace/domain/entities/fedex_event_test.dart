import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/fedex_event.dart';

void main() {
  // Shared test data
  final now = DateTime(2026, 2, 4, 10, 0, 0);
  final eventTime = DateTime(2026, 2, 4, 8, 30, 0);
  final rawPayload = {
    'scanEvents': [
      {
        'eventType': 'PU',
        'eventDescription': 'Picked up',
        'scanLocation': {
          'city': 'CHICAGO',
          'stateOrProvinceCode': 'IL',
          'countryCode': 'US',
        },
      },
    ],
  };

  FedExEvent createEvent({
    String id = 'event-123',
    String? transactionId,
    String trackingNumber = '123456789012',
    String eventType = 'picked_up',
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
      id: id,
      transactionId: transactionId,
      trackingNumber: trackingNumber,
      eventType: eventType,
      eventDescription: eventDescription,
      eventCode: eventCode,
      location: location,
      locationCity: locationCity,
      locationCountry: locationCountry,
      eventTimestamp: eventTimestamp,
      rawPayload: rawPayload,
      createdAt: createdAt ?? now,
    );
  }

  group('FedExEvent', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create with required fields only (optional fields null)',
          () {
        final event = createEvent();

        expect(event.id, 'event-123');
        expect(event.trackingNumber, '123456789012');
        expect(event.eventType, 'picked_up');
        expect(event.createdAt, now);
        expect(event.transactionId, isNull);
        expect(event.eventDescription, isNull);
        expect(event.eventCode, isNull);
        expect(event.location, isNull);
        expect(event.locationCity, isNull);
        expect(event.locationCountry, isNull);
        expect(event.eventTimestamp, isNull);
        expect(event.rawPayload, isNull);
      });

      test('should create with all optional fields', () {
        final event = createEvent(
          transactionId: 'txn-456',
          eventDescription: 'Package picked up by FedEx',
          eventCode: 'PU',
          location: 'CHICAGO IL US',
          locationCity: 'CHICAGO',
          locationCountry: 'US',
          eventTimestamp: eventTime,
          rawPayload: rawPayload,
        );

        expect(event.transactionId, 'txn-456');
        expect(event.eventDescription, 'Package picked up by FedEx');
        expect(event.eventCode, 'PU');
        expect(event.location, 'CHICAGO IL US');
        expect(event.locationCity, 'CHICAGO');
        expect(event.locationCountry, 'US');
        expect(event.eventTimestamp, eventTime);
        expect(event.rawPayload, rawPayload);
      });

      test('should be immutable', () {
        final event = createEvent();

        // Verify fields are final (compile-time check)
        // Cannot reassign: event.eventType = 'delivered'; would not compile
        expect(event.eventType, 'picked_up');
      });
    });

    // ==============================================================
    // EVENT TYPE HELPERS
    // ==============================================================

    group('event type helpers', () {
      test('isDelivered should be true when eventType is delivered', () {
        final event = createEvent(eventType: 'delivered');
        expect(event.isDelivered, isTrue);
      });

      test('isDelivered should be false when eventType is not delivered', () {
        final event = createEvent(eventType: 'in_transit');
        expect(event.isDelivered, isFalse);
      });

      test('isException should be true when eventType is exception', () {
        final event = createEvent(eventType: 'exception');
        expect(event.isException, isTrue);
      });

      test('isException should be false when eventType is not exception', () {
        final event = createEvent(eventType: 'picked_up');
        expect(event.isException, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id matches', () {
        final event1 = createEvent(id: 'same-id', eventType: 'picked_up');
        final event2 = createEvent(id: 'same-id', eventType: 'delivered');

        expect(event1, equals(event2));
      });

      test('hashCode should be consistent with equality', () {
        final event1 = createEvent(id: 'same-id', eventType: 'picked_up');
        final event2 = createEvent(id: 'same-id', eventType: 'delivered');

        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when id differs', () {
        final event1 = createEvent(id: 'event-111');
        final event2 = createEvent(id: 'event-222');

        expect(event1, isNot(equals(event2)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated transactionId', () {
        final event = createEvent();
        final updated = event.copyWith(transactionId: 'txn-new');

        expect(updated.transactionId, 'txn-new');
        expect(updated.id, event.id);
        expect(updated.trackingNumber, event.trackingNumber);
        expect(updated.eventType, event.eventType);
      });

      test('should preserve all fields when no params provided', () {
        final event = createEvent(
          transactionId: 'txn-456',
          eventDescription: 'Picked up',
          eventCode: 'PU',
          location: 'CHICAGO IL US',
          locationCity: 'CHICAGO',
          locationCountry: 'US',
          eventTimestamp: eventTime,
          rawPayload: rawPayload,
        );
        final copied = event.copyWith();

        expect(copied.id, event.id);
        expect(copied.transactionId, event.transactionId);
        expect(copied.trackingNumber, event.trackingNumber);
        expect(copied.eventType, event.eventType);
        expect(copied.eventDescription, event.eventDescription);
        expect(copied.eventCode, event.eventCode);
        expect(copied.location, event.location);
        expect(copied.locationCity, event.locationCity);
        expect(copied.locationCountry, event.locationCountry);
        expect(copied.eventTimestamp, event.eventTimestamp);
        expect(copied.rawPayload, event.rawPayload);
        expect(copied.createdAt, event.createdAt);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should contain key fields', () {
        final event = createEvent(
          id: 'evt-abc',
          trackingNumber: '794644790138',
          eventType: 'in_transit',
        );

        final str = event.toString();

        expect(str, contains('evt-abc'));
        expect(str, contains('794644790138'));
        expect(str, contains('in_transit'));
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse valid Supabase row with all fields', () {
        final json = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'transaction_id': '660e8400-e29b-41d4-a716-446655440001',
          'tracking_number': '794644790138',
          'event_type': 'out_for_delivery',
          'event_description': 'On FedEx vehicle for delivery',
          'event_code': 'OD',
          'location': 'CHICAGO IL US',
          'location_city': 'CHICAGO',
          'location_country': 'US',
          'event_timestamp': '2026-02-04T10:30:00.000Z',
          'raw_payload': {
            'scanEvents': [
              {'eventType': 'OD', 'eventDescription': 'Out for delivery'},
            ],
          },
          'created_at': '2026-02-04T12:00:00.000Z',
        };

        final event = FedExEvent.fromJson(json);

        expect(event.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(event.transactionId, '660e8400-e29b-41d4-a716-446655440001');
        expect(event.trackingNumber, '794644790138');
        expect(event.eventType, 'out_for_delivery');
        expect(event.eventDescription, 'On FedEx vehicle for delivery');
        expect(event.eventCode, 'OD');
        expect(event.location, 'CHICAGO IL US');
        expect(event.locationCity, 'CHICAGO');
        expect(event.locationCountry, 'US');
        expect(
          event.eventTimestamp,
          DateTime.parse('2026-02-04T10:30:00.000Z'),
        );
        expect(event.rawPayload, isNotNull);
        expect(event.rawPayload!['scanEvents'], isA<List>());
        expect(event.createdAt, DateTime.parse('2026-02-04T12:00:00.000Z'));
      });

      test('should parse with minimal fields (nullables as null)', () {
        final json = {
          'id': 'evt-minimal',
          'transaction_id': null,
          'tracking_number': '123456789012',
          'event_type': 'label_created',
          'event_description': null,
          'event_code': null,
          'location': null,
          'location_city': null,
          'location_country': null,
          'event_timestamp': null,
          'raw_payload': null,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final event = FedExEvent.fromJson(json);

        expect(event.id, 'evt-minimal');
        expect(event.transactionId, isNull);
        expect(event.trackingNumber, '123456789012');
        expect(event.eventType, 'label_created');
        expect(event.eventDescription, isNull);
        expect(event.eventCode, isNull);
        expect(event.location, isNull);
        expect(event.locationCity, isNull);
        expect(event.locationCountry, isNull);
        expect(event.eventTimestamp, isNull);
        expect(event.rawPayload, isNull);
      });

      test('should map snake_case to camelCase correctly', () {
        final json = {
          'id': 'evt-snake',
          'transaction_id': 'txn-abc',
          'tracking_number': '999888777',
          'event_type': 'in_transit',
          'event_description': 'In transit',
          'event_code': 'IT',
          'location': 'PARIS FR',
          'location_city': 'PARIS',
          'location_country': 'FR',
          'event_timestamp': '2026-02-04T14:00:00.000Z',
          'raw_payload': {'key': 'value'},
          'created_at': '2026-02-04T15:00:00.000Z',
        };

        final event = FedExEvent.fromJson(json);

        // Verify snake_case keys mapped to camelCase properties
        expect(event.transactionId, 'txn-abc');
        expect(event.trackingNumber, '999888777');
        expect(event.eventType, 'in_transit');
        expect(event.eventDescription, 'In transit');
        expect(event.eventCode, 'IT');
        expect(event.locationCity, 'PARIS');
        expect(event.locationCountry, 'FR');
        expect(event.eventTimestamp, isNotNull);
      });

      test('should parse rawPayload JSONB correctly', () {
        final complexPayload = {
          'transactionId': '624deea6-b709-470c-8c39-4b5511281492',
          'output': {
            'completeTrackResults': [
              {
                'trackingNumber': '123456789012',
                'trackResults': [
                  {
                    'latestStatusDetail': {
                      'scanEventType': 'OD',
                      'statusCode': 'OD',
                    },
                    'scanEvents': [
                      {
                        'eventType': 'OD',
                        'scanLocation': {'city': 'CHICAGO', 'countryCode': 'US'},
                      },
                    ],
                  },
                ],
              },
            ],
          },
        };

        final json = {
          'id': 'evt-payload',
          'transaction_id': null,
          'tracking_number': '123456789012',
          'event_type': 'out_for_delivery',
          'event_description': null,
          'event_code': null,
          'location': null,
          'location_city': null,
          'location_country': null,
          'event_timestamp': null,
          'raw_payload': complexPayload,
          'created_at': '2026-02-04T10:00:00.000Z',
        };

        final event = FedExEvent.fromJson(json);

        expect(event.rawPayload, isNotNull);
        expect(event.rawPayload!['transactionId'],
            '624deea6-b709-470c-8c39-4b5511281492');
        expect(event.rawPayload!['output'], isA<Map>());

        final output = event.rawPayload!['output'] as Map;
        final results = output['completeTrackResults'] as List;
        expect(results, hasLength(1));

        final trackResult = results[0] as Map;
        expect(trackResult['trackingNumber'], '123456789012');
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should exclude id and created_at', () {
        final event = createEvent();
        final json = event.toJson();

        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_at'), isFalse);
      });

      test('should include all insert-relevant fields', () {
        final event = createEvent(
          transactionId: 'txn-456',
          eventDescription: 'Picked up',
          eventCode: 'PU',
          location: 'CHICAGO IL US',
          locationCity: 'CHICAGO',
          locationCountry: 'US',
          eventTimestamp: eventTime,
          rawPayload: rawPayload,
        );
        final json = event.toJson();

        expect(json['transaction_id'], 'txn-456');
        expect(json['tracking_number'], '123456789012');
        expect(json['event_type'], 'picked_up');
        expect(json['event_description'], 'Picked up');
        expect(json['event_code'], 'PU');
        expect(json['location'], 'CHICAGO IL US');
        expect(json['location_city'], 'CHICAGO');
        expect(json['location_country'], 'US');
        expect(json['event_timestamp'], isA<String>());
        expect(json['raw_payload'], rawPayload);
      });

      test('should serialize eventTimestamp to ISO8601', () {
        final ts = DateTime(2026, 2, 4, 10, 30, 0);
        final event = createEvent(eventTimestamp: ts);
        final json = event.toJson();

        expect(json['event_timestamp'], ts.toIso8601String());
      });

      test('should handle null optional fields', () {
        final event = createEvent();
        final json = event.toJson();

        expect(json['transaction_id'], isNull);
        expect(json['event_description'], isNull);
        expect(json['event_code'], isNull);
        expect(json['location'], isNull);
        expect(json['location_city'], isNull);
        expect(json['location_country'], isNull);
        expect(json['event_timestamp'], isNull);
        expect(json['raw_payload'], isNull);
      });
    });

    // ==============================================================
    // ROUNDTRIP TEST
    // ==============================================================

    group('roundtrip', () {
      test('fromJson -> toJson should produce consistent data', () {
        final originalJson = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'transaction_id': '660e8400-e29b-41d4-a716-446655440001',
          'tracking_number': '794644790138',
          'event_type': 'delivered',
          'event_description': 'Delivered to front door',
          'event_code': 'DL',
          'location': 'LYON FR',
          'location_city': 'LYON',
          'location_country': 'FR',
          'event_timestamp': '2026-02-04T10:30:00.000',
          'raw_payload': {'status': 'DL', 'detail': 'Delivered'},
          'created_at': '2026-02-04T12:00:00.000Z',
        };

        final event = FedExEvent.fromJson(originalJson);
        final outputJson = event.toJson();

        // toJson should NOT contain id, created_at (auto-generated)
        expect(outputJson.containsKey('id'), isFalse);
        expect(outputJson.containsKey('created_at'), isFalse);

        // All insert-relevant fields should match
        expect(outputJson['transaction_id'], originalJson['transaction_id']);
        expect(outputJson['tracking_number'], originalJson['tracking_number']);
        expect(outputJson['event_type'], originalJson['event_type']);
        expect(
            outputJson['event_description'], originalJson['event_description']);
        expect(outputJson['event_code'], originalJson['event_code']);
        expect(outputJson['location'], originalJson['location']);
        expect(outputJson['location_city'], originalJson['location_city']);
        expect(outputJson['location_country'], originalJson['location_country']);
        expect(outputJson['raw_payload'], originalJson['raw_payload']);

        // eventTimestamp is serialized back to ISO8601
        expect(outputJson['event_timestamp'], isA<String>());

        // Verify we can parse it back
        final reparsedTimestamp =
            DateTime.parse(outputJson['event_timestamp'] as String);
        expect(reparsedTimestamp, event.eventTimestamp);
      });
    });
  });
}
