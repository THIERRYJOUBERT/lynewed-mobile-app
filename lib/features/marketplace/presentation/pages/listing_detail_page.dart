/// Listing Detail Page - Full view of a marketplace listing.
///
/// Displays photo carousel, listing info, seller info, and action buttons.
/// Fetches listing, photos, and seller data on load.
library;

import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
import '/core/design/design.dart';
import '/core/di/injection_container.dart';
import '../../domain/entities/marketplace_listing.dart';
import '../../domain/entities/seller_profile.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../sheets/make_offer_sheet.dart';
import '../widgets/action_buttons_bar.dart';
import '../widgets/listing_info_section.dart';
import '../widgets/photo_carousel.dart';
import '../widgets/seller_info_widget.dart';
import 'seller_listings_page.dart';
import 'checkout_page.dart';
import 'create_listing_page.dart';
import 'marketplace_chat_page.dart';
import 'received_offers_page.dart';

/// Detail page for a marketplace listing.
///
/// Displays:
/// - Photo carousel (swipeable with page indicator)
/// - Listing details (title, price, description, size, brand, condition, location)
/// - Seller info (name, avatar, listings count)
/// - Action buttons (Contact, Make Offer, Buy Now for buyers; View Offers for sellers)
///
/// States:
/// - Loading: circular progress indicator
/// - Error: error message with retry button
/// - Data: full detail layout with scroll
class ListingDetailPage extends StatefulWidget {
  /// Creates a listing detail page.
  const ListingDetailPage({
    required this.listingId,
    this.currentUserId,
    this.repository,
    super.key,
  });

  /// Route name for navigation.
  static const String routeName = 'ListingDetail';

  /// Route path for GoRouter registration.
  static const String routePath = '/marketplace/listing';

  /// The ID of the listing to display.
  final String listingId;

  /// Optional repository override for testing.
  final MarketplaceRepository? repository;

