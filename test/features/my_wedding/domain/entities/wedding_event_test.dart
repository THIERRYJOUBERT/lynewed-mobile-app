import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_event.dart';

void main() {
  group('WeddingEvent', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create WeddingEvent with required fields', () {
        final eventDate = DateTime(2025, 9, 15, 14, 0, 0);
        final event = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: eventDate,
        );

        expect(event.id, 'event-123');
        expect(event.weddingId, 'wedding-456');
        expect(event.title, 'Ceremonie');
        expect(event.eventDate, eventDate);
        expect(event.description, isNull);
        expect(event.eventEndDate, isNull);
        expect(event.location, isNull);
        expect(event.linkedProId, isNull);
        expect(event.linkedProName, isNull);
        expect(event.isPublic, false);
        expect(event.status, EventStatus.pending);
        expect(event.reminderMinutes, [1440, 60]);
        expect(event.createdAt, isNull);
      });

      test('should create WeddingEvent with all optional fields', () {
        final eventDate = DateTime(2025, 9, 15, 14, 0, 0);
        final eventEndDate = DateTime(2025, 9, 15, 15, 0, 0);
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final event = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: eventDate,
          description: 'Ceremonie civile a la mairie',
          eventEndDate: eventEndDate,
          location: 'Mairie de Paris',
          linkedProId: 'pro-789',
          linkedProName: 'Photographe Pro',
          isPublic: true,
          status: EventStatus.done,
          reminderMinutes: [720, 30],
          createdAt: createdAt,
        );

        expect(event.description, 'Ceremonie civile a la mairie');
        expect(event.eventEndDate, eventEndDate);
        expect(event.location, 'Mairie de Paris');
        expect(event.linkedProId, 'pro-789');
        expect(event.linkedProName, 'Photographe Pro');
        expect(event.isPublic, true);
        expect(event.status, EventStatus.done);
        expect(event.reminderMinutes, [720, 30]);
        expect(event.createdAt, createdAt);
      });
    });

    // ==============================================================
    // COMPUTED PROPERTIES TESTS
    // ==============================================================

    group('computed properties', () {
      group('isDone', () {
        test('should be true when status is done', () {
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2025, 9, 15),
            status: EventStatus.done,
          );

          expect(event.isDone, true);
        });

        test('should be false when status is pending', () {
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2025, 9, 15),
            status: EventStatus.pending,
          );

          expect(event.isDone, false);
        });

        test('should be false when status is cancelled', () {
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2025, 9, 15),
            status: EventStatus.cancelled,
          );

          expect(event.isDone, false);
        });
      });

      group('isCancelled', () {
        test('should be true when status is cancelled', () {
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2025, 9, 15),
            status: EventStatus.cancelled,
          );

          expect(event.isCancelled, true);
        });

        test('should be false when status is pending', () {
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2025, 9, 15),
            status: EventStatus.pending,
          );

          expect(event.isCancelled, false);
        });

        test('should be false when status is done', () {
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2025, 9, 15),
            status: EventStatus.done,
          );

          expect(event.isCancelled, false);
        });
      });

      group('isPast', () {
        test('should be true when event date is in the past', () {
          // Create event in the past (year 2020)
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2020, 1, 1),
          );

          expect(event.isPast, true);
        });

        test('should be false when event date is in the future', () {
          // Create event far in the future (year 2099)
          final event = WeddingEvent(
            id: 'event-1',
            weddingId: 'wedding-1',
            title: 'Test',
            eventDate: DateTime(2099, 12, 31),
          );

          expect(event.isPast, false);
        });
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse event with all fields', () {
        final json = {
          'id': 'event-123',
          'wedding_id': 'wedding-456',
          'title': 'Ceremonie',
          'description': 'Ceremonie civile a la mairie',
          'event_date': '2025-09-15T14:00:00Z',
          'event_end_date': '2025-09-15T15:00:00Z',
          'location': 'Mairie de Paris',
          'linked_pro_id': 'pro-789',
          'linked_pro_name': 'Photographe Pro',
          'is_public': true,
          'status': 'done',
          'reminder_minutes': [720, 30],
          'created_at': '2025-01-24T10:00:00Z',
        };

        final event = WeddingEvent.fromJson(json);

        expect(event.id, 'event-123');
        expect(event.weddingId, 'wedding-456');
        expect(event.title, 'Ceremonie');
        expect(event.description, 'Ceremonie civile a la mairie');
        expect(event.eventDate.year, 2025);
        expect(event.eventDate.month, 9);
        expect(event.eventDate.day, 15);
        expect(event.eventEndDate?.year, 2025);
        expect(event.eventEndDate?.month, 9);
        expect(event.eventEndDate?.day, 15);
        expect(event.location, 'Mairie de Paris');
        expect(event.linkedProId, 'pro-789');
        expect(event.linkedProName, 'Photographe Pro');
        expect(event.isPublic, true);
        expect(event.status, EventStatus.done);
        expect(event.reminderMinutes, [720, 30]);
        expect(event.createdAt?.year, 2025);
      });

      test('should parse event with minimal fields', () {
        final json = {
          'id': 'event-123',
          'wedding_id': 'wedding-456',
          'title': 'Ceremonie',
          'event_date': '2025-09-15T14:00:00Z',
        };

        final event = WeddingEvent.fromJson(json);

        expect(event.id, 'event-123');
        expect(event.weddingId, 'wedding-456');
        expect(event.title, 'Ceremonie');
        expect(event.eventDate.year, 2025);
        expect(event.description, isNull);
        expect(event.eventEndDate, isNull);
        expect(event.location, isNull);
        expect(event.linkedProId, isNull);
        expect(event.linkedProName, isNull);
        expect(event.isPublic, false);
        expect(event.status, EventStatus.pending);
        expect(event.reminderMinutes, [1440, 60]);
        expect(event.createdAt, isNull);
      });

      test('should parse status "pending" correctly', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'status': 'pending',
        };

        expect(WeddingEvent.fromJson(json).status, EventStatus.pending);
      });

      test('should parse status "done" correctly', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'status': 'done',
        };

        expect(WeddingEvent.fromJson(json).status, EventStatus.done);
      });

      test('should parse status "cancelled" correctly', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'status': 'cancelled',
        };

        expect(WeddingEvent.fromJson(json).status, EventStatus.cancelled);
      });

      test('should default to pending for invalid status', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'status': 'invalid_status',
        };

        expect(WeddingEvent.fromJson(json).status, EventStatus.pending);
      });

      test('should default to pending for null status', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'status': null,
        };

        expect(WeddingEvent.fromJson(json).status, EventStatus.pending);
      });

      test('should default to false for null is_public', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'is_public': null,
        };

        expect(WeddingEvent.fromJson(json).isPublic, false);
      });

      test('should default to [1440, 60] for null reminder_minutes', () {
        final json = {
          'id': 'event-1',
          'wedding_id': 'wedding-1',
          'title': 'Test',
          'event_date': '2025-09-15T14:00:00Z',
          'reminder_minutes': null,
        };

        expect(WeddingEvent.fromJson(json).reminderMinutes, [1440, 60]);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final eventDate = DateTime(2025, 9, 15, 14, 0, 0);
        final eventEndDate = DateTime(2025, 9, 15, 15, 0, 0);
        final event = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: eventDate,
          description: 'Ceremonie civile',
          eventEndDate: eventEndDate,
          location: 'Mairie de Paris',
          linkedProId: 'pro-789',
          isPublic: true,
          status: EventStatus.done,
          reminderMinutes: [720, 30],
        );

        final json = event.toJson();

        expect(json['wedding_id'], 'wedding-456');
        expect(json['title'], 'Ceremonie');
        expect(json['description'], 'Ceremonie civile');
        expect(json['event_date'], eventDate.toIso8601String());
        expect(json['event_end_date'], eventEndDate.toIso8601String());
        expect(json['location'], 'Mairie de Paris');
        expect(json['linked_pro_id'], 'pro-789');
        expect(json['is_public'], true);
        expect(json['status'], 'done');
        expect(json['reminder_minutes'], [720, 30]);
        // id, linked_pro_name, created_at are not serialized
        expect(json.containsKey('id'), false);
        expect(json.containsKey('linked_pro_name'), false);
        expect(json.containsKey('created_at'), false);
      });

      test('should serialize null optional fields', () {
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Test',
          eventDate: DateTime(2025, 9, 15),
        );

        final json = event.toJson();

        expect(json['description'], isNull);
        expect(json['event_end_date'], isNull);
        expect(json['location'], isNull);
        expect(json['linked_pro_id'], isNull);
      });

      test('should serialize pending status correctly', () {
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Test',
          eventDate: DateTime(2025, 9, 15),
          status: EventStatus.pending,
        );

        expect(event.toJson()['status'], 'pending');
      });

      test('should serialize cancelled status correctly', () {
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Test',
          eventDate: DateTime(2025, 9, 15),
          status: EventStatus.cancelled,
        );

        expect(event.toJson()['status'], 'cancelled');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final eventDate = DateTime(2025, 9, 15, 14, 0, 0);
        final eventEndDate = DateTime(2025, 9, 15, 15, 0, 0);
        final createdAt = DateTime(2025, 1, 24);
        final original = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: eventDate,
          description: 'Original description',
          eventEndDate: eventEndDate,
          location: 'Mairie de Paris',
          linkedProId: 'pro-789',
          linkedProName: 'Photographe',
          isPublic: true,
          status: EventStatus.pending,
          reminderMinutes: [720, 30],
          createdAt: createdAt,
        );

        final copied = original.copyWith(title: 'Reception');

        expect(copied.id, 'event-123');
        expect(copied.weddingId, 'wedding-456');
        expect(copied.title, 'Reception');
        expect(copied.eventDate, eventDate);
        expect(copied.description, 'Original description');
        expect(copied.eventEndDate, eventEndDate);
        expect(copied.location, 'Mairie de Paris');
        expect(copied.linkedProId, 'pro-789');
        expect(copied.linkedProName, 'Photographe');
        expect(copied.isPublic, true);
        expect(copied.status, EventStatus.pending);
        expect(copied.reminderMinutes, [720, 30]);
        expect(copied.createdAt, createdAt);
      });

      test('should update multiple fields at once', () {
        final original = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Test',
          eventDate: DateTime(2025, 9, 15),
          status: EventStatus.pending,
          isPublic: false,
        );

        final copied = original.copyWith(
          status: EventStatus.done,
          isPublic: true,
        );

        expect(copied.status, EventStatus.done);
        expect(copied.isPublic, true);
      });

      test('should not modify original', () {
        final original = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Original',
          eventDate: DateTime(2025, 9, 15),
        );

        original.copyWith(title: 'Modified');

        expect(original.title, 'Original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        final event1 = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: DateTime(2025, 9, 15),
        );
        final event2 = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Reception',
          eventDate: DateTime(2025, 10, 20),
        );

        expect(event1, equals(event2));
        expect(event1.hashCode, equals(event2.hashCode));
      });

      test('should not be equal when id differs', () {
        final event1 = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: DateTime(2025, 9, 15),
        );
        final event2 = WeddingEvent(
          id: 'event-789',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: DateTime(2025, 9, 15),
        );

        expect(event1, isNot(equals(event2)));
      });

      test('should return identical for same instance', () {
        final event = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: DateTime(2025, 9, 15),
        );

        expect(event == event, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final event = WeddingEvent(
          id: 'event-123',
          weddingId: 'wedding-456',
          title: 'Ceremonie',
          eventDate: DateTime(2025, 9, 15),
        );

        final result = event.toString();

        expect(result, contains('event-123'));
        expect(result, contains('Ceremonie'));
        expect(result, contains('2025'));
      });
    });
  });

  // ==============================================================
  // REMINDER FIELDS TESTS (EPIC-08)
  // ==============================================================

  group('reminder fields', () {
    test('should have default values of false', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test Event',
        eventDate: DateTime.now(),
      );

      expect(event.reminder1Week, false);
      expect(event.reminder1Day, false);
      expect(event.reminder1Hour, false);
    });

    test('should create event with reminder fields set to true', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test Event',
        eventDate: DateTime.now(),
        reminder1Week: true,
        reminder1Day: true,
        reminder1Hour: true,
      );

      expect(event.reminder1Week, true);
      expect(event.reminder1Day, true);
      expect(event.reminder1Hour, true);
    });

    test('should serialize reminder fields to JSON', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test Event',
        eventDate: DateTime(2025, 9, 15),
        reminder1Week: true,
        reminder1Day: true,
        reminder1Hour: false,
      );

      final json = event.toJson();

      expect(json['reminder_1_week'], true);
      expect(json['reminder_1_day'], true);
      expect(json['reminder_1_hour'], false);
    });

    test('should deserialize reminder fields from JSON', () {
      final json = {
        'id': 'event-1',
        'wedding_id': 'wedding-1',
        'title': 'Test Event',
        'event_date': DateTime.now().toIso8601String(),
        'reminder_1_week': true,
        'reminder_1_day': false,
        'reminder_1_hour': true,
      };

      final event = WeddingEvent.fromJson(json);

      expect(event.reminder1Week, true);
      expect(event.reminder1Day, false);
      expect(event.reminder1Hour, true);
    });

    test('should handle missing reminder fields (backward compatibility)', () {
      final json = {
        'id': 'event-1',
        'wedding_id': 'wedding-1',
        'title': 'Test Event',
        'event_date': DateTime.now().toIso8601String(),
        // No reminder fields - simulating old data
      };

      final event = WeddingEvent.fromJson(json);

      expect(event.reminder1Week, false);
      expect(event.reminder1Day, false);
      expect(event.reminder1Hour, false);
    });

    test('should handle null reminder fields (backward compatibility)', () {
      final json = {
        'id': 'event-1',
        'wedding_id': 'wedding-1',
        'title': 'Test Event',
        'event_date': DateTime.now().toIso8601String(),
        'reminder_1_week': null,
        'reminder_1_day': null,
        'reminder_1_hour': null,
      };

      final event = WeddingEvent.fromJson(json);

      expect(event.reminder1Week, false);
      expect(event.reminder1Day, false);
      expect(event.reminder1Hour, false);
    });

    test('copyWith should update reminder1Week', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test',
        eventDate: DateTime.now(),
        reminder1Week: false,
      );

      final updated = event.copyWith(reminder1Week: true);

      expect(updated.reminder1Week, true);
      expect(updated.reminder1Day, false);
      expect(updated.reminder1Hour, false);
    });

    test('copyWith should update reminder1Day', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test',
        eventDate: DateTime.now(),
        reminder1Day: false,
      );

      final updated = event.copyWith(reminder1Day: true);

      expect(updated.reminder1Day, true);
    });

    test('copyWith should update reminder1Hour', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test',
        eventDate: DateTime.now(),
        reminder1Hour: false,
      );

      final updated = event.copyWith(reminder1Hour: true);

      expect(updated.reminder1Hour, true);
    });

    test('copyWith should preserve unchanged reminder fields', () {
      final event = WeddingEvent(
        id: 'event-1',
        weddingId: 'wedding-1',
        title: 'Test',
        eventDate: DateTime.now(),
        reminder1Week: true,
        reminder1Day: true,
        reminder1Hour: true,
      );

      final updated = event.copyWith(title: 'Updated Title');

      expect(updated.reminder1Week, true);
      expect(updated.reminder1Day, true);
      expect(updated.reminder1Hour, true);
    });
  });

  // ==============================================================
  // EVENTSTATUS ENUM TESTS
  // ==============================================================

  group('EventStatus', () {
    test('should have all expected values', () {
      expect(EventStatus.values, contains(EventStatus.pending));
      expect(EventStatus.values, contains(EventStatus.done));
      expect(EventStatus.values, contains(EventStatus.cancelled));
      expect(EventStatus.values.length, 3);
    });
  });
}
