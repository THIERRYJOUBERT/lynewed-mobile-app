/// Gallery Grid Widget - Multi-select gallery with filter tabs.
///
/// Displays a grid of photos/videos with selection mode support.
/// Includes filter tabs (All, Favorites, Hidden) and selection action bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/design/design.dart';
import '../../domain/entities/album_image.dart';
import '../bloc/gallery_selection_cubit.dart';
import '../bloc/gallery_selection_state.dart';
import 'photo_tile.dart';
import 'selection_action_bar.dart';

/// Media item data for the gallery grid.
class GalleryMediaItem {
  /// Creates a gallery media item.
  const GalleryMediaItem({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.isVideo = false,
    this.isFavorite = false,
    this.isHidden = false,
  });

  /// Creates a gallery media item from an AlbumImage.
  factory GalleryMediaItem.fromAlbumImage(AlbumImage image) {
    return GalleryMediaItem(
      id: image.id,
      imageUrl: image.imageUrl,
      thumbnailUrl: image.thumbnailUrl,
      isVideo: image.isVideo,
      isFavorite: image.isFavorite,
      isHidden: image.isHidden,
    );
  }

  /// The unique ID of the media item.
  final String id;

  /// The URL of the full-size image.
  final String imageUrl;

  /// The URL of the thumbnail image (optional).
  final String? thumbnailUrl;

  /// Whether this media item is a video.
  final bool isVideo;

  /// Whether this media item is marked as favorite.
  final bool isFavorite;

  /// Whether this media item is hidden.
  final bool isHidden;
}

/// A gallery grid widget with multi-select functionality.
///
/// Provides:
/// - Filter tabs (All, Favorites, Hidden)
/// - Selection mode via long press
/// - Selection action bar with actions
/// - Grid display with 3 columns
class GalleryGrid extends StatelessWidget {
  /// Creates a gallery grid widget.
  const GalleryGrid({
    super.key,
    required this.mediaItems,
    this.onMediaTap,
    this.onFavoriteSelected,
    this.onHideSelected,
    this.onDownloadSelected,
    this.onDeleteSelected,
    this.onShareSelected,
    this.onAddToMagazine,
    this.showFilterTabs = true,
    this.isReadOnly = false,
  });

  /// List of media items to display.
  final List<GalleryMediaItem> mediaItems;

  /// Callback when a media item is tapped (not in selection mode).
  final void Function(GalleryMediaItem item)? onMediaTap;

  /// Callback when favorite is requested for selected items.
  final void Function(Set<String> selectedIds)? onFavoriteSelected;

  /// Callback when hide is requested for selected items.
  final void Function(Set<String> selectedIds)? onHideSelected;

  /// Callback when download is requested for selected items.
  final void Function(Set<String> selectedIds)? onDownloadSelected;

  /// Callback when delete is requested for selected items.
  final void Function(Set<String> selectedIds)? onDeleteSelected;

  /// Callback when share is requested for selected items.
  final void Function(Set<String> selectedIds)? onShareSelected;

  /// Callback when add to magazine is requested for selected items.
  final void Function(Set<String> selectedIds)? onAddToMagazine;

  /// Whether to show the filter tabs.
  final bool showFilterTabs;

