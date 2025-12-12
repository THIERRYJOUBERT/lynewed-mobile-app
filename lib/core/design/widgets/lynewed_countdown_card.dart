import 'package:flutter/material.dart';
import '../design.dart';

/// Wedding countdown card with cover image, name, date, and countdown
/// 
/// Design System V4:
/// - Border radius: 4px (items/chips)
/// - Image overlay with gradient for text readability
/// - Countdown badge: J-XX format
class LynewedCountdownCard extends StatelessWidget {
  const LynewedCountdownCard({
    super.key,
    required this.weddingName,
    required this.eventDate,
    this.coverImageUrl,
    this.venueLabel,
    this.participantsCount = 0,
    this.onTap,
    this.onEdit,
  });

  /// Wedding name (e.g., "Smith-Jones Wedding")
  final String weddingName;
  
  /// Event date for countdown calculation
  final DateTime eventDate;
  
  /// Optional cover image URL
  final String? coverImageUrl;
  
  /// Venue label (e.g., "Paris, France")
  final String? venueLabel;
  
  /// Number of participants in wedding team
  final int participantsCount;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  /// Callback when edit button is tapped
  final VoidCallback? onEdit;

  int get _daysUntilWedding {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final wedding = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return wedding.difference(today).inDays;
  }

  String get _countdownText {
    final days = _daysUntilWedding;
    if (days < 0) {
      return 'J+${days.abs()}';
    } else if (days == 0) {
      return 'Today!';
    } else {
      return 'J-$days';
    }
  }

  String get _formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${eventDate.day} ${months[eventDate.month - 1]} ${eventDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: LynewedColors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or placeholder
            if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
              Image.network(
                coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            
            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(LynewedSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: countdown badge + edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Countdown badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: LynewedColors.primary,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          _countdownText,
                          style: LynewedTextStyles.titleSmall.copyWith(
                            color: LynewedColors.textOnPrimary,
                          ),
                        ),
                      ),
                      // Edit button
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 18.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Bottom: wedding info
                  Text(
                    weddingName,
                    style: LynewedTextStyles.headlineMedium.copyWith(
                      color: LynewedColors.textOnDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        _formattedDate,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: LynewedColors.textOnDark.withValues(alpha: 0.9),
                        ),
                      ),
                      if (venueLabel != null && venueLabel!.isNotEmpty) ...[
                        Text(
                          ' • ',
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            color: LynewedColors.textOnDark.withValues(alpha: 0.7),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            venueLabel!,
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              color: LynewedColors.textOnDark.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (participantsCount > 0) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      '$participantsCount pro${participantsCount > 1 ? 's' : ''} in team',
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: LynewedColors.textOnDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: LynewedColors.gray200,
      child: const Center(
        child: Icon(
          Icons.diamond_outlined,
          size: 48.0,
          color: LynewedColors.gray300,
        ),
      ),
    );
  }
}
