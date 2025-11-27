/// MarkerDetailsSheet - Bottom sheet showing marker details on tap
/// 
/// Unified component for all marker types (professional, alert, wedding).
library;

import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// Sheet affichant les détails d'un marqueur
class MarkerDetailsSheet extends StatelessWidget {
  const MarkerDetailsSheet({
    super.key,
    required this.marker,
    this.onViewProfile,
    this.onContact,
    this.onClose,
  });

  final MapMarker marker;
  final VoidCallback? onViewProfile;
  final VoidCallback? onContact;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          _buildHandle(),

          // Content based on marker type
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildContent(context),
          ),

          // Actions
          _buildActions(context),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (marker.type) {
      case MapMarkerType.professional:
      case MapMarkerType.proFixedLocation:
        return _buildProfessionalContent(context);
      case MapMarkerType.professionalAlert:
        return _buildAlertContent(context);
      case MapMarkerType.wedding:
        return _buildWeddingContent(context);
      case MapMarkerType.poiPrivate:
        return _buildPoiContent(context);
    }
  }

  Widget _buildProfessionalContent(BuildContext context) {
    final name = marker.style.label ?? marker.metadata['full_name'] ?? 'Professional';
    final profession = marker.metadata['profession'] as String?;
    final avatarUrl = marker.style.avatarUrl;

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 32,
          backgroundColor: _parseColor(marker.style.borderColorHex),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? const Icon(Icons.person, size: 32, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 16),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (profession != null)
                Text(
                  _formatProfession(profession),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatLocation(),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Type badge
        _buildTypeBadge(context),
      ],
    );
  }

  Widget _buildAlertContent(BuildContext context) {
    final title = marker.style.label ?? 'Community Alert';
    final alertType = marker.metadata['alert_type'] as String?;
    final eventDate = marker.metadata['event_date'] as String?;
    final proName = marker.metadata['professional_name'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _alertIcon(alertType),
                color: Colors.orange.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (alertType != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatAlertType(alertType),
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (proName != null)
          _buildInfoRow(Icons.person, 'Posted by $proName'),
        if (eventDate != null)
          _buildInfoRow(Icons.event, 'Event: $eventDate'),
      ],
    );
  }

  Widget _buildWeddingContent(BuildContext context) {
    final venueName = marker.style.label ?? marker.metadata['venue_name'] ?? 'Wedding';
    final brideName = marker.metadata['bride_name'] as String?;
    final eventDate = marker.metadata['event_date'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.pink.shade400,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venueName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (brideName != null)
                    Text(
                      brideName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (eventDate != null)
          _buildInfoRow(Icons.calendar_today, eventDate),
        _buildInfoRow(Icons.location_on, _formatLocation()),
      ],
    );
  }

  Widget _buildPoiContent(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.place,
            color: Colors.purple.shade400,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marker.style.label ?? 'Private Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                _formatLocation(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final isFixedLocation = marker.type == MapMarkerType.proFixedLocation;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFixedLocation ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isFixedLocation ? 'Studio' : 'Mobile',
        style: TextStyle(
          color: isFixedLocation ? Colors.green.shade700 : Colors.blue.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // View profile button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewProfile,
              icon: const Icon(Icons.person_outline, size: 18),
              label: const Text('View Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Contact button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onContact,
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(_contactButtonLabel()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _contactButtonLabel() {
    switch (marker.type) {
      case MapMarkerType.professional:
      case MapMarkerType.proFixedLocation:
        return 'Contact';
      case MapMarkerType.professionalAlert:
        return 'I Can Help';
      case MapMarkerType.wedding:
        return 'Request';
      case MapMarkerType.poiPrivate:
        return 'Details';
    }
  }

  String _formatLocation() {
    return '${marker.position.latitude.toStringAsFixed(4)}, ${marker.position.longitude.toStringAsFixed(4)}';
  }

  String _formatProfession(String profession) {
    // Convert PHOTOGRAPHER → Photographer
    return profession.toLowerCase().split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatAlertType(String type) {
    switch (type.toLowerCase()) {
      case 'backup_needed':
        return 'Backup Needed';
      case 'gear_emergency':
        return 'Gear Emergency';
      case 'team_member':
        return 'Team Member';
      case 'emergency_help':
        return 'Emergency Help';
      default:
        return type;
    }
  }

  IconData _alertIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'backup_needed':
        return Icons.person_add;
      case 'gear_emergency':
        return Icons.camera_alt;
      case 'team_member':
        return Icons.group_add;
      case 'emergency_help':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      final colorHex = hex.replaceFirst('#', '');
      return Color(int.parse('FF$colorHex', radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }
}
