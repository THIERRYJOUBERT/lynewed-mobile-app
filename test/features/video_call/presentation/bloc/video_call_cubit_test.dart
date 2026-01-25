/// Tests for VideoCallCubit and VideoCallState.
///
/// Comprehensive tests covering:
/// - State creation and manipulation
/// - All cubit methods (startCall, endCall, toggleMute, toggleCamera, etc.)
/// - Error handling
/// - Edge cases
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/call_status.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/video_session.dart';
import 'package:lynewed_beta/features/video_call/domain/repositories/video_call_repository.dart';
import 'package:lynewed_beta/features/video_call/presentation/bloc/video_call_cubit.dart';
import 'package:lynewed_beta/features/video_call/presentation/bloc/video_call_state.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoCallRepository extends Mock implements VideoCallRepository {}

void main() {
  group('VideoCallState', () {
    group('creation', () {
      test('should create with default values', () {
        const state = VideoCallState();

        expect(state.status, CallStatus.initial);
        expect(state.session, isNull);
        expect(state.remoteUid, isNull);
        expect(state.isMuted, false);
        expect(state.isCameraOn, true);
        expect(state.isFrontCamera, true);
        expect(state.error, isNull);
        expect(state.callDuration, Duration.zero);
      });

      test('should create with provided values', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: DateTime.now(),
        );

        final state = VideoCallState(
          status: CallStatus.connected,
          session: session,
          remoteUid: 54321,
          isMuted: true,
          isCameraOn: false,
          isFrontCamera: false,
          error: 'Some error',
          callDuration: const Duration(minutes: 5),
        );

        expect(state.status, CallStatus.connected);
        expect(state.session, session);
        expect(state.remoteUid, 54321);
        expect(state.isMuted, true);
        expect(state.isCameraOn, false);
        expect(state.isFrontCamera, false);
        expect(state.error, 'Some error');
        expect(state.callDuration, const Duration(minutes: 5));
      });
    });

    group('computed properties', () {
      test('isCallActive should return true when status is active', () {
        const connectingState = VideoCallState(status: CallStatus.connecting);
        const ringingState = VideoCallState(status: CallStatus.ringing);
        const connectedState = VideoCallState(status: CallStatus.connected);

        expect(connectingState.isCallActive, true);
        expect(ringingState.isCallActive, true);
        expect(connectedState.isCallActive, true);
      });

      test('isCallActive should return false when status is not active', () {
        const initialState = VideoCallState(status: CallStatus.initial);
        const endedState = VideoCallState(status: CallStatus.ended);
        const errorState = VideoCallState(status: CallStatus.error);

        expect(initialState.isCallActive, false);
        expect(endedState.isCallActive, false);
        expect(errorState.isCallActive, false);
      });

      test('canToggleControls should return true only when connected', () {
        const connectedState = VideoCallState(status: CallStatus.connected);
        const connectingState = VideoCallState(status: CallStatus.connecting);
        const endedState = VideoCallState(status: CallStatus.ended);

        expect(connectedState.canToggleControls, true);
        expect(connectingState.canToggleControls, false);
        expect(endedState.canToggleControls, false);
      });

      test('hasRemoteUser should return true when remoteUid is set', () {
        const withRemote = VideoCallState(remoteUid: 12345);
        const withoutRemote = VideoCallState();

        expect(withRemote.hasRemoteUser, true);
        expect(withoutRemote.hasRemoteUser, false);
      });

      test('formattedDuration should format duration correctly', () {
        const state1 = VideoCallState(callDuration: Duration.zero);
        const state2 = VideoCallState(callDuration: Duration(seconds: 45));
        const state3 = VideoCallState(callDuration: Duration(minutes: 5, seconds: 30));
        const state4 = VideoCallState(callDuration: Duration(hours: 1, minutes: 23, seconds: 45));

        expect(state1.formattedDuration, '00:00');
        expect(state2.formattedDuration, '00:45');
        expect(state3.formattedDuration, '05:30');
        expect(state4.formattedDuration, '01:23:45');
      });
    });

    group('copyWith', () {
      test('should copy with new status', () {
        const original = VideoCallState();
        final copied = original.copyWith(status: CallStatus.connected);

        expect(copied.status, CallStatus.connected);
        expect(copied.isMuted, original.isMuted);
      });

      test('should copy with new isMuted', () {
        const original = VideoCallState(isMuted: false);
        final copied = original.copyWith(isMuted: true);

        expect(copied.isMuted, true);
      });

      test('should copy with new isCameraOn', () {
        const original = VideoCallState(isCameraOn: true);
        final copied = original.copyWith(isCameraOn: false);

        expect(copied.isCameraOn, false);
      });

      test('should copy with new remoteUid', () {
        const original = VideoCallState();
        final copied = original.copyWith(remoteUid: 12345);

        expect(copied.remoteUid, 12345);
      });

      test('should clear error with clearError flag', () {
        const original = VideoCallState(error: 'Previous error');
        final copied = original.copyWith(clearError: true);

        expect(copied.error, isNull);
      });

      test('should preserve unchanged values', () {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: DateTime.now(),
        );

        final state = VideoCallState(
          status: CallStatus.connected,
          session: session,
          remoteUid: 54321,
          isMuted: true,
          isCameraOn: false,
        );

        final copied = state.copyWith(isFrontCamera: false);

        expect(copied.status, state.status);
        expect(copied.session, state.session);
        expect(copied.remoteUid, state.remoteUid);
        expect(copied.isMuted, state.isMuted);
        expect(copied.isCameraOn, state.isCameraOn);
        expect(copied.isFrontCamera, false);
      });
    });

    group('equality', () {
      test('should be equal with same values', () {
        const state1 = VideoCallState(
          status: CallStatus.connected,
          isMuted: true,
        );
        const state2 = VideoCallState(
          status: CallStatus.connected,
          isMuted: true,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal with different status', () {
        const state1 = VideoCallState(status: CallStatus.connecting);
        const state2 = VideoCallState(status: CallStatus.connected);

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal with different isMuted', () {
        const state1 = VideoCallState(isMuted: true);
        const state2 = VideoCallState(isMuted: false);

        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('VideoCallCubit', () {
    late MockVideoCallRepository mockRepository;
    const testSessionId = 'session-123';

    final testSession = VideoSession(
      id: testSessionId,
      channelName: 'channel-abc',
      token: 'token-xyz',
      uid: 12345,
      callerProfileId: 'caller-1',
      receiverProfileId: 'receiver-1',
      status: VideoSessionStatus.connected,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockRepository = MockVideoCallRepository();
    });

    group('initial state', () {
      test('should have correct initial state', () {
        final cubit = VideoCallCubit(repository: mockRepository);

        expect(cubit.state.status, CallStatus.initial);
        expect(cubit.state.session, isNull);
        expect(cubit.state.isMuted, false);
        expect(cubit.state.isCameraOn, true);

        cubit.close();
      });
    });

    group('joinCall', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should emit connecting then connected state on success',
        build: () {
          when(() => mockRepository.getSession(sessionId: testSessionId))
              .thenAnswer((_) async => VideoCallResult.success(testSession));
          when(() => mockRepository.updateSessionStatus(
                sessionId: testSessionId,
                status: VideoSessionStatus.connected,
              )).thenAnswer((_) async => const VideoCallResult.success(null));
          return VideoCallCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.joinCall(sessionId: testSessionId),
        expect: () => [
          const VideoCallState(status: CallStatus.connecting),
          isA<VideoCallState>()
              .having((s) => s.status, 'status', CallStatus.connected)
              .having((s) => s.session, 'session', testSession),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should emit error state when session not found',
        build: () {
          when(() => mockRepository.getSession(sessionId: testSessionId))
              .thenAnswer((_) async => const VideoCallResult.success(null));
          return VideoCallCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.joinCall(sessionId: testSessionId),
        expect: () => [
          const VideoCallState(status: CallStatus.connecting),
          isA<VideoCallState>()
              .having((s) => s.status, 'status', CallStatus.error)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should emit error state when repository fails',
        build: () {
          when(() => mockRepository.getSession(sessionId: testSessionId))
              .thenAnswer((_) async => const VideoCallResult.failure('Network error'));
          return VideoCallCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.joinCall(sessionId: testSessionId),
        expect: () => [
          const VideoCallState(status: CallStatus.connecting),
          isA<VideoCallState>()
              .having((s) => s.status, 'status', CallStatus.error)
              .having((s) => s.error, 'error', 'Network error'),
        ],
      );
    });

    group('toggleMute', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should toggle mute from false to true',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          isMuted: false,
        ),
        act: (cubit) => cubit.toggleMute(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            isMuted: true,
          ),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should toggle mute from true to false',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          isMuted: true,
        ),
        act: (cubit) => cubit.toggleMute(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            isMuted: false,
          ),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should not toggle mute when not connected',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connecting,
          isMuted: false,
        ),
        act: (cubit) => cubit.toggleMute(),
        expect: () => const <VideoCallState>[],
      );
    });

    group('toggleCamera', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should toggle camera from on to off',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          isCameraOn: true,
        ),
        act: (cubit) => cubit.toggleCamera(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            isCameraOn: false,
          ),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should toggle camera from off to on',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          isCameraOn: false,
        ),
        act: (cubit) => cubit.toggleCamera(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            isCameraOn: true,
          ),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should not toggle camera when not connected',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.ended,
          isCameraOn: true,
        ),
        act: (cubit) => cubit.toggleCamera(),
        expect: () => const <VideoCallState>[],
      );
    });

    group('switchCamera', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should switch camera from front to back',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          isFrontCamera: true,
        ),
        act: (cubit) => cubit.switchCamera(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            isFrontCamera: false,
          ),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should switch camera from back to front',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          isFrontCamera: false,
        ),
        act: (cubit) => cubit.switchCamera(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            isFrontCamera: true,
          ),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should not switch camera when not connected',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.initial,
          isFrontCamera: true,
        ),
        act: (cubit) => cubit.switchCamera(),
        expect: () => const <VideoCallState>[],
      );
    });

    group('endCall', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should emit ended state and call repository',
        build: () {
          when(() => mockRepository.endSession(sessionId: testSessionId))
              .thenAnswer((_) async => const VideoCallResult.success(null));
          return VideoCallCubit(repository: mockRepository);
        },
        seed: () => VideoCallState(
          status: CallStatus.connected,
          session: testSession,
        ),
        act: (cubit) => cubit.endCall(),
        expect: () => [
          isA<VideoCallState>()
              .having((s) => s.status, 'status', CallStatus.ended),
        ],
        verify: (_) {
          verify(() => mockRepository.endSession(sessionId: testSessionId))
              .called(1);
        },
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should emit ended state even when no session',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(status: CallStatus.connecting),
        act: (cubit) => cubit.endCall(),
        expect: () => [
          const VideoCallState(status: CallStatus.ended),
        ],
      );

      blocTest<VideoCallCubit, VideoCallState>(
        'should not emit when already ended',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(status: CallStatus.ended),
        act: (cubit) => cubit.endCall(),
        expect: () => const <VideoCallState>[],
      );
    });

    group('setRemoteUser', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should set remote user uid',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(status: CallStatus.connected),
        act: (cubit) => cubit.setRemoteUser(uid: 54321),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            remoteUid: 54321,
          ),
        ],
      );
    });

    group('removeRemoteUser', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should remove remote user uid',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.connected,
          remoteUid: 54321,
        ),
        act: (cubit) => cubit.removeRemoteUser(),
        expect: () => [
          isA<VideoCallState>()
              .having((s) => s.remoteUid, 'remoteUid', isNull),
        ],
      );
    });

    group('updateCallDuration', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should update call duration',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(status: CallStatus.connected),
        act: (cubit) => cubit.updateCallDuration(const Duration(minutes: 5)),
        expect: () => [
          const VideoCallState(
            status: CallStatus.connected,
            callDuration: Duration(minutes: 5),
          ),
        ],
      );
    });

    group('clearError', () {
      blocTest<VideoCallCubit, VideoCallState>(
        'should clear error state',
        build: () => VideoCallCubit(repository: mockRepository),
        seed: () => const VideoCallState(
          status: CallStatus.error,
          error: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          const VideoCallState(
            status: CallStatus.error,
            error: null,
          ),
        ],
      );
    });
  });
}
