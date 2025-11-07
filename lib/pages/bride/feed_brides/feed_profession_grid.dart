import 'package:flutter/material.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/profession_display_helper.dart';

/// Widget pour afficher les checkboxes de professions en grille 3 colonnes (4-4-4) pour FeedBridesWidget
class FeedProfessionGrid extends StatelessWidget {
  final QueryFiltersStruct? filters;
  final Function(Function(QueryFiltersStruct) updateFn) onFiltersUpdate;
  final Function() onSetState;

  const FeedProfessionGrid({
    super.key,
    required this.filters,
    required this.onFiltersUpdate,
    required this.onSetState,
  });

  // Liste des 12 professions dans l'ordre souhaité (4-4-4)
  static const List<List<Profession>> professionColumns = [
    // Colonne 1 (4 professions)
    [
      Profession.PHOTOGRAPHER,
      Profession.FILMMAKER,
      Profession.PLANNER,
      Profession.MAKEUP,
    ],
    // Colonne 2 (4 professions)
    [
      Profession.HAIRDRESSER,
      Profession.MAKEUPARTIST,
      Profession.EVENTDESIGNER,
      Profession.BRIDALDESIGNER,
    ],
    // Colonne 3 (4 professions)
    [
      Profession.VENUE,
      Profession.BRIDALSHOP,
      Profession.FLORIST,
      Profession.PHOTOMOVIE,
    ],
  ];

  Widget _buildProfessionCheckbox(
    BuildContext context,
    Profession profession,
  ) {
    final isSelected = filters?.professions.contains(profession) ?? false;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Theme(
          data: ThemeData(
            checkboxTheme: CheckboxThemeData(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            unselectedWidgetColor: FlutterFlowTheme.of(context).secondaryText,
          ),
          child: Checkbox(
            value: isSelected,
            onChanged: (newValue) async {
              if (newValue == true) {
                onFiltersUpdate(
                  (e) => e
                    ..updateProfessions(
                      (e) => e.add(profession),
                    ),
                );
              } else {
                onFiltersUpdate(
                  (e) => e
                    ..updateProfessions(
                      (e) => e.remove(profession),
                    ),
                );
              }
              onSetState();
            },
            side: (FlutterFlowTheme.of(context).secondaryText != null)
                ? BorderSide(
                    width: 2,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  )
                : null,
            activeColor: FlutterFlowTheme.of(context).primary,
            checkColor: FlutterFlowTheme.of(context).info,
          ),
        ),
        Text(
          getProfessionDisplayName(profession),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Haas Grot Text Trial',
                fontSize: 12.0,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: professionColumns.map((columnProfessions) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnProfessions
              .map((prof) => _buildProfessionCheckbox(context, prof))
              .toList(),
        );
      }).toList(),
    );
  }
}
