import 'package:flutter/material.dart';
import '../design.dart';

/// Section title widget for sheets and forms
/// 
/// Design System v2:
/// - Style: bodyLarge + w600
/// - Color: textPrimary
/// - Spacing: 10px to content below
class LynewedSectionTitle extends StatelessWidget {
  const LynewedSectionTitle(
    this.title, {
    super.key,
    this.trailing,
  });

  /// Title text
  final String title;
  
  /// Optional trailing widget (e.g., "View all" link)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (trailing != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: LynewedTextStyles.sectionTitle,
          ),
          trailing!,
        ],
      );
    }
    
    return Text(
      title,
      style: LynewedTextStyles.sectionTitle,
    );
  }
}
