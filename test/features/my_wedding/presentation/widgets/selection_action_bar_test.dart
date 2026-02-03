/// Tests for SelectionActionBar widget.
///
/// Comprehensive tests covering:
/// - Display of selected count
/// - Select all / Clear button
/// - Action buttons
/// - Callbacks
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/selection_action_bar.dart';

void main() {
  Widget buildSelectionActionBar({
    int selectedCount = 3,
    int totalCount = 10,
    VoidCallback? onClose,
    VoidCallback? onSelectAll,
    VoidCallback? onFavorite,
    VoidCallback? onHide,
    VoidCallback? onShare,
    VoidCallback? onAddToMagazine,
    VoidCallback? onDownload,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SelectionActionBar(
          selectedCount: selectedCount,
          totalCount: totalCount,
          onClose: onClose ?? () {},
          onSelectAll: onSelectAll ?? () {},
          onFavorite: onFavorite,
          onHide: onHide,
          onShare: onShare,
          onAddToMagazine: onAddToMagazine,
          onDownload: onDownload,
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('SelectionActionBar', () {
    group('display', () {
      testWidgets('should display selected count', (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(selectedCount: 5));

        expect(find.text('5 selected'), findsOneWidget);
      });

      testWidgets('should display Select all when not all selected',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          selectedCount: 3,
          totalCount: 10,
        ));

        expect(find.text('Select all'), findsOneWidget);
        expect(find.text('Clear'), findsNothing);
      });

      testWidgets('should display Clear when all selected', (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          selectedCount: 10,
          totalCount: 10,
        ));

        expect(find.text('Clear'), findsOneWidget);
        expect(find.text('Select all'), findsNothing);
      });

      testWidgets('should display close button', (tester) async {
        await tester.pumpWidget(buildSelectionActionBar());

        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('action buttons', () {
      testWidgets('should display Favorite button when onFavorite provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onFavorite: () {},
        ));

        expect(find.text('Favorite'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      });

      testWidgets('should display Hide button when onHide provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onHide: () {},
        ));

        expect(find.text('Hide'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      });

      testWidgets('should display Share button when onShare provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onShare: () {},
        ));

        expect(find.text('Share'), findsOneWidget);
        expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      });

      testWidgets('should not display Share button when onShare is null',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onShare: null,
        ));

        expect(find.text('Share'), findsNothing);
      });

      testWidgets('should display Magazine button when onAddToMagazine provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onAddToMagazine: () {},
        ));

        expect(find.text('Magazine'), findsOneWidget);
        expect(find.byIcon(Icons.auto_stories_outlined), findsOneWidget);
      });

      testWidgets('should display Download button when onDownload provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onDownload: () {},
        ));

        expect(find.text('Download'), findsOneWidget);
        expect(find.byIcon(Icons.download_outlined), findsOneWidget);
      });

      testWidgets('should display Delete button when onDelete provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onDelete: () {},
        ));

        expect(find.text('Delete'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('should display all action buttons when all callbacks provided',
          (tester) async {
        await tester.pumpWidget(buildSelectionActionBar(
          onFavorite: () {},
          onHide: () {},
          onShare: () {},
          onAddToMagazine: () {},
          onDownload: () {},
          onDelete: () {},
        ));

        expect(find.text('Favorite'), findsOneWidget);
        expect(find.text('Hide'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Magazine'), findsOneWidget);
        expect(find.text('Download'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('should call onClose when close button tapped',
          (tester) async {
        var closeCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          onClose: () => closeCalled = true,
        ));

        await tester.tap(find.byIcon(Icons.close));
        expect(closeCalled, true);
      });

      testWidgets('should call onSelectAll when Select all tapped',
          (tester) async {
        var selectAllCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          selectedCount: 3,
          totalCount: 10,
          onSelectAll: () => selectAllCalled = true,
        ));

        await tester.tap(find.text('Select all'));
        expect(selectAllCalled, true);
      });

      testWidgets('should call onSelectAll when Clear tapped', (tester) async {
        var selectAllCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          selectedCount: 10,
          totalCount: 10,
          onSelectAll: () => selectAllCalled = true,
        ));

        await tester.tap(find.text('Clear'));
        expect(selectAllCalled, true);
      });

      testWidgets('should call onFavorite when Favorite button tapped',
          (tester) async {
        var favoriteCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          onFavorite: () => favoriteCalled = true,
        ));

        await tester.tap(find.text('Favorite'));
        expect(favoriteCalled, true);
      });

      testWidgets('should call onHide when Hide button tapped',
          (tester) async {
        var hideCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          onHide: () => hideCalled = true,
        ));

        await tester.tap(find.text('Hide'));
        expect(hideCalled, true);
      });

      testWidgets('should call onShare when Share button tapped',
          (tester) async {
        var shareCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          onShare: () => shareCalled = true,
        ));

        await tester.tap(find.text('Share'));
        expect(shareCalled, true);
      });

      testWidgets('should call onDownload when Download button tapped',
          (tester) async {
        var downloadCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          onDownload: () => downloadCalled = true,
        ));

        await tester.tap(find.text('Download'));
        expect(downloadCalled, true);
      });

      testWidgets('should call onDelete when Delete button tapped',
          (tester) async {
        var deleteCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          onDelete: () => deleteCalled = true,
        ));

        await tester.tap(find.text('Delete'));
        expect(deleteCalled, true);
      });

      testWidgets('should not call action callbacks when selectedCount is 0',
          (tester) async {
        var shareCalled = false;
        await tester.pumpWidget(buildSelectionActionBar(
          selectedCount: 0,
          onShare: () => shareCalled = true,
        ));

        await tester.tap(find.text('Share'));
        expect(shareCalled, false);
      });
    });
  });
}
