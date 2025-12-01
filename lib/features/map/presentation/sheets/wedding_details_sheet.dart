/// Wedding details sheet widget
/// 
/// Clean, modern sheet for displaying wedding details.
/// Phase 5: Updated to use new `weddings` table (hub central per bride).
/// Uses Lynewed Design System for consistent styling.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/core/design/design.dart';
import '../../domain/entities/wedding_details.dart';

/// Wedding details bottom sheet
class WeddingDetailsSheet extends StatelessWidget {
  const WeddingDetailsSheet({
    super.key,
    required this.details,
    this.userRole = 'bride',
    this.onContact,
    this.onViewBrideProfile,
    this.onEdit,
  });

  final WeddingDetails details;
  /// User role: 'bride' or 'professional'
  final String userRole;
  final VoidCallback? onContact;
  final VoidCallback? onViewBrideProfile;
  final VoidCallback? onEdit;

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
          Padding(
            padding: EdgeInsets.fromLTRB(
              LynewedSpacing.xl,
              0,
              LynewedSpacing.xl,
              LynewedSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wedding header with heart icon
                _buildWeddingHeader(),
                LynewedGap.verticalLg,
                
                // Event date
                if (details.eventDate != null)
                  _buildEventDateRow(),
                
                // Location
                if (details.venueLabel != null)
                  _buildLocationRow(),
                
                // Budget range
                _buildBudgetRow(),
                LynewedGap.verticalLg,
                
                // Professions needed
                if (details.hasProfessionsNeeded)
                  _buildProfessionsNeeded(),
                
                // Search radius
                if (details.radiusFormatted != null)
                  _buildSearchRadius(),
                
                // Status badge for own wedding
                if (details.isOwn)
                  _buildStatusBadge(),
                
                LynewedGap.verticalLg,
                
                // Bride info
                _buildBrideInfo(),
                LynewedGap.verticalXl,
                
                // Action button
                _buildActionButton(),
              ],
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

  Widget _buildWeddingHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(LynewedSpacing.md),
          decoration: BoxDecoration(
            color: LynewedColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite,
            color: LynewedColors.primary,
            size: 28,
          ),
        ),
        LynewedGap.horizontalLg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wedding',
                style: LynewedTextStyles.sheetTitle.copyWith(
                  color: LynewedColors.primary,
                ),
              ),
              if (details.daysUntilWedding != null)
                Text(
                  details.isPast
                      ? 'Wedding has passed'
                      : '${details.daysUntilWedding} days to go',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        // Status badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: LynewedSpacing.sm,
            vertical: LynewedSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: details.isUpcoming
                ? LynewedColors.success.withValues(alpha: 0.1)
                : LynewedColors.gray200,
            borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
          ),
          child: Text(
            details.isUpcoming ? 'Upcoming' : 'Past',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: details.isUpcoming ? LynewedColors.success : LynewedColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDateRow() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.event_outlined,
            size: 18,
            color: LynewedColors.textSecondary, // Changed to secondary for consistency
          ),
          LynewedGap.horizontalSm,
          Text(
            details.eventDateFormatted!,
            style: LynewedTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: LynewedColors.primary,
            ),
          ),
        ],
      ),
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
              details.venueLabel!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildProfessionsNeeded() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Looking for',
            style: LynewedTextStyles.sectionTitle,
          ),
          LynewedGap.verticalSm,
          Wrap(
            spacing: LynewedSpacing.sm,
            runSpacing: LynewedSpacing.sm,
            children: details.professionsNeeded.map((profession) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: LynewedSpacing.md,
                  vertical: LynewedSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: LynewedColors.primary,
                  borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
                ),
                child: Text(
                  profession.displayName,
                  style: LynewedTextStyles.labelMedium.copyWith(
                    color: LynewedColors.textOnPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRadius() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.radar_outlined,
            size: 18,
            color: LynewedColors.textSecondary,
          ),
          LynewedGap.horizontalSm,
          Text(
            'Search radius: ${details.radiusFormatted}',
            style: LynewedTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.md),
      child: Row(
        children: [
          Icon(
            details.isVisibleToPros ? Icons.visibility : Icons.visibility_off,
            size: 18,
            color: LynewedColors.textSecondary,
          ),
          LynewedGap.horizontalSm,
          Text(
            details.visibility.displayName,
            style: LynewedTextStyles.bodyMedium,
          ),
          LynewedGap.horizontalMd,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.sm,
              vertical: LynewedSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: LynewedColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(LynewedComponentStyles.chipBorderRadius),
            ),
            child: Text(
              details.status.displayName,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrideInfo() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Row(
        children: [
          // Bride avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: LynewedColors.primary.withValues(alpha: 0.1),
            backgroundImage: details.brideAvatarUrl != null
                ? CachedNetworkImageProvider(details.brideAvatarUrl!)
                : null,
            child: details.brideAvatarUrl == null
                ? Icon(
                    Icons.person,
                    color: LynewedColors.primary,
                  )
                : null,
          ),
          LynewedGap.horizontalMd,
          
          // Bride info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.brideName ?? 'Bride',
                  style: LynewedTextStyles.sectionTitle,
                ),
                Text(
                  'Wedding organizer',
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

  Widget _buildActionButton() {
    final isBride = userRole == 'bride';
    final isPro = userRole == 'professional';
    
    // Bride viewing own wedding: show edit button
    // Only show edit if user is bride AND it's their own wedding
    if (isBride && details.isOwn) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onEdit,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: LynewedColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LynewedComponentStyles.inputBorderRadius)),
          ),
          icon: Icon(Icons.edit, color: LynewedColors.primary),
          label: Text(
            'Edit Wedding',
            style: LynewedTextStyles.labelLarge.copyWith(color: LynewedColors.primary),
          ),
        ),
      );
    }
    
    // Pro viewing visible wedding: can request contact with bride
    if (isPro) {
      final canContact = details.isUpcoming && details.isVisibleToPros;
      
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canContact ? onContact : null,
          style: LynewedComponentStyles.primaryButton(),
          icon: const Icon(Icons.mail_outline),
          label: Text(
            details.isUpcoming
                ? (canContact ? 'Contact Bride' : 'Not Available')
                : 'Wedding Passed',
          ),
        ),
      );
    }
    
    // Fallback for other cases (bride viewing other's wedding - shouldn't happen)
    return const SizedBox.shrink();
  }
}
