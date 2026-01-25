/// Feed Detail Page - Professional portfolio detail view
///
/// Displays a professional's full portfolio with contact options.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/feed_professional.dart';
import '../widgets/portfolio_grid.dart';

/// Feed Detail Page
class FeedDetailPage extends StatelessWidget {
  const FeedDetailPage({
    super.key,
    required this.professional,
    required this.onFavoriteToggle,
    this.onContact,
    this.onItemTap,
  });

  /// The professional to display.
  final FeedProfessional professional;

  /// Callback when favorite button is tapped.
  final VoidCallback onFavoriteToggle;

  /// Callback when contact button is tapped.
  final VoidCallback? onContact;

  /// Callback when a portfolio item is tapped.
  final void Function(int index)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(),
                    _buildPortfolioSection(),
                  ],
                ),
              ),
            ),
            if (onContact != null) _buildContactButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: LynewedColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              professional.displayName,
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              professional.isFavorited ? Icons.favorite : Icons.favorite_border,
              color: professional.isFavorited
                  ? LynewedColors.error
                  : LynewedColors.textPrimary,
            ),
            onPressed: onFavoriteToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LynewedColors.gray200,
            ),
            clipBehavior: Clip.antiAlias,
            child: professional.avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: professional.avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Icon(
                      Icons.person,
                      size: 40,
                      color: LynewedColors.gray300,
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 40,
                      color: LynewedColors.gray300,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: LynewedColors.gray300,
                  ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.displayName,
                  style: LynewedTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  professional.displayProfession,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${professional.portfolioCount} photos',
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

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'PORTFOLIO',
            style: LynewedTextStyles.sectionTitle,
          ),
        ),
        const SizedBox(height: 12),
        PortfolioGrid(
          items: professional.portfolioItems,
          onItemTap: (item) {
            final index = professional.portfolioItems.indexOf(item);
            onItemTap?.call(index);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          spacing: 4,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          emptyMessage: 'No portfolio images yet',
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LynewedButton(
        text: 'Contact',
        onPressed: onContact,
        width: double.infinity,
      ),
    );
  }
}
