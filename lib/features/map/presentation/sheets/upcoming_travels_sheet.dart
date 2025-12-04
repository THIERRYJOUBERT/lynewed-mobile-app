/// Upcoming Travels Sheet
/// 
/// Displays a professional's upcoming travel dates and locations.
/// Currently a stub UI - backend table not yet created.
/// 
/// DESIGN SYSTEM v3 APPLIED:
/// - LynewedSheet wrapper
/// - LynewedColors, LynewedTextStyles tokens
/// - Spacing: 30px between sections, 10px label→content
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';

/// Upcoming travels bottom sheet
/// 
/// Shows where a professional will be traveling for work.
/// Currently displays placeholder content until backend is ready.
class UpcomingTravelsSheet extends StatelessWidget {
  const UpcomingTravelsSheet({
    super.key,
    required this.professionalName,
  });

  final String professionalName;

  /// Show the sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String professionalName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpcomingTravelsSheet(
        professionalName: professionalName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Upcoming Travels',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty state placeholder
          _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LynewedColors.gray100,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.flight_takeoff,
              size: 32,
              color: LynewedColors.gray300,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'No upcoming travels',
            style: LynewedTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: LynewedColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '$professionalName hasn\'t added any upcoming travel dates yet.',
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Coming soon badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LynewedColors.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Coming soon',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Future: Travel item widget for when backend is ready
/// 
/// Will display:
/// - Location name
/// - Date range
/// - Optional notes
/// 
/// Example structure:
/// ```dart
/// class TravelItem {
///   final String id;
///   final String location;
///   final DateTime startDate;
///   final DateTime endDate;
///   final String? notes;
/// }
/// ```
