/// Wedding details sheet widget
/// 
/// Clean, modern sheet for displaying wedding details.
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

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '../../domain/entities/wedding_details.dart';

/// Wedding details bottom sheet
/// 
/// Layout:
/// - Header: Heart icon + "Wedding" + Days countdown + Status badge
/// - About section: Date, Location & Budget inline
/// - Professions needed section (chips)
/// - Bride info section
/// - Action buttons: Edit (own) or Contact (pro)
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
    return LynewedDetailsSheet(
      headerIcon: Icons.favorite,
      headerIconColor: LynewedColors.primary,
      titleWidget: _buildTitleWidget(),
      subtitle: _buildHeaderSubtitle(),
      badge: _buildStatusBadge(),
      actions: _buildActionButtons(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section with date, location, budget
          _buildAboutSection(),
          
          // Professions needed section
          if (details.hasProfessionsNeeded)
            _buildProfessionsSection(),
          
          // Bride info section
          _buildBrideSection(),
        ],
      ),
    );
  }

  Widget _buildTitleWidget() {
    return Text(
      details.weddingName ?? 'Wedding',
      style: LynewedTextStyles.sheetTitle.copyWith(
        color: LynewedColors.primary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Header subtitle: Days countdown
  Widget _buildHeaderSubtitle() {
    if (details.daysUntilWedding == null) {
      return const SizedBox.shrink();
    }
    
    return Text(
      details.isPast
          ? 'Wedding has passed'
          : '${details.daysUntilWedding} days to go',
      style: LynewedTextStyles.bodyMedium.copyWith(
        color: LynewedColors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: details.isUpcoming
            ? LynewedColors.success.withValues(alpha: 0.1)
            : LynewedColors.gray200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        details.isUpcoming ? 'Upcoming' : 'Past',
        style: LynewedTextStyles.labelSmall.copyWith(
          color: details.isUpcoming ? LynewedColors.success : LynewedColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// About section: Date, Location, Budget
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text('Details', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          
          // Event date (highlighted)
          if (details.eventDate != null) ...[
            Row(
              children: [
                LynewedInfoRow(
                  icon: Icons.event_outlined,
                  text: details.eventDateFormatted!,
                  textStyle: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          
          // Location & Budget inline
          Row(
            children: [
              // Location
              if (details.venueLabel != null) ...[
                Flexible(
                  child: LynewedInfoRow(
                    icon: Icons.location_on_outlined,
                    text: details.venueLabel!,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 16,
                  color: LynewedColors.gray200,
                ),
                const SizedBox(width: 10),
              ],
              
              // Budget (uses dynamic currency icon)
              LynewedBudgetRow(
                budget: details.budgetRange,
              ),
            ],
          ),
          
          // Search radius (if available)
          if (details.radiusFormatted != null) ...[
            const SizedBox(height: 10),
            LynewedInfoRow(
              icon: Icons.radar_outlined,
              text: 'Search radius: ${details.radiusFormatted}',
            ),
          ],
          
          // Visibility (only for own wedding)
          if (details.isOwn) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                LynewedInfoRow(
                  icon: details.isVisibleToPros ? Icons.visibility : Icons.visibility_off,
                  text: details.visibility.displayName,
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: LynewedColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    details.status.displayName,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Professions needed section with chips
  Widget _buildProfessionsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Looking for', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.professionsNeeded.map((profession) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LynewedColors.primary,
                  borderRadius: BorderRadius.circular(4),
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

  /// Bride info section with avatar
  Widget _buildBrideSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Organizer', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          
          Material(
            color: LynewedColors.background,
            borderRadius: BorderRadius.circular(4),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onViewBrideProfile,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
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
                          ? Text(
                              _getInitials(details.brideName ?? 'B'),
                              style: LynewedTextStyles.labelMedium.copyWith(
                                color: LynewedColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Bride info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.brideName ?? 'Bride',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
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
                    
                    // Own badge or chevron
                    if (details.isOwn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: LynewedColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You',
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: LynewedColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.chevron_right,
                        color: LynewedColors.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isBride = userRole == 'bride';
    final isPro = userRole == 'professional';
    
    // Bride viewing own wedding: show edit button
    if (isBride && details.isOwn) {
      return LynewedButton(
        text: 'Edit Wedding',
        onPressed: onEdit,
        type: LynewedButtonType.secondary,
        icon: Icons.edit_outlined,
        width: double.infinity,
      );
    }
    
    // Pro viewing visible wedding: can request contact with bride
    if (isPro) {
      final canContact = details.isUpcoming && details.isVisibleToPros;
      
      return LynewedButton(
        text: details.isUpcoming
            ? (canContact ? 'Contact Bride' : 'Not Available')
            : 'Wedding Passed',
        onPressed: canContact ? onContact : null,
        type: LynewedButtonType.primary,
        icon: Icons.mail_outline,
        width: double.infinity,
      );
    }
    
    // Fallback
    return const SizedBox.shrink();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}
