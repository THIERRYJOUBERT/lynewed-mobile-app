/// Empty state widget - Clean Architecture
/// 
/// Displays an empty state message.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// Widget for displaying empty states
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.compact = false,
  });

  final String message;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            message,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: LynewedColors.gray300,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
