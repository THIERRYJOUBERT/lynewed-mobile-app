/// Reusable About section for detail sheets
/// 
/// Displays location, budget, and description with Design System v2 compliance.
/// Used in ProfessionalDetailsSheet and other detail sheets.
library;

import 'package:flutter/material.dart';
import '../design.dart';
import 'widgets.dart';

/// About section with location, budget, and description
/// 
/// Layout:
/// - Section title
/// - Location & Budget inline with vertical separator
/// - Description (optional)
class LynewedAboutSection extends StatelessWidget {
  const LynewedAboutSection({
    super.key,
    this.location,
    this.distance,
    this.budget,
    this.description,
    this.title = 'About',
    this.showLocation = true,
    this.showBudget = true,
  });

  /// Location city name (from fixed location, not profile)
  final String? location;
  
  /// Distance from user (e.g., "12km")
  final String? distance;
  
  /// Budget range (e.g., "1000-2000€")
  final String? budget;
  
  /// Description text (optional)
  final String? description;
  
  /// Section title (default: "About")
  final String title;
  
  /// Whether to show location info
  final bool showLocation;
  
  /// Whether to show budget info
  final bool showBudget;

  @override
  Widget build(BuildContext context) {
    final hasDescription = description?.isNotEmpty == true;
    final hasLocation = showLocation && location != null;
    final hasBudget = showBudget && budget != null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(title, style: LynewedTextStyles.sectionTitle),
          const SizedBox(height: 10),
          
          // Location & Budget inline
          if (hasLocation || hasBudget)
            _buildLocationBudgetRow(hasLocation, hasBudget),
          
          // Description
          if (hasDescription) ...[
            const SizedBox(height: 10),
            Text(
              description!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationBudgetRow(bool hasLocation, bool hasBudget) {
    // If only one item, show it without separator
    if (hasLocation && !hasBudget) {
      return LynewedLocationRow(location: location!, distance: distance);
    }
    
    if (!hasLocation && hasBudget) {
      return LynewedBudgetRow(budget: budget!);
    }
    
    // Both items - show with separator
    return LynewedInlineInfoRow(
      left: LynewedLocationRow(location: location!, distance: distance),
      right: LynewedBudgetRow(budget: budget!),
    );
  }
}
