/// Delete Confirmation Dialog - confirms photo deletion.
///
/// Shows a confirmation dialog before deleting photos from the gallery.
/// Explains that the guest will still see their photos in their album.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Dialog asking user to confirm photo deletion.
///
/// Supports single and batch deletion with appropriate messaging.
class DeleteConfirmationDialog extends StatelessWidget {
  /// Creates a delete confirmation dialog.
  const DeleteConfirmationDialog({
    super.key,
    required this.count,
    required this.onConfirm,
  });

  /// Number of photos to delete.
  final int count;

  /// Callback when user confirms deletion.
  final VoidCallback onConfirm;

  /// Whether deleting a single item.
  bool get _isSingle => count == 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        _isSingle ? 'Remove photo?' : 'Remove $count photos?',
        style: LynewedTextStyles.headlineSmall,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isSingle
                ? 'This photo will be removed from your gallery.'
                : 'These $count photos will be removed from your gallery.',
            style: LynewedTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: LynewedColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The guest will still see it in their album.',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: LynewedColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

/// Shows the delete confirmation dialog.
///
/// Returns true if user confirmed deletion, false otherwise.
Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  required int count,
}) async {
  bool confirmed = false;

  await showDialog(
    context: context,
    builder: (context) => DeleteConfirmationDialog(
      count: count,
      onConfirm: () => confirmed = true,
    ),
  );

  return confirmed;
}
