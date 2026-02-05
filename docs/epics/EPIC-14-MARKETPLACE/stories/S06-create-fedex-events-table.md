# Story S06: Create fedex_events table

## Description
En tant que developpeur backend, je veux creer la table fedex_events dans Supabase, afin de logger tous les evenements de tracking FedEx avec audit complet.

## Criteres d'Acceptance (Gherkin)

- [x] Given the marketplace_transactions table exists When the migration create_fedex_events is applied Then table fedex_events should exist with columns for tracking_number, event_type, event_description, location, event_timestamp, raw_payload
- [x] Given a transaction with tracking When FedEx reports picked_up, in_transit, out_for_delivery, delivered Then each event should be logged with full details And raw webhook payload should be preserved as JSONB
- [x] Given FedEx events for a transaction When the buyer queries Then they should see events When the seller queries Then they should see events When other user queries Then access should be denied (RLS)
- [x] Given an event with location details Then location_city and location_country should be extracted from the payload
- [x] Given an insert attempt with event_type 'invalid_event' Then the insert should fail (CHECK constraint on event_type)
- [x] Given transaction_id is NULL but tracking_number is provided When inserting event Then insert should succeed (transaction_id is nullable for FedEx webhook events not yet linked)

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260204100006_create_fedex_events.sql` - Migration principale
- `lib/features/marketplace/domain/entities/fedex_event.dart` - Entity Dart
- `test/features/marketplace/domain/entities/fedex_event_test.dart` - Tests entity

### A Modifier
- Aucun

## SQL Migration Complet

```sql
-- Migration: 20260204100006_create_fedex_events.sql

-- Create the fedex_events table
CREATE TABLE IF NOT EXISTS fedex_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID REFERENCES marketplace_transactions(id) ON DELETE CASCADE,
  tracking_number VARCHAR(255) NOT NULL,

  -- Event details
  event_type VARCHAR(100) NOT NULL
    CHECK (event_type IN (
      'label_created',
      'picked_up',
      'in_transit',
      'out_for_delivery',
      'delivered',
      'exception',
      'returned',
      'delayed',
      'attempted_delivery'
    )),
  event_description TEXT,
  event_code VARCHAR(50),
  location TEXT,
  location_city VARCHAR(255),
  location_country VARCHAR(100),

  -- FedEx timestamp (when the event actually happened)
  event_timestamp TIMESTAMP,

  -- Raw payload for debugging (full JSON from FedEx API)
  raw_payload JSONB,

  -- When we processed this event
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_fedex_events_transaction ON fedex_events(transaction_id, event_timestamp DESC);
CREATE INDEX idx_fedex_events_tracking ON fedex_events(tracking_number, event_timestamp DESC);
CREATE INDEX idx_fedex_events_type ON fedex_events(event_type, created_at DESC);

-- Enable RLS
ALTER TABLE fedex_events ENABLE ROW LEVEL SECURITY;

-- Grant basic access (SELECT only for authenticated, INSERT via service_role)
GRANT SELECT ON fedex_events TO authenticated;
-- Note: INSERT/UPDATE via service_role only (Edge Functions/webhooks)
```

## RLS Policies SQL

```sql
-- Policy 1: Transaction parties view events
-- Users can see FedEx events if they are buyer or seller of the transaction
CREATE POLICY "Transaction parties view events"
ON fedex_events FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM marketplace_transactions mt
    WHERE mt.id = fedex_events.transaction_id
    AND (mt.seller_id = auth.uid() OR mt.buyer_id = auth.uid())
  )
);

-- Policy 2: Service role inserts (Edge Functions/webhooks)
-- Note: service_role bypasses RLS, so no policy needed for INSERT
-- This is intentional - only Edge Functions should insert FedEx events
```

## Post-Migration Verification

```sql
-- 1. Verify table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'fedex_events';

-- 2. Verify columns exist
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'fedex_events'
ORDER BY ordinal_position;

-- 3. Verify FK constraint to marketplace_transactions
SELECT
  tc.constraint_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'fedex_events';

-- 4. Verify CHECK constraint on event_type
SELECT constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema = 'public'
  AND constraint_name LIKE '%fedex_events%';

-- 5. Verify RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'fedex_events';

-- 6. Verify policies created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'fedex_events';

-- 7. Verify indexes created
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'fedex_events';

-- 8. Test constraint: invalid event_type (should FAIL)
-- INSERT INTO fedex_events (tracking_number, event_type)
-- VALUES ('123456789', 'invalid_event');
-- Expected: ERROR: new row violates check constraint "fedex_events_event_type_check"

