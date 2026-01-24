import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import 'portfolio_image_viewer_model.dart';
export 'portfolio_image_viewer_model.dart';

/// Portfolio Image Viewer - Full screen image gallery
/// 
/// Design System v3 compliant:
/// - Clean header with back button
/// - Vertical scroll for images
/// - Bottom info bar with pro details
/// - Smooth page indicators
class PortfolioImageViewerWidget extends StatefulWidget {
  const PortfolioImageViewerWidget({
    super.key,
    required this.portfolioImages,
    required this.initialIndex,
    required this.proInfo,
  });

  final List<String>? portfolioImages;
  final int? initialIndex;
  final ProDetailsStruct? proInfo;

  static String routeName = 'PortfolioImageViewer';
  static String routePath = '/portfolioImageViewer';

  @override
  State<PortfolioImageViewerWidget> createState() =>
      _PortfolioImageViewerWidgetState();
}

class _PortfolioImageViewerWidgetState
    extends State<PortfolioImageViewerWidget> {
  late PortfolioImageViewerModel _model;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PortfolioImageViewerModel());
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.portfolioImages ?? [];
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image viewer with vertical scroll
          _buildImageViewer(images),
          
          // Top gradient overlay for better visibility
          _buildTopGradient(),
          
          // Back button
          _buildBackButton(context, mediaQuery),
          
          // Page indicator (right side, vertical)
          if (images.length > 1)
            _buildPageIndicator(images),
          
          // Bottom info bar
          _buildBottomInfoBar(images),
        ],
      ),
    );
  }

  Widget _buildImageViewer(List<String> images) {
    if (images.isEmpty) {
      return const Center(
        child: Text(
          'No images',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: images.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
      },
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: CachedNetworkImage(
            imageUrl: images[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha:0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, MediaQueryData mediaQuery) {
    return Positioned(
      top: mediaQuery.padding.top + 12,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha:0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_left,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(List<String> images) {
    return Positioned(
      right: 20,
      top: 0,
      bottom: 0,
      child: Center(
        child: smooth_page_indicator.SmoothPageIndicator(
          controller: _pageController,
          count: images.length,
          axisDirection: Axis.vertical,
          effect: const smooth_page_indicator.SlideEffect(
            spacing: 8.0,
            radius: 4.0,
            dotWidth: 8.0,
            dotHeight: 8.0,
            dotColor: Colors.white38,
            activeDotColor: Colors.white,
            paintStyle: PaintingStyle.fill,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfoBar(List<String> images) {
    final pro = widget.proInfo;
    if (pro == null) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: pro.avatarUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 48,
                      height: 48,
                      color: LynewedColors.surface,
                      child: const Icon(
                        Icons.person_outline,
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 48,
                      height: 48,
                      color: LynewedColors.surface,
                      child: const Icon(
                        Icons.person_outline,
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Pro info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pro.fullName,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pro.profession?.name ?? '',
                        style: LynewedTextStyles.bodySmall.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Image counter
                if (images.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: LynewedColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${images.length}',
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
