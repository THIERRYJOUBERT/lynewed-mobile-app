/// Widget for filtering guests by status.
///
/// Displays a popup menu with filter options:
/// - All
/// - Pending
/// - Invited
/// - Joined
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_guest.dart';

/// Filter options for guest list.
enum GuestStatusFilter {
  all,
  pending,
  invited,
  joined,
}

/// Extension to convert filter to display label.
extension GuestStatusFilterExtension on GuestStatusFilter {
  String get label => switch (this) {
        GuestStatusFilter.all => 'All',
        GuestStatusFilter.pending => 'Pending',
        GuestStatusFilter.invited => 'Invited',
        GuestStatusFilter.joined => 'Joined',
      };
}

/// Widget displaying a filter button with popup menu.
class GuestStatusFilterButton extends StatelessWidget {
  const GuestStatusFilterButton({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final GuestStatusFilter currentFilter;
  final ValueChanged<GuestStatusFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GuestStatusFilter>(
      icon: Badge(
        isLabelVisible: currentFilter != GuestStatusFilter.all,
        backgroundColor: LynewedColors.primary,
        child: const Icon(
          Icons.filter_list,
          color: LynewedColors.textPrimary,
        ),
      ),
      onSelected: onFilterChanged,
      itemBuilder: (context) => GuestStatusFilter.values.map((filter) {
        final isSelected = filter == currentFilter;
        return PopupMenuItem<GuestStatusFilter>(
          value: filter,
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check, size: 18, color: LynewedColors.primary)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(
                filter.label,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Chip showing the current active filter with option to clear.
class GuestStatusFilterChip extends StatelessWidget {
  const GuestStatusFilterChip({
    super.key,
    required this.filter,
    required this.onClear,
  });

  final GuestStatusFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (filter == GuestStatusFilter.all) {
      return const SizedBox.shrink();
    }

    return Chip(
      label: Text(
        filter.label,
        style: LynewedTextStyles.labelMedium.copyWith(
          color: LynewedColors.textPrimary,
        ),
      ),
      backgroundColor: LynewedColors.surface,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onClear,
    );
  }
}

/// Utility to filter guests by status.
List<WeddingGuest> filterGuests(
  List<WeddingGuest> guests,
  GuestStatusFilter filter,
) {
  if (filter == GuestStatusFilter.all) return guests;

  return guests.where((guest) {
    return switch (filter) {
      GuestStatusFilter.pending => guest.status == GuestStatus.pending,
      GuestStatusFilter.invited => guest.status == GuestStatus.invited,
      GuestStatusFilter.joined => guest.status == GuestStatus.joined,
      GuestStatusFilter.all => true,
    };
  }).toList();
}
