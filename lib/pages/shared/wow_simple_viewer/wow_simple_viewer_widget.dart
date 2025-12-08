import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import 'wow_simple_viewer_model.dart';
export 'wow_simple_viewer_model.dart';

/// Simple Image Viewer for Wedding of the Week
/// 
/// Design System v3 compliant:
/// - Clean back button with gradient overlay
/// - Bottom info bar with pro details (no favorite, no View Profile button)
/// - Vertical carousel for multiple images
class WowSimpleViewerWidget extends StatefulWidget {
  const WowSimpleViewerWidget({
    super.key,
    required this.portfolioImages,
    required this.initialIndex,
    required this.proInfo,
  });

  final List<String>? portfolioImages;
  final int? initialIndex;
  final ProDetailsStruct? proInfo;

  static String routeName = 'WowSimpleViewer';
  static String routePath = '/wowSimpleViewer';

  @override
  State<WowSimpleViewerWidget> createState() => _WowSimpleViewerWidgetState();
}

class _WowSimpleViewerWidgetState extends State<WowSimpleViewerWidget> {
  late WowSimpleViewerModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WowSimpleViewerModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.portfolioImages ?? [];
    final pro = widget.proInfo;
    final mediaQuery = MediaQuery.of(context);

    if (images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Go back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final initialPage = (widget.initialIndex ?? 0).clamp(0, images.length - 1);
    _model.pageViewController ??= PageController(initialPage: initialPage);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image carousel (vertical scroll)
          _buildImageCarousel(images),
          
          // Page indicator (right side, vertical)
          if (images.length > 1)
            _buildPageIndicator(images.length),
          
          // Top gradient overlay
          _buildTopGradient(),
          
          // Back button
          _buildBackButton(context, mediaQuery),
          
          // Bottom info bar (simplified - no fav, no button)
          if (pro != null)
            _buildBottomInfoBar(context, pro),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return PageView.builder(
      controller: _model.pageViewController,
      scrollDirection: Axis.vertical,
      itemCount: images.length,
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

  Widget _buildPageIndicator(int count) {
    return Positioned(
      right: 20,
      top: 0,
      bottom: 0,
      child: Center(
        child: smooth_page_indicator.SmoothPageIndicator(
          controller: _model.pageViewController!,
          count: count,
          axisDirection: Axis.vertical,
          effect: const smooth_page_indicator.SlideEffect(
            spacing: 8.0,
            radius: 8.0,
            dotWidth: 8.0,
            dotHeight: 8.0,
            dotColor: Color(0xB3D9D9D9),
            activeDotColor: Colors.white,
            paintStyle: PaintingStyle.fill,
          ),
        ),
      ),
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
              Colors.black.withValues(alpha: 0.6),
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
            color: Colors.black.withValues(alpha: 0.5),
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

  Widget _buildBottomInfoBar(BuildContext context, ProDetailsStruct pro) {
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
                      // Name
                      Text(
                        pro.fullName,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Profession and location row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              pro.profession?.name ?? '',
                              style: LynewedTextStyles.bodySmall.copyWith(
                                color: LynewedColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            pro.locationLabel,
                            style: LynewedTextStyles.bodySmall.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
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
