/// Alert details sheet widget
/// 
/// Clean, modern sheet for displaying alert details.
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
import '../../domain/entities/alert_details.dart';

/// Alert details bottom sheet
/// 
/// Layout:
/// - Header: Alert type icon + Title + Status badge
/// - About section: Location & Time info + Message
/// - Author section (if not own alert)
/// - Action buttons: Delete (own) or Help (other)
class AlertDetailsSheet extends StatelessWidget {
  const AlertDetailsSheet({
    super.key,
    required this.details,
    this.onHelp,
    this.onViewAuthorProfile,
    this.onDelete,
  });

  final AlertDetails details;
  final VoidCallback? onHelp;
  final VoidCallback? onViewAuthorProfile;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return LynewedDetailsSheet(
      headerIcon: _getAlertTypeIcon(details.alertType),
      headerIconColor: LynewedColors.primary,
      titleWidget: _buildHeaderTitleRow(),
      subtitle: _buildHeaderSubtitleRow(),
      actions: _buildActionButtons(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section with location, time, and message
          _buildAboutSection(),
          
          // Author info (only for other's alerts)
          if (!details.isOwn)
            _buildAuthorSection(),
        ],
      ),
    );
  }

  /// Header title row: Title + Status badge
  Widget _buildHeaderTitleRow() {
    final isActive = details.isActive;
    
    return Row(
      children: [
        Expanded(
          child: Text(
            details.alertType.displayName,
            style: LynewedTextStyles.sheetTitle.copyWith(
              color: LynewedColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive 
                ? LynewedColors.success.withValues(alpha: 0.1) 
                : LynewedColors.gray200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isActive ? 'Active' : 'Expired',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: isActive ? LynewedColors.success : LynewedColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Header subtitle row: Description + Time remaining
  Widget _buildHeaderSubtitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            details.alertType.description,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Time remaining (aligned with status badge)
        if (details.timeRemaining != null && details.isActive) ...[  
          const SizedBox(width: 8),
          Text(
            details.timeRemaining!,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// About section: Location, Time, Message
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text('Details', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          
          // Location & Time inline
          Row(
            children: [
              // Location
              if (details.locationLabel != null) ...[
                LynewedInfoRow(
                  icon: Icons.location_on_outlined,
                  text: details.locationLabel!,
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 16,
                  color: LynewedColors.gray200,
                ),
                const SizedBox(width: 10),
              ],
              
              // Time
              if (details.startAt != null)
                LynewedInfoRow(
                  icon: Icons.schedule_outlined,
                  text: _formatDateTime(details.startAt!),
                ),
            ],
          ),
          
          // Message (if different from title)
          if (details.message?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              details.message!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Author section with avatar and info
  Widget _buildAuthorSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Posted by', style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          
          Material(
            color: LynewedColors.background,
            borderRadius: BorderRadius.circular(4),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onViewAuthorProfile,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: LynewedColors.gray200),
                ),
                child: Row(
                  children: [
                    // Author avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: LynewedColors.gray100,
                      backgroundImage: details.authorAvatarUrl != null
                          ? CachedNetworkImageProvider(details.authorAvatarUrl!)
                          : null,
                      child: details.authorAvatarUrl == null
                          ? Text(
                              _getInitials(details.authorFullName ?? '?'),
                              style: LynewedTextStyles.labelMedium.copyWith(
                                color: LynewedColors.textSecondary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Author info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.authorFullName ?? 'Unknown',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (details.authorProfession != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.work_outline,
                                  size: 14,
                                  color: LynewedColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  details.authorProfession!.displayName,
                                  style: LynewedTextStyles.bodySmall.copyWith(
                                    color: LynewedColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    // Chevron
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
    if (details.isOwn) {
      // Own alert - show red filled delete button
      return LynewedButton(
        text: 'Delete Alert',
        onPressed: onDelete,
        type: LynewedButtonType.destructiveFilled,
        icon: Icons.delete_outline,
        width: double.infinity,
      );
    }
    
    // Other's alert - show black primary button to help
    final canHelp = details.isContactable && details.isActive;
    return LynewedButton(
      text: details.isActive
          ? (canHelp ? 'I Can Help' : 'Not Available')
          : 'Alert Expired',
      onPressed: canHelp ? onHelp : null,
      type: LynewedButtonType.primary,
      icon: Icons.handshake_outlined,
      width: double.infinity,
    );
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return Icons.person_add;
      case AlertType.gearEmergency:
        return Icons.camera_alt;
      case AlertType.teamMember:
        return Icons.group_add;
      case AlertType.emergencyHelp:
        return Icons.warning;
      case AlertType.other:
        return Icons.notifications;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
