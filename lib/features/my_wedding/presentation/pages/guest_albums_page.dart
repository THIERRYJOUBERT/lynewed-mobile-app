/// Guest Albums Page for brides to view guest albums.
///
/// Lists all guest albums from the wedding with navigation to detail view.
/// Supports downloading media from guest albums.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/design/design.dart';
import '/features/guest/domain/entities/guest_media.dart';
import '../../data/datasources/download_data_source_impl.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/guest_album.dart';
import '../../domain/usecases/download_media_use_case.dart';
import '../widgets/download_button.dart';
import '../widgets/guest_album_card.dart';

/// Page displaying all guest albums for the bride.
///
/// Shows a list of guest albums with avatar, name, media count, and thumbnail.
/// Style reference: messages_page.dart (list layout)
class GuestAlbumsPage extends StatefulWidget {
  /// Creates the GuestAlbumsPage.
  const GuestAlbumsPage({
    super.key,
    required this.weddingId,
    this.testAlbums,
    this.testError,
  });

  /// The wedding ID to load albums for.
  final String weddingId;

  /// For testing: pre-loaded albums to bypass repository.
  final List<GuestAlbum>? testAlbums;

  /// For testing: simulated error message.
  final String? testError;

  /// Route name for navigation.
  static const String routeName = 'GuestAlbums';

  /// Route path for navigation.
  static const String routePath = '/guest-albums';

  @override
  State<GuestAlbumsPage> createState() => _GuestAlbumsPageState();
}

class _GuestAlbumsPageState extends State<GuestAlbumsPage> {
  bool _isLoading = true;
  String? _error;
  List<GuestAlbum> _albums = [];

  @override
  void initState() {
    super.initState();

    // Check for test data
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

  Future<void> _loadAlbums() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = MyWeddingRepositoryImpl();
    final result = await repository.getGuestAlbums(weddingId: widget.weddingId);

    if (!mounted) return;

    result.isSuccess
        ? setState(() {
            _albums = result.data ?? [];
            _isLoading = false;
          })
        : setState(() {
            _error = result.error;
            _isLoading = false;
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildBody()),
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
              'Guest Albums',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                textAlign: TextAlign.center,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              LynewedButton(
                text: 'Retry',
                onPressed: _loadAlbums,
                type: LynewedButtonType.secondary,
              ),
            ],
          ),
        ),
      );
    }

    if (_albums.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      color: LynewedColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _albums.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final album = _albums[index];
          return GuestAlbumCard(
            album: album,
            onTap: () => _navigateToAlbum(album),
          );
        },
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
              Icons.photo_album_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            Text(
              'No guest albums yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Photos and videos from your guests will appear here',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAlbum(GuestAlbum album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GuestAlbumDetailPage(album: album),
      ),
    );
  }
}

/// Detail page for viewing a specific guest's album.
///
/// Style reference: album_detail_page.dart (grid layout)
class _GuestAlbumDetailPage extends StatefulWidget {
  const _GuestAlbumDetailPage({required this.album});

  final GuestAlbum album;

  @override
  State<_GuestAlbumDetailPage> createState() => _GuestAlbumDetailPageState();
}

class _GuestAlbumDetailPageState extends State<_GuestAlbumDetailPage> {
  late DownloadMediaUseCase _downloadUseCase;
  bool _isLoading = true;
  String? _error;
  List<GuestMedia> _media = [];

  @override
  void initState() {
    super.initState();
    _downloadUseCase = DownloadMediaUseCase(DownloadDataSourceImpl());
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadMedia();
    });
  }

  Future<void> _loadMedia() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = MyWeddingRepositoryImpl();
    final result = await repository.getGuestAlbumMedia(albumId: widget.album.id);

    if (!mounted) return;

    result.isSuccess
        ? setState(() {
            _media = result.data ?? [];
            _isLoading = false;
          })
        : setState(() {
            _error = result.error;
            _isLoading = false;
          });
  }

  /// Storage bucket base URL.
  String get _bucketBaseUrl {
    final supabase = Supabase.instance.client;
    return supabase.storage.from('wedding-albums').getPublicUrl('');
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.album.guestName}'s Album",
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.album.totalMediaCount} media',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
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
              onPressed: _loadMedia,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_media.isEmpty) {
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
              Text(
                'No media yet',
                style: LynewedTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.album.guestName} hasn't uploaded any photos or videos yet",
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedia,
      color: LynewedColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _media.length,
        itemBuilder: (context, index) {
          return _buildMediaTile(_media[index]);
        },
      ),
    );
  }

  Widget _buildMediaTile(GuestMedia media) {
    final imageUrl = _getImageUrl(media);

    return GestureDetector(
      onTap: () => _openMediaViewer(media),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: LynewedColors.gray200,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(LynewedColors.gray300),
                    ),
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
            )
          else
            Container(
              color: LynewedColors.gray200,
              child: Icon(
                media.isVideo ? Icons.videocam : Icons.image,
                color: LynewedColors.gray300,
              ),
            ),

          // Video play icon overlay
          if (media.isVideo)
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Gets the URL for the image to display.
  String? _getImageUrl(GuestMedia media) {
    final baseUrl = _bucketBaseUrl;

    // For videos, prefer thumbnail
    if (media.isVideo && media.thumbnailPath != null) {
      return '$baseUrl${media.thumbnailPath}';
    }

    // Use main storage path
    return '$baseUrl${media.storagePath}';
  }

  void _openMediaViewer(GuestMedia media) {
    // Show options sheet with download option
    showModalBottomSheet(
      context: context,
      backgroundColor: LynewedColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LynewedColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download_rounded, color: LynewedColors.textPrimary),
              title: Text(
                media.isVideo ? 'Download Video' : 'Download Photo',
                style: LynewedTextStyles.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadMedia(media);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Downloads a single media item.
  Future<void> _downloadMedia(GuestMedia media) async {
    // Build the storage URL
    final storageUrl = '$_bucketBaseUrl${media.storagePath}';

    // Show download progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DownloadProgressDialog(
        progress: 0.0,
        message: media.isVideo ? 'Downloading video...' : 'Downloading photo...',
      ),
    );

    final result = await _downloadUseCase.downloadSingle(
      storageUrl: storageUrl,
      fileName: media.storagePath.split('/').last,
    );

    if (!mounted) return;

    // Close progress dialog
    Navigator.of(context).pop();

    result.fold(
      onSuccess: (file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              media.isVideo ? 'Video downloaded' : 'Photo downloaded',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
      },
      onFailure: (failure) {
        showDialog(
          context: context,
          builder: (ctx) => RetryDownloadDialog(
            message: failure.message,
            onCancel: () => Navigator.pop(ctx),
            onRetry: () {
              Navigator.pop(ctx);
              _downloadMedia(media);
            },
          ),
        );
      },
    );
  }
}
