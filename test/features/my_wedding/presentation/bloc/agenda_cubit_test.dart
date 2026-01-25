/// Tests for AgendaCubit and AgendaState.
///
/// Comprehensive tests covering:
/// - State creation and manipulation
/// - All cubit methods (loadEvents, createEvent, toggleEventStatus, deleteEvent)
/// - Computed properties (upcomingEvents, pastEvents, pendingEvents, completedEvents)
/// - Error handling
/// - Edge cases
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_event.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/agenda_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/agenda_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  group('AgendaState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = AgendaState();

        expect(state.events, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should create with provided values', () {
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Venue Visit',
          eventDate: DateTime(2025, 6, 15),
        );

        final state = AgendaState(
          events: [event],
          isLoading: true,
          error: 'Some error',
        );

        expect(state.events, [event]);
        expect(state.isLoading, true);
        expect(state.error, 'Some error');
      });
    });

    group('computed properties', () {
      test('upcomingEvents should return events in the future', () {
        final futureEvent = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Future Event',
          eventDate: DateTime.now().add(const Duration(days: 30)),
        );
        final pastEvent = WeddingEvent(
          id: 'event-2',
          weddingId: 'wedding-1',
          title: 'Past Event',
          eventDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        final state = AgendaState(events: [futureEvent, pastEvent]);

        expect(state.upcomingEvents, [futureEvent]);
      });

      test('pastEvents should return events in the past', () {
        final futureEvent = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Future Event',
          eventDate: DateTime.now().add(const Duration(days: 30)),
        );
        final pastEvent = WeddingEvent(
          id: 'event-2',
          weddingId: 'wedding-1',
          title: 'Past Event',
          eventDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        final state = AgendaState(events: [futureEvent, pastEvent]);

        expect(state.pastEvents, [pastEvent]);
      });

      test('pendingEvents should return events with pending status', () {
        final pendingEvent = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Pending Event',
          eventDate: DateTime.now(),
          status: EventStatus.pending,
        );
        final doneEvent = WeddingEvent(
          id: 'event-2',
          weddingId: 'wedding-1',
          title: 'Done Event',
          eventDate: DateTime.now(),
          status: EventStatus.done,
        );

        final state = AgendaState(events: [pendingEvent, doneEvent]);

        expect(state.pendingEvents, [pendingEvent]);
      });

      test('completedEvents should return events with done status', () {
        final pendingEvent = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Pending Event',
          eventDate: DateTime.now(),
          status: EventStatus.pending,
        );
        final doneEvent = WeddingEvent(
          id: 'event-2',
          weddingId: 'wedding-1',
          title: 'Done Event',
          eventDate: DateTime.now(),
          status: EventStatus.done,
        );

        final state = AgendaState(events: [pendingEvent, doneEvent]);

        expect(state.completedEvents, [doneEvent]);
      });

      test('should return empty lists when no events', () {
        const state = AgendaState();

        expect(state.upcomingEvents, isEmpty);
        expect(state.pastEvents, isEmpty);
        expect(state.pendingEvents, isEmpty);
        expect(state.completedEvents, isEmpty);
      });
    });

    group('copyWith', () {
      test('should copy with new events', () {
        const original = AgendaState();
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'New Event',
          eventDate: DateTime.now(),
        );
        final copied = original.copyWith(events: [event]);

        expect(copied.events, [event]);
        expect(copied.isLoading, false);
        expect(copied.error, isNull);
      });

      test('should copy with new isLoading', () {
        const original = AgendaState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with new error', () {
        const original = AgendaState();
        final copied = original.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should clear error with clearError flag', () {
        const original = AgendaState(error: 'Previous error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should preserve unchanged values', () {
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Event',
          eventDate: DateTime.now(),
        );
        final state = AgendaState(
          events: [event],
          isLoading: true,
        );
        final copied = state.copyWith(error: 'New error');

        expect(copied.events, [event]);
        expect(copied.isLoading, true);
        expect(copied.error, 'New error');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final event = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Event',
          eventDate: DateTime(2025, 6, 15),
        );
        final state1 = AgendaState(events: [event]);
        final state2 = AgendaState(events: [event]);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different events', () {
        final event1 = WeddingEvent(
          id: 'event-1',
          weddingId: 'wedding-1',
          title: 'Event 1',
          eventDate: DateTime(2025, 6, 15),
        );
        final event2 = WeddingEvent(
          id: 'event-2',
          weddingId: 'wedding-1',
          title: 'Event 2',
          eventDate: DateTime(2025, 6, 15),
        );
        final state1 = AgendaState(events: [event1]);
        final state2 = AgendaState(events: [event2]);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different isLoading', () {
        const state1 = AgendaState(isLoading: true);
        const state2 = AgendaState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different error', () {
        const state1 = AgendaState(error: 'Error 1');
        const state2 = AgendaState(error: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('AgendaCubit', () {
    late MockMyWeddingRepository mockRepository;
    const testWeddingId = 'wedding-123';

    final testEvents = [
      WeddingEvent(
        id: 'event-1',
        weddingId: testWeddingId,
        title: 'Venue Visit',
        eventDate: DateTime.now().add(const Duration(days: 30)),
        status: EventStatus.pending,
      ),
      WeddingEvent(
        id: 'event-2',
        weddingId: testWeddingId,
        title: 'Dress Fitting',
        eventDate: DateTime.now().add(const Duration(days: 60)),
        status: EventStatus.done,
      ),
    ];

    setUp(() {
      mockRepository = MockMyWeddingRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = AgendaCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        );

        expect(cubit.state.events, isEmpty);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
        expect(cubit.weddingId, testWeddingId);

        cubit.close();
      });
    });

    group('loadEvents', () {
      blocTest<AgendaCubit, AgendaState>(
        'should emit loading state then loaded state on success',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testEvents));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          const AgendaState(isLoading: true),
          AgendaState(
            isLoading: false,
            events: testEvents,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .called(1);
        },
      );

      blocTest<AgendaCubit, AgendaState>(
        'should emit error state on failure',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Network error'));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          const AgendaState(isLoading: true),
          const AgendaState(isLoading: false, error: 'Network error'),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should handle empty events list',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          const AgendaState(isLoading: true),
          const AgendaState(isLoading: false, events: []),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should clear error when reloading events',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testEvents));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => const AgendaState(error: 'Previous error'),
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          const AgendaState(isLoading: true),
          AgendaState(isLoading: false, events: testEvents),
        ],
      );
    });

    group('createEvent', () {
      final newEventDate = DateTime(2025, 7, 20);

      blocTest<AgendaCubit, AgendaState>(
        'should create event and add it to the list',
        build: () {
          final newEvent = WeddingEvent(
            id: 'event-3',
            weddingId: testWeddingId,
            title: 'Cake Tasting',
            eventDate: newEventDate,
          );
          when(() => mockRepository.createWeddingEvent(
                weddingId: testWeddingId,
                title: 'Cake Tasting',
                eventDate: newEventDate,
                description: null,
                eventEndDate: null,
                location: null,
                linkedProId: null,
                isPublic: false,
              )).thenAnswer((_) async => RepositoryResult.success(newEvent));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.createEvent(
          title: 'Cake Tasting',
          eventDate: newEventDate,
        ),
        expect: () => [
          const AgendaState(isLoading: true),
          isA<AgendaState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.events.length, 'events.length', 1)
              .having((s) => s.events.first.title, 'events.first.title', 'Cake Tasting'),
        ],
        verify: (_) {
          verify(() => mockRepository.createWeddingEvent(
                weddingId: testWeddingId,
                title: 'Cake Tasting',
                eventDate: newEventDate,
                description: null,
                eventEndDate: null,
                location: null,
                linkedProId: null,
                isPublic: false,
              )).called(1);
        },
      );

      blocTest<AgendaCubit, AgendaState>(
        'should create event with all optional parameters',
        build: () {
          final endDate = DateTime(2025, 7, 20, 18, 0);
          final newEvent = WeddingEvent(
            id: 'event-3',
            weddingId: testWeddingId,
            title: 'Venue Visit',
            eventDate: newEventDate,
            description: 'Visit the main venue',
            eventEndDate: endDate,
            location: 'Paris',
            linkedProId: 'pro-1',
            isPublic: true,
          );
          when(() => mockRepository.createWeddingEvent(
                weddingId: testWeddingId,
                title: 'Venue Visit',
                eventDate: newEventDate,
                description: 'Visit the main venue',
                eventEndDate: endDate,
                location: 'Paris',
                linkedProId: 'pro-1',
                isPublic: true,
              )).thenAnswer((_) async => RepositoryResult.success(newEvent));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.createEvent(
          title: 'Venue Visit',
          eventDate: newEventDate,
          description: 'Visit the main venue',
          eventEndDate: DateTime(2025, 7, 20, 18, 0),
          location: 'Paris',
          linkedProId: 'pro-1',
          isPublic: true,
        ),
        expect: () => [
          const AgendaState(isLoading: true),
          isA<AgendaState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.events.first.description, 'description', 'Visit the main venue')
              .having((s) => s.events.first.location, 'location', 'Paris')
              .having((s) => s.events.first.isPublic, 'isPublic', true),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should emit error state on creation failure',
        build: () {
          when(() => mockRepository.createWeddingEvent(
                weddingId: testWeddingId,
                title: 'Cake Tasting',
                eventDate: newEventDate,
                description: null,
                eventEndDate: null,
                location: null,
                linkedProId: null,
                isPublic: false,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Creation failed'));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.createEvent(
          title: 'Cake Tasting',
          eventDate: newEventDate,
        ),
        expect: () => [
          const AgendaState(isLoading: true),
          const AgendaState(isLoading: false, error: 'Creation failed'),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should add event to existing list',
        build: () {
          final newEvent = WeddingEvent(
            id: 'event-3',
            weddingId: testWeddingId,
            title: 'Third Event',
            eventDate: newEventDate,
          );
          when(() => mockRepository.createWeddingEvent(
                weddingId: testWeddingId,
                title: 'Third Event',
                eventDate: newEventDate,
                description: null,
                eventEndDate: null,
                location: null,
                linkedProId: null,
                isPublic: false,
              )).thenAnswer((_) async => RepositoryResult.success(newEvent));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.createEvent(
          title: 'Third Event',
          eventDate: newEventDate,
        ),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          isA<AgendaState>()
              .having((s) => s.events.length, 'events.length', 3)
              .having((s) => s.events.last.title, 'events.last.title', 'Third Event'),
        ],
      );
    });

    group('toggleEventStatus', () {
      blocTest<AgendaCubit, AgendaState>(
        'should toggle event from pending to done',
        build: () {
          when(() => mockRepository.toggleEventStatus(
                eventId: 'event-1',
                currentStatus: 'pending',
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.toggleEventStatus('event-1', 'pending'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          isA<AgendaState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.events.firstWhere((e) => e.id == 'event-1').status,
                'event-1 status',
                EventStatus.done,
              ),
        ],
        verify: (_) {
          verify(() => mockRepository.toggleEventStatus(
                eventId: 'event-1',
                currentStatus: 'pending',
              )).called(1);
        },
      );

      blocTest<AgendaCubit, AgendaState>(
        'should toggle event from done to pending',
        build: () {
          when(() => mockRepository.toggleEventStatus(
                eventId: 'event-2',
                currentStatus: 'done',
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.toggleEventStatus('event-2', 'done'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          isA<AgendaState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.events.firstWhere((e) => e.id == 'event-2').status,
                'event-2 status',
                EventStatus.pending,
              ),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should emit error state on toggle failure',
        build: () {
          when(() => mockRepository.toggleEventStatus(
                eventId: 'event-1',
                currentStatus: 'pending',
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Toggle failed'));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.toggleEventStatus('event-1', 'pending'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          AgendaState(
            events: testEvents,
            isLoading: false,
            error: 'Toggle failed',
          ),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should handle toggling non-existent event gracefully',
        build: () {
          when(() => mockRepository.toggleEventStatus(
                eventId: 'non-existent',
                currentStatus: 'pending',
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.toggleEventStatus('non-existent', 'pending'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          AgendaState(events: testEvents, isLoading: false),
        ],
      );
    });

    group('deleteEvent', () {
      blocTest<AgendaCubit, AgendaState>(
        'should delete event and remove it from list',
        build: () {
          when(() => mockRepository.deleteWeddingEvent(eventId: 'event-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.deleteEvent('event-1'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          AgendaState(
            events: [testEvents[1]],
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteWeddingEvent(eventId: 'event-1'))
              .called(1);
        },
      );

      blocTest<AgendaCubit, AgendaState>(
        'should emit error state on deletion failure',
        build: () {
          when(() => mockRepository.deleteWeddingEvent(eventId: 'event-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Deletion failed'));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.deleteEvent('event-1'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          AgendaState(
            events: testEvents,
            isLoading: false,
            error: 'Deletion failed',
          ),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should handle deleting non-existent event gracefully',
        build: () {
          when(() => mockRepository.deleteWeddingEvent(eventId: 'non-existent'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: testEvents),
        act: (cubit) => cubit.deleteEvent('non-existent'),
        expect: () => [
          AgendaState(events: testEvents, isLoading: true),
          AgendaState(events: testEvents, isLoading: false),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should handle deleting last event',
        build: () {
          when(() => mockRepository.deleteWeddingEvent(eventId: 'event-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => AgendaState(events: [testEvents.first]),
        act: (cubit) => cubit.deleteEvent('event-1'),
        expect: () => [
          AgendaState(events: [testEvents.first], isLoading: true),
          const AgendaState(events: [], isLoading: false),
        ],
      );
    });

    group('clearError', () {
      blocTest<AgendaCubit, AgendaState>(
        'should clear error state',
        build: () => AgendaCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => const AgendaState(error: 'Some error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const AgendaState(error: null),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should preserve other state when clearing error',
        build: () => AgendaCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => AgendaState(
          events: testEvents,
          isLoading: false,
          error: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          AgendaState(
            events: testEvents,
            isLoading: false,
            error: null,
          ),
        ],
      );
    });

    group('edge cases', () {
      blocTest<AgendaCubit, AgendaState>(
        'should handle null data from repository',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          const AgendaState(isLoading: true),
          const AgendaState(isLoading: false, events: []),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should handle generic error message',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.failure(''));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => [
          const AgendaState(isLoading: true),
          isA<AgendaState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );

      blocTest<AgendaCubit, AgendaState>(
        'should handle sequential operations',
        build: () {
          when(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testEvents));
          return AgendaCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) async {
          await cubit.loadEvents();
          await cubit.loadEvents();
        },
        expect: () => [
          const AgendaState(isLoading: true),
          AgendaState(isLoading: false, events: testEvents),
          AgendaState(isLoading: true, events: testEvents),
          AgendaState(isLoading: false, events: testEvents),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingEvents(weddingId: testWeddingId))
              .called(2);
        },
      );
    });
  });
}

// Helper to avoid needing to import dart:async
void unawaited(Future<void>? future) {}
