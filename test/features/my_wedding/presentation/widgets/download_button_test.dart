/// Tests for DownloadButton widget
///
/// Tests download UI behavior, progress indicator, and retry functionality.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/download_button.dart';

void main() {
  group('DownloadButton', () {
    testWidgets('should display download icon when idle', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('should have tooltip', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
            ),
          ),
        ),
      );

      // Assert - Find the IconButton and check its tooltip
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Download');
    });

    testWidgets('should be tappable', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.download_rounded));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should show progress indicator when downloading',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
              isDownloading: true,
              progress: 0.5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should show 0% progress at start', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
              isDownloading: true,
              progress: 0.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('should show 100% progress when complete', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
              isDownloading: true,
              progress: 1.0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should disable tap when downloading', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadButton(
              storageUrl: 'https://example.com/photo.jpg',
              fileName: 'photo.jpg',
              isDownloading: true,
              progress: 0.5,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(DownloadButton));
      await tester.pump();

      // Assert - onTap should not be called when downloading
      expect(tapped, false);
    });
  });

  group('DownloadProgressDialog', () {
    testWidgets('should display downloading message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadProgressDialog(
              progress: 0.5,
              message: 'Downloading...',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Downloading...'), findsOneWidget);
    });

    testWidgets('should display progress bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadProgressDialog(
              progress: 0.5,
              message: 'Downloading...',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display percentage text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadProgressDialog(
              progress: 0.75,
              message: 'Downloading...',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('should display file count for multi-file download',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadProgressDialog(
              progress: 0.5,
              message: 'Creating zip...',
              totalFiles: 5,
              currentFile: 3,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('File 3 of 5'), findsOneWidget);
    });

    testWidgets('should not display file count for single file download',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadProgressDialog(
              progress: 0.5,
              message: 'Downloading...',
              totalFiles: 1,
              currentFile: 1,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('File'), findsNothing);
    });

    testWidgets('should show cancel button when onCancel provided',
        (tester) async {
      // Arrange
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadProgressDialog(
              progress: 0.5,
              message: 'Downloading...',
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Assert
      expect(cancelled, true);
    });
  });

  group('RetryDownloadDialog', () {
    testWidgets('should display error message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RetryDownloadDialog(
              message: 'Network error',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Download Failed'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('should have Cancel and Retry buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RetryDownloadDialog(
              message: 'Network error',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should call onCancel when Cancel tapped', (tester) async {
      // Arrange
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryDownloadDialog(
              message: 'Network error',
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Assert
      expect(cancelled, true);
    });

    testWidgets('should call onRetry when Retry tapped', (tester) async {
      // Arrange
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryDownloadDialog(
              message: 'Network error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert
      expect(retried, true);
    });
  });
}
