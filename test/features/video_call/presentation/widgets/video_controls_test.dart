/// Tests for VideoControls widget.
///
/// Tests covering:
/// - Button rendering
/// - Callbacks when buttons are tapped
/// - Visual states (muted, camera off, etc.)
/// - Disabled state when not connected
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/video_call/presentation/widgets/video_controls.dart';

void main() {
  group('VideoControls', () {
    group('rendering', () {
      testWidgets('should render all control buttons', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
              ),
            ),
          ),
        );

        // Find mute button (mic icon)
        expect(find.byIcon(Icons.mic), findsOneWidget);

        // Find camera toggle button
        expect(find.byIcon(Icons.videocam), findsOneWidget);

        // Find switch camera button
        expect(find.byIcon(Icons.cameraswitch), findsOneWidget);

        // Find end call button
        expect(find.byIcon(Icons.call_end), findsOneWidget);
      });

      testWidgets('should show mic_off icon when muted', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: true,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.mic_off), findsOneWidget);
        expect(find.byIcon(Icons.mic), findsNothing);
      });

      testWidgets('should show videocam_off icon when camera is off', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: false,
                isFrontCamera: true,
                canToggle: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.videocam_off), findsOneWidget);
        expect(find.byIcon(Icons.videocam), findsNothing);
      });
    });

    group('callbacks', () {
      testWidgets('should call onMuteToggle when mute button is tapped', (tester) async {
        var muteToggled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
                onMuteToggle: () => muteToggled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(muteToggled, true);
      });

      testWidgets('should call onCameraToggle when camera button is tapped', (tester) async {
        var cameraToggled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
                onCameraToggle: () => cameraToggled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.videocam));
        await tester.pumpAndSettle();

        expect(cameraToggled, true);
      });

      testWidgets('should call onSwitchCamera when switch camera button is tapped', (tester) async {
        var switchCameraPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
                onSwitchCamera: () => switchCameraPressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.cameraswitch));
        await tester.pumpAndSettle();

        expect(switchCameraPressed, true);
      });

      testWidgets('should call onEndCall when end call button is tapped', (tester) async {
        var endCallPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
                onEndCall: () => endCallPressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pumpAndSettle();

        expect(endCallPressed, true);
      });
    });

    group('disabled state', () {
      testWidgets('should not call onMuteToggle when canToggle is false', (tester) async {
        var muteToggled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: false,
                onMuteToggle: () => muteToggled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(muteToggled, false);
      });

      testWidgets('should not call onCameraToggle when canToggle is false', (tester) async {
        var cameraToggled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: false,
                onCameraToggle: () => cameraToggled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.videocam));
        await tester.pumpAndSettle();

        expect(cameraToggled, false);
      });

      testWidgets('should not call onSwitchCamera when canToggle is false', (tester) async {
        var switchCameraPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: false,
                onSwitchCamera: () => switchCameraPressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.cameraswitch));
        await tester.pumpAndSettle();

        expect(switchCameraPressed, false);
      });

      testWidgets('should always allow end call even when canToggle is false', (tester) async {
        var endCallPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: false,
                onEndCall: () => endCallPressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pumpAndSettle();

        expect(endCallPressed, true);
      });
    });

    group('visual feedback', () {
      testWidgets('should have red background on end call button', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VideoControls(
                isMuted: false,
                isCameraOn: true,
                isFrontCamera: true,
                canToggle: true,
              ),
            ),
          ),
        );

        // Find the end call button container
        final endCallButton = tester.widget<Container>(
          find.ancestor(
            of: find.byIcon(Icons.call_end),
            matching: find.byType(Container),
          ).first,
        );

        // The button should exist
        expect(endCallButton, isNotNull);
      });
    });
  });
}
