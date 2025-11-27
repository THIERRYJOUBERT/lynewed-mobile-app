/// Wedding details sheet widget
/// 
/// Clean, modern sheet for displaying wedding details.
/// Replaces FlutterFlow's InfoWeddingPinSheetWidget.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                // Wedding header with heart icon
                _buildWeddingHeader(context),
                const SizedBox(height: 16),
                
                // Event date
                if (details.eventDate != null)
                  _buildEventDateRow(context),
                
                // Location
                if (details.locationLabel != null)
                  _buildLocationRow(context),
                
                // Budget range
                _buildBudgetRow(context),
                const SizedBox(height: 16),
                
                // Professions needed
                if (details.hasProfessionsNeeded)
                  _buildProfessionsNeeded(context),
                
                // Search radius
                if (details.radiusFormatted != null)
                  _buildSearchRadius(context),
                
                // Guest count
                if (details.guestCount != null)
                  _buildGuestCount(context),
                
                const SizedBox(height: 16),
                
                // Bride info
                _buildBrideInfo(context),
                const SizedBox(height: 20),
                
                // Action button
                _buildActionButton(context),
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

  Widget _buildWeddingHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.pink,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wedding',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
                if (details.daysUntilWedding != null)
                  Text(
                    details.isPast
                        ? 'Wedding has passed'
                        : '${details.daysUntilWedding} days to go',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: details.isPast
                          ? Colors.grey
                          : Colors.pink.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: details.isUpcoming
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              details.isUpcoming ? 'Upcoming' : 'Past',
              style: theme.textTheme.labelSmall?.copyWith(
                color: details.isUpcoming ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDateRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.event_outlined,
            size: 18,
            color: Colors.pink.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            details.eventDateFormatted!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.pink.shade700,
            ),
          ),
        ],
      ),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildProfessionsNeeded(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Looking for',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: details.professionsNeeded.map((profession) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profession.displayName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRadius(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.radar_outlined,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Search radius: ${details.radiusFormatted}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCount(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '${details.guestCount} guests',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBrideInfo(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onViewBrideProfile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Bride avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.pink.shade100,
              backgroundImage: details.brideAvatarUrl != null
                  ? CachedNetworkImageProvider(details.brideAvatarUrl!)
                  : null,
              child: details.brideAvatarUrl == null
                  ? Icon(
                      Icons.person,
                      color: Colors.pink.shade400,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Wedding organizer',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: details.isContactable && details.isUpcoming ? onContact : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
