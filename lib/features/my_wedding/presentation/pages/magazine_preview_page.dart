/// Magazine Preview Page - Preview magazine with format selection.
///
/// Allows bride to view the generated magazine layout and select a format
/// before proceeding to checkout.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_format.dart';
import '../../domain/entities/magazine_page.dart';
import '../bloc/magazine_preview_cubit.dart';
import '../bloc/magazine_preview_state.dart';
import '../bloc/magazine_selection_state.dart';
import '../sheets/magazine_format_sheet.dart';
import '../sheets/magazine_page_edit_sheet.dart';
import '../widgets/magazine_cover.dart';
import '../widgets/magazine_double_page.dart';
import '../widgets/magazine_mosaic_page.dart';
import '../widgets/magazine_single_page.dart';
import 'magazine_full_preview_page.dart';

/// Page for previewing the magazine and selecting format.
class MagazinePreviewPage extends StatefulWidget {
  /// Creates a magazine preview page.
  const MagazinePreviewPage({
    super.key,
    required this.photos,
    required this.weddingTitle,
    required this.weddingDate,
    required this.weddingId,
    this.onNavigateBack,
    this.onNavigateToCheckout,
  });

  /// Photos to include in the magazine.
  final List<MagazinePhoto> photos;

  /// Wedding title for the cover.
  final String weddingTitle;

  /// Wedding date for the cover.
  final DateTime weddingDate;

  /// Wedding ID for draft persistence.
  final String weddingId;

  /// Callback to navigate back to selection.
  final VoidCallback? onNavigateBack;

  /// Callback to navigate to checkout with selected format, cover photo,
  /// and actual spread count.
  final void Function(
          MagazineFormat format, String? coverPhotoUrl, int spreadCount)?
      onNavigateToCheckout;

  @override
  State<MagazinePreviewPage> createState() => _MagazinePreviewPageState();
}

class _MagazinePreviewPageState extends State<MagazinePreviewPage> {
  late MagazinePreviewCubit _cubit;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cubit = MagazinePreviewCubit(
      photos: widget.photos,
      weddingTitle: widget.weddingTitle,
      weddingDate: widget.weddingDate,
      weddingId: widget.weddingId,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _cubit.initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Don't notify the cubit for the blank "add page" placeholder.
    if (index < _cubit.state.pages.length) {
      _cubit.goToPage(index);
    }
  }

