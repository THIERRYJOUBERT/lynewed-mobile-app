/// Step-based tracking timeline for the buyer's order view.
///
/// Shows a vertical timeline of all order lifecycle steps with
/// completed/current/pending states. Displays the tracking number
/// as a tappable link to FedEx tracking website.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/design/design.dart';
import '../../domain/entities/tracking_event.dart';

/// Displays a step-based tracking timeline for a buyer's order.
///
/// Each step shows:
/// - A circle indicator (filled green if completed, outlined gray if pending)
/// - A vertical line connecting steps
/// - Step label and icon
/// - Event date and location if a matching [TrackingEvent] exists
///
/// The [trackingNumber] is displayed as a tappable link that opens
/// the FedEx tracking website.
class BuyerTrackingTimeline extends StatelessWidget {
  /// Current transaction status to determine which steps are completed.
  final String currentStatus;

  /// FedEx tracking number. Shown with a link when not null.
  final String? trackingNumber;

  /// Tracking events to display dates/locations for matched steps.
  final List<TrackingEvent> events;

  const BuyerTrackingTimeline({
    required this.currentStatus,
    this.trackingNumber,
    this.events = const [],
    super.key,
  });

  /// Step IDs matching transaction status values.
  static const _stepIds = [
    'pending',
    'paid',
    'label_created',
    'shipped',
    'in_transit',
    'delivered',
    'completed',
  ];

  /// Human-readable step labels.
  static const _stepLabels = [
    'Order Placed',
    'Payment Confirmed',
    'Label Created',
    'Shipped',
    'In Transit',
    'Delivered',
    'Completed',
  ];

  /// Icons for each step.
  static const _stepIcons = [
    Icons.shopping_bag,
    Icons.payment,
    Icons.qr_code,
    Icons.local_shipping,
    Icons.flight_takeoff,
    Icons.home,
    Icons.check_circle,
  ];

  /// Date format used for event timestamps, created once per build.
  static final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stepIds.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Tracking'),
        const SizedBox(height: 10),
        if (trackingNumber != null && trackingNumber!.isNotEmpty)
          _buildTrackingNumberRow(),
        if (trackingNumber != null && trackingNumber!.isNotEmpty)
          const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Column(
            children: List.generate(_stepIds.length, (index) {
              return _buildStepItem(
                index: index,
                currentIndex: currentIndex,
                isLast: index == _stepIds.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingNumberRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: LynewedComponentStyles.cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping,
            size: 18,
            color: LynewedColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trackingNumber!,
              style: LynewedTextStyles.titleSmall.copyWith(
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: _openFedExTracking,
            child: Text(
              'Track on FedEx',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int index,
    required int currentIndex,
    required bool isLast,
  }) {
    final isCompleted = index <= currentIndex;
    final isCurrent = index == currentIndex;
    final matchingEvent = _findEventForStep(_stepIds[index]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator column.
        SizedBox(
          width: 24,
          child: Column(
            children: [
              _buildCircleIndicator(isCompleted, isCurrent),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted && !isCurrent
                      ? Colors.green
                      : LynewedColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Step content.
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _stepIcons[index],
                      size: 16,
                      color: isCompleted
                          ? LynewedColors.textPrimary
                          : LynewedColors.gray300,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _stepLabels[index],
                      style: LynewedTextStyles.titleSmall.copyWith(
                        fontSize: 14,
                        color: isCompleted
                            ? LynewedColors.textPrimary
                            : LynewedColors.gray300,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (matchingEvent != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _dateFormat.format(matchingEvent.timestamp),
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (matchingEvent.location != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      matchingEvent.location!,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.gray300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleIndicator(bool isCompleted, bool isCurrent) {
    if (isCompleted) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: isCurrent
            ? const Icon(Icons.radio_button_checked,
                size: 14, color: Colors.white)
            : const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: LynewedColors.gray300,
          width: 2,
        ),
      ),
    );
  }

  /// Finds a tracking event matching the given step ID.
  TrackingEvent? _findEventForStep(String stepId) {
    for (final event in events) {
      if (event.eventType == stepId) {
        return event;
      }
    }
    return null;
  }

  /// Opens the FedEx tracking website for the tracking number.
  Future<void> _openFedExTracking() async {
    if (trackingNumber == null) return;
    final url = Uri.parse(
      'https://www.fedex.com/fedextrack/?trknbr=$trackingNumber',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
