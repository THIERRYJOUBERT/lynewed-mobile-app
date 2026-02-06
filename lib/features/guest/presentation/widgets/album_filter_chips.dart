/// Filter chips for the guest album page.
///
/// Allows filtering by All, Photos, or Videos.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Active filter type for the album.
enum AlbumFilter {
  /// Show all media.
  all,

  /// Show only photos.
  photos,

  /// Show only videos.
  videos,
}

/// Row of filter chips for the guest album.
///
/// Layout: [ All ]  [ Photos ]  [ Videos ]
class AlbumFilterChips extends StatelessWidget {
  /// Creates album filter chips.
  const AlbumFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  /// The currently active filter.
  final AlbumFilter activeFilter;

  /// Called when a filter is selected.
  final ValueChanged<AlbumFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: null,
            selected: activeFilter == AlbumFilter.all,
            onTap: () => onFilterChanged(AlbumFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Photos',
            icon: Icons.photo_camera_outlined,
            selected: activeFilter == AlbumFilter.photos,
            onTap: () => onFilterChanged(AlbumFilter.photos),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Videos',
            icon: Icons.videocam_outlined,
            selected: activeFilter == AlbumFilter.videos,
            onTap: () => onFilterChanged(AlbumFilter.videos),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? LynewedColors.primary : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? LynewedColors.textOnPrimary
                    : LynewedColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: LynewedTextStyles.chipText.copyWith(
                color: selected
                    ? LynewedColors.textOnPrimary
                    : LynewedColors.textPrimary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
