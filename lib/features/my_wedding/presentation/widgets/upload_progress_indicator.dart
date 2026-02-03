/// Upload Progress Indicator widget
///
/// Displays a circular progress indicator with percentage text.
/// Used during media upload to show progress to the user.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Circular progress indicator with percentage display
///
/// Shows upload progress as both a circular indicator and percentage text.
class UploadProgressIndicator extends StatelessWidget {
  const UploadProgressIndicator({
    super.key,
    required this.progress,
    this.size = 64.0,
    this.strokeWidth = 4.0,
    this.showPercentage = true,
    this.backgroundColor,
    this.progressColor,
    this.textStyle,
  });

  /// Upload progress from 0.0 to 1.0
  final double progress;

  /// Size of the circular indicator
  final double size;

  /// Width of the progress stroke
  final double strokeWidth;

  /// Whether to show the percentage text in the center
  final bool showPercentage;

  /// Background color for the indicator track
  final Color? backgroundColor;

  /// Color for the progress indicator
  final Color? progressColor;

  /// Custom text style for the percentage
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt().clamp(0, 100);
    final bgColor = backgroundColor ?? LynewedColors.gray200;
    final fgColor = progressColor ?? LynewedColors.primary;
    final defaultTextStyle = textStyle ??
        LynewedTextStyles.labelSmall.copyWith(
          color: LynewedColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress indicator
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          // Percentage text
          if (showPercentage)
            Text(
              '$percentage%',
              style: defaultTextStyle,
            ),
        ],
      ),
    );
  }
}

/// A compact upload progress indicator for use in grid tiles
///
/// Shows an overlay with progress during upload.
class UploadProgressOverlay extends StatelessWidget {
  const UploadProgressOverlay({
    super.key,
    required this.progress,
    this.isUploading = true,
  });

  /// Upload progress from 0.0 to 1.0
  final double progress;

  /// Whether upload is currently in progress
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    if (!isUploading) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 8),
            Text(
              'Uploading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
