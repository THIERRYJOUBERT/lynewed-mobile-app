import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/core/design/design.dart';
import '/index.dart';
import 'feed_detail_viewer_model.dart';
export 'feed_detail_viewer_model.dart';

/// Feed Detail Viewer - Full screen feed image viewer
/// 
/// Design System v3 compliant:
/// - Clean back button with gradient overlay
/// - Bottom info bar with pro details
/// - Favorite toggle with black icon
/// - View Profile button (LynewedButton)
class FeedDetailViewerWidget extends StatefulWidget {
  const FeedDetailViewerWidget({
    super.key,
    required this.feedInfosPro,
  });

  final FeedImageItemStruct? feedInfosPro;

  static String routeName = 'FeedDetailViewer';
  static String routePath = '/feedDetailViewer';

  @override
  State<FeedDetailViewerWidget> createState() => _FeedDetailViewerWidgetState();
}

class _FeedDetailViewerWidgetState extends State<FeedDetailViewerWidget> {
  late FeedDetailViewerModel _model;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeedDetailViewerModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _model.fav = widget.feedInfosPro?.isFavorited ?? false;
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = widget.feedInfosPro;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image with zoom
          _buildImage(feed),
          
          // Top gradient overlay
          _buildTopGradient(),
          
          // Back button
          _buildBackButton(context, mediaQuery),
          
          // Bottom info bar
          _buildBottomInfoBar(context, feed),
        ],
      ),
    );
  }

  Widget _buildImage(FeedImageItemStruct? feed) {
    // Use fullscreenUrl (9:16) for fullscreen view, fallback to imageUrl
    final imageUrl = feed?.fullscreenUrl ?? feed?.imageUrl ?? '';
    
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 3.0,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
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

  Widget _buildBottomInfoBar(BuildContext context, FeedImageItemStruct? feed) {
    if (feed == null) return const SizedBox.shrink();

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pro info row
                Row(
                  children: [
                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        imageUrl: feed.proAvatarUrl,
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
                          // Name row with favorite
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  feed.proFullName,
                                  style: LynewedTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Favorite button - Only visible for Brides (not Pros)
                              if (FFAppState().currentUserRole == UserRole.bride)
                                GestureDetector(
                                  onTap: _model.isLoadingFav ? null : _toggleFavorite,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: _model.isLoadingFav
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: LynewedColors.textSecondary,
                                            ),
                                          )
                                        : Icon(
                                            _model.fav
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _model.fav
                                                ? LynewedColors.textPrimary
                                                : LynewedColors.textSecondary,
                                            size: 22,
                                          ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Profession and location row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  feed.proProfession?.name ?? '',
                                  style: LynewedTextStyles.bodySmall.copyWith(
                                    color: LynewedColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                feed.proLocationLabel,
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
                const SizedBox(height: 16),
                
                // View Profile button
                LynewedButton(
                  text: 'View Profile',
                  onPressed: _isLoadingProfile ? null : _navigateToProfile,
                  isLoading: _isLoadingProfile,
                  type: LynewedButtonType.primary,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final feed = widget.feedInfosPro;
    if (feed == null) return;

    // Optimistic update
    safeSetState(() => _model.fav = !_model.fav);
    _model.isLoadingFav = true;
    safeSetState(() {});

    try {
      final newStatus = await actions.toggleWishlistAction(feed.proProfileId);
      
      if (newStatus != null) {
        _model.fav = newStatus;
      } else {
        // Revert on error
        _model.fav = !_model.fav;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Action not possible. Please log in.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Revert on error
      _model.fav = !_model.fav;
    } finally {
      _model.isLoadingFav = false;
      if (mounted) safeSetState(() {});
    }
  }

  Future<void> _navigateToProfile() async {
    final feed = widget.feedInfosPro;
    if (feed == null) return;

    setState(() => _isLoadingProfile = true);

    try {
      final proDetails = await actions.getProItemDetailsAction(feed.proProfileId);
      
      if (mounted && proDetails != null) {
        context.pushNamed(
          ProDetailsWidget.routeName,
          queryParameters: {
            'proDetails': serializeParam(proDetails, ParamType.DataStruct),
          }.withoutNulls,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }
}
