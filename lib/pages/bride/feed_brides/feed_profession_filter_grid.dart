import 'package:flutter/material.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/profession_display_helper.dart';

/// Widget pour afficher les checkboxes de professions en grille 3 colonnes pour FeedBridesWidget
class FeedProfessionFilterGrid extends StatelessWidget {
  final QueryFiltersStruct? filters;
  final Function(Function(QueryFiltersStruct) updateFn) onFiltersUpdate;
  final Function() onSetState;

  const FeedProfessionFilterGrid({
    super.key,
    required this.filters,
    required this.onFiltersUpdate,
    required this.onSetState,
  });

  // Liste des 12 professions dans l'ordre souhaité (3x4 = 12 professions)
  static const List<Profession> allProfessions = [
    Profession.PHOTOGRAPHER,
    Profession.FILMMAKER,
    Profession.PLANNER,
    Profession.MAKEUP,
    Profession.HAIRDRESSER,
    Profession.MAKEUPARTIST,
    Profession.EVENTDESIGNER,
    Profession.BRIDALDESIGNER,
    Profession.VENUE,
    Profession.BRIDALSHOP,
    Profession.FLORIST,
    Profession.PHOTOMOVIE,
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
            onChanged: (newValue) {
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
        Expanded(
          child: Text(
            getProfessionDisplayName(profession),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Diviser en 3 colonnes : 4-4-4 = 12 professions
    final column1 = allProfessions.take(4).toList();
    final column2 = allProfessions.skip(4).take(4).toList();
    final column3 = allProfessions.skip(8).take(4).toList();

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Colonne 1 (4 professions)
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: column1.map((prof) => _buildProfessionCheckbox(context, prof)).toList(),
        ),
        // Colonne 2 (4 professions)
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: column2.map((prof) => _buildProfessionCheckbox(context, prof)).toList(),
        ),
        // Colonne 3 (4 professions)
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: column3.map((prof) => _buildProfessionCheckbox(context, prof)).toList(),
        ),
      ],
    );
  }
}
