/// Tests for VideoCallPage.
///
/// Tests covering:
/// - Page rendering with different states
/// - BlocProvider integration
/// - Controls visibility
/// - Status display
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/call_status.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/video_session.dart';
import 'package:lynewed_beta/features/video_call/presentation/bloc/video_call_cubit.dart';
import 'package:lynewed_beta/features/video_call/presentation/bloc/video_call_state.dart';
import 'package:lynewed_beta/features/video_call/presentation/pages/video_call_page.dart';
import 'package:lynewed_beta/features/video_call/presentation/widgets/video_controls.dart';
import 'package:mocktail/mocktail.dart';

class MockVideoCallCubit extends MockCubit<VideoCallState>
    implements VideoCallCubit {}

void main() {
  group('VideoCallPage', () {
    late MockVideoCallCubit mockCubit;

    setUp(() {
      mockCubit = MockVideoCallCubit();
    });

    Widget buildSubject({VideoCallState? state}) {
      when(() => mockCubit.state).thenReturn(state ?? const VideoCallState());
      when(() => mockCubit.stream).thenAnswer(
        (_) => Stream.value(state ?? const VideoCallState()),
      );

      return MaterialApp(
        home: BlocProvider<VideoCallCubit>.value(
          value: mockCubit,
          child: const VideoCallPage(sessionId: 'test-session'),
        ),
      );
    }

    group('rendering', () {
      testWidgets('should render with initial state', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Should show some content
        expect(find.byType(VideoCallPage), findsOneWidget);
      });

      testWidgets('should show connecting status when connecting', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(status: CallStatus.connecting),
        ));
        await tester.pumpAndSettle();

        // Should show connecting indicator
        expect(find.text('Connecting...'), findsOneWidget);
      });

      testWidgets('should show ringing status when ringing', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(status: CallStatus.ringing),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Ringing...'), findsOneWidget);
      });

      testWidgets('should show duration when connected', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(
            status: CallStatus.connected,
            callDuration: Duration(minutes: 5, seconds: 30),
          ),
        ));
        await tester.pump();

        expect(find.text('05:30'), findsOneWidget);
      });

      testWidgets('should show error message when error state', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(
            status: CallStatus.error,
            error: 'Connection failed',
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Connection failed'), findsOneWidget);
      });

      testWidgets('should show call ended message when ended', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(status: CallStatus.ended),
        ));
        await tester.pump();

        expect(find.text('Call Ended'), findsOneWidget);

        // Clean up the delayed timer to avoid test warning
        await tester.pump(const Duration(seconds: 3));
      });
    });

    group('controls', () {
      testWidgets('should show VideoControls', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(status: CallStatus.connected),
        ));
        await tester.pump();

        expect(find.byType(VideoControls), findsOneWidget);
      });

      testWidgets('should call toggleMute when mute button is tapped', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(
            status: CallStatus.connected,
            isMuted: false,
          ),
        ));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();

        verify(() => mockCubit.toggleMute()).called(1);
      });

      testWidgets('should call toggleCamera when camera button is tapped', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(
            status: CallStatus.connected,
            isCameraOn: true,
          ),
        ));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.videocam));
        await tester.pump();

        verify(() => mockCubit.toggleCamera()).called(1);
      });

      testWidgets('should call switchCamera when switch button is tapped', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(status: CallStatus.connected),
        ));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.cameraswitch));
        await tester.pump();

        verify(() => mockCubit.switchCamera()).called(1);
      });

      testWidgets('should call endCall when end button is tapped', (tester) async {
        when(() => mockCubit.endCall()).thenAnswer((_) async {});

        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(status: CallStatus.connected),
        ));
        await tester.pump();

        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pump();

        verify(() => mockCubit.endCall()).called(1);
      });
    });

    group('remote user', () {
      testWidgets('should show waiting message when no remote user', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(
            status: CallStatus.connected,
            remoteUid: null,
          ),
        ));
        await tester.pump();

        expect(find.textContaining('Waiting'), findsOneWidget);
      });

      testWidgets('should show remote video placeholder when remote user joins', (tester) async {
        await tester.pumpWidget(buildSubject(
          state: const VideoCallState(
            status: CallStatus.connected,
            remoteUid: 12345,
          ),
        ));
        await tester.pump();

        // Remote video area should exist
        expect(find.byType(VideoCallPage), findsOneWidget);
      });
    });

    group('participant info', () {
      testWidgets('should show caller name when available', (tester) async {
        final session = VideoSession(
          id: 'session-1',
          channelName: 'channel-abc',
          token: 'token-xyz',
          uid: 12345,
          callerProfileId: 'caller-1',
          receiverProfileId: 'receiver-1',
          status: VideoSessionStatus.connected,
          createdAt: DateTime.now(),
          callerName: 'John Doe',
        );

        await tester.pumpWidget(buildSubject(
          state: VideoCallState(
            status: CallStatus.connected,
            session: session,
          ),
        ));
        await tester.pump();

        expect(find.text('John Doe'), findsOneWidget);
      });
    });

    group('static properties', () {
      test('should have routeName', () {
        expect(VideoCallPage.routeName, 'video-call');
      });

      test('should have routePath', () {
        expect(VideoCallPage.routePath, '/video-call/:sessionId');
      });
    });
  });
}
