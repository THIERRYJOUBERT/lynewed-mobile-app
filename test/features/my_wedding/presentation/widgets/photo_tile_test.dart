/// Tests for PhotoTile widget.
///
/// Comprehensive tests covering:
/// - Normal display (not in selection mode)
/// - Selection mode display
/// - Video overlay
/// - Tap and long press callbacks
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/photo_tile.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/shared_badge.dart';

void main() {
  const testMediaId = 'media-1';
  const testImageUrl = 'https://example.com/image.jpg';
  const testThumbnailUrl = 'https://example.com/thumb.jpg';

  Widget buildPhotoTile({
    String mediaId = testMediaId,
    String imageUrl = testImageUrl,
    String? thumbnailUrl,
    bool isVideo = false,
    bool isSelectionMode = false,
    bool isSelected = false,
    bool isShared = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 100,
          height: 100,
          child: PhotoTile(
            mediaId: mediaId,
            imageUrl: imageUrl,
            thumbnailUrl: thumbnailUrl,
            isVideo: isVideo,
            isSelectionMode: isSelectionMode,
            isSelected: isSelected,
            isShared: isShared,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
      ),
    );
  }

  group('PhotoTile', () {
    group('normal mode', () {
      testWidgets('should display image', (tester) async {
        await tester.pumpWidget(buildPhotoTile());

        expect(find.byType(CachedNetworkImage), findsOneWidget);
      });

      testWidgets('should use thumbnail if provided', (tester) async {
        await tester.pumpWidget(buildPhotoTile(
          thumbnailUrl: testThumbnailUrl,
        ));

        final cachedImage = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        expect(cachedImage.imageUrl, testThumbnailUrl);
      });

      testWidgets('should use imageUrl if no thumbnail', (tester) async {
        await tester.pumpWidget(buildPhotoTile());

        final cachedImage = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        expect(cachedImage.imageUrl, testImageUrl);
      });

      testWidgets('should not show selection checkbox in normal mode',
          (tester) async {
        await tester.pumpWidget(buildPhotoTile(isSelectionMode: false));

        // No checkbox should be visible
        expect(find.byIcon(Icons.check), findsNothing);
      });

      testWidgets('should show video play icon for videos', (tester) async {
        await tester.pumpWidget(buildPhotoTile(isVideo: true));

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('should not show video play icon for photos', (tester) async {
        await tester.pumpWidget(buildPhotoTile(isVideo: false));

        expect(find.byIcon(Icons.play_arrow), findsNothing);
      });
    });

    group('selection mode', () {
      testWidgets('should show empty checkbox when not selected',
          (tester) async {
        await tester.pumpWidget(buildPhotoTile(
          isSelectionMode: true,
          isSelected: false,
        ));

        // There should be a circle container but no check icon
        expect(find.byIcon(Icons.check), findsNothing);
      });

      testWidgets('should show checkmark when selected', (tester) async {
        await tester.pumpWidget(buildPhotoTile(
          isSelectionMode: true,
          isSelected: true,
        ));

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should not show video play icon in selection mode',
          (tester) async {
        await tester.pumpWidget(buildPhotoTile(
          isVideo: true,
          isSelectionMode: true,
        ));

        expect(find.byIcon(Icons.play_arrow), findsNothing);
      });
    });

    group('interactions', () {
      testWidgets('should call onTap when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(buildPhotoTile(
          onTap: () => tapped = true,
        ));

        await tester.tap(find.byType(PhotoTile));
        expect(tapped, true);
      });

      testWidgets('should call onLongPress when long pressed', (tester) async {
        var longPressed = false;
        await tester.pumpWidget(buildPhotoTile(
          onLongPress: () => longPressed = true,
        ));

        await tester.longPress(find.byType(PhotoTile));
        expect(longPressed, true);
      });

      testWidgets('should not crash when onTap is null', (tester) async {
        await tester.pumpWidget(buildPhotoTile(onTap: null));

        await tester.tap(find.byType(PhotoTile));
        // Should not throw
      });

      testWidgets('should not crash when onLongPress is null', (tester) async {
        await tester.pumpWidget(buildPhotoTile(onLongPress: null));

        await tester.longPress(find.byType(PhotoTile));
        // Should not throw
      });
    });

    group('shared badge', () {
      testWidgets('should show shared badge when isShared is true',
          (tester) async {
        await tester.pumpWidget(buildPhotoTile(isShared: true));

        expect(find.byType(SharedBadge), findsOneWidget);
      });

      testWidgets('should not show shared badge when isShared is false',
          (tester) async {
        await tester.pumpWidget(buildPhotoTile(isShared: false));

        expect(find.byType(SharedBadge), findsNothing);
      });

      testWidgets('should not show shared badge in selection mode',
          (tester) async {
        await tester.pumpWidget(buildPhotoTile(
          isShared: true,
          isSelectionMode: true,
        ));

        expect(find.byType(SharedBadge), findsNothing);
      });
    });
  });
}
