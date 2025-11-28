/// Alert details sheet widget
/// 
/// Clean, modern sheet for displaying alert details.
/// Replaces FlutterFlow's InfoAlertItemSheetWidget.
/// Uses Lynewed Design System for consistent styling.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/core/design/design.dart';
import '../../domain/entities/alert_details.dart';

/// Alert details bottom sheet
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
                // Alert type header
                _buildAlertTypeHeader(),
                LynewedGap.verticalLg,
                
                // Title and message
                _buildTitleAndMessage(),
                LynewedGap.verticalLg,
                
                // Location
                if (details.locationLabel != null)
                  _buildLocationRow(),
                
                // Time info
                _buildTimeInfo(),
                LynewedGap.verticalLg,
                
                // Author info
                _buildAuthorInfo(),
                LynewedGap.verticalXl,
                
                // Action buttons
                _buildActionButtons(),
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

  Widget _buildAlertTypeHeader() {
    final color = _getAlertTypeColor(details.alertType);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(LynewedSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getAlertTypeIcon(details.alertType),
            color: color,
            size: 28, // Increased from 24 to match Wedding sheet
          ),
        ),
        LynewedGap.horizontalLg, // Increased from Md to match Wedding sheet
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.alertType.displayName,
                style: LynewedTextStyles.titleLarge.copyWith( // Increased from titleMedium
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                details.alertType.description,
                style: LynewedTextStyles.bodyMedium.copyWith( // Increased from bodySmall
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Status badge
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isActive = details.isActive;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LynewedSpacing.sm,
        vertical: LynewedSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? LynewedColors.success.withValues(alpha: 0.1) 
            : LynewedColors.gray200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Expired',
        style: LynewedTextStyles.labelSmall.copyWith(
          color: isActive ? LynewedColors.success : LynewedColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTitleAndMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.displayTitle,
          style: LynewedTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (details.message?.isNotEmpty == true) ...[
          LynewedGap.verticalSm,
          Text(
            details.message!,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textPrimary,
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
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      children: [
        // Start time
        if (details.startAt != null) ...[
          Icon(
            Icons.schedule_outlined,
            size: 18,
            color: LynewedColors.textSecondary,
          ),
          LynewedGap.horizontalSm,
          Text(
            _formatDateTime(details.startAt!),
            style: LynewedTextStyles.bodyMedium,
          ),
        ],
        
        // Time remaining (only for active alerts)
        if (details.timeRemaining != null && details.isActive) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: LynewedSpacing.sm,
              vertical: LynewedSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: LynewedColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              details.timeRemaining!,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuthorInfo() {
    return Material(
      color: LynewedColors.background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias, // Ensure ripple is clipped
      child: InkWell(
        onTap: onViewAuthorProfile,
        child: Container(
          padding: EdgeInsets.all(LynewedSpacing.md),
          decoration: BoxDecoration(
            // Color moved to Material widget to allow InkWell ripple effect
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LynewedColors.border),
          ),
          child: Row(
          children: [
            // Author avatar
            CircleAvatar(
              radius: 24, // Increased to match Bride avatar size in Wedding sheet
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
            LynewedGap.horizontalMd,
            
            // Author info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.authorFullName ?? 'Unknown',
                    style: LynewedTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (details.authorProfession != null)
                    Text(
                      details.authorProfession!.displayName,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            
            // Own badge
            if (details.isOwn)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: LynewedSpacing.sm,
                  vertical: LynewedSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: LynewedColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your alert',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: LynewedColors.textSecondary,
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildActionButtons() {
    if (details.isOwn) {
      // Own alert - show delete button
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onDelete,
          style: OutlinedButton.styleFrom(
            foregroundColor: LynewedColors.error,
            side: BorderSide(color: LynewedColors.error),
            minimumSize: Size(0, LynewedSpacing.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: LynewedBorders.borderRadiusNone,
            ),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Alert'),
        ),
      );
    }
    
    // Other's alert - show help button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: details.isContactable && details.isActive ? onHelp : null,
        style: LynewedComponentStyles.primaryButton(),
        icon: const Icon(Icons.handshake_outlined),
        label: Text(
          details.isActive
              ? (details.isContactable ? 'I Can Help' : 'Not Available')
              : 'Alert Expired',
        ),
      ),
    );
  }

  Color _getAlertTypeColor(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return LynewedColors.primary;
      case AlertType.gearEmergency:
        return LynewedColors.primary;
      case AlertType.teamMember:
        return LynewedColors.primary;
      case AlertType.emergencyHelp:
        return LynewedColors.primary;
      case AlertType.other:
        return LynewedColors.primary;
    }
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return Icons.person_add; // Filled version
      case AlertType.gearEmergency:
        return Icons.camera_alt; // Filled version
      case AlertType.teamMember:
        return Icons.group_add; // Filled version
      case AlertType.emergencyHelp:
        return Icons.warning; // Filled version
      case AlertType.other:
        return Icons.notifications; // Filled version, better than question mark
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
