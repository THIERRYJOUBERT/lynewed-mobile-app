/// Alert details sheet widget
/// 
/// Clean, modern sheet for displaying alert details.
/// Replaces FlutterFlow's InfoAlertItemSheetWidget.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert type header
                _buildAlertTypeHeader(context),
                const SizedBox(height: 16),
                
                // Title and message
                _buildTitleAndMessage(context),
                const SizedBox(height: 16),
                
                // Location
                if (details.locationLabel != null)
                  _buildLocationRow(context),
                
                // Time info
                _buildTimeInfo(context),
                const SizedBox(height: 16),
                
                // Author info
                _buildAuthorInfo(context),
                const SizedBox(height: 20),
                
                // Action buttons
                _buildActionButtons(context),
              ],
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

  Widget _buildAlertTypeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getAlertTypeColor(details.alertType);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAlertTypeIcon(details.alertType),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.alertType.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  details.alertType.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = details.isActive;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Expired',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isActive ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTitleAndMessage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.displayTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (details.message?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            details.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
        ],
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Start time
        if (details.startAt != null) ...[
          Icon(
            Icons.schedule_outlined,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(details.startAt!),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        
        // Time remaining
        if (details.timeRemaining != null) ...[
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: details.isActive
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              details.timeRemaining!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: details.isActive ? Colors.orange : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onViewAuthorProfile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Author avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: details.authorAvatarUrl != null
                  ? CachedNetworkImageProvider(details.authorAvatarUrl!)
                  : null,
              child: details.authorAvatarUrl == null
                  ? Text(
                      _getInitials(details.authorFullName ?? '?'),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (details.authorProfession != null)
                    Text(
                      details.authorProfession!.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
            
            // Own badge
            if (details.isOwn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your alert',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    if (details.isOwn) {
      // Own alert - show delete button
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onDelete,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
      child: FilledButton.icon(
        onPressed: details.isContactable && details.isActive ? onHelp : null,
        style: FilledButton.styleFrom(
          backgroundColor: _getAlertTypeColor(details.alertType),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
        return Colors.orange;
      case AlertType.gearEmergency:
        return Colors.red;
      case AlertType.teamMember:
        return Colors.purple;
      case AlertType.emergencyHelp:
        return Colors.pink;
      case AlertType.other:
        return Colors.blue;
    }
  }

  IconData _getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.backupNeeded:
        return Icons.person_add_outlined;
      case AlertType.gearEmergency:
        return Icons.camera_outlined;
      case AlertType.teamMember:
        return Icons.group_add_outlined;
      case AlertType.emergencyHelp:
        return Icons.warning_amber_outlined;
      case AlertType.other:
        return Icons.help_outline;
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