  void _goToPage(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openFormatSheet(MagazinePreviewState state) async {
    final format = await MagazineFormatSheet.show(
      context,
      photoCount: state.photoCount,
      currentFormat: state.selectedFormat,
    );
    if (format != null && mounted) {
      _cubit.selectFormat(format);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<MagazinePreviewCubit, MagazinePreviewState>(
        listener: (context, state) {
          if (_pageController.hasClients &&
              _pageController.page?.round() != state.currentPageIndex) {
            _goToPage(state.currentPageIndex);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: LynewedColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(state),
                  Expanded(
                    child: state.isLoading
                        ? _buildLoading()
                        : _buildPreview(state),
                  ),
                  if (!state.isLoading) _buildBottomBar(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(MagazinePreviewState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          bottom: BorderSide(color: LynewedColors.border),
        ),
      ),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(
            context,
            onTap: widget.onNavigateBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Magazine Preview',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
            ),
          ),
          if (!state.isLoading && state.pages.isNotEmpty)
            GestureDetector(
              onTap: () => MagazineFullPreviewPage.show(
                context,
                pages: state.pages,
                initialPage: state.currentPageIndex,
                aspectRatio:
                    state.selectedFormat?.aspectRatio ?? 0.7,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 18,
                    color: LynewedColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Preview',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
          SizedBox(height: 16),
          Text('Generating your magazine...'),
        ],
      ),
    );
  }

  Widget _buildPreview(MagazinePreviewState state) {
    if (state.pages.isEmpty) {
      return _buildEmptyState();
    }

    final hasAddPage = state.hasUnassignedPhotos;
    final pageViewCount =
        state.pages.length + (hasAddPage ? 1 : 0);
    final currentIndex = _pageController.hasClients
        ? (_pageController.page?.round() ?? state.currentPageIndex)
        : state.currentPageIndex;
    final isOnAddPage = currentIndex >= state.pages.length;

    return Column(
      children: [
        // Page counter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            isOnAddPage
                ? 'New Page'
                : '${state.currentPageIndex + 1} / ${state.pageCount}',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        // Page viewer
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: pageViewCount,
            itemBuilder: (context, index) {
              if (index >= state.pages.length) {
                return _buildAddPagePlaceholder(state);
              }
              return _buildPage(state.pages[index], index);
            },
          ),
        ),
        // Page indicators
        _buildPageIndicators(state),
      ],
    );
  }

  Widget _buildAddPagePlaceholder(MagazinePreviewState state) {
    return GestureDetector(
      onTap: _openNewPageSheet,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LynewedColors.gray200),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 48,
                  color: LynewedColors.gray300,
                ),
                const SizedBox(height: 12),
                Text(
                  'Add New Page',
                  style: LynewedTextStyles.titleSmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.unassignedCount} photos available',
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(MagazinePage page, int index) {
    final pageWidget = switch (page) {
      CoverPage() => MagazineCover(page: page),
      SinglePage() => MagazineSinglePage(page: page),
      DoublePage() => MagazineDoublePage(page: page),
      MosaicPage() => MagazineMosaicPage(page: page),
      _ => const SizedBox.shrink(),
    };

    final ar = _cubit.state.selectedFormat?.aspectRatio;
    final constrained = ar != null
        ? Center(
            child: AspectRatio(
              aspectRatio: ar,
              child: pageWidget,
            ),
          )
        : pageWidget;

    return GestureDetector(
      onTap: () => _openPageEditSheet(index),
      child: Stack(
        children: [
          constrained,
          // Edit overlay icon
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPageEditSheet(int pageIndex) {
    MagazinePageEditSheet.show(
      context,
      pageIndex: pageIndex,
      cubit: _cubit,
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openNewPageSheet() {
    MagazinePageEditSheet.showCreate(
      context,
      afterIndex: _cubit.state.pages.length - 1,
      cubit: _cubit,
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildPageIndicators(MagazinePreviewState state) {
    const maxVisible = 7;
    final total = state.pageCount;
    final hasAddPage = state.hasUnassignedPhotos;
    final displayTotal = total + (hasAddPage ? 1 : 0);
    final currentViewIndex = _pageController.hasClients
        ? (_pageController.page?.round() ?? state.currentPageIndex)
        : state.currentPageIndex;

    if (displayTotal <= maxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(displayTotal, (index) {
            final isAddPageDot = index >= total;
            final isActive = index == currentViewIndex;
            return GestureDetector(
              onTap: () => _goToPage(index),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? LynewedColors.primary
                      : isAddPageDot
                          ? Colors.transparent
                          : LynewedColors.gray200,
                  border: isAddPageDot && !isActive
                      ? Border.all(color: LynewedColors.gray300, width: 1.5)
                      : null,
                ),
              ),
            );
          }),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentViewIndex > 0
                ? () => _goToPage(currentViewIndex - 1)
                : null,
            color: currentViewIndex > 0
                ? LynewedColors.textPrimary
                : LynewedColors.gray300,
          ),
          Text(
            currentViewIndex >= total
                ? '+'
                : '${currentViewIndex + 1} / $total',
            style: LynewedTextStyles.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentViewIndex < displayTotal - 1
                ? () => _goToPage(currentViewIndex + 1)
                : null,
            color: currentViewIndex < displayTotal - 1
                ? LynewedColors.textPrimary
                : LynewedColors.gray300,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            'No pages to preview',
            style: LynewedTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos to your magazine to see the preview',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(MagazinePreviewState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: LynewedColors.background,
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
          // Format summary
          if (state.selectedFormat != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedFormat!.name,
                        style: LynewedTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.selectedFormat!.size} - ${state.photoCount} photos',
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _openFormatSheet(state),
                  child: Text(
                    'Change',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Order button
          LynewedButton(
            text: 'Order Magazine - ${state.priceFormatted}',
            onPressed: state.selectedFormat != null &&
                    widget.onNavigateToCheckout != null
                ? () {
                    // Extract cover photo URL from first page (CoverPage)
                    String? coverUrl;
                    if (state.pages.isNotEmpty &&
                        state.pages.first is CoverPage) {
                      coverUrl =
                          (state.pages.first as CoverPage).photo.thumbnailUrl;
                    }
                    // Spread count = total pages minus the cover page.
                    final spreadCount =
                        state.pages.length > 1 ? state.pages.length - 1 : 0;
                    widget.onNavigateToCheckout!(
                        state.selectedFormat!, coverUrl, spreadCount);
                  }
                : null,
            width: double.infinity,
            icon: Icons.shopping_cart_outlined,
          ),
        ],
      ),
    );
  }
}
