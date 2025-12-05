/// Alert Item Widget for Dashboard Pro
/// 
/// Compact card displaying alert information in a horizontal carousel.
/// Refactored with Design System v3 for improved UI/UX.
/// 
/// DESIGN SYSTEM v3 APPLIED:
/// - FontWeight max w500 (except CTAs)
/// - Border radius 4px for cards
/// - LynewedColors, LynewedTextStyles tokens
/// - Touch targets 44px minimum
/// - Spacing: 10px label→content, 30px between sections
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '/core/design/design.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';

/// Alert type enum for display purposes
enum AlertDisplayType {
  backupNeeded,
  gearEmergency,
  teamMember,
  emergencyHelp,
  other;

  factory AlertDisplayType.fromCode(String? code) {
    switch (code?.toLowerCase()) {
      case 'backup_needed':
        return AlertDisplayType.backupNeeded;
      case 'gear_emergency':
        return AlertDisplayType.gearEmergency;
      case 'team_member':
        return AlertDisplayType.teamMember;
      case 'emergency_help':
        return AlertDisplayType.emergencyHelp;
      default:
        return AlertDisplayType.other;
    }
  }

  String get displayName {
    switch (this) {
      case AlertDisplayType.backupNeeded:
        return 'Backup Needed';
      case AlertDisplayType.gearEmergency:
        return 'Gear Emergency';
      case AlertDisplayType.teamMember:
        return 'Team Member';
      case AlertDisplayType.emergencyHelp:
        return 'Emergency Help';
      case AlertDisplayType.other:
        return 'Alert';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertDisplayType.backupNeeded:
        return Icons.person_search_outlined;
      case AlertDisplayType.gearEmergency:
        return Icons.camera_alt_outlined;
      case AlertDisplayType.teamMember:
        return Icons.groups_outlined;
      case AlertDisplayType.emergencyHelp:
        return Icons.warning_amber_rounded;
      case AlertDisplayType.other:
        return Icons.notifications_none_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case AlertDisplayType.emergencyHelp:
        return LynewedColors.error;
      case AlertDisplayType.gearEmergency:
        return const Color(0xFFFF9500); // Orange
      case AlertDisplayType.backupNeeded:
        return const Color(0xFF007AFF); // Blue
      case AlertDisplayType.teamMember:
        return LynewedColors.success;
      case AlertDisplayType.other:
        return LynewedColors.textSecondary;
    }
  }
}

/// Compact alert card for horizontal carousel
/// 
/// Layout (optimized for ~160px height):
/// ```
/// ┌─────────────────────────────────────────────┐
/// │ [Type Badge]              [Time Remaining]  │
/// │                                             │
/// │ [Avatar] Author Name                        │
/// │          Profession                         │
/// │                                             │
/// │ "Message preview text..."                   │
/// │                                             │
/// │ [📍 Location]        [Action Button]        │
/// └─────────────────────────────────────────────┘
/// ```
class AlertItemWidget extends StatelessWidget {
  const AlertItemWidget({
    super.key,
    required this.alert,
    required this.onContact,
    this.onDelete,
  });

  final AlertItemDataStruct alert;
  final VoidCallback onContact;
  final VoidCallback? onDelete;

  AlertDisplayType get _alertType => AlertDisplayType.fromCode(alert.motifCode);
  bool get _isOwn => alert.isOwn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + 3 lines (name, profession, alert type) | Time remaining
          _buildHeaderRow(),
          const SizedBox(height: 10.0),
          
          // Row 2: Message preview
          if (alert.message.isNotEmpty) ...[
            _buildMessagePreview(),
            const SizedBox(height: 10.0),
          ],
          
