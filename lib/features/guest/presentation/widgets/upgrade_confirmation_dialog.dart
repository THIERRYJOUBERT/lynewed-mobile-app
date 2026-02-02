/// Confirmation dialog for upgrading a guest to a bride account.
///
/// Displays warning about irreversible action and lists
/// what data will be preserved.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Dialog asking user to confirm upgrade to bride account.
class UpgradeConfirmationDialog extends StatelessWidget {
  const UpgradeConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Upgrade to Bride account',
              style: LynewedTextStyles.headlineSmall,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Warning: this action is irreversible. You will not be able to switch back to a guest account.',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // What will be preserved
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your photos and account will be preserved.',
                  style: LynewedTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: LynewedColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('I confirm'),
        ),
      ],
    );
  }
}
