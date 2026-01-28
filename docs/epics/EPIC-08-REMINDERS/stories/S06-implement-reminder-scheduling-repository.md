# Story S06: Implementer scheduling des rappels dans repository

## Description
En tant que developpeur Flutter, je veux implementer la logique de scheduling des rappels dans le repository, afin de creer/modifier/supprimer automatiquement les scheduled_notifications quand un evenement est cree ou modifie.

## Criteres d'Acceptance (Gherkin)
- [ ] Given a new event with event_date = "2026-02-15 14:00" and reminder_1_week = true, reminder_1_day = true When the event is created Then scheduled_notifications should contain entries for 1_week (2026-02-08 14:00) and 1_day (2026-02-14 14:00)
- [ ] Given an existing event with reminder_1_week = true When updated with reminder_1_week = false, reminder_1_day = true Then the 1_week notification should be deleted and a new 1_day notification created
- [ ] Given an event with reminder_1_week = true and existing notification When saved again with reminder_1_week = true Then only one 1_week notification should exist (no duplicates)
- [ ] Given an event with scheduled notifications When the event is deleted Then all related scheduled notifications should be deleted (CASCADE)
- [ ] Given an event with event_date changed from "2026-02-15 14:00" to "2026-02-20 10:00" and reminder_1_day = true When saved Then the 1_day notification scheduled_at should be updated to "2026-02-19 10:00"
- [ ] Given an event with event_date = NOW() + 6 hours and all reminders enabled When created Then only 1_hour notification should be created (1_week and 1_day are in the past)

## Fichiers Concernes
### A Creer
- `lib/features/my_wedding/data/datasources/scheduled_notification_datasource.dart`
- `test/features/my_wedding/data/datasources/scheduled_notification_datasource_test.dart`
- `test/features/my_wedding/data/repositories/wedding_event_repository_reminder_test.dart`

### A Modifier
- `lib/features/my_wedding/data/repositories/wedding_event_repository_impl.dart`

## Notes Techniques

### ScheduledNotificationDatasource
```dart
// lib/features/my_wedding/data/datasources/scheduled_notification_datasource.dart

abstract class ScheduledNotificationDatasource {
  Future<void> scheduleReminders(WeddingEvent event, String userId);
  Future<void> deleteRemindersForEvent(String eventId);
}

class ScheduledNotificationDatasourceImpl implements ScheduledNotificationDatasource {
  final SupabaseClient _supabase;

  ScheduledNotificationDatasourceImpl(this._supabase);

  @override
  Future<void> scheduleReminders(WeddingEvent event, String userId) async {
    // Delete existing notifications for this event
    await deleteRemindersForEvent(event.id);

    final eventDate = event.eventDate;
    final now = DateTime.now();
    final notifications = <Map<String, dynamic>>[];

    // 1 week before
    if (event.reminder1Week) {
      final scheduledAt = eventDate.subtract(const Duration(days: 7));
      if (scheduledAt.isAfter(now)) {
        notifications.add(_buildNotification(event.id, userId, scheduledAt, '1_week'));
      }
    }

    // 1 day before
    if (event.reminder1Day) {
      final scheduledAt = eventDate.subtract(const Duration(days: 1));
      if (scheduledAt.isAfter(now)) {
        notifications.add(_buildNotification(event.id, userId, scheduledAt, '1_day'));
      }
    }

    // 1 hour before
    if (event.reminder1Hour) {
      final scheduledAt = eventDate.subtract(const Duration(hours: 1));
      if (scheduledAt.isAfter(now)) {
        notifications.add(_buildNotification(event.id, userId, scheduledAt, '1_hour'));
      }
    }

    if (notifications.isNotEmpty) {
      await _supabase.from('scheduled_notifications').insert(notifications);
    }
  }

  @override
  Future<void> deleteRemindersForEvent(String eventId) async {
    await _supabase
        .from('scheduled_notifications')
        .delete()
        .eq('event_id', eventId);
  }

  Map<String, dynamic> _buildNotification(
    String eventId,
    String userId,
    DateTime scheduledAt,
    String notificationType,
  ) {
    return {
      'event_id': eventId,
      'user_id': userId,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'notification_type': notificationType,
    };
  }
}
```

### Repository Integration
```dart
// In wedding_event_repository_impl.dart

class WeddingEventRepositoryImpl implements WeddingEventRepository {
  final WeddingEventDatasource _datasource;
  final ScheduledNotificationDatasource _notificationDatasource;
  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, WeddingEvent>> createEvent(WeddingEvent event) async {
    try {
      final response = await _datasource.createEvent(event);
      final createdEvent = WeddingEventModel.fromJson(response);

      // Schedule notifications
      final userId = _supabase.auth.currentUser!.id;
      await _notificationDatasource.scheduleReminders(createdEvent, userId);

      return Right(createdEvent);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, WeddingEvent>> updateEvent(WeddingEvent event) async {
    try {
      final response = await _datasource.updateEvent(event);
      final updatedEvent = WeddingEventModel.fromJson(response);

      // Re-schedule notifications
      final userId = _supabase.auth.currentUser!.id;
      await _notificationDatasource.scheduleReminders(updatedEvent, userId);

      return Right(updatedEvent);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // Note: deleteEvent relies on CASCADE delete for notifications
}
```

