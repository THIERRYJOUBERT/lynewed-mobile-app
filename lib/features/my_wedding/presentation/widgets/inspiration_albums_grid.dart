/// Reusable grid widget for inspiration albums.
///
/// Loads and displays inspiration albums in a 2-column grid.
/// Supports filtering by private/public and provides
/// loading, error, and empty states.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../pages/album_detail_page.dart';

/// A reusable grid of inspiration albums.
///
/// Extracted from [InspirationsPage] for reuse in [AllAlbumsPage] tabs.
class InspirationAlbumsGrid extends StatefulWidget {
  const InspirationAlbumsGrid({
    super.key,
    required this.weddingId,
    this.isReadOnly = false,
    this.filterPrivate,
    this.onCreateAlbum,
    this.testAlbums,
    this.testError,
  });

  /// The wedding ID to load albums for.
  final String weddingId;

  /// Whether to disable editing actions (rename, delete).
  final bool isReadOnly;

  /// Filter albums by privacy:
  /// - `null` = all albums
  /// - `true` = private only
  /// - `false` = public only (wedding albums)
  final bool? filterPrivate;

  /// Callback for creating a new album (opens sheet).
  final VoidCallback? onCreateAlbum;

  /// For testing: pre-loaded albums to bypass repository.
  final List<InspirationAlbum>? testAlbums;

  /// For testing: simulated error message.
  final String? testError;

  @override
  State<InspirationAlbumsGrid> createState() => InspirationAlbumsGridState();
}

class InspirationAlbumsGridState extends State<InspirationAlbumsGrid> {
  late MyWeddingRepository _repository;

  bool _isLoading = true;
  String? _error;
  List<InspirationAlbum> _albums = [];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();

    if (widget.testAlbums != null || widget.testError != null) {
      _albums = widget.testAlbums ?? [];
      _error = widget.testError;
      _isLoading = false;
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadAlbums();
      });
    }
  }

  /// Reload albums from the repository.
  Future<void> reload() => _loadAlbums();

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
      var albums = result.data ?? [];
      // Apply privacy filter
      if (widget.filterPrivate != null) {
        albums = albums.where((a) => a.isPrivate == widget.filterPrivate).toList();
      }
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Icon(Icons.error_outline, size: 48, color: LynewedColors.error),
            const SizedBox(height: 16),
            const Text('Something went wrong', style: LynewedTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
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
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) => _buildAlbumCard(_albums[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    final label = widget.filterPrivate == true
        ? 'No private albums yet'
        : widget.filterPrivate == false
            ? 'No wedding albums yet'
            : 'No albums yet';
    final description = widget.filterPrivate == true
        ? 'Create private albums visible only to you.'
        : widget.filterPrivate == false
            ? 'Create albums to share with your wedding team.'
            : 'Create albums to organize your wedding inspiration.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 24),
            Text(label, style: LynewedTextStyles.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              description,
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (widget.onCreateAlbum != null && !widget.isReadOnly) ...[
              const SizedBox(height: 32),
              LynewedButton(
                text: 'Create Album',
                onPressed: widget.onCreateAlbum!,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (album.coverImageUrl != null && album.coverImageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: album.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildImagePlaceholder(),
                        errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                      )
                    else
                      _buildImagePlaceholder(),
                    // Private badge
                    if (album.isPrivate)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline, size: 10, color: Colors.white),
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
                    style: LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: LynewedColors.gray200,
      child: const Center(
        child: Icon(Icons.photo_library_outlined, color: LynewedColors.gray300, size: 32),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    final color = isDestructive ? LynewedColors.error : LynewedColors.textSecondary;
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
              child: Center(child: Icon(icon, color: color, size: 14)),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: LynewedTextStyles.labelLarge.copyWith(
                color: isDestructive ? LynewedColors.error : LynewedColors.textPrimary,
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
          decoration: const InputDecoration(hintText: 'Album name'),
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
                await _repository.updateInspirationAlbum(albumId: album.id, name: newName);
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
            child: const Text('Delete', style: TextStyle(color: LynewedColors.error)),
          ),
        ],
      ),
    );
  }
}
