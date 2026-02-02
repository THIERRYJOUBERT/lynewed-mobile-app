/// Widget displaying a summary of guest statuses.
///
/// Shows counts for:
/// - Total guests
/// - Invited guests (invitation sent)
/// - Joined guests (account created and joined)
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_guest.dart';

/// Summary widget showing guest status counts.
class GuestListSummary extends StatelessWidget {
  const GuestListSummary({
    super.key,
    required this.guests,
  });

  final List<WeddingGuest> guests;

  @override
  Widget build(BuildContext context) {
    final total = guests.length;
    final invited = guests.where((g) => g.status == GuestStatus.invited).length;
    final joined = guests.where((g) => g.status == GuestStatus.joined).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            count: total,
            label: 'guests',
            color: LynewedColors.textSecondary,
          ),
          _SummaryItem(
            count: invited,
            label: 'invitations\nsent',
            color: Colors.amber.shade700,
          ),
          _SummaryItem(
            count: joined,
            label: 'have\njoined',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: LynewedTextStyles.headlineLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