### Tests
```dart
// test/features/my_wedding/data/datasources/scheduled_notification_datasource_test.dart

group('ScheduledNotificationDatasource', () {
  late MockSupabaseClient mockSupabase;
  late ScheduledNotificationDatasourceImpl datasource;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    datasource = ScheduledNotificationDatasourceImpl(mockSupabase);
  });

  test('should create notifications for enabled reminders', () async {
    final event = WeddingEvent(
      id: 'event-1',
      weddingId: 'wedding-1',
      title: 'Test Event',
      eventDate: DateTime.now().add(const Duration(days: 14)),
      reminder1Week: true,
      reminder1Day: true,
      reminder1Hour: false,
    );

    when(mockSupabase.from('scheduled_notifications').delete().eq('event_id', 'event-1'))
        .thenAnswer((_) async => {});
    when(mockSupabase.from('scheduled_notifications').insert(any))
        .thenAnswer((_) async => {});

    await datasource.scheduleReminders(event, 'user-1');

    verify(mockSupabase.from('scheduled_notifications').insert(argThat(
      predicate<List<Map<String, dynamic>>>((notifications) =>
        notifications.length == 2 &&
        notifications.any((n) => n['notification_type'] == '1_week') &&
        notifications.any((n) => n['notification_type'] == '1_day')
      ),
    ))).called(1);
  });

  test('should skip past notifications', () async {
    final event = WeddingEvent(
      id: 'event-1',
      weddingId: 'wedding-1',
      title: 'Test Event',
      eventDate: DateTime.now().add(const Duration(hours: 6)),
      reminder1Week: true,  // Will be skipped (past)
      reminder1Day: true,   // Will be skipped (past)
      reminder1Hour: true,  // Will be created
    );

    when(mockSupabase.from('scheduled_notifications').delete().eq('event_id', 'event-1'))
        .thenAnswer((_) async => {});
    when(mockSupabase.from('scheduled_notifications').insert(any))
        .thenAnswer((_) async => {});

    await datasource.scheduleReminders(event, 'user-1');

    verify(mockSupabase.from('scheduled_notifications').insert(argThat(
      predicate<List<Map<String, dynamic>>>((notifications) =>
        notifications.length == 1 &&
        notifications[0]['notification_type'] == '1_hour'
      ),
    ))).called(1);
  });

  test('should delete existing notifications before creating new ones', () async {
    final event = WeddingEvent(
      id: 'event-1',
      weddingId: 'wedding-1',
      title: 'Test Event',
      eventDate: DateTime.now().add(const Duration(days: 14)),
      reminder1Week: true,
    );

    when(mockSupabase.from('scheduled_notifications').delete().eq('event_id', 'event-1'))
        .thenAnswer((_) async => {});
    when(mockSupabase.from('scheduled_notifications').insert(any))
        .thenAnswer((_) async => {});

    await datasource.scheduleReminders(event, 'user-1');

    verifyInOrder([
      mockSupabase.from('scheduled_notifications').delete().eq('event_id', 'event-1'),
      mockSupabase.from('scheduled_notifications').insert(any),
    ]);
  });

  test('should store scheduled_at in UTC', () async {
    final eventDate = DateTime(2026, 2, 15, 14, 0);
    final event = WeddingEvent(
      id: 'event-1',
      weddingId: 'wedding-1',
      title: 'Test Event',
      eventDate: eventDate,
      reminder1Day: true,
    );

    List<Map<String, dynamic>>? capturedNotifications;
    when(mockSupabase.from('scheduled_notifications').delete().eq('event_id', 'event-1'))
        .thenAnswer((_) async => {});
    when(mockSupabase.from('scheduled_notifications').insert(any))
        .thenAnswer((invocation) async {
          capturedNotifications = invocation.positionalArguments[0];
        });

    await datasource.scheduleReminders(event, 'user-1');

    final scheduledAt = DateTime.parse(capturedNotifications![0]['scheduled_at']);
    expect(scheduledAt.isUtc, true);
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] ScheduledNotificationDatasource cree avec tests
- [ ] Repository integre avec datasource
- [ ] Logique de calcul des dates testee (1_week, 1_day, 1_hour)
- [ ] Skip des notifications passees teste
- [ ] Delete + recreate teste (pas de doublons)
- [ ] Dates stockees en UTC
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (logique metier de calcul des dates)

## Dependances
- S02: Creer table scheduled_notifications (table doit exister)
- S04: Mettre a jour entite WeddingEvent en Dart (entity avec reminder fields)

## Stories Dependantes
- S07: Integrer avec notifications_outbox existante (depend du scheduling)
- S08: Tests E2E du flow complet (depend du scheduling)
