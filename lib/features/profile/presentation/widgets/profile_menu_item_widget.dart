/// Profile menu item widget.
///
/// A styled list tile for profile menu items with icon, title,
/// optional subtitle, trailing widget, and tap callback.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/profile_menu_item.dart';

/// A widget that displays a profile menu item.
///
/// Uses [ProfileMenuItemData] to configure the display and behavior.
/// Follows the Lynewed design system styling.
class ProfileMenuItemWidget extends StatelessWidget {
  /// The data for this menu item.
  final ProfileMenuItemData data;

  /// Creates a profile menu item widget.
  const ProfileMenuItemWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Leading icon
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: LynewedColors.gray200,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: Icon(
                  data.icon,
                  size: 20.0,
                  color: LynewedColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.title,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (data.subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      data.subtitle!,
                      style: LynewedTextStyles.labelMedium.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing widget (default to chevron)
            data.trailing ??
                const Icon(
                  Icons.chevron_right,
                  size: 20.0,
                  color: LynewedColors.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}
