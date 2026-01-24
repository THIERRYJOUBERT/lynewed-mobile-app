# Story S22: My Wedding - Agenda/Budget/Guests

## Description

En tant que developpeur, je veux migrer les fonctionnalites Agenda, Budget et Guests vers Clean Architecture afin de completer le module My Wedding.

## Criteres d'Acceptance (Gherkin)

### Agenda
- [ ] Given la page Agenda When j'affiche les evenements Then la liste est ordonnee par date
- [ ] Given un nouvel evenement When je le cree Then il apparait dans l'agenda
- [ ] Given un evenement When je le marque comme fait Then son statut est mis a jour

### Budget
- [ ] Given la page Budget When j'affiche les depenses Then le total est calcule
- [ ] Given une nouvelle depense When je l'ajoute Then elle apparait dans la liste
- [ ] Given une depense When je la mets a jour Then les totaux sont recalcules

### Guests
- [ ] Given la page Guests When j'affiche les invites Then la liste est chargee
- [ ] Given un nouvel invite When je l'ajoute Then il apparait dans la liste

## Fichiers Concernes

### Existants (a migrer/verifier)
- `lib/features/my_wedding/presentation/pages/agenda_page.dart`
- `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart`
- `lib/features/my_wedding/presentation/pages/budget_page.dart`
- `lib/features/my_wedding/presentation/sheets/add_expense_sheet.dart`
- `lib/features/my_wedding/presentation/pages/guests_page.dart`
- `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart`

### A Creer
- `lib/features/my_wedding/presentation/bloc/agenda_cubit.dart`
- `lib/features/my_wedding/presentation/bloc/budget_cubit.dart`
- `lib/features/my_wedding/presentation/bloc/guests_cubit.dart`
- States correspondants

## Notes Techniques

### Agenda Cubit
```dart
class AgendaCubit extends Cubit<AgendaState> {
  final MyWeddingRepository _repository;
  final String weddingId;

  AgendaCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  }) : _repository = repository,
       super(const AgendaState()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getWeddingEvents(weddingId: weddingId);

    result.when(
      success: (events) => emit(state.copyWith(
        isLoading: false,
        events: events,
      )),
      failure: (error) => emit(state.copyWith(
        isLoading: false,
        error: error,
      )),
    );
  }

  Future<void> createEvent({
    required String title,
    required DateTime eventDate,
    String? description,
    DateTime? eventEndDate,
    String? location,
    String? linkedProId,
    bool isPublic = false,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.createWeddingEvent(
      weddingId: weddingId,
      title: title,
      eventDate: eventDate,
      description: description,
      eventEndDate: eventEndDate,
      location: location,
      linkedProId: linkedProId,
      isPublic: isPublic,
    );

    result.when(
      success: (event) {
        final updatedEvents = [...state.events, event]
            ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
        emit(state.copyWith(isLoading: false, events: updatedEvents));
      },
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }

  Future<void> toggleEventStatus(String eventId, String currentStatus) async {
    await _repository.toggleEventStatus(
      eventId: eventId,
      currentStatus: currentStatus,
    );

    // Update local state
    final updatedEvents = state.events.map((e) {
      if (e.id == eventId) {
        final newStatus = currentStatus == 'pending' ? 'done' : 'pending';
        return e.copyWith(status: newStatus);
      }
      return e;
    }).toList();

    emit(state.copyWith(events: updatedEvents));
  }

  Future<void> deleteEvent(String eventId) async {
    await _repository.deleteWeddingEvent(eventId: eventId);
    final updatedEvents = state.events.where((e) => e.id != eventId).toList();
    emit(state.copyWith(events: updatedEvents));
  }
}

class AgendaState {
  final List<WeddingEvent> events;
  final bool isLoading;
  final String? error;

  const AgendaState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  List<WeddingEvent> get upcomingEvents =>
      events.where((e) => e.eventDate.isAfter(DateTime.now())).toList();

  List<WeddingEvent> get pastEvents =>
      events.where((e) => e.eventDate.isBefore(DateTime.now())).toList();

  List<WeddingEvent> get pendingEvents =>
      events.where((e) => e.status == 'pending').toList();

  List<WeddingEvent> get completedEvents =>
      events.where((e) => e.status == 'done').toList();

  AgendaState copyWith({...});
}
```

