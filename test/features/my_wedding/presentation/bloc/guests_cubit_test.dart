/// Tests for GuestsCubit and GuestsState.
///
/// Comprehensive tests covering:
/// - State creation and manipulation
/// - All cubit methods (loadGuests, addGuest, deleteGuest)
/// - Computed properties (totalGuests)
/// - Error handling
/// - Edge cases
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_guest.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/guests_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/guests_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  group('GuestsState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = GuestsState();

        expect(state.guests, isEmpty);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should create with provided values', () {
        final guest = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
          email: 'john@example.com',
        );

        final state = GuestsState(
          guests: [guest],
          isLoading: true,
          error: 'Some error',
        );

        expect(state.guests, [guest]);
        expect(state.isLoading, true);
        expect(state.error, 'Some error');
      });
    });

    group('computed properties', () {
      test('totalGuests should return count of all guests', () {
        final guest1 = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
        );
        final guest2 = WeddingGuest(
          id: 'guest-2',
          weddingId: 'wedding-1',
          name: 'Jane Doe',
        );
        final guest3 = WeddingGuest(
          id: 'guest-3',
          weddingId: 'wedding-1',
          name: 'Bob Smith',
        );

        final state = GuestsState(guests: [guest1, guest2, guest3]);

        expect(state.totalGuests, 3);
      });

      test('totalGuests should return 0 when no guests', () {
        const state = GuestsState();

        expect(state.totalGuests, 0);
      });

      test('guestsByRole should group guests by role', () {
        final guest1 = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
          role: GuestRole.guest,
        );
        final guest2 = WeddingGuest(
          id: 'guest-2',
          weddingId: 'wedding-1',
          name: 'Jane Doe',
          role: GuestRole.bridesmaid,
        );
        final guest3 = WeddingGuest(
          id: 'guest-3',
          weddingId: 'wedding-1',
          name: 'Bob Smith',
          role: GuestRole.family,
        );
        final guest4 = WeddingGuest(
          id: 'guest-4',
          weddingId: 'wedding-1',
          name: 'Alice Smith',
          role: GuestRole.family,
        );

        final state = GuestsState(guests: [guest1, guest2, guest3, guest4]);

        expect(state.guestsByRole[GuestRole.guest], [guest1]);
        expect(state.guestsByRole[GuestRole.bridesmaid], [guest2]);
        expect(state.guestsByRole[GuestRole.family]?.length, 2);
      });

      test('guestsByRole should return empty map when no guests', () {
        const state = GuestsState();

        expect(state.guestsByRole, isEmpty);
      });
    });

    group('copyWith', () {
      test('should copy with new guests', () {
        const original = GuestsState();
        final guest = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
        );
        final copied = original.copyWith(guests: [guest]);

        expect(copied.guests, [guest]);
        expect(copied.isLoading, false);
        expect(copied.error, isNull);
      });

      test('should copy with new isLoading', () {
        const original = GuestsState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with new error', () {
        const original = GuestsState();
        final copied = original.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should clear error with clearError flag', () {
        const original = GuestsState(error: 'Previous error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should preserve unchanged values', () {
        final guest = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
        );
        final state = GuestsState(
          guests: [guest],
          isLoading: true,
        );
        final copied = state.copyWith(error: 'New error');

        expect(copied.guests, [guest]);
        expect(copied.isLoading, true);
        expect(copied.error, 'New error');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final guest = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
        );
        final state1 = GuestsState(guests: [guest]);
        final state2 = GuestsState(guests: [guest]);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different guests', () {
        final guest1 = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          name: 'John Doe',
        );
        final guest2 = WeddingGuest(
          id: 'guest-2',
          weddingId: 'wedding-1',
          name: 'Jane Doe',
        );
        final state1 = GuestsState(guests: [guest1]);
        final state2 = GuestsState(guests: [guest2]);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different isLoading', () {
        const state1 = GuestsState(isLoading: true);
        const state2 = GuestsState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different error', () {
        const state1 = GuestsState(error: 'Error 1');
        const state2 = GuestsState(error: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('GuestsCubit', () {
    late MockMyWeddingRepository mockRepository;
    const testWeddingId = 'wedding-123';

    final testGuests = [
      WeddingGuest(
        id: 'guest-1',
        weddingId: testWeddingId,
        name: 'John Doe',
        email: 'john@example.com',
        role: GuestRole.guest,
      ),
      WeddingGuest(
        id: 'guest-2',
        weddingId: testWeddingId,
        name: 'Jane Doe',
        email: 'jane@example.com',
        role: GuestRole.bridesmaid,
      ),
    ];

    setUp(() {
      mockRepository = MockMyWeddingRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = GuestsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        );

        expect(cubit.state.guests, isEmpty);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
        expect(cubit.weddingId, testWeddingId);

        cubit.close();
      });
    });

    group('loadGuests', () {
      blocTest<GuestsCubit, GuestsState>(
        'should emit loading state then loaded state on success',
        build: () {
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testGuests));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadGuests(),
        expect: () => [
          const GuestsState(isLoading: true),
          GuestsState(
            isLoading: false,
            guests: testGuests,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .called(1);
        },
      );

      blocTest<GuestsCubit, GuestsState>(
        'should emit error state on failure',
        build: () {
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Network error'));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadGuests(),
        expect: () => [
          const GuestsState(isLoading: true),
          const GuestsState(isLoading: false, error: 'Network error'),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should handle empty guests list',
        build: () {
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadGuests(),
        expect: () => [
          const GuestsState(isLoading: true),
          const GuestsState(isLoading: false, guests: []),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should clear error when reloading guests',
        build: () {
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testGuests));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => const GuestsState(error: 'Previous error'),
        act: (cubit) => cubit.loadGuests(),
        expect: () => [
          const GuestsState(isLoading: true),
          GuestsState(isLoading: false, guests: testGuests),
        ],
      );
    });

    group('addGuest', () {
      blocTest<GuestsCubit, GuestsState>(
        'should add guest and add it to the list',
        build: () {
          final newGuest = WeddingGuest(
            id: 'guest-3',
            weddingId: testWeddingId,
            name: 'Bob Smith',
          );
          when(() => mockRepository.createWeddingGuest(
                weddingId: testWeddingId,
                name: 'Bob Smith',
                email: null,
                phone: null,
                role: null,
                notes: null,
              )).thenAnswer((_) async => RepositoryResult.success(newGuest));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.addGuest(name: 'Bob Smith'),
        expect: () => [
          const GuestsState(isLoading: true),
          isA<GuestsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.guests.length, 'guests.length', 1)
              .having((s) => s.guests.first.name, 'guests.first.name', 'Bob Smith'),
        ],
        verify: (_) {
          verify(() => mockRepository.createWeddingGuest(
                weddingId: testWeddingId,
                name: 'Bob Smith',
                email: null,
                phone: null,
                role: null,
                notes: null,
              )).called(1);
        },
      );

      blocTest<GuestsCubit, GuestsState>(
        'should add guest with all optional parameters',
        build: () {
          final newGuest = WeddingGuest(
            id: 'guest-3',
            weddingId: testWeddingId,
            name: 'Bob Smith',
            email: 'bob@example.com',
            phone: '+33612345678',
            role: GuestRole.bestMan,
            notes: 'Groom\'s brother',
          );
          when(() => mockRepository.createWeddingGuest(
                weddingId: testWeddingId,
                name: 'Bob Smith',
                email: 'bob@example.com',
                phone: '+33612345678',
                role: 'bestMan',
                notes: 'Groom\'s brother',
              )).thenAnswer((_) async => RepositoryResult.success(newGuest));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.addGuest(
          name: 'Bob Smith',
          email: 'bob@example.com',
          phone: '+33612345678',
          role: 'bestMan',
          notes: 'Groom\'s brother',
        ),
        expect: () => [
          const GuestsState(isLoading: true),
          isA<GuestsState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.guests.first.email, 'email', 'bob@example.com')
              .having((s) => s.guests.first.role, 'role', GuestRole.bestMan),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should emit error state on add failure',
        build: () {
          when(() => mockRepository.createWeddingGuest(
                weddingId: testWeddingId,
                name: 'Bob Smith',
                email: null,
                phone: null,
                role: null,
                notes: null,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Creation failed'));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.addGuest(name: 'Bob Smith'),
        expect: () => [
          const GuestsState(isLoading: true),
          const GuestsState(isLoading: false, error: 'Creation failed'),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should add guest to existing list',
        build: () {
          final newGuest = WeddingGuest(
            id: 'guest-3',
            weddingId: testWeddingId,
            name: 'Bob Smith',
          );
          when(() => mockRepository.createWeddingGuest(
                weddingId: testWeddingId,
                name: 'Bob Smith',
                email: null,
                phone: null,
                role: null,
                notes: null,
              )).thenAnswer((_) async => RepositoryResult.success(newGuest));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => GuestsState(guests: testGuests),
        act: (cubit) => cubit.addGuest(name: 'Bob Smith'),
        expect: () => [
          GuestsState(guests: testGuests, isLoading: true),
          isA<GuestsState>()
              .having((s) => s.guests.length, 'guests.length', 3)
              .having((s) => s.guests.last.name, 'guests.last.name', 'Bob Smith'),
        ],
      );
    });

    group('deleteGuest', () {
      blocTest<GuestsCubit, GuestsState>(
        'should delete guest and remove it from list',
        build: () {
          when(() => mockRepository.deleteWeddingGuest(guestId: 'guest-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => GuestsState(guests: testGuests),
        act: (cubit) => cubit.deleteGuest('guest-1'),
        expect: () => [
          GuestsState(guests: testGuests, isLoading: true),
          GuestsState(
            guests: [testGuests[1]],
            isLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteWeddingGuest(guestId: 'guest-1'))
              .called(1);
        },
      );

      blocTest<GuestsCubit, GuestsState>(
        'should emit error state on deletion failure',
        build: () {
          when(() => mockRepository.deleteWeddingGuest(guestId: 'guest-1'))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Deletion failed'));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => GuestsState(guests: testGuests),
        act: (cubit) => cubit.deleteGuest('guest-1'),
        expect: () => [
          GuestsState(guests: testGuests, isLoading: true),
          GuestsState(
            guests: testGuests,
            isLoading: false,
            error: 'Deletion failed',
          ),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should handle deleting non-existent guest gracefully',
        build: () {
          when(() => mockRepository.deleteWeddingGuest(guestId: 'non-existent'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => GuestsState(guests: testGuests),
        act: (cubit) => cubit.deleteGuest('non-existent'),
        expect: () => [
          GuestsState(guests: testGuests, isLoading: true),
          GuestsState(guests: testGuests, isLoading: false),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should handle deleting last guest',
        build: () {
          when(() => mockRepository.deleteWeddingGuest(guestId: 'guest-1'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        seed: () => GuestsState(guests: [testGuests.first]),
        act: (cubit) => cubit.deleteGuest('guest-1'),
        expect: () => [
          GuestsState(guests: [testGuests.first], isLoading: true),
          const GuestsState(guests: [], isLoading: false),
        ],
      );
    });

    group('clearError', () {
      blocTest<GuestsCubit, GuestsState>(
        'should clear error state',
        build: () => GuestsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => const GuestsState(error: 'Some error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const GuestsState(error: null),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should preserve other state when clearing error',
        build: () => GuestsCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => GuestsState(
          guests: testGuests,
          isLoading: false,
          error: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          GuestsState(
            guests: testGuests,
            isLoading: false,
            error: null,
          ),
        ],
      );
    });

    group('edge cases', () {
      blocTest<GuestsCubit, GuestsState>(
        'should handle null data from repository',
        build: () {
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadGuests(),
        expect: () => [
          const GuestsState(isLoading: true),
          const GuestsState(isLoading: false, guests: []),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should handle large guest list',
        build: () {
          final largeGuestList = List.generate(
            500,
            (index) => WeddingGuest(
              id: 'guest-$index',
              weddingId: testWeddingId,
              name: 'Guest $index',
            ),
          );
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(largeGuestList));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadGuests(),
        expect: () => [
          const GuestsState(isLoading: true),
          isA<GuestsState>()
              .having((s) => s.totalGuests, 'totalGuests', 500)
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<GuestsCubit, GuestsState>(
        'should handle sequential operations',
        build: () {
          when(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testGuests));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) async {
          await cubit.loadGuests();
          await cubit.loadGuests();
        },
        expect: () => [
          const GuestsState(isLoading: true),
          GuestsState(isLoading: false, guests: testGuests),
          GuestsState(isLoading: true, guests: testGuests),
          GuestsState(isLoading: false, guests: testGuests),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingGuests(weddingId: testWeddingId))
              .called(2);
        },
      );

      blocTest<GuestsCubit, GuestsState>(
        'should handle add then delete operations',
        build: () {
          final newGuest = WeddingGuest(
            id: 'guest-new',
            weddingId: testWeddingId,
            name: 'New Guest',
          );
          when(() => mockRepository.createWeddingGuest(
                weddingId: testWeddingId,
                name: 'New Guest',
                email: null,
                phone: null,
                role: null,
                notes: null,
              )).thenAnswer((_) async => RepositoryResult.success(newGuest));
          when(() => mockRepository.deleteWeddingGuest(guestId: 'guest-new'))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return GuestsCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) async {
          await cubit.addGuest(name: 'New Guest');
          await cubit.deleteGuest('guest-new');
        },
        expect: () => [
          const GuestsState(isLoading: true),
          isA<GuestsState>()
              .having((s) => s.guests.length, 'guests.length', 1)
              .having((s) => s.guests.first.name, 'first.name', 'New Guest'),
          isA<GuestsState>().having((s) => s.isLoading, 'isLoading', true),
          const GuestsState(guests: [], isLoading: false),
        ],
      );
    });
  });
}