  /// The current authenticated user's ID. Falls back to [currentUserUid] if not provided.
  final String? currentUserId;

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  late final MarketplaceRepository _repository;

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  MarketplaceListing? _listing;
  SellerProfile? _seller;
  List<String> _photoUrls = [];
  bool _hasAcceptedOffer = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? sl<MarketplaceRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch listing details.
      final listing = await _repository.getListingById(widget.listingId);
      if (listing == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Listing not found';
        });
        return;
      }

      // Fetch photos, seller info, and accepted offer status in parallel.
      final offerRepo = sl<MarketplaceOfferRepository>();
      final results = await Future.wait([
        _repository.getPhotoUrls(widget.listingId),
        _repository.getSellerInfo(listing.sellerId),
        offerRepo.hasAcceptedOfferForListing(widget.listingId),
      ]);

      if (!mounted) return;
      setState(() {
        _listing = listing;
        _photoUrls = results[0] as List<String>;
        _seller = results[1] as SellerProfile?;
        _hasAcceptedOffer = results[2] as bool;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load listing';
      });
    }
  }

  void _openFullScreenViewer(int index) {
    // Navigate to full screen image viewer for the tapped photo.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _FullScreenPhotoViewer(
          photoUrls: _photoUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: _buildBody(),
      bottomNavigationBar: _listing != null ? _buildActionBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: LynewedColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_listing == null) {
      return _buildErrorState();
    }

    return _buildDetailContent();
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
              _errorMessage ?? 'Failed to load listing',
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

  Widget _buildDetailContent() {
    return CustomScrollView(
      slivers: [
        // App bar overlaid on photo carousel
        SliverToBoxAdapter(
          child: Stack(
            children: [
              PhotoCarousel(
                photoUrls: _photoUrls,
                onPhotoTap: _photoUrls.isNotEmpty ? _openFullScreenViewer : null,
              ),
              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: _buildCircularButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),

        // Listing info
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(LynewedSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListingInfoSection(listing: _listing!),
                SizedBox(height: LynewedSpacing.xxl),

                // Seller info
                if (_seller != null) ...[
                  const LynewedSectionTitle('Seller'),
                  SizedBox(height: LynewedSpacing.sm),
                  SellerInfoWidget(
                    seller: _seller!,
                    onViewListings: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SellerListingsPage(
                            sellerId: _seller!.id,
                            sellerName: _seller!.name,
                            sellerAvatarUrl: _seller!.avatarUrl,
                            sellerListingsCount: _seller!.listingsCount,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: LynewedSpacing.xxl),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: LynewedColors.background.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: LynewedColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  void _openChat() {
    if (_listing == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MarketplaceChatPage(
          listingId: _listing!.id,
          otherUserId: _listing!.sellerId,
          listingTitle: _listing!.title,
          listingPriceCents: _listing!.priceCents,
          listingCoverUrl: _photoUrls.isNotEmpty ? _photoUrls.first : null,
          otherUserName: _seller?.name,
          otherUserAvatarUrl: _seller?.avatarUrl,
          sellerId: _listing!.sellerId,
        ),
      ),
    );
  }

  void _openCheckout() {
    if (_listing == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutPage(
          listing: _listing!,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  /// Returns the current user ID.
  String get _currentUserId => widget.currentUserId ?? currentUserUid;

  /// Whether the current user is the seller of this listing.
  bool get _isCurrentUserSeller =>
      _listing != null && _currentUserId == _listing!.sellerId;

  Widget _buildActionBar() {
    if (_isCurrentUserSeller) {
      return _buildSellerActionBar();
    }
    return ActionButtonsBar(
      onContact: _openChat,
      onMakeOffer: _hasAcceptedOffer ? null : _openMakeOfferSheet,
      onBuyNow: _openCheckout,
    );
  }

  /// Action bar shown when the current user is the seller.
  Widget _buildSellerActionBar() {
    final isDraft = _listing?.status == 'draft';

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(LynewedSpacing.md),
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          border: Border(
            top: BorderSide(color: LynewedColors.gray200),
          ),
        ),
        child: isDraft
            ? LynewedButton(
                text: 'Edit Draft',
                type: LynewedButtonType.primary,
                onPressed: _editListing,
              )
            : Row(
                children: [
                  Expanded(
                    child: LynewedButton(
                      text: 'View Offers',
                      type: LynewedButtonType.primary,
                      onPressed: _openReceivedOffers,
                    ),
                  ),
                  SizedBox(width: LynewedSpacing.md),
                  Expanded(
                    child: LynewedButton(
                      text: 'Edit',
                      type: LynewedButtonType.secondary,
                      onPressed: _editListing,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _editListing() {
    if (_listing == null) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => CreateListingPage(
              existingListing: _listing,
              userId: _currentUserId,
            ),
          ),
        )
        .then((_) => _loadData());
  }

  void _openMakeOfferSheet() {
    if (_listing == null) return;
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LynewedColors.transparent,
      builder: (_) => MakeOfferSheet(
        listingId: _listing!.id,
        listingTitle: _listing!.title,
        listingPriceCents: _listing!.priceCents,
        receiverId: _listing!.sellerId,
      ),
    ).then((result) {
      if (result == true && mounted) {
        // Navigate to the conversation with the seller after making an offer.
        _openChat();
      }
    });
  }

  void _openReceivedOffers() {
    if (_listing == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceivedOffersPage(
          listingId: _listing!.id,
          listingTitle: _listing!.title,
        ),
      ),
    );
  }
}

/// Simple full-screen photo viewer with PageView for listing photos.
///
/// Allows swiping between photos and tap to close.
class _FullScreenPhotoViewer extends StatefulWidget {
  const _FullScreenPhotoViewer({
    required this.photoUrls,
    required this.initialIndex,
  });

  final List<String> photoUrls;
  final int initialIndex;

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.textPrimary,
      body: Stack(
        children: [
          // Photo pages
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photoUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => InteractiveViewer(
              child: Center(
                child: Image.network(
                  widget.photoUrls[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    color: LynewedColors.background,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LynewedColors.textPrimary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: LynewedColors.background,
                  size: 24,
                ),
              ),
            ),
          ),

          // Page counter
          if (widget.photoUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: LynewedColors.textPrimary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photoUrls.length}',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.background,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
