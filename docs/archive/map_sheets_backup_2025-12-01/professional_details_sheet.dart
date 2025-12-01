/// Professional details sheet widget
/// 
/// Clean, modern sheet for displaying professional details.
/// Replaces FlutterFlow's InfoProItemSheetWidget.
/// Uses Lynewed Design System for consistent styling.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '../../domain/entities/professional_details.dart';

/// Professional details bottom sheet
class ProfessionalDetailsSheet extends StatelessWidget {
  const ProfessionalDetailsSheet({
    super.key,
    required this.details,
    this.onContact,
    this.onFavoriteToggle,
    this.onViewProfile,
    this.showFavoriteButton = true, // Only show for brides
  });

  final ProfessionalDetails details;
  final VoidCallback? onContact;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onViewProfile;
  /// Whether to show the favorite button (only for brides, not for pros)
  final bool showFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          _buildHandleBar(),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                LynewedSpacing.xl, // Increased padding
                0,
                LynewedSpacing.xl, // Increased padding
                LynewedSpacing.xl, // Increased padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and name
                  _buildHeader(),
                  LynewedGap.verticalLg,
                  
                  // Profession and tier badge
                  _buildProfessionRow(),
                  LynewedGap.verticalLg,
                  
                  // Location and distance
                  if (details.locationLabel != null)
                    _buildLocationRow(),
                  
                  // Budget range
                  _buildBudgetRow(),
                  LynewedGap.verticalLg,
                  
                  // Description
                  if (details.description?.isNotEmpty == true)
                    _buildDescription(),
                  
                  // Portfolio preview
                  if (details.hasPortfolio)
                    _buildPortfolioPreview(),
                  
                  // Social links
                  if (details.hasSocialLinks)
                    _buildSocialLinks(),
                  
                  LynewedGap.verticalXl,
                  
                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: LynewedSpacing.md),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        Hero(
          tag: 'pro_avatar_${details.id}',
          child: CircleAvatar(
            radius: 36,
            backgroundColor: LynewedColors.gray100,
            backgroundImage: details.avatarUrl != null
                ? CachedNetworkImageProvider(details.avatarUrl!)
                : null,
            child: details.avatarUrl == null
                ? Text(
                    _getInitials(details.fullName),
                    style: LynewedTextStyles.titleLarge.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  )
                : null,
          ),
        ),
        LynewedGap.horizontalLg,
        
        // Name and business
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.displayName,
                style: LynewedTextStyles.sheetTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (details.businessName != null && details.businessName != details.fullName)
                Text(
                  details.fullName,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        
        // Favorite button (only for brides)
        if (showFavoriteButton)
          IconButton(
            onPressed: onFavoriteToggle,
            icon: Icon(
              details.isFavorited ? Icons.favorite : Icons.favorite_border,
              color: details.isFavorited ? LynewedColors.error : LynewedColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildProfessionRow() {
    return Row(
      children: [
        // Profession chip
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: LynewedSpacing.md,
            vertical: LynewedSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: LynewedColors.primary,
            borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
          ),
          child: Text(
            details.profession.displayName,
            style: LynewedTextStyles.labelMedium.copyWith(
              color: LynewedColors.textOnPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        LynewedGap.horizontalSm,
        
        // Subscription tier badge
        if (details.subscriptionTier != SubscriptionTier.inactive)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.sm,
              vertical: LynewedSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: _getTierColor(details.subscriptionTier).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
              border: Border.all(
                color: _getTierColor(details.subscriptionTier),
                width: 1,
              ),
            ),
            child: Text(
              details.subscriptionTier.displayName,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: _getTierColor(details.subscriptionTier),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        // Live indicator
        if (details.isLive) ...[
          LynewedGap.horizontalSm,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.sm,
              vertical: LynewedSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: LynewedColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: LynewedColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                LynewedGap.horizontalXxs,
                Text(
                  'Live',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationRow() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18,
            color: LynewedColors.textSecondary,
          ),
          LynewedGap.horizontalSm,
          Expanded(
            child: Text(
              details.locationLabel!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (details.distanceFormatted != null)
            Text(
              details.distanceFormatted!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow() {
    return Row(
      children: [
        Icon(
          Icons.euro_outlined,
          size: 18,
          color: LynewedColors.textSecondary,
        ),
        LynewedGap.horizontalSm,
        Text(
          details.budgetRange,
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: LynewedTextStyles.sectionTitle,
          ),
          LynewedGap.verticalSm,
          Text(
            details.description!,
            style: LynewedTextStyles.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioPreview() {
    final images = details.portfolioImages.take(4).toList();
    
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Portfolio',
                style: LynewedTextStyles.sectionTitle,
              ),
              if (details.portfolioImages.length > 4)
                TextButton(
                  onPressed: onViewProfile,
                  style: LynewedComponentStyles.textButton(),
                  child: Text('View all (${details.portfolioImages.length})'),
                ),
            ],
          ),
          LynewedGap.verticalSm,
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => LynewedGap.horizontalSm,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: LynewedColors.gray100,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: LynewedColors.gray100,
                      child: Icon(Icons.broken_image, color: LynewedColors.textSecondary),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.lg),
      child: Row(
        children: [
          if (details.instagramUrl != null)
            _SocialButton(
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              onTap: () => _launchUrl(details.instagramUrl!),
            ),
          if (details.websiteUrl != null) ...[
            if (details.instagramUrl != null) LynewedGap.horizontalMd,
            _SocialButton(
              icon: Icons.language,
              label: 'Website',
              onTap: () => _launchUrl(details.websiteUrl!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // View profile button
        Expanded(
          child: OutlinedButton(
            onPressed: onViewProfile,
            style: LynewedComponentStyles.secondaryButton(),
            child: const Text('View Profile'),
          ),
        ),
        LynewedGap.horizontalMd,
        
        // Contact button
        Expanded(
          child: ElevatedButton(
            onPressed: details.canBeContactedByBride ? onContact : null,
            style: LynewedComponentStyles.primaryButton(),
            child: Text(
              details.canBeContactedByBride ? 'Contact' : 'Not Available',
            ),
          ),
        ),
      ],
    );
  }

  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.ultimateAccess:
        return LynewedColors.primary; // Black for ultimate
      case SubscriptionTier.premiumVisibility:
        return LynewedColors.primary; // Black for premium
      case SubscriptionTier.earlyAccess:
        return LynewedColors.textSecondary; // Gray for early
      case SubscriptionTier.trial:
        return LynewedColors.gray100;
      case SubscriptionTier.inactive:
        return LynewedColors.gray100;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: LynewedColors.gray200,
          ),
          borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: LynewedColors.textPrimary),
            LynewedGap.horizontalXs,
            Text(label, style: LynewedTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}
