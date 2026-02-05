/// HomeMarketplacePreview widget for bride home page.
///
/// Displays a horizontal preview of recent marketplace listings with
/// section header, "View all" link, and mini listing cards.
/// Returns SizedBox.shrink() if no listings or on error.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../pages/marketplace_feed_page.dart';

/// Number of listings to fetch for the home preview.
const int _kPreviewPageSize = 5;

/// Width of each mini listing card.
const double _kCardWidth = 150.0;

/// Height of the card photo section.
const double _kCardPhotoHeight = 150.0;

/// A preview section for the bride home page showing recent marketplace listings.
///
/// Features:
/// - Fetches the 5 most recent active listings
/// - Horizontal scrollable card row
/// - Section header "MARKETPLACE" with "View all" link
/// - Mini cards: square photo + title (1 line) + price
/// - Returns SizedBox.shrink() if empty or on error
class HomeMarketplacePreview extends StatefulWidget {
  /// Creates the marketplace preview widget.
  const HomeMarketplacePreview({
    this.repository,
    this.onSeeAllTap,
    this.onListingTap,
    super.key,
  });

  /// Optional repository override for testing.
  final MarketplaceRepository? repository;

  /// Optional callback when "View all" is tapped (for testing).
  final VoidCallback? onSeeAllTap;

  /// Optional callback when a listing card is tapped (for testing).
  final void Function(String listingId)? onListingTap;

  @override
  State<HomeMarketplacePreview> createState() => _HomeMarketplacePreviewState();
}

class _HomeMarketplacePreviewState extends State<HomeMarketplacePreview> {
  late final MarketplaceRepository _repository;
  List<MarketplaceListing>? _listings;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceRepository>();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      final listings = await _repository.getListings(
        page: 0,
        pageSize: _kPreviewPageSize,
      );
      if (!mounted) return;
      setState(() {
        _listings = listings;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
      });
    }
  }

  /// Default navigation to marketplace feed page.
  void _navigateToMarketplace(BuildContext context) {
    context.goNamed(
      MarketplaceFeedPage.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // While loading, show nothing (avoid layout shift).
    if (_listings == null && !_hasError) {
      return const SizedBox.shrink();
    }

    // Empty or error: show nothing.
    if (_hasError || _listings == null || _listings!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14.0),
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MARKETPLACE',
              style: LynewedTextStyles.sectionTitle,
            ),
            GestureDetector(
              onTap: widget.onSeeAllTap ?? () => _navigateToMarketplace(context),
              behavior: HitTestBehavior.opaque,
              child: Text(
                'View all',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          'Discover pre-loved wedding items',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14.0),
        // Horizontal listings row
        SizedBox(
          height: _kCardPhotoHeight + 60, // photo + info section
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _listings!.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final listing = _listings![index];
              return _MiniListingCard(
                listing: listing,
                onTap: () {
                  if (widget.onListingTap != null) {
                    widget.onListingTap!(listing.id);
                  } else {
                    _navigateToMarketplace(context);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A compact listing card for the home preview.
///
/// Shows a square photo on top, then title (1 line) and price below.
class _MiniListingCard extends StatelessWidget {
  const _MiniListingCard({
    required this.listing,
    required this.onTap,
  });

  final MarketplaceListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _kCardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square photo
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: _kCardWidth,
                height: _kCardPhotoHeight,
                child: _buildPhoto(),
              ),
            ),
            const SizedBox(height: 6),
            // Title (1 line)
            Text(
              listing.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LynewedTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            // Price
            Text(
              _formatPrice(listing.priceCents),
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    final photoPath = listing.coverPhotoStoragePath;
    if (photoPath == null || photoPath.isEmpty) {
      return Container(
        color: LynewedColors.gray200,
        child: const Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            color: LynewedColors.gray300,
            size: 32,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: photoPath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: LynewedColors.gray200,
      ),
      errorWidget: (context, url, error) => Container(
        color: LynewedColors.gray200,
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: LynewedColors.gray300,
            size: 32,
          ),
        ),
      ),
    );
  }

  String _formatPrice(int cents) {
    final dollars = cents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}
