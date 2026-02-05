/// Seller Dashboard Page - "My Sales" management page.
///
/// Displays all seller listings grouped by status with earnings stats,
/// offer count badges, and navigation to listing/transaction details.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';
import 'create_listing_page.dart';
import 'listing_detail_page.dart';
import 'transaction_detail_page.dart';

/// Status filter options for the seller dashboard.
const List<String> _statusFilters = ['All', 'Active', 'Sold', 'Reserved', 'Draft'];

/// Maps a filter chip label to the listing status value.
String? _filterToStatus(String filter) {
  switch (filter) {
    case 'Active':
      return 'active';
    case 'Sold':
      return 'sold';
    case 'Reserved':
      return 'reserved';
    case 'Draft':
      return 'draft';
    default:
      return null; // "All" = no filter.
  }
}

/// Seller dashboard page showing listings, earnings stats, and sales management.
///
/// Features:
/// - Earnings summary (total sales, 10% commission, net payout)
/// - Status filter chips (All / Active / Sold / Reserved / Draft)
/// - Listing cards with status badge, price, and offer count
/// - Navigation to listing detail (draft/active) or transaction detail (reserved)
/// - Create new listing action
class SellerDashboardPage extends StatefulWidget {
  /// Creates the seller dashboard page.
  const SellerDashboardPage({
    this.repository,
    this.transactionRepository,
    this.offerRepository,
    this.onListingTap,
    this.onTransactionTap,
    super.key,
  });

  /// Optional repository override for testing.
  final MarketplaceRepository? repository;

  /// Optional transaction repository override for testing.
  final MarketplaceTransactionRepository? transactionRepository;

  /// Optional offer repository override for testing.
  final MarketplaceOfferRepository? offerRepository;

  /// Optional callback when a listing is tapped (for testing).
  final void Function(String listingId)? onListingTap;

  /// Optional callback when a transaction is tapped (for testing).
  final void Function(String transactionId)? onTransactionTap;

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  late final MarketplaceRepository _repository;
  late final MarketplaceTransactionRepository _transactionRepository;
  late final MarketplaceOfferRepository _offerRepository;

  bool _isLoading = true;
  String? _errorMessage;
  List<MarketplaceListing> _listings = [];
  List<MarketplaceTransaction> _sales = [];
  Map<String, int> _pendingOfferCounts = {};
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceRepository>();
    _transactionRepository =
        widget.transactionRepository ?? sl<MarketplaceTransactionRepository>();
    _offerRepository =
        widget.offerRepository ?? sl<MarketplaceOfferRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load listings and sales in parallel.
      final results = await Future.wait([
        _repository.getMyListings(),
        _transactionRepository.getMySales(),
      ]);

      final listings = results[0] as List<MarketplaceListing>;
      final sales = results[1] as List<MarketplaceTransaction>;

      // Load pending offer counts for each active/reserved listing.
      final offerCounts = <String, int>{};
      final listingsNeedingOfferCount =
          listings.where((l) => l.status == 'active' || l.status == 'reserved');

      await Future.wait(
        listingsNeedingOfferCount.map((listing) async {
          try {
            final offers =
                await _offerRepository.getOffersForListing(listing.id);
            final pendingCount =
                offers.where((o) => o.status == 'pending').length;
            if (pendingCount > 0) {
              offerCounts[listing.id] = pendingCount;
            }
          } catch (_) {
            // Silently handle offer loading errors per listing.
          }
        }),
      );

