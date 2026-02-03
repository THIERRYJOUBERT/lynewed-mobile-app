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
import '../widgets/magazine_cover.dart';
import '../widgets/magazine_double_page.dart';
import '../widgets/magazine_format_selector.dart';
import '../widgets/magazine_mosaic_page.dart';
import '../widgets/magazine_single_page.dart';

/// Page for previewing the magazine and selecting format.
class MagazinePreviewPage extends StatefulWidget {
  /// Creates a magazine preview page.
  const MagazinePreviewPage({
    super.key,
    required this.photos,
    required this.weddingTitle,
    required this.weddingDate,
    this.onNavigateBack,
    this.onNavigateToCheckout,
  });

  /// Photos to include in the magazine.
  final List<MagazinePhoto> photos;

  /// Wedding title for the cover.
  final String weddingTitle;

  /// Wedding date for the cover.
  final DateTime weddingDate;

  /// Callback to navigate back to selection.
  final VoidCallback? onNavigateBack;

  /// Callback to navigate to checkout with selected format.
  final void Function(MagazineFormat format)? onNavigateToCheckout;

  @override
  State<MagazinePreviewPage> createState() => _MagazinePreviewPageState();
}

class _MagazinePreviewPageState extends State<MagazinePreviewPage> {
  late MagazinePreviewCubit _cubit;
  late PageController _pageController;
  bool _showFormatSelector = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cubit = MagazinePreviewCubit(
      photos: widget.photos,
      weddingTitle: widget.weddingTitle,
      weddingDate: widget.weddingDate,
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

  void _toggleFormatSelector() {
    setState(() {
      _showFormatSelector = !_showFormatSelector;
    });
  }

  void _onPageChanged(int index) {
    _cubit.goToPage(index);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<MagazinePreviewCubit, MagazinePreviewState>(
        listener: (context, state) {
          // Sync page controller with state
          if (_pageController.hasClients &&
              _pageController.page?.round() != state.currentPageIndex) {
            _goToPage(state.currentPageIndex);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: LynewedColors.surface,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(state),
                  Expanded(
                    child: state.isLoading
                        ? _buildLoading()
                        : _showFormatSelector
                            ? _buildFormatSelector(state)
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
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
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
            onTap: _showFormatSelector
                ? _toggleFormatSelector
                : widget.onNavigateBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _showFormatSelector ? 'Select Format' : 'Magazine Preview',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
            ),
          ),
          if (!state.isLoading && !_showFormatSelector)
            TextButton(
              onPressed: _toggleFormatSelector,
              child: Text(
                state.selectedFormat?.name ?? 'Format',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.primary,
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildFormatSelector(MagazinePreviewState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: MagazineFormatSelector(
        photoCount: state.photoCount,
        selectedFormat: state.selectedFormat,
        onFormatSelected: (format) {
          _cubit.selectFormat(format);
          _toggleFormatSelector();
        },
      ),
    );
  }

  Widget _buildPreview(MagazinePreviewState state) {
    if (state.pages.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Page counter
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${state.currentPageIndex + 1} / ${state.pageCount}',
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
            itemCount: state.pages.length,
            itemBuilder: (context, index) => _buildPage(state.pages[index]),
          ),
        ),
        // Page indicators
        _buildPageIndicators(state),
      ],
    );
  }

  Widget _buildPage(MagazinePage page) {
    return switch (page) {
      CoverPage() => MagazineCover(page: page),
      SinglePage() => MagazineSinglePage(page: page),
      DoublePage() => MagazineDoublePage(page: page),
      MosaicPage() => MagazineMosaicPage(page: page),
      _ => const SizedBox.shrink(), // Fallback for any unknown page type
    };
  }

  Widget _buildPageIndicators(MagazinePreviewState state) {
    const maxVisible = 7;
    final total = state.pageCount;
    final current = state.currentPageIndex;

    if (total <= maxVisible) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (index) {
            return GestureDetector(
              onTap: () => _goToPage(index),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == current
                      ? LynewedColors.primary
                      : LynewedColors.gray200,
                ),
              ),
            );
          }),
        ),
      );
    }

    // For many pages, show truncated indicators
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.canGoPrevious ? () => _cubit.previousPage() : null,
            color: state.canGoPrevious
                ? LynewedColors.textPrimary
                : LynewedColors.gray300,
          ),
          // Current / Total
          Text(
            '${current + 1} / $total',
            style: LynewedTextStyles.bodyMedium,
          ),
          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.canGoNext ? () => _cubit.nextPage() : null,
            color: state.canGoNext
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
        12 + MediaQuery.of(context).padding.bottom,
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
          if (state.selectedFormat != null && !_showFormatSelector) ...[
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
                  onPressed: _toggleFormatSelector,
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
          Row(
            children: [
              if (!_showFormatSelector) ...[
                TextButton(
                  onPressed: widget.onNavigateBack,
                  child: Text(
                    'Edit',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: LynewedButton(
                  text: _showFormatSelector
                      ? 'Apply'
                      : 'Order Magazine - ${state.priceFormatted}',
                  onPressed: state.selectedFormat != null
                      ? () {
                          if (_showFormatSelector) {
                            _toggleFormatSelector();
                          } else if (widget.onNavigateToCheckout != null) {
                            widget.onNavigateToCheckout!(state.selectedFormat!);
                          }
                        }
                      : null,
                  width: double.infinity,
                  icon: _showFormatSelector ? null : Icons.shopping_cart_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
