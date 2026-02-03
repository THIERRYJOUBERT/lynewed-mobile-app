/// Reorderable Magazine Grid Widget.
///
/// Displays magazine photos in a grid with drag & drop reordering.
/// Shows position numbers and remove buttons on each photo.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../bloc/magazine_selection_state.dart';

/// A reorderable grid of magazine photos.
///
/// Supports drag and drop to reorder photos, with position indicators
/// and remove buttons on each tile.
class ReorderableMagazineGrid extends StatelessWidget {
  /// Creates a reorderable magazine grid.
  const ReorderableMagazineGrid({
    super.key,
    required this.photos,
    required this.onReorder,
    required this.onRemove,
    this.isReordering = false,
  });

  /// List of photos to display.
  final List<MagazinePhoto> photos;

  /// Callback when photos are reordered.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Callback when a photo is removed.
  final void Function(String selectionId) onRemove;

  /// Whether a reorder is currently in progress.
  final bool isReordering;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(12),
      buildDefaultDragHandles: false,
      itemCount: photos.length,
      onReorder: (oldIndex, newIndex) {
        // ReorderableListView gives newIndex as if the item was already removed
        // We need to adjust for our API which expects the final position
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        onReorder(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final animValue = Curves.easeInOut.transform(animation.value);
            final elevation = 8.0 * animValue;
            final scale = 1.0 + (0.05 * animValue);
            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _MagazinePhotoTile(
          key: ValueKey(photo.selectionId),
          photo: photo,
          index: index,
          onRemove: () => onRemove(photo.selectionId),
          isDragging: isReordering,
        );
      },
    );
  }
}

/// A grid-based reorderable magazine display (3 columns).
class ReorderableMagazineGridView extends StatefulWidget {
  /// Creates a grid-based reorderable magazine display.
  const ReorderableMagazineGridView({
    super.key,
    required this.photos,
    required this.onReorder,
    required this.onRemove,
    this.isReordering = false,
    this.crossAxisCount = 3,
  });

  /// List of photos to display.
  final List<MagazinePhoto> photos;

  /// Callback when photos are reordered.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Callback when a photo is removed.
  final void Function(String selectionId) onRemove;

  /// Whether a reorder is currently in progress.
  final bool isReordering;

  /// Number of columns in the grid.
  final int crossAxisCount;

  @override
  State<ReorderableMagazineGridView> createState() =>
      _ReorderableMagazineGridViewState();
}

class _ReorderableMagazineGridViewState
    extends State<ReorderableMagazineGridView> {
  int? _dragStartIndex;
  int? _dragOverIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        final photo = widget.photos[index];
        final isDragTarget = _dragOverIndex == index && _dragStartIndex != index;

        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 40) /
                  widget.crossAxisCount,
              height: (MediaQuery.of(context).size.width - 40) /
                  widget.crossAxisCount,
              child: _MagazineGridTile(
                photo: photo,
                showRemove: false,
                onRemove: () {},
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _MagazineGridTile(
              photo: photo,
              showRemove: false,
              onRemove: () {},
            ),
          ),
          onDragStarted: () {
            setState(() {
              _dragStartIndex = index;
            });
          },
          onDragEnd: (details) {
            setState(() {
              _dragStartIndex = null;
              _dragOverIndex = null;
            });
          },
          child: DragTarget<int>(
            onWillAcceptWithDetails: (details) {
              setState(() {
                _dragOverIndex = index;
              });
              return details.data != index;
            },
            onLeave: (data) {
              setState(() {
                if (_dragOverIndex == index) {
                  _dragOverIndex = null;
                }
              });
            },
            onAcceptWithDetails: (details) {
              widget.onReorder(details.data, index);
              setState(() {
                _dragStartIndex = null;
                _dragOverIndex = null;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: isDragTarget
                      ? Border.all(color: LynewedColors.primary, width: 2)
                      : null,
                ),
                child: _MagazineGridTile(
                  photo: photo,
                  showRemove: true,
                  onRemove: () => widget.onRemove(photo.selectionId),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A single tile in the magazine grid.
class _MagazineGridTile extends StatelessWidget {
  const _MagazineGridTile({
    required this.photo,
    required this.showRemove,
    required this.onRemove,
  });

  final MagazinePhoto photo;
  final bool showRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          CachedNetworkImage(
            imageUrl: photo.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: LynewedColors.gray200,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(LynewedColors.gray300),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: LynewedColors.gray200,
              child: const Icon(
                Icons.broken_image_outlined,
                color: LynewedColors.gray300,
              ),
            ),
          ),
          // Position badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${photo.position}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Remove button
          if (showRemove)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A single tile in the magazine list (used for ReorderableListView).
class _MagazinePhotoTile extends StatelessWidget {
  const _MagazinePhotoTile({
    super.key,
    required this.photo,
    required this.index,
    required this.onRemove,
    this.isDragging = false,
  });

  final MagazinePhoto photo;
  final int index;
  final VoidCallback onRemove;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 40,
              height: 80,
              decoration: const BoxDecoration(
                color: LynewedColors.gray100,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
              ),
              child: const Icon(
                Icons.drag_indicator,
                color: LynewedColors.gray300,
              ),
            ),
          ),
          // Position number
          Container(
            width: 32,
            height: 80,
            alignment: Alignment.center,
            child: Text(
              '${photo.position}',
              style: LynewedTextStyles.headlineSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          // Photo thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CachedNetworkImage(
                imageUrl: photo.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: LynewedColors.gray200),
                errorWidget: (_, __, ___) => Container(
                  color: LynewedColors.gray200,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.remove_circle_outline,
              color: LynewedColors.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
