import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  group('CubitOnboardingData', () {
    group('creation', () {
      test('should create with default values', () {
        const data = CubitOnboardingData();

        expect(data.eventDate, isNull);
        expect(data.venueName, isNull);
        expect(data.venueAddress, isNull);
        expect(data.lat, isNull);
        expect(data.lng, isNull);
        expect(data.countryCode, isNull);
        expect(data.professionsNeeded, isEmpty);
        expect(data.guestCount, isNull);
        expect(data.budgetMin, isNull);
        expect(data.budgetMax, isNull);
        expect(data.visibility, 'private');
        expect(data.searchRadius, 50);
        expect(data.coverImageUrl, isNull);
      });

      test('should create with provided values', () {
        final eventDate = DateTime(2025, 6, 15);
        final data = CubitOnboardingData(
          eventDate: eventDate,
          venueName: 'Test Venue',
          venueAddress: '123 Main St',
          lat: 48.8566,
          lng: 2.3522,
          countryCode: 'FR',
          professionsNeeded: ['PHOTOGRAPHER', 'DJ'],
          guestCount: 150,
          budgetMin: 10000,
          budgetMax: 25000,
          visibility: 'visible_to_pros',
          searchRadius: 100,
          coverImageUrl: 'https://example.com/cover.jpg',
        );

        expect(data.eventDate, eventDate);
        expect(data.venueName, 'Test Venue');
        expect(data.venueAddress, '123 Main St');
        expect(data.lat, 48.8566);
        expect(data.lng, 2.3522);
        expect(data.countryCode, 'FR');
        expect(data.professionsNeeded, ['PHOTOGRAPHER', 'DJ']);
        expect(data.guestCount, 150);
        expect(data.budgetMin, 10000);
        expect(data.budgetMax, 25000);
        expect(data.visibility, 'visible_to_pros');
        expect(data.searchRadius, 100);
        expect(data.coverImageUrl, 'https://example.com/cover.jpg');
      });
    });

    group('copyWith', () {
      test('should copy with new eventDate', () {
        final original = CubitOnboardingData(eventDate: DateTime(2025, 1, 1));
        final newDate = DateTime(2025, 6, 15);
        final copied = original.copyWith(eventDate: newDate);

        expect(copied.eventDate, newDate);
      });

      test('should copy with new venue data', () {
        const original = CubitOnboardingData();
        final copied = original.copyWith(
          venueAddress: '123 Main St',
          lat: 48.8566,
          lng: 2.3522,
          countryCode: 'FR',
        );

        expect(copied.venueAddress, '123 Main St');
        expect(copied.lat, 48.8566);
        expect(copied.lng, 2.3522);
        expect(copied.countryCode, 'FR');
      });

      test('should preserve unchanged values', () {
        final original = CubitOnboardingData(
          eventDate: DateTime(2025, 1, 1),
          guestCount: 100,
        );
        final copied = original.copyWith(budgetMin: 5000);

        expect(copied.eventDate, original.eventDate);
        expect(copied.guestCount, 100);
        expect(copied.budgetMin, 5000);
      });

      test('should allow setting values to null', () {
        final original = CubitOnboardingData(
          eventDate: DateTime(2025, 1, 1),
          guestCount: 100,
        );
        final copied = original.copyWith(
          eventDate: null,
          setEventDateNull: true,
        );

        expect(copied.eventDate, isNull);
        expect(copied.guestCount, 100);
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final date = DateTime(2025, 6, 15);
        final data1 = CubitOnboardingData(
          eventDate: date,
          guestCount: 100,
        );
        final data2 = CubitOnboardingData(
          eventDate: date,
          guestCount: 100,
        );

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('should not be equal with different values', () {
        final data1 = CubitOnboardingData(
          eventDate: DateTime(2025, 6, 15),
          guestCount: 100,
        );
        final data2 = CubitOnboardingData(
          eventDate: DateTime(2025, 6, 15),
          guestCount: 150,
        );

        expect(data1, isNot(equals(data2)));
      });
    });
  });

  group('WeddingOnboardingState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = WeddingOnboardingState();

        expect(state.currentStep, 1);
        expect(state.totalSteps, 7);
        expect(state.weddingId, isNull);
        expect(state.data, const CubitOnboardingData());
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should create with provided values', () {
        const data = CubitOnboardingData(guestCount: 100);
        const state = WeddingOnboardingState(
          currentStep: 3,
          weddingId: 'wedding-123',
          data: data,
          isLoading: true,
          error: 'Some error',
        );

        expect(state.currentStep, 3);
        expect(state.totalSteps, 7);
        expect(state.weddingId, 'wedding-123');
        expect(state.data.guestCount, 100);
        expect(state.isLoading, true);
        expect(state.error, 'Some error');
      });
    });

    group('computed properties', () {
      test('isFirstStep should return true when currentStep is 1', () {
        const state = WeddingOnboardingState(currentStep: 1);
        expect(state.isFirstStep, true);
      });

      test('isFirstStep should return false when currentStep is not 1', () {
        const state = WeddingOnboardingState(currentStep: 3);
        expect(state.isFirstStep, false);
      });

      test('isLastStep should return true when currentStep equals totalSteps', () {
        const state = WeddingOnboardingState(currentStep: 7);
        expect(state.isLastStep, true);
      });

      test('isLastStep should return false when currentStep is not last', () {
        const state = WeddingOnboardingState(currentStep: 5);
        expect(state.isLastStep, false);
      });

      test('progress should return correct fraction', () {
        const state1 = WeddingOnboardingState(currentStep: 1);
        expect(state1.progress, closeTo(1 / 7, 0.001));

        const state2 = WeddingOnboardingState(currentStep: 4);
        expect(state2.progress, closeTo(4 / 7, 0.001));

        const state3 = WeddingOnboardingState(currentStep: 7);
        expect(state3.progress, closeTo(1.0, 0.001));
      });
    });

    group('copyWith', () {
      test('should copy with new currentStep', () {
        const original = WeddingOnboardingState(currentStep: 2);
        final copied = original.copyWith(currentStep: 5);

        expect(copied.currentStep, 5);
        expect(copied.totalSteps, 7); // Should remain unchanged
      });

      test('should copy with new weddingId', () {
        const original = WeddingOnboardingState();
        final copied = original.copyWith(weddingId: 'new-wedding-id');

        expect(copied.weddingId, 'new-wedding-id');
      });

      test('should copy with new data', () {
        const original = WeddingOnboardingState();
        const newData = CubitOnboardingData(guestCount: 200);
        final copied = original.copyWith(data: newData);

        expect(copied.data.guestCount, 200);
      });

      test('should copy with isLoading', () {
        const original = WeddingOnboardingState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with error', () {
        const original = WeddingOnboardingState();
        final copied = original.copyWith(error: 'Test error');

        expect(copied.error, 'Test error');
      });

      test('should clear error with copyWith', () {
        const original = WeddingOnboardingState(error: 'Test error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should preserve unchanged values', () {
        const original = WeddingOnboardingState(
          currentStep: 3,
          weddingId: 'wedding-123',
          isLoading: true,
        );
        final copied = original.copyWith(error: 'New error');

        expect(copied.currentStep, 3);
        expect(copied.weddingId, 'wedding-123');
        expect(copied.isLoading, true);
        expect(copied.error, 'New error');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        const state1 = WeddingOnboardingState(
          currentStep: 3,
          weddingId: 'test-id',
        );
        const state2 = WeddingOnboardingState(
          currentStep: 3,
          weddingId: 'test-id',
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different values', () {
        const state1 = WeddingOnboardingState(currentStep: 3);
        const state2 = WeddingOnboardingState(currentStep: 4);

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('WeddingOnboardingCubit', () {
    late MockMyWeddingRepository mockRepository;

    setUp(() {
      mockRepository = MockMyWeddingRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = WeddingOnboardingCubit(repository: mockRepository);

        expect(cubit.state, const WeddingOnboardingState());
        expect(cubit.state.currentStep, 1);
        expect(cubit.state.isLoading, false);

        cubit.close();
      });
    });

    group('navigation', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'nextStep should increment currentStep when not at last step',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.nextStep(),
        expect: () => [
          const WeddingOnboardingState(currentStep: 2),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'nextStep should not exceed totalSteps',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => const WeddingOnboardingState(currentStep: 7),
        act: (cubit) => cubit.nextStep(),
        expect: () => [], // No state change
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'previousStep should decrement currentStep when not at first step',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => const WeddingOnboardingState(currentStep: 3),
        act: (cubit) => cubit.previousStep(),
        expect: () => [
          const WeddingOnboardingState(currentStep: 2),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'previousStep should not go below step 1',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => const WeddingOnboardingState(currentStep: 1),
        act: (cubit) => cubit.previousStep(),
        expect: () => [], // No state change
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'nextStep should clear error',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => const WeddingOnboardingState(currentStep: 2, error: 'Previous error'),
        act: (cubit) => cubit.nextStep(),
        expect: () => [
          const WeddingOnboardingState(currentStep: 3, error: null),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'previousStep should clear error',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => const WeddingOnboardingState(currentStep: 3, error: 'Previous error'),
        act: (cubit) => cubit.previousStep(),
        expect: () => [
          const WeddingOnboardingState(currentStep: 2, error: null),
        ],
      );
    });

    group('update methods', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateEventDate should update data with new date',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateEventDate(DateTime(2025, 6, 15)),
        expect: () => [
          WeddingOnboardingState(
            data: CubitOnboardingData(eventDate: DateTime(2025, 6, 15)),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateVenue should update venue data',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateVenue(
          address: '123 Main St',
          lat: 48.8566,
          lng: 2.3522,
          countryCode: 'FR',
        ),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(
              venueAddress: '123 Main St',
              lat: 48.8566,
              lng: 2.3522,
              countryCode: 'FR',
            ),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateProfessions should update professions list',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateProfessions(['PHOTOGRAPHER', 'DJ', 'FLORIST']),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(
              professionsNeeded: ['PHOTOGRAPHER', 'DJ', 'FLORIST'],
            ),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateGuestCount should update guest count',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateGuestCount(150),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(guestCount: 150),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateBudget should update budget min and max',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateBudget(min: 10000, max: 25000),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(budgetMin: 10000, budgetMax: 25000),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateVisibility should update visibility',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateVisibility('visible_to_pros'),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(visibility: 'visible_to_pros'),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateSearchRadius should update search radius',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateSearchRadius(100),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(searchRadius: 100),
          ),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'updateCoverImage should update cover image URL',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.updateCoverImage('https://example.com/cover.jpg'),
        expect: () => [
          const WeddingOnboardingState(
            data: CubitOnboardingData(coverImageUrl: 'https://example.com/cover.jpg'),
          ),
        ],
      );
    });

    group('setWeddingId', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should update weddingId',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.setWeddingId('wedding-456'),
        expect: () => [
          const WeddingOnboardingState(weddingId: 'wedding-456'),
        ],
      );
    });

    group('setLoading', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should set loading state',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.setLoading(true),
        expect: () => [
          const WeddingOnboardingState(isLoading: true),
        ],
      );
    });

    group('setError', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should set error message',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.setError('Something went wrong'),
        expect: () => [
          const WeddingOnboardingState(error: 'Something went wrong'),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should clear error when set to null',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => const WeddingOnboardingState(error: 'Previous error'),
        act: (cubit) => cubit.setError(null),
        expect: () => [
          const WeddingOnboardingState(error: null),
        ],
      );
    });

    group('goToStep', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should navigate to valid step',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.goToStep(5),
        expect: () => [
          const WeddingOnboardingState(currentStep: 5),
        ],
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should not navigate to invalid step (less than 1)',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.goToStep(0),
        expect: () => [], // No state change
      );

      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should not navigate to invalid step (greater than totalSteps)',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) => cubit.goToStep(8),
        expect: () => [], // No state change
      );
    });

    group('reset', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should reset to initial state',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        seed: () => WeddingOnboardingState(
          currentStep: 5,
          weddingId: 'wedding-123',
          data: CubitOnboardingData(
            eventDate: DateTime(2025, 6, 15),
            guestCount: 150,
          ),
          isLoading: true,
          error: 'Some error',
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const WeddingOnboardingState(),
        ],
      );
    });

    group('multiple data updates', () {
      blocTest<WeddingOnboardingCubit, WeddingOnboardingState>(
        'should preserve previous data when updating new fields',
        build: () => WeddingOnboardingCubit(repository: mockRepository),
        act: (cubit) {
          cubit.updateEventDate(DateTime(2025, 6, 15));
          cubit.updateGuestCount(150);
          cubit.updateBudget(min: 10000, max: 25000);
        },
        expect: () => [
          WeddingOnboardingState(
            data: CubitOnboardingData(eventDate: DateTime(2025, 6, 15)),
          ),
          WeddingOnboardingState(
            data: CubitOnboardingData(
              eventDate: DateTime(2025, 6, 15),
              guestCount: 150,
            ),
          ),
          WeddingOnboardingState(
            data: CubitOnboardingData(
              eventDate: DateTime(2025, 6, 15),
              guestCount: 150,
              budgetMin: 10000,
              budgetMax: 25000,
            ),
          ),
        ],
      );
    });
  });
}
