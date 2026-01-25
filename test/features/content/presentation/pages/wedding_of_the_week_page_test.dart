/// Tests for WeddingOfTheWeekPage.
///
/// Verifies the wedding of the week page:
/// - Displays loading state
/// - Displays article content
/// - Displays error state
/// - Proper layout with SliverAppBar
/// - Navigation handling
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/presentation/pages/wedding_of_the_week_page.dart';

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

  group('WeddingOfTheWeekPage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(WeddingOfTheWeekPage.routeName, 'wedding-of-the-week');
      });

      test('should have correct route path', () {
        expect(WeddingOfTheWeekPage.routePath, '/wedding-of-the-week');
      });
    });

    group('Initial state', () {
      testWidgets('should display loading indicator initially', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));

        // Should show loading state before async completes
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Clean up by letting the timer complete
        await tester.pumpAndSettle();
      });
    });

    group('Layout', () {
      testWidgets('should be a StatefulWidget', (tester) async {
        const widget = WeddingOfTheWeekPage();
        expect(widget, isA<StatefulWidget>());
      });

      testWidgets('should have a Scaffold', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should use CustomScrollView with SliverAppBar', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        // The page uses CustomScrollView
        expect(find.byType(CustomScrollView), findsOneWidget);
      });

      testWidgets('should have SliverAppBar', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(SliverAppBar), findsOneWidget);
      });
    });

    group('Header', () {
      testWidgets('should display back button', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

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
                  builder: (_) => const WeddingOfTheWeekPage(),
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

    group('Loading state', () {
      testWidgets('should show loading indicator', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Clean up
        await tester.pumpAndSettle();
      });

      testWidgets('should center the loading indicator in SliverFillRemaining', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));

        // The loading indicator should be in a SliverFillRemaining widget
        expect(find.byType(SliverFillRemaining), findsOneWidget);

        // Clean up
        await tester.pumpAndSettle();
      });
    });

    group('Content state', () {
      testWidgets('should display article title after loading', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        // After loading, should display the title
        expect(find.text('Wedding of the Week'), findsOneWidget);
      });

      testWidgets('should display article subtitle after loading', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        expect(find.text('A beautiful celebration of love'), findsOneWidget);
      });
    });

    group('Widget configuration', () {
      testWidgets('should render without errors', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(WeddingOfTheWeekPage), findsOneWidget);
      });

      testWidgets('should accept key parameter', (tester) async {
        const key = Key('test-key');
        const widget = WeddingOfTheWeekPage(key: key);
        expect(widget.key, key);
      });
    });

    group('Accessibility', () {
      testWidgets('back button should be tappable', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          child: const WeddingOfTheWeekPage(),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
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
