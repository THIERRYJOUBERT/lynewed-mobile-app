import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '/actions/actions.dart' as action_blocks;
import '/backend/schema/structs/index.dart';
import '/core/design/design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import 'wishlist_pro_model.dart';

export 'wishlist_pro_model.dart';

/// WishlistPro Page - Liste des brides qui ont mis ce pro en favoris
/// 
/// Design System v3 compliant:
/// - Header avec back button et titre
/// - Subheader avec compteur
/// - Liste des brides avec avatar, infos et action contact
/// - Empty state quand pas de favoris
/// - Accessible uniquement pour les pros Ultimate
class WishlistProWidget extends StatefulWidget {
  const WishlistProWidget({super.key});

  static String routeName = 'WishlistPro';
  static String routePath = '/wishlistPro';

  @override
  State<WishlistProWidget> createState() => _WishlistProWidgetState();
}

class _WishlistProWidgetState extends State<WishlistProWidget> {
  late WishlistProModel _model;
  List<WishlistedByBrideItemStruct> _brides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WishlistProModel());
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadBrides();
    });
  }

  Future<void> _loadBrides() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final result = await actions.getWishlistedByBridesAction();
      
      setState(() {
        _brides = result.cast<WishlistedByBrideItemStruct>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _contactBride(WishlistedByBrideItemStruct bride) {
    action_blocks.contactChatRoom(
      context,
      targetProfileID: bride.brideProfileId,
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
                  ? const Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
                    ))
                  : _error != null
                      ? _buildError()
                      : _brides.isEmpty
                          ? _buildEmptyState()
                          : _buildBridesList(),
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
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: LynewedColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MY FANS',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubheader() {
    final count = _brides.length;
    final text = count == 0
        ? 'No brides have added you to their wishlist yet.'
        : count == 1
            ? '1 bride has added you to their wishlist.'
            : '$count brides have added you to their wishlist.';

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
              onPressed: _loadBrides,
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
              'No fans yet',
              style: LynewedTextStyles.bodyLarge.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When brides add you to their wishlist,\nthey will appear here!',
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

  Widget _buildBridesList() {
    return RefreshIndicator(
      onRefresh: _loadBrides,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _brides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final bride = _brides[index];
          return _BrideFanTile(
            bride: bride,
            onTap: () => _contactBride(bride),
          );
        },
      ),
    );
  }
}

/// Tile pour afficher une bride qui a mis le pro en favoris
class _BrideFanTile extends StatelessWidget {
  final WishlistedByBrideItemStruct bride;
  final VoidCallback onTap;

  const _BrideFanTile({
    required this.bride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = bride.contactStatus;
    final isPending = status == 'pending';
    final isAccepted = status == 'accepted';
    
    return GestureDetector(
      onTap: isPending ? null : onTap, // Disable tap if pending
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
                imageUrl: bride.avatarUrl.isNotEmpty
                    ? bride.avatarUrl
                    : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
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
            
            // Bride info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    bride.fullName.isNotEmpty ? bride.fullName : 'Bride',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Added date
                  if (bride.addedAt != null)
                    Text(
                      'Added ${dateTimeFormat(
                        "relative",
                        bride.addedAt!,
                        locale: FFLocalizations.of(context).languageCode,
                      )}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Action button based on status
            _buildActionButton(isPending, isAccepted),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isPending, bool isAccepted) {
    if (isPending) {
      // Pending state - show "Pending" badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: LynewedColors.gray200,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_empty,
              size: 14,
              color: LynewedColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Pending',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (isAccepted) {
      // Accepted - show "Chat" button
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: LynewedColors.success,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Chat',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      // No request yet - show "Contact" button
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: LynewedColors.primary,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Text(
          'Contact',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }
}
