import 'package:flutter/material.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/core/design/design.dart';
import '/flutter_flow/profession_display_helper.dart';

/// Widget pour afficher les professions en chips Wrap pour FeedBridesWidget
/// Adapte les professions affichées selon le marché utilisateur (IN vs GLOBAL)
/// Design System v3 compliant - Same as Map filter_sheet.dart
class FeedProfessionGrid extends StatelessWidget {
  final QueryFiltersStruct? filters;
  final Function(Function(QueryFiltersStruct) updateFn) onFiltersUpdate;
  final Function() onSetState;
  final String userMarket;

  const FeedProfessionGrid({
    super.key,
    required this.filters,
    required this.onFiltersUpdate,
    required this.onSetState,
    this.userMarket = 'GLOBAL',
  });

  @override
  Widget build(BuildContext context) {
    final availableProfessions = getAvailableProfessions(userMarket);
    final selectedProfessions = filters?.professions ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title - Design System v3
        Text(
          'Filter by profession',
          style: LynewedTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Wrap with FilterChips - Same as Map filter_sheet
        Wrap(
          spacing: LynewedSpacing.sm,
          runSpacing: LynewedSpacing.sm,
          children: availableProfessions.map((profession) {
            final isSelected = selectedProfessions.contains(profession);
            
            return FilterChip(
              label: Text(
                getProfessionDisplayName(profession),
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : LynewedColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              backgroundColor: LynewedColors.gray200,
              selectedColor: LynewedColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false, // Cleaner look with color change only
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // 4px radius - Design System
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (selected) {
                if (selected) {
                  onFiltersUpdate(
                    (e) => e..updateProfessions((e) => e.add(profession)),
                  );
                } else {
                  onFiltersUpdate(
                    (e) => e..updateProfessions((e) => e.remove(profession)),
                  );
                }
                onSetState();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
