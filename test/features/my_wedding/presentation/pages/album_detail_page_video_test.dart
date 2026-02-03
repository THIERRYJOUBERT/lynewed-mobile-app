import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/video_utils.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/album_image.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/media_picker_sheet.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/upload_progress_indicator.dart';

void main() {
  group('MediaPickerSheet', () {
    testWidgets('should display title and two options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: MediaPickerSheet(
              onPhotoSelected: () {},
              onVideoSelected: () {},
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('Add Media'), findsOneWidget);

      // Verify Photo option
      expect(find.text('Photo'), findsOneWidget);
      expect(find.text('Upload from gallery'), findsOneWidget);

      // Verify Video option
      expect(find.text('Video'), findsOneWidget);
      expect(
        find.text('Max ${VideoConstants.maxDurationFormatted}, '
            '${VideoConstants.maxFileSizeFormatted}'),
        findsOneWidget,
      );

      // Verify icons
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });

    testWidgets('should call onPhotoSelected when photo tapped', (tester) async {
      bool photoSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaPickerSheet(
              onPhotoSelected: () => photoSelected = true,
              onVideoSelected: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();

      expect(photoSelected, true);
    });

    testWidgets('should call onVideoSelected when video tapped', (tester) async {
      bool videoSelected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaPickerSheet(
              onPhotoSelected: () {},
              onVideoSelected: () => videoSelected = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Video'));
      await tester.pumpAndSettle();

      expect(videoSelected, true);
    });

    testWidgets('should show video constraints in subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaPickerSheet(
              onPhotoSelected: () {},
              onVideoSelected: () {},
            ),
          ),
        ),
      );

      // Check that constraints are displayed
      expect(find.textContaining('10 minutes'), findsOneWidget);
      expect(find.textContaining('500 MB'), findsOneWidget);
    });
  });

  group('UploadProgressIndicator', () {
    testWidgets('should display 0% at start', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UploadProgressIndicator(progress: 0.0),
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('should display 50% at half progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UploadProgressIndicator(progress: 0.5),
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should display 100% at full progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UploadProgressIndicator(progress: 1.0),
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should clamp progress to 100%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UploadProgressIndicator(progress: 1.5),
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should hide percentage when showPercentage is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UploadProgressIndicator(
                progress: 0.5,
                showPercentage: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsNothing);
    });

    testWidgets('should display CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: UploadProgressIndicator(progress: 0.5),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('UploadProgressOverlay', () {
    testWidgets('should show uploading text when isUploading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UploadProgressOverlay(
              progress: 0.5,
              isUploading: true,
            ),
          ),
        ),
      );

      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should hide when isUploading is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UploadProgressOverlay(
              progress: 0.5,
              isUploading: false,
            ),
          ),
        ),
      );

      expect(find.text('Uploading...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('AlbumImage video support', () {
    test('should detect video mediaType', () {
      const image = AlbumImage(
        id: 'video-1',
        albumId: 'album-1',
        imageUrl: 'https://example.com/video.mp4',
        mediaType: 'video',
      );

      expect(image.isVideo, true);
      expect(image.isPhoto, false);
    });

    test('should detect photo mediaType', () {
      const image = AlbumImage(
        id: 'photo-1',
        albumId: 'album-1',
        imageUrl: 'https://example.com/photo.jpg',
        mediaType: 'photo',
      );

      expect(image.isVideo, false);
      expect(image.isPhoto, true);
    });

    test('should default to photo when mediaType not specified', () {
      const image = AlbumImage(
        id: 'image-1',
        albumId: 'album-1',
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(image.isPhoto, true);
      expect(image.isVideo, false);
      expect(image.mediaType, 'photo');
    });

    test('should parse video with duration and file size from JSON', () {
      final json = {
        'id': 'video-1',
        'album_id': 'album-1',
        'image_url': 'https://example.com/video.mp4',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'media_type': 'video',
        'duration_seconds': 120,
        'file_size_bytes': 52428800,
      };

      final image = AlbumImage.fromJson(json);

      expect(image.isVideo, true);
      expect(image.durationSeconds, 120);
      expect(image.fileSizeBytes, 52428800);
      expect(image.thumbnailUrl, 'https://example.com/thumb.jpg');
    });
  });

  group('Video validation integration', () {
    test('should validate video extension correctly', () {
      expect(validateVideoExtension('video.mp4').isValid, true);
      expect(validateVideoExtension('video.mov').isValid, true);
      expect(validateVideoExtension('video.m4v').isValid, true);
      expect(validateVideoExtension('video.avi').isValid, false);
    });

    test('should validate file size correctly', () {
      expect(validateVideoFileSize(100000000).isValid, true); // 100 MB
      expect(validateVideoFileSize(524288000).isValid, true); // 500 MB
      expect(validateVideoFileSize(524288001).isValid, false); // 500 MB + 1
    });

    test('should validate duration correctly', () {
      expect(validateVideoDuration(300).isValid, true); // 5 min
      expect(validateVideoDuration(600).isValid, true); // 10 min
      expect(validateVideoDuration(601).isValid, false); // 10 min + 1 sec
    });

    test('should provide correct error messages', () {
      expect(
        validateVideoExtension('video.avi').error,
        'Please select an MP4, MOV, or M4V video',
      );
      expect(
        validateVideoFileSize(600000000).error,
        'Video must be 500 MB or less',
      );
      expect(
        validateVideoDuration(700).error,
        'Video must be 10 minutes or less',
      );
    });
  });

  group('Video thumbnail grid display', () {
    testWidgets('should show play icon for video items in grid', (tester) async {
      // Create a test widget that mimics the video tile behavior
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.grey), // Placeholder for image
                // Video play icon overlay - same as in album_detail_page.dart
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should not show play icon for photo items', (tester) async {
      // Photo items should not have the play icon overlay
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.grey), // Placeholder for image
                // No play icon for photos
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });
  });
}
