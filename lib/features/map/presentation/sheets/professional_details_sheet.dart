/// Professional details sheet widget
/// 
/// Clean, modern sheet for displaying professional details.
/// Refactored to use LynewedDetailsSheet widget and Design System v2.
/// 
/// DESIGN SYSTEM v2 APPLIED:
/// - FontWeight max w500 (except CTAs)
/// - Border radius 4px for chips/badges
/// - LynewedColors, LynewedTextStyles tokens
/// - Reusable widgets: LynewedDetailsSheet, LynewedButton, etc.
/// - Spacing: 10px label→content, 30px between sections
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '../../domain/entities/professional_details.dart';
import 'upcoming_travels_sheet.dart';

/// Professional details bottom sheet
/// 
/// Layout:
/// - Header: Avatar + Name + Profession (subtitle)
/// - About section: Fixed Location & Budget inline + Description
/// - Portfolio section (if available)
/// - Links section (if available)
/// - Action buttons: View Profile (secondary) + Contact (primary)
class ProfessionalDetailsSheet extends StatelessWidget {
  const ProfessionalDetailsSheet({
    super.key,
    required this.details,
    this.fixedLocation, // Add fixed location parameter
    this.onContact,
    this.onFavoriteToggle,
    this.onViewProfile,
    this.onReport,
    this.showFavoriteButton = true,
  });

  final ProfessionalDetails details;
  final String? fixedLocation; // City name from fixed location
  final VoidCallback? onContact;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onViewProfile;
  final VoidCallback? onReport;
  final bool showFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return LynewedDetailsSheet(
      headerAvatarUrl: details.avatarUrl,
      headerAvatarInitials: _getInitials(details.fullName),
      titleWidget: _buildTitleWidget(),
      subtitle: _buildHeaderSubtitle(), // Profession in header
      trailing: _buildHeaderActions(), // More menu + Favorite in header
      actions: _buildActionButtons(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section with fixed location, budget, and description
          _buildAboutSection(),
          
          // Portfolio preview
          if (details.hasPortfolio)
            _buildPortfolioPreview(),
          
          // Social links
          if (details.hasSocialLinks)
            _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Hero(
      tag: 'pro_name_${details.id}',
      child: Material(
        color: Colors.transparent,
        child: Text(
          details.displayName,
          style: LynewedTextStyles.sheetTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Header subtitle: Business name (if different) + Profession with icon
  Widget _buildHeaderSubtitle() {
    final hasBusinessName = details.businessName != null && 
                            details.businessName != details.fullName;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Business name (if different from display name)
        if (hasBusinessName) ...[
          Text(
            details.fullName,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
              fontWeight: FontWeight.w300,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        // Profession with icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.work_outline,
              size: 16,
              color: LynewedColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              details.profession.displayName,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Header actions: More menu (with report) + Favorite button
  Widget? _buildHeaderActions() {
    final hasAnyAction = showFavoriteButton || onReport != null;
    if (!hasAnyAction) return null;
    
    return LynewedHeaderActions(
      isFavorited: details.isFavorited,
      onFavoriteToggle: onFavoriteToggle,
      showFavorite: showFavoriteButton,
      menuItems: [
        if (onReport != null)
          LynewedMenuItem(
            icon: Icons.flag_outlined,
            label: 'Report',
            onTap: onReport!,
          ),
      ],
    );
  }

  /// About section: Uses reusable LynewedAboutSection widget
  Widget _buildAboutSection() {
    return LynewedAboutSection(
      location: fixedLocation, // City from fixed location marker metadata
      distance: details.distanceFormatted,
      budget: details.budgetRange,
      description: details.description,
    );
  }

  Widget _buildPortfolioPreview() {
    final images = details.portfolioImages.take(4).toList();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio',
                style: LynewedTextStyles.sectionTitle,
              ),
              if (details.portfolioImages.length > 4)
                TextButton(
                  onPressed: onViewProfile,
                  style: LynewedComponentStyles.textButton(),
                  child: Text(
                    'View all (${details.portfolioImages.length})',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.primary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                      child: const Icon(Icons.broken_image, color: LynewedColors.textSecondary),
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
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Links',
            style: LynewedTextStyles.sectionTitle,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (details.instagramUrl != null)
                _SocialLinkButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  onTap: () => _launchUrl(details.instagramUrl!),
                ),
              if (details.websiteUrl != null)
                _SocialLinkButton(
                  icon: Icons.language,
                  label: 'Website',
                  onTap: () => _launchUrl(details.websiteUrl!),
                ),
              // Upcoming Travels button - always visible
              Builder(
                builder: (context) => _SocialLinkButton(
                  icon: Icons.flight_takeoff,
                  label: 'Upcoming Travels',
                  onTap: () => UpcomingTravelsSheet.show(
                    context: context,
                    professionalName: details.displayName,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: LynewedButton(
            text: 'View Profile',
            onPressed: onViewProfile,
            type: LynewedButtonType.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LynewedButton(
            text: details.canBeContactedByBride ? 'Contact' : 'Not Available',
            onPressed: details.canBeContactedByBride ? onContact : null,
            type: LynewedButtonType.primary,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Social link button widget (no border, clean style)
class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({
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
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: LynewedColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