-- 9. Test nullable transaction_id (should SUCCEED)
-- INSERT INTO fedex_events (tracking_number, event_type, event_description)
-- VALUES ('123456789', 'picked_up', 'Package picked up by FedEx');
-- Expected: Success (transaction_id can be NULL initially)

-- 10. Test JSONB raw_payload insertion
-- INSERT INTO fedex_events (
--   tracking_number, event_type, event_description, raw_payload
-- ) VALUES (
--   '123456789',
--   'in_transit',
--   'Package in transit',
--   '{"scanEvents": [{"eventType": "PU", "eventDescription": "Picked up"}]}'::jsonb
-- );
-- Expected: Success
```

## Raw Payload JSONB Schema (Example)

Le champ `raw_payload` contient le JSON brut retourne par FedEx API :

```json
{
  "transactionId": "624deea6-b709-470c-8c39-4b5511281492",
  "customerTransactionId": "AnyCo_order_12345",
  "output": {
    "completeTrackResults": [
      {
        "trackingNumber": "123456789012",
        "trackResults": [
          {
            "trackingNumberInfo": {
              "trackingNumber": "123456789012",
              "carrierCode": "FDXG"
            },
            "latestStatusDetail": {
              "scanEventType": "OD",
              "scanEventDescription": "Out for delivery",
              "statusCode": "OD"
            },
            "dateAndTimes": [
              {
                "type": "ACTUAL_DELIVERY",
                "dateTime": "2026-02-04T10:30:00-06:00"
              }
            ],
            "scanEvents": [
              {
                "eventType": "OD",
                "eventDescription": "Out for delivery",
                "scanLocation": {
                  "city": "CHICAGO",
                  "stateOrProvinceCode": "IL",
                  "countryCode": "US"
                },
                "date": "2026-02-04T10:30:00-06:00"
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### Extraction des champs

L'Edge Function qui insere les events extrait :
- `event_type` : Map FedEx `scanEventType` vers notre enum
- `event_description` : `scanEventDescription`
- `event_code` : `statusCode`
- `location_city` : `scanLocation.city`
- `location_country` : `scanLocation.countryCode`
- `event_timestamp` : `date` (parse ISO8601)
- `raw_payload` : Full JSON pour audit

## Justification transaction_id Nullable

**Question du challenger** : "transaction_id nullable justifie ?"

**Reponse** : Oui, car :

1. **FedEx webhooks asynchrones** : FedEx peut envoyer un event avant qu'on ait cree la transaction en DB
2. **Tracking number seul** : On peut recevoir des events avec juste le tracking number
3. **Linkage posterieur** : L'Edge Function peut linker l'event a la transaction plus tard via `tracking_number`

**Workflow** :
1. FedEx webhook arrive avec `tracking_number`
2. Edge Function insere event avec `transaction_id = NULL`
3. Plus tard, quand transaction est creee, on peut UPDATE :
   ```sql
   UPDATE fedex_events
   SET transaction_id = 'new-transaction-id'
   WHERE tracking_number = 'xyz' AND transaction_id IS NULL;
   ```

Alternative : INDEX sur `tracking_number` permet de query events meme sans transaction_id.

## Entity Dart

### Fichier: `lib/features/marketplace/domain/entities/fedex_event.dart`

```dart
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
  String toString() => 'FedExEvent(id: $id, trackingNumber: $trackingNumber, eventType: $eventType)';

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
```

### Fichier: `test/features/marketplace/domain/entities/fedex_event_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/fedex_event.dart';

void main() {
  group('FedExEvent', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create FedExEvent with required fields', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        expect(event.id, 'event-123');
        expect(event.trackingNumber, '123456789012');
        expect(event.eventType, 'picked_up');
        expect(event.createdAt, now);
        expect(event.transactionId, isNull);
        expect(event.eventDescription, isNull);
      });

      test('should create FedExEvent with all optional fields', () {
        final now = DateTime.now();
        final eventTime = now.subtract(const Duration(hours: 2));
        final rawPayload = {'scanEvents': [{'eventType': 'PU'}]};

        final event = FedExEvent(
          id: 'event-123',
          transactionId: 'transaction-456',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          eventDescription: 'Package picked up by FedEx',
          eventCode: 'PU',
          location: 'CHICAGO IL US',
          locationCity: 'CHICAGO',
          locationCountry: 'US',
          eventTimestamp: eventTime,
          rawPayload: rawPayload,
          createdAt: now,
        );

        expect(event.transactionId, 'transaction-456');
        expect(event.eventDescription, 'Package picked up by FedEx');
        expect(event.eventCode, 'PU');
        expect(event.locationCity, 'CHICAGO');
        expect(event.locationCountry, 'US');
        expect(event.eventTimestamp, eventTime);
        expect(event.rawPayload, rawPayload);
      });

      test('should be immutable', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        // Verify fields are final (compile-time check)
        // Cannot reassign: event.eventType = 'delivered'; // Would not compile
        expect(event.eventType, 'picked_up');
      });
    });

    // ==============================================================
    // EVENT TYPE HELPERS
    // ==============================================================

    group('event type helpers', () {
      test('isDelivered should be true when eventType is delivered', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'delivered',
          createdAt: now,
        );

        expect(event.isDelivered, isTrue);
      });

      test('isDelivered should be false when eventType is not delivered', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'in_transit',
          createdAt: now,
        );

        expect(event.isDelivered, isFalse);
      });

      test('isException should be true when eventType is exception', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'exception',
          createdAt: now,
        );

        expect(event.isException, isTrue);
      });

      test('isException should be false when eventType is not exception', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        expect(event.isException, isFalse);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is the same', () {
        final now = DateTime.now();
        final event1 = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        final event2 = FedExEvent(
          id: 'event-123',
          trackingNumber: '999999999999',
          eventType: 'delivered',
          createdAt: now.add(const Duration(days: 1)),
        );

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when id differs', () {
        final now = DateTime.now();
        final event1 = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        final event2 = FedExEvent(
          id: 'event-999',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        expect(event1, isNot(equals(event2)));
        expect(event1.hashCode, isNot(equals(event2.hashCode)));
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should create copy with updated transaction_id', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        final updated = event.copyWith(transactionId: 'transaction-456');

        expect(updated.transactionId, 'transaction-456');
        expect(updated.id, event.id);
        expect(updated.trackingNumber, event.trackingNumber);
      });

      test('should preserve all fields when no parameter provided', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        final copied = event.copyWith();

        expect(copied.id, event.id);
        expect(copied.trackingNumber, event.trackingNumber);
        expect(copied.eventType, event.eventType);
      });
    });

    // ==============================================================
    // TOSTRING TESTS
    // ==============================================================

    group('toString', () {
      test('should provide readable string representation', () {
        final now = DateTime.now();
        final event = FedExEvent(
          id: 'event-123',
          trackingNumber: '123456789012',
          eventType: 'picked_up',
          createdAt: now,
        );

        final str = event.toString();

        expect(str, contains('event-123'));
        expect(str, contains('123456789012'));
        expect(str, contains('picked_up'));
      });
    });
  });
}
```

## Tests Requis

### Tests base de donnees (via migration verification):
- Test 1: FK constraint to marketplace_transactions enforced
- Test 2: CHECK constraint event_type valid values enforced
- Test 3: CHECK constraint invalid event_type rejected
- Test 4: transaction_id can be NULL (for async FedEx webhooks)
- Test 5: RLS policy - transaction parties can view events
- Test 6: RLS policy - non-parties cannot view events
- Test 7: JSONB raw_payload stores complex JSON
- Test 8: Indexes created (transaction, tracking, type)

### Tests entity Dart:
- Test 1: Create event with required fields only
- Test 2: Create event with all optional fields (including rawPayload)
- Test 3: Immutability verification
- Test 4: isDelivered helper when eventType is delivered
- Test 5: isException helper when eventType is exception
- Test 6: Equality based on id
- Test 7: CopyWith updates transaction_id
- Test 8: ToString contains key fields

## Definition of Done
- [x] Migration appliquee avec succes sur Supabase (MCP apply_migration)
- [x] Post-migration verification complete (FK, CHECK, RLS, indexes)
- [x] CHECK constraint event_type enforce valid values
- [x] transaction_id nullable (justified for async webhooks)
- [x] 3 indexes crees
- [x] 1 RLS policy active (Transaction parties view)
- [x] Entity Dart creee avec isDelivered/isException helpers + fromJson/toJson
- [x] Tests entity Dart passes (9 test groups, 22 tests)
- [x] `flutter analyze --fatal-infos` passe (0 warnings)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible

## Dependances

### Requires (BLOQUANTS):
- S04: `marketplace_transactions` table doit exister (FK transaction_id)

### Order:
- S04 (marketplace_transactions) → **S06 (fedex_events)**

## Stories Dependantes (BLOQUEES si S06 incomplete)
- S13 (FedEx Track API) - insere events via Edge Function
- S22 (tracking colis frontend) - affiche timeline FedExEvent
