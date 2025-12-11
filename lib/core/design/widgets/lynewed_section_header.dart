import 'package:flutter/material.dart';
import '../design.dart';

/// Section header with title and optional action button
/// 
/// Design System V4:
/// - Title: titleMedium (16px, w500)
/// - Action: bodyMedium (14px, w400) with textSecondary color
/// - Used for My Wedding page sections
class LynewedSectionHeader extends StatelessWidget {
  const LynewedSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  /// Section title
  final String title;
  
  /// Optional action button label (e.g., "View all", "Add")
  final String? actionLabel;
  
  /// Callback when action is tapped
  final VoidCallback? onAction;
  
  /// Optional custom trailing widget (overrides actionLabel)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: LynewedTextStyles.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null)
          trailing!
        else if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                actionLabel!,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
