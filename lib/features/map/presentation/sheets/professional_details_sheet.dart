/// Professional details sheet widget
/// 
/// Clean, modern sheet for displaying professional details.
/// Replaces FlutterFlow's InfoProItemSheetWidget.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/professional_details.dart';

/// Professional details bottom sheet
class ProfessionalDetailsSheet extends StatelessWidget {
  const ProfessionalDetailsSheet({
    super.key,
    required this.details,
    this.onContact,
    this.onFavoriteToggle,
    this.onViewProfile,
  });

  final ProfessionalDetails details;
  final VoidCallback? onContact;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          _buildHandleBar(colorScheme),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and name
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  
                  // Profession and tier badge
                  _buildProfessionRow(context),
                  const SizedBox(height: 16),
                  
                  // Location and distance
                  if (details.locationLabel != null)
                    _buildLocationRow(context),
                  
                  // Budget range
                  _buildBudgetRow(context),
                  const SizedBox(height: 16),
                  
                  // Description
                  if (details.description?.isNotEmpty == true)
                    _buildDescription(context),
                  
                  // Portfolio preview
                  if (details.hasPortfolio)
                    _buildPortfolioPreview(context),
                  
                  // Social links
                  if (details.hasSocialLinks)
                    _buildSocialLinks(context),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Avatar
        Hero(
          tag: 'pro_avatar_${details.id}',
          child: CircleAvatar(
            radius: 36,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: details.avatarUrl != null
                ? CachedNetworkImageProvider(details.avatarUrl!)
                : null,
            child: details.avatarUrl == null
                ? Text(
                    _getInitials(details.fullName),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        
        // Name and business
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (details.businessName != null && details.businessName != details.fullName)
                Text(
                  details.fullName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        
        // Favorite button
        IconButton(
          onPressed: onFavoriteToggle,
          icon: Icon(
            details.isFavorited ? Icons.favorite : Icons.favorite_border,
            color: details.isFavorited ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Profession chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            details.profession.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        // Subscription tier badge
        if (details.subscriptionTier != SubscriptionTier.inactive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTierColor(details.subscriptionTier).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getTierColor(details.subscriptionTier),
                width: 1,
              ),
            ),
            child: Text(
              details.subscriptionTier.displayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getTierColor(details.subscriptionTier),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        
        // Live indicator
        if (details.isLive) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              details.locationLabel!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (details.distanceFormatted != null)
            Text(
              details.distanceFormatted!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.euro_outlined,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          details.budgetRange,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            details.description!,
            style: theme.textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioPreview(BuildContext context) {
    final theme = Theme.of(context);
    final images = details.portfolioImages.take(4).toList();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Portfolio',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (details.portfolioImages.length > 4)
                TextButton(
                  onPressed: onViewProfile,
                  child: Text('View all (${details.portfolioImages.length})'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image),
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

  Widget _buildSocialLinks(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (details.instagramUrl != null)
            _SocialButton(
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              onTap: () => _launchUrl(details.instagramUrl!),
            ),
          if (details.websiteUrl != null) ...[
            if (details.instagramUrl != null) const SizedBox(width: 12),
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

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // View profile button
        Expanded(
          child: OutlinedButton(
            onPressed: onViewProfile,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Profile'),
          ),
        ),
        const SizedBox(width: 12),
        
        // Contact button
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: details.canBeContactedByBride ? onContact : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
        return Colors.purple;
      case SubscriptionTier.premiumVisibility:
        return Colors.amber.shade700;
      case SubscriptionTier.earlyAccess:
        return Colors.blue;
      case SubscriptionTier.trial:
        return Colors.grey;
      case SubscriptionTier.inactive:
        return Colors.grey;
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
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
