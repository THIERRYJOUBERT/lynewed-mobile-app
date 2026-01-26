/// WishlistProPage - Clean Architecture
///
/// Displays the list of brides who have added this professional
/// to their wishlist. Uses Clean Architecture patterns.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/core/design/design.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/features/chat/domain/entities/entities.dart' show ContactRequestSource;

import '../../domain/entities/entities.dart';

/// Professional wishlist page displaying brides who saved this pro
class WishlistProPage extends StatefulWidget {
  const WishlistProPage({super.key})
      : initialBrides = null,
        isLoading = false,
        error = null,
        _isTestMode = false;

  /// For testing: create with predefined data
  const WishlistProPage.withTestData({
    super.key,
    this.initialBrides,
    this.isLoading = false,
    this.error,
  }) : _isTestMode = true;

  final List<WishlistBride>? initialBrides;
  final bool isLoading;
  final String? error;
  final bool _isTestMode;

  static const String routeName = 'WishlistPro';
  static const String routePath = '/wishlistPro';

  @override
  State<WishlistProPage> createState() => _WishlistProPageState();
}

class _WishlistProPageState extends State<WishlistProPage> {
  List<WishlistBride> _brides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    if (widget._isTestMode) {
      _brides = widget.initialBrides ?? [];
      _isLoading = widget.isLoading;
      _error = widget.error;
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadBrides();
      });
    }
  }

  Future<void> _loadBrides() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await actions.getWishlistedByBridesAction();

      if (!mounted) return;

      final brides = result
          .cast<WishlistedByBrideItemStruct>()
          .map(_convertToBride)
          .toList();

      setState(() {
        _brides = brides;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  WishlistBride _convertToBride(WishlistedByBrideItemStruct item) {
    return WishlistBride(
      profileId: item.brideProfileId,
      fullName: item.fullName.isNotEmpty ? item.fullName : 'Bride',
      avatarUrl: item.avatarUrl.isNotEmpty ? item.avatarUrl : null,
      addedAt: item.addedAt ?? DateTime.now(),
      contactStatus: ContactStatus.fromString(item.contactStatus),
    );
  }

  void _contactBride(WishlistBride bride) {
    action_blocks.contactChatRoom(
      context,
      targetProfileID: bride.profileId,
      source: ContactRequestSource.fromWishlist,
    );
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
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(LynewedColors.primary),
                      ),
                    )
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
            onTap: bride.canContact ? () => _contactBride(bride) : null,
          );
        },
      ),
    );
  }
}

/// Tile for displaying a bride who added the pro to their wishlist
class _BrideFanTile extends StatelessWidget {
  const _BrideFanTile({
    required this.bride,
    this.onTap,
  });

  final WishlistBride bride;
  final VoidCallback? onTap;

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
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(context)),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const defaultAvatarUrl =
        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: CachedNetworkImage(
        imageUrl: bride.hasAvatar ? bride.avatarUrl! : defaultAvatarUrl,
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
    );
  }

  Widget _buildInfo(BuildContext context) {
    // Get locale, defaulting to 'en' for tests where FFLocalizations is not available
    String locale;
    try {
      locale = FFLocalizations.of(context).languageCode;
    } catch (_) {
      locale = 'en';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bride.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Added ${dateTimeFormat("relative", bride.addedAt, locale: locale)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LynewedTextStyles.labelLarge.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (bride.isPending) {
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
    } else if (bride.isAccepted) {
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
