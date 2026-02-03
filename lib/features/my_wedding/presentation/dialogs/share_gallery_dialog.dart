/// Share Gallery Dialog
///
/// Confirmation dialog for sharing/unsharing photos with wedding guests.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Dialog for confirming photo sharing with wedding guests.
///
/// Displays the number of photos to share/unshare and provides
/// Cancel and Share/Unshare action buttons.
class ShareGalleryDialog extends StatelessWidget {
  /// Creates a share gallery dialog.
  const ShareGalleryDialog({
    super.key,
    required this.photoCount,
    required this.isSharing,
    this.isUnshare = false,
    this.onCancel,
    this.onShare,
  });

  /// Number of photos to share/unshare.
  final int photoCount;

  /// Whether the share operation is in progress.
  final bool isSharing;

  /// Whether this is an unshare operation (default: false = share).
  final bool isUnshare;

  /// Callback when cancel is tapped.
  final VoidCallback? onCancel;

  /// Callback when share/unshare is tapped.
  final VoidCallback? onShare;

  String get _title => isUnshare ? 'Unshare Photos' : 'Share with Guests';

  String get _actionText => isUnshare ? 'Unshare' : 'Share';

  String get _photoText => photoCount == 1 ? '1 photo' : '$photoCount photos';

  String get _description => isUnshare
      ? 'Remove $_photoText from the shared gallery?\n\nGuests will no longer be able to view or download these photos.'
      : 'Share $_photoText with your wedding guests?\n\nThey will be able to view and download these photos.';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _title,
        style: LynewedTextStyles.sheetTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _description,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSharing ? null : onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isSharing ? LynewedColors.textSecondary : null,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isSharing ? null : onShare,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isUnshare ? LynewedColors.error : LynewedColors.primary,
            foregroundColor: Colors.white,
          ),
          child: isSharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(_actionText),
        ),
      ],
    );
  }
}

/// Shows the share gallery dialog.
///
/// Returns true if the user confirmed the share/unshare action.
Future<bool> showShareGalleryDialog({
  required BuildContext context,
  required int photoCount,
  bool isUnshare = false,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ShareGalleryDialogWrapper(
          photoCount: photoCount,
          isUnshare: isUnshare,
        ),
      ) ??
      false;
}

/// Wrapper widget to handle state for the dialog.
class _ShareGalleryDialogWrapper extends StatefulWidget {
  const _ShareGalleryDialogWrapper({
    required this.photoCount,
    required this.isUnshare,
  });

  final int photoCount;
  final bool isUnshare;

  @override
  State<_ShareGalleryDialogWrapper> createState() =>
      _ShareGalleryDialogWrapperState();
}

class _ShareGalleryDialogWrapperState
    extends State<_ShareGalleryDialogWrapper> {
  @override
  Widget build(BuildContext context) {
    return ShareGalleryDialog(
      photoCount: widget.photoCount,
      isSharing: false,
      isUnshare: widget.isUnshare,
      onCancel: () => Navigator.pop(context, false),
      onShare: () => Navigator.pop(context, true),
    );
  }
}