          // Row 3: Location + Action button
          const Spacer(),
          _buildFooterRow(),
        ],
      ),
    );
  }

  /// Header: Avatar + 3 lines (name, profession, alert type) | Time remaining
  Widget _buildHeaderRow() {
    final timeInfo = _getTimeRemaining();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Avatar + 3 lines (70%)
        Expanded(
          flex: 7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (48px)
              _buildAvatar(),
              const SizedBox(width: 12.0),
              
              // 3 lines: Name, Profession, Alert type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line 1: Name
                    Text(
                      alert.authorFullName.isNotEmpty 
                          ? alert.authorFullName 
                          : 'Unknown',
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Line 2: Profession
                    if (alert.authorProfession != null)
                      Text(
                        _getProfessionDisplayName(alert.authorProfession!).toUpperCase(),
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: LynewedColors.gray300,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4.0),
                    
                    // Line 3: Alert type with icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _alertType.icon,
                          size: 14.0,
                          color: _alertType.accentColor,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            _alertType.displayName,
                            style: LynewedTextStyles.labelLarge.copyWith(
                              color: _alertType.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Right: Time remaining (30%)
        if (timeInfo.text.isNotEmpty)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                timeInfo.text,
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: timeInfo.isExpiringSoon 
                      ? LynewedColors.error 
                      : LynewedColors.gray300,
                  fontWeight: timeInfo.isExpiringSoon ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Author avatar with fallback initials (48px)
  Widget _buildAvatar() {
    final hasAvatar = alert.authorAvatarUrl.isNotEmpty;
    
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: LynewedColors.gray200,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: hasAvatar
            ? CachedNetworkImage(
                imageUrl: alert.authorAvatarUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildInitials(),
                errorWidget: (_, __, ___) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(alert.authorFullName);
    return Center(
      child: Text(
        initials,
        style: LynewedTextStyles.labelLarge.copyWith(
          color: LynewedColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Message preview (1 line max)
  Widget _buildMessagePreview() {
    return Text(
      alert.message,
      style: LynewedTextStyles.bodySmall.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Footer: Location + Action button
  Widget _buildFooterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Location
        if (alert.locationLabel.isNotEmpty)
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14.0,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    alert.locationLabel,
                    style: LynewedTextStyles.labelLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          const Spacer(),
        
        const SizedBox(width: 12.0),
        
        // Action button
        _buildActionButton(),
      ],
    );
  }

  /// Action button: Delete (own) or Help (other's)
  Widget _buildActionButton() {
    if (_isOwn) {
      // Delete button for own alerts
      return GestureDetector(
        onTap: onDelete,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: LynewedColors.error,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline,
                size: 18.0,
                color: Colors.white,
              ),
              const SizedBox(width: 6.0),
              Text(
                'Delete',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Help button for other's alerts (white on dark background)
    return GestureDetector(
      onTap: onContact,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.handshake_outlined,
              size: 18.0,
              color: LynewedColors.primary,
            ),
            const SizedBox(width: 6.0),
            Text(
              'I can help',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get time remaining info
  _TimeRemainingInfo _getTimeRemaining() {
    if (alert.endAt == null) {
      return const _TimeRemainingInfo(text: '', isExpiringSoon: false);
    }
    
    final now = DateTime.now();
    final diff = alert.endAt!.difference(now);
    
    if (diff.isNegative) {
      return const _TimeRemainingInfo(text: 'Expired', isExpiringSoon: true);
    }
    
    final isExpiringSoon = diff.inHours < 2;
    
    String text;
    if (diff.inDays > 0) {
      text = '${diff.inDays}d left';
    } else if (diff.inHours > 0) {
      text = '${diff.inHours}h left';
    } else if (diff.inMinutes > 0) {
      text = '${diff.inMinutes}m left';
    } else {
      text = 'Expiring soon';
    }
    
    return _TimeRemainingInfo(text: text, isExpiringSoon: isExpiringSoon);
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// Get profession display name
  String _getProfessionDisplayName(Profession profession) {
    // Use the enum's name and format it
    final name = profession.name;
    // Convert camelCase to Title Case with spaces
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim().split(' ').map((word) => 
      word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
    ).join(' ');
  }
}

/// Helper class for time remaining info
class _TimeRemainingInfo {
  const _TimeRemainingInfo({
    required this.text,
    required this.isExpiringSoon,
  });
  
  final String text;
  final bool isExpiringSoon;
}
