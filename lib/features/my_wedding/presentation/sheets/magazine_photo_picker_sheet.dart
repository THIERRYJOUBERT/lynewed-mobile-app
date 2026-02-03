/// Magazine Photo Picker Sheet - Select photos for wedding magazine
///
/// Allows bride to select photos from all available sources
/// (guest albums and inspiration albums) for their wedding magazine.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../bloc/magazine_selection_cubit.dart';

/// Photo Picker Sheet for magazine selection
class MagazinePhotoPickerSheet extends StatefulWidget {
  const MagazinePhotoPickerSheet({
    super.key,
    required this.weddingId,
    required this.userId,
    required this.currentCount,
    required this.maxPhotos,
    required this.onPhotosAdded,
  });

  final String weddingId;
  final String userId;
  final int currentCount;
  final int maxPhotos;
  final void Function(int count) onPhotosAdded;

  /// Show the photo picker sheet
  static Future<void> show(
    BuildContext context, {
    required String weddingId,
    required String userId,
    required int currentCount,
    int maxPhotos = 60,
    required void Function(int count) onPhotosAdded,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MagazinePhotoPickerSheet(
        weddingId: weddingId,
        userId: userId,
        currentCount: currentCount,
        maxPhotos: maxPhotos,
        onPhotosAdded: onPhotosAdded,
      ),
    );
  }

  @override
  State<MagazinePhotoPickerSheet> createState() =>
      _MagazinePhotoPickerSheetState();
}

class _MagazinePhotoPickerSheetState extends State<MagazinePhotoPickerSheet> {
  late MyWeddingRepository _repository;
  late MagazineSelectionCubit _cubit;

  List<PickerMediaSection> _sections = [];
  final Set<String> _selectedIds = {};
  String _filter = 'all'; // 'all', 'guest', 'inspiration'
  bool _isLoading = true;
  bool _isAdding = false;
  String? _error;

