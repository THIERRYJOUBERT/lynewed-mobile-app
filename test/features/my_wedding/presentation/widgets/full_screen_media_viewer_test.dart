import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/full_screen_media_viewer.dart';

void main() {
  group('FullScreenMediaViewer', () {
    testWidgets('displays photo with zoom support', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenMediaViewer(
            imageUrl: 'https://example.com/photo.jpg',
            isVideo: false,
          ),
        ),
      );

      // Should have InteractiveViewer for zoom
      expect(find.byType(InteractiveViewer), findsOneWidget);
      // Should have close button
      expect(find.byIcon(Icons.close), findsOneWidget);
      // Should have download button
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('displays video placeholder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenMediaViewer(
            imageUrl: 'https://example.com/video.mp4',
            isVideo: true,
          ),
        ),
      );

      // Should show video icon
      expect(find.byIcon(Icons.videocam_rounded), findsOneWidget);
      // Should show placeholder text
      expect(find.text('Video playback coming soon'), findsOneWidget);
    });

    testWidgets('displays caption when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenMediaViewer(
            imageUrl: 'https://example.com/photo.jpg',
            caption: 'Beautiful sunset',
          ),
        ),
      );

      expect(find.text('Beautiful sunset'), findsOneWidget);
    });

    testWidgets('hides caption when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FullScreenMediaViewer(
            imageUrl: 'https://example.com/photo.jpg',
          ),
        ),
      );

      // No caption text visible
      expect(find.textContaining('Beautiful'), findsNothing);
    });

    testWidgets('close button pops navigation', (tester) async {
      var popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenMediaViewer(
                      imageUrl: 'https://example.com/video.mp4',
                      isVideo: true, // Use video to avoid CachedNetworkImage loading
                    ),
                  ),
                ).then((_) => popped = true);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open viewer
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(popped, isTrue);
    });

    testWidgets('show static method creates route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => FullScreenMediaViewer.show(
                context,
                imageUrl: 'https://example.com/video.mp4',
                isVideo: true, // Use video to avoid CachedNetworkImage loading
                fileName: 'video.mp4',
                caption: 'Test caption',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open viewer via static method
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should display the viewer
      expect(find.byType(FullScreenMediaViewer), findsOneWidget);
      expect(find.text('Test caption'), findsOneWidget);
    });
  });
}
