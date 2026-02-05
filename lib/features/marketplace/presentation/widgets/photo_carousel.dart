/// PhotoCarousel widget for listing detail pages.
///
/// Displays a swipeable PageView of photos with a SmoothPageIndicator
/// and tap-to-view-fullscreen support.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '/core/design/design.dart';

/// A swipeable photo carousel with a page indicator.
///
/// Displays listing photos in a square aspect ratio with:
/// - Swipe navigation between photos
/// - Dot indicator showing current position
/// - Tap callback for full-screen viewing
/// - Placeholder and error states
class PhotoCarousel extends StatefulWidget {
  /// Creates a photo carousel.
  const PhotoCarousel({
    required this.photoUrls,
    this.onPhotoTap,
    super.key,
  });

  /// URLs of photos to display.
  final List<String> photoUrls;

  /// Callback when a photo is tapped, with the index of the tapped photo.
  final void Function(int index)? onPhotoTap;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: LynewedColors.gray200,
          child: const Center(
            child: Icon(
              Icons.shopping_bag_outlined,
              color: LynewedColors.gray300,
              size: 64,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          // Photo PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photoUrls.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => widget.onPhotoTap?.call(index),
              child: CachedNetworkImage(
                imageUrl: widget.photoUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: LynewedColors.gray200,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LynewedColors.gray300,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: LynewedColors.gray200,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: LynewedColors.gray300,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page indicator (only show if more than 1 photo)
          if (widget.photoUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.photoUrls.length,
                  effect: WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    activeDotColor: LynewedColors.primary,
                    dotColor:
                        LynewedColors.background.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
