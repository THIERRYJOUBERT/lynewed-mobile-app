/// Wedding summary card widget for the home page.
///
/// Displays a compact summary of the bride's wedding with:
/// - Countdown to wedding day
/// - Venue information
/// - Cover image (if available)
/// - "No wedding" state with CTA when no wedding exists
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '/features/my_wedding/domain/entities/wedding_overview.dart';

/// A card showing wedding summary information.
///
/// When [wedding] is provided, shows countdown, date, and venue.
/// When [wedding] is null, shows an empty state with CTA to create wedding.
/// When [isLoading] is true, shows a loading indicator.
class WeddingSummaryCard extends StatelessWidget {
  /// The wedding data to display.
  final WeddingOverview? wedding;

  /// Whether the data is currently loading.
  final bool isLoading;

  /// Callback when the card is tapped (navigates to wedding details).
  final VoidCallback onTap;

  /// Callback when the create wedding CTA is tapped.
  final VoidCallback onCreateWeddingTap;

  /// Creates a wedding summary card.
  const WeddingSummaryCard({
    required this.onTap,
    required this.onCreateWeddingTap,
    this.wedding,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (wedding == null) {
      return _buildEmptyState();
    }

    return _buildWeddingCard();
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: onCreateWeddingTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: LynewedColors.gray200,
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration_outlined,
              size: 40.0,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Plan your wedding',
              style: LynewedTextStyles.headlineSmall.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Create your wedding to start planning',
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            LynewedButton(
              text: 'Create Wedding',
              onPressed: onCreateWeddingTap,
              type: LynewedButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeddingCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: LynewedColors.primary,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          children: [
            // Left: Countdown badge
            if (wedding!.daysUntilWedding != null) ...[
              Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                  child: Text(
                    'J-${wedding!.daysUntilWedding}',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
            ],
            // Center: Wedding info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wedding!.name ?? 'My Wedding',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (wedding!.eventDate != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      DateFormat('MMMM d, yyyy').format(wedding!.eventDate!),
                      style: LynewedTextStyles.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                  if (wedding!.venueAddress != null) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 13.0,
                        ),
                        const SizedBox(width: 3.0),
                        Expanded(
                          child: Text(
                            wedding!.venueAddress!,
                            style: LynewedTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Right: Chevron
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
