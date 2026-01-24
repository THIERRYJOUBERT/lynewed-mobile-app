/// Save To Album Sheet - Select album to save an image from feed
///
/// Displays list of albums (wedding + private) for the bride to save an image.
/// Can also create a new album directly from this sheet.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import 'create_album_sheet.dart';

/// Save To Album Sheet
class SaveToAlbumSheet extends StatefulWidget {
  const SaveToAlbumSheet({
    super.key,
    required this.weddingId,
    required this.imageUrl,
    this.sourceProfileId,
    this.onSaved,
  });

  final String weddingId;
  final String imageUrl;
  final String? sourceProfileId;
  final VoidCallback? onSaved;

  @override
  State<SaveToAlbumSheet> createState() => _SaveToAlbumSheetState();
}

class _SaveToAlbumSheetState extends State<SaveToAlbumSheet> {
  late MyWeddingRepository _repository;

  bool _isLoading = true;
  bool _isSaving = false;
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

  Future<void> _saveToAlbum(InspirationAlbum album) async {
    setState(() => _isSaving = true);

    final result = await _repository.saveImageToAlbum(
      albumId: album.id,
      imageUrl: widget.imageUrl,
      sourceProfileId: widget.sourceProfileId,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      widget.onSaved?.call();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved to "${album.name}"',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to save image',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LynewedColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Save to Album',
                  style: LynewedTextStyles.sheetTitle,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: LynewedColors.gray200),
          // Content
          Flexible(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadAlbums,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 120,
                color: LynewedColors.gray200,
              ),
              errorWidget: (_, __, ___) => Container(
                height: 120,
                color: LynewedColors.gray200,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: LynewedColors.gray300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Create new album button
          GestureDetector(
            onTap: _openCreateAlbumSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: LynewedColors.gray200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: LynewedColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: LynewedColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Create New Album',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_albums.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Your Albums',
              style: LynewedTextStyles.sectionTitle,
            ),
            const SizedBox(height: 10),
            ..._albums.map((album) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildAlbumTile(album),
                )),
          ] else ...[
            const SizedBox(height: 30),
            Center(
              child: Text(
                'No albums yet. Create one to save this image.',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAlbumTile(InspirationAlbum album) {
    return GestureDetector(
      onTap: _isSaving ? null : () => _saveToAlbum(album),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Album cover
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: album.coverImageUrl != null &&
                      album.coverImageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: album.coverImageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48,
                        height: 48,
                        color: LynewedColors.gray200,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: LynewedColors.gray200,
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: LynewedColors.gray300,
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: LynewedColors.gray200,
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: LynewedColors.gray300,
                        size: 20,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Album info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          album.name,
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (album.isPrivate) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: LynewedColors.textSecondary,
                        ),
                      ],
                    ],
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
            // Arrow
            const Icon(
              Icons.chevron_right,
              color: LynewedColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
