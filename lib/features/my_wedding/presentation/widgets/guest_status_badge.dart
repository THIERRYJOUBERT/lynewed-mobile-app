/// Widget displaying the invitation status of a wedding guest.
///
/// Shows different colors and icons based on status:
/// - pending: no badge
/// - invited: yellow badge with mail icon
/// - joined: green badge with check icon
library;

import 'package:flutter/material.dart';

import '../../domain/entities/wedding_guest.dart';

/// Badge displaying guest invitation status.
class GuestStatusBadge extends StatelessWidget {
  const GuestStatusBadge({
    super.key,
    required this.status,
  });

  final GuestStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, text, icon) = switch (status) {
      GuestStatus.invited => (Colors.amber, 'Invité', Icons.mail_outline),
      GuestStatus.joined => (Colors.green, 'Rejoint', Icons.check_circle_outline),
      GuestStatus.pending => (Colors.grey, '', null),
    };

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
