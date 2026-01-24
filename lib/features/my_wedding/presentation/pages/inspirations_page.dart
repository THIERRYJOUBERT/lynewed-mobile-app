/// Inspirations Page - Albums list for wedding moodboards
///
/// Displays wedding albums (shared with pros) and private albums (bride only).
/// Allows creating, viewing, and managing inspiration albums.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../sheets/create_album_sheet.dart';
import 'album_detail_page.dart';

/// Inspirations Page
class InspirationsPage extends StatefulWidget {
  const InspirationsPage({
    super.key,
    required this.weddingId,
    this.isReadOnly = false,
  });

  final String weddingId;
  final bool isReadOnly;

  static const String routeName = 'inspirations';
  static const String routePath = '/inspirations';

  @override
  State<InspirationsPage> createState() => _InspirationsPageState();
}

class _InspirationsPageState extends State<InspirationsPage> {
  late MyWeddingRepository _repository;

  bool _isLoading = true;
  String? _error;
  List<InspirationAlbum> _albums = [];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAlbums();
    });
  }

  Future<void> _loadAlbums() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getInspirationAlbums(
      weddingId: widget.weddingId,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _albums = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  List<InspirationAlbum> get _weddingAlbums =>
      _albums.where((a) => !a.isPrivate).toList();

  List<InspirationAlbum> get _privateAlbums =>
      widget.isReadOnly ? const [] : _albums.where((a) => a.isPrivate).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Inspirations',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          if (!widget.isReadOnly)
            GestureDetector(
              onTap: _openCreateAlbumSheet,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LynewedColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 22,
                  color: LynewedColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: LynewedTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadAlbums,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      color: LynewedColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wedding Albums Section
            if (_weddingAlbums.isNotEmpty) ...[
              _buildSectionHeader(
                'WEDDING ALBUMS',
                '${_weddingAlbums.length} album${_weddingAlbums.length > 1 ? 's' : ''}',
              ),
              const SizedBox(height: 10),
              _buildAlbumsGrid(_weddingAlbums),
              const SizedBox(height: 30),
            ],
            // Private Albums Section
            if (_privateAlbums.isNotEmpty) ...[
              _buildSectionHeader(
                'PRIVATE ALBUMS',
                '${_privateAlbums.length} album${_privateAlbums.length > 1 ? 's' : ''}',
              ),
              const SizedBox(height: 10),
              _buildAlbumsGrid(_privateAlbums),
            ],
            // If only one type exists, add bottom padding
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No albums yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create albums to organize your wedding inspiration and moodboards.',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Create Album',
              onPressed: _openCreateAlbumSheet,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumsGrid(List<InspirationAlbum> albums) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) => _buildAlbumCard(albums[index]),
    );
  }

  Widget _buildAlbumCard(InspirationAlbum album) {
    return GestureDetector(
      onTap: () => _openAlbumDetail(album),
      onLongPress: widget.isReadOnly ? null : () => _showAlbumOptions(album),
      child: Container(
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (album.coverImageUrl != null &&
                        album.coverImageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: album.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: LynewedColors.gray200,
                          child: const Center(
                            child: Icon(
                              Icons.photo_library_outlined,
                              color: LynewedColors.gray300,
                              size: 32,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: LynewedColors.gray200,
                          child: const Center(
                            child: Icon(
                              Icons.photo_library_outlined,
                              color: LynewedColors.gray300,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: LynewedColors.gray200,
                        child: const Center(
                          child: Icon(
                            Icons.photo_library_outlined,
                            color: LynewedColors.gray300,
                            size: 32,
                          ),
                        ),
                      ),
                    // Private badge
                    if (album.isPrivate)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Private',
                                style: LynewedTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Album info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.imagesCount} image${album.imagesCount != 1 ? 's' : ''}',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateAlbumSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlbumSheet(
        weddingId: widget.weddingId,
        onCreated: _loadAlbums,
      ),
    );
  }

  void _openAlbumDetail(InspirationAlbum album) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlbumDetailPage(
          album: album,
          onUpdated: _loadAlbums,
          isReadOnly: widget.isReadOnly,
        ),
      ),
    );
  }

  void _showAlbumOptions(InspirationAlbum album) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: LynewedColors.surface,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOptionRow(
                      icon: Icons.edit_outlined,
                      label: 'Rename',
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _renameAlbum(album);
                      },
                    ),
                    const SizedBox(height: 4),
                    _buildOptionRow(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _confirmDeleteAlbum(album);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? LynewedColors.error : LynewedColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: LynewedColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 14),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: LynewedTextStyles.labelLarge.copyWith(
                color:
                    isDestructive ? LynewedColors.error : LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _renameAlbum(InspirationAlbum album) {
    final controller = TextEditingController(text: album.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Album'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Album name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != album.name) {
                Navigator.pop(context);
                await _repository.updateInspirationAlbum(
                  albumId: album.id,
                  name: newName,
                );
                _loadAlbums();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAlbum(InspirationAlbum album) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Album'),
        content: Text(
          'Are you sure you want to delete "${album.name}"? This will also delete all images in this album.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _repository.deleteInspirationAlbum(albumId: album.id);
              _loadAlbums();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