### Budget Cubit
```dart
class BudgetCubit extends Cubit<BudgetState> {
  final MyWeddingRepository _repository;
  final String weddingId;
  final String currency;

  BudgetCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
    required this.currency,
  }) : _repository = repository,
       super(const BudgetState()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getWeddingExpenses(weddingId: weddingId);

    result.when(
      success: (expenses) => emit(state.copyWith(
        isLoading: false,
        expenses: expenses,
      )),
      failure: (error) => emit(state.copyWith(
        isLoading: false,
        error: error,
      )),
    );
  }

  Future<void> addExpense({
    required String category,
    required double amount,
    String? description,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
    String? linkedProId,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.createWeddingExpense(
      weddingId: weddingId,
      category: category,
      amount: amount,
      currencyCode: currency,
      description: description,
      status: status,
      paidAmount: paidAmount,
      dueDate: dueDate,
      linkedProId: linkedProId,
    );

    result.when(
      success: (expense) {
        final updatedExpenses = [...state.expenses, expense];
        emit(state.copyWith(isLoading: false, expenses: updatedExpenses));
      },
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }

  Future<void> updateExpense({
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    String? status,
    double? paidAmount,
    DateTime? dueDate,
  }) async {
    await _repository.updateWeddingExpense(
      expenseId: expenseId,
      category: category,
      description: description,
      amount: amount,
      status: status,
      paidAmount: paidAmount,
      dueDate: dueDate,
    );

    loadExpenses(); // Reload to get updated data
  }

  Future<void> deleteExpense(String expenseId) async {
    await _repository.deleteWeddingExpense(expenseId: expenseId);
    final updatedExpenses = state.expenses.where((e) => e.id != expenseId).toList();
    emit(state.copyWith(expenses: updatedExpenses));
  }
}

class BudgetState {
  final List<WeddingExpense> expenses;
  final bool isLoading;
  final String? error;

  const BudgetState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalBudget => expenses.fold(0, (sum, e) => sum + e.amount);
  double get totalPaid => expenses.fold(0, (sum, e) => sum + (e.paidAmount ?? 0));
  double get totalRemaining => totalBudget - totalPaid;

  Map<String, double> get expensesByCategory {
    final map = <String, double>{};
    for (final expense in expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  BudgetState copyWith({...});
}
```

### Guests Cubit
```dart
class GuestsCubit extends Cubit<GuestsState> {
  final MyWeddingRepository _repository;
  final String weddingId;

  GuestsCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  }) : _repository = repository,
       super(const GuestsState()) {
    loadGuests();
  }

  Future<void> loadGuests() async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.getWeddingGuests(weddingId: weddingId);

    result.when(
      success: (guests) => emit(state.copyWith(
        isLoading: false,
        guests: guests,
      )),
      failure: (error) => emit(state.copyWith(
        isLoading: false,
        error: error,
      )),
    );
  }

  Future<void> addGuest({
    required String name,
    String? email,
    String? phone,
    String? role,
    String? notes,
  }) async {
    emit(state.copyWith(isLoading: true));

    final result = await _repository.createWeddingGuest(
      weddingId: weddingId,
      name: name,
      email: email,
      phone: phone,
      role: role,
      notes: notes,
    );

    result.when(
      success: (guest) {
        final updatedGuests = [...state.guests, guest];
        emit(state.copyWith(isLoading: false, guests: updatedGuests));
      },
      failure: (error) => emit(state.copyWith(isLoading: false, error: error)),
    );
  }

  Future<void> deleteGuest(String guestId) async {
    await _repository.deleteWeddingGuest(guestId: guestId);
    final updatedGuests = state.guests.where((g) => g.id != guestId).toList();
    emit(state.copyWith(guests: updatedGuests));
  }
}

class GuestsState {
  final List<WeddingGuest> guests;
  final bool isLoading;
  final String? error;

  const GuestsState({
    this.guests = const [],
    this.isLoading = false,
    this.error,
  });

  int get totalGuests => guests.length;

  GuestsState copyWith({...});
}
```

## Definition of Done

- [ ] AgendaCubit + AgendaState implementes
- [ ] BudgetCubit + BudgetState implementes
- [ ] GuestsCubit + GuestsState implementes
- [ ] Pages migrees et utilisant les Cubits
- [ ] Sheets migres (add event, add expense, add guest)
- [ ] Tests bloc
- [ ] `flutter analyze --fatal-infos` passe

## Estimation

**Points** : 8
**Complexite** : Moyenne
**Risque** : Faible

## Dependances

- S03 : Design system
- S17 : My Wedding - Domain
- S18 : My Wedding - Data

## Stories Dependantes

- Aucune (module complet)
