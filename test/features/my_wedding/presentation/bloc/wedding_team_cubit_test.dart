import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/repositories/my_wedding_repository.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/wedding_team_cubit.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/bloc/wedding_team_state.dart';
import 'package:mocktail/mocktail.dart';

class MockMyWeddingRepository extends Mock implements MyWeddingRepository {}

void main() {
  group('WeddingTeamState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = WeddingTeamState();

        expect(state.members, isEmpty);
        expect(state.availablePros, isEmpty);
        expect(state.teamChat, isNull);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });

      test('should create with provided values', () {
        final member = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'John Photographer',
          profession: 'PHOTOGRAPHER',
          status: 'active',
        );
        final contactedPro = ContactedPro(
          profileId: 'pro-2',
          displayName: 'Jane DJ',
          profession: 'DJ',
        );
        const chatInfo = WeddingTeamChatInfo(
          roomId: 'room-1',
          weddingId: 'wedding-1',
          participantsCount: 3,
        );

        final state = WeddingTeamState(
          members: [member],
          availablePros: [contactedPro],
          teamChat: chatInfo,
          isLoading: true,
          error: 'Some error',
        );

        expect(state.members, [member]);
        expect(state.availablePros, [contactedPro]);
        expect(state.teamChat, chatInfo);
        expect(state.isLoading, true);
        expect(state.error, 'Some error');
      });
    });

    group('computed properties', () {
      test('activeMembers should return only active members', () {
        final activeMember = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'Active Pro',
          status: 'active',
        );
        final leftMember = WeddingTeamMember(
          profileId: 'pro-2',
          displayName: 'Left Pro',
          status: 'left',
        );
        final excludedMember = WeddingTeamMember(
          profileId: 'pro-3',
          displayName: 'Excluded Pro',
          status: 'excluded',
        );

        final state = WeddingTeamState(
          members: [activeMember, leftMember, excludedMember],
        );

        expect(state.activeMembers, [activeMember]);
        expect(state.activeMembers.length, 1);
      });

      test('activeMembers should return empty list when no active members', () {
        final leftMember = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'Left Pro',
          status: 'left',
        );

        final state = WeddingTeamState(members: [leftMember]);

        expect(state.activeMembers, isEmpty);
      });

      test('leftMembers should return only left and excluded members', () {
        final activeMember = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'Active Pro',
          status: 'active',
        );
        final leftMember = WeddingTeamMember(
          profileId: 'pro-2',
          displayName: 'Left Pro',
          status: 'left',
        );
        final excludedMember = WeddingTeamMember(
          profileId: 'pro-3',
          displayName: 'Excluded Pro',
          status: 'excluded',
        );

        final state = WeddingTeamState(
          members: [activeMember, leftMember, excludedMember],
        );

        expect(state.leftMembers, [leftMember, excludedMember]);
        expect(state.leftMembers.length, 2);
      });
    });

    group('copyWith', () {
      test('should copy with new members', () {
        const original = WeddingTeamState();
        final member = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'New Pro',
          status: 'active',
        );
        final copied = original.copyWith(members: [member]);

        expect(copied.members, [member]);
        expect(copied.availablePros, isEmpty);
        expect(copied.isLoading, false);
      });

      test('should copy with new availablePros', () {
        const original = WeddingTeamState();
        final pro = ContactedPro(
          profileId: 'pro-1',
          displayName: 'Available Pro',
        );
        final copied = original.copyWith(availablePros: [pro]);

        expect(copied.availablePros, [pro]);
        expect(copied.members, isEmpty);
      });

      test('should copy with new teamChat', () {
        const original = WeddingTeamState();
        const chatInfo = WeddingTeamChatInfo(
          roomId: 'room-1',
          weddingId: 'wedding-1',
        );
        final copied = original.copyWith(teamChat: chatInfo);

        expect(copied.teamChat, chatInfo);
      });

      test('should copy with new isLoading', () {
        const original = WeddingTeamState(isLoading: false);
        final copied = original.copyWith(isLoading: true);

        expect(copied.isLoading, true);
      });

      test('should copy with new error', () {
        const original = WeddingTeamState();
        final copied = original.copyWith(error: 'New error');

        expect(copied.error, 'New error');
      });

      test('should clear error with clearError flag', () {
        const original = WeddingTeamState(error: 'Previous error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should preserve unchanged values', () {
        final member = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'Test Pro',
          status: 'active',
        );
        final state = WeddingTeamState(
          members: [member],
          isLoading: true,
        );
        final copied = state.copyWith(error: 'New error');

        expect(copied.members, [member]);
        expect(copied.isLoading, true);
        expect(copied.error, 'New error');
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        final member = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'Test Pro',
          status: 'active',
        );
        final state1 = WeddingTeamState(members: [member]);
        final state2 = WeddingTeamState(members: [member]);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different values', () {
        final member1 = WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'Test Pro 1',
          status: 'active',
        );
        final member2 = WeddingTeamMember(
          profileId: 'pro-2',
          displayName: 'Test Pro 2',
          status: 'active',
        );
        final state1 = WeddingTeamState(members: [member1]);
        final state2 = WeddingTeamState(members: [member2]);

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('WeddingTeamCubit', () {
    late MockMyWeddingRepository mockRepository;
    const testWeddingId = 'wedding-123';

    setUp(() {
      mockRepository = MockMyWeddingRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = WeddingTeamCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        );

        expect(cubit.state, const WeddingTeamState());
        expect(cubit.state.members, isEmpty);
        expect(cubit.state.isLoading, false);
        expect(cubit.weddingId, testWeddingId);

        cubit.close();
      });
    });

    group('loadTeam', () {
      final testMembers = [
        WeddingTeamMember(
          profileId: 'pro-1',
          displayName: 'John Photographer',
          profession: 'PHOTOGRAPHER',
          status: 'active',
        ),
        WeddingTeamMember(
          profileId: 'pro-2',
          displayName: 'Jane DJ',
          profession: 'DJ',
          status: 'active',
        ),
      ];

      final testPros = [
        ContactedPro(
          profileId: 'pro-3',
          displayName: 'Bob Florist',
          profession: 'FLORIST',
        ),
      ];

      const testChat = WeddingTeamChatInfo(
        roomId: 'chat-123',
        weddingId: testWeddingId,
        participantsCount: 3,
      );

      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should emit loading state then loaded state on success',
        build: () {
          when(() => mockRepository.getWeddingTeam(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testMembers));
          when(() => mockRepository.getContactedPros())
              .thenAnswer((_) async => RepositoryResult.success(testPros));
          when(() => mockRepository.getWeddingTeamChat(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testChat));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadTeam(),
        expect: () => [
          const WeddingTeamState(isLoading: true),
          WeddingTeamState(
            isLoading: false,
            members: testMembers,
            availablePros: testPros,
            teamChat: testChat,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getWeddingTeam(weddingId: testWeddingId))
              .called(1);
          verify(() => mockRepository.getContactedPros()).called(1);
          verify(() => mockRepository.getWeddingTeamChat(weddingId: testWeddingId))
              .called(1);
        },
      );

      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should handle null chat result gracefully',
        build: () {
          when(() => mockRepository.getWeddingTeam(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testMembers));
          when(() => mockRepository.getContactedPros())
              .thenAnswer((_) async => RepositoryResult.success(testPros));
          when(() => mockRepository.getWeddingTeamChat(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadTeam(),
        expect: () => [
          const WeddingTeamState(isLoading: true),
          WeddingTeamState(
            isLoading: false,
            members: testMembers,
            availablePros: testPros,
            teamChat: null,
          ),
        ],
      );

      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should handle team fetch failure gracefully',
        build: () {
          when(() => mockRepository.getWeddingTeam(weddingId: testWeddingId))
              .thenAnswer(
                  (_) async => const RepositoryResult.failure('Network error'));
          when(() => mockRepository.getContactedPros())
              .thenAnswer((_) async => RepositoryResult.success(testPros));
          when(() => mockRepository.getWeddingTeamChat(weddingId: testWeddingId))
              .thenAnswer((_) async => RepositoryResult.success(testChat));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.loadTeam(),
        expect: () => [
          const WeddingTeamState(isLoading: true),
          WeddingTeamState(
            isLoading: false,
            members: const [],
            availablePros: testPros,
            teamChat: testChat,
          ),
        ],
      );
    });

    group('invitePro', () {
      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should emit loading then reload team on success',
        build: () {
          when(() => mockRepository.inviteProToWedding(
                weddingId: testWeddingId,
                proProfileId: 'pro-1',
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          when(() => mockRepository.getWeddingTeam(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          when(() => mockRepository.getContactedPros())
              .thenAnswer((_) async => const RepositoryResult.success([]));
          when(() => mockRepository.getWeddingTeamChat(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.invitePro('pro-1'),
        expect: () => [
          // isLoading: true emitted by invitePro
          const WeddingTeamState(isLoading: true),
          // loadTeam called after success -> emits final state
          // Note: duplicate isLoading: true is coalesced by bloc_test
          const WeddingTeamState(isLoading: false),
        ],
        verify: (_) {
          verify(() => mockRepository.inviteProToWedding(
                weddingId: testWeddingId,
                proProfileId: 'pro-1',
              )).called(1);
        },
      );

      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should emit error state on failure',
        build: () {
          when(() => mockRepository.inviteProToWedding(
                weddingId: testWeddingId,
                proProfileId: 'pro-1',
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Invitation failed'));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.invitePro('pro-1'),
        expect: () => [
          const WeddingTeamState(isLoading: true),
          const WeddingTeamState(isLoading: false, error: 'Invitation failed'),
        ],
      );
    });

    group('excludePro', () {
      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should emit loading then reload team on success',
        build: () {
          when(() => mockRepository.excludeProFromWedding(
                weddingId: testWeddingId,
                proProfileId: 'pro-1',
                reason: 'No longer needed',
              )).thenAnswer((_) async => const RepositoryResult.success(null));
          when(() => mockRepository.getWeddingTeam(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success([]));
          when(() => mockRepository.getContactedPros())
              .thenAnswer((_) async => const RepositoryResult.success([]));
          when(() => mockRepository.getWeddingTeamChat(weddingId: testWeddingId))
              .thenAnswer((_) async => const RepositoryResult.success(null));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.excludePro('pro-1', reason: 'No longer needed'),
        expect: () => [
          // isLoading: true emitted by excludePro
          const WeddingTeamState(isLoading: true),
          // loadTeam called after success -> emits final state
          // Note: duplicate isLoading: true is coalesced by bloc_test
          const WeddingTeamState(isLoading: false),
        ],
        verify: (_) {
          verify(() => mockRepository.excludeProFromWedding(
                weddingId: testWeddingId,
                proProfileId: 'pro-1',
                reason: 'No longer needed',
              )).called(1);
        },
      );

      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should emit error state on failure',
        build: () {
          when(() => mockRepository.excludeProFromWedding(
                weddingId: testWeddingId,
                proProfileId: 'pro-1',
                reason: null,
              )).thenAnswer(
              (_) async => const RepositoryResult.failure('Exclusion failed'));
          return WeddingTeamCubit(
            repository: mockRepository,
            weddingId: testWeddingId,
          );
        },
        act: (cubit) => cubit.excludePro('pro-1'),
        expect: () => [
          const WeddingTeamState(isLoading: true),
          const WeddingTeamState(isLoading: false, error: 'Exclusion failed'),
        ],
      );
    });

    group('clearError', () {
      blocTest<WeddingTeamCubit, WeddingTeamState>(
        'should clear error state',
        build: () => WeddingTeamCubit(
          repository: mockRepository,
          weddingId: testWeddingId,
        ),
        seed: () => const WeddingTeamState(error: 'Some error'),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const WeddingTeamState(error: null),
        ],
      );
    });
  });
}
