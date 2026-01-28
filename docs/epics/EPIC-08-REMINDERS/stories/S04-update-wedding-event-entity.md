# Story S04: Mettre a jour entite WeddingEvent en Dart

## Description
En tant que developpeur Flutter, je veux ajouter les champs de rappel a l'entite WeddingEvent et son model, afin de serialiser/deserialiser correctement les preferences de rappel depuis Supabase.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the WeddingEvent entity When inspecting its fields Then it should have reminder1Week, reminder1Day, reminder1Hour of type bool
- [ ] Given a new WeddingEvent created without reminder values When the entity is instantiated Then reminder1Week, reminder1Day, reminder1Hour should all default to false
- [ ] Given a WeddingEvent with reminder1Week = true and reminder1Day = true When toJson is called Then the JSON should contain "reminder_1_week": true, "reminder_1_day": true, "reminder_1_hour": false
- [ ] Given a JSON with reminder fields When WeddingEventModel.fromJson is called Then the reminder fields should be correctly deserialized
- [ ] Given a JSON without reminder fields (old format) When WeddingEventModel.fromJson is called Then reminder fields should default to false and no exception should be thrown (backward compatibility)
- [ ] Given a WeddingEvent with reminder1Week = false When copyWith(reminder1Week: true) is called Then the new entity should have reminder1Week = true and other fields unchanged

## Fichiers Concernes
### A Creer
- `test/features/my_wedding/domain/entities/wedding_event_reminder_test.dart`
- `test/features/my_wedding/data/models/wedding_event_model_reminder_test.dart`

### A Modifier
- `lib/features/my_wedding/domain/entities/wedding_event.dart`
- `lib/features/my_wedding/data/models/wedding_event_model.dart`

## Notes Techniques

### Entity (wedding_event.dart)
```dart
class WeddingEvent extends Equatable {
  final String id;
  final String weddingId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime? eventEndDate;
  final String? location;
  // ... existing fields ...

  // NEW: Reminder flags
  final bool reminder1Week;
  final bool reminder1Day;
  final bool reminder1Hour;

  const WeddingEvent({
    required this.id,
    required this.weddingId,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventEndDate,
    this.location,
    // ... existing fields ...
    this.reminder1Week = false,  // NEW
    this.reminder1Day = false,   // NEW
    this.reminder1Hour = false,  // NEW
  });

  WeddingEvent copyWith({
    // ... existing params ...
    bool? reminder1Week,
    bool? reminder1Day,
    bool? reminder1Hour,
  }) {
    return WeddingEvent(
      // ... existing fields ...
      reminder1Week: reminder1Week ?? this.reminder1Week,
      reminder1Day: reminder1Day ?? this.reminder1Day,
      reminder1Hour: reminder1Hour ?? this.reminder1Hour,
    );
  }

  @override
  List<Object?> get props => [
    // ... existing props ...
    reminder1Week,
    reminder1Day,
    reminder1Hour,
  ];
}
```

### Model (wedding_event_model.dart)
```dart
factory WeddingEventModel.fromJson(Map<String, dynamic> json) {
  return WeddingEventModel(
    // ... existing fields ...
    // NEW: With backward compatibility (null -> false)
    reminder1Week: json['reminder_1_week'] as bool? ?? false,
    reminder1Day: json['reminder_1_day'] as bool? ?? false,
    reminder1Hour: json['reminder_1_hour'] as bool? ?? false,
  );
}

Map<String, dynamic> toJson() {
  return {
    // ... existing fields ...
    // NEW
    'reminder_1_week': reminder1Week,
    'reminder_1_day': reminder1Day,
    'reminder_1_hour': reminder1Hour,
  };
}
```

### Tests
```dart
// test/features/my_wedding/domain/entities/wedding_event_reminder_test.dart

group('WeddingEvent reminder fields', () {
  test('should have default values of false', () {
    final event = WeddingEvent(
      id: '1',
      weddingId: 'w1',
      title: 'Test Event',
      eventDate: DateTime.now(),
    );

    expect(event.reminder1Week, false);
    expect(event.reminder1Day, false);
    expect(event.reminder1Hour, false);
  });

  test('should support copyWith for reminder fields', () {
    final event = WeddingEvent(
      id: '1',
      weddingId: 'w1',
      title: 'Test Event',
      eventDate: DateTime.now(),
      reminder1Week: false,
    );

    final updated = event.copyWith(reminder1Week: true);

    expect(updated.reminder1Week, true);
    expect(updated.reminder1Day, false);
    expect(updated.title, 'Test Event');
  });

  test('should include reminder fields in props', () {
    final event1 = WeddingEvent(
      id: '1', weddingId: 'w1', title: 'Test', eventDate: DateTime(2026, 2, 15),
      reminder1Week: true,
    );
    final event2 = WeddingEvent(
      id: '1', weddingId: 'w1', title: 'Test', eventDate: DateTime(2026, 2, 15),
      reminder1Week: false,
    );

    expect(event1, isNot(equals(event2)));
  });
});

// test/features/my_wedding/data/models/wedding_event_model_reminder_test.dart

group('WeddingEventModel reminder serialization', () {
  test('should serialize reminder fields to JSON', () {
    final model = WeddingEventModel(
      id: '1',
      weddingId: 'w1',
      title: 'Test Event',
      eventDate: DateTime.now(),
      reminder1Week: true,
      reminder1Day: true,
      reminder1Hour: false,
    );

    final json = model.toJson();

    expect(json['reminder_1_week'], true);
    expect(json['reminder_1_day'], true);
    expect(json['reminder_1_hour'], false);
  });

  test('should deserialize reminder fields from JSON', () {
    final json = {
      'id': '1',
      'wedding_id': 'w1',
      'title': 'Test Event',
      'event_date': DateTime.now().toIso8601String(),
      'reminder_1_week': true,
      'reminder_1_day': false,
      'reminder_1_hour': true,
    };

    final model = WeddingEventModel.fromJson(json);

    expect(model.reminder1Week, true);
    expect(model.reminder1Day, false);
    expect(model.reminder1Hour, true);
  });

  test('should handle missing reminder fields (backward compatibility)', () {
    final json = {
      'id': '1',
      'wedding_id': 'w1',
      'title': 'Test Event',
      'event_date': DateTime.now().toIso8601String(),
      // No reminder fields
    };

    final model = WeddingEventModel.fromJson(json);

    expect(model.reminder1Week, false);
    expect(model.reminder1Day, false);
    expect(model.reminder1Hour, false);
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Tests unitaires pour entity (default values, copyWith, props)
- [ ] Tests unitaires pour model (serialization, deserialization, backward compat)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe (tous les tests existants + nouveaux)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Faible (modifications simples avec backward compatibility)

## Dependances
- S01: Ajouter colonnes reminder a wedding_events (colonnes DB doivent exister pour tests integration)

## Stories Dependantes
- S05: Ajouter checkboxes rappel dans formulaire event (utilise l'entite modifiee)
- S06: Implementer scheduling des rappels dans repository (utilise l'entite modifiee)
