# Story S05: Ajouter checkboxes rappel dans formulaire event

## Description
En tant que bride, je veux pouvoir selectionner des rappels (1 semaine, 1 jour, 1 heure avant) lors de la creation/edition d'un evenement, afin de recevoir des notifications push aux moments choisis.

## Criteres d'Acceptance (Gherkin)
- [ ] Given the bride is on the create/edit event page When the form is displayed Then there should be a "Rappels" section with 3 checkboxes: "1 semaine avant", "1 jour avant", "1 heure avant"
- [ ] Given the bride is creating an event When she checks multiple reminders Then all selected checkboxes should be checked (multi-selection)
- [ ] Given an existing event with reminder_1_week = true and reminder_1_day = true When the bride edits the event Then "1 semaine avant" and "1 jour avant" should be pre-checked
- [ ] Given the bride has selected reminders When she saves the event Then the event should be saved with the correct reminder flags
- [ ] Given the event form When viewing the reminders section Then the checkboxes should use the app's standard checkbox style with consistent spacing
- [ ] Given an event with event_date in the past When editing the event Then the reminder checkboxes should be disabled with message "Rappels non disponibles pour les evenements passes"

## Fichiers Concernes
### A Creer
- `lib/features/my_wedding/presentation/widgets/reminder_section_widget.dart`
- `test/features/my_wedding/presentation/widgets/reminder_section_widget_test.dart`

### A Modifier
- `lib/features/my_wedding/presentation/pages/event_form_page.dart` (ou equivalent)
- `lib/features/my_wedding/presentation/cubit/event_form_cubit.dart` (ou bloc equivalent)
- `lib/features/my_wedding/presentation/cubit/event_form_state.dart`

## Notes Techniques

### Widget ReminderSection
```dart
// lib/features/my_wedding/presentation/widgets/reminder_section_widget.dart

class ReminderSectionWidget extends StatelessWidget {
  final bool reminder1Week;
  final bool reminder1Day;
  final bool reminder1Hour;
  final bool isEnabled;
  final ValueChanged<bool?> onReminder1WeekChanged;
  final ValueChanged<bool?> onReminder1DayChanged;
  final ValueChanged<bool?> onReminder1HourChanged;

  const ReminderSectionWidget({
    super.key,
    required this.reminder1Week,
    required this.reminder1Day,
    required this.reminder1Hour,
    required this.isEnabled,
    required this.onReminder1WeekChanged,
    required this.onReminder1DayChanged,
    required this.onReminder1HourChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rappels',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (!isEnabled)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Rappels non disponibles pour les evenements passes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        CheckboxListTile(
          title: const Text('1 semaine avant'),
          value: reminder1Week,
          onChanged: isEnabled ? onReminder1WeekChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('1 jour avant'),
          value: reminder1Day,
          onChanged: isEnabled ? onReminder1DayChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
        CheckboxListTile(
          title: const Text('1 heure avant'),
          value: reminder1Hour,
          onChanged: isEnabled ? onReminder1HourChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        ),
      ],
    );
  }
}
```

### State Update (Cubit)
```dart
// In event_form_cubit.dart

void updateReminder1Week(bool value) {
  emit(state.copyWith(reminder1Week: value));
}

void updateReminder1Day(bool value) {
  emit(state.copyWith(reminder1Day: value));
}

void updateReminder1Hour(bool value) {
  emit(state.copyWith(reminder1Hour: value));
}

// In state
class EventFormState {
  // ... existing fields
  final bool reminder1Week;
  final bool reminder1Day;
  final bool reminder1Hour;

  bool get isRemindersEnabled => eventDate?.isAfter(DateTime.now()) ?? true;
}
```

### Tests Widget
```dart
// test/features/my_wedding/presentation/widgets/reminder_section_widget_test.dart

group('ReminderSectionWidget', () {
  testWidgets('should display all three checkboxes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderSectionWidget(
            reminder1Week: false,
            reminder1Day: false,
            reminder1Hour: false,
            isEnabled: true,
            onReminder1WeekChanged: (_) {},
            onReminder1DayChanged: (_) {},
            onReminder1HourChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Rappels'), findsOneWidget);
    expect(find.text('1 semaine avant'), findsOneWidget);
    expect(find.text('1 jour avant'), findsOneWidget);
    expect(find.text('1 heure avant'), findsOneWidget);
  });

  testWidgets('should reflect checked values', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderSectionWidget(
            reminder1Week: true,
            reminder1Day: true,
            reminder1Hour: false,
            isEnabled: true,
            onReminder1WeekChanged: (_) {},
            onReminder1DayChanged: (_) {},
            onReminder1HourChanged: (_) {},
          ),
        ),
      ),
    );

    final checkboxes = tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    ).toList();

    expect(checkboxes[0].value, true);  // 1 semaine
    expect(checkboxes[1].value, true);  // 1 jour
    expect(checkboxes[2].value, false); // 1 heure
  });

  testWidgets('should be disabled when isEnabled is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderSectionWidget(
            reminder1Week: false,
            reminder1Day: false,
            reminder1Hour: false,
            isEnabled: false,
            onReminder1WeekChanged: (_) {},
            onReminder1DayChanged: (_) {},
            onReminder1HourChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.text('Rappels non disponibles pour les evenements passes'),
      findsOneWidget,
    );

    final checkboxes = tester.widgetList<CheckboxListTile>(
      find.byType(CheckboxListTile),
    ).toList();

    for (final checkbox in checkboxes) {
      expect(checkbox.onChanged, isNull);
    }
  });

  testWidgets('should call callbacks when checked', (tester) async {
    bool weekCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReminderSectionWidget(
            reminder1Week: false,
            reminder1Day: false,
            reminder1Hour: false,
            isEnabled: true,
            onReminder1WeekChanged: (_) => weekCalled = true,
            onReminder1DayChanged: (_) {},
            onReminder1HourChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('1 semaine avant'));
    expect(weekCalled, true);
  });
});
```

## Definition of Done
- [ ] Criteres valides
- [ ] Widget ReminderSectionWidget cree avec tests
- [ ] Integration dans event_form_page
- [ ] State management (cubit) mis a jour
- [ ] Multi-selection fonctionne
- [ ] Disabled state pour events passes
- [ ] `flutter analyze --fatal-infos` passe
- [ ] `flutter test` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Faible (UI standard Flutter)

## Dependances
- S04: Mettre a jour entite WeddingEvent en Dart (entity avec reminder fields)

## Stories Dependantes
- S06: Implementer scheduling des rappels dans repository (UI permet de sauvegarder les preferences)
