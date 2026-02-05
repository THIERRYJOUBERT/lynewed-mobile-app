/// Magazine Page Edit Sheet.
///
/// Bottom sheet for editing a single magazine page's layout and photos.
/// Manages local state with nullable slots — changes are only committed
/// to the cubit when the user taps Save.
///
/// Supports two modes:
/// - Edit mode: modify an existing page's layout and photos.
/// - Create mode: build a new page from scratch.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';
import '../bloc/magazine_preview_cubit.dart';
import '../bloc/magazine_selection_state.dart';
import '../widgets/layout_option_tile.dart';

/// Bottom sheet for editing a magazine page.
class MagazinePageEditSheet extends StatefulWidget {
  /// Creates a magazine page edit sheet in edit mode.
  const MagazinePageEditSheet._({
    required this.cubit,
    required this.isNewPage,
    this.pageIndex,
    this.afterIndex,
  });

  /// The preview cubit for state management.
  final MagazinePreviewCubit cubit;

  /// Whether this is a new page creation.
  final bool isNewPage;

  /// The index of the page being edited (edit mode only).
  final int? pageIndex;

  /// The index after which to insert a new page (create mode only).
  final int? afterIndex;

  /// Shows the page edit sheet in edit mode.
  static Future<void> show(
    BuildContext context, {
    required int pageIndex,
    required MagazinePreviewCubit cubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MagazinePageEditSheet._(
        cubit: cubit,
        isNewPage: false,
        pageIndex: pageIndex,
      ),
    );
  }

  /// Shows the page edit sheet in create mode.
  static Future<void> showCreate(
    BuildContext context, {
    required int afterIndex,
    required MagazinePreviewCubit cubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MagazinePageEditSheet._(
        cubit: cubit,
        isNewPage: true,
        afterIndex: afterIndex,
      ),
    );
  }

  @override
  State<MagazinePageEditSheet> createState() => _MagazinePageEditSheetState();
}

class _MagazinePageEditSheetState extends State<MagazinePageEditSheet> {
  late EditablePageLayout _targetLayout;
  late List<MagazinePhoto?> _slots;
  late List<MagazinePhoto> _available;
  int? _selectedSlotIndex;

  // Cover text controllers (only used when editing cover).
  TextEditingController? _titleController;
  TextEditingController? _subtitleController;

  bool get _isNewPage => widget.isNewPage;
  bool get _isCover =>
      !_isNewPage &&
      widget.pageIndex != null &&
      widget.pageIndex! < widget.cubit.state.pages.length &&
      widget.cubit.state.pages[widget.pageIndex!] is CoverPage;

  bool get _allSlotsFilled => _slots.every((s) => s != null);

  @override
  void initState() {
    super.initState();
    if (_isNewPage) {
      _targetLayout = EditablePageLayout.single;
      _slots = [null];
      _available = List.from(widget.cubit.state.unassignedPhotos);
    } else {
      final page = widget.cubit.state.pages[widget.pageIndex!];
      _targetLayout = EditablePageLayout.fromPage(page);
      _slots = List<MagazinePhoto?>.from(page.photos);
      _available = List.from(widget.cubit.state.unassignedPhotos);

      // Initialize cover text controllers.
      if (page is CoverPage) {
        _titleController = TextEditingController(text: page.weddingTitle);
        _subtitleController = TextEditingController(text: page.coverSubtitle);
      }
    }
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _subtitleController?.dispose();
    super.dispose();
  }

  void _changeLayout(EditablePageLayout newLayout) {
    if (newLayout == _targetLayout) return;

    final oldCount = _targetLayout.photoCount;
    final newCount = newLayout.photoCount;

    if (newCount < oldCount) {
      // Shrinking: move excess filled slots to available.
      final excess = _slots.sublist(newCount);
      for (final photo in excess) {
        if (photo != null) {
          _available.add(photo);
        }
      }
      _slots = _slots.sublist(0, newCount);
    } else {
      // Growing: add null slots at the end (no auto-fill).
      _slots = [
        ..._slots,
        ...List<MagazinePhoto?>.filled(newCount - oldCount, null),
      ];
    }

    _targetLayout = newLayout;
    _selectedSlotIndex = null;
  }

  void _removePhotoFromSlot(int index) {
    final photo = _slots[index];
    if (photo != null) {
      _available.add(photo);
    }
    _slots[index] = null;
    _selectedSlotIndex = null;
  }

