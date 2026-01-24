import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/core/design/design.dart';
import '/index.dart';
import 'fav_pro_list_model.dart';
export 'fav_pro_list_model.dart';

/// Wishlist Page - Liste des professionnels favoris
/// 
/// Design System v3 compliant:
/// - Header avec back button et titre
/// - Subheader avec compteur
/// - Liste des pros avec avatar, infos et action favori
/// - Empty state quand pas de favoris
class FavProListWidget extends StatefulWidget {
  const FavProListWidget({super.key});

  static String routeName = 'FavProList';
  static String routePath = '/favProList';

  @override
  State<FavProListWidget> createState() => _FavProListWidgetState();
}

class _FavProListWidgetState extends State<FavProListWidget> {
  late FavProListModel _model;
  List<ProDetailsStruct> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FavProListModel());
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await actions.getFavoritedProfessionalsAction();
      
      setState(() {
        _favorites = result.cast<ProDetailsStruct>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _toggleFavorite(ProDetailsStruct pro) async {
    // Optimistic removal from list
    setState(() {
      _favorites.removeWhere((p) => p.proProfileId == pro.proProfileId);
    });

    try {
      await actions.toggleWishlistAction(pro.proProfileId);
    } catch (e) {
      // Revert on error
      await _loadFavorites();
    }
  }

  void _navigateToProfile(ProDetailsStruct pro) {
    context.pushNamed(
      ProDetailsWidget.routeName,
      queryParameters: {
        'proDetails': serializeParam(pro, ParamType.DataStruct),
      }.withoutNulls,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
            _buildSubheader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _favorites.isEmpty
                          ? _buildEmptyState()
                          : _buildFavoritesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.chevron_left,
              size: 28,
              color: LynewedColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'MY WISHLIST',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubheader() {
    final count = _favorites.length;
    final text = count == 0
        ? 'No professionals in your wishlist yet.'
        : count == 1
            ? 'You have 1 professional in your wishlist.'
            : 'You have $count professionals in your wishlist.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load wishlist',
              style: LynewedTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: LynewedColors.gray200,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: LynewedTextStyles.bodyLarge.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start exploring and add professionals\nto your wishlist!',
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pro = _favorites[index];
        return _FavoriteTile(
          pro: pro,
          onTap: () => _navigateToProfile(pro),
          onRemove: () => _toggleFavorite(pro),
        );
      },
    );
  }
}

/// Tile pour afficher un professionnel favori.
class _FavoriteTile extends StatelessWidget {
  final ProDetailsStruct pro;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteTile({
    required this.pro,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
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
                  color: LynewedColors.gray200,
                  child: const Icon(
                    Icons.person_outline,
                    color: LynewedColors.textSecondary,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 48,
                  height: 48,
                  color: LynewedColors.gray200,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    pro.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Profession
                  if (pro.profession?.name != null)
                    Text(
                      pro.profession!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 2),
                  // Location
                  if (pro.locationLabel.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: LynewedColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pro.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LynewedTextStyles.labelLarge.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Favorite button (always filled, tap to remove)
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.favorite,
                  color: LynewedColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
