/// Media Picker Sheet for selecting Photo or Video upload
///
/// Uses LynewedSheet design component with Photo and Video options.
/// Video option shows max duration and file size limits.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '/core/utils/video_utils.dart';

/// Sheet for selecting media type (Photo or Video)
class MediaPickerSheet extends StatelessWidget {
  const MediaPickerSheet({
    super.key,
    required this.onPhotoSelected,
    required this.onVideoSelected,
  });

  /// Callback when Photo option is selected
  final VoidCallback onPhotoSelected;

  /// Callback when Video option is selected
  final VoidCallback onVideoSelected;

  /// Shows the media picker sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onPhotoSelected,
    required VoidCallback onVideoSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MediaPickerSheet(
        onPhotoSelected: onPhotoSelected,
        onVideoSelected: onVideoSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Add Media',
      onClose: () => Navigator.pop(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MediaOption(
            icon: Icons.photo_camera_outlined,
            label: 'Photo',
            subtitle: 'Upload from gallery',
            onTap: () {
              Navigator.pop(context);
              onPhotoSelected();
            },
          ),
          const SizedBox(height: 12),
          _MediaOption(
            icon: Icons.videocam_outlined,
            label: 'Video',
            subtitle: 'Max ${VideoConstants.maxDurationFormatted}, '
                '${VideoConstants.maxFileSizeFormatted}',
            onTap: () {
              Navigator.pop(context);
              onVideoSelected();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Individual media type option row
class _MediaOption extends StatelessWidget {
  const _MediaOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LynewedColors.gray100),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: LynewedColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: LynewedColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: LynewedTextStyles.labelLarge.copyWith(
                      color: LynewedColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: LynewedColors.gray300,
            ),
          ],
        ),
      ),
    );
  }
}
