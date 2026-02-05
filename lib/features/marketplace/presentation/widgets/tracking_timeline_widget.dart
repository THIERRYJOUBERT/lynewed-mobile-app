/// Widget for displaying a shipment tracking timeline.
///
/// Shows a vertical timeline of tracking events with colored dots
/// based on event type and formatted timestamps.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/design/design.dart';
import '../../domain/entities/tracking_event.dart';

/// Displays a shipment tracking timeline.
///
/// Each event is shown with a colored dot, description, location,
/// and formatted timestamp. Colors vary by event type:
/// - delivered: success (green)
/// - out_for_delivery: primary (black)
/// - in_transit/picked_up: info blue (gray100)
/// - exception: error (red)
/// - default: gray300
class TrackingTimelineWidget extends StatelessWidget {
  /// Tracking events to display (ordered by timestamp).
  final List<TrackingEvent> events;

  /// Callback when the refresh button is tapped.
  final VoidCallback? onRefresh;

  const TrackingTimelineWidget({
    required this.events,
    this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        ...events.reversed.map(_buildTimelineItem),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Tracking',
          style: LynewedTextStyles.titleSmall.copyWith(
            color: LynewedColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (onRefresh != null)
          LynewedIconButton(
            icon: const Icon(
              Icons.refresh,
              size: 20,
              color: LynewedColors.textSecondary,
            ),
            onPressed: onRefresh,
            buttonSize: 40,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(TrackingEvent event) {
    final color = _getColorForEventType(event.eventType);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: LynewedColors.border,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: LynewedTextStyles.titleSmall.copyWith(
                    color: LynewedColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.location!,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(event.timestamp),
                  style: LynewedTextStyles.bodySmall.copyWith(
                    color: LynewedColors.gray300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: LynewedColors.gray300,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'No Tracking Events Yet',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Tracking information will appear once the package is shipped.',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate color for the event type.
  Color _getColorForEventType(String eventType) {
    switch (eventType) {
      case 'delivered':
        return LynewedColors.success;
      case 'out_for_delivery':
        return LynewedColors.primary;
      case 'in_transit':
      case 'picked_up':
        return LynewedColors.gray100;
      case 'exception':
        return LynewedColors.error;
      default:
        return LynewedColors.gray300;
    }
  }
}
