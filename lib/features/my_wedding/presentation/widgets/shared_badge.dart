/// Shared Badge Widget
///
/// A small badge indicator showing that a photo is shared with guests.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Badge widget indicating a photo is shared with wedding guests.
///
/// Displays a small circular badge with a people icon.
/// Can be positioned in a Stack overlay on photo tiles.
class SharedBadge extends StatelessWidget {
  /// Creates a shared badge.
  const SharedBadge({
    super.key,
    this.size = 24,
  });

  /// Size of the badge container (icon will be smaller).
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LynewedColors.primary.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.people_outline,
        size: size * 0.65,
        color: Colors.white,
      ),
    );
  }
}