  /// Whether the gallery is read-only (no selection mode).
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GallerySelectionCubit(),
      child: BlocBuilder<GallerySelectionCubit, GallerySelectionState>(
        builder: (context, state) {
          final filteredItems = _getFilteredItems(state.currentFilter);
          final allFilteredIds = filteredItems.map((e) => e.id).toList();

          return Column(
            children: [
              // Selection action bar (when in selection mode)
              if (state.isSelectionMode)
                SelectionActionBar(
                  selectedCount: state.selectedCount,
                  totalCount: filteredItems.length,
                  onClose: () =>
                      context.read<GallerySelectionCubit>().exitSelectionMode(),
                  onSelectAll: () {
                    final cubit = context.read<GallerySelectionCubit>();
                    if (state.selectedCount == filteredItems.length) {
                      cubit.deselectAll();
                    } else {
                      cubit.selectAll(allFilteredIds);
                    }
                  },
                  onFavorite: onFavoriteSelected != null && !isReadOnly
                      ? () => onFavoriteSelected!(state.selectedMediaIds)
                      : null,
                  onHide: onHideSelected != null && !isReadOnly
                      ? () => onHideSelected!(state.selectedMediaIds)
                      : null,
                  onShare: onShareSelected != null
                      ? () => onShareSelected!(state.selectedMediaIds)
                      : null,
                  onAddToMagazine: onAddToMagazine != null
                      ? () => onAddToMagazine!(state.selectedMediaIds)
                      : null,
                  onDownload: onDownloadSelected != null
                      ? () => onDownloadSelected!(state.selectedMediaIds)
                      : null,
                  onDelete: onDeleteSelected != null && !isReadOnly
                      ? () => onDeleteSelected!(state.selectedMediaIds)
                      : null,
                ),
              // Filter tabs (when not in selection mode)
              if (showFilterTabs && !state.isSelectionMode)
                _buildFilterTabs(context, state),
              // Grid
              Expanded(
                child: filteredItems.isEmpty
                    ? _buildEmptyState(state.currentFilter)
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return PhotoTile(
                            mediaId: item.id,
                            imageUrl: item.imageUrl,
                            thumbnailUrl: item.thumbnailUrl,
                            isVideo: item.isVideo,
                            isSelectionMode: state.isSelectionMode,
                            isSelected: state.isSelected(item.id),
                            onTap: () => _handleTap(context, state, item),
                            onLongPress: isReadOnly
                                ? null
                                : () => context
                                    .read<GallerySelectionCubit>()
                                    .enterSelectionMode(item.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<GalleryMediaItem> _getFilteredItems(GalleryFilter filter) {
    switch (filter) {
      case GalleryFilter.all:
        return mediaItems.where((item) => !item.isHidden).toList();
      case GalleryFilter.favorites:
        return mediaItems.where((item) => item.isFavorite).toList();
      case GalleryFilter.hidden:
        return mediaItems.where((item) => item.isHidden).toList();
    }
  }

  void _handleTap(
    BuildContext context,
    GallerySelectionState state,
    GalleryMediaItem item,
  ) {
    if (state.isSelectionMode) {
      context.read<GallerySelectionCubit>().toggleSelection(item.id);
    } else {
      onMediaTap?.call(item);
    }
  }

  Widget _buildFilterTabs(BuildContext context, GallerySelectionState state) {
    final allCount = mediaItems.where((item) => !item.isHidden).length;
    final favoritesCount = mediaItems.where((item) => item.isFavorite).length;
    final hiddenCount = mediaItems.where((item) => item.isHidden).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          LynewedChip(
            label: 'All',
            selected: state.currentFilter == GalleryFilter.all,
            count: allCount,
            onSelected: (_) =>
                context.read<GallerySelectionCubit>().setFilter(GalleryFilter.all),
          ),
          const SizedBox(width: 8),
          LynewedChip(
            label: 'Favorites',
            selected: state.currentFilter == GalleryFilter.favorites,
            count: favoritesCount > 0 ? favoritesCount : null,
            onSelected: (_) => context
                .read<GallerySelectionCubit>()
                .setFilter(GalleryFilter.favorites),
          ),
          const SizedBox(width: 8),
          LynewedChip(
            label: 'Hidden',
            selected: state.currentFilter == GalleryFilter.hidden,
            count: hiddenCount > 0 ? hiddenCount : null,
            onSelected: (_) => context
                .read<GallerySelectionCubit>()
                .setFilter(GalleryFilter.hidden),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(GalleryFilter filter) {
    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case GalleryFilter.all:
        title = 'No photos yet';
        subtitle = 'Upload photos from your gallery';
        icon = Icons.photo_library_outlined;
      case GalleryFilter.favorites:
        title = 'No favorites yet';
        subtitle = 'Mark photos as favorites to see them here';
        icon = Icons.favorite_outline;
      case GalleryFilter.hidden:
        title = 'No hidden photos';
        subtitle = 'Hidden photos will appear here';
        icon = Icons.visibility_off_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: LynewedSpacing.lg),
            Text(
              title,
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            const SizedBox(height: LynewedSpacing.sm),
            Text(
              subtitle,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
