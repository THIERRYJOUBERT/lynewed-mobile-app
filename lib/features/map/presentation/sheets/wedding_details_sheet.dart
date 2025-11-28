/// Wedding details sheet widget
/// 
/// Clean, modern sheet for displaying wedding details.
/// Replaces FlutterFlow's InfoWeddingPinSheetWidget.
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
    this.onContact,
    this.onViewBrideProfile,
  });

  final WeddingDetails details;
  final VoidCallback? onContact;
  final VoidCallback? onViewBrideProfile;

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
                if (details.locationLabel != null)
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
                
                // Guest count
                if (details.guestCount != null)
                  _buildGuestCount(),
                
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
                style: LynewedTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
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
            borderRadius: BorderRadius.circular(12),
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
              details.locationLabel!,
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
            style: LynewedTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
                  borderRadius: BorderRadius.circular(20),
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

  Widget _buildGuestCount() {
    return Padding(
      padding: EdgeInsets.only(bottom: LynewedSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            size: 18,
            color: LynewedColors.textSecondary,
          ),
          LynewedGap.horizontalSm,
          Text(
            '${details.guestCount} guests',
            style: LynewedTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBrideInfo() {
    return Container(
      padding: EdgeInsets.all(LynewedSpacing.md),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LynewedColors.border),
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
                  style: LynewedTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: details.isContactable && details.isUpcoming ? onContact : null,
        style: LynewedComponentStyles.primaryButton(),
        icon: const Icon(Icons.mail_outline),
        label: Text(
          details.isUpcoming
              ? (details.isContactable ? 'Request Contact' : 'Not Available')
              : 'Wedding Passed',
        ),
      ),
    );
  }
}
