/// Marketplace Feed Page - Browsing active listings.
///
/// Displays a grid of marketplace listings with category filtering,
/// advanced filters, infinite scroll pagination, and pull-to-refresh.
library;

import 'package:flutter/material.dart';

import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/listing_filter.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/entities/offer_display_model.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../widgets/category_chips.dart';
import '../widgets/filter_badge_row.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/listing_card.dart';
import '../widgets/listing_skeleton_card.dart';
import '../widgets/pending_payment_banner.dart';
import '../widgets/seller_action_banner.dart';
import 'create_listing_page.dart';
import 'listing_detail_page.dart';
import 'marketplace_chat_page.dart';
import 'my_offers_page.dart';
import 'my_purchases_page.dart';
import 'seller_dashboard_page.dart';

/// Number of items per page for pagination.
const int _kPageSize = 20;

/// Pixels from bottom to trigger loading more.
const double _kLoadMoreThreshold = 200.0;

/// Number of skeleton cards to show during initial load.
const int _kSkeletonCount = 6;

/// Marketplace feed page showing active listings in a grid.
///
/// Features:
/// - Grid display of listing cards (2 cols mobile, 3 cols tablet)
/// - Category filtering via chips (All / Dresses / Shoes)
/// - Advanced filters via FilterSheet modal
/// - Active filter badges below category chips
/// - Infinite scroll pagination (20 items per page)
/// - Pull-to-refresh
/// - Loading, empty, and error states
/// - Navigation to listing detail on tap
class MarketplaceFeedPage extends StatefulWidget {
  /// Creates the marketplace feed page.
  const MarketplaceFeedPage({
    this.repository,
    this.onListingTap,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'MarketplaceFeed';

  /// Route path for navigation.
  static const String routePath = '/marketplace';

  /// Optional repository override for testing.
  final MarketplaceRepository? repository;

  /// Optional callback when a listing is tapped (for testing).
  /// If null, uses default navigation via GoRouter.
  final void Function(String listingId)? onListingTap;

  @override
  State<MarketplaceFeedPage> createState() => _MarketplaceFeedPageState();
}

class _MarketplaceFeedPageState extends State<MarketplaceFeedPage> {
  late final MarketplaceRepository _repository;
  final ScrollController _scrollController = ScrollController();

  List<MarketplaceListing> _listings = [];
  int _currentPage = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  String? _selectedCategory;
  ListingFilter _currentFilter = const ListingFilter.empty();

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

  /// Whether advanced filters (beyond category) are active.
  bool get _hasAdvancedFilters {
    // Check if filter has anything beyond just category.
    return _currentFilter.minPriceCents != null ||
        _currentFilter.maxPriceCents != null ||
        (_currentFilter.sizes != null && _currentFilter.sizes!.isNotEmpty) ||
        (_currentFilter.brands != null && _currentFilter.brands!.isNotEmpty) ||
        (_currentFilter.conditions != null &&
            _currentFilter.conditions!.isNotEmpty) ||
        _currentFilter.country != null;
  }

  /// Builds the effective filter combining category chips and advanced filters.
  ListingFilter get _effectiveFilter {
    if (_selectedCategory != null) {
      return _currentFilter.copyWith(category: _selectedCategory);
    }
    // If category is not selected via chips, use whatever is in the filter.
    return _currentFilter;
  }

  Future<void> _loadInitialListings() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final List<MarketplaceListing> listings;

      if (_hasAdvancedFilters || _currentFilter.category != null) {
        // Use filtered query when any filter is active.
        listings = await _repository.getFilteredListings(
          filter: _effectiveFilter,
          page: 0,
          pageSize: _kPageSize,
        );
      } else {
        // Use simple query when only category chip is active.
        listings = await _repository.getListings(
          category: _selectedCategory,
          page: 0,
          pageSize: _kPageSize,
        );
      }

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
      final List<MarketplaceListing> newListings;

      if (_hasAdvancedFilters || _currentFilter.category != null) {
        newListings = await _repository.getFilteredListings(
          filter: _effectiveFilter,
          page: nextPage,
          pageSize: _kPageSize,
        );
      } else {
        newListings = await _repository.getListings(
          category: _selectedCategory,
          page: nextPage,
          pageSize: _kPageSize,
        );
      }

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

  Future<void> _onRefresh() async {
    _currentPage = 0;
    _hasMore = true;
    _errorMessage = null;

    try {
      final List<MarketplaceListing> listings;

      if (_hasAdvancedFilters || _currentFilter.category != null) {
        listings = await _repository.getFilteredListings(
          filter: _effectiveFilter,
          page: 0,
          pageSize: _kPageSize,
        );
      } else {
        listings = await _repository.getListings(
          category: _selectedCategory,
          page: 0,
          pageSize: _kPageSize,
        );
      }

      if (!mounted) return;
      setState(() {
        _listings = listings;
        _hasMore = listings.length == _kPageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
      // Sync category from chips into the filter for the filter sheet.
      if (category != null) {
        _currentFilter = _currentFilter.copyWith(category: category);
      } else {
        _currentFilter = _currentFilter.copyWith(clearCategory: true);
      }
    });
    _loadInitialListings();
  }

  void _onFilterChanged(ListingFilter filter) {
    setState(() {
      _currentFilter = filter;
      // Sync category from filter to category chips.
      _selectedCategory = filter.category;
      _listings.clear();
      _currentPage = 0;
    });
    _loadInitialListings();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LynewedColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => FilterSheet(
          initialFilter: _effectiveFilter,
          repository: _repository,
          scrollController: scrollController,
          onApply: (filter) {
            Navigator.pop(context);
            _onFilterChanged(filter);
          },
        ),
      ),
    );
  }

  void _onCreateListing() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CreateListingPage(),
      ),
    );
  }

  void _onMyOffersTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MyOffersPage(),
      ),
    );
  }

  void _onPendingPaymentTap(List<OfferDisplayModel> offers) {
    if (offers.length == 1) {
      final offer = offers.first;
      final partnerId = offer.chatPartnerId ?? offer.sellerId;
      if (partnerId != null) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MarketplaceChatPage(
              listingId: offer.offer.listingId,
              otherUserId: partnerId,
              listingTitle: offer.listingTitle,
              otherUserName: offer.chatPartnerName ?? offer.sellerName,
              otherUserAvatarUrl:
                  offer.chatPartnerAvatarUrl ?? offer.sellerAvatarUrl,
            ),
          ),
        );
        return;
      }
    }
    _onMyOffersTap();
  }

  void _onMySalesTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SellerDashboardPage(),
      ),
    );
  }

  void _onMyPurchasesTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MyPurchasesPage(),
      ),
    );
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

  String? _extractCoverPhotoUrl(MarketplaceListing listing) {
    // The coverPhotoStoragePath is populated by the repository
    // with a full public URL when the query joins marketplace_photos.
    return listing.coverPhotoStoragePath;
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
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 84.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    CategoryChips(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: _onCategoryChanged,
                    ),
                    // Show active filter badges when advanced filters are active.
                    if (_currentFilter.hasActiveFilters)
                      FilterBadgeRow(
                        filter: _currentFilter,
                        onFilterChanged: _onFilterChanged,
                      ),
                    PendingPaymentBanner(
                      onTap: _onPendingPaymentTap,
                    ),
                    SellerActionBanner(
                      onTap: (_) => _onMySalesTap(),
                    ),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ),
            // Bottom Navigation
            const Align(
              alignment: Alignment.bottomCenter,
              child: NavBarBridesWidget(number: 3),
            ),
            // Sell FAB
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton(
                heroTag: 'sell-fab',
                onPressed: _onCreateListing,
                backgroundColor: LynewedColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Marketplace',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          // My Purchases button (buyer view).
          LynewedIconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: LynewedColors.textPrimary,
              size: 22,
            ),
            onPressed: _onMyPurchasesTap,
            buttonSize: 40,
          ),
          // My Offers button (buyer view).
          LynewedIconButton(
            icon: const Icon(
              Icons.local_offer_outlined,
              color: LynewedColors.textPrimary,
              size: 22,
            ),
            onPressed: _onMyOffersTap,
            buttonSize: 40,
          ),
          // My Sales button.
          LynewedIconButton(
            icon: const Icon(
              Icons.storefront_outlined,
              color: LynewedColors.textPrimary,
              size: 22,
            ),
            onPressed: _onMySalesTap,
            buttonSize: 40,
          ),
          // Filter button with badge indicator.
          Stack(
            clipBehavior: Clip.none,
            children: [
              LynewedIconButton(
                icon: const Icon(
                  Icons.tune,
                  color: LynewedColors.textPrimary,
                  size: 22,
                ),
                onPressed: _openFilterSheet,
                buttonSize: 40,
              ),
              if (_currentFilter.hasActiveFilters)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: LynewedColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentFilter.activeFilterCount}',
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: LynewedColors.textOnPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitialLoading) {
      return _buildSkeletonGrid();
    }

    if (_errorMessage != null && _listings.isEmpty) {
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
              'No listings yet',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              'Be the first to list your wedding dress or shoes!',
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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: LynewedColors.primary,
      child: CustomScrollView(
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
                      coverPhotoUrl: _extractCoverPhotoUrl(listing),
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
      ),
    );
  }
}