  int get _availableSlots => widget.maxPhotos - widget.currentCount;
  int get _selectedCount => _selectedIds.length;
  bool get _canAddMore => _selectedCount < _availableSlots;

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();
    _cubit = MagazineSelectionCubit(
      weddingId: widget.weddingId,
      userId: widget.userId,
      repository: _repository,
      getThumbnailUrl: _getThumbnailUrl,
    );
    _loadPhotos();
  }

  Future<String?> _getThumbnailUrl(String mediaType, String mediaId) async {
    try {
      if (mediaType == 'album_image') {
        final result =
            await _repository.getAlbumImageThumbnail(imageId: mediaId);
        return result.data;
      } else if (mediaType == 'guest_media') {
        final result =
            await _repository.getGuestMediaThumbnail(mediaId: mediaId);
        return result.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getAllPhotosForMagazinePicker(
      weddingId: widget.weddingId,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _sections = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error ?? 'Failed to load photos';
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(PickerMediaItem item) {
    if (item.isAlreadySelected) return; // Already in magazine

    setState(() {
      if (_selectedIds.contains(item.id)) {
        _selectedIds.remove(item.id);
      } else if (_canAddMore) {
        _selectedIds.add(item.id);
      }
    });
  }

  Future<void> _addSelectedPhotos() async {
    if (_selectedIds.isEmpty) return;

    setState(() => _isAdding = true);

    // Build media items from selected IDs
    final mediaItems = <MagazineMediaItem>[];
    for (final section in _sections) {
      for (final group in section.groups) {
        for (final item in group.items) {
          if (_selectedIds.contains(item.id)) {
            mediaItems.add(MagazineMediaItem(
              mediaType: item.mediaType,
              mediaId: item.id,
            ));
          }
        }
      }
    }

    final success = await _cubit.addPhotos(mediaItems);

    if (!mounted) return;

    if (success) {
      widget.onPhotosAdded(_selectedIds.length);
      Navigator.pop(context);
    } else {
      setState(() => _isAdding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add photos')),
      );
    }
  }

  List<PickerMediaSection> get _filteredSections {
    var sections = _sections;

    // Filter by source type
    if (_filter == 'guest') {
      sections = sections.where((s) => s.title.contains('Guest')).toList();
    } else if (_filter == 'inspiration') {
      sections = sections.where((s) => s.title.contains('Inspiration')).toList();
    }

    // Filter out videos (photos only for magazine)
    return sections.map((section) {
      final filteredGroups = section.groups.map((group) {
        final photosOnly = group.items.where((item) => !item.isVideo).toList();
        return PickerMediaGroup(
          id: group.id,
          name: group.name,
          avatarUrl: group.avatarUrl,
          items: photosOnly,
        );
      }).where((g) => g.items.isNotEmpty).toList();

      final totalPhotos = filteredGroups.fold<int>(0, (sum, g) => sum + g.count);
      final sourceLabel = section.title.contains('Guest') ? 'guests' : 'albums';

      return PickerMediaSection(
        title: section.title,
        subtitle: '$totalPhotos photos from ${filteredGroups.length} $sourceLabel',
        groups: filteredGroups,
      );
    }).where((s) => s.groups.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(child: _buildContent()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Photos',
                  style: LynewedTextStyles.sheetTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_selectedCount selected · $_availableSlots slots available',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Guest Albums', 'guest'),
          const SizedBox(width: 8),
          _buildFilterChip('Inspiration', 'inspiration'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary : LynewedColors.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: LynewedTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : LynewedColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: LynewedColors.textSecondary),
            const SizedBox(height: 16),
            Text(_error!, style: LynewedTextStyles.bodyMedium),
            const SizedBox(height: 16),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadPhotos,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    final sections = _filteredSections;
    if (sections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No photos available',
              style: LynewedTextStyles.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload photos to your albums first',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sections.length,
      itemBuilder: (context, index) => _buildSection(sections[index]),
    );
  }

  Widget _buildSection(PickerMediaSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          section.title.toUpperCase(),
          style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        if (section.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              section.subtitle!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 12),
        ...section.groups.map(_buildGroup),
      ],
    );
  }

  Widget _buildGroup(PickerMediaGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (group.avatarUrl != null)
              CircleAvatar(
                radius: 14,
                backgroundImage: CachedNetworkImageProvider(group.avatarUrl!),
              )
            else
              CircleAvatar(
                radius: 14,
                backgroundColor: LynewedColors.gray200,
                child: Text(
                  group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                  style: LynewedTextStyles.labelSmall,
                ),
              ),
            const SizedBox(width: 8),
            Text(
              group.name,
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${group.count} photos',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: group.items.length,
          itemBuilder: (context, index) => _buildPhotoTile(group.items[index]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhotoTile(PickerMediaItem item) {
    final isSelected = _selectedIds.contains(item.id);
    final isAlreadyInMagazine = item.isAlreadySelected;

    return GestureDetector(
      onTap: () => _toggleSelection(item),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: item.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: LynewedColors.gray100,
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: LynewedColors.gray100,
                child: const Icon(Icons.broken_image, size: 24),
              ),
            ),
          ),

          // Video indicator
          if (item.isVideo)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

          // Selection overlay
          if (isSelected || isAlreadyInMagazine)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isAlreadyInMagazine
                    ? Colors.black38
                    : LynewedColors.primary.withValues(alpha: 0.3),
                border: isSelected
                    ? Border.all(color: LynewedColors.primary, width: 2)
                    : null,
              ),
            ),

          // Checkbox or "In Magazine" indicator
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAlreadyInMagazine
                    ? Colors.green  // Green for already in magazine
                    : isSelected
                        ? LynewedColors.primary
                        : Colors.white.withValues(alpha: 0.8),
                border: !isSelected && !isAlreadyInMagazine
                    ? Border.all(color: LynewedColors.gray300)
                    : null,
              ),
              child: isAlreadyInMagazine
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        border: Border(
          top: BorderSide(color: LynewedColors.gray200),
        ),
      ),
      child: SafeArea(
        top: false,
        child: LynewedButton(
          text: _selectedCount > 0
              ? 'Add $_selectedCount Photo${_selectedCount > 1 ? 's' : ''}'
              : 'Select Photos',
          onPressed: _selectedCount > 0 ? _addSelectedPhotos : null,
          isLoading: _isAdding,
          width: double.infinity,
        ),
      ),
    );
  }
}
