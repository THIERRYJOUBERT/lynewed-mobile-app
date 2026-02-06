/// Seller Listings Page - Displays all active listings from a specific seller.
///
/// Shows a seller header with avatar, name, and count,
/// followed by a paginated grid of their active listings.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../widgets/listing_card.dart';
import '../widgets/listing_skeleton_card.dart';
import 'listing_detail_page.dart';

/// Number of items per page for pagination.
const int _kPageSize = 20;

/// Pixels from bottom to trigger loading more.
const double _kLoadMoreThreshold = 200.0;

/// Number of skeleton cards to show during initial load.
const int _kSkeletonCount = 6;

/// Page displaying all active listings from a specific seller.
///
/// Features:
/// - Seller header with avatar, name, and listings count
/// - Grid display of listing cards (2 cols mobile, 3 cols tablet)
/// - Infinite scroll pagination (20 items per page)
/// - Loading, empty, and error states
/// - Navigation to listing detail on tap
class SellerListingsPage extends StatefulWidget {
  /// Creates the seller listings page.
  const SellerListingsPage({
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    this.sellerListingsCount = 0,
    this.repository,
    this.onListingTap,
    super.key,
  });

  /// The seller's user ID.
  final String sellerId;

  /// The seller's display name.
  final String sellerName;

  /// The seller's avatar URL (optional).
  final String? sellerAvatarUrl;

  /// Number of active listings for this seller.
  final int sellerListingsCount;

  /// Optional repository override for testing.
  final MarketplaceRepository? repository;

  /// Optional callback when a listing is tapped (for testing).
  final void Function(String listingId)? onListingTap;

  @override
  State<SellerListingsPage> createState() => _SellerListingsPageState();
}

class _SellerListingsPageState extends State<SellerListingsPage> {
  late final MarketplaceRepository _repository;
  final ScrollController _scrollController = ScrollController();

  List<MarketplaceListing> _listings = [];
  int _currentPage = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceRepository>();
    _scrollController.addListener(_onScroll);
    _loadInitialListings();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _kLoadMoreThreshold) {
      _loadMoreListings();
    }
  }

  Future<void> _loadInitialListings() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final listings = await _repository.getSellerListings(
        sellerId: widget.sellerId,
        page: 0,
        pageSize: _kPageSize,
      );

      if (!mounted) return;
      setState(() {
        _listings = listings;
        _hasMore = listings.length == _kPageSize;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMoreListings() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final newListings = await _repository.getSellerListings(
        sellerId: widget.sellerId,
        page: nextPage,
        pageSize: _kPageSize,
      );

      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _listings.addAll(newListings);
        _hasMore = newListings.length == _kPageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _onListingTap(MarketplaceListing listing) {
    if (widget.onListingTap != null) {
      widget.onListingTap!(listing.id);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListingDetailPage(listingId: listing.id),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 768) return 3;
    return 2;
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
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 8),
          // Seller avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: LynewedColors.primary,
            backgroundImage: widget.sellerAvatarUrl != null
                ? CachedNetworkImageProvider(widget.sellerAvatarUrl!)
                : null,
            child: widget.sellerAvatarUrl == null
                ? Text(
                    widget.sellerName.isNotEmpty
                        ? widget.sellerName[0].toUpperCase()
                        : '?',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      color: LynewedColors.textOnDark,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sellerName,
                  style: LynewedTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.sellerListingsCount} listing${widget.sellerListingsCount == 1 ? '' : 's'}',
                  style: LynewedTextStyles.bodySmall.copyWith(
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

  Widget _buildBody() {
    if (_isInitialLoading) {
      return _buildSkeletonGrid();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_listings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildListingsGrid();
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.62,
      ),
      itemCount: _kSkeletonCount,
      itemBuilder: (context, index) => const ListingSkeletonCard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: LynewedColors.error,
            ),
            SizedBox(height: LynewedSpacing.lg),
            Text(
              'Failed to load listings',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: LynewedSpacing.lg),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.secondary,
              onPressed: _loadInitialListings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            SizedBox(height: LynewedSpacing.lg),
            Text(
              'No listings',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'This seller has no active listings at the moment.',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsGrid() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _listings.length) {
                  final listing = _listings[index];
                  return ListingCard(
                    title: listing.title,
                    priceCents: listing.priceCents,
                    condition: listing.condition,
                    city: listing.city,
                    country: listing.country,
                    coverPhotoUrl: listing.coverPhotoStoragePath,
                    onTap: () => _onListingTap(listing),
                  );
                }
                // Loading indicator at the end
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LynewedColors.primary,
                      ),
                    ),
                  ),
                );
              },
              childCount:
                  _listings.length + (_hasMore && _listings.isNotEmpty ? 1 : 0),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.62,
            ),
          ),
        ),
      ],
    );
  }
}
