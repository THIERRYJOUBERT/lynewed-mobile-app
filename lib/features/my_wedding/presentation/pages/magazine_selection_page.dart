/// Magazine Selection Page - Select and order photos for wedding magazine.
///
/// Allows bride to view, reorder, add, and remove photos from the magazine.
/// Supports drag & drop reordering and navigation to preview.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/magazine_selection.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../bloc/magazine_selection_cubit.dart';
import '../bloc/magazine_selection_state.dart';
import '../sheets/magazine_photo_picker_sheet.dart';
import '../widgets/reorderable_magazine_grid.dart';
import 'magazine_checkout_page.dart';
import 'magazine_preview_page.dart';

/// Page for managing magazine photo selection.
class MagazineSelectionPage extends StatefulWidget {
  /// Creates a magazine selection page.
  const MagazineSelectionPage({
    super.key,
    required this.weddingId,
    required this.userId,
    required this.weddingTitle,
    required this.weddingDate,
  });

  /// The wedding ID for this magazine.
  final String weddingId;

  /// The current user ID.
  final String userId;

  /// Wedding title for the magazine cover.
  final String weddingTitle;

  /// Wedding date for the magazine cover.
  final DateTime weddingDate;

  @override
  State<MagazineSelectionPage> createState() => _MagazineSelectionPageState();
}

class _MagazineSelectionPageState extends State<MagazineSelectionPage> {
  late MagazineSelectionCubit _cubit;
  late MyWeddingRepository _repository;

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

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _cubit.loadSelections();
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Gets the thumbnail URL for a media item.
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

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Magazine'),
        content:
            const Text('Remove all photos from your magazine? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cubit.clearAll();
            },
            style: TextButton.styleFrom(
              foregroundColor: LynewedColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Opens the photo picker sheet to add more photos.
  void _openPhotoPicker(MagazineSelectionState state) {
    MagazinePhotoPickerSheet.show(
      context,
      weddingId: widget.weddingId,
      userId: widget.userId,
      currentCount: state.count,
      maxPhotos: state.maxPhotos,
      onPhotosAdded: (count) {
        // Reload selections to show newly added photos
        _cubit.loadSelections();
      },
    );
  }

  /// Opens the magazine preview page.
  void _openMagazinePreview(MagazineSelectionState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (navContext) => MagazinePreviewPage(
          photos: state.photos,
          weddingTitle: widget.weddingTitle,
          weddingDate: widget.weddingDate,
          weddingId: widget.weddingId,
          onNavigateBack: () => Navigator.pop(navContext),
          onNavigateToCheckout: (format, coverPhotoUrl, spreadCount) {
            Navigator.of(navContext).push(
              MaterialPageRoute(
                builder: (_) => MagazineCheckoutPage(
                  weddingId: widget.weddingId,
                  brideUserId: widget.userId,
                  format: format,
                  photoCount: state.count,
                  spreadCount: spreadCount,
                  weddingTitle: widget.weddingTitle,
                  weddingDate: widget.weddingDate,
                  coverPhotoUrl: coverPhotoUrl,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<MagazineSelectionCubit, MagazineSelectionState>(
        listener: (context, state) {
          // Show error toast
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
                backgroundColor: LynewedColors.error,
              ),
            );
            _cubit.clearError();
          }

          // Show success toast
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage!,
                  style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
                backgroundColor: LynewedColors.success,
              ),
            );
            _cubit.clearSuccess();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: LynewedColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(state),
                  const Divider(height: 1, color: LynewedColors.gray200),
                  if (!state.isEmpty) _buildPhotoCounter(state),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
            bottomNavigationBar: state.canPreview
                ? _buildBottomBar(state)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildHeader(MagazineSelectionState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Magazine Selection',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          // Clear button
          if (!state.isEmpty)
            TextButton(
              onPressed: state.isLoading ? null : _showClearConfirmation,
              child: Text(
                'Clear',
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: LynewedColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoCounter(MagazineSelectionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: LynewedColors.surface,
      child: Row(
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            size: 20,
            color: LynewedColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '${state.count} photo${state.count != 1 ? 's' : ''} selected',
            style: LynewedTextStyles.bodyMedium,
          ),
          const Spacer(),
          Text(
            'max ${state.maxPhotos}',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(MagazineSelectionState state) {
    if (state.isLoading && state.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (state.isEmpty) {
      return _buildEmptyState(state);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => _cubit.loadSelections(),
          color: LynewedColors.primary,
          child: ReorderableMagazineGridView(
            photos: state.photos,
            onReorder: _cubit.reorderPhoto,
            onRemove: _cubit.removePhoto,
            isReordering: state.isReordering,
          ),
        ),
        // Loading overlay for reordering
        if (state.isReordering)
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(LynewedColors.primary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(MagazineSelectionState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            Text(
              'No photos yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Select photos from your albums to create your wedding magazine',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Select Photos',
              onPressed: () => _openPhotoPicker(state),
              width: double.infinity,
              icon: Icons.add_photo_alternate_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(MagazineSelectionState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add more photos button (if not full)
          if (state.canAddMore) ...[
            LynewedButton(
              text: 'Add more photos',
              onPressed: () => _openPhotoPicker(state),
              type: LynewedButtonType.secondary,
              width: double.infinity,
              icon: Icons.add_photo_alternate_outlined,
            ),
            const SizedBox(height: 12),
          ],
          // Create magazine button
          LynewedButton(
            text: 'Preview Magazine',
            onPressed: () => _openMagazinePreview(state),
            width: double.infinity,
            icon: Icons.auto_stories,
          ),
        ],
      ),
    );
  }
}

/// Widget that shows a magazine selection page as a full-screen sheet.
class MagazineSelectionSheet extends StatelessWidget {
  /// Creates a magazine selection sheet.
  const MagazineSelectionSheet({
    super.key,
    required this.weddingId,
    required this.userId,
    required this.weddingTitle,
    required this.weddingDate,
    this.maxPhotos = MagazineSelection.maxPhotosCollector,
  });

  /// The wedding ID.
  final String weddingId;

  /// The current user ID.
  final String userId;

  /// Wedding title for magazine cover.
  final String weddingTitle;

  /// Wedding date for magazine cover.
  final DateTime weddingDate;

  /// Maximum photos allowed.
  final int maxPhotos;

  /// Shows the magazine selection sheet.
  static Future<void> show(
    BuildContext context, {
    required String weddingId,
    required String userId,
    required String weddingTitle,
    required DateTime weddingDate,
    int maxPhotos = MagazineSelection.maxPhotosCollector,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: LynewedColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MagazineSelectionSheet(
        weddingId: weddingId,
        userId: userId,
        weddingTitle: weddingTitle,
        weddingDate: weddingDate,
        maxPhotos: maxPhotos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return MagazineSelectionPage(
          weddingId: weddingId,
          userId: userId,
          weddingTitle: weddingTitle,
          weddingDate: weddingDate,
        );
      },
    );
  }
}
