/// Download Button Widget for media download functionality.
///
/// Displays a download icon that shows progress during download
/// and handles tap events.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// A button for downloading media files.
///
/// Shows a download icon when idle, and a circular progress indicator
/// with percentage when downloading.
class DownloadButton extends StatelessWidget {
  /// Creates a download button.
  const DownloadButton({
    super.key,
    required this.storageUrl,
    required this.fileName,
    this.isDownloading = false,
    this.progress = 0.0,
    this.onTap,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.color,
  });

  /// The URL to download from.
  final String storageUrl;

  /// The filename to save as.
  final String fileName;

  /// Whether download is in progress.
  final bool isDownloading;

  /// Download progress (0.0 to 1.0).
  final double progress;

  /// Callback when button is tapped.
  final VoidCallback? onTap;

  /// Size of the button container.
  final double size;

  /// Size of the download icon.
  final double iconSize;

  /// Custom color for the icon.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return _buildProgressIndicator();
    }

    return IconButton(
      icon: Icon(
        Icons.download_rounded,
        size: iconSize,
        color: color ?? LynewedColors.textPrimary,
      ),
      tooltip: 'Download',
      onPressed: onTap,
    );
  }

  Widget _buildProgressIndicator() {
    final percentage = (progress * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size - 8,
            height: size - 8,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(color ?? LynewedColors.primary),
              backgroundColor: LynewedColors.gray200,
            ),
          ),
          Text(
            '$percentage%',
            style: LynewedTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: LynewedColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog showing download progress for multi-file downloads.
///
/// Displays a linear progress bar with percentage and file count.
class DownloadProgressDialog extends StatelessWidget {
  /// Creates a download progress dialog.
  const DownloadProgressDialog({
    super.key,
    required this.progress,
    required this.message,
    this.totalFiles = 1,
    this.currentFile = 1,
    this.onCancel,
  });

  /// Download progress (0.0 to 1.0).
  final double progress;

  /// Message to display (e.g., 'Downloading...', 'Creating zip...').
  final String message;

  /// Total number of files being downloaded.
  final int totalFiles;

  /// Current file being downloaded (1-indexed).
  final int currentFile;

  /// Callback when cancel is tapped.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return AlertDialog(
      title: Text(
        message,
        style: LynewedTextStyles.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: LynewedColors.gray200,
            valueColor:
                const AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            '$percentage%',
            style: LynewedTextStyles.headlineSmall,
          ),
          if (totalFiles > 1) ...[
            const SizedBox(height: 8),
            Text(
              'File $currentFile of $totalFiles',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: onCancel != null
          ? [
              TextButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: LynewedTextStyles.labelLarge.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
            ]
          : null,
    );
  }
}

/// Dialog for retry after download failure.
///
/// Displays an error message with Cancel and Retry options.
class RetryDownloadDialog extends StatelessWidget {
  /// Creates a retry download dialog.
  const RetryDownloadDialog({
    super.key,
    required this.message,
    this.onCancel,
    this.onRetry,
  });

  /// Error message to display.
  final String message;

  /// Callback when Cancel is tapped.
  final VoidCallback? onCancel;

  /// Callback when Retry is tapped.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Download Failed',
        style: LynewedTextStyles.titleMedium,
      ),
      content: Text(
        message,
        style: LynewedTextStyles.bodyMedium.copyWith(
          color: LynewedColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: LynewedTextStyles.labelLarge.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: LynewedColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Retry',
            style: LynewedTextStyles.labelLarge.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
