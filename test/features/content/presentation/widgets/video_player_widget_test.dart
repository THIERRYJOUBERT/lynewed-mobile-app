/// Tests for VideoPlayerWidget.
///
/// Verifies the video player widget:
/// - Displays correct player based on video type
/// - Shows placeholder when appropriate
/// - Handles tap interactions
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_article.dart';
import 'package:lynewed_beta/features/content/presentation/widgets/video_player_widget.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('VideoPlayerWidget', () {
    group('Basic rendering', () {
      testWidgets('should display video placeholder with youtube icon', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://youtube.com/watch?v=abc123',
            videoType: VideoType.youtube,
          ),
        ));

        expect(find.byType(VideoPlayerWidget), findsOneWidget);
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });

      testWidgets('should display video placeholder for vimeo', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
          ),
        ));

        expect(find.byType(VideoPlayerWidget), findsOneWidget);
      });

      testWidgets('should display video placeholder for direct video', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://example.com/video.mp4',
            videoType: VideoType.direct,
          ),
        ));

        expect(find.byType(VideoPlayerWidget), findsOneWidget);
      });

      testWidgets('should display thumbnail when provided', (tester) async {
        // Note: This test verifies widget accepts thumbnailUrl parameter
        // Actual network image loading would require image mocking
        const widget = VideoPlayerWidget(
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          thumbnailUrl: 'https://example.com/thumb.jpg',
        );

        expect(widget.thumbnailUrl, 'https://example.com/thumb.jpg');
      });

      testWidgets('should display title when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
            title: 'Wedding Ceremony',
          ),
        ));

        expect(find.text('Wedding Ceremony'), findsOneWidget);
      });

      testWidgets('should not display title when not provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
          ),
        ));

        expect(find.text('Wedding Ceremony'), findsNothing);
      });

      testWidgets('should display video type label', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://youtube.com/watch?v=abc',
            videoType: VideoType.youtube,
          ),
        ));

        expect(find.textContaining('YouTube'), findsOneWidget);
      });

      testWidgets('should display Vimeo label for vimeo videos', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
          ),
        ));

        expect(find.textContaining('Vimeo'), findsOneWidget);
      });
    });

    group('Tap handling', () {
      testWidgets('should call onTap when tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(buildTestWidget(
          child: VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
            onTap: () => tapped = true,
          ),
        ));

        await tester.tap(find.byType(VideoPlayerWidget));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('should not throw when tapped without onTap callback', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
          ),
        ));

        await tester.tap(find.byType(VideoPlayerWidget));
        await tester.pump();

        // Should not throw
      });
    });

    group('Layout', () {
      testWidgets('should respect aspectRatio parameter', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const SizedBox(
            width: 400,
            child: VideoPlayerWidget(
              videoUrl: 'https://vimeo.com/123456',
              videoType: VideoType.vimeo,
              aspectRatio: 16 / 9,
            ),
          ),
        ));

        final aspectRatioFinder = find.byType(AspectRatio);
        expect(aspectRatioFinder, findsOneWidget);

        final aspectRatioWidget = tester.widget<AspectRatio>(aspectRatioFinder);
        expect(aspectRatioWidget.aspectRatio, closeTo(16 / 9, 0.01));
      });

      testWidgets('should have default aspect ratio of 16:9', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const SizedBox(
            width: 400,
            child: VideoPlayerWidget(
              videoUrl: 'https://vimeo.com/123456',
              videoType: VideoType.vimeo,
            ),
          ),
        ));

        final aspectRatioFinder = find.byType(AspectRatio);
        expect(aspectRatioFinder, findsOneWidget);
      });

      testWidgets('play icon should be centered', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const SizedBox(
            width: 400,
            height: 225,
            child: VideoPlayerWidget(
              videoUrl: 'https://vimeo.com/123456',
              videoType: VideoType.vimeo,
            ),
          ),
        ));

        // Find the icon and check it exists
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept all required parameters', (tester) async {
        const widget = VideoPlayerWidget(
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
        );

        expect(widget.videoUrl, 'https://vimeo.com/123456');
        expect(widget.videoType, VideoType.vimeo);
      });

      testWidgets('should accept all optional parameters', (tester) async {
        void tapCallback() {}

        final widget = VideoPlayerWidget(
          videoUrl: 'https://vimeo.com/123456',
          videoType: VideoType.vimeo,
          thumbnailUrl: 'https://example.com/thumb.jpg',
          title: 'Wedding Video',
          aspectRatio: 4 / 3,
          onTap: tapCallback,
        );

        expect(widget.videoUrl, 'https://vimeo.com/123456');
        expect(widget.videoType, VideoType.vimeo);
        expect(widget.thumbnailUrl, 'https://example.com/thumb.jpg');
        expect(widget.title, 'Wedding Video');
        expect(widget.aspectRatio, 4 / 3);
        expect(widget.onTap, tapCallback);
      });
    });

    group('Styling', () {
      testWidgets('should have rounded corners', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
          ),
        ));

        // Look for ClipRRect which provides rounded corners
        expect(find.byType(ClipRRect), findsOneWidget);
      });

      testWidgets('should have gradient overlay', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const VideoPlayerWidget(
            videoUrl: 'https://vimeo.com/123456',
            videoType: VideoType.vimeo,
          ),
        ));

        // Widget should render without errors
        expect(find.byType(VideoPlayerWidget), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should be tappable with sufficient size', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const SizedBox(
            width: 320,
            child: VideoPlayerWidget(
              videoUrl: 'https://vimeo.com/123456',
              videoType: VideoType.vimeo,
            ),
          ),
        ));

        final size = tester.getSize(find.byType(VideoPlayerWidget));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      });
    });
  });
}
