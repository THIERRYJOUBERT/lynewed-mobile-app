/// Tests for ReplayPlayerPage.
///
/// Verifies the replay player page:
/// - Displays video player
/// - Shows replay information
/// - Handles navigation
/// - Proper layout and styling
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/replay.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_article.dart';
import 'package:lynewed_beta/features/content/presentation/pages/replay_player_page.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
    NavigatorObserver? observer,
  }) {
    return MaterialApp(
      home: child,
      navigatorObservers: observer != null ? [observer] : [],
    );
  }

  // Use replay without thumbnail to avoid network image loading issues in tests
  final testReplay = Replay(
    id: 'replay-1',
    title: 'Wedding Ceremony Replay',
    description: 'A beautiful ceremony in Paris',
    videoUrl: 'https://vimeo.com/123456',
    videoType: VideoType.vimeo,
    duration: const Duration(minutes: 45, seconds: 30),
    createdAt: DateTime(2025, 6, 15),
  );

  group('ReplayPlayerPage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(ReplayPlayerPage.routeName, 'replay-player');
      });

      test('should have correct route path', () {
        expect(ReplayPlayerPage.routePath, '/replay/:id');
      });
    });

    group('Display', () {
      testWidgets('should display replay title', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        // Title appears both in video player and content section
        expect(find.text('Wedding Ceremony Replay'), findsWidgets);
      });

      testWidgets('should display replay description when available', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        expect(find.text('A beautiful ceremony in Paris'), findsOneWidget);
      });

      testWidgets('should not display description when not available', (tester) async {
        final replayWithoutDesc = Replay(
          id: 'replay-2',
          title: 'Simple Replay',
          videoUrl: 'https://vimeo.com/123',
          videoType: VideoType.vimeo,
          createdAt: DateTime(2025, 6, 15),
        );

        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: replayWithoutDesc),
        ));

        // Title appears in both video player and content section
        expect(find.text('Simple Replay'), findsWidgets);
        expect(find.text('A beautiful ceremony in Paris'), findsNothing);
      });

      testWidgets('should display formatted duration when available', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        // Duration should be displayed somewhere (45:30)
        expect(find.textContaining('45:30'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('should be a StatelessWidget', (tester) async {
        final widget = ReplayPlayerPage(replay: testReplay);
        expect(widget, isA<StatelessWidget>());
      });

      testWidgets('should have a Scaffold', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display back button', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate back when back button is pressed', (tester) async {
        var navigatedBack = false;
        final observer = _MockNavigatorObserver(
          onPop: () => navigatedBack = true,
        );

        await tester.pumpWidget(MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReplayPlayerPage(replay: testReplay),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ));

        // Navigate to page
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(navigatedBack, isTrue);
      });
    });

    group('Video player', () {
      testWidgets('should display video player placeholder', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        // Should show play button
        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });

      testWidgets('should display video type badge', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        // Should show Vimeo badge
        expect(find.textContaining('Vimeo'), findsOneWidget);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept replay parameter', (tester) async {
        final widget = ReplayPlayerPage(replay: testReplay);

        expect(widget.replay, testReplay);
        expect(widget.replay.id, 'replay-1');
      });

      testWidgets('should render without errors', (tester) async {
        expect(
          () async => tester.pumpWidget(buildTestWidget(
            child: ReplayPlayerPage(replay: testReplay),
          )),
          returnsNormally,
        );
      });

      testWidgets('should accept key parameter', (tester) async {
        const key = Key('test-key');
        final widget = ReplayPlayerPage(replay: testReplay, key: key);
        expect(widget.key, key);
      });
    });

    group('Accessibility', () {
      testWidgets('back button should be tappable', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        await tester.tap(find.byIcon(Icons.arrow_back));
        // Should not throw
      });

      testWidgets('video player should be tappable', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: ReplayPlayerPage(replay: testReplay),
        ));

        await tester.tap(find.byIcon(Icons.play_circle_outline));
        // Should not throw
      });
    });
  });
}

/// Mock navigator observer for testing navigation.
class _MockNavigatorObserver extends NavigatorObserver {
  final VoidCallback? onPop;

  _MockNavigatorObserver({this.onPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop?.call();
    super.didPop(route, previousRoute);
  }
}