      if (!mounted) return;
      setState(() {
        _listings = listings;
        _sales = sales;
        _pendingOfferCounts = offerCounts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load listings';
      });
    }
  }

  /// Returns listings filtered by the current selected status.
  List<MarketplaceListing> get _filteredListings {
    final statusFilter = _filterToStatus(_selectedFilter);
    if (statusFilter == null) return _listings;
    return _listings.where((l) => l.status == statusFilter).toList();
  }

  /// Calculates earnings from completed transactions only.
  double get _totalSales {
    return _completedSales.fold<double>(
      0,
      (sum, tx) => sum + tx.itemPriceInDollars,
    );
  }

  double get _totalCommission {
    return _completedSales.fold<double>(
      0,
      (sum, tx) => sum + tx.platformFeeInDollars,
    );
  }

  double get _totalNetPayout {
    return _completedSales.fold<double>(
      0,
      (sum, tx) => sum + tx.sellerPayoutInDollars,
    );
  }

  List<MarketplaceTransaction> get _completedSales {
    return _sales.where((tx) => tx.status == 'completed').toList();
  }

  /// Finds the transaction for a reserved listing.
  MarketplaceTransaction? _findTransactionForListing(String listingId) {
    try {
      return _sales.firstWhere((tx) => tx.listingId == listingId);
    } catch (_) {
      return null;
    }
  }

  void _onListingTap(MarketplaceListing listing) {
    if (listing.status == 'reserved') {
      final transaction = _findTransactionForListing(listing.id);
      if (transaction != null) {
        if (widget.onTransactionTap != null) {
          widget.onTransactionTap!(transaction.id);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TransactionDetailPage(
                transactionId: transaction.id,
              ),
            ),
          );
        }
        return;
      }
    }

    // For draft, active, and sold listings, navigate to listing detail.
    if (widget.onListingTap != null) {
      widget.onListingTap!(listing.id);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ListingDetailPage(listingId: listing.id),
        ),
      );
    }
  }

  void _onCreateListing() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CreateListingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      floatingActionButton: (!_isLoading && _errorMessage == null)
          ? FloatingActionButton(
              onPressed: _onCreateListing,
              backgroundColor: LynewedColors.primary,
              child: const Icon(Icons.add, color: LynewedColors.textOnDark),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
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
              'My Sales',
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
        child: CircularProgressIndicator(color: LynewedColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: LynewedColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEarningsSection(),
            const SizedBox(height: 30),
            _buildFilterChips(),
            const SizedBox(height: 20),
            _buildListingsSection(),
            const SizedBox(height: 80), // Space for FAB.
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'Total Sales',
              value: _formatCurrency(_totalSales),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: LynewedColors.gray200,
          ),
          Expanded(
            child: _buildStatItem(
              label: 'Commission',
              value: _formatCurrency(_totalCommission),
              valueColor: LynewedColors.error,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: LynewedColors.gray200,
          ),
          Expanded(
            child: _buildStatItem(
              label: 'Net Payout',
              value: _formatCurrency(_totalNetPayout),
              valueColor: LynewedColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: LynewedTextStyles.titleSmall.copyWith(
            color: valueColor ?? LynewedColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? LynewedColors.primary
                    : LynewedColors.background,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? LynewedColors.primary
                      : LynewedColors.gray300,
                ),
              ),
              child: Text(
                filter,
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? LynewedColors.textOnDark
                      : LynewedColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListingsSection() {
    final listings = _filteredListings;

    if (listings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _buildListingTile(listings[index]),
    );
  }

  Widget _buildListingTile(MarketplaceListing listing) {
    final pendingOffers = _pendingOfferCounts[listing.id] ?? 0;
    final transaction = listing.status == 'reserved'
        ? _findTransactionForListing(listing.id)
        : null;
    final showGenerateLabel =
        listing.status == 'reserved' && transaction?.isPaid == true;

    return GestureDetector(
      onTap: () => _onListingTap(listing),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LynewedColors.gray200),
        ),
        child: Row(
          children: [
            // Cover photo thumbnail.
            _buildThumbnail(listing),
            const SizedBox(width: 12),

            // Info section.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with status badge.
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LynewedTextStyles.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(listing.status),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Price.
                  Text(
                    _formatCurrency(listing.priceInDollars),
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bottom row: offer badge + generate label.
                  Row(
                    children: [
                      if (pendingOffers > 0)
                        Container(
                          key: Key('offer-badge-${listing.id}'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                LynewedColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer,
                                size: 14,
                                color: LynewedColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$pendingOffers',
                                style: LynewedTextStyles.labelSmall.copyWith(
                                  color: LynewedColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showGenerateLabel) ...[
                        if (pendingOffers > 0) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                LynewedColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.label_outline,
                                size: 14,
                                color: LynewedColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Generate Label',
                                style: LynewedTextStyles.labelSmall.copyWith(
                                  color: LynewedColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Chevron.
            const Icon(
              Icons.chevron_right,
              color: LynewedColors.gray300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(MarketplaceListing listing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 64,
        child: listing.coverPhotoStoragePath != null
            ? Image.network(
                listing.coverPhotoStoragePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderThumbnail(),
              )
            : _buildPlaceholderThumbnail(),
      ),
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      color: LynewedColors.gray200,
      child: const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: LynewedColors.gray300,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final label = status.toUpperCase();
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: LynewedTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final statusFilter = _filterToStatus(_selectedFilter);
    final message = statusFilter == null
        ? 'No listings yet'
        : 'No $statusFilter listings';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            SizedBox(height: LynewedSpacing.lg),
            Text(
              message,
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            SizedBox(height: LynewedSpacing.sm),
            Text(
              statusFilter == null
                  ? 'Start selling by creating your first listing'
                  : 'No listings match this filter',
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
              _errorMessage ?? 'Failed to load listings',
              style: LynewedTextStyles.titleSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LynewedSpacing.lg),
            LynewedButton(
              text: 'Retry',
              type: LynewedButtonType.secondary,
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return LynewedColors.success;
      case 'sold':
        return LynewedColors.primary;
      case 'reserved':
        return LynewedColors.warning;
      case 'draft':
        return LynewedColors.textSecondary;
      default:
        return LynewedColors.textSecondary;
    }
  }
}