  void _fillSlot(int slotIndex, MagazinePhoto photo) {
    // If slot already has a photo, send it back to available.
    final existing = _slots[slotIndex];
    if (existing != null) {
      _available.add(existing);
    }
    _slots[slotIndex] = photo;
    _available.remove(photo);
    _selectedSlotIndex = null;
  }

  void _swapSlots(int fromIndex, int toIndex) {
    final temp = _slots[fromIndex];
    _slots[fromIndex] = _slots[toIndex];
    _slots[toIndex] = temp;
  }

  void _save() {
    final photos = _slots.whereType<MagazinePhoto>().toList();
    if (_isNewPage) {
      widget.cubit.addPageWithPhotos(
        widget.afterIndex!,
        _targetLayout,
        photos,
        _available,
      );
    } else {
      widget.cubit.setPageContent(
        widget.pageIndex!,
        _targetLayout,
        photos,
        _available,
      );
    }
    Navigator.pop(context);
  }

  void _deletePage() {
    widget.cubit.deletePage(widget.pageIndex!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Cover pages use a simplified swap-only mode.
    if (_isCover) {
      return _buildCoverSheet();
    }

    final String title;
    if (_isNewPage) {
      title = 'New Page';
    } else {
      title = 'Edit Page ${widget.pageIndex! + 1}';
    }

    return LynewedSheet(
      title: title,
      onClose: () => Navigator.pop(context),
      bottomAction: _isNewPage
          ? LynewedButton(
              text: 'Create Page',
              onPressed: _allSlotsFilled ? _save : null,
              width: double.infinity,
            )
          : Row(
              children: [
                LynewedButton(
                  text: 'Delete',
                  onPressed: _deletePage,
                  type: LynewedButtonType.destructiveOutlined,
                  icon: Icons.delete_outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LynewedButton(
                    text: 'Save',
                    onPressed: _allSlotsFilled ? _save : null,
                  ),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Layout selector
          _buildLayoutSection(),
          const SizedBox(height: 30),

          // Section 2: Photo slots
          _buildSlotsSection(),

          // Section 3: Available photos
          if (_available.isNotEmpty) ...[
            const SizedBox(height: 30),
            _buildAvailableSection(),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Cover Sheet (swap-only mode) ──────────────────────────────────────

  void _saveCoverText() {
    widget.cubit.updateCoverText(
      title: _titleController?.text,
      subtitle: _subtitleController?.text,
    );
    Navigator.pop(context);
  }

  Widget _buildCoverSheet() {
    // Re-read fresh state from cubit on every build (after setState).
    final page = widget.cubit.state.pages[widget.pageIndex!] as CoverPage;
    final coverPhoto = page.photo;
    final available = widget.cubit.state.unassignedPhotos;

    return LynewedSheet(
      title: 'Edit Cover',
      onClose: () => Navigator.pop(context),
      bottomAction: LynewedButton(
        text: 'Save',
        onPressed: _saveCoverText,
        width: double.infinity,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LynewedSectionTitle('Cover Photo'),
          const SizedBox(height: 10),
          _buildCoverPhotoTile(coverPhoto),
          if (available.isNotEmpty) ...[
            const SizedBox(height: 30),
            const LynewedSectionTitle('Swap Cover Photo'),
            const SizedBox(height: 10),
            _buildCoverSwapGrid(available),
          ],
          const SizedBox(height: 30),
          const LynewedSectionTitle('Cover Text'),
          const SizedBox(height: 10),
          LynewedTextField(
            controller: _titleController!,
            label: 'Title',
            hint: 'e.g. Jessica & Kyle',
          ),
          const SizedBox(height: 12),
          LynewedTextField(
            controller: _subtitleController!,
            label: 'Subtitle',
            hint: 'e.g. Captured by our loved ones',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCoverPhotoTile(MagazinePhoto photo) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photo.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: LynewedColors.surface,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(LynewedColors.gray300),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: LynewedColors.surface,
                child: const Icon(Icons.broken_image,
                    color: LynewedColors.gray300),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Cover Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverSwapGrid(List<MagazinePhoto> available) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: available.length,
      itemBuilder: (context, index) {
        final photo = available[index];
        return GestureDetector(
          onTap: () {
            widget.cubit.swapCoverPhoto(photo);
            setState(() {});
          },
          child: _buildPhotoTile(
            photo: photo,
            index: index,
            showRemove: false,
          ),
        );
      },
    );
  }

  // ── Layout Section ────────────────────────────────────────────────────

  Widget _buildLayoutSection() {
    final totalPhotos = _slots.whereType<MagazinePhoto>().length +
        _available.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Layout'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: EditablePageLayout.values.map((layout) {
              final hasEnough = totalPhotos >= layout.photoCount;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: LayoutOptionTile(
                  layout: layout,
                  isSelected: layout == _targetLayout,
                  isEnabled: hasEnough,
                  onTap: () => setState(() => _changeLayout(layout)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Slots Section ─────────────────────────────────────────────────────

  Widget _buildSlotsSection() {
    final filledCount = _slots.whereType<MagazinePhoto>().length;
    final total = _targetLayout.photoCount;
    final hasSelection = _selectedSlotIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LynewedSectionTitle(
          hasSelection
              ? 'Photos ($filledCount/$total) — Tap below to fill'
              : 'Photos ($filledCount/$total)',
        ),
        const SizedBox(height: 10),
        _buildSlotGrid(),
      ],
    );
  }

  Widget _buildSlotGrid() {
    final columns = _targetLayout.photoCount <= 2 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _targetLayout.photoCount,
      itemBuilder: (context, index) {
        final photo = _slots[index];
        final isSelected = _selectedSlotIndex == index;

        if (photo == null) {
          return _buildEmptySlot(index, isSelected);
        }

        return _buildFilledSlot(photo, index, isSelected);
      },
    );
  }

  Widget _buildEmptySlot(int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedSlotIndex = _selectedSlotIndex == index ? null : index;
      }),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != index,
        onAcceptWithDetails: (details) => setState(() {
          _swapSlots(details.data, index);
        }),
        builder: (context, candidateData, rejectedData) {
          final isDragOver = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: LynewedColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected || isDragOver
                    ? LynewedColors.primary
                    : LynewedColors.gray200,
                width: isSelected || isDragOver ? 2 : 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: isSelected
                        ? LynewedColors.primary
                        : LynewedColors.gray300,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Empty',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? LynewedColors.primary
                          : LynewedColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilledSlot(MagazinePhoto photo, int index, bool isSelected) {
    final tileSize =
        (MediaQuery.of(context).size.width - 40 -
                ((_targetLayout.photoCount <= 2 ? 2 : 3) - 1) * 8) /
            (_targetLayout.photoCount <= 2 ? 2 : 3);

    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: tileSize,
          height: tileSize,
          child: _buildPhotoTile(
            photo: photo,
            index: index,
            showRemove: false,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildPhotoTile(
          photo: photo,
          index: index,
          showRemove: false,
        ),
      ),
      onDragStarted: () => setState(() {
        _selectedSlotIndex = null;
      }),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != index,
        onAcceptWithDetails: (details) => setState(() {
          _swapSlots(details.data, index);
        }),
        builder: (context, candidateData, rejectedData) {
          final isDragOver = candidateData.isNotEmpty;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedSlotIndex =
                  _selectedSlotIndex == index ? null : index;
            }),
            child: _buildPhotoTile(
              photo: photo,
              index: index,
              showRemove: true,
              isHighlighted: isDragOver || isSelected,
              onRemove: () => setState(() {
                _removePhotoFromSlot(index);
              }),
            ),
          );
        },
      ),
    );
  }

  // ── Available Photos Section ──────────────────────────────────────────

  Widget _buildAvailableSection() {
    final hasSelection = _selectedSlotIndex != null;
    final title = hasSelection
        ? 'Tap a photo to fill slot'
        : 'Available Photos (${_available.length})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LynewedSectionTitle(title),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _available.length,
          itemBuilder: (context, index) {
            final photo = _available[index];
            return GestureDetector(
              onTap: () => setState(() {
                if (hasSelection) {
                  _fillSlot(_selectedSlotIndex!, photo);
                } else {
                  final emptyIndex = _slots.indexWhere((s) => s == null);
                  if (emptyIndex != -1) {
                    _fillSlot(emptyIndex, photo);
                  }
                }
              }),
              child: _buildPhotoTile(
                photo: photo,
                index: index,
                showRemove: false,
                isHighlighted: hasSelection,
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Shared Photo Tile ─────────────────────────────────────────────────

  Widget _buildPhotoTile({
    required MagazinePhoto photo,
    required int index,
    required bool showRemove,
    bool isHighlighted = false,
    VoidCallback? onRemove,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              isHighlighted ? LynewedColors.primary : LynewedColors.gray200,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isHighlighted ? 4 : 5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photo.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: LynewedColors.surface,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        LynewedColors.gray300),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: LynewedColors.surface,
                child: const Icon(Icons.broken_image,
                    size: 20, color: LynewedColors.gray300),
              ),
            ),
            // Position badge
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Remove button
            if (showRemove && onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
      ),
    );
  }
}
